DECLARE @ixp_clr_functions_id INT

SELECT @ixp_clr_functions_id = ixp_clr_functions_id 
FROM ixp_clr_functions 
WHERE method_name  = 'LocusEnergyMntlyVolsImporter'

UPDATE ixp_parameters SET field_type = 'dyn_calendar' WHERE parameter_name IN ('PS_DateStart', 'PS_DateEnd') AND clr_function_id = @ixp_clr_functions_id

