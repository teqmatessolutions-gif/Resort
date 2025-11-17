#!/bin/bash

# Pomma Holidays - Production Deployment Script
# Repository: https://github.com/teqmatessolutions-gif/pomma-latest.git
# Deploy to: 
#   - Frontend: https://teqmates.com/pommaholidays/
#   - Admin: https://teqmates.com/pommaadmin/
#   - API: pommoapi
#   - Database: pommodb

set -e  # Exit on error

echo "🚀 Starting Pomma Holidays Deployment Process..."
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration - UPDATE THESE PATHS AS NEEDED
PROJECT_DIR="/var/www/resort/Resort_first"
# Alternative paths if different:
# PROJECT_DIR="/var/www/pomma"
# PROJECT_DIR="/opt/pomma"

# Check if running as root or with sudo
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}⚠️  Please run with sudo or as root${NC}"
    exit 1
fi

# Check if project directory exists
if [ ! -d "$PROJECT_DIR" ]; then
    echo -e "${RED}❌ Project directory not found: $PROJECT_DIR${NC}"
    echo -e "${YELLOW}Please update PROJECT_DIR in the script or create the directory${NC}"
    exit 1
fi

cd "$PROJECT_DIR" || { echo -e "${RED}Failed to navigate to project directory!${NC}"; exit 1; }

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Pomma Holidays Deployment${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Step 1: Update Git Remote and Pull Latest Code
echo -e "${GREEN}Step 1/8: Updating Git repository...${NC}"
echo "Current remote:"
git remote -v
echo ""

# Update remote URL if needed
CURRENT_REMOTE=$(git remote get-url origin 2>/dev/null || echo "")
if [[ "$CURRENT_REMOTE" != *"pomma-latest"* ]]; then
    echo -e "${YELLOW}Updating remote to pomma-latest repository...${NC}"
    git remote set-url origin https://github.com/teqmatessolutions-gif/pomma-latest.git
fi

# Pull latest changes
echo "Pulling latest code from main branch..."
git fetch origin main || { echo -e "${RED}Git fetch failed!${NC}"; exit 1; }
git pull origin main || { echo -e "${RED}Git pull failed!${NC}"; exit 1; }
echo -e "${GREEN}✅ Code updated to latest commit${NC}"
echo "Latest commit:"
git log -1 --oneline
echo ""

# Step 2: Update Python Dependencies (Backend)
echo -e "${GREEN}Step 2/8: Updating Python dependencies...${NC}"
cd ResortApp

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo -e "${YELLOW}Creating virtual environment...${NC}"
    python3 -m venv venv
fi

source venv/bin/activate

# Check if requirements file exists
if [ -f "requirements.txt" ]; then
    pip install -r requirements.txt --upgrade || { echo -e "${RED}Pip install failed!${NC}"; exit 1; }
elif [ -f "requirements_production.txt" ]; then
    pip install -r requirements_production.txt --upgrade || { echo -e "${RED}Pip install failed!${NC}"; exit 1; }
else
    echo -e "${YELLOW}⚠️  No requirements.txt found, skipping pip install${NC}"
fi

echo -e "${GREEN}✅ Python dependencies updated${NC}"
echo ""

# Step 3: Database Migrations
echo -e "${GREEN}Step 3/8: Running database migrations...${NC}"

# Check if Alembic is available
if command -v alembic &> /dev/null || [ -f "alembic.ini" ]; then
    echo "Running Alembic migrations..."
    alembic upgrade head || echo -e "${YELLOW}⚠️  Alembic migration failed or not configured${NC}"
else
    echo -e "${YELLOW}⚠️  Alembic not found, skipping migrations${NC}"
    echo -e "${YELLOW}⚠️  IMPORTANT: You may need to manually run database migrations:${NC}"
    echo -e "${YELLOW}   - Add room feature columns (air_conditioning, wifi, etc.)${NC}"
    echo -e "${YELLOW}   - Add package booking_type and room_types columns${NC}"
fi

echo -e "${GREEN}✅ Database migrations completed${NC}"
echo ""

# Step 4: Build Dashboard Frontend
echo -e "${GREEN}Step 4/8: Building Dashboard frontend (Admin)...${NC}"
cd ../dasboard

# Check if node_modules exists, if not install
if [ ! -d "node_modules" ]; then
    echo "Installing npm dependencies..."
    npm install --legacy-peer-deps || { echo -e "${RED}NPM install failed for dashboard!${NC}"; exit 1; }
else
    echo "Updating npm dependencies..."
    npm install --legacy-peer-deps || { echo -e "${YELLOW}⚠️  NPM install had warnings, continuing...${NC}"; }
fi

echo "Building dashboard..."
npm run build || { echo -e "${RED}Dashboard build failed!${NC}"; exit 1; }

if [ ! -d "build" ]; then
    echo -e "${RED}❌ Build directory not created!${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Dashboard built successfully${NC}"
echo "Build size: $(du -sh build | cut -f1)"
echo ""

# Step 5: Build Userend Frontend
echo -e "${GREEN}Step 5/8: Building Userend frontend (Public)...${NC}"
cd ../userend/userend

# Check if node_modules exists, if not install
if [ ! -d "node_modules" ]; then
    echo "Installing npm dependencies..."
    npm install --legacy-peer-deps || { echo -e "${RED}NPM install failed for userend!${NC}"; exit 1; }
else
    echo "Updating npm dependencies..."
    npm install --legacy-peer-deps || { echo -e "${YELLOW}⚠️  NPM install had warnings, continuing...${NC}"; }
fi

echo "Building userend..."
npm run build || { echo -e "${RED}Userend build failed!${NC}"; exit 1; }

if [ ! -d "build" ]; then
    echo -e "${RED}❌ Build directory not created!${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Userend built successfully${NC}"
echo "Build size: $(du -sh build | cut -f1)"
echo ""

# Step 6: Verify Build Files
echo -e "${GREEN}Step 6/8: Verifying build files...${NC}"
cd "$PROJECT_DIR"

# Check dashboard build
if [ -d "dasboard/build" ]; then
    echo -e "${GREEN}✅ Dashboard build exists${NC}"
else
    echo -e "${RED}❌ Dashboard build missing!${NC}"
    exit 1
fi

# Check userend build
if [ -d "userend/userend/build" ]; then
    echo -e "${GREEN}✅ Userend build exists${NC}"
else
    echo -e "${RED}❌ Userend build missing!${NC}"
    exit 1
fi

echo ""

# Step 7: Restart Services
echo -e "${GREEN}Step 7/8: Restarting services...${NC}"

# Restart backend service (adjust service name as needed)
if systemctl is-active --quiet resort.service 2>/dev/null || systemctl is-active --quiet pommoapi.service 2>/dev/null; then
    SERVICE_NAME=""
    if systemctl list-units --type=service | grep -q "resort.service"; then
        SERVICE_NAME="resort.service"
    elif systemctl list-units --type=service | grep -q "pommoapi.service"; then
        SERVICE_NAME="pommoapi.service"
    fi
    
    if [ ! -z "$SERVICE_NAME" ]; then
        echo "Restarting $SERVICE_NAME..."
        systemctl restart "$SERVICE_NAME" || { echo -e "${RED}Failed to restart $SERVICE_NAME!${NC}"; exit 1; }
        echo -e "${GREEN}✅ $SERVICE_NAME restarted${NC}"
    else
        echo -e "${YELLOW}⚠️  Backend service not found, skipping restart${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Backend service not running, skipping restart${NC}"
fi

# Restart nginx
if systemctl is-active --quiet nginx; then
    echo "Restarting nginx..."
    systemctl restart nginx || { echo -e "${RED}Failed to restart nginx!${NC}"; exit 1; }
    echo -e "${GREEN}✅ Nginx restarted${NC}"
else
    echo -e "${YELLOW}⚠️  Nginx not running${NC}"
fi

echo ""

# Step 8: Verify Deployment
echo -e "${GREEN}Step 8/8: Verifying deployment...${NC}"
sleep 3

# Check service status
if [ ! -z "$SERVICE_NAME" ]; then
    echo "Checking $SERVICE_NAME status..."
    systemctl status "$SERVICE_NAME" --no-pager -l || echo -e "${YELLOW}⚠️  Service status check failed${NC}"
fi

# Check nginx status
echo "Checking nginx status..."
systemctl status nginx --no-pager -l || echo -e "${YELLOW}⚠️  Nginx status check failed${NC}"

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}✅ Deployment Completed Successfully!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${YELLOW}📋 Post-Deployment Checklist:${NC}"
echo "  1. Verify API is accessible: https://teqmates.com/api/health (or your API endpoint)"
echo "  2. Verify Admin Dashboard: https://teqmates.com/pommaadmin/"
echo "  3. Verify Userend: https://teqmates.com/pommaholidays/"
echo "  4. Check service logs: sudo journalctl -u $SERVICE_NAME -n 50"
echo "  5. Check nginx logs: sudo tail -f /var/log/nginx/error.log"
echo ""
echo -e "${YELLOW}⚠️  IMPORTANT: Database Migrations${NC}"
echo "  If you haven't run database migrations, you need to:"
echo "  1. Add room feature columns to 'rooms' table"
echo "  2. Add booking_type and room_types to 'packages' table"
echo "  See database migration scripts in the project root"
echo ""
echo -e "${GREEN}🎉 Deployment finished!${NC}"

