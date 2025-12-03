---
description: Start MLM Backend Server
---

1. Open a terminal and navigate to the backend directory.
   ```bash
   cd /Users/machd/Developer/Practice-Projects/Flutter/flutter_mlm_investment_backend
   ```
2. Start the PHP built-in development server on port 8000.
   // turbo
   ```bash
   php -S 0.0.0.0:8000 -t .
   ```
3. The server will now listen for requests at `http://localhost:8000`. You can test it by opening a browser and visiting:
   ```
   http://localhost:8000/?action=test
   ```
   You should receive a JSON response indicating a successful database connection.
4. To stop the server, press `Ctrl+C` in the terminal.
