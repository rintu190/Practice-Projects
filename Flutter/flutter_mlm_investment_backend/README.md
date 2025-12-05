# Flutter MLM Investment - Backend API

RESTful API backend for the Flutter MLM Investment mobile application built with PHP and MySQL.

## Features

- ✅ User Authentication (OTP & Password)
- ✅ JWT Token-based Authorization
- ✅ Investment Management
- ✅ Wallet System (E-Wallet, Investment Wallet, Earnings)
- ✅ MLM Genealogy & Referral System
- ✅ Commission Calculation
- ✅ KYC Document Management
- ✅ Bank Details Management
- ✅ Admin Panel APIs
- ✅ Support Ticket System
- ✅ Automated Profit Calculation
- ✅ Environment-based Configuration

## Tech Stack

- **Language**: PHP 7.4+
- **Database**: MySQL 5.7+
- **Authentication**: JWT
- **SMS**: Twilio / MSG91 / 2Factor (configurable)

## Quick Start

### 1. Clone & Setup
```bash
git clone <your-repo>
cd flutter_mlm_investment_backend
cp .env.example .env
```

### 2. Configure Environment
Edit `.env` with your database credentials:
```env
DB_HOST=127.0.0.1
DB_NAME=flutter_mlm_investment
DB_USER=root
DB_PASS=root
```

### 3. Import Database
```bash
mysql -u root -p flutter_mlm_investment < database/schema.sql
```

### 4. Test API
```
http://localhost/flutter_mlm_investment_backend/?action=test
```

## Project Structure

```
flutter_mlm_investment_backend/
├── config/
│   ├── config.php          # Main configuration (loads from .env)
│   ├── database.php        # Database connection
│   └── env_loader.php      # Environment variable loader
├── routes/
│   ├── auth.php           # Authentication endpoints
│   ├── wallet.php         # Wallet operations
│   ├── investment.php     # Investment management
│   ├── genealogy.php      # MLM tree & referrals
│   ├── admin.php          # Admin operations
│   └── ...
├── utils/
│   ├── jwt.php            # JWT token handling
│   ├── profit_calculator.php
│   └── ...
├── cron/
│   ├── calculate_profits.php
│   └── process_matured.php
├── database/
│   └── schema.sql         # Database schema
├── uploads/               # User uploaded files
├── logs/                  # Application logs
├── .env                   # Environment variables (local)
├── .env.example           # Environment template
├── .env.production.example # Production template
├── index.php              # Main entry point
└── DEPLOYMENT.md          # Deployment guide
```

## API Endpoints

### Authentication
- `POST /?action=send_otp` - Send OTP
- `POST /?action=verify_otp` - Verify OTP
- `POST /?action=login_password` - Password login
- `POST /?action=register` - Register user

### Wallet
- `GET /?action=get_balance` - Get wallet balance
- `GET /?action=get_transactions` - Get transaction history
- `POST /?action=add_funds` - Add funds (deposit)
- `POST /?action=withdraw` - Withdraw funds

### Investment
- `GET /?action=get_products` - Get investment products
- `POST /?action=invest` - Create investment
- `GET /?action=get_my_investments` - Get user investments

### Admin
- `GET /?action=get_users` - Get all users
- `GET /?action=get_pending_approvals` - Get pending items
- `POST /?action=trigger_profit_calculation` - Trigger profit calc

[See full API documentation in DEPLOYMENT.md]

## Environment Variables

Key variables in `.env`:

```env
# Application
APP_ENV=local|production
APP_DEBUG=true|false
APP_URL=http://localhost/api

# Database
DB_HOST=127.0.0.1
DB_NAME=flutter_mlm_investment
DB_USER=root
DB_PASS=password

# JWT
JWT_SECRET_KEY=your-secret-key
JWT_EXPIRY=86400

# OTP Provider
OTP_PROVIDER=test|twilio|msg91|2factor
MSG91_AUTH_KEY=your-key
```

[See `.env.example` for all options]

## Deployment

For production deployment instructions, see [DEPLOYMENT.md](DEPLOYMENT.md)

### Quick Production Checklist
- [ ] Copy `.env.production.example` to `.env`
- [ ] Update database credentials
- [ ] Generate strong JWT secret
- [ ] Configure SMS provider
- [ ] Set `APP_ENV=production` and `APP_DEBUG=false`
- [ ] Enable HTTPS/SSL
- [ ] Set up cron jobs
- [ ] Configure backups

## Security

- JWT-based authentication
- Password hashing (bcrypt)
- SQL injection protection (PDO prepared statements)
- CORS configuration
- Environment-based error handling
- File upload validation

## Development

### Adding New Endpoints

1. Create route handler in `routes/your_module.php`
2. Add action to `index.php` switch case
3. Implement authentication if needed
4. Test with Postman/curl

### Database Changes

1. Update `database/schema.sql`
2. Create migration script if needed
3. Test on local first
4. Backup production before applying

## Cron Jobs

Set up these cron jobs for automated tasks:

```bash
# Daily profit calculation (12:01 AM)
1 0 * * * php /path/to/api/cron/calculate_profits.php

# Process matured investments (12:05 AM)
5 0 * * * php /path/to/api/cron/process_matured.php
```

## Troubleshooting

### Common Issues

**Database connection failed**
- Check `.env` credentials
- Verify MySQL is running
- Test: `mysql -u user -p`

**.env not loading**
- Check file exists: `ls -la .env`
- Check permissions: `chmod 644 .env`

**500 Error**
- Check `logs/php_errors.log`
- Enable debug: `APP_DEBUG=true`
- Check web server error logs

## License

Proprietary - All rights reserved

## Support

For issues and questions, contact: support@yourdomain.com
