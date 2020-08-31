IF OBJECT_ID('TRGUPD_SOURCE_DEAL_DETAIL') IS NOT null
DROP TRIGGER [dbo].[TRGUPD_SOURCE_DEAL_DETAIL]

GO

create TRIGGER [dbo].[TRGUPD_SOURCE_DEAL_DETAIL]
ON [dbo].[source_deal_detail]
FOR UPDATE
AS
--IF (COLUMNS_UPDATED() & cast(4398046511104 AS BIGINT))<> 4398046511104 --the total_volume is at 43rd column

if  OBJECT_ID('tempdb..#is_total_volume_only_update') is  NULL --the table will be created in the sp spa_update_deal_total_volume, and it is not required to update timestamp
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
