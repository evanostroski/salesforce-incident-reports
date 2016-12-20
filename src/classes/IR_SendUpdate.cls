public class IR_SendUpdate {

    private final Incident_Report__c report;
	public String updateText{get;set;}
    
    public IR_SendUpdate() {
        report = [SELECT Id, 
                          Name,  
                          Affected_Data_Centers__c,
                          Description__c,
                          Start_Time__c,
                          End_Time__c,
                          Severity__c,
                          Estimated_Time_to_Resolution__c,
                          Chat_Failure_Rate__c,
                          Comments_Failure_Rate__c,
                          Feed_Failure_Rate__c,
                          Gamification_Failure_Rate__c,
                          Identity_Store_Failure_Rate__c,
                          Login_Failure_Rate__c,
                          RaaS_Failure_Rate__c,
                          Share_Failure_Rate__c,
                          Webhooks_Failure_Rate__c
                          FROM Incident_Report__c WHERE Id = :ApexPages.currentPage().getParameters().get('id')];
    }

    public Incident_Report__c getReport() {
        return report;
    }
    
    public String getEmailBodyText() {
        String body = 'We would like to provide the following update regarding the current service interruption:  \n\n' +
          updateText + '\n\n' +
          'Event start date and time: ' + report.Start_Time__c + '\n\n' +
          'Data center(s) impacted: ' + report.Affected_Data_Centers__c + '\n\n' +
          'Current status: Open \n\n' +
          'Impacted APIs: \n';
        if(report.Chat_Failure_Rate__c != '0%' && report.Chat_Failure_Rate__c != null) 
            body += 'Chat: ' + report.Chat_Failure_Rate__c + ' failure rate\n';
        if(report.Comments_Failure_Rate__c != '0%' && report.Comments_Failure_Rate__c != null) 
            body += 'Comments: ' + report.Comments_Failure_Rate__c +' failure rate\n';
        if(report.Feed_Failure_Rate__c != '0%' && report.Feed_Failure_Rate__c != null) 
            body += 'Feed: ' + report.Feed_Failure_Rate__c + ' failure rate\n';
        if(report.Gamification_Failure_Rate__c != '0%' && report.Gamification_Failure_Rate__c != null) 
            body += 'Game Mechanics: ' + report.Gamification_Failure_Rate__c + ' failure rate\n';
        if(report.Identity_Store_Failure_Rate__c != '0%' && report.Identity_Store_Failure_Rate__c != null) 
            body += 'Identity Store: ' + report.Identity_Store_Failure_Rate__c + ' failure rate\n';
        if(report.Login_Failure_Rate__c != '0%' && report.Login_Failure_Rate__c != null) 
            body += 'Social Login: ' + report.Login_Failure_Rate__c + ' failure rate\n';
        if(report.RaaS_Failure_Rate__c != '0%' && report.RaaS_Failure_Rate__c != null) 
            body += 'RaaS: ' + report.RaaS_Failure_Rate__c  + ' failure rate\n';
        if(report.Share_Failure_Rate__c != '0%' && report.Share_Failure_Rate__c != null) 
            body += 'Social Share: ' + report.Share_Failure_Rate__c + ' failure rate\n';
        if(report.Webhooks_Failure_Rate__c != '0%' && report.Webhooks_Failure_Rate__c != null) 
            body += 'Webhooks: ' + report.Webhooks_Failure_Rate__c + ' failure rate\n';
        
        return body;
    }

    public PageReference save() {
        // CREATE UPDATE
    	IR_Email__c updateEmail = new IR_Email__c();
    
        // POPULATE IT FROM THE incident
        updateEmail.Incident_Report__c = report.Id;
        updateEmail.Type__c = 'Update';
        updateEmail.Name = 'Update Notification of Gigya Service Interruption on ' + report.Start_Time__c;
        updateEmail.Email_Body__c = getEmailBodyText();
        
        System.debug('********SENDING UPDATE EMAIL***********');
        insert updateEmail;
        
        PageReference reportPage = new ApexPages.StandardController(report).view();
        reportPage.setRedirect(true);
        return reportPage;
    }
}