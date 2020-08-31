INSERT INTO dbo.static_data_type (type_id,type_name,internal,description) VALUES (2200, 'Counterparty External ID', 1, 'Counterparty External ID')

SELECT * FROM dbo.static_data_type WHERE [type_id] = 2200 

SET IDENTITY_INSERT dbo.static_data_value ON 
INSERT INTO dbo.static_data_value (value_id,type_id,code,description) VALUES (2200, 2200, 'Federal Tax Id', 'Federal Tax Id')
INSERT INTO dbo.static_data_value (value_id,type_id,code,description) VALUES (2201, 2200, 'EPA ID', 'EPA ID')
INSERT INTO dbo.static_data_value (value_id,type_id,code,description) VALUES (2202, 2200, 'State ID', 'State ID')
SET IDENTITY_INSERT dbo.static_data_value OFF 

SELECT * FROM dbo.static_data_value WHERE [type_id] = 2200 