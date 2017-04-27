@isTest
private class AccountsContactsTest {

	@isTest static void test_method_one() {
		AccountsContacts.inflate();
		Contact c = new Contact();
		c.LastName = 'Test';
		insert c;
	}



}
