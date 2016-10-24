//  this script updates all Campaigns with an M5Connect TN, to make them valid Campaigns for skyenterprise
//  it has a limit of 5000 records to avoid breaking governor limits
//  it may be run multiple times, until no unprocessed records are retrieved

list<Campaign> campaigns = [SELECT Id, 
                              m5__Campaign_TN__c, skyenterprise__Phone__c 
                              FROM Campaign 
                              WHERE m5__Campaign_TN__c <> null
                              AND skyenterprise__Phone__c = null
                              LIMIT 5000];
for (Campaign c : campaigns)
{
     c.skyenterprise__Phone__c = c.m5__Campaign_TN__c;
}
update campaigns;