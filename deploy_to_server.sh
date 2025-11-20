#!/bin/bash
# Complete deployment script for Resort Demo

cd /var/www/resort/resort_production

# Pull latest code
echo "Pulling latest code..."
git pull origin main

# Build Dashboard
echo "Building Dashboard..."
cd dasboard
npm install --legacy-peer-deps
npm run build
cd ..

# Build Userend
echo "Building Userend..."
cd userend/userend
npm install --legacy-peer-deps
npm run build
cd ../..

# Restart services
echo "Restarting services..."
systemctl restart resort.service
systemctl reload nginx

echo "Deployment completed!"

