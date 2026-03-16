/// IMPORTANT: Ensure this matches your ASP.NET Core backend port in launchSettings.json
/// Example: http://localhost:5053/api
class AppConstants {
  // Point to the locally-running API (updated to port 5000 where the API is listening)
  // Use --dart-define=API_URL=https://your-api.com/api when building for production
  /// For Netlify production, this must match your Render backend URL (with /api)
  /// For local dev, use --dart-define=API_URL=http://localhost:5000/api
  static const String apiBaseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://supermarket-api-2lx7.onrender.com/api',
  );
}
