IF OBJECT_ID('TRGUPD_SOURCE_DEAL_DETAIL') IS NOT NULL
	DROP TRIGGER [dbo].[TRGUPD_SOURCE_DEAL_DETAIL]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE TRIGGER [dbo].[TRGUPD_SOURCE_DEAL_DETAIL]
ON [dbo].[source_deal_detail]
FOR UPDATE
AS

 IF OBJECT_ID('tempdb..#is_total_volume_only_update') IS NULL --the table will be created in the sp spa_update_deal_total_volume, and it is not required to update timestamp
begin 
	declare @dt datetime
	set @dt=GETDATE()
    UPDATE source_deal_detail
    SET update_user = dbo.fnadbuser(),
        update_ts = @dt
    FROM [source_deal_detail] s
		INNER JOIN deleted i ON s.source_deal_detail_id = i.source_deal_detail_id

    --to update the update_ts of source_deal_header same as update_ts of source_deal_detail when a shaped hourly deal is imported 
	UPDATE sdh SET sdh.update_ts = @dt
	FROM source_deal_header sdh 
		inner join (select max(source_deal_header_id) source_deal_header_id from inserted ) i 
		ON sdh.source_deal_header_id = i.source_deal_header_id 
		and ISNULL(sdh.internal_desk_id,17300)=17302 
end


  IF UPDATE(deal_volume)
  BEGIN
    UPDATE source_deal_detail
    SET volume_left = ISNULL(source_deal_detail.volume_left, 0) + (ISNULL(source_deal_detail.deal_volume, 0) - ISNULL(deleted.deal_volume, 0))                   
    FROM deleted, source_deal_detail
    WHERE source_deal_detail.source_deal_detail_id = deleted.source_deal_detail_id
  END
GO

ALTER TABLE [dbo].[source_deal_detail] ENABLE TRIGGER [TRGUPD_SOURCE_DEAL_DETAIL]
GO


