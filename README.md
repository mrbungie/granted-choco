# Chocolatey Package for Granted CLI

[![Chocolatey Version](https://img.shields.io/chocolatey/v/granted.svg)](https://chocolatey.org/packages/granted)
[![Chocolatey Downloads](https://img.shields.io/chocolatey/dt/granted.svg)](https://chocolatey.org/packages/granted)

This repository contains the Chocolatey package for [Granted CLI](https://github.com/fwdcloudsec/granted) - a command line interface application that simplifies access to cloud roles and allows multiple cloud accounts to be opened in your web browser simultaneously.

## 🚀 Quick Installation

```powershell
choco install granted
```

## 📋 Prerequisites

- Windows 10/11 or Windows Server 2016+
- [Chocolatey](https://chocolatey.org/install) package manager
- PowerShell 5.0 or later

## 🏗️ Supported Architectures

This package automatically detects your system architecture and installs the appropriate binary:

- **x64** (AMD64) - Most common for modern Windows systems
- **x86** (32-bit) - Legacy 32-bit Windows systems  
- **ARM64** - ARM-based Windows devices (Surface Pro X, etc.)

## 📦 Package Information

- **Package ID**: `granted`
- **Maintainer**: Germán Oviedo
- **Source**: [Common Fate/Granted](https://github.com/fwdcloudsec/granted)
- **License**: MIT
- **Tags**: aws, cli, security, access, iam, assume-role, cloud, devops

## 🔧 Usage

After installation, Granted CLI is available globally via the `granted` command:

```powershell
# Get help
granted --help

# Login to AWS SSO
granted sso login

# Assume an AWS role
granted assume <profile-name>

# Open browser for AWS console access
granted browser
```

## 📚 Documentation

- [Official Granted Documentation](https://docs.commonfate.io/granted/)
- [GitHub Repository](https://github.com/fwdcloudsec/granted)
- [Common Fate Website](https://commonfate.io/)

## 🔄 Upgrading

To upgrade to the latest version:

```powershell
choco upgrade granted
```

## 🗑️ Uninstallation

```powershell
choco uninstall granted
```

## 🛠️ Development & Contributing

### Package Structure

```
granted-choco/
├── granted.nuspec              # Package specification
├── tools/
│   ├── chocolateyInstall.ps1   # Installation script
│   └── chocolateyUninstall.ps1 # Uninstallation script
├── .github/workflows/
│   └── build.yml               # Automated package building
└── README.md                   # This file
```

### Building the Package Locally

1. **Clone this repository:**
   ```bash
   git clone https://github.com/YOUR_USERNAME/granted-choco.git
   cd granted-choco
   ```

2. **Update version in `granted.nuspec` if needed**

3. **Pack the package:**
   ```powershell
   choco pack
   ```

4. **Test locally:**
   ```powershell
   choco install granted -s . -f
   ```

### Automation

This package uses GitHub Actions to automatically build and release new versions when tags are pushed:

1. **Create a new tag:**
   ```bash
   git tag v0.38.0
   git push origin v0.38.0
   ```

2. **GitHub Actions will:**
   - Extract version from tag
   - Update `granted.nuspec` with the new version
   - Build the `.nupkg` file
   - Create a GitHub release with the package as an asset

### Version Management

- Package versions should match upstream Granted CLI releases
- Tags should follow the format: `v{MAJOR}.{MINOR}.{PATCH}` (e.g., `v0.38.0`)
- The automation will automatically update URLs and version numbers

## 🐛 Issues & Support

- **Package Issues**: [Open an issue](https://github.com/YOUR_USERNAME/granted-choco/issues) in this repository
- **Granted CLI Issues**: [Report upstream](https://github.com/fwdcloudsec/granted/issues)
- **Chocolatey Issues**: [Chocolatey Community](https://github.com/chocolatey/choco/issues)

## ⚖️ License

This packaging is licensed under the MIT License. The Granted CLI itself is licensed under the MIT License by Common Fate.

## 🙏 Acknowledgments

- [Common Fate](https://commonfate.io/) for creating Granted CLI
- [Chocolatey Community](https://chocolatey.org/) for the package management platform
- All contributors who help maintain this package

---

**Note**: This is an unofficial community-maintained package and is not officially supported by Common Fate. 