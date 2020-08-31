--select * from static_data_value 
--where TYPE_ID=225

--delete static_data_value
--where code='Extrinsic Values in AOCI' and type_id=225


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 401055)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (401055, 225, 'Extrinsic Values in AOCI', 'Extrinsic Values in AOCI', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 401055 - Extrinsic Values in AOCI.'
END
ELSE
BEGIN
    PRINT 'Static data value 401055 - Extrinsic Values in AOCI already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF





