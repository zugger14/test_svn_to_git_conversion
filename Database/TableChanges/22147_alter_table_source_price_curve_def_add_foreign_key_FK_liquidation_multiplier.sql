IF NOT EXISTS(
	SELECT 1
    FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
    INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
        AND tc.Constraint_name = ccu.Constraint_name
        AND tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
        AND tc.Table_Name = 'source_price_curve_def'
        AND ccu.COLUMN_NAME = 'liquidation_multiplier'
)
BEGIN
	ALTER TABLE [dbo].[source_price_curve_def] WITH NOCHECK ADD CONSTRAINT [FK_liquidation_multiplier] FOREIGN KEY([liquidation_multiplier])
	REFERENCES [dbo].[source_price_curve_def] ([source_curve_def_id])
END

GO