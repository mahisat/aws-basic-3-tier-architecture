# AWS Three-Tier Architecture (Terraform + React + Node.js + RDS)

A **Zero-to-Hero learning project**: deploy a Todo app on AWS with a classic **three-tier** design (React on EC2, Node API on EC2, RDS MySQL), managed by **Terraform**, with optional **GitHub Actions** deployment.

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
| [`docs/`](docs/) | **Zero-to-Hero blog series** (Medium-ready Markdown) |

## Learning path (recommended order)

1. Read **[docs/series-00-zero-to-hero-index.md](docs/series-00-zero-to-hero-index.md)**
2. **[Part 1 — Terraform + AWS](docs/01-terraform-aws-zero-to-hero.md)** — infrastructure, every Terraform file, debugging
3. **[Part 2 — GitHub Actions + OIDC](docs/02-github-actions-oidc-zero-to-hero.md)** — CI/CD, trust policies, new GitHub `sub` claim format, architecture review
4. **[Linux commands reference](docs/linux-commands-reference.md)** — `ssh`, `systemctl`, `curl`, `terraform`, etc.

## Prerequisites

- AWS account and IAM permissions ([`terraform/IAM.md`](terraform/IAM.md), [`iam-terraform-least-privilege.json`](terraform/iam-terraform-least-privilege.json))
- [Terraform](https://www.terraform.io/downloads) >= 1.5
- Node.js 20+ for local dev
- **Public** GitHub repo URL in `terraform.tfvars` for EC2 `git clone` bootstrap (private repos — upcoming blog)

## Quick start — Terraform

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

## GitHub Actions (after Part 1)

Configure secrets: `AWS_DEPLOY_ROLE_ARN`, `EC2_PRIVATE_KEY`, `FRONTEND_EC2_PUBLIC_IP`, `BACKEND_EC2_PRIVATE_IP`. See Part 2 and [`terraform/IAM.md`](terraform/IAM.md).

## Bootstrap / debug logs (EC2)

| Log | Purpose |
|-----|---------|
| `/var/log/cloud-init-output.log` | user_data |
| `/var/log/backend-setup.log` | Backend bootstrap |
| `/var/log/frontend-setup.log` | Frontend bootstrap |
| `journalctl -u todo-backend` | API service |

Manual repair: [`terraform/install-backend-service.sh`](terraform/install-backend-service.sh) (run as root on backend).

## Cost warning

**NAT Gateway** and **RDS** bill while resources exist. Destroy the stack when not learning.

## License

MIT (application). Adjust for your fork.
