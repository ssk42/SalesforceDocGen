# Portwood DocGen — AppExchange Package Info

## Package Details

| Field | Value |
|-------|-------|
| Package Name | Portwood DocGen Managed |
| Package Type | Managed 2GP |
| Namespace | portwoodglobal |
| Version | 1.0.0 |
| Subscriber Package Version ID | 04tal000006PEPJAA4 |
| Package ID | 0Hoal0000003d9hCAA |
| DevHub Org ID | 00Dal00001QGGvlEAH |

## Install Links

**Production:**
https://login.salesforce.com/packaging/installPackage.apexp?p0=04tal000006PEPJAA4

**Sandbox:**
https://test.salesforce.com/packaging/installPackage.apexp?p0=04tal000006PEPJAA4

**CLI:**
```bash
sf package install --package 04tal000006PEPJAA4 --wait 10 --target-org <your-org>
```

## Post-Install Setup

1. Assign **DocGen Admin** permission set to administrators
2. Assign **DocGen User** permission set to end users
3. Enable the **Blob.toPdf() Release Update** in Setup (required for PDF output)
4. Open the **DocGen** app from the App Launcher

## Test Org Credentials (for Security Review)

| Role | Username | Password | Login URL |
|------|----------|----------|-----------|
| System Administrator | test-gjvdgdhjyxdl@example.com | DocGenReview2026! | https://test.salesforce.com |
| Standard User | docgen-demo-v2@portwoodglobal.demo | DocGenUser2026! | https://test.salesforce.com |

Test org instance: https://java-site-4851-dev-ed.scratch.my.salesforce.com
Test org expiry: 2026-04-25

## Source Code

GitHub: https://github.com/Portwood-Global-Solutions/Portwood-DocGen
License: Apache 2.0

## Quality Metrics

| Metric | Value |
|--------|-------|
| Apex Tests | 507/507 passing |
| Code Coverage | 77% org-wide |
| E2E Tests | 24/24 passing |
| Code Analyzer Critical | 0 |
| Code Analyzer High | 0 |
| External Callouts | 0 |
| Sharing Model | All classes use `with sharing` |
| CRUD/FLS | All queries use `WITH USER_MODE` |
