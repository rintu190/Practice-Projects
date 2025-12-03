<?php
class AppConfig {
    // Withdrawal Settings
    const MIN_WITHDRAWAL_AMOUNT = 100.0;
    const MAX_DAILY_WITHDRAWAL = 50000.0;
    const WITHDRAWAL_CHARGE_PERCENTAGE = 2.0;
    
    // Deposit Settings
    const MIN_DEPOSIT_AMOUNT = 100.0;
    const MAX_DEPOSIT_AMOUNT = 100000.0;
    
    // Investment Settings
    const MIN_INVESTMENT_AMOUNT = 1000.0;
    const MAX_INVESTMENT_AMOUNT = 1000000.0;
    
    // Admin Approval Settings
    const REQUIRE_ADMIN_APPROVAL = false; // Set to true in production
}
?>
