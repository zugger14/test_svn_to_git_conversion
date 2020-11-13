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

DECLARE @datetime DATETIME = GETDATE()

UPDATE source_deal_detail
SET update_user = dbo.FNADBUser(),
    update_ts = @datetime
FROM [source_deal_detail] s
INNER JOIN deleted i ON s.source_deal_detail_id = i.source_deal_detail_id

IF UPDATE(deal_volume)
BEGIN
	UPDATE source_deal_detail
	SET volume_left = ISNULL(source_deal_detail.volume_left, 0) + (ISNULL(source_deal_detail.deal_volume, 0) - ISNULL(deleted.deal_volume, 0))                   
	FROM deleted, source_deal_detail
	WHERE source_deal_detail.source_deal_detail_id = deleted.source_deal_detail_id
END

GO

ALTER TABLE [dbo].[source_deal_detail] /** */ ENABLE TRIGGER [TRGUPD_SOURCE_DEAL_DETAIL]
GO