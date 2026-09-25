#!/bin/bash
set -euo pipefail
exec > >(tee -a /var/log/frontend-setup.log) 2>&1

echo "=== Frontend setup started at $(date -Is) ==="

dnf update -y
dnf install -y git nginx

curl -fsSL https://rpm.nodesource.com/setup_20.x | bash -
dnf install -y nodejs

if command -v setsebool >/dev/null 2>&1; then
  setsebool -P httpd_can_network_connect 1 || true
fi

for i in $(seq 1 36); do
  if curl -fsS --connect-timeout 5 https://github.com >/dev/null 2>&1; then
    break
  fi
  sleep 10
done

install -d -o ec2-user -g ec2-user -m 755 /home/ec2-user/app

CLONED=0
for i in $(seq 1 36); do
  if [ -f /home/ec2-user/app/frontend/package.json ]; then
    CLONED=1
    break
  fi
  rm -rf /home/ec2-user/app/.git /home/ec2-user/app/frontend 2>/dev/null || true
  if sudo -u ec2-user git clone --depth 1 "${github_repo}" /home/ec2-user/app; then
    CLONED=1
    break
  fi
  sleep 10
done

if [ "$CLONED" -ne 1 ] || [ ! -f /home/ec2-user/app/frontend/package.json ]; then
  echo "FATAL: could not clone repo or frontend/package.json is missing."
  exit 1
fi

chown -R ec2-user:ec2-user /home/ec2-user/app

sudo -u ec2-user bash << 'FRONTEND_BUILD'
set -euo pipefail
cd /home/ec2-user/app/frontend
cat > .env.production << 'ENVFILE'
VITE_API_BASE_URL=${vite_api_base_url}
ENVFILE
npm ci
npm run build
FRONTEND_BUILD

mkdir -p /var/www/frontend
cp -r /home/ec2-user/app/frontend/dist/* /var/www/frontend/

cat > /etc/nginx/conf.d/frontend.conf << 'NGINX_CONF_EOF'
${nginx_conf}
NGINX_CONF_EOF

systemctl enable nginx
systemctl restart nginx

echo "=== Frontend setup completed at $(date -Is) ==="
