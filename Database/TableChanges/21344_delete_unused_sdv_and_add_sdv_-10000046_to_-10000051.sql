DELETE FROM static_data_value
WHERE code IN (
	'Withdrawal Volume',
	'Injection Amount',
	'Withdrawal Amount',
	'Injection Volume',
	'WACOG with Fees',
	'WACOG w/o Fees'
) AND type_id = 5500 and value_id > 0

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000046)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-10000046, 5500, 'Injection Volume', 'Injection Volume', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000046 - Injection Volume.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000046 - Injection Volume already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000047)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-10000047, 5500, 'Withdrawal Volume', 'Withdrawal Volume', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000047 - Withdrawal Volume.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000047 - Withdrawal Volume already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000048)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-10000048, 5500, 'Injection Amount', 'Injection Amount', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000048 - Injection Amount.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000048 - Injection Amount already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000049)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-10000049, 5500, 'Withdrawal Amount', 'Withdrawal Amount', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000049 - Withdrawal Amount.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000049 - Withdrawal Amount already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000050)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-10000050, 5500, 'WACOG with Fees', 'WACOG with Fees', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000050 - WACOG with Fees.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000050 - WACOG with Fees already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000051)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-10000051, 5500, 'WACOG w/o Fees', 'WACOG w/o Fees', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000051 - WACOG w/o Fees.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000051 - WACOG w/o Fees already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF