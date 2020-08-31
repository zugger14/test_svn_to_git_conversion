IF NOT EXISTS (SELECT 1 FROM gl_code_mapping_temp gcmt WHERE gcmt.column_map_name IN ('gl_number_unhedged_der_st_asset', 'gl_number_unhedged_der_lt_asset', 'gl_number_unhedged_der_st_liab', 'gl_number_unhedged_der_lt_liab'))
BEGIN
	UPDATE gl_code_mapping_temp SET sequence_order = sequence_order + 4 WHERE account_type_id = 150 AND sequence_order > 4
END

IF NOT EXISTS (SELECT 1 FROM gl_code_mapping_temp gcmt WHERE gcmt.account_type_id = 150 AND gcmt.column_map_name = 'gl_number_unhedged_der_st_asset') 
BEGIN
	INSERT INTO gl_code_mapping_temp (gl_account_description,gl_account_value_id,account_type_id,column_map_name,sequence_order) 
	VALUES ('UnHedged ST Asset', NULL, 150, 'gl_number_unhedged_der_st_asset', 5) 
END

IF NOT EXISTS (SELECT 1 FROM gl_code_mapping_temp gcmt WHERE gcmt.account_type_id = 150 AND gcmt.column_map_name = 'gl_number_unhedged_der_lt_asset') 
BEGIN
	INSERT INTO gl_code_mapping_temp (gl_account_description,gl_account_value_id,account_type_id,column_map_name,sequence_order) 
	VALUES ('UnHedged LT Asset', NULL, 150, 'gl_number_unhedged_der_lt_asset', 6) 	
END

IF NOT EXISTS (SELECT 1 FROM gl_code_mapping_temp gcmt WHERE gcmt.account_type_id = 150 AND gcmt.column_map_name = 'gl_number_unhedged_der_st_liab') 
BEGIN
	INSERT INTO gl_code_mapping_temp (gl_account_description,gl_account_value_id,account_type_id,column_map_name,sequence_order) 
	VALUES ('UnHedged ST Liab', NULL, 150, 'gl_number_unhedged_der_st_liab', 7) 	
END
IF NOT EXISTS (SELECT 1 FROM gl_code_mapping_temp gcmt WHERE gcmt.account_type_id = 150 AND gcmt.column_map_name = 'gl_number_unhedged_der_lt_liab') 
BEGIN
	INSERT INTO gl_code_mapping_temp (gl_account_description,gl_account_value_id,account_type_id,column_map_name,sequence_order) 
	VALUES ('UnHedged LT Liab', NULL, 150, 'gl_number_unhedged_der_lt_liab', 8) 	
END

