--   UPDATE user_defined_fields_template
--    SET Field_label = 'Proj Index Group'
-- select * from  delete user_defined_fields_template  WHERE  Field_label = 'Commodity'


--    SELECT 1
--       update user_defined_fields_template set Field_label='Proj Index Group'   
--       WHERE  Field_label = 'Proj. Index Group'


--  update static_data_value set  code='Proj Index Group' , [description] ='Proj Index Group' where code='Proj. Index Group' and 
  
--  select * from static_data_value where type_id=5500	  and code like 'Pro%'

--  delete gmd FROM   generic_mapping_definition gmd
--	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmh.mapping_table_id where gmh.mapping_name in 
--(	'DE	Static Limit Deal','DE Own Use Deal','DE Final Limit Deal','Markdown per')

--delete 
--dbo.generic_mapping_header where mapping_name in 
--(	'DE	Static Limit Deal','DE Own Use Deal','DE Final Limit Deal','Markdown per')


/* step 1 start*/
IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external

CREATE TABLE #insert_output_sdv_external(value_id INT, [type_id] INT , [type_name] VARCHAR(500))

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Portfolio Hierarchy')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Portfolio Hierarchy', 'Portfolio Hierarchy'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Portfolio Hierarchy'
END


/* step 1 end */

/* step 2 start*/

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Portfolio Hierarchy'
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
           'Portfolio Hierarchy',
           'd',
           'VARCHAR(150)',
           'y',
           'SELECT entity_id, entity_name FROM portfolio_hierarchy where parent_entity_id is null',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Portfolio Hierarchy'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET sql_string =  'SELECT entity_id, entity_name FROM portfolio_hierarchy where parent_entity_id is null',
		is_required	= 'y'  ,
		Field_type='d'
    WHERE  Field_label = 'Portfolio Hierarchy'
END


/* end of part 2 */

/* Step3: Insert Generic Mapping Header */

IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'UK Participating Subsidiaries')
BEGIN
	PRINT 'Mapping Table Already Exists'
END
ELSE 
BEGIN 
	insert into dbo.generic_mapping_header (mapping_name,total_columns_used)
	values
	('UK Participating Subsidiaries',1)

END




--select * from dbo.generic_mapping_header

SELECT [Portfolio Hierarchy]=max(case when Field_label='Portfolio Hierarchy' then udf_template_id else null end)
into #tmp_udf
FROM user_defined_fields_template 

IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd 
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
           WHERE gmh.mapping_name = 'UK Participating Subsidiaries')
BEGIN
	UPDATE gmd
	SET 
		clm1_label = 'Portfolio Hierarchy',
		clm1_udf_id = udf.[Portfolio Hierarchy]
	FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
	cross join #tmp_udf udf
	WHERE  gmh.mapping_name = 'UK Participating Subsidiaries'
END
ELSE
BEGIN
	INSERT INTO generic_mapping_definition (
		mapping_table_id,
		clm1_label, 
		clm1_udf_id
	)
	SELECT 
		gmh.mapping_table_id,
		'Portfolio Hierarchy',
		 udf.[Portfolio Hierarchy]
	FROM generic_mapping_header gmh
	cross join #tmp_udf udf
	WHERE mapping_name = 'UK Participating Subsidiaries'
END




  drop table #tmp_udf