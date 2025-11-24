#!/bin/bash

# Test the users/riders endpoint
echo "Testing /api/users/riders endpoint..."
echo ""

# First, login to get a token
echo "1. Logging in as admin..."
LOGIN_RESPONSE=$(curl -s -X POST http://127.0.0.1:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"password"}')

echo "Login response: $LOGIN_RESPONSE"
echo ""

# Extract token (simple grep, assumes token is in response)
TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"token":"[^"]*' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
  echo "ERROR: Could not get token. Please check if admin user exists."
  exit 1
fi

echo "2. Got token: ${TOKEN:0:20}..."
echo ""

# Test the riders endpoint
echo "3. Testing /api/users/riders endpoint..."
RIDERS_RESPONSE=$(curl -s -X GET http://127.0.0.1:8000/api/users/riders \
  -H "Authorization: Bearer $TOKEN")

echo "Riders response: $RIDERS_RESPONSE"
