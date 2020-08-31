
IF  EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'import_data_files_audit' AND COLUMN_NAME = 'description')
	BEGIN
		alter table import_data_files_audit alter column description varchar(8000)
	END

IF EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'import_data_files_audit' AND COLUMN_NAME = 'imp_file_name')
	BEGIN
		alter table import_data_files_audit alter column imp_file_name varchar(8000)
	END