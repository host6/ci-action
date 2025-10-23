# GitHub Actions & CI/CD Analysis - Documentation Index

## Overview

This analysis documents the complete relationship between GitHub events, workflows, and scripts across the **voedger** and **ci-action** repositories. The documentation is organized into 5 comprehensive guides.

---

## Documentation Files

### 1. **QUICK_START_GUIDE.md** ⭐ START HERE
**Best for:** Getting oriented quickly

Contains:
- Overview of what triggers what
- Summary of all GitHub events and their actions
- Key workflows and their purposes
- Common patterns
- File locations summary
- Quick reference tables

**Read this first** to understand the big picture.

---

### 2. **GITHUB_ACTIONS_ANALYSIS.md**
**Best for:** Detailed event-to-action mapping

Contains:
- Complete mapping of GitHub events to triggered actions
- Line numbers for each action
- Step-by-step breakdown of what happens in each workflow
- Files involved from both repositories
- Key bash scripts reference table
- Custom actions reference table

**Use this** when you need to know exactly what happens for a specific GitHub event.

---

### 3. **WORKFLOW_REFERENCE_TABLE.md**
**Best for:** Quick lookup and cross-referencing

Contains:
- Quick reference tables for all events
- Workflow file locations and line numbers
- Reusable workflows specifications
- Custom actions specifications
- Bash scripts reference with purposes
- Environment variables and secrets
- Workflow dependencies

**Use this** when you need to find something quickly or cross-reference workflows.

---

### 4. **DETAILED_WORKFLOW_FLOWS.md**
**Best for:** Understanding execution flow

Contains:
- Step-by-step execution flows for 6 major scenarios:
  1. Pull Request on pkg-cmd
  2. Pull Request on storage paths
  3. Push to main on pkg-cmd
  4. Daily scheduled test suite
  5. Manual trigger: ctool integration test
  6. Issue events (closed, reopened, opened)
- ASCII flow diagrams
- Key files involved for each scenario
- Detailed step descriptions with line numbers

**Use this** when you want to understand the complete execution flow for a specific scenario.

---

### 5. **DEPENDENCY_GRAPH.md**
**Best for:** Understanding relationships and dependencies

Contains:
- Complete workflow call hierarchy
- Script call graphs
- Repository cross-references
- Data flow for secrets and tokens
- Execution order for key scenarios
- Summary statistics

**Use this** when you need to understand how components relate to each other or trace dependencies.

---

## Quick Navigation

### I want to know...

**"What happens when a PR is created on pkg-cmd?"**
→ Read: QUICK_START_GUIDE.md → "PR on pkg/** (excluding pkg/istorage/**)"
→ Then: DETAILED_WORKFLOW_FLOWS.md → "1. Pull Request on pkg-cmd"

**"Which scripts are called by ci_reuse_go.yml?"**
→ Read: WORKFLOW_REFERENCE_TABLE.md → "Bash Scripts in ci-action/scripts"
→ Or: DEPENDENCY_GRAPH.md → "Script Call Graph"

**"What's the complete flow for the daily test?"**
→ Read: DETAILED_WORKFLOW_FLOWS.md → "4. Daily Scheduled Test Suite"

**"How do workflows depend on each other?"**
→ Read: DEPENDENCY_GRAPH.md → "Workflow Call Hierarchy"

**"Where is the merge workflow and what does it do?"**
→ Read: GITHUB_ACTIONS_ANALYSIS.md → Search for "merge.yml"
→ Or: WORKFLOW_REFERENCE_TABLE.md → "Reusable Workflows"

**"What secrets are needed for Docker builds?"**
→ Read: WORKFLOW_REFERENCE_TABLE.md → "Environment Variables & Secrets"

**"Which workflows call the ci_reuse_go.yml?"**
→ Read: DEPENDENCY_GRAPH.md → "Repository Cross-References"

**"What happens if a storage test fails?"**
→ Read: DETAILED_WORKFLOW_FLOWS.md → "2. Pull Request on Storage Paths"

---

## Key Concepts

### GitHub Events
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

### Script Types
- **Bash Scripts** - Executable scripts in ci-action/scripts
- **Inline Scripts** - Scripts defined directly in workflow steps
- **Downloaded Scripts** - Scripts downloaded via curl from ci-action

---

## File Structure

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

## Common Workflows

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

## Key Statistics

- **14** workflows in voedger
- **4+** reusable workflows in ci-action
- **5** custom actions in voedger
- **11+** bash scripts in ci-action
- **6** types of GitHub events handled
- **20+** cross-repository references

---

## How to Use This Documentation

### For New Team Members
1. Start with QUICK_START_GUIDE.md
2. Read GITHUB_ACTIONS_ANALYSIS.md for your area of interest
3. Reference WORKFLOW_REFERENCE_TABLE.md as needed

### For Debugging
1. Identify the GitHub event that triggered the issue
2. Look up the event in QUICK_START_GUIDE.md
3. Read the detailed flow in DETAILED_WORKFLOW_FLOWS.md
4. Check DEPENDENCY_GRAPH.md for dependencies
5. Reference specific files in WORKFLOW_REFERENCE_TABLE.md

### For Adding New Workflows
1. Review similar workflows in GITHUB_ACTIONS_ANALYSIS.md
2. Check DEPENDENCY_GRAPH.md for how to integrate
3. Use WORKFLOW_REFERENCE_TABLE.md as a template reference

### For Understanding Secrets & Environment
1. Check WORKFLOW_REFERENCE_TABLE.md → "Environment Variables & Secrets"
2. Look up specific workflows in GITHUB_ACTIONS_ANALYSIS.md
3. Check DEPENDENCY_GRAPH.md → "Data Flow: Secrets & Tokens"

---

## Document Maintenance

These documents were generated by analyzing:
- All workflow files in voedger/.github/workflows/
- All custom actions in voedger/.github/actions/
- All reusable workflows in ci-action/.github/workflows/
- All bash scripts in ci-action/scripts/

**Last Updated:** 2025-10-23

---

## Additional Resources

- GitHub Actions Documentation: https://docs.github.com/en/actions
- Workflow Syntax: https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions
- Reusable Workflows: https://docs.github.com/en/actions/using-workflows/reusing-workflows
- Custom Actions: https://docs.github.com/en/actions/creating-actions

---

## Questions?

If you have questions about:
- **Specific workflows** → Check GITHUB_ACTIONS_ANALYSIS.md
- **How things connect** → Check DEPENDENCY_GRAPH.md
- **Step-by-step execution** → Check DETAILED_WORKFLOW_FLOWS.md
- **Quick lookup** → Check WORKFLOW_REFERENCE_TABLE.md
- **Getting started** → Check QUICK_START_GUIDE.md

