
IF COL_LENGTH('hour_block_term', 'org_hr_value') IS NULL
BEGIN
	ALTER TABLE hour_block_term ADD org_hr_value TINYINT
	PRINT 'Column hour_block_term.org_hr_value added.'
END
ELSE
BEGIN
	PRINT 'Column hour_block_term.org_hr_value already exists.'
END
GO



IF COL_LENGTH('hour_block_term', 'hours_dec_val') IS NULL
BEGIN
	PRINT 'Column hour_block_term.hours_dec_val is not exist.'
END
ELSE
BEGIN
	ALTER TABLE hour_block_term DROP COLUMN hours_dec_val
	PRINT 'Column hour_block_term.hours_dec_val is dropped.'
END


alter table hour_block_term alter column add_dst_hour int