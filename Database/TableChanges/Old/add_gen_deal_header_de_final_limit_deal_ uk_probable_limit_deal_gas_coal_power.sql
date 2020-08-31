--   UPDATE user_defined_fields_template
--    SET Field_label = 'Proj Index Group'
-- select * from  delete user_defined_fields_template  WHERE  Field_label = 'Commodity'


--    SELECT 1
--       update user_defined_fields_template set Field_label='Proj Index Group'   
--       WHERE  Field_label = 'Proj. Index Group'


--  update static_data_value set  code='Proj Index Group' , [description] ='Proj Index Group' where code='Proj. Index Group' and 
  
--  select * from static_data_value where type_id=5500	  and code like 'Pro%'

-- delete gmd FROM   generic_mapping_definition gmd
--	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmh.mapping_table_id where gmh.mapping_name in 
--(	'DE Final Limit Deal','DE Power Limit Deal','UK Probable Limit Deals','UK Final Limit Deal')

--delete 
--dbo.generic_mapping_header where mapping_name in 
--(	'DE Final Limit Deal','DE Power Limit Deal','UK Probable Limit Deals','UK Final Limit Deal')


/* step 1 start*/
IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external

CREATE TABLE #insert_output_sdv_external(value_id INT, [type_id] INT , [type_name] VARCHAR(500))

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Commodity')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Commodity', 'Commodity'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Commodity'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Internal Portfolio')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Internal Portfolio', 'Internal Portfolio'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Internal Portfolio'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Counterparty Group')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Counterparty Group', 'Counterparty Group'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Counterparty Group'
END

 IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Instrument Type')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Instrument Type', 'Instrument Type'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Instrument Type'
END
 IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Proj Index Group')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Proj Index Group', 'Proj Index Group'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Proj Index Group'
END

 IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Transaction Type')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Transaction Type', 'Transaction Type'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Transaction Type'
END



/* step 1 end */

/* step 2 start*/

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Commodity'
   )
BEGIN
    INSERT INTO user_defined_fields_template
      (
        field_name,
        Field_label,
        Field_type,
        data_type,
        is_required,
        sql_string,
        udf_type,
        sequence,
        field_size,
        field_id
      )
    SELECT iose.value_id,
           'Commodity',
           'd',
           'VARCHAR(150)',
           'y',
           'SELECT sc.source_commodity_id, sc.commodity_name FROM source_commodity sc ',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Commodity'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET sql_string =  'SELECT sc.source_commodity_id, sc.commodity_name FROM source_commodity sc ',
		is_required	= 'y'  ,
		Field_type='d'
    WHERE  Field_label = 'Commodity'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Internal Portfolio'
   )
BEGIN
    INSERT INTO user_defined_fields_template
      (
        field_name,
        Field_label,
        Field_type,
        data_type,
        is_required,
        sql_string,
        udf_type,
        sequence,
        field_size,
        field_id
      )
    SELECT iose.value_id,
          'Internal Portfolio',
           'd',
           'VARCHAR(150)',
           'y',
           'SELECT source_book_id, source_book_name FROM source_book where source_system_book_type_value_id=50',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Internal Portfolio'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET sql_string =  'SELECT source_book_id, source_book_name FROM source_book where source_system_book_type_value_id=50',
		is_required	= 'y'
    WHERE  Field_label = 'Internal Portfolio'
END



IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Counterparty Group'
   )
BEGIN
    INSERT INTO user_defined_fields_template
      (
        field_name,
        Field_label,
        Field_type,
        data_type,
        is_required,
        sql_string,
        udf_type,
        sequence,
        field_size,
        field_id
      )
    SELECT iose.value_id,
           'Counterparty Group',
           'd',
           'VARCHAR(150)',
           'y',
           'SELECT source_book_id, source_book_name FROM source_book where source_system_book_type_value_id=51',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Counterparty Group'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET sql_string =  'SELECT source_book_id, source_book_name FROM source_book where source_system_book_type_value_id=51',
		is_required	= 'y'
    WHERE  Field_label = 'Counterparty Group'
END
IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Instrument Type'
   )
BEGIN
    INSERT INTO user_defined_fields_template
      (
        field_name,
        Field_label,
        Field_type,
        data_type,
        is_required,
        sql_string,
        udf_type,
        sequence,
        field_size,
        field_id
      )
    SELECT iose.value_id,
           'Instrument Type',
           'd',
           'VARCHAR(150)',
           'y',
           'SELECT source_book_id, source_book_name FROM source_book where source_system_book_type_value_id=52',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Instrument Type'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET sql_string =  'SELECT source_book_id, source_book_name FROM source_book where source_system_book_type_value_id=52',
		is_required	= 'y'
    WHERE  Field_label = 'Instrument Type'
END

IF NOT EXISTS (
       SELECT *
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Proj Index Group'
   )
BEGIN
    INSERT INTO user_defined_fields_template
      (
        field_name,
        Field_label,
        Field_type,
        data_type,
        is_required,
        sql_string,
        udf_type,
        sequence,
        field_size,
        field_id
      )
    SELECT iose.value_id,
           'Proj Index Group',
           'd',
           'VARCHAR(150)',
           'y',
           'SELECT source_book_id, source_book_name FROM source_book where source_system_book_type_value_id=53',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Proj Index Group'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET sql_string =  'SELECT source_book_id, source_book_name FROM source_book where source_system_book_type_value_id=53',
		is_required	= 'y'
    WHERE  Field_label = 'Proj Index Group'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Transaction Type'
   )
BEGIN
    INSERT INTO user_defined_fields_template
      (
        field_name,
        Field_label,
        Field_type,
        data_type,
        is_required,
        sql_string,
        udf_type,
        sequence,
        field_size,
        field_id
      )

	  
    SELECT iose.value_id,
          'Transaction Type',
           'd',
           'VARCHAR(150)',
           'y',
           'select value_id,code from static_data_value where type_id=400',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Transaction Type'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET sql_string =  'select value_id,code from static_data_value where type_id=400',
		is_required	= 'y'
    WHERE  Field_label = 'Transaction Type'
END

/* end of part 2 */

/* Step3: Insert Generic Mapping Header */



IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'DE Expected to Occur Deal')
BEGIN
	PRINT 'Mapping Table Already Exists:DE Expected to Occur Deal'
END
ELSE 
BEGIN 
	  insert into dbo.generic_mapping_header (mapping_name,total_columns_used)
	values
		
	(	'DE Expected to Occur Deal',5) 
	 
END

IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'UK Probable Limit Deal (Power)')
BEGIN
	PRINT 'Mapping Table Already Exists:UK Probable UK Probable Limit Deal (Power)'
END
ELSE 
BEGIN 
	  insert into dbo.generic_mapping_header (mapping_name,total_columns_used)
	values
	
	 (	'UK Probable Limit Deal (Power)',5)

END

IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'UK Probable Limit Deal (Gas)')
BEGIN
	PRINT 'Mapping Table Already Exists:UK Probable Limit Deal (Gas)'
END
ELSE 
BEGIN 
	  insert into dbo.generic_mapping_header (mapping_name,total_columns_used)
	values
	
	 (	'UK Probable Limit Deal (Gas)',5)

END
IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'UK Probable Limit Deal (Coal)')
BEGIN
	PRINT 'Mapping Table Already Exists:UK Probable Limit Deal (Coal)'
END
ELSE 
BEGIN 
	  insert into dbo.generic_mapping_header (mapping_name,total_columns_used)
	values
	
	 (	'UK Probable Limit Deal (Coal)',5)

END


--select * from dbo.generic_mapping_header

SELECT Commodity=max(case when Field_label='Commodity' then udf_template_id else null end)
	,[Internal Portfolio] =max(case when Field_label='Internal Portfolio' then udf_template_id else null end)
	,[Counterparty Group] =max(case when Field_label='Counterparty Group' then udf_template_id else null end)
	,[Instrument Type] =max(case when Field_label='Instrument Type' then udf_template_id else null end)
	,[Proj. Index Group] =max(case when Field_label='Proj Index Group' then udf_template_id else null end)
	,[Transaction Type] =max(case when Field_label='Transaction Type' then udf_template_id else null end)
into #tmp_udf
FROM user_defined_fields_template 


IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd 
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
           WHERE gmh.mapping_name = 'DE Expected to Occur Deal')
BEGIN
	UPDATE gmd
	SET 
		clm1_label = 'Internal Portfolio',
		clm1_udf_id = udf.[Internal Portfolio]	,
	   	clm2_label = 'Counterparty Group',
		clm2_udf_id = udf.[Counterparty Group]	,
		clm3_label = 'Instrument Type',
		clm3_udf_id = udf.[Instrument Type]	,
		clm4_label = 'Proj Index Group',
		clm4_udf_id = udf.[Proj. Index Group],
		clm5_label = 'Transaction Type',
		clm5_udf_id = udf.[Transaction Type]
		FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
	cross join #tmp_udf udf
	WHERE  gmh.mapping_name = 'DE Expected to Occur Deal'
END
ELSE
BEGIN
	INSERT INTO generic_mapping_definition (
		mapping_table_id,
		clm1_label, 
		clm1_udf_id, 
		clm2_label, 
		clm2_udf_id,
		clm3_label, 
		clm3_udf_id,
		clm4_label, 
		clm4_udf_id,
		clm5_label, 
		clm5_udf_id

	)
	SELECT 
		gmh.mapping_table_id,
		'Internal Portfolio',
		udf.[Internal Portfolio]	,
	   'Counterparty Group',
		 udf.[Counterparty Group]	,
		'Instrument Type',
		udf.[Instrument Type]	,
		'Proj Index Group',
		 udf.[Proj. Index Group],
		'Transaction Type',
		 udf.[Transaction Type]
	FROM generic_mapping_header gmh
	cross join #tmp_udf udf
	WHERE mapping_name = 'DE Expected to Occur Deal'
END


IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd 
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
           WHERE gmh.mapping_name = 'UK Probable Limit Deal (Power)')
BEGIN
	UPDATE gmd
	SET 
		clm1_label = 'Internal Portfolio',
		clm1_udf_id = udf.[Internal Portfolio]	,
	   	clm2_label = 'Counterparty Group',
		clm2_udf_id = udf.[Counterparty Group]	,
		clm3_label = 'Instrument Type',
		clm3_udf_id = udf.[Instrument Type]	,
		clm4_label = 'Proj Index Group',
		clm4_udf_id = udf.[Proj. Index Group]
		,clm5_label = 'Transaction Type',
		clm5_udf_id = udf.[Transaction Type]

	FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
	cross join #tmp_udf udf
	WHERE  gmh.mapping_name = 'UK Probable Limit Deal (Power)'
END
ELSE
BEGIN
	INSERT INTO generic_mapping_definition (
		mapping_table_id,
		clm1_label, 
		clm1_udf_id, 
		clm2_label, 
		clm2_udf_id,
		clm3_label, 
		clm3_udf_id,
		clm4_label, 
		clm4_udf_id
		,clm5_label, 
		clm5_udf_id

	)
	SELECT 
		gmh.mapping_table_id,
		'Internal Portfolio',
		udf.[Internal Portfolio]	,
	   'Counterparty Group',
		 udf.[Counterparty Group]	,
		'Instrument Type',
		udf.[Instrument Type]	,
		'Proj Index Group',
		 udf.[Proj. Index Group]
		 ,'Transaction Type',
		 udf.[Transaction Type]

	FROM generic_mapping_header gmh
	cross join #tmp_udf udf
	WHERE mapping_name = 'UK Probable Limit Deal (Power)'
END	




IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd 
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
           WHERE gmh.mapping_name = 'UK Probable Limit Deal (Gas)')
BEGIN
	UPDATE gmd
	SET 
		clm1_label = 'Internal Portfolio',
		clm1_udf_id = udf.[Internal Portfolio]	,
	   	clm2_label = 'Counterparty Group',
		clm2_udf_id = udf.[Counterparty Group]	,
		clm3_label = 'Instrument Type',
		clm3_udf_id = udf.[Instrument Type]	,
		clm4_label = 'Proj Index Group',
		clm4_udf_id = udf.[Proj. Index Group]
		,clm5_label = 'Transaction Type',
		clm5_udf_id = udf.[Transaction Type]

	FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
	cross join #tmp_udf udf
	WHERE  gmh.mapping_name = 'UK Probable Limit Deal (Gas)'
END
ELSE
BEGIN
	INSERT INTO generic_mapping_definition (
		mapping_table_id,
		clm1_label, 
		clm1_udf_id, 
		clm2_label, 
		clm2_udf_id,
		clm3_label, 
		clm3_udf_id,
		clm4_label, 
		clm4_udf_id
	   	,clm5_label, 
		clm5_udf_id

	)
	SELECT 
		gmh.mapping_table_id,
		'Internal Portfolio',
		udf.[Internal Portfolio]	,
	   'Counterparty Group',
		 udf.[Counterparty Group]	,
		'Instrument Type',
		udf.[Instrument Type]	,
		'Proj Index Group',
		 udf.[Proj. Index Group]
		,'Transaction Type',
		 udf.[Transaction Type]

	FROM generic_mapping_header gmh
	cross join #tmp_udf udf
	WHERE mapping_name = 'UK Probable Limit Deal (Gas)'
END	

IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd 
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
           WHERE gmh.mapping_name = 'UK Probable Limit Deal (Coal)')
BEGIN
	UPDATE gmd
	SET 
		clm1_label = 'Internal Portfolio',
		clm1_udf_id = udf.[Internal Portfolio]	,
	   	clm2_label = 'Counterparty Group',
		clm2_udf_id = udf.[Counterparty Group]	,
		clm3_label = 'Instrument Type',
		clm3_udf_id = udf.[Instrument Type]	,
		clm4_label = 'Proj Index Group',
		clm4_udf_id = udf.[Proj. Index Group]
		,clm5_label = 'Transaction Type',
		clm5_udf_id = udf.[Transaction Type]

	FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
	cross join #tmp_udf udf
	WHERE  gmh.mapping_name = 'UK Probable Limit Deal (Coal)'
END
ELSE
BEGIN
	INSERT INTO generic_mapping_definition (
		mapping_table_id,
		clm1_label, 
		clm1_udf_id, 
		clm2_label, 
		clm2_udf_id,
		clm3_label, 
		clm3_udf_id,
		clm4_label, 
		clm4_udf_id
		,clm5_label, 
		clm5_udf_id
	)
	SELECT 
		gmh.mapping_table_id,
		'Internal Portfolio',
		udf.[Internal Portfolio]	,
	   'Counterparty Group',
		 udf.[Counterparty Group]	,
		'Instrument Type',
		udf.[Instrument Type]	,
		'Proj Index Group',
		 udf.[Proj. Index Group]
	   ,'Transaction Type',
		 udf.[Transaction Type]

	FROM generic_mapping_header gmh
	cross join #tmp_udf udf
	WHERE mapping_name = 'UK Probable Limit Deal (Coal)'
END	


DELETE FROM user_defined_fields_template WHERE field_label = 'internal portofolio'
DELETE FROM static_data_value WHERE code = 'internal portofolio' AND type_id = 5500
  drop table #tmp_udf