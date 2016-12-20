public class IR_SendPostMortem {
	private final Incident_Report__c report;
	public String issueDescText{get;set;}
    public String rootCauseText{get;set;}
    public String preventativeText{get;set;}
    public IR_SendPostMortem() {
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

    public PageReference save() {
        // CREATE UPDATE
    	IR_Email__c postMortemEmail = new IR_Email__c();
    
        // POPULATE IT FROM THE incident
        postMortemEmail.Incident_Report__c = report.Id;
        postMortemEmail.Type__c = 'Post Mortem';
        postMortemEmail.Name = 'Post Mortem Notification of Gigya Service Interruption on ' + report.Start_Time__c;
        postMortemEmail.Email_Body__c = 'Issue Description:\n' + issueDescText + '\n\n';
        postMortemEmail.Email_Body__c += 'Event start date and time: ' + report.Start_Time__c + '\n\n' +
          'Event end date and time:' + report.End_Time__c + '\n\n' +
          'Data center(s) impacted: ' + report.Affected_Data_Centers__c + '\n\n' +
          'Current status: Resolved \n\n' +
          'Impacted APIs: \n';
        if(report.Chat_Failure_Rate__c != '0%' && report.Chat_Failure_Rate__c != null) 
            postMortemEmail.Email_Body__c += 'Chat: ' + report.Chat_Failure_Rate__c + ' failure rate\n';
        if(report.Comments_Failure_Rate__c != '0%' && report.Comments_Failure_Rate__c != null) 
            postMortemEmail.Email_Body__c += 'Comments: ' + report.Comments_Failure_Rate__c +' failure rate\n';
        if(report.Feed_Failure_Rate__c != '0%' && report.Feed_Failure_Rate__c != null) 
            postMortemEmail.Email_Body__c += 'Feed: ' + report.Feed_Failure_Rate__c + ' failure rate\n';
        if(report.Gamification_Failure_Rate__c != '0%' && report.Gamification_Failure_Rate__c != null) 
            postMortemEmail.Email_Body__c += 'Game Mechanics: ' + report.Gamification_Failure_Rate__c + ' failure rate\n';
        if(report.Identity_Store_Failure_Rate__c != '0%' && report.Identity_Store_Failure_Rate__c != null) 
            postMortemEmail.Email_Body__c += 'Identity Store: ' + report.Identity_Store_Failure_Rate__c + ' failure rate\n';
        if(report.Login_Failure_Rate__c != '0%' && report.Login_Failure_Rate__c != null) 
            postMortemEmail.Email_Body__c += 'Social Login: ' + report.Login_Failure_Rate__c + ' failure rate\n';
        if(report.RaaS_Failure_Rate__c != '0%' && report.RaaS_Failure_Rate__c != null) 
            postMortemEmail.Email_Body__c += 'RaaS: ' + report.RaaS_Failure_Rate__c  + ' failure rate\n';
        if(report.Share_Failure_Rate__c != '0%' && report.Share_Failure_Rate__c != null) 
            postMortemEmail.Email_Body__c += 'Social Share: ' + report.Share_Failure_Rate__c + ' failure rate\n';
        if(report.Webhooks_Failure_Rate__c != '0%' && report.Webhooks_Failure_Rate__c != null) 
            postMortemEmail.Email_Body__c += 'Webhooks: ' + report.Webhooks_Failure_Rate__c + ' failure rate\n';
        
        postMortemEmail.Email_Body__c += '\nRoot Cause:\n' + rootCauseText + '\n';
        postMortemEmail.Email_Body__c += '\nPreventative Measures:\n' + preventativeText;
        
        System.debug('********SENDING UPDATE EMAIL***********');
        insert postMortemEmail;
        
        PageReference reportPage = new ApexPages.StandardController(report).view();
        reportPage.setRedirect(true);
        return reportPage;
    }
}