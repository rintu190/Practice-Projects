import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class ApiConfig {
  // Base URL - Automatically detects platform
  // For Web/Desktop: use localhost
  // For Android Emulator: use 10.0.2.2
  // For iOS Simulator: use localhost
  // For Physical Device: use your computer's IP address (e.g., 192.168.1.8)
  static String get baseUrl {
    if (kIsWeb) {
      // Web platform
      return 'http://localhost:8000';
    } else {
      try {
        if (Platform.isAndroid) {
          // Android emulator
          return 'http://10.0.2.2:8000';
        } else if (Platform.isIOS) {
          // iOS simulator
          return 'http://localhost:8000';
        } else {
          // Desktop (macOS, Windows, Linux)
          return 'http://localhost:8000';
        }
      } catch (e) {
        // Fallback
        return 'http://localhost:8000';
      }
    }
  }

  // API Endpoints
  static const String apiVersion = 'v1';

  // Auth Endpoints
  static const String login = '/?action=login';
  static const String sendOtp = '/?action=send_otp';
  static const String verifyOtp = '/?action=verify_otp';
  static const String loginPassword = '/?action=login_password';
  static const String register = '/?action=register';
  static const String logout = '/?action=logout';


  // KYC Endpoints
  static const String uploadKyc = '/?action=upload';
  static const String getKycStatus = '/?action=get_status';
  static const String updateKyc = '/?action=update';

  // Bank Endpoints
  static const String addBank = '/?action=add';
  static const String getBank = '/?action=get';
  static const String updateBank = '/?action=update_bank';

  // P&L Endpoints
  static const String getTodayPnl = '/?action=get_today';
  static const String getPnlHistory = '/?action=get_pnl_history';
  static const String getUnrealizedPnl = '/?action=get_unrealized';

  // Genealogy Endpoints
  static const String getGenealogyTree = '/?action=get_tree';
  static const String getGenealogyStats = '/?action=get_stats';

  // Referral Endpoints
  static const String getReferralCode = '/?action=get_code';
  static const String getReferralAnalytics = '/?action=get_analytics';

  // User Endpoints
  static const String getUserProfile = '/?action=get_profile';
  static const String updateProfile = '/?action=update_profile';

  // Bank Details Endpoints
  static const String addBankDetails = '/?action=add';
  static const String getBankDetails = '/?action=get';

  // Dashboard Endpoints
  static const String getDashboard = '/?action=get_data';
  static const String getTeam = '/?action=get_directs';

  // Wallet Endpoints
  static const String getWalletBalance = '/?action=get_balance';
  static const String getTransactions = '/?action=get_transactions';
  static const String addFunds = '/?action=add_funds';
  static const String withdraw = '/?action=withdraw';
  static const String withdrawEarnings = '/?action=withdraw_earnings';

  // Earnings Endpoints
  static const String getEarningsBreakdown = '/?action=get_breakdown';
  static const String getEarningsHistory = '/?action=get_history';

  // Investment Endpoints
  static const String getInvestmentProducts = '/?action=get_products';
  static const String investNow = '/?action=invest';
  static const String getMyInvestments = '/?action=get_my_investments';
  static const String getPortfolio = '/?action=get_portfolio';

  // Genealogy Endpoints
  static const String getGenealogy = '/?action=get_tree';
  static const String getReferrals = '/?action=get_referrals';
  static const String getReferralLink = '/?action=get_referral_link';

  // Commission Endpoints
  static const String getCommissions = '/?action=get_commissions';
  static const String getCommissionSummary = '/?action=get_summary';

  // Reports Endpoints
  static const String getPnlReport = '/?action=get_pnl';
  static const String getInvestmentReport = '/?action=get_investment';

  // Notifications Endpoints
  static const String getNotifications = '/?action=get_all';
  static const String markAsRead = '/?action=mark_read';

  // Support Endpoints
  static const String createTicket = '/?action=create_ticket';
  static const String getTickets = '/?action=get_tickets';
  static const String sendMessage = '/?action=send_message';

  // Admin Endpoints
  static const String getUsers = '/?action=get_users';
  static const String getUserDetailsAdmin = '/?action=get_user_details';
  static const String updateUser = '/?action=update_user';
  static const String getPendingApprovals = '/?action=get_pending_approvals';
  static const String approveItem = '/?action=approve_item';
  static const String rejectItem = '/?action=reject_item';
  static const String approveDeposits = '/?action=approve_deposits';
  static const String approveWithdrawals = '/?action=approve_withdrawals';
  static const String approveTransfers = '/?action=approve_transfers';
  static const String triggerProfitCalculation = '/?action=trigger_profit_calculation';
  static const String adjustWallet = '/?action=adjust_wallet';
  static const String createProduct = '/?action=create_product';
  static const String updateProduct = '/?action=update_product';
  static const String uploadPnl = '/?action=upload_pnl';
  static const String getCommissionRules = '/?action=get_commission_rules';
  static const String updateCommissionRule = '/?action=update_commission_rule';

  // Request timeout
  static const Duration timeout = Duration(seconds: 30);

  // Get full URL
  static String getUrl(String endpoint) {
    return baseUrl + endpoint;
  }
}
