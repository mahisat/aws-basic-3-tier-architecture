# Terraform IAM (least privilege)

This stack creates VPC, NAT, two EC2 instances, RDS MySQL, key pair, and an EC2 instance profile for SSM.

## Policies in this repo

| File | Use |
|------|-----|
| `iam-terraform-least-privilege.json` | IAM user or GitHub OIDC role for `terraform plan` / `terraform apply` |
| `iam-github-deploy-least-privilege.json` | GitHub OIDC role for backend deploy workflow (SSM) |

Replace `my-project` in IAM resource ARNs if you change `var.project`.

## Terraform runner (`AWS_TERRAFORM_ROLE_ARN`)

Attach `iam-terraform-least-privilege.json` (adjust project prefix) plus:

- **Trust policy**: GitHub OIDC `token.actions.githubusercontent.com` for your repo/branch.
- **`iam:PassRole`**: scoped to `${project}-ec2-ssm-role` only (already in the JSON).

### Service actions (summary)

| AWS service | Why |
|-------------|-----|
| **EC2 (VPC)** | VPC, subnets, IGW, route tables, NAT gateway, EIP, security groups, instances, key pair |
| **EC2 Describe** | AMI/AZ lookups (`data.aws_ami`, `data.aws_availability_zones`) |
| **RDS** | DB instance, DB subnet group, tags |
| **IAM** | Create/delete instance profile + role; attach `AmazonSSMManagedInstanceCore` |

No S3/DynamoDB permissions are included (local state). If you add a remote backend, extend the policy with scoped S3 and `dynamodb:PutItem` / `GetItem` / `DeleteItem` on the lock table.

## Backend deploy runner (`AWS_DEPLOY_ROLE_ARN`)

Attach `iam-github-deploy-least-privilege.json`. Frontend deploy uses SSH and does **not** need AWS API access (only `EC2_PRIVATE_KEY` and `FRONTEND_EC2_PUBLIC_IP` secrets).

Optional hardening: replace `"Resource": "*"` on `ssm:SendCommand` with specific instance ARNs or use a tag condition on `aws:ResourceTag/Name`.

## After apply

1. Copy `terraform/<project>-deployer-key.pem` → GitHub secret `EC2_PRIVATE_KEY`.
2. `terraform output -raw frontend_public_ip` → `FRONTEND_EC2_PUBLIC_IP`.
3. Configure OIDC roles and secrets per root README (if present) or workflow comments.
