/* step 1 start*/
IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external

CREATE TABLE #insert_output_sdv_external(value_id INT, [type_id] INT , [type_name] VARCHAR(500))


IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Formula Functions')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Formula Functions', 'Formula Functions'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Formula Functions'
END
/* step 1 end */


/* step 2 start*/
IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Formula Functions'
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
           'Formula Functions',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT fe.formula_id, dbo.FNAFormulaFormatMaxString(fe.formula, ''r'') [formula] FROM formula_editor fe LEFT JOIN formula_nested fn ON fe.formula_id = fn.formula_id LEFT JOIN contract_group_detail cgd ON fn.formula_group_id = cgd.formula_id
		  INNER JOIN contract_group cg ON cgd.contract_id = cg.contract_id INNER JOIN static_data_value sdv ON sdv.value_id = cgd.invoice_line_item_id WHERE cgd.formula_id IS NOT NULL 
		  UNION SELECT fe.formula_id, dbo.FNAFormulaFormatMaxString(fe.formula, ''r'') [formula] FROM formula_editor fe LEFT JOIN formula_nested fn ON fe.formula_id = fn.formula_id
		  LEFT JOIN contract_charge_type_detail cctd ON fn.formula_group_id = cctd.formula_id  INNER JOIN contract_charge_type cct ON cct.contract_charge_type_id = cctd.contract_charge_type_id
		  INNER JOIN static_data_value sdv ON sdv.value_id = cctd.invoice_line_item_id  UNION 
		  SELECT fe.formula_id, REPLACE(fe.formula, ''DBO.FNA'', '''') AS [formula] from  formula_editor fe WHERE fe.formula IS NOT NULL',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Formula Functions'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'SELECT fe.formula_id,dbo.FNAFormulaFormatMaxString(fe.formula, ''r'') formula FROM formula_editor fe
INNER JOIN formula_nested fn ON fe.formula_id = fn.formula_id INNER JOIN contract_group_detail cgd ON fn.formula_group_id = cgd.formula_id
INNER JOIN contract_group cg ON cgd.contract_id = cg.contract_id
INNER JOIN static_data_value sdv ON sdv.value_id = cgd.invoice_line_item_id WHERE cgd.formula_id IS NOT NULL
AND formula IS NOT NULL AND formula LIKE ''%[^0-9]%'' AND fe.formula NOT like ''%GetCurveValue(%'''
    WHERE  Field_label = 'Formula Functions'
END

/* step 2 end */


/* step 3 start*/

DECLARE @sub_book INT
DECLARE @formula_functions INT
SELECT @sub_book = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Sub Book'
SELECT @formula_functions = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Formula Functions'


UPDATE gmd
	SET 
		clm10_label = 'Sub Book',
		clm10_udf_id = @sub_book,
		clm11_label = 'Formula Functions',
		clm11_udf_id = @formula_functions
		FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
	WHERE  gmh.mapping_name = 'Imbalance Deal'

/* step 3 end */