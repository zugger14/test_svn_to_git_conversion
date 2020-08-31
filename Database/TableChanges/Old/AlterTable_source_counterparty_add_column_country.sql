IF COL_LENGTH('source_counterparty', 'country') IS NULL
BEGIN
    ALTER TABLE source_counterparty ADD country VARCHAR(500)
END
GO

--2 -print
UPDATE source_counterparty SET delivery_method = 2 WHERE cast (delivery_method AS varchar ) ='p'
UPDATE source_counterparty SET delivery_method = NULL WHERE cast (delivery_method AS varchar ) ='u'
UPDATE source_counterparty SET delivery_method = 3 WHERE cast (delivery_method AS varchar ) = 'e'

IF COL_LENGTH('source_counterparty', 'delivery_method') IS NOT NULL
BEGIN
    ALTER TABLE source_counterparty ALTER COLUMN delivery_method INT
END
GO
UPDATE source_counterparty SET delivery_method = 21302 WHERE delivery_method = 2
UPDATE source_counterparty SET delivery_method = 21301 WHERE delivery_method = 3


