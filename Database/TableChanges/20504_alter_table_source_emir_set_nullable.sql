IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.columns WHERE column_name = 'other_counterparty_id' AND table_name = 'source_emir')
	ALTER TABLE source_emir ALTER COLUMN other_counterparty_id VARCHAR(50) NULL

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.columns WHERE column_name = 'counterparty_id' AND table_name = 'source_emir')
	ALTER TABLE source_emir ALTER COLUMN counterparty_id VARCHAR(50) NULL

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.columns WHERE column_name = 'counterparty_name' AND table_name = 'source_emir')
	ALTER TABLE source_emir ALTER COLUMN counterparty_name VARCHAR(100) NULL

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.columns WHERE column_name = 'level' AND table_name = 'source_emir')
	ALTER TABLE source_emir ALTER COLUMN LEVEL CHAR(1) NULL

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.columns WHERE column_name = 'action_type' AND table_name = 'source_emir')
	ALTER TABLE source_emir ALTER COLUMN action_type CHAR(1) NULL
