# Quick Start Guide: GitHub Actions & CI/CD Workflows

## What You Have

Two repositories working together:

1. **voedger** - Main repository with:
   - GitHub Actions workflows (`.github/workflows/`)
   - Custom actions (`.github/actions/`)
   - Test and deployment scripts (`.github/scripts/`)

2. **ci-action** (untillpro/ci-action) - Reusable library with:
   - Reusable workflows (`.github/workflows/`)
   - Bash scripts (scripts/)
   - Main CI action (action.yml)

---

## GitHub Events & What They Trigger

### 1. Pull Request Events

#### PR on `.github/workflows/**`
- **File:** `ci-wf_pr.yml`
- **Action:** Auto-merge PR
- **Scripts:** `domergepr.sh`

#### PR on `pkg/**` (excluding `pkg/istorage/**`)
- **File:** `ci-pkg-cmd_pr.yml`
- **Actions:**
  1. Run CI tests (Go, copyright, linters)
  2. Auto-merge if tests pass
- **Scripts:** `checkPR.sh`, `cancelworkflow.sh`, `test_subfolders.sh`, `check_copyright.sh`, `gbash.sh`, `domergepr.sh`

#### PR on `pkg/istorage/**`, `pkg/vvm/storage/**`, `pkg/elections/**`
- **File:** `ci-pkg-storage.yml`
- **Actions:**
  1. Determine which storage backend changed
  2. Run Cassandra tests (if CAS changed)
  3. Run DynamoDB tests (if Amazon changed)
  4. Auto-merge if tests pass
- **Scripts:** `createissue.sh` (on failure)

### 2. Push Events

#### Push to `main` on `pkg/**` (excluding `pkg/istorage/**`)
- **File:** `ci-pkg-cmd.yml`
- **Actions:**
  1. Run CI tests
  2. Build and push Docker image
- **Docker:** `voedger/voedger:0.0.1-alpha`

#### Push to `main` on `pkg/istorage/**`, `pkg/vvm/storage/**`, `pkg/elections/**`
- **File:** `ci-pkg-storage.yml`
- **Actions:** Same as PR (Cassandra + DynamoDB tests)

### 3. Scheduled Events

#### Daily at 5 AM UTC
- **File:** `ci-full.yml`
- **Actions:**
  1. Run full CI tests with race detector
  2. Run vulnerability checks
  3. Build and push Docker image
  4. Create issue if tests fail
- **Scripts:** `execgovuln.sh`, `createissue.sh`

### 4. Issue Events

#### Issue Closed
- **File:** `linkIssue.yml`
- **Action:** Link issue to milestone
- **Script:** `linkmilestone.sh`

#### Issue Reopened
- **File:** `unlinkIssue.yml`
- **Action:** Unlink issue from milestone
- **Script:** `unlinkmilestone.sh`

#### Issue Opened (cprc/cprelease prefix)
- **File:** `cp.yml`
- **Action:** Cherry-pick commits
- **Workflow:** `untillpro/ci-action/.github/workflows/cp.yml@main`

### 5. Manual Trigger

#### ctool Integration Test
- **File:** `ctool-integration-test.yml`
- **Input:** Cluster type (n1, n5, SE3)
- **Actions:**
  1. Create AWS infrastructure (Terraform)
  2. Initialize cluster
  3. Run cluster tests
  4. Upgrade cluster
  5. Destroy infrastructure
- **Custom Actions:** `infrastructure-create-action`, `cluster-init-action`, `ce-test-action`, `cluster-test-action`, `cluster-backup-action`

---

## Key Workflows & Their Purpose

| Workflow | Trigger | Purpose | Location |
|----------|---------|---------|----------|
| `ci-wf_pr.yml` | PR on `.github/workflows/**` | Auto-merge workflow changes | voedger |
| `ci-pkg-cmd_pr.yml` | PR on `pkg/**` | Test and auto-merge pkg changes | voedger |
| `ci-pkg-storage.yml` | PR/Push on storage paths | Test storage backends | voedger |
| `ci-pkg-cmd.yml` | Push to main on `pkg/**` | Test and build Docker image | voedger |
| `ci-full.yml` | Daily 5 AM UTC | Full test suite + vulnerability check | voedger |
| `cd-voedger.yml` | Called by other workflows | Build and push Docker image | voedger |
| `ci-vulncheck.yml` | Called by ci-full.yml | Vulnerability check | voedger |
| `ci_cas.yml` | Called by ci-pkg-storage.yml | Cassandra tests | voedger |
| `ci_amazon.yml` | Called by ci-pkg-storage.yml | DynamoDB tests | voedger |
| `merge.yml` | Called by other workflows | Auto-merge PR | voedger |
| `ci_reuse_go.yml` | Called by other workflows | Reusable Go CI workflow | ci-action |
| `ci_reuse_go_pr.yml` | Called by other workflows | Reusable Go CI workflow (PR) | ci-action |
| `create_issue.yml` | Called by other workflows | Create GitHub issue | ci-action |
| `cp.yml` | Called by voedger cp.yml | Cherry-pick commits | ci-action |

---

## Key Bash Scripts

### In ci-action/scripts

| Script | Purpose | Called From |
|--------|---------|-------------|
| `checkPR.sh` | Validate PR file size | ci_reuse_go*.yml |
| `cancelworkflow.sh` | Cancel other running workflows | ci_reuse_go_pr.yml |
| `check_copyright.sh` | Verify copyright headers | ci_reuse_go*.yml |
| `gbash.sh` | Run linters (golangci-lint) | ci_reuse_go*.yml |
| `test_subfolders.sh` | Run tests in subfolders (short) | ci_reuse_go*.yml |
| `test_subfolders_full.sh` | Run tests in subfolders (full) | ci_reuse_go.yml |
| `execgovuln.sh` | Run vulnerability checks | ci-vulncheck.yml |
| `domergepr.sh` | Merge PR automatically | merge.yml |
| `createissue.sh` | Create GitHub issue | create_issue.yml |
| `linkmilestone.sh` | Link issue to milestone | linkIssue.yml |
| `unlinkmilestone.sh` | Unlink issue from milestone | unlinkIssue.yml |

---

## Custom Actions in voedger

| Action | Purpose | Used In |
|--------|---------|---------|
| `infrastructure-create-action` | Create AWS infrastructure via Terraform | ctool-integration-test.yml |
| `ce-test-action` | Test Voedger CE cluster | ctool-integration-test.yml |
| `cluster-init-action` | Initialize Voedger cluster | ctool-integration-test.yml |
| `cluster-test-action` | Test Voedger SE/SE3 cluster | ctool-integration-test.yml |
| `cluster-backup-action` | Backup and restore cluster | ce-test-action |

---

## Environment & Secrets

### Required Secrets
- `REPOREADING_TOKEN` - GitHub token for reading repos
- `PERSONAL_TOKEN` - GitHub token for personal operations
- `CODECOV_TOKEN` - Codecov integration
- `DOCKER_USERNAME` - Docker Hub credentials
- `DOCKER_PASSWORD` - Docker Hub credentials
- `AWS_SSH_KEY` - AWS SSH key
- `AWS_ACCESS_KEY_ID` - AWS credentials
- `AWS_SECRET_ACCESS_KEY` - AWS credentials

### Key Environment Variables
- `GOPRIVATE` - Go private modules
- `CGO_ENABLED` - C bindings (usually 0)
- `CASSANDRA_TESTS_ENABLED` - Enable Cassandra tests
- `DYNAMODB_TESTS_ENABLED` - Enable DynamoDB tests
- `DYNAMODB_ENDPOINT` - DynamoDB endpoint (local: http://localhost:8000)
- `AWS_REGION` - AWS region (usually eu-west-1)

---

## Common Patterns

### Pattern 1: PR Workflow
```
PR Created → Determine Changes → Run Tests → Auto-merge if Pass
```

### Pattern 2: Push Workflow
```
Push to main → Run Tests → Build Docker → Push to Registry
```

### Pattern 3: Scheduled Workflow
```
Daily 5 AM → Full Tests → Vuln Check → Build Docker → Create Issue if Fail
```

### Pattern 4: Storage Tests
```
PR/Push on storage → Determine Backend → Run CAS Tests + Amazon Tests → Merge if Pass
```

### Pattern 5: Manual Cluster Test
```
Manual Trigger → Create Infrastructure → Init Cluster → Run Tests → Upgrade → Destroy
```

---

## How to Find Information

### To find what triggers a workflow:
1. Look at the `on:` section in the workflow file
2. Check for `pull_request_target`, `push`, `schedule`, `issues`, `workflow_dispatch`

### To find what a workflow does:
1. Look at the `jobs:` section
2. Check for `uses:` (calls to other workflows)
3. Check for `run:` (inline scripts)
4. Look for `curl ... | bash` (downloads scripts from ci-action)

### To find which scripts are called:
1. Search for `curl -s https://raw.githubusercontent.com/untillpro/ci-action/` in workflow files
2. The script name is at the end of the URL

### To find dependencies between jobs:
1. Look for `needs:` in job definitions
2. Look for `if:` conditions

---

## File Locations Summary

```
voedger/
├── .github/
│   ├── workflows/
│   │   ├── ci-wf_pr.yml
│   │   ├── ci-pkg-cmd_pr.yml
│   │   ├── ci-pkg-cmd.yml
│   │   ├── ci-pkg-storage.yml
│   │   ├── ci-full.yml
│   │   ├── cd-voedger.yml
│   │   ├── ci-vulncheck.yml
│   │   ├── ci_cas.yml
│   │   ├── ci_amazon.yml
│   │   ├── merge.yml
│   │   ├── linkIssue.yml
│   │   ├── unlinkIssue.yml
│   │   ├── cp.yml
│   │   └── ctool-integration-test.yml
│   ├── actions/
│   │   ├── infrastructure-create-action/
│   │   ├── ce-test-action/
│   │   ├── cluster-init-action/
│   │   ├── cluster-test-action/
│   │   └── cluster-backup-action/
│   └── scripts/
│       ├── voedger_ce_status.sh
│       ├── mon_password_set.sh
│       ├── mon_ce_status.sh
│       └── ...

ci-action/
├── .github/
│   ├── workflows/
│   │   ├── ci_reuse_go.yml
│   │   ├── ci_reuse_go_pr.yml
│   │   ├── create_issue.yml
│   │   ├── cp.yml
│   │   └── ...
│   └── scripts/
│       ├── checkPR.sh
│       ├── cancelworkflow.sh
│       ├── check_copyright.sh
│       ├── gbash.sh
│       ├── test_subfolders.sh
│       ├── test_subfolders_full.sh
│       ├── execgovuln.sh
│       ├── domergepr.sh
│       ├── createissue.sh
│       ├── linkmilestone.sh
│       ├── unlinkmilestone.sh
│       └── ...
└── action.yml (main CI action)
```

---

## Next Steps

1. **Read GITHUB_ACTIONS_ANALYSIS.md** for detailed event-to-action mapping
2. **Read WORKFLOW_REFERENCE_TABLE.md** for quick lookup tables
3. **Read DETAILED_WORKFLOW_FLOWS.md** for step-by-step execution flows
4. **Check specific workflow files** for implementation details

