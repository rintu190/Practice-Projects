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
			reference_id varchar(100) NOT NULL, -- e.g., Order ID or User ID
			type varchar(50) NOT NULL, -- 'purchase', 'signup'
			amount decimal(10,2) DEFAULT 0.00, -- Order amount
			currency varchar(10) DEFAULT 'USD',
			status varchar(20) DEFAULT 'pending', -- pending, verified, rejected
			description text,
			parent_referral_id bigint(20) DEFAULT 0, -- For multi-level
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
			user_id bigint(20) NOT NULL, -- The affiliate User ID
			amount decimal(10,2) NOT NULL,
			type varchar(50) NOT NULL, -- 'commission', 'payout', 'bonus', 'penalty'
			status varchar(20) DEFAULT 'completed',
			reference_id bigint(20) DEFAULT 0, -- ID from bqr_referrals or bqr_payouts
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
			method varchar(50) NOT NULL, -- 'paypal', 'bank', 'upi'
			details text NOT NULL, -- JSON or serialized payment details
			status varchar(20) DEFAULT 'pending', -- pending, processing, paid, rejected
			processed_at datetime DEFAULT NULL,
			created_at datetime DEFAULT CURRENT_TIMESTAMP,
			PRIMARY KEY  (id),
			KEY affiliate_id (affiliate_id)
		) $charset_collate;";

		require_once( ABSPATH . 'wp-admin/includes/upgrade.php' );
		dbDelta( $sql_clicks );
		dbDelta( $sql_referrals );
		dbDelta( $sql_transactions );
		dbDelta( $sql_payouts );

		// Update version option
		update_option( 'bqr_db_version', '1.0.0' );
	}
}
