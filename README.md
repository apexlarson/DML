# DML

##Exception Handling Patterns

Exception handling for DML operations is something we should be able to standardize! Many of the most common handling patterns simply involve mapping the errors back to the source records.

### Updating Children (Map Back To Parent)

**Standard approach:**

    try
    {
        update records;
    }
    catch (DmlException dmx)
    {
        Map<Id, Parent__c> parentMap = new Map<Id, Parent__c>(parents);
        for (Integer i = 0; i < dmx.getNumDml(); i++)
        {
            MyObject__c errorRecord = records[dmx.getDmlIndex(i)];
            parentMap.get(errorRecord.Parent__c).addError(dmx);
        }
    }

**With DML:**

    new DML(records).mapToParent(MyObject__c.Parent__c, parents).safeUpdate();

### Updating Siblings (Map Back To Sibling)

**Standard approach:**

    try
    {
        update records;
    }
    catch (DmlException dmx)
    {
        Map<Id, List<MyObject__c>> siblingMap = new Map<Id, List<MyObject__c>>();
        for (MyObject__c sibling : siblings)
        {
            if (!siblingMap.containsKey(sibling.RelatedParent__c))
                siblingMap.put(sibling.RelatedParent__c, new List<MyObject__c>());
            siblingMap.get(sibling.RelatedParent__c).add(sibling);
        }
        for (Integer i = 0; i < dmx.getNumDml(); i++)
        {
            MyObject__c errorRecord = records[dmx.getDmlIndex(i)];
            for (MyObject__c sibling : siblingMap.get(errorRecord.OriginParent__c))
                sibling.addError(dmx);
        }
    }

**With DML:**

    new DML(records).mapToSiblings(MyObject__c.OriginParent__c, MyObject__c.RelatedParent__c, siblings).safeUpdate();

### Updating Parents (Map Back To Children)

**Standard approach:**

    try
    {
        update records;
    }
    catch (DmlException dmx)
    {
        Map<Id, List<Child__c>> childMap = new Map<Id, List<Child__c>>();
        for (Child__c child : children)
        {
            if (!childMap.containsKey(child.Parent__c))
                childMap.put(child.Parent__c, new List<Child__c>());
            childMap.get(child.Parent__c).add(child);
        }
        for (Integer i = 0; i < dmx.getNumDml(); i++)
        {
            MyObject__c errorRecord = records[dmx.getDmlIndex(i)];
            for (Child__c child : childMap.get(errorRecord.Id))
                child.addError(dmx);
        }
    }

**With DML:**

    new DML(records).mapToChildren(Child.Parent__c, children).safeUpdate();
