IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE code = 'Rating 1' AND type_id =10097)
BEGIN
    INSERT INTO static_data_value ([type_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (10097, 'Rating 1', 'Rating 1', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value Rating 1.'
END
ELSE
BEGIN
    PRINT 'Static data value Rating 1 already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE code = 'Rating 2' AND type_id =10097)
BEGIN
    INSERT INTO static_data_value ([type_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (10097, 'Rating 2', 'Rating 2', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value Rating 2.'
END
ELSE
BEGIN
    PRINT 'Static data value Rating 2 already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE code = 'Rating 3' AND type_id =10097)
BEGIN
    INSERT INTO static_data_value ([type_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (10097, 'Rating 3', 'Rating 3', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value Rating 3.'
END
ELSE
BEGIN
    PRINT 'Static data value Rating 3 already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE code = 'Rating 4' AND type_id =10097)
BEGIN
    INSERT INTO static_data_value ([type_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (10097, 'Rating 4', 'Rating 4', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value Rating 4.'
END
ELSE
BEGIN
    PRINT 'Static data value Rating 4 already EXISTS.'
END