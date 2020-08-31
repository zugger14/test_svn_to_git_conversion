IF COL_LENGTH ('contract_group', 'holiday_calender_id') IS NOT NULL
BEGIN
	ALTER TABLE contract_group DROP COLUMN holiday_calender_id
	PRINT 'ready to delete'
END
ELSE
	PRINT 'column holiday_calender_id does not exist.'