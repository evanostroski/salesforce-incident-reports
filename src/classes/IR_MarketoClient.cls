public class IR_MarketoClient implements Queueable, Database.AllowsCallouts
{
	private string instanceID;
	private string clientId;
	private string clientSecret;
	private IR_MarketoAuth auth;
    private string env = 'Development';
    private string campaignId;
    private IR_Settings__c settings;
    private Incident_Report__c incident;
    private IR_Email__c email;

    public IR_MarketoClient (Incident_Report__c ir, IR_Email__c ire) {
        this.settings = IR_Settings__c.getInstance(this.env);
        this.incident = ir;
        this.email = ire;
       	
        if (this.settings != null) {
            this.instanceID = settings.Instance_ID__c;
        	this.clientID = settings.Client_ID__c;
        	this.clientSecret = settings.Client_Secret__c;
            this.campaignId = settings.Campaign_Id__c;
        }
        else {
            System.debug('IR_MarketoClient() Error: could not find settings named ' + this.env);
        }       
        auth = new IR_MarketoAuth(this.env);
    }
    
    public void execute(QueueableContext context) {   	   
        List<sObject> affectedImps = Database.query(this.getQuery());
        List<String> affectedAccounts = new List<String>();
        for(sObject imp :affectedImps) {
            List<Product_Implementation__c> pimps = imp.getSObjects('Product_Implementation__r');
            if(pimps != null) {
                affectedAccounts.add(String.valueOf(imp.get('Account__c')));
            }
        }
        
        List<Contact> affectedContacts = getAffectedContacts(affectedAccounts);
        
        String error = sendEmail(affectedContacts);
        if(error != '') {
            System.debug(error);
        }
        
        // MUST WAIT UNTIL ALL CALLOUTS ARE DONE BEFORE WRITING TO DATABASE
        this.incident.Number_of_Affected_Accounts__c = affectedAccounts.size();
        this.incident.Number_of_Affected_Contacts__c = affectedContacts.size();
        update this.incident;
    }
    
    private String sendEmail(List<Contact> affectedContacts) {
        String error = '';
        Boolean emailSent = false;
        List<String> emailBatch = new List<String>();
        
        //main loop
        Integer i = 0;
        while(i < affectedContacts.size()) {
            // batches of 50 emails
            // Note, this is a HACK
            // Both the leads endpoint and requestCampaign take 100 values each
            // However, the leads endpoint, when filtering by email, can return 
            // greater than 100 IDs if there are duplicate records in Marketo.
            // 
            // The proper way to do this will be to hit the leads endpoint with
            // SFDCContactID as the filter values, which is a one-to-one mapping
            // with Marketo UIDs      
            emailBatch.clear();
            for(Integer n = 0; n < 50; n++) {
                if(i < affectedContacts.size()) {
                    emailBatch.add(affectedContacts.get(i).Email);
                    i++;
                }               
            }
            String filterValues = '';
            for(Integer n = 0; n < emailBatch.size(); n++) {
                filterValues += emailBatch[n];
                if(n+1 < emailBatch.size()) {
                    filterValues += ',';
                }
            }
            
            List<String> leadIds = getLeadIdsFromEmails(filterValues);
            if(leadIds.size() == 0) { continue; }
            
            Map<String, String> tokenMap = getTokenMap();
            
            Map<String, Object> campaignResponse = requestCampaign(leadIds, tokenMap);
            
            if(String.valueOf(campaignResponse.get('success')) == 'true') {
                emailSent = true;
            } else {
                if(emailSent == true) {
                    error += 'requestCampaign failed, but email was sent: ' + campaignResponse.get('error') + '\n';
                } else {
                    error += 'requestCampaign failed: ' + campaignResponse.get('error') + '\n';
                }
            }
        }
        return error;
    }
    
    private Map<String, String> getTokenMap() {
        Map<String, String> tokenMap = new Map<String, String>();
        tokenMap.put('{{my.emailsubject}}', this.email.Name);
        tokenMap.put('{{my.emailbody}}', this.email.Email_Body__c);
        tokenMap.put('{{my.emailBodyRT}}', this.email.Email_Body__c.replace('\n', '<BR>'));
        return tokenMap;
    }
    
    private List<String> getLeadIdsFromEmails(String filterEmails) {
        Map<String, Object> response = getLeads('email', filterEmails);
        List<String> leadIds = new List<String>();
        if(String.valueOf(response.get('success')) == 'true') {
            List<Object> idList = (List<Object>)response.get('result');
            for(Object listItem :idList) {
                Map<String, Object> itemMap = (Map<String, Object>)listItem;
                leadIds.add(String.valueof(itemMap.get('id')));
            }               
        }
        return leadIds;
    }
    
    private List<Contact> getAffectedContacts(List<String> affectedAccounts) {
        // Limitations on the number of SOQL queries 
        // in a queued job force us to pull all contacts
        // and perform the inner join in code.
        List<Contact> allContacts = Database.query('SELECT Email, Account.Id, FirstName FROM Contact WHERE ' +
                                                        'Downtime_Alert__c = True');
        List<Contact> affectedContacts = new List<Contact>();
        
        for(String accountId :affectedAccounts) {
            for(Contact con :allContacts) {
                if(con.Account.Id == accountId) {
                    // Check if email already in array
                    Boolean found = false;
                    for(Contact dupe :affectedContacts) {
                        if(dupe.Email == con.Email) {
                            found = true;
                        }                       
                    }
                    if(!found) {
                        affectedContacts.add(con);
                    }
                }
            }
        }
        return affectedContacts;
    }
    
    private String getEndpoint(String type) {
        if(type == 'leads') {
            return 'https://' + instanceID + '.mktorest.com/rest/v1/leads.json?access_token=' 
                + auth.getToken();
        } else if(type == 'campaign') {
            return 'https://' + instanceID + '.mktorest.com/rest/v1/campaigns/' + campaignId 
                + '/trigger.json?access_token=' + auth.getToken();
        }
        return 'error';
    }
    
    //
    // SALESFORCE Affected Accounts query methods
    /////
    public String getQuery() {
        return 'SELECT Account__r.Name, Account__r.Id, ' +
            '( SELECT RecordType.Name FROM Product_Implementation__r WHERE ' +
            	'( Implementation_Status__c = \'Purchased - Live\' ' +
            		'OR Implementation_Status__c = \'Purchased - Live - In Progress\' ' +
            	') ' +
            	'AND ' +
            	affectedServicePart() +
            ') ' +
            'FROM Implementation__c WHERE ' +
            	'( Implementation_Status_2__c = \'In Progress - one or more live\' ' +
            		'OR Implementation_Status_2__c = \'On Hold - One or more live\' ' +
					'OR Implementation_Status_2__c = \'All Live - Additional Work\' ' +
            		'OR Implementation_Status_2__c = \'Complete\' ' +
            	') ' +
  //          	'AND Account__r.Active_Client__c = True ' +
            dataCenterPart();
    }
    
    // Returns the affected services part of the main query's WHERE clause
    private String affectedServicePart() {
        String result = '';
        if(this.incident.RaaS_Failure_Rate__c != '0') { if(result != '') { result += ' OR '; } result += 'RecordType.Name = \'RaaS\''; }
        if(this.incident.Login_Failure_Rate__c != '0') { if(result != '') { result += ' OR '; } result += 'RecordType.Name = \'Social Login\''; }
        if(this.incident.Identity_Store_Failure_Rate__c != '0') { if(result != '') { result += ' OR '; } result += 'RecordType.Name = \'Identity Storage\''; }
        if(this.incident.Share_Failure_Rate__c != '0') { if(result != '') { result += ' OR '; } result += 'RecordType.Name = \'Share\''; }
        if(this.incident.Comments_Failure_Rate__c != '0') { if(result != '') { result += ' OR '; } result += 'RecordType.Name = \'Comments\''; }
        if(this.incident.Feed_Failure_Rate__c != '0') { if(result != '') { result += ' OR '; } result += 'RecordType.Name = \'Activity Feed\''; }
        if(this.incident.Chat_Failure_Rate__c != '0') { if(result != '') { result += ' OR '; } result += 'RecordType.Name = \'Chat\''; }
        if(this.incident.Gamification_Failure_Rate__c != '0') { if(result != '') { result += ' OR '; } result += 'RecordType.Name = \'Game Mechanics\''; }
        
        result = '(' + result + ')';
        
        return result;
    }
    
    // Returns the data centers part of the main query's WHERE clause
    private String dataCenterPart() {
        String result = '';
        String[] dataCenters = this.incident.Affected_Data_Centers__c.split(';');
        for(String dc :dataCenters) {
            if(result != '') {
                result += ' OR ';
            }
            result += 'Data_Center_Location__c LIKE \'' + dc + '_\'';
        }
        if(result != '') {
            result = ' AND ( ' + result + ' )';
        }
        return result;
    }
    
    //
    // MARKETO REST API methods
    /////
    public map<string, object> getLeads(string filterType, string filterValues) {
    	HttpRequest req = new HttpRequest();
		req.setEndpoint(getEndpoint('leads') + '&filterType=' + filterType + 
                        '&filterValues=' + filterValues +
                       '&fields=id');
		req.setMethod('GET');
		req.setHeader('Content-type', 'application/json');

		HTTPResponse res = new Http().send(req);
		if (res.getStatusCode() != 200) {
            return new map<string, object>{ 'err' => 'IR_MarketoClient.getLeads() Error: Request Failed ' + req.getEndpoint() };
        }
        else {
        	return (map<string, object>)JSON.deserializeUntyped(res.getBody());
        }
    }

    public map<string, object> requestCampaign(list<string> leadIds, map<string, string> tokens) {
    	//create request
    	HttpRequest req = new HttpRequest();
		req.setEndpoint(getEndpoint('campaign'));
		req.setMethod('POST');
		req.setHeader('Content-type', 'application/json');

		//build leads input
		list<map<string, object>> leadsInput = new list<map<string, object>>();
		for (string leadId : leadIds) {
			leadsInput.add(new map<string, object>{ 'id' => leadId });
		}

		//build tokens input
		list<map<string, object>> tokensInput = new list<map<string, object>>();
		for (string tokenName : tokens.keySet()) {
			tokensInput.add(new map<string, object>{ 'name' => tokenName, 'value' => tokens.get(tokenName) });
		}

		//build request body with inputs
		map<string, object> requestBody = new map<string, object>{
			'input' => new map<string, object>{
				'leads' => leadsInput,
				'tokens' => tokensInput
			}
		};
		req.setBody(JSON.serialize(requestBody));

		HTTPResponse res = new Http().send(req);
		if (res.getStatusCode() != 200) {
            return new map<string, object>{ 'err' => 
                'IR_MarketoClient.requestCampaign() Error: Request Failed ' + req.getEndpoint() };
        } else {
        	return (map<string, object>)JSON.deserializeUntyped(res.getBody());
        }
    }
}