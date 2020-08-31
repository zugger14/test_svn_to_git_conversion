IF NOT EXISTS (SELECT 1 FROM ixp_tables WHERE ixp_tables_name ='ixp_recs_obligation_volumes_import_template')
BEGIN
	INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)
	VALUES ('ixp_recs_obligation_volumes_import_template', 'RECs Obligation Volumes Import', 'i')
END
ELSE
    BEGIN
        PRINT 'RECs Obligation Volumes Import already Exists'
    END

--insert into ixp_columns
DECLARE @ixp_tables_id INT
SELECT @ixp_tables_id = ixp_tables_id
FROM ixp_tables
WHERE ixp_tables_name = 'ixp_recs_obligation_volumes_import_template'

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'state_value_id')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,seq,is_required)
	VALUES (@ixp_tables_id, 'state_value_id', 'NVARCHAR(600)', 1, 10, 1)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'from_year')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,seq,is_required)
	VALUES (@ixp_tables_id, 'from_year', 'NVARCHAR(600)', 1, 20, 1)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'to_year')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,seq,is_required)
	VALUES (@ixp_tables_id, 'to_year', 'NVARCHAR(600)', 1, 30, 1)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'tier_type')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,seq,is_required)
	VALUES (@ixp_tables_id, 'tier_type', 'NVARCHAR(600)', 1, 40, 1)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'min_target')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,seq,is_required)
	VALUES (@ixp_tables_id, 'min_target', 'NVARCHAR(600)', 0, 50, 1)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'min_absolute_target')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,seq,is_required)
	VALUES (@ixp_tables_id, 'min_absolute_target', 'NVARCHAR(600)', 0, 60, 1)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'rec_assignment_priority_group_id')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,seq,is_required)
	VALUES (@ixp_tables_id, 'rec_assignment_priority_group_id', 'NVARCHAR(600)', 0, 70, 0)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'renewable_target')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,seq,is_required)
	VALUES (@ixp_tables_id, 'renewable_target', 'NVARCHAR(600)', 0, 80, 0)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'per_profit_give_back')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,seq,is_required)
	VALUES (@ixp_tables_id, 'per_profit_give_back', 'NVARCHAR(600)', 0, 90, 0)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'requirement_type_id')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,seq,is_required)
	VALUES (@ixp_tables_id, 'requirement_type_id', 'NVARCHAR(600)', 0, 100, 1)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'sub_tier_value_id')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,seq,is_required)
	VALUES (@ixp_tables_id, 'sub_tier_value_id', 'NVARCHAR(600)', 0, 110, 0)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'max_absolute_target')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,seq,is_required)
	VALUES (@ixp_tables_id, 'max_absolute_target', 'NVARCHAR(600)', 0, 120, 0)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'max_target')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,seq,is_required)
	VALUES (@ixp_tables_id, 'max_target', 'NVARCHAR(600)', 0, 130, 0)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'compliance_year')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,seq,is_required)
	VALUES (@ixp_tables_id, 'compliance_year', 'NVARCHAR(600)', 0, 140, 0)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'assignment_type_id')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,seq,is_required)
	VALUES (@ixp_tables_id, 'assignment_type_id', 'NVARCHAR(600)', 0, 150, 0)
END




