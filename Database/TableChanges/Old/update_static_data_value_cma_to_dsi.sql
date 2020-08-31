--Update CMA to DSI
UPDATE static_data_value
SET	code = 'dsi_price_curve_request',
	[description] = 'DSI price curve request value'
WHERE value_id = 4038

UPDATE static_data_value
SET	code = 'dsi_price_curve_response',
	[description] = 'DSI price curve response value'
WHERE value_id = 4039