# Close any processes that might be using the build folder
# Then rebuild

$buildPath = "c:/Users/pc/Desktop/cannabis-delivery-platform/apps/customer-app/build"

# Try to rename the build folder instead of deleting
if (Test-Path $buildPath) {
    $newPath = "c:/Users/pc/Desktop/cannabis-delivery-platform/apps/customer-app/build-old"
    
    # Remove old backup if exists
    if (Test-Path $newPath) {
        Remove-Item -Recurse -Force $newPath -ErrorAction SilentlyContinue
    }
    
    # Try to rename
    try {
        Rename-Item -Path $buildPath -NewName "build-old" -Force
        Write-Host "Renamed build folder to build-old"
    } catch {
        Write-Host "Could not rename build folder. It may be in use by another process."
        Write-Host "Please close any applications using this folder (e.g., File Explorer, VS Code, SWA emulator)"
        exit 1
    }
}

# Now rebuild
cd c:/Users/pc/Desktop/cannabis-delivery-platform/apps/customer-app
npx react-scripts build
