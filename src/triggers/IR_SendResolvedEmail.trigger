trigger IR_SendResolvedEmail on Incident_Report__c (after update) {
	IR_Settings__c settings = IR_Settings__c.getInstance('Production');
    
    if(settings != null && settings.Debug_Mode__c == true) {
        System.debug('********SendResolvedEmail Trigger values***********');
    	System.debug('***SFDC: Trigger.old is: ' + Trigger.old);
    	System.debug('***SFDC: Trigger.new is: ' + Trigger.new);
    }
    
    Incident_Report__c[] newInc = Trigger.new;
    Incident_Report__c[] oldInc = Trigger.old;
	
    for(Integer i = 0; i < newInc.size(); i++) {
        if(oldInc[i].End_Time__c == null && newInc[i].End_Time__c != null) {
            Incident_Report__c incident = newInc[i];
            
            // CREATE RESOLVED
            IR_Email__c resolvedEmail = new IR_Email__c();
        
            // POPULATE IT FROM THE incident
            resolvedEmail.Incident_Report__c = incident.Id;
            resolvedEmail.Type__c = 'Resolved';
            resolvedEmail.Name = 'Resolved Notification of Gigya Service Interruption on ' + incident.Start_Time__c;
            if(incident.Severity__c == 'P2 - Degradation' || incident.Severity__c == 'P3 - Degradation') {
                resolvedEmail.Email_Body__c = 'The service interruption has been resolved and this issue is now closed. Below are the details of the incident:\n\n';
            } else {
                resolvedEmail.Email_Body__c = 'The service interruption has been resolved. Below is the latest information on the issue. We will be providing a full post mortem within 48 hours:\n\n';
            }               
                
            resolvedEmail.Email_Body__c += 'The network operations team at Gigya has identified a service ' +
              'interruption potentially impacting your service. \n\n' +
              'Event start date and time: ' + incident.Start_Time__c + '\n\n' +
              'Event end date and time: ' + incident.End_Time__c + '\n\n' +
              'Data center(s) impacted: ' + incident.Affected_Data_Centers__c + '\n\n' +
              'Current status: Resolved \n\n' +
              'Impacted APIs: \n';
            if(incident.Chat_Failure_Rate__c != '0' && incident.Chat_Failure_Rate__c != null) resolvedEmail.Email_Body__c += 'Chat\n';
            if(incident.Comments_Failure_Rate__c != '0' && incident.Comments_Failure_Rate__c != null) resolvedEmail.Email_Body__c += 'Comments\n';
            if(incident.Feed_Failure_Rate__c != '0' && incident.Feed_Failure_Rate__c != null) resolvedEmail.Email_Body__c += 'Feed\n';
            if(incident.Gamification_Failure_Rate__c != '0' && incident.Gamification_Failure_Rate__c != null) resolvedEmail.Email_Body__c += 'Game Mechanics\n';
            if(incident.Identity_Store_Failure_Rate__c != '0' && incident.Identity_Store_Failure_Rate__c != null) resolvedEmail.Email_Body__c += 'Identity Store\n';
            if(incident.Login_Failure_Rate__c != '0' && incident.Login_Failure_Rate__c != null) resolvedEmail.Email_Body__c += 'Social Login\n';
            if(incident.RaaS_Failure_Rate__c != '0' && incident.RaaS_Failure_Rate__c != null) resolvedEmail.Email_Body__c += 'RaaS\n';
            if(incident.Share_Failure_Rate__c != '0' && incident.Share_Failure_Rate__c != null) resolvedEmail.Email_Body__c += 'Social Share\n';
            
            resolvedEmail.Email_Body__c += '\nRegards, \n' +
              'Gigya Support Team';      
           
            // INSERT EMAIL TO TRIGGER SEND
            System.debug('********SENDING RESOLVED EMAIL***********');
            insert resolvedEmail;
    	}
    }        
}