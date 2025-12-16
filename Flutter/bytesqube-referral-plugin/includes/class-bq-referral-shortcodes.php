<?php

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

class BQ_Referral_Shortcodes {

	public function __construct() {
		add_shortcode( 'bytesqube_referral_dashboard', array( $this, 'render_dashboard' ) );
		add_shortcode( 'bytesqube_investment_dashboard', array( $this, 'render_investment_dashboard' ) );
		add_shortcode( 'bytesqube_wallet_dashboard', array( $this, 'render_wallet_dashboard' ) );
		add_action( 'init', array( $this, 'handle_wallet_action' ) );
		add_action( 'init', array( $this, 'handle_blog_submission' ) );
		add_action( 'init', array( $this, 'handle_investment_action' ) );
		add_action( 'wp_enqueue_scripts', array( $this, 'enqueue_assets' ) );
	}

	public function enqueue_assets() {
		// Only enqueue on pages with the shortcode generally, but for simplicity here we register and let WP handle dependencies if needed.
		// Optimized: Check for shortcode presence could be done, but we'll queue it.
		// using time() to bust cache
		wp_enqueue_style( 'bqr-style', BQR_PLUGIN_URL . 'assets/css/bqr-style.css', array(), time() );
		wp_enqueue_script( 'bqr-script', BQR_PLUGIN_URL . 'assets/js/bqr-script.js', array(), BQR_VERSION, true );
	}

	public function render_dashboard( $atts ) {
		if ( ! is_user_logged_in() ) {
			return '<div class="bqr-alert">Please <a href="' . wp_login_url( get_permalink() ) . '" style="margin-left:5px; font-weight:700;">login</a> to view your Affiliate Dashboard.</div>';
		}

		$user_id = get_current_user_id();
		$tracker = new BQ_Referral_Tracker();
		$wallet = new BQ_Referral_Wallet();

		// Data
		$referral_link = $tracker::get_referral_link( $user_id );
		$balance = $wallet->get_balance( $user_id );
		
		global $wpdb;
		// 1. Clicks (Unchanged)
		$clicks = $wpdb->get_var( $wpdb->prepare( "SELECT COUNT(*) FROM {$wpdb->prefix}bqr_clicks WHERE affiliate_id = %d", $user_id ) );
		
		// 2. Referrals (Exclude blog posts)
		$referrals = $wpdb->get_var( $wpdb->prepare( "SELECT COUNT(*) FROM {$wpdb->prefix}bqr_referrals WHERE affiliate_id = %d AND status = 'verified' AND type != 'blog_post'", $user_id ) );
		
		// 3. Earnings (Sales Commissions only)
		$earnings = $wpdb->get_var( $wpdb->prepare( "SELECT SUM(amount) FROM {$wpdb->prefix}bqr_referrals WHERE affiliate_id = %d AND status = 'verified' AND type != 'blog_post'", $user_id ) );
		
		// 4. Blog Earnings
		$blog_earnings = $wpdb->get_var( $wpdb->prepare( "SELECT SUM(amount) FROM {$wpdb->prefix}bqr_referrals WHERE affiliate_id = %d AND status = 'verified' AND type = 'blog_post'", $user_id ) );
		
		// Social Share Links
		$share_text = urlencode( "Check out this amazing site! " );
		$share_url = urlencode( $referral_link );
		
		$wa_link = "https://wa.me/?text={$share_text}{$share_url}";
		$fb_link = "https://www.facebook.com/sharer/sharer.php?u={$share_url}";
		$tw_link = "https://twitter.com/intent/tweet?text={$share_text}&url={$share_url}";
		$li_link = "https://www.linkedin.com/sharing/share-offsite/?url={$share_url}";
		
		// QR Code
		$qr_api = "https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=" . $share_url;

		ob_start();
		?>
		<div class="bqr-dashboard">
			
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
					<h3>Referral Earnings</h3>
					<div class="value"><?php echo wc_price( $earnings ? $earnings : 0 ); ?></div>
				</div>
				<div class="bqr-card" style="background: #f0fdf4; border-color: #bbf7d0;">
					<h3>Blog Earnings</h3>
					<div class="value" style="color: #15803d;"><?php echo wc_price( $blog_earnings ? $blog_earnings : 0 ); ?></div>
				</div>
				<?php
				// 5. Investment Earnings
				$inv_earnings = $wpdb->get_var( $wpdb->prepare( "SELECT SUM(total_earned) FROM {$wpdb->prefix}bqr_investments WHERE user_id = %d", $user_id ) );
				?>
				<div class="bqr-card" style="background: #ecfeff; border-color: #a5f3fc;">
					<h3>Investment Profit</h3>
					<div class="value" style="color: #0891b2;"><?php echo wc_price( $inv_earnings ? $inv_earnings : 0 ); ?></div>
				</div>
				<div class="bqr-card highlight">
					<h3>Wallet Balance</h3>
					<div class="value"><?php echo wc_price( $balance ); ?></div>
				</div>
			</div>

			<div class="bqr-section">
				<h2>
					Your Referral Link
					<span style="font-size:0.8rem; font-weight:400; color:#6b7280;">Share & Earn</span>
				</h2>
				
				<div class="bqr-share-cointainer">
					<div class="bqr-share-actions">
						<p style="margin-top:0; color:#4b5563;">Share your unique link with friends or on social media.</p>
						
						<div class="bqr-input-group">
							<input type="text" id="bqr-ref-link" value="<?php echo esc_url( $referral_link ); ?>" readonly>
							<button class="bqr-btn bqr-btn-primary" id="bqr-copy-btn">
								Copy Link
							</button>
						</div>
						
						<div style="margin-top: 24px;">
							<p style="font-size:0.875rem; font-weight:500; margin-bottom:12px;">Share directly:</p>
							<div style="display: flex; gap: 10px; flex-wrap:wrap;">
								<a href="<?php echo $wa_link; ?>" target="_blank" class="bqr-btn bqr-btn-social btn-whatsapp bqr-share-btn">WhatsApp</a>
								<a href="<?php echo $fb_link; ?>" target="_blank" class="bqr-btn bqr-btn-social btn-facebook bqr-share-btn">Facebook</a>
								<a href="<?php echo $tw_link; ?>" target="_blank" class="bqr-btn bqr-btn-social btn-twitter bqr-share-btn">Twitter</a>
								<a href="<?php echo $li_link; ?>" target="_blank" class="bqr-btn bqr-btn-social btn-linkedin bqr-share-btn">LinkedIn</a>
							</div>
						</div>
					</div>

					<div class="bqr-qr-code">
						<img src="<?php echo esc_url( $qr_api ); ?>" alt="QR Code" width="150" height="150">
						<span>Scan to visit</span>
					</div>
				</div>
			<div class="bqr-section">
				<h2 style="border-bottom: 2px solid #f0f0f0;">Performance Analytics</h2>
				
				<div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 30px; margin-top: 24px;">
					<!-- Top Pages -->
					<div>
						<h3 style="margin-bottom: 16px; font-size: 1.1rem; color: #111;">Top Visited Pages</h3>
						<div class="table-responsive">
							<table class="bqr-table">
								<thead>
									<tr>
										<th>Page URL</th>
										<th>Visits</th>
									</tr>
								</thead>
								<tbody>
									<?php
									$top_pages = $wpdb->get_results( $wpdb->prepare( 
										"SELECT page_visited, COUNT(*) as visits FROM {$wpdb->prefix}bqr_clicks WHERE affiliate_id = %d GROUP BY page_visited ORDER BY visits DESC LIMIT 5", 
										$user_id 
									) );
									
									if ( $top_pages ) : foreach ( $top_pages as $page ) : ?>
										<tr>
											<td style="word-break: break-all;"><a href="<?php echo esc_url( home_url( $page->page_visited ) ); ?>" target="_blank"><?php echo esc_html( $page->page_visited ); ?></a></td>
											<td style="font-weight:700;"><?php echo number_format( $page->visits ); ?></td>
										</tr>
									<?php endforeach; else: ?>
										<tr><td colspan="2" style="color:#999;">No visits recorded yet.</td></tr>
									<?php endif; ?>
								</tbody>
							</table>
						</div>
					</div>

					<!-- Commission Status Breakdown -->
					<div>
						<h3 style="margin-bottom: 16px; font-size: 1.1rem; color: #111;">Commission Status</h3>
						<?php
						$stats = $wpdb->get_results( $wpdb->prepare( 
							"SELECT status, COUNT(*) as count, SUM(amount) as total FROM {$wpdb->prefix}bqr_referrals WHERE affiliate_id = %d AND type != 'blog_post' GROUP BY status", 
							$user_id 
						) );
						
						$stats_map = array();
						if($stats) {
							foreach($stats as $s) $stats_map[$s->status] = $s;
						}
						
						$statuses = ['verified', 'pending', 'rejected'];
						?>
						<div style="display:flex; flex-direction:column; gap:12px;">
							<?php foreach($statuses as $st): 
								$data = isset($stats_map[$st]) ? $stats_map[$st] : (object)['count'=>0, 'total'=>0];
								$label = ucfirst($st);
								$color = ($st == 'verified') ? '#10B981' : (($st == 'pending') ? '#F59E0B' : '#EF4444');
								$bg = ($st == 'verified') ? '#ECFDF5' : (($st == 'pending') ? '#FFFBEB' : '#FEF2F2');
							?>
							<div style="background: <?php echo $bg; ?>; padding: 15px; border-radius: 8px; border: 1px solid <?php echo $color; ?>30; display:flex; justify-content:space-between; align-items:center;">
								<div>
									<span style="display:block; font-size:0.8rem; font-weight:600; color:<?php echo $color; ?>; text-transform:uppercase;"><?php echo $label; ?> Sales</span>
									<span style="font-size:1.2rem; font-weight:700; color:#333;"><?php echo number_format($data->count); ?></span>
								</div>
								<div style="text-align:right;">
									<span style="display:block; font-size:0.8rem; color:#666;">Earnings</span>
									<span style="font-size:1.1rem; font-weight:700; color:#333;"><?php echo wc_price($data->total); ?></span>
								</div>
							</div>
							<?php endforeach; ?>
						</div>
					</div>
				</div>

				<!-- Recent Conversions -->
				<div style="margin-top: 40px;">
					<h3 style="margin-bottom: 16px; font-size: 1.1rem; color: #111;">Recent Conversions (Orders)</h3>
					<div class="table-responsive">
						<table class="bqr-table">
							<thead>
								<tr>
									<th>Date</th>
									<th>Order ID</th>
									<th>Order Total</th>
									<th>Commission</th>
									<th>Status</th>
								</tr>
							</thead>
							<tbody>
								<?php
								$recent_refs = $wpdb->get_results( $wpdb->prepare( 
									"SELECT * FROM {$wpdb->prefix}bqr_referrals WHERE affiliate_id = %d ORDER BY created_at DESC LIMIT 10", 
									$user_id 
								) );
								
								if ( $recent_refs ) : foreach ( $recent_refs as $ref ) : 
									$order = wc_get_order( $ref->reference_id );
									$order_total = $order ? $order->get_total() : 'N/A';
								?>
									<tr>
										<td><?php echo date_i18n( get_option( 'date_format' ), strtotime( $ref->created_at ) ); ?></td>
										<td>#<?php echo esc_html( $ref->reference_id ); ?></td>
										<td><?php echo is_numeric($order_total) ? wc_price($order_total) : $order_total; ?></td>
										<td><?php echo wc_price( $ref->amount ); ?></td>
										<td><span class="status-badge status-<?php echo esc_attr( $ref->status ); ?>"><?php echo ucfirst( $ref->status ); ?></span></td>
									</tr>
								<?php endforeach; else: ?>
									<tr><td colspan="5" style="text-align:center; padding: 20px; color: #999;">No conversions generated yet.</td></tr>
								<?php endif; ?>
							</tbody>
						</table>
					</div>
				</div>
			</div>

			<!-- Blog Posting Section -->
			<div class="bqr-section">
				<h2 style="border-bottom: 2px solid #f0f0f0;">Blog Posting Program</h2>
				<p style="color:#666;">Earn an extra <strong><?php echo wc_price( get_option('bqr_blog_bounty', 100) ); ?></strong> for every blog post you write about us!</p>
				
				<form method="post" style="margin-top: 20px; background: #f9fafb; padding: 20px; border-radius: 8px;">
					<?php wp_nonce_field( 'bqr_submit_blog', 'bqr_blog_nonce' ); ?>
					<h3 style="margin-top:0; font-size:1rem;">Submit Your Post</h3>
					<div class="bqr-input-group" style="max-width: 100%;">
						<input type="url" name="bqr_blog_url" placeholder="Enter your blog post URL (e.g., https://myblog.com/review)" required style="background:white;">
						<button type="submit" name="bqr_action" value="submit_blog" class="bqr-btn bqr-btn-primary">Submit for Review</button>
					</div>
				</form>

				<h3 style="margin-top: 30px; font-size: 1.1rem;">Submission History</h3>
				<div class="table-responsive">
					<table class="bqr-table">
						<thead>
							<tr>
								<th>Date</th>
								<th>URL</th>
								<th>Status</th>
								<th>Bounty</th>
							</tr>
						</thead>
						<tbody>
							<?php
							$blogs = $wpdb->get_results( $wpdb->prepare( "SELECT * FROM {$wpdb->prefix}bqr_referrals WHERE affiliate_id = %d AND type = 'blog_post' ORDER BY created_at DESC LIMIT 5", $user_id ) );
							if ( $blogs ) :
								foreach ( $blogs as $blog ) : ?>
								<tr>
									<td><?php echo date_i18n( get_option( 'date_format' ), strtotime( $blog->created_at ) ); ?></td>
									<td style="word-break: break-all;"><a href="<?php echo esc_url( $blog->description ); ?>" target="_blank" style="color:#2563eb; text-decoration:none;">View Post</a></td>
									<td><span class="status-badge status-<?php echo esc_attr( $blog->status ); ?>"><?php echo ucfirst( $blog->status ); ?></span></td>
									<td><?php echo wc_price( $blog->amount ); ?></td>
								</tr>
							<?php endforeach; else: ?>
								<tr><td colspan="4" style="text-align:center; padding: 24px; color: #9ca3af;">No blog posts submitted yet.</td></tr>
							<?php endif; ?>
						</tbody>
					</table>
				</div>
			</div>

			</div>
				</div>
			</div>
			
			</div>
		</div>
		<?php
		return ob_get_clean();
	}

	public function render_investment_dashboard( $atts ) {
		if ( ! is_user_logged_in() ) {
			return '<div class="bqr-alert">Please <a href="' . wp_login_url( get_permalink() ) . '" style="margin-left:5px; font-weight:700;">login</a> to view your Investment Portfolio.</div>';
		}

		$user_id = get_current_user_id();
		$wallet = new BQ_Referral_Wallet();
		$balance = $wallet->get_balance( $user_id );
		global $wpdb;

		ob_start();
		?>
		<div class="bqr-dashboard">
			<?php if ( isset( $_GET['bqr_msg'] ) ) : ?>
				<div class="bqr-success"><?php echo esc_html( $_GET['bqr_msg'] ); ?></div>
			<?php endif; ?>

			<div class="bqr-section" style="border: 1px solid #ccfbf1; background: linear-gradient(to bottom right, #f0fdfa, #ffffff);">
				<div style="display:flex; justify-content:space-between; align-items:center; border-bottom: 2px solid #ccfbf1; padding-bottom:16px;">
					<h2 style="border:none; margin:0; padding:0; color:#0f766e;">Investment Portfolio</h2>
					<div style="text-align:right;">
						<span style="display:block; font-size:0.8rem; color:#666;">Investable Balance</span>
						<span style="font-weight:700; color:#0f766e; font-size:1.5rem;"><?php echo wc_price( $balance ); ?></span>
					</div>
				</div>

				<!-- Invest Action -->
				<form method="post" style="margin-top:20px; background:white; padding:24px; border-radius:12px; border:1px solid #e2e8f0; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);">
					<?php wp_nonce_field( 'bqr_invest_action', 'bqr_invest_nonce' ); ?>
					<h3 style="margin-top:0; color:#111; font-size:1.1rem; margin-bottom: 8px;">Start New Investment</h3>
					<p style="font-size:0.95rem; color:#475569; margin-bottom:20px;">Choose a category to invest in. Returns accrue daily based on category performance.</p>
					
					<div style="margin-bottom:20px;">
						<label style="display:block; margin-bottom:8px; font-weight:600; color:#334155;">Select Category</label>
						<select name="invest_category" style="width:100%; padding:10px; border:1px solid #cbd5e1; border-radius:8px; background:#f8fafc; font-size:1rem;">
							<option value="Securities & Derivatives">Securities & Derivatives (ROI: <?php echo get_option('bqr_roi_securities', 1.00); ?>%)</option>
							<option value="Currencies & Commodities">Currencies & Commodities (ROI: <?php echo get_option('bqr_roi_currencies', 1.25); ?>%)</option>
							<option value="Real Estate">Real Estate (ROI: <?php echo get_option('bqr_roi_realestate', 0.80); ?>%)</option>
						</select>
					</div>
					
					<div class="bqr-input-group" style="max-width:100%; box-shadow:none; border: 1px solid #cbd5e1; background: #f8fafc;">
						<input type="number" name="invest_amount" placeholder="Enter Amount to Invest (Min 100)" min="100" step="0.01" style="background:transparent; font-size:1.1rem;">
						<button type="submit" name="bqr_action" value="invest_start" class="bqr-btn" style="background:#0f766e; color:white; padding: 12px 30px; font-size: 1rem;">Invest Now</button>
					</div>
				</form>

				<!-- Active Investments -->
				<h3 style="margin-top:40px; margin-bottom:20px; font-size:1.2rem; color:#1e293b;">Your Active Investments</h3>
				<div class="table-responsive" style="box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);">
					<table class="bqr-table">
						<thead>
							<tr>
								<th>Date</th>
								<th>Category</th>
								<th>Principal</th>
								<th>ROI / Day</th>
								<th>Accrued Profit</th>
								<th>Total Earned</th>
								<th>Actions</th>
							</tr>
						</thead>
						<tbody>
							<?php
							// Show 'active' and 'closing_pending' (Withdrawal Requested) investments
							$investments = $wpdb->get_results( $wpdb->prepare( "SELECT * FROM {$wpdb->prefix}bqr_investments WHERE user_id = %d AND status IN ('active', 'closing_pending') ORDER BY created_at DESC", $user_id ) );
							
							if ($investments) : foreach($investments as $inv) :
								$stats_label = 'Active';
								$row_style = '';
								
								// Calculate Profit logic
								$start = strtotime($inv->last_profit_withdrawal); 
								$now = time();
								$seconds_elapsed = $now - $start;
								$days_fraction = $seconds_elapsed / 86400;
								$pending_profit = $inv->amount * ($inv->roi_rate / 100) * $days_fraction;
								
								if($inv->status == 'closing_pending') {
									$pending_profit = 0; // Stop accruing if closing
									$stats_label = 'Withdrawal Pending';
									$row_style = 'background: #fff7ed;';
								}
								
								if($pending_profit < 0) $pending_profit = 0;
							?>
							<tr style="<?php echo $row_style; ?>">
								<td>
									<?php echo date_i18n( get_option( 'date_format' ), strtotime( $inv->created_at ) ); ?>
									<?php if($inv->status == 'closing_pending'): ?>
										<br><span style="font-size:0.75rem; color:#c2410c; font-weight:600;">Processing Exit</span>
									<?php endif; ?>
								</td>
								<td style="font-weight:600; color:#475569;"><?php echo esc_html( !empty($inv->category) ? $inv->category : 'Securities & Derivatives' ); ?></td>
								<td style="font-weight:700; color:#334155;"><?php echo wc_price( $inv->amount ); ?></td>
								<td><span style="background:#f1f5f9; padding:4px 8px; border-radius:4px; font-weight:600;"><?php echo $inv->roi_rate; ?>%</span></td>
								<td style="color:#059669; font-weight:700; font-size:1.05rem;"><?php echo wc_price( $pending_profit ); ?></td>
								<td style="color:#64748b;"><?php echo wc_price( $inv->total_earned ); ?></td>
								<td>
									<?php if($inv->status == 'active'): ?>
										<form method="post" style="display:inline-flex; gap:8px;">
											<?php wp_nonce_field( 'bqr_invest_action', 'bqr_invest_nonce' ); ?>
											<input type="hidden" name="inv_id" value="<?php echo $inv->id; ?>">
											
											<?php if($pending_profit > 0.01): ?>
											<button type="submit" name="bqr_action" value="invest_claim" class="bqr-btn" style="padding:8px 16px; font-size:0.85rem; background:#10b981; color:white; box-shadow:none;">Claim</button>
											<?php else: ?>
											<button type="button" disabled class="bqr-btn" style="padding:8px 16px; font-size:0.85rem; background:#cbd5e1; color:#fff; cursor:default; box-shadow:none;">Claim</button>
											<?php endif; ?>
											
											<button type="submit" name="bqr_action" value="invest_withdraw" class="bqr-btn" style="padding:8px 16px; font-size:0.85rem; background:#fff; color:#ef4444; border:1px solid #ef4444; box-shadow:none;" onclick="return confirm('Withdraw principal and close investment? This requires admin approval.');">Withdraw</button>
										</form>
									<?php else: ?>
										<span style="color:#f59e0b; font-weight:600;">Locked</span>
									<?php endif; ?>
								</td>
							</tr>
							<?php endforeach; else: ?>
							<tr><td colspan="7" style="text-align:center; color:#94a3b8; padding:30px;">No active investments found. Start investing to earn daily profit!</td></tr>
							<?php endif; ?>
						</tbody>
					</table>
				</div>
			</div>
		</div>
		<?php
		return ob_get_clean();
	}

	public function render_wallet_dashboard( $atts ) {
		if ( ! is_user_logged_in() ) {
			return '<div class="bqr-alert">Please <a href="' . wp_login_url( get_permalink() ) . '" style="margin-left:5px; font-weight:700;">login</a> to view your Wallet.</div>';
		}

		$user_id = get_current_user_id();
		$wallet = new BQ_Referral_Wallet();
		$balance = $wallet->get_balance( $user_id );
		global $wpdb;

		ob_start();
		?>
		<div class="bqr-dashboard">
			<?php if ( isset( $_GET['bqr_msg'] ) ) : ?>
				<div class="bqr-success"><?php echo esc_html( $_GET['bqr_msg'] ); ?></div>
			<?php endif; ?>

			<div class="bqr-stats-grid" style="grid-template-columns: 1fr;">
				<div class="bqr-card highlight" style="background: linear-gradient(135deg, #4f46e5, #3730a3); color: white; border:none; text-align:center; padding: 40px;">
					<h3 style="color: #c7d2fe; margin-bottom: 10px;">Total Wallet Balance</h3>
					<div class="value" style="color: white; font-size: 3rem;"><?php echo wc_price( $balance ); ?></div>
					<div style="margin-top: 20px; font-size: 0.9rem; opacity: 0.8;">Available for Investment or Withdrawal</div>
				</div>
			</div>

			<div style="display:grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap:30px; margin-top:30px;">
				<!-- Add Funds (Deposit Request) -->
				<div class="bqr-section" style="margin-top:0;">
					<h2 style="border-bottom: 1px solid #e5e7eb;">Add Funds</h2>
					<p style="color:#666; margin-bottom:20px;">Submit a deposit request. Funds will be added after admin approval.</p>
					
					<form method="post" style="background: #f9fafb; padding: 20px; border-radius: 8px;">
						<?php wp_nonce_field( 'bqr_wallet_action', 'bqr_wallet_nonce' ); ?>
						<div style="margin-bottom:15px;">
							<select name="deposit_method" style="width:100%; padding: 10px; border: 1px solid #d1d5db; border-radius: 8px; background:white;">
								<option value="bank">Bank Transfer</option>
								<option value="upi">UPI / GPay</option>
								<option value="crypto">USDT / Crypto</option>
							</select>
						</div>
						<div style="margin-bottom:15px;">
							<input type="text" name="transaction_ref" placeholder="Enter Transaction Ref ID (UTR/Hash)" required style="width:100%; padding: 10px; border: 1px solid #d1d5db; border-radius: 8px;">
						</div>
						<div class="bqr-input-group" style="max-width: 100%;">
							<input type="number" name="amount" placeholder="Amount" min="10" step="0.01" required style="background:white;">
							<button type="submit" name="bqr_action" value="add_funds_request" class="bqr-btn bqr-btn-primary">Submit Request</button>
						</div>
					</form>
				</div>

				<!-- Withdraw -->
				<div class="bqr-section" style="margin-top:0;">
					<h2 style="border-bottom: 1px solid #e5e7eb;">Withdraw Funds</h2>
					<p style="color:#666; margin-bottom:20px;">Request a payout to your bank account.</p>
					
					<form method="post" style="background: #f9fafb; padding: 20px; border-radius: 8px;">
						<?php wp_nonce_field( 'bqr_wallet_action', 'bqr_wallet_nonce' ); ?>
						<div style="margin-bottom:15px;">
							<select name="bqr_payout_method" style="width:100%; padding: 10px; border: 1px solid #d1d5db; border-radius: 8px; background:white;">
								<option value="bank">Bank Transfer</option>
								<option value="paypal">PayPal</option>
								<option value="upi">UPI</option>
							</select>
						</div>
						
						<?php if ( $balance >= 50 ) : ?>
							<div class="bqr-input-group" style="max-width: 100%;">
								<input type="number" name="amount" placeholder="Amount to Withdraw (Max <?php echo $balance; ?>)" min="50" max="<?php echo $balance; ?>" step="0.01" required style="background:white;">
								<button type="submit" name="bqr_action" value="request_payout" class="bqr-btn" style="background:#ef4444; color:white;">Request Payout</button>
							</div>
						<?php else: ?>
							<button type="button" class="bqr-btn" style="width:100%; background: #e5e7eb; color:#9ca3af; cursor: not-allowed;">Min Balance 50</button>
						<?php endif; ?>
					</form>
				</div>
				</div>
			</div>

			<div class="bqr-section">
				<h3>Transaction History</h3>
				<div class="table-responsive">
					<table class="bqr-table">
						<thead>
							<tr>
								<th>Date</th>
								<th>Type</th>
								<th>Amount</th>
								<th>Details</th>
							</tr>
						</thead>
						<tbody>
							<?php
							// Show all wallet transactions (commissions, investments, deposits, withdrawals)
							$transactions = $wpdb->get_results( $wpdb->prepare( "SELECT * FROM {$wpdb->prefix}bqr_transactions WHERE user_id = %d ORDER BY created_at DESC LIMIT 20", $user_id ) );
							if ( $transactions ) :
								foreach ( $transactions as $t ) : 
									$color = $t->amount >= 0 ? '#10b981' : '#ef4444';
								?>
								<tr>
									<td><?php echo date_i18n( get_option( 'date_format' ), strtotime( $t->created_at ) ); ?></td>
									<td><?php echo ucfirst( str_replace('_', ' ', $t->type) ); ?></td>
									<td style="font-weight:700; color:<?php echo $color; ?>;"><?php echo ($t->amount > 0 ? '+' : '') . wc_price( $t->amount ); ?></td>
									<td style="color:#666; font-size:0.9rem;"><?php echo esc_html( $t->description ); ?></td>
								</tr>
							<?php endforeach; else: ?>
								<tr><td colspan="4" style="text-align:center; padding: 24px; color: #9ca3af;">No transaction history found.</td></tr>
							<?php endif; ?>
						</tbody>
					</table>
				</div>
			</div>
			
			<div class="bqr-section" style="margin-top: 30px;">
				<h3>Pending Requests (Deposits & Withdrawals)</h3>
				<div class="table-responsive">
					<table class="bqr-table">
						<thead>
							<tr>
								<th>Date</th>
								<th>Type</th>
								<th>Amount</th>
								<th>Method / Details</th>
								<th>Status</th>
							</tr>
						</thead>
						<tbody>
							<?php
							// Fetch both deposits (from transactions?? No, need a place for pending deposits. Using Payouts table with type 'deposit' or custom logic?? 
							// Actually, for simplicity, let's store pending deposits in `bqr_payouts` table but with type 'deposit' or negative amount? 
							// Better: Use `bqr_payouts` table but renamed conceptually to `bqr_requests`. 
							// Current schema `bqr_payouts` has: id, affiliate_id, amount, method, details, status.
							// We will use positive amount for Payout, negative amount (or just a type field if we had one) or just differentiate by context.
							// Let's stick to `bqr_payouts` for now, adding a 'type' column via DB update would be cleanest, but for now we can infer:
							// Wait, `bqr_payouts` doesn't have a 'type' column. 
							// Let's use `details` to store JSON prefix "DEPOSIT:" or "PAYOUT:".
							
							$requests = $wpdb->get_results( $wpdb->prepare( "SELECT * FROM {$wpdb->prefix}bqr_payouts WHERE affiliate_id = %d ORDER BY created_at DESC LIMIT 10", $user_id ) );
							
							if ( $requests ) :
								foreach ( $requests as $req ) : 
									$is_deposit = ( strpos($req->details, 'DEPOSIT:') === 0 );
									$label = $is_deposit ? 'Deposit' : 'Withdrawal';
									$color = $is_deposit ? '#0f766e' : '#c2410c';
								?>
								<tr>
									<td><?php echo date_i18n( get_option( 'date_format' ), strtotime( $req->created_at ) ); ?></td>
									<td style="font-weight:600; color:<?php echo $color; ?>"><?php echo $label; ?></td>
									<td><?php echo wc_price( $req->amount ); ?></td>
									<td style="font-size:0.9rem; color:#555;">
										<?php echo ucfirst( $req->method ); ?>
										<br><span style="color:#888; font-size:0.8rem;"><?php echo esc_html( str_replace(['DEPOSIT:', 'PAYOUT:'], '', $req->details) ); ?></span>
									</td>
									<td><span class="status-badge status-<?php echo esc_attr( $req->status ); ?>"><?php echo ucfirst( $req->status ); ?></span></td>
								</tr>
							<?php endforeach; else: ?>
								<tr><td colspan="5" style="text-align:center; padding: 24px; color: #9ca3af;">No pending requests found.</td></tr>
							<?php endif; ?>
						</tbody>
					</table>
				</div>
			</div>

		</div>
		<?php
		return ob_get_clean();
	}

	public function handle_wallet_action() {
		if ( isset( $_POST['bqr_action'] ) && in_array($_POST['bqr_action'], ['request_payout', 'add_funds_request']) ) {
			if ( ! is_user_logged_in() ) return;
			if ( ! wp_verify_nonce( $_POST['bqr_wallet_nonce'], 'bqr_wallet_action' ) ) return;

			$user_id = get_current_user_id();
			$wallet = new BQ_Referral_Wallet();
			$balance = $wallet->get_balance( $user_id );
			global $wpdb;

			if ( $_POST['bqr_action'] == 'add_funds_request' ) {
				$amount = floatval( $_POST['amount'] );
				$method = sanitize_text_field( $_POST['deposit_method'] );
				$ref = sanitize_text_field( $_POST['transaction_ref'] );
				
				if ( $amount > 0 && !empty($ref) ) {
					// Create Pending Request in Payouts table (abusing it slightly for Requests)
					// storing "DEPOSIT: Ref ID" in details
					$wpdb->insert(
						$wpdb->prefix . 'bqr_payouts',
						array(
							'affiliate_id' => $user_id,
							'amount'       => $amount, 
							'method'       => $method,
							'details'      => 'DEPOSIT: ' . $ref,
							'status'       => 'pending' // pending approval
						),
						array( '%d', '%f', '%s', '%s', '%s' )
					);
					
					wp_redirect( add_query_arg( 'bqr_msg', 'Deposit request submitted! Admin will verify and approve.', remove_query_arg( 'bqr_action' ) ) );
					exit;
				}
			}

			if ( $_POST['bqr_action'] == 'request_payout' ) {
				$amount = floatval( $_POST['amount'] );
				if ( $amount >= 50 && $balance >= $amount ) {
					$method = isset($_POST['bqr_payout_method']) ? sanitize_text_field($_POST['bqr_payout_method']) : 'manual';
					
					// 1. Create Payout Request
					$wpdb->insert(
						$wpdb->prefix . 'bqr_payouts',
						array(
							'affiliate_id' => $user_id,
							'amount'       => $amount, 
							'method'       => $method,
							'details'      => 'PAYOUT: User requested via ' . ucfirst($method),
							'status'       => 'pending'
						),
						array( '%d', '%f', '%s', '%s', '%s' )
					);
					
					$payout_id = $wpdb->insert_id;
					
					// Notify Admin
					do_action( 'bqr_payout_requested', $payout_id, $user_id );

					// 2. Debit Wallet immediately (Lock funds)
					$wallet->add_transaction( $user_id, -$amount, 'payout_hold', $payout_id, 'Funds locked for Payout #' . $payout_id );

					wp_redirect( add_query_arg( 'bqr_msg', 'Payout requested successfully!', remove_query_arg( 'bqr_action' ) ) );
					exit;
				} else {
					wp_redirect( add_query_arg( 'bqr_msg', 'Invalid amount or insufficient balance.', remove_query_arg( 'bqr_action' ) ) );
					exit;
				}
			}
		}
	}
	public function handle_blog_submission() {
		if ( isset( $_POST['bqr_action'] ) && $_POST['bqr_action'] == 'submit_blog' ) {
			if ( ! is_user_logged_in() ) return;
			if ( ! wp_verify_nonce( $_POST['bqr_blog_nonce'], 'bqr_submit_blog' ) ) return;

			$url = esc_url_raw( $_POST['bqr_blog_url'] );
			if ( empty( $url ) ) return;

			$user_id = get_current_user_id();
			global $wpdb;
			
			// Duplicate check
			$exists = $wpdb->get_var( $wpdb->prepare( "SELECT id FROM {$wpdb->prefix}bqr_referrals WHERE description = %s AND type='blog_post'", $url ) );
			if ( $exists ) {
				wp_redirect( add_query_arg( 'bqr_msg', 'This URL has already been submitted.', remove_query_arg( 'bqr_action' ) ) );
				exit;
			}

			$amount = get_option( 'bqr_blog_bounty', 100 );
			
			$wpdb->insert(
				$wpdb->prefix . 'bqr_referrals',
				array(
					'affiliate_id' => $user_id,
					'reference_id' => 'blog_' . time() . '_' . rand(100,999),
					'type'         => 'blog_post',
					'amount'       => $amount,
					'currency'     => get_woocommerce_currency(),
					'status'       => 'pending',
					'description'  => $url
				),
				array( '%d', '%s', '%s', '%f', '%s', '%s', '%s' )
			);

			wp_redirect( add_query_arg( 'bqr_msg', 'Blog post submitted successfully for review!', remove_query_arg( 'bqr_action' ) ) );
			exit;
		}
	}

	public function handle_investment_action() {
		if ( isset( $_POST['bqr_action'] ) && strpos( $_POST['bqr_action'], 'invest_' ) === 0 ) {
			if ( ! is_user_logged_in() ) return;
			if ( ! wp_verify_nonce( $_POST['bqr_invest_nonce'], 'bqr_invest_action' ) ) return;

			global $wpdb;
			$user_id = get_current_user_id();
			$wallet = new BQ_Referral_Wallet();
			$action = $_POST['bqr_action'];

			if ( $action == 'invest_start' ) {
				$amount = floatval( $_POST['invest_amount'] );
				if ( $amount < 100 ) {
					wp_redirect( add_query_arg( 'bqr_msg', 'Minimum investment is 100.', remove_query_arg('bqr_action') ) );
					exit;
				}
				
				if ( ! $wallet->has_sufficient_balance( $user_id, $amount ) ) {
					wp_redirect( add_query_arg( 'bqr_msg', 'Insufficient wallet balance.', remove_query_arg('bqr_action') ) );
					exit;
				}

				// Debit Wallet
				$wallet->add_transaction( $user_id, -$amount, 'investment_debit', 0, 'Invested in Portfolio' );

				// Create Investment
				$category = isset($_POST['invest_category']) ? sanitize_text_field($_POST['invest_category']) : 'Securities & Derivatives';
				$roi = 1.00;
				
				if( $category == 'Securities & Derivatives' ) $roi = get_option('bqr_roi_securities', 1.00);
				elseif( $category == 'Currencies & Commodities' ) $roi = get_option('bqr_roi_currencies', 1.25);
				elseif( $category == 'Real Estate' ) $roi = get_option('bqr_roi_realestate', 0.80);

				$inserted = $wpdb->insert(
					$wpdb->prefix . 'bqr_investments',
					array( 'user_id' => $user_id, 'amount' => $amount, 'category' => $category, 'roi_rate' => $roi ),
					array( '%d', '%f', '%s', '%f' )
				);
				
				if ( false === $inserted ) {
					// Refund
					$wallet->add_transaction( $user_id, $amount, 'investment_refund', 0, 'Refund for failed investment' );
					wp_redirect( add_query_arg( 'bqr_msg', 'Investment failed. Please try again. Wallet refunded.', remove_query_arg('bqr_action') ) );
					exit;
				}
				
				wp_redirect( add_query_arg( 'bqr_msg', 'Investment started successfully in ' . $category . '!', remove_query_arg('bqr_action') ) );
				exit;
			}
			
			if ( $action == 'invest_claim' || $action == 'invest_withdraw' ) {
				$inv_id = intval( $_POST['inv_id'] );
				$inv = $wpdb->get_row( $wpdb->prepare( "SELECT * FROM {$wpdb->prefix}bqr_investments WHERE id=%d AND user_id=%d", $inv_id, $user_id ) );
				
				if ( ! $inv ) return;

				// Calculate Interest to CLAIM
				$start = strtotime( $inv->last_profit_withdrawal );
				$now = time();
				$seconds_elapsed = $now - $start;
				$days_fraction = $seconds_elapsed / 86400;
				$profit = $inv->amount * ($inv->roi_rate / 100) * $days_fraction;

				if ( $profit > 0 ) {
					// Credit Profit
					$wallet->add_transaction( $user_id, $profit, 'investment_roi', $inv_id, 'ROI from Investment #' . $inv_id );
					
					// Update Investment
					$wpdb->update(
						$wpdb->prefix . 'bqr_investments',
						array( 
							'last_profit_withdrawal' => current_time( 'mysql' ),
							'total_earned' => $inv->total_earned + $profit
						),
						array( 'id' => $inv_id )
					);
				}

				if ( $action == 'invest_withdraw' ) {
					// 1. Create Withdrawal Request for Principal
					$wpdb->insert(
						$wpdb->prefix . 'bqr_payouts',
						array(
							'affiliate_id' => $user_id,
							'amount'       => $inv->amount, 
							'method'       => 'wallet', // Internal wallet return
							'details'      => 'INVESTMENT_RETURN: Principal for #' . $inv_id,
							'status'       => 'pending'
						),
						array( '%d', '%f', '%s', '%s', '%s' )
					);
					
					// 2. Mark Investment as 'closing_pending' (so they can't withdraw again)
					$wpdb->update( 
						$wpdb->prefix . 'bqr_investments', 
						array( 'status' => 'closing_pending' ), 
						array( 'id' => $inv_id ) 
					);
					
					wp_redirect( add_query_arg( 'bqr_msg', 'Withdrawal requested! Principal will be returned to wallet after admin approval.', remove_query_arg('bqr_action') ) );
					exit;
				}

				wp_redirect( add_query_arg( 'bqr_msg', 'Profit claimed successfully!', remove_query_arg('bqr_action') ) );
				exit;
			}
		}
	}
}
new BQ_Referral_Shortcodes();
