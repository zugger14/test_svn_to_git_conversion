IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_cum_pnl_series_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    SELECT 'ixp_cum_pnl_series_template'  , 'Cum PNL Series', 'i' END

-- ixp_cum_pnl_series_template starts
DECLARE @ixp_cum_pnl_series_template INT	
SELECT @ixp_cum_pnl_series_template = it.ixp_tables_id FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_cum_pnl_series_template'

--ixp_cum_pnl_series_template 
INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
SELECT (
           SELECT it.ixp_tables_id
           FROM   ixp_tables it
           WHERE  it.ixp_tables_name = 'ixp_cum_pnl_series_template'
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
            WHERE  it.ixp_tables_name = 'ixp_cum_pnl_series_template'
        )
WHERE  o.[name] = 'cum_pnl_series' AND ic.ixp_columns_id IS NULL
    