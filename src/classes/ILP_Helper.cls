public with sharing class ILP_Helper {
	public ILP_Helper(ILP ilp) {}

    public static void sendSubmittedEmail(String to) {
        String subject = 'ILP Sucessfully Submitted';
        String body = 'Your ILP has been successfully submitted and is under review.\n\nYou will receive another email update when the status of your ILP changes.';
        sendEmail(to, subject, body);
    }

    public static void sendApprovedEmail(String to) {
        String subject = 'ILP Approved';
        String body = 'Your ILP has been approved!';
        sendEmail(to, subject, body);
    }

    public static void sendRejectEmail(String to, String notes) {
        String subject = 'ILP Rejected';
        String body = 'Your ILP has been rejected.\n\nFix any validation errors and resubmit your ILP or contact your advisor.';
        if (notes!=null && notes!='') {
            body += '\n\nAdvisor Notes:\n'+notes;
        }
        sendEmail(to, subject, body);
    }

    public static void sendEmail(String to, String subject, String body) {
        Messaging.reserveSingleEmailCapacity(1);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setBccSender(false);
        mail.setUseSignature(false);                
        String[] toAddresses = new String[] {to};                   
        mail.setToAddresses(toAddresses);        
        mail.setReplyTo('no-reply@csumb.edu');
        mail.setSenderDisplayName('CSU ILP Mailbot');        
        mail.setSubject(subject);
        mail.setPlainTextBody(body);                
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }


	/**
	Function:	Constructs a standardized JSON response object
	{ 
		success: <flag>,
		payload: <response>,
		message: <message>
	}
	*/
	public static String buildResponse(Boolean success_flag, String payload, String message) {
		if (payload=='') { payload='""'; }
        if (message.startsWith('"') && message.endsWith('"')) { message = message.substring(1, message.length()-1); }
		return '{ "success": ' + success_flag + ', "payload": ' + payload + ', "message": "' + message + '" }'; 
	}

    /**
    Function:   Returns the picklist options for a variable on an object    
    */
    //https://developer.salesforce.com/forums/?id=906F000000090GdIAI
    public static List<selectOption> getPicklistValues(Sobject object_name, String field_name) {
        List<selectOption> options = new List<selectOption>(); //new list for holding all of the picklist options
        Schema.sObjectType sobject_type = object_name.getSObjectType(); //grab the sobject that was passed
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
        List<Schema.PicklistEntry> pick_list_values = field_map.get(field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
        for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
                    
              options.add(new selectOption(a.getValue(), a.getLabel())); //add the value and label to our final list
        }
        return options; //return the List
    }


    /**
    Function:   Returns a json array of master / dependant picklist values
    Input:      SF Object API Name, Master picklist, dependant picklist
    Output:     JSON packet containing success, payload(picklist data?), and message fields     
    */
    //http://titancronus.com/blog/2014/05/01/salesforce-acquiring-dependent-picklists-in-apex/#comment-18167
    @RemoteAction
    public static String getDependentOptions(String pObjName, String pControllingFieldName, String pDependentFieldName){
        Map<String,List<String>> objResults = new Map<String,List<String>>();
        //get the string to sobject global map
        Map<String,Schema.SObjectType> objGlobalMap = Schema.getGlobalDescribe();
        if (!objGlobalMap.containsKey(pObjName)) {
            objResults.remove(null);
            objResults.remove('');
            return buildResponse(true, JSON.serialize(objResults), '');
        }
        //get the type being dealt with
        Schema.SObjectType pType = objGlobalMap.get(pObjName);
        Map<String, Schema.SObjectField> objFieldMap = pType.getDescribe().fields.getMap();
        //verify field names
        if (!objFieldMap.containsKey(pControllingFieldName) || !objFieldMap.containsKey(pDependentFieldName)) {
            objResults.remove(null);
            objResults.remove('');
            return buildResponse(true, JSON.serialize(objResults), '');
        }
        //get the control values   
        List<Schema.PicklistEntry> ctrl_ple = objFieldMap.get(pControllingFieldName).getDescribe().getPicklistValues();
        //get the dependent values
        List<Schema.PicklistEntry> dep_ple = objFieldMap.get(pDependentFieldName).getDescribe().getPicklistValues();
        //iterate through the values and get the ones valid for the controlling field name
        ILP_Bitset objBitSet = new ILP_Bitset();
        //set up the results
        for(Integer pControllingIndex=0; pControllingIndex<ctrl_ple.size(); pControllingIndex++){        	
            //get the pointer to the entry
            Schema.PicklistEntry ctrl_entry = ctrl_ple[pControllingIndex];
            //get the label
            String pControllingLabel = ctrl_entry.getLabel();
            //create the entry with the label
            objResults.put(pControllingLabel,new List<String>());
        }
        //cater for null and empty
         objResults.put('',new List<String>());
         objResults.put(null,new List<String>());
        //check the dependent values
        for(Integer pDependentIndex=0; pDependentIndex<dep_ple.size(); pDependentIndex++){        	
            //get the pointer to the dependent index
           	Schema.PicklistEntry dep_entry = dep_ple[pDependentIndex];
           	//get the valid for
            String pEntryStructure = JSON.serialize(dep_entry);                
            ILP_PicklistEntry objDepPLE = (ILP_PicklistEntry)JSON.deserialize(pEntryStructure, ILP_PicklistEntry.class);
            //if valid for is empty, skip
            if (objDepPLE.validFor==null || objDepPLE.validFor==''){
                continue;
            }
            //iterate through the controlling values
            for(Integer pControllingIndex=0; pControllingIndex<ctrl_ple.size(); pControllingIndex++){    
            	if (objBitSet.testBit(objDepPLE.validFor,pControllingIndex)){            		
		            //get the label
		            String pControllingLabel = ctrl_ple[pControllingIndex].getLabel();
                    objResults.get(pControllingLabel).add(objDepPLE.label);
                }
            }
        } 
        objResults.remove(null);
        objResults.remove('');
        return buildResponse(true, JSON.serialize(objResults), '');    
    }

    
    public static Map<String,List<String>> getDependentOptionsBackEnd(String pObjName, String pControllingFieldName, String pDependentFieldName){
        Map<String,List<String>> objResults = new Map<String,List<String>>();
        //get the string to sobject global map
        Map<String,Schema.SObjectType> objGlobalMap = Schema.getGlobalDescribe();
        if (!objGlobalMap.containsKey(pObjName)) {
            objResults.remove(null);
            objResults.remove('');
            return objResults;
        }
        //get the type being dealt with
        Schema.SObjectType pType = objGlobalMap.get(pObjName);
        Map<String, Schema.SObjectField> objFieldMap = pType.getDescribe().fields.getMap();
        //verify field names
        if (!objFieldMap.containsKey(pControllingFieldName) || !objFieldMap.containsKey(pDependentFieldName)) {
            objResults.remove(null);
            objResults.remove('');
            return objResults;
        }
        //get the control values   
        List<Schema.PicklistEntry> ctrl_ple = objFieldMap.get(pControllingFieldName).getDescribe().getPicklistValues();
        //get the dependent values
        List<Schema.PicklistEntry> dep_ple = objFieldMap.get(pDependentFieldName).getDescribe().getPicklistValues();
        //iterate through the values and get the ones valid for the controlling field name
        ILP_Bitset objBitSet = new ILP_Bitset();
        //set up the results
        for(Integer pControllingIndex=0; pControllingIndex<ctrl_ple.size(); pControllingIndex++){           
            //get the pointer to the entry
            Schema.PicklistEntry ctrl_entry = ctrl_ple[pControllingIndex];
            //get the label
            String pControllingLabel = ctrl_entry.getLabel();
            //create the entry with the label
            objResults.put(pControllingLabel,new List<String>());
        }
        //cater for null and empty        
         objResults.put('',new List<String>());
         objResults.put(null,new List<String>());
        //check the dependent values
        for(Integer pDependentIndex=0; pDependentIndex<dep_ple.size(); pDependentIndex++){          
            //get the pointer to the dependent index
            Schema.PicklistEntry dep_entry = dep_ple[pDependentIndex];
            //get the valid for
            String pEntryStructure = JSON.serialize(dep_entry);                
            ILP_PicklistEntry objDepPLE = (ILP_PicklistEntry)JSON.deserialize(pEntryStructure, ILP_PicklistEntry.class);
            //if valid for is empty, skip
            if (objDepPLE.validFor==null || objDepPLE.validFor==''){
                continue;
            }
            //iterate through the controlling values
            for(Integer pControllingIndex=0; pControllingIndex<ctrl_ple.size(); pControllingIndex++){    
                if (objBitSet.testBit(objDepPLE.validFor,pControllingIndex)){                   
                    //get the label
                    String pControllingLabel = ctrl_ple[pControllingIndex].getLabel();
                    objResults.get(pControllingLabel).add(objDepPLE.label);
                }
            }
        } 
        objResults.remove(null);
        objResults.remove('');
        return objResults;          
    }
}