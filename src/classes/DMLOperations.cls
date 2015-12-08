public class DMLOperations
{
	abstract class ExecutionHandler
	{
		final List<SObject> records;
		final List<DML.Handler> handlers;
		ExecutionHandler(SObject record)
		{
			this.handlers = new List<DML.Handler>();
			this.records = new List<SObject> { record };
		}
		ExecutionHandler(Set<Id> recordIds)
		{
			this.handlers = new List<DML.Handler>();
			this.records = new List<SObject>();
			for (Id recordId : recordIds)
				records.add(recordId.getSobjectType().newSObject(recordId));
		}
		ExecutionHandler(List<SObject> records)
		{
			this.handlers = new List<DML.Handler>();
			this.records = records;
		}
		DML.Result execute(Type operationType, List<SObject> records)
		{
			return execute((WrappedOperation)operationType.newInstance(), records);
		}
		DML.Result execute(Type operationType, SObjectType sObjectType, List<SObject> records)
		{
			return execute(((WrappedOperation)operationType.newInstance()).setSObjectType(sObjectType), records);
		}
		DML.Result execute(WrappedOperation operation, List<SObject> records)
		{
			return operation.addAll(records).execute();
		}
	}
	public class AllOrNone extends ExecutionHandler implements DML.Operation
	{
		public AllOrNone(SObject record) { super(record); }
		public AllOrNone(Set<Id> recordIds) { super(recordIds); }
		public AllOrNone(List<SObject> records) { super(records); }
		public DML.Operation safeInsert() { return handle(execute(TryInsert.class, records)); }
		public DML.Operation safeUpdate() { return handle(execute(TryUpdate.class, records)); }
		public DML.Operation safeDelete() { return handle(execute(TryDelete.class, records)); }
		public DML.Operation safeUndelete() { return handle(execute(TryUndelete.class, records)); }
		public DML.Operation safeUpsert(SObjectType sObjectType)
		{
			return handle(execute(TryUpsert.class, sObjectType, records));
		}
		public DML.Operation addHandlers(List<DML.Handler> handler)
		{
			handlers.addAll(handler);
			return this;
		}
		DML.Operation handle(DML.Result result)
		{
			for (DML.Handler handler : handlers) handler.handle(result);
			return this;
		}
	}
	public class Partial extends ExecutionHandler implements DML.Operation
	{
		public Partial(SObject record) { super(record); }
		public Partial(Set<Id> recordIds) { super(recordIds); }
		public Partial(List<SObject> records) { super(records); }
		public DML.Operation safeInsert() { return handle(execute(PartialInsert.class, records)); }
		public DML.Operation safeUpdate() { return handle(execute(PartialUpdate.class, records)); }
		public DML.Operation safeDelete() { return handle(execute(PartialDelete.class, records)); }
		public DML.Operation safeUndelete() { return handle(execute(PartialUndelete.class, records)); }
		public DML.Operation safeUpsert(SObjectType sObjectType)
		{
			return handle(execute(PartialUpsert.class, sObjectType, records));
		}
		public DML.Operation addHandlers(List<DML.Handler> handler)
		{
			handlers.addAll(handler);
			return this;
		}
		DML.Operation handle(DML.Result result)
		{
			for (DML.Handler handler : handlers) handler.handle(result);
			return this;
		}
	}

	abstract class WrappedOperation
	{
		SObjectType sObjectType;
		List<SObject> records;
		public WrappedOperation addAll(List<SObject> records)
		{
			this.records = records;
			return this;
		}
		public WrappedOperation setSObjectType(SObjectType sObjectType)
		{
			this.sObjectType = sObjectType;
			return this;
		}
		abstract DML.Result execute();
	}

	class TryInsert extends WrappedOperation
	{
		public override DML.Result execute()
		{
			try { insert records; }
			catch (DmlException dmx) { return new DMLResults.AllOrNone(dmx); }
			return new DMLResults.AllOrNone(records.size());
		}
	}
	class TryUpsert extends WrappedOperation
	{
		public override DML.Result execute()
		{
			if (sObjectType == null) return new DMLResults.AllOrNone(records.size());
			List<SObject> castRecords = (List<SObject>)Type.forName('List<' + sObjectType + '>')
				.newInstance();
			castRecords.addAll(records);
			try { upsert castRecords; }
			catch (DmlException dmx) { return new DMLResults.AllOrNone(dmx); }
			return new DMLResults.AllOrNone(records.size());
		}
	}
	class TryUpdate extends WrappedOperation
	{
		public override DML.Result execute()
		{
			try { update records; }
			catch (DmlException dmx) { return new DMLResults.AllOrNone(dmx); }
			return new DMLResults.AllOrNone(records.size());
		}
	}
	class TryDelete extends WrappedOperation
	{
		public override DML.Result execute()
		{
			try { delete records; }
			catch (DmlException dmx) { return new DMLResults.AllOrNone(dmx); }
			return new DMLResults.AllOrNone(records.size());
		}
	}
	class TryUndelete extends WrappedOperation
	{
		public override DML.Result execute()
		{
			try { undelete records; }
			catch (DmlException dmx) { return new DMLResults.AllOrNone(dmx); }
			return new DMLResults.AllOrNone(records.size());
		}
	}

	class PartialInsert extends WrappedOperation
	{
		public override DML.Result execute()
		{
			return new DMLResults.Partial(Database.insert(records, /*allOrNone*/ false));
		}
	}
	class PartialUpsert extends WrappedOperation
	{
		public override DML.Result execute()
		{
			if (sObjectType == null) return new DMLResults.AllOrNone(records.size());
			List<SObject> castRecords = (List<SObject>)Type.forName('List<' + sObjectType + '>')
				.newInstance();
			castRecords.addAll(records);
			return new DMLResults.Partial(Database.upsert(castRecords, /*allOrNone*/ false));
		}
	}
	class PartialUpdate extends WrappedOperation
	{
		public override DML.Result execute()
		{
			return new DMLResults.Partial(Database.update(records, /*allOrNone*/ false));
		}
	}
	class PartialDelete extends WrappedOperation
	{
		public override DML.Result execute()
		{
			return new DMLResults.Partial(Database.delete(records, /*allOrNone*/ false));
		}
	}
	class PartialUndelete extends WrappedOperation
	{
		public override DML.Result execute()
		{
			return new DMLResults.Partial(Database.undelete(records, /*allOrNone*/ false));
		}
	}
}