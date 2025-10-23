# CI Action Investigation - Implementation Details

## Overview

The CI action is a **Node.js program** (ci-action/index.js) that serves as the core orchestrator for the CI/CD pipeline. It's implemented as a GitHub Action and handles build, test, and publish operations for both Go and Node.js projects.

---

## Architecture

### Main Files

| File | Lines | Purpose |
|------|-------|---------|
| `index.js` | 1-194 | Main CI action orchestrator |
| `action.yml` | 1-66 | GitHub Action configuration |
| `common.js` | 1-27 | Shell command execution utility |
| `checkSources.js` | 1-89 | Source code validation |
| `rejectHiddenFolders.js` | 1-25 | Hidden folder validation |
| `publish.js` | 1-148 | Release publishing logic |

---

## Execution Flow

### Phase 1: Initialization (lines 15-70)

1. **Parse Inputs** (lines 15-37)
   - Extract 13 input parameters from action.yml
   - Convert comma-separated values to arrays
   - Inputs: ignore, organization, token, codecov-token, codecov-go-race, ignore-build, publish-asset, publish-token, publish-keep, repository, run-mod-tidy, main-branch, ignore-copyright, test-folder, short-test, build-cmd

2. **Extract Repository Context** (lines 39-48)
   - Parse repository owner and name
   - Extract branch name from git ref
   - Determine fork status

3. **Log Context** (lines 57-69)
   - Print debugging information
   - Log: repository, organization, actor, event name, fork status, branch name

### Phase 2: Validation (lines 71-91)

4. **Reject Hidden Folders** (lines 71-72)
   - Module: `rejectHiddenFolders.js`
   - Validates only expected hidden folders exist
   - Allowed: .git, .github, .husky, .augment
   - Throws error on unexpected folders

5. **Check Source Files** (lines 74-76)
   - Module: `checkSources.checkFirstCommentInSources()`
   - Verifies copyright headers in .go and .js files
   - Checks LICENSE file consistency
   - Skipped if `ignore-copyright` is true

6. **Detect Language** (lines 78-91)
   - Module: `checkSources.detectLanguage()`
   - Checks for go.mod file first
   - Scans for .go or .js/.ts files
   - Returns: "go", "node_js", or "unknown"

### Phase 3: Build & Test (lines 79-170)

#### For Go Projects (lines 79-147)

a. **Setup Private Dependencies** (lines 88-93)
   - For each organization:
     - Add to GOPRIVATE environment variable
     - Configure git authentication with token

b. **Change Test Folder** (lines 95-97)
   - If `test-folder` specified, cd into it

c. **Run go mod tidy** (lines 99-101)
   - Execute `go mod tidy` if `run-mod-tidy` is true
   - Cleans up go.mod file

d. **Build** (lines 103-105)
   - Execute `go build ./...` unless `ignore-build` is true
   - Compiles all packages

e. **Run Tests with Codecov** (lines 109-138)
   - **With Codecov:**
     - Install gocov tool
     - Run `go test ./...` with coverage flags
     - Add `-race` flag if `codecov-go-race` is true
     - Add `-short` flag if `short-test` is true
     - Upload coverage to Codecov
   - **Without Codecov:**
     - Run `go test ./...` with optional `-race` and `-short` flags

f. **Restore Directory** (lines 139-141)
   - If `test-folder` was specified, cd back to root

g. **Run Custom Build Command** (lines 142-144)
   - Execute custom build command if provided

#### For Node.js Projects (lines 149-170)

a. **Install Dependencies** (line 155)
   - Execute `npm install`

b. **Build** (line 156)
   - Execute `npm run build --if-present`

c. **Run Tests** (line 157)
   - Execute `npm test`

d. **Codecov** (lines 160-166)
   - If `codecov-token` provided:
     - Install codecov globally
     - Run Istanbul coverage
     - Upload to Codecov

### Phase 4: Publishing (lines 174-182)

7. **Publish Asset** (lines 174-182)
   - Only if on main branch and `publish-asset` specified
   - Module: `publish.publishAsRelease()`
   - Generates version from UTC timestamp (yyyyMMdd.HHmmss.SSS)
   - Creates zip file from asset
   - Creates GitHub release with version tag
   - Uploads asset as release attachment
   - Uploads deploy.txt with download URL
   - Deletes old releases (keeps N releases based on `publish-keep`)

### Phase 5: Finalization (lines 184-190)

8. **Set Outputs** (lines 184-186)
   - Set GitHub action outputs for downstream jobs:
     - `release_id`
     - `release_name`
     - `release_html_url`
     - `release_upload_url`
     - `asset_browser_download_url`

9. **Error Handling** (lines 188-190)
   - Catch any errors during execution
   - Set workflow as failed with error message

---

## Helper Modules

### common.js (lines 11-22)

**Purpose:** Execute shell commands asynchronously

**Function:** `execute(command)`
- Executes shell command using Node.js child_process
- Logs command and output
- Throws error if command fails
- Returns stdout and stderr

### checkSources.js (lines 30-88)

**Purpose:** Validate source code structure and language detection

**Functions:**
- `detectLanguage()` - Detects Go or Node.js project
  - Checks for go.mod file first
  - Scans for .go or .js/.ts files
  - Returns: "go", "node_js", or "unknown"

- `checkFirstCommentInSources()` - Validates copyright headers
  - Scans all .go and .js files
  - Verifies copyright in first comment
  - Checks LICENSE file consistency
  - Throws error on violations

- `checkGoMod()` - Validates go.mod file
  - Checks for local replaces
  - Throws error if local replaces found

- `getSourceFiles()` - Recursively finds source files
  - Finds all .go and .js files
  - Respects ignore list
  - Returns array of file paths

### rejectHiddenFolders.js (lines 15-22)

**Purpose:** Validate hidden folder structure

**Function:** `rejectHiddenFolders(ignore)`
- Scans root directory for hidden folders
- Allows: .git, .github, .husky, .augment
- Rejects: any other hidden folders
- Throws error on unexpected folders

### publish.js (lines 52-142)

**Purpose:** Publish releases to GitHub

**Function:** `publishAsRelease(asset, token, keep, repositoryOwner, repositoryName, targetCommitish)`

**Steps:**
1. Validate asset exists
2. Validate deployer.url exists
3. Generate version from UTC timestamp (yyyyMMdd.HHmmss.SSS)
4. Create zip file from asset
5. Create GitHub release with version tag
6. Upload asset as release attachment
7. Upload deploy.txt with download URL
8. Delete old releases (keeps N versions)
9. Return release metadata

**Outputs:**
- `release_id`
- `release_name`
- `release_html_url`
- `release_upload_url`
- `asset_browser_download_url`

---

## Input Parameters (action.yml)

| Parameter | Default | Description |
|-----------|---------|-------------|
| `ignore` | - | Folders/files to ignore (comma-separated) |
| `organization` | untillpro | GitHub organization(s) for private repos |
| `token` | - | Auth token for private dependencies |
| `codecov-token` | - | Codecov token |
| `codecov-go-race` | true | Use Go Race Detector |
| `ignore-build` | false | Skip Go build |
| `publish-asset` | - | File/dir name to publish |
| `publish-token` | github.token | Auth token for publishing |
| `publish-keep` | 8 | Number of releases to keep (0 = all) |
| `repository` | github.repository | Repository name with owner |
| `run-mod-tidy` | true | Execute go mod tidy |
| `main-branch` | main | Main branch name |
| `ignore-copyright` | false | Skip copyright check |
| `test-folder` | - | Run tests only in specific folder |
| `short-test` | false | Run tests with -short flag |
| `build-cmd` | - | Custom build command |
| `stop-test` | false | Skip tests entirely |

---

## Output Parameters (action.yml)

| Output | Description |
|--------|-------------|
| `release_id` | The ID of the created Release |
| `release_name` | The name (version) of the created Release |
| `release_html_url` | URL to view the release |
| `release_upload_url` | URL for uploading assets to the release |
| `asset_browser_download_url` | URL to download the uploaded asset |

---

## Key Features

### 1. Multi-Language Support
- Detects Go and Node.js projects automatically
- Runs appropriate build and test commands
- Supports custom build commands

### 2. Code Quality Checks
- Validates copyright headers in source files
- Checks for unexpected hidden folders
- Validates go.mod file (no local replaces)

### 3. Testing & Coverage
- Supports Go race detector
- Supports short tests
- Integrates with Codecov for coverage reporting
- Supports custom test folders

### 4. Private Dependencies
- Configures git authentication for private repos
- Supports multiple organizations
- Sets GOPRIVATE environment variable

### 5. Release Management
- Automatic version generation from timestamp
- Creates GitHub releases with assets
- Manages old releases (keeps N versions)
- Uploads deploy.txt for deployment

### 6. Error Handling
- Validates all inputs
- Checks source code structure
- Catches and reports errors
- Sets workflow status appropriately

---

## Integration Points

### Called By
- `ci_reuse_go.yml` - Reusable Go CI workflow
- `ci_reuse_go_pr.yml` - Reusable Go CI workflow (PR context)

### Calls
- `common.js` - For shell command execution
- `checkSources.js` - For source code validation
- `rejectHiddenFolders.js` - For folder validation
- `publish.js` - For release publishing

### Environment Variables Used
- `GOPRIVATE` - Go private modules
- `CODECOV_TOKEN` - Codecov authentication
- `GIT_CONFIG` - Git authentication

---

## Usage Example

```yaml
- name: Run CI action
  uses: untillpro/ci-action@main
  with:
    ignore: 'vendor,node_modules'
    organization: 'untillpro,myorg'
    token: ${{ secrets.REPOREADING_TOKEN }}
    codecov-token: ${{ secrets.CODECOV_TOKEN }}
    codecov-go-race: 'true'
    short-test: 'false'
    test-folder: 'pkg'
    publish-asset: 'dist'
    publish-token: ${{ secrets.PERSONAL_TOKEN }}
    publish-keep: '8'
```

---

## Documentation Updated

The CI Action Flow has been added to **DETAILED_WORKFLOW_FLOWS.md** as substeps under:
- Section 1: Pull Request on pkg-cmd
- Subsection: "CI Action Flow (index.js)"

This provides complete visibility into what happens when the CI action runs, including all 9 execution phases and helper modules.

