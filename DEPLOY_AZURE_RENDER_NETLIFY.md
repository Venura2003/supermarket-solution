# Full Stack Deployment Guide (Flutter Web + .NET API + Azure SQL)

This guide walks you through deploying your Supermarket Solution to the cloud using **Netlify** (Frontend), **Render** (Backend), and **Azure SQL** (Database).

---

## **Phase 1: Database Setup (Azure SQL)**

1.  **Create Azure SQL Database**
    *   Go to [Azure Portal](https://portal.azure.com).
    *   Search for **SQL Databases** -> **Create**.
    *   **Resource Group**: Create new (e.g., `SupermarketRG`).
    *   **Database Name**: `SupermarketDB`.
    *   **Server**: Create new.
        *   **Authentication**: Use SQL Authentication.
        *   **Admin Login**: `superadmin` (or your choice).
        *   **Password**: Strong password (Save this!).
    *   **Networking**:
        *   **Connectivity method**: Public endpoint.
        *   **Allow Azure services and resources to access this server**: **YES** (Crucial for Render connection).
        *   **Add current client IP address**: **YES** (So you can connect from your PC).
    *   Review + Create.

2.  **Get Connection String**
    *   Once created, go to the database resource page.
    *   Click **Connection strings** on the left menu.
    *   Copy the string under **ADO.NET**. It looks like:
        ```
        Server=tcp:your-server.database.windows.net,1433;Initial Catalog=SupermarketDB;Persist Security Info=False;User ID={your_username};Password={your_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;
        ```
    *   **Important**: Replace `{your_password}` with the actual password you set.

3.  **Deploy Database Schema**
    *   Use **Azure Data Studio** or **SSMS** to connect to the server URL (e.g., `your-server.database.windows.net`) with your admin credentials.
    *   Open `release/database_setup.sql` in the editor.
    *   Run the script to create tables in the cloud database.

---

## **Phase 2: Backend Deployment (Render)**

1.  **Push Code to GitHub**
    *   Open your terminal in `E:\Flutter apps\SupermarketSolution`.
    *   Run these commands:
        ```powershell
        git init
        git add .
        git commit -m "Prepare for deployment"
        # ⚠️ Create a repo on GitHub first! Then replace URL below:
        git remote add origin https://github.com/YOUR_USERNAME/SupermarketSolution.git
        git push -u origin master
        ```

2.  **Create Service on Render**
    *   Go to [Dashboard.render.com](https://dashboard.render.com).
    *   Click **New +** -> **Web Service**.
    *   Connect your GitHub repository.
    *   **Settings**:
        *   **Name**: `supermarket-api`
        *   **Runtime**: **.NET**
        *   **Build Command**: `dotnet publish SupermarketAPI/SupermarketAPI.csproj -c Release -o out`
        *   **Start Command**: `dotnet out/SupermarketAPI.dll`
    *   **Environment Variables** (Click "Advanced"):
        *   Key: `ConnectionStrings__DefaultConnection`
        *   Value: (Paste your Azure SQL Connection String here)
        *   Key: `ASPNETCORE_ENVIRONMENT`
        *   Value: `Production`

3.  **Get API URL**
    *   Wait for the deployment to finish (Green checkmark).
    *   Copy the URL (e.g., `https://supermarket-api.onrender.com`).

---

## **Phase 3: Frontend Deployment (Netlify)**

1.  **Update API URL**
    *   Open `supermarket_flutter_app/lib/core/constants/app_constants.dart`.
    *   Change `apiBaseUrl` to your new Render URL:
        ```dart
        class AppConstants {
          static const String apiBaseUrl = 'https://supermarket-api.onrender.com/api';
        }
        ```

2.  **Build Flutter Web App**
    *   Open terminal in `E:\Flutter apps\SupermarketSolution`.
    *   Run the build script I created for you:
        ```powershell
        .\scripts\build_deployment.ps1
        ```
    *   This will create a `release/frontend_web` folder and a `release/frontend_web.zip` file.

3.  **Deploy to Netlify**
    *   Go to [app.netlify.com](https://app.netlify.com).
    *   Log in -> **Add new site** -> **Deploy manually**.
    *   **Drag and Drop** the `release/frontend_web` folder (or the ZIP file) into the upload area.
    *   Wait a few seconds. Your site is live!

---

## **Phase 4: Common Issues & Fixes**

### 1. CORS Errors (Frontend can't fetch data)
*   **Error**: `Access-Control-Allow-Origin` missing.
*   **Fix**: I have already added `builder.Services.AddCors(...)` to `Program.cs`. Ensure you redeploy the backend after any changes to `Program.cs`.

### 2. Database Connection Failed (500 Error)
*   **Error**: API returns 500 or "Login failed for user".
*   **Fix**:
    *   Check the Connection String in Render Environment Variables.
    *   Ensure the password is correct (no `{}` brackets!).
    *   Ensure **Allow Azure services** is enabled in Azure SQL Networking.

### 3. Flutter "Page Not Found" on Refresh
*   **Error**: Refreshing a specific page gives 404.
*   **Fix**: I have already created a `_redirects` file in `web/` which handles this for Netlify. Ensure it exists in your build folder (the script handles this).

---

**Summary of URLs:**
*   **Frontend**: `https://your-site-name.netlify.app`
*   **Backend**: `https://supermarket-api.onrender.com`
*   **Database**: Azure SQL Server
