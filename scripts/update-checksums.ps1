# Helper script to update checksums for a new Granted CLI version
# Usage: .\scripts\update-checksums.ps1 -Version "0.38.0"

param(
    [Parameter(Mandatory=$true)]
    [string]$Version
)

$ErrorActionPreference = 'Stop'

# Architecture mappings
$architectures = @{
    'x86_64' = 'x86_64'
    'i386' = 'i386' 
    'arm64' = 'arm64'
}

Write-Host "Updating checksums for Granted CLI v$Version" -ForegroundColor Green
Write-Host ""

$checksums = @{}

foreach ($arch in $architectures.Keys) {
    $fileName = "granted_${Version}_windows_${arch}.zip"
    $url = "https://github.com/fwdcloudsec/granted/releases/download/v$Version/$fileName"
    
    Write-Host "Downloading $fileName..." -ForegroundColor Yellow
    
    try {
        # Download file to temp directory
        $tempFile = Join-Path $env:TEMP $fileName
        Invoke-WebRequest -Uri $url -OutFile $tempFile -ErrorAction Stop
        
        # Calculate SHA256 checksum
        $hash = Get-FileHash -Path $tempFile -Algorithm SHA256
        $checksums[$arch] = $hash.Hash.ToLower()
        
        Write-Host "✅ $arch`: $($checksums[$arch])" -ForegroundColor Green
        
        # Clean up
        Remove-Item $tempFile -Force
        
    } catch {
        Write-Warning "❌ Failed to download $arch version: $($_.Exception.Message)"
        $checksums[$arch] = "FAILED_TO_DOWNLOAD"
    }
}

Write-Host ""
Write-Host "=== CHECKSUMS ===" -ForegroundColor Cyan
foreach ($arch in $architectures.Keys) {
    Write-Host "$arch`: $($checksums[$arch])" -ForegroundColor White
}

Write-Host ""
Write-Host "=== UPDATE INSTALL SCRIPT ===" -ForegroundColor Cyan
Write-Host "Add these checksums to your chocolateyInstall.ps1:" -ForegroundColor Yellow
Write-Host ""

$installScriptUpdate = @"
# Architecture-specific checksums for v$Version
`$checksums = @{
    'x86_64' = '$($checksums['x86_64'])'
    'i386' = '$($checksums['i386'])'
    'arm64' = '$($checksums['arm64'])'
}

# Use in package args:
checksum = `$checksums[`$arch]
"@

Write-Host $installScriptUpdate -ForegroundColor White

Write-Host ""
Write-Host "=== VALIDATION URLs ===" -ForegroundColor Cyan
foreach ($arch in $architectures.Keys) {
    $url = "https://github.com/fwdcloudsec/granted/releases/download/v$Version/granted_${Version}_windows_${arch}.zip"
    Write-Host "$arch`: $url" -ForegroundColor Gray
}

Write-Host ""
Write-Host "Done! 🎉" -ForegroundColor Green 