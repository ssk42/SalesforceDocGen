# Portwood DocGen — Code Analyzer Security Report

**Package:** Portwood DocGen v1.2.0 (portwoodglobal namespace)
**Scan Date:** March 28, 2026
**Scanner:** Salesforce Code Analyzer v5.9.0 (sf code-analyzer run --rule-selector "recommended")
**Target:** force-app/ (all package source — Apex classes, LWC, custom objects, permission sets)

## Summary

| Severity | Count | Status |
|----------|-------|--------|
| **Critical** | **0** | Clean |
| **High** | **0** | Clean |
| Moderate | 289 | Code quality only (see below) |
| Low | 392 | Style/documentation (see below) |
| Info | 56 | Copy-paste detection |

**Zero security vulnerabilities found. All Critical and High severity violations are zero.**

## Security-Relevant Findings

None. The scan found zero violations in any security-relevant category:

- **No CRUD/FLS violations** — all SOQL queries use `WITH USER_MODE` or `AccessLevel.USER_MODE`
- **No sharing violations** — all classes declare `with sharing`
- **No SOQL injection** — all dynamic SOQL uses bind variables and `String.escapeSingleQuotes()`
- **No XSS vulnerabilities** — no unescaped user input in markup
- **No hardcoded credentials** — no API keys, passwords, or tokens in source
- **No SOQL/DML in loops** — all refactored to bulk operations
- **No external callouts** — zero HttpRequest usage in the distributed package

## Moderate Violations (289) — Not Security Related

These are all **code quality metrics**, not security findings:

| Rule | Count | Category |
|------|-------|----------|
| CyclomaticComplexity | 84 | Method branching complexity |
| CognitiveComplexity | 62 | Method readability |
| AvoidDeeplyNestedIfStmts | 59 | Nested if statements |
| NcssCount | 44 | Method line count |
| ExcessiveParameterList | 23 | Method parameter count |
| no-async-operation (ESLint) | 7 | setTimeout/setInterval in LWC |
| AvoidBooleanMethodParameters | 8 | Boolean params |
| AvoidGlobalModifier | 2 | Required for @InvocableMethod |

**Why these are not security risks:** Cyclomatic/cognitive complexity, method length, and parameter counts are software engineering quality metrics. They indicate methods that could benefit from refactoring but do not represent security vulnerabilities. The `AvoidGlobalModifier` violations are intentional — `global` access is required for @InvocableMethod to be visible in Flow Builder across namespace boundaries.

## Low Violations (392) — Documentation & Style

| Rule | Count | Category |
|------|-------|----------|
| no-hardcoded-values-slds2 (ESLint) | 24 | CSS values without SLDS tokens |
| ApexDoc | 212 | Missing Javadoc comments |
| ApexUnitTestClassShouldHaveRunAs | 95 | Test methods without System.runAs() |
| no-slds-namespace-for-custom-hooks | 45 | CSS custom property naming |
| AnnotationsNamingConventions | 5 | @isTest vs @IsTest casing |
| AvoidNonRestrictiveQueries | 2 | Queries with LIMIT but no WHERE |
| Other | 9 | Minor style suggestions |

**Why these are not security risks:** Missing documentation, test patterns, CSS naming conventions, and annotation casing have no impact on application security.

## Info Violations (56)

All 56 Info-level findings are from the **copy-paste detection (CPD)** engine, identifying similar code blocks. These are refactoring suggestions, not security findings.

## Detailed Report

The full violation-by-violation CSV report is attached as `code-analyzer-report.csv`.

## Scan Reproduction

To reproduce this scan:

```bash
sf plugins install @salesforce/plugin-code-analyzer
sf code-analyzer run --rule-selector "recommended" --target force-app
```

## No DAST Scanner Required

This solution has no external web application, API, mobile application, or external component. All functionality runs within the Salesforce platform using standard Apex and LWC. No external endpoints are exposed or consumed. Therefore, no DAST scan (OWASP ZAP, Burp Suite, etc.) is applicable.
