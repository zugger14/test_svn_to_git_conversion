IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'source_counterparty' AND COLUMN_NAME = 'city')
BEGIN
	ALTER TABLE source_counterparty ADD city varchar(50)
END

IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'source_counterparty' AND COLUMN_NAME = 'state')
BEGIN
	ALTER TABLE source_counterparty ADD state int
END

IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'source_counterparty' AND COLUMN_NAME = 'zip')
BEGIN
	ALTER TABLE source_counterparty ADD zip varchar(50)
END
