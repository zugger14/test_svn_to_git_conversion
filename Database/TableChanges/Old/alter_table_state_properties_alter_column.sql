-- setting settlement_period column nullable
IF EXISTS (SELECT 1 FROM sys.[columns] WHERE NAME = N'settlement_period' AND [object_id] = OBJECT_ID(N'state_properties'))
BEGIN
	ALTER TABLE state_properties DROP COLUMN settlement_period  
	ALTER TABLE state_properties ADD settlement_period INT 
END
