IF OBJECT_ID('TRGIUD_matching_header_detail_info_update_volume_left') IS NOT NULL
	DROP TRIGGER [dbo].[TRGIUD_matching_header_detail_info_update_volume_left]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TRGIUD_matching_header_detail_info_update_volume_left] ON [dbo].[matching_header_detail_info]
AFTER UPDATE, INSERT, DELETE
AS

IF EXISTS(SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
BEGIN
	IF UPDATE(assigned_vol)
	BEGIN
		UPDATE source_deal_detail 
		SET volume_left = sd.volume_left+(del.assigned_volume-ins.assigned_volume)
		FROM source_deal_detail sd
		INNER JOIN (SELECT source_deal_detail_id, 
					SUM(assigned_vol) assigned_volume
					FROM inserted
					GROUP BY source_deal_detail_id) ins ON ins.source_deal_detail_id =  sd.source_deal_detail_id
		INNER JOIN (SELECT source_deal_detail_id, 
					SUM(assigned_vol) assigned_volume
					FROM deleted
					GROUP BY source_deal_detail_id) del ON del.source_deal_detail_id =  sd.source_deal_detail_id

	END
END

IF EXISTS (SELECT * FROM inserted) AND NOT EXISTS(SELECT * FROM deleted)
BEGIN
    UPDATE sdd 
	SET volume_left = (sdd.volume_left-ins.assigned_volume)
	FROM source_deal_detail sdd 
	INNER JOIN (SELECT source_deal_detail_id, 
					SUM(inserted.assigned_vol) assigned_volume
				FROM inserted 
				GROUP BY source_deal_detail_id) ins ON sdd.source_deal_detail_id = ins.source_deal_detail_id
END

IF EXISTS(SELECT * FROM deleted) AND NOT EXISTS(SELECT * FROM inserted)
BEGIN 
	UPDATE a
		 SET volume_left = (a.volume_left+del.assigned_volume)
	FROM source_deal_detail a
	INNER JOIN (SELECT source_deal_detail_id,
					SUM(d.assigned_vol) assigned_volume
				FROM deleted d
				GROUP BY d.source_deal_detail_id) del ON a.source_deal_detail_id = del.source_deal_detail_id
END
