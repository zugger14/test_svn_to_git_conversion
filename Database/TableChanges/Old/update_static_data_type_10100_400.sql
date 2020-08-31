
UPDATE sdt SET sdt.internal = 0 
FROM static_data_type sdt
WHERE  
	sdt.type_id = 10100 and type_name = 'Enhance Type'

UPDATE sdt SET sdt.internal = 0 
FROM static_data_type sdt
WHERE 
	 sdt.type_id = 400 and type_name = 'FAS Deal type'

