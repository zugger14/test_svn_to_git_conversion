USE [TRMTracker_Essent]
GO
/****** Object:  Trigger [dbo].[TRGINS_SOURCE_DEAL_DETAIL]    Script Date: 01/05/2011 11:28:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER TRIGGER [dbo].[TRGINS_SOURCE_DEAL_DETAIL]
ON [dbo].[source_deal_detail]
FOR Insert
AS



update source_deal_detail
	set volume_left=s.deal_volume
	,create_ts=getdate()
	,create_user =  dbo.FNADBUser()
	from inserted i inner join source_deal_detail s
	on  s.source_deal_detail_id=i.source_deal_detail_id

