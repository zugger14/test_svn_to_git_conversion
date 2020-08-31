INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
SELECT (
           SELECT it.ixp_tables_id
           FROM   ixp_tables it
           WHERE  it.ixp_tables_name = 'ixp_contract_template'
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
            WHERE  it.ixp_tables_name = 'ixp_contract_template'
        )
WHERE  o.[name] = 'contract_group' AND ic.ixp_columns_id IS NULL