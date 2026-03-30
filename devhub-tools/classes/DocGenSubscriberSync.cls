/**
 * Scheduled job that syncs PackageSubscriber data into DocGen_Subscriber_Org__c
 * records linked to Account records. Runs in the DevHub org only.
 *
 * Schedule: System.schedule('DocGen Subscriber Sync', '0 0 0/6 * * ?', new DocGenSubscriberSync());
 *
 * This class uses without sharing and SYSTEM_MODE because it runs as a scheduled
 * job under the system context — no user session, no sharing rules apply.
 * All DML is internal DevHub data management (Account + Subscriber Org records).
 */
public without sharing class DocGenSubscriberSync implements Schedulable {

    public void execute(SchedulableContext sc) {
        syncSubscribers();
    }

    @AuraEnabled
    public static void syncNow() {
        syncSubscribers();
    }

    private static void syncSubscribers() {
        List<MetadataPackage> packages = [
            SELECT Id FROM MetadataPackage WHERE NamespacePrefix = 'portwoodglobal' WITH SYSTEM_MODE LIMIT 1
        ];
        if (packages.isEmpty()) return;
        String packageId = packages[0].Id;

        Map<String, String> versionMap = new Map<String, String>();
        for (MetadataPackageVersion mpv : [
            SELECT Id, MajorVersion, MinorVersion, PatchVersion, Name
            FROM MetadataPackageVersion WHERE MetadataPackageId = :packageId WITH SYSTEM_MODE
        ]) {
            versionMap.put(mpv.Id, 'v' + mpv.MajorVersion + '.' + mpv.MinorVersion + '.' + mpv.PatchVersion);
        }

        List<PackageSubscriber> subscribers = [
            SELECT OrgKey, OrgName, OrgType, InstalledStatus, MetadataPackageVersionId, SystemModstamp
            FROM PackageSubscriber WHERE MetadataPackageId = :packageId WITH SYSTEM_MODE
        ];
        if (subscribers.isEmpty()) return;

        Set<String> orgIds = new Set<String>();
        for (PackageSubscriber sub : subscribers) { orgIds.add(sub.OrgKey); }

        Map<String, DocGen_Subscriber_Org__c> existingOrgs = new Map<String, DocGen_Subscriber_Org__c>();
        for (DocGen_Subscriber_Org__c so : [
            SELECT Id, Org_Id__c, Account__c FROM DocGen_Subscriber_Org__c WHERE Org_Id__c IN :orgIds WITH SYSTEM_MODE
        ]) {
            existingOrgs.put(so.Org_Id__c, so);
        }

        // Build normalized name → Account map for fuzzy matching.
        // Multiple orgs (prod + sandboxes) from the same company should link to ONE Account.
        Map<String, Account> accountsByName = new Map<String, Account>();
        Map<String, Account> accountsByNormalized = new Map<String, Account>();
        for (Account a : [SELECT Id, Name FROM Account WITH SYSTEM_MODE LIMIT 50000]) {
            accountsByName.put(a.Name, a);
            accountsByNormalized.put(normalizeOrgName(a.Name), a);
        }

        Id customerRtId;
        List<RecordType> rts = [
            SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'Customer' WITH SYSTEM_MODE LIMIT 1
        ];
        if (!rts.isEmpty()) customerRtId = rts[0].Id;

        // Match subscriber orgs to Accounts. Try exact name first, then normalized
        // (strips sandbox/developer suffixes so "Acme Corp - Sandbox" matches "Acme Corp").
        // Only create a new Account if no match found AND the org doesn't already have one.
        List<Account> newAccounts = new List<Account>();
        Map<String, Account> resolvedAccounts = new Map<String, Account>(); // orgKey → Account
        for (PackageSubscriber sub : subscribers) {
            String orgName = String.isNotBlank(sub.OrgName) ? sub.OrgName : sub.OrgKey;

            // Skip if this org already has an Account linked
            if (existingOrgs.containsKey(sub.OrgKey) && existingOrgs.get(sub.OrgKey).Account__c != null) {
                continue;
            }

            // Try exact match
            Account matched = accountsByName.get(orgName);
            // Try normalized match (strip sandbox/dev suffixes)
            if (matched == null) {
                matched = accountsByNormalized.get(normalizeOrgName(orgName));
            }

            if (matched != null) {
                resolvedAccounts.put(sub.OrgKey, matched);
            } else {
                // Create new Account using the normalized name (clean company name)
                String cleanName = normalizeOrgName(orgName);
                if (String.isBlank(cleanName)) cleanName = orgName;
                // Check if we already queued an Account with this clean name
                if (!accountsByNormalized.containsKey(cleanName)) {
                    Account a = new Account(Name = cleanName);
                    if (customerRtId != null) a.RecordTypeId = customerRtId;
                    newAccounts.add(a);
                    accountsByNormalized.put(cleanName, a);
                }
                resolvedAccounts.put(sub.OrgKey, accountsByNormalized.get(cleanName));
            }
        }

        if (!newAccounts.isEmpty()) {
            Map<String, Account> deduped = new Map<String, Account>();
            for (Account a : newAccounts) { deduped.put(a.Name, a); }
            newAccounts = deduped.values();
            insert newAccounts; // NOPMD ApexCRUDViolation — scheduled sync: auto-creating Account records for subscriber orgs
            for (Account a : newAccounts) {
                accountsByName.put(a.Name, a);
                accountsByNormalized.put(normalizeOrgName(a.Name), a);
            }
        }

        List<DocGen_Subscriber_Org__c> upsertOrgs = new List<DocGen_Subscriber_Org__c>();
        for (PackageSubscriber sub : subscribers) {
            String orgName = String.isNotBlank(sub.OrgName) ? sub.OrgName : sub.OrgKey;
            String statusLabel = sub.InstalledStatus == 'i' ? 'Installed' : sub.InstalledStatus == 'u' ? 'Uninstalled' : sub.InstalledStatus;

            DocGen_Subscriber_Org__c so;
            if (existingOrgs.containsKey(sub.OrgKey)) {
                so = existingOrgs.get(sub.OrgKey);
            } else {
                so = new DocGen_Subscriber_Org__c();
                so.Org_Id__c = sub.OrgKey;
            }

            so.Name = orgName;
            so.Org_Type__c = sub.OrgType;
            so.Install_Status__c = statusLabel;
            so.Install_Date__c = sub.SystemModstamp;
            so.Last_Synced__c = Datetime.now();
            if (versionMap.containsKey(sub.MetadataPackageVersionId)) {
                so.Package_Version__c = versionMap.get(sub.MetadataPackageVersionId);
            }
            if (so.Account__c == null && resolvedAccounts.containsKey(sub.OrgKey)) {
                so.Account__c = resolvedAccounts.get(sub.OrgKey).Id;
            }
            upsertOrgs.add(so);
        }

        if (!upsertOrgs.isEmpty()) {
            upsert upsertOrgs Org_Id__c; // NOPMD ApexCRUDViolation — scheduled sync: upserting Subscriber Org records
        }
    }

    /**
     * Normalizes an org name for fuzzy Account matching.
     * Strips common Salesforce org suffixes so production and sandbox orgs
     * from the same company resolve to one Account.
     * "Acme Corp - Sandbox" → "Acme Corp"
     * "Acme Corp Developer Edition" → "Acme Corp"
     */
    private static String normalizeOrgName(String name) {
        if (String.isBlank(name)) return '';
        String n = name.trim();
        // Strip trailing patterns: " - Sandbox", " Sandbox", " - Developer", " Developer Edition", " - Dev", " (Sandbox)", " (Dev)"
        n = n.replaceAll('(?i)\\s*[-–]?\\s*(sandbox|developer\\s*edition|developer|dev|scratch|uat|staging|test|qa)\\s*$', '');
        n = n.replaceAll('(?i)\\s*\\((sandbox|dev|developer|test|uat|qa|staging|scratch)\\)\\s*$', '');
        return n.trim();
    }
}
