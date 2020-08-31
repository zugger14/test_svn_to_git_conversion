--   UPDATE user_defined_fields_template
--    SET Field_label = 'Curve'
-- select * from  delete user_defined_fields_template  WHERE  Field_label = 'Commodity'


--    SELECT 1
--       update user_defined_fields_template set Field_label='Curve'   
--       WHERE  Field_label = 'Proj. Index Group'


--  update static_data_value set  code='Curve' , [description] ='Curve' where code='Proj. Index Group' and 
  
--  select * from static_data_value where type_id=5500	  and code like 'Pro%'

--  delete gmd FROM   generic_mapping_definition gmd
--	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmh.mapping_table_id where gmh.mapping_name in 
--(	'DE	Static Limit Deal','DE Own Use Deal','DE Net Physical Retail Sales','Markdown per')

--delete 
--dbo.generic_mapping_header where mapping_name in 
--(	'DE	Static Limit Deal','DE Own Use Deal','DE Net Physical Retail Sales','Markdown per')


/* step 1 start*/
IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external

CREATE TABLE #insert_output_sdv_external(value_id INT, [type_id] INT , [type_name] VARCHAR(500))


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


 IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Curve')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Curve', 'Curve'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Curve'
END

 IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'IncludeExclude')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'IncludeExclude', 'IncludeExclude'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'IncludeExclude'
END



/* step 1 end */

/* step 2 start*/

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
       WHERE  Field_label = 'Curve'
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
           'Curve',
           'd',
           'VARCHAR(150)',
           'y',
           'SELECT source_curve_def_id, curve_name FROM source_price_curve_def',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Curve'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET sql_string =  'SELECT source_curve_def_id, curve_name FROM source_price_curve_def',
		is_required	= 'y'
    WHERE  Field_label = 'Curve'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'IncludeExclude'
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
          'IncludeExclude',
           'd',
           'VARCHAR(150)',
           'y',
           'select 1 id,''Include'' Descp union all select 2 id,''Exclude'' Descp',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'IncludeExclude'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET sql_string =  'select 1 id,''Include'' Descp union all select 2 id,''Exclude'' Descp',
		is_required	= 'y'
    WHERE  Field_label = 'IncludeExclude'
END

/* end of part 2 */

/* Step3: Insert Generic Mapping Header */

IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'DE Net Physical Retail Sales')
BEGIN
	PRINT 'Mapping Table Already Exists'
END
ELSE 
BEGIN 
	  insert into dbo.generic_mapping_header (mapping_name,total_columns_used)
	values ('DE Net Physical Retail Sales',4) 

END



SELECT 
	[Internal Portfolio] =max(case when Field_label='Internal Portfolio' then udf_template_id else null end)
	,[Instrument Type] =max(case when Field_label='Instrument Type' then udf_template_id else null end)
	,[Curve] =max(case when Field_label='Curve' then udf_template_id else null end)
	,[IncludeExclude] =max(case when Field_label='IncludeExclude' then udf_template_id else null end)
into #tmp_udf
FROM user_defined_fields_template 



IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd 
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
           WHERE gmh.mapping_name = 'DE Net Physical Retail Sales')
BEGIN
	UPDATE gmd
	SET 
		clm1_label = 'Internal Portfolio',
		clm1_udf_id = udf.[Internal Portfolio]	,
		clm2_label = 'Instrument Type',
		clm2_udf_id = udf.[Instrument Type]	,
		clm3_label = 'Curve',
		clm3_udf_id = udf.[Curve],
		clm4_label = 'IncludeExclude',
		clm4_udf_id = udf.[IncludeExclude]
		FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
	cross join #tmp_udf udf
	WHERE  gmh.mapping_name = 'DE Net Physical Retail Sales'
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
	)
	SELECT 
		gmh.mapping_table_id,
		'Internal Portfolio',
		udf.[Internal Portfolio]	,
	   'Instrument Type',
		 udf.[Instrument Type]	,
		'Curve',
		 udf.[Curve],
		'IncludeExclude',
		 udf.[IncludeExclude]
	FROM generic_mapping_header gmh
	cross join #tmp_udf udf
	WHERE mapping_name = 'DE Net Physical Retail Sales'
END



















  drop table #tmp_udf