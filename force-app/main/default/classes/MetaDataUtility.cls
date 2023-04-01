public class MetaDataUtility {

	public static String upsertMetadata(List<Metadata.CustomMetadata> customMetadataList) {
		Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();

		for (Metadata.CustomMetadata customMetadata : customMetadataList) {
			if (customMetadata != null) {
				mdContainer.addMetadata(customMetadata);
			}
		}

		DeployCallback callback = new DeployCallback();
		Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback);
		return jobId;
	}

	public class DeployCallback implements Metadata.DeployCallback {
		public void handleResult(Metadata.DeployResult result, Metadata.DeployCallbackContext context) {
			if (result.status == Metadata.DeployStatus.Succeeded) {
				System.debug('Metadata deployment succeeded.');
			} else {
				System.debug('Metadata deployment failed with message: ' + result.errorMessage);
			}
		}

	}
}