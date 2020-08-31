IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_fair_value_reporting_level') 
BEGIN 
	INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    
	SELECT 'ixp_fair_value_reporting_level'  , 'Fair Value Reporting Level', 'i' 
END

-- ixp_fair_value_reporting_level starts
DECLARE @ixp_fair_value_reporting_level INT	
SELECT @ixp_fair_value_reporting_level = it.ixp_tables_id FROM   ixp_tables it WHERE  it.ixp_tables_name = 'ixp_fair_value_reporting_level'

--ixp_fair_value_reporting_level 
INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
SELECT (
           SELECT it.ixp_tables_id
           FROM   ixp_tables it
           WHERE  it.ixp_tables_name = 'ixp_fair_value_reporting_level'
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
            WHERE  it.ixp_tables_name = 'ixp_fair_value_reporting_level'
    )
WHERE  o.[name] = 'fv_report_group_deal' AND ic.ixp_columns_id IS NULL

EXEC ('UPDATE ixp_columns SET ixp_columns_name = ''deal_id'' WHERE ixp_columns_name = ''source_deal_header_id'' AND ixp_table_id = ' + @ixp_fair_value_reporting_level)