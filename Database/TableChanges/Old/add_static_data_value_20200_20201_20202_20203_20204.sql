/* 
Added by sbantawa@pioneerglobalsolution.com (24th May, 2012) 
Inserts static data value Others, Trader, Trading Role, Commodity, Counterparty
*/

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20200)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20200, 20200, 'Others', 'Others', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20200 - Others.'
END
ELSE
BEGIN
	PRINT 'Static data value 20200 - Others already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20201)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20201, 20200, 'Trader', 'Trader', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20201 - Trader.'
END
ELSE
BEGIN
	PRINT 'Static data value 20201 - Trader already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20202)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20202, 20200, 'Trading Role', 'Trading Role', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20202 - Trading Role.'
END
ELSE
BEGIN
	PRINT 'Static data value 20202 - Trading Role already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20203)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20203, 20200, 'Commodity', 'Commodity', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20203 - Commodity.'
END
ELSE
BEGIN
	PRINT 'Static data value 20203 - Commodity already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20204)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20204, 20200, 'Counterparty', 'Counterparty', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20204 - Counterparty.'
END
ELSE
BEGIN
	PRINT 'Static data value 20204 - Counterparty already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF