public class DMLHandlers
{
	public class MapErrors implements Dml.Handler
	{
		@TestVisible List<SObject> records;
		@TestVisible FieldReference lookup;
		@TestVisible Map<Id, List<SObject>> relatedRecords;

		public MapErrors(List<SObject> records)
		{
			this.records = records;
			this.lookup = FieldReference.build('Id');
			this.relatedRecords = new Map<Id, List<SObject>>();
		}
		public MapErrors mapBy(SObjectField field)
		{
			this.lookup = FieldReference.build(field);
			return this;
		}
		public MapErrors mapTo(SObjectField field, List<SObject> records)
		{
			this.relatedRecords = new Map<Id, List<SObject>>();
			relatedRecords.putAll(GroupBy.ids(FieldReference.build(field), records));
			return this;
		}
		public MapErrors mapTo(List<SObject> records)
		{
			return mapTo(new Map<Id, SObject>(records));
		}
		public MapErrors mapTo(Map<Id, SObject> records)
		{
			this.relatedRecords = new Map<Id, List<SObject>>();
			for (Id recordId : records.keySet())
				relatedRecords.put(recordId, new List<SObject> { records.get(recordId) });
			return this;
		}
		public void handle(DML.Result result)
		{
			DmlException cause = result.getDmlException();
			for (Integer i = 0; i < result.getNumDml(); i++)
			{
				Id key = (Id)lookup.getFrom(records[i]);
				for (SObject record : relatedRecords.get(key))
				{
					if (cause != null) record.addError(cause);
					else
					{
						String message = result.getDmlMessage(i);
						if (String.isNotBlank(message)) record.addError(message);
					}
				}
			}
		}
	}
}