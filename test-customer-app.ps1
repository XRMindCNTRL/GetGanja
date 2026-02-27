# Test Customer App - Install dependencies and build
Write-Host "Installing dependencies for customer-app..." -ForegroundColor Cyan
Set-Location "apps/customer-app"
npm install

if ($LASTEXITCODE -eq 0) {
    Write-Host "Dependencies installed successfully!" -ForegroundColor Green
    
    Write-Host "Building customer-app..." -ForegroundColor Cyan
    npm run build
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Build successful!" -ForegroundColor Green
        Write-Host "Build output is in apps/customer-app/build" -ForegroundColor Yellow
    } else {
        Write-Host "Build failed!" -ForegroundColor Red
    }
} else {
    Write-Host "npm install failed!" -ForegroundColor Red
}

Set-Location "../.."
