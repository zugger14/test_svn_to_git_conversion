
IF COL_LENGTH('pratos_stage_deal_header', 'msg_format') IS  NULL
	ALTER TABLE pratos_stage_deal_header ADD  msg_format VARCHAR(20)
GO
