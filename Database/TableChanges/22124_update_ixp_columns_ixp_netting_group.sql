DECLARE @ixp_table_id INT
SELECT @ixp_table_id = ixp_tables_id from ixp_tables WHERE ixp_tables_name = 'ixp_netting_group'

-- Update Mandatory
UPDATE ic 
SET ic.is_required = 1 
FROM ixp_columns ic 
WHERE ixp_table_id = @ixp_table_id
       AND ic.ixp_columns_name IN (
	     'netting_parent_group_name'
		,'is_active'
		,'netting_group_name'
		,'effective_date'
	)

-- Update Repetition
UPDATE ic 
SET ic.is_major = 1 
FROM ixp_columns ic 
WHERE ixp_table_id = @ixp_table_id 
       AND ic.ixp_columns_name IN (
	     'netting_parent_group_name'
		,'netting_group_name'
	)

-- Update Date
UPDATE ic 
SET ic.datatype = '[datetime]' 
FROM ixp_columns ic 
WHERE ixp_table_id = @ixp_table_id 
       AND ic.ixp_columns_name IN (
	     'effective_date'
		,'end_date'
	)

-- Update sequence
UPDATE ic SET seq = 10 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'netting_parent_group_name'
UPDATE ic SET seq = 20 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'legal_entity'
UPDATE ic SET seq = 30 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'is_active'
UPDATE ic SET seq = 40 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'fas_subsidiary_id'
UPDATE ic SET seq = 50 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'netting_group_name'
UPDATE ic SET seq = 60 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'source_commodity_id'
UPDATE ic SET seq = 70 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'source_deal_type_id'
UPDATE ic SET seq = 80 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'hedge_type_value_id'
UPDATE ic SET seq = 90 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'effective_date'
UPDATE ic SET seq = 100 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'end_date'
UPDATE ic SET seq = 110 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'physical_financial_flag'
UPDATE ic SET seq = 120 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'source_contract_id'
UPDATE ic SET seq = 130 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'source_counterparty_id'
UPDATE ic SET seq = 140 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'gl_number_id_st_asset'
UPDATE ic SET seq = 150 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'gl_number_id_st_liab'
UPDATE ic SET seq = 160 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'gl_number_id_lt_asset'
UPDATE ic SET seq = 170 FROM ixp_columns ic WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'gl_number_id_lt_liab'