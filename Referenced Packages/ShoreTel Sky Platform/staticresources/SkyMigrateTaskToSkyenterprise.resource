// this script updates all sky Tasks to make them valid skyenterprise Tasks
// it has a limit of 5000 records to avoid breaking governor limits
// it may be run multiple times, until no unprocessed records are retrieved

list<Task> tasks = [SELECT Id,
						sky__Answered_By__c,
						sky__Caller_ID__c,
						sky__CNAM__c,
						sky__Dialed_Label__c,
						sky__DNIS__c,
						sky__Extra_Info__c,
						sky__Hold_Time__c,
						sky__Is_Answered__c,
						sky__Is_Quality_Call__c,
						sky__Quality_Of_Call__c,
						sky__Remote_Party_Label__c,
						sky__Ring_Time__c,
						sky__Subscriber_Label__c,
						sky__Talk_Time__c,
											
						skyenterprise__Answered_By__c,
						skyenterprise__Caller_ID__c,
						skyenterprise__CNAM__c,
						skyenterprise__Dialed_Label__c,
						skyenterprise__DNIS__c,
						skyenterprise__Extra_Info__c,
						skyenterprise__Hold_Time__c,
						skyenterprise__Is_Answered__c,
						skyenterprise__Is_Quality_Call__c,
						skyenterprise__Quality_Of_Call__c,
						skyenterprise__Remote_Party_Label__c,
						skyenterprise__Ring_Time__c,
						skyenterprise__Subscriber_Label__c,
						skyenterprise__Talk_Time__c
											
						FROM Task
						WHERE sky__Activity_Type__c = 'Call'
						AND sky__Quality_Of_Call__c <> null
						AND skyenterprise__Quality_Of_Call__c = null
						LIMIT 5000];
for (Task t : tasks)
{
	t.skyenterprise__Answered_By__c = t.sky__Answered_By__c;
	t.skyenterprise__Caller_ID__c = t.sky__Caller_ID__c;
	t.skyenterprise__CNAM__c = t.sky__CNAM__c;
	t.skyenterprise__Dialed_Label__c = t.sky__Dialed_Label__c;
	t.skyenterprise__DNIS__c = t.sky__DNIS__c;
	t.skyenterprise__Extra_Info__c = t.sky__Extra_Info__c;
	t.skyenterprise__Hold_Time__c = t.sky__Hold_Time__c;
	t.skyenterprise__Is_Answered__c = t.sky__Is_Answered__c;
	t.skyenterprise__Is_Answered__c = t.sky__Is_Quality_Call__c;
	t.skyenterprise__Quality_Of_Call__c = t.sky__Quality_Of_Call__c;
	t.skyenterprise__Remote_Party_Label__c = t.sky__Remote_Party_Label__c;
	t.skyenterprise__Ring_Time__c = t.sky__Ring_Time__c;
	t.skyenterprise__Subscriber_Label__c = t.sky__Subscriber_Label__c;
	t.skyenterprise__Talk_Time__c = t.sky__Talk_Time__c;
}
update tasks;
