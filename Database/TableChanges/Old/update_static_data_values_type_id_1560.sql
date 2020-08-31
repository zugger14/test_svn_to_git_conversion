
--SELECT * FROM static_data_value sdv WHERE sdv.[type_id] = 1560

UPDATE static_data_value
SET	
	[description] = 'Normal Distribution'
WHERE value_id = 1562

UPDATE static_data_value
SET	
	[description] = 'Log Normal Distribution'
WHERE value_id = 1563

UPDATE static_data_value
SET	
	[description] = 'Poissions Distribution'
WHERE value_id = 1561

UPDATE static_data_value
SET
	[description] = 'T-Distribution'
WHERE value_id = 1560