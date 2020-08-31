DECLARE @ixp_tables_id INT
SELECT @ixp_tables_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_source_deal_template'
 
-- insert into ixp_columns
IF NOT EXISTS(SELECT * FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name = 'internal_counterparty')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, is_required, seq)
	VALUES
	(@ixp_tables_id,'internal_counterparty',  0, 0, 810)
END
