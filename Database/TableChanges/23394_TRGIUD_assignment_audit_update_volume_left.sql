/* Note: Dropped existing triggers and replaced by new one
OLD: It was not supported if we insert/update/delete multiple rows of same detail id at once, it couldn't update the volume_left correctly.
NEW: Aggregated volume SUM of multiple rows of inserted/updated/deleted details and then update the column volume_left to resolve the issue
IMP: In case of multiple insertion/updation/deletion of same id, first aggregate sum then update the column is recommended solution as done below
*/
IF OBJECT_ID('TRGINS_ASSIGNMENT_AUDIT') IS NOT NULL
	DROP TRIGGER [dbo].[TRGINS_ASSIGNMENT_AUDIT]

IF OBJECT_ID('TRGUPS_ASSIGNMENT_AUDIT') IS NOT NULL
	DROP TRIGGER [dbo].[TRGUPS_ASSIGNMENT_AUDIT]

IF OBJECT_ID('TRGDELETE_ASSIGNMENT_AUDIT') IS NOT NULL
	DROP TRIGGER [dbo].[TRGDELETE_ASSIGNMENT_AUDIT]


IF OBJECT_ID('TRGIUD_assignment_audit_update_volume_left') IS NOT NULL
	DROP TRIGGER [dbo].[TRGIUD_assignment_audit_update_volume_left]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TRGIUD_assignment_audit_update_volume_left] ON [dbo].[assignment_audit]
AFTER UPDATE, INSERT, DELETE
AS

IF EXISTS(SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
BEGIN
	IF UPDATE(assigned_volume)
	BEGIN
		UPDATE source_deal_detail 
		SET volume_left = sd.volume_left+(del.assigned_volume-ins.assigned_volume)
		FROM source_deal_detail sd
		INNER JOIN (SELECT source_deal_header_id_from, 
					SUM(assigned_volume) assigned_volume
					FROM inserted
					GROUP BY source_deal_header_id_from) ins ON ins.source_deal_header_id_from =  sd.source_deal_detail_id
		INNER JOIN (SELECT source_deal_header_id_from, 
					SUM(assigned_volume) assigned_volume
					FROM deleted
					GROUP BY source_deal_header_id_from) del ON del.source_deal_header_id_from =  sd.source_deal_detail_id

	END
END

IF EXISTS (SELECT * FROM inserted) AND NOT EXISTS(SELECT * FROM deleted)
BEGIN
    UPDATE sdd 
	SET volume_left = (sdd.volume_left-ins.assigned_volume)
	FROM source_deal_detail sdd 
	INNER JOIN (SELECT source_deal_header_id_from, 
					SUM(inserted.assigned_volume) assigned_volume
				FROM inserted 
				GROUP BY source_deal_header_id_from) ins ON sdd.source_deal_detail_id = ins.source_deal_header_id_from
END

IF EXISTS(SELECT * FROM deleted) AND NOT EXISTS(SELECT * FROM inserted)
BEGIN 
	UPDATE a
		 SET volume_left = (a.volume_left+del.assigned_volume)
	FROM source_deal_detail a
	INNER JOIN (SELECT source_deal_header_id_from,
					SUM(d.assigned_volume) assigned_volume
				FROM deleted d
				GROUP BY d.source_deal_header_id_from) del ON a.source_deal_detail_id = del.source_deal_header_id_from
END
