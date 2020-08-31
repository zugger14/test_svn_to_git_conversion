IF EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 20001200)
BEGIN
	UPDATE setup_menu SET window_name = 'windowSetupFees' WHERE function_id = 20001200
END
