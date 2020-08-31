
/****** Object:  Trigger [TRGUPD_SOURCE_DEAL_DETAIL]    Script Date: 12/18/2009 17:10:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[TRGUPD_SOURCE_DEAL_DETAIL]'))
DROP TRIGGER [dbo].[TRGUPD_SOURCE_DEAL_DETAIL]
GO

CREATE TRIGGER [TRGUPD_SOURCE_DEAL_DETAIL]
ON [dbo].[source_deal_detail]
FOR UPDATE
AS
  --IF (COLUMNS_UPDATED() & cast(4398046511104 AS BIGINT))<> 4398046511104 --the total_volume is at 43rd column

  IF OBJECT_ID('tempdb..#is_total_volume_only_update') IS NULL --the table will be created in the sp spa_update_deal_total_volume, and it is not required to update timestamp
    UPDATE source_deal_detail
    SET update_user = dbo.fnadbuser(),
        update_ts = GETDATE()
    FROM [source_deal_detail] s
    INNER JOIN deleted i
      ON s.source_deal_detail_id = i.source_deal_detail_id


  IF UPDATE(deal_volume)
  BEGIN
    UPDATE source_deal_detail
    SET volume_left = ISNULL(source_deal_detail.volume_left, 0) + (ISNULL(source_deal_detail.deal_volume, 0) - ISNULL(deleted.deal_volume, 0))                   
    FROM deleted, source_deal_detail
    WHERE source_deal_detail.source_deal_detail_id = deleted.source_deal_detail_id
  END