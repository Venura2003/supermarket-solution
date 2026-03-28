# One-Click Build & Deploy Script for Vercel
# This PowerShell script builds your Flutter web app, deploys to Vercel, and updates your app with the new deployment URL.

# Step 1: Build Flutter web
flutter build web --no-tree-shake-icons
if ($LASTEXITCODE -ne 0) {
    Write-Error 'Flutter build failed.'
    exit 1
}

# Step 2: Deploy to Vercel and capture the deployment URL
$vercelOutput = vercel --prod --confirm --cwd ./build/web | Tee-Object -Variable vercelLog
if ($LASTEXITCODE -ne 0) {
    Write-Error 'Vercel deployment failed.'
    exit 1
}

# Step 3: Extract the deployment URL from Vercel output
$deploymentUrl = ($vercelLog | Select-String -Pattern 'https://.*\.vercel\.app' | Select-Object -Last 1).Matches.Value
if (-not $deploymentUrl) {
    Write-Error 'Could not find deployment URL in Vercel output.'
    exit 1
}

Write-Host "Deployment URL: $deploymentUrl"

# Step 4: Inject the deployment URL into your app
$env:API_URL = $deploymentUrl
node ./scripts/inject-api-url.js
if ($LASTEXITCODE -ne 0) {
    Write-Error 'Failed to inject API URL.'
    exit 1
}

Write-Host "Build, deploy, and injection complete!"
