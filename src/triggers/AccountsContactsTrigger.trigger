trigger AccountsContactsTrigger on Contact (after insert) {
	Contact[] c = Trigger.new;
	AccountsContacts ctrl = new AccountsContacts();
	ctrl.updateContactCount(c);
}