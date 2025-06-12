$ErrorActionPreference = 'Stop'

# Package information
$packageName = 'granted'
$version = $env:ChocolateyPackageVersion
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
    
    # Define specific files to install as commands (per PRD requirements)
    $filesToInstall = @{
        "granted.exe"  = "granted";
        "assumego.exe" = "assumego";
        "assume.ps1"   = "assume.ps1";
        "assume.bat"   = "assume.bat";
    }
    
    # Files to explicitly exclude from installation
    $filesToExclude = @("assume")  # assume without extension - avoid conflicts
    
    $anyInstalled = $false
    Write-Host "Installing specific binaries to global PATH..." -ForegroundColor Green

    foreach ($entry in $filesToInstall.GetEnumerator()) {
        $fileName = $entry.Name
        $commandName = $entry.Value

        # Search for the file recursively
        $fileObject = Get-ChildItem -Path $toolsDir -Filter $fileName -Recurse | Select-Object -First 1
        
        if ($fileObject) {
            $fullPath = $fileObject.FullName
            Write-Host "  Installing '$fileName' as global command '$commandName'" -ForegroundColor Cyan
            Write-Host "    Source: $fullPath" -ForegroundColor Gray
            
            # For .exe files, use Install-BinFile to create shims
            if ($fileName.EndsWith('.exe')) {
                Install-BinFile -Name $commandName -Path $fullPath
            }
            # For .bat and .ps1 files, copy directly to chocolatey bin directory for global access
            else {
                $chocoDir = Join-Path $env:ChocolateyInstall "bin"
                $destPath = Join-Path $chocoDir $fileName
                Copy-Item -Path $fullPath -Destination $destPath -Force
                Write-Host "    Copied to: $destPath" -ForegroundColor Gray
            }
            $anyInstalled = $true
        } else {
            Write-Warning "Could not find '$fileName' in the extracted package."
        }
    }
    
    # Verify and warn about excluded files
    foreach ($excludedFile in $filesToExclude) {
        $foundExcluded = Get-ChildItem -Path $toolsDir -Filter $excludedFile -Recurse | Select-Object -First 1
        if ($foundExcluded) {
            Write-Host "  Skipping '$excludedFile' (excluded per PRD to avoid conflicts)" -ForegroundColor Yellow
        }
    }
    
    if ($anyInstalled) {
        Write-Host ""
        Write-Host "Granted CLI and tools have been successfully installed to global PATH!" -ForegroundColor Green
        Write-Host "Available commands globally:" -ForegroundColor Yellow
        Write-Host "  - granted       (main CLI)" -ForegroundColor White
        Write-Host "  - assumego      (backend executable)" -ForegroundColor White  
        Write-Host "  - assume.bat    (CMD/Git Bash wrapper)" -ForegroundColor White
        Write-Host "  - assume.ps1    (PowerShell wrapper)" -ForegroundColor White
        Write-Host ""
        Write-Host "Quick start:" -ForegroundColor Cyan
        Write-Host "  granted --help" -ForegroundColor White
        Write-Host "  granted sso login" -ForegroundColor White
        Write-Host ""
        Write-Host "Note: assume.ps1 requires ExecutionPolicy RemoteSigned or Bypass" -ForegroundColor Yellow
        Write-Host "Documentation: https://docs.commonfate.io/granted/" -ForegroundColor Cyan
    } else {
        throw "Could not find any of the required executables in the package."
    }
} catch {
    Write-Error "Failed to install Granted CLI: $($_.Exception.Message)"
    throw
} 