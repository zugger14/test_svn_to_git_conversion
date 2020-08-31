-- UDF changes

DELETE FROM static_data_value WHERE [type_id] = 5500 AND code = 'Customer'
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5584)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5584, 5500, 'Customer', 'Customer', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5584 - Customer.'
END
ELSE
BEGIN
	UPDATE static_data_value SET code = 'Customer', [description] = 'Customer' WHERE [value_id] = -5584
	PRINT 'Updated Static value -5584 - Customer.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5580)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5580, 5500, 'Fixed_Offpeak', 'Fixed OffPeak', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5580 - Fixed_Offpeak.'
END
ELSE
BEGIN
	UPDATE static_data_value SET code = 'Fixed_Offpeak', [description] = 'Fixed OffPeak' WHERE [value_id] = -5580
	PRINT 'Updated Static value -5580 - Fixed_Offpeak.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5579)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5579, 5500, 'Fixed', 'Fixed', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5579 - Fixed.'
END
ELSE
BEGIN
	UPDATE static_data_value SET code = 'Fixed', [description] = 'Fixed' WHERE [value_id] = -5579
	PRINT 'Updated Static value -5579 - Fixed.'
END
SET IDENTITY_INSERT static_data_value OFF

-- id is reshuffled to match with that of UAT. So to avoid violation of UNIQUE constraint, rename code to something temporary
UPDATE static_data_value SET code = code + 'X' WHERE [type_id] = 5500 AND value_id IN (-5553, -5554, -5555, -5556)
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5556)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5556, 5500, 'Weight1', 'Weight1', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5556 - Weight1.'
END
ELSE
BEGIN
	UPDATE static_data_value SET code = 'Weight1', [description] = 'Weight1' WHERE [value_id] = -5556
	PRINT 'Updated Static value -5556 - Weight1.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5555)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5555, 5500, 'Weight4', 'Weight4', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5555 - Weight4.'
END
ELSE
BEGIN
	UPDATE static_data_value SET code = 'Weight4', [description] = 'Weight4' WHERE [value_id] = -5555
	PRINT 'Updated Static value -5555 - Weight4.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5554)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5554, 5500, 'Weight2', 'Weight2', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5554 - Weight2.'
END
ELSE
BEGIN
	UPDATE static_data_value SET code = 'Weight2', [description] = 'Weight2' WHERE [value_id] = -5554
	PRINT 'Updated Static value -5554 - Weight2.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5553)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5553, 5500, 'Weight3', 'Weight3', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5553 - Weight3.'
END
ELSE
BEGIN
	UPDATE static_data_value SET code = 'Weight3', [description] = 'Weight3' WHERE [value_id] = -5553
	PRINT 'Updated Static value -5553 - Weight3.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5564)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5564, 5500, 'Is_Profile', 'Is_Profile', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5564 - Is_Profile.'
END
ELSE
BEGIN
	UPDATE static_data_value SET code = 'Is_Profile', [description] = 'Is_Profile' WHERE [value_id] = -5564
	PRINT 'Updated Static value -5564 - Is_Profile.'
END
SET IDENTITY_INSERT static_data_value OFF


-- rename Adder to Add-ons and Multiplier to Weight

DELETE FROM static_data_value WHERE [type_id] = 15600 AND code IN ('Adder', 'Multiplier')

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE [type_id] = 15600 AND code = 'Weight')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description], create_user, create_ts)
	VALUES (15600, 'Weight', 'Weight', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value Weight.'
END
ELSE
BEGIN
	PRINT 'Updated Static value Weight EXISTS'
END

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE [type_id] = 15600 AND code = 'Add-ons')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description], create_user, create_ts)
	VALUES (15600, 'Add-ons', 'Add-ons', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value Add-ons.'
END
ELSE
BEGIN
	PRINT 'Updated Static value Add-ons EXISTS'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 15600 AND code = 'Others')
	INSERT INTO static_data_value ([type_id], code, [description], create_user, create_ts)
	VALUES (15600, 'Others', 'Others', 'farrms_admin', GETDATE())




