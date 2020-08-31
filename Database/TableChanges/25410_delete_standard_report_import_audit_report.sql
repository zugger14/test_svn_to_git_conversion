IF EXISTS(SELECT 1 FROM application_ui_template WHERE application_function_id = 10232800)
BEGIN
	EXEC spa_application_ui_template 'd', 10232800
	IF EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10232800)
	BEGIN
		DELETE FROM application_functional_users WHERE function_id = 10232800
		DELETE FROM application_functions WHERE function_id = 10232800
	END
END