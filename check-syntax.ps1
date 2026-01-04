$errors = $null
$ast = [System.Management.Automation.Language.Parser]::ParseFile('setup-production.ps1', [ref]$null, [ref]$errors)
if ($errors.Count -eq 0) {
    Write-Host 'Syntax OK'
} else {
    Write-Host 'Syntax Errors:'
    $errors | ForEach-Object { Write-Host $_.Message }
}
