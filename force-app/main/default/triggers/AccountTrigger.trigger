trigger AccountTrigger on Account (after insert, after update) {

	if (Trigger.isAfter && Trigger.isInsert) {
		AccountTriggerHandler.afterInsert(Trigger.newMap);
	}
}
