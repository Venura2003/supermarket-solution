# Azure SQL Database Creation Guide

Since you do not have the Azure CLI installed, you will need to create the database manually using the Azure Portal website. Follow these exact steps.

### **Step 1: Sign In & Start**
1.  Go to [portal.azure.com](https://portal.azure.com).
2.  Sign in with your Microsoft account.
3.  In the search bar at the top, type **"SQL databases"** and select it.
4.  Click the **+ Create** button in the top left.

### **Step 2: Basic Settings**
*   **Subscription**: Select your subscription (e.g., "Azure for Students" or "Pay-As-You-Go").
*   **Resource Group**: Click **Create new**.
    *   Name: `SupermarketRG`
    *   Click **OK**.
*   **Database name**: `SupermarketDB`
*   **Serve**: Click **Create new**.
    *   **Server name**: Choose a unique name (e.g., `supermarket-server-2024`).
    *   **Location**: Pick a region close to you (e.g., `(Asia Pacific) Southeast Asia` or `(US) East US`).
    *   **Authentication method**: Select **Use SQL authentication**.
    *   **Server admin login**: `superadmin`
    *   **Password**: Create a strong password (e.g., `SuperMarket@2024!`). **Write this down!**
    *   Click **OK**.
*   **Want to use SQL elastic pool?**: No.
*   **Workload environment**: Development.
*   **Compute + storage**: Click **Configure database**.
    *   Select **Service tier: Basic** (The cheapest option, ~5 USD/month).
    *   Click **Apply**.
*   Click **Next: Networking >**.

### **Step 3: Networking (CRITICAL)**
*   **Connectivity method**: Select **Public endpoint**.
*   **Firewall rules**:
    *   **Allow Azure services and resources to access this server**: Select **Yes**.
        *   *(This allows Render to connect to your database)*.
    *   **Add current client IP address**: Select **Yes**.
        *   *(This allows YOUR computer to connect so you can create tables)*.
*   Click **Review + create**.

### **Step 4: create**
1.  Review your settings.
2.  Click **Create**.
3.  Wait for the deployment to complete (takes 2-5 minutes).
4.  Click **Go to resource**.

### **Step 5: Get Connection String**
1.  On the database page, click **Connection strings** in the left menu (under Settings).
2.  Click the **ADO.NET** tab.
3.  Copy the entire string. It will look like this:
    ```
    Server=tcp:supermarket-server-2024.database.windows.net,1433;Initial Catalog=SupermarketDB;Persist Security Info=False;User ID=superadmin;Password={your_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;
    ```
4.  **Action**: Paste this into a Notepad file. Replace `{your_password}` with the password you created in Step 2 (remove the curly braces `{}`).

### **Step 6: Initialize Database (Check Table Creation)**
Now that the database is online, you need to create the tables.
1.  Download **Azure Data Studio** (recommended) or use **SSMS**.
2.  Open it and click **New Connection**.
    *   **Server**: `supermarket-server-2024.database.windows.net` (from your connection string).
    *   **Authentication**: SQL Login.
    *   **User**: `superadmin`
    *   **Password**: Your password.
    *   **Database**: `SupermarketDB`.
3.  Click **Connect**.
4.  Open the file `release/database_setup.sql` from your project folder.
5.  Copy the content and paste it into a **New Query** window in Azure Data Studio.
6.  Click **Run**.
7.  Success! Your cloud database now has all the tables.

---
**Next Step:** Proceed to Phase 2 (Backend Deployment) in the main guide.
