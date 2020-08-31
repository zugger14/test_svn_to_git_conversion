/*
* update func_ref_id of 'Report Manager View', 'Report Manager View IU' from 'Report Writer' to 'Report Manager'.
* 2013/04/02
* sligal
*/
IF EXISTS (SELECT 1 FROM application_functions WHERE function_id IN (10201633, 10201634))
BEGIN
	UPDATE application_functions
	SET func_ref_id = 10201600
	WHERE function_id IN (10201633, 10201634)
	PRINT 'func_ref_id updated.'
END
ELSE
	PRINT 'Function IDs does not exists'