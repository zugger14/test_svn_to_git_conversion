IF NOT EXISTS (SELECT 1 FROM ixp_tables WHERE ixp_tables_name ='ixp_transportation_contract')
BEGIN
	INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)
	VALUES ('ixp_transportation_contract', 'Transportation Contract', 'i')
END
ELSE
    BEGIN
        PRINT 'Transportation Contract Import already Exists'
    END

	--insert into ixp_columns
DECLARE @ixp_tables_id INT
SELECT @ixp_tables_id = ixp_tables_id
FROM ixp_tables
WHERE ixp_tables_name = 'ixp_transportation_contract'


IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'contract_name')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,seq,is_required)
	VALUES (@ixp_tables_id, 'contract_name', 'NVARCHAR(600)', 0, 10, 1)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'pipeline_company')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,seq,is_required)
	VALUES (@ixp_tables_id, 'pipeline_company', 'NVARCHAR(600)', 0, 20, 1)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'contract_id')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,seq,is_required)
	VALUES (@ixp_tables_id, 'contract_id', 'NVARCHAR(600)', 0, 190, 1)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'flow_start_date')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,seq,is_required)
	VALUES (@ixp_tables_id, 'flow_start_date', 'NVARCHAR(600)',0, 30, 0)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'flow_end_date')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,seq,is_required)
	VALUES (@ixp_tables_id, 'flow_end_date', 'NVARCHAR(600)', 0, 40,0)
END
IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'rate_schedule')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,seq,is_required)
	VALUES (@ixp_tables_id, 'rate_schedule', 'NVARCHAR(600)', 0, 50,0)
END
IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'mdq')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,seq,is_required)
	VALUES (@ixp_tables_id, 'mdq', 'NVARCHAR(600)', 0, 170, 0)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'type')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,seq,is_required)
	VALUES (@ixp_tables_id, 'type', 'NVARCHAR(600)', 0, 60, 0)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'contract_status')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,seq,is_required)
	VALUES (@ixp_tables_id, 'contract_status', 'NVARCHAR(600)', 0, 70, 0)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'uom')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,seq,is_required)
	VALUES (@ixp_tables_id, 'uom', 'NVARCHAR(600)', 0, 80, 1)
END
IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'commodity')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,seq,is_required)
	VALUES (@ixp_tables_id, 'commodity', 'NVARCHAR(600)', 0, 90, 1)
END


IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'currency')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,seq,is_required)
	VALUES (@ixp_tables_id, 'currency', 'NVARCHAR(600)', 0, 100, 1)
END
IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'block_definition')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,seq,is_required)
	VALUES (@ixp_tables_id, 'block_definition', 'NVARCHAR(600)',0, 110, 0)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'contract_component_template')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,seq,is_required)
	VALUES (@ixp_tables_id, 'contract_component_template', 'NVARCHAR(600)', 0, 120, 0)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'time_zone')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,seq,is_required)
	VALUES (@ixp_tables_id, 'time_zone', 'NVARCHAR(600)', 0, 130, 0)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'capacity_release')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,seq,is_required)
	VALUES (@ixp_tables_id, 'capacity_release', 'NVARCHAR(600)', 0, 140, 0)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'segmentation')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,seq,is_required)
	VALUES (@ixp_tables_id, 'segmentation', 'NVARCHAR(600)', 0, 150, 0)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'active')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,seq,is_required)
	VALUES (@ixp_tables_id, 'active', 'NVARCHAR(600)', 0, 160, 0)
END

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'mdq_effective_date')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major,seq,is_required)
	VALUES (@ixp_tables_id, 'mdq_effective_date', 'NVARCHAR(600)', 0, 180, 0)
END

	--delete from mapping
DELETE idm FROM ixp_import_data_mapping idm 
	INNER JOIN ixp_rules ir ON ir.ixp_rules_id = idm.ixp_rules_id 
	INNER JOIN ixp_columns ic ON ic.ixp_columns_id = idm.dest_column
WHERE ir.ixp_rules_name = 'Transportation Contract'
AND ic.ixp_columns_name IN ('block_definition','time_zone') 

--DECLARE @ixp_table_id INT
--SELECT @ixp_table_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_transportation_contract'

-- Update to non  Mandatory
UPDATE ic 
SET ic.is_required = 0,
datatype = '[datetime]'
FROM ixp_columns ic 
WHERE ixp_table_id = @ixp_tables_id
       AND ic.ixp_columns_name IN (
	     'flow_start_date'
		,'flow_end_date'
	)
--update to non unique
UPDATE ic 
SET ic.is_major = 0
FROM ixp_columns ic 
WHERE ixp_table_id = @ixp_tables_id
       AND ic.ixp_columns_name IN (
	     'contract_name'
	)
	--UPDATE to mandatory and unique
UPDATE ic 
	SET ic.is_major = 1,
		ic.is_required = 1
FROM ixp_columns ic 
WHERE ixp_table_id = @ixp_tables_id
AND ic.ixp_columns_name IN (
'contract_id'
)
--update seq 
UPDATE ic SET seq = 190 FROM ixp_columns ic WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'contract_id'

