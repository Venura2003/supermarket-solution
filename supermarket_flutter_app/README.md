# supermarket_flutter_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)



## Production Deployment (Netlify + Render)

1. **Set API URL for Netlify**
	- In `lib/core/constants/app_constants.dart`, set `apiBaseUrl` to your Render backend URL (ending with `/api`).
	- Example: `https://supermarket-api-2lx7.onrender.com/api`
	- You can also use `--dart-define=API_URL=...` for custom builds.

2. **Build for Web**
	- Run:
	  ```sh
	  flutter build web --release
	  ```

3. **Deploy to Netlify**
	- Upload the `build/web` folder to Netlify.

4. **Backend (Render) Setup**
	- Set environment variables:
	  - `ConnectionStrings__DefaultConnection` (Azure SQL connection string)
	  - `JwtSettings__SecretKey` (long, random string)
	- Ensure CORS allows your Netlify frontend URL.

5. **Login Troubleshooting**
	- The login identifier (email or username) is always sent in the `email` field.
	- Backend must accept this for both email and username logins.

## 🌐 Live Demo

You can access the deployed Flutter web app here:

[https://supermarket-solution.vercel.app/](https://supermarket-solution.vercel.app/)
