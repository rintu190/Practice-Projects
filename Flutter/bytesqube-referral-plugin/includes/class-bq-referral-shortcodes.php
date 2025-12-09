<?php

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

class BQ_Referral_Shortcodes {

	public function __construct() {
		add_shortcode( 'bytesqube_referral_dashboard', array( $this, 'render_dashboard' ) );
		add_action( 'init', array( $this, 'handle_payout_request' ) );
	}

	public function render_dashboard( $atts ) {
		if ( ! is_user_logged_in() ) {
			return '<p class="bqr-alert">Please <a href="' . wp_login_url( get_permalink() ) . '">login</a> to view your Affiliate Dashboard.</p>';
		}

		$user_id = get_current_user_id();
		$tracker = new BQ_Referral_Tracker();
		$wallet = new BQ_Referral_Wallet();

		// Data
		$referral_link = $tracker::get_referral_link( $user_id );
		$balance = $wallet->get_balance( $user_id );
		
		global $wpdb;
		$clicks = $wpdb->get_var( $wpdb->prepare( "SELECT COUNT(*) FROM {$wpdb->prefix}bqr_clicks WHERE affiliate_id = %d", $user_id ) );
		$referrals = $wpdb->get_var( $wpdb->prepare( "SELECT COUNT(*) FROM {$wpdb->prefix}bqr_referrals WHERE affiliate_id = %d AND status = 'verified'", $user_id ) );
		$earnings = $wpdb->get_var( $wpdb->prepare( "SELECT SUM(amount) FROM {$wpdb->prefix}bqr_referrals WHERE affiliate_id = %d AND status = 'verified'", $user_id ) );
		
		ob_start();
		?>
		<div class="bqr-dashboard">
			<style>
				.bqr-dashboard { font-family: 'Segoe UI', system-ui, sans-serif; max-width: 1000px; margin: 0 auto; color: #333; }
				.bqr-stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin-bottom: 30px; }
				.bqr-card { background: #fff; padding: 25px; border-radius: 12px; box-shadow: 0 4px 12px rgba(0,0,0,0.05); text-align: center; border: 1px solid #eee; }
				.bqr-card h3 { font-size: 0.9rem; text-transform: uppercase; color: #888; margin: 0 0 10px 0; letter-spacing: 1px; }
				.bqr-card .value { font-size: 2rem; font-weight: 700; color: #111; }
				.bqr-section { background: #fff; padding: 30px; border-radius: 12px; box-shadow: 0 4px 12px rgba(0,0,0,0.05); margin-bottom: 30px; border: 1px solid #eee; }
				.bqr-section h2 { margin-top: 0; font-size: 1.5rem; border-bottom: 2px solid #f0f0f0; padding-bottom: 15px; margin-bottom: 20px; }
				.bqr-input-group { display: flex; gap: 10px; margin-top: 10px; }
				.bqr-input-group input { flex: 1; padding: 12px; border: 1px solid #ddd; border-radius: 6px; font-size: 1rem; color: #555; background: #f9f9f9; }
				.bqr-btn { padding: 12px 25px; background: #0073aa; color: white; border: none; border-radius: 6px; cursor: pointer; font-weight: 600; transition: 0.2s; text-decoration: none; }
				.bqr-btn:hover { background: #005177; }
				.table-responsive { overflow-x: auto; }
				.bqr-table { width: 100%; border-collapse: collapse; margin-top: 15px; }
				.bqr-table th, .bqr-table td { text-align: left; padding: 15px; border-bottom: 1px solid #eee; }
				.bqr-table th { background: #f8f8f8; color: #666; font-weight: 600; }
				.status-badge { display: inline-block; padding: 4px 10px; border-radius: 20px; font-size: 0.8rem; font-weight: 600; }
				.status-completed { background: #e6fffa; color: #047481; }
				.status-pending { background: #fffbea; color: #944c0c; }
				.bqr-alert { padding: 15px; background: #fee2e2; color: #991b1b; border-radius: 6px; margin-bottom: 20px; }
				.bqr-success { padding: 15px; background: #dcfce7; color: #166534; border-radius: 6px; margin-bottom: 20px; }
			</style>

			<?php if ( isset( $_GET['bqr_msg'] ) ) : ?>
				<div class="bqr-success"><?php echo esc_html( $_GET['bqr_msg'] ); ?></div>
			<?php endif; ?>

			<div class="bqr-stats-grid">
				<div class="bqr-card">
					<h3>Total Clicks</h3>
					<div class="value"><?php echo number_format( $clicks ); ?></div>
				</div>
				<div class="bqr-card">
					<h3>Referrals</h3>
					<div class="value"><?php echo number_format( $referrals ); ?></div>
				</div>
				<div class="bqr-card">
					<h3>Earnings</h3>
					<div class="value"><?php echo wc_price( $earnings ? $earnings : 0 ); ?></div>
				</div>
				<div class="bqr-card" style="background: #f0f7ff; border-color: #cce5ff;">
					<h3>Wallet Balance</h3>
					<div class="value" style="color: #0073aa;"><?php echo wc_price( $balance ); ?></div>
				</div>
			</div>

			<div class="bqr-section">
				<h2>Your Referral Link</h2>
				<p>Share this link to earn commissions on every successful sale.</p>
				<div class="bqr-input-group">
					<input type="text" value="<?php echo esc_url( $referral_link ); ?>" readonly onclick="this.select();">
					<button class="bqr-btn" onclick="navigator.clipboard.writeText('<?php echo esc_js( $referral_link ); ?>'); alert('Copied!');">Copy</button>
				</div>
				
				<div style="margin-top: 20px; display: flex; gap: 10px;">
					<a href="#" class="bqr-btn" style="background: #25D366;">WhatsApp</a>
					<a href="#" class="bqr-btn" style="background: #1877F2;">Facebook</a>
					<a href="#" class="bqr-btn" style="background: #1DA1F2;">Twitter</a>
				</div>
			</div>

			<div class="bqr-section">
				<div style="display: flex; justify-content: space-between; align-items: center;">
					<h2 style="border:none; margin:0;">Payout Requests</h2>
						<form method="post" style="display: inline-flex; gap: 10px; align-items: center;">
							<?php wp_nonce_field( 'bqr_request_payout', 'bqr_nonce' ); ?>
							<select name="bqr_payout_method" style="padding: 10px; border: 1px solid #ddd; border-radius: 6px;" <?php disabled( $balance < 50 ); ?>>
								<option value="bank">Bank Transfer</option>
								<option value="paypal">PayPal</option>
								<option value="upi">UPI</option>
							</select>
							<?php if ( $balance >= 50 ) : ?>
								<button type="submit" name="bqr_action" value="request_payout" class="bqr-btn">Request Payout</button>
							<?php else: ?>
								<button type="button" class="bqr-btn" style="background: #ccc; cursor: not-allowed;" title="Minimum balance of 50 required">Min Balance 50</button>
							<?php endif; ?>
						</form>
				</div>
				<div style="margin-top: 20px;" class="table-responsive">
					<table class="bqr-table">
						<thead>
							<tr>
								<th>Date</th>
								<th>Amount</th>
								<th>Method</th>
								<th>Status</th>
							</tr>
						</thead>
						<tbody>
							<?php
							$payouts = $wpdb->get_results( $wpdb->prepare( "SELECT * FROM {$wpdb->prefix}bqr_payouts WHERE affiliate_id = %d ORDER BY created_at DESC LIMIT 5", $user_id ) );
							if ( $payouts ) :
								foreach ( $payouts as $payout ) : ?>
								<tr>
									<td><?php echo date_i18n( get_option( 'date_format' ), strtotime( $payout->created_at ) ); ?></td>
									<td><?php echo wc_price( $payout->amount ); ?></td>
									<td><?php echo ucfirst( $payout->method ); ?></td>
									<td><span class="status-badge status-<?php echo esc_attr( $payout->status ); ?>"><?php echo ucfirst( $payout->status ); ?></span></td>
								</tr>
							<?php endforeach; else: ?>
								<tr><td colspan="4">No payout history yet.</td></tr>
							<?php endif; ?>
						</tbody>
					</table>
				</div>
			</div>
		</div>
		<?php
		return ob_get_clean();
	}

	public function handle_payout_request() {
		if ( isset( $_POST['bqr_action'] ) && $_POST['bqr_action'] == 'request_payout' ) {
			if ( ! is_user_logged_in() ) return;
			if ( ! wp_verify_nonce( $_POST['bqr_nonce'], 'bqr_request_payout' ) ) return;

			$user_id = get_current_user_id();
			$wallet = new BQ_Referral_Wallet();
			$balance = $wallet->get_balance( $user_id );

			if ( $balance >= 50 ) {
				global $wpdb;
				$method = isset($_POST['bqr_payout_method']) ? sanitize_text_field($_POST['bqr_payout_method']) : 'manual';
				
				// 1. Create Payout Request
				$wpdb->insert(
					$wpdb->prefix . 'bqr_payouts',
					array(
						'affiliate_id' => $user_id,
						'amount'       => $balance, 
						'method'       => $method,
						'details'      => 'User requested payout via ' . ucfirst($method),
						'status'       => 'pending'
					),
					array( '%d', '%f', '%s', '%s', '%s' )
				);
				
				$payout_id = $wpdb->insert_id;
				
				// Notify Admin
				do_action( 'bqr_payout_requested', $payout_id, $user_id );

				// 2. Debit Wallet immediately (move to 'held' essentially, though we rely on transaction logs)
				// We create a transaction to 0 out the balance
				$wallet->add_transaction( $user_id, -$balance, 'payout', $payout_id, 'Payout Request #' . $payout_id );

				wp_redirect( add_query_arg( 'bqr_msg', 'Payout requested successfully!', remove_query_arg( 'bqr_action' ) ) );
				exit;
			}
		}
	}
}
new BQ_Referral_Shortcodes();
