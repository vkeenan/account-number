public with sharing class AccountTriggerHandler {
	public static void afterInsert (Map<Id, Account> newMap) {
		checkBasics(newMap.keySet());
	}

	private static void checkBasics(Set<Id> recordIds) {
		Boolean updateFlag = false;
		List<Account> theSobjects = [
			SELECT
			Id,
			AccountNumber,
			Name
			FROM Account
			WHERE Id IN : recordIds
			WITH SECURITY_ENFORCED
		];

		Account_Number_Settings__mdt accountSetting = [
			SELECT DeveloperName, MasterLabel, Last_Account_Number__c, Prefix__c
			FROM Account_Number_Settings__mdt
			WHERE (DeveloperName = 'AccountNumberFormat')
			LIMIT 1
		];
		Integer nextAccountNumber = accountSetting.Last_Account_Number__c.intValue();

		for (Account theSobject : theSobjects) {
			if (theSobject.AccountNumber == null) {
				updateFlag = true;
				nextAccountNumber++;
				theSobject.AccountNumber = accountSetting.Prefix__c + String.valueOf(nextAccountNumber).leftPad(6, '0');
			}
		}

		if (updateFlag) {
			Update theSobjects;
			// Create a new Metadata.CustomMetadata instance and populate it with the existing record's data
			Metadata.CustomMetadata customMetadataRecord = new Metadata.CustomMetadata();
			customMetadataRecord.fullName = 'Account_Number_Settings__mdt.' + accountSetting.DeveloperName;
			customMetadataRecord.label = accountSetting.MasterLabel;

			// Update the field value for Account_Number_Format__c
			Metadata.CustomMetadataValue customFieldValue = new Metadata.CustomMetadataValue();
			customFieldValue.field = 'NextAccountNumber__c';
			customFieldValue.value = nextAccountNumber;

			// Add the updated custom field value to the custom metadata record
			customMetadataRecord.values.add(customFieldValue);

			// Enqueue the custom metadata upsert operation using UpsertCustomMetadataQueueable
			UpsertCustomMetadataQueueable queueableJob = new UpsertCustomMetadataQueueable(new List<Metadata.CustomMetadata> {customMetadataRecord});
			System.enqueueJob(queueableJob);
		}
	}

}