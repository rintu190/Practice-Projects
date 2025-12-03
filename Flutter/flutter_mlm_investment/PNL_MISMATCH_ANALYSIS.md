# P&L Mismatch Analysis - Dashboard vs Portfolio

## Problem
The profit and loss (P&L) values shown in Dashboard and Portfolio screens don't match:
- Dashboard shows: "Today's P&L" and "Unrealized P&L" 
- Portfolio shows: Investment amounts and ROI percentages
- **Issue**: Values are calculated differently from different sources

## Current Data Sources

### Dashboard (dashboard.php)
**Today's P&L**: Fetches from `daily_pnl` table
```sql
SELECT SUM(net_pnl) as today_pnl 
FROM daily_pnl 
WHERE user_id = ? AND pnl_date = CURRENT_DATE
```

**Total P&L (Unrealized)**: Fetches from `daily_pnl` table (all days)
```sql
SELECT SUM(net_pnl) as total_pnl 
FROM daily_pnl 
WHERE user_id = ?
```

**Investment Profit**: Set to hardcoded 0
```php
'total_profit' => (float)($investment['total_profit'] ?? 0),
```

### Portfolio (dashboard_provider.dart → dashboard_service.dart)
**Current Value**: From dashboard investment data (currently = total_invested)
**Profit**: Calculated as `current_value - total_invested` (which equals 0)

## The Real Issue

### Backend Query (Line 81-88)
```php
$invStmt = $this->conn->prepare("
    SELECT 
        SUM(amount) as total_invested,
        SUM(amount) as current_value,    // ← WRONG: Should calculate growth
        0 as total_profit                 // ← HARDCODED 0: Should calculate actual profit
    FROM user_investments 
    WHERE user_id = ? AND status = 'active'
");
```

**Problems:**
1. `current_value` = `total_invested` (not accounting for growth)
2. `total_profit` is always 0 (hardcoded)
3. Daily P&L from `daily_pnl` table might not match investment profit

## Solution

### 1. Fix Backend P&L Calculation
Need to calculate actual profit from investments:
- Option A: Query from user_investments and calculate (current - invested)
- Option B: Sum all daily_pnl entries as "total profit"
- **Best**: Use daily_pnl for "today's P&L" and sum of all daily_pnl for "unrealized total P&L"

### 2. Update dashboard.php
```php
// Get current value with P&L calculation
$pnlSumStmt = $this->conn->prepare("
    SELECT SUM(net_pnl) as unrealized_profit 
    FROM daily_pnl 
    WHERE user_id = ? AND status = 'active'
");

// Update investment data
'investment' => [
    'total_invested' => (float)($investment['total_invested'] ?? 0),
    'current_value' => (float)($investment['total_invested'] ?? 0) + (float)($unrealizedProfit ?? 0),
    'total_profit' => (float)($unrealizedProfit ?? 0),
]
```

### 3. Ensure Portfolio Uses Correct Values
Portfolio should display:
- **Total Invested**: Sum of all investment amounts
- **Current Value**: Total Invested + Unrealized Profit
- **Total Profit/Unrealized P&L**: Sum from daily_pnl table

## P&L Types Explanation

| Type | Source | When | Value |
|------|--------|------|-------|
| **Today's P&L** | daily_pnl WHERE pnl_date = TODAY | Real-time gains/losses | Refreshes daily |
| **Unrealized P&L** | SUM(daily_pnl) | Total from inception | cumulative gains/losses |
| **Total Profit** | current_value - total_invested | Portfolio view | Same as Unrealized P&L |
| **Current Value** | total_invested + unrealized_pnl | Portfolio display | Investment + gains |

## Required Changes

### Backend
- [ ] Fix `current_value` calculation in investment query
- [ ] Fix `total_profit` calculation (use actual data, not 0)
- [ ] Ensure `today_pnl` and `total_pnl` come from same source
- [ ] Return `unrealized_pnl` separately for clarity

### Frontend
- [ ] Dashboard: Display `today_pnl` and `unrealized_pnl` correctly
- [ ] Portfolio: Display investment with `current_value` and `total_profit`
- [ ] Ensure both use same backend values

## Status
🔴 **PENDING** - Need to fix backend queries and recalculate P&L values
