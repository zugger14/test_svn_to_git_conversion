/*
* Inserts static data required for importing Deal Data Hour (both Power & Gas or LRS & CSV)
*/
--add import format for Deal Hourly Data (LRS)
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 5467)
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
	    5467,
	    5450,
	    'Deal_Hourly_Data_LRS',
	    'Deal Hourly Data (LRS)',
	    'farrms_admin',
	    GETDATE()
	  )
	  
	PRINT 'Inserted static data value 5467 - Deal_Hourly_Data_LRS'
END
ELSE
BEGIN
	UPDATE static_data_value SET code = 'Deal_Hourly_Data_LRS', [description] = 'Deal Hourly Data (LRS)' WHERE value_id = 5467
	PRINT 'Updated static data value 5467 - Deal_Hourly_Data_LRS.'
END

--add import format for Deal Hourly Data (CSV)
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 5469)
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
	    5469,
	    5450,
	    'Deal_Hourly_Data_CSV',
	    'Deal Hourly Data (CSV)',
	    'farrms_admin',
	    GETDATE()
	  )
	  
	PRINT 'Inserted static data value 5469 - Deal_Hourly_Data_CSV'
END
ELSE
BEGIN
	UPDATE static_data_value SET code = 'Deal_Hourly_Data_CSV', [description] = 'Deal Hourly Data (CSV)' WHERE value_id = 5469
	PRINT 'Updated static data value 5469 - Deal_Hourly_Data_CSV.'
END

--add import table name for Deal Hourly Data (LRS)
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 4035)
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
	    4035,
	    4000,
	    'deal_detail_hour_lrs',
	    'Deal Detail Hour',
	    'farrms_admin',
	    GETDATE()
	  )
	  
	PRINT 'Inserted static data value 4035 - deal_detail_hour_lrs.'
END
ELSE
BEGIN
	UPDATE static_data_value SET code = 'deal_detail_hour_lrs', [description] = 'Deal Detail Hour' WHERE value_id = 4035
	PRINT 'Updated static data value 4035 - deal_detail_hour_lrs.'
END

--add import table name for Deal Hourly Data (CSV)
IF NOT EXISTS(SELECT 1 FROM static_data_value where value_id = 4036)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
    VALUES (4036, 4000, 'deal_detail_hour_csv', 'Deal Detail Hour', 'farrms_admin', GETDATE()) 
      
	PRINT 'Inserted static data value 4036 - deal_detail_hour_csv.'
END
ELSE
BEGIN
	UPDATE static_data_value SET code = 'deal_detail_hour_csv', [description] = 'Deal Detail Hour' WHERE value_id = 4036
	PRINT 'Updated static data value 4036 - deal_detail_hour_csv.'
END

--add Deal Hourly Data (LRS) in external import source
IF NOT EXISTS(SELECT 1 FROM external_source_import WHERE data_type_id = 4035)
BEGIN
	INSERT INTO external_source_import(source_system_id, data_type_id) SELECT 2, 4035
	PRINT 'Inserted external_source_import 4035 - deal_detail_hour_lrs.'
END
ELSE
BEGIN
	PRINT 'external_source_import 4035 - deal_detail_hour_lrs already EXISTS.'
END

SET IDENTITY_INSERT static_data_value OFF
