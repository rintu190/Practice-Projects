<?php

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

class BQ_Referral_Tracker {

	private $cookie_name = 'bqr_ref_id';
	private $cookie_expiry = 30; // Days

	public function __construct() {
		add_action( 'init', array( $this, 'capture_referral' ) );
		add_action( 'user_register', array( $this, 'handle_user_registration' ) );
	}

	/**
	 * Handle User Registration - Bind new user to referrer
	 */
	/**
	 * Handle User Registration - Bind new user to referrer
	 */
	public function handle_user_registration( $user_id ) {
		// Generate and assign unique referral code
		$code = $this->generate_unique_referral_code();
		update_user_meta( $user_id, 'bqr_referral_code', $code );

		$referrer_id = $this->get_current_referrer_id();
		if ( $referrer_id ) {
			// Save the referrer ID in the new user's meta
			update_user_meta( $user_id, 'bqr_referrer_id', $referrer_id );
			
			// Optional: Log signup conversion immediately
			global $wpdb;
			$wpdb->insert(
				$wpdb->prefix . 'bqr_referrals',
				array(
					'affiliate_id' => $referrer_id,
					'reference_id' => $user_id,
					'type'         => 'signup',
					'amount'       => 0.00, // Or a signup bonus
					'status'       => 'verified',
					'description'  => 'New User Signup'
				),
				array( '%d', '%s', '%s', '%f', '%s', '%s' )
			);
		}
	}

	/**
	 * Generate a unique 4-6 character alphanumeric referral code
	 */
	public function generate_unique_referral_code() {
		global $wpdb;
		$length = 6;
		$chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
		$max_attempts = 10;
		
		for ( $i = 0; $i < $max_attempts; $i++ ) {
			$code = '';
			for ( $j = 0; $j < $length; $j++ ) {
				$code .= $chars[ rand( 0, strlen( $chars ) - 1 ) ];
			}
			
			// Check uniqueness
			// 1. Check meta
			$exists_meta = $wpdb->get_var( $wpdb->prepare( 
				"SELECT user_id FROM {$wpdb->usermeta} WHERE meta_key = 'bqr_referral_code' AND meta_value = %s", 
				$code 
			) );
			
			// 2. Check usernames (avoid conflict if someone has this username)
			$exists_user = username_exists( $code );
			
			if ( ! $exists_meta && ! $exists_user ) {
				return $code;
			}
		}
		
		// Fallback: If collision persists (highly unlikely), append timestamp
		return 'REF' . rand(100, 999);
	}

	/**
	 * Capture 'ref' parameter from URL and set cookie
	 */
	public function capture_referral() {
		if ( is_admin() ) {
			return;
		}

		if ( isset( $_GET['ref'] ) && ! empty( $_GET['ref'] ) ) {
			$referral_code = sanitize_text_field( $_GET['ref'] );
			
			// Resolve referral code to User ID
			$affiliate_user = $this->get_user_by_referral_code( $referral_code );

			if ( $affiliate_user ) {
				$affiliate_id = $affiliate_user->ID;

				// Self-referral check (if user is logged in)
				if ( is_user_logged_in() && get_current_user_id() == $affiliate_id ) {
					return; // Do not track self-referrals
				}

				// Set Cookie
				setcookie( $this->cookie_name, $affiliate_id, time() + ( 86400 * $this->cookie_expiry ), COOKIEPATH, COOKIE_DOMAIN );

				// Log Click to DB
				$this->log_click( $affiliate_id );
			}
		}
	}

	/**
	 * Log the click to database
	 */
	private function log_click( $affiliate_id ) {
		global $wpdb;
		$table_name = $wpdb->prefix . 'bqr_clicks';

		// Basic Fraud check: Check if same IP clicked for same affiliate in last hour
		$ip = $this->get_ip_address();
		$exists = $wpdb->get_var( $wpdb->prepare(
			"SELECT id FROM $table_name WHERE affiliate_id = %d AND visitor_ip = %s AND created_at > %s",
			$affiliate_id,
			$ip,
			date( 'Y-m-d H:i:s', strtotime( '-1 hour' ) )
		) );

		if ( ! $exists ) {
			$wpdb->insert(
				$table_name,
				array(
					'affiliate_id' => $affiliate_id,
					'visitor_ip'   => $ip,
					'referrer_url' => isset( $_SERVER['HTTP_REFERER'] ) ? sanitize_text_field( $_SERVER['HTTP_REFERER'] ) : '',
					'page_visited' => isset( $_SERVER['REQUEST_URI'] ) ? sanitize_text_field( $_SERVER['REQUEST_URI'] ) : '',
					'browser'      => isset( $_SERVER['HTTP_USER_AGENT'] ) ? sanitize_text_field( $_SERVER['HTTP_USER_AGENT'] ) : '',
				),
				array( '%d', '%s', '%s', '%s', '%s' )
			);
		}
	}

	/**
	 * Get IP Address
	 */
	private function get_ip_address() {
		if ( ! empty( $_SERVER['HTTP_CLIENT_IP'] ) ) {
			$ip = $_SERVER['HTTP_CLIENT_IP'];
		} elseif ( ! empty( $_SERVER['HTTP_X_FORWARDED_FOR'] ) ) {
			$ip = $_SERVER['HTTP_X_FORWARDED_FOR'];
		} else {
			$ip = $_SERVER['REMOTE_ADDR'];
		}
		return $ip;
	}

	/**
	 * Get User by Referral Code
	 * Currently assumes referral code = username for simplicity, 
	 * or stores a custom meta 'bqr_referral_code'.
	 */
	public function get_user_by_referral_code( $code ) {
		// First, check by ID if it's numeric
		if ( is_numeric( $code ) ) {
			$user = get_userdata( $code );
			if ( $user ) return $user;
		}

		// Check meta (the new standard)
		$users = get_users( array(
			'meta_key'   => 'bqr_referral_code',
			'meta_value' => $code,
			'number'     => 1,
			'fields'     => 'all_with_meta'
		) );

		if ( ! empty( $users ) ) {
			return $users[0];
		}

		// Fallback: Check by username (backward compatibility)
		$user = get_user_by( 'login', $code );
		if ( $user ) return $user;

		return false;
	}

	/**
	 * Get current tracked affiliate ID from cookie
	 */
	public function get_current_referrer_id() {
		if ( isset( $_COOKIE[ $this->cookie_name ] ) ) {
			return intval( $_COOKIE[ $this->cookie_name ] );
		}
		return 0;
	}

	/**
	 * Generate a referral link for a user
	 */
	public static function get_referral_link( $user_id ) {
		$user = get_userdata( $user_id );
		if ( ! $user ) return '';
		
		// Use username or custom code
		$code = get_user_meta( $user_id, 'bqr_referral_code', true );
		
		// Lazy-generate code if missing
		if ( ! $code ) {
			$tracker = new self();
			$code = $tracker->generate_unique_referral_code();
			update_user_meta( $user_id, 'bqr_referral_code', $code );
		}

		return home_url( '/?ref=' . $code );
	}
}
new BQ_Referral_Tracker();
