# 🚀 Pomma Holidays - SSH Deployment Guide

## Latest Commit Details

**Commit Hash:** `633422f6cef7f0a1e269a2320ff5fd9a0f10ac64`  
**Author:** basil <basilabraham44@gmail.com>  
**Date:** Mon Nov 17 13:48:44 2025 +0530  
**Message:** Major updates: Eco-friendly theme, room features, booking validation, and bug fixes

**Repository:** https://github.com/teqmatessolutions-gif/pomma-latest.git

---

## Deployment Targets

- **Frontend (Userend):** https://teqmates.com/pommaholidays/
- **Admin Dashboard:** https://teqmates.com/pommaadmin/
- **API:** pommoapi
- **Database:** pommodb

---

## Prerequisites

1. SSH access to production server
2. Server has Git, Python 3, Node.js, PostgreSQL, and Nginx installed
3. Project directory exists (typically `/var/www/resort/Resort_first` or similar)

---

## Step 1: Connect to Server via SSH

```bash
ssh username@your_server_ip
# OR
ssh root@your_server_ip
```

---

## Step 2: Navigate to Project Directory

```bash
# Update this path based on your server setup
cd /var/www/resort/Resort_first

# OR if different location:
# cd /var/www/pomma
# cd /opt/pomma
```

---

## Step 3: Update Git Remote (if needed)

```bash
# Check current remote
git remote -v

# Update to pomma-latest repository if needed
git remote set-url origin https://github.com/teqmatessolutions-gif/pomma-latest.git

# Verify
git remote -v
```

---

## Step 4: Pull Latest Code

```bash
# Fetch and pull latest changes
git fetch origin main
git pull origin main

# Verify latest commit
git log -1 --oneline
```

---

## Step 5: Run Database Migrations

**⚠️ IMPORTANT:** Run these migrations before restarting services!

```bash
cd ResortApp

# Activate virtual environment
source venv/bin/activate

# Run database migration script
python3 add_package_columns.py
python3 add_room_features.py
```

**OR manually via PostgreSQL:**

```bash
# Connect to database
sudo -u postgres psql pommodb

# Run these SQL commands:
ALTER TABLE packages ADD COLUMN IF NOT EXISTS booking_type VARCHAR(50);
ALTER TABLE packages ADD COLUMN IF NOT EXISTS room_types TEXT;

ALTER TABLE rooms ADD COLUMN IF NOT EXISTS air_conditioning BOOLEAN DEFAULT FALSE;
ALTER TABLE rooms ADD COLUMN IF NOT EXISTS wifi BOOLEAN DEFAULT FALSE;
ALTER TABLE rooms ADD COLUMN IF NOT EXISTS bathroom BOOLEAN DEFAULT FALSE;
ALTER TABLE rooms ADD COLUMN IF NOT EXISTS living_area BOOLEAN DEFAULT FALSE;
ALTER TABLE rooms ADD COLUMN IF NOT EXISTS terrace BOOLEAN DEFAULT FALSE;
ALTER TABLE rooms ADD COLUMN IF NOT EXISTS parking BOOLEAN DEFAULT FALSE;
ALTER TABLE rooms ADD COLUMN IF NOT EXISTS kitchen BOOLEAN DEFAULT FALSE;
ALTER TABLE rooms ADD COLUMN IF NOT EXISTS family_room BOOLEAN DEFAULT FALSE;
ALTER TABLE rooms ADD COLUMN IF NOT EXISTS bbq BOOLEAN DEFAULT FALSE;
ALTER TABLE rooms ADD COLUMN IF NOT EXISTS garden BOOLEAN DEFAULT FALSE;
ALTER TABLE rooms ADD COLUMN IF NOT EXISTS dining BOOLEAN DEFAULT FALSE;
ALTER TABLE rooms ADD COLUMN IF NOT EXISTS breakfast BOOLEAN DEFAULT FALSE;

# Exit PostgreSQL
\q
```

---

## Step 6: Update Python Dependencies

```bash
cd ResortApp

# Activate virtual environment
source venv/bin/activate

# Update dependencies
pip install -r requirements.txt --upgrade
# OR if you have requirements_production.txt:
# pip install -r requirements_production.txt --upgrade
```

---

## Step 7: Build Dashboard Frontend

```bash
cd ../dasboard

# Install/update dependencies
npm install --legacy-peer-deps

# Build for production
npm run build

# Verify build directory exists
ls -la build/
```

---

## Step 8: Build Userend Frontend

```bash
cd ../userend/userend

# Install/update dependencies
npm install --legacy-peer-deps

# Build for production
npm run build

# Verify build directory exists
ls -la build/
```

---

## Step 9: Restart Services

```bash
# Restart backend service (adjust service name as needed)
sudo systemctl restart resort.service
# OR
sudo systemctl restart pommoapi.service

# Restart nginx
sudo systemctl restart nginx
```

---

## Step 10: Verify Deployment

```bash
# Check backend service status
sudo systemctl status resort.service
# OR
sudo systemctl status pommoapi.service

# Check nginx status
sudo systemctl status nginx

# View recent logs
sudo journalctl -u resort.service -n 50
# OR
sudo journalctl -u pommoapi.service -n 50

# Check nginx error logs
sudo tail -f /var/log/nginx/error.log
```

---

## Quick Deployment Script

Alternatively, you can use the automated deployment script:

```bash
# Make script executable
chmod +x deploy_pomma_latest.sh

# Run deployment
sudo ./deploy_pomma_latest.sh
```

---

## Post-Deployment Checklist

- [ ] Verify API is accessible: `curl https://teqmates.com/api/health` (or your API endpoint)
- [ ] Verify Admin Dashboard: https://teqmates.com/pommaadmin/
- [ ] Verify Userend: https://teqmates.com/pommaholidays/
- [ ] Test login functionality
- [ ] Verify room features are displaying correctly
- [ ] Check that eco-friendly theme is active
- [ ] Verify booking validation works (adults/children separately)
- [ ] Test checkout details modal
- [ ] Verify employee management (activate/deactivate, password change)

---

## Troubleshooting

### Service won't start
```bash
# Check service logs
sudo journalctl -u resort.service -n 100

# Check for Python errors
cd /var/www/resort/Resort_first/ResortApp
source venv/bin/activate
python3 -c "from app.database import engine; print('Database connection OK')"
```

### Build fails
```bash
# Clear node_modules and rebuild
cd dasboard
rm -rf node_modules package-lock.json
npm install --legacy-peer-deps
npm run build
```

### Database connection errors
```bash
# Verify database credentials in .env file
cd ResortApp
cat .env | grep DATABASE

# Test database connection
source venv/bin/activate
python3 -c "from app.database import engine; engine.connect()"
```

### Nginx errors
```bash
# Check nginx configuration
sudo nginx -t

# View nginx error logs
sudo tail -f /var/log/nginx/error.log

# Reload nginx configuration
sudo nginx -s reload
```

---

## Rollback (if needed)

```bash
# Revert to previous commit
cd /var/www/resort/Resort_first
git log --oneline -5  # View recent commits
git checkout <previous_commit_hash>

# Rebuild and restart
cd ResortApp && source venv/bin/activate && cd ../dasboard && npm run build && cd ../userend/userend && npm run build
sudo systemctl restart resort.service
sudo systemctl restart nginx
```

---

## Support

If you encounter issues:
1. Check service logs: `sudo journalctl -u resort.service -f`
2. Check nginx logs: `sudo tail -f /var/log/nginx/error.log`
3. Verify database migrations were applied
4. Ensure all environment variables are set correctly

