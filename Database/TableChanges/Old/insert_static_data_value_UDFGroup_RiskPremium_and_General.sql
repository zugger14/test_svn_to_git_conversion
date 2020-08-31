IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE [type_id] = 15600 AND code = 'Fees')
BEGIN	
	INSERT INTO static_data_value ([type_id], code, [description], create_user, create_ts)
	VALUES (15600, 'Fees', 'Fees', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value - Fees.'
END
ELSE
BEGIN
	PRINT 'Static data value  - Fees already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE [type_id] = 15600 AND code = 'General')
BEGIN	
	INSERT INTO static_data_value ([type_id], code, [description], create_user, create_ts)
	VALUES (15600, 'General', 'General', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value - General.'
END
ELSE
BEGIN
	PRINT 'Static data value  - General already EXISTS.'
END


IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE [type_id] = 15600 AND code = 'Risk Premium')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description], create_user, create_ts)
	VALUES (15600, 'Risk Premium', 'Risk Premium', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value - Risk Premium.'
END
ELSE
BEGIN
		PRINT 'Static data value  - Risk Premium already EXISTS.'
END

--SELECT * FROM static_data_value WHERE [type_id] = 15600 