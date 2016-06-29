public class IR_MarketoAuth {
    private datetime expiry;
    private string accessToken;
    private string instanceID;
    private string clientID;
    private string clientSecret;
    private IR_Settings__c settings;
    
    public IR_MarketoAuth (string env) {
        this.settings = IR_Settings__c.getInstance(env);
       	
        if (this.settings != null) {
            this.instanceID = settings.Instance_ID__c;
        	this.clientID = settings.Client_ID__c;
        	this.clientSecret = settings.Client_Secret__c;
        	this.accessToken = '';
       		this.expiry = datetime.now();
        }
        else {
            System.debug('IR_MarketoAuth() Error: could not find settings named ' + env);
        }
    }
    
    public string getToken () {
        if(this.expiry < datetime.now()) {
            requestNewToken();
        } 
        else {
            if (this.accessToken != '') {
                return this.accessToken;
            }
            else {
                System.debug('IR_MarketoAuth.getToken() Error: accessToken not set');
            }
        }
        return this.accessToken;
    }
    
    private void requestNewToken() {
        HttpRequest req = new HttpRequest();
        
		req.setEndpoint(this.getEndpoint());
		req.setMethod('GET');
		req.setHeader('Content-type', 'application/json');
        
        HTTPResponse res = new Http().send(req);
		if (res.getStatusCode() != 200) {
            System.debug('Error from ' + req.getEndpoint() + ' : ' + res.getStatusCode() + ' ' + res.getStatus());
        }
        else {
            datetime curTime = datetime.now();
        	map<string, object> jsonRes = (map<string, object>)JSON.deserializeUntyped(res.getBody());
        	this.accessToken = string.valueOf(jsonRes.get('access_token'));          
            this.expiry = curTime.addSeconds(integer.valueOf(jsonRes.get('expires_in')));
        }
    }
    
    private String getEndpoint() {
        if(this.instanceID != '' && this.clientID != '' && this.clientSecret != '') {
            return 'https://' + this.instanceID 
            + '.mktorest.com/identity/oauth/token?grant_type=client_credentials&client_id='
            + this.clientID + '&client_secret=' + this.clientSecret;
        }
        else {
            System.debug('IR_MarketoAuth.getEndpoint() Error: missing Marketo details');
            return '';
        }      
    }
}