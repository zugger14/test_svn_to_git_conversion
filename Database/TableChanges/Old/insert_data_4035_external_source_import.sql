if not exists(select 1 from external_source_import where data_type_id=4035)
	insert into external_source_import(source_system_id,data_type_id) select 2,4035
