go


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
IF columns_updated() & 4096 <> 4096     --SELECT POWER(2,13-1)=4096  deal_volume is at 13 th column
BEGIN
	IF OBJECT_ID('tempdb..#inserted_source_deal_detail') IS not NULL
	begin
		delete s from  #inserted_source_deal_detail s  inner join deleted d on s.source_deal_detail_id=d.source_deal_detail_id
		insert into #inserted_source_deal_detail SELECT * FROM inserted
	end
END
go


CREATE TRIGGER [dbo].[TRGDEL_SOURCE_DEAL_DETAIL]
ON [dbo].[source_deal_detail]
FOR Delete
AS
IF OBJECT_ID('tempdb..#deleted_source_deal_detail') IS not NULL
	insert into #deleted_source_deal_detail SELECT * FROM deleted
