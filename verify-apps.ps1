#!/usr/bin/env powershell
<#
.SYNOPSIS
Verifies all 4 Cannabis Delivery Platform apps are deployed and accessible
.DESCRIPTION
Tests each app URL, checks response codes, and provides detailed status
.EXAMPLE
./verify-apps.ps1
#>

$ErrorActionPreference = "Continue"
$WarningPreference = "SilentlyContinue"

# Define apps
$apps = @(
    @{
        name = "Customer App"
        url = "https://orange-mud-083f9ac0f.4.azurestaticapps.net"
        resourceName = "orange-mud-083f9ac0f"
        expectedContent = @("home", "product", "login", "register", "app", "root")
    },
    @{
        name = "Vendor Dashboard"
        url = "https://gentle-grass-00bb9010f.1.azurestaticapps.net"
        resourceName = "gentle-grass-00bb9010f"
        expectedContent = @("vendor", "dashboard", "app", "root", "inventory")
    },
    @{
        name = "Driver App"
        url = "https://red-mud-0b72f350f.2.azurestaticapps.net"
        resourceName = "red-mud-0b72f350f"
        expectedContent = @("driver", "delivery", "app", "root", "tracking")
    },
    @{
        name = "Admin Panel"
        url = "https://kind-stone-01c35960f.1.azurestaticapps.net"
        resourceName = "kind-stone-01c35960f"
        expectedContent = @("admin", "app", "root", "manage")
    }
)

# API
$api = @{
    name = "Backend API"
    url = "https://getganja.azurewebsites.net/health"
}

# Colors
$colors = @{
    header = "Cyan"
    success = "Green"
    warning = "Yellow"
    error = "Red"
    info = "White"
}

Write-Host ""
Write-Host "===============================================" -ForegroundColor $colors.header
Write-Host "  Cannabis Delivery Platform - App Verification" -ForegroundColor $colors.header
Write-Host "  $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor $colors.header
Write-Host "===============================================" -ForegroundColor $colors.header
Write-Host ""

$results = @()
$passCount = 0
$failCount = 0

# Test each app
foreach ($app in $apps) {
    Write-Host "Testing: $($app.name)" -ForegroundColor $colors.info
    Write-Host "  URL: $($app.url)" -ForegroundColor $colors.info
    
    $testResult = @{
        name = $app.name
        url = $app.url
        statusCode = $null
        accessible = $false
        hasContent = $false
        error = $null
    }
    
    try {
        $response = Invoke-WebRequest -Uri $app.url -UseBasicParsing -TimeoutSec 15 -ErrorAction Stop
        $testResult.statusCode = $response.StatusCode
        $testResult.accessible = $true
        
        # Check for expected content
        $content = $response.Content.ToLower()
        $hasExpectedContent = $false
        
        foreach ($expected in $app.expectedContent) {
            if ($content -like "*$expected*") {
                $hasExpectedContent = $true
                break
            }
        }
        
        $testResult.hasContent = $hasExpectedContent
        
        if ($response.StatusCode -eq 200) {
            Write-Host "  Status: ✓ OK ($($response.StatusCode))" -ForegroundColor $colors.success
            
            if ($hasExpectedContent) {
                Write-Host "  Content: ✓ Valid HTML content" -ForegroundColor $colors.success
                $passCount++
            } else {
                Write-Host "  Content: ⚠ HTML present but content may be empty" -ForegroundColor $colors.warning
                $passCount++
            }
        } else {
            Write-Host "  Status: ⚠ Unexpected status code: $($response.StatusCode)" -ForegroundColor $colors.warning
            $failCount++
        }
    } catch {
        $testResult.error = $_.Exception.Message
        Write-Host "  Status: ❌ FAILED" -ForegroundColor $colors.error
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor $colors.error
        $failCount++
    }
    
    $results += $testResult
    Write-Host ""
}

# Test backend API
Write-Host "Testing: $($api.name)" -ForegroundColor $colors.info
Write-Host "  URL: $($api.url)" -ForegroundColor $colors.info

try {
    $response = Invoke-WebRequest -Uri $api.url -UseBasicParsing -TimeoutSec 15 -ErrorAction Stop
    if ($response.StatusCode -eq 200) {
        Write-Host "  Status: ✓ OK ($($response.StatusCode))" -ForegroundColor $colors.success
        Write-Host "  Response: Backend is healthy" -ForegroundColor $colors.success
        $passCount++
    } else {
        Write-Host "  Status: ⚠ Unexpected status code: $($response.StatusCode)" -ForegroundColor $colors.warning
        $failCount++
    }
} catch {
    Write-Host "  Status: ❌ FAILED" -ForegroundColor $colors.error
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor $colors.error
    $failCount++
}

Write-Host ""
Write-Host "===============================================" -ForegroundColor $colors.header
Write-Host "  SUMMARY" -ForegroundColor $colors.header
Write-Host "===============================================" -ForegroundColor $colors.header
Write-Host ""
Write-Host "Total Tests: $($passCount + $failCount)" -ForegroundColor $colors.info
Write-Host "Passed: $passCount" -ForegroundColor $colors.success
Write-Host "Failed: $failCount" -ForegroundColor $colors.error
Write-Host ""

# Overall status
if ($failCount -eq 0) {
    Write-Host "✓ ALL APPS ARE ACCESSIBLE AND CONFIGURED CORRECTLY!" -ForegroundColor $colors.success
    Write-Host ""
    Write-Host "Next Steps:" -ForegroundColor $colors.header
    Write-Host "  1. Open each app in a browser to verify UI displays correctly"
    Write-Host "  2. Test user registration and login flows"
    Write-Host "  3. Verify API connectivity from each app"
    Write-Host "  4. Check browser console (F12) for any JavaScript errors"
    Write-Host "  5. Verify Firebase and Stripe integration"
    Write-Host ""
} else {
    Write-Host "⚠ SOME APPS NEED ATTENTION" -ForegroundColor $colors.warning
    Write-Host ""
    Write-Host "Failed Apps:" -ForegroundColor $colors.header
    foreach ($result in $results) {
        if (-not $result.accessible) {
            Write-Host "  - $($result.name): $($result.error)" -ForegroundColor $colors.error
        }
    }
    Write-Host ""
    Write-Host "Troubleshooting:" -ForegroundColor $colors.header
    Write-Host "  1. Check GitHub Actions workflows for build/deployment errors"
    Write-Host "  2. Verify environment variables in Azure Static Web Apps settings"
    Write-Host "  3. Check if apps have been built and deployed to build/ folders"
    Write-Host "  4. Review 'VERIFY-APPS.md' for detailed troubleshooting steps"
    Write-Host ""
}

Write-Host "===============================================" -ForegroundColor $colors.header
Write-Host ""
