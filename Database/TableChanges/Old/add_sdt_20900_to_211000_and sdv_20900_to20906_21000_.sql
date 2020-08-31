/*Static data type start*/
IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 20900)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (20900, 'Product', 1, 'Product', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 20900 - Product.'
END
ELSE
BEGIN
	PRINT 'Static data type 20900 - Product already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 21000)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (21000, 'Cost', 1, 'Cost', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 21000 - Cost.'
END
ELSE
BEGIN
	PRINT 'Static data type 21000 - Cost already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 21100)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (21100, 'Vintage', 1, 'Vintage', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 21100 - Vintage.'
END
ELSE
BEGIN
	PRINT 'Static data type 21100 - Vintage already EXISTS.'
END

/*Static data type end */

/*Static data value start*/

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20900)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20900, 20900, 'APX_PRIJZEN_AUTO_15mins', 'APX_PRIJZEN_AUTO_15mins', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20900 - APX_PRIJZEN_AUTO_15mins.'
END
ELSE
BEGIN
	PRINT 'Static data value 20900 - APX_PRIJZEN_AUTO_15mins already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20901)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20901, 20900, 'Biomass', 'Biomass', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20901 - Biomass.'
END
ELSE
BEGIN
	PRINT 'Static data value 20901 - Biomass already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20902)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20902, 20900, 'Swine', 'Swine', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20902 - Swine.'
END
ELSE
BEGIN
	PRINT 'Static data value 20902 - Swine already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20903)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20903, 20900, 'Poultry', 'Poultry', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20903 - Poultry.'
END
ELSE
BEGIN
	PRINT 'Static data value 20903 - Poultry already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20904)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20904, 20900, 'Solar', 'Solar', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20904 - Solar.'
END
ELSE
BEGIN
	PRINT 'Static data value 20904 - Solar already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20905)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20905, 20900, 'Wind', 'Wind', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20905 - Wind.'
END
ELSE
BEGIN
	PRINT 'Static data value 20905 - Wind already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20906)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20906, 20900, 'Hydro', 'Hydro', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20906 - Hydro.'
END
ELSE
BEGIN
	PRINT 'Static data value 20906 - Hydro already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 21000)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (21000, 21000, 'High', 'High', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 21000 - High.'
END
ELSE
BEGIN
	PRINT 'Static data value 21000 - High already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 21001)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (21001, 21000, 'Low', 'Low', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 21001 - Low.'
END
ELSE
BEGIN
	PRINT 'Static data value 21001 - Low already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 21100)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (21100, 21100, 'FIFO', 'FIFO', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 21100 - FIFO.'
END
ELSE
BEGIN
	PRINT 'Static data value 21100 - FIFO already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 21101)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (21101, 21100, 'LIFO', 'LIFO', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 21101 - LIFO.'
END
ELSE
BEGIN
	PRINT 'Static data value 21101 - LIFO already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
/*Static data value end*/
GO
 