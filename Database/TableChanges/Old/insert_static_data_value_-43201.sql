SET NOCOUNT ON 
GO
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -43201)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-43201, 43200, 'N/A', ' N/A', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -43201 - N/A.'
END
ELSE
BEGIN
    PRINT 'Static data value -43201 - N/A already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

