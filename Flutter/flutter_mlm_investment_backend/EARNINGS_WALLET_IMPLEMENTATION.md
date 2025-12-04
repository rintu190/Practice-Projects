# Earnings Wallet System - Implementation Summary

## ✅ Completed Changes

### 1. Database Schema Updates
- Added `earnings_balance` column to `wallets` table
- Created `earnings_withdrawals` table to track transfers from earnings to e-wallet
- Migrated existing `total_earned` to `earnings_balance`

### 2. Backend Updates
- **Commission Calculator** (`utils/commission_calculator.php`):
  - Now credits commissions to `earnings_balance` instead of `e_wallet_balance`
  - Transaction records use `wallet_type = 'earnings'`
  
- **Profit Calculator** (`utils/profit_calculator.php`):
  - Now credits investment profits to `earnings_balance` instead of `e_wallet_balance`
  - Transaction records use `wallet_type = 'earnings'`

## 🔄 Pending Tasks

### 3. Dashboard API Update
- Update `routes/dashboard.php` to return `earnings_balance` in wallet data

### 4. Earnings Withdrawal API
- Create new endpoint in `routes/wallet.php`:
  - `action=withdraw_earnings`
  - Transfer from `earnings_balance` to `e_wallet_balance`
  - Record in `earnings_withdrawals` table
  - Create transaction records

### 5. Earnings Breakdown API
- Create new endpoint to get earnings breakdown:
  - Commissions by type (direct, level, matching)
  - Investment profits by product
  - Total earnings
  - Available to withdraw

### 6. Frontend Updates
- Update dashboard to show earnings_balance
- Add "Withdraw to Wallet" button on earnings card
- Create earnings breakdown screen
- Update wallet service to handle earnings withdrawal

## Database Structure

```sql
wallets:
- e_wallet_balance (for spending/withdrawal)
- earnings_balance (accumulated earnings, needs manual withdrawal)
- total_earned (lifetime total)

earnings_withdrawals:
- Records all transfers from earnings to e-wallet
```

## Flow
1. User earns commission/profit → Goes to `earnings_balance`
2. User clicks "Withdraw to Wallet" → Transfers to `e_wallet_balance`
3. User can withdraw `e_wallet_balance` to bank account
