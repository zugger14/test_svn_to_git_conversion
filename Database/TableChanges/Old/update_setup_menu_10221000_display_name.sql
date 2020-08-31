IF EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10221000)
BEGIN
UPDATE setup_menu
SET display_name = 'Process Invoice'
WHERE function_id = 10221000
END