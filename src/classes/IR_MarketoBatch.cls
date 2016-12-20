global class IR_MarketoBatch implements Database.Batchable<String>, Database.AllowsCallouts, Database.Stateful {
	private string instanceID;
	private string clientId;
	private string clientSecret;
	private IR_MarketoAuth auth;
    private string env = 'Development';
    private string campaignId;
    private IR_Settings__c settings;
    private Incident_Report__c incident;
    private IR_Email__c email;
    private integer accountCount;
    private integer contactCount;

    public IR_MarketoBatch (Id report, Id email) {
        this.settings = IR_Settings__c.getInstance(this.env);
        this.incident = [SELECT Id,   
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
                                 FROM Incident_Report__c WHERE id = :report];
        this.email = [SELECT Id, Name, Email_Body__c FROM IR_Email__c WHERE id = :email];
       	
        if (this.settings != null) {
            this.instanceID = settings.Instance_ID__c;
        	this.clientID = settings.Client_ID__c;
        	this.clientSecret = settings.Client_Secret__c;
            this.campaignId = settings.Campaign_Id__c;
        }
        else {
            System.debug('IR_MarketoBatch() Error: could not find settings named ' + this.env);
        }       
        auth = new IR_MarketoAuth(this.env);
        contactCount = 0;
        accountCount = 0;
    }
    
    // THIS RUNS FIRST
    // builds and returns the List of emails used by the batchable's execute method
    global List<String> start(Database.BatchableContext info) {       
        List<Id> affectedAccounts = new List<Id>();       
		for(sObject a: Database.query(this.getQuery())) {
            affectedAccounts.add(Id.valueOf(String.valueOf(a.get('Account__c'))));
        }
        accountCount = affectedAccounts.size();
        // Get a unique set of contact emails
        return getAffectedEmails(affectedAccounts);
    }
    
    // THIS SHOULD RUN SECOND
    // this take the List of affected emails returned by Batchable.start() and executes across them
    global void execute(Database.BatchableContext info, List<String> affectedEmails) {
        System.debug('IR_MarketoBatch().execute');
        //contactCount += affectedEmails.size();
        String error = '';
        Boolean emailSent = false;
        List<String> emailBatch = new List<String>();
        
        //main loop
        Integer i = 0;
        while(i < affectedEmails.size()) {
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
                if(i < affectedEmails.size()) {
                    emailBatch.add(affectedEmails.get(i));
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
            else { contactCount += leadIds.size(); }
            
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
    }
    
    // AND FINALLY
    global void finish(Database.BatchableContext info) {
        System.debug('IR_MarketoBatch().finish');
        this.incident.Number_of_Affected_Accounts__c = accountCount;
        this.incident.Number_of_Affected_Contacts__c = contactCount;
        update this.incident;
    }
    
    //
    // HELPER METHODS
    ////
    private List<String> getAffectedEmails(List<Id> affectedAccounts) {
 		// FIX BEFORE LAUNCH
 		// Commented out for Downtime_Alert__c field
        //List<Contact> affectedContacts = Database.query('SELECT Email, Account.Id, FirstName FROM Contact WHERE Downtime_Alert__c = True AND Account.Id IN :affectedAccounts');
        List<Contact> affectedContacts = Database.query('SELECT Email, Account.Id, FirstName FROM Contact WHERE Account.Id IN :affectedAccounts');
        
        // Create Set first
        Set<String> affectedEmailsSet = new Set<String>();
        for(Contact c :affectedContacts) {
			affectedEmailsSet.add(c.email);
        }   
        
        // Convert set to iterable list
        List<String> affectedEmailsList = new List<String>();
        for(String email :affectedEmailsSet) {
            affectedEmailsList.add(email);
        }
        return affectedEmailsList;
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
    
    private Map<String, String> getTokenMap() {
        Map<String, String> tokenMap = new Map<String, String>();
        tokenMap.put('{{my.emailsubject}}', this.email.Name);
        tokenMap.put('{{my.emailbody}}', this.email.Email_Body__c);
        tokenMap.put('{{my.emailBodyRT}}', this.email.Email_Body__c.replace('\n', '<BR>'));
        return tokenMap;
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
        return 'SELECT Account__r.Id ' +
        'FROM Implementation__c ' +
        'WHERE Implementation_Status_2__c IN (\'In Progress - one or more live\',' +
        	'\'On Hold - One or more live\',\'All Live - Additional Work\',\'Complete\') ' +
        	//
        	//
        	// FIX BEFORE LAUNCH
            //'AND Account__r.Active_Client__c = True ' +
            //
            //
        	dataCenterPart() +
        	' AND Id IN (' +
        		'SELECT Implementation__c FROM Product_Implementation__c ' +
        		'WHERE Implementation_Status__c IN (\'Purchased - Live\',\'Purchased - Live - In Progress\') ' +
        		'AND ' + affectedServicePart() + ')';
    }
    
    // Returns the affected services part of the main query's WHERE clause
    private String affectedServicePart() {
        String result = 'RecordType.Name IN ( ';
        if(this.incident.RaaS_Failure_Rate__c != '0') { if(result != 'RecordType.Name IN ( ') { result += ','; } result += '\'RaaS\''; }
        if(this.incident.Login_Failure_Rate__c != '0') { if(result != 'RecordType.Name IN ( ') { result += ','; } result += '\'Social Login\''; }
        if(this.incident.Identity_Store_Failure_Rate__c != '0') { if(result != 'RecordType.Name IN ( ') { result += ','; } result += '\'Identity Storage\''; }
        if(this.incident.Share_Failure_Rate__c != '0') { if(result != 'RecordType.Name IN ( ') { result += ','; } result += '\'Share\''; }
        if(this.incident.Comments_Failure_Rate__c != '0') { if(result != 'RecordType.Name IN ( ') { result += ','; } result += '\'Comments\''; }
        if(this.incident.Feed_Failure_Rate__c != '0') { if(result != 'RecordType.Name IN ( ') { result += ','; } result += '\'Activity Feed\''; }
        if(this.incident.Chat_Failure_Rate__c != '0') { if(result != 'RecordType.Name IN ( ') { result += ','; } result += '\'Chat\''; }
        if(this.incident.Gamification_Failure_Rate__c != '0') { if(result != 'RecordType.Name IN ( ') { result += ','; } result += '\'Game Mechanics\''; }
        
        result = result + ')';
        
        return result;
    }
    
    // Returns the data centers part of the main query's WHERE clause
    private String dataCenterPart() {
        String result = '';
        String[] dataCenters = this.incident.Affected_Data_Centers__c.split(';');
        for(String dc :dataCenters) {
            if(dc == 'CDN') {
                return 'AND ( Data_Center_Location__c LIKE \'US_\''
                    	+ ' OR Data_Center_Location__c LIKE \'EU_\''
                    	+ ' OR Data_Center_Location__c LIKE \'AU_\''
                    	+ ' OR Data_Center_Location__c LIKE \'RU_\' )';
            }
            if(result != '') {
                result += ' OR ';
            }
            result += 'Data_Center_Location__c LIKE \'' + dc + '\'';
            
        }
        if(result != '') {
            result = ' AND ( ' + result + ' ) ';
        }
        return result;
    }
    
    //
    // MARKETO API methods
    ////
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
    
    public map<string, object> getLeads(string filterType, string filterValues) {
    	HttpRequest req = new HttpRequest();
		req.setEndpoint(getEndpoint('leads') + '&filterType=' + filterType + 
                        '&filterValues=' + filterValues +
                       '&fields=id');
		req.setMethod('GET');
		req.setHeader('Content-type', 'application/json');
        req.setTimeout(30000);

		HTTPResponse res = new Http().send(req);
		if (res.getStatusCode() != 200) {
            return new map<string, object>{ 'err' => 'IR_MarketoClient.getLeads() Error: Request Failed ' + req.getEndpoint() };
        }
        else {
        	return (map<string, object>)JSON.deserializeUntyped(res.getBody());
        }
    }
}