IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'source_deal_settlement' AND COLUMN_NAME = 'set_type')
BEGIN
	ALTER TABLE source_deal_settlement ADD  set_type CHAR(1)
END

GO


IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'index_fees_breakdown_settlement' AND COLUMN_NAME = 'set_type')
BEGIN
	ALTER TABLE index_fees_breakdown_settlement ADD  set_type CHAR(1)
END

GO

IF EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[index_fees_breakdown_settlement]') AND name = N'IX_index_fees_breakdown_settlement')
DROP Index [IX_index_fees_breakdown_settlement] ON [dbo].[index_fees_breakdown_settlement] 

CREATE UNIQUE NONCLUSTERED INDEX [IX_index_fees_breakdown_settlement] ON [dbo].[index_fees_breakdown_settlement] 
(
	[source_deal_header_id] ASC,
	[term_start] ASC,
	[field_id] ASC,
	[leg] ASC,
	[as_of_date] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'source_deal_settlement' AND COLUMN_NAME = 'allocation_volume')
BEGIN
	ALTER TABLE source_deal_settlement ADD  allocation_volume FLOAT
END

GO


IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'index_fees_breakdown' AND COLUMN_NAME = 'contract_mkt_flag')
BEGIN
	ALTER TABLE index_fees_breakdown ADD  contract_mkt_flag CHAR(1)
END

GO


IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'index_fees_breakdown_settlement' AND COLUMN_NAME = 'contract_mkt_flag')
BEGIN
	ALTER TABLE index_fees_breakdown_settlement ADD  contract_mkt_flag CHAR(1)
END

GO