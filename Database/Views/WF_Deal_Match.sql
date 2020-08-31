IF OBJECT_ID ('WF_Deal_Match', 'V') IS NOT NULL
	DROP VIEW WF_Deal_Match;
GO

-- ===============================================================================================================
-- Author: sbasnet@pioneersolutionsglobal.com
-- Create date: 2019-07-05
-- Description: View to be used in workflow and alert 
-- ===============================================================================================================
CREATE VIEW WF_Deal_Match
AS 

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
      ,lock
      ,create_user
      ,create_ts
      ,update_user
      ,update_ts
      ,match_status
      ,assignment_type
FROM matching_header