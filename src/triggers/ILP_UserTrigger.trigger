trigger ILP_UserTrigger on Contact (before insert) {
	System.debug('trigger tripped');
}
