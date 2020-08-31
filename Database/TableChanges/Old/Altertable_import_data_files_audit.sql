IF not EXISTS(SELECT * FROM sys.[columns] WHERE [object_id]=object_id('import_data_files_audit') AND [name]='source_system_id')
	ALTER table import_data_files_audit ADD source_system_id INT
