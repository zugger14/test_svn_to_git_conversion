-- static data type
IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 20800)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (20800, 'Action Type', 1, 'Action Type', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 20800 - Action Type.'
END
ELSE
BEGIN
	PRINT 'Static data type 20800 - Action Type already EXISTS.'
END


-- static data values

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20801)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20801, 20800, 'Activate Counterparty', 'Activate Counterparty', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20801 - Activate Counterparty.'
END
ELSE
BEGIN
	PRINT 'Static data value 20801 - Activate Counterparty already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20802)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20802, 20800, 'Approve Contract', 'Approve Contract', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20802 - Approve Contract.'
END
ELSE
BEGIN
	PRINT 'Static data value 20802 - Approve Contract already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20803)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20803, 20800, 'Validate Deal', 'Validate Deal', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20803 - Validate Deal.'
END
ELSE
BEGIN
	PRINT 'Static data value 20803 - Validate Deal already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

--- NEW
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20804)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20804, 20800, 'Contract - Final Review', 'Contract - Final Review', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20804 - Contract - Final Review.'
END
ELSE
BEGIN
	PRINT 'Static data value 20804 - Contract - Final Review already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20805)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20805, 20800, 'Unapprove Contract', 'Unapprove Contract', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20805 - Unapprove Contract.'
END
ELSE
BEGIN
	PRINT 'Static data value 20805 - Unapprove Contract already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
