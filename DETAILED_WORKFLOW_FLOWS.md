# Detailed Workflow Execution Flows

## 1. Pull Request on pkg-cmd (excluding pkg/istorage)

**Trigger:** `pull_request_target` on paths excluding `pkg/istorage/**`
**File:** `voedger/.github/workflows/ci-pkg-cmd_pr.yml`

### Execution Flow

PR Created/Updated
    ↓
ci-pkg-cmd_pr.yml triggered
    ↓
Job: call-workflow-ci-pkg [.github/workflows/ci-pkg-cmd_pr.yml#L9](.github/workflows/ci-pkg-cmd_pr.yml#L9)
    ├─ Uses: untillpro/ci-action/.github/workflows/ci_reuse_go_pr.yml@main
    ├─ Inputs:
    │  ├─ test_folder: "pkg"
    │  ├─ ignore_copyright: "cmd/voedger/sys.monitor/site.main"
    │  ├─ short_test: "true"
    │  ├─ go_race: "false"
    │  └─ test_subfolders: "true"
    │
    └─ Steps in ci_reuse_go_pr.yml:
       ├─ [Set up Go 1.24](.github/workflows/ci_reuse_go_pr.yml#L42)
       ├─ [Install TinyGo 0.37.0](.github/workflows/ci_reuse_go_pr.yml#L49)
       ├─ [Checkout PR head commit](.github/workflows/ci_reuse_go_pr.yml#L54)
       ├─ [Check PR file size](.github/workflows/ci_reuse_go_pr.yml#L60)
       │  └─ Script: ci-action/scripts/checkPR.sh
       ├─ [Cancel other workflows](.github/workflows/ci_reuse_go_pr.yml#L66)
       │  └─ Script: ci-action/scripts/cancelworkflow.sh
       ├─ [Cache Go modules](.github/workflows/ci_reuse_go_pr.yml#L74)
       ├─ [Run CI action](.github/workflows/ci_reuse_go_pr.yml#L82)
       │  └─ Uses: untillpro/ci-action@main
       │  └─ [See CI Action Flow below]
       ├─ [Test subfolders](.github/workflows/ci_reuse_go_pr.yml#L95)
       │  └─ Script: ci-action/scripts/test_subfolders.sh
       ├─ [Check copyright](.github/workflows/ci_reuse_go_pr.yml#L100)
       │  └─ Script: ci-action/scripts/check_copyright.sh
       └─ [Run linters](.github/workflows/ci_reuse_go_pr.yml#L103)
          └─ Script: ci-action/scripts/gbash.sh
    ↓
Job: auto-merge-pr [.github/workflows/ci-pkg-cmd_pr.yml#L25](.github/workflows/ci-pkg-cmd_pr.yml#L25) [depends on call-workflow-ci-pkg]
    ├─ Uses: ./.github/workflows/merge.yml (local)
    └─ Steps in merge.yml:
       └─ [Merge PR](.github/workflows/merge.yml#L15)
          └─ Script: ci-action/scripts/domergepr.sh
          └─ Env: GH_TOKEN, repo, pr_number, br_name

### Key Files Involved
- **voedger:** `ci-pkg-cmd_pr.yml`, `merge.yml`
- **ci-action:** `ci_reuse_go_pr.yml`, `checkPR.sh`, `cancelworkflow.sh`, `test_subfolders.sh`, `check_copyright.sh`, `gbash.sh`, `domergepr.sh`, `index.js`

### CI Action Flow (index.js)

The CI action is a Node.js program (ci-action/index.js) that orchestrates the build and test process. It's invoked as a GitHub Action and runs the following steps:

**File:** [`ci-action/index.js`](index.js#L1)
**Configuration:** [`ci-action/action.yml`](action.yml#L1)

#### [Step 1: Parse Inputs](index.js#L15)
- Extract all input parameters from action.yml
- Convert comma-separated inputs to arrays
- Parse: ignore, organization, token, codecov-token, codecov-go-race, ignore-build, publish-asset, publish-token, publish-keep, repository, run-mod-tidy, main-branch, ignore-copyright, test-folder, short-test, build-cmd

#### [Step 2: Extract Repository Context](index.js#L39)
- Parse repository owner and name from input or GitHub context
- Extract branch name from git ref (remove 'refs/heads/' prefix)
- Determine if repository is a fork

#### [Step 3: Log Context](index.js#L57)
- Print GitHub context information for debugging
- Log: repository, token, organization, actor, event name, fork status, branch name

#### [Step 4: Reject Hidden Folders](index.js#L71)
- Call `rejectHiddenFolders.js` module
- Validates that only expected hidden folders exist (.git, .github, .husky, .augment)
- Throws error if unexpected hidden folders found

#### [Step 5: Check Source Files](index.js#L74)
- Call `checkSources.checkFirstCommentInSources()` module
- Verifies copyright headers in source files (.go and .js files)
- Checks LICENSE file consistency
- Skipped if `ignore-copyright` is true

#### [Step 6: Detect Language](index.js#L78)
- Call `checkSources.detectLanguage()` module
- Checks for `go.mod` file first
- Scans for .go or .js/.ts files
- Returns "go", "node_js", or "unknown"

**If Go Project Detected [index.js#L79](index.js#L79):**

a. **[Setup Private Dependencies](index.js#L88)**
   - For each organization in input:
     - Add to GOPRIVATE environment variable
     - Configure git to use token for authentication

b. **[Change Test Folder](index.js#L95)**
   - If `test-folder` specified, cd into it

c. **[Run go mod tidy](index.js#L99)**
   - Execute `go mod tidy` if `run-mod-tidy` is true
   - Cleans up go.mod file

d. **[Build](index.js#L103)**
   - Execute `go build ./...` unless `ignore-build` is true
   - Compiles all packages

e. **[Run Tests with Codecov](index.js#L109)**
   - If `codecov-token` provided:
     - Install gocov tool
     - Run `go test ./...` with coverage flags
     - Add `-race` flag if `codecov-go-race` is true
     - Add `-short` flag if `short-test` is true
     - Upload coverage to Codecov
   - If no codecov-token:
     - Run `go test ./...` with optional `-race` and `-short` flags

f. **[Restore Directory](index.js#L139)**
   - If `test-folder` was specified, cd back to root

g. **[Run Custom Build Command](index.js#L142)**
   - Execute custom build command if provided

**If Node.js Project Detected [index.js#L149](index.js#L149):**

a. **[Install Dependencies](index.js#L155)**
   - Execute `npm install`

b. **[Build](index.js#L156)**
   - Execute `npm run build --if-present`

c. **[Run Tests](index.js#L157)**
   - Execute `npm test`

d. **[Codecov](index.js#L160)**
   - If `codecov-token` provided:
     - Install codecov globally
     - Run Istanbul coverage
     - Upload to Codecov

#### [Step 7: Publish Asset](index.js#L174)
- If on main branch and `publish-asset` specified:
  - Call `publish.publishAsRelease()` module
  - Generates version from UTC timestamp (yyyyMMdd.HHmmss.SSS)
  - Creates zip file from asset
  - Creates GitHub release with version tag
  - Uploads asset as release attachment
  - Uploads deploy.txt with download URL
  - Deletes old releases (keeps N releases based on `publish-keep`)

#### [Step 8: Set Outputs](index.js#L184)
- Set GitHub action outputs for downstream jobs:
  - `release_id`
  - `release_name`
  - `release_html_url`
  - `release_upload_url`
  - `asset_browser_download_url`

#### [Step 9: Error Handling](index.js#L188)
- Catch any errors during execution
- Set workflow as failed with error message

#### Helper Modules Used:

**[common.js](common.js#L11)**
- `execute(command)` - Executes shell commands asynchronously
- Logs command and output
- Throws error if command fails

**[checkSources.js](checkSources.js#L30)**
- `detectLanguage()` - Detects Go or Node.js project
- `checkFirstCommentInSources()` - Validates copyright headers
- `checkGoMod()` - Validates go.mod (no local replaces)
- `getSourceFiles()` - Recursively finds .go and .js files

**[rejectHiddenFolders.js](rejectHiddenFolders.js#L15)**
- Validates hidden folders
- Allows: .git, .github, .husky, .augment
- Rejects: any other hidden folders

**[publish.js](publish.js#L52)**
- `publishAsRelease()` - Creates GitHub release
- Generates version from UTC timestamp
- Creates zip file from asset
- Uploads to GitHub release
- Uploads deploy.txt with download URL
- Deletes old releases (keeps N versions)

---

## 2. Pull Request on Storage Paths (pkg/istorage, pkg/vvm/storage, pkg/elections)

**Trigger:** `pull_request_target` on storage paths
**File:** `voedger/.github/workflows/ci-pkg-storage.yml`

### Execution Flow

PR Created/Updated on storage paths
    ↓
ci-pkg-storage.yml triggered
    ↓
Job: determine_changes [.github/workflows/ci-pkg-storage.yml#L19](.github/workflows/ci-pkg-storage.yml#L19)
    ├─ [Install GitHub CLI](.github/workflows/ci-pkg-storage.yml#L34)
    ├─ [Get changed files in PR](.github/workflows/ci-pkg-storage.yml#L37)
    │  └─ Outputs: cas_changed, amazon_changed, others_changed, ttlstorage_changed, elections_changed
    └─ Outputs used by downstream jobs
    ↓
Job: trigger_cas [.github/workflows/ci-pkg-storage.yml#L145](.github/workflows/ci-pkg-storage.yml#L145) [depends on determine_changes]
    ├─ Condition: If CAS or TTL/Elections changed [.github/workflows/ci-pkg-storage.yml#L147](.github/workflows/ci-pkg-storage.yml#L147)
    ├─ Uses: ./.github/workflows/ci_cas.yml (local)
    └─ Steps in ci_cas.yml:
       ├─ [Checkout](.github/workflows/ci_cas.yml#L35)
       ├─ [Set up Go (stable)](.github/workflows/ci_cas.yml#L38)
       ├─ [Cache Go modules](.github/workflows/ci_cas.yml#L33)
       ├─ [Run Cassandra tests](.github/workflows/ci_cas.yml#L41)
       │  └─ Working dir: pkg/istorage/cas
       │  └─ Env: CASSANDRA_TESTS_ENABLED=true
       ├─ [Run TTL/Elections tests](.github/workflows/ci_cas.yml#L47)
       │  └─ Working dir: pkg/vvm/storage
       │  └─ Env: CASSANDRA_TESTS_ENABLED=true
       ├─ [Set failure URL](.github/workflows/ci_cas.yml#L54)
       └─ [On failure] [Create issue](.github/workflows/ci_cas.yml#L68)
          └─ Uses: untillpro/ci-action/.github/workflows/create_issue.yml@main
          └─ Script: ci-action/scripts/createissue.sh
    ↓
Job: trigger_amazon [.github/workflows/ci-pkg-storage.yml#L164](.github/workflows/ci-pkg-storage.yml#L164) [depends on determine_changes]
    ├─ Condition: If Amazon or TTL/Elections changed [.github/workflows/ci-pkg-storage.yml#L166](.github/workflows/ci-pkg-storage.yml#L166)
    ├─ Uses: ./.github/workflows/ci_amazon.yml (local)
    └─ Steps in ci_amazon.yml:
       ├─ [Checkout](.github/workflows/ci_amazon.yml#L35)
       ├─ [Set up Go (stable)](.github/workflows/ci_amazon.yml#L38)
       ├─ [Run Amazon DynamoDB tests](.github/workflows/ci_amazon.yml#L43)
       │  └─ Working dir: pkg/istorage/amazondb
       │  └─ Service: amazon/dynamodb-local on port 8000
       │  └─ Env: DYNAMODB_TESTS_ENABLED=true
       ├─ [Run TTL/Elections tests](.github/workflows/ci_amazon.yml#L53)
       │  └─ Working dir: pkg/vvm/storage
       │  └─ Env: DYNAMODB_TESTS_ENABLED=true
       ├─ [Set failure URL](.github/workflows/ci_amazon.yml#L63)
       └─ [On failure] [Create issue](.github/workflows/ci_amazon.yml#L68)
          └─ Uses: untillpro/ci-action/.github/workflows/create_issue.yml@main
    ↓
Job: auto-merge-pr [.github/workflows/ci-pkg-storage.yml#L183](.github/workflows/ci-pkg-storage.yml#L183) [depends on determine_changes, trigger_cas, trigger_amazon]
    ├─ Condition: If tests pass [.github/workflows/ci-pkg-storage.yml#L191](.github/workflows/ci-pkg-storage.yml#L191)
    ├─ Uses: ./.github/workflows/merge.yml (local)
    └─ Steps: Merge PR via domergepr.sh

### Key Files Involved
- **voedger:** `ci-pkg-storage.yml`, `ci_cas.yml`, `ci_amazon.yml`, `merge.yml`
- **ci-action:** `createissue.sh`, `domergepr.sh`

---

## 3. Push to main on pkg-cmd

**Trigger:** `push` to `main` branch (paths-ignore: `pkg/istorage/**`)
**File:** `voedger/.github/workflows/ci-pkg-cmd.yml`

### Execution Flow

Commit pushed to main (pkg-cmd)
    ↓
ci-pkg-cmd.yml triggered
    ↓
Job: call-workflow-ci-pkg [.github/workflows/ci-pkg-cmd.yml#L11](.github/workflows/ci-pkg-cmd.yml#L11)
    ├─ Uses: untillpro/ci-action/.github/workflows/ci_reuse_go.yml@main
    ├─ Inputs:
    │  ├─ test_folder: "pkg"
    │  ├─ short_test: "true"
    │  ├─ ignore_build: "true"
    │  └─ test_subfolders: "true"
    │
    └─ Steps: Same as ci_reuse_go_pr.yml but without cancelworkflow
       ├─ [Checkout](.github/workflows/ci_reuse_go.yml#L42)
       ├─ [Set up Go 1.24](.github/workflows/ci_reuse_go.yml#L45)
       ├─ [Install TinyGo](.github/workflows/ci_reuse_go.yml#L52)
       ├─ [Check PR file size](.github/workflows/ci_reuse_go.yml#L57)
       ├─ [Cache Go modules](.github/workflows/ci_reuse_go.yml#L64)
       ├─ [Run CI action](.github/workflows/ci_reuse_go.yml#L72)
       ├─ [Test subfolders](.github/workflows/ci_reuse_go.yml#L85)
       ├─ [Check copyright](.github/workflows/ci_reuse_go.yml#L94)
       └─ [Run linters](.github/workflows/ci_reuse_go.yml#L97)
    ↓
Job: build [.github/workflows/ci-pkg-cmd.yml#L26](.github/workflows/ci-pkg-cmd.yml#L26)
    ├─ [Set Ignore Build BP3](.github/workflows/ci-pkg-cmd.yml#L34)
    └─ Output: ibp3 flag
    ↓
Job: call-workflow-cd_voeger [.github/workflows/ci-pkg-cmd.yml#L43](.github/workflows/ci-pkg-cmd.yml#L43) [depends on build]
    ├─ Condition: If voedger/voedger repo [.github/workflows/ci-pkg-cmd.yml#L45](.github/workflows/ci-pkg-cmd.yml#L45)
    ├─ Uses: voedger/voedger/.github/workflows/cd-voedger.yml@main
    └─ Steps in cd-voedger.yml:
       ├─ [Checkout](../voedger/.github/workflows/cd-voedger.yml#L21)
       ├─ [Set up Go (stable)](../voedger/.github/workflows/cd-voedger.yml#L24)
       ├─ [Build executable](../voedger/.github/workflows/cd-voedger.yml#L30)
       │  └─ Command: go build -o ./cmd/voedger ./cmd/voedger
       ├─ [Log in to Docker Hub](../voedger/.github/workflows/cd-voedger.yml#L40)
       ├─ [Build and push Docker image](../voedger/.github/workflows/cd-voedger.yml#L46)
       │  └─ Tag: voedger/voedger:0.0.1-alpha
       └─ Env: GOPRIVATE, CGO_ENABLED=0

### Key Files Involved
- **voedger:** `ci-pkg-cmd.yml`, `cd-voedger.yml`
- **ci-action:** `ci_reuse_go.yml`, `checkPR.sh`, `test_subfolders_full.sh`, `check_copyright.sh`, `gbash.sh`

---

## 4. Daily Scheduled Test Suite (5 AM UTC)

**Trigger:** `schedule` cron `0 5 * * *` or `workflow_dispatch`
**File:** `voedger/.github/workflows/ci-full.yml`

### Execution Flow

Daily 5 AM UTC or Manual Trigger
    ↓
ci-full.yml triggered
    ↓
Job: call-workflow-ci [.github/workflows/ci-full.yml#L9](.github/workflows/ci-full.yml#L9)
    ├─ Uses: untillpro/ci-action/.github/workflows/ci_reuse_go.yml@main
    ├─ Inputs:
    │  ├─ go_race: "true"
    │  ├─ short_test: "false"
    │  ├─ test_subfolders: "true"
    │  └─ ignore_build: "true"
    │
    └─ Steps: Full CI with race detector
       ├─ [Checkout](.github/workflows/ci_reuse_go.yml#L42)
       ├─ [Set up Go 1.24](.github/workflows/ci_reuse_go.yml#L45)
       ├─ [Install TinyGo](.github/workflows/ci_reuse_go.yml#L52)
       ├─ [Check PR file size](.github/workflows/ci_reuse_go.yml#L57)
       ├─ [Cache Go modules](.github/workflows/ci_reuse_go.yml#L64)
       ├─ [Run CI action](.github/workflows/ci_reuse_go.yml#L72)
       ├─ [Test subfolders](.github/workflows/ci_reuse_go.yml#L85)
       ├─ [Check copyright](.github/workflows/ci_reuse_go.yml#L94)
       └─ [Run linters](.github/workflows/ci_reuse_go.yml#L97)
    ↓
Job: notify_failure [.github/workflows/ci-full.yml#L23](.github/workflows/ci-full.yml#L23) [depends on call-workflow-ci]
    ├─ Condition: If CI failed [.github/workflows/ci-full.yml#L25](.github/workflows/ci-full.yml#L25)
    └─ [Set Failure URL Output](.github/workflows/ci-full.yml#L30)
    ↓
Job: call-workflow-create-issue [.github/workflows/ci-full.yml#L34](.github/workflows/ci-full.yml#L34) [depends on notify_failure]
    ├─ Condition: If CI failed [.github/workflows/ci-full.yml#L36](.github/workflows/ci-full.yml#L36)
    ├─ Uses: untillpro/ci-action/.github/workflows/create_issue.yml@main
    ├─ Inputs:
    │  ├─ repo: "voedger/voedger"
    │  ├─ assignee: "host6"
    │  ├─ name: "Daily Test failed on"
    │  ├─ body: failure_url
    │  └─ label: "prty/blocker"
    │
    └─ Steps in create_issue.yml:
       ├─ [Checkout](../ci-action/.github/workflows/create_issue.yml#L32)
       └─ [Create issue](../ci-action/.github/workflows/create_issue.yml#L35)
          └─ Script: ci-action/scripts/createissue.sh
    ↓
Job: call-workflow-vulncheck [.github/workflows/ci-full.yml#L47](.github/workflows/ci-full.yml#L47) [depends on call-workflow-ci]
    ├─ Uses: voedger/voedger/.github/workflows/ci-vulncheck.yml@main
    └─ Steps in ci-vulncheck.yml:
       ├─ [Set up Go (stable, check-latest)](../voedger/.github/workflows/ci-vulncheck.yml#L11)
       ├─ [Checkout](../voedger/.github/workflows/ci-vulncheck.yml#L18)
       ├─ [Install govulncheck](../voedger/.github/workflows/ci-vulncheck.yml#L21)
       └─ [Run vulnerability check](../voedger/.github/workflows/ci-vulncheck.yml#L21)
          └─ Script: ci-action/scripts/execgovuln.sh
    ↓
Job: call-workflow-cd-voeger [.github/workflows/ci-full.yml#L50](.github/workflows/ci-full.yml#L50) [depends on call-workflow-vulncheck]
    ├─ Condition: If voedger/voedger repo [.github/workflows/ci-full.yml#L52](.github/workflows/ci-full.yml#L52)
    ├─ Uses: voedger/voedger/.github/workflows/cd-voedger.yml@main
    └─ Steps: Build and push Docker image (same as ci-pkg-cmd.yml)

### Key Files Involved
- **voedger:** `ci-full.yml`, `ci-vulncheck.yml`, `cd-voedger.yml`
- **ci-action:** `ci_reuse_go.yml`, `create_issue.yml`, `createissue.sh`, `execgovuln.sh`

---

## 5. Manual Trigger: ctool Integration Test

**Trigger:** `workflow_dispatch` with cluster_type input (n1, n5, SE3)
**File:** `voedger/.github/workflows/ctool-integration-test.yml`

### Execution Flow

Manual Trigger with cluster_type
    ↓
ctool-integration-test.yml triggered
    ↓
Job: deploy [.github/workflows/ctool-integration-test.yml#L25](.github/workflows/ctool-integration-test.yml#L25)
    ├─ [Checkout](.github/workflows/ctool-integration-test.yml#L44)
    ├─ [Configure AWS credentials](.github/workflows/ctool-integration-test.yml#L47)
    ├─ [Create Infrastructure](.github/workflows/ctool-integration-test.yml#L54)
    │  └─ Uses: ./.github/actions/infrastructure-create-action
    │  └─ Steps:
    │     ├─ [Setup Terraform](.github/actions/infrastructure-create-action/action.yml#L17)
    │     ├─ [Terraform init](.github/actions/infrastructure-create-action/action.yml#L22)
    │     ├─ [Terraform plan](.github/actions/infrastructure-create-action/action.yml#L26)
    │     └─ [Terraform apply](.github/actions/infrastructure-create-action/action.yml#L30)
    ├─ [Setup SSH](.github/workflows/ctool-integration-test.yml#L64)
    ├─ [Load environment](.github/workflows/ctool-integration-test.yml#L69)
    ├─ [Init Cluster](.github/workflows/ctool-integration-test.yml#L89)
    │  ├─ If n1: [Direct SSH command](.github/workflows/ctool-integration-test.yml#L91)
    │  ├─ If n5: [Uses cluster-init-action](.github/workflows/ctool-integration-test.yml#L99)
    │  └─ If SE3: [Uses cluster-init-action](.github/workflows/ctool-integration-test.yml#L104)
    │     └─ Steps in cluster-init-action:
    │        └─ [SSH command with error handling](.github/actions/cluster-init-action/action.yml#L18)
    ├─ [Run Voedger Cluster Tests](.github/workflows/ctool-integration-test.yml#L109)
    │  ├─ If n1: [Uses ce-test-action](.github/workflows/ctool-integration-test.yml#L111)
    │  └─ If n5/SE3: [Uses cluster-test-action](.github/workflows/ctool-integration-test.yml#L118)
    │     └─ Steps in ce-test-action:
    │        ├─ [Smoke test - wait for db](.github/actions/ce-test-action/action.yml#L12)
    │        ├─ [Backup and restore](.github/actions/ce-test-action/action.yml#L34)
    │        ├─ [Check voedger CE status](.github/actions/ce-test-action/action.yml#L37)
    │        ├─ [Set Mon password](.github/actions/ce-test-action/action.yml#L41)
    │        ├─ [Check Prometheus/Alertmanager](.github/actions/ce-test-action/action.yml#L47)
    │        ├─ [Add ACME domain](.github/actions/ce-test-action/action.yml#L51)
    │        ├─ [Check HTTPS status](.github/actions/ce-test-action/action.yml#L59)
    │        └─ [Check Mon HTTPS status](.github/actions/ce-test-action/action.yml#L63)
    └─ [Terraform destroy](.github/workflows/ctool-integration-test.yml#L123)
    ↓
Job: upgrade [.github/workflows/ctool-integration-test.yml#L135](.github/workflows/ctool-integration-test.yml#L135) [depends on deploy]
    ├─ [Checkout](.github/workflows/ctool-integration-test.yml#L156)
    ├─ [Configure AWS credentials](.github/workflows/ctool-integration-test.yml#L159)
    ├─ [Create Infrastructure](.github/workflows/ctool-integration-test.yml#L166)
    ├─ [Setup SSH](.github/workflows/ctool-integration-test.yml#L176)
    ├─ [Load environment](.github/workflows/ctool-integration-test.yml#L181)
    ├─ [Init Cluster](.github/workflows/ctool-integration-test.yml#L201)
    ├─ [Wait for db cluster](.github/workflows/ctool-integration-test.yml#L221)
    ├─ [Upgrade Voedger Cluster](.github/workflows/ctool-integration-test.yml#L264)
    ├─ [Add ACME domain](.github/workflows/ctool-integration-test.yml#L294)
    ├─ [Run Voedger Cluster Tests](.github/workflows/ctool-integration-test.yml#L302)
    └─ [Terraform destroy](.github/workflows/ctool-integration-test.yml#L316)

### Key Files Involved
- **voedger:** `ctool-integration-test.yml`, `infrastructure-create-action/action.yml`, `cluster-init-action/action.yml`, `ce-test-action/action.yml`, `cluster-test-action/action.yml`, `cluster-backup-action/action.yml`

---

## 6. Issue Events

### Issue Closed
**File:** `voedger/.github/workflows/linkIssue.yml`

Issue closed
    ↓
linkIssue.yml triggered
    ↓
Job: link [.github/workflows/linkIssue.yml#L8](.github/workflows/linkIssue.yml#L8)
    └─ [Link issue to milestone](.github/workflows/linkIssue.yml#L12)
       └─ Script: ci-action/scripts/linkmilestone.sh
       └─ Env: GH_TOKEN, repo, issue

### Issue Reopened
**File:** `voedger/.github/workflows/unlinkIssue.yml`

Issue reopened
    ↓
unlinkIssue.yml triggered
    ↓
Job: unlink [.github/workflows/unlinkIssue.yml#L8](.github/workflows/unlinkIssue.yml#L8)
    └─ [Unlink issue from milestone](.github/workflows/unlinkIssue.yml#L12)
       └─ Script: ci-action/scripts/unlinkmilestone.sh
       └─ Env: GH_TOKEN, repo, issue

### Issue Opened (cprc/cprelease)
**File:** `voedger/.github/workflows/cp.yml`

Issue opened with title starting with cprc or cprelease
    ↓
cp.yml triggered
    ↓
Job: cherry-pick [.github/workflows/cp.yml#L8](.github/workflows/cp.yml#L8)
    ├─ Condition: Title starts with cprc or cprelease [.github/workflows/cp.yml#L9](.github/workflows/cp.yml#L9)
    ├─ Uses: untillpro/ci-action/.github/workflows/cp.yml@main
    └─ Inputs: org, repo, team, user, issue, issue-title, issue-body

---

## Summary of Repositories and Files

### voedger Repository
- **Workflows:** `.github/workflows/*.yml`
- **Custom Actions:** `.github/actions/*/action.yml`
- **Scripts:** `.github/scripts/*.sh`

### ci-action Repository (untillpro/ci-action)
- **Reusable Workflows:** `.github/workflows/*.yml`
- **Bash Scripts:** `scripts/*.sh`
- **Main Action:** `action.yml` (used as `untillpro/ci-action@main`)

