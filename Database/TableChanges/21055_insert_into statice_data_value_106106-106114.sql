IF EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 106105)
BEGIN
	UPDATE static_data_value set code = 'Custom Array', description = 'Custom' where  value_id = 106105
	PRINT 'Static data value 106105 - Custom Array is updated successfully.'
END

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 106106)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (106106, 106100, 'Contract Group', 'EXEC spa_contract_group ''r''', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 106106 - Contract Group.'
END
ELSE
BEGIN
    PRINT 'Static data value 106106 - Contract Group already EXISTS.'
END

GO

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 106107)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (106107, 106100, 'Meter', 'EXEC spa_getAllMeter @flag = ''s''', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 106107 - Meter.'
END
ELSE
BEGIN
    PRINT 'Static data value 106107 - Meter already EXISTS.'
END

GO

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 106108)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (106108, 106100, 'Counterparty', 'EXEC spa_getsourcecounterparty ''s''', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 106108 - Counterparty.'
END
ELSE
BEGIN
    PRINT 'Static data value 106108 - Counterparty already EXISTS.'
END

GO

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 106109)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (106109, 106100, 'Source Book', 'Exec spa_source_book_maintain ''x''', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 106109 - Source Book.'
END
ELSE
BEGIN
    PRINT 'Static data value 106109 - Source Book already EXISTS.'
END

GO

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 106110)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (106110, 106100, 'Price Curve', 'Exec spa_source_price_curve_def_maintain ''l''', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 106110 - Price Curve.'
END
ELSE
BEGIN
    PRINT 'Static data value 106110 - Price Curve already EXISTS.'
END

GO

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 106111)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (106111, 106100, 'Counterparty Maintain', 'Exec spa_source_counterparty_maintain ''c''', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 106111 - Counterparty Maintain.'
END
ELSE
BEGIN
    PRINT 'Static data value 106111 - Counterparty Maintain already EXISTS.'
END

GO

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 106112)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (106112, 106100, 'Product', 'EXEC spa_source_product ''g''', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 106112 - Product.'
END
ELSE
BEGIN
    PRINT 'Static data value 106112 - Product already EXISTS.'
END

GO

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 106113)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (106113, 106100, 'Traders', 'EXEC spa_source_traders_maintain ''x''', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 106113 - Traders.'
END
ELSE
BEGIN
    PRINT 'Static data value 106113 - Traders already EXISTS.'
END

GO

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 106114)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (106114, 106100, 'UOM Maintain', 'EXEC spa_source_uom_maintain ''c''', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 106114 - UOM Maintain.'
END
ELSE
BEGIN
    PRINT 'Static data value 106114 - UOM Maintain already EXISTS.'
END

GO

SET IDENTITY_INSERT static_data_value OFF

GO