IF NOT EXISTS(SELECT 'X' FROM information_schema.columns where table_name like 'source_counterparty' and column_name like 'state')
ALTER TABLE source_counterparty ADD  state INT