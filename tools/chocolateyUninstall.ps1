$ErrorActionPreference = 'Stop'

$packageName = 'granted'

try {
    Write-Host "Uninstalling Granted CLI and tools..." -ForegroundColor Yellow
    
    # Remove shims for .exe files (these were installed with Install-BinFile)
    $shimNames = @('granted', 'assumego')
    
    foreach ($shimName in $shimNames) {
        try {
            Uninstall-BinFile -Name $shimName
            Write-Host "  Removed shim: $shimName" -ForegroundColor Green
        } catch {
            Write-Warning "  Could not remove shim '$shimName': $($_.Exception.Message)"
        }
    }
    
    # Remove .bat and .ps1 files that were copied directly to chocolatey bin directory
    $directFiles = @('assume.bat', 'assume.ps1')
    $chocoDir = Join-Path $env:ChocolateyInstall "bin"
    
    foreach ($fileName in $directFiles) {
        $filePath = Join-Path $chocoDir $fileName
        if (Test-Path $filePath) {
            try {
                Remove-Item -Path $filePath -Force
                Write-Host "  Removed file: $fileName" -ForegroundColor Green
            } catch {
                Write-Warning "  Could not remove file '$fileName': $($_.Exception.Message)"
            }
        } else {
            Write-Host "  File not found (already removed): $fileName" -ForegroundColor Gray
        }
    }
    
    Write-Host ""
    Write-Host "Granted CLI and tools have been successfully uninstalled." -ForegroundColor Green
    Write-Host "Removed commands: granted, assumego, assume.bat, assume.ps1" -ForegroundColor Yellow
} catch {
    Write-Warning "Error during uninstallation: $($_.Exception.Message)"
} 