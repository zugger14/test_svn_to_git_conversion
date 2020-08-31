/*
* update internal value to 1 (make it internal) for type id 14750 [what if criteria]                                ]
* 07/27/2015
*/
IF EXISTS(SELECT 1 FROM static_data_type sdt WHERE sdt.[type_id] = 14750)
BEGIN
	UPDATE dbo.static_data_type
	SET internal = 1
	WHERE [type_id] = 14750
END 
ELSE
	PRINT 'Type Id: 14750 does not exists.'