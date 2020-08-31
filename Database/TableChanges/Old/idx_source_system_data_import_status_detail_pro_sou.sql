IF not EXISTS (SELECT name FROM sys.indexes  WHERE name = N'idx_source_system_data_import_status_detail_pro_sou')
	create index idx_source_system_data_import_status_detail_pro_sou on source_system_data_import_status_detail(process_id,source)

