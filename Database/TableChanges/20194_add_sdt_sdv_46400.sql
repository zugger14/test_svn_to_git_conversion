IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 46400)
BEGIN
	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (46400, 'Forecast Aggregation', 1, 'Forecast Aggregation', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data type 46400 - Forecast Aggregation.'
END
ELSE
BEGIN
	PRINT 'Static data type 46400 - Forecast Aggregation already EXISTS.'
END


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 46400)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (46400, 46400, 'Average', 'Average', '1', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 46400 - Average.'
END
ELSE
BEGIN
    PRINT 'Static data value 46400 - Average already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF



SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 46401)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (46401, 46400, 'Sum', 'Sum', '1', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 46401 - Sum.'
END
ELSE
BEGIN
    PRINT 'Static data value 46401 - Sum already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 46402)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (46402, 46400, 'Evenly Allocate', 'Evenly Allocate', '2', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 46402 - Evenly Allocate.'
END
ELSE
BEGIN
    PRINT 'Static data value 46402 - Evenly Allocate already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 46403)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (46403, 46400, 'Use Same', 'Use Same', '2', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 46403 - Use Same.'
END
ELSE
BEGIN
    PRINT 'Static data value 46403 - Use Same already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


UPDATE static_data_value
    SET code = 'AVG',
    [category_id] = '1'
    WHERE [value_id] = 46400
PRINT 'Updated Static value 46400 - AVG.'