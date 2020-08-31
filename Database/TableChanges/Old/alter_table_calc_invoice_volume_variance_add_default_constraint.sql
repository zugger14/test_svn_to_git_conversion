IF NOT EXISTS(SELECT 1
                FROM INFORMATION_SCHEMA.COLUMNS
                WHERE TABLE_SCHEMA = 'dbo'
                      AND TABLE_NAME = 'calc_invoice_volume_variance'      --table name
                      AND COLUMN_NAME = 'invoice_status'    --column name where DEFAULT constaint it to be created
                      AND COLUMN_DEFAULT IS NOT NULL)
BEGIN
    ALTER TABLE dbo.calc_invoice_volume_variance
    ADD CONSTRAINT DF_calc_invoice_volume_variance_invoice_status DEFAULT 20709 FOR [invoice_status]
END
