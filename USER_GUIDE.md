# Supermarket Solution - User Guide & Process Walkthrough

This document outlines the complete workflow and features of the Supermarket POS & Management System.

## 1. Authentication (Login)
- **Screen**: Login Screen
- **Process**:
  - Enter your email and password.
  - The system automatically detects your role (`Admin` or `Cashier`) and redirects you to the appropriate dashboard.
- **Default Credentials** (for testing):
  - **Admin**: `admin@freshmart.com` / `admin123`
  - **Cashier**: `cashier@freshmart.com` / `cashier123`

---

## 2. Admin Dashboard (Management Portal)
Designed for store owners and managers to oversee operations.

### A. Dashboard Overview
- **Visuals**: Displays key performance indicators (KPIs) at a glance.
- **Features**:
  - **Total Sales**: Today's revenue.
  - **Total Orders**: Number of transactions today.
  - **Low Stock Alerts**: Warnings for products running out.
  - **Sales Trend Chart**: A graphical view of sales over time.

### B. Inventory Management
- **Screen**: Inventory Screen
- **Features**:
  - **Product List**: View all products with details (Name, Price, Stock, Category).
  - **Search**: Quickly find products by name.
  - **Add Product**: Create new items with images, prices, and stock levels.
  - **Edit/Delete**: Update product details or remove obsolete items.
  - **Category Management**: Create and organize product categories (e.g., Vegetables, Dairy).

### C. Employee Management
- **Screen**: Employee Screen
- **Features**:
  - **Staff List**: View all registered employees.
  - **Add Employee**: Create accounts for new staff members (assigning roles like `Cashier` or `Manager`).
  - **Edit Details**: Update contact info or roles.

### D. Reports & Analytics
- **Screen**: Reports Screen
- **Features**:
  - **Sales Report**: Detailed breakdown of sales by date range.
  - **Inventory Report**: Current stock valuation and low-stock items.
  - **Profit/Loss**: Analyze margins and revenue.
  - **Export**: Ability to view these reports for business decisions.

### E. Receipts & Settings
- **Screen**: Receipt Integration
- **Features**:
  - Configure receipt templates.
  - View generated receipt logs.

---

## 3. Cashier Dashboard (Point of Sale)
Designed for speed and efficiency at the checkout counter.

### A. POS Interface (Main Screen)
- **Layout**: Split screen for maximum efficiency.
  - **Left Side (Product Catalog)**: 
    - Search bar to find items by name or barcode.
    - Grid view of available products with images.
    - "Add to Cart" buttons.
  - **Right Side (Cart)**:
    - Live list of scanned items.
    - Quantity adjusters (+ / -).
    - Remove item button.
    - **Real-time Totals**: Subtotal, Tax, and Grand Total updates instantly.

### B. Checkout Process
- **Screen**: Checkout Screen (Modern UI)
- **Process**:
  1. **Review Cart**: Confirm items with the customer.
  2. **Payment Method**: Select `Cash`, `Card`, or `Online` via large touch buttons.
  3. **Discounts**: Apply percentage discounts if applicable (e.g., 10% off).
  4. **Confirm Payment**: Tap the large green "Confirm Payment" button.
- **Outcome**: A success dialog appears, and a professional **Thermal Receipt** (PDF) is generated for printing or digital sharing.

### C. Order History
- **Screen**: Orders Screen
- **Features**:
  - View past transactions processed by the cashier.
  - Check status of orders.

---

## 4. Technical Features
- **Sidebar Navigation**: A dynamic, collapsible sidebar that shows the logged-in user's name and role (e.g., "Cashier: John Doe") and allows easy navigation between modules.
- **Real-time Updates**: Stock levels decrease immediately after a sale.
- **Data Persistence**: All data is stored securely in the database.
- **Responsive Design**: The app adapts to different screen sizes (Desktop/Tablet).
