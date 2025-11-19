#!/bin/bash
# Resort Demo - SSH Deployment Script
# Run this on the server via SSH

set -e

echo "=========================================="
echo "  Resort Demo - Server Deployment"
echo "=========================================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Configuration
DEPLOY_PATH="/var/www/resort/resort_production"
GIT_REPO="https://github.com/teqmatessolutions-gif/Resort.git"
SERVICE_NAME="resort.service"

echo -e "${YELLOW}Step 1: Updating code from Git...${NC}"
mkdir -p /var/www/resort
cd /var/www/resort

if [ -d "resort_production" ]; then
    echo "Pulling latest changes..."
    cd resort_production
    git pull origin main
else
    echo "Cloning repository..."
    git clone $GIT_REPO resort_production
    cd resort_production
fi

echo -e "${GREEN}✓ Code updated${NC}"
echo ""

echo -e "${YELLOW}Step 2: Setting up backend...${NC}"
cd ResortApp

# Create virtual environment if needed
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
fi

# Install/update dependencies
source venv/bin/activate
pip install --upgrade pip --quiet
pip install -r requirements.txt --quiet

echo -e "${GREEN}✓ Backend dependencies installed${NC}"
echo ""

echo -e "${YELLOW}Step 3: Building admin dashboard...${NC}"
cd ../dasboard
npm install --legacy-peer-deps --silent
npm run build

echo -e "${GREEN}✓ Admin dashboard built${NC}"
echo ""

echo -e "${YELLOW}Step 4: Building user frontend...${NC}"
cd ../userend/userend
npm install --legacy-peer-deps --silent
npm run build

echo -e "${GREEN}✓ User frontend built${NC}"
echo ""

echo -e "${YELLOW}Step 5: Setting up systemd service...${NC}"
cd ../../ResortApp
sudo cp resort.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable $SERVICE_NAME

echo -e "${GREEN}✓ Systemd service configured${NC}"
echo ""

echo -e "${YELLOW}Step 6: Setting permissions...${NC}"
sudo mkdir -p /var/log/resort
sudo mkdir -p /var/run/resort
sudo chown -R www-data:www-data /var/www/resort/resort_production
sudo chown -R www-data:www-data /var/log/resort
sudo chown -R www-data:www-data /var/run/resort

echo -e "${GREEN}✓ Permissions set${NC}"
echo ""

echo -e "${YELLOW}Step 7: Restarting service...${NC}"
sudo systemctl restart $SERVICE_NAME
sleep 2
sudo systemctl status $SERVICE_NAME --no-pager -l

echo ""
echo -e "${GREEN}=========================================="
echo "  Deployment Complete!"
echo "==========================================${NC}"
echo ""
echo "Next steps:"
echo "1. Configure Nginx (add location blocks)"
echo "2. Test: https://teqmates.com/admin/"
echo "3. Test: https://teqmates.com/resort/"
echo "4. Test: https://teqmates.com/resoapi/api/docs"
echo ""
echo "Service: systemctl status $SERVICE_NAME"
echo "Logs: journalctl -u $SERVICE_NAME -f"

