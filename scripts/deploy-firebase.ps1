# Сборка веб-версии и публикация на Firebase Hosting + правила Firestore
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot\..

Write-Host "Building Flutter web (release)..." -ForegroundColor Cyan
flutter build web --release
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "Deploying to Firebase (diplomkauniverse)..." -ForegroundColor Cyan
firebase deploy --only "hosting,firestore:rules"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host ""
Write-Host "Done. Open: https://diplomkauniverse.web.app" -ForegroundColor Green
