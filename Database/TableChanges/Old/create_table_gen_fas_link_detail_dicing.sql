
if OBJECT_ID('gen_fas_link_detail_dicing') is null
begin
	CREATE TABLE [dbo].[gen_fas_link_detail_dicing](
		[link_id] [int] NULL,
		[source_deal_header_id] [int] NULL,
		[term_start] [datetime] NULL,
		[percentage_used] [float] NULL,
		[effective_date] [datetime] NULL
	) ON [PRIMARY]

	create unique clustered  index ind_cru_uniq_gen_fas_link_detail_dicing_11 on dbo.gen_fas_link_detail_dicing ( [link_id] ,[source_deal_header_id] ,[term_start])
end
GO


