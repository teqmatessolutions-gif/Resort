#!/bin/bash
# Deploy latest code to pomma production

set -e

echo "🚀 Deploying Pomma Production..."

# Pull latest code
cd /var/www/resort/pomma_production
git pull origin main

# Restart service
systemctl restart pomma.service
sleep 3

# Check service status
systemctl status pomma.service --no-pager | head -15

# Test endpoints
echo ""
echo "Testing endpoints..."
for endpoint in resort-info gallery reviews header-banner signature-experiences plan-weddings nearby-attractions nearby-attraction-banner; do
    status=$(curl -s -o /dev/null -w "%{http_code}" "http://127.0.0.1:8010/api/$endpoint" || echo "000")
    echo "  /api/$endpoint: $status"
done

echo ""
echo "✅ Deployment complete!"

