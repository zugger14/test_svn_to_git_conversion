IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[broker_fees]') AND name = N'IX_broker_fees')
DROP INDEX [IX_broker_fees] ON [dbo].[broker_fees] WITH ( ONLINE = OFF )
GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_broker_fees] ON [dbo].[broker_fees] 
(
	[counterparty_id] ASC,
	[commodity] ASC,
	[product] ASC,
	[deal_type] ASC,
	[effective_date] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

