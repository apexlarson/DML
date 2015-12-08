@isTest
public class DMLTestUtility
{
	public static final SObjectType DEFAULT_TYPE = Lead.sObjectType;
	public static final Integer DEFAULT_COUNT = SObjectFactory.getRecordThreshold();

	public static List<Lead> getExceptionRecords_Upsert()
	{
		return getExceptionRecords_Upsert(DEFAULT_COUNT);
	}
	public static List<Lead> getExceptionRecords_Upsert(Integer recordCount)
	{
		List<Lead> records = new List<Lead>();
		while (records.size() < recordCount) records.add(new Lead());
		return records;
	}

	public static List<SObject> getExceptionRecords_Delete()
	{
		return getExceptionRecords_Delete(DEFAULT_TYPE, DEFAULT_COUNT);
	}
	public static List<SObject> getExceptionRecords_Delete(Integer recordCount)
	{
		return getExceptionRecords_Delete(DEFAULT_TYPE, recordCount);
	}
	public static List<SObject> getExceptionRecords_Delete(SObjectType sObjectType)
	{
		return getExceptionRecords_Delete(sObjectType, DEFAULT_COUNT);
	}
	public static List<SObject> getExceptionRecords_Delete(SObjectType sObjectType, Integer recordCount)
	{
		List<SObject> records = SObjectFactory.create(sObjectType, recordCount);
		delete records;
		return records;
	}

	public static List<SObject> getExceptionRecords_Undelete()
	{
		return SObjectFactory.create(DEFAULT_TYPE, DEFAULT_COUNT);
	}
	public static List<SObject> getExceptionRecords_Undelete(Integer recordCount)
	{
		return SObjectFactory.create(DEFAULT_TYPE, recordCount);
	}
	public static List<SObject> getExceptionRecords_Undelete(SObjectType sObjectType)
	{
		return SObjectFactory.create(sObjectType, DEFAULT_COUNT);
	}
	public static List<SObject> getExceptionRecords_Undelete(SObjectType sObjectType, Integer recordCount)
	{
		return SObjectFactory.create(sObjectType, recordCount);
	}
}