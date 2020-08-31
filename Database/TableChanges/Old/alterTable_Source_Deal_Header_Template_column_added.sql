IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Source_Deal_Header_Template' AND COLUMN_NAME = 'term_end_flag')
BEGIN
	ALTER TABLE Source_Deal_Header_Template ADD term_end_flag CHAR(1)

END

