--static data type

IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 106100)
BEGIN
	INSERT INTO static_data_type([type_id], [type_name], [internal], [description], [is_active], create_user, create_ts)
	VALUES (106100, 'UDF Data Source', 1, 'UDF Data Source', 1, 'farrms_admin', GETDATE())
	PRINT 'Inserted static data type 106100 - UDF Data Source.'
END
ELSE
BEGIN
	PRINT 'Static data type 106100 - UDF Data Source already EXISTS.'
END
GO
---static data values

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 106100)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (106100, 106100, 'Deal Status', 'SELECT source_deal_type_id, source_deal_type_name 
FROM source_deal_type 
WHERE ISNULL(sub_type, ''n'') = ''y'' 
ORDER BY source_deal_type_name', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 106100 - Deal Status.'
END
ELSE
BEGIN
    PRINT 'Static data value 106100 - Deal Status already EXISTS.'
END

GO

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 106101)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (106101, 106100, 'Location', 'EXEC spa_source_minor_location ''o''', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 106101 - Location.'
END
ELSE
BEGIN
    PRINT 'Static data value 106101 - Location already EXISTS.'
END

GO

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 106102)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (106102, 106100, 'Trader', 'EXEC spa_source_traders_maintain ''x''', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 106102 - Trader.'
END
ELSE
BEGIN
    PRINT 'Static data value 106102 - Trader already EXISTS.'
END

GO

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 106103)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (106103, 106100, 'currency', 'Exec spa_source_currency_maintain ''p''', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 106103 - currency.'
END
ELSE
BEGIN
    PRINT 'Static data value 106103 - currency already EXISTS.'
END

GO

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 106104)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (106104, 106100, 'Price Curve Definition', 'Exec spa_source_currency_maintain ''p''', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 106104 - Price Curve Definition.'
END
ELSE
BEGIN
    PRINT 'Static data value 106104 - Price Curve Definition already EXISTS.'
END

GO

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 106104)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (106104, 106100, 'Price Curve Definition', 'Exec spa_source_currency_maintain ''p''', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 106104 - Price Curve Definition.'
END
ELSE
BEGIN
    PRINT 'Static data value 106104 - Price Curve Definition already EXISTS.'
END

GO

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 106105)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (106105, 106100, 'custom sql', 'custom_sql', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 106105 - Custom Sql.'
END
ELSE
BEGIN
    PRINT 'Static data value 106105 - Custom Sql already EXISTS.'
END

GO

SET IDENTITY_INSERT static_data_value OFF

GO