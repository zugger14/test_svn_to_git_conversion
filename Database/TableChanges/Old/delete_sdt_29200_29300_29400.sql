IF EXISTS (SELECT 1 FROM static_data_type sdt WHERE sdt.type_id = 29200)
BEGIN
	DELETE FROM static_data_type WHERE type_id IN (29200)	
	PRINT 'Delete static_data_type 29200, Commodity Group 1.'	
END
ELSE
	PRINT 'Data does not exist.'

IF EXISTS (SELECT 1 FROM static_data_type sdt WHERE sdt.type_id = 29300)
BEGIN
	DELETE FROM static_data_type WHERE type_id IN (29300)	
	PRINT 'Delete static_data_type 29300, Commodity Group 3.'	
END
ELSE
	PRINT 'Data does not exist.'

IF EXISTS (SELECT 1 FROM static_data_type sdt WHERE sdt.type_id = 29400)
BEGIN
	DELETE FROM static_data_type WHERE type_id IN (29400)	
	PRINT 'Delete static_data_type 29400, Commodity Group 4.'	
END
ELSE
	PRINT 'Data does not exist.'