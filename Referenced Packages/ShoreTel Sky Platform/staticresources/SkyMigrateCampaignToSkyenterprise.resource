//  this script updates all Campaigns with a sky TN, to make them valid Campaigns for skyenterprise
//  it has a limit of 5000 records to avoid breaking governor limits
//  it may be run multiple times, until no unprocessed records are retrieved

list<Campaign> campaigns = [SELECT Id, 
								sky__Phone__c, skyenterprise__Phone__c 
								FROM Campaign 
								WHERE sky__Phone__c <> null
								AND skyenterprise__Phone__c = null
								LIMIT 5000];
for (Campaign c : campaigns)
{
	c.skyenterprise__Phone__c = c.sky__Phone__c;
}
update campaigns;