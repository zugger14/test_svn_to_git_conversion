/*
Adding netting column in source_counterparty table
*/
IF COL_LENGTH('source_counterparty','netting') IS NULL
BEGIN
    ALTER TABLE source_counterparty ADD netting INT NULL
END
ELSE
PRINT 'Netting column already Exists'

