$ErrorActionPreference = 'Stop'

# Package information
$packageName = 'granted'
$version = '0.38.0'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

# Architecture detection
$architecture = $env:PROCESSOR_ARCHITECTURE
$arch = switch ($architecture) {
    'AMD64' { 'x86_64' }
    'x86' { 'i386' }
    'ARM64' { 'arm64' }
    default { 
        Write-Warning "Unknown architecture: $architecture. Defaulting to x86_64"
        'x86_64' 
    }
}

Write-Host "Detected architecture: $architecture -> $arch" -ForegroundColor Green

# Download URL construction
$baseUrl = "https://github.com/fwdcloudsec/granted/releases/download"
$fileName = "granted_${version}_windows_${arch}.zip"
$url = "$baseUrl/v$version/$fileName"

Write-Host "Download URL: $url" -ForegroundColor Cyan

# Package parameters for Install-ChocolateyZipPackage
$packageArgs = @{
    packageName   = $packageName
    unzipLocation = $toolsDir
    url           = $url
    checksum      = ''  # Will be updated by automation or manual verification
    checksumType  = 'sha256'
}

# Download and extract
try {
    Install-ChocolateyZipPackage @packageArgs
    
    # Find the extracted executable
    $exePath = Get-ChildItem -Path $toolsDir -Name "granted.exe" -Recurse | Select-Object -First 1
    
    if ($exePath) {
        $fullExePath = Join-Path $toolsDir $exePath
        Write-Host "Granted CLI extracted to: $fullExePath" -ForegroundColor Green
        
        # Create shim for global access
        Install-BinFile -Name 'granted' -Path $fullExePath
        
        Write-Host ""
        Write-Host "Granted CLI has been successfully installed!" -ForegroundColor Green
        Write-Host "You can now use 'granted' from any command prompt." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Quick start:" -ForegroundColor Cyan
        Write-Host "  granted --help" -ForegroundColor White
        Write-Host "  granted sso login" -ForegroundColor White
        Write-Host ""
        Write-Host "Documentation: https://docs.commonfate.io/granted/" -ForegroundColor Cyan
    } else {
        throw "Could not find granted.exe in the extracted files"
    }
} catch {
    Write-Error "Failed to install Granted CLI: $($_.Exception.Message)"
    throw
} 