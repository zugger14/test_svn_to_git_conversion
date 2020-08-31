
/****** Object:  Index [uci_hour_block_term]    Script Date: 05/22/2011 13:49:17 ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[source_deal_settlement]') AND name = N'unq_cur_indx_source_deal_settlement')
DROP INDEX [unq_cur_indx_source_deal_settlement] ON [dbo].[source_deal_settlement] WITH ( ONLINE = OFF )
GO


/****** Object:  Index [uci_hour_block_term]    Script Date: 05/22/2011 13:49:23 ******/
CREATE UNIQUE INDEX [unq_cur_indx_source_deal_settlement] ON [dbo].[source_deal_settlement] 
(
	source_deal_header_id ASC,
	term_start,leg ASC,
	as_of_date ASC,
	set_type ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO


