//  this script updates all M5Connect Tasks to make them valid skyplatform Tasks
//  it has a limit of 5000 records to avoid breaking governor limits
//  it may be run multiple times, until no unprocessed records are retrieved

list<Task> tasks = [SELECT Id, 
                         m5__Call_Start_Time__c, sky__Call_Start_Date_Time__c,
                         m5__CNAM__c, sky__CNAM__c,
                         m5__CallerID__c, 
                         skyplatform__Caller_ID__c,
                         skyplatform__Is_Call_Record__c,
                         skyplatform_Activity_Type__c
                         FROM Task 
                         WHERE m5__Call_Start_Time__c <> null 
                         AND skyplatform__Call_Start_Date_Time__c = null
                         LIMIT 5000];
for (Task t : tasks)
{
     t.skyplatform__Call_Start_Date_Time__c = t.m5__Call_Start_Time__c;
     t.skyplatform__CNAM__c = t.m5__CNAM__c;
     t.skyplatform__Caller_ID__c = t.m5__CallerID__c;

     t.skyplatform__Is_Call_Record__c = true;
     t.skyplatform_Activity_Type__c = 'Call';
}
update tasks;
