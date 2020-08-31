SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 2170)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (2170, 2150, 'MTM Option Deal Breakdown', 'MTM Option Deal Breakdown', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 2170 - MTM Option Deal Breakdown.'
END
ELSE
BEGIN
    PRINT 'Static data value 2170 - MTM Option Deal Breakdown already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF