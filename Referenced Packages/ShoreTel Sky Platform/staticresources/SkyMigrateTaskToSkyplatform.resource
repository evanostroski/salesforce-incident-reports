// this script updates all sky Tasks to make them valid skyplatform Tasks
// it has a limit of 5000 records to avoid breaking governor limits
// it may be run multiple times, until no unprocessed records are retrieved

list<Task> tasks = [SELECT Id,
                    	sky__Activity_Type__c,
						sky__Unique_Call_Id__c,
						sky__From_Phone__c,
						sky__To_Phone__c,
						sky__Call_Start_Date_Time__c,
						sky__Is_Call_Record__c,
						sky__Is_Imported__c,
						sky__Is_Personal__c,
						
						skyplatform__Activity_Type__c,
						skyplatform__Unique_Call_Id__c,
						skyplatform__From_Phone__c,
						skyplatform__To_Phone__c,
						skyplatform__Call_Start_Date_Time__c,
						skyplatform__Is_Call_Record__c,
						skyplatform__Is_Imported__c,
						skyplatform__Is_Personal__c
						
                    	FROM Task
                    	WHERE sky__Call_Start_Date_Time__c != null
                    	AND skyplatform__Call_Start_Date_Time__c = null
                    	LIMIT 5000];
for (Task t : tasks)
{
	t.skyplatform__Activity_Type__c = t.sky__Activity_Type__c;
	t.skyplatform__Unique_Call_Id__c = t.sky__Unique_Call_Id__c;
	t.skyplatform__From_Phone__c = t.sky__From_Phone__c;
	t.skyplatform__To_Phone__c = t.sky__To_Phone__c;
	t.skyplatform__Call_Start_Date_Time__c = t.sky__Call_Start_Date_Time__c;
	t.skyplatform__Is_Call_Record__c = t.sky__Is_Call_Record__c;
	t.skyplatform__Is_Imported__c = t.sky__Is_Imported__c;
	t.skyplatform__Is_Personal__c = t.sky__Is_Personal__c;
}
update tasks;
