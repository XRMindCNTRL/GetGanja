# Kill any processes using the build folder
Get-Process | Where-Object {$_.Path -like "*customer-app*"} | Stop-Process -Force -ErrorAction SilentlyContinue

# Wait a moment
Start-Sleep -Seconds 2

# Remove build folder
Remove-Item -Recurse -Force "c:/Users/pc/Desktop/cannabis-delivery-platform/apps/customer-app/build" -ErrorAction SilentlyContinue

# Build the app
cd c:/Users/pc/Desktop/cannabis-delivery-platform/apps/customer-app
npx react-scripts build
