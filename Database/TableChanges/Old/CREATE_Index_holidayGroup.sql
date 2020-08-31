IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.holiday_group') AND name = N'IDX_holiday_group')
BEGIN
	CREATE UNIQUE  INDEX [IDX_holiday_group] ON holiday_group(hol_group_value_id,hol_date)
END

IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.holiday_group') AND name = N'IDX_holiday_group1')
BEGIN
	CREATE   INDEX [IDX_holiday_group1] ON holiday_group(exp_date)
END
	
