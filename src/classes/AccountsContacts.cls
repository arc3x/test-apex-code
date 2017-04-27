public with sharing class AccountsContacts {

	public String SelectedAccount {get;set;}
	public String newContactAccount {get;set;}
	public boolean doneSearch {get; set;}
	public List<Contact> contacts {get; set;}
	public List<Contact> contacts_original {get; set;}
	public Contact newContact {get; set;}
	//public String contactId {get; set;}

	public AccountsContacts() {	
		doneSearch = false;				
		newContact = new Contact();
	}

	// Trigger method
	public void updateContactCount(Contact[] NewContacts) {
		System.debug(NewContacts);
		for(Contact c: NewContacts) {
			if (c.AccountId != null) {
				String aid = c.AccountId;
				Integer contact_count = [SELECT COUNT() FROM Contact WHERE AccountId=:aid];
				Account a = [SELECT Id, ContactCount__c FROM Account WHERE Id=:aid];
				a.ContactCount__c = contact_count;
				System.debug(a.ContactCount__c);
				update a;
			}
		}
	}

	// returns a list of accounts for page picklist
	public List<SelectOption> getAccountOptions() {		
		List<Account> acts = [SELECT Id, Name, ContactCount__c FROM Account];
		List<SelectOption> accountOptions = new List<SelectOption>();
		// loop over accounts and add to SelectOption list
		for(Account a : acts) {			
			accountOptions.add(new SelectOption(a.Id, a.Name+' ('+a.ContactCount__c+')'));				
		}		
		return accountOptions;
	}

	public PageReference loadContactInfo() {
		doneSearch = true;
		contacts = [SELECT Id, FirstName, LastName, Phone, Email FROM Contact WHERE Account.Id=:SelectedAccount];
		contacts_original = contacts.deepClone();
		return new pagereference('/apex/AccountsContacts');
	}

	public void updateContactInfo() {
		//System.debug(contacts);
		//System.debug(contacts_original);
		for (Integer i=0; i<contacts.size(); i++) {
			if (contacts[i].FirstName!=contacts_original[i].FirstName ||
				contacts[i].LastName!=contacts_original[i].LastName ||
				contacts[i].Email!=contacts_original[i].Email ||
				contacts[i].Phone!=contacts_original[i].Phone ) {
					update contacts[i];
			}
		}		
	}

	public PageReference deleteContactInfo() {
		//System.debug();
		String id = apexpages.currentpage().getparameters().get('contactId');
		System.debug(id);
		Contact c = [SELECT Id FROM Contact WHERE Id=:id];		
		System.debug(c);
		delete c;
		loadContactInfo();
		return new pagereference('/apex/AccountsContacts');
	}

	public void createContactInfo() {
		newContact.AccountId = newContactAccount;
		insert newContact; 
		newContact = new Contact();
	}

}