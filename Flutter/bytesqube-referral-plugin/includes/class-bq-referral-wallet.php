<?php

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

class BQ_Referral_Wallet {

	/**
	 * Get Current Wallet Balance for a User
	 */
	public function get_balance( $user_id ) {
		global $wpdb;
		$table_name = $wpdb->prefix . 'bqr_transactions';
		
		// Sum all transaction amounts
		$balance = $wpdb->get_var( $wpdb->prepare(
			"SELECT SUM(amount) FROM $table_name WHERE user_id = %d AND status = 'completed'",
			$user_id
		) );

		return $balance ? floatval( $balance ) : 0.00;
	}

	/**
	 * Add a transaction (Credit or Debit)
	 */
	public function add_transaction( $user_id, $amount, $type, $reference_id = 0, $description = '' ) {
		global $wpdb;
		$table_name = $wpdb->prefix . 'bqr_transactions';

		// If it's a payout (debit), ensure amount is negative strictly if we sum all.
		// However, display logic usually prefers positive numbers for "Payout of $50".
		// Let's decide: Credits are positive, Debits are negative in the DB sum.
		
		if ( $type === 'payout' && $amount > 0 ) {
			$amount = -1 * abs( $amount );
		}

		$current_balance = $this->get_balance( $user_id );
		$new_balance = $current_balance + $amount;

		$wpdb->insert(
			$table_name,
			array(
				'user_id'       => $user_id,
				'amount'        => $amount,
				'type'          => $type,
				'status'        => 'completed',
				'reference_id'  => $reference_id,
				'description'   => $description,
				'balance_after' => $new_balance
			),
			array( '%d', '%f', '%s', '%s', '%d', '%s', '%f' )
		);

		return $wpdb->insert_id;
	}

	/**
	 * Check if user has sufficient balance
	 */
	public function has_sufficient_balance( $user_id, $amount ) {
		return $this->get_balance( $user_id ) >= $amount;
	}
}
