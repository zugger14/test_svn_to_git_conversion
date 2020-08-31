IF COL_LENGTH('ixp_tables', 'import_export_flag') IS NULL
BEGIN
    ALTER TABLE ixp_tables ADD import_export_flag CHAR(1)
END
GO

IF COL_LENGTH('ixp_rules', 'import_export_flag') IS NULL
BEGIN
    ALTER TABLE ixp_rules ADD import_export_flag CHAR(1)
END
GO

IF COL_LENGTH('ixp_import_data_source', 'delimiter') IS NULL
BEGIN
    ALTER TABLE ixp_import_data_source ADD delimiter VARCHAR(10)
END
GO

IF COL_LENGTH('ixp_import_data_source', 'source_system_id') IS NULL
BEGIN
    ALTER TABLE ixp_import_data_source ADD source_system_id INT
END
GO

IF COL_LENGTH('ixp_import_data_source', 'data_source_alias') IS NULL
BEGIN
    ALTER TABLE ixp_import_data_source ADD data_source_alias VARCHAR(50)
END
GO

IF COL_LENGTH('ixp_import_data_mapping', 'repeat_number') IS NULL
BEGIN
    ALTER TABLE ixp_import_data_mapping ADD repeat_number INT
END
GO

IF COL_LENGTH('ixp_export_tables', 'repeat_number') IS NULL
BEGIN
    ALTER TABLE ixp_export_tables ADD repeat_number INT
END
GO


IF COL_LENGTH('ixp_import_where_clause', 'repeat_number') IS NULL
BEGIN
    ALTER TABLE ixp_import_where_clause ADD repeat_number INT
END
GO

IF COL_LENGTH('ixp_import_data_source', 'is_customized') IS NULL
BEGIN
    ALTER TABLE ixp_import_data_source ADD is_customized CHAR(1)
END
GO

IF COL_LENGTH('ixp_import_data_source', 'customizing_query') IS NULL
BEGIN
    ALTER TABLE ixp_import_data_source ADD customizing_query VARCHAR(MAX)
END
GO

IF COL_LENGTH('ixp_import_data_source', 'is_header_less') IS NULL
BEGIN
    ALTER TABLE ixp_import_data_source ADD is_header_less CHAR(1)
END
GO

IF COL_LENGTH('ixp_import_data_source', 'no_of_columns') IS NULL
BEGIN
    ALTER TABLE ixp_import_data_source ADD no_of_columns INT
END
GO

IF COL_LENGTH('ixp_import_data_source', 'folder_location') IS NULL
BEGIN
    ALTER TABLE ixp_import_data_source ADD folder_location VARCHAR(8000)
END
GO

IF COL_LENGTH('ixp_data_mapping', 'source_column') IS NULL
BEGIN
    ALTER TABLE ixp_data_mapping ADD source_column VARCHAR(500)
END
GO

IF COL_LENGTH('ixp_data_mapping', 'export_folder') IS NULL
BEGIN
    ALTER TABLE ixp_data_mapping ADD export_folder VARCHAR(5000)
END
GO

IF COL_LENGTH('ixp_data_mapping', 'export_delim') IS NULL
BEGIN
    ALTER TABLE ixp_data_mapping ADD export_delim VARCHAR(20)
END
GO

IF COL_LENGTH('ixp_export_relation', 'data_source') IS NULL
BEGIN
    ALTER TABLE ixp_export_relation ADD data_source INT
END
GO

IF COL_LENGTH('ixp_import_data_source', 'custom_import') IS NULL
BEGIN
    ALTER TABLE ixp_import_data_source ADD custom_import CHAR(1)
END
GO

IF COL_LENGTH('ixp_custom_import_mapping', 'default_value') IS NULL
BEGIN
    ALTER TABLE ixp_custom_import_mapping ADD default_value VARCHAR(500)
END
GO

IF COL_LENGTH('ixp_rules', 'ixp_owner') IS NULL
BEGIN
    ALTER TABLE ixp_rules ADD ixp_owner VARCHAR(1000)
END
GO

UPDATE ixp_rules
SET ixp_owner = 'farrms_admin' WHERE ixp_owner IS NULL

IF COL_LENGTH('ixp_rules', 'ixp_category') IS NULL
BEGIN
    ALTER TABLE ixp_rules ADD ixp_category INT
END
GO

IF COL_LENGTH('ixp_rules', 'is_system_import') IS NULL
BEGIN
    ALTER TABLE ixp_rules ADD is_system_import CHAR(1)
END
GO

IF COL_LENGTH('ixp_data_mapping', 'generate_script') IS NULL
BEGIN
    ALTER TABLE ixp_data_mapping ADD generate_script CHAR(1)
END
GO

IF COL_LENGTH('ixp_export_data_source', 'root_table_id') IS NULL
BEGIN
    ALTER TABLE ixp_export_data_source ADD root_table_id INT
END
GO

IF COL_LENGTH('ixp_import_data_mapping', 'dest_column_name') IS NOT NULL
BEGIN
   EXEC SP_RENAME 'ixp_import_data_mapping.[dest_column_name]' , 'dest_column', 'COLUMN'
END
GO

IF COL_LENGTH('ixp_import_data_mapping', 'dest_column') IS NOT NULL
BEGIN
	ALTER TABLE ixp_import_data_mapping ALTER COLUMN dest_column INT
END
GO

IF COL_LENGTH('ixp_data_mapping', 'column_alias') IS NULL
BEGIN
    ALTER TABLE ixp_data_mapping ADD column_alias VARCHAR(500)
END
GO

IF COL_LENGTH('ixp_data_mapping', 'main_table') IS NULL
BEGIN
    ALTER TABLE ixp_data_mapping ADD main_table INT
END
GO

IF COL_LENGTH('ixp_import_data_mapping', 'where_clause') IS NULL
BEGIN
	ALTER TABLE ixp_import_data_mapping ADD where_clause VARCHAR(MAX)
END
GO

IF COL_LENGTH('ixp_import_data_source', 'ssis_package') IS NULL
BEGIN
    ALTER TABLE ixp_import_data_source ADD ssis_package INT
END
GO

IF COL_LENGTH('ixp_import_data_source', 'use_parameter') IS NULL
BEGIN
    ALTER TABLE ixp_import_data_source ADD use_parameter CHAR(1)
END
GO

IF COL_LENGTH('ixp_import_data_source', 'soap_function_id') IS NULL
BEGIN
    ALTER TABLE ixp_import_data_source ADD soap_function_id INT
END
GO