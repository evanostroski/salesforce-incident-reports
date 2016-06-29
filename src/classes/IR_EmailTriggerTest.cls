@isTest(SeeAllData=true) //This annotation requires API v24 or greater
public class IR_EmailTriggerTest {
    @isTest
    static void testTrigger() {
        Test.setMock(HttpCalloutMock.class, new IR_MarketoClientMock()); 
        
        Test.startTest();
        Incident_Report__c incident = new Incident_Report__c();       
        incident.Affected_Data_Centers__c = 'US;EU;AU';
        incident.RaaS_Failure_Rate__c = '10';
        incident.Name = 'Unit Test Incident';
        incident.Start_Time__c = Date.today();
        insert incident;
        
        IR_Email__c email = new IR_Email__c();
        email.Name = 'Unit Test Email';
        email.Incident_Report__c = incident.Id;
        email.Email_Body__c = 'Unit Test Body';
        insert email;
        Test.stopTest();
        Incident_Report__c updatedRecord = [SELECT Number_of_Affected_Accounts__c 
                                                  FROM Incident_Report__c 
                                                  WHERE Incident_Report__c.Id = :incident.Id];
        Integer affectedActual = Integer.valueOf(updatedRecord.Number_of_Affected_Accounts__c);
        Integer affectedExpected = 0;
        System.assertNotEquals(affectedExpected, affectedActual);
    }
}