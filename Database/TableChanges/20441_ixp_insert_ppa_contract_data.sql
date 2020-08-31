
EXEC spa_ixp_rules @flag =  'd' , @ixp_rules_name = 'PPA Contract Data'
GO

IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_ppa_contract_data')
BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag) 
	SELECT 'ixp_ppa_contract_data'  , 'ppa_contract_data', 'i'
END
DECLARE @ixp_tables_id INT
SELECT @ixp_tables_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_ppa_contract_data'
 
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
(@ixp_tables_id, 'Counterparty', 0 ),
(@ixp_tables_id, 'Contract', 0 ),
(@ixp_tables_id, 'Effective_Date', 0 ),
(@ixp_tables_id, 'Expiration_Date', 0 ),
(@ixp_tables_id, 'Meter', 0 ),
(@ixp_tables_id, 'Generator_Name', 0 ),
(@ixp_tables_id, 'Generator_ID', 0 ),
(@ixp_tables_id, 'Generator_Unit_ID', 0 ),
(@ixp_tables_id, 'Facility_Owner', 0 ),
(@ixp_tables_id, 'Subsidairy', 0 ),
(@ixp_tables_id, 'Strategy', 0 ),
(@ixp_tables_id, 'Book', 0 ),
(@ixp_tables_id, 'Technology', 0 ),
(@ixp_tables_id, 'Env_Product', 0 ),
(@ixp_tables_id, 'Jurisdiction', 0 ),
(@ixp_tables_id, 'First_Gen_Date', 0 )
