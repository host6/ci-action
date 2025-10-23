# Investigation Summary: GitHub Actions & CI/CD Workflows

## 🎯 Objective

Investigate relationships between GitHub actions and bash scripts from voedger and ci-action repositories to understand:
- Which GitHub event triggers which action
- Which steps are executed
- Which files from which repositories are involved

## ✅ Deliverables

Created **7 comprehensive documentation files** totaling **~70 KB** with **2000+ lines** of detailed analysis.

### Documentation Files Created

| File | Size | Purpose |
|------|------|---------|
| **INDEX.md** | 10.15 KB | Navigation guide and documentation index |
| **QUICK_START_GUIDE.md** | 9.41 KB | Quick reference for getting oriented |
| **GITHUB_ACTIONS_ANALYSIS.md** | 10.08 KB | Detailed event-to-action mapping |
| **WORKFLOW_REFERENCE_TABLE.md** | 8.59 KB | Quick lookup tables and cross-references |
| **DETAILED_WORKFLOW_FLOWS.md** | 13.09 KB | Step-by-step execution flows |
| **DEPENDENCY_GRAPH.md** | 10.17 KB | Relationships and dependencies |
| **README_ANALYSIS.md** | 8.6 KB | Documentation overview |

**Location:** `c:\Workspace\ci-action\`

---

## 📊 Analysis Results

### GitHub Events Identified: 6 Types

1. **Pull Request** (pull_request_target)
   - On `.github/workflows/**`
   - On `pkg/**` (excluding `pkg/istorage/**`)
   - On `pkg/istorage/**`, `pkg/vvm/storage/**`, `pkg/elections/**`

2. **Push** (push to main)
   - On `pkg/**` (excluding `pkg/istorage/**`)
   - On `pkg/istorage/**`, `pkg/vvm/storage/**`, `pkg/elections/**`

3. **Scheduled** (cron 0 5 * * *)
   - Daily at 5 AM UTC

4. **Issues**
   - Closed
   - Reopened
   - Opened (with cprc/cprelease prefix)

5. **Manual** (workflow_dispatch)
   - ctool integration test with cluster type input

---

### Workflows Identified: 18 Total

#### voedger Repository (14 workflows)
- `ci-wf_pr.yml` - Auto-merge workflow changes
- `ci-pkg-cmd_pr.yml` - Test and auto-merge pkg changes
- `ci-pkg-cmd.yml` - Test and build Docker image
- `ci-pkg-storage.yml` - Test storage backends
- `ci-full.yml` - Full test suite + vulnerability check
- `cd-voedger.yml` - Build and push Docker image
- `ci-vulncheck.yml` - Vulnerability check
- `ci_cas.yml` - Cassandra tests
- `ci_amazon.yml` - DynamoDB tests
- `merge.yml` - Auto-merge PR
- `linkIssue.yml` - Link issue to milestone
- `unlinkIssue.yml` - Unlink issue from milestone
- `cp.yml` - Cherry-pick commits
- `ctool-integration-test.yml` - Manual cluster test

#### ci-action Repository (4+ reusable workflows)
- `ci_reuse_go.yml` - Reusable Go CI workflow
- `ci_reuse_go_pr.yml` - Reusable Go CI workflow (PR context)
- `create_issue.yml` - Create GitHub issue
- `cp.yml` - Cherry-pick commits

---

### Custom Actions Identified: 5

All in voedger repository:
1. `infrastructure-create-action` - Create AWS infrastructure via Terraform
2. `ce-test-action` - Test Voedger CE cluster
3. `cluster-init-action` - Initialize Voedger cluster
4. `cluster-test-action` - Test Voedger SE/SE3 cluster
5. `cluster-backup-action` - Backup and restore cluster

---

### Bash Scripts Identified: 11+

All in ci-action/scripts:
1. `checkPR.sh` - Validate PR file size
2. `cancelworkflow.sh` - Cancel other running workflows
3. `check_copyright.sh` - Verify copyright headers
4. `gbash.sh` - Run linters (golangci-lint)
5. `test_subfolders.sh` - Run tests in subfolders (short)
6. `test_subfolders_full.sh` - Run tests in subfolders (full)
7. `execgovuln.sh` - Run vulnerability checks
8. `domergepr.sh` - Merge PR automatically
9. `createissue.sh` - Create GitHub issue
10. `linkmilestone.sh` - Link issue to milestone
11. `unlinkmilestone.sh` - Unlink issue from milestone

---

## 🔄 Key Workflows

### 1. Pull Request Workflow (pkg-cmd)
```
PR Created → ci-pkg-cmd_pr.yml
├── Run CI tests (ci_reuse_go_pr.yml)
│   ├── checkPR.sh
│   ├── cancelworkflow.sh
│   ├── test_subfolders.sh
│   ├── check_copyright.sh
│   └── gbash.sh
└── Auto-merge (merge.yml)
    └── domergepr.sh
```

### 2. Push Workflow (main branch)
```
Push to main → ci-pkg-cmd.yml
├── Run CI tests (ci_reuse_go.yml)
│   ├── checkPR.sh
│   ├── test_subfolders_full.sh
│   ├── check_copyright.sh
│   └── gbash.sh
└── Build & Push Docker (cd-voedger.yml)
    └── voedger/voedger:0.0.1-alpha
```

### 3. Daily Scheduled Workflow
```
5 AM UTC → ci-full.yml
├── Full CI tests (ci_reuse_go.yml)
├── Vulnerability check (ci-vulncheck.yml)
│   └── execgovuln.sh
├── Build & Push Docker (cd-voedger.yml)
└── Create issue on failure (create_issue.yml)
    └── createissue.sh
```

### 4. Storage Tests Workflow
```
PR/Push on storage → ci-pkg-storage.yml
├── Determine changes
├── Run Cassandra tests (ci_cas.yml)
├── Run DynamoDB tests (ci_amazon.yml)
├── Create issue on failure (create_issue.yml)
└── Auto-merge if pass (merge.yml)
```

### 5. Manual Cluster Test Workflow
```
Manual trigger → ctool-integration-test.yml
├── Create infrastructure (infrastructure-create-action)
├── Initialize cluster (cluster-init-action)
├── Run tests (ce-test-action or cluster-test-action)
│   └── cluster-backup-action
└── Destroy infrastructure
```

---

## 📈 Statistics

| Metric | Count |
|--------|-------|
| Total workflows | 18 |
| Workflows in voedger | 14 |
| Reusable workflows in ci-action | 4+ |
| Custom actions | 5 |
| Bash scripts | 11+ |
| GitHub event types | 6 |
| Cross-repository references | 20+ |
| Documentation files | 7 |
| Total documentation size | ~70 KB |
| Total documentation lines | 2000+ |

---

## 🔑 Key Findings

### 1. Repository Architecture
- **voedger** is the main repository with workflows and custom actions
- **ci-action** is a reusable library with workflows and bash scripts
- voedger references ci-action via `untillpro/ci-action@main` or `untillpro/ci-action/.github/workflows/*.yml@main`

### 2. Workflow Patterns
- **Reusable workflows** are used extensively to avoid duplication
- **Custom actions** encapsulate complex multi-step operations
- **Bash scripts** are downloaded via curl from ci-action repository

### 3. CI/CD Pipeline
- **PR workflows** run tests and auto-merge on success
- **Push workflows** run tests and build Docker images
- **Scheduled workflows** run full test suite with vulnerability checks
- **Storage workflows** run backend-specific tests (Cassandra, DynamoDB)
- **Manual workflows** test cluster deployment and upgrade

### 4. Secrets & Environment
- Multiple secrets used: REPOREADING_TOKEN, PERSONAL_TOKEN, CODECOV_TOKEN, Docker credentials, AWS credentials
- Environment variables control test behavior (go_race, short_test, test_subfolders, etc.)
- Secrets flow through workflow calls to reusable workflows

### 5. Error Handling
- Failed tests create GitHub issues automatically
- Issues are assigned to specific users (e.g., host6)
- Issues are labeled with priority (e.g., prty/blocker)

---

## 📚 How to Use the Documentation

### Quick Start (15 minutes)
1. Read **INDEX.md** - Navigation guide
2. Read **QUICK_START_GUIDE.md** - Overview

### Comprehensive Understanding (1 hour)
1. Read **INDEX.md**
2. Read **QUICK_START_GUIDE.md**
3. Read **GITHUB_ACTIONS_ANALYSIS.md**
4. Reference **WORKFLOW_REFERENCE_TABLE.md**

### Deep Dive (2+ hours)
1. All of the above
2. Read **DETAILED_WORKFLOW_FLOWS.md**
3. Read **DEPENDENCY_GRAPH.md**

### For Specific Scenarios
- **PR workflow:** DETAILED_WORKFLOW_FLOWS.md → Section 1 & 2
- **Push workflow:** DETAILED_WORKFLOW_FLOWS.md → Section 3
- **Daily tests:** DETAILED_WORKFLOW_FLOWS.md → Section 4
- **Manual tests:** DETAILED_WORKFLOW_FLOWS.md → Section 5
- **Issue events:** DETAILED_WORKFLOW_FLOWS.md → Section 6

---

## 🎓 What You'll Learn

After reading the documentation, you'll understand:

✓ Which GitHub events trigger which workflows  
✓ What steps are executed in each workflow  
✓ Which files from which repositories are involved  
✓ How workflows depend on each other  
✓ What bash scripts are called and when  
✓ How secrets and environment variables flow through workflows  
✓ How to debug workflow issues  
✓ How to add new workflows  
✓ The complete CI/CD pipeline architecture  

---

## 📁 File Locations

All documentation files are located in: **`c:\Workspace\ci-action\`**

```
c:\Workspace\ci-action\
├── INDEX.md
├── QUICK_START_GUIDE.md
├── GITHUB_ACTIONS_ANALYSIS.md
├── WORKFLOW_REFERENCE_TABLE.md
├── DETAILED_WORKFLOW_FLOWS.md
├── DEPENDENCY_GRAPH.md
├── README_ANALYSIS.md
└── SUMMARY.md (this file)
```

---

## 🚀 Next Steps

1. **Start with INDEX.md** - It's your navigation guide
2. **Choose your learning path:**
   - Quick overview? → QUICK_START_GUIDE.md
   - Need details? → GITHUB_ACTIONS_ANALYSIS.md
   - Need to debug? → DETAILED_WORKFLOW_FLOWS.md
   - Need to understand relationships? → DEPENDENCY_GRAPH.md
3. **Reference as needed** → Use WORKFLOW_REFERENCE_TABLE.md

---

## 📞 Questions?

Refer to the appropriate documentation file:
- **"What happens when...?"** → DETAILED_WORKFLOW_FLOWS.md
- **"Where is...?"** → WORKFLOW_REFERENCE_TABLE.md
- **"How do...relate?"** → DEPENDENCY_GRAPH.md
- **"Quick overview?"** → QUICK_START_GUIDE.md
- **"Detailed info?"** → GITHUB_ACTIONS_ANALYSIS.md

---

**Investigation completed successfully! 🎉**

All relationships between GitHub actions and bash scripts have been documented with line numbers, file locations, and execution flows.

