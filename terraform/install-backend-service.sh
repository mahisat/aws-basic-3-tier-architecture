#!/bin/bash
# Run on backend EC2 as root (SSM). Installs deps, builds TypeScript, starts systemd unit.
set -euo pipefail

APP_DIR=/home/ec2-user/app/backend
UNIT=/etc/systemd/system/todo-backend.service

if [ ! -f "$APP_DIR/package.json" ]; then
  echo "Missing $APP_DIR — clone the repo under /home/ec2-user/app first."
  exit 1
fi

if [ ! -f "$APP_DIR/.env" ]; then
  echo "Missing $APP_DIR/.env — set DB_* and PORT=5000."
  exit 1
fi

if ! command -v node >/dev/null 2>&1; then
  curl -fsSL https://rpm.nodesource.com/setup_20.x | bash -
  dnf install -y nodejs git
fi

chown -R ec2-user:ec2-user /home/ec2-user/app

echo "npm ci && npm run build..."
sudo -u ec2-user bash << 'EOF'
set -euo pipefail
cd /home/ec2-user/app/backend
npm ci
npm run build
test -f dist/server.js
EOF

cat > "$UNIT" << 'EOF'
[Unit]
Description=Todo API (Node.js backend)
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=ec2-user
Group=ec2-user
WorkingDirectory=/home/ec2-user/app/backend
EnvironmentFile=/home/ec2-user/app/backend/.env
ExecStart=/usr/bin/node dist/server.js
Restart=on-failure
RestartSec=5
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable todo-backend
systemctl restart todo-backend
systemctl status todo-backend --no-pager
curl -sf http://127.0.0.1:5000/health && echo " Backend health OK"
