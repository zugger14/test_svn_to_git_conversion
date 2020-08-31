IF NOT EXISTS(SELECT 'X' FROM information_schema.columns where table_name = 'delivery_path' and column_name='shipping_counterparty')
ALTER TABLE delivery_path ADD shipping_counterparty INT

IF NOT EXISTS(SELECT 'X' FROM information_schema.columns where table_name = 'delivery_path' and column_name='receiving_counterparty')
ALTER TABLE delivery_path ADD receiving_counterparty INT

