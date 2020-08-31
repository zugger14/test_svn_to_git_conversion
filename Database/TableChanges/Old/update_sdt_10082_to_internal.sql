/************************************************************
 * update account status, static data type from external to internal.
 * sligal
 * 11/21/2012
 ************************************************************/
IF EXISTS (SELECT 1 FROM static_data_type sdt WHERE sdt.[type_id] = 10082)
BEGIN
	UPDATE static_data_type
	SET    internal = 1
	WHERE  [type_id] = 10082	
END
ELSE
	PRINT 'Type ID 10082 does not exists.'
