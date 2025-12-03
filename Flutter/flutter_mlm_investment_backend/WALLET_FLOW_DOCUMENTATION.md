# WALLET FLOW DOCUMENTATION
## How Referral Earnings and Investment Profits Move to E-Wallet

---

## 🎯 OVERVIEW
After simplification, the system now uses **ONLY E-WALLET** with **ADMIN APPROVAL** for deposits and withdrawals.

---

## 💰 REFERRAL EARNINGS FLOW

### When Does It Happen?
**Trigger:** When a user makes an investment

### Step-by-Step Process:

1. **User Makes Investment**
   - Location: `routes/investment.php` → `invest()` method
   - User's e_wallet balance is deducted
   - Investment record created in `user_investments` table

2. **Commission Distribution Triggered**
   - Location: `routes/investment.php` (line 194-196)
   ```php
   require_once __DIR__ . '/../utils/commission_calculator.php';
   $commCalc = new CommissionCalculator();
   $commCalc->distributeCommissions($this->userId, $amount, $investmentId);
   ```

3. **Direct Referral Commission (5%)**
   - Location: `utils/commission_calculator.php` → `processDirectReferral()`
   - Finds the sponsor from `genealogy` table
   - Calculates: `commission = (investment_amount × 5%) / 100`
   - **IMMEDIATELY credits to sponsor's e_wallet**

4. **Level Income Commission (3%, 2%, 1%)**
   - Location: `utils/commission_calculator.php` → `processLevelIncome()`
   - Traverses upline hierarchy (up to 3 levels)
   - Level 1: 3%, Level 2: 2%, Level 3: 1%
   - **IMMEDIATELY credits to each upline's e_wallet**

5. **Wallet Update**
   - Location: `utils/commission_calculator.php` → `creditCommission()`
   ```php
   UPDATE wallets 
   SET e_wallet_balance = e_wallet_balance + ?, 
       total_earned = total_earned + ? 
   WHERE user_id = ?
   ```

6. **Record Keeping**
   - Creates entry in `commissions` table (for tracking)
   - Creates entry in `transactions` table (for history)
   - Status: `'completed'` (instant credit, no approval needed)

### Summary:
✅ **Referral earnings are INSTANT**
✅ **No admin approval required**
✅ **Credited directly to e_wallet**
✅ **Available immediately for withdrawal/investment**

---

## 📈 INVESTMENT PROFIT FLOW

### When Does It Happen?
**Trigger:** Automated cron job runs daily (or manually via admin panel)

### Step-by-Step Process:

1. **Cron Job Execution**
   - Location: `cron/calculate_profits.php`
   - Scheduled to run: Daily at 1:00 AM
   - Can also be triggered manually: Admin Panel → "Trigger Profit Calculation"

2. **Find Eligible Investments**
   ```sql
   SELECT ui.*, ip.roi_frequency
   FROM user_investments ui
   JOIN investment_products ip ON ui.product_id = ip.id
   WHERE ui.status = 'active'
   AND (
       (roi_frequency = 'daily' AND last_profit_date < CURDATE())
       OR (roi_frequency = 'weekly' AND DATEDIFF >= 7)
       OR (roi_frequency = 'bi-weekly' AND DATEDIFF >= 14)
       OR (roi_frequency = 'monthly' AND DATEDIFF >= 30)
       OR (roi_frequency = 'quarterly' AND DATEDIFF >= 90)
   )
   ```

3. **Calculate Profit**
   - Location: `utils/profit_calculator.php` → `calculateProfit()`
   - Formula depends on ROI frequency:
     - **Daily:** `(amount × roi_percentage) / 100`
     - **Weekly:** `(amount × roi_percentage / 7) / 100`
     - **Bi-weekly:** `(amount × roi_percentage / 14) / 100`
     - **Monthly:** `(amount × roi_percentage / 30) / 100`
     - **Quarterly:** `(amount × roi_percentage / 90) / 100`

4. **Distribute Profit**
   - Location: `utils/profit_calculator.php` → `distributeProfit()`
   
   **Step 4a: Record Profit**
   ```php
   INSERT INTO investment_profits 
   (investment_id, user_id, amount, profit_date, credited_to)
   VALUES (?, ?, ?, CURDATE(), 'e_wallet')
   ```

   **Step 4b: Update Investment Record**
   ```php
   UPDATE user_investments 
   SET total_profit_earned = total_profit_earned + ?,
       last_profit_date = CURDATE()
   WHERE id = ?
   ```

   **Step 4c: Credit E-Wallet**
   ```php
   UPDATE wallets 
   SET e_wallet_balance = e_wallet_balance + ?
   WHERE user_id = ?
   ```

   **Step 4d: Create Transaction Record**
   ```php
   INSERT INTO transactions 
   (user_id, wallet_type, type, amount, description, reference_type, reference_id)
   VALUES (?, 'e_wallet', 'credit', ?, 'Investment Profit', 'investment_profit', ?)
   ```

5. **Process Matured Investments**
   - Location: `utils/profit_calculator.php` → `processMaturedInvestments()`
   - Returns principal + final profit to e_wallet
   - Updates investment status to `'completed'`

### Summary:
✅ **Profits are AUTOMATED**
✅ **No admin approval required**
✅ **Credited directly to e_wallet**
✅ **Runs daily via cron job**
✅ **Can be triggered manually by admin**

---

## 💳 DEPOSIT FLOW (WITH ADMIN APPROVAL)

### Step-by-Step Process:

1. **User Requests Deposit**
   - Location: `routes/wallet.php` → `addFunds()`
   - User submits amount via app
   ```php
   INSERT INTO deposits 
   (user_id, amount, wallet_type, status, created_at)
   VALUES (?, ?, 'e_wallet', 'pending', NOW())
   ```
   - Status: `'pending'`
   - ⏳ **Funds NOT added to wallet yet**

2. **Admin Reviews Request**
   - Admin Panel → "Pending Approvals"
   - Location: `routes/admin.php` → `getPendingApprovals()`
   - Shows all pending deposits

3. **Admin Approves Deposit**
   - Location: `routes/admin.php` → `approveSingleItem()`
   
   **Step 3a: Update Deposit Status**
   ```php
   UPDATE deposits 
   SET status = 'approved', approved_at = NOW(), approved_by = ?
   WHERE id = ?
   ```

   **Step 3b: Credit E-Wallet**
   ```php
   UPDATE wallets 
   SET e_wallet_balance = e_wallet_balance + ?
   WHERE user_id = ?
   ```

   **Step 3c: Create Transaction**
   ```php
   INSERT INTO transactions 
   (user_id, wallet_type, type, amount, description, reference_type, status)
   VALUES (?, 'e_wallet', 'credit', ?, 'Deposit Approved', 'deposit', 'completed')
   ```

4. **User Sees Updated Balance**
   - E-wallet balance increases
   - Transaction appears in history

### Summary:
⏳ **Deposits require ADMIN APPROVAL**
⏳ **Funds held until approved**
✅ **Once approved, credited to e_wallet**

---

## 💸 WITHDRAWAL FLOW (WITH ADMIN APPROVAL)

### Step-by-Step Process:

1. **User Requests Withdrawal**
   - Location: `routes/wallet.php` → `withdraw()`
   
   **Step 1a: Check Balance**
   ```php
   SELECT e_wallet_balance FROM wallets WHERE user_id = ?
   ```

   **Step 1b: Deduct Immediately**
   ```php
   UPDATE wallets 
   SET e_wallet_balance = e_wallet_balance - ?
   WHERE user_id = ?
   ```
   - ⚠️ **Funds deducted immediately** (held for processing)

   **Step 1c: Create Withdrawal Record**
   ```php
   INSERT INTO withdrawals 
   (user_id, amount, wallet_type, status, created_at)
   VALUES (?, ?, 'e_wallet', 'pending', NOW())
   ```

   **Step 1d: Create Transaction**
   ```php
   INSERT INTO transactions 
   (user_id, wallet_type, type, amount, description, status)
   VALUES (?, 'e_wallet', 'debit', ?, 'Withdrawal Request (Pending Approval)', 'pending')
   ```

2. **Admin Reviews Request**
   - Admin Panel → "Pending Approvals"
   - Shows all pending withdrawals

3. **Admin Approves Withdrawal**
   - Location: `routes/admin.php` → `approveSingleItem()`
   ```php
   UPDATE withdrawals 
   SET status = 'approved', approved_at = NOW(), approved_by = ?
   WHERE id = ?
   ```
   - Admin processes payment externally (bank transfer, etc.)
   - ✅ **Funds already deducted, no wallet update needed**

4. **OR Admin Rejects Withdrawal**
   - Location: `routes/admin.php` → `rejectSingleItem()`
   
   **Step 4a: Update Status**
   ```php
   UPDATE withdrawals 
   SET status = 'rejected', rejection_reason = ?, rejected_at = NOW()
   WHERE id = ?
   ```

   **Step 4b: Refund E-Wallet**
   ```php
   UPDATE wallets 
   SET e_wallet_balance = e_wallet_balance + ?
   WHERE user_id = ?
   ```

   **Step 4c: Create Refund Transaction**
   ```php
   INSERT INTO transactions 
   (user_id, wallet_type, type, amount, description, reference_type, status)
   VALUES (?, 'e_wallet', 'credit', ?, 'Withdrawal Rejected - Refund', 'withdrawal_refund', 'completed')
   ```

### Summary:
⚠️ **Funds deducted IMMEDIATELY on request**
⏳ **Held until admin approval**
✅ **If approved: Admin processes payment**
🔄 **If rejected: Funds refunded to e_wallet**

---

## 📊 SUMMARY TABLE

| Transaction Type | Timing | Admin Approval | Wallet Impact |
|-----------------|--------|----------------|---------------|
| **Referral Earnings** | Instant (on investment) | ❌ No | ✅ Immediate credit |
| **Investment Profits** | Daily (cron job) | ❌ No | ✅ Immediate credit |
| **Deposits** | On request | ✅ Yes | ⏳ After approval |
| **Withdrawals** | On request | ✅ Yes | ⚠️ Deducted immediately, held |
| **Investments** | On request | ❌ No | ✅ Immediate debit |

---

## 🔧 TECHNICAL NOTES

### Database Tables Involved:
- `wallets` - Stores e_wallet balance
- `commissions` - Records all referral earnings
- `investment_profits` - Records all investment profits
- `deposits` - Pending/approved deposit requests
- `withdrawals` - Pending/approved withdrawal requests
- `transactions` - Complete transaction history
- `user_investments` - Active investments
- `genealogy` - Referral tree structure

### Key Files:
- `routes/wallet.php` - Deposit/withdrawal requests
- `routes/admin.php` - Approval/rejection logic
- `routes/investment.php` - Investment processing
- `utils/commission_calculator.php` - Referral earnings
- `utils/profit_calculator.php` - Investment profits
- `cron/calculate_profits.php` - Daily profit distribution

### Cron Job Setup:
```bash
# Add to crontab (runs daily at 1:00 AM)
0 1 * * * cd /path/to/backend && php cron/calculate_profits.php >> logs/profits.log 2>&1
```

### Manual Profit Trigger:
Admin can manually trigger via:
- Admin Panel → "Trigger Profit Calculation"
- API: `POST /routes/admin.php?action=trigger_profit_calculation`

---

## ✅ CHANGES MADE (Investment Wallet Removal)

### What Changed:
1. ❌ **Removed:** Investment Wallet (separate wallet)
2. ✅ **Kept:** E-Wallet only (single wallet)
3. ✅ **Added:** Admin approval for deposits
4. ✅ **Added:** Admin approval for withdrawals
5. ✅ **Simplified:** All earnings go to e_wallet
6. ✅ **Simplified:** All investments deduct from e_wallet

### Benefits:
- 🎯 **Simpler for users** - One wallet to manage
- 🎯 **Better control** - Admin approves all money in/out
- 🎯 **Clearer tracking** - Single balance to monitor
- 🎯 **Easier accounting** - One ledger for all transactions

---

*Last Updated: 2025-12-02*
*System Version: 2.0 (Simplified Wallet)*
