IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 112600)
BEGIN
    INSERT INTO static_data_type([type_id], [type_name], [description], [internal], [is_active], create_user, create_ts)
    VALUES (112600, 'Auction Name', 'Auction Name', 0, 1, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data type 112600 - Auction Name.'
END
ELSE
BEGIN
    PRINT 'Static data type 112600 - Auction Name already EXISTS.'
END            

IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 112500)
BEGIN
    INSERT INTO static_data_type([type_id], [type_name], [description], [internal], [is_active], create_user, create_ts)
    VALUES (112500, 'Auction Area', 'Auction Area', 0, 1, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data type 112500 - Auction Area.'
END
ELSE
BEGIN
    PRINT 'Static data type 112500 - Auction Area already EXISTS.'
END            
