# Resort Demo Deployment Configuration

## Overview
This is a new demo deployment separate from Pomma Holidays and Orchid.

## Configuration Details

### URLs
- **Admin Dashboard:** `https://teqmates.com/admin/`
- **User Frontend:** `https://teqmates.com/resort/`
- **API Base:** `https://teqmates.com/resoapi/api/`
- **File Uploads:** `https://teqmates.com/resortfiles/`

### Backend
- **Port:** `8012` (localhost only: 127.0.0.1:8012)
- **Service Name:** `resort.service`
- **Deployment Path:** `/var/www/resort/resort_production/ResortApp`
- **Virtual Environment:** `/var/www/resort/resort_production/ResortApp/venv`

### Database
- **Database Name:** `rdb`
- **Database User:** `resortuser`
- **Database Password:** `resort123`
- **Connection String:** `postgresql+psycopg2://resortuser:resort123@localhost:5432/rdb`

### Frontend Builds
- **Admin Build:** `/var/www/resort/resort_production/dasboard/build` → `/admin/`
- **User Build:** `/var/www/resort/resort_production/userend/userend/build` → `/resort/`

### Git Repository
- **Repository:** `https://github.com/teqmatessolutions-gif/Resort.git`
- **Branch:** `main` (or `master`)

## Nginx Configuration

Add these location blocks to your Nginx configuration:

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

## Database Setup

```bash
# Create database and user
sudo -u postgres psql << EOF
CREATE DATABASE rdb;
CREATE USER resortuser WITH PASSWORD 'resort123';
GRANT ALL PRIVILEGES ON DATABASE rdb TO resortuser;
\c rdb
GRANT ALL ON SCHEMA public TO resortuser;
EOF
```

## Systemd Service

Service file location: `/etc/systemd/system/resort.service`

Enable and start:
```bash
sudo systemctl daemon-reload
sudo systemctl enable resort.service
sudo systemctl start resort.service
sudo systemctl status resort.service
```

## Local Development

### Backend
```bash
cd C:\releasing\Resort\ResortApp
python -m venv venv
.\venv\Scripts\activate
pip install -r requirements.txt
# Create .env file from .env.example
# Update DATABASE_URL for local PostgreSQL
python main.py
# Or: uvicorn app.main:app --reload --host 0.0.0.0 --port 8012
```

### Frontend - Admin
```bash
cd C:\releasing\Resort\dasboard
npm install
npm start
# Runs on http://localhost:3000/admin
```

### Frontend - User
```bash
cd C:\releasing\Resort\userend\userend
npm install
npm start
# Runs on http://localhost:3002
```

## Deployment Steps

1. **Clone repository on server:**
```bash
cd /var/www/resort
git clone https://github.com/teqmatessolutions-gif/Resort.git resort_production
```

2. **Setup backend:**
```bash
cd /var/www/resort/resort_production/ResortApp
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
# Edit .env with production values
```

3. **Setup database:**
```bash
# Run database setup commands above
# Then run migrations if using Alembic
alembic upgrade head
```

4. **Build frontends:**
```bash
# Admin
cd /var/www/resort/resort_production/dasboard
npm install
npm run build

# User
cd /var/www/resort/resort_production/userend/userend
npm install
npm run build
```

5. **Setup systemd service:**
```bash
sudo cp /var/www/resort/resort_production/ResortApp/resort.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable resort.service
sudo systemctl start resort.service
```

6. **Configure Nginx:**
```bash
# Add location blocks to your Nginx config
sudo nano /etc/nginx/sites-available/default
# Or create a new config file
sudo nginx -t
sudo systemctl reload nginx
```

## Verification

- Admin: `https://teqmates.com/admin/`
- User: `https://teqmates.com/resort/`
- API: `https://teqmates.com/resoapi/api/rooms`
- Service: `systemctl status resort.service`
- Logs: `journalctl -u resort.service -f`

