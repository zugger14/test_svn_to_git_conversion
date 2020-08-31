set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go


ALTER TRIGGER [dbo].[TRGINS_SOURCE_DEAL_DETAIL]
ON [dbo].[source_deal_detail]
FOR Insert
AS



update source_deal_detail
	set volume_left=s.deal_volume,create_ts=getdate(),create_user =  dbo.FNADBUser()
	from inserted i inner join source_deal_detail s
	on  s.source_deal_detail_id=i.source_deal_detail_id
	
IF OBJECT_ID('tempdb..#inserted_source_deal_detail') IS not NULL
	insert into #inserted_source_deal_detail SELECT * FROM inserted

