SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 4073)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (4073, 4000, 'contract_group_non_standard', 'Contract Group Standard', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 4073 - contract_group_non_standard.'
END
ELSE
BEGIN
	PRINT 'Static data value -4073 - GetLogicalValue already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 4074)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (4074, 4000, 'contract_group_transportation', 'Contract Group Standard', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -4074 - GetLogicalValue.'
END
ELSE
BEGIN
	PRINT 'Static data value -4074 - GetLogicalValue already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

