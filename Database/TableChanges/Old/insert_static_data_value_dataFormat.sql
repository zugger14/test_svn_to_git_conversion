SET IDENTITY_INSERT dbo.static_data_value ON 

IF NOT EXISTS (SELECT 'X' FROM dbo.static_data_value WHERE value_id = 5461)
	INSERT INTO dbo.static_data_value (value_id, [type_id], code,	description) VALUES (5461, 5450, 'MV90 Data','MV90 Data')

SET IDENTITY_INSERT dbo.static_data_value OFF  
