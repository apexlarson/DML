@isTest
class DMLOperationsTests
{
	class AssertNoErrorsHandler implements DML.Handler
	{
		final Integer recordCount;
		AssertNoErrorsHandler(Integer recordCount) { this.recordCount = recordCount; }
		public void handle(DML.Result result)
		{
			system.assertEquals(null, result.getDmlException(),
				'There should be no exception');
			system.assertEquals(recordCount, result.getNumDml(),
				'The correct number of records should be processed');
			for (Integer i = 0; i < recordCount; i++)
			{
				system.assert(String.isBlank(result.getDmlStatusCode(i)),
					'There should be no errors');
				system.assert(String.isBlank(result.getDmlMessage(i)),
					'There should be no errors');
			}
		}
	}
	class AssertDmlExceptionHandler implements DML.Handler
	{
		public void handle(DML.Result result)
		{
			system.assertNotEquals(null, result.getDmlException(),
				'There should be an exception');
		}
	}
	static final Integer RECORD_COUNT = DMLTestUtility.DEFAULT_COUNT;

	static DML.Operation allOrNone_Exception(List<SObject> records)
	{
		return new DMLOperations.AllOrNone(records).addHandlers(
			new List<DML.Handler> { new AssertDmlExceptionHandler() }
		);
	}
	static DML.Operation allOrNone(List<SObject> records)
	{
		return new DMLOperations.AllOrNone(records).addHandlers(
			new List<DML.Handler> { new AssertNoErrorsHandler(records.size()) }
		);
	}
	static DML.Operation partial(List<SObject> records)
	{
		return new DMLOperations.Partial(records).addHandlers(
			new List<DML.Handler> { new AssertNoErrorsHandler(records.size()) }
		);
	}

	static testMethod void testAllOrNone_Insert()
	{
		List<SObject> records = SObjectFactory.build(Case.sObjectType, RECORD_COUNT);
		Test.startTest();
			allOrNone(records).safeInsert();
		Test.stopTest();
		system.assertEquals(RECORD_COUNT, [SELECT count() FROM Case], 'Records should be inserted');
	}
	static testMethod void testAllOrNone_Insert_Exception()
	{
		List<SObject> records = DMLTestUtility.getExceptionRecords_Upsert();
		Test.startTest();
			allOrNone_Exception(records).safeInsert();
		Test.stopTest();
		system.assertEquals(0, [SELECT count() FROM Lead], 'Records should not be inserted');
	}
	static testMethod void testAllOrNone_Upsert()
	{
		List<SObject> records = SObjectFactory.build(Case.sObjectType, RECORD_COUNT);
		records.addAll(SObjectFactory.create(Case.sObjectType, RECORD_COUNT));
		Test.startTest();
			allOrNone(records).safeUpsert(Case.sObjectType);
		Test.stopTest();
		system.assertEquals(RECORD_COUNT * 2, [SELECT count() FROM Case], 'Records should be inserted');
	}
	static testMethod void testAllOrNone_Upsert_Exception()
	{
		List<SObject> records = DMLTestUtility.getExceptionRecords_Upsert();
		Test.startTest();
			allOrNone_Exception(records).safeUpsert(Lead.sObjectType);
		Test.stopTest();
		system.assertEquals(0, [SELECT count() FROM Lead], 'Records should not be inserted');
	}
	static testMethod void testAllOrNone_Update()
	{
		List<SObject> records = SObjectFactory.create(Case.sObjectType, RECORD_COUNT);
		Test.startTest();
			allOrNone(records).safeUpdate();
		Test.stopTest();
		system.assertEquals(RECORD_COUNT, [SELECT count() FROM Case], 'Records should still exist');
	}
	static testMethod void testAllOrNone_Update_Exception()
	{
		List<SObject> records = DMLTestUtility.getExceptionRecords_Upsert();
		Test.startTest();
			allOrNone_Exception(records).safeUpdate();
		Test.stopTest();
		system.assertEquals(0, [SELECT count() FROM Lead], 'Records should not still exist');
	}
	static testMethod void testAllOrNone_Delete()
	{
		List<SObject> records = SObjectFactory.create(Case.sObjectType, RECORD_COUNT);
		Test.startTest();
			allOrNone(records).safeDelete();
		Test.stopTest();
		system.assertEquals(0, [SELECT count() FROM Case], 'Records should be deleted');
	}
	static testMethod void testAllOrNone_Delete_Exception()
	{
		List<SObject> records = DMLTestUtility.getExceptionRecords_Delete();
		system.assertEquals(0, [SELECT count() FROM Lead], 'Records should already be deleted');
		Test.startTest();
			allOrNone_Exception(records).safeDelete();
		Test.stopTest();
		system.assertEquals(0, [SELECT count() FROM Lead], 'Records should not be deleted');
	}
	static testMethod void testAllOrNone_Undelete()
	{
		List<SObject> records = SObjectFactory.create(Case.sObjectType, RECORD_COUNT);
		delete records;
		Test.startTest();
			allOrNone(records).safeUndelete();
		Test.stopTest();
		system.assertEquals(RECORD_COUNT, [SELECT count() FROM Case], 'Records should be undeleted');
	}
	static testMethod void testAllOrNone_Undelete_Exception()
	{
		List<SObject> records = DMLTestUtility.getExceptionRecords_Undelete();
		system.assertEquals(RECORD_COUNT, [SELECT count() FROM Lead], 'Records should not be in the recycle bin');
		Test.startTest();
			allOrNone_Exception(records).safeUndelete();
		Test.stopTest();
		system.assertEquals(RECORD_COUNT, [SELECT count() FROM Lead], 'Records should not be undeleted');
	}
	static testMethod void testAllOrNone_SingleRecord()
	{
		SObject record = SObjectFactory.build(Case.sObjectType);
		Test.startTest();
			new DMLOperations.AllOrNone(record).safeInsert();
		Test.stopTest();
		system.assertEquals(1, [SELECT count() FROM Case], 'Records should be inserted');
	}
	static testMethod void testAllOrNone_Ids()
	{
		Set<Id> recordIds = Pluck.ids(SObjectFactory.create(Case.sObjectType, RECORD_COUNT));
		Test.startTest();
			new DMLOperations.AllOrNone(recordIds).safeDelete();
		Test.stopTest();
		system.assertEquals(0, [SELECT count() FROM Case], 'Records should be deleted');
	}

	static testMethod void testPartial_Insert()
	{
		List<SObject> records = SObjectFactory.build(Case.sObjectType, RECORD_COUNT);
		Test.startTest();
			partial(records).safeInsert();
		Test.stopTest();
		system.assertEquals(RECORD_COUNT, [SELECT count() FROM Case], 'Records should be inserted');
	}
	static testMethod void testPartial_Upsert()
	{
		List<SObject> records = SObjectFactory.build(Case.sObjectType, RECORD_COUNT);
		records.addAll(SObjectFactory.create(Case.sObjectType, RECORD_COUNT));
		Test.startTest();
			partial(records).safeUpsert(Case.sObjectType);
		Test.stopTest();
		system.assertEquals(RECORD_COUNT * 2, [SELECT count() FROM Case], 'Records should be inserted');
	}
	static testMethod void testPartial_Update()
	{
		List<SObject> records = SObjectFactory.create(Case.sObjectType, RECORD_COUNT);
		Test.startTest();
			partial(records).safeUpdate();
		Test.stopTest();
		system.assertEquals(RECORD_COUNT, [SELECT count() FROM Case], 'Records should still exist');
	}
	static testMethod void testPartial_Delete()
	{
		List<SObject> records = SObjectFactory.create(Case.sObjectType, RECORD_COUNT);
		Test.startTest();
			partial(records).safeDelete();
		Test.stopTest();
		system.assertEquals(0, [SELECT count() FROM Case], 'Records should be deleted');
	}
	static testMethod void testPartial_Undelete()
	{
		List<SObject> records = SObjectFactory.create(Case.sObjectType, RECORD_COUNT);
		delete records;
		Test.startTest();
			partial(records).safeUndelete();
		Test.stopTest();
		system.assertEquals(RECORD_COUNT, [SELECT count() FROM Case], 'Records should be undeleted');
	}
	static testMethod void testPartial_SingleRecord()
	{
		SObject record = SObjectFactory.build(Case.sObjectType);
		Test.startTest();
			new DMLOperations.Partial(record).safeInsert();
		Test.stopTest();
		system.assertEquals(1, [SELECT count() FROM Case], 'Records should be inserted');
	}
	static testMethod void testPartial_Ids()
	{
		Set<Id> recordIds = Pluck.ids(SObjectFactory.create(Case.sObjectType, RECORD_COUNT));
		Test.startTest();
			new DMLOperations.Partial(recordIds).safeDelete();
		Test.stopTest();
		system.assertEquals(0, [SELECT count() FROM Case], 'Records should be deleted');
	}
}