trigger IR_SendEmail on IR_Email__c (after insert) {
    // Please note that triggers handle objects in bulk operations
    // In other words, there is no guarantee that only one object will get passed
    // The sendEmails() static method will loop the bulk object in a Queueable class
    // to avoid blocking/timeouts on the trigger
    System.debug('SendIREmail Trigger called');
    IR_Email__c[] emails = Trigger.new;
    IR_Dispatch.enqueueJob(emails);

    // Update Incident Description
    for(IR_Email__c email :emails) {
        System.debug('***** UPDATE INCIDENT DESCRIPTION *****');
        Incident_Report__c incident = [SELECT Id, 
                                       Name, 
                                       Description__c
                                       FROM Incident_Report__c WHERE id = :email.Incident_Report__c];
        incident.Description__c = email.Email_Body__c;
        update incident;                                               
    }
}