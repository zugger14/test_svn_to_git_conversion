
IF  EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'source_counterparty' AND COLUMN_NAME = 'is_jurisdiction')
	BEGIN
		ALTER TABLE source_counterparty drop column is_jurisdiction  
	END

	ALter table source_counterparty ADD is_jurisdiction CHAR(1)
