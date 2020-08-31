SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -807)
BEGIN
	INSERT INTO static_data_value
	  (
	    value_id,
	    [type_id],
	    code,
	    [description],	    
	    create_user,
	    create_ts
	  )
	VALUES
	  (
	    -807,
	    800,
	    'DaysInYr',
	    'DaysInYr',
	    'farrms_admin',
	    GETDATE()
	  )
	  
	PRINT 'Inserted static data value -807 - DaysInYr'
END
ELSE
BEGIN
	UPDATE static_data_value
	SET
		-- value_id = ? -- this column value is auto-generated
		code = 'DaysInYr',
		[description] =  'DaysInYr'
	WHERE value_id = '-807'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -866)
BEGIN
	INSERT INTO static_data_value
	  (
	    value_id,
	    [type_id],
	    code,
	    [description],	    
	    create_user,
	    create_ts
	  )
	VALUES
	  (
	    -866,
	    800,
	    'VATPercent',
	    'Function to derive VAT rate (used as curve value) based on effective date and VAT Rule Mapping.',
	    'farrms_admin',
	    GETDATE()
	  )
	  
	PRINT 'Inserted static data value -866 - FNAVATPercent'
END
ELSE
BEGIN
	UPDATE static_data_value
	SET
		-- value_id = ? -- this column value is auto-generated
		code = 'VATPercent',
		[description] =  'Function to derive VAT rate (used as curve value) based on effective date and VAT Rule Mapping.'
	WHERE value_id = '-866'
END
SET IDENTITY_INSERT static_data_value OFF