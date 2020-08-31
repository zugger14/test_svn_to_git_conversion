IF EXISTS(SELECT 1 FROM setup_menu WHERE window_name in ('windowMaintainContract', 'windowMaintainContractGroup') AND function_id = 10211000)
BEGIN
	UPDATE setup_menu SET function_id = 10211200 WHERE window_name in ('windowMaintainContract', 'windowMaintainContractGroup') AND function_id = 10211000
END
BEGIN
	PRINT 'Searched Data does not EXIST'
END