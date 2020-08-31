IF NOT EXISTS(
	SELECT 1
    FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
    INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
        AND tc.Constraint_name = ccu.Constraint_name
        AND tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
        AND tc.Table_Name = 'regression_rule'
        AND ccu.COLUMN_NAME = 'regression_module_header_id'
)
BEGIN
	ALTER TABLE [dbo].[regression_rule] WITH NOCHECK ADD CONSTRAINT [FK_regression_rule_regression_module_header_id] FOREIGN KEY([regression_module_header_id])
	REFERENCES [dbo].[regression_module_header] ([regression_module_header_id])
END

GO