# Admin Panel Approvals Feature

## Overview

The Admin Panel now includes functionality to approve all pending deposits, withdrawals, and wallet transfers with a single click. This streamlines the approval process for administrators.

## Features

### 1. Approve All Deposits
- **Endpoint**: `GET /routes/admin.php?action=approve_deposits`
- **Description**: Approves all pending deposit requests
- **Database Updates**:
  - Sets `status = 'approved'`
  - Records `approved_at` timestamp
  - Records `approved_by` admin user ID
- **Response**:
  ```json
  {
    "success": true,
    "message": "All pending deposits approved",
    "data": {
      "approved_count": 5,
      "pending_before": 5,
      "pending_after": 0
    }
  }
  ```

### 2. Approve All Withdrawals
- **Endpoint**: `GET /routes/admin.php?action=approve_withdrawals`
- **Description**: Approves all pending withdrawal requests
- **Database Updates**:
  - Sets `status = 'approved'`
  - Records `approved_at` timestamp
  - Records `approved_by` admin user ID
- **Response**:
  ```json
  {
    "success": true,
    "message": "All pending withdrawals approved",
    "data": {
      "approved_count": 3,
      "pending_before": 3,
      "pending_after": 0
    }
  }
  ```

### 3. Approve All Transfers
- **Endpoint**: `GET /routes/admin.php?action=approve_transfers`
- **Description**: Approves all pending wallet transfer requests
- **Database Updates**:
  - Sets `status = 'completed'` for transactions with `reference_type = 'transfer'`
  - Updates `updated_at` timestamp
- **Response**:
  ```json
  {
    "success": true,
    "message": "All pending transfers approved",
    "data": {
      "approved_count": 2,
      "pending_before": 2,
      "pending_after": 0
    }
  }
  ```

## Database Schema Requirements

### Deposits Table
```sql
ALTER TABLE deposits ADD COLUMN approved_by INT DEFAULT NULL;
ALTER TABLE deposits ADD COLUMN approved_at TIMESTAMP DEFAULT NULL;
```

### Withdrawals Table
```sql
ALTER TABLE withdrawals ADD COLUMN approved_by INT DEFAULT NULL;
ALTER TABLE withdrawals ADD COLUMN approved_at TIMESTAMP DEFAULT NULL;
```

### Transactions Table
- Already has `status` and `reference_type` columns
- `status` field supports: 'pending', 'completed', 'failed'
- `reference_type` field supports: 'transfer', 'deposit', 'withdrawal'

## Usage in Admin Panel

1. Navigate to **Admin Panel** from the dashboard
2. Scroll to **Approvals** section
3. Click one of the following buttons:
   - **Approve Deposits** - Approves all pending deposit requests
   - **Approve Withdrawals** - Approves all pending withdrawal requests
   - **Approve Transfers** - Approves all pending wallet transfers

4. The system shows a success message with:
   - Number of items approved
   - Pending count before and after

## Security

- Only admin users (users with `role = 'admin'` in JWT token) can access these endpoints
- Each approval is logged with the admin user ID
- Requires valid Bearer token authentication

## Audit Trail

All approvals are tracked:
- **Deposits/Withdrawals**: `approved_by` field records admin ID, `approved_at` records timestamp
- **Transfers**: `updated_at` field records when transfer was completed

## Notes

- Approvals are **permanent** - they cannot be undone
- Bulk approval is useful for processing multiple pending requests
- Consider implementing approval confirmation dialogs for safety
- Monitor the database for audit trails to track approvals

## Future Enhancements

- Add approval confirmation dialogs
- Implement selective approval (approve individual items)
- Add bulk reject functionality
- Create approval history/audit logs
- Add filters to view pending items before approval
- Implement notification system for approved users
