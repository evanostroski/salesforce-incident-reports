//  this script updates all Users with a sky ShoreTel_Sky_Profile_Type__c field, to make them valid Users for skyplatform
//  it has a limit of 5000 records to avoid breaking governor limits
//  it may be run multiple times, until no unprocessed records are retrieved

list<User> users = [SELECT Id, 
						sky__Do_Not_Log_Calls__c,
						sky__ShoreTel_Sky_Profile_Type__c,
						
						skyplatform__Do_Not_Log_Calls__c,
						skyplatform__ShoreTel_Sky_Profile_Type__c        
						
						FROM User
						WHERE sky__ShoreTel_Sky_Profile_Type__c <> null
						AND skyplatform__ShoreTel_Sky_Profile_Type__c = null
						LIMIT 5000];                     

for (User u : users)
{
	u.skyplatform__Do_Not_Log_Calls__c = u.sky__Do_Not_Log_Calls__c;
	u.skyplatform__ShoreTel_Sky_Profile_Type__c = u.sky__ShoreTel_Sky_Profile_Type__c;
}
update users;