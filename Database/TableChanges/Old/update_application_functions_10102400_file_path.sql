IF EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10102400)
BEGIN
UPDATE application_functions
SET file_path = '_setup/formula_builder/formula.builder.php'
WHERE function_id = 10102400
END

DELETE from setup_menu where function_id = 10105600