# Detailed Workflow Execution Flows - Starting from Voedger

This document describes complete CI/CD workflow execution paths, starting from GitHub events that trigger Voedger workflows, which then call ci-action workflows and bash scripts.

---

## 1. Pull Request on pkg-cmd (excluding pkg/istorage)

**GitHub Event:** `pull_request_target` on paths excluding `pkg/istorage/**`

**Voedger Workflow:** [`ci-pkg-cmd_pr.yml`](.github/workflows/ci-pkg-cmd_pr.yml)

### Step 1: [Call CI Workflow](.github/workflows/ci-pkg-cmd_pr.yml#L11)

**Condition:** `github.repository == 'voedger/voedger'`

```yaml
uses: untillpro/ci-action/.github/workflows/ci_reuse_go_pr.yml@main
```

**Called Workflow:** [`ci_reuse_go_pr.yml`](https://github.com/untillpro/ci-action/blob/main/.github/workflows/ci_reuse_go_pr.yml)

**Parameters:**

- `test_folder: "pkg"`
- `ignore_copyright: "cmd/voedger/sys.monitor/site.main"`
- `ignore_bp3: "true"`
- `short_test: "true"`
- `ignore_build: "true"`
- `running_workflow: "CI pkg-cmd PR"`
- `go_race: "false"`
- `test_subfolders: "true"`

### Actions in `ci_reuse_go_pr.yml`

1. [**Setup Go 1.24**](https://github.com/untillpro/ci-action/blob/main/.github/workflows/ci_reuse_go_pr.yml#L42)
   - Install Go environment

2. [**Install TinyGo 0.37.0**](https://github.com/untillpro/ci-action/blob/main/.github/workflows/ci_reuse_go_pr.yml#L49)
   - Download and install TinyGo compiler

3. [**Checkout PR Head Commit**](https://github.com/untillpro/ci-action/blob/main/.github/workflows/ci_reuse_go_pr.yml#L54)
   - Checkout PR head SHA with full history (fetch-depth: 0)

4. [**Check PR File Size**](https://github.com/untillpro/ci-action/blob/main/.github/workflows/ci_reuse_go_pr.yml#L60) → [`checkPR.sh`](https://github.com/untillpro/ci-action/blob/main/scripts/checkPR.sh)
   - **Validates:**
     - Total changes: ≤ 2MB
     - Single file: ≤ 100KB
     - Number of files: ≤ 200

5. [**Cancel Previous Workflows**](https://github.com/untillpro/ci-action/blob/main/.github/workflows/ci_reuse_go_pr.yml#L66) → [`cancelworkflow.sh`](https://github.com/untillpro/ci-action/blob/main/scripts/cancelworkflow.sh)
   - Cancels older in-progress workflows on same PR branch

6. [**Cache Go Modules**](https://github.com/untillpro/ci-action/blob/main/.github/workflows/ci_reuse_go_pr.yml#L74)
   - Cache `~/go/pkg/mod` for faster builds

7. [**Run CI Action**](https://github.com/untillpro/ci-action/blob/main/.github/workflows/ci_reuse_go_pr.yml#L82)
   - **Action:** `untillpro/ci-action@main` (Node.js action)
   - Executes: `go test ./... -short` with coverage

8. [**Test Subfolders**](https://github.com/untillpro/ci-action/blob/main/.github/workflows/ci_reuse_go_pr.yml#L95) → [`test_subfolders.sh`](https://github.com/untillpro/ci-action/blob/main/scripts/test_subfolders.sh)
   - Runs `go test ./... -short` in all subdirectories with `go.mod`

9. [**Check Copyright Headers**](https://github.com/untillpro/ci-action/blob/main/.github/workflows/ci_reuse_go_pr.yml#L100) → [`check_copyright.sh`](https://github.com/untillpro/ci-action/blob/main/scripts/check_copyright.sh)
   - Validates copyright headers in `.go` and `.sql` files

10. [**Run Linters**](https://github.com/untillpro/ci-action/blob/main/.github/workflows/ci_reuse_go_pr.yml#L103) → [`gbash.sh`](https://github.com/untillpro/ci-action/blob/main/scripts/gbash.sh)
    - Runs golangci-lint v2.4.0 on `pkg` folder

### Step 2: [Auto-Merge PR (if CI passes)](.github/workflows/ci-pkg-cmd_pr.yml#L25)

**Condition:** `needs: call-workflow-ci-pkg` (waits for CI to pass)

```yaml
uses: ./.github/workflows/merge.yml
```

**Called Workflow:** [`./.github/workflows/merge.yml`](.github/workflows/merge.yml)

### Actions in `merge.yml`

1. [**Merge PR**](.github/workflows/merge.yml#L15) → [`domergepr.sh`](https://github.com/untillpro/ci-action/blob/main/scripts/domergepr.sh)
   - Automatically merges PR if all checks pass

---

## 2. Push to main (pkg-cmd)

**GitHub Event:** `push` to `main` branch on paths excluding `pkg/istorage/**`

**Voedger Workflow:** [`.github/workflows/ci-pkg-cmd.yml`](.github/workflows/ci-pkg-cmd.yml)

**Condition:** `github.repository == 'voedger/voedger'`

### Step 1: [Call CI Workflow](.github/workflows/ci-pkg-cmd.yml#L11)

```yaml
uses: untillpro/ci-action/.github/workflows/ci_reuse_go.yml@main
```

**Called Workflow:** [`ci_reuse_go.yml`](https://github.com/untillpro/ci-action/blob/main/.github/workflows/ci_reuse_go.yml)

**Parameters:**

- `test_folder: "pkg"`
- `ignore_copyright: "cmd/voedger/sys.monitor/site.main"`
- `ignore_bp3: "true"`
- `short_test: "true"`
- `go_race: "false"`
- `ignore_build: "true"`
- `test_subfolders: "true"`

**Actions in `ci_reuse_go.yml`:**

1. Checkout, Setup Go, Install TinyGo
2. Cache Go Modules
3. Run CI Action
4. Test Subfolders → [`test_subfolders.sh`](https://github.com/untillpro/ci-action/blob/main/scripts/test_subfolders.sh)
5. Check Copyright → [`check_copyright.sh`](https://github.com/untillpro/ci-action/blob/main/scripts/check_copyright.sh)
6. Run Linters → [`gbash.sh`](https://github.com/untillpro/ci-action/blob/main/scripts/gbash.sh)

### Step 2: [Set BP3 Flag](.github/workflows/ci-pkg-cmd.yml#L26)

**Condition:** `needs: call-workflow-ci-pkg`

### Step 3: [Rebuild airs-bp3 (if needed)](.github/workflows/ci-pkg-cmd.yml#L46)

**Condition:** `needs: build && outputs.ibp3 == 'true'`

```yaml
uses: untillpro/ci-action/.github/workflows/ci_rebuild_bp3.yml@main
```

**Called Workflow:** [`ci_rebuild_bp3.yml`](https://github.com/untillpro/ci-action/blob/main/.github/workflows/ci_rebuild_bp3.yml)

**Actions:**

- [**Rebuild airs-bp3**](https://github.com/untillpro/ci-action/blob/main/.github/workflows/ci_rebuild_bp3.yml#L28) → [`rebuild-test-bp3.sh`](https://github.com/untillpro/ci-action/blob/main/scripts/rebuild-test-bp3.sh)
- [**Push to airs-bp3**](https://github.com/untillpro/ci-action/blob/main/.github/workflows/ci_rebuild_bp3.yml#L39)

---

## 3. Daily Scheduled Test Suite (5 AM UTC)

**GitHub Event:** `schedule` (5 AM UTC) or `workflow_dispatch`

**Voedger Workflow:** [`.github/workflows/ci-full.yml`](.github/workflows/ci-full.yml)

**Condition:** `github.repository == 'voedger/voedger'`

### Step 1: [Call CI Workflow](.github/workflows/ci-full.yml#L9)

```yaml
uses: untillpro/ci-action/.github/workflows/ci_reuse_go.yml@main
```

**Parameters:**

- `ignore_copyright: "cmd/voedger/sys.monitor/site.main"`
- `go_race: "true"` (enable race detector)
- `short_test: "false"` (full tests)
- `ignore_build: "true"`
- `test_subfolders: "true"`

### Step 2: [Notify on Failure](.github/workflows/ci-full.yml#L23)

**Condition:** `if: failure()`

```yaml
uses: untillpro/ci-action/.github/workflows/create_issue.yml@main
```

### Step 3: [Vulnerability Check](.github/workflows/ci-full.yml#L37)

**Condition:** `needs: call-workflow-ci`

```yaml
uses: untillpro/ci-action/.github/workflows/ci-vulncheck.yml@main
```

### Step 4: [Build and Deploy](.github/workflows/ci-full.yml#L49)

**Condition:** `needs: call-workflow-vuln`

```yaml
uses: untillpro/ci-action/.github/workflows/cd-voedger.yml@main
```

---

## 4. Workflow Files PR

**GitHub Event:** `pull_request_target` on `.github/workflows/**`

**Voedger Workflow:** [`.github/workflows/ci-wf_pr.yml`](.github/workflows/ci-wf_pr.yml)

### Step 1: [Auto-Merge PR](.github/workflows/ci-wf_pr.yml#L9)

```yaml
uses: voedger/voedger/.github/workflows/merge.yml@main
```

**Action:** Automatically merges workflow file changes

---

## 5. Cherry-Pick Commits

**GitHub Event:** Issue opened with title starting with `cprc` or `cprelease`

**Voedger Workflow:** [`.github/workflows/cp.yml`](.github/workflows/cp.yml)

**Actions:**

1. [**Add comment to issue**](https://github.com/untillpro/ci-action/blob/main/scripts/add-issue-commit.sh) → [`add-issue-commit.sh`](https://github.com/untillpro/ci-action/blob/main/scripts/add-issue-commit.sh)
2. [**Cherry-pick commits**](https://github.com/untillpro/ci-action/blob/main/scripts/cp.sh) → [`cp.sh`](https://github.com/untillpro/ci-action/blob/main/scripts/cp.sh)
3. [**Close issue**](https://github.com/untillpro/ci-action/blob/main/scripts/close-issue.sh) → [`close-issue.sh`](https://github.com/untillpro/ci-action/blob/main/scripts/close-issue.sh)

---

## 6. Release Candidate Creation

**GitHub Event:** Manual trigger via issue

**Voedger Workflow:** [`.github/workflows/rc.yml`](.github/workflows/rc.yml)

**Actions:**

1. [**Create RC branch**](https://github.com/untillpro/ci-action/blob/main/scripts/rc.sh) → [`rc.sh`](https://github.com/untillpro/ci-action/blob/main/scripts/rc.sh)
2. [**Close issue**](https://github.com/untillpro/ci-action/blob/main/scripts/close-issue.sh) → [`close-issue.sh`](https://github.com/untillpro/ci-action/blob/main/scripts/close-issue.sh)

---

## Workflow Dependency Graph

```
GitHub Event
  ↓
Voedger Workflow (ci-pkg-cmd_pr.yml, ci-pkg-cmd.yml, etc.)
  ├─ Calls: untillpro/ci-action/.github/workflows/*.yml@main
  │   ├─ ci_reuse_go_pr.yml
  │   ├─ ci_reuse_go.yml
  │   ├─ ci_rebuild_bp3.yml
  │   ├─ create_issue.yml
  │   ├─ ci-vulncheck.yml
  │   └─ cd-voedger.yml
  │
  ├─ Calls: Local workflows (./.github/workflows/*.yml)
  │   ├─ merge.yml
  │   ├─ cp.yml
  │   └─ rc.yml
  │
  └─ Executes: ci-action bash scripts via curl
      ├─ checkPR.sh
      ├─ cancelworkflow.sh
      ├─ test_subfolders.sh
      ├─ test_subfolders_full.sh
      ├─ check_copyright.sh
      ├─ gbash.sh
      ├─ rebuild-test-bp3.sh
      ├─ cp.sh
      ├─ rc.sh
      ├─ add-issue-commit.sh
      ├─ close-issue.sh
      └─ domergepr.sh
```

---

## Summary

Voedger's CI/CD pipeline follows this pattern:

1. **GitHub Event** triggers Voedger workflow
2. **Voedger workflow** calls ci-action reusable workflows
3. **ci-action workflows** execute bash scripts via curl
4. **Bash scripts** perform specific CI/CD tasks
5. **Results** determine next workflow steps (merge, deploy, etc.)

This modular architecture allows:

- Easy updates to CI logic (update ci-action repo)
- Consistent practices across projects
- Clear separation of concerns
- Reusable components
