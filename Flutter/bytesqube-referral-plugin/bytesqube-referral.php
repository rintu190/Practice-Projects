<?php
/**
 * Plugin Name: BytesQube Referral System
 * Plugin URI: https://bytesqube.com/
 * Description: A robust, multi-level referral and affiliate tracking system with WooCommerce integration, wallet management, and fraud detection.
 * Version: 1.0.0
 * Author: BytesQube Dev Team
 * Author URI: https://bytesqube.com/
 * Text Domain: bytesqube-referral
 * Domain Path: /languages
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

// Define Constants
define( 'BQR_VERSION', '1.0.0' );
define( 'BQR_PLUGIN_DIR', plugin_dir_path( __FILE__ ) );
define( 'BQR_PLUGIN_URL', plugin_dir_url( __FILE__ ) );
define( 'BQR_ABSPATH', dirname( __FILE__ ) );

/**
 * Main Plugin Class
 */
class BytesQube_Referral {

	private static $instance = null;

	public static function get_instance() {
		if ( null === self::$instance ) {
			self::$instance = new self();
		}
		return self::$instance;
	}

	private function __construct() {
		$this->includes();
		$this->init_hooks();
	}

	private function includes() {
		require_once BQR_PLUGIN_DIR . 'includes/class-bq-referral-db.php';
		require_once BQR_PLUGIN_DIR . 'includes/class-bq-referral-tracker.php';
		require_once BQR_PLUGIN_DIR . 'includes/class-bq-referral-woocommerce.php';
		require_once BQR_PLUGIN_DIR . 'includes/class-bq-referral-wallet.php';
		require_once BQR_PLUGIN_DIR . 'includes/class-bq-referral-shortcodes.php';
		require_once BQR_PLUGIN_DIR . 'includes/class-bq-referral-notifications.php';
		require_once BQR_PLUGIN_DIR . 'includes/class-bq-referral-api.php';
		
		if ( is_admin() ) {
			require_once BQR_PLUGIN_DIR . 'admin/class-bq-referral-admin.php';
		}
	}

	private function init_hooks() {
		register_activation_hook( __FILE__, array( 'BQ_Referral_DB', 'create_tables' ) );
		add_action( 'plugins_loaded', array( $this, 'load_textdomain' ) );
		add_action( 'init', array( $this, 'register_post_types' ) );
		
		// Initialize Components
		new BQ_Referral_Notifications();
		new BQ_Referral_API();

		// Auto-update DB and rules if version changed
		add_action( 'init', array( $this, 'check_version' ) );
	}

	public function check_version() {
		if ( get_option( 'bqr_db_version' ) != '1.2.3' ) {
			BQ_Referral_DB::create_tables();
			flush_rewrite_rules();
		}
	}

	public function load_textdomain() {
		load_plugin_textdomain( 'bytesqube-referral', false, dirname( plugin_basename( __FILE__ ) ) . '/languages' );
	}
	
	public function register_post_types() {
		// Register any specific post types if needed (e.g., Payout Requests could be a CPT, but we are using custom tables for performance)
	}

}

// Initialize the Plugin
function run_bytesqube_referral() {
	return BytesQube_Referral::get_instance();
}
run_bytesqube_referral();
