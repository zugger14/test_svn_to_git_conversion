IF OBJECT_ID('TRGIUD_matching_header_detail_info') IS NOT NULL
	DROP TRIGGER [dbo].[TRGIUD_matching_header_detail_info]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER TRGIUD_matching_header_detail_info ON matching_header_detail_info
AFTER UPDATE, INSERT, DELETE
AS

IF EXISTS(SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
BEGIN
    --UPDATE matching_header
    --   SET update_user = dbo.FNADBUser(),
    --       update_ts = GETDATE()
    --FROM matching_header t
    --INNER JOIN DELETED u ON t.[link_id] = u.[link_id]

	INSERT INTO matching_header_detail_info_audit (
		id,
		link_id,
		source_deal_header_id,
		source_deal_detail_id,
		source_deal_header_id_from,
		source_deal_detail_id_from,
		assigned_vol,
		state_value_id,
		tier_value_id,
		create_ts,
		create_user,
		update_ts,
		update_user,
		user_action
	)
	SELECT id,
		link_id,
		source_deal_header_id,
		source_deal_detail_id,
		source_deal_header_id_from,
		source_deal_detail_id_from,
		assigned_vol,
		state_value_id,
		tier_value_id,
		create_ts,
		create_user,
		update_ts,
		update_user,
		'Update'
	FROM inserted
END

IF EXISTS (SELECT * FROM inserted) AND NOT EXISTS(SELECT * FROM deleted)
BEGIN
    INSERT INTO matching_header_detail_info_audit (
		id,
		link_id,
		source_deal_header_id,
		source_deal_detail_id,
		source_deal_header_id_from,
		source_deal_detail_id_from,
		assigned_vol,
		state_value_id,
		tier_value_id,
		create_ts,
		create_user,
		update_ts,
		update_user,
		user_action
	)
	SELECT id,
		link_id,
		source_deal_header_id,
		source_deal_detail_id,
		source_deal_header_id_from,
		source_deal_detail_id_from,
		assigned_vol,
		state_value_id,
		tier_value_id,
		create_ts,
		create_user,
		update_ts,
		update_user,
		'Insert'
	FROM inserted
END

IF EXISTS(SELECT * FROM deleted) AND NOT EXISTS(SELECT * FROM inserted)
BEGIN 
    INSERT INTO matching_header_detail_info_audit (
		id,
		link_id,
		source_deal_header_id,
		source_deal_detail_id,
		source_deal_header_id_from,
		source_deal_detail_id_from,
		assigned_vol,
		state_value_id,
		tier_value_id,
		create_ts,
		create_user,
		update_ts,
		update_user,
		user_action
	)
	SELECT id,
		link_id,
		source_deal_header_id,
		source_deal_detail_id,
		source_deal_header_id_from,
		source_deal_detail_id_from,
		assigned_vol,
		state_value_id,
		tier_value_id,
		create_ts,
		create_user,
		update_ts,
		update_user,
		'Delete'
	FROM deleted
END
GO
--SELECT * FROM source_deal_header_audit
--DELETE FROM matching_detail_audit
--SELECT * FROM matching_detail_audit