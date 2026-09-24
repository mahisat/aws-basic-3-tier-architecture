#!/bin/bash
set -euo pipefail

echo "Starting frontend setup..."

dnf update -y
dnf install -y git nginx

curl -fsSL https://rpm.nodesource.com/setup_20.x | bash -
dnf install -y nodejs

mkdir -p /home/ec2-user/app
cd /home/ec2-user/app

if [ ! -d ".git" ]; then
  git clone "${github_repo}" .
else
  git pull origin main
fi

cd frontend
npm ci
npm run build

mkdir -p /var/www/frontend
cp -r dist/* /var/www/frontend/

cat > /etc/nginx/conf.d/frontend.conf << EOF
server {
    listen 80;
    server_name _;
    root /var/www/frontend;
    index index.html;

    location / {
        try_files \$uri \$uri/ /index.html;
    }

    location /api/ {
        proxy_pass http://${backend_host}:5000;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

systemctl enable nginx
systemctl restart nginx

echo "Frontend setup completed!"
