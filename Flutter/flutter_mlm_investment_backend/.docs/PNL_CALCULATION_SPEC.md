# P&L Calculation Specification

## Problem
Multiple inconsistent P&L calculations across the application:
- Dashboard uses `daily_pnl` table SUM
- Investment history calculates on-the-fly using daily ROI
- Portfolio shows different values

## Solution: Single Source of Truth

### Database Schema
```sql
-- daily_pnl table (already exists)
CREATE TABLE daily_pnl (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    investment_id INT NULL,
    pnl_date DATE NOT NULL,
    profit_amount DECIMAL(15,2) DEFAULT 0,
    loss_amount DECIMAL(15,2) DEFAULT 0,
    net_pnl DECIMAL(15,2) DEFAULT 0,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- user_investments table should track cumulative profit
ALTER TABLE user_investments 
ADD COLUMN total_profit_earned DECIMAL(15,2) DEFAULT 0,
ADD COLUMN last_profit_date DATE NULL;
```

### Calculation Rules

1. **Daily P&L Entry**: Admin uploads daily P&L for each investment
   - Stored in `daily_pnl` table with `investment_id`
   - Updates `user_investments.total_profit_earned`
   - Updates `user_investments.last_profit_date`

2. **Today's P&L**: 
   ```sql
   SELECT SUM(net_pnl) FROM daily_pnl 
   WHERE user_id = ? AND DATE(pnl_date) = CURDATE()
   ```

3. **Total Unrealized P&L**:
   ```sql
   SELECT SUM(net_pnl) FROM daily_pnl WHERE user_id = ?
   ```

4. **Investment Current Value**:
   ```
   current_value = amount + total_profit_earned
   ```

5. **Portfolio Total**:
   ```
   total_invested = SUM(user_investments.amount)
   total_profit = SUM(user_investments.total_profit_earned)
   current_value = total_invested + total_profit
   ```

### API Endpoints Must Return Consistent Data

All endpoints should use the same calculation:
- `/routes/dashboard.php?action=get_data`
- `/routes/investment.php?action=get_my_investments`
- `/routes/investment.php?action=get_portfolio`
- `/routes/pnl.php?action=get_history`

## Implementation Steps

1. ✅ Ensure `user_investments` has `total_profit_earned` column
2. ✅ Update `investment.php` to use `total_profit_earned` instead of calculating
3. ✅ Ensure daily P&L upload updates `user_investments.total_profit_earned`
4. ✅ Update dashboard to use consistent calculations
5. ✅ Update Flutter models to use backend data directly
