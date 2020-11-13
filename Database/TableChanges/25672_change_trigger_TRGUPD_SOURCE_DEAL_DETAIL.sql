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

--the table will be created in the sp spa_update_deal_total_volume, and it is not required to update timestamp
IF OBJECT_ID('tempdb..#is_total_volume_only_update') IS NULL
BEGIN 
	DECLARE @datetime DATETIME = GETDATE()

    UPDATE source_deal_detail
    SET update_user = dbo.FNADBUser(),
        update_ts = @datetime
    FROM [source_deal_detail] s
	INNER JOIN deleted i ON s.source_deal_detail_id = i.source_deal_detail_id
	-- (summy bidur) rigesh gyan sushil annal deal capture owners

	/** Disabled this because, the timestamp of deal is updated from Stored Procedure and is handled in Import as well.
		-- To update the update_ts of source_deal_header same as update_ts of source_deal_detail when a shaped hourly deal is imported.
		UPDATE sdh
		SET sdh.update_ts = @datetime
		FROM source_deal_header sdh
		INNER JOIN (
			SELECT MAX(source_deal_header_id) source_deal_header_id
			FROM INSERTED
		) i ON sdh.source_deal_header_id = i.source_deal_header_id
			AND ISNULL(sdh.internal_desk_id, 17300) = 17302
	**/
END

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