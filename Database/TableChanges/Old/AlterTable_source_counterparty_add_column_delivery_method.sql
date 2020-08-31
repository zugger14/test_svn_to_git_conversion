IF COL_LENGTH('source_counterparty', 'delivery_method') IS NULL
BEGIN
    ALTER TABLE source_counterparty ADD delivery_method CHAR(1) NULL
END
GO