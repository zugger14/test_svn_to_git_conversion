IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10163730)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, file_path)
	VALUES (10163730, 'Deal Detail Spilt Volume', 'Deal Detail Spilt Volume', 10163700, 'windowDealDetailSpiltVolume', '_scheduling_delivery/schedule_liquid_hydrocarbon_products/deal.detail.split.volume.php')
 	PRINT ' Inserted 10163730 - Deal Detail Spilt Volume.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10163730 - Deal Detail Spilt Volume already EXISTS.'
END

GO

