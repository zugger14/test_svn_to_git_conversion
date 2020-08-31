IF COL_LENGTH('source_counterparty', 'analyst') IS NULL
BEGIN
    ALTER TABLE source_counterparty ADD analyst VARCHAR(200) NULL
END
ELSE
	PRINT('Column analyst already exists.')
GO