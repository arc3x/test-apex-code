@isTest
private class ILP_HelperTest {
	
	@isTest static void test_method_one() {		
		ILP_Helper.buildResponse(true, 'test', '');
		ILP_Helper.getDependentOptions('ILP_User__c', 'Major__c', 'Concentration__c');
		ILP_Helper.getDependentOptionsBackEnd('ILP_User__c', 'Major__c', 'Concentration__c');
	}
	

	
}