// Creates 5000 products + PricebookEntries per run
// Run this script 5 times to add 25,000 total (on top of existing 3,000 = 28,000)
// Or run 4-5 times depending on how many already exist

Id stdPbId = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1].Id;
Integer existing = [SELECT COUNT() FROM Product2 WHERE ProductCode LIKE 'DEMO-%'];
Integer startNum = existing + 1;
Integer batchSize = 5000;

List<Product2> prods = new List<Product2>();
for (Integer i = startNum; i < startNum + batchSize; i++) {
    prods.add(new Product2(
        Name = 'Demo Product ' + i,
        ProductCode = 'DEMO-' + String.valueOf(i).leftPad(6, '0'),
        IsActive = true
    ));
}
insert prods;

List<PricebookEntry> pbes = new List<PricebookEntry>();
for (Product2 p : prods) {
    pbes.add(new PricebookEntry(
        Pricebook2Id = stdPbId,
        Product2Id = p.Id,
        UnitPrice = Math.round(Math.random() * 99900 + 100) / 100.0,
        IsActive = true
    ));
}
insert pbes;
System.debug('BATCH COMPLETE: Created ' + prods.size() + ' products and ' + pbes.size() + ' PBEs. Start offset: ' + startNum);
Integer totalPBE = [SELECT COUNT() FROM PricebookEntry WHERE Pricebook2.Name = 'Standard Price Book'];
System.debug('TOTAL PricebookEntries: ' + totalPBE);
