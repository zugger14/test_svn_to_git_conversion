IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 113000)
BEGIN
    INSERT INTO static_data_type([type_id], [type_name], [description], [internal], [is_active], create_user, create_ts)
    VALUES (113000, 'Reporting Group1', 'Reporting Group1', 0, 1, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data type 113000 - Reporting Group1.'
END
ELSE
BEGIN
    PRINT 'Static data type 113000 - Reporting Group1 already EXISTS.'
END            

IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 113100)
BEGIN
    INSERT INTO static_data_type([type_id], [type_name], [description], [internal], [is_active], create_user, create_ts)
    VALUES (113100, 'Reporting Group2', 'Reporting Group2', 0, 1, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data type 113100 - Reporting Group2.'
END
ELSE
BEGIN
    PRINT 'Static data type 113100 - Reporting Group2 already EXISTS.'
END            


IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 113200)
BEGIN
    INSERT INTO static_data_type([type_id], [type_name], [description], [internal], [is_active], create_user, create_ts)
    VALUES (113200, 'Reporting Group3', 'Reporting Group3', 0, 1, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data type 113200 - Reporting Group3.'
END
ELSE
BEGIN
    PRINT 'Static data type 113200 - Reporting Group3 already EXISTS.'
END            

IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 113300)
BEGIN
    INSERT INTO static_data_type([type_id], [type_name], [description], [internal], [is_active], create_user, create_ts)
    VALUES (113300, 'Reporting Group4', 'Reporting Group4', 0, 1, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data type 113300 - Reporting Group4.'
END
ELSE
BEGIN
    PRINT 'Static data type 113300 - Reporting Group4 already EXISTS.'
END            


IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 113400)
BEGIN
    INSERT INTO static_data_type([type_id], [type_name], [description], [internal], [is_active], create_user, create_ts)
    VALUES (113400, 'Reporting Group5', 'Reporting Group5', 0, 1, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data type 113400 - Reporting Group5.'
END
ELSE
BEGIN
    PRINT 'Static data type 113400 - Reporting Group5 already EXISTS.'
END            

