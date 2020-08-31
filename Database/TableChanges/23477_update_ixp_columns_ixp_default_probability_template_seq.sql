DECLARE @ixp_table_id INT
SELECT @ixp_table_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_default_probability_template'

UPDATE ixp_columns SET seq = 10 WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'effective_date'
UPDATE ixp_columns SET seq = 20 WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'debt_rating'
UPDATE ixp_columns SET seq = 30 WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'recovery'
UPDATE ixp_columns SET seq = 40 WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'months'
UPDATE ixp_columns SET seq = 50 WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'probability'
UPDATE ixp_columns SET seq = 60 WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'rating_type'








