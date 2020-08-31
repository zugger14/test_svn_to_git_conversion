IF NOT EXISTS (
	SELECT 1
	FROM sys.all_columns c
	JOIN sys.tables t ON t.object_id = c.object_id
	JOIN sys.schemas s ON s.schema_id = t.schema_id
	JOIN sys.default_constraints d ON c.default_object_id = d.object_id
	WHERE t.name = 'Import_Transactions_Log'
		AND c.name = 'create_ts'
)
BEGIN
	ALTER TABLE Import_Transactions_Log ADD CONSTRAINT DF_create_ts_Import_Transactions_Log DEFAULT GETDATE() FOR create_ts;
END

IF NOT EXISTS (
	SELECT 1
	FROM sys.all_columns c
	JOIN sys.tables t ON t.object_id = c.object_id
	JOIN sys.schemas s ON s.schema_id = t.schema_id
	JOIN sys.default_constraints d ON c.default_object_id = d.object_id
	WHERE t.name = 'inventory_accounting_log'
		AND c.name = 'create_ts'
)
BEGIN
	ALTER TABLE inventory_accounting_log ADD CONSTRAINT DF_create_ts_inventory_accounting_log DEFAULT GETDATE() FOR create_ts;
END

IF NOT EXISTS (
	SELECT 1
	FROM sys.all_columns c
	JOIN sys.tables t ON t.object_id = c.object_id
	JOIN sys.schemas s ON s.schema_id = t.schema_id
	JOIN sys.default_constraints d ON c.default_object_id = d.object_id
	WHERE t.name = 'process_settlement_invoice_log'
		AND c.name = 'create_ts'
)
BEGIN
	ALTER TABLE process_settlement_invoice_log ADD CONSTRAINT DF_create_ts_process_settlement_invoice_log DEFAULT GETDATE() FOR create_ts;
END

IF NOT EXISTS (
	SELECT 1
	FROM sys.all_columns c
	JOIN sys.tables t ON t.object_id = c.object_id
	JOIN sys.schemas s ON s.schema_id = t.schema_id
	JOIN sys.default_constraints d ON c.default_object_id = d.object_id
	WHERE t.name = 'source_system_data_import_status_detail'
		AND c.name = 'create_ts'
)
BEGIN
	ALTER TABLE source_system_data_import_status_detail ADD CONSTRAINT DF_create_ts_source_system_data_import_status_detail DEFAULT GETDATE() FOR create_ts;
END

IF NOT EXISTS (
	SELECT 1
	FROM sys.all_columns c
	JOIN sys.tables t ON t.object_id = c.object_id
	JOIN sys.schemas s ON s.schema_id = t.schema_id
	JOIN sys.default_constraints d ON c.default_object_id = d.object_id
	WHERE t.name = 'source_system_data_import_status_vol_detail'
		AND c.name = 'create_ts'
)
BEGIN
	ALTER TABLE source_system_data_import_status_vol_detail ADD CONSTRAINT DF_create_ts_source_system_data_import_status_vol_detail DEFAULT GETDATE() FOR create_ts;
END

IF NOT EXISTS (
	SELECT 1
	FROM sys.all_columns c
	JOIN sys.tables t ON t.object_id = c.object_id
	JOIN sys.schemas s ON s.schema_id = t.schema_id
	JOIN sys.default_constraints d ON c.default_object_id = d.object_id
	WHERE t.name = 'trm_sap_status_log_header'
		AND c.name = 'create_ts'
)
BEGIN
	ALTER TABLE trm_sap_status_log_header ADD CONSTRAINT DF_create_ts_trm_sap_status_log_header DEFAULT GETDATE() FOR create_ts;
END