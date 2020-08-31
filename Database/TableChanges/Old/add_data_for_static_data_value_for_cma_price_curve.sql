
--inserting value_id for cma price curve request (4038) and response (4039)

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS ( SELECT * FROM static_data_value WHERE [value_id] = 4038)
BEGIN
		INSERT INTO static_data_value (value_id, [type_id], code, [description])
		VALUES (4038, 4000, 'cma_price_curve_request', 'CMA price curve request value')
ENd

IF NOT EXISTS ( SELECT * FROM static_data_value WHERE [value_id] = 4039)
BEGIN
		INSERT INTO static_data_value (value_id, [type_id], code, [description])
		VALUES (4039, 4000, 'cma_price_curve_response', 'CMA price curve response value')
ENd

SET IDENTITY_INSERT static_data_value OFF