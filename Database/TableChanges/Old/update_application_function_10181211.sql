IF EXISTS(SELECT 'x' FROM application_functions WHERE function_id = 10181211)
UPDATE application_functions 
	 SET function_name = 'Maintain VaR Measurement Criteria Book IU',
		function_desc = 'Maintain VaR Measurement Criteria Book IU',
		func_ref_id = 10181200,
		function_call = 'VaRCriteriaBookIU'
	WHERE [function_id] = 10181211
PRINT 'Updated Application Function '
