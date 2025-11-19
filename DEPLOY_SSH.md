# Resort Demo - SSH Deployment Guide

## Server Information
- **IP:** 139.84.211.200
- **User:** root
- **Deployment Path:** `/var/www/resort/resort_production`

## Quick Deployment

### Step 1: Connect to Server
```bash
ssh root@139.84.211.200
```

### Step 2: Deploy Resort Demo
```bash
cd /var/www/resort
git clone https://github.com/teqmatessolutions-gif/Resort.git resort_production
cd resort_production
chmod +x deploy_resort_ssh.sh
./deploy_resort_ssh.sh
```

### Step 3: Configure Nginx
Add these location blocks to your Nginx config:

```nginx
# Resort Admin Dashboard
location /admin {
    alias /var/www/resort/resort_production/dasboard/build;
    try_files $uri $uri/ /admin/index.html;
}

location /admin/static/ {
    alias /var/www/resort/resort_production/dasboard/build/static/;
    expires 1y;
    add_header Cache-Control "public, immutable";
}

# Resort User Frontend
location /resort {
    alias /var/www/resort/resort_production/userend/userend/build;
    try_files $uri $uri/ /resort/index.html;
}

location /resort/static/ {
    alias /var/www/resort/resort_production/userend/userend/build/static/;
    expires 1y;
    add_header Cache-Control "public, immutable";
}

# Resort API Backend
location /resoapi/ {
    rewrite ^/resoapi/(.*)$ /$1 break;
    proxy_pass http://127.0.0.1:8012;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_buffering off;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
}

# Resort File Uploads
location /resortfiles/ {
    alias /var/www/resort/resort_production/ResortApp/uploads/;
    expires 30d;
    add_header Cache-Control "public";
}
```

Then reload Nginx:
```bash
sudo nginx -t
sudo systemctl reload nginx
```

### Step 4: Create Database
```bash
sudo -u postgres psql << EOF
CREATE DATABASE rdb;
CREATE USER resortuser WITH PASSWORD 'resort123';
GRANT ALL PRIVILEGES ON DATABASE rdb TO resortuser;
\c rdb
GRANT ALL ON SCHEMA public TO resortuser;
EOF
```

### Step 5: Create Admin User
```bash
cd /var/www/resort/resort_production/ResortApp
source venv/bin/activate
python create_admin.py
```

## Verification

- Admin: https://teqmates.com/admin/
- User: https://teqmates.com/resort/
- API: https://teqmates.com/resoapi/api/docs
- Service: `systemctl status resort.service`

