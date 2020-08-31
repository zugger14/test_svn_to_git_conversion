
EXEC spa_ixp_rules @flag =  'd' , @ixp_rules_name = 'Implied Volatility Run Param'
GO

IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_implied_volatility_run_param')
BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag) 
	SELECT 'ixp_implied_volatility_run_param'  , 'implied_volatility_run_param', 'i'
END
DECLARE @ixp_tables_id INT
SELECT @ixp_tables_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_implied_volatility_run_param'
 
DELETE FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id
DELETE FROM ixp_table_meta_data where ixp_tables_id = @ixp_tables_id


INSERT INTO ixp_table_meta_data (ixp_tables_id, table_name)
SELECT it.ixp_tables_id,
       it.ixp_tables_name
FROM   ixp_tables it
LEFT JOIN ixp_table_meta_data itmd ON  itmd.ixp_tables_id = it.ixp_tables_id
WHERE  itmd.ixp_table_meta_data_table_id IS NULL


-- ixp_source_counterparty_template 
INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
VALUES
(@ixp_tables_id, 'options', 0 ),
(@ixp_tables_id, 'exercise Type', 0 ),
(@ixp_tables_id, 'commodity', 0 ),
(@ixp_tables_id, 'index', 0 ),
(@ixp_tables_id, 'term', 0 ),
(@ixp_tables_id, 'expiration', 0 ),
(@ixp_tables_id, 'strike', 0 ),
(@ixp_tables_id, 'premium', 0 ),
(@ixp_tables_id, 'seed', 0 )
