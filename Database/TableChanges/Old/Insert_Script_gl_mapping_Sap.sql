IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external
    
CREATE TABLE #insert_output_sdv_external(value_id INT, [type_id] INT , [type_name] VARCHAR(500))

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Process')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Process', 'Process'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Process'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Inbound Outbound')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Inbound Outbound', 'Inbound Outbound'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Inbound Outbound'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Country')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Country', 'Country'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Country'
END


IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Counterparty')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Counterparty', 'Counterparty'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Counterparty'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Product group')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Product group', 'Product group'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Product group'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Products')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Products', 'Products'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Products'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Current Year General Ledger')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Current Year General Ledger', 'Current Year General Ledger'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Current Year General Ledger'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Current Year Cost Center')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Current Year Cost Center', 'Current Year Cost Center'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Current Year Cost Center'
END


IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Current Year Profit Center')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Current Year Profit Center', 'Current Year Profit Center'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Current Year Profit Center'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Last Year General Ledger')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Last Year General Ledger', 'Last Year General Ledger'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Last Year General Ledger'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Last Year Cost Center')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Last Year Cost Center', 'Last Year Cost Center'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Last Year Cost Center'
END


IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Last Year Profit Center')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Last Year Profit Center', 'Last Year Profit Center'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Last Year Profit Center'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Process'
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
           'Process',
           'd',
           'VARCHAR(150)',
           'n',
           'Select ''i'' as id,''Invoicing'' as name
			UNION ALL
			Select ''a''  as id,''Accrual''  as name',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Process'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'Select ''i'' as id,''Invoicing'' as name
			UNION ALL
			Select ''a''  as id,''Accrual''  as name'
    WHERE  Field_label = 'Process'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Inbound Outbound'
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
           'Inbound Outbound',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT  ''o'' as ID, ''Outbound'' name 
			UNION ALL 
			SELECT ''s'' as ID, ''Self-Billing'' name
		   ',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Inbound Outbound'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'SELECT  ''o'' as ID, ''Outbound'' name 
							UNION ALL 
							SELECT ''s'' as ID, ''Self-Billing'' name'
    WHERE  Field_label = 'Inbound Outbound'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Country'
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
           'Country',
           'd',
           'VARCHAR(150)',
           'n',
           'Select value_id,code FROM static_Data_value where type_id = 11150',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Country'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'Select  value_id,code FROM static_Data_value where type_id = 11150'
    WHERE  Field_label = 'Country'
END



IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Counterparty'
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
           'Counterparty',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT source_Counterparty_id, Counterparty_id FROM source_Counterparty',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Counterparty'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'SELECT source_Counterparty_id, Counterparty_id FROM source_Counterparty'
    WHERE  Field_label = 'Counterparty'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Product Group'
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
           'Product Group',
           'd',
           'VARCHAR(150)',
           'n',
           'Select value_id,code FROM static_data_value where type_id  =27000',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Product Group'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'Select value_id,code FROM static_data_value where type_id  =27000'
    WHERE  Field_label = 'Product Group'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Products'
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
           'Products',
           'd',
           'VARCHAR(150)',
           'n',
           'Select value_id,code FROM static_data_value where type_id  =10019',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Products'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'Select value_id,code FROM static_data_value where type_id  =10019'
    WHERE  Field_label = 'Products'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Current Year General Ledger'
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
           'Current Year General Ledger',
           'd',
           'VARCHAR(150)',
           'n',
           'Select value_id,code FROM static_data_value where type_id  =29800',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Current Year General Ledger'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'Select value_id,code FROM static_data_value where type_id  =29800'
    WHERE  Field_label = 'Current Year General Ledger'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Current Year Cost Center'
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
           'Current Year Cost Center',
           'd',
           'VARCHAR(150)',
           'n',
           'Select value_id,code FROM static_data_value where type_id  =10005',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Current Year Cost Center'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'Select value_id,code FROM static_data_value where type_id  =10005'
    WHERE  Field_label = 'Current Year Cost Center'
END


IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Current Year Profit Center'
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
           'Current Year Profit Center',
           'd',
           'VARCHAR(150)',
           'n',
           'Select value_id,code FROM static_data_value where type_id  =29900',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Current Year Profit Center'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'Select value_id,code FROM static_data_value where type_id  =29900'
    WHERE  Field_label = 'Current Year Profit Center'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Last Year General Ledger'
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
           'Last Year General Ledger',
           'd',
           'VARCHAR(150)',
           'n',
           'Select value_id,code FROM static_data_value where type_id  =29800',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Last Year General Ledger'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'Select value_id,code FROM static_data_value where type_id  =29800'
    WHERE  Field_label = 'Last Year General Ledger'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Last Year Cost Center'
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
           'Last Year Cost Center',
           'd',
           'VARCHAR(150)',
           'n',
           'Select value_id,code FROM static_data_value where type_id  =10005',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Last Year Cost Center'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'Select value_id,code FROM static_data_value where type_id  =10005'
    WHERE  Field_label = 'Last Year Cost Center'
END


IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Last Year Profit Center'
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
           'Last Year Profit Center',
           'd',
           'VARCHAR(150)',
           'n',
           'Select value_id,code FROM static_data_value where type_id  =29900',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Last Year Profit Center'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'Select value_id,code FROM static_data_value where type_id  =29900'
    WHERE  Field_label = 'Last Year Profit Center'
END

/* Insert Generic Mapping Header */
IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'SAP GL Mapping')
BEGIN
	PRINT 'Mapping Table Already Exists'
END
ELSE 
BEGIN 
	INSERT INTO generic_mapping_header (
	mapping_name,
	total_columns_used
	) VALUES (
	'SAP GL Mapping',
	12
	)
END

/*Insert into Generic Mapping Defination*/
DECLARE @Process                      INT
,@Inbound_Outbound            INT
,@Country                     INT
,@Counterparty                INT
,@Product_Group               INT
,@Products                    INT
,@Current_Year_General_Ledger INT
,@Current_Year_Cost_Center    INT
,@Current_Year_Profit_Center  INT
,@Last_Year_General_Ledger    INT
,@Last_Year_Cost_Center       INT
,@Last_Year_Profit_Center     INT 


SELECT @Process=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'process'
SELECT @Inbound_Outbound=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Inbound Outbound'
SELECT @Country=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Country'
SELECT @Counterparty=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Counterparty'

SELECT @Product_Group=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'product group'
SELECT @Products=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'products'
SELECT @Current_Year_General_Ledger=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Current Year General Ledger'
SELECT @current_year_cost_center= udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Current Year Cost Center'
SELECT @Current_Year_Profit_Center=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Current Year Profit Center'
SELECT @Last_Year_General_Ledger=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Last Year General Ledger'
SELECT @Last_Year_Cost_Center=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Last Year Cost Center'
SELECT @Last_Year_Profit_Center=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Last Year Profit Center'




IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd 
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
           WHERE gmh.mapping_name = 'SAP GL Mapping')
BEGIN
	UPDATE gmd
	SET 
		clm1_label= 'Process',
		 clm1_udf_id = @Process,
		clm2_label = 'Inbound Outbound', 
		clm2_udf_id =@Inbound_Outbound  ,
		clm3_label = 'Country',
		 clm3_udf_id = @country,
		clm4_label ='Counterparty', 
		clm4_udf_id = @country,
		clm5_label='Product Group', 
		clm5_udf_id = @product_group,
		clm6_label = 'Products' ,
		 clm6_udf_id = @products,
		clm7_label = 'Current Year General Ledger',
		 clm7_udf_id = @Current_Year_General_Ledger ,
		clm8_label ='Current Year Cost Center', 
		clm8_udf_id= @Current_Year_Cost_Center,
		clm9_label = 'Current Year Profit Center',
		 clm9_udf_id = @Current_Year_Profit_Center,
		clm10_label ='Last Year General Ledger',
		 clm10_udf_id =@Last_Year_General_Ledger ,
		clm11_label = 'Last Year Cost Center',
		 clm11_udf_id =@Last_Year_Cost_Center,
		clm12_label= 'Last Year Profit Center',
		clm12_udf_id = @Last_Year_Profit_Center 
		FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
	WHERE  gmh.mapping_name = 'SAP GL Mapping'
END
ELSE
BEGIN
	INSERT INTO generic_mapping_definition (
		mapping_table_id,
		clm1_label, clm1_udf_id,
		clm2_label, clm2_udf_id,
		clm3_label, clm3_udf_id,
		clm4_label, clm4_udf_id,
		clm5_label, clm5_udf_id,
		clm6_label, clm6_udf_id,
		clm7_label, clm7_udf_id,
		clm8_label, clm8_udf_id,
		clm9_label, clm9_udf_id,
		clm10_label, clm10_udf_id,
		clm11_label, clm11_udf_id,
		clm12_label, clm12_udf_id
	)
	SELECT 
		mapping_table_id,
		'Process',@Process,
		'Inbound Outbound',@Inbound_Outbound  ,
		'Country',@country,
		'Counterparty', @country,
		'Product Group',@product_group,
		'Products' ,@products,
		'Current Year General Ledger',@Current_Year_General_Ledger ,
		'Current Year Cost Center', @Current_Year_Cost_Center,
		'Current Year Profit Center',@Current_Year_Profit_Center,
		'Last Year General Ledger',@Last_Year_General_Ledger ,
		'Last Year Cost Center',@Last_Year_Cost_Center,
		'Last Year Profit Center',@Last_Year_Profit_Center 
	FROM generic_mapping_header 
	WHERE mapping_name = 'SAP GL Mapping'
END

