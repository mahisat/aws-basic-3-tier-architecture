#!/bin/bash
set -e

echo "Starting frontend setup..."

# Update system
yum update -y
yum install -y git nodejs npm curl

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
cd frontend
npm install

# Build React app
npm run build

# Install PM2 globally for process management
npm install -g pm2

# Start the app with PM2
pm2 start "npm start" --name "react-app"
pm2 startup
pm2 save

echo "Frontend setup completed!"
