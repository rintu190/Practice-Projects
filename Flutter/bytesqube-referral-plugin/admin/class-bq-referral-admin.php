<?php

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

class BQ_Referral_Admin {

	public function __construct() {
		add_action( 'admin_menu', array( $this, 'add_admin_menu' ) );
		add_action( 'admin_init', array( $this, 'register_settings' ) );
		add_action( 'admin_post_bqr_approve_payout', array( $this, 'handle_payout_approval' ) );
		add_action( 'admin_post_bqr_handle_blog', array( $this, 'handle_blog_approval' ) );
		
		// User Profile Fields
		add_action( 'show_user_profile', array( $this, 'add_user_fields' ) );
		add_action( 'edit_user_profile', array( $this, 'add_user_fields' ) );
		add_action( 'personal_options_update', array( $this, 'save_user_fields' ) );
		add_action( 'edit_user_profile_update', array( $this, 'save_user_fields' ) );
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

		add_submenu_page(
			'bytesqube-referral',
			'Blog Submissions',
			'Blog Submissions',
			'manage_options',
			'bytesqube-referral-blog',
			array( $this, 'render_blog_submissions_page' )
		);
	}

	public function register_settings() {
		register_setting( 'bqr_settings_group', 'bqr_commission_rate' );
		register_setting( 'bqr_settings_group', 'bqr_commission_rate_l2' );
		register_setting( 'bqr_settings_group', 'bqr_cookie_expiry' );
		register_setting( 'bqr_settings_group', 'bqr_blog_bounty' );
		
		// Category ROIs
		register_setting( 'bqr_settings_group', 'bqr_roi_securities' );
		register_setting( 'bqr_settings_group', 'bqr_roi_currencies' );
		register_setting( 'bqr_settings_group', 'bqr_roi_realestate' );
	}

	public function render_dashboard_page() {
		global $wpdb;
		$total_clicks = $wpdb->get_var( "SELECT COUNT(*) FROM {$wpdb->prefix}bqr_clicks" );
		$total_referrals = $wpdb->get_var( "SELECT COUNT(*) FROM {$wpdb->prefix}bqr_referrals WHERE status='verified'" );
		$total_payouts_pending = $wpdb->get_var( "SELECT COUNT(*) FROM {$wpdb->prefix}bqr_payouts WHERE status='pending'" );
		
		// Investment Stats
		$total_invested = $wpdb->get_var( "SELECT SUM(amount) FROM {$wpdb->prefix}bqr_investments WHERE status='active'" );
		$total_profit_paid = $wpdb->get_var( "SELECT SUM(total_earned) FROM {$wpdb->prefix}bqr_investments" );

		?>
		<div class="wrap">
			<h1>Referral & Investment Overview</h1>
			
			<div style="display: flex; gap: 20px; margin-top: 20px; flex-wrap:wrap;">
				<div class="card" style="padding: 20px; text-align: center; min-width: 150px;">
					<h2 style="margin:0; font-size: 2em;"><?php echo $total_clicks; ?></h2>
					<p>Total Clicks</p>
				</div>
				<div class="card" style="padding: 20px; text-align: center; min-width: 150px;">
					<h2 style="margin:0; font-size: 2em; color: #46b450;"><?php echo $total_referrals; ?></h2>
					<p>Verified Referrals</p>
				</div>
				<div class="card" style="padding: 20px; text-align: center; min-width: 150px;">
					<h2 style="margin:0; font-size: 2em; color: #ffb900;"><?php echo $total_payouts_pending; ?></h2>
					<p>Pending Payouts</p>
				</div>
				<div class="card" style="padding: 20px; text-align: center; min-width: 150px; border-left: 4px solid #6366f1;">
					<h2 style="margin:0; font-size: 2em; color: #6366f1;"><?php echo wc_price($total_invested ?: 0); ?></h2>
					<p>Total Active Invested</p>
				</div>
				<div class="card" style="padding: 20px; text-align: center; min-width: 150px; border-left: 4px solid #10b981;">
					<h2 style="margin:0; font-size: 2em; color: #10b981;"><?php echo wc_price($total_profit_paid ?: 0); ?></h2>
					<p>Total Profit Paid</p>
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

	public function render_blog_submissions_page() {
		global $wpdb;
		$submissions = $wpdb->get_results( "SELECT * FROM {$wpdb->prefix}bqr_referrals WHERE type='blog_post' AND status='pending' ORDER BY created_at ASC" );
		?>
		<div class="wrap">
			<h1>Pending Blog Submissions</h1>
			<table class="wp-list-table widefat fixed striped">
				<thead>
					<tr>
						<th>Date</th>
						<th>Affiliate</th>
						<th>Blog Post URL</th>
						<th>Bounty Amount</th>
						<th>Actions</th>
					</tr>
				</thead>
				<tbody>
					<?php if ( $submissions ) : foreach ( $submissions as $s ) : 
						$user = get_userdata( $s->affiliate_id );
						?>
						<tr>
							<td><?php echo $s->created_at; ?></td>
							<td><?php echo $user ? $user->display_name : 'Unknown'; ?></td>
							<td><a href="<?php echo esc_url( $s->description ); ?>" target="_blank"><?php echo esc_html( $s->description ); ?></a></td>
							<td><?php echo wc_price( $s->amount ); ?></td>
							<td>
								<div style="display:flex; gap: 10px;">
									<form method="post" action="<?php echo admin_url('admin-post.php'); ?>">
										<input type="hidden" name="action" value="bqr_handle_blog">
										<input type="hidden" name="ref_id" value="<?php echo $s->id; ?>">
										<input type="hidden" name="decision" value="approve">
										<?php wp_nonce_field( 'bqr_handle_blog_' . $s->id ); ?>
										<button type="submit" class="button button-primary">Approve</button>
									</form>
									<form method="post" action="<?php echo admin_url('admin-post.php'); ?>">
										<input type="hidden" name="action" value="bqr_handle_blog">
										<input type="hidden" name="ref_id" value="<?php echo $s->id; ?>">
										<input type="hidden" name="decision" value="reject">
										<?php wp_nonce_field( 'bqr_handle_blog_' . $s->id ); ?>
										<button type="submit" class="button button-secondary">Reject</button>
									</form>
								</div>
							</td>
						</tr>
					<?php endforeach; else: ?>
						<tr><td colspan="5">No pending blog submissions.</td></tr>
					<?php endif; ?>
				</tbody>
			</table>

			<h2 style="margin-top: 50px;">History</h2>
			<table class="wp-list-table widefat fixed striped">
				<thead>
					<tr>
						<th>Date</th>
						<th>Affiliate</th>
						<th>Status</th>
						<th>URL</th>
					</tr>
				</thead>
				<tbody>
					<?php
					$history = $wpdb->get_results( "SELECT * FROM {$wpdb->prefix}bqr_referrals WHERE type='blog_post' AND status!='pending' ORDER BY created_at DESC LIMIT 10" );
					if ( $history ) : foreach ( $history as $h ) : 
						$user = get_userdata( $h->affiliate_id );
					?>
						<tr>
							<td><?php echo $h->created_at; ?></td>
							<td><?php echo $user ? $user->display_name : 'Unknown'; ?></td>
							<td><?php echo ucfirst($h->status); ?></td>
							<td><a href="<?php echo esc_url( $h->description ); ?>" target="_blank">View Post</a></td>
						</tr>
					<?php endforeach; endif; ?>
				</tbody>
			</table>
		</div>
		<?php
	}

	public function handle_blog_approval() {
		if ( ! current_user_can( 'manage_options' ) ) return;
		
		$ref_id = intval( $_POST['ref_id'] );
		$decision = sanitize_text_field( $_POST['decision'] );
		check_admin_referer( 'bqr_handle_blog_' . $ref_id );

		global $wpdb;

		if ( $decision === 'approve' ) {
			// 1. Update Status
			$wpdb->update( 
				$wpdb->prefix . 'bqr_referrals', 
				array( 'status' => 'verified' ), 
				array( 'id' => $ref_id ) 
			);

			// 2. Credit Wallet
			$referral = $wpdb->get_row( $wpdb->prepare( "SELECT * FROM {$wpdb->prefix}bqr_referrals WHERE id = %d", $ref_id ) );
			if ( $referral ) {
				$wallet = new BQ_Referral_Wallet();
				$wallet->add_transaction( $referral->affiliate_id, $referral->amount, 'commission', $ref_id, "Blog Post Bounty - Approved" );
			}
		} else {
			// Reject
			$wpdb->update( 
				$wpdb->prefix . 'bqr_referrals', 
				array( 'status' => 'rejected' ), 
				array( 'id' => $ref_id ) 
			);
		}

		wp_redirect( admin_url( 'admin.php?page=bytesqube-referral-blog&msg=' . $decision ) );
		exit;
	}

	public function add_user_fields( $user ) {
		$rate = get_user_meta( $user->ID, 'bqr_commission_rate', true );
		$coupon = get_user_meta( $user->ID, 'bqr_referral_coupon', true );
		?>
		<h3>Referral Program Settings</h3>
		<table class="form-table">
			<tr>
				<th><label for="bqr_commission_rate">Custom Commission Rate (%)</label></th>
				<td>
					<input type="number" name="bqr_commission_rate" id="bqr_commission_rate" value="<?php echo esc_attr( $rate ); ?>" class="regular-text" step="0.1" />
					<p class="description">Leave empty to use global default.</p>
				</td>
			</tr>
			<tr>
				<th><label for="bqr_referral_coupon">Linked Coupon Code</label></th>
				<td>
					<input type="text" name="bqr_referral_coupon" id="bqr_referral_coupon" value="<?php echo esc_attr( $coupon ); ?>" class="regular-text" />
					<p class="description">Enter a WooCommerce Coupon Code. When this coupon is used, this user will get commission.</p>
				</td>
			</tr>
		</table>
		<?php
	}

	public function save_user_fields( $user_id ) {
		if ( ! current_user_can( 'edit_user', $user_id ) ) {
			return false;
		}

		if ( isset( $_POST['bqr_commission_rate'] ) ) {
			update_user_meta( $user_id, 'bqr_commission_rate', sanitize_text_field( $_POST['bqr_commission_rate'] ) );
		}
		if ( isset( $_POST['bqr_referral_coupon'] ) ) {
			update_user_meta( $user_id, 'bqr_referral_coupon', sanitize_text_field( $_POST['bqr_referral_coupon'] ) );
		}
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
						<th scope="row">Tier 2 Commission Rate (%)</th>
						<td><input type="number" name="bqr_commission_rate_l2" value="<?php echo esc_attr( get_option('bqr_commission_rate_l2', 2) ); ?>" /></td>
					</tr>
					<tr valign="top">
						<th scope="row">Cookie Expiry (Days)</th>
						<td><input type="number" name="bqr_cookie_expiry" value="<?php echo esc_attr( get_option('bqr_cookie_expiry', 30) ); ?>" /></td>
					</tr>
					<tr valign="top">
						<th scope="row">Blog Posting Bounty (<?php echo get_woocommerce_currency_symbol(); ?>)</th>
						<td><input type="number" name="bqr_blog_bounty" value="<?php echo esc_attr( get_option('bqr_blog_bounty', 100) ); ?>" step="0.01" /></td>
					</tr>
					
					<tr><th colspan="2"><h3>Investment ROI Rates (Daily %)</h3></th></tr>
					
					<tr valign="top">
						<th scope="row">Securities & Derivatives ROI</th>
						<td><input type="number" name="bqr_roi_securities" value="<?php echo esc_attr( get_option('bqr_roi_securities', 1.00) ); ?>" step="0.01" /></td>
					</tr>
					<tr valign="top">
						<th scope="row">Currencies & Commodities ROI</th>
						<td><input type="number" name="bqr_roi_currencies" value="<?php echo esc_attr( get_option('bqr_roi_currencies', 1.25) ); ?>" step="0.01" /></td>
					</tr>
					<tr valign="top">
						<th scope="row">Real Estate ROI</th>
						<td><input type="number" name="bqr_roi_realestate" value="<?php echo esc_attr( get_option('bqr_roi_realestate', 0.80) ); ?>" step="0.01" /></td>
					</tr>
				</table>
				<?php submit_button(); ?>
			</form>
		</div>
		<?php
	}
}
new BQ_Referral_Admin();
