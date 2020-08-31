/*
* update internal value to 1 (make it internal) for type id 10097 [Source Book Group1,2,3,4]                                ]
* 07/27/2015
*/
IF EXISTS(SELECT 1 FROM static_data_type sdt WHERE sdt.[type_id] in (31000,31100,31200,31300))
BEGIN
	UPDATE dbo.static_data_type
	SET internal = 1
	WHERE [type_id] in (31000,31100,31200,31300)
END 
ELSE
	PRINT 'Type Id: 31000,31100,31200,31300 does not exists.'