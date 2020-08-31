
IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 102200)
BEGIN
	INSERT INTO static_data_type([type_id], [type_name], [internal], [description], create_user, create_ts)
	VALUES (102200, 'DST Group', 1, 'DST Group','farrms_admin', GETDATE())
	PRINT 'Inserted static data type 102200 - DST Group.'
END
ELSE
BEGIN
	PRINT 'Static data type 102200 - DST Group already EXISTS.'
END


--UPDATE static_data_type
--SET [type_name] = 'DST Group',
--	[description] = 'DST Group',
--	[internal] = 1, 
--	[is_active] = 1
--	WHERE [type_id] = 102200
--PRINT 'Updated static data type 102200 - DST Group.'


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 102201)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (102201, 102200, 'EU DST', 'EU DST', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 102201 - EU DST.'
END
ELSE
BEGIN
    PRINT 'Static data value 102201 - EU DST already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


--UPDATE static_data_value
--    SET code = 'EU DST',
--    [category_id] = ''
--    WHERE [value_id] = 102201
--PRINT 'Updated Static value 102201 - EU DST.'


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 102200)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (102200, 102200, 'US DST', 'US DST', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 102200 - US DST.'
END
ELSE
BEGIN
    PRINT 'Static data value 102200 - US DST already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

--UPDATE static_data_value
--    SET code = 'US DST',
--    [category_id] = ''
--    WHERE [value_id] = 102200
--PRINT 'Updated Static value 102200 - US DST.'



SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 102202)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (102202, 102200, 'Not Available DST', 'Not Available DST', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 102202 - Not Available DST.'
END
ELSE
BEGIN
    PRINT 'Static data value 102202 - Not Available DST already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF