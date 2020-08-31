/*Insert Generic Mapping Header */

IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'Density Conversion Mapping')
BEGIN
	PRINT 'Mapping Table Already Exists'
END
ELSE 
BEGIN 
	INSERT INTO generic_mapping_header (
	mapping_name,
	total_columns_used
	) VALUES (
	'Density Converion Mapping',
	5
	)
END

 /*Insert into Generic Mapping Defination*/
DECLARE @uom_from INT
DECLARE @uom_to INT
DECLARE @density_from INT
DECLARE @density_to INT
DECLARE @uom_conversion INT

SELECT @uom_from = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'UOM From'
SELECT @uom_to = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'UOM To'
SELECT @density_from = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Density From'
SELECT @density_to = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Density To'
SELECT @uom_conversion = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'UOM Conversion'

IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd 
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
           WHERE gmh.mapping_name = 'Density Converion Mapping')
BEGIN
	UPDATE gmd
	SET 
		clm1_label   = 'UOM From',
		clm1_udf_id  = @uom_from,
		clm2_label   = 'UOM To',
		clm2_udf_id  = @uom_to,
		clm3_label   = 'Density From',
		clm3_udf_id  = @density_from,
		clm4_label   = 'Density To',
		clm4_udf_id  = @density_to,
		clm5_label   = 'UOM Conversion',
		clm5_udf_id  = @uom_conversion
		FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
	WHERE  gmh.mapping_name = 'Density Converion Mapping'
END
ELSE
BEGIN
	INSERT INTO generic_mapping_definition (
		mapping_table_id,
		clm1_label, clm1_udf_id,
		clm2_label, clm2_udf_id,
		clm3_label, clm3_udf_id,
		clm4_label, clm4_udf_id,
		clm5_label, clm5_udf_id
	)
	SELECT 
		mapping_table_id,
		'UOM From', @uom_from,
		'UOM To', @uom_to,
		'Density From',@density_from,
		'Density To',@density_to,
		'UOM Conversion',@uom_conversion
	FROM generic_mapping_header 
	WHERE mapping_name = 'Density Converion Mapping'
END