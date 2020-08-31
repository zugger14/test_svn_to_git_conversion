SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 5468)
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
	    5468,
	    5450,
	    'Source System File',
	    'Source System File',
	    'farrms_admin',
	    GETDATE()
	  )
	  
	PRINT 'Inserted static data value 5468 - Source System File'
END
ELSE
BEGIN
	PRINT 'Static data value 5468 - Source System File already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

