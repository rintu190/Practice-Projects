# Setup Instructions for PHP Backend

Since Composer is not installed on your system, you have two options:

## Option 1: Install Composer (Recommended)

1. Install Composer globally:
```bash
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
```

2. Install dependencies:
```bash
cd /Users/machd/Developer/Practice-Projects/Flutter/flutter_food_regional_php_backend
composer install
```

## Option 2: Manual Dependency Installation

If you prefer not to install Composer, you can manually download the required libraries:

### 1. Download firebase/php-jwt

```bash
cd /Users/machd/Developer/Practice-Projects/Flutter/flutter_food_regional_php_backend
mkdir -p vendor/firebase/php-jwt/src
curl -L https://github.com/firebase/php-jwt/archive/refs/tags/v6.10.0.tar.gz | tar xz
cp -r php-jwt-6.10.0/src/* vendor/firebase/php-jwt/src/
rm -rf php-jwt-6.10.0
```

### 2. Download vlucas/phpdotenv

```bash
mkdir -p vendor/vlucas/phpdotenv/src
curl -L https://github.com/vlucas/phpdotenv/archive/refs/tags/v5.6.0.tar.gz | tar xz
cp -r phpdotenv-5.6.0/src/* vendor/vlucas/phpdotenv/src/
rm -rf phpdotenv-5.6.0
```

### 3. Create autoload file

Create `vendor/autoload.php` with the following content:

```php
<?php

spl_autoload_register(function ($class) {
    $prefix = 'Firebase\\JWT\\';
    $base_dir = __DIR__ . '/firebase/php-jwt/src/';
    $len = strlen($prefix);
    if (strncmp($prefix, $class, $len) !== 0) {
        return;
    }
    $relative_class = substr($class, $len);
    $file = $base_dir . str_replace('\\', '/', $relative_class) . '.php';
    if (file_exists($file)) {
        require $file;
    }
});

spl_autoload_register(function ($class) {
    $prefix = 'Dotenv\\';
    $base_dir = __DIR__ . '/vlucas/phpdotenv/src/';
    $len = strlen($prefix);
    if (strncmp($prefix, $class, $len) !== 0) {
        return;
    }
    $relative_class = substr($class, $len);
    $file = $base_dir . str_replace('\\', '/', $relative_class) . '.php';
    if (file_exists($file)) {
        require $file;
    }
});
```

## Running the Server

Once dependencies are installed, start the PHP server:

```bash
cd /Users/machd/Developer/Practice-Projects/Flutter/flutter_food_regional_php_backend
php -S localhost:8000
```

## Testing

Test the health endpoint:

```bash
curl http://localhost:8000/api/health
```

Expected response:
```json
{"status":"ok","message":"Server is running"}
```
