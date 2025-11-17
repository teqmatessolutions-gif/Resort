#!/bin/bash
# Complete deployment script for Orchid Resort

set -e

echo "=== Orchid Resort Deployment Script ==="

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}>>> $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

# Step 1: Create database
print_status "Step 1: Creating database orchiddb..."
sudo -u postgres psql <<EOF
-- Create user if not exists
DO \$\$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_user WHERE usename = 'orchiduser') THEN
        CREATE USER orchiduser WITH PASSWORD 'orchid123';
    END IF;
END
\$\$;

-- Create database
SELECT 'CREATE DATABASE orchiddb OWNER orchiduser'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'orchiddb')\gexec

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE orchiddb TO orchiduser;
\c orchiddb
GRANT ALL ON SCHEMA public TO orchiduser;
EOF

if [ $? -eq 0 ]; then
    print_success "Database orchiddb created successfully"
else
    print_error "Failed to create database"
    exit 1
fi

# Step 2: Clone/Update repository
print_status "Step 2: Setting up code repository..."
ORCHID_DIR="/var/www/resort/orchid_production"
if [ ! -d "$ORCHID_DIR" ]; then
    mkdir -p "$ORCHID_DIR"
    cd "$ORCHID_DIR"
    git clone https://github.com/teqmatessolutions-gif/orchidresort.git .
    print_success "Repository cloned"
else
    cd "$ORCHID_DIR"
    git pull origin main || print_warning "Git pull failed or no changes"
fi

# Step 3: Set up Python environment
print_status "Step 3: Setting up Python virtual environment..."
cd "$ORCHID_DIR/ResortApp"
if [ ! -d "venv" ]; then
    python3 -m venv venv
    print_success "Virtual environment created"
fi

source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
print_success "Python dependencies installed"

# Step 4: Create .env file
print_status "Step 4: Creating .env file..."
SECRET_KEY=$(python3 -c 'import secrets; print(secrets.token_urlsafe(32))')
cat > .env <<EOF
DATABASE_URL=postgresql://orchiduser:orchid123@localhost:5432/orchiddb
SECRET_KEY=$SECRET_KEY
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=1440
EOF
print_success ".env file created"

# Step 5: Create log directory
print_status "Step 5: Creating log directory..."
sudo mkdir -p /var/log/orchid
sudo chown www-data:www-data /var/log/orchid
print_success "Log directory created"

# Step 6: Set up systemd service
print_status "Step 6: Setting up systemd service..."
sudo cp "$ORCHID_DIR/orchid.service" /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable orchid.service
print_success "Systemd service configured"

# Step 7: Update Nginx configuration
print_status "Step 7: Updating Nginx configuration..."
# Backup existing config
sudo cp /etc/nginx/sites-enabled/resort /etc/nginx/sites-enabled/resort.backup.$(date +%Y%m%d_%H%M%S)

# Append orchid configuration
sudo bash -c "cat $ORCHID_DIR/nginx_orchid_additions.conf >> /etc/nginx/sites-enabled/resort"

# Test Nginx configuration
sudo nginx -t
if [ $? -eq 0 ]; then
    print_success "Nginx configuration is valid"
    sudo systemctl reload nginx
else
    print_error "Nginx configuration test failed"
    print_warning "Restoring backup..."
    sudo cp /etc/nginx/sites-enabled/resort.backup.* /etc/nginx/sites-enabled/resort
    exit 1
fi

# Step 8: Build frontend
print_status "Step 8: Building frontend applications..."

# Build dashboard
cd "$ORCHID_DIR/dasboard"
if [ -f "package.json" ]; then
    npm install --legacy-peer-deps
    npm run build
    print_success "Dashboard built"
else
    print_warning "Dashboard package.json not found"
fi

# Build userend
cd "$ORCHID_DIR/userend/userend"
if [ -f "package.json" ]; then
    npm install --legacy-peer-deps
    npm run build
    print_success "Userend built"
else
    print_warning "Userend package.json not found"
fi

# Step 9: Start services
print_status "Step 9: Starting services..."
sudo systemctl restart orchid.service
sleep 3
sudo systemctl status orchid.service --no-pager | head -10

print_success "=== Deployment Complete ==="
print_status "Frontend: https://teqmates.com/orchid"
print_status "Admin: https://teqmates.com/orchidadmin"
print_status "API: https://teqmates.com/orchidapi/api"

