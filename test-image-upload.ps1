# Test Image Upload API Script (PowerShell)
# This script tests the blob storage image upload endpoint

param(
    [string]$ApiUrl = "http://localhost:3001",
    [string]$ProductId = "1",
    [string]$ImagePath = "./test-image.jpg"
)

function Write-Header {
    param([string]$Text)
    Write-Host ""
    Write-Host "===================================" -ForegroundColor Cyan
    Write-Host $Text -ForegroundColor Cyan
    Write-Host "===================================" -ForegroundColor Cyan
    Write-Host ""
}

function Test-ImageUpload {
    Write-Header "Testing Image Upload Endpoint"
    
    Write-Host "API URL: $ApiUrl" -ForegroundColor Yellow
    Write-Host "Product ID: $ProductId" -ForegroundColor Yellow
    Write-Host "Image Path: $ImagePath" -ForegroundColor Yellow
    Write-Host ""
    
    # Create test image if it doesn't exist
    if (-not (Test-Path $ImagePath)) {
        Write-Host "Creating test image..." -ForegroundColor Yellow
        
        # Create a minimal JPEG file
        $jpegHeader = @(0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46, 0x00, 0x01, 0x01, 0x00, 0x00, 0x01, 0x00, 0x01, 0x00, 0x00)
        $jpegData = $jpegHeader + @(0xFF, 0xD9)
        
        [System.IO.File]::WriteAllBytes($ImagePath, $jpegData)
        Write-Host "✅ Test image created: $ImagePath" -ForegroundColor Green
    }
    
    # Test 1: Check server
    Write-Host "Test 1: Checking if server is running..." -ForegroundColor Cyan
    try {
        $null = Invoke-WebRequest -Uri "$ApiUrl/health" -ErrorAction SilentlyContinue
        Write-Host "✅ Server is running" -ForegroundColor Green
    }
    catch {
        Write-Host "⚠️  Warning: Could not reach server at $ApiUrl" -ForegroundColor Yellow
        Write-Host "   Make sure the backend is running: npm run dev" -ForegroundColor Yellow
    }
    
    # Test 2: Upload image
    Write-Host ""
    Write-Host "Test 2: Testing image upload..." -ForegroundColor Cyan
    Write-Host "Uploading image to: POST $ApiUrl/products/$ProductId/upload-image" -ForegroundColor Yellow
    Write-Host ""
    
    try {
        $form = @{
            image = Get-Item -Path $ImagePath
        }
        
        $response = Invoke-WebRequest -Uri "$ApiUrl/products/$ProductId/upload-image" `
            -Method Post `
            -Form $form `
            -ErrorVariable webError
        
        $statusCode = $response.StatusCode
        $body = $response.Content
        
        Write-Host "HTTP Status Code: $statusCode" -ForegroundColor Green
        Write-Host ""
        Write-Host "Response Body:" -ForegroundColor Yellow
        
        try {
            $json = $body | ConvertFrom-Json
            $json | ConvertTo-Json | Write-Host
        }
        catch {
            Write-Host $body
        }
        
        Write-Host ""
        
        if ($statusCode -eq 200) {
            Write-Host "✅ Upload successful!" -ForegroundColor Green
            Write-Host ""
            Write-Host "Extracted fields:" -ForegroundColor Cyan
            try {
                $json = $body | ConvertFrom-Json
                Write-Host "  - Image URL: $($json.imageUrl)" -ForegroundColor Gray
                Write-Host "  - Upload Time: $($json.uploadedAt)" -ForegroundColor Gray
                Write-Host ""
                Write-Host "Test with SAS URL:" -ForegroundColor Cyan
                
                if ($json.imageUrl) {
                    Write-Host "Verifying SAS URL is accessible..." -ForegroundColor Yellow
                    try {
                        $testResponse = Invoke-WebRequest -Uri $json.imageUrl -Method Head -ErrorAction SilentlyContinue
                        Write-Host "✅ SAS URL is accessible!" -ForegroundColor Green
                    }
                    catch {
                        Write-Host "⚠️  Warning: SAS URL may not be accessible yet" -ForegroundColor Yellow
                    }
                }
            }
            catch {
                Write-Host "Could not parse JSON response" -ForegroundColor Yellow
            }
        }
        elseif ($statusCode -eq 400) {
            Write-Host "❌ Client error (400): Check image format and file size" -ForegroundColor Red
        }
        elseif ($statusCode -eq 404) {
            Write-Host "❌ Not found (404): Product $ProductId does not exist" -ForegroundColor Red
        }
        elseif ($statusCode -eq 500) {
            Write-Host "❌ Server error (500): Check Azure Storage configuration" -ForegroundColor Red
        }
    }
    catch {
        $statusCode = $webError[0].Exception.Response.StatusCode.Value__ 
        Write-Host "Error: $($webError[0].Exception.Message)" -ForegroundColor Red
        
        if ($statusCode -eq 400) {
            Write-Host "❌ Client error (400): Check image format and file size" -ForegroundColor Red
        }
        elseif ($statusCode -eq 404) {
            Write-Host "❌ Not found (404): Product $ProductId does not exist" -ForegroundColor Red
        }
        elseif ($statusCode -eq 500) {
            Write-Host "❌ Server error (500): Check Azure Storage configuration" -ForegroundColor Red
        }
    }
    
    Write-Header "Test Complete"
    
    Write-Host "Next Steps:" -ForegroundColor Cyan
    Write-Host "1. Verify the image appears in Azure Blob Storage" -ForegroundColor Gray
    Write-Host "2. Check that Product.imageUrl is updated in database" -ForegroundColor Gray
    Write-Host "3. Verify the SAS URL is valid and image is accessible" -ForegroundColor Gray
    Write-Host ""
}

# Run the test
Test-ImageUpload
