
IF NOT EXISTS (SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'contract_group' and column_name = 'holiday_calendar_id')
	alter table contract_group add holiday_calendar_id int