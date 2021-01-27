IF OBJECT_ID(N'process_deal_alert_transfer_adjust', N'U') IS NOT NULL
	AND COL_LENGTH('process_deal_alert_transfer_adjust', 'deal_workflow_type_id') IS NULL
BEGIN
    ALTER TABLE
	/**
		Columns
		deal_workflow_type_id: A field for capturing Workflow that works with deal/deal detail level data which requires monitoring per row during workflow execution..
	*/
	process_deal_alert_transfer_adjust ADD deal_workflow_type_id INT

	PRINT 'Added column deal_workflow_type_id in table process_deal_alert_transfer_adjust.'
END
ELSE
	PRINT 'Column deal_workflow_type_id exists in table process_deal_alert_transfer_adjust.'

GO


