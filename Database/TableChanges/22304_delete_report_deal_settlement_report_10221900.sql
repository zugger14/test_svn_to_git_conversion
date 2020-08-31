IF EXISTS(SELECT 1 FROM application_ui_template WHERE application_function_id = 10221900)
BEGIN
	EXEC spa_application_ui_template 'd', 10221900
	IF EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10221900)
	BEGIN
		DELETE FROM application_functional_users WHERE function_id = 10221900
		DELETE FROM application_functions WHERE function_id = 10221900
	END
END