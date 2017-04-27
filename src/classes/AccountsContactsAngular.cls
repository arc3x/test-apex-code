public with sharing class AccountsContactsAngular {



	public AccountsContactsAngular() {
		
	}	

	// returns a list of accounts for page picklist
	@RemoteAction
	public static String getAccountOptions() {		
		List<Account> acts = [SELECT Id, Name FROM Account];				
		return JSON.serialize(acts);
	}

	@RemoteAction
	public static String getContactsByAccount(String accountId) {			
		List<Contact> contacts = [SELECT Id, FirstName, LastName, Phone, Email FROM Contact WHERE Account.Id=:accountId];					
		return JSON.serialize(contacts);
	}	

	@RemoteAction
	public static void updateContact(String cont) {		
		Contact c = (Contact)JSON.deserialize(cont, Contact.class);
		update c;
		//System.debug(c);   
	}

	@RemoteAction
	public static void createContact(String cont) {
		Contact c = (Contact)JSON.deserialize(cont, Contact.class);
		insert c;			
	}

	@RemoteAction
	public static void deleteContact(String cont) {
		Contact c = (Contact)JSON.deserialize(cont, Contact.class);
		delete c;			
	}
}