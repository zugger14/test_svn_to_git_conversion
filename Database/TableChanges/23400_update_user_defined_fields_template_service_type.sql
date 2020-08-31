UPDATE user_defined_fields_template
  SET
  sql_string = 'SELECT 1 ID, 
       ''Unit Contingent'' code 
UNION ALL 
SELECT 2      ID, 
       ''Firm'' code 
UNION ALL 
SELECT 3 ID, 
       ''Forward Transfer'' code 
UNION ALL 
SELECT 4 ID, 
       ''Auto Transfer'' 
UNION ALL 
SELECT 5 ID, 
       ''Externally Managed'''
WHERE Field_label = 'Service Type' AND udf_type = 'h';