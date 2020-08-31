IF NOT EXISTS (SELECT 1 FROM ixp_tables WHERE ixp_tables_name = 'ixp_recovery_rate')
BEGIN
	INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description)
	VALUES('ixp_recovery_rate', 'Recovery Rate')
END

INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
SELECT (
           SELECT it.ixp_tables_id
           FROM   ixp_tables it
           WHERE  it.ixp_tables_name = 'ixp_recovery_rate'
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
            WHERE  it.ixp_tables_name = 'ixp_recovery_rate'
        )
WHERE o.[name] = 'default_recovery_rate' AND ic.ixp_columns_id IS NULL AND c.name NOT IN ('id' ,'create_user' ,'create_ts' ,'update_user' ,'update_ts')