IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10104600)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10104600, 'Setup Settlement Netting Group', 'Setup Settlement Netting Group', 10100000, 'windowMaintainNettingGrp')
 	PRINT ' Inserted 10104600 - Setup Settlement Netting Group.'
END
ELSE
BEGIN
	UPDATE application_functions 
	SET func_ref_id = 10100000,
	function_name = 'Setup Settlement Netting Group' ,
	function_desc = 'Setup Settlement Netting Group' 
	WHERE  function_id = 10104600
	PRINT 'Application FunctionID 10104600 - Setup Settlement Netting Group updated.'
END
GO

UPDATE application_functions
SET file_path = '_setup/maintain_settlement_netting_grp/maintain.settlement.netting.grp.php'
WHERE function_id = 10104600
GO

