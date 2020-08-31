
IF  EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'forward_value_report' AND COLUMN_NAME = 'country_id')
alter table forward_value_report drop column country_id

IF not EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'forward_value_report' AND COLUMN_NAME = 'base_curve_id')
alter table forward_value_report add base_curve_id int


IF not EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'forward_value_report' AND COLUMN_NAME = 'curve_id')
alter table forward_value_report add curve_id int

