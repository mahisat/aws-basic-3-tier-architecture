# AWS Three-Tier Architecture (Console + Terraform + React + Node.js + RDS)

**Repository:** [AWS Three Tier Basic](https://github.com/mahisat/aws-basic-3-tier-architecture)

A **Zero-to-Hero learning project**: deploy a Todo app on AWS with a classic **three-tier** design (React on EC2, Node API on EC2, RDS MySQL). Start in **Part 1** by creating every resource in the **AWS Management Console** (no Terraform). Then use **Part 2** to reproduce the same stack with **Terraform**, and **Part 3** for optional **GitHub Actions** deployment.

## Learning path

| Step | What you do | In this repo |
|------|-------------|--------------|
| **Part 1 — AWS Console** | VPC, NAT, security groups, RDS, EC2, user-data bootstrap (click-by-click) | Bootstrap scripts under [`terraform/`](terraform/) (`backend-setup.sh`, `frontend-setup.sh`, nginx template, systemd unit) |
| **Part 2 — Terraform** | Same architecture as code (`terraform apply`) | [`terraform/*.tf`](terraform/), [`terraform.tfvars.example`](terraform/terraform.tfvars.example) |
| **Part 3 — GitHub Actions** | OIDC deploy to EC2 (no long-lived AWS keys in GitHub) | [`.github/workflows/`](.github/workflows/), [`terraform/IAM.md`](terraform/IAM.md) |

Follow the blog posts **in order** — Part 1 explains networking and tiers; Part 2 maps those resources to Terraform; Part 3 automates deploys.

## Architecture

```text
Internet → Frontend EC2 (nginx :80, static UI, /api reverse proxy)
         → Backend EC2 (:5000, private subnet)
         → RDS MySQL (private subnets, two AZs for subnet group)
Private outbound traffic → NAT Gateway → Internet Gateway
```

## Repository structure

| Path | Description |
|------|-------------|
| [`terraform/`](terraform/) | VPC, EC2, RDS, IAM, bootstrap scripts, IAM policy JSON |
| [`frontend/`](frontend/) | React (Vite) SPA |
| [`backend/`](backend/) | Express + TypeScript API |
| [`.github/workflows/`](.github/workflows/) | Frontend (SSH) and backend (SSM + OIDC) deploy |

## Documentation (Zero to Hero blog)

Tutorials for this repo live on **GitHub Pages** — read them **in order**:

| Step | Link |
|------|------|
| Series home | [Zero to Hero Terraform AWS](https://mahisat.github.io/terraform-aws-zero-to-hero/) |
| **Part 1 — AWS Console** | [Build in the Management Console](https://mahisat.github.io/terraform-aws-zero-to-hero/posts/part-1-aws-console-three-tier/) |
| Part 2 — Terraform + AWS | [Build a three-tier architecture](https://mahisat.github.io/terraform-aws-zero-to-hero/posts/part-2-terraform-aws-three-tier/) |
| Part 3 — GitHub Actions + OIDC | [Automated deployment](https://mahisat.github.io/terraform-aws-zero-to-hero/posts/part-3-github-actions-oidc/) |
| Appendix — Terraform & project files | [Deep dive](https://mahisat.github.io/terraform-aws-zero-to-hero/reference/appendix-terraform-and-project-files/) |
| Linux commands reference | [ssh, systemctl, curl, terraform, …](https://mahisat.github.io/terraform-aws-zero-to-hero/reference/linux-commands-reference/) |

Repo-specific IAM notes remain in [`terraform/IAM.md`](terraform/IAM.md).

## Prerequisites

**Part 1 (Console):** AWS account with permissions to create VPC, EC2, RDS, IAM roles, and NAT Gateway. No Terraform or local Node install required for the infrastructure lab (the EC2 user-data scripts install app dependencies on the instances).

**Part 2+ (this repo automation):**

- IAM permissions ([`terraform/IAM.md`](terraform/IAM.md), [`iam-terraform-least-privilege.json`](terraform/iam-terraform-least-privilege.json))
- [Terraform](https://www.terraform.io/downloads) >= 1.5
- Node.js 20+ for local dev
- **Public** GitHub repo URL in `terraform.tfvars` for EC2 `git clone` bootstrap (private repos — see Part 3 on the blog)

## Quick start — AWS Console (Part 1)

1. Open **[Part 1 — Build in the Management Console](https://mahisat.github.io/terraform-aws-zero-to-hero/posts/part-1-aws-console-three-tier/)** and work through it with this repo open.
2. When the post asks for bootstrap scripts, use the files in [`terraform/`](terraform/):
   - [`backend-setup.sh`](terraform/backend-setup.sh) — backend EC2 user data (replace `${…}` placeholders per the post)
   - [`frontend-setup.sh`](terraform/frontend-setup.sh) — frontend EC2 user data
   - [`nginx-frontend.conf.tpl`](terraform/nginx-frontend.conf.tpl) — nginx config (set backend private IP)
   - [`todo-backend.service`](terraform/todo-backend.service) — systemd unit pasted into backend user data
3. Use a **public** clone URL for this repository (default in the post: `https://github.com/mahisat/aws-basic-3-tier-architecture`).
4. When finished learning, tear down resources in the console (order is in the Part 1 post). **Release Elastic IPs** after deleting the NAT Gateway to avoid ongoing charges.

Expect about **45–90 minutes** on first run (RDS and cloud-init take most of the wait).

## Quick start — Terraform (Part 2)

```bash
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
# Edit github_repo_url, db_password, project

cd terraform
terraform init
terraform plan
terraform apply

terraform output frontend_public_ip
terraform output -raw backend_private_ip
```

Open `http://<frontend_public_ip>/`. When finished: `terraform destroy`.

## Quick start — local dev

```bash
# Backend
cd backend && cp .env.example .env && npm install && npm run dev

# Frontend (separate terminal)
cd frontend && npm install && npm run dev
```

## GitHub Actions (Part 3)

Configure secrets: `AWS_DEPLOY_ROLE_ARN`, `EC2_PRIVATE_KEY`, `FRONTEND_EC2_PUBLIC_IP`, `BACKEND_EC2_PRIVATE_IP`. See [Part 3 on the blog](https://mahisat.github.io/terraform-aws-zero-to-hero/posts/part-3-github-actions-oidc/) and [`terraform/IAM.md`](terraform/IAM.md).

## Bootstrap / debug logs (EC2)

| Log | Purpose |
|-----|---------|
| `/var/log/cloud-init-output.log` | user_data |
| `/var/log/backend-setup.log` | Backend bootstrap |
| `/var/log/frontend-setup.log` | Frontend bootstrap |
| `journalctl -u todo-backend` | API service |

Manual repair: [`terraform/install-backend-service.sh`](terraform/install-backend-service.sh) (run as root on backend).

## Cost warning

**NAT Gateway** and **RDS** bill while resources exist. Destroy the stack when not learning (console tear-down in Part 1, or `terraform destroy` in Part 2).

## License
This project is licensed under the Apache License, Version 2.0. See the LICENSE file for the full text.
