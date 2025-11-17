# Orchid Resort Setup Guide

This guide will help you set up the Orchid Resort subdomain with:
- Frontend: `https://teqmates.com/orchid`
- Admin Dashboard: `https://teqmates.com/orchidadmin`
- API: `https://teqmates.com/orchidapi/api`
- Database: `orchiddb` (password: `orchid123`)

## Prerequisites

- Server access (SSH)
- PostgreSQL installed
- Nginx installed
- Python 3.8+ installed
- Node.js and npm installed

## Setup Steps

### 1. Create Database on Server

```bash
ssh root@139.84.211.200
sudo -u postgres psql <<EOF
CREATE USER orchiduser WITH PASSWORD 'orchid123';
CREATE DATABASE orchiddb OWNER orchiduser;
GRANT ALL PRIVILEGES ON DATABASE orchiddb TO orchiduser;
\c orchiddb
GRANT ALL ON SCHEMA public TO orchiduser;
EOF
```

### 2. Deploy Code to Server

```bash
# On server
cd /var/www/resort
mkdir -p orchid_production
cd orchid_production
git clone https://github.com/teqmatessolutions-gif/orchidresort.git .
```

### 3. Set Up Backend Environment

```bash
cd /var/www/resort/orchid_production/ResortApp
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Create .env file
cat > .env <<EOF
DATABASE_URL=postgresql://orchiduser:orchid123@localhost:5432/orchiddb
SECRET_KEY=$(python3 -c 'import secrets; print(secrets.token_urlsafe(32))')
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=1440
EOF
```

### 4. Create Systemd Service

Copy `orchid.service` to `/etc/systemd/system/orchid.service` and enable:

```bash
sudo cp /var/www/resort/orchid_production/orchid.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable orchid.service
sudo systemctl start orchid.service
```

### 5. Update Nginx Configuration

Add orchid routes to `/etc/nginx/sites-enabled/resort` (see `nginx_orchid_additions.conf`)

### 6. Build and Deploy Frontend

```bash
# Dashboard
cd /var/www/resort/orchid_production/dasboard
npm install
npm run build

# Userend
cd /var/www/resort/orchid_production/userend/userend
npm install
npm run build
```

### 7. Restart Services

```bash
sudo systemctl restart orchid.service
sudo systemctl reload nginx
```

## Verification

- Frontend: https://teqmates.com/orchid
- Admin: https://teqmates.com/orchidadmin
- API: https://teqmates.com/orchidapi/api/resort-info

