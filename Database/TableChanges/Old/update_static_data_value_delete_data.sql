IF EXISTS(SELECT 'X' FROM static_data_value WHERE value_id = 251)
DELETE FROM static_data_value WHERE value_id = 251

IF EXISTS(SELECT 'X' FROM static_data_value WHERE value_id = 253)
DELETE FROM static_data_value WHERE value_id = 253