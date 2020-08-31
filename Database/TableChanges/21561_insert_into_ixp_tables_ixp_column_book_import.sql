IF NOT EXISTS(SELECT 1 FROM ixp_tables WHERE ixp_tables_name = 'ixp_book_template')
BEGIN
		INSERT INTO ixp_tables(ixp_tables_name,ixp_tables_description,import_export_flag)
		VALUES('ixp_book_template','Book','i')

END
ELSE 
	PRINT 'Table already exists'

	
DECLARE @ixp_tables_id INT

SELECT @ixp_tables_id = ixp_tables_id
FROM ixp_tables
WHERE ixp_tables_name = 'ixp_book_template'

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'parent_entity_name')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@ixp_tables_id, 'parent_entity_name', 'VARCHAR(600)', 0)
END
IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'name')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@ixp_tables_id, 'name', 'VARCHAR(600)', 0)
END
IF NOT EXISTS(SELECT * FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name LIKE 'strategy_name')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
	VALUES
	(@ixp_tables_id,'strategy_name', 0 )
END


INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, column_datatype)
SELECT (
           SELECT it.ixp_tables_id
           FROM   ixp_tables it
           WHERE  it.ixp_tables_name = 'ixp_book_template'
       ) table_id,
       c.name,
       0,
	   'VARCHAR(600)'
FROM   sys.columns c
INNER JOIN sys.objects o ON  c.object_id = o.object_id
LEFT JOIN ixp_columns ic
    ON  ic.ixp_columns_name = c.name
    AND ic.ixp_table_id = (
            SELECT it.ixp_tables_id
            FROM   ixp_tables it
            WHERE  it.ixp_tables_name = 'ixp_book_template'
        )
WHERE  o.[name] = 'fas_books' AND ic.ixp_columns_id IS NULL

