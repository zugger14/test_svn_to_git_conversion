/*
* update internal value to 1 (make it internal) for type id 10100 [Enhance Type]
* 07/27/2015
*/
IF EXISTS(SELECT 1 FROM static_data_type sdt WHERE sdt.[type_id] = 10100)
BEGIN
	UPDATE dbo.static_data_type
	SET internal = 1
	WHERE [type_id] = 10100
END 
ELSE
	PRINT 'Type Id: 10100 does not exists.'