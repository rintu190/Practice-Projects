class ApiConfig {
  // Base URL - Change this to your server URL
  // For Android Emulator: use 10.0.2.2
  // For iOS Simulator: use localhost or 127.0.0.1
  // For Physical Device: use your computer's IP address (e.g., 192.168.1.8)
  static const String baseUrl = 'http://10.0.2.2:8000';

  // API Endpoints
  static const String apiVersion = 'v1';

  // Auth Endpoints
  static const String login = '/routes/auth.php?action=login';
  static const String sendOtp = '/routes/auth.php?action=send_otp';
  static const String verifyOtp = '/routes/auth.php?action=verify_otp';
  static const String loginPassword = '/routes/auth.php?action=login_password';
  static const String register = '/routes/auth.php?action=register';
  static const String logout = '/routes/auth.php?action=logout';

  // KYC Endpoints
  static const String uploadKyc = '/routes/kyc.php?action=upload';
  static const String getKycStatus = '/routes/kyc.php?action=get_status';
  static const String updateKyc = '/routes/kyc.php?action=update';

  // Bank Endpoints
  static const String addBank = '/routes/bank.php?action=add';
  static const String getBank = '/routes/bank.php?action=get';
  static const String updateBank = '/routes/bank.php?action=update';

  // P&L Endpoints
  static const String getTodayPnl = '/routes/pnl.php?action=get_today';
  static const String getPnlHistory = '/routes/pnl.php?action=get_history';
  static const String getUnrealizedPnl =
      '/routes/pnl.php?action=get_unrealized';

  // Genealogy Endpoints
  static const String getGenealogyTree = '/routes/genealogy.php?action=get_tree';
  static const String getGenealogyStats = '/routes/genealogy.php?action=get_stats';

  // Referral Endpoints
  static const String getReferralCode = '/routes/referral.php?action=get_code';
  static const String getReferralAnalytics = '/routes/referral.php?action=get_analytics';

  // User Endpoints
  static const String getUserProfile = '/routes/users.php?action=get_profile';
  static const String updateProfile = '/routes/users/php?action=update_profile';

  // KYC Endpoints
  // static const String uploadKyc = '/routes/kyc.php?action=upload';
  // static const String getKycStatus = '/routes/kyc.php?action=get_status';

  // Bank Details Endpoints
  static const String addBankDetails = '/routes/bank.php?action=add';
  static const String getBankDetails = '/routes/bank.php?action=get';

  // Dashboard Endpoints
  static const String getDashboard = '/routes/dashboard.php?action=get_data';
  static const String getTeam = '/routes/team.php?action=get_directs';

  // Wallet Endpoints
  static const String getWalletBalance =
      '/routes/wallet.php?action=get_balance';
  static const String getTransactions =
      '/routes/wallet.php?action=get_transactions';
  static const String addFunds = '/routes/wallet.php?action=add_funds';
  static const String withdraw = '/routes/wallet.php?action=withdraw';

  // Investment Endpoints
  static const String getInvestmentProducts =
      '/routes/investment.php?action=get_products';
  static const String investNow = '/routes/investment.php?action=invest';
  static const String getMyInvestments =
      '/routes/investment.php?action=get_my_investments';
  static const String getPortfolio =
      '/routes/investment.php?action=get_portfolio';

  // Genealogy Endpoints
  static const String getGenealogy = '/routes/genealogy.php?action=get_tree';
  static const String getReferrals =
      '/routes/genealogy.php?action=get_referrals';
  static const String getReferralLink =
      '/routes/genealogy.php?action=get_referral_link';

  // Commission Endpoints
  static const String getCommissions =
      '/routes/commission.php?action=get_commissions';
  static const String getCommissionSummary =
      '/routes/commission.php?action=get_summary';

  // Reports Endpoints
  static const String getPnlReport = '/routes/reports.php?action=get_pnl';
  static const String getInvestmentReport =
      '/routes/reports.php?action=get_investment';

  // Notifications Endpoints
  static const String getNotifications =
      '/routes/notifications.php?action=get_all';
  static const String markAsRead = '/routes/notifications.php?action=mark_read';

  // Support Endpoints
  static const String createTicket = '/routes/support.php?action=create_ticket';
  static const String getTickets = '/routes/support.php?action=get_tickets';
  static const String sendMessage = '/routes/support.php?action=send_message';

  // Request timeout
  static const Duration timeout = Duration(seconds: 30);

  // Get full URL
  static String getUrl(String endpoint) {
    return baseUrl + endpoint;
  }
}
