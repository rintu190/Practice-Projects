# Flutter Food Regional - PHP Backend

A RESTful API backend server built with PHP for the Flutter Food Regional application. This backend provides authentication, restaurant browsing, address management, and order processing functionality.

## Features

- ✅ User authentication with JWT tokens
- ✅ Restaurant and menu management
- ✅ User address management
- ✅ Order creation and tracking
- ✅ CORS support for Flutter app
- ✅ MySQL database with PDO
- ✅ Transaction support for orders

## Requirements

- **PHP 7.4+** with the following extensions:
  - PDO
  - PDO_MYSQL
  - JSON
  - mbstring
- **Composer** (for dependency management)
- **MySQL 5.7+** or **MariaDB 10.3+**
- **Apache** or **Nginx** web server

## Installation

### 1. Clone or Copy the Project

```bash
cd /path/to/your/projects
```

### 2. Install Dependencies

```bash
cd flutter_food_regional_php_backend
composer install
```

### 3. Configure Environment

Copy the example environment file and update with your settings:

```bash
cp .env.example .env
```

Edit `.env` and update the following values:

```env
PORT=8000
DB_HOST=localhost
DB_USER=your_database_user
DB_PASSWORD=your_database_password
DB_NAME=flutter_food_regional
JWT_SECRET=your_random_secret_key_here
```

### 4. Set Up Database

Create the database and import the schema:

```bash
mysql -u root -p < database/schema.sql
```

Or manually:

```sql
mysql -u root -p
CREATE DATABASE flutter_food_regional;
USE flutter_food_regional;
SOURCE database/schema.sql;
```

### 5. Run the Server

#### Using PHP Built-in Server (Development)

```bash
php -S localhost:8000
```

#### Using Apache

1. Point your virtual host to the project directory
2. Ensure `mod_rewrite` is enabled
3. The `.htaccess` file will handle routing

#### Using Nginx

Add this configuration to your server block:

```nginx
location / {
    try_files $uri $uri/ /index.php?$query_string;
}

location ~ \.php$ {
    fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
    fastcgi_index index.php;
    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    include fastcgi_params;
}
```

## API Documentation

### Base URL

```
http://localhost:8000/api
```

### Authentication Endpoints

#### Register User

```http
POST /api/auth/register
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123",
  "phone": "1234567890"
}
```

**Response:**
```json
{
  "token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "user": {
    "id": "uuid",
    "name": "John Doe",
    "email": "john@example.com",
    "phone": "1234567890"
  }
}
```

#### Login

```http
POST /api/auth/login
Content-Type: application/json

{
  "email": "john@example.com",
  "password": "password123"
}
```

#### Get Current User

```http
GET /api/auth/me
Authorization: Bearer {token}
```

### Restaurant Endpoints

#### Get All Restaurants

```http
GET /api/restaurants
GET /api/restaurants?cuisine=North
```

#### Get Restaurant Details

```http
GET /api/restaurants/{restaurantId}
```

#### Get Restaurant Menu

```http
GET /api/restaurants/{restaurantId}/menu
```

### Address Endpoints (Requires Authentication)

#### Get User Addresses

```http
GET /api/addresses
Authorization: Bearer {token}
```

#### Create Address

```http
POST /api/addresses
Authorization: Bearer {token}
Content-Type: application/json

{
  "houseNumber": "123",
  "street": "Main Street",
  "locality": "Downtown",
  "city": "Mumbai",
  "state": "Maharashtra",
  "pincode": "400001",
  "landmark": "Near City Mall",
  "latitude": 19.0760,
  "longitude": 72.8777
}
```

#### Delete Address

```http
DELETE /api/addresses/{addressId}
Authorization: Bearer {token}
```

### Order Endpoints (Requires Authentication)

#### Get User Orders

```http
GET /api/orders
Authorization: Bearer {token}
```

#### Get Order Details

```http
GET /api/orders/{orderId}
Authorization: Bearer {token}
```

#### Create Order

```http
POST /api/orders
Authorization: Bearer {token}
Content-Type: application/json

{
  "restaurantId": "uuid",
  "addressId": "uuid",
  "totalAmount": 599.50,
  "items": [
    {
      "menuItemId": "uuid",
      "quantity": 2,
      "price": 299.75
    }
  ]
}
```

### Health Check

```http
GET /api/health
```

## Project Structure

```
flutter_food_regional_php_backend/
├── config/
│   └── Database.php           # PDO database connection class
├── middleware/
│   └── AuthMiddleware.php     # JWT authentication middleware
├── routes/
│   ├── auth.php              # Authentication route handlers
│   ├── restaurants.php       # Restaurant route handlers
│   ├── addresses.php         # Address route handlers
│   └── orders.php            # Order route handlers
├── database/
│   └── schema.sql            # Database schema
├── .htaccess                 # Apache URL rewriting
├── index.php                 # Main application entry point
├── composer.json             # PHP dependencies
├── .env.example              # Environment configuration template
├── .gitignore               # Git ignore rules
└── README.md                # This file
```

## Database Schema

The application uses the following tables:

- **users** - User accounts with authentication
- **restaurants** - Restaurant information
- **menu_items** - Menu items for each restaurant
- **addresses** - User delivery addresses
- **orders** - Order records
- **order_items** - Items in each order

See `database/schema.sql` for the complete schema definition.

## Security

- Passwords are hashed using PHP's `password_hash()` with bcrypt
- JWT tokens expire after 7 days
- Protected routes require valid JWT token in Authorization header
- Database queries use prepared statements to prevent SQL injection
- CORS headers allow cross-origin requests from Flutter app

## Testing

Test the API using curl:

```bash
# Health check
curl http://localhost:8000/api/health

# Register a user
curl -X POST http://localhost:8000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com","password":"password123","phone":"1234567890"}'

# Login
curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'

# Get restaurants
curl http://localhost:8000/api/restaurants

# Get current user (replace TOKEN with actual token)
curl http://localhost:8000/api/auth/me \
  -H "Authorization: Bearer TOKEN"
```

## Troubleshooting

### Apache Authorization Header Not Working

If you're using Apache and the Authorization header is not being passed to PHP, ensure `mod_rewrite` is enabled and the `.htaccess` file is being read.

### CORS Issues

If you encounter CORS errors from your Flutter app, verify:
1. The CORS headers in `index.php` are set correctly
2. Your web server is not overriding these headers
3. The `.htaccess` file (for Apache) includes the CORS configuration

### Database Connection Errors

1. Verify your database credentials in `.env`
2. Ensure the MySQL server is running
3. Check that the database exists and the schema is imported
4. Verify the PHP PDO_MYSQL extension is installed

## License

This project is part of the Flutter Food Regional application.

## Support

For issues or questions, please refer to the main Flutter Food Regional project documentation.
