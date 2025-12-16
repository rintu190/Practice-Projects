<?php

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

class BQ_Referral_DB {

	public static function create_tables() {
		global $wpdb;

		$charset_collate = $wpdb->get_charset_collate();

		// 1. Clicks Table - Tracks every click on a referral link
		$table_clicks = $wpdb->prefix . 'bqr_clicks';
		$sql_clicks = "CREATE TABLE $table_clicks (
			id bigint(20) NOT NULL AUTO_INCREMENT,
			affiliate_id bigint(20) NOT NULL,
			visitor_ip varchar(100) NOT NULL,
			referrer_url text DEFAULT NULL,
			page_visited text NOT NULL,
			browser varchar(255) DEFAULT '',
			created_at datetime DEFAULT CURRENT_TIMESTAMP,
			PRIMARY KEY  (id),
			KEY affiliate_id (affiliate_id)
		) $charset_collate;";

		// 2. Referrals Table - Tracks successful conversions (orders/signups)
		$table_referrals = $wpdb->prefix . 'bqr_referrals';
		$sql_referrals = "CREATE TABLE $table_referrals (
			id bigint(20) NOT NULL AUTO_INCREMENT,
			affiliate_id bigint(20) NOT NULL,
			reference_id varchar(100) NOT NULL,
			type varchar(50) NOT NULL,
			amount decimal(10,2) DEFAULT 0.00,
			currency varchar(10) DEFAULT 'USD',
			status varchar(20) DEFAULT 'pending',
			description text,
			parent_referral_id bigint(20) DEFAULT 0,
			created_at datetime DEFAULT CURRENT_TIMESTAMP,
			updated_at datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
			PRIMARY KEY  (id),
			KEY affiliate_id (affiliate_id),
			KEY reference_id (reference_id)
		) $charset_collate;";

		// 3. Transactions Table - The Wallet
		$table_transactions = $wpdb->prefix . 'bqr_transactions';
		$sql_transactions = "CREATE TABLE $table_transactions (
			id bigint(20) NOT NULL AUTO_INCREMENT,
			user_id bigint(20) NOT NULL,
			amount decimal(10,2) NOT NULL,
			type varchar(50) NOT NULL,
			status varchar(20) DEFAULT 'completed',
			reference_id bigint(20) DEFAULT 0,
			description varchar(255) DEFAULT '',
			balance_after decimal(10,2) DEFAULT 0.00,
			created_at datetime DEFAULT CURRENT_TIMESTAMP,
			PRIMARY KEY  (id),
			KEY user_id (user_id)
		) $charset_collate;";

		// 4. Payout Requests
		$table_payouts = $wpdb->prefix . 'bqr_payouts';
		$sql_payouts = "CREATE TABLE $table_payouts (
			id bigint(20) NOT NULL AUTO_INCREMENT,
			affiliate_id bigint(20) NOT NULL,
			amount decimal(10,2) NOT NULL,
			method varchar(50) NOT NULL,
			details text NOT NULL,
			status varchar(20) DEFAULT 'pending',
			processed_at datetime DEFAULT NULL,
			created_at datetime DEFAULT CURRENT_TIMESTAMP,
			PRIMARY KEY  (id),
			KEY affiliate_id (affiliate_id)
		) $charset_collate;";


		// 5. Investments Table
		$table_investments = $wpdb->prefix . 'bqr_investments';
		$sql_investments = "CREATE TABLE $table_investments (
			id bigint(20) NOT NULL AUTO_INCREMENT,
			user_id bigint(20) NOT NULL,
			amount decimal(10,2) NOT NULL,
			category varchar(50) DEFAULT 'Securities & Derivatives',
			roi_rate decimal(5,2) NOT NULL DEFAULT 1.00,
			start_date datetime DEFAULT CURRENT_TIMESTAMP,
			last_profit_withdrawal datetime DEFAULT CURRENT_TIMESTAMP,
			status varchar(20) DEFAULT 'active',
			total_earned decimal(10,2) DEFAULT 0.00,
			created_at datetime DEFAULT CURRENT_TIMESTAMP,
			PRIMARY KEY  (id),
			KEY user_id (user_id)
		) $charset_collate;";

		require_once( ABSPATH . 'wp-admin/includes/upgrade.php' );
		dbDelta( $sql_clicks );
		dbDelta( $sql_referrals );
		dbDelta( $sql_transactions );
		dbDelta( $sql_payouts );
		dbDelta( $sql_investments );

		// Update version option
		update_option( 'bqr_db_version', '1.2.3' );
	}
}
