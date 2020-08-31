IF COL_LENGTH('process_settlement_invoice_log', 'description') IS NOT NULL
BEGIN
	ALTER table process_settlement_invoice_log 
	ALTER COLUMN description NVARCHAR(4000)
END

IF COL_LENGTH('workflow_activities', 'message') IS NOT NULL
BEGIN
	ALTER TABLE workflow_activities
	ALTER COLUMN message NVARCHAR(4000)
END

IF COL_LENGTH('workflow_event_message', 'message') IS NOT NULL
BEGIN
	ALTER TABLE workflow_event_message
	ALTER COLUMN message NVARCHAR(4000) 
END

IF COL_LENGTH('message_board', 'description') IS NOT NULL
BEGIN
	ALTER TABLE message_board
	ALTER COLUMN description NVARCHAR(4000) 
END

IF COL_LENGTH('message_board_audit', 'description') IS NOT NULL
BEGIN
	ALTER TABLE message_board_audit
	ALTER COLUMN description NVARCHAR(4000)
END
