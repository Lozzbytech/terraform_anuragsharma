#!/bin/bash
# Log execution outputs for remote debugging tasks
set -e
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "=== 1. Installing System Dependencies ==="
apt-get update -y

apt-get install -y python3-pip python3.14-venv

apt-get install -y  nodejs npm

echo "=== 2. Downloading Source Code ==="

cd /home/ubuntu
# Injects the target repository URL passed from main.tf
git clone ${REPO_URL}


chown -R ubuntu:ubuntu /home/ubuntu/ares

echo "=== 3. Starting Backend (Flask) ==="
cd /home/ubuntu/ares/ares/backend

su - ubuntu -c "cd /home/ubuntu/ares/ares/backend && python3 -m venv venv"

./venv/bin/pip install --upgrade pip
if [ -f requirements.txt ]; then
  ./venv/bin/pip install -r requirements.txt
else
  ./venv/bin/pip install flask
fi

chown -R ubuntu:ubuntu /home/ubuntu/ares/ares/backend/venv
# Launches the Flask backend on port 5000 in the background
nohup su - ubuntu -c "cd /home/ubuntu/ares/ares/backend && ./venv/bin/python app.py" > flask.log 2>&1 &

echo "=== 4. Starting Frontend (Express) ==="
cd /home/ubuntu/ares/ares/frontend
if [ -f package.json ]; then
  npm install
else
  npm install express
fi
# Launches the Express frontend on port 3000 in the background
nohup node server.js > express.log 2>&1 &

echo "=== Setup complete! ==="
