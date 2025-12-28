# Freelance Job Portal App

This is a complete solution containing a Flutter Mobile App and a PHP MySQL Backend.

## Project Structure

- `flutter_freelance_job_portal/`: The Flutter Mobile Application.
- `flutter_freelance_job_portal_backend/`: The PHP Backend API.

## Getting Started

### 1. Backend Setup

1.  **Database Setup**:
    -   Create a new MySQL database named `freelance_job_portal`.
    -   Import the `database/schema.sql` file into your database.
2.  **Configuration**:
    -   Navigate to `flutter_freelance_job_portal_backend/config/config.php`.
    -   Update the database credentials (`DB_USER`, `DB_PASS`) if necessary.
3.  **Run Server**:
    -   You can run the PHP server using the built-in command:
        ```bash
        cd flutter_freelance_job_portal_backend
        php -S localhost:8000
        ```
    -   Alternatively, deploy the folder to your XAMPP/MAMP `htdocs` directory.

### 2. Flutter App Setup

1.  **Dependencies**:
    -   Navigate to the app directory:
        ```bash
        cd flutter_freelance_job_portal
        ```
    -   Install dependencies:
        ```bash
        flutter pub get
        ```
2.  **Run App**:
    -   Run on your simulator or device:
        ```bash
        flutter run
        ```

## Features Implemented (Scaffolding)

-   **Backend**: Reference architecture with routing/controllers, Database connection, and Auth scaffolding.
-   **Mobile App**: Modern UI Theme (Light/Dark mode), Splash Screen, and project structure ready for feature implementation.

## Next Steps

1.  Implement the Login/Register screens in Flutter calling the `routes/auth.php` endpoints.
2.  Flesh out the Dashboard for different user types (Freelancer vs Employer).
3.  Implement the Job Posting and Bidding logic.
