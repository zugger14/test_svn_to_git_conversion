ALTER TABLE [dbo].[source_deal_pnl_detail_options] ADD pnl_source_value_id int NOT NULL; 
GO
ALTER TABLE [dbo].[source_deal_pnl_detail_options]  WITH CHECK ADD  CONSTRAINT [FK_source_deal_pnl_detail_options_static_data_value] FOREIGN KEY([pnl_source_value_id])
REFERENCES [dbo].[static_data_value] ([value_id])
GO

/****** Object:  Index [PK_source_deal_pnl_detail_options]    Script Date: 01/07/2009 11:35:49 ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[source_deal_pnl_detail_options]') AND name = N'PK_source_deal_pnl_detail_options')
ALTER TABLE [dbo].[source_deal_pnl_detail_options] DROP CONSTRAINT [PK_source_deal_pnl_detail_options]
GO
ALTER TABLE [dbo].[source_deal_pnl_detail_options] ALTER COLUMN as_of_date datetime NOT NULL; 
GO
delete from source_deal_pnl_detail_options
go
/****** Object:  Index [PK_source_deal_pnl_detail_options]    Script Date: 01/07/2009 11:36:15 ******/
ALTER TABLE [dbo].[source_deal_pnl_detail_options] ADD  CONSTRAINT [PK_source_deal_pnl_detail_options] PRIMARY KEY CLUSTERED 
(
	[as_of_date] ASC,
	[source_deal_header_id] ASC,
	[term_start] ASC,
	[pnl_source_value_id] ASC
)WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
GO