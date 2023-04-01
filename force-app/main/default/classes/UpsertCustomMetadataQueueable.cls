public class UpsertCustomMetadataQueueable implements Queueable {
	private List<Metadata.CustomMetadata> customMetadataList;

	public UpsertCustomMetadataQueueable(List<Metadata.CustomMetadata> customMetadataList) {
		this.customMetadataList = customMetadataList;
	}

	public void execute(QueueableContext context) {
		String jobId = MetaDataUtility.upsertMetadata(customMetadataList);
		System.debug('Deployment Job ID: ' + jobId);
	}

}
