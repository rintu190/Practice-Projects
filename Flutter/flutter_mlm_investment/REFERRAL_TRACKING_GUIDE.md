# Referral Tracking System - MLM Investment Android App

## 📱 Overview

The referral tracking system in your MLM Investment Android app is a comprehensive multi-level marketing system that tracks user relationships, commissions, and team hierarchies.

---

## 🔄 How Referral Tracking Works

### 1. **User Registration Flow**

When a new user signs up, here's what happens:

#### **Step 1: User Enters Referral Code (Optional)**
```
Registration Screen → Referral Input Screen
```
- User can enter a referral code OR skip it
- Referral code is validated in real-time
- Format: 6-20 alphanumeric characters (e.g., "6F672807")

#### **Step 2: Backend Validation**
```php
// File: routes/auth.php (Line 190-201)

// Validate referral code
if ($referralCode) {
    $refStmt = $conn->prepare("SELECT id FROM users WHERE referral_code = ?");
    $refStmt->execute([$referralCode]);
    $referrer = $refStmt->fetch();
    
    if ($referrer) {
        $referredBy = $referrer['id'];  // Link to sponsor
    } else {
        return error('Invalid referral code');
    }
}
```

#### **Step 3: User Creation**
```php
// File: routes/auth.php (Line 203-224)

// 1. Generate unique referral code for new user
$newReferralCode = generateReferralCode(); // e.g., "A3B9C2D1"

// 2. Create user with referral link
INSERT INTO users (phone, password_hash, referral_code, referred_by)
VALUES (?, ?, ?, ?);

// 3. Create wallet for new user
INSERT INTO wallets (user_id) VALUES (?);

// 4. Create profile
INSERT INTO user_profiles (user_id, full_name) VALUES (?, ?);

// 5. Add to genealogy tree
INSERT INTO genealogy (user_id, sponsor_id) VALUES (?, ?);
```

---

## 🗄️ Database Structure

### **1. Users Table**
```sql
CREATE TABLE users (
    id INT PRIMARY KEY,
    phone VARCHAR(15) UNIQUE,
    referral_code VARCHAR(20) UNIQUE,  -- User's own code
    referred_by INT,                    -- ID of sponsor
    FOREIGN KEY (referred_by) REFERENCES users(id)
);
```

**Example:**
```
User A (ID: 1, Code: "ABC123", referred_by: NULL)
  └─ User B (ID: 2, Code: "XYZ789", referred_by: 1)
      └─ User C (ID: 3, Code: "DEF456", referred_by: 2)
```

### **2. Genealogy Table**
```sql
CREATE TABLE genealogy (
    id INT PRIMARY KEY,
    user_id INT UNIQUE,
    sponsor_id INT,                     -- Direct sponsor
    placement_id INT,                   -- For binary placement
    level INT DEFAULT 1,                -- Level in tree
    left_leg_count INT DEFAULT 0,       -- Left team count
    right_leg_count INT DEFAULT 0,      -- Right team count
    total_downline INT DEFAULT 0,       -- Total team size
    active_downline INT DEFAULT 0,      -- Active members
    tree_type ENUM('binary', 'unilevel', 'matrix') DEFAULT 'binary'
);
```

**Purpose:** Tracks the MLM tree structure for commission calculations

### **3. Referrals Table**
```sql
CREATE TABLE referrals (
    id INT PRIMARY KEY,
    referrer_id INT,                    -- Who referred
    referred_id INT,                    -- Who was referred
    referral_level INT DEFAULT 1,       -- Direct = 1, Indirect = 2+
    is_direct BOOLEAN DEFAULT TRUE,     -- Direct referral?
    total_earnings DECIMAL(15,2),       -- Earnings from this referral
    UNIQUE KEY (referrer_id, referred_id)
);
```

---

## 📊 Referral Tracking Features

### **1. Referral Code Generation**
Each user gets a unique code when they register:
```php
function generateReferralCode() {
    return strtoupper(substr(md5(uniqid()), 0, 8));
}
// Example output: "6F672807"
```

### **2. Referral Link Sharing**
Users can share their referral link via the app:

**Frontend (Flutter):**
```dart
// File: lib/features/team/presentation/screens/referral_screen.dart

Share.share(
  'Join me on MLM Investment! Use my code $code to register: $link'
);
```

**Link Format:**
```
https://yourapp.com/register?ref=ABC123
```

### **3. Referral Analytics**
Users can view their referral performance:

```dart
// Fetches from backend
ReferralProvider.fetchReferralData()
  ├─ getReferralCode()     // User's own code
  └─ getAnalytics()        // Stats (total referrals, earnings, etc.)
```

**Analytics Include:**
- Total direct referrals
- Total team size (downline)
- Total earnings from referrals
- Active vs inactive referrals
- Level-wise breakdown

---

## 💰 Commission Tracking

### **Commission Types**
```sql
CREATE TABLE commissions (
    commission_type ENUM(
        'direct_sponsor',      -- Direct referral bonus
        'level_bonus',         -- Multi-level commission
        'matching_bonus',      -- Matching team performance
        'rank_bonus',          -- Rank achievement bonus
        'investment_bonus',    -- Investment-based commission
        'roi_bonus',           -- ROI sharing
        'global_pool'          -- Global pool distribution
    )
);
```

### **Example Commission Flow**

**Scenario:** User C invests ₹10,000

```
User A (Sponsor of B)
  └─ User B (Sponsor of C)
      └─ User C (Makes investment of ₹10,000)
```

**Commissions Generated:**
1. **Direct Sponsor (User B):**
   - Type: `direct_sponsor`
   - Amount: ₹1,000 (10% of ₹10,000)
   - Level: 1

2. **Level Bonus (User A):**
   - Type: `level_bonus`
   - Amount: ₹500 (5% of ₹10,000)
   - Level: 2

**Database Entry:**
```sql
INSERT INTO commissions (
    user_id, 
    from_user_id, 
    commission_type, 
    amount, 
    level, 
    reference_type, 
    reference_id
) VALUES 
(2, 3, 'direct_sponsor', 1000.00, 1, 'investment', 123),
(1, 3, 'level_bonus', 500.00, 2, 'investment', 123);
```

---

## 🌳 Genealogy Tree Structure

### **Binary Tree (Default)**
```
                User A
               /      \
          User B      User C
         /     \      /     \
     User D  User E  User F  User G
```

**Features:**
- Each user can have max 2 direct placements
- Spillover to downline when full
- Balanced growth tracking
- Left/Right leg counting

### **Unilevel Tree**
```
                User A
         /       |       \
     User B   User C   User D
     /  |  \
  User E F  G
```

**Features:**
- Unlimited direct referrals
- Level-based commission structure
- Simpler to understand

---

## 📱 Android App Implementation

### **1. Registration with Referral**

**File:** `lib/features/auth/presentation/screens/referral_input_screen.dart`

```dart
class ReferralInputScreen extends StatefulWidget {
  final String phoneNumber;
  
  // User can:
  // 1. Enter referral code
  // 2. Skip (proceed without referral)
}

Future<void> _submitReferral() async {
  await AuthProvider().register(
    phoneNumber,
    _hasReferral ? _referralController.text : null,
  );
}
```

### **2. Viewing Referral Stats**

**File:** `lib/features/team/presentation/screens/referral_screen.dart`

```dart
class ReferralScreen extends StatefulWidget {
  // Displays:
  // - User's referral code
  // - Shareable link
  // - Total referrals
  // - Total earnings
  // - Team analytics
}
```

### **3. Backend API Calls**

**File:** `lib/features/team/data/services/referral_service.dart`

```dart
class ReferralService {
  // GET /?action=get_code
  Future<Map<String, dynamic>> getReferralCode();
  
  // GET /?action=get_analytics
  Future<Map<String, dynamic>> getAnalytics();
}
```

---

## 🔐 Security & Validation

### **1. Referral Code Validation**
```dart
// File: lib/core/utils/validators.dart

static String? validateReferralCode(String? value) {
  if (value == null || value.isEmpty) {
    return null; // Optional
  }
  
  if (value.length < 6 || value.length > 20) {
    return 'Referral code must be between 6-20 characters';
  }
  
  if (!RegExp(r'^[A-Z0-9]+$').hasMatch(value.toUpperCase())) {
    return 'Referral code can only contain letters and numbers';
  }
  
  return null;
}
```

### **2. Backend Validation**
- Checks if referral code exists
- Prevents self-referral
- Validates before user creation
- Returns error if invalid

---

## 📈 Tracking Metrics

### **Key Metrics Tracked:**

1. **Direct Referrals**
   - Count of users directly referred
   - Status (active/inactive)

2. **Team Size**
   - Total downline count
   - Active members
   - Level-wise distribution

3. **Earnings**
   - Total commission earned
   - Per-referral earnings
   - Commission type breakdown

4. **Performance**
   - Conversion rate
   - Average investment per referral
   - Team growth rate

---

## 🚀 Deep Linking (Future Enhancement)

### **For Better Referral Tracking:**

```dart
// Handle deep links like: yourapp://register?ref=ABC123

void handleDeepLink(Uri uri) {
  if (uri.path == '/register') {
    final referralCode = uri.queryParameters['ref'];
    // Pre-fill referral code in registration
  }
}
```

**Benefits:**
- One-click registration with referral
- Better user experience
- Higher conversion rates
- Automatic tracking

---

## 📊 Admin Dashboard Features

### **Admin Can View:**
1. Total referrals system-wide
2. Top referrers
3. Referral conversion rates
4. Commission payouts
5. Genealogy tree visualization
6. Inactive referral chains

---

## 🎯 Best Practices

### **1. Referral Code Design**
✅ **Do:**
- Keep codes short (6-8 characters)
- Use uppercase for consistency
- Make them memorable
- Avoid confusing characters (0 vs O, 1 vs I)

❌ **Don't:**
- Use sequential codes (security risk)
- Make them too long
- Include special characters

### **2. Commission Structure**
✅ **Do:**
- Set clear commission rules
- Document payout schedules
- Track all transactions
- Provide transparency

❌ **Don't:**
- Promise unrealistic returns
- Hide commission calculations
- Delay payouts

### **3. User Experience**
✅ **Do:**
- Make referral sharing easy
- Show real-time stats
- Provide shareable links
- Gamify with leaderboards

❌ **Don't:**
- Force referrals
- Make it complicated
- Hide referral benefits

---

## 🔄 Complete Flow Diagram

```
┌─────────────────────────────────────────────────────────┐
│  User A registers (No referral)                         │
│  - Gets code: ABC123                                    │
│  - referred_by: NULL                                    │
└─────────────────────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│  User A shares code ABC123 with User B                  │
│  - Via WhatsApp, SMS, or in-app share                   │
└─────────────────────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│  User B registers with code ABC123                      │
│  - Gets code: XYZ789                                    │
│  - referred_by: User A's ID                             │
│  - Creates genealogy link                               │
└─────────────────────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│  User B makes investment of ₹10,000                     │
│  - User A earns ₹1,000 direct commission                │
│  - Commission record created                            │
│  - Wallet updated                                       │
└─────────────────────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│  User B shares code XYZ789 with User C                  │
│  - User C registers                                     │
│  - User B earns direct commission                       │
│  - User A earns level 2 commission                      │
└─────────────────────────────────────────────────────────┘
```

---

## 📝 Summary

Your MLM Investment app has a **comprehensive referral tracking system** that:

1. ✅ Generates unique codes for each user
2. ✅ Validates referral codes during registration
3. ✅ Tracks multi-level genealogy
4. ✅ Calculates commissions automatically
5. ✅ Provides analytics and reporting
6. ✅ Supports multiple commission types
7. ✅ Maintains referral relationships in database
8. ✅ Allows easy sharing via social media

The system is **production-ready** and follows MLM industry best practices! 🎉
