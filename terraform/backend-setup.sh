#!/bin/bash
set -euo pipefail

echo "Starting backend setup..."

dnf update -y
dnf install -y git nginx mysql

curl -fsSL https://rpm.nodesource.com/setup_20.x | bash -
dnf install -y nodejs

mkdir -p /home/ec2-user/app
cd /home/ec2-user/app

if [ ! -d ".git" ]; then
  git clone "${github_repo}" .
else
  git pull origin main
fi

cd backend
npm ci
npm run build

cat > .env << EOF
NODE_ENV=production
PORT=5000
DB_HOST=${db_endpoint}
DB_PORT=3306
DB_USER=${db_user}
DB_PASSWORD=${db_password}
DB_NAME=${db_name}
EOF

echo "Waiting for RDS to be ready..."
DB_HOST_ONLY="$(echo "${db_endpoint}" | cut -d: -f1)"
for i in $(seq 1 30); do
  if mysql -h "$DB_HOST_ONLY" -u "${db_user}" -p"${db_password}" -e "SELECT 1" 2>/dev/null; then
    echo "RDS is ready!"
    break
  fi
  echo "Attempt $i - RDS not ready yet, waiting..."
  sleep 10
done

npm install -g pm2
pm2 start dist/server.js --name node-app
pm2 startup systemd -u ec2-user --hp /home/ec2-user
pm2 save

echo "Backend setup completed!"
