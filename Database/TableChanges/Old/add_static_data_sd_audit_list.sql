IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 19900)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (19900, 'Static Data Audit Log', 1, 'Static Data Audit Log', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 19900 - Static Data Audit Log.'
END
ELSE
BEGIN
	PRINT 'Static data type 19900 - Static Data Audit Log already EXISTS.'
END	SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19901)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19901, 19900, 'Book Structure', 'Book Structure', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19901 - Book Structure.'
END
ELSE
BEGIN
	PRINT 'Static data value 19901 - Book Structure already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 19900)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (19900, 'Static Data Audit Log', 1, 'Static Data Audit Log', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 19900 - Static Data Audit Log.'
END
ELSE
BEGIN
	PRINT 'Static data type 19900 - Static Data Audit Log already EXISTS.'
END	SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19902)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19902, 19900, 'Contract', 'Contract', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19902 - Contract.'
END
ELSE
BEGIN
	PRINT 'Static data value 19902 - Contract already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 19900)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (19900, 'Static Data Audit Log', 1, 'Static Data Audit Log', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 19900 - Static Data Audit Log.'
END
ELSE
BEGIN
	PRINT 'Static data type 19900 - Static Data Audit Log already EXISTS.'
END	SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19903)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19903, 19900, 'Counterparty', 'Counterparty', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19903 - Counterparty.'
END
ELSE
BEGIN
	PRINT 'Static data value 19903 - Counterparty already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 19900)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (19900, 'Static Data Audit Log', 1, 'Static Data Audit Log', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 19900 - Static Data Audit Log.'
END
ELSE
BEGIN
	PRINT 'Static data type 19900 - Static Data Audit Log already EXISTS.'
END	SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19904)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19904, 19900, 'Deal Type', 'Deal Type', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19904 - Deal Type.'
END
ELSE
BEGIN
	PRINT 'Static data value 19904 - Deal Type already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 19900)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (19900, 'Static Data Audit Log', 1, 'Static Data Audit Log', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 19900 - Static Data Audit Log.'
END
ELSE
BEGIN
	PRINT 'Static data type 19900 - Static Data Audit Log already EXISTS.'
END	SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19905)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19905, 19900, 'Trader', 'Trader', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19905 - Trader.'
END
ELSE
BEGIN
	PRINT 'Static data value 19905 - Trader already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 19900)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (19900, 'Static Data Audit Log', 1, 'Static Data Audit Log', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 19900 - Static Data Audit Log.'
END
ELSE
BEGIN
	PRINT 'Static data type 19900 - Static Data Audit Log already EXISTS.'
END	SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19906)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19906, 19900, 'UOM', 'UOM', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19906 - UOM.'
END
ELSE
BEGIN
	PRINT 'Static data value 19906 - UOM already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 19900)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (19900, 'Static Data Audit Log', 1, 'Static Data Audit Log', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 19900 - Static Data Audit Log.'
END
ELSE
BEGIN
	PRINT 'Static data type 19900 - Static Data Audit Log already EXISTS.'
END	SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19907)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19907, 19900, 'UOM Conversion', 'UOM Conversion', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19907 - UOM Conversion.'
END
ELSE
BEGIN
	PRINT 'Static data value 19907 - UOM Conversion already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 19900)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (19900, 'Static Data Audit Log', 1, 'Static Data Audit Log', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 19900 - Static Data Audit Log.'
END
ELSE
BEGIN
	PRINT 'Static data type 19900 - Static Data Audit Log already EXISTS.'
END	SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19908)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19908, 19900, 'Price Curve Definition', 'Price Curve Definition', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19908 - Price Curve Definition.'
END
ELSE
BEGIN
	PRINT 'Static data value 19908 - Price Curve Definition already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 19900)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (19900, 'Static Data Audit Log', 1, 'Static Data Audit Log', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 19900 - Static Data Audit Log.'
END
ELSE
BEGIN
	PRINT 'Static data type 19900 - Static Data Audit Log already EXISTS.'
END	SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19909)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19909, 19900, 'Price Curves', 'Price Curves', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19909 - Price Curves.'
END
ELSE
BEGIN
	PRINT 'Static data value 19909 - Price Curves already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 19900)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (19900, 'Static Data Audit Log', 1, 'Static Data Audit Log', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 19900 - Static Data Audit Log.'
END
ELSE
BEGIN
	PRINT 'Static data type 19900 - Static Data Audit Log already EXISTS.'
END	SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19910)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19910, 19900, 'Hourly Block', 'Hourly Block', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19910 - Hourly Block.'
END
ELSE
BEGIN
	PRINT 'Static data value 19910 - Hourly Block already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 19900)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (19900, 'Static Data Audit Log', 1, 'Static Data Audit Log', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 19900 - Static Data Audit Log.'
END
ELSE
BEGIN
	PRINT 'Static data type 19900 - Static Data Audit Log already EXISTS.'
END	SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19911)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19911, 19900, 'User', 'User', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19911 - User.'
END
ELSE
BEGIN
	PRINT 'Static data value 19911 - User already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 19900)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (19900, 'Static Data Audit Log', 1, 'Static Data Audit Log', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 19900 - Static Data Audit Log.'
END
ELSE
BEGIN
	PRINT 'Static data type 19900 - Static Data Audit Log already EXISTS.'
END	SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19912)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19912, 19900, 'User Roles', 'User Roles', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19912 - User Roles.'
END
ELSE
BEGIN
	PRINT 'Static data value 19912 - User Roles already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 19900)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (19900, 'Static Data Audit Log', 1, 'Static Data Audit Log', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 19900 - Static Data Audit Log.'
END
ELSE
BEGIN
	PRINT 'Static data type 19900 - Static Data Audit Log already EXISTS.'
END	SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19913)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19913, 19900, 'User Privileges', 'User Privileges', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19913 - User Privileges.'
END
ELSE
BEGIN
	PRINT 'Static data value 19913 - User Privileges already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 19900)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (19900, 'Static Data Audit Log', 1, 'Static Data Audit Log', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 19900 - Static Data Audit Log.'
END
ELSE
BEGIN
	PRINT 'Static data type 19900 - Static Data Audit Log already EXISTS.'
END	SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19914)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19914, 19900, 'Holiday block', 'Holiday block', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19914 - Holiday block.'
END
ELSE
BEGIN
	PRINT 'Static data value 19914 - Holiday block already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF





IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 19900)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (19900, 'Static Data Audit Log', 1, 'Static Data Audit Log', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 19900 - Static Data Audit Log.'
END
ELSE
BEGIN
	PRINT 'Static data type 19900 - Static Data Audit Log already EXISTS.'
END	SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19915)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19915, 19900, 'Subsidiary', 'Subsidiary', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19915 - Subsidiary.'
END
ELSE
BEGIN
	PRINT 'Static data value 19915 - Subsidiary already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 19900)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (19900, 'Static Data Audit Log', 1, 'Static Data Audit Log', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 19900 - Static Data Audit Log.'
END
ELSE
BEGIN
	PRINT 'Static data type 19900 - Static Data Audit Log already EXISTS.'
END	SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19916)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19916, 19900, 'Strategy', 'Strategy', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19916 - Strategy.'
END
ELSE
BEGIN
	PRINT 'Static data value 19916 - Strategy already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 19900)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (19900, 'Static Data Audit Log', 1, 'Static Data Audit Log', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 19900 - Static Data Audit Log.'
END
ELSE
BEGIN
	PRINT 'Static data type 19900 - Static Data Audit Log already EXISTS.'
END	SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19917)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19917, 19900, 'Book', 'Book', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19917 - Book.'
END
ELSE
BEGIN
	PRINT 'Static data value 19917 - Book already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF





UPDATE static_data_value SET code = 'User', [description] = 'User' WHERE [value_id] = 19911
PRINT 'Updated Static value 19911 - User.'