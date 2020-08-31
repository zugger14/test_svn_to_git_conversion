
/****** Object:  Index [uci_hour_block_term]    Script Date: 05/22/2011 13:49:17 ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[hour_block_term]') AND name = N'uci_hour_block_term')
DROP INDEX [uci_hour_block_term] ON [dbo].[hour_block_term] WITH ( ONLINE = OFF )
GO


/****** Object:  Index [uci_hour_block_term]    Script Date: 05/22/2011 13:49:23 ******/
CREATE UNIQUE CLUSTERED INDEX [uci_hour_block_term] ON [dbo].[hour_block_term] 
(
	[block_type] ASC,
	[block_define_id] ASC,
	[term_date] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO


