/*
* update internal value to 1 (make it internal) for type id 29700 [Market]
* 07/27/2015
*/
IF EXISTS(SELECT 1 FROM static_data_type sdt WHERE sdt.[type_id] = 29700)
BEGIN
	UPDATE dbo.static_data_type
	SET internal = 0
	WHERE [type_id] = 29700
END 
ELSE
	PRINT 'Type Id: 29700 does not exists.'

