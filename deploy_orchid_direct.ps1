# Orchid Production Direct Deployment
# This script executes deployment commands on the production server

$SERVER_IP = "139.84.211.200"
$SERVER_USER = "root"
$PRODUCTION_PATH = "/var/www/resort/orchid_production"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Orchid Production Deployment" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Deployment commands as a single SSH command
$deployCommands = @"
cd $PRODUCTION_PATH && git pull origin main && 
cd $PRODUCTION_PATH/ResortApp && source venv/bin/activate && pip install -q -r requirements.txt 2>/dev/null || true && 
cd $PRODUCTION_PATH/userend/userend && npm install --legacy-peer-deps --silent && npm run build && 
cd $PRODUCTION_PATH/dasboard && npm install --legacy-peer-deps --silent && npm run build && 
systemctl restart orchid.service && 
systemctl reload nginx && 
echo 'Deployment Complete!'
"@

Write-Host "Connecting to server and deploying..." -ForegroundColor Yellow
Write-Host "Server: $SERVER_USER@$SERVER_IP" -ForegroundColor Yellow
Write-Host ""

# Try to execute SSH command
try {
    Write-Host "Executing deployment commands..." -ForegroundColor Green
    ssh "$SERVER_USER@$SERVER_IP" $deployCommands
    
    Write-Host ""
    Write-Host "==========================================" -ForegroundColor Green
    Write-Host "Deployment Complete!" -ForegroundColor Green
    Write-Host "==========================================" -ForegroundColor Green
    Write-Host "Userend: https://teqmates.com/orchid" -ForegroundColor Cyan
    Write-Host "Dashboard: https://teqmates.com/orchidadmin" -ForegroundColor Cyan
    Write-Host "API: https://teqmates.com/orchidapi/api" -ForegroundColor Cyan
    
} catch {
    Write-Host ""
    Write-Host "SSH connection failed or requires authentication." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Please run this command manually:" -ForegroundColor Yellow
    Write-Host "ssh $SERVER_USER@$SERVER_IP" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Then execute:" -ForegroundColor Yellow
    Write-Host "cd $PRODUCTION_PATH" -ForegroundColor Cyan
    Write-Host "git pull origin main" -ForegroundColor Cyan
    Write-Host "cd $PRODUCTION_PATH && chmod +x deploy_orchid_production.sh && ./deploy_orchid_production.sh" -ForegroundColor Cyan
}

