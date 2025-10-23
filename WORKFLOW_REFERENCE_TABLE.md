# GitHub Actions Workflow Reference Table

## Quick Reference: GitHub Events → Workflows → Scripts

### Pull Request Events

| Event Trigger | Workflow File | Line | Condition | Called Workflow | Scripts/Actions |
|---|---|---|---|---|---|
| PR on `.github/workflows/**` | `voedger/.github/workflows/ci-wf_pr.yml` | 10 | `pull_request_target` | `merge.yml@main` | `domergepr.sh` |
| PR on pkg-cmd (not pkg/istorage) | `voedger/.github/workflows/ci-pkg-cmd_pr.yml` | 11 | `pull_request_target` | `ci_reuse_go_pr.yml@main` | `checkPR.sh`, `cancelworkflow.sh`, `test_subfolders.sh`, `check_copyright.sh`, `gbash.sh` |
| PR on pkg-cmd (not pkg/istorage) | `voedger/.github/workflows/ci-pkg-cmd_pr.yml` | 27 | After CI passes | `merge.yml` (local) | `domergepr.sh` |
| PR on storage paths | `voedger/.github/workflows/ci-pkg-storage.yml` | 19 | `pull_request_target` | (local job) | GitHub CLI |
| PR on storage - CAS | `voedger/.github/workflows/ci-pkg-storage.yml` | 160 | If CAS changed | `ci_cas.yml` (local) | Go test |
| PR on storage - Amazon | `voedger/.github/workflows/ci-pkg-storage.yml` | 179 | If Amazon changed | `ci_amazon.yml` (local) | Go test |
| PR on storage - Merge | `voedger/.github/workflows/ci-pkg-storage.yml` | 184 | If tests pass | `merge.yml` (local) | `domergepr.sh` |

### Push Events

| Event Trigger | Workflow File | Line | Condition | Called Workflow | Scripts/Actions |
|---|---|---|---|---|---|
| Push to main (pkg-cmd) | `voedger/.github/workflows/ci-pkg-cmd.yml` | 13 | `push` to main | `ci_reuse_go.yml@main` | `checkPR.sh`, `test_subfolders_full.sh`, `check_copyright.sh`, `gbash.sh` |
| Push to main (pkg-cmd) | `voedger/.github/workflows/ci-pkg-cmd.yml` | 46 | After CI passes | `cd-voedger.yml@main` | Docker build & push |
| Push to storage paths | `voedger/.github/workflows/ci-pkg-storage.yml` | 19 | `push` event | (local job) | GitHub CLI |
| Push to storage - CAS | `voedger/.github/workflows/ci-pkg-storage.yml` | 160 | If CAS changed | `ci_cas.yml` (local) | Go test |
| Push to storage - Amazon | `voedger/.github/workflows/ci-pkg-storage.yml` | 179 | If Amazon changed | `ci_amazon.yml` (local) | Go test |

### Scheduled Events

| Event Trigger | Workflow File | Line | Condition | Called Workflow | Scripts/Actions |
|---|---|---|---|---|---|
| Daily 5 AM UTC | `voedger/.github/workflows/ci-full.yml` | 11 | `schedule` or `workflow_dispatch` | `ci_reuse_go.yml@main` | `checkPR.sh`, `test_subfolders_full.sh`, `check_copyright.sh`, `gbash.sh` |
| Daily 5 AM UTC (failure) | `voedger/.github/workflows/ci-full.yml` | 37 | If CI fails | `create_issue.yml@main` | `createissue.sh` |
| Daily 5 AM UTC | `voedger/.github/workflows/ci-full.yml` | 49 | After CI passes | `ci-vulncheck.yml@main` | `execgovuln.sh` |
| Daily 5 AM UTC | `voedger/.github/workflows/ci-full.yml` | 53 | After vuln check | `cd-voedger.yml@main` | Docker build & push |

### Issue Events

| Event Trigger | Workflow File | Line | Condition | Called Workflow | Scripts/Actions |
|---|---|---|---|---|---|
| Issue closed | `voedger/.github/workflows/linkIssue.yml` | 12 | `issues` type `closed` | (inline) | `linkmilestone.sh` |
| Issue reopened | `voedger/.github/workflows/unlinkIssue.yml` | 12 | `issues` type `reopened` | (inline) | `unlinkmilestone.sh` |
| Issue opened (cprc/cprelease) | `voedger/.github/workflows/cp.yml` | 15 | Title starts with cprc/cprelease | `cp.yml@main` | (cherry-pick logic) |

### Manual Trigger Events

| Event Trigger | Workflow File | Line | Condition | Called Workflow | Scripts/Actions |
|---|---|---|---|---|---|
| Manual dispatch (cluster_type) | `voedger/.github/workflows/ctool-integration-test.yml` | 55 | `workflow_dispatch` | `infrastructure-create-action` | Terraform |
| Manual dispatch (cluster_type) | `voedger/.github/workflows/ctool-integration-test.yml` | 99 | If n5 cluster | `cluster-init-action` | SSH commands |
| Manual dispatch (cluster_type) | `voedger/.github/workflows/ctool-integration-test.yml` | 111 | If n1 cluster | `ce-test-action` | Bash scripts |
| Manual dispatch (cluster_type) | `voedger/.github/workflows/ctool-integration-test.yml` | 118 | If n5/SE3 cluster | `cluster-test-action` | Bash scripts |

---

## Reusable Workflows (ci-action repository)

| Workflow | File | Type | Inputs | Key Steps |
|---|---|---|---|---|
| CI - golang | `ci-action/.github/workflows/ci_reuse_go.yml` | `workflow_call` | `ignore_copyright`, `test_folder`, `ignore_bp3`, `short_test`, `go_race`, `ignore_build`, `test_subfolders` | Setup Go 1.24, TinyGo, checkPR, CI action, test_subfolders, check_copyright, gbash |
| CI - golang (PR) | `ci-action/.github/workflows/ci_reuse_go_pr.yml` | `workflow_call` | Same + `running_workflow` | Same + cancelworkflow |
| Create Issue | `ci-action/.github/workflows/create_issue.yml` | `workflow_call` | `repo`, `assignee`, `name`, `body`, `label` | Checkout, createissue.sh |
| Cherry Pick | `ci-action/.github/workflows/cp.yml` | `workflow_call` | `org`, `repo`, `team`, `user`, `issue`, `issue-title`, `issue-body` | Cherry-pick logic |

---

## Custom Actions (voedger repository)

| Action | File | Purpose | Key Steps |
|---|---|---|---|
| infrastructure-create-action | `.github/actions/infrastructure-create-action/action.yml` | Create AWS infrastructure | Terraform init, plan, apply |
| ce-test-action | `.github/actions/ce-test-action/action.yml` | Test CE cluster | Smoke tests, backup/restore, status checks, ACME domain |
| cluster-init-action | `.github/actions/cluster-init-action/action.yml` | Initialize cluster | SSH commands, error handling, repeat logic |
| cluster-test-action | `.github/actions/cluster-test-action/action.yml` | Test SE/SE3 cluster | Similar to ce-test-action |
| cluster-backup-action | `.github/actions/cluster-backup-action/action.yml` | Backup/restore cluster | Backup and restore operations |

---

## Bash Scripts in ci-action/scripts

| Script | Purpose | Called From |
|---|---|---|
| `checkPR.sh` | Validate PR file size | `ci_reuse_go.yml:59`, `ci_reuse_go_pr.yml:61` |
| `cancelworkflow.sh` | Cancel other running workflows | `ci_reuse_go_pr.yml:67` |
| `check_copyright.sh` | Verify copyright headers | `ci_reuse_go.yml:95`, `ci_reuse_go_pr.yml:101` |
| `gbash.sh` | Run linters (golangci-lint) | `ci_reuse_go.yml:98`, `ci_reuse_go_pr.yml:104` |
| `test_subfolders.sh` | Run tests in subfolders (short) | `ci_reuse_go.yml:89`, `ci_reuse_go_pr.yml:98` |
| `test_subfolders_full.sh` | Run tests in subfolders (full) | `ci_reuse_go.yml:91` |
| `execgovuln.sh` | Run vulnerability checks | `ci-vulncheck.yml:24` |
| `domergepr.sh` | Merge PR automatically | `merge.yml:22`, `linkIssue.yml:17` |
| `createissue.sh` | Create GitHub issue | `create_issue.yml:36` |
| `linkmilestone.sh` | Link issue to milestone | `linkIssue.yml:17` |
| `unlinkmilestone.sh` | Unlink issue from milestone | `unlinkIssue.yml:17` |

---

## Environment Variables & Secrets

### Common Secrets
- `REPOREADING_TOKEN` - GitHub token for reading repos
- `PERSONAL_TOKEN` - GitHub token for personal operations
- `CODECOV_TOKEN` - Codecov integration token
- `DOCKER_USERNAME` - Docker Hub username
- `DOCKER_PASSWORD` - Docker Hub password
- `AWS_SSH_KEY` - AWS SSH private key
- `AWS_ACCESS_KEY_ID` - AWS access key
- `AWS_SECRET_ACCESS_KEY` - AWS secret key

### Common Environment Variables
- `GOPRIVATE` - Go private modules
- `CGO_ENABLED` - C bindings enabled
- `CASSANDRA_TESTS_ENABLED` - Enable Cassandra tests
- `DYNAMODB_TESTS_ENABLED` - Enable DynamoDB tests
- `DYNAMODB_ENDPOINT` - DynamoDB endpoint (local testing)
- `AWS_REGION` - AWS region
- `SSH_PORT` - SSH port (default 2214)
- `SSH_OPTIONS` - SSH options

---

## Workflow Dependencies

```
ci-full.yml (Daily)
├── ci_reuse_go.yml (CI tests)
├── ci-vulncheck.yml (Vulnerability check)
│   └── execgovuln.sh
├── cd-voedger.yml (Docker build & push)
└── create_issue.yml (on failure)
    └── createissue.sh

ci-pkg-cmd_pr.yml (PR on pkg-cmd)
├── ci_reuse_go_pr.yml (CI tests)
│   ├── checkPR.sh
│   ├── cancelworkflow.sh
│   ├── test_subfolders.sh
│   ├── check_copyright.sh
│   └── gbash.sh
└── merge.yml (auto-merge)
    └── domergepr.sh

ci-pkg-storage.yml (PR/Push on storage)
├── determine_changes (job)
├── ci_cas.yml (Cassandra tests)
│   └── create_issue.yml (on failure)
├── ci_amazon.yml (DynamoDB tests)
│   └── create_issue.yml (on failure)
└── merge.yml (auto-merge)

ctool-integration-test.yml (Manual)
├── infrastructure-create-action
│   └── Terraform
├── cluster-init-action
│   └── SSH commands
├── ce-test-action or cluster-test-action
│   └── Bash scripts
└── cluster-backup-action
```

