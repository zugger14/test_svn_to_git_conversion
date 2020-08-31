UPDATE udft 
SET window_id = NULL
FROM user_defined_fields_template udft 
LEFT JOIN application_functions af ON af.function_id = udft.window_id
WHERE window_id is not null and af.file_path IS NULL