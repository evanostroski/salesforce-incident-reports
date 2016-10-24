//  this script updates all Contacts with a sky Is Personal field, to make them valid Contacts for skyplatform
//  it has a limit of 5000 records to avoid breaking governor limits
//  it may be run multiple times, until no unprocessed records are retrieved
//  it processes all Contacts that have not been updated today

list<Contact> contacts = [SELECT Id, 
							sky__Is_Personal__c, skyplatform__Is_Personal__c 
							FROM Contact 
							WHERE LastModifiedDate < :System.today()
							LIMIT 5000];
for (Contact c : contacts)
{
	c.skyplatform__Is_Personal__c = c.sky__Is_Personal__c;
}
update contacts;