IF NOT EXISTS(SELECT 'X' FROM information_schema.columns where table_name = 'source_price_curve_def' and column_name='index_group')
ALTER TABLE source_price_curve_def ADD index_group INT NULL