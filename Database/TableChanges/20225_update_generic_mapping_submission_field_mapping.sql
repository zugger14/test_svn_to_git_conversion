
DECLARE @contract INT
DECLARE @book INT 
DECLARE @deal_type INT 
DECLARE @deal_sub_type INT 
DECLARE @commodity INT 
DECLARE @template INT 
DECLARE @confimation_status INT 
DECLARE @deal_status INT 
DECLARE @submission_type INT 

SELECT @contract = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Contract'
SELECT @book = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Book'
SELECT @deal_type = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Deal Type'
SELECT @deal_sub_type = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Deal Sub Type'
SELECT @commodity = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Commodity'
SELECT @template = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Template'
SELECT @confimation_status = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Confirmation Status'
SELECT @deal_status = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Deal Status'
SELECT @submission_type = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Submission Type'

UPDATE gmd
SET    clm1_label       = 'Contract',
       clm1_udf_id      = @contract,
       clm2_label       = 'Book',
       clm2_udf_id      = @book,
       clm3_label       = 'Deal Type',
       clm3_udf_id      = @deal_type,
       clm4_label       = 'Deal Sub Type',
       clm4_udf_id      = @deal_sub_type,
       clm5_label       = 'Commodity',
       clm5_udf_id      = @commodity,
       clm6_label       = 'Template',
       clm6_udf_id      = @template,
       clm7_label       = 'Confirmation Status',
       clm7_udf_id      = @confimation_status,
       clm8_label       = 'Deal Status',
       clm8_udf_id      = @deal_status,
       clm9_label       = 'Submission Type',
       clm9_udf_id      = @submission_type,
       clm10_label      = NULL,
       clm10_udf_id     = NULL
FROM   generic_mapping_definition gmd
       INNER JOIN generic_mapping_header gmh
            ON  gmh.mapping_table_id = gmd.mapping_table_id
WHERE  gmh.mapping_name = 'Submission Field Mapping'


UPDATE gmv
SET    clm1_value      = clm2_value,
       clm2_value      = clm3_value,
       clm3_value      = clm4_value,
       clm4_value      = clm5_value,
       clm5_value      = clm6_value,
       clm6_value      = clm7_value,
       clm7_value      = clm8_value,
       clm8_value      = clm9_value,
       clm9_value      = clm10_value,
       clm10_value     = NULL
FROM   generic_mapping_values gmv
       INNER JOIN generic_mapping_header gmh
            ON  gmh.mapping_table_id = gmv.mapping_table_id
WHERE  gmh.mapping_name = 'Submission Field Mapping'


           
          