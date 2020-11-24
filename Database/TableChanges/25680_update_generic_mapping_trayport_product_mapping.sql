IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external
    
CREATE TABLE #insert_output_sdv_external(value_id INT, [type_id] INT , [type_name] VARCHAR(500))   



IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Source Product')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
	INTO #insert_output_sdv_external
	SELECT '5500', 'Source Product', 'Source Product'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Source Product'
END



IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'TRM Index')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
	INTO #insert_output_sdv_external
	SELECT '5500', 'TRM Index', 'TRM Index'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'TRM Index'
END

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Granularity')
BEGIN
    INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
	INTO #insert_output_sdv_external
	SELECT '5500', 'Granularity', 'Granularity'
END
ELSE
BEGIN
    INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Granularity'
END
SET IDENTITY_INSERT static_data_value OFF  

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'DealTemplate')
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
	INTO #insert_output_sdv_external
    SELECT 5500, -10000315, 'DealTemplate', 'Deal Template', NULL, 'farrms_admin', GETDATE()
    PRINT 'Inserted static data value -10000315 - Deal Template.'
END
ELSE
BEGIN
    INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'DealTemplate'
END

SET IDENTITY_INSERT static_data_value OFF 

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Volume Frequency')
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
	INTO #insert_output_sdv_external
    SELECT 5500, -10000342, 'Volume Frequency', 'Volume Frequency', NULL, 'farrms_admin', GETDATE()
    PRINT 'Inserted static data value -10000342 - Volume Frequency.'
END
ELSE
BEGIN
    INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Volume Frequency'
END 

SET IDENTITY_INSERT static_data_value OFF 

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Multiplier')
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
	INTO #insert_output_sdv_external
    SELECT 5500, -10000343, 'Multiplier', 'Multiplier', NULL, 'farrms_admin', GETDATE()
    PRINT 'Inserted static data value -10000343 - Multiplier.'
END
ELSE
BEGIN
    INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Multiplier'
END

SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'UOM')
BEGIN
    INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
	INTO #insert_output_sdv_external
	SELECT '5500', 'UOM', 'UOM'
END
ELSE
BEGIN
    INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'UOM'
END
SET IDENTITY_INSERT static_data_value OFF 

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Position UOM')
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
	INTO #insert_output_sdv_external
    SELECT 5500, -10000354, 'Position UOM', 'Position UOM', NULL, 'farrms_admin', GETDATE()
    PRINT 'Inserted static data value -10000354 - Position UOM.'
END
ELSE
BEGIN
    INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Position UOM'
END

SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Deal Type')
BEGIN
    INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
	INTO #insert_output_sdv_external
	SELECT '5500', 'Deal Type', 'Deal Type'
END
ELSE
BEGIN
    INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Deal Type'
END
SET IDENTITY_INSERT static_data_value OFF 
           

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Source Product'
   )
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT iose.value_id,
           'Source Product',
           't',
           'VARCHAR(150)',
           'n',
           '',
           'h',
           NULL,
           200,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Source Product'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 't',
           field_size = 200
    WHERE  Field_label = 'Source Product'
END


IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'TRM Index'
   )
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT iose.value_id,
           'TRM Index',
           'd',
           'VARCHAR(150)',
           'n',
           'EXEC spa_source_price_curve_def_maintain ''l'', @is_active = ''y''',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'TRM Index'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'EXEC spa_source_price_curve_def_maintain ''l'', @is_active = ''y'''
    WHERE  Field_label = 'TRM Index'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Granularity'
   )
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT iose.value_id,
           'Granularity',
           'd',
           'int',
           'n',
           'EXEC spa_staticdatavalues @flag = ''h'', @type_id = ''978''',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Granularity'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'EXEC spa_staticdatavalues @flag = ''h'', @type_id = ''978''',
		   data_type = 'int'
    WHERE  Field_label = 'Granularity'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'DealTemplate'
   )
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT iose.value_id,
           'DealTemplate',
           'd',
           'int',
           'n',
           'EXEC spa_getDealTemplate ''s''',
           'o',
           NULL,
           100,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'DealTemplate'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'EXEC spa_getDealTemplate ''s''',
		   data_type = 'int',
		   udf_type = 'o'
    WHERE  Field_label = 'DealTemplate'
END

 
IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Volume Frequency'
   )
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT iose.value_id,
           'Volume Frequency',
           'd',
           'int',
           'n',
           'EXEC  spa_getVolumeFrequency NULL,NULL',
           'o',
           NULL,
           100,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Volume Frequency'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'EXEC  spa_getVolumeFrequency NULL,NULL',
		   data_type = 'int',
		   udf_type = 'o'
    WHERE  Field_label = 'Volume Frequency'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Multiplier'
   )
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT iose.value_id,
           'Multiplier',
           't',
           'numeric(38,20)',
           'n',
           NULL,
           'o',
           NULL,
           100,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Multiplier'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 't',
		   sql_string = NULL,
		   data_type = 'numeric(38,20)',
		   udf_type = 'o'
    WHERE  Field_label = 'Multiplier'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'UOM'
   )
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT iose.value_id,
           'UOM',
           'd',
           'int',
           'n',
           'SELECT source_uom_id, uom_name FROM source_uom',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'UOM'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'SELECT source_uom_id, uom_name FROM source_uom',
		   data_type = 'int'
    WHERE  Field_label = 'UOM'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Position UOM'
   )
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT iose.value_id,
           'UOM',
           'd',
           'int',
           'n',
           'SELECT source_uom_id, uom_name FROM source_uom',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Position UOM'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'SELECT source_uom_id, uom_name FROM source_uom',
		   data_type = 'int'
    WHERE  Field_label = 'Position UOM'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Deal Type'
   )
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT iose.value_id,
           'Deal Type',
           'd',
           'int',
           'n',
           'SELECT source_deal_type_id, deal_type_id FROM source_deal_type WHERE sub_type = ''n''',
           'h',
           NULL,
           100,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Deal Type'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'SELECT source_deal_type_id, deal_type_id FROM source_deal_type WHERE sub_type = ''n''',
		   data_type = 'int',
		   udf_type = 'h'
    WHERE  Field_label = 'Deal Type'
END


IF NOT EXISTS(SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'Trayport product Mapping')
BEGIN 
	INSERT INTO generic_mapping_header(mapping_name, total_columns_used, system_defined)
	VALUES('Trayport product Mapping', 10, 0)
END
ELSE
BEGIN
	UPDATE gmh
	SET mapping_name = 'Trayport product Mapping'
	  , total_columns_used = 10
	  , system_defined = 0
	FROM generic_mapping_header gmh
	WHERE gmh.mapping_name = 'Trayport product Mapping'
END

DECLARE @trayport_mapping_table_id INT
	  , @trayport_source_product INT
	  , @trayport_trm_product INT
	  , @commodity_id INT
	  , @granularity_id INT
	  , @template_id INT
	  , @volume_frequency INT
	  , @multiplier INT
	  , @uom_id INT
	  , @position_uom_id INT
	  , @deal_type_id INT
	

SELECT @trayport_mapping_table_id = mapping_table_id
FROM generic_mapping_header
WHERE mapping_name = 'Trayport product Mapping'

SELECT @trayport_trm_product = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_id = (SELECT field_id FROM user_defined_fields_template WHERE Field_label = 'TRM Index')

SELECT @trayport_source_product = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_id = (SELECT field_id FROM user_defined_fields_template WHERE Field_label = 'Source Product')

SELECT @commodity_id = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_label = 'Commodity'

SELECT @granularity_id = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_label = 'Granularity'

SELECT @template_id = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_label = 'DealTemplate'

SELECT @volume_frequency = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_label = 'Volume Frequency'

SELECT @multiplier = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_label = 'Multiplier'

SELECT @uom_id = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_label = 'UOM'

SELECT @position_uom_id = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_label = 'Position UOM'

SELECT @deal_type_id = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_label = 'Deal Type'


----- needed for text
IF NOT EXISTS (SELECT 1 FROM generic_mapping_definition WHERE mapping_table_id = @trayport_mapping_table_id)
BEGIN
	INSERT INTO generic_mapping_definition(mapping_table_id, clm1_label, clm1_udf_id, clm2_label,clm2_udf_id, clm3_label,clm3_udf_id,clm4_label,clm4_udf_id,clm5_label,clm5_udf_id, clm6_label,clm6_udf_id,clm7_label,clm7_udf_id,clm8_label,clm8_udf_id,clm9_label,clm9_udf_id,clm10_label,clm10_udf_id,unique_columns_index)
	SELECT @trayport_mapping_table_id, 'Source Product', @trayport_source_product, 'TRM Index', @trayport_trm_product,'Commodity',@commodity_id,'Granularity', @granularity_id, 'DealTemplate',@template_id, 'Volume Frequency', @volume_frequency, 'Multiplier', @multiplier, 'UOM', @uom_id, 'Position UOM',@position_uom_id, 'Deal Type', @deal_type_id,  '1,2,4'
END
ELSE
BEGIN
	UPDATE gmd
	SET clm1_label = 'Source Product'
	  , clm1_udf_id = @trayport_source_product
	  , clm2_label = 'TRM Index'
	  , clm2_udf_id = @trayport_trm_product
	  ,clm3_label = 'Commodity'
	 , clm3_udf_id = @commodity_id
	  ,clm4_label = 'Granularity'
	 , clm4_udf_id = @granularity_id
	 ,clm5_label = 'DealTemplate'
	 , clm5_udf_id = @template_id
	 ,clm6_label = 'Volume Frequency'
	 , clm6_udf_id = @volume_frequency
	 ,clm7_label = 'Multiplier'
	 , clm7_udf_id = @multiplier
	 ,clm8_label = 'UOM'
	 , clm8_udf_id = @uom_id
	 , clm9_label = 'Position UOM'
	 , clm9_udf_id = @position_uom_id
	 , clm10_label = 'Deal Type'
	 , clm10_udf_id = @deal_type_id
	 , unique_columns_index = '1,2,4'
	FROM generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh 
		ON gmh.mapping_table_id = gmd.mapping_table_id
	WHERE gmh.mapping_name = 'Trayport product Mapping'
END