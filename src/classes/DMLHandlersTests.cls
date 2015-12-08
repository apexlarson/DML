@isTest
class DMLHandlersTests
{
	static final Integer RECORD_COUNT = SObjectFactory.getRecordThreshold();
	static final SObjectField field = Opportunity.AccountId;

	static testMethod void testMapErrors_Constructor()
	{
		Test.startTest();
			DMLHandlers.MapErrors handler = new DMLHandlers.MapErrors(new List<SObject>());
		Test.stopTest();

		system.assert(handler.records.isEmpty(), 'The list passed in should be retained');
		system.assert(handler.relatedRecords.isEmpty(), 'The map should initialize empty');
		system.assertEquals('Id', String.valueOf(handler.lookup), 'Id should be the default lookup');
	}

	static testMethod void testMapErrors_MapBy()
	{
		Test.startTest();
			DMLHandlers.MapErrors handler = new DMLHandlers.MapErrors(new List<SObject>()).mapBy(field);
		Test.stopTest();

		system.assertEquals(String.valueOf(field), String.valueOf(handler.lookup), 'The lookup should be changed');
	}

	static testMethod void testMapErrors_MapTo_Grouping()
	{
		Set<Id> accountIds = Pluck.ids(SObjectFactory.create(Account.sObjectType, RECORD_COUNT));
		List<SObject> records = new List<SObject>();
		for (Id accountId : accountIds)
			records.addAll(SObjectFactory.build(Opportunity.sObjectType, RECORD_COUNT, field, accountId));

		Test.startTest();
			DMLHandlers.MapErrors handler = new DMLHandlers.MapErrors(new List<SObject>()).mapTo(field, records);
		Test.stopTest();

		system.assertEquals(RECORD_COUNT, handler.relatedRecords.size(), 'The records should be mapped');
		for (Id accountId : accountIds)
		{
			system.assert(handler.relatedRecords.containsKey(accountId), 'Each key should be mapped');
			system.assertEquals(RECORD_COUNT, handler.relatedRecords.get(accountId).size(), 'Every record should be mapped');
		}
	}

	static testMethod void testMapErrors_MapTo_Mapping()
	{
		List<SObject> records = SObjectFactory.create(Opportunity.sObjectType, RECORD_COUNT);

		Test.startTest();
			DMLHandlers.MapErrors handler = new DMLHandlers.MapErrors(new List<SObject>()).mapTo(records);
		Test.stopTest();

		system.assertEquals(RECORD_COUNT, handler.relatedRecords.size(), 'The records should be mapped');
		for (SObject record : records)
		{
			system.assert(handler.relatedRecords.containsKey(record.Id), 'Each key should be mapped');
			system.assertEquals(1, handler.relatedRecords.get(record.Id).size(), 'Every record should be mapped');
		}
	}

	static testMethod void testMapErrors_Handle_DmlException()
	{
		DML.Result result;
		try { insert new Lead(); }
		catch (DmlException dmx) { result = new DMLResults.AllOrNone(dmx); }

		List<SObject> accounts = SObjectFactory.create(Account.sObjectType, RECORD_COUNT);
		List<SObject> opportunities = new List<SObject>();
		for (Id accountId : Pluck.ids(accounts))
			opportunities.addAll(SObjectFactory.build(Opportunity.sObjectType, RECORD_COUNT, field, accountId));

		Test.startTest();
			new DMLHandlers.MapErrors(opportunities)
				.mapBy(field).mapTo(accounts).handle(result);
		Test.stopTest();

		// cannot assert on addError except when used in a trigger
	}

	static testMethod void testMapErrors_Handle_NoException()
	{
		List<Database.SaveResult> results = Database.insert(
			new List<Lead> { new Lead() }, /*allOrNone*/ false
		);
		DML.Result result = new DMLResults.Partial(results);

		List<SObject> accounts = SObjectFactory.create(Account.sObjectType, RECORD_COUNT);
		List<SObject> opportunities = new List<SObject>();
		for (Id accountId : Pluck.ids(accounts))
			opportunities.addAll(SObjectFactory.build(Opportunity.sObjectType, RECORD_COUNT, field, accountId));

		Test.startTest();
			new DMLHandlers.MapErrors(opportunities)
				.mapBy(field).mapTo(accounts).handle(result);
		Test.stopTest();

		// cannot assert on addError except when used in a trigger
	}
}