--Updating code to insert new internal data with same name in the same type
UPDATE static_data_value SET code = 'Positive Price Commodity Old' WHERE code = 'Positive Price Commodity' AND type_id = 5500
UPDATE static_data_value SET code = 'Negative Price Commodity Old' WHERE code = 'Negative Price Commodity' AND type_id = 5500