IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'user_defined_deal_fields_template' AND COLUMN_NAME = 'calc_granularity')
BEGIN
	alter table user_defined_fields_template  add calc_granularity int
	alter table user_defined_deal_fields_template  add calc_granularity int

END

