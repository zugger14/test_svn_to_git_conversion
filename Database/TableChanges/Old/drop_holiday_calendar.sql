SELECT * FROM dbo.static_data_type WHERE [type_name] LIKE '%calendar%'

SELECT * FROM dbo.static_data_value WHERE [type_id] = 10099

SELECT * FROM holiday_calendar 

SELECT * FROM holiday_group

DROP TABLE holiday_calendar 
DELETE static_data_value WHERE [type_id] = 10099
DELETE static_data_type WHERE [type_id] = 10099
