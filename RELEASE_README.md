# Codex Release Process - Plain English Guide

## What Is Codex?

Codex is a fork of Microsoft's VS Code editor (via VSCodium - thank you VSCodium team!). We take the open-source VS Code code, remove Microsoft's telemetry/tracking, add our own customizations, and release it as "Codex".

## Where Do New Versions Come From?

**Short Answer:** Microsoft VS Code releases → We manually select version → We build our version

**Detailed Process:**

1. **Microsoft releases new VS Code** (like version 1.99.3)
2. **We manually review and test** the new version for compatibility
3. **We manually trigger builds** when ready (using `.github/workflows/manual-release.yml`)

## How Our Build Process Works

### Step 1: Manual Version Selection & Triggering

- **File:** `.github/workflows/manual-release.yml`
- **What it does:**
  - You select which VS Code version to build
  - Updates `upstream/stable.json` with your chosen version
  - Triggers builds for all platforms (Mac, Windows, Linux)

### Step 2: The Build Happens

- **Files:** `.github/workflows/stable-*.yml` (macos, linux, windows)
- **What happens:**
  1. **Download VS Code source** from Microsoft's GitHub
  2. **Apply our patches** (removes telemetry, adds features like microphone support)
  3. **Rebrand** from "VS Code" to "Codex"
  4. **Build** the app for each platform (Mac, Windows, Linux)
  5. **Create releases** on GitHub
  6. **Update version database** so users can get updates

### Step 3: Our Customizations Get Applied

- **Telemetry removal:** `update_settings.sh` disables all Microsoft tracking
- **UI changes:** Activity bar views moved to panel
- **Microphone support:** `patches/user/microphone.patch` enables microphone in webviews
- **Branding:** Everything changed from "VS Code" to "Codex"

## How Users Get Updates

### The Update System

1. **Your Codex app** periodically checks: `https://raw.githubusercontent.com/genesis-ai-dev/versions/master/stable/[platform]/[arch]/latest.json`
2. **Compares versions** with what you have installed
3. **Shows notification** if newer version available
4. **Downloads from** our GitHub releases

### Version Database

- **Repository:** `genesis-ai-dev/versions`
- **Contains:** JSON files with download links, version numbers, checksums
- **Updated by:** `update_version.sh` script during each successful build

## Manual Release Process

If you need to create a release manually:

### Option 1: Trigger via GitHub API

```bash
curl -X POST \
  -H "Authorization: Bearer YOUR_GITHUB_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  https://api.github.com/repos/genesis-ai-dev/codex/dispatches \
  -d '{"event_type":"stable"}'
```

### Option 2: Use GitHub Actions UI

1. Go to **Actions** tab in GitHub
2. Select **stable-macos** (or linux/windows)
3. Click **Run workflow**
4. Leave all options default and click **Run**

### Option 3: Update VS Code Version Manually

1. Edit `upstream/stable.json`
2. Change `tag` to new VS Code version (like "1.99.3")
3. Change `commit` to the corresponding Git commit hash
4. Commit and push - this triggers builds automatically

## Files That Control Everything

### Version Tracking

- `upstream/stable.json` - Current VS Code version we're based on
- `upstream/insider.json` - Insider/preview version tracking

### Build Scripts

- `get_repo.sh` - Downloads VS Code source code
- `prepare_vscode.sh` - Applies all our patches and customizations
- `build.sh` - Main build script
- `update_version.sh` - Updates the version database for user updates

### Customization Files

- `patches/user/microphone.patch` - Adds microphone support
- `update_settings.sh` - Removes telemetry and moves UI elements
- `product.json` - App configuration and branding

### Workflows (GitHub Actions)

- `.github/workflows/check-updates.yml` - Auto-detects new VS Code versions
- `.github/workflows/stable-*.yml` - Builds releases for each platform

## Version Number Format

**VS Code version:** `1.99.2`
**Our version:** `1.99.22712`

The extra digits (`2712`) represent:

- **Julian day of year × 24 + hour of day**
- This ensures each build has a unique version number
- Example: Day 271 at 2 PM = 2712

## Local Development & Testing

### **Building Locally for Testing**

```bash
# Prerequisites: Node.js 20.18.2, Python 3.11, jq, git

# Clean build (downloads VS Code source, applies patches, builds)
./dev/build.sh

# Quick rebuild after patch changes (skips source download)
./dev/build.sh -s

# Build with packages/installers
./dev/build.sh -p

# Build insider version
./dev/build.sh -i
```

### **Testing Your Local Build**

```bash
# macOS
open ./VSCode-darwin-arm64/Codex.app

# Linux
./VSCode-linux-x64/bin/codex

# Windows
./VSCode-win32-x64/Codex.exe
```

### **Testing Updates Locally**

```bash
# Check if version files exist
./test-version-url.sh

# Test update detection with your built app
./test-update-detection.sh
```

### **Common Development Workflow**

1. **Make patch changes** (edit files in `patches/user/` or `update_settings.sh`)
2. **Quick rebuild:** `./dev/build.sh -s`
3. **Test:** `open ./VSCode-darwin-arm64/Codex.app`
4. **Repeat** until satisfied
5. **Trigger production build** via GitHub Actions

## Troubleshooting

### "No updates available" but I know there's a newer version

1. Check if versions repository has the file: `https://raw.githubusercontent.com/genesis-ai-dev/versions/master/stable/darwin/arm64/latest.json`
2. Verify the `updateUrl` in your app's product.json points to the right place
3. Check if the build actually succeeded in GitHub Actions

### Build failed

1. Check GitHub Actions logs
2. Common issues:
   - VS Code changed their API
   - Patches don't apply cleanly to new VS Code version
   - Missing secrets (signing certificates, tokens)

### Version numbers seem wrong

- Our version numbers will always be higher than VS Code's because we add the time-based suffix
- This is normal and expected

## Quick Reference

## How to Create New Releases

### **Option 1: Patch Rebuild (Same VS Code Version)**

**Use this when you've updated patches/customizations but want to keep the same base VS Code version**

1. Go to **Actions** → **Patch Rebuild (Force Build)**
2. Select quality (`stable` or `insider`)
3. Enter reason (e.g., "Fix microphone patch", "Add new UI feature")
4. Click **Run workflow**

**What happens:**

- Uses current VS Code version from `upstream/stable.json`
- Adds timestamp to version (e.g., `1.99.2.2501281430`)
- **Forces builds to bypass existing asset checks** - ensures patches are applied
- Triggers all platforms at once (Mac, Windows, Linux)
- Creates new release assets even if the base VS Code version hasn't changed

**✅ Fixed Issue:** Patch rebuilds now properly apply patches and create new assets, even when releases with the same base version already exist.

### **Option 2: Full Version Update**

**Use this when you want to update to a newer VS Code version**

1. Go to **Actions** → **Manual Release Build**
2. Enter VS Code version (e.g., `1.99.3`)
3. Enter optional commit hash (or leave empty)
4. Click **Run workflow**

**What happens:**

- Updates `upstream/stable.json` with new VS Code version
- Downloads new VS Code source
- Applies all your patches
- Builds for all platforms

**To check current version:**

- Look at `upstream/stable.json`

**To see what customizations we apply:**

- Look in `patches/user/` and `update_settings.sh`

**To check if releases are working:**

- Visit `https://github.com/genesis-ai-dev/codex/releases`

**To check if updates work:**

- Visit `https://github.com/genesis-ai-dev/versions`
