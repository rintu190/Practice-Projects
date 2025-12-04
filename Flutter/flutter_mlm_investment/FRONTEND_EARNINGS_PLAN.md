# Frontend Implementation Plan - Earnings Wallet System

## ✅ Completed
1. API Config updated with earnings endpoints

## 🔄 Remaining Frontend Tasks

### 1. Create Earnings Service
**File:** `lib/features/earnings/data/services/earnings_service.dart`
- `getEarningsBreakdown()` - Fetch earnings breakdown
- `getEarningsHistory()` - Fetch earnings history
- `withdrawEarnings(amount)` - Withdraw earnings to wallet

### 2. Update Wallet Service
**File:** `lib/features/wallet/data/services/wallet_service.dart`
- Add `withdrawEarnings(amount)` method

### 3. Update Dashboard Provider
**File:** `lib/features/dashboard/data/providers/dashboard_provider.dart`
- Add `earningsBalance` getter
- Update to handle earnings_balance from API

### 4. Update Dashboard Screen
**File:** `lib/features/dashboard/presentation/screens/dashboard_screen.dart`
- Update wallet card to show earnings_balance
- Add "Withdraw to Wallet" button
- Make earnings card tappable to navigate to breakdown screen

### 5. Create Earnings Breakdown Screen
**File:** `lib/features/earnings/presentation/screens/earnings_breakdown_screen.dart`
- Show total earnings
- Show earnings by source (commissions, profits)
- Show commission breakdown (direct, level, matching)
- Show profit breakdown by product
- Show withdrawal history
- Add "Withdraw All" button

### 6. Create Earnings Provider
**File:** `lib/features/earnings/data/providers/earnings_provider.dart`
- Manage earnings state
- Handle withdrawal logic

## UI Design Requirements

### Dashboard Earnings Card
```
┌─────────────────────────────────┐
│ 💰 Total Earnings               │
│ ₹2,302.38                       │
│                                 │
│ [Withdraw to Wallet] Button     │
│                                 │
│ Tap for detailed breakdown →   │
└─────────────────────────────────┘
```

### Earnings Breakdown Screen
```
┌─────────────────────────────────┐
│ ← Earnings Breakdown            │
├─────────────────────────────────┤
│ Available Balance               │
│ ₹2,302.38                       │
│ [Withdraw All to Wallet]        │
├─────────────────────────────────┤
│ 📊 Earnings Summary             │
│ Total Earned: ₹2,302.38         │
│ Total Withdrawn: ₹0.00          │
├─────────────────────────────────┤
│ 💼 Commissions (₹0.00)          │
│ • Direct Referral: ₹0.00        │
│ • Level Bonus: ₹0.00            │
│ • Matching Bonus: ₹0.00         │
├─────────────────────────────────┤
│ 📈 Investment Profits (₹2,302)  │
│ • Product A: ₹1,200             │
│ • Product B: ₹1,102             │
├─────────────────────────────────┤
│ 📜 Recent Earnings              │
│ [List of transactions]          │
└─────────────────────────────────┘
```

## Next Steps
1. Create earnings feature folder structure
2. Implement earnings service
3. Update dashboard to show earnings
4. Create earnings breakdown screen
5. Test the complete flow
