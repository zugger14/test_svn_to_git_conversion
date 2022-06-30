IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 117600)
BEGIN
    INSERT INTO static_data_type([type_id], [type_name], [description], [internal], [is_active], create_user, create_ts)
    VALUES (117600, 'Venue', 'Venue', 0, 1, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data type 117600 - Venue.'
END
ELSE
BEGIN
    PRINT 'Static data type 117600 - Venue already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 117700)
BEGIN
    INSERT INTO static_data_type([type_id], [type_name], [description], [internal], [is_active], create_user, create_ts)
    VALUES (117700, 'ENMACC Commodity', 'ENMACC Commodity', 0, 1, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data type 117700 - ENMACC Commodity.'
END
ELSE
BEGIN
    PRINT 'Static data type 117700 - ENMACC Commodity already EXISTS.'
END