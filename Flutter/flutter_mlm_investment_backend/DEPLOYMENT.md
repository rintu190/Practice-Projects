# Deployment Guide - Flutter MLM Investment Backend

## Prerequisites
- PHP 7.4 or higher
- MySQL 5.7 or higher
- Apache/Nginx web server
- Composer (optional, for dependencies)

## Local Development Setup

1. **Clone the repository**
   ```bash
   cd /path/to/your/webserver/root
   git clone <your-repo-url> flutter_mlm_investment_backend
   cd flutter_mlm_investment_backend
   ```

2. **Configure environment**
   ```bash
   cp .env.example .env
   ```
   
3. **Update `.env` with your local database credentials**
   ```
   DB_HOST=127.0.0.1
   DB_NAME=flutter_mlm_investment
   DB_USER=root
   DB_PASS=root
   ```

4. **Import database schema**
   ```bash
   mysql -u root -p flutter_mlm_investment < database/schema.sql
   ```

5. **Set permissions**
   ```bash
   chmod 755 uploads/
   chmod 755 logs/
   ```

6. **Test the API**
   ```
   http://localhost/flutter_mlm_investment_backend/?action=test
   ```

## Production Deployment

### Step 1: Prepare Production Server

1. **Upload files to server**
   - Use FTP/SFTP or Git to upload files
   - Recommended path: `/var/www/html/api/` or `/home/username/public_html/api/`

2. **Create production environment file**
   ```bash
   cp .env.production.example .env
   ```

3. **Configure production `.env`**
   ```bash
   nano .env
   ```
   
   Update the following:
   ```
   APP_ENV=production
   APP_DEBUG=false
   APP_URL=https://yourdomain.com/api
   
   DB_HOST=your-production-db-host
   DB_NAME=your_production_db_name
   DB_USER=your_production_db_user
   DB_PASS=your_strong_password
   
   JWT_SECRET_KEY=<generate-strong-random-key>
   
   # Choose your SMS provider
   OTP_PROVIDER=msg91
   MSG91_AUTH_KEY=your_key
   MSG91_SENDER_ID=your_sender
   MSG91_TEMPLATE_ID=your_template
   ```

4. **Generate JWT Secret Key**
   ```bash
   openssl rand -base64 64
   ```
   Copy the output to `JWT_SECRET_KEY` in `.env`

### Step 2: Database Setup

1. **Create production database**
   ```sql
   CREATE DATABASE flutter_mlm_investment CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
   CREATE USER 'mlm_user'@'localhost' IDENTIFIED BY 'strong_password';
   GRANT ALL PRIVILEGES ON flutter_mlm_investment.* TO 'mlm_user'@'localhost';
   FLUSH PRIVILEGES;
   ```

2. **Import schema**
   ```bash
   mysql -u mlm_user -p flutter_mlm_investment < database/schema.sql
   ```

### Step 3: File Permissions

```bash
# Set correct ownership
chown -R www-data:www-data /var/www/html/api

# Set directory permissions
find /var/www/html/api -type d -exec chmod 755 {} \;

# Set file permissions
find /var/www/html/api -type f -exec chmod 644 {} \;

# Make uploads and logs writable
chmod 775 uploads/
chmod 775 logs/
```

### Step 4: Web Server Configuration

#### Apache (.htaccess)
Create/update `.htaccess` in root:
```apache
RewriteEngine On
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^(.*)$ index.php?action=$1 [QSA,L]

# Security headers
Header set X-Content-Type-Options "nosniff"
Header set X-Frame-Options "SAMEORIGIN"
Header set X-XSS-Protection "1; mode=block"

# Hide .env file
<Files .env>
    Order allow,deny
    Deny from all
</Files>
```

#### Nginx
Add to your server block:
```nginx
location /api {
    try_files $uri $uri/ /index.php?$query_string;
    
    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
    
    location ~ /\.env {
        deny all;
    }
}
```

### Step 5: SSL Certificate (HTTPS)

**Using Let's Encrypt (Free)**:
```bash
sudo apt install certbot python3-certbot-apache
sudo certbot --apache -d yourdomain.com
```

### Step 6: Cron Jobs Setup

Add to crontab for automated profit calculation:
```bash
crontab -e
```

Add:
```
# Calculate daily profits at 12:01 AM
1 0 * * * php /var/www/html/api/cron/calculate_profits.php >> /var/www/html/api/logs/cron.log 2>&1

# Process matured investments at 12:05 AM
5 0 * * * php /var/www/html/api/cron/process_matured.php >> /var/www/html/api/logs/cron.log 2>&1
```

### Step 7: Testing

1. **Test database connection**
   ```
   https://yourdomain.com/api/?action=test
   ```

2. **Test OTP sending** (if configured)
   ```
   POST https://yourdomain.com/api/?action=send_otp
   Body: {"phone": "9876543210", "purpose": "login"}
   ```

## Security Checklist

- [ ] `.env` file is NOT accessible via web
- [ ] `APP_DEBUG=false` in production
- [ ] Strong JWT secret key generated
- [ ] Database user has minimal required permissions
- [ ] HTTPS/SSL enabled
- [ ] CORS configured for your domain only
- [ ] File upload directory is outside web root (or protected)
- [ ] Error logging enabled, display disabled
- [ ] Regular database backups configured
- [ ] Firewall configured (allow only 80, 443, 22)

## Updating Production

```bash
# Backup database first
mysqldump -u mlm_user -p flutter_mlm_investment > backup_$(date +%Y%m%d).sql

# Pull latest code
git pull origin main

# Clear any cache if applicable
rm -rf cache/*

# Test
curl https://yourdomain.com/api/?action=test
```

## Troubleshooting

### .env file not loading
- Check file permissions: `chmod 644 .env`
- Verify file exists: `ls -la .env`
- Check PHP error logs

### Database connection failed
- Verify credentials in `.env`
- Check MySQL is running: `systemctl status mysql`
- Test connection: `mysql -u username -p`

### 500 Internal Server Error
- Check PHP error logs: `tail -f /var/log/apache2/error.log`
- Enable debug temporarily: `APP_DEBUG=true`
- Check file permissions

## Support

For issues, check:
1. `logs/php_errors.log`
2. Web server error logs
3. Database logs

## Environment Variables Reference

See `.env.example` for all available configuration options.
