IF COL_LENGTH('source_counterparty', 'counterparty_status') IS NULL
BEGIN
    ALTER TABLE source_counterparty ADD counterparty_status INT NULL
END
ELSE
BEGIN
    PRINT 'counterparty_status Already Exists.'
END
