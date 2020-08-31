IF COL_LENGTH('source_counterparty','credit') IS NULL
BEGIN
	ALTER TABLE source_counterparty
	ADD credit VARCHAR(MAX) NULL
END

