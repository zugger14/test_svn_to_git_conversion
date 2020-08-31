IF COL_LENGTH('fix_message_log','unique_execution_id') IS NULL
	ALTER TABLE fix_message_log ADD unique_execution_id VARCHAR(1000)
GO

IF COL_LENGTH('fix_message_log','transaction_timestamp') IS NULL
	ALTER TABLE fix_message_log ADD transaction_timestamp VARCHAR(50)
GO

IF COL_LENGTH('interface_configuration_detail','reject_duplicate_trade') IS NULL
	ALTER TABLE interface_configuration_detail ADD reject_duplicate_trade BIT DEFAULT 0
GO
