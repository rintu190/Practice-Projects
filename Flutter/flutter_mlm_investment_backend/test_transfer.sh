#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Transfer Feature - Testing Script${NC}"
echo -e "${BLUE}========================================${NC}\n"

BASE_URL="http://192.168.1.8:8000"
BACKEND_DIR="/Users/machd/Developer/Practice-Projects/Flutter/flutter_mlm_investment_backend"

# Step 1: Check PHP Server
echo -e "${YELLOW}Step 1: Checking PHP Server...${NC}"
response=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/routes/dashboard.php")
if [ "$response" == "401" ]; then
    echo -e "${GREEN}✓ PHP Server is running${NC}\n"
else
    echo -e "${RED}✗ PHP Server is not responding (HTTP $response)${NC}\n"
    exit 1
fi

# Step 2: Check Database Connection
echo -e "${YELLOW}Step 2: Checking Database Connection...${NC}"
php -r "
require '$BACKEND_DIR/config/database.php';
try {
    \$conn = Database::getInstance()->getConnection();
    \$result = \$conn->query('SELECT 1');
    echo \"✓ Database connected\n\";
} catch (Exception \$e) {
    echo \"✗ Database error: \" . \$e->getMessage() . \"\n\";
    exit(1);
}
"
echo ""

# Step 3: Check Transactions Table
echo -e "${YELLOW}Step 3: Checking Transactions Table Structure...${NC}"
php -r "
require '$BACKEND_DIR/config/database.php';
\$conn = Database::getInstance()->getConnection();
\$result = \$conn->query('SHOW COLUMNS FROM transactions');
\$columns = [];
while(\$row = \$result->fetch(PDO::FETCH_ASSOC)) {
    \$columns[] = \$row['Field'];
}

\$required = ['id', 'user_id', 'wallet_type', 'type', 'amount', 'balance_before', 'balance_after', 'description', 'reference_type', 'status'];
\$missing = array_diff(\$required, \$columns);

if (empty(\$missing)) {
    echo \"✓ All required columns exist:\n\";
    foreach (\$columns as \$col) {
        echo \"  - \$col\n\";
    }
} else {
    echo \"✗ Missing columns: \" . implode(', ', \$missing) . \"\n\";
    exit(1);
}
"
echo ""

# Step 4: Check Sample Data
echo -e "${YELLOW}Step 4: Checking Sample Data...${NC}"
php -r "
require '$BACKEND_DIR/config/database.php';
\$conn = Database::getInstance()->getConnection();

// Check users
\$users = \$conn->query('SELECT COUNT(*) as count FROM users')->fetch();
echo \"Users: \" . \$users['count'] . \"\n\";

// Check wallets
\$wallets = \$conn->query('SELECT COUNT(*) as count FROM wallets')->fetch();
echo \"Wallets: \" . \$wallets['count'] . \"\n\";

// Check transactions
\$transactions = \$conn->query('SELECT COUNT(*) as count FROM transactions')->fetch();
echo \"Transactions: \" . \$transactions['count'] . \"\n\";
"
echo ""

# Step 5: Get a Valid Token (for testing purposes)
echo -e "${YELLOW}Step 5: Getting Test Token...${NC}"
echo -e "${YELLOW}Note: Use your actual JWT token from the app for real testing${NC}"
echo -e "${BLUE}To get token:${NC}"
echo "  1. Open Flutter app and login"
echo "  2. Go to Wallet tab"
echo "  3. Check Flutter console for 'Dashboard Token' or use SharedPreferences"
echo "  4. Replace TOKEN in the curl commands below"
echo ""

# Step 6: Show curl command for transfer
echo -e "${YELLOW}Step 6: Transfer Test Command${NC}"
echo -e "${BLUE}Run this command with your actual JWT token:${NC}\n"
echo -e "${YELLOW}curl -X POST \"$BASE_URL/routes/wallet.php?action=transfer\" \\${NC}"
echo -e "${YELLOW}  -H \"Content-Type: application/json\" \\${NC}"
echo -e "${YELLOW}  -H \"Authorization: Bearer YOUR_JWT_TOKEN\" \\${NC}"
echo -e "${YELLOW}  -d '{\"amount\": 100, \"transfer_type\": \"e_to_investment\"}' \\${NC}"
echo -e "${YELLOW}  -v${NC}\n"

# Step 7: Test Transfer (if token is provided)
if [ ! -z "$1" ]; then
    echo -e "${YELLOW}Step 7: Testing Transfer with Provided Token...${NC}\n"
    response=$(curl -X POST "$BASE_URL/routes/wallet.php?action=transfer" \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $1" \
      -d '{"amount": 100, "transfer_type": "e_to_investment"}')
    
    echo -e "${BLUE}Response:${NC}"
    echo "$response" | python3 -m json.tool 2>/dev/null || echo "$response"
    echo ""
fi

echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}Testing Complete!${NC}"
echo -e "${BLUE}========================================${NC}\n"
