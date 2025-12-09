<?php

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

class BQ_Referral_Notifications {

	public function __construct() {
		add_action( 'bqr_referral_verified', array( $this, 'send_commission_email' ), 10, 2 );
		add_action( 'bqr_payout_requested', array( $this, 'send_payout_request_admin_email' ), 10, 2 );
		add_action( 'bqr_payout_paid', array( $this, 'send_payout_paid_email' ), 10, 2 );
		// Hook into user registration for welcome email if needed
	}

	public function send_commission_email( $affiliate_id, $amount ) {
		$user = get_userdata( $affiliate_id );
		if ( ! $user ) return;

		$subject = 'You Earned a Commission! - BytesQube';
		$message = "Hi " . $user->display_name . ",\n\n";
		$message .= "Great news! You have earned a commission of " . wc_price( $amount ) . " from a recent referral.\n";
		$message .= "This amount has been credited to your BytesQube Wallet.\n\n";
		$message .= "Keep up the great work!\n";
		$message .= "View your dashboard: " . home_url( '/affiliate-dashboard' ) . "\n\n";
		$message .= "Regards,\nBytesQube Team";

		wp_mail( $user->user_email, $subject, $message );
	}

	public function send_payout_request_admin_email( $payout_id, $affiliate_id ) {
		$admin_email = get_option( 'admin_email' );
		$user = get_userdata( $affiliate_id );
		
		$subject = 'New Payout Request #' . $payout_id;
		$message = "Admin,\n\n";
		$message .= "Affiliate " . $user->display_name . " has requested a payout.\n";
		$message .= "Please review and process it in the admin panel.\n";

		wp_mail( $admin_email, $subject, $message );
	}

	public function send_payout_paid_email( $payout_id, $affiliate_id ) {
		$user = get_userdata( $affiliate_id );
		if ( ! $user ) return;

		$subject = 'Payout Processed - BytesQube';
		$message = "Hi " . $user->display_name . ",\n\n";
		$message .= "Your payout request #" . $payout_id . " has been processed and paid.\n";
		$message .= "Please check your account.\n\n";
		$message .= "Regards,\nBytesQube Team";

		wp_mail( $user->user_email, $subject, $message );
	}
}
