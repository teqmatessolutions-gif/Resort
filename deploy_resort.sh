#!/bin/bash
# Resort Demo Deployment Script
# Deploys to /var/www/resort/resort_production

set -e

echo "=========================================="
echo "  Resort Demo - Server Deployment"
echo "=========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Deployment path
DEPLOY_PATH="/var/www/resort/resort_production"
GIT_REPO="https://github.com/teqmatessolutions-gif/Resort.git"

echo -e "${YELLOW}Step 1: Creating deployment directory...${NC}"
mkdir -p /var/www/resort
cd /var/www/resort

if [ -d "resort_production" ]; then
    echo "Directory exists, pulling latest changes..."
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

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
fi

# Activate and install dependencies
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

echo -e "${GREEN}✓ Backend dependencies installed${NC}"
echo ""

echo -e "${YELLOW}Step 3: Setting up database...${NC}"
# Check if database exists
python3 setup_database.py || echo "Database setup may need manual intervention"

echo -e "${GREEN}✓ Database setup checked${NC}"
echo ""

echo -e "${YELLOW}Step 4: Building admin dashboard...${NC}"
cd ../dasboard
npm install --legacy-peer-deps
npm run build

echo -e "${GREEN}✓ Admin dashboard built${NC}"
echo ""

echo -e "${YELLOW}Step 5: Building user frontend...${NC}"
cd ../userend/userend
npm install --legacy-peer-deps
npm run build

echo -e "${GREEN}✓ User frontend built${NC}"
echo ""

echo -e "${YELLOW}Step 6: Setting up systemd service...${NC}"
cd ../../ResortApp
sudo cp resort.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable resort.service

echo -e "${GREEN}✓ Systemd service configured${NC}"
echo ""

echo -e "${YELLOW}Step 7: Creating necessary directories...${NC}"
mkdir -p /var/log/resort
mkdir -p /var/run/resort
chown -R www-data:www-data /var/www/resort/resort_production
chown -R www-data:www-data /var/log/resort
chown -R www-data:www-data /var/run/resort

echo -e "${GREEN}✓ Directories created${NC}"
echo ""

echo -e "${YELLOW}Step 8: Starting services...${NC}"
sudo systemctl restart resort.service
sudo systemctl status resort.service --no-pager

echo ""
echo -e "${GREEN}=========================================="
echo "  Deployment Complete!"
echo "==========================================${NC}"
echo ""
echo "Next steps:"
echo "1. Configure Nginx (add location blocks from DEPLOYMENT_CONFIG.md)"
echo "2. Test: https://teqmates.com/admin/"
echo "3. Test: https://teqmates.com/resort/"
echo "4. Test: https://teqmates.com/resoapi/api/docs"
echo ""
echo "Service status: systemctl status resort.service"
echo "Logs: journalctl -u resort.service -f"

