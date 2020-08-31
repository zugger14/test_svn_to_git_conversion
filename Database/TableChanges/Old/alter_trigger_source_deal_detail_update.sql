/****** Object:  Trigger [dbo].[TRGUPD_SOURCE_DEAL_DETAIL]    Script Date: 01/05/2011 11:36:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER TRIGGER [dbo].[TRGUPD_SOURCE_DEAL_DETAIL]
ON [dbo].[source_deal_detail]
FOR UPDATE
AS
UPDATE SOURCE_DEAL_DETAIL SET update_user =  dbo.FNADBUser(), update_ts = getdate() from [source_deal_DETAIL] s inner join deleted i on 
s.source_deal_DETAIL_id=i.source_deal_DETAIL_id

if update(deal_volume)
begin
	update source_deal_detail
	set volume_left= case when (source_deal_detail.deal_volume-deleted.deal_volume)+deleted.volume_left<0 then 0 else
	(source_deal_detail.deal_volume-deleted.deal_volume)+deleted.volume_left end	
	from deleted, source_deal_detail
	where source_deal_detail.source_deal_detail_id=deleted.source_deal_detail_id
end
