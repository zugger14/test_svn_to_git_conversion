IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 105100)
BEGIN
	INSERT INTO static_data_type([type_id], [type_name], [internal], [description], [is_active], create_user, create_ts)
	VALUES (105100, 'Reservoir Type', 1, '', 1, 'farrms_admin', GETDATE())
	PRINT 'Inserted static data type 105100 - Reservoir Type.'
END
ELSE
BEGIN
	PRINT 'Static data type 105100 - Reservoir Type already EXISTS.'
END

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 105100)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (105100, 105100, 'Depleted Reservoir', 'Depleted Reservoir', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 105100 - Depleted Reservoir.'
END
ELSE
BEGIN
    PRINT 'Static data value 105100 - Depleted Reservoir already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 105101)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (105101, 105100, 'Aquifer Reservoir', 'Aquifer Reservoir', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 105101 - Aquifer Reservoir.'
END
ELSE
BEGIN
    PRINT 'Static data value 105101 - Aquifer Reservoir already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 105102)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (105102, 105100, 'Salt Formation', 'Salt Formation', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 105102 - Salt Formation.'
END
ELSE
BEGIN
    PRINT 'Static data value 105102 - Salt Formation already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF