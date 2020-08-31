IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'deal_transfer_mapping' AND COLUMN_NAME = 'unapprove')
ALTER TABLE dbo.deal_transfer_mapping ADD
	unapprove CHAR(1) NULL
GO

IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'deal_transfer_mapping' AND COLUMN_NAME = 'offset')
ALTER TABLE dbo.deal_transfer_mapping ADD
	offset CHAR(1) NULL
GO

IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'deal_transfer_mapping' AND COLUMN_NAME = 'transfer')
ALTER TABLE dbo.deal_transfer_mapping ADD
	transfer CHAR(1) NULL
GO

