IF OBJECT_ID('TRGIUD_matching_header') IS NOT NULL
	DROP TRIGGER [dbo].[TRGIUD_matching_header]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER TRGIUD_matching_header ON matching_header
AFTER UPDATE, INSERT, DELETE
AS

IF EXISTS(SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
BEGIN
	INSERT INTO matching_header_audit (
		link_id
		,fas_book_id
		,perfect_hedge
		,fully_dedesignated
		,link_description
		,eff_test_profile_id
		,link_effective_date
		,link_type_value_id
		,link_active
		,original_link_id
		,link_end_date
		,dedesignated_percentage
		,total_matched_volume
		,group1
		,group2
		,group3
		,group4
		,lock
		,[audit_user]
		,[create_ts]
		,update_user
		,update_ts
		,match_status
		,[action]
		,assignment_type
	)
	SELECT link_id
		,fas_book_id
		,perfect_hedge
		,fully_dedesignated
		,link_description
		,eff_test_profile_id
		,link_effective_date
		,link_type_value_id
		,link_active
		,original_link_id
		,link_end_date
		,dedesignated_percentage
		,total_matched_volume
		,group1
		,group2
		,group3
		,group4
		,lock
		,create_user
		,create_ts
		,update_user
		,update_ts
		,match_status
		,'Update'
		,assignment_type
	FROM INSERTED
END

IF EXISTS (SELECT * FROM inserted) AND NOT EXISTS(SELECT * FROM deleted)
BEGIN
    INSERT INTO matching_header_audit (
		link_id
		,fas_book_id
		,perfect_hedge
		,fully_dedesignated
		,link_description
		,eff_test_profile_id
		,link_effective_date
		,link_type_value_id
		,link_active
		,original_link_id
		,link_end_date
		,dedesignated_percentage
		,total_matched_volume
		,group1
		,group2
		,group3
		,group4
		,lock
		,[audit_user]
		,[create_ts]
		,update_user
		,update_ts
		,match_status
		,[action]
		,assignment_type
	)
	SELECT link_id
		,fas_book_id
		,perfect_hedge
		,fully_dedesignated
		,link_description
		,eff_test_profile_id
		,link_effective_date
		,link_type_value_id
		,link_active
		,original_link_id
		,link_end_date
		,dedesignated_percentage
		,total_matched_volume
		,group1
		,group2
		,group3
		,group4
		,lock
		,create_user
		,create_ts
		,update_user
		,update_ts
		,match_status
		,'Insert'
		,assignment_type
	FROM inserted
END

IF EXISTS(SELECT * FROM deleted) AND NOT EXISTS(SELECT * FROM inserted)
BEGIN 
    INSERT INTO matching_header_audit (
		link_id
		,fas_book_id
		,perfect_hedge
		,fully_dedesignated
		,link_description
		,eff_test_profile_id
		,link_effective_date
		,link_type_value_id
		,link_active
		,original_link_id
		,link_end_date
		,dedesignated_percentage
		,total_matched_volume
		,group1
		,group2
		,group3
		,group4
		,lock
		,[audit_user]
		,[create_ts]
		,update_user
		,update_ts
		,match_status
		,[action]
		,assignment_type
	)
	SELECT link_id
		,fas_book_id
		,perfect_hedge
		,fully_dedesignated
		,link_description
		,eff_test_profile_id
		,link_effective_date
		,link_type_value_id
		,link_active
		,original_link_id
		,link_end_date
		,dedesignated_percentage
		,total_matched_volume
		,group1
		,group2
		,group3
		,group4
		,lock
		,create_user
		,create_ts
		,update_user
		,update_ts
		,match_status
		,'Delete'
		,assignment_type
	FROM deleted
END
GO