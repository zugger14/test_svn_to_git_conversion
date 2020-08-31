/*
* update internal value to 1 (make it internal) for type id 11150 [Region]
* 07/27/2015
*/
IF EXISTS(SELECT 1 FROM static_data_type sdt WHERE sdt.[type_id] = 11150)
BEGIN
	UPDATE dbo.static_data_type
	SET internal = 1
	WHERE [type_id] = 11150
END 
ELSE
	PRINT 'Type Id: 11150 does not exists.'