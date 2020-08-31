

UPDATE user_defined_fields_template
SET    Field_type      = 'd',
       sql_string      = 'SELECT  ''i'' as ID, ''Inbound'' name UNION ALL SELECT  ''o'' as ID, ''Outbound'' name UNION ALL  SELECT ''s'' as ID, ''Self-Billing'' name'
WHERE  Field_label     = 'Sub process'



