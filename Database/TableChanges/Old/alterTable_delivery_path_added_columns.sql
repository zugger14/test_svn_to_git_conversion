IF NOT EXISTS (SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'delivery_path' and column_name = 'rateSchedule')
	ALTER TABLE delivery_path add rateSchedule INT NULL
GO
IF NOT EXISTS (SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'delivery_path' and column_name = 'counterParty')
	ALTER TABLE delivery_path add counterParty INT NULL
GO
IF NOT EXISTS (SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'delivery_path' and column_name = 'CONTRACT')
	ALTER TABLE delivery_path add [CONTRACT] INT NULL 
GO

IF NOT EXISTS (SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'delivery_path' and column_name = 'location_id')
	ALTER TABLE delivery_path add location_id INT NULL 
GO
IF NOT EXISTS (SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'delivery_path' and column_name = 'from_location')
	ALTER TABLE delivery_path add from_location INT NULL 
GO
IF NOT EXISTS (SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'delivery_path' and column_name = 'to_location')
	ALTER TABLE delivery_path add to_location INT NULL 
GO
IF NOT EXISTS (SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'delivery_path' and column_name = 'groupPath')
	ALTER TABLE delivery_path add groupPath CHAR(1) NULL 
GO

