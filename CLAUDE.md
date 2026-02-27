# Codex Development Guide

This repository builds Codex, a freely-licensed VS Code distribution. It is a fork of [VSCodium](https://github.com/VSCodium/vscodium) with custom branding and configuration. The build process clones Microsoft's vscode repository and modifies it via git patches.

## Upstream Relationship

```
Microsoft/vscode (source code)
        ↓ (cloned at specific commit)
VSCodium/vscodium (origin) ──patches──→ VSCodium binaries
        ↓ (forked)
This repo (Codex) ──patches──→ Codex binaries
```

**Remotes:**
- `origin` = VSCodium/vscodium (upstream we sync from)
- `nexus` = BiblioNexus-Foundation/codex (our main repo)

## Repository Structure

```
patches/           # All patch files that modify vscode source
  *.patch          # Core patches applied to all builds
  insider/         # Patches specific to insider builds
  osx/             # macOS-specific patches
  linux/           # Linux-specific patches
  windows/         # Windows-specific patches
  user/            # Optional user patches

vscode/            # Cloned vscode repository (gitignored, generated)
dev/               # Development helper scripts
src/               # Brand assets and configuration overlays
```

## Working with Patches

### Understanding the Patch Workflow

1. **Patches are the source of truth** - Never commit direct changes to the `vscode/` directory. All modifications to VS Code source must be captured as `.patch` files in the `patches/` directory.

2. **Patches are applied sequentially** - Order matters. Core patches are applied first, then platform-specific patches.

3. **Patches use placeholder variables** - Patches can use placeholders like `!!APP_NAME!!`, `!!BINARY_NAME!!`, etc. that get replaced during application.

### Making Changes to VS Code Source

#### Step 1: Set Up Working Environment

```bash
# Fresh clone of vscode at the correct commit
./get_repo.sh

# Or use dev/build.sh which does this automatically
./dev/build.sh
```

#### Step 2: Apply Existing Patches

To work on an existing patch:
```bash
# Apply prerequisite patches + the target patch for editing
./dev/patch.sh prerequisite1 prerequisite2 target-patch

# Example: To modify the brand.patch
./dev/patch.sh brand
```

The `dev/patch.sh` script:
- Resets vscode to clean state
- Applies the helper settings patch
- Applies all listed prerequisite patches
- Applies the target patch (last argument)
- Waits for you to make changes
- Regenerates the patch file when you press a key

#### Step 3: Making Changes

After running `dev/patch.sh`:
1. Edit files in `vscode/` as needed
2. Press any key in the terminal when done
3. The script regenerates the patch file automatically

#### Manual Patch Creation/Update

If working manually:
```bash
cd vscode

# Make your changes to the source files
# ...

# Stage and generate diff
git add .
git diff --staged -U1 > ../patches/your-patch-name.patch
```

### Testing Patches

#### Validate All Patches Apply Cleanly

```bash
./dev/update_patches.sh
```

This script:
- Iterates through all patches
- Attempts to apply each one
- If a patch fails, it applies with `--reject` and pauses for manual resolution
- Regenerates any patches that needed fixing

#### Full Build Test

```bash
# Run a complete local build
./dev/build.sh

# Options:
#   -i    Build insider version
#   -l    Use latest vscode version
#   -o    Skip build (only prepare source)
#   -s    Skip source preparation (use existing vscode/)
```

### Common Development Tasks

#### Creating a New Patch

1. Apply all prerequisite patches that your change depends on
2. Make your changes in `vscode/`
3. Generate the patch:
   ```bash
   cd vscode
   git add .
   git diff --staged -U1 > ../patches/my-new-feature.patch
   ```
4. Add the patch to the appropriate location in `prepare_vscode.sh` if it should be applied during builds

#### Updating a Patch After Upstream Changes

When VS Code updates and a patch no longer applies:
```bash
# Run update script - it will pause on failing patches
./dev/update_patches.sh

# Fix the conflicts in vscode/, then press any key
# The script regenerates the fixed patch
```

#### Debugging Patch Application

```bash
cd vscode
git apply --check ../patches/problem.patch    # Dry run
git apply --reject ../patches/problem.patch   # Apply with .rej files for conflicts
```

## Key Scripts Reference

| Script | Purpose |
|--------|---------|
| `get_repo.sh` | Clone vscode at correct version |
| `prepare_vscode.sh` | Apply patches and prepare for build |
| `build.sh` | Main build script |
| `dev/build.sh` | Local development build |
| `dev/patch.sh` | Apply patches for editing a single patch |
| `dev/update_patches.sh` | Validate/update all patches |
| `dev/clean_codex.sh` | Remove all Codex app data from macOS user dirs (reset to clean state; macOS only) |
| `utils.sh` | Common functions including `apply_patch` |

## Build Environment

The build process:
1. `get_repo.sh` - Fetches vscode source at a specific commit
2. `prepare_vscode.sh` - Applies patches, copies branding, runs npm install
3. `build.sh` - Compiles the application

Environment variables:
- `VSCODE_QUALITY`: "stable" or "insider"
- `OS_NAME`: "osx", "linux", or "windows"
- `VSCODE_ARCH`: CPU architecture

### Version Tracking

The VS Code version to build is determined by:

1. **`upstream/stable.json`** (or `insider.json`) - Contains the target VS Code tag and commit:
   ```json
   {
     "tag": "1.100.0",
     "commit": "19e0f9e681ecb8e5c09d8784acaa601316ca4571"
   }
   ```

2. **`VSCODE_LATEST=yes`** - If set, queries Microsoft's update API for the latest version instead

When syncing upstream, update these JSON files to match VSCodium's versions to ensure patches are compatible.

## Syncing with Upstream VSCodium

This is the most challenging maintenance task. VSCodium regularly updates their patches and build scripts to support new VS Code versions.

### Check Current Status

```bash
git fetch origin
git log --oneline origin/master -5                    # See upstream's recent changes
git rev-list --count $(git merge-base HEAD origin/master)..origin/master  # Commits behind
```

### Codex-Specific Customizations to Preserve

When merging upstream, these are our key customizations that must be preserved:

1. **Branding** (`src/stable/`, `src/insider/`, `icons/`)
   - Custom icons and splash screens
   - Keep all Codex assets

2. **GitHub Workflows** (`.github/workflows/`)
   - Simplified compared to VSCodium
   - Uses different release repos (genesis-ai-dev/codex, BiblioNexus-Foundation/codex)
   - Has custom workflows: `docker-build-push.yml`, `patch-rebuild.yml`, `manual-release.yml`

3. **Windows MSI Files** (`build/windows/msi/`)
   - Files renamed from `vscodium.*` to `codex.*`
   - References updated for Codex branding

4. **Product Configuration** (`product.json`, `prepare_vscode.sh`)
   - URLs point to genesis-ai-dev/codex repos
   - App names, identifiers set to Codex

5. **Custom Patches** (`patches/`)
   - `patches/user/microphone.patch` - Codex-specific
   - Minor modifications to other patches for branding

6. **Windows Code Signing** (`.github/workflows/stable-windows.yml`)
   - SSL.com eSigner integration for code signing
   - Signs application binaries (.exe, .dll) before packaging
   - Signs installer packages (.exe, .msi) after packaging
   - Required secrets: `ES_USERNAME`, `ES_PASSWORD`, `ES_CREDENTIAL_ID`, `ES_TOTP_SECRET`
   - **Must preserve**: The signing steps between "Build" and "Prepare assets", and after "Upload unsigned artifacts"

### Merge Strategy

#### Option A: Incremental Merge (Recommended for small gaps)

```bash
# Create a working branch
git checkout -b upstream-sync

# Merge upstream
git merge origin/master

# Resolve conflicts - most will be in:
#   - .github/workflows/ (keep ours, incorporate new build steps if needed)
#   - patches/*.patch (need careful merge - see below)
#   - build/windows/msi/ (keep our codex.* files)
#   - prepare_vscode.sh (keep our branding, adopt new build logic)
```

#### Option B: Cherry-pick Patch Updates (Recommended for large gaps)

When far behind (like 1.99 → 1.108), it's often easier to:

1. **Identify patch update commits** in upstream:
   ```bash
   git log origin/master --oneline --grep="update patches"
   ```

2. **Cherry-pick or manually apply** the patch changes:
   ```bash
   # See what patches changed in a specific upstream commit
   git show <commit> -- patches/
   ```

3. **Copy updated patches** from upstream, then re-apply our branding changes

#### Option C: Reset and Re-apply Customizations

For very large gaps, it may be cleanest to:

1. Create a fresh branch from upstream
2. Re-apply Codex customizations on top
3. This ensures we get all upstream fixes cleanly

### Resolving Patch Conflicts

When upstream updates patches that we've also modified:

1. **Compare the patches:**
   ```bash
   git diff origin/master -- patches/brand.patch
   ```

2. **Accept upstream's patch structure** (they've adapted to new VS Code)

3. **Re-apply our branding on top:**
   - Our changes are usually just `VSCodium` → `Codex` type substitutions
   - The placeholder system (`!!APP_NAME!!`) handles most of this automatically

### After Merging: Validate Everything

```bash
# 1. Update upstream/stable.json to new version if needed
# 2. Test patches apply cleanly
./dev/update_patches.sh

# 3. Run a full local build
./dev/build.sh -l  # -l uses latest VS Code version

# 4. If patches fail, fix them one by one
# The update_patches.sh script will pause on failures
```

### Common Conflict Patterns

| File/Area | Typical Resolution |
|-----------|-------------------|
| `.github/workflows/*.yml` | Keep our simplified versions, cherry-pick important CI fixes |
| `.github/workflows/stable-windows.yml` | **Preserve code signing steps** - keep SSL.com eSigner integration intact |
| `patches/*.patch` | Take upstream's version, verify our branding placeholders work |
| `prepare_vscode.sh` | Keep our branding URLs/names, adopt new build logic |
| `build/windows/msi/` | Keep our `codex.*` files, apply equivalent changes from `vscodium.*` |
| `README.md` | Keep ours |
| `product.json` | Keep ours (merged at build time anyway) |

## Tips

- Always work from a clean vscode state when creating patches
- Keep patches focused and minimal - one logical change per patch
- Test patches apply to a fresh clone before committing
- The `vscode/` directory is gitignored - your patch files are the persistent record
- When syncing upstream, focus on patch files first - they're the core of the build
