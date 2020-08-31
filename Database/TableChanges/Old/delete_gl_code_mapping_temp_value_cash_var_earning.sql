IF EXISTS(SELECT 'X' FROM gl_code_mapping_temp WHERE gl_account_id IN (139,142) AND account_type_id=150 AND sequence_order=15)
BEGIN
	DELETE FROM gl_code_mapping_temp WHERE gl_account_id IN (139,142) AND account_type_id=150 AND sequence_order=15
END

IF EXISTS(SELECT 'X' FROM gl_code_mapping_temp WHERE gl_account_id IN (140,143) AND account_type_id=151 AND sequence_order=12)
BEGIN
	DELETE FROM gl_code_mapping_temp WHERE gl_account_id IN (140,143) AND account_type_id=151 AND sequence_order=12
END

IF EXISTS(SELECT 'X' FROM gl_code_mapping_temp WHERE gl_account_id IN (141,144) AND account_type_id=152 AND sequence_order=8)
BEGIN
	DELETE FROM gl_code_mapping_temp WHERE gl_account_id IN (141,144) AND account_type_id=152 AND sequence_order=8
END