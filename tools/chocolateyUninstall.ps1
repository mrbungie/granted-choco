$ErrorActionPreference = 'Stop'

$packageName = 'granted'

try {
    # Remove the shim/symlink
    Uninstall-BinFile -Name 'granted'
    
    Write-Host "Granted CLI has been successfully uninstalled." -ForegroundColor Green
} catch {
    Write-Warning "Could not remove Granted CLI shim: $($_.Exception.Message)"
} 