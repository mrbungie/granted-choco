# Test script for local development and testing of the Chocolatey package
# Usage: .\scripts\test-package.ps1

param(
    [string]$Version = "0.38.0",
    [switch]$SkipBuild,
    [switch]$SkipInstall,
    [switch]$SkipTest,
    [switch]$Cleanup
)

$ErrorActionPreference = 'Stop'

# Check if running as administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if (-not $isAdmin) {
    Write-Warning "This script should be run as Administrator for proper Chocolatey package testing."
    Write-Host "Right-click PowerShell and select 'Run as Administrator', then try again." -ForegroundColor Yellow
    Read-Host "Press Enter to continue anyway (may fail) or Ctrl+C to exit"
}

$originalLocation = Get-Location
$rootDir = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

try {
    Set-Location $rootDir
    
    Write-Host "Testing Chocolatey Package for Granted CLI" -ForegroundColor Green
    Write-Host "================================================" -ForegroundColor Green
    Write-Host "Version: $Version"
    Write-Host "Root Directory: $rootDir"
    Write-Host ""

    # Check if granted is already installed
    if (-not $SkipInstall) {
        $existingInstall = choco list granted --local-only --exact 2>$null
        if ($existingInstall -match "granted") {
            Write-Warning "ATTENTION: Granted CLI is already installed on this system!"
            Write-Host ""
            Write-Host "Current installation details:" -ForegroundColor Yellow
            choco list granted --local-only --exact
            Write-Host ""
            Write-Host "This test will UNINSTALL your existing Granted CLI installation" -ForegroundColor Red
            Write-Host "and replace it temporarily with the test version." -ForegroundColor Red
            Write-Host ""
            Write-Host "Options:" -ForegroundColor Cyan
            Write-Host "  [C]ontinue - Uninstall existing and proceed with test" -ForegroundColor White
            Write-Host "  [S]kip - Skip installation test (recommended)" -ForegroundColor White  
            Write-Host "  [Q]uit - Exit without testing" -ForegroundColor White
            Write-Host ""
            
            do {
                $choice = Read-Host "What would you like to do? [C/S/Q]"
                $choice = $choice.ToUpper()
            } while ($choice -notin @('C', 'S', 'Q'))
            
            switch ($choice) {
                'Q' { 
                    Write-Host "Exiting test script. Your existing installation is unchanged." -ForegroundColor Green
                    exit 0 
                }
                'S' { 
                    Write-Host "Skipping installation test to preserve your existing installation." -ForegroundColor Yellow
                    $SkipInstall = $true 
                }
                'C' { 
                    Write-Host "Continuing with test. Your existing installation will be restored afterward." -ForegroundColor Yellow
                    $restoreExisting = $true
                }
            }
            Write-Host ""
        }
    }

    # Step 1: Build package
    if (-not $SkipBuild) {
        Write-Host "Building package..." -ForegroundColor Yellow
        
        # Clean up any existing packages
        Get-ChildItem -Path . -Name "*.nupkg" | Remove-Item -Force -ErrorAction SilentlyContinue
        
        # Build the package
        choco pack granted.nuspec
        
        $packageFile = Get-ChildItem -Name "*.nupkg" | Select-Object -First 1
        if (-not $packageFile) {
            throw "No package file was created"
        }
        
        Write-Host "Package built: $packageFile" -ForegroundColor Green
        Write-Host ""
    }

    # Step 2: Install package locally
    if (-not $SkipInstall) {
        Write-Host "Installing package locally..." -ForegroundColor Yellow
        
        # Uninstall if already installed
        try {
            choco uninstall granted -y 2>$null
            Write-Host "Removed existing installation" -ForegroundColor Gray
        } catch {
            # Ignore errors if not installed
        }
        
        # Install from local package
        $packageFile = Get-ChildItem -Name "*.nupkg" | Select-Object -First 1
        if ($packageFile) {
            Write-Host "Installing package: $packageFile" -ForegroundColor Gray
            choco install granted --version="$Version" --source="." -f -y
        } else {
            throw "No package file found to install"
        }
        
        Write-Host "Package installed locally" -ForegroundColor Green
        Write-Host ""
    }

    # Step 3: Test installation
    if (-not $SkipTest) {
        Write-Host "Testing installation..." -ForegroundColor Yellow
        
        # Test 1: Command availability
        try {
            $output = granted --version 2>&1
            Write-Host "granted --version: $output" -ForegroundColor Green
        } catch {
            Write-Error "granted command not available: $($_.Exception.Message)"
        }
        
        # Test 2: Help command
        try {
            $helpOutput = granted --help 2>&1
            if ($helpOutput -match "Granted CLI") {
                Write-Host "Help command works" -ForegroundColor Green
            } else {
                Write-Warning "Help output unexpected"
            }
        } catch {
            Write-Warning "Help command failed: $($_.Exception.Message)"
        }
        
        # Test 3: Binary location
        $shimLocation = Get-Command granted -ErrorAction SilentlyContinue
        if ($shimLocation) {
            Write-Host "Binary location: $($shimLocation.Source)" -ForegroundColor Green
        } else {
            Write-Error "Binary not found in PATH"
        }
        
        Write-Host ""
    }



    Write-Host "Testing completed successfully!" -ForegroundColor Green
    
    # Ask about cleanup if not explicitly set
    if (-not $Cleanup -and -not $SkipInstall) {
        Write-Host ""
        $cleanupChoice = Read-Host "Do you want to uninstall the test package now? [Y/n]"
        if ($cleanupChoice -eq "" -or $cleanupChoice -match "^[Yy]") {
            $Cleanup = $true
        }
    }
    
    # Perform cleanup if requested
    if ($Cleanup -and -not $SkipInstall) {
        Write-Host ""
        Write-Host "Cleaning up test installation..." -ForegroundColor Yellow
        
        try {
            choco uninstall granted -y
            Write-Host "Test package uninstalled successfully" -ForegroundColor Green
        } catch {
            Write-Warning "Failed to uninstall test package: $($_.Exception.Message)"
        }
        
        # Remove package files
        Get-ChildItem -Path . -Name "*.nupkg" | Remove-Item -Force -ErrorAction SilentlyContinue
        Write-Host "Package files cleaned up" -ForegroundColor Green
        
        # Restore original installation if user had one
        if ($restoreExisting) {
            Write-Host ""
            Write-Host "Restoring your original Granted CLI installation..." -ForegroundColor Yellow
            try {
                choco install granted -y
                Write-Host "Original Granted CLI installation restored" -ForegroundColor Green
            } catch {
                Write-Warning "Failed to restore original installation. You may need to reinstall manually."
                Write-Host "Run: choco install granted" -ForegroundColor Gray
            }
        }
    }
    
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "- Review test results above" -ForegroundColor White
    Write-Host "- Make any necessary adjustments" -ForegroundColor White
    Write-Host "- Commit changes and create a version tag" -ForegroundColor White
    Write-Host "- Push tag to trigger automated build" -ForegroundColor White

} catch {
    Write-Error "Test failed: $($_.Exception.Message)"
    exit 1
} finally {
    Set-Location $originalLocation
}

Write-Host ""
Write-Host "Usage examples:" -ForegroundColor Gray
Write-Host "  .\scripts\test-package.ps1                    # Full test cycle" -ForegroundColor Gray
Write-Host "  .\scripts\test-package.ps1 -SkipBuild         # Skip building, test existing package" -ForegroundColor Gray
Write-Host "  .\scripts\test-package.ps1 -Cleanup           # Include cleanup at the end" -ForegroundColor Gray 