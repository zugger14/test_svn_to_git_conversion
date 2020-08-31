IF EXISTS (SELECT 1 FROM sys.[columns] WHERE NAME = N'code_value' AND [object_id] = OBJECT_ID(N'state_properties_bonus'))
BEGIN
	EXEC sp_RENAME 'state_properties_bonus.code_value', 'state_value_id', 'COLUMN'
END