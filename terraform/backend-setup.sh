#!/bin/bash
set -e

echo "Starting backend setup..."

# Update system
yum update -y
yum install -y git nodejs npm curl mysql

# Create app directory
mkdir -p /home/ec2-user/app
cd /home/ec2-user/app

# Clone repository (or pull if exists)
if [ ! -d ".git" ]; then
  git clone ${github_repo} .
else
  git pull origin main
fi

# Install dependencies
cd backend
npm install

# Create .env file with database connection
cat > .env << EOF
NODE_ENV=production
PORT=5000
DB_HOST=${db_endpoint}
DB_USER=${db_user}
DB_PASSWORD=${db_password}
DB_NAME=${db_name}
EOF

# Wait for RDS to be ready (retry 30 times with 10 second intervals)
echo "Waiting for RDS to be ready..."
for i in {1..30}; do
  if mysql -h "$(echo ${db_endpoint} | cut -d: -f1)" -u ${db_user} -p${db_password} -e "SELECT 1" 2>/dev/null; then
    echo "RDS is ready!"
    break
  fi
  echo "Attempt $i - RDS not ready yet, waiting..."
  sleep 10
done

# Install PM2 globally for process management
npm install -g pm2

# Start the app with PM2
pm2 start "npm start" --name "node-app"
pm2 startup
pm2 save

echo "Backend setup completed!"
