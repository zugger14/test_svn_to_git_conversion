SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20501)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20501, 20500, 'Deal - Pre Insert', 'Deal - Pre Insert', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20501 - Deal - Pre Insert.'
END
ELSE
BEGIN
	PRINT 'Static data value 20501 - Deal - Pre Insert already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20502)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20502, 20500, 'Deal - Post Insert', 'Deal - Post Insert', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20502 - Deal - Post Insert.'
END
ELSE
BEGIN
	PRINT 'Static data value 20502 - Deal - Post Insert already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20503)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20503, 20500, 'Deal - Pre Update', 'Deal - Pre Update', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20503 - Deal - Pre Update.'
END
ELSE
BEGIN
	PRINT 'Static data value 20503 - Deal - Pre Update already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20504)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20504, 20500, 'Deal - Post Update', 'Deal - Post Update', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20504 - Deal - Post Update.'
END
ELSE
BEGIN
	PRINT 'Static data value 20504 - Deal - Post Update already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20505)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20505, 20500, 'Deal - Pre Delete', 'Deal - Pre Delete', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20505 - Deal - Pre Delete.'
END
ELSE
BEGIN
	PRINT 'Static data value 20505 - Deal - Pre Delete already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20506)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20506, 20500, 'Deal - Post Delete', 'Deal - Post Delete', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20506 - Deal - Post Delete.'
END
ELSE
BEGIN
	PRINT 'Static data value 20506 - Deal - Post Delete already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20507)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20507, 20500, 'Counterparty Credit File Update', 'Counterparty Credit File Update', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20507 - Counterparty Credit File Update.'
END
ELSE
BEGIN
	PRINT 'Static data value 20507 - Counterparty Credit File Update already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20508)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20508, 20500, 'Counterparty Credit Exposure Calculation', 'Counterparty Credit Exposure Calculation', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20508 - Counterparty Credit Exposure Calculation.'
END
ELSE
BEGIN
	PRINT 'Static data value 20508 - Counterparty Credit Exposure Calculation already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20601)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20601, 20600, 'Deal', 'Deal', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20601 - Deal.'
END
ELSE
BEGIN
	PRINT 'Static data value 20601 - Deal already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20602)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20602, 20600, 'Counterparty', 'Counterparty', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20602 - Counterparty.'
END
ELSE
BEGIN
	PRINT 'Static data value 20602 - Counterparty already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20603)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20603, 20600, 'Contract', 'Contract', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20603 - Contract.'
END
ELSE
BEGIN
	PRINT 'Static data value 20603 - Contract already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20604)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20604, 20600, 'Counterparty Credit File', 'Counterparty Credit File', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20604 - Counterparty Credit File.'
END
ELSE
BEGIN
	PRINT 'Static data value 20604 - Counterparty Credit File already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
