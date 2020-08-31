IF COL_LENGTH('measurement_process_status', 'subsidiary_entity_id') IS NOT NULL
BEGIN
	ALTER TABLE measurement_process_status ALTER COLUMN [subsidiary_entity_id] VARCHAR(8000)
END

IF COL_LENGTH('measurement_process_status', 'strategy_entity_id') IS NOT NULL
BEGIN
	ALTER TABLE measurement_process_status ALTER COLUMN [strategy_entity_id] VARCHAR(8000)
END

IF COL_LENGTH('measurement_process_status', 'book_entity_id') IS NOT NULL
BEGIN
	ALTER TABLE measurement_process_status ALTER COLUMN [book_entity_id] VARCHAR(8000)
END
