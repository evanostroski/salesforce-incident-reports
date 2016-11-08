// The philosophy here is to limit the amount of time on the trigger as much as possible, 
// and get the work broken out into a Batchable class like IR_MarketoBatch
public class IR_Dispatch {
    public static void enqueueJob(IR_Email__c[] emails) {
        for(IR_Email__c e :emails) {
            // There should be no conceivable way for more 
            // than one Incident Report to get returned by this query
            Incident_Report__c i = [SELECT Id FROM Incident_Report__c WHERE id = :e.Incident_Report__c];
            System.debug('Found Incident Id:' + i.Id);
            
            // This calls the .execute() method of IR_MarketoClient
            //System.enqueueJob(new IR_MarketoClient(i, e));
            
            // Use Batch method instead
            IR_MarketoBatch batch = new IR_MarketoBatch(i.Id, e.Id);
        	Database.executeBatch(batch);
        }
    }
}