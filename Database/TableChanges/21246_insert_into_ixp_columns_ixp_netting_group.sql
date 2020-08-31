DECLARE @table_id INT 

SELECT @table_id = ixp_tables_id
FROM ixp_tables
WHERE ixp_tables_name = 'ixp_netting_group'

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @table_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype)
	VALUES(@table_id, 'netting_group_id', 'VARCHAR(6000)')

	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype)
	VALUES (@table_id, 'netting_parent_group_id', 'VARCHAR(500)')

	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype)
	VALUES(@table_id, 'netting_group_name', 'VARCHAR(600)')

	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype)
	VALUES(@table_id, 'source_commodity_id', 'VARCHAR(600)')

	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype)
	VALUES(@table_id, 'source_deal_type_id', 'VARCHAR(600)')

	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype)
	VALUES(@table_id, 'hedge_type_value_id', 'VARCHAR(600)')

	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype)
	VALUES(@table_id, 'effective_date', 'VARCHAR(600)')

	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype)
	VALUES(@table_id, 'end_date', 'VARCHAR(600)')

	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype)
	VALUES(@table_id, 'physical_financial_flag', 'VARCHAR(600)')

	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype)
	VALUES(@table_id, 'source_contract_id', 'VARCHAR(600)')

	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype)
	VALUES(@table_id, 'netting_parent_group_name', 'VARCHAR(600)')

	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype)
	VALUES(@table_id, 'legal_entity', 'VARCHAR(600)')

	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype)
	VALUES(@table_id, 'is_active', 'VARCHAR(600)')

	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype)
	VALUES(@table_id, 'fas_subsidiary_id', 'VARCHAR(600)')

	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype)
	VALUES(@table_id, 'source_counterparty_id', 'VARCHAR(600)')

	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype)
	VALUES(@table_id, 'gl_number_id_st_asset', 'VARCHAR(600)')

	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype)
	VALUES(@table_id, 'gl_number_id_st_liab', 'VARCHAR(600)')

	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype)
	VALUES(@table_id, 'gl_number_id_lt_asset', 'VARCHAR(600)')

	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype)
	VALUES(@table_id, 'gl_number_id_lt_liab', 'VARCHAR(600)')
END

GO