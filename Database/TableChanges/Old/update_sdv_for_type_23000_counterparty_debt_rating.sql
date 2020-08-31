/*
* update internal value to 0 (make it external) for type id 23000 [Counterparty Debt Rating]
* 8/23/2013
*/
IF EXISTS(SELECT 1 FROM static_data_type sdt WHERE sdt.[type_id] = 23000)
BEGIN
	UPDATE dbo.static_data_type
	SET internal = 0
	WHERE [type_id] = 23000
END 
ELSE
	PRINT 'Type Id: 23000 doesn not exists.'