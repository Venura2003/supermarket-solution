# Receipt Integration: Backend & Flutter

Summary
- Backend: added pragmatic fallbacks to handle schema mismatches for `Employees` and a resilient checkout flow that always generates a receipt PDF.
- Frontend: `CheckoutScreen` now reads `ApiResponse.data.receiptPath` and downloads the receipt via `ApiService.downloadReceipt`.

Key backend changes
- `SaleService.GenerateReceiptAsync(int saleId)`
  - Generates a PDF into `Receipts/receipt_{SaleNo}.pdf` and returns a relative URL: `/sales/receipts/{fileName}`.
- `SalesController`
  - `GET /api/sales/test-checkout` — dev helper: creates a minimal sale (product id 10) and returns `data.receiptPath`.
  - `GET /api/sales/receipts/{fileName}` — serves generated PDF files from the `Receipts` folder.
- Employee workarounds
  - Controllers and `EmployeeService` use parameterized raw-SQL fallback to insert or resolve minimal `Employees` when EF fails due to missing columns.

Frontend changes
- `supermarket_flutter_app/lib/screens/checkout_screen.dart`
  - Parses backend `ApiResponse` wrapper and extracts `data.receiptPath`.
  - Shows a receipt dialog that calls `ApiService.downloadReceipt(receiptPath, filename)` and previews via `open_file`.
- `supermarket_flutter_app/lib/core/services/api_service.dart`
  - `checkout` and `downloadReceipt` helpers used by the screen.

How to run and verify locally
1. Start the API (from repo root):
```powershell
dotnet clean "e:\Flutter apps\SupermarketSolution\SupermarketAPI\SupermarketAPI.csproj"
dotnet build "e:\Flutter apps\SupermarketSolution\SupermarketAPI\SupermarketAPI.csproj" -v minimal
dotnet run --project "e:\Flutter apps\SupermarketSolution\SupermarketAPI\SupermarketAPI.csproj" --no-launch-profile --urls "http://localhost:5000"
```
2. Smoke test endpoints:
```powershell
curl "http://localhost:5000/api/products"
curl "http://localhost:5000/api/sales/test-checkout"
# should return JSON with data.receiptPath, e.g. "/sales/receipts/receipt_SAL-...pdf"
```
3. Download receipt to verify endpoint:
```powershell
curl "http://localhost:5000/api/sales/receipts/receipt_SAL-...pdf" -o downloaded_receipt.pdf
```
4. Run Flutter (Windows desktop):
```powershell
cd "e:\Flutter apps\SupermarketSolution\supermarket_flutter_app"
flutter pub get
flutter run -d windows
```
5. In the app: add items to cart, go to Checkout, complete checkout. The receipt dialog should appear and the PDF should preview.

Security & hardening notes
- The `receipts/{fileName}` endpoint is intentionally permissive for dev/test only. For production:
  - Authenticate/authorize access to receipts.
  - Validate and sanitize `fileName` (avoid path traversal).
  - Consider storing receipts in a protected blob storage and return pre-signed URLs.

Troubleshooting
- MSB3027 (apphost.exe locked): kill any running `SupermarketAPI.exe` before build:
```powershell
taskkill /F /IM SupermarketAPI.exe
```
- If Flutter run complains about missing `pubspec.yaml`, ensure you're in `supermarket_flutter_app` folder.

Contact
- If something fails during your local run, copy the terminal output and paste it into the issue thread; I can diagnose further.
