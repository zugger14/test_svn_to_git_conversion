
/****** Object:  Trigger [TRGINS_SOURCE_DEAL_DETAIL]    Script Date: 12/18/2009 17:08:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[TRGINS_SOURCE_DEAL_DETAIL]'))
DROP TRIGGER [dbo].[TRGINS_SOURCE_DEAL_DETAIL]

GO

CREATE TRIGGER [TRGINS_SOURCE_DEAL_DETAIL]
ON [dbo].[source_deal_detail]
FOR Insert
AS

update source_deal_detail
	set volume_left=s.deal_volume,create_ts=getdate(),create_user =  dbo.FNADBUser()
	from inserted i inner join source_deal_detail s
	on  s.source_deal_detail_id=i.source_deal_detail_id
