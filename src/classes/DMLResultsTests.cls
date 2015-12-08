@isTest
with sharing class DMLResultsTests
{
	static testMethod void testAllOrNone()
	{
		DMLException allOrNoneException;
		try { insert DMLTestUtility.getExceptionRecords_Upsert(); }
		catch (DmlException dmx) { allOrNoneException = dmx; }

		Test.startTest();
			DML.Result result = new DMLResults.AllOrNone(allOrNoneException);
		Test.stopTest();

		system.assertNotEquals(null, result.getDmlException(),
			'The exception should be retained');
		system.assertEquals(DMLTestUtility.DEFAULT_COUNT, result.getNumDml(),
			'The correct number of records should be processed');
		for (Integer i = 0; i < result.getNumDml(); i++)
		{
			system.assertEquals(null, result.getDmlId(i),
				'The correct records should be processed');
			system.assertEquals(String.valueOf(StatusCode.REQUIRED_FIELD_MISSING), result.getDmlStatusCode(i),
				'The status code should be preserved');
			system.assertNotEquals(null, result.getDmlMessage(i),
				'There should be an exception message');

			List<String> dmlFields = result.getDmlFields(i);
			system.assertNotEquals(null, dmlFields, 'There should be error fields');
			system.assert(!dmlFields.isEmpty(), 'There should be error fields');
		}
	}

	static testMethod void testAllOrNone_NoException()
	{
		final Integer numDml = 0;

		Test.startTest();
			DML.Result result = new DMLResults.AllOrNone(numDml);
		Test.stopTest();

		system.assertEquals(numDml, result.getNumDml(),
			'The correct number of records should be processed');
		system.assertEquals(null, result.getDmlId(0),
			'The correct records should be processed');
		system.assertEquals(null, result.getDmlStatusCode(0),
			'The status code should be preserved');
		system.assertEquals(null, result.getDmlMessage(0),
			'There should be an exception message');
		system.assertEquals(null, result.getDmlException(),
			'The exception should be retained');

		List<String> dmlFields = result.getDmlFields(0);
		system.assertNotEquals(null, dmlFields, 'There should be a collection');
		system.assert(dmlFields.isEmpty(), 'The collection should be empty');
	}

	static testMethod void testPartial_Save()
	{
		List<Database.SaveResult> results = Database.insert(DMLTestUtility.getExceptionRecords_Upsert(), /*allOrNone*/ false);

		Test.startTest();
			DML.Result result = new DMLResults.Partial(results);
		Test.stopTest();

		system.assertEquals(null, result.getDmlException(),
			'The exception should be retained');
		system.assertEquals(DMLTestUtility.DEFAULT_COUNT, result.getNumDml(),
			'The correct number of records should be processed');
		for (Integer i = 0; i < result.getNumDml(); i++)
		{
			system.assertEquals(null, result.getDmlId(i),
				'The correct records should be processed');
			system.assertEquals(String.valueOf(StatusCode.REQUIRED_FIELD_MISSING), result.getDmlStatusCode(i),
				'The status code should be preserved');
			system.assertNotEquals(null, result.getDmlMessage(i),
				'There should be an exception message');

			List<String> dmlFields = result.getDmlFields(i);
			system.assertNotEquals(null, dmlFields, 'There should be error fields');
			system.assert(!dmlFields.isEmpty(), 'There should be error fields');
		}
	}

	static testMethod void testPartial_Upsert()
	{
		List<Database.UpsertResult> results = Database.upsert(DMLTestUtility.getExceptionRecords_Upsert(), /*allOrNone*/ false);

		Test.startTest();
			DML.Result result = new DMLResults.Partial(results);
		Test.stopTest();

		system.assertEquals(null, result.getDmlException(),
			'The exception should be retained');
		system.assertEquals(DMLTestUtility.DEFAULT_COUNT, result.getNumDml(),
			'The correct number of records should be processed');
		for (Integer i = 0; i < result.getNumDml(); i++)
		{
			system.assertEquals(null, result.getDmlId(i),
				'The correct records should be processed');
			system.assertEquals(String.valueOf(StatusCode.REQUIRED_FIELD_MISSING), result.getDmlStatusCode(i),
				'The status code should be preserved');
			system.assertNotEquals(null, result.getDmlMessage(i),
				'There should be an exception message');

			List<String> dmlFields = result.getDmlFields(i);
			system.assertNotEquals(null, dmlFields, 'There should be error fields');
			system.assert(!dmlFields.isEmpty(), 'There should be error fields');
		}
	}

	static testMethod void testPartial_Delete()
	{
		List<Case> cases = DMLTestUtility.getExceptionRecords_Delete(Case.sObjectType);
		List<Database.DeleteResult> results = Database.delete(cases, /*allOrNone*/ false);

		Test.startTest();
			DML.Result result = new DMLResults.Partial(results);
		Test.stopTest();

		system.assertEquals(null, result.getDmlException(),
			'The exception should be retained');
		system.assertEquals(DMLTestUtility.DEFAULT_COUNT, result.getNumDml(),
			'The correct number of records should be processed');
		for (Integer i = 0; i < result.getNumDml(); i++)
		{
			system.assertEquals(cases[i].Id, result.getDmlId(i),
				'The correct records should be processed');
			system.assertEquals(String.valueOf(StatusCode.ENTITY_IS_DELETED), result.getDmlStatusCode(i),
				'The status code should be preserved');
			system.assertNotEquals(null, result.getDmlMessage(i),
				'There should be an exception message');

			List<String> dmlFields = result.getDmlFields(i);
			system.assertNotEquals(null, dmlFields, 'There should be error fields');
			system.assert(dmlFields.isEmpty(), 'There should be error fields');
		}
	}

	static testMethod void testPartial_Undelete()
	{
		List<Case> cases = DMLTestUtility.getExceptionRecords_Undelete(Case.sObjectType);
		List<Database.UndeleteResult> results = Database.undelete(cases, /*allOrNone*/ false);

		Test.startTest();
			DML.Result result = new DMLResults.Partial(results);
		Test.stopTest();

		system.assertEquals(null, result.getDmlException(),
			'The exception should be retained');
		system.assertEquals(DMLTestUtility.DEFAULT_COUNT, result.getNumDml(),
			'The correct number of records should be processed');
		for (Integer i = 0; i < result.getNumDml(); i++)
		{
			system.assertEquals(cases[i].Id, result.getDmlId(i),
				'The correct records should be processed');
			system.assertEquals(String.valueOf(StatusCode.UNDELETE_FAILED), result.getDmlStatusCode(i),
				'The status code should be preserved');
			system.assertNotEquals(null, result.getDmlMessage(i),
				'There should be an exception message');

			List<String> dmlFields = result.getDmlFields(i);
			system.assertNotEquals(null, dmlFields, 'There should be error fields');
			system.assert(dmlFields.isEmpty(), 'There should be error fields');
		}
	}
}