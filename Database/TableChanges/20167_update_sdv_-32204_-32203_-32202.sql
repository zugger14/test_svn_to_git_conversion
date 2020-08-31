SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE type_id = 32200 AND code = 'Accountant (Payables)')
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-32202, 32200, 'Accountant (Payables)', 'Accountant (Payables)', '', 'farrms_admin', GETDATE())    
END
ELSE 
BEGIN 
	IF EXISTS(SELECT 1 FROM static_data_value WHERE type_id = 32200 AND code = 'Accountant (Payables)' AND value_id <> -32202)
	BEGIN
		DELETE FROM static_data_value    
		WHERE type_id = 32200 AND code = 'Accountant (Payables)' AND value_id <> -32202

		INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
		VALUES (-32202, 32200, 'Accountant (Payables)', 'Accountant (Payables)', '', 'farrms_admin', GETDATE())
	END 
END 
 
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE type_id = 32200 AND code = 'Accountant (Receivables)')
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-32203, 32200, 'Accountant (Receivables)', 'Accountant (Receivables)', '', 'farrms_admin', GETDATE())
END
ELSE 
BEGIN 
	IF EXISTS(SELECT 1 FROM static_data_value WHERE type_id = 32200 AND code = 'Accountant (Receivables)' AND value_id <> -32203)
	BEGIN
		DELETE FROM static_data_value    
		WHERE type_id = 32200 
			AND code = 'Accountant (Receivables)'
			AND value_id <> -32203

		INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
		VALUES (-32203, 32200, 'Accountant (Receivables)', 'Accountant (Receivables)', '', 'farrms_admin', GETDATE())
	END 
END 

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE type_id = 32200 AND code = 'Confirmation')
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-32204, 32200, 'Confirmation', 'Confirmation', '', 'farrms_admin', GETDATE())
END
ELSE 
BEGIN 
	IF EXISTS(SELECT 1 FROM static_data_value WHERE type_id = 32200 AND code = 'Confirmation' AND value_id <> -32204)
	BEGIN
		DELETE FROM static_data_value    
		WHERE type_id = 32200 
			AND code = 'confirmation'
			AND value_id <> -32204

		INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
		VALUES (-32204, 32200, 'Confirmation', 'Confirmation', '', 'farrms_admin', GETDATE())
	END
END 
SET IDENTITY_INSERT static_data_value OFF

