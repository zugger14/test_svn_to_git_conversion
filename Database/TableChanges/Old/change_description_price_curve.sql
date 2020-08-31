IF EXISTS(SELECT 1 FROM static_data_value sdv WHERE sdv.value_id = 2175)
BEGIN
	UPDATE static_data_value
	SET
		[description] = 'Price Curve'
	WHERE value_id = 2175
END