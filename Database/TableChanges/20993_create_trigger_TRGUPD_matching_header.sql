IF OBJECT_ID('TRGUPD_matching_header') IS NOT NULL
	DROP TRIGGER [dbo].[TRGUPD_matching_header]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE TRIGGER [dbo].[TRGUPD_matching_header]
ON [dbo].[matching_header]
FOR UPDATE
AS
    UPDATE matching_header
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM matching_header t
      INNER JOIN DELETED u ON t.[link_id] = u.[link_id]

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
		,[action]
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
		,'u'
		FROM inserted
GO