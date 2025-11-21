# Flutter Food Regional - Backend API

Node.js + Express + MySQL backend for the Flutter Food Regional app.

## Quick Start

1. Install MySQL and create database
2. Copy `.env.example` to `.env` and configure
3. Run `npm install`
4. Initialize database: `mysql -u username -p < database/schema.sql`
5. Seed data: `mysql -u username -p < database/seed.sql`
6. Start server: `npm run dev`

Server runs on `http://localhost:3000`

## API Documentation

See [Backend Setup Guide](../.gemini/antigravity/brain/c4a05664-12d6-469a-9ab7-82d3a0be9480/backend_setup_guide.md) for complete documentation.

## Project Structure

```
├── config/
│   └── database.js      # MySQL connection pool
├── database/
│   ├── schema.sql       # Database schema
│   └── seed.sql         # Initial data
├── middleware/
│   └── auth.js          # JWT authentication
├── routes/
│   ├── auth.js          # Authentication endpoints
│   ├── restaurants.js   # Restaurant endpoints
│   ├── addresses.js     # Address endpoints
│   └── orders.js        # Order endpoints
├── .env.example         # Environment template
└── server.js            # Main application file
```
