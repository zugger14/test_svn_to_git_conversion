/****** Object:  Index [cui_source_deal_pnl_arch1]    Script Date: 06/30/2010 11:24:41 ******/
CREATE UNIQUE CLUSTERED INDEX [cui_source_deal_pnl_arch1] ON [dbo].[source_deal_pnl_arch1] 
(
	[pnl_as_of_date] ASC,
	[source_deal_header_id] ASC,
	[term_start] ASC,
	[term_end] ASC,
	[Leg] ASC,
	pnl_source_value_id asc
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = ON, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

CREATE UNIQUE CLUSTERED INDEX [cui_source_deal_pnl_eff] ON [dbo].[source_deal_pnl_eff] 
(
	[pnl_as_of_date] ASC,
	[source_deal_header_id] ASC,
	[term_start] ASC,
	[term_end] ASC,
	[Leg] ASC,
	pnl_source_value_id asc
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = ON, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO