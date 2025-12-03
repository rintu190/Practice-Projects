class Validators {
  // Phone Number Validation (Indian)
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    
    // Remove spaces and special characters
    String phone = value.replaceAll(RegExp(r'[^\d]'), '');
    
    if (phone.length != 10) {
      return 'Phone number must be 10 digits';
    }
    
    if (!RegExp(r'^\d{10}$').hasMatch(phone)) {
      return 'Please enter a valid 10-digit phone number';
    }
    
    return null;
  }
  
  // Email Validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }
  
  // PAN Card Validation
  static String? validatePAN(String? value) {
    if (value == null || value.isEmpty) {
      return 'PAN number is required';
    }
    
    String pan = value.toUpperCase().trim();
    
    if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(pan)) {
      return 'Please enter a valid PAN number (e.g., ABCDE1234F)';
    }
    
    return null;
  }
  
  // Aadhaar Validation
  static String? validateAadhaar(String? value) {
    if (value == null || value.isEmpty) {
      return 'Aadhaar number is required';
    }
    
    String aadhaar = value.replaceAll(RegExp(r'[^\d]'), '');
    
    if (aadhaar.length != 12) {
      return 'Aadhaar number must be 12 digits';
    }
    
    if (!RegExp(r'^\d{12}$').hasMatch(aadhaar)) {
      return 'Please enter a valid Aadhaar number';
    }
    
    return null;
  }
  
  // IFSC Code Validation
  static String? validateIFSC(String? value) {
    if (value == null || value.isEmpty) {
      return 'IFSC code is required';
    }
    
    String ifsc = value.toUpperCase().trim();
    
    if (!RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(ifsc)) {
      return 'Please enter a valid IFSC code (e.g., SBIN0001234)';
    }
    
    return null;
  }
  
  // UPI ID Validation
  static String? validateUPI(String? value) {
    if (value == null || value.isEmpty) {
      return null; // UPI is optional
    }
    
    if (!RegExp(r'^[\w.-]+@[\w]+$').hasMatch(value)) {
      return 'Please enter a valid UPI ID (e.g., user@paytm)';
    }
    
    return null;
  }
  
  // Bank Account Number Validation
  static String? validateAccountNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Account number is required';
    }
    
    String account = value.replaceAll(RegExp(r'[^\d]'), '');
    
    if (account.length < 9 || account.length > 18) {
      return 'Account number must be between 9-18 digits';
    }
    
    return null;
  }
  
  // Amount Validation
  static String? validateAmount(String? value, {double? min, double? max}) {
    if (value == null || value.isEmpty) {
      return 'Amount is required';
    }
    
    double? amount = double.tryParse(value);
    
    if (amount == null) {
      return 'Please enter a valid amount';
    }
    
    if (amount <= 0) {
      return 'Amount must be greater than 0';
    }
    
    if (min != null && amount < min) {
      return 'Minimum amount is ₹$min';
    }
    
    if (max != null && amount > max) {
      return 'Maximum amount is ₹$max';
    }
    
    return null;
  }
  
  // OTP Validation
  static String? validateOTP(String? value, {int length = 6}) {
    if (value == null || value.isEmpty) {
      return 'OTP is required';
    }
    
    if (value.length != length) {
      return 'OTP must be $length digits';
    }
    
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'OTP must contain only numbers';
    }
    
    return null;
  }
  
  // Name Validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Name can only contain letters and spaces';
    }
    
    return null;
  }
  
  // Referral Code Validation
  static String? validateReferralCode(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Referral code is optional
    }
    
    if (value.length < 6 || value.length > 20) {
      return 'Referral code must be between 6-20 characters';
    }
    
    if (!RegExp(r'^[A-Z0-9]+$').hasMatch(value.toUpperCase())) {
      return 'Referral code can only contain letters and numbers';
    }
    
    return null;
  }
  
  // Required Field Validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
}
