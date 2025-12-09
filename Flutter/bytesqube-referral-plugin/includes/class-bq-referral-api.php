<?php

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

class BQ_Referral_API {

	public function __construct() {
		add_action( 'rest_api_init', array( $this, 'register_routes' ) );
	}

	public function register_routes() {
		register_rest_route( 'bytesqube/v1', '/stats', array(
			'methods'  => 'GET',
			'callback' => array( $this, 'get_stats' ),
			'permission_callback' => array( $this, 'check_auth' ),
		) );
	}

	public function check_auth( $request ) {
		return is_user_logged_in();
	}

	public function get_stats( $request ) {
		$user_id = get_current_user_id();
		global $wpdb;
		
		$clicks = $wpdb->get_var( $wpdb->prepare( "SELECT COUNT(*) FROM {$wpdb->prefix}bqr_clicks WHERE affiliate_id = %d", $user_id ) );
		$referrals = $wpdb->get_var( $wpdb->prepare( "SELECT COUNT(*) FROM {$wpdb->prefix}bqr_referrals WHERE affiliate_id = %d AND status = 'verified'", $user_id ) );
		
		$wallet = new BQ_Referral_Wallet();
		$balance = $wallet->get_balance( $user_id );

		return new WP_REST_Response( array( 
			'clicks' => $clicks,
			'referrals' => $referrals,
			'balance' => $balance,
			'referral_link' => BQ_Referral_Tracker::get_referral_link( $user_id )
		), 200 );
	}
}
