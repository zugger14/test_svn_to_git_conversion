--Insertion of Density To Start--
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5625)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5625, 5500, 'Density To', 'Density To', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5625 - Density To.'
END
ELSE
BEGIN
	PRINT 'Static data value -5625 - Density To already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF	
--Insertion of Density To End--

--Insertion of Density From Start--
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5624)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5624, 5500, 'Density From', 'Density From', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5624 - Density From.'
END
ELSE
BEGIN
	PRINT 'Static data value -5624 - Density From already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF	
--Insertion of Density From End--

--Insertion of UOM To Start--
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5623)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5623, 5500, 'UOM To', 'UOM To', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5623 - UOM To.'
END
ELSE
BEGIN
	PRINT 'Static data value -5623 - UOM To already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
--Insertion of UOM To End--

--Insertion of UOM From Start--
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5622)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5622, 5500, 'UOM From', 'UOM From', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5622 - UOM From.'
END
ELSE
BEGIN
	PRINT 'Static data value -5622 - UOM From already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF	
--Insertion of UOM From End--

--Insertion of Price Multiplier Start--
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5621)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5621, 5500, 'Price Multiplier', 'Price Multiplier', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5621 - Price Multiplier.'
END
ELSE
BEGIN
	PRINT 'Static data value -5621 - Price Multiplier already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
--Insertion of Price Multiplier End--

--Insertion of UOM Conversionr Start--
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5620)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5620, 5500, 'UOM Conversion', 'UOM Conversion', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5620 - UOM Conversion.'
END
ELSE
BEGIN
	PRINT 'Static data value -5620 - UOM Conversion already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF	
--Insertion of UOM Conversionr End--
--Insertion of Density Start--
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5619)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5619, 5500, 'Density', 'Density', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5619 - Density.'
END
ELSE
BEGIN
	PRINT 'Static data value -5619 - Density already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
--Insertion of Density End--