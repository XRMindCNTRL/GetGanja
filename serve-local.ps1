# Simple HTTP server to serve the built React apps locally
# This allows testing the apps without deploying to Azure

$port = 3000

Write-Host "Starting local server for Customer App..." -ForegroundColor Cyan
Write-Host "URL: http://localhost:$port" -ForegroundColor Yellow
Write-Host ""
Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Gray
Write-Host ""

# Use PowerShell's built-in HTTP listener
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")

try {
    $listener.Start()
    Write-Host "Server is running. Serving files from apps/customer-app/build" -ForegroundColor Green
    
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $requestUrl = $context.Request.Url.LocalPath
        
        # Default to index.html for SPA routing
        if ($requestUrl -eq "/" -or $requestUrl -eq "") {
            $requestUrl = "/index.html"
        }
        
        $filePath = "apps/customer-app/build$requestUrl"
        
        if (Test-Path $filePath) {
            $contentType = "text/html"
            if ($filePath.EndsWith(".js")) { $contentType = "application/javascript" }
            elseif ($filePath.EndsWith(".css")) { $contentType = "text/css" }
            elseif ($filePath.EndsWith(".json")) { $contentType = "application/json" }
            elseif ($filePath.EndsWith(".png")) { $contentType = "image/png" }
            elseif ($filePath.EndsWith(".ico")) { $contentType = "image/x-icon" }
            
            $content = Get-Content $filePath -Raw -Encoding UTF8
            $context.Response.ContentType = $contentType
            $context.Response.Headers.Add("Access-Control-Allow-Origin", "*")
            $buffer = [System.Text.Encoding]::UTF8.GetBytes($content)
            $context.Response.ContentLength64 = $buffer.Length
            $context.Response.OutputStream.Write($buffer, 0, $buffer.Length)
        } else {
            # Return 404
            $context.Response.StatusCode = 404
            $context.Response.ContentType = "text/plain"
            $buffer = [System.Text.Encoding]::UTF8.GetBytes("File not found: $requestUrl")
            $context.Response.OutputStream.Write($buffer, 0, $buffer.Length)
        }
        
        $context.Response.Close()
    }
} finally {
    $listener.Stop()
    $listener.Close()
}
