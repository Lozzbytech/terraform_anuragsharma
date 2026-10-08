#!/bin/bash
set -e
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "=== 1. Installing System Dependencies ==="
apt-get update -y
apt-get install -y nodejs npm

echo "=== 2. Downloading Source Code ==="
cd /home/ubuntu
git clone ${REPO_URL}
chown -R ubuntu:ubuntu /home/ubuntu/ares

echo "=== 3. Injecting backend URL ==="
cd /home/ubuntu/ares/ares/frontend

sed -i "s|const backendUrl = .*;|const backendUrl = 'http://${BACKEND_IP}:5000/api/message';|g" public/index.html

echo "=== 4. launching Frontend (Express) ==="
cd /home/ubuntu/ares/ares/frontend
if [ -f package.json ]; then
su - ubuntu -c "cd /home/ubuntu/ares/ares/frontend && npm install"
else
su - ubuntu -c "cd /home/ubuntu/ares/ares/frontend && npm install express"
fi 

nohup su - ubuntu -c "cd /home/ubuntu/ares/ares/frontend && node server.js" > express.log 2>&1 &

echo "=== 4. Frontend Setup Complete ==="