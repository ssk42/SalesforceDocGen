# Privacy Policy

**Portwood Global Solutions — Portwood DocGen**
*Last updated: March 28, 2026*

## The Short Version

We don't collect your data. Period. Portwood DocGen runs entirely inside your Salesforce org. Nothing leaves the platform. We have no servers, no analytics, no tracking, and no access to your org.

## 1. What Data We Collect

**None.** Portwood DocGen is a 100% native Salesforce application. All processing occurs within your Salesforce org using your existing Salesforce infrastructure. We do not operate any external servers, APIs, databases, or data collection systems.

Specifically, we do NOT collect:
- Personal information
- Salesforce org data or metadata
- Template content or generated documents
- Usage analytics or telemetry
- IP addresses or device information
- Cookies (outside of standard Salesforce session cookies)

## 2. How the Software Works

Portwood DocGen reads data from your Salesforce records, merges it into document templates, and saves the generated documents back to your Salesforce org as ContentVersion records. This entire process happens within the Salesforce platform boundary using standard Apex and Lightning Web Components. No data is transmitted externally at any point.

## 3. Data Storage

All data created or used by Portwood DocGen is stored in standard Salesforce objects within your org:
- Templates → DocGen_Template__c and ContentVersion
- Generated documents → ContentVersion linked to source records
- Job records → DocGen_Job__c
- Saved queries → DocGen_Saved_Query__c

This data is subject to your org's Salesforce security settings, sharing rules, field-level security, and data retention policies. We have no access to any of it.

## 4. Third-Party Services

Portwood DocGen does not integrate with, transmit data to, or receive data from any third-party service. There are no external callouts, webhooks, or API connections in the distributed package.

## 5. Salesforce Platform

Your use of Portwood DocGen is subject to Salesforce's own Privacy Policy and Terms of Service. Salesforce processes and stores your org data according to their policies. We recommend reviewing Salesforce's privacy documentation at salesforce.com/company/privacy.

## 6. Open Source

The full source code of Portwood DocGen is publicly available at github.com/Portwood-Global-Solutions/Portwood-DocGen under the Apache License 2.0. You can audit every line of code to verify our privacy claims.

## 7. Support Communications

If you contact us for support at hello@portwoodglobalsolutions.com or via GitHub Issues, we will receive and store the information you voluntarily provide (name, email, description of your issue). We use this information solely to provide support and will not sell or share it with third parties.

## 8. Partner Referrals

If you request implementation services, we may refer you to third-party Salesforce consulting partners. In doing so, we may share your name and contact information with the referred partner so they can reach out to you. We will only do this with your explicit consent.

## 9. Website

Our website at portwoodglobalsolutions.com is hosted on Salesforce Sites. Standard Salesforce session cookies are used for site functionality. We do not use Google Analytics, Facebook Pixel, or any third-party tracking tools on our website.

## 10. Children's Privacy

Portwood DocGen is a business application and is not directed at children under 13. We do not knowingly collect information from children.

## 11. International Data

Because all data stays within your Salesforce org, data residency is determined by your Salesforce instance location and your Salesforce contract. We do not transfer data across borders.

## 12. Changes

We may update this Privacy Policy from time to time. Changes will be posted at portwoodglobalsolutions.com/privacy. The "Last updated" date at the top reflects the most recent revision.

## 13. Contact

If you have questions about this Privacy Policy:

Portwood Global Solutions
hello@portwoodglobalsolutions.com
portwoodglobalsolutions.com
