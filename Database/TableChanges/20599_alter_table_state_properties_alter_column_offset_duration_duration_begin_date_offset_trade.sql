IF EXISTS (SElECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'state_properties' AND column_name = 'offset_duration')
BEGIN
	ALTER TABLE state_properties
	ALTER COLUMN offset_duration INT NULL	
END

IF EXISTS (SElECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'state_properties' AND column_name = 'duration')
BEGIN
	ALTER TABLE state_properties
	ALTER COLUMN duration INT NULL	
END

IF EXISTS (SElECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'state_properties' AND column_name = 'begin_date')
BEGIN
	ALTER TABLE state_properties
	ALTER COLUMN begin_date DATETIME NULL	
END

IF EXISTS (SElECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'state_properties' AND column_name = 'offset_trade')
BEGIN
	ALTER TABLE state_properties
	ALTER COLUMN offset_trade VARCHAR(200) NULL	
END