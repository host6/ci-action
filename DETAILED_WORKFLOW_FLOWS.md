# Detailed Workflow Execution Flows

## 1. PR on pkg-cmd

**Trigger:** `pull_request_target` | **File:** [`ci-pkg-cmd_pr.yml`](.github/workflows/ci-pkg-cmd_pr.yml#L1)

[call-workflow-ci-pkg](.github/workflows/ci-pkg-cmd_pr.yml#L9) → [`ci_reuse_go_pr.yml`](.github/workflows/ci_reuse_go_pr.yml#L1)
1. [Set up Go 1.24](.github/workflows/ci_reuse_go_pr.yml#L42)
2. [Install TinyGo](.github/workflows/ci_reuse_go_pr.yml#L49)
3. [Checkout PR](.github/workflows/ci_reuse_go_pr.yml#L54)
4. [Check PR size](.github/workflows/ci_reuse_go_pr.yml#L60)
5. [Cancel workflows](.github/workflows/ci_reuse_go_pr.yml#L66)
6. [Cache modules](.github/workflows/ci_reuse_go_pr.yml#L74)
7. [Run CI action](.github/workflows/ci_reuse_go_pr.yml#L82)
8. [Test subfolders](.github/workflows/ci_reuse_go_pr.yml#L95)
9. [Check copyright](.github/workflows/ci_reuse_go_pr.yml#L100)
10. [Run linters](.github/workflows/ci_reuse_go_pr.yml#L103)

[auto-merge-pr](.github/workflows/ci-pkg-cmd_pr.yml#L25) → [`merge.yml`](.github/workflows/merge.yml#L1)
- [Merge PR](.github/workflows/merge.yml#L15)

## CI Action Flow

**File:** [`index.js`](index.js#L1) | **Config:** [`action.yml`](action.yml#L1)

1. [Parse Inputs](index.js#L15)
2. [Extract Context](index.js#L39)
3. [Log Context](index.js#L57)
4. [Reject Hidden Folders](index.js#L71)
5. [Check Sources](index.js#L74)
6. [Detect Language](index.js#L78)

**If Go Project:**
7. [Setup Deps](index.js#L88)
8. [Change Folder](index.js#L95)
9. [go mod tidy](index.js#L99)
10. [Build](index.js#L103)
11. [Test+Codecov](index.js#L109)
12. [Restore Dir](index.js#L139)
13. [Custom Build](index.js#L142)

**If Node.js Project:**
7. [npm install](index.js#L155)
8. [npm build](index.js#L156)
9. [npm test](index.js#L157)
10. [Codecov](index.js#L160)

14. [Publish Asset](index.js#L174)
15. [Set Outputs](index.js#L184)
16. [Error Handling](index.js#L188)

**Modules:** [`common.js`](common.js#L11) | [`checkSources.js`](checkSources.js#L30) | [`rejectHiddenFolders.js`](rejectHiddenFolders.js#L15) | [`publish.js`](publish.js#L52)

---

## 2. PR on Storage Paths

**Trigger:** `pull_request_target` | **File:** [`ci-pkg-storage.yml`](.github/workflows/ci-pkg-storage.yml#L1)

1. [determine_changes](.github/workflows/ci-pkg-storage.yml#L19)
2. [Get changed files](.github/workflows/ci-pkg-storage.yml#L37)

**If CAS/TTL changed:**
3. [trigger_cas](.github/workflows/ci-pkg-storage.yml#L145) → [`ci_cas.yml`](.github/workflows/ci_cas.yml#L1)
   - [Checkout](.github/workflows/ci_cas.yml#L35)
   - [Setup Go](.github/workflows/ci_cas.yml#L38)
   - [Cache](.github/workflows/ci_cas.yml#L33)
   - [Cassandra tests](.github/workflows/ci_cas.yml#L41)
   - [TTL tests](.github/workflows/ci_cas.yml#L47)

**If Amazon/TTL changed:**
4. [trigger_amazon](.github/workflows/ci-pkg-storage.yml#L164) → [`ci_amazon.yml`](.github/workflows/ci_amazon.yml#L1)
   - [Checkout](.github/workflows/ci_amazon.yml#L35)
   - [Setup Go](.github/workflows/ci_amazon.yml#L38)
   - [DynamoDB tests](.github/workflows/ci_amazon.yml#L43)
   - [TTL tests](.github/workflows/ci_amazon.yml#L53)

5. [auto-merge-pr](.github/workflows/ci-pkg-storage.yml#L183) → [`merge.yml`](.github/workflows/merge.yml#L1)

---

## 3. Push to main (pkg-cmd)

**Trigger:** `push` | **File:** [`ci-pkg-cmd.yml`](.github/workflows/ci-pkg-cmd.yml#L1)

1. [call-workflow-ci-pkg](.github/workflows/ci-pkg-cmd.yml#L11) → [`ci_reuse_go.yml`](.github/workflows/ci_reuse_go.yml#L1)
   - [Checkout](.github/workflows/ci_reuse_go.yml#L42)
   - [Setup Go](.github/workflows/ci_reuse_go.yml#L45)
   - [TinyGo](.github/workflows/ci_reuse_go.yml#L52)
   - [Cache](.github/workflows/ci_reuse_go.yml#L64)
   - [CI action](.github/workflows/ci_reuse_go.yml#L72)
   - [Tests](.github/workflows/ci_reuse_go.yml#L85)
   - [Copyright](.github/workflows/ci_reuse_go.yml#L94)
   - [Linters](.github/workflows/ci_reuse_go.yml#L97)

2. [build](.github/workflows/ci-pkg-cmd.yml#L26) → [Set BP3 flag](.github/workflows/ci-pkg-cmd.yml#L34)

3. [call-workflow-cd_voeger](.github/workflows/ci-pkg-cmd.yml#L43) → [`cd-voedger.yml`](../voedger/.github/workflows/cd-voedger.yml#L1)
   - [Checkout](../voedger/.github/workflows/cd-voedger.yml#L21)
   - [Setup Go](../voedger/.github/workflows/cd-voedger.yml#L24)
   - [Build](../voedger/.github/workflows/cd-voedger.yml#L30)
   - [Docker login](../voedger/.github/workflows/cd-voedger.yml#L40)
   - [Push image](../voedger/.github/workflows/cd-voedger.yml#L46)

---

## 4. Daily Scheduled (5 AM UTC)

**Trigger:** `schedule` | **File:** [`ci-full.yml`](.github/workflows/ci-full.yml#L1)

1. [call-workflow-ci](.github/workflows/ci-full.yml#L9) → [`ci_reuse_go.yml`](.github/workflows/ci_reuse_go.yml#L1) (with race detector)
   - [Checkout](.github/workflows/ci_reuse_go.yml#L42)
   - [Setup Go](.github/workflows/ci_reuse_go.yml#L45)
   - [TinyGo](.github/workflows/ci_reuse_go.yml#L52)
   - [Cache](.github/workflows/ci_reuse_go.yml#L64)
   - [CI action](.github/workflows/ci_reuse_go.yml#L72)
   - [Tests](.github/workflows/ci_reuse_go.yml#L85)
   - [Copyright](.github/workflows/ci_reuse_go.yml#L94)
   - [Linters](.github/workflows/ci_reuse_go.yml#L97)

2. [notify_failure](.github/workflows/ci-full.yml#L23) (if failed) → [Set URL](.github/workflows/ci-full.yml#L30)

3. [call-workflow-create-issue](.github/workflows/ci-full.yml#L34) (if failed) → [`create_issue.yml`](../ci-action/.github/workflows/create_issue.yml#L1)
   - [Checkout](../ci-action/.github/workflows/create_issue.yml#L32)
   - [Create issue](../ci-action/.github/workflows/create_issue.yml#L35)

4. [call-workflow-vulncheck](.github/workflows/ci-full.yml#L47) → [`ci-vulncheck.yml`](../voedger/.github/workflows/ci-vulncheck.yml#L1)
   - [Setup Go](../voedger/.github/workflows/ci-vulncheck.yml#L11)
   - [Checkout](../voedger/.github/workflows/ci-vulncheck.yml#L18)
   - [Install govulncheck](../voedger/.github/workflows/ci-vulncheck.yml#L21)
   - [Run check](../voedger/.github/workflows/ci-vulncheck.yml#L21)

5. [call-workflow-cd-voeger](.github/workflows/ci-full.yml#L50) → [`cd-voedger.yml`](../voedger/.github/workflows/cd-voedger.yml#L1)

---

## 5. Manual Trigger (ctool Integration)

**Trigger:** `workflow_dispatch` | **File:** [`ctool-integration-test.yml`](.github/workflows/ctool-integration-test.yml#L1)

1. [deploy](.github/workflows/ctool-integration-test.yml#L25)
   - [Checkout](.github/workflows/ctool-integration-test.yml#L44)
   - [AWS creds](.github/workflows/ctool-integration-test.yml#L47)
   - [Terraform](.github/actions/infrastructure-create-action/action.yml#L17)
   - [SSH](.github/workflows/ctool-integration-test.yml#L64)
   - [Init cluster](.github/workflows/ctool-integration-test.yml#L89)
   - [Tests](.github/workflows/ctool-integration-test.yml#L109)
   - [Destroy](.github/workflows/ctool-integration-test.yml#L123)

2. [upgrade](.github/workflows/ctool-integration-test.yml#L135)
   - [Checkout](.github/workflows/ctool-integration-test.yml#L156)
   - [AWS creds](.github/workflows/ctool-integration-test.yml#L159)
   - [Infra](.github/workflows/ctool-integration-test.yml#L166)
   - [SSH](.github/workflows/ctool-integration-test.yml#L176)
   - [Upgrade](.github/workflows/ctool-integration-test.yml#L264)
   - [Tests](.github/workflows/ctool-integration-test.yml#L302)
   - [Destroy](.github/workflows/ctool-integration-test.yml#L316)

---

## 6. Issue Events

**Closed:** [`linkIssue.yml`](.github/workflows/linkIssue.yml#L1) → [Link to milestone](.github/workflows/linkIssue.yml#L12)

**Reopened:** [`unlinkIssue.yml`](.github/workflows/unlinkIssue.yml#L1) → [Unlink from milestone](.github/workflows/unlinkIssue.yml#L12)

**Opened (cprc/cprelease):** [`cp.yml`](.github/workflows/cp.yml#L1) → [Cherry-pick](.github/workflows/cp.yml#L8)

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

