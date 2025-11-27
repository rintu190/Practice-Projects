# Database Management

This directory contains the database schema and utilities for the Flutter Food Regional application.

## Files

- **`schema.sql`** - Complete database schema with all table definitions
  - Includes all columns: `google_id` for Google Sign-In, `is_veg` for menu items, etc.
  - Use this to create a fresh database from scratch

- **`full_dump.sql`** - Complete database dump with structure and sample data
  - Auto-generated snapshot of the current database state
  - Includes all tables, data, and relationships
  - Last updated: 2025-11-27

- **`data_only.sql`** - Data-only dump (no table creation)
  - Contains only INSERT statements
  - Useful for populating an existing database schema
  - Does not drop or create tables

- **`create_dump.php`** - Utility script to regenerate `full_dump.sql`
  - Creates a fresh dump of your current database
  - Useful when you need to update the dump with new data

## Usage

### Creating a New Database

To set up a fresh database using the schema:

```bash
mysql -u root -p -e "CREATE DATABASE flutter_food_regional;"
mysql -u root -p flutter_food_regional < database/schema.sql
```

### Restoring from Dump

To restore the database with sample data:

```bash
mysql -u root -p flutter_food_regional < database/full_dump.sql
```

Or from within MySQL:

```sql
USE flutter_food_regional;
SOURCE /path/to/database/full_dump.sql;
```

### Creating a Fresh Dump

To create an updated dump of your current database:

```bash
cd /path/to/flutter_food_regional_php_backend
php database/create_dump.php
```

This will update `database/full_dump.sql` with the latest data.

## Database Schema Overview

The database includes the following tables:

- **users** - User accounts (customers, riders, restaurant owners, admins)
- **restaurants** - Restaurant information and details
- **menu_items** - Menu items for each restaurant
- **addresses** - User delivery addresses
- **orders** - Customer orders
- **order_items** - Items within each order
- **payment_methods** - User payment methods
- **commissions** - Commission tracking for orders

## Notes

- The schema includes support for Google Sign-In via the `google_id` column
- Menu items have a `is_veg` flag to indicate vegetarian/non-vegetarian
- All timestamps use `CURRENT_TIMESTAMP` with auto-update
- Foreign keys are properly configured with CASCADE/SET NULL as appropriate
- Database credentials are read from the `.env` file
