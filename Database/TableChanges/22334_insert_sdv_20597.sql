SET IDENTITY_INSERT static_data_value ON
IF EXISTS (SELECT 1 FROM static_data_value WHERE type_id = 20500 AND code = 'Deal - Post Transferred' AND value_id <> 20597)
BEGIN
	DELETE FROM
	static_data_value 
	WHERE type_id = 20500 AND code = 'Deal - Post Transferred'
END
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20597)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (20500, 20597, 'Deal - Post Transferred', 'Deal - Post Transferred', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 20597 - Deal - Post Transferred.'
END
ELSE
BEGIN
    PRINT 'Static data value 20597 - Deal - Post Transferred already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
