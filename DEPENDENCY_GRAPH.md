# Complete Dependency Graph

## Workflow Call Hierarchy

### Level 1: GitHub Events (Triggers)

```
pull_request_target
├── ci-wf_pr.yml
├── ci-pkg-cmd_pr.yml
└── ci-pkg-storage.yml

push
├── ci-pkg-cmd.yml
└── ci-pkg-storage.yml

schedule (0 5 * * *)
└── ci-full.yml

issues (closed)
└── linkIssue.yml

issues (reopened)
└── unlinkIssue.yml

issues (opened, cprc/cprelease)
└── cp.yml

workflow_dispatch
└── ctool-integration-test.yml
```

---

## Level 2: Workflow Dependencies

### ci-wf_pr.yml
```
ci-wf_pr.yml
└── merge.yml@main (voedger)
    └── domergepr.sh (ci-action)
```

### ci-pkg-cmd_pr.yml
```
ci-pkg-cmd_pr.yml
├── ci_reuse_go_pr.yml@main (ci-action)
│   ├── checkPR.sh (ci-action)
│   ├── cancelworkflow.sh (ci-action)
│   ├── test_subfolders.sh (ci-action)
│   ├── check_copyright.sh (ci-action)
│   └── gbash.sh (ci-action)
└── merge.yml (voedger)
    └── domergepr.sh (ci-action)
```

### ci-pkg-cmd.yml
```
ci-pkg-cmd.yml
├── ci_reuse_go.yml@main (ci-action)
│   ├── checkPR.sh (ci-action)
│   ├── test_subfolders_full.sh (ci-action)
│   ├── check_copyright.sh (ci-action)
│   └── gbash.sh (ci-action)
└── cd-voedger.yml@main (voedger)
    └── Docker build & push
```

### ci-pkg-storage.yml
```
ci-pkg-storage.yml
├── ci_cas.yml (voedger)
│   ├── Go test (Cassandra)
│   └── create_issue.yml@main (ci-action) [on failure]
│       └── createissue.sh (ci-action)
├── ci_amazon.yml (voedger)
│   ├── Go test (DynamoDB)
│   └── create_issue.yml@main (ci-action) [on failure]
│       └── createissue.sh (ci-action)
└── merge.yml (voedger)
    └── domergepr.sh (ci-action)
```

### ci-full.yml
```
ci-full.yml
├── ci_reuse_go.yml@main (ci-action)
│   ├── checkPR.sh (ci-action)
│   ├── test_subfolders_full.sh (ci-action)
│   ├── check_copyright.sh (ci-action)
│   └── gbash.sh (ci-action)
├── create_issue.yml@main (ci-action) [on failure]
│   └── createissue.sh (ci-action)
├── ci-vulncheck.yml@main (voedger)
│   └── execgovuln.sh (ci-action)
└── cd-voedger.yml@main (voedger)
    └── Docker build & push
```

### linkIssue.yml
```
linkIssue.yml
└── linkmilestone.sh (ci-action)
```

### unlinkIssue.yml
```
unlinkIssue.yml
└── unlinkmilestone.sh (ci-action)
```

### cp.yml
```
cp.yml
└── cp.yml@main (ci-action)
    └── Cherry-pick logic
```

### ctool-integration-test.yml
```
ctool-integration-test.yml
├── infrastructure-create-action (voedger)
│   └── Terraform (init, plan, apply)
├── cluster-init-action (voedger)
│   └── SSH commands
├── ce-test-action (voedger)
│   ├── Smoke tests
│   ├── cluster-backup-action (voedger)
│   │   └── Backup/restore
│   ├── voedger_ce_status.sh (voedger)
│   ├── mon_password_set.sh (voedger)
│   ├── mon_ce_status.sh (voedger)
│   └── ACME domain setup
└── cluster-test-action (voedger)
    └── Similar to ce-test-action
```

---

## Script Call Graph

### From ci_reuse_go.yml (and ci_reuse_go_pr.yml)
```
ci_reuse_go.yml
├── checkPR.sh
│   └── Validates PR file size
├── cancelworkflow.sh (PR only)
│   └── Cancels other running workflows
├── untillpro/ci-action@main
│   └── Main CI action (Go tests, build)
├── test_subfolders.sh (if short_test=true)
│   └── Runs tests in subfolders
├── test_subfolders_full.sh (if short_test=false)
│   └── Runs full tests in subfolders
├── check_copyright.sh
│   └── Verifies copyright headers
└── gbash.sh
    └── Runs linters (golangci-lint)
```

### From ci-vulncheck.yml
```
ci-vulncheck.yml
├── Install govulncheck
└── execgovuln.sh
    └── Runs vulnerability checks
```

### From create_issue.yml
```
create_issue.yml
└── createissue.sh
    └── Creates GitHub issue with specified details
```

### From merge.yml
```
merge.yml
└── domergepr.sh
    └── Merges PR automatically
```

### From linkIssue.yml
```
linkIssue.yml
└── linkmilestone.sh
    └── Links issue to milestone
```

### From unlinkIssue.yml
```
unlinkIssue.yml
└── unlinkmilestone.sh
    └── Unlinks issue from milestone
```

### From ce-test-action
```
ce-test-action
├── cluster-backup-action
│   └── Backup and restore operations
├── voedger_ce_status.sh
│   └── Checks CE stack status
├── mon_password_set.sh
│   └── Sets Mon stack password
├── mon_ce_status.sh
│   └── Checks Prometheus/Alertmanager status
└── ACME domain setup
    └── SSH commands
```

---

## Repository Cross-References

### voedger Repository References ci-action

```
voedger/
├── ci-wf_pr.yml
│   └── merge.yml@main (voedger)
│       └── domergepr.sh (ci-action)
├── ci-pkg-cmd_pr.yml
│   ├── ci_reuse_go_pr.yml@main (ci-action)
│   │   ├── checkPR.sh (ci-action)
│   │   ├── cancelworkflow.sh (ci-action)
│   │   ├── test_subfolders.sh (ci-action)
│   │   ├── check_copyright.sh (ci-action)
│   │   └── gbash.sh (ci-action)
│   └── merge.yml (voedger)
│       └── domergepr.sh (ci-action)
├── ci-pkg-cmd.yml
│   ├── ci_reuse_go.yml@main (ci-action)
│   │   ├── checkPR.sh (ci-action)
│   │   ├── test_subfolders_full.sh (ci-action)
│   │   ├── check_copyright.sh (ci-action)
│   │   └── gbash.sh (ci-action)
│   └── cd-voedger.yml@main (voedger)
├── ci-pkg-storage.yml
│   ├── ci_cas.yml (voedger)
│   │   └── create_issue.yml@main (ci-action)
│   │       └── createissue.sh (ci-action)
│   ├── ci_amazon.yml (voedger)
│   │   └── create_issue.yml@main (ci-action)
│   │       └── createissue.sh (ci-action)
│   └── merge.yml (voedger)
│       └── domergepr.sh (ci-action)
├── ci-full.yml
│   ├── ci_reuse_go.yml@main (ci-action)
│   ├── create_issue.yml@main (ci-action)
│   │   └── createissue.sh (ci-action)
│   ├── ci-vulncheck.yml@main (voedger)
│   │   └── execgovuln.sh (ci-action)
│   └── cd-voedger.yml@main (voedger)
├── linkIssue.yml
│   └── linkmilestone.sh (ci-action)
├── unlinkIssue.yml
│   └── unlinkmilestone.sh (ci-action)
├── cp.yml
│   └── cp.yml@main (ci-action)
└── ctool-integration-test.yml
    ├── infrastructure-create-action (voedger)
    ├── cluster-init-action (voedger)
    ├── ce-test-action (voedger)
    │   ├── cluster-backup-action (voedger)
    │   ├── voedger_ce_status.sh (voedger)
    │   ├── mon_password_set.sh (voedger)
    │   └── mon_ce_status.sh (voedger)
    └── cluster-test-action (voedger)
```

---

## Data Flow: Secrets & Tokens

### Secrets Used

```
REPOREADING_TOKEN
├── ci_reuse_go.yml (reporeading_token)
├── ci_reuse_go_pr.yml (reporeading_token)
├── ci-pkg-storage.yml (REPOREADING_TOKEN)
├── ci-full.yml (REPOREADING_TOKEN)
├── linkIssue.yml (GH_TOKEN)
├── unlinkIssue.yml (GH_TOKEN)
├── cp.yml (git_token)
└── ctool-integration-test.yml (TF_VAR_gh_token)

PERSONAL_TOKEN
├── ci_reuse_go.yml (personal_token)
├── ci_reuse_go_pr.yml (personal_token)
├── ci-pkg-cmd_pr.yml (REPOREADING_TOKEN)
├── ci-pkg-storage.yml (REPOREADING_TOKEN)
├── ci-full.yml (PERSONAL_TOKEN)
├── cd-voedger.yml (personaltoken)
├── ci_cas.yml (personaltoken)
├── ci_amazon.yml (personaltoken)
└── create_issue.yml (personaltoken)

CODECOV_TOKEN
├── ci_reuse_go.yml (codecov_token)
├── ci_reuse_go_pr.yml (codecov_token)
└── ci-full.yml (CODECOV_TOKEN)

DOCKER_USERNAME & DOCKER_PASSWORD
├── cd-voedger.yml (dockerusername, dockerpassword)
└── ci-full.yml (DOCKER_USERNAME, DOCKER_PASSWORD)

AWS_SSH_KEY, AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY
└── ctool-integration-test.yml (TF_VAR_ssh_private_key, etc.)
```

---

## Execution Order for Key Scenarios

### Scenario 1: PR on pkg-cmd
```
1. PR created/updated
2. ci-pkg-cmd_pr.yml triggered
3. call-workflow-ci-pkg job starts
   a. ci_reuse_go_pr.yml called
   b. checkPR.sh runs
   c. cancelworkflow.sh runs
   d. CI action runs
   e. test_subfolders.sh runs
   f. check_copyright.sh runs
   g. gbash.sh runs
4. auto-merge-pr job starts (depends on call-workflow-ci-pkg)
   a. merge.yml called
   b. domergepr.sh runs
5. PR merged
```

### Scenario 2: Push to main on pkg-cmd
```
1. Commit pushed to main
2. ci-pkg-cmd.yml triggered
3. call-workflow-ci-pkg job starts
   a. ci_reuse_go.yml called
   b. checkPR.sh runs
   c. CI action runs
   d. test_subfolders_full.sh runs
   e. check_copyright.sh runs
   f. gbash.sh runs
4. build job starts (depends on call-workflow-ci-pkg)
   a. Sets ibp3 output
5. call-workflow-cd_voeger job starts (depends on build)
   a. cd-voedger.yml called
   b. Go build runs
   c. Docker build & push runs
```

### Scenario 3: Daily scheduled test
```
1. 5 AM UTC trigger
2. ci-full.yml triggered
3. call-workflow-ci job starts
   a. ci_reuse_go.yml called (with go_race=true)
   b. Full CI tests run
4. notify_failure job starts (depends on call-workflow-ci)
   a. Sets failure URL (if failed)
5. call-workflow-create-issue job starts (depends on notify_failure, if failed)
   a. create_issue.yml called
   b. createissue.sh runs
6. call-workflow-vulncheck job starts (depends on call-workflow-ci)
   a. ci-vulncheck.yml called
   b. execgovuln.sh runs
7. call-workflow-cd-voeger job starts (depends on call-workflow-vulncheck)
   a. cd-voedger.yml called
   b. Docker build & push runs
```

---

## Summary Statistics

- **Total Workflows:** 14 in voedger, 4+ in ci-action
- **Total Custom Actions:** 5 in voedger
- **Total Bash Scripts:** 11+ in ci-action
- **GitHub Events Handled:** 6 types (PR, Push, Schedule, Issues, Manual)
- **Reusable Workflows:** 4 in ci-action
- **Cross-Repository References:** 20+

