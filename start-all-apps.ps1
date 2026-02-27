# Start all 4 React apps on different ports
$basePath = "c:/Users/pc/Desktop/cannabis-delivery-platform"

# Customer App on port 3000
Start-Process cmd -ArgumentList "/k", "cd $basePath\apps\customer-app && set PORT=3000 && npm start" -WindowStyle Normal

# Vendor Dashboard on port 3001
Start-Process cmd -ArgumentList "/k", "cd $basePath\apps\vendor-dashboard && set PORT=3001 && npm start" -WindowStyle Normal

# Driver App on port 3002
Start-Process cmd -ArgumentList "/k", "cd $basePath\apps\driver-app && set PORT=3002 && npm start" -WindowStyle Normal

# Admin Panel on port 3003
Start-Process cmd -ArgumentList "/k", "cd $basePath\apps\admin-panel && set PORT=3003 && npm start" -WindowStyle Normal

Write-Host "Starting all apps..."
Write-Host "Customer App: http://localhost:3000"
Write-Host "Vendor Dashboard: http://localhost:3001"
Write-Host "Driver App: http://localhost:3002"
Write-Host "Admin Panel: http://localhost:3003"
Write-Host ""
