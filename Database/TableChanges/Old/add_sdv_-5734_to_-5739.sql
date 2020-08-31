SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5734)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-5734, 5500, 'Broker Fee($/UOM)', ' Broker Fee($/UOM)', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -5734 - Broker Fee($/UOM).'
END
ELSE
BEGIN
    PRINT 'Static data value -5734 - Broker Fee($/UOM) already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5735)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-5735, 5500, 'Broker Fee(%)', ' Broker Fee(%)', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -5735 - Broker Fee(%).'
END
ELSE
BEGIN
    PRINT 'Static data value -5735 - Broker Fee(%) already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5736)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-5736, 5500, 'Broker Fee( flat fee)', ' Broker Fee( flat fee)', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -5736 - Broker Fee( flat fee).'
END
ELSE
BEGIN
    PRINT 'Static data value -5736 - Broker Fee( flat fee) already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5737)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-5737, 5500, 'Commission ($/UOM)', ' Commission ($/UOM)', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -5737 - Commission ($/UOM).'
END
ELSE
BEGIN
    PRINT 'Static data value -5737 - Commission ($/UOM) already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5738)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-5738, 5500, 'Commission (%)', ' Commission (%)', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -5738 - Commission (%).'
END
ELSE
BEGIN
    PRINT 'Static data value -5738 - Commission (%) already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5739)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-5739, 5500, 'Commission (flat fee)', ' Commission (flat fee)', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -5739 - Commission (flat fee).'
END
ELSE
BEGIN
    PRINT 'Static data value -5739 - Commission (flat fee) already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF