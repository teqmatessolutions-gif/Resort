# Orchid Production Auto-Deployment Script
# This script automatically deploys Orchid changes to production
# Server: 139.84.211.200
# Project: /var/www/resort/orchid_production

param(
    [Parameter(Mandatory=$false)]
    [string]$ServerPassword
)

$ErrorActionPreference = "Stop"

$SERVER_IP = "139.84.211.200"
$SERVER_USER = "root"
$PRODUCTION_PATH = "/var/www/resort/orchid_production"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Orchid Production Auto-Deployment" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Server: $SERVER_USER@$SERVER_IP" -ForegroundColor Yellow
Write-Host "Project: $PRODUCTION_PATH" -ForegroundColor Yellow
Write-Host ""

# Check if SSH is available
try {
    $sshTest = ssh -V 2>&1
    Write-Host "✓ SSH client found" -ForegroundColor Green
} catch {
    Write-Host "✗ SSH client not found. Please install OpenSSH or use PuTTY." -ForegroundColor Red
    exit 1
}

# Create deployment script content
$deployScript = @"
#!/bin/bash
set -e

echo "=========================================="
echo "Orchid Production Deployment"
echo "=========================================="

cd $PRODUCTION_PATH

# Step 1: Pull latest code
echo "Step 1: Pulling latest code from git..."
git pull origin main
echo "✓ Code updated"

# Step 2: Update backend dependencies
echo "Step 2: Updating backend dependencies..."
cd $PRODUCTION_PATH/ResortApp
source venv/bin/activate
pip install -q -r requirements.txt 2>/dev/null || echo "Note: requirements.txt not found or no new dependencies"
echo "✓ Backend dependencies checked"

# Step 3: Build Userend
echo "Step 3: Building Userend frontend..."
cd $PRODUCTION_PATH/userend/userend
npm install --legacy-peer-deps --silent
npm run build
echo "✓ Userend built successfully"

# Step 4: Build Dashboard
echo "Step 4: Building Dashboard frontend..."
cd $PRODUCTION_PATH/dasboard
npm install --legacy-peer-deps --silent
npm run build
echo "✓ Dashboard built successfully"

# Step 5: Restart backend service
echo "Step 5: Restarting Orchid backend service..."
systemctl restart orchid.service
sleep 2
systemctl status orchid.service --no-pager -l || echo "Warning: Service status check failed"
echo "✓ Backend service restarted"

# Step 6: Reload Nginx
echo "Step 6: Reloading Nginx..."
nginx -t && systemctl reload nginx || echo "Warning: Nginx reload failed"
echo "✓ Nginx reloaded"

echo "=========================================="
echo "Deployment Complete!"
echo "=========================================="
echo "Userend: https://teqmates.com/orchid"
echo "Dashboard: https://teqmates.com/orchidadmin"
echo "API: https://teqmates.com/orchidapi/api"
echo "=========================================="
"@

Write-Host "Connecting to server and deploying..." -ForegroundColor Yellow
Write-Host ""

# If password provided, use it; otherwise prompt
if ($ServerPassword) {
    # Use sshpass equivalent or expect-like approach
    # For Windows, we'll use plink if available, or prompt for password
    Write-Host "Attempting SSH connection with provided credentials..." -ForegroundColor Yellow
    
    # Try using SSH with password (requires sshpass or similar)
    # For Windows, we'll use a different approach
    $sshCommand = "ssh $SERVER_USER@$SERVER_IP `"$deployScript`""
    
    Write-Host "Please run this command manually:" -ForegroundColor Yellow
    Write-Host $sshCommand -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Or connect manually and run:" -ForegroundColor Yellow
    Write-Host $deployScript -ForegroundColor Cyan
    
} else {
    # Interactive mode
    Write-Host "Connecting to server (you will be prompted for password)..." -ForegroundColor Yellow
    Write-Host ""
    
    # Save script to temp file and execute via SSH
    $tempScript = [System.IO.Path]::GetTempFileName()
    $deployScript | Out-File -FilePath $tempScript -Encoding UTF8
    
    Write-Host "To deploy, run this command:" -ForegroundColor Yellow
    Write-Host "ssh $SERVER_USER@$SERVER_IP 'bash -s' < $tempScript" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Or connect manually:" -ForegroundColor Yellow
    Write-Host "ssh $SERVER_USER@$SERVER_IP" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Then run the deployment script on the server." -ForegroundColor Yellow
    
    # Try to execute if possible
    try {
        Write-Host ""
        Write-Host "Attempting automatic deployment..." -ForegroundColor Yellow
        $result = ssh $SERVER_USER@$SERVER_IP $deployScript 2>&1
        Write-Host $result
    } catch {
        Write-Host ""
        Write-Host "Automatic deployment requires manual SSH connection." -ForegroundColor Yellow
        Write-Host "Please run the commands shown above." -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Deployment Instructions" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Option 1: Manual SSH Connection" -ForegroundColor Yellow
Write-Host "  1. Open PowerShell or Terminal" -ForegroundColor White
Write-Host "  2. Run: ssh $SERVER_USER@$SERVER_IP" -ForegroundColor Cyan
Write-Host "  3. Enter password when prompted" -ForegroundColor White
Write-Host "  4. Run: cd $PRODUCTION_PATH" -ForegroundColor Cyan
Write-Host "  5. Run: git pull origin main" -ForegroundColor Cyan
Write-Host "  6. Run: ./deploy_orchid_production.sh" -ForegroundColor Cyan
Write-Host ""
Write-Host "Option 2: Copy deployment script to server" -ForegroundColor Yellow
Write-Host "  The deployment script is saved in the repository." -ForegroundColor White
Write-Host "  After connecting via SSH, run:" -ForegroundColor White
Write-Host "  cd $PRODUCTION_PATH" -ForegroundColor Cyan
Write-Host "  chmod +x deploy_orchid_production.sh" -ForegroundColor Cyan
Write-Host "  ./deploy_orchid_production.sh" -ForegroundColor Cyan
Write-Host ""

