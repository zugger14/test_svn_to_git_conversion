
IF COL_LENGTH('pratos_stage_deal_header', 'product') IS  NOT NULL
	ALTER TABLE pratos_stage_deal_header ALTER COLUMN product VARCHAR(100)
GO

IF COL_LENGTH('pratos_stage_deal_header', 'msg_format') IS  NOT NULL
	ALTER TABLE pratos_stage_deal_header ALTER COLUMN msg_format VARCHAR(100)
GO
