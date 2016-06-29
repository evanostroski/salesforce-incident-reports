trigger IR_SendInitialEmail on Incident_Report__c (after insert) {
	System.debug('SendIREmail Trigger called');
    Incident_Report__c[] incidents = Trigger.new;
	
    for(Incident_Report__c incident :incidents) {
        // Create the initial email and save it, which will fire the original trigger that already exists.
    	// 
        // CREATE INITIAL
    	IR_Email__c initialEmail = new IR_Email__c();
    
        // POPULATE IT FROM THE incident
        initialEmail.Incident_Report__c = incident.Id;
        initialEmail.Type__c = 'Initial';
        initialEmail.Name = 'Initial Notification of Gigya Service Interruption on ' + incident.Start_Time__c;
        initialEmail.Email_Body__c = 'The network operations team at Gigya has identified a service ' +
          'interruption potentially impacting your service. \n\n' +
          'Event start date and time: ' + incident.Start_Time__c + '\n\n' +
          'Data center(s) impacted: ' + incident.Affected_Data_Centers__c + '\n\n' +
          'Current status: Open \n\n' +
          'Impacted APIs: \n';
        if(incident.Chat_Failure_Rate__c != '0' && incident.Chat_Failure_Rate__c != null) initialEmail.Email_Body__c += 'Chat\n';
        if(incident.Comments_Failure_Rate__c != '0' && incident.Comments_Failure_Rate__c != null) initialEmail.Email_Body__c += 'Comments\n';
        if(incident.Feed_Failure_Rate__c != '0' && incident.Feed_Failure_Rate__c != null) initialEmail.Email_Body__c += 'Feed\n';
        if(incident.Gamification_Failure_Rate__c != '0' && incident.Gamification_Failure_Rate__c != null) initialEmail.Email_Body__c += 'Game Mechanics\n';
        if(incident.Identity_Store_Failure_Rate__c != '0' && incident.Identity_Store_Failure_Rate__c != null) initialEmail.Email_Body__c += 'Identity Store\n';
        if(incident.Login_Failure_Rate__c != '0' && incident.Login_Failure_Rate__c != null) initialEmail.Email_Body__c += 'Social Login\n';
        if(incident.RaaS_Failure_Rate__c != '0' && incident.RaaS_Failure_Rate__c != null) initialEmail.Email_Body__c += 'RaaS\n';
        if(incident.Share_Failure_Rate__c != '0' && incident.Share_Failure_Rate__c != null) initialEmail.Email_Body__c += 'Social Share\n';
        
        initialEmail.Email_Body__c += '\nWe will be sending a follow-up email as soon as we have additional information. \n\n' +
          'Regards, \n' +
          'Gigya Support Team';      
       
        // INSERT EMAIL TO TRIGGER SEND
        System.debug('********SENDING INITIAL EMAIL***********');
        insert initialEmail;
    }   
}