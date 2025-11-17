#!/bin/bash

# Pomma Holidays - Production Deployment Script
# Server: 139.84.211.200
# Username: root
# Repository: https://github.com/teqmatessolutions-gif/pomma-latest.git

set -e  # Exit on error

echo "🚀 Starting Pomma Holidays Deployment to Production Server..."
echo ""

# Server Configuration
SERVER_IP="139.84.211.200"
SERVER_USER="root"
PROJECT_DIR="/var/www/resort/Resort_first"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Pomma Holidays Production Deployment${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${YELLOW}Server: ${SERVER_USER}@${SERVER_IP}${NC}"
echo -e "${YELLOW}Project Directory: ${PROJECT_DIR}${NC}"
echo ""

# Check if we're running locally or on server
if [ "$HOSTNAME" != "$SERVER_IP" ] && [ "$SSH_CLIENT" == "" ]; then
    echo -e "${YELLOW}⚠️  This script should be run on the server.${NC}"
    echo -e "${YELLOW}Connecting to server and running deployment...${NC}"
    echo ""
    
    # Create a temporary deployment script on the server
    ssh ${SERVER_USER}@${SERVER_IP} << 'ENDSSH'
cd /var/www/resort/Resort_first || { echo "Project directory not found!"; exit 1; }

# Update Git remote if needed
git remote set-url origin https://github.com/teqmatessolutions-gif/pomma-latest.git 2>/dev/null || true

# Pull latest code
echo "📥 Pulling latest code..."
git fetch origin main
git pull origin main

# Verify latest commit
echo ""
echo "Latest commit:"
git log -1 --oneline
echo ""

# Run database migration
echo "🗄️  Running database migration..."
cd ResortApp
source venv/bin/activate
python3 migrate_database.py || echo "⚠️  Migration script not found, skipping..."

# Update Python dependencies
echo ""
echo "📦 Updating Python dependencies..."
pip install -r requirements.txt --upgrade 2>/dev/null || pip install -r requirements_production.txt --upgrade 2>/dev/null || echo "⚠️  Requirements file not found"

# Build Dashboard
echo ""
echo "🏗️  Building Dashboard frontend..."
cd ../dasboard
npm install --legacy-peer-deps
npm run build

# Build Userend
echo ""
echo "🏗️  Building Userend frontend..."
cd ../userend/userend
npm install --legacy-peer-deps
npm run build

# Restart services
echo ""
echo "🔄 Restarting services..."
cd /var/www/resort/Resort_first/ResortApp
systemctl restart resort.service 2>/dev/null || systemctl restart pommoapi.service 2>/dev/null || echo "⚠️  Service not found"
systemctl restart nginx

# Verify deployment
echo ""
echo "✅ Deployment completed!"
echo ""
echo "Service status:"
systemctl status resort.service --no-pager -l | head -n 5 || systemctl status pommoapi.service --no-pager -l | head -n 5
echo ""
systemctl status nginx --no-pager -l | head -n 5
ENDSSH

else
    # Running on server directly
    cd ${PROJECT_DIR} || { echo -e "${RED}Project directory not found!${NC}"; exit 1; }

    echo -e "${GREEN}Step 1/8: Updating Git repository...${NC}"
    git remote set-url origin https://github.com/teqmatessolutions-gif/pomma-latest.git 2>/dev/null || true
    git fetch origin main
    git pull origin main
    echo -e "${GREEN}✅ Code updated${NC}"
    echo "Latest commit:"
    git log -1 --oneline
    echo ""

    echo -e "${GREEN}Step 2/8: Running database migration...${NC}"
    cd ResortApp
    source venv/bin/activate
    python3 migrate_database.py || echo -e "${YELLOW}⚠️  Migration script not found${NC}"
    echo ""

    echo -e "${GREEN}Step 3/8: Updating Python dependencies...${NC}"
    pip install -r requirements.txt --upgrade 2>/dev/null || pip install -r requirements_production.txt --upgrade 2>/dev/null || echo -e "${YELLOW}⚠️  Requirements file not found${NC}"
    echo ""

    echo -e "${GREEN}Step 4/8: Building Dashboard frontend...${NC}"
    cd ../dasboard
    npm install --legacy-peer-deps
    npm run build
    echo ""

    echo -e "${GREEN}Step 5/8: Building Userend frontend...${NC}"
    cd ../userend/userend
    npm install --legacy-peer-deps
    npm run build
    echo ""

    echo -e "${GREEN}Step 6/8: Restarting services...${NC}"
    cd /var/www/resort/Resort_first/ResortApp
    systemctl restart resort.service 2>/dev/null || systemctl restart pommoapi.service 2>/dev/null || echo -e "${YELLOW}⚠️  Service not found${NC}"
    systemctl restart nginx
    echo ""

    echo -e "${GREEN}Step 7/8: Verifying deployment...${NC}"
    sleep 3
    systemctl status resort.service --no-pager -l | head -n 10 || systemctl status pommoapi.service --no-pager -l | head -n 10
    systemctl status nginx --no-pager -l | head -n 10
    echo ""

    echo -e "${GREEN}✅ Deployment completed successfully!${NC}"
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}🎉 Deployment Finished!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${YELLOW}📋 Verify deployment:${NC}"
echo "  - Admin Dashboard: https://teqmates.com/pommaadmin/"
echo "  - Userend: https://teqmates.com/pommaholidays/"
echo "  - Check logs: ssh ${SERVER_USER}@${SERVER_IP} 'journalctl -u resort.service -n 50'"
echo ""

