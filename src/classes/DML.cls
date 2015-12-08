public class DML
{
	public interface Handler
	{
		void handle(Result result);
	}
	public interface Result
	{
		Integer getNumDml();
		Id getDmlId(Integer index);
		DmlException getDmlException();
		String getDmlMessage(Integer index);
		String getDmlStatusCode(Integer index);
		List<String> getDmlFields(Integer index);
	}
	public interface Operation
	{
		Operation safeInsert();
		Operation safeUpdate();
		Operation safeDelete();
		Operation safeUndelete();
		Operation safeUpsert(SObjectType collectionType);
	}

	@TestVisible final List<SObject> records;
	@TestVisible final List<DML.Handler> handlers;
	public DML(List<SObject> records)
	{
		this.records = records;
		this.handlers = new List<Handler>();
	}
	//operations
	public DML safeInsert()
	{
		new DMLOperations.AllOrNone(records).addHandlers(handlers).safeInsert();
		return this;
	}
	public DML PartialInsert()
	{
		new DMLOperations.Partial(records).addHandlers(handlers).safeInsert();
		return this;
	}
	public DML safeUpsert(SObjectType sObjectType)
	{
		new DMLOperations.AllOrNone(records).addHandlers(handlers).safeUpsert(sObjectType);
		return this;
	}
	public DML PartialUpsert(SObjectType sObjectType)
	{
		new DMLOperations.Partial(records).addHandlers(handlers).safeUpsert(sObjectType);
		return this;
	}
	public DML safeUpdate()
	{
		new DMLOperations.AllOrNone(records).addHandlers(handlers).safeUpdate();
		return this;
	}
	public DML PartialUpdate()
	{
		new DMLOperations.Partial(records).addHandlers(handlers).safeUpdate();
		return this;
	}
	public DML safeDelete()
	{
		new DMLOperations.AllOrNone(records).addHandlers(handlers).safeDelete();
		return this;
	}
	public DML PartialDelete()
	{
		new DMLOperations.Partial(records).addHandlers(handlers).safeDelete();
		return this;
	}
	public DML safeUndelete()
	{
		new DMLOperations.AllOrNone(records).addHandlers(handlers).safeUndelete();
		return this;
	}
	public DML PartialUndelete()
	{
		new DMLOperations.Partial(records).addHandlers(handlers).safeUndelete();
		return this;
	}
	//handlers
	public DML addHandler(Handler handler)
	{
		this.handlers.add(handler);
		return this;
	}
	public DML mapToSiblings(SObjectField originLookup, SObjectField relatedLookup, List<SObject> relatedRecords)
	{
		Handler handler = new DMLHandlers.MapErrors(records)
			.mapBy(originLookup).mapTo(relatedLookup, relatedRecords);
		return addHandler(handler);
	}
	public DML mapToParent(SObjectField originLookup, List<SObject> relatedRecords)
	{
		Handler handler = new DMLHandlers.MapErrors(records)
			.mapBy(originLookup).mapTo(relatedRecords);
		return addHandler(handler);
	}
	public DML mapToChildren(SObjectField relatedLookup, List<SObject> relatedRecords)
	{
		Handler handler = new DMLHandlers.MapErrors(records)
			.mapTo(relatedLookup, relatedRecords);
		return addHandler(handler);
	}
	
}