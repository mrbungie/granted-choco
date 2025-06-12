# Setup Guide for Granted Chocolatey Package

This guide will help you set up automated building and publishing of the Chocolatey package.

## 🚀 Quick Setup

### 1. Repository Setup

1. **Create GitHub repository** (if not done already):
   ```bash
   # Clone and setup
   git clone https://github.com/YOUR_USERNAME/granted-choco.git
   cd granted-choco
   
   # Update nuspec with your details
   # Edit granted.nuspec and replace YOUR_USERNAME with your GitHub username
   ```

2. **Update package metadata**:
   - Edit `granted.nuspec`
   - Replace `YOUR_USERNAME` with your actual GitHub username
   - Update `<owners>` and `<packageSourceUrl>` fields

### 2. GitHub Actions Setup

The workflow is already configured! It will:

- ✅ **Trigger on version tags** (`v0.38.0`, `v0.39.0`, etc.)
- ✅ **Build package automatically**
- ✅ **Test installation**
- ✅ **Create GitHub release**
- ✅ **Publish to chocolatey.org** (optional)

### 3. Chocolatey.org Publication (Optional)

To enable automatic publication to chocolatey.org:

#### Step 3.1: Get Chocolatey API Key

1. **Create account** at [community.chocolatey.org](https://community.chocolatey.org/account/Register)
2. **Get API key** from [your account page](https://community.chocolatey.org/account)
3. **Copy the API key** (keep it secret!)

#### Step 3.2: Add GitHub Secret

1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Name: `CHOCOLATEY_API_KEY`
5. Value: Paste your API key
6. Click **Add secret**

#### Step 3.3: Create GitHub Environment (Recommended)

For extra security, create a protected environment:

1. Go to **Settings** → **Environments**
2. Click **New environment**
3. Name: `chocolatey-publish`
4. **Optional**: Add required reviewers for production releases
5. **Optional**: Add deployment branches rule (only `main` branch)

## 🎯 Usage

### Creating a New Release

1. **Ensure upstream Granted CLI version exists**:
   ```bash
   # Check if v0.39.0 exists
   curl -I https://github.com/fwdcloudsec/granted/releases/tag/v0.39.0
   ```

2. **Create and push version tag**:
   ```bash
   git tag v0.39.0
   git push origin v0.39.0
   ```

3. **GitHub Actions will automatically**:
   - Build the package
   - Test it works
   - Create GitHub release
   - Publish to chocolatey.org (if API key is set)

### Manual Testing

Test locally before creating a release:

```powershell
# Run the test script
.\scripts\test-package.ps1

# Or test with cleanup
.\scripts\test-package.ps1 -Cleanup
```

## 🔧 Workflow Details

### Build Job (`build`)

- **Triggers**: Version tags (`v*`) or manual dispatch
- **Runs on**: `windows-latest`
- **Steps**:
  1. Extract version from git tag
  2. Update `granted.nuspec` with version
  3. Update `tools/chocolateyInstall.ps1` with version
  4. Verify upstream Granted CLI release exists
  5. Install Chocolatey
  6. Build package (`choco pack`)
  7. Test package installation
  8. Create GitHub release with `.nupkg` file
  9. Upload package as artifact

### Publish Job (`publish`)

- **Triggers**: Only on version tag pushes (not manual dispatch)
- **Depends on**: Build job success
- **Environment**: `chocolatey-publish` (for security)
- **Steps**:
  1. Download package artifact from build job
  2. Validate package file
  3. Publish to chocolatey.org (if API key available)
  4. Display success summary

## 🛡️ Security Features

### Repository Secrets
- `CHOCOLATEY_API_KEY` - Protected secret for publishing

### Environment Protection
- `chocolatey-publish` environment can require manual approval
- Only runs on version tags (not PRs or manual triggers)

### Validation Steps
- Verifies upstream release exists before building
- Tests package installation before publishing
- Validates package file size and format

## 🚨 Troubleshooting

### Common Issues

**"Upstream release not found"**
- Ensure Granted CLI has released the version you're tagging
- Check: https://github.com/fwdcloudsec/granted/releases

**"Package already exists"**
- You cannot republish the same version to chocolatey.org
- Increment version number or use a patch version

**"API key invalid"**
- Check your chocolatey.org API key is correct
- Regenerate from https://community.chocolatey.org/account

**"Test installation failed"**
- Check if the download URLs are working
- Verify architecture mappings in install script

### Manual Package Building

If automation fails, build manually:

```powershell
# Update version manually in files
$version = "0.39.0"

# Update nuspec
(Get-Content granted.nuspec) -replace '<version>[\d\.]+</version>', "<version>$version</version>" | Set-Content granted.nuspec

# Update install script  
(Get-Content tools/chocolateyInstall.ps1) -replace '\$version = ''[\d\.]+''', "`$version = '$version'" | Set-Content tools/chocolateyInstall.ps1

# Build package
choco pack granted.nuspec

# Test locally
choco install granted --version="$version" --source="." -f -y
```

## 📊 Monitoring

- **GitHub Actions**: Monitor runs in the Actions tab
- **Chocolatey.org**: Check package status at https://community.chocolatey.org/packages/granted
- **GitHub Releases**: View releases at https://github.com/YOUR_USERNAME/granted-choco/releases

## 🎉 Success!

Once setup is complete:

1. **Users install with**: `choco install granted`
2. **Automatic updates** when Granted CLI releases new versions
3. **GitHub releases** provide .nupkg files for direct download
4. **Public package** available at community.chocolatey.org

---

**Questions?** Open an issue in this repository! 