@IsTest
class DMLTests
{
	static final Integer RECORD_COUNT = SObjectFactory.getRecordThreshold();

	static testmethod void smokeTestAllOrNone()
	{
		List<SObject> records = SObjectFactory.create(Opportunity.sObjectType, RECORD_COUNT);
		Test.startTest();
			new DML(records)
				.safeInsert().safeUpdate()
				.safeDelete().safeUndelete()
				.safeUpsert(Opportunity.sObjectType);
		Test.stopTest();
	}
	static testmethod void smokeTestPartial()
	{
		List<SObject> records = SObjectFactory.create(Opportunity.sObjectType, RECORD_COUNT);
		Test.startTest();
			new DML(records)
				.partialInsert().partialUpdate()
				.partialDelete().partialUndelete()
				.partialUpsert(Opportunity.sObjectType);
		Test.stopTest();
	}

	static testMethod void testMapToSiblings()
	{
		final Integer RECORDS_PER = 2;
		List<SObject> accounts = SObjectFactory.create(Account.sObjectType, RECORD_COUNT);
		List<SObject> opportunities = SObjectFactory.build(
			Opportunity.sObjectType, RECORD_COUNT, Opportunity.AccountId,
			SObjectFactory.provideParents(accounts)
		);
		List<SObject> contacts = SObjectFactory.build(
			Contact.sObjectType, RECORDS_PER * RECORD_COUNT, Contact.AccountId,
			SObjectFactory.provideParents(accounts)
		);

		Test.startTest();
			DML operation = new DML(opportunities)
				.mapToSiblings(Opportunity.AccountId, Contact.AccountId, contacts);
		Test.stopTest();

		system.assertEquals(1, operation.handlers.size(),
			'The handler should be added');
		system.assert(operation.handlers[0] instanceof DMLHandlers.MapErrors,
			'The handler should be a MapErrors handler');
		DMLHandlers.MapErrors handler = (DMLHandlers.MapErrors)operation.handlers[0];
		system.assertEquals(String.valueOf(Opportunity.AccountId), String.valueOf(handler.lookup),
			'The handler should have the origin lookup set');
		system.assertEquals(RECORD_COUNT, handler.relatedRecords.size(),
			'Each key should be mapped');
		for (SObject account : accounts)
		{
			system.assert(handler.relatedRecords.containsKey(account.Id),
				'Every key should be mapped');
			system.assertEquals(RECORDS_PER, handler.relatedRecords.get(account.Id).size(),
				'Records should be properly grouped');
		}
	}
	static testMethod void testMapToParent()
	{
		List<SObject> accounts = SObjectFactory.create(Account.sObjectType, RECORD_COUNT);
		List<SObject> opportunities = SObjectFactory.build(
			Opportunity.sObjectType, RECORD_COUNT, Opportunity.AccountId,
			SObjectFactory.provideParents(accounts)
		);

		Test.startTest();
			DML operation = new DML(opportunities)
				.mapToParent(Opportunity.AccountId, accounts);
		Test.stopTest();

		system.assertEquals(1, operation.handlers.size(),
			'The handler should be added');
		system.assert(operation.handlers[0] instanceof DMLHandlers.MapErrors,
			'The handler should be a MapErrors handler');
		DMLHandlers.MapErrors handler = (DMLHandlers.MapErrors)operation.handlers[0];
		system.assertEquals(String.valueOf(Opportunity.AccountId), String.valueOf(handler.lookup),
			'The handler should have the origin lookup set');
		system.assertEquals(RECORD_COUNT, handler.relatedRecords.size(),
			'Each key should be mapped');
		for (SObject account : accounts)
		{
			system.assert(handler.relatedRecords.containsKey(account.Id),
				'Every key should be mapped');
			system.assertEquals(1, handler.relatedRecords.get(account.Id).size(),
				'Records should be properly grouped');
		}
	}
	static testMethod void testMapToChildren()
	{
		final Integer RECORDS_PER = 2;
		List<SObject> accounts = SObjectFactory.create(Account.sObjectType, RECORD_COUNT);
		List<SObject> opportunities = SObjectFactory.build(
			Opportunity.sObjectType, RECORDS_PER * RECORD_COUNT, Opportunity.AccountId,
			SObjectFactory.provideParents(accounts)
		);

		Test.startTest();
			DML operation = new DML(accounts)
				.mapToChildren(Opportunity.AccountId, opportunities);
		Test.stopTest();

		system.assertEquals(1, operation.handlers.size(),
			'The handler should be added');
		system.assert(operation.handlers[0] instanceof DMLHandlers.MapErrors,
			'The handler should be a MapErrors handler');
		DMLHandlers.MapErrors handler = (DMLHandlers.MapErrors)operation.handlers[0];
		system.assertEquals(String.valueOf(Account.Id), String.valueOf(handler.lookup),
			'The handler should have the origin lookup set');
		system.assertEquals(RECORD_COUNT, handler.relatedRecords.size(),
			'Each key should be mapped');
		for (SObject account : accounts)
		{
			system.assert(handler.relatedRecords.containsKey(account.Id),
				'Every key should be mapped');
			system.assertEquals(RECORDS_PER, handler.relatedRecords.get(account.Id).size(),
				'Records should be properly grouped');
		}
	}
}