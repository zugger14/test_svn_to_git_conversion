INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
SELECT (
           SELECT it.ixp_tables_id
           FROM   ixp_tables it
           WHERE  it.ixp_tables_name = 'ixp_delivery_path_template'
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
            WHERE  it.ixp_tables_name = 'ixp_delivery_path_template'
        )
WHERE  o.[name] = 'delivery_path' AND ic.ixp_columns_id IS NULL

DECLARE @ixp_delivery_path_template_id INT 

SELECT @ixp_delivery_path_template_id = it.ixp_tables_id
FROM   ixp_tables it
WHERE  it.ixp_tables_name = 'ixp_delivery_path_template'
        
IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'rank' AND ixp_table_id = @ixp_delivery_path_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_delivery_path_template_id, 'rank', 0, NULL END

