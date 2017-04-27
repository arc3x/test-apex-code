@isTest
private class AccountsContactsTest {
	
	@isTest static void test_method_one() {
		// Implement test code
		AccountsContacts myCtrl = new AccountsContacts();
		Account a = new Account();
		a.Name='testAcnt';
		insert a;
		
		Contact c = new Contact(
			FirstName='Matt',
			LastName='Slocum'			
		);
		Contact c2 = new Contact(
			FirstName='Matt2',
			LastName='Slocum2'			
		);
		Contact c3 = new Contact(
			FirstName='Matt2',
			LastName='Slocum2',
			Email='asd@com.com',
			Phone='5034321171'			
		);

		myCtrl.newContact = c;
		myCtrl.newContactAccount = a.Id;
		
		myCtrl.getAccountOptions();
		insert c3;
		myCtrl.loadContactInfo();
		myCtrl.contacts[0].Phone='5034444444';
		//c3.FirstName='Matt';
		//update c3;
		myCtrl.updateContactInfo();

		
		//c.
		myCtrl.createContactInfo();
		insert c2;
		//apexpages.currentpage().setparameters().set('contactId', '1234');
		ApexPages.currentPage().getParameters().put('contactId', c2.Id);
		myCtrl.deleteContactInfo();
	}
	
	
	
}