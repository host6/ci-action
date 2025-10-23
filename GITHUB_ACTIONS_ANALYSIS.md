# GitHub Actions and CI/CD Workflow Analysis

## Pull Request Events

### Workflows PR
**File:** [ci-wf_pr.yml](../voedger/.github/workflows/ci-wf_pr.yml#L1) | **Trigger:** `pull_request_target` on `.github/workflows/**`

[Auto-merge PR](../voedger/.github/workflows/ci-wf_pr.yml#L10) → [merge.yml](../voedger/.github/workflows/merge.yml#L15)

---

### pkg-cmd PR
**File:** [ci-pkg-cmd_pr.yml](../voedger/.github/workflows/ci-pkg-cmd_pr.yml#L1) | **Trigger:** `pull_request_target`

[CI pkg-cmd PR](../voedger/.github/workflows/ci-pkg-cmd_pr.yml#L9) → [ci_reuse_go_pr.yml](../ci-action/.github/workflows/ci_reuse_go_pr.yml#L42)
1. [Setup Go](../ci-action/.github/workflows/ci_reuse_go_pr.yml#L42)
2. [TinyGo](../ci-action/.github/workflows/ci_reuse_go_pr.yml#L49)
3. [Checkout](../ci-action/.github/workflows/ci_reuse_go_pr.yml#L54)
4. [Check size](../ci-action/.github/workflows/ci_reuse_go_pr.yml#L60)
5. [Cancel](../ci-action/.github/workflows/ci_reuse_go_pr.yml#L66)
6. [Cache](../ci-action/.github/workflows/ci_reuse_go_pr.yml#L74)
7. [CI action](../ci-action/.github/workflows/ci_reuse_go_pr.yml#L82)
8. [Tests](../ci-action/.github/workflows/ci_reuse_go_pr.yml#L95)
9. [Copyright](../ci-action/.github/workflows/ci_reuse_go_pr.yml#L100)
10. [Linters](../ci-action/.github/workflows/ci_reuse_go_pr.yml#L103)

[Auto-merge PR](../voedger/.github/workflows/ci-pkg-cmd_pr.yml#L25) → [merge.yml](../voedger/.github/workflows/merge.yml#L15)

---

### Storage PR
**File:** [ci-pkg-storage.yml](../voedger/.github/workflows/ci-pkg-storage.yml#L1) | **Trigger:** `pull_request_target` on storage paths

1. [Determine changes](../voedger/.github/workflows/ci-pkg-storage.yml#L19) → [CAS/Amazon/TTL/Elections]

**If CAS/TTL changed:**
2. [Trigger CAS](../voedger/.github/workflows/ci-pkg-storage.yml#L145) → [ci_cas.yml](../voedger/.github/workflows/ci_cas.yml#L35)
   - [Checkout](../voedger/.github/workflows/ci_cas.yml#L35)
   - [Setup Go](../voedger/.github/workflows/ci_cas.yml#L38)
   - [Cassandra tests](../voedger/.github/workflows/ci_cas.yml#L41)
   - [TTL tests](../voedger/.github/workflows/ci_cas.yml#L47)

**If Amazon/TTL changed:**
3. [Trigger Amazon](../voedger/.github/workflows/ci-pkg-storage.yml#L164) → [ci_amazon.yml](../voedger/.github/workflows/ci_amazon.yml#L35)
   - [Checkout](../voedger/.github/workflows/ci_amazon.yml#L35)
   - [Setup Go](../voedger/.github/workflows/ci_amazon.yml#L38)
   - [DynamoDB tests](../voedger/.github/workflows/ci_amazon.yml#L43)
   - [TTL tests](../voedger/.github/workflows/ci_amazon.yml#L53)

4. [Auto-merge PR](../voedger/.github/workflows/ci-pkg-storage.yml#L183) → [merge.yml](../voedger/.github/workflows/merge.yml#L15)

---

## Push Events

### pkg-cmd Push
**File:** [ci-pkg-cmd.yml](../voedger/.github/workflows/ci-pkg-cmd.yml#L1) | **Trigger:** `push` to `main`

1. [CI pkg-cmd](../voedger/.github/workflows/ci-pkg-cmd.yml#L11) → [ci_reuse_go.yml](../ci-action/.github/workflows/ci_reuse_go.yml#L42)

2. [Set BP3 flag](../voedger/.github/workflows/ci-pkg-cmd.yml#L26)

3. [CD voedger](../voedger/.github/workflows/ci-pkg-cmd.yml#L43) → [cd-voedger.yml](../voedger/.github/workflows/cd-voedger.yml#L21)
   - [Checkout](../voedger/.github/workflows/cd-voedger.yml#L21)
   - [Setup Go](../voedger/.github/workflows/cd-voedger.yml#L24)
   - [Build](../voedger/.github/workflows/cd-voedger.yml#L30)
   - [Docker login](../voedger/.github/workflows/cd-voedger.yml#L40)
   - [Push image](../voedger/.github/workflows/cd-voedger.yml#L46)
---

### Storage Push
**File:** [ci-pkg-storage.yml](../voedger/.github/workflows/ci-pkg-storage.yml#L1) | **Trigger:** `push` to storage paths

[Determine changes](../voedger/.github/workflows/ci-pkg-storage.yml#L19) | [Trigger CAS](../voedger/.github/workflows/ci-pkg-storage.yml#L145) | [Trigger Amazon](../voedger/.github/workflows/ci-pkg-storage.yml#L164)

---

## Scheduled Events

### Daily Test Suite
**File:** [ci-full.yml](../voedger/.github/workflows/ci-full.yml#L1) | **Trigger:** `schedule` (5 AM UTC)

1. [Call CI](../voedger/.github/workflows/ci-full.yml#L9) → [ci_reuse_go.yml](../ci-action/.github/workflows/ci_reuse_go.yml#L42) (with race detector)

2. [Notify failure](../voedger/.github/workflows/ci-full.yml#L23) (if failed)

3. [Create issue](../voedger/.github/workflows/ci-full.yml#L34) (if failed) → [create_issue.yml](../ci-action/.github/workflows/create_issue.yml#L1)

4. [Vulnerability check](../voedger/.github/workflows/ci-full.yml#L47) → [ci-vulncheck.yml](../voedger/.github/workflows/ci-vulncheck.yml#L11)
   - [Setup Go](../voedger/.github/workflows/ci-vulncheck.yml#L11)
   - [Checkout](../voedger/.github/workflows/ci-vulncheck.yml#L18)
   - [Install govulncheck](../voedger/.github/workflows/ci-vulncheck.yml#L21)
   - [Run](../voedger/.github/workflows/ci-vulncheck.yml#L21)

5. [CD voedger](../voedger/.github/workflows/ci-full.yml#L50) → [cd-voedger.yml](../voedger/.github/workflows/cd-voedger.yml#L21)

---

## Issue Events

**Closed:** [linkIssue.yml](../voedger/.github/workflows/linkIssue.yml#L1) → [Link to milestone](../voedger/.github/workflows/linkIssue.yml#L12)

**Reopened:** [unlinkIssue.yml](../voedger/.github/workflows/unlinkIssue.yml#L1) → [Unlink from milestone](../voedger/.github/workflows/unlinkIssue.yml#L12)

**Opened (cprc/cprelease):** [cp.yml](../voedger/.github/workflows/cp.yml#L1) → [Cherry-pick](../voedger/.github/workflows/cp.yml#L8)

---

## Manual Trigger (workflow_dispatch)

### ctool Integration Test
**File:** [ctool-integration-test.yml](../voedger/.github/workflows/ctool-integration-test.yml#L1)

1. [Deploy](../voedger/.github/workflows/ctool-integration-test.yml#L25)
   - [Checkout](../voedger/.github/workflows/ctool-integration-test.yml#L44)
   - [AWS creds](../voedger/.github/workflows/ctool-integration-test.yml#L47)
   - [Terraform](../voedger/.github/workflows/ctool-integration-test.yml#L54)
   - [SSH](../voedger/.github/workflows/ctool-integration-test.yml#L64)
   - [Init cluster](../voedger/.github/workflows/ctool-integration-test.yml#L89)
   - [Tests](../voedger/.github/workflows/ctool-integration-test.yml#L109)
   - [Destroy](../voedger/.github/workflows/ctool-integration-test.yml#L123)

2. [Upgrade](../voedger/.github/workflows/ctool-integration-test.yml#L135)
   - [Checkout](../voedger/.github/workflows/ctool-integration-test.yml#L156)
   - [AWS creds](../voedger/.github/workflows/ctool-integration-test.yml#L159)
   - [Infra](../voedger/.github/workflows/ctool-integration-test.yml#L166)
   - [SSH](../voedger/.github/workflows/ctool-integration-test.yml#L176)
   - [Upgrade](../voedger/.github/workflows/ctool-integration-test.yml#L264)
   - [Tests](../voedger/.github/workflows/ctool-integration-test.yml#L302)
   - [Destroy](../voedger/.github/workflows/ctool-integration-test.yml#L316)

---

## CI-Action Repository Workflows

### Reusable Workflow: ci_reuse_go.yml
**File:** [ci-action/.github/workflows/ci_reuse_go.yml](../ci-action/.github/workflows/ci_reuse_go.yml#L1)

- **Type:** `workflow_call` (reusable)
- **Inputs:** `ignore_copyright`, `test_folder`, `ignore_bp3`, `short_test`, `go_race`, `ignore_build`, `test_subfolders`
- **Steps:**
  - Checkout
  - Set up Go 1.24
  - Install TinyGo 0.37.0
  - Check PR file size: `scripts/checkPR.sh`
  - Cache Go modules
  - Run CI action: `untillpro/ci-action@main`
  - Test subfolders: `scripts/test_subfolders.sh` or `scripts/test_subfolders_full.sh`
  - Check copyright: `scripts/check_copyright.sh`
  - Run linters: `scripts/gbash.sh`

### Reusable Workflow: ci_reuse_go_pr.yml
**File:** [ci-action/.github/workflows/ci_reuse_go_pr.yml](../ci-action/.github/workflows/ci_reuse_go_pr.yml#L1)

- **Type:** `workflow_call` (reusable)
- **Similar to:** `ci_reuse_go.yml` but for PR context
- **Additional steps:**
  - Checkout PR head commit
  - Cancel other workflows: `scripts/cancelworkflow.sh`

### Reusable Workflow: create_issue.yml
**File:** [ci-action/.github/workflows/create_issue.yml](../ci-action/.github/workflows/create_issue.yml#L1)

- **Type:** `workflow_call` (reusable)
- **Inputs:** `repo`, `assignee`, `name`, `body`, `label`
- **Steps:**
  - Checkout
  - Create issue: `scripts/createissue.sh`

---

## Key Bash Scripts in ci-action/scripts

| Script                    | Purpose                         |
|---------------------------|---------------------------------|
| `checkPR.sh`              | Check PR file size              |
| `cancelworkflow.sh`       | Cancel other running workflows  |
| `check_copyright.sh`      | Verify copyright headers        |
| `gbash.sh`                | Run linters (golangci-lint)     |
| `test_subfolders.sh`      | Run tests in subfolders (short) |
| `test_subfolders_full.sh` | Run tests in subfolders (full)  |
| `execgovuln.sh`           | Run vulnerability checks        |
| `domergepr.sh`            | Merge PR automatically          |
| `createissue.sh`          | Create GitHub issue             |
| `linkmilestone.sh`        | Link issue to milestone         |
| `unlinkmilestone.sh`      | Unlink issue from milestone     |

---

## Custom Actions in voedger/.github/actions

| Action                         | Purpose                                 | File                                                      |
|--------------------------------|-----------------------------------------|-----------------------------------------------------------|
| `infrastructure-create-action` | Create AWS infrastructure via Terraform | `.github/actions/infrastructure-create-action/action.yml` |
| `ce-test-action`               | Test Voedger CE cluster                 | `.github/actions/ce-test-action/action.yml`               |
| `cluster-init-action`          | Initialize Voedger cluster              | `.github/actions/cluster-init-action/action.yml`          |
| `cluster-test-action`          | Test Voedger SE/SE3 cluster             | `.github/actions/cluster-test-action/action.yml`          |
| `cluster-backup-action`        | Backup and restore cluster              | `.github/actions/cluster-backup-action/action.yml`        |

---

## Repository References

- **voedger:** Main repository with workflows and custom actions
- **ci-action (untillpro/ci-action):** Reusable workflows and bash scripts library
  - Referenced as: `untillpro/ci-action@main` or `untillpro/ci-action/.github/workflows/*.yml@main`

