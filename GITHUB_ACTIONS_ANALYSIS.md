# GitHub Actions and CI/CD Workflow Analysis

## Overview
This document maps GitHub events to their triggered actions, steps, and involved files across the `voedger` and `ci-action` repositories.

---

## GitHub Event: Pull Request (pull_request_target)

### Event: Pull Request on `.github/workflows/**` paths
**File:** [`voedger/.github/workflows/ci-wf_pr.yml`](../voedger/.github/workflows/ci-wf_pr.yml#L1)

- **Trigger:** `pull_request_target` on `.github/workflows/**`
- **Action 1:** [`Auto-merge PR`](../voedger/.github/workflows/ci-wf_pr.yml#L10)
  - Calls: `voedger/.github/workflows/merge.yml@main`
  - Steps in merge.yml:
    - [`Merge PR`](../voedger/.github/workflows/merge.yml#L15) using bash script from ci-action
    - Script: `ci-action/scripts/domergepr.sh`

---

### Event: Pull Request on pkg-cmd (excluding pkg/istorage)
**File:** [`voedger/.github/workflows/ci-pkg-cmd_pr.yml`](../voedger/.github/workflows/ci-pkg-cmd_pr.yml#L1)

- **Trigger:** `pull_request_target` (paths-ignore: `pkg/istorage/**`)
- **Action 1:** [`CI pkg-cmd PR`](../voedger/.github/workflows/ci-pkg-cmd_pr.yml#L9)
  - Calls: `untillpro/ci-action/.github/workflows/ci_reuse_go_pr.yml@main`
  - Steps in ci_reuse_go_pr.yml:
    - [`Set up Go 1.24`](../ci-action/.github/workflows/ci_reuse_go_pr.yml#L42)
    - [`Install TinyGo 0.37.0`](../ci-action/.github/workflows/ci_reuse_go_pr.yml#L49)
    - [`Checkout PR head commit`](../ci-action/.github/workflows/ci_reuse_go_pr.yml#L54)
    - [`Check PR file size`](../ci-action/.github/workflows/ci_reuse_go_pr.yml#L60): `ci-action/scripts/checkPR.sh`
    - [`Cancel other workflows`](../ci-action/.github/workflows/ci_reuse_go_pr.yml#L66): `ci-action/scripts/cancelworkflow.sh`
    - [`Cache Go modules`](../ci-action/.github/workflows/ci_reuse_go_pr.yml#L74)
    - [`Run CI action`](../ci-action/.github/workflows/ci_reuse_go_pr.yml#L82): `untillpro/ci-action@main`
    - [`Test subfolders`](../ci-action/.github/workflows/ci_reuse_go_pr.yml#L95): `ci-action/scripts/test_subfolders.sh`
    - [`Check copyright`](../ci-action/.github/workflows/ci_reuse_go_pr.yml#L100): `ci-action/scripts/check_copyright.sh`
    - [`Run linters`](../ci-action/.github/workflows/ci_reuse_go_pr.yml#L103): `ci-action/scripts/gbash.sh`

- **Action 2:** [`Auto-merge PR`](../voedger/.github/workflows/ci-pkg-cmd_pr.yml#L25)
  - Calls: `./.github/workflows/merge.yml` (local)
  - Depends on: `call-workflow-ci-pkg`

---

### Event: Pull Request on pkg/istorage, pkg/vvm/storage, pkg/elections
**File:** [`voedger/.github/workflows/ci-pkg-storage.yml`](../voedger/.github/workflows/ci-pkg-storage.yml#L1)

- **Trigger:** `pull_request_target` on storage-related paths
- **Action 1:** [`Determine changes`](../voedger/.github/workflows/ci-pkg-storage.yml#L19)
  - Analyzes which storage backend changed (CAS, Amazon, TTL, Elections)
  - Outputs: `cas_changed`, `amazon_changed`, `others_changed`, `ttlstorage_changed`, `elections_changed`

- **Action 2:** [`Trigger CAS tests`](../voedger/.github/workflows/ci-pkg-storage.yml#L145) (conditional)
  - Calls: `./.github/workflows/ci_cas.yml` (local)
  - Steps in ci_cas.yml:
    - [`Checkout repository`](../voedger/.github/workflows/ci_cas.yml#L35)
    - [`Set up Go (stable)`](../voedger/.github/workflows/ci_cas.yml#L38)
    - [`Cache Go modules`](../voedger/.github/workflows/ci_cas.yml#L33)
    - [`Run Cassandra tests`](../voedger/.github/workflows/ci_cas.yml#L41): `pkg/istorage/cas` with `CASSANDRA_TESTS_ENABLED=true`
    - [`Run TTL/Elections tests`](../voedger/.github/workflows/ci_cas.yml#L47): `pkg/vvm/storage` with `CASSANDRA_TESTS_ENABLED=true`
    - [`Set failure URL`](../voedger/.github/workflows/ci_cas.yml#L54) if failed
  - On failure: [`Create issue`](../voedger/.github/workflows/ci_cas.yml#L68) via `untillpro/ci-action/.github/workflows/create_issue.yml@main`
    - Script: `ci-action/scripts/createissue.sh`

- **Action 3:** [`Trigger Amazon tests`](../voedger/.github/workflows/ci-pkg-storage.yml#L164) (conditional)
  - Calls: `./.github/workflows/ci_amazon.yml` (local)
  - Steps in ci_amazon.yml:
    - [`Checkout repository`](../voedger/.github/workflows/ci_amazon.yml#L35)
    - [`Set up Go (stable)`](../voedger/.github/workflows/ci_amazon.yml#L38)
    - [`Run Amazon DynamoDB tests`](../voedger/.github/workflows/ci_amazon.yml#L43): `pkg/istorage/amazondb` with `DYNAMODB_TESTS_ENABLED=true`
    - [`Run TTL/Elections tests`](../voedger/.github/workflows/ci_amazon.yml#L53): `pkg/vvm/storage` with `DYNAMODB_TESTS_ENABLED=true`
    - [`Set failure URL`](../voedger/.github/workflows/ci_amazon.yml#L63) if failed
  - On failure: [`Create issue`](../voedger/.github/workflows/ci_amazon.yml#L68) via `untillpro/ci-action/.github/workflows/create_issue.yml@main`

- **Action 4:** [`Auto-merge PR`](../voedger/.github/workflows/ci-pkg-storage.yml#L183) (conditional)
  - Calls: `./.github/workflows/merge.yml` (local)
  - Depends on: `determine_changes`, `trigger_cas`, `trigger_amazon`

---

## GitHub Event: Push to main branch

### Event: Push on pkg-cmd (excluding pkg/istorage)
**File:** [`voedger/.github/workflows/ci-pkg-cmd.yml`](../voedger/.github/workflows/ci-pkg-cmd.yml#L1)

- **Trigger:** `push` to `main` branch (paths-ignore: `pkg/istorage/**`)
- **Action 1:** [`CI pkg-cmd`](../voedger/.github/workflows/ci-pkg-cmd.yml#L11)
  - Calls: `untillpro/ci-action/.github/workflows/ci_reuse_go.yml@main`
  - Steps: Same as PR workflow (see ci_reuse_go.yml above)

- **Action 2:** [`Set Ignore Build BP3`](../voedger/.github/workflows/ci-pkg-cmd.yml#L26)
  - Outputs: `ibp3` flag

- **Action 3:** [`CD voedger`](../voedger/.github/workflows/ci-pkg-cmd.yml#L43)
  - Calls: `voedger/voedger/.github/workflows/cd-voedger.yml@main`
  - Steps in cd-voedger.yml:
    - [`Checkout`](../voedger/.github/workflows/cd-voedger.yml#L21)
    - [`Set up Go (stable)`](../voedger/.github/workflows/cd-voedger.yml#L24)
    - [`Build executable`](../voedger/.github/workflows/cd-voedger.yml#L30): `go build -o ./cmd/voedger ./cmd/voedger`
    - [`Log in to Docker Hub`](../voedger/.github/workflows/cd-voedger.yml#L40)
    - [`Build and push Docker image`](../voedger/.github/workflows/cd-voedger.yml#L46): `voedger/voedger:0.0.1-alpha`

---

### Event: Push on pkg/istorage, pkg/vvm/storage, pkg/elections
**File:** [`voedger/.github/workflows/ci-pkg-storage.yml`](../voedger/.github/workflows/ci-pkg-storage.yml#L1)

- **Trigger:** `push` to paths
- **Action 1:** Determine changes (same as PR)
- **Action 2:** Trigger CAS tests (conditional)
- **Action 3:** Trigger Amazon tests (conditional)
- **Action 4:** Auto-merge PR (conditional)

---

## GitHub Event: Scheduled (Daily)

### Event: Daily test suite (5 AM UTC)
**File:** [`voedger/.github/workflows/ci-full.yml`](../voedger/.github/workflows/ci-full.yml#L1)

- **Trigger:** `schedule` cron `0 5 * * *` or `workflow_dispatch`
- **Action 1:** [`Call CI workflow`](../voedger/.github/workflows/ci-full.yml#L9)
  - Calls: `untillpro/ci-action/.github/workflows/ci_reuse_go.yml@main`
  - With: `go_race=true`, `short_test=false`, `test_subfolders=true`

- **Action 2:** [`Notify failure`](../voedger/.github/workflows/ci-full.yml#L23) (if failed)
  - Sets failure URL output

- **Action 3:** [`Create issue`](../voedger/.github/workflows/ci-full.yml#L34) (if failed)
  - Calls: `untillpro/ci-action/.github/workflows/create_issue.yml@main`
  - Assignee: `host6`
  - Label: `prty/blocker`

- **Action 4:** [`Vulnerability check`](../voedger/.github/workflows/ci-full.yml#L47)
  - Calls: `voedger/voedger/.github/workflows/ci-vulncheck.yml@main`
  - Steps in ci-vulncheck.yml:
    - [`Set up Go (stable, check-latest)`](../voedger/.github/workflows/ci-vulncheck.yml#L11)
    - [`Checkout`](../voedger/.github/workflows/ci-vulncheck.yml#L18)
    - [`Install govulncheck`](../voedger/.github/workflows/ci-vulncheck.yml#L21)
    - [`Run`](../voedger/.github/workflows/ci-vulncheck.yml#L21): `ci-action/scripts/execgovuln.sh`

- **Action 5:** [`CD voedger`](../voedger/.github/workflows/ci-full.yml#L50)
  - Calls: `voedger/voedger/.github/workflows/cd-voedger.yml@main`
  - Depends on: `call-workflow-vulncheck`

---

## GitHub Event: Issue Closed

### Event: Issue closed
**File:** [`voedger/.github/workflows/linkIssue.yml`](../voedger/.github/workflows/linkIssue.yml#L1)

- **Trigger:** `issues` type `closed`
- **Action 1:** [`Link issue to milestone`](../voedger/.github/workflows/linkIssue.yml#L12)
  - Script: `ci-action/scripts/linkmilestone.sh`

---

## GitHub Event: Issue Reopened

### Event: Issue reopened
**File:** [`voedger/.github/workflows/unlinkIssue.yml`](../voedger/.github/workflows/unlinkIssue.yml#L1)

- **Trigger:** `issues` type `reopened`
- **Action 1:** [`Unlink issue from milestone`](../voedger/.github/workflows/unlinkIssue.yml#L12)
  - Script: `ci-action/scripts/unlinkmilestone.sh`

---

## GitHub Event: Issue Opened

### Event: Issue opened with cprc or cprelease prefix
**File:** [`voedger/.github/workflows/cp.yml`](../voedger/.github/workflows/cp.yml#L1)

- **Trigger:** `issues` type `opened` with title starting with `cprc` or `cprelease`
- **Action 1:** [`Cherry-pick commits`](../voedger/.github/workflows/cp.yml#L8)
  - Calls: `untillpro/ci-action/.github/workflows/cp.yml@main`

---

## GitHub Event: Manual Trigger (workflow_dispatch)

### Event: ctool integration test
**File:** [`voedger/.github/workflows/ctool-integration-test.yml`](../voedger/.github/workflows/ctool-integration-test.yml#L1)

- **Trigger:** `workflow_dispatch` with cluster_type input (n1, n5, SE3)
- **Job 1: Deploy** ([lines 25-133](../voedger/.github/workflows/ctool-integration-test.yml#L25))
  - Action 1: [`Checkout`](../voedger/.github/workflows/ctool-integration-test.yml#L44)
  - Action 2: [`Configure AWS credentials`](../voedger/.github/workflows/ctool-integration-test.yml#L47)
  - Action 3: [`Create Infrastructure`](../voedger/.github/workflows/ctool-integration-test.yml#L54)
    - Uses: `./.github/actions/infrastructure-create-action`
    - Steps: Terraform init, plan, apply
  - Action 4: [`Setup SSH`](../voedger/.github/workflows/ctool-integration-test.yml#L64)
  - Action 5: [`Load environment`](../voedger/.github/workflows/ctool-integration-test.yml#L69)
  - Action 6: [`Init Cluster`](../voedger/.github/workflows/ctool-integration-test.yml#L89) (CE/SE/SE3)
  - Action 7: [`Run Voedger Cluster Tests`](../voedger/.github/workflows/ctool-integration-test.yml#L109)
    - Uses: `./.github/actions/ce-test-action` or `./.github/actions/cluster-test-action`
  - Action 8: [`Terraform destroy`](../voedger/.github/workflows/ctool-integration-test.yml#L123)

- **Job 2: Upgrade** ([lines 135-327](../voedger/.github/workflows/ctool-integration-test.yml#L135))
  - Similar to Deploy but includes upgrade steps
  - Runs after Deploy job

---

## CI-Action Repository Workflows

### Reusable Workflow: ci_reuse_go.yml
**File:** [`ci-action/.github/workflows/ci_reuse_go.yml`](../ci-action/.github/workflows/ci_reuse_go.yml#L1)

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
**File:** [`ci-action/.github/workflows/ci_reuse_go_pr.yml`](../ci-action/.github/workflows/ci_reuse_go_pr.yml#L1)

- **Type:** `workflow_call` (reusable)
- **Similar to:** `ci_reuse_go.yml` but for PR context
- **Additional steps:**
  - Checkout PR head commit
  - Cancel other workflows: `scripts/cancelworkflow.sh`

### Reusable Workflow: create_issue.yml
**File:** [`ci-action/.github/workflows/create_issue.yml`](../ci-action/.github/workflows/create_issue.yml#L1)

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

