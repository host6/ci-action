# GitHub Actions & CI/CD Analysis - Complete Documentation

## 📋 Documentation Overview

This comprehensive analysis documents the complete relationship between GitHub events, workflows, and scripts across the **voedger** and **ci-action** repositories.

**Total Documentation:** 6 files, ~60 KB, 2000+ lines

---

## 📚 Documentation Files

### 1. **README_ANALYSIS.md** ⭐ START HERE
- **Purpose:** Navigation guide and documentation index
- **Size:** 8.6 KB
- **Contains:**
  - Quick navigation guide
  - How to use the documentation
  - Key concepts explained
  - File structure overview
  - Common workflows summary

**👉 Read this first to understand how to use the other documents**

---

### 2. **QUICK_START_GUIDE.md**
- **Purpose:** Quick reference for getting oriented
- **Size:** 9.41 KB
- **Contains:**
  - What you have (2 repositories)
  - GitHub events & what they trigger
  - Key workflows & their purposes
  - Key bash scripts
  - Custom actions
  - Environment & secrets
  - Common patterns
  - File locations summary

**👉 Use this when you need a quick overview**

---

### 3. **GITHUB_ACTIONS_ANALYSIS.md**
- **Purpose:** Detailed event-to-action mapping
- **Size:** 10.08 KB
- **Contains:**
  - Complete mapping of GitHub events to triggered actions
  - Line numbers for each action
  - Step-by-step breakdown of workflows
  - Files involved from both repositories
  - Key bash scripts reference
  - Custom actions reference
  - Repository references

**👉 Use this when you need detailed information about a specific event**

---

### 4. **WORKFLOW_REFERENCE_TABLE.md**
- **Purpose:** Quick lookup and cross-referencing
- **Size:** 8.59 KB
- **Contains:**
  - Quick reference tables for all events
  - Workflow file locations and line numbers
  - Reusable workflows specifications
  - Custom actions specifications
  - Bash scripts reference with purposes
  - Environment variables and secrets
  - Workflow dependencies

**👉 Use this for quick lookups and cross-referencing**

---

### 5. **DETAILED_WORKFLOW_FLOWS.md**
- **Purpose:** Understanding execution flow
- **Size:** 13.09 KB
- **Contains:**
  - Step-by-step execution flows for 6 major scenarios
  - ASCII flow diagrams
  - Key files involved for each scenario
  - Detailed step descriptions with line numbers
  - Scenarios covered:
    1. Pull Request on pkg-cmd
    2. Pull Request on storage paths
    3. Push to main on pkg-cmd
    4. Daily scheduled test suite
    5. Manual trigger: ctool integration test
    6. Issue events

**👉 Use this when you want to understand complete execution flow**

---

### 6. **DEPENDENCY_GRAPH.md**
- **Purpose:** Understanding relationships and dependencies
- **Size:** 10.17 KB
- **Contains:**
  - Complete workflow call hierarchy
  - Script call graphs
  - Repository cross-references
  - Data flow for secrets and tokens
  - Execution order for key scenarios
  - Summary statistics

**👉 Use this when you need to understand how components relate**

---

## 🎯 Quick Navigation

### I want to know...

| Question | Read This | Then This |
|----------|-----------|-----------|
| What happens when a PR is created on pkg-cmd? | QUICK_START_GUIDE.md | DETAILED_WORKFLOW_FLOWS.md |
| Which scripts are called by ci_reuse_go.yml? | WORKFLOW_REFERENCE_TABLE.md | DEPENDENCY_GRAPH.md |
| What's the complete flow for the daily test? | DETAILED_WORKFLOW_FLOWS.md | GITHUB_ACTIONS_ANALYSIS.md |
| How do workflows depend on each other? | DEPENDENCY_GRAPH.md | WORKFLOW_REFERENCE_TABLE.md |
| Where is the merge workflow? | GITHUB_ACTIONS_ANALYSIS.md | WORKFLOW_REFERENCE_TABLE.md |
| What secrets are needed for Docker? | WORKFLOW_REFERENCE_TABLE.md | GITHUB_ACTIONS_ANALYSIS.md |
| Which workflows call ci_reuse_go.yml? | DEPENDENCY_GRAPH.md | QUICK_START_GUIDE.md |
| What happens if a storage test fails? | DETAILED_WORKFLOW_FLOWS.md | GITHUB_ACTIONS_ANALYSIS.md |

---

## 🔑 Key Concepts

### GitHub Events Handled
- **Pull Request** - Triggered when PR is created/updated on specific paths
- **Push** - Triggered when commits are pushed to main branch
- **Schedule** - Triggered daily at 5 AM UTC
- **Issues** - Triggered when issues are closed/reopened/opened
- **Manual** - Triggered manually via workflow_dispatch

### Repositories
- **voedger** - Main repository with workflows and custom actions
- **ci-action** (untillpro/ci-action) - Reusable library with workflows and scripts

### Workflow Types
- **Standalone Workflows** - Triggered directly by GitHub events
- **Reusable Workflows** - Called by other workflows using `uses:`
- **Custom Actions** - Composite actions that run steps

---

## 📊 Statistics

| Metric | Count |
|--------|-------|
| Workflows in voedger | 14 |
| Reusable workflows in ci-action | 4+ |
| Custom actions in voedger | 5 |
| Bash scripts in ci-action | 11+ |
| GitHub event types handled | 6 |
| Cross-repository references | 20+ |
| Total documentation lines | 2000+ |
| Total documentation size | ~60 KB |

---

## 🗂️ File Structure

```
voedger/
├── .github/workflows/
│   ├── ci-wf_pr.yml
│   ├── ci-pkg-cmd_pr.yml
│   ├── ci-pkg-cmd.yml
│   ├── ci-pkg-storage.yml
│   ├── ci-full.yml
│   ├── cd-voedger.yml
│   ├── ci-vulncheck.yml
│   ├── ci_cas.yml
│   ├── ci_amazon.yml
│   ├── merge.yml
│   ├── linkIssue.yml
│   ├── unlinkIssue.yml
│   ├── cp.yml
│   └── ctool-integration-test.yml
├── .github/actions/
│   ├── infrastructure-create-action/
│   ├── ce-test-action/
│   ├── cluster-init-action/
│   ├── cluster-test-action/
│   └── cluster-backup-action/
└── .github/scripts/
    └── (various shell scripts)

ci-action/
├── .github/workflows/
│   ├── ci_reuse_go.yml
│   ├── ci_reuse_go_pr.yml
│   ├── create_issue.yml
│   ├── cp.yml
│   └── (others)
├── scripts/
│   ├── checkPR.sh
│   ├── cancelworkflow.sh
│   ├── check_copyright.sh
│   ├── gbash.sh
│   ├── test_subfolders.sh
│   ├── test_subfolders_full.sh
│   ├── execgovuln.sh
│   ├── domergepr.sh
│   ├── createissue.sh
│   ├── linkmilestone.sh
│   ├── unlinkmilestone.sh
│   └── (others)
└── action.yml (main CI action)
```

---

## 🔄 Common Workflows

### PR Workflow
```
PR Created → Determine Changes → Run Tests → Auto-merge if Pass
```

### Push Workflow
```
Push to main → Run Tests → Build Docker → Push to Registry
```

### Scheduled Workflow
```
Daily 5 AM → Full Tests → Vuln Check → Build Docker → Create Issue if Fail
```

### Storage Tests Workflow
```
PR/Push on storage → Determine Backend → Run CAS Tests + Amazon Tests → Merge if Pass
```

### Manual Cluster Test Workflow
```
Manual Trigger → Create Infrastructure → Init Cluster → Run Tests → Upgrade → Destroy
```

---

## 🚀 How to Use This Documentation

### For New Team Members
1. Start with **README_ANALYSIS.md** (this file)
2. Read **QUICK_START_GUIDE.md** for overview
3. Read **GITHUB_ACTIONS_ANALYSIS.md** for your area of interest
4. Reference **WORKFLOW_REFERENCE_TABLE.md** as needed

### For Debugging
1. Identify the GitHub event that triggered the issue
2. Look up the event in **QUICK_START_GUIDE.md**
3. Read the detailed flow in **DETAILED_WORKFLOW_FLOWS.md**
4. Check **DEPENDENCY_GRAPH.md** for dependencies
5. Reference specific files in **WORKFLOW_REFERENCE_TABLE.md**

### For Adding New Workflows
1. Review similar workflows in **GITHUB_ACTIONS_ANALYSIS.md**
2. Check **DEPENDENCY_GRAPH.md** for how to integrate
3. Use **WORKFLOW_REFERENCE_TABLE.md** as a template reference

### For Understanding Secrets & Environment
1. Check **WORKFLOW_REFERENCE_TABLE.md** → "Environment Variables & Secrets"
2. Look up specific workflows in **GITHUB_ACTIONS_ANALYSIS.md**
3. Check **DEPENDENCY_GRAPH.md** → "Data Flow: Secrets & Tokens"

---

## 📝 Document Maintenance

These documents were generated by analyzing:
- All workflow files in voedger/.github/workflows/
- All custom actions in voedger/.github/actions/
- All reusable workflows in ci-action/.github/workflows/
- All bash scripts in ci-action/scripts/

**Last Updated:** 2025-10-23

---

## 🔗 Additional Resources

- GitHub Actions Documentation: https://docs.github.com/en/actions
- Workflow Syntax: https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions
- Reusable Workflows: https://docs.github.com/en/actions/using-workflows/reusing-workflows
- Custom Actions: https://docs.github.com/en/actions/creating-actions

---

## 📖 Reading Order Recommendations

### For Quick Understanding (15 minutes)
1. README_ANALYSIS.md (this file)
2. QUICK_START_GUIDE.md

### For Comprehensive Understanding (1 hour)
1. README_ANALYSIS.md
2. QUICK_START_GUIDE.md
3. GITHUB_ACTIONS_ANALYSIS.md
4. WORKFLOW_REFERENCE_TABLE.md

### For Deep Dive (2+ hours)
1. All of the above
2. DETAILED_WORKFLOW_FLOWS.md
3. DEPENDENCY_GRAPH.md

### For Specific Scenarios
- **PR workflow:** DETAILED_WORKFLOW_FLOWS.md → Section 1 & 2
- **Push workflow:** DETAILED_WORKFLOW_FLOWS.md → Section 3
- **Daily tests:** DETAILED_WORKFLOW_FLOWS.md → Section 4
- **Manual tests:** DETAILED_WORKFLOW_FLOWS.md → Section 5
- **Issue events:** DETAILED_WORKFLOW_FLOWS.md → Section 6

---

## ✅ What You'll Learn

After reading these documents, you'll understand:

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

## 🎓 Next Steps

1. **Read README_ANALYSIS.md** (you are here)
2. **Choose your path:**
   - Quick overview? → Read QUICK_START_GUIDE.md
   - Need details? → Read GITHUB_ACTIONS_ANALYSIS.md
   - Need to debug? → Read DETAILED_WORKFLOW_FLOWS.md
   - Need to understand relationships? → Read DEPENDENCY_GRAPH.md
3. **Reference as needed** → Use WORKFLOW_REFERENCE_TABLE.md

---

**Happy learning! 🚀**

