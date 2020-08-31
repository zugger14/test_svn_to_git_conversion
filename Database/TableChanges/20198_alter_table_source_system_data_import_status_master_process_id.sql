 IF COL_LENGTH('source_system_data_import_status', 'master_process_id') IS NULL
 BEGIN
     ALTER TABLE source_system_data_import_status
	ADD master_process_id VARCHAR(250)
 END
 ELSE 
	PRINT 'Master_process_id ALREADY present'
 GO