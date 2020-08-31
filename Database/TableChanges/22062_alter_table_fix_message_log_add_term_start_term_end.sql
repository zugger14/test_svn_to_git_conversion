IF COL_LENGTH('fix_message_log','term_start') IS NULL 
	ALTER TABLE fix_message_log ADD term_start VARCHAR(20)
GO

IF COL_LENGTH('fix_message_log','term_end') IS NULL 
	ALTER TABLE fix_message_log ADD term_end VARCHAR(20)
GO

IF COL_LENGTH('fix_message_log','is_rejected') IS NULL 
	ALTER TABLE fix_message_log ADD is_rejected BIT
GO	