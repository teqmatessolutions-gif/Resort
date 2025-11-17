# Orchid Resort Setup Summary

## Configuration Complete ✅

All configuration files have been created and updated for the Orchid Resort subdomain setup.

## What Has Been Configured

### 1. Backend Configuration
- ✅ `gunicorn.conf.py` - Updated to use port 8011 and orchid paths
- ✅ `orchid.service` - Systemd service file created
- ✅ Database: `orchiddb` with user `orchiduser` (password: `orchid123`)

### 2. Frontend Configuration
- ✅ `dasboard/src/utils/env.js` - Updated to support `/orchidadmin` and `/orchidapi/api`
- ✅ `userend/userend/src/utils/env.js` - Updated to support `/orchid` and `/orchidapi/api`

### 3. Nginx Configuration
- ✅ `nginx_orchid_additions.conf` - Routes for:
  - `/orchid` - Frontend
  - `/orchidadmin` - Admin Dashboard
  - `/orchidapi/api` - Backend API
  - `/orchidfiles` - Static files and uploads

### 4. Deployment Scripts
- ✅ `DEPLOY_ORCHID.sh` - Complete automated deployment script
- ✅ `setup_orchid.sh` - Database setup script
- ✅ `ORCHID_SETUP.md` - Setup documentation

## URLs

- **Frontend:** https://teqmates.com/orchid
- **Admin Dashboard:** https://teqmates.com/orchidadmin
- **API:** https://teqmates.com/orchidapi/api
- **Static Files:** https://teqmates.com/orchidfiles

## Next Steps - Server Deployment

1. **SSH to server:**
   ```bash
   ssh root@139.84.211.200
   ```

2. **Run deployment script:**
   ```bash
   cd /var/www/resort
   wget https://raw.githubusercontent.com/teqmatessolutions-gif/orchidresort/main/DEPLOY_ORCHID.sh
   chmod +x DEPLOY_ORCHID.sh
   sudo ./DEPLOY_ORCHID.sh
   ```

   OR manually follow the steps in `ORCHID_SETUP.md`

3. **Verify deployment:**
   - Check service: `sudo systemctl status orchid.service`
   - Check Nginx: `sudo nginx -t`
   - Test URLs in browser

## Important Notes

- ✅ **Pomma setup is NOT touched** - All orchid configurations are separate
- ✅ Database: `orchiddb` (separate from `pommodb`)
- ✅ Backend port: `8011` (separate from pomma's `8010`)
- ✅ All paths use `/orchid*` prefix to avoid conflicts

## Local Development

Local development path: `C:\releasing\orchid`

To run locally:
```bash
cd C:\releasing\orchid\ResortApp
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
# Create .env with DATABASE_URL pointing to local orchiddb
python main.py
```

