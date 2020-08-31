SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 898)
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
	    898,
	    800,
	    'FixedVolm',
	    'Fixed Volume of Deal',
	    'farrms_admin',
	    GETDATE()
	  )
	  
	PRINT 'Inserted static data value 898 - FixedVolm'
END
ELSE
BEGIN
	PRINT 'Static data value 898 - ContractualVolm already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 899)
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
	    899,
	    800,
	    'ContractualVolm',
	    'Contract Volume from Deal',
	    'farrms_admin',
	    GETDATE()
	  )
	  
	PRINT 'Inserted static data value 899 - ContractualVolm'
END
ELSE
BEGIN
	PRINT 'Static data value 899 - ContractualVolm already EXISTS.'
END



SET IDENTITY_INSERT static_data_value OFF

GO

update static_data_value set code='WghtFixPrice', description='Weighted Average Deal Price' where value_id=889