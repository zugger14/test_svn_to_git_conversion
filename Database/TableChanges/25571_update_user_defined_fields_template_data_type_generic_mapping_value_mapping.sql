/**
	Update query value for generic mapping ''Value Mapping''
*/
UPDATE user_defined_fields_template
SET data_type = 'NVARCHAR(250)'
WHERE Field_label = 'Value'
	AND udf_type = 'h';
