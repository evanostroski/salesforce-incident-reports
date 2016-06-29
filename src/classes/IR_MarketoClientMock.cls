@isTest
global class IR_MarketoClientMock implements HttpCalloutMock {
    String successAuthEndpoint = 'oauth';
	String successLeadEndpoint = 'leads';
    String successCampEndpoint = 'campaigns';
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
		response.setHeader('Content-Type', 'application/json');
        
        if(request.getEndpoint().contains(successAuthEndpoint) == true) {            
        	response.setBody('{"access_token":"mockAccessToken","token_type":"bearer","expires_in":3599,"scope":"brian.fagan@gigya.com"}');
        	response.setStatusCode(200);
        	return response;
        } else if (request.getEndpoint().contains(successLeadEndpoint) == true) {
            response.setBody('{"success":"true","result":[{"id": "0"}]}');
        	response.setStatusCode(200);
            return response;
        } else if (request.getEndpoint().contains(successCampEndpoint) == true) {
            response.setBody('{"success":"true"}');
            response.setStatusCode(200);
            return response;
        } 
        return response;
    }
}