# Deployment Guide for Flutter Food Regional PHP Backend

## 📦 Package Information

**File**: `flutter_food_regional_php_backend.zip`  
**Size**: 47 KB  
**Location**: `/Users/machd/Developer/Practice-Projects/Flutter/flutter_food_regional_php_backend/`

## 📋 What's Included

✅ **Application Files**:
- All PHP route files (`routes/`)
- Configuration files (`config/`)
- Middleware (`middleware/`)
- Main entry point (`index.php`)
- Helper functions (`helpers.php`)
- Composer dependencies (`vendor/`)

✅ **Database Files**:
- `database/schema.sql` - Complete database schema
- `database/full_dump.sql` - Database with sample data
- `database/README.md` - Database documentation

✅ **Configuration**:
- `.env.example` - Environment variables template
- `.htaccess` - Apache rewrite rules
- `composer.json` - PHP dependencies

✅ **Documentation**:
- `README.md` - Application documentation
- `SETUP.md` - Setup instructions

## 🚫 Excluded (Not in ZIP)

- `.env` file (contains sensitive credentials - create new on server)
- `logs/` directory (will be created on server)
- `uploads/` directory (will be created on server)
- `.git/` directory (version control)
- `database/create_dump.php` (development utility)

## 🚀 Deployment Steps

### 1. Upload to Server

Upload `flutter_food_regional_php_backend.zip` to your server via:
- FTP/SFTP
- cPanel File Manager
- SSH/SCP

### 2. Extract Files

```bash
# Via SSH
unzip flutter_food_regional_php_backend.zip -d /path/to/public_html/

# Or use cPanel's Extract feature
```

### 3. Set Up Environment Variables

```bash
# Copy the example file
cp .env.example .env

# Edit with your server's database credentials
nano .env
```

Update these values in `.env`:
```env
DB_HOST=localhost
DB_USER=your_db_user
DB_PASSWORD=your_db_password
DB_NAME=flutter_food_regional
JWT_SECRET=your_secure_random_secret_key_here
```

### 4. Create Database

```bash
# Create the database
mysql -u your_user -p -e "CREATE DATABASE flutter_food_regional;"

# Import the schema
mysql -u your_user -p flutter_food_regional < database/schema.sql

# OR import with sample data
mysql -u your_user -p flutter_food_regional < database/full_dump.sql
```

### 5. Set Permissions

```bash
# Create required directories
mkdir -p logs uploads

# Set proper permissions
chmod 755 logs uploads
chmod 644 .env
chmod 644 .htaccess
```

### 6. Configure Apache (if needed)

Ensure Apache has:
- `mod_rewrite` enabled
- `AllowOverride All` in your virtual host config

### 7. Test the API

Visit your domain to test:
```
https://yourdomain.com/api/
```

You should see a JSON response indicating the API is running.

## 🔒 Security Checklist

- [ ] `.env` file is created with secure credentials
- [ ] JWT_SECRET is a strong random string
- [ ] Database user has appropriate permissions (not root)
- [ ] `logs/` and `uploads/` directories exist with proper permissions
- [ ] `.htaccess` is working (test URL rewriting)
- [ ] HTTPS is enabled on your domain
- [ ] File permissions are set correctly (644 for files, 755 for directories)

## 🧪 Testing Endpoints

Test these endpoints to verify deployment:

```bash
# Health check
curl https://yourdomain.com/api/

# Get restaurants
curl https://yourdomain.com/api/restaurants

# Register a user
curl -X POST https://yourdomain.com/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com","password":"password123"}'
```

## 📝 Post-Deployment

1. **Update Flutter App**: Update the API base URL in your Flutter app to point to your server
2. **Monitor Logs**: Check `logs/` directory for any errors
3. **Backup**: Set up regular database backups
4. **SSL**: Ensure HTTPS is properly configured

## 🆘 Troubleshooting

### 500 Internal Server Error
- Check Apache error logs
- Verify `.htaccess` is being read
- Ensure `mod_rewrite` is enabled

### Database Connection Failed
- Verify `.env` credentials
- Check database user permissions
- Ensure MySQL is running

### 404 Not Found
- Check `.htaccess` file exists
- Verify `AllowOverride All` in Apache config
- Ensure `mod_rewrite` is enabled

## 📞 Support

For issues, check:
- `README.md` - General documentation
- `SETUP.md` - Setup instructions
- `database/README.md` - Database documentation

---

**Ready to deploy!** 🚀
