# Supermarket ERP - Hosting Guide

This guide explains how to host your Supermarket ERP solution on a **Windows Server** (common for .NET apps) or **Cloud**.

## 📂 Deployment Folder
I have created a `release` folder in your project root containing:
1.  `database_setup.sql` - Run this on your SQL Server.
2.  `api/` - Copy these files to your IIS web folder.

---

## 1. Database Setup (SQL Server)

1.  Log in to your Production SQL Server (e.g., via SSMS).
2.  Create a new empty database named `SupermarketDB`.
3.  Open the `release/database_setup.sql` file I generated.
4.  Execute the script against your new database.

---

## 2. Backend API Setup (IIS on Windows Server)

1.  **Prerequisites**: Install **.NET Core Hosting Bundle** (match your .NET version) on the server.
2.  **Copy Files**: Copy the contents of `release/api` to a folder on your server (e.g., `C:\inetpub\wwwroot\supermarket-api`).
3.  **Configure IIS**:
    *   Create a new Website in IIS.
    *   Point the Physical Path to the folder above.
    *   Set the Application Pool to "No Managed Code".
4.  **Update Connection String**:
    *   Open `appsettings.json` in the server folder.
    *   Change the `"DefaultConnection"` to point to your Production SQL Server (not localhost).

    ```json
    "ConnectionStrings": {
      "DefaultConnection": "Server=YOUR_SERVER_IP;Database=SupermarketDB;User Id=sa;Password=your_password;TrustServerCertificate=True;"
    }
    ```

---

## 3. Frontend App (Flutter)

**IMPORTANT:** Before building, you must update the API URL to point to your new server.

1.  Open `supermarket_flutter_app/lib/core/constants/app_constants.dart`.
2.  Change `localhost` to your server's IP or Domain:
    ```dart
    // CHANGE THIS
    static const String apiBaseUrl = 'http://YOUR_SERVER_IP_OR_DOMAIN/api';
    ```

### To Build for Windows (Admin/POS PC)
Run this terminal command:
```powershell
flutter build windows --release
```
*   **Output**: Go to `supermarket_flutter_app/build/windows/runner/Release`.
*   **Install**: Copy the entire `Release` folder to the client's PC. Create a shortcut to `supermarket_flutter_app.exe`.

### To Build for Android (Manager App)
Run this terminal command:
```powershell
flutter build apk --release
```
*   **Output**: `supermarket_flutter_app/build/app/outputs/flutter-apk/app-release.apk`.
*   **Install**: Send the APK to the phone and install.

---

## 4. Troubleshooting
*   **API 500 Error**: Check `stdoutLogEnabled="true"` in `web.config` on the server and check the `logs` folder.
*   **Flutter Network Error**: Ensure the Windows Firewall on the Server allows traffic on Port 80 (HTTP) or 443 (HTTPS).
