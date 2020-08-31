IF EXISTS(SELECT 1 FROM static_data_value WHERE [type_id] = 2200 AND value_id = 2203)
	BEGIN
		UPDATE static_data_value
		SET code = 'SAP Payable ID',
		[description] = 'SAP Payable ID'
		WHERE [type_id] = 2200 AND value_id = 2203
	END
IF EXISTS(SELECT 1 FROM static_data_value WHERE [type_id] = 2200 AND value_id = 2202)
	BEGIN
		UPDATE static_data_value
		SET code = 'SAP Receivable ID',
		[description] = 'SAP Receivable ID'
		WHERE [type_id] = 2200 AND value_id = 2202
	END
IF EXISTS(SELECT 1 FROM static_data_value WHERE [type_id] = 2200 AND value_id = 2200)
	BEGIN
		UPDATE static_data_value
		SET code = 'VAT No',
		[description] = 'VAT No'
		WHERE [type_id] = 2200 AND value_id = 2200
	END