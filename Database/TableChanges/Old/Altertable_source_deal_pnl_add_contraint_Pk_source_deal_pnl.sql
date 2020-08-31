IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[PK_source_deal_pnl]'))
	ALTER TABLE source_deal_pnl ADD CONSTRAINT [PK_source_deal_pnl] PRIMARY KEY NONCLUSTERED 
	(
		[source_deal_header_id] ASC,
		[term_start] ASC,
		[term_end] ASC,
		[Leg] ASC,
		[pnl_as_of_date] ASC,
		[pnl_source_value_id] ASC
	)