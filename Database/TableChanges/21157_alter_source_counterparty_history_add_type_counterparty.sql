IF COL_LENGTH('source_counterparty_history', 'type') IS NULL
BEGIN
    ALTER TABLE source_counterparty_history ADD [type] INT NULL
END
ELSE
BEGIN
    PRINT 'type Already Exists.'
END

IF COL_LENGTH('source_counterparty_history', 'counterparty') IS NULL
BEGIN
    ALTER TABLE source_counterparty_history ADD [counterparty] INT NULL
END
ELSE
BEGIN
    PRINT 'counterparty Already Exists.'
END

