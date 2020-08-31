IF OBJECT_ID('TRGIUD_matching_detail') IS NOT NULL
	DROP TRIGGER [dbo].[TRGIUD_matching_detail]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER TRGIUD_matching_detail ON matching_detail
AFTER UPDATE, INSERT, DELETE
AS

IF EXISTS(SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
BEGIN
	INSERT INTO matching_detail_audit (
		fas_link_detail_id,
		link_id,
		source_deal_header_id,
		matched_volume,
		[set],
		create_user,
		create_ts,
		update_user,
		update_ts,
		user_action
	)
	SELECT fas_link_detail_id,
		link_id,
		source_deal_header_id,
		matched_volume,
		[set],
		create_user,
		create_ts,
		update_user,
		update_ts,
		'Update'
	FROM inserted
END

IF EXISTS (SELECT * FROM inserted) AND NOT EXISTS(SELECT * FROM deleted)
BEGIN
    INSERT INTO matching_detail_audit (
		fas_link_detail_id,
		link_id,
		source_deal_header_id,
		matched_volume,
		[set],
		create_user,
		create_ts,
		update_user,
		update_ts,
		user_action
	)
	SELECT fas_link_detail_id,
		link_id,
		source_deal_header_id,
		matched_volume,
		[set],
		create_user,
		create_ts,
		update_user,
		update_ts,
		'Insert'
	FROM inserted
END

IF EXISTS(SELECT * FROM deleted) AND NOT EXISTS(SELECT * FROM inserted)
BEGIN 
    INSERT INTO matching_detail_audit (
		fas_link_detail_id,
		link_id,
		source_deal_header_id,
		matched_volume,
		[set],
		create_user,
		create_ts,
		update_user,
		update_ts,
		user_action
	)
	SELECT fas_link_detail_id,
		link_id,
		source_deal_header_id,
		matched_volume,
		[set],
		create_user,
		create_ts,
		update_user,
		update_ts,
		'Delete'
	FROM deleted
END
GO