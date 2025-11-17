# 🚀 Quick SSH Deployment Reference

## Latest Commit
- **Hash:** `633422f6cef7f0a1e269a2320ff5fd9a0f10ac64`
- **Author:** basil <basilabraham44@gmail.com>
- **Date:** 2025-11-17 13:48:44 +0530
- **Message:** Major updates: Eco-friendly theme, room features, booking validation, and bug fixes

---

## One-Line Deployment (After SSH Connection)

```bash
cd /var/www/resort/Resort_first && \
git pull origin main && \
cd ResortApp && source venv/bin/activate && python3 migrate_database.py && pip install -r requirements.txt --upgrade && \
cd ../dasboard && npm install --legacy-peer-deps && npm run build && \
cd ../userend/userend && npm install --legacy-peer-deps && npm run build && \
cd ../../ResortApp && sudo systemctl restart resort.service && sudo systemctl restart nginx
```

---

## Step-by-Step Commands

### 1. Connect & Navigate
```bash
ssh username@server_ip
cd /var/www/resort/Resort_first
```

### 2. Pull Latest Code
```bash
git pull origin main
```

### 3. Run Database Migration
```bash
cd ResortApp
source venv/bin/activate
python3 migrate_database.py
```

### 4. Update Backend
```bash
pip install -r requirements.txt --upgrade
```

### 5. Build Dashboard
```bash
cd ../dasboard
npm install --legacy-peer-deps
npm run build
```

### 6. Build Userend
```bash
cd ../userend/userend
npm install --legacy-peer-deps
npm run build
```

### 7. Restart Services
```bash
cd /var/www/resort/Resort_first/ResortApp
sudo systemctl restart resort.service
sudo systemctl restart nginx
```

### 8. Verify
```bash
sudo systemctl status resort.service
sudo systemctl status nginx
```

---

## Quick Checks

```bash
# Check latest commit
git log -1 --oneline

# Check service status
sudo systemctl status resort.service

# View logs
sudo journalctl -u resort.service -n 50

# Test API
curl http://localhost:8000/api/health
```

---

## Rollback (Emergency)

```bash
cd /var/www/resort/Resort_first
git log --oneline -5  # Find previous commit
git checkout <previous_commit_hash>
# Rebuild and restart (see steps 4-7 above)
```

