# MLM + Investment Mobile App

A comprehensive Multi-Level Marketing (MLM) and Investment management mobile application built with Flutter and PHP.

## ⚠️ Legal Disclaimer

This application involves financial services and MLM operations which are heavily regulated. Before deployment:

- Consult with legal counsel regarding MLM regulations
- Ensure compliance with securities laws and investment regulations
- Implement proper KYC/AML procedures
- Obtain necessary licenses and registrations
- Include proper risk disclosures and investor protection measures

## 🚀 Features

### Phase 1: Foundation ✅
- Flutter project structure
- PHP backend with MySQL
- Compliance warnings and legal disclaimers
- Theme system (Light/Dark mode)
- Core utilities and validators

### Phase 2: Authentication & Onboarding (In Progress)
- OTP-based login
- Referral code linking
- KYC upload (PAN/Aadhaar)
- Bank/UPI linking
- Investment risk warnings

### Upcoming Features
- User Dashboard
- MLM Genealogy System
- Dual Wallet System
- Investment Management
- P&L Reporting
- Commission Engine
- Reports & Analytics
- Notifications
- Admin Panel
- Support System

## 📁 Project Structure

```
flutter_mlm_investment/
├── lib/
│   ├── core/
│   │   ├── config/          # API, App, Compliance configs
│   │   ├── theme/           # App theme and colors
│   │   ├── utils/           # Validators, formatters
│   │   └── widgets/         # Reusable widgets
│   ├── features/
│   │   ├── auth/            # Authentication
│   │   ├── dashboard/       # User dashboard
│   │   ├── genealogy/       # MLM tree
│   │   ├── wallet/          # Wallet management
│   │   ├── investment/      # Investment products
│   │   └── ...
│   └── main.dart
└── pubspec.yaml

flutter_mlm_investment_backend/
├── config/
│   ├── config.php           # App configuration
│   └── database.php         # Database connection
├── routes/
│   ├── auth.php
│   ├── wallet.php
│   ├── investment.php
│   └── ...
├── models/
├── middleware/
├── utils/
├── database/
│   └── schema.sql           # Database schema
├── index.php
└── .htaccess
```

## 🛠️ Tech Stack

**Mobile App:**
- Flutter 3.x
- Provider (State Management)
- HTTP Client
- Google Fonts
- FL Chart (for graphs)
- Image Picker
- Mobile Scanner (QR codes)

**Backend:**
- PHP 7.4+
- MySQL 8.0+
- JWT Authentication
- RESTful API

## 📦 Installation

### Prerequisites
- Flutter SDK (3.1.0 or higher)
- PHP 7.4 or higher
- MySQL 8.0 or higher
- XAMPP/WAMP/MAMP (for local development)

### Flutter App Setup

1. Navigate to the Flutter project:
```bash
cd flutter_mlm_investment
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Backend Setup

1. Copy the backend folder to your web server directory:
```bash
# For XAMPP on Mac
cp -r flutter_mlm_investment_backend /Applications/XAMPP/htdocs/

# For XAMPP on Windows
# Copy to C:\xampp\htdocs\
```

2. Create the database:
```bash
mysql -u root -p
```

```sql
CREATE DATABASE mlm_investment_db;
USE mlm_investment_db;
SOURCE /path/to/flutter_mlm_investment_backend/database/schema.sql;
```

3. Update database credentials in `config/config.php`:
```php
define('DB_HOST', 'localhost');
define('DB_NAME', 'mlm_investment_db');
define('DB_USER', 'root');
define('DB_PASS', 'your_password');
```

4. Update API URL in Flutter app `lib/core/config/api_config.dart`:
```dart
static const String baseUrl = 'http://your-server-ip/flutter_mlm_investment_backend';
```

5. Test the backend:
```
http://localhost/flutter_mlm_investment_backend/index.php?action=test
```

## 🔐 Security Features

- JWT-based authentication
- Encrypted data storage
- SQL injection prevention
- XSS protection
- CORS configuration
- File upload validation
- Rate limiting (to be implemented)

## 📊 Database Schema

The database includes 30+ tables covering:
- User management
- KYC verification
- MLM genealogy
- Dual wallet system
- Investment products
- P&L tracking
- Commission calculations
- Transactions
- Support tickets
- Audit logs

## 🎨 Design System

- **Primary Color:** Purple (#6C63FF)
- **Accent Color:** Pink (#FF6584)
- **Success:** Green (#00C853)
- **Error:** Red (#FF5252)
- **Typography:** Inter (Google Fonts)
- **Border Radius:** 12px
- **Elevation:** Material Design 3

## 📱 Supported Platforms

- ✅ Android
- ✅ iOS
- ⏳ Web (future)

## 🧪 Testing

```bash
# Run Flutter tests
flutter test

# Run Flutter analyzer
flutter analyze

# Check for outdated packages
flutter pub outdated
```

## 📝 Development Roadmap

- [x] Phase 1: Project Foundation
- [ ] Phase 2: Authentication & Onboarding
- [ ] Phase 3: User Dashboard
- [ ] Phase 4: MLM Genealogy
- [ ] Phase 5: Wallet System
- [ ] Phase 6: Investment Management
- [ ] Phase 7: P&L Reporting
- [ ] Phase 8: Commission Engine
- [ ] Phase 9: Product/Package Purchase
- [ ] Phase 10: Reports & Analytics
- [ ] Phase 11: Notifications
- [ ] Phase 12: Admin Panel
- [ ] Phase 13: Support System

## 📄 License

This project is proprietary. All rights reserved.

## 👥 Support

For support, email: support@mlminvestment.com

## ⚖️ Compliance

This application is designed to comply with:
- SEBI guidelines (India)
- RBI regulations
- Income Tax Act
- Prevention of Money Laundering Act (PMLA)
- Information Technology Act

**Note:** Consult with legal experts before deployment in any jurisdiction.

---

**Version:** 1.0.0  
**Last Updated:** November 2025
