IF NOT EXISTS (SELECT 1 FROM adiha_grid_definition WHERE grid_name = 'run_deal_settlement_counterparty')
BEGIN
	INSERT INTO adiha_grid_definition (grid_name, fk_table, fk_column, load_sql, grid_label, grid_type, grouping_column)
	VALUES ('run_deal_settlement_counterparty', '', '', 'EXEC spa_getsourcecounterparty @flag=''s''', '', 'g', NULL)
	
	DECLARE @grid_id INT
	SET @grid_id = SCOPE_IDENTITY();
	
	INSERT INTO adiha_grid_columns_definition (grid_id, column_name, column_label, field_type, sql_string, is_editable, is_required, column_order, is_hidden)
	SELECT @grid_id,'source_counterparty_id', 'Counterparty ID','ro', NULL,'y', 'y', 1, 'y' UNION ALL
	SELECT @grid_id,'counterparty', 'Counterparty','ro', NULL,'y', 'y', 2, 'n' 
END
ELSE 
BEGIN
	PRINT 'Data already exists.'
END	


IF NOT EXISTS (SELECT 1 FROM adiha_grid_definition WHERE grid_name = 'run_deal_settlement_contract')
BEGIN
	INSERT INTO adiha_grid_definition (grid_name, fk_table, fk_column, load_sql, grid_label, grid_type, grouping_column)
	VALUES ('run_deal_settlement_contract', '', '', 'EXEC spa_source_contract_detail @flag=''e''', '', 'g', NULL)
	
	DECLARE @grid_id_contract INT
	SET @grid_id_contract = SCOPE_IDENTITY();
	
	INSERT INTO adiha_grid_columns_definition (grid_id, column_name, column_label, field_type, sql_string, is_editable, is_required, column_order, is_hidden)
	SELECT @grid_id_contract, 'contract_id', 'ID','ro', NULL,'y', 'y', 1, 'y' UNION ALL
	SELECT @grid_id_contract, 'contract_name', 'Contract','ro', NULL,'y', 'y', 2, 'n' UNION ALL
	SELECT @grid_id_contract, 'contract_desc', 'Description','ro', NULL,'y', 'y', 3, 'y' UNION ALL
	SELECT @grid_id_contract, 'source_system_name', 'System','ro', NULL,'y', 'y', 4, 'y' UNION ALL
	SELECT @grid_id_contract, 'source_contract_id', 'Source ID','ro', NULL,'y', 'y', 5, 'y' UNION ALL
	SELECT @grid_id_contract, 'create_ts', 'Created Date','ro', NULL,'y', 'y', 6, 'y' UNION ALL
	SELECT @grid_id_contract, 'create_user', 'Created User','ro', NULL,'y', 'y', 7, 'y' UNION ALL
	SELECT @grid_id_contract, 'update_user', 'Updated User','ro', NULL,'y', 'y', 8, 'y' UNION ALL
	SELECT @grid_id_contract, 'update_ts', 'Updated Date','ro', NULL,'y', 'y', 9, 'y'
END
ELSE 
BEGIN
	PRINT 'Data already exists.'
END	

IF NOT EXISTS (SELECT 1 FROM adiha_grid_definition WHERE grid_name = 'deal_search')
BEGIN
	INSERT INTO adiha_grid_definition (grid_name, fk_table, fk_column, load_sql, grid_label, grid_type, grouping_column)
	VALUES ('deal_search', '', '', 'EXEC spa_search_engine ''s'', ''NULL'', ''''''master_deal_view'''''', NULL, NULL, ''d'', NULL', '', 'g', NULL)
	
	DECLARE @grid_id_deal_filter INT
	SET @grid_id_deal_filter = SCOPE_IDENTITY();
	
	INSERT INTO adiha_grid_columns_definition (grid_id, column_name, column_label, field_type, sql_string, is_editable, is_required, column_order, is_hidden)
	SELECT @grid_id_deal_filter, 'ProcessTable', 'Process Table','ro', NULL,'y', 'y', 1, 'y' UNION ALL
	SELECT @grid_id_deal_filter, 'Deal ID', 'Deal ID','ro', NULL,'y', 'y', 2, 'n' UNION ALL
	SELECT @grid_id_deal_filter, 'Details', 'Details','ro', NULL,'y', 'y', 3, 'n'
END
ELSE 
BEGIN
	PRINT 'Data already exists.'
END	

