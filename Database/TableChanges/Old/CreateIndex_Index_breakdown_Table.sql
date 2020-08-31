IF EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[index_fees_breakdown]') AND name = N'IX_index_fees_breakdown')
BEGIN
DROP INDEX IX_index_fees_breakdown ON [index_fees_breakdown]

CREATE UNIQUE NONCLUSTERED INDEX [IX_index_fees_breakdown] ON [dbo].[index_fees_breakdown] 
(
	[as_of_date] ASC,
	[source_deal_header_id] ASC,
	[term_start] ASC,
	[field_id] ASC,
	[leg] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
END
GO