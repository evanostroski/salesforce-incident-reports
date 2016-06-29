// The philosophy here is to limit the amount of time on the trigger as much as possible, 
// and get the work broken out into a Queueable class like IR_MarketoClient
public class IR_Dispatch {
    public static void enqueueJob(IR_Email__c[] emails) {
        for(IR_Email__c e :emails) {
            // There should be no conceivable way for more 
            // than one Incident Report to get returned by this query
            Incident_Report__c i = [SELECT Id, 
                                           Name,  
                                           Affected_Data_Centers__c,
                                           Description__c,
                                           Start_Time__c,
                                           End_Time__c,
                                           Status__c,
                                           Severity__c,
                                           Estimated_Time_to_Resolution__c,
                                           Chat_Failure_Rate__c,
                                           Comments_Failure_Rate__c,
                                           Feed_Failure_Rate__c,
                                           Gamification_Failure_Rate__c,
                                           Identity_Store_Failure_Rate__c,
                                           Login_Failure_Rate__c,
                                           RaaS_Failure_Rate__c,
                                           Share_Failure_Rate__c
                                           FROM Incident_Report__c WHERE id = :e.Incident_Report__c];
            System.debug('Found Incident Id:' + i.Id);
            
            // This calls the .execute() method of IR_MarketoClient
            System.enqueueJob(new IR_MarketoClient(i, e));
        }
    }
}