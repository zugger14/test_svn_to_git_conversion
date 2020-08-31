
UPDATE sdt SET sdt.internal = 1 
FROM static_data_type sdt
WHERE internal = 0 
	AND sdt.type_id not in 
	(10008,10017,10018, 10019, 10097, 10098, 10100, 11140, 11150, 5500, 14750, 15001, 15100, 23000, 29700)