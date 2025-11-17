#!/bin/bash
# Verify pomma production deployment

echo "🔍 Verifying Pomma Production Deployment..."
echo ""

# Check git status
echo "1. Checking git status..."
cd /var/www/resort/pomma_production
git status --short
echo ""

# Check if routes exist in code
echo "2. Checking if routes exist in code..."
if grep -q "def list_resort_info_no_slash" ResortApp/app/api/frontend.py; then
    echo "✅ resort-info route without slash exists"
else
    echo "❌ resort-info route without slash NOT found"
fi

if grep -q "def list_gallery_no_slash" ResortApp/app/api/frontend.py; then
    echo "✅ gallery route without slash exists"
else
    echo "❌ gallery route without slash NOT found"
fi

if grep -q "def list_reviews_no_slash" ResortApp/app/api/frontend.py; then
    echo "✅ reviews route without slash exists"
else
    echo "❌ reviews route without slash NOT found"
fi

echo ""

# Check service status
echo "3. Checking pomma.service status..."
systemctl status pomma.service --no-pager | head -10
echo ""

# Test endpoints directly on backend
echo "4. Testing endpoints on backend (127.0.0.1:8010)..."
for endpoint in resort-info gallery reviews header-banner signature-experiences plan-weddings nearby-attractions nearby-attraction-banner; do
    status=$(curl -s -o /dev/null -w "%{http_code}" "http://127.0.0.1:8010/api/$endpoint" 2>/dev/null || echo "000")
    if [ "$status" = "200" ]; then
        echo "✅ /api/$endpoint: $status"
    else
        echo "❌ /api/$endpoint: $status"
    fi
done

echo ""
echo "5. Testing endpoints through Nginx (https://teqmates.com/pommaapi/api/)..."
for endpoint in resort-info gallery reviews header-banner signature-experiences plan-weddings nearby-attractions nearby-attraction-banner; do
    status=$(curl -s -o /dev/null -w "%{http_code}" "https://teqmates.com/pommaapi/api/$endpoint" 2>/dev/null || echo "000")
    if [ "$status" = "200" ]; then
        echo "✅ /pommaapi/api/$endpoint: $status"
    else
        echo "❌ /pommaapi/api/$endpoint: $status"
    fi
done

echo ""
echo "✅ Verification complete!"

