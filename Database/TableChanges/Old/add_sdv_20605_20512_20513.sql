SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20605)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20605, 20600, 'Invoice', 'Invoice', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20605 - Invoice.'
END
ELSE
BEGIN
	PRINT 'Static data value 20605 - Invoice already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20512)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20512, 20500, 'Invoice - Post Update', 'Invoice - Post Update', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20512 - Invoice - Post Update.'
END
ELSE
BEGIN
	PRINT 'Static data value 20512 - Invoice - Post Update already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20513)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20513, 20500, 'Deal - Post Confirm Staus Update' , 'Deal - Post Confirm Staus Update' , 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20513 - Deal - Post Confirm Staus Update.'
END
ELSE
BEGIN
	PRINT 'Static data value 20513 - Deal - Post Confirm Staus Update already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20514)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20514, 20500, 'Post - Outage Information Changed' , 'Post - Outage Information Changed' , 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20514 - Post - Outage Information Changed.'
END
ELSE
BEGIN
	PRINT 'Static data value 20514 - Post - Outage Information Changed already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF