<?php

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

class BQ_Referral_WooCommerce {

	public function __construct() {
		add_action( 'woocommerce_order_status_completed', array( $this, 'process_referral_on_order' ), 10, 1 );
		// Store referrer in order meta when order is created
		add_action( 'woocommerce_checkout_update_order_meta', array( $this, 'add_referrer_to_order' ), 10, 1 );
	}

	/**
	 * Save referrer ID to the order
	 */
	public function add_referrer_to_order( $order_id ) {
		$referrer_id = 0;

		// 1. Check for Coupons (High Priority)
		if ( class_exists( 'WC_Coupon' ) ) {
			$order = wc_get_order( $order_id );
			$coupons = $order->get_coupon_codes();
			
			if ( ! empty( $coupons ) ) {
				foreach ( $coupons as $code ) {
					// Check if this coupon belongs to an affiliate
					$users = get_users( array(
						'meta_key'    => 'bqr_referral_coupon',
						'meta_value'  => $code,
						'number'      => 1,
						'fields'      => 'ID'
					) );
					
					if ( ! empty( $users ) ) {
						$referrer_id = $users[0];
						break; // Found a referrer
					}
				}
			}
		}

		// 2. Fallback to Cookie (if no coupon referrer found)
		if ( ! $referrer_id ) {
			$tracker = new BQ_Referral_Tracker();
			$referrer_id = $tracker->get_current_referrer_id();
		}

		if ( $referrer_id ) {
			// Prevent self-referral
			$order = wc_get_order( $order_id );
			if ( $order->get_user_id() != $referrer_id ) {
				update_post_meta( $order_id, '_bqr_referrer_id', $referrer_id );
			}
		}
	}

	/**
	 * Process commission when order is completed
	 */
	public function process_referral_on_order( $order_id ) {
		// Avoid duplicates: check if already processed
		if ( get_post_meta( $order_id, '_bqr_commission_processed', true ) ) {
			return;
		}

		$referrer_id = get_post_meta( $order_id, '_bqr_referrer_id', true );
		
		// Fallback: Check if the BUYER was referred by someone during registration (Life-time association)
		if ( ! $referrer_id ) {
			$order = wc_get_order( $order_id );
			$user_id = $order->get_user_id();
			if ( $user_id ) {
				$referrer_id = get_user_meta( $user_id, 'bqr_referrer_id', true );
			}
		}

		if ( ! $referrer_id ) {
			return;
		}

		$order = wc_get_order( $order_id );
		if ( ! $order ) return;

		global $wpdb;
		$table_referrals = $wpdb->prefix . 'bqr_referrals';
		$order_total = $order->get_total() - $order->get_total_tax() - $order->get_shipping_total();

		// Level 1 Commission
		$commission_l1 = $this->calculate_commission( $order_total, $referrer_id, 1 );

		if ( $commission_l1 > 0 ) {
			// Insert Level 1
			$wpdb->insert(
				$table_referrals,
				array(
					'affiliate_id' => $referrer_id,
					'reference_id' => $order_id,
					'type'         => 'purchase',
					'amount'       => $commission_l1,
					'currency'     => $order->get_currency(),
					'status'       => 'verified',
					'description'  => 'Commission for Order #' . $order_id
				),
				array( '%d', '%s', '%s', '%f', '%s', '%s', '%s' )
			);

			$referral_db_id = $wpdb->insert_id;
			
			// Credit Wallet L1
			$wallet = new BQ_Referral_Wallet();
			$wallet->add_transaction( $referrer_id, $commission_l1, 'commission', $referral_db_id, "Level 1 Commission Order #{$order_id}" );

			// Trigger Notification L1
			do_action( 'bqr_referral_verified', $referrer_id, $commission_l1 );

			// Check for Level 2 (Referrer of the Referrer)
			$parent_referrer_id = get_user_meta( $referrer_id, 'bqr_referrer_id', true );
			if ( $parent_referrer_id ) {
				$commission_l2 = $this->calculate_commission( $order_total, $parent_referrer_id, 2 );
				if ( $commission_l2 > 0 ) {
					// Insert Level 2
					$wpdb->insert(
						$table_referrals,
						array(
							'affiliate_id' => $parent_referrer_id,
							'reference_id' => $order_id,
							'type'         => 'purchase_tier_2',
							'amount'       => $commission_l2,
							'currency'     => $order->get_currency(),
							'status'       => 'verified',
							'description'  => 'Level 2 Commission for Order #' . $order_id,
							'parent_referral_id' => $referral_db_id
						),
						array( '%d', '%s', '%s', '%f', '%s', '%s', '%s', '%d' )
					);
					
					// Credit Wallet L2
					$wallet->add_transaction( $parent_referrer_id, $commission_l2, 'commission', $wpdb->insert_id, "Level 2 Commission Order #{$order_id}" );
					
					// Trigger Notification L2
					do_action( 'bqr_referral_verified', $parent_referrer_id, $commission_l2 );
				}
			}

			// Mark order as processed
			update_post_meta( $order_id, '_bqr_commission_processed', 'yes' );
		}
	}


	/**
	 * Commission Calculation Logic
	 * Can be extended for tiered rates, per-product rates, etc.
	 */
	private function calculate_commission( $amount, $affiliate_id, $level = 1 ) {
		// Default Rates from Settings
		$rate_l1 = get_option( 'bqr_commission_rate', 10 );
		$rate_l2 = get_option( 'bqr_commission_rate_l2', 2 );

		// Allow overrides via filter or user meta (Only for Level 1 typically)
		if ( $level === 1 ) {
			$user_rate = get_user_meta( $affiliate_id, 'bqr_commission_rate', true );
			if ( $user_rate !== '' && is_numeric($user_rate) ) {
				$rate_l1 = floatval( $user_rate );
			}
			return ( $amount * $rate_l1 ) / 100;
		} elseif ( $level === 2 ) {
			return ( $amount * $rate_l2 ) / 100;
		}
		
		return 0;
	}

}
new BQ_Referral_WooCommerce();

/**
 * Integrate with My Account
 */
class BQ_Referral_MyAccount {

	public function __construct() {
		add_action( 'init', array( $this, 'add_referral_endpoint' ) );
		add_filter( 'query_vars', array( $this, 'add_query_vars' ), 0 );
		add_filter( 'woocommerce_account_menu_items', array( $this, 'add_link_my_account' ) );
		
		add_action( 'woocommerce_account_referrals_endpoint', array( $this, 'referral_content' ) );
		add_action( 'woocommerce_account_investments_endpoint', array( $this, 'investment_content' ) );
		add_action( 'woocommerce_account_wallet_endpoint', array( $this, 'wallet_content' ) );
		
		add_action( 'woocommerce_account_dashboard', array( $this, 'dashboard_banners' ) );
	}

	public function dashboard_banners() {
		// Ensure styles are enqueued (redundant if shortcodes loaded but ensuring visibility on dashboard home)
		wp_enqueue_style( 'bqr-style', BQR_PLUGIN_URL . 'assets/css/bqr-style.css', array(), BQR_VERSION );
		
		$referral_url = wc_get_account_endpoint_url( 'referrals' );
		$invest_url   = wc_get_account_endpoint_url( 'investments' );
		$wallet_url   = wc_get_account_endpoint_url( 'wallet' );
		
		?>
		<div class="bqr-dashboard-grid">
			<a href="<?php echo esc_url( $referral_url ); ?>" class="bqr-dashboard-banner">
				<span class="bqr-banner-icon">🤝</span>
				<span class="bqr-banner-title">Referral System</span>
				<span class="bqr-banner-desc">Manage links & track commissions</span>
			</a>
			<a href="<?php echo esc_url( $invest_url ); ?>" class="bqr-dashboard-banner">
				<span class="bqr-banner-icon">📈</span>
				<span class="bqr-banner-title">My Investments</span>
				<span class="bqr-banner-desc">View portfolio & daily returns</span>
			</a>
			<a href="<?php echo esc_url( $wallet_url ); ?>" class="bqr-dashboard-banner">
				<span class="bqr-banner-icon">💼</span>
				<span class="bqr-banner-title">My Wallet</span>
				<span class="bqr-banner-desc">Withdraw funds & check balance</span>
			</a>
		</div>
		<?php
	}

	public function add_referral_endpoint() {
		add_rewrite_endpoint( 'referrals', EP_ROOT | EP_PAGES );
		add_rewrite_endpoint( 'investments', EP_ROOT | EP_PAGES );
		add_rewrite_endpoint( 'wallet', EP_ROOT | EP_PAGES );
	}

	public function add_query_vars( $vars ) {
		$vars[] = 'referrals';
		$vars[] = 'investments';
		$vars[] = 'wallet';
		return $vars;
	}

	public function add_link_my_account( $items ) {
		// Insert 'Referrals' and 'Investments' after 'Orders'
		$new_items = array();
		foreach ( $items as $key => $value ) {
			$new_items[ $key ] = $value;
			if ( $key === 'orders' ) {
				$new_items['referrals'] = 'Referrals';
				$new_items['investments'] = 'My Investments';
				$new_items['wallet'] = 'My Wallet';
			}
		}
		return $new_items;
	}

	public function referral_content() {
		echo do_shortcode( '[bytesqube_referral_dashboard]' );
	}
	public function investment_content() {
		echo do_shortcode( '[bytesqube_investment_dashboard]' );
	}
	public function wallet_content() {
		echo do_shortcode( '[bytesqube_wallet_dashboard]' );
	}
}
new BQ_Referral_MyAccount();
