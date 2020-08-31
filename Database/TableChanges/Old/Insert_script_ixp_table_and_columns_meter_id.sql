IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_meter_id_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    SELECT 'ixp_meter_id_template'  , 'Meter Definition', 'i' END

INSERT INTO ixp_table_meta_data (ixp_tables_id, table_name)
SELECT it.ixp_tables_id,
       it.ixp_tables_name
FROM   ixp_tables it
LEFT JOIN ixp_table_meta_data itmd ON itmd.ixp_tables_id = it.ixp_tables_id
WHERE itmd.ixp_table_meta_data_table_id IS NULL

-- ixp_meter_id_template starts
DECLARE @ixp_meter_id_template INT	
SELECT @ixp_meter_id_template = it.ixp_tables_id FROM   ixp_tables it WHERE  it.ixp_tables_name = 'ixp_meter_id_template'

--ixp_meter_id_template 
INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
SELECT (
           SELECT it.ixp_tables_id
           FROM   ixp_tables it
           WHERE  it.ixp_tables_name = 'ixp_meter_id_template'
       ) table_id,
       c.name,
       0
FROM   sys.columns c
INNER JOIN sys.objects o ON  c.object_id = o.object_id
LEFT JOIN ixp_columns ic
    ON  ic.ixp_columns_name = c.name
    AND ic.ixp_table_id = (
            SELECT it.ixp_tables_id
            FROM   ixp_tables it
            WHERE  it.ixp_tables_name = 'ixp_meter_id_template'
        )
WHERE  o.[name] = 'meter_id' AND ic.ixp_columns_id IS NULL



    