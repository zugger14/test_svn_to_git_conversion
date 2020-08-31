IF NOT EXISTS(
	SELECT 1
    FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
    INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
        AND tc.Constraint_name = ccu.Constraint_name
        AND tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
        AND tc.Table_Name = 'matching_detail'
        AND ccu.COLUMN_NAME = 'source_deal_header_id'
)
BEGIN
	ALTER TABLE [dbo].[matching_detail] WITH NOCHECK ADD CONSTRAINT [FK_matching_detail_source_deal_header_id] FOREIGN KEY([source_deal_header_id])
	REFERENCES [dbo].[source_deal_header] ([source_deal_header_id])
END

GO