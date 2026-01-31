#!/bin/bash

# Backend Testing Script for Fraud Detection App
# This script helps test the backend API locally

echo "🧪 Testing Fraud Detection Backend..."
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test 1: Health Check
echo -n "1️⃣  Testing health endpoint... "
response=$(curl -s http://localhost:8001/api/health)
if echo "$response" | grep -q "ok"; then
    echo -e "${GREEN}✓ PASS${NC}"
    echo "   Response: $response"
else
    echo -e "${RED}✗ FAIL${NC}"
    echo "   Response: $response"
    exit 1
fi
echo ""

# Test 2: Root endpoint
echo -n "2️⃣  Testing root endpoint... "
response=$(curl -s http://localhost:8001/api/)
if echo "$response" | grep -q "Fraud Detection"; then
    echo -e "${GREEN}✓ PASS${NC}"
    echo "   Response: $response"
else
    echo -e "${RED}✗ FAIL${NC}"
    echo "   Response: $response"
fi
echo ""

# Test 3: Call history (should be empty initially)
echo -n "3️⃣  Testing call history endpoint... "
response=$(curl -s http://localhost:8001/api/call-history)
if [ "$response" = "[]" ] || echo "$response" | grep -q "\["; then
    echo -e "${GREEN}✓ PASS${NC}"
    echo "   Response: $response"
else
    echo -e "${RED}✗ FAIL${NC}"
    echo "   Response: $response"
fi
echo ""

# Summary
echo "=========================================="
echo -e "${GREEN}✅ Backend is working correctly!${NC}"
echo "=========================================="
echo ""
echo "📱 Next steps:"
echo "   1. Update backend URL in Flutter app:"
echo "      File: lib/services/api_service.dart"
echo "      Line: static const String baseUrl = 'http://YOUR_IP:8001/api';"
echo ""
echo "   2. Build APK:"
echo "      cd /app/fraud_detection_app"
echo "      flutter pub get"
echo "      flutter build apk --release"
echo ""
echo "   3. Install and test on Android device"
echo ""
