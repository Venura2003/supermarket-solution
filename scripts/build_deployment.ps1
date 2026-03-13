# Setup Release Directory
$ErrorActionPreference = "Stop"
$Root = $PSScriptRoot + "\.."
$ReleaseDir = "$Root\release"

Write-Host "🚧 Cleaning previous build artifacts..." -ForegroundColor Yellow
if (Test-Path $ReleaseDir) { Remove-Item $ReleaseDir -Recurse -Force }
New-Item -ItemType Directory -Path "$ReleaseDir\backend" | Out-Null
New-Item -ItemType Directory -Path "$ReleaseDir\frontend_web" | Out-Null

# ----------------------------------------------------
# 1. Build .NET Backend (API)
# ----------------------------------------------------
Write-Host "`n🚀 Building .NET Backend for Production..." -ForegroundColor Cyan
Set-Location "$Root\SupermarketAPI"
dotnet publish -c Release -o "$ReleaseDir\backend"

if ($LASTEXITCODE -ne 0) {
    Write-Error "❌ Backend Build Failed!"
} else {
    Write-Host "✅ Backend Build Successful! Output in release\backend" -ForegroundColor Green
}

# ----------------------------------------------------
# 2. Build Flutter Frontend (Web)
# ----------------------------------------------------
Write-Host "`n🌐 Building Flutter Web App for Production..." -ForegroundColor Cyan
Set-Location "$Root\supermarket_flutter_app"
flutter build web --release --web-renderer canvaskit

if ($LASTEXITCODE -ne 0) {
    Write-Error "❌ Frontend Build Failed!"
} else {
    # Copy build output to release folder
    Copy-Item "build\web\*" "$ReleaseDir\frontend_web" -Recurse
    Write-Host "✅ Frontend Web Build Successful! Output in release\frontend_web" -ForegroundColor Green
}

# ----------------------------------------------------
# 3. Zipping for Manual Upload (Optional but helpful)
# ----------------------------------------------------
Write-Host "`n📦 Zipping Frontend for Netlify manual deploy..." -ForegroundColor Cyan
Compress-Archive -Path "$ReleaseDir\frontend_web\*" -DestinationPath "$ReleaseDir\frontend_web.zip" -Force
Write-Host "✅ Created frontend_web.zip ready for drag-and-drop to Netlify!" -ForegroundColor Green

Set-Location $Root
Write-Host "`n🎉 Build Process Complete!" -ForegroundColor Green
Write-Host "📂 API Files: $ReleaseDir\backend"
Write-Host "📂 Web Files: $ReleaseDir\frontend_web"