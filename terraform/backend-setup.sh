#!/bin/bash
# Backend EC2 first-boot (user_data). Log: /var/log/backend-setup.log
set -euo pipefail
exec > >(tee -a /var/log/backend-setup.log) 2>&1

echo "=== Backend setup started at $(date -Is) ==="

dnf update -y
dnf install -y git

curl -fsSL https://rpm.nodesource.com/setup_20.x | bash -
dnf install -y nodejs

echo "Waiting for network..."
for i in $(seq 1 36); do
  if curl -fsS --connect-timeout 5 https://github.com >/dev/null 2>&1; then
    echo "Network is up."
    break
  fi
  echo "Network not ready (attempt $i/36)..."
  sleep 10
done

install -d -o ec2-user -g ec2-user -m 755 /home/ec2-user/app

echo "Cloning repository..."
CLONED=0
for i in $(seq 1 36); do
  if [ -f /home/ec2-user/app/backend/package.json ]; then
    CLONED=1
    break
  fi
  rm -rf /home/ec2-user/app/.git 2>/dev/null || true
  if sudo -u ec2-user git clone --depth 1 "${github_repo}" /home/ec2-user/app; then
    CLONED=1
    break
  fi
  echo "git clone failed (attempt $i/36), retrying..."
  sleep 10
done

if [ "$CLONED" -ne 1 ] || [ ! -f /home/ec2-user/app/backend/package.json ]; then
  echo "FATAL: clone failed or backend/package.json missing."
  exit 1
fi

chown -R ec2-user:ec2-user /home/ec2-user/app

cat > /home/ec2-user/app/backend/.env << 'ENVFILE'
NODE_ENV=production
PORT=5000
DB_HOST=${db_endpoint}
DB_PORT=3306
DB_USER=${db_user}
DB_PASSWORD=${db_password}
DB_NAME=${db_name}
ENVFILE
chown ec2-user:ec2-user /home/ec2-user/app/backend/.env
chmod 600 /home/ec2-user/app/backend/.env

echo "Installing dependencies and compiling TypeScript..."
sudo -u ec2-user bash << 'APP_SETUP'
set -euo pipefail
cd /home/ec2-user/app/backend
npm ci
npm run build
test -f dist/server.js
APP_SETUP

echo "Waiting for RDS to accept connections on port 3306..."
RDS_READY=0
for i in $(seq 1 36); do
  if timeout 3 bash -c "echo >/dev/tcp/${db_endpoint}/3306" 2>/dev/null; then
    echo "RDS endpoint is reachable on 3306."
    RDS_READY=1
    break
  fi
  echo "RDS not reachable yet (attempt $i/36)..."
  sleep 10
done

if [ "$RDS_READY" -ne 1 ]; then
  echo "FATAL: RDS not ready."
  exit 1
fi

cat > /etc/systemd/system/todo-backend.service << 'UNITEOF'
${systemd_unit}
UNITEOF

systemctl daemon-reload
systemctl enable todo-backend
systemctl restart todo-backend

sleep 2
systemctl is-active --quiet todo-backend
curl -sf http://127.0.0.1:5000/health >/dev/null

echo "=== Backend setup completed at $(date -Is) ==="
