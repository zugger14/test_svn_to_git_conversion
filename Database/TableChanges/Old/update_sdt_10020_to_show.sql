
IF EXISTS ( SELECT 1 FROM static_data_type AS sdt WHERE sdt.[type_id] = 10020)
BEGIN
    UPDATE static_data_type SET internal = 0 WHERE  [type_id] = 10020
    PRINT 'Static data shown in front end.'
END
ELSE
    PRINT 'Type Id 10020 not exists in static data type. '
	 
 	
 