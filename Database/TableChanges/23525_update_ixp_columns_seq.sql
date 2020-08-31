-- Correlation
DECLARE @ixp_table_id INT
SELECT @ixp_table_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_curve_correlation_template'

-- Date
UPDATE ic
SET datatype = '[datetime]'
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	  'as_of_date'
	 ,'term1'
	 ,'term2'
)

UPDATE ixp_columns SET seq = 10 WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'as_of_date'
UPDATE ixp_columns SET seq = 20 WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'curve_id_from'
UPDATE ixp_columns SET seq = 30 WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'curve_id_to'
UPDATE ixp_columns SET seq = 40 WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'term1'
UPDATE ixp_columns SET seq = 50 WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'term2'
UPDATE ixp_columns SET seq = 60 WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'curve_source_value_id'
UPDATE ixp_columns SET seq = 70 WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'value'

-- Storage Asset Detail
SET @ixp_table_id = NULL
SELECT @ixp_table_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_default_probability_template'

-- Date
UPDATE ic
SET datatype = '[datetime]'
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	  'effective_date'
)

-- Contract Charge Type Value
SET @ixp_table_id = NULL
SELECT @ixp_table_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_calc_invoice_volume_variance'

UPDATE ixp_columns SET seq = 10 WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'as_of_date'
UPDATE ixp_columns SET seq = 20 WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'counterparty_id'
UPDATE ixp_columns SET seq = 30 WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'contract_id'
UPDATE ixp_columns SET seq = 40 WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'prod_date'
UPDATE ixp_columns SET seq = 50 WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'prod_date_to'
UPDATE ixp_columns SET seq = 60 WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'invoice_line_item_id'
UPDATE ixp_columns SET seq = 70 WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'Value'
UPDATE ixp_columns SET seq = 80 WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'Volume'
UPDATE ixp_columns SET seq = 90 WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'uom_id'
UPDATE ixp_columns SET seq = 100 WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'payment_date'
UPDATE ixp_columns SET seq = 110 WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'price'
UPDATE ixp_columns SET seq = 120 WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'buy_sell'

-- Storage Contract Ratchets
SET @ixp_table_id = NULL
SELECT @ixp_table_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_storage_ratchet'

-- required
UPDATE ic
SET is_required = 1
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	  'general_assest_id'
)

-- Date
UPDATE ic
SET datatype = '[datetime]'
FROM ixp_columns ic
WHERE ixp_table_id = @ixp_table_id
  AND ixp_columns_name IN (
	 'term_from'
	,'term_to'
)

UPDATE ixp_columns SET seq = 10 WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'general_assest_id'
UPDATE ixp_columns SET seq = 20 WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'term_from'
UPDATE ixp_columns SET seq = 30 WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'term_to'
UPDATE ixp_columns SET seq = 40 WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'inventory_level_from'
UPDATE ixp_columns SET seq = 50 WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'inventory_level_to'
UPDATE ixp_columns SET seq = 60 WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'gas_in_storage_perc_from'
UPDATE ixp_columns SET seq = 70 WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'gas_in_storage_perc_to'
UPDATE ixp_columns SET seq = 80 WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'type'
UPDATE ixp_columns SET seq = 90 WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'perc_of_contracted_storage_space'
UPDATE ixp_columns SET seq = 100 WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'fixed_value'
