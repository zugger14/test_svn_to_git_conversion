IF NOT EXISTS( SELECT 1 FROM sys.tables t INNER JOIN sys.columns c on t.object_id = c.object_id where t.name = 'ixp_columns' and c.name = 'seq')
BEGIN
	ALTER TABLE ixp_columns
	ADD seq INT
END
ELSE 
	PRINT 'Column SEQ already exists in ixp_columns table'
/*
DECLARE @column_seq INT 
SELECT @column_seq= count(seq) FROM ixp_columns where seq is null
IF @column_seq>50 
BEGIN 
	UPDATE c SET c.seq = b.row_id
	FROM ixp_columns c 
	INNER JOIN (SELECT row_number() over (PARTITION BY ixp_table_id order by is_major desc,ixp_columns_id asc) row_id,* FROM ixp_columns a) b 
	ON b.ixp_columns_id = c.ixp_columns_id
	AND b.ixp_table_id = c.ixp_table_id
END
*/
