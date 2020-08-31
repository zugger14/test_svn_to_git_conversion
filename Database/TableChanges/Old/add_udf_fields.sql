SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5565)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5565, 5500, 'PV', 'PV', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5565 - PV.'
END
ELSE
BEGIN
	PRINT 'Static data value -5565 - PV already EXISTS.'
END

SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5566)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5566, 5500, 'Spot Cannibalisation', 'Spot Cannibalisation', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5566 - Spot Cannibalisation.'
END
ELSE
BEGIN
	PRINT 'Static data value -5566 - Spot Cannibalisation already EXISTS.'
END

SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5567)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5567, 5500, 'Contract Capacity', 'Contract Capacity', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5567 - Contract Capacity.'
END
ELSE
BEGIN
	PRINT 'Static data value -5567 - Contract Capacity already EXISTS.'
END

SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5568)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5568, 5500, 'Currency', 'Currency', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5568 - Currency.'
END
ELSE
BEGIN
	PRINT 'Static data value -5568 - Currency already EXISTS.'
END

SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5569)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5569, 5500, 'Capacity Unit', 'Capacity Unit', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5569 - Capacity Unit.'
END
ELSE
BEGIN
	PRINT 'Static data value -5569 - Capacity Unit already EXISTS.'
END

SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5570)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5570, 5500, 'Capacity Currency', 'Capacity Currency', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5570 - Capacity Currency.'
END
ELSE
BEGIN
	PRINT 'Static data value -5570 - Capacity Currency already EXISTS.'
END

SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5571)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5571, 5500, 'Framework', 'Framework', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5571 - Framework.'
END
ELSE
BEGIN
	PRINT 'Static data value -5571 - Framework already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5575)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5575, 5500, 'Weight OffPeak1', 'Weight OffPeak1', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5575 - Weight OffPeak1.'
END
ELSE
BEGIN
	PRINT 'Static data value -5575 - Weight OffPeak1 already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5576)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5576, 5500, 'Weight OffPeak2', 'Weight OffPeak2', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5576 - Weight OffPeak2.'
END
ELSE
BEGIN
	PRINT 'Static data value -5576 - Weight OffPeak2 already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5577)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5577, 5500, 'Weight OffPeak3', 'Weight OffPeak3', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5577 - Weight OffPeak3.'
END
ELSE
BEGIN
	PRINT 'Static data value -5577 - Weight OffPeak3 already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5578)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5578, 5500, 'Weight OffPeak4', 'Weight OffPeak4', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5578 - Weight OffPeak4.'
END
ELSE
BEGIN
	PRINT 'Static data value -5578 - Weight OffPeak4 already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF