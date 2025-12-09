<?php

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

class BQ_Referral_Admin {

	public function __construct() {
		add_action( 'admin_menu', array( $this, 'add_admin_menu' ) );
		add_action( 'admin_init', array( $this, 'register_settings' ) );
		add_action( 'admin_post_bqr_approve_payout', array( $this, 'handle_payout_approval' ) );
	}

	public function add_admin_menu() {
		add_menu_page(
			'Referral System',
			'Referrals',
			'manage_options',
			'bytesqube-referral',
			array( $this, 'render_dashboard_page' ),
			'dashicons-share-alt',
			56
		);

		add_submenu_page(
			'bytesqube-referral',
			'Payouts',
			'Payouts',
			'manage_options',
			'bytesqube-referral-payouts',
			array( $this, 'render_payouts_page' )
		);
		
		add_submenu_page(
			'bytesqube-referral',
			'Settings',
			'Settings',
			'manage_options',
			'bytesqube-referral-settings',
			array( $this, 'render_settings_page' )
		);
	}

	public function register_settings() {
		register_setting( 'bqr_settings_group', 'bqr_commission_rate' );
		register_setting( 'bqr_settings_group', 'bqr_cookie_expiry' );
	}

	public function render_dashboard_page() {
		global $wpdb;
		$total_clicks = $wpdb->get_var( "SELECT COUNT(*) FROM {$wpdb->prefix}bqr_clicks" );
		$total_referrals = $wpdb->get_var( "SELECT COUNT(*) FROM {$wpdb->prefix}bqr_referrals WHERE status='verified'" );
		$total_payouts_pending = $wpdb->get_var( "SELECT COUNT(*) FROM {$wpdb->prefix}bqr_payouts WHERE status='pending'" );
		
		?>
		<div class="wrap">
			<h1>Referral System Overview</h1>
			
			<div style="display: flex; gap: 20px; margin-top: 20px;">
				<div class="card" style="padding: 20px; text-align: center; min-width: 200px;">
					<h2 style="margin:0; font-size: 3em;"><?php echo $total_clicks; ?></h2>
					<p>Total Clicks</p>
				</div>
				<div class="card" style="padding: 20px; text-align: center; min-width: 200px;">
					<h2 style="margin:0; font-size: 3em; color: #46b450;"><?php echo $total_referrals; ?></h2>
					<p>Verified Referrals</p>
				</div>
				<div class="card" style="padding: 20px; text-align: center; min-width: 200px;">
					<h2 style="margin:0; font-size: 3em; color: #ffb900;"><?php echo $total_payouts_pending; ?></h2>
					<p>Pending Payouts</p>
				</div>
			</div>

			<h2 style="margin-top: 40px;">Recent Referrals</h2>
			<table class="wp-list-table widefat fixed striped">
				<thead>
					<tr>
						<th>Date</th>
						<th>Affiliate</th>
						<th>Order ID</th>
						<th>Commission</th>
						<th>Status</th>
					</tr>
				</thead>
				<tbody>
					<?php
					$referrals = $wpdb->get_results( "SELECT * FROM {$wpdb->prefix}bqr_referrals ORDER BY created_at DESC LIMIT 10" );
					if ( $referrals ) :
						foreach ( $referrals as $r ) :
							$user = get_userdata( $r->affiliate_id );
							?>
							<tr>
								<td><?php echo $r->created_at; ?></td>
								<td><?php echo $user ? $user->display_name : 'Unknown'; ?></td>
								<td>#<?php echo $r->reference_id; ?></td>
								<td><?php echo wc_price( $r->amount ); ?></td>
								<td><?php echo ucfirst( $r->status ); ?></td>
							</tr>
						<?php endforeach;
					else: ?>
						<tr><td colspan="5">No referrals yet.</td></tr>
					<?php endif; ?>
				</tbody>
			</table>
		</div>
		<?php
	}

	public function render_payouts_page() {
		global $wpdb;
		$payouts = $wpdb->get_results( "SELECT * FROM {$wpdb->prefix}bqr_payouts WHERE status='pending' ORDER BY created_at ASC" );
		?>
		<div class="wrap">
			<h1>Payout Requests</h1>
			<table class="wp-list-table widefat fixed striped">
				<thead>
					<tr>
						<th>Date</th>
						<th>Affiliate</th>
						<th>Amount</th>
						<th>Method</th>
						<th>Status</th>
						<th>Actions</th>
					</tr>
				</thead>
				<tbody>
					<?php if ( $payouts ) : foreach ( $payouts as $p ) : 
						$user = get_userdata( $p->affiliate_id );
						?>
						<tr>
							<td><?php echo $p->created_at; ?></td>
							<td><?php echo $user ? $user->display_name : 'Unknown'; ?></td>
							<td><?php echo wc_price( $p->amount ); ?></td>
							<td><?php echo ucfirst( $p->method ); ?> <br><small><i><?php echo esc_html( $p->details ); ?></i></small></td>
							<td><?php echo ucfirst( $p->status ); ?></td>
							<td>
								<form method="post" action="<?php echo admin_url('admin-post.php'); ?>">
									<input type="hidden" name="action" value="bqr_approve_payout">
									<input type="hidden" name="payout_id" value="<?php echo $p->id; ?>">
									<?php wp_nonce_field( 'bqr_approve_payout_' . $p->id ); ?>
									<button type="submit" class="button button-primary">Mark Paid</button>
								</form>
							</td>
						</tr>
					<?php endforeach; else: ?>
						<tr><td colspan="5">No pending payouts.</td></tr>
					<?php endif; ?>
				</tbody>
			</table>
		</div>
		<?php
	}

	public function handle_payout_approval() {
		if ( ! current_user_can( 'manage_options' ) ) return;
		
		$payout_id = intval( $_POST['payout_id'] );
		check_admin_referer( 'bqr_approve_payout_' . $payout_id );

		global $wpdb;
		$wpdb->update( 
			$wpdb->prefix . 'bqr_payouts', 
			array( 'status' => 'paid', 'processed_at' => current_time( 'mysql' ) ), 
			array( 'id' => $payout_id ) 
		);

		// Get affiliate ID for notification
		$payout = $wpdb->get_row( $wpdb->prepare( "SELECT affiliate_id FROM {$wpdb->prefix}bqr_payouts WHERE id = %d", $payout_id ) );
		if ( $payout ) {
			do_action( 'bqr_payout_paid', $payout_id, $payout->affiliate_id );
		}

		wp_redirect( admin_url( 'admin.php?page=bytesqube-referral-payouts&msg=approved' ) );
		exit;
	}

	public function render_settings_page() {
		?>
		<div class="wrap">
			<h1>Referral Settings</h1>
			<form method="post" action="options.php">
				<?php settings_fields( 'bqr_settings_group' ); ?>
				<?php do_settings_sections( 'bqr_settings_group' ); ?>
				<table class="form-table">
					<tr valign="top">
						<th scope="row">Default Commission Rate (%)</th>
						<td><input type="number" name="bqr_commission_rate" value="<?php echo esc_attr( get_option('bqr_commission_rate', 10) ); ?>" /></td>
					</tr>
					<tr valign="top">
						<th scope="row">Cookie Expiry (Days)</th>
						<td><input type="number" name="bqr_cookie_expiry" value="<?php echo esc_attr( get_option('bqr_cookie_expiry', 30) ); ?>" /></td>
					</tr>
				</table>
				<?php submit_button(); ?>
			</form>
		</div>
		<?php
	}
}
new BQ_Referral_Admin();
