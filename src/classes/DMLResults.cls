public class DMLResults
{
	public class AllOrNone implements DML.Result
	{
		final Integer numDml;
		final DmlException dmx;
		public AllOrNone(Integer numDml) { this.numDml = numDml; }
		public AllOrNone(DmlException dmx) { this.dmx = dmx; }
		public DmlException getDmlException() { return dmx; }
		public Integer getNumDml()
		{
			return (dmx == null) ? numDml : dmx.getNumDml();
		}
		public Id getDmlId(Integer index)
		{
			return (dmx == null) ? null : dmx.getDmlId(index);
		}
		public String getDmlMessage(Integer index)
		{
			return (dmx == null) ? null : dmx.getDmlMessage(index);
		}
		public String getDmlStatusCode(Integer index)
		{
			return (dmx == null) ? null : dmx.getDmlStatusCode(index);
		}
		public List<String> getDmlFields(Integer index)
		{
			List<String> dmlFields = new List<String>();
			if (dmx == null || dmx.getDmlFields(index) == null) return dmlFields;
			for (SObjectField field : dmx.getDmlFields(index))
				dmlFields.add(String.valueOf(field));
			return dmlFields;
		}
	}

	public class Partial implements DML.Result
	{
		final List<GenericResult> results;
		public Partial() { this.results = new List<GenericResult>(); }
		public Partial(List<Database.SaveResult> saveResults)
		{
			this();
			for (Database.SaveResult result : saveResults)
				results.add(new GenericResult(
					result.getId(), result.getErrors())
				);
		}
		public Partial(List<Database.UpsertResult> upsertResults)
		{
			this();
			for (Database.UpsertResult result : upsertResults)
				results.add(new GenericResult(
					result.getId(), result.getErrors())
				);
		}
		public Partial(List<Database.DeleteResult> deleteResults)
		{
			this();
			for (Database.DeleteResult result : deleteResults)
				results.add(new GenericResult(
					result.getId(), result.getErrors())
				);
		}
		public Partial(List<Database.UndeleteResult> undeleteResults)
		{
			this();
			for (Database.UndeleteResult result : undeleteResults)
				results.add(new GenericResult(
					result.getId(), result.getErrors())
				);
		}

		public DmlException getDmlException() { return null; }
		public Integer getNumDml() { return results.size(); }
		public Id getDmlId(Integer index) { return results[index].getId(); }
		public String getDmlMessage(Integer index)
		{
			List<String> dmlMessages = new List<String>();
			for (Database.Error error : results[index].getErrors())
				dmlMessages.add(error.getMessage());
			return String.join(dmlMessages, ';');
		}
		public String getDmlStatusCode(Integer index)
		{
			List<Database.Error> errors = results[index].getErrors();
			return errors.isEmpty() ? null : String.valueOf(errors[0].getStatusCode());
		}
		public List<String> getDmlFields(Integer index)
		{
			List<String> dmlFields = new List<String>();
			for (Database.Error error : results[index].getErrors())
				dmlFields.addAll(error.getFields());
			return dmlFields;
		}
	}

	public class GenericResult
	{
		final Id recordId;
		final List<Database.Error> errors;
		public GenericResult(Id recordId, List<Database.Error> errors)
		{
			this.recordId = recordId;
			this.errors = (errors != null) ? errors : new List<Database.Error>();
		}
		public Id getId() { return recordId; }
		public List<Database.Error> getErrors() { return errors; }
	}
}