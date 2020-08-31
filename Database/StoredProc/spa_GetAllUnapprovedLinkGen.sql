if object_id('[dbo].[spa_GetAllUnapprovedLinkGen]') is not null
DROP PROCEDURE [dbo].[spa_GetAllUnapprovedLinkGen] 
GO 

-- EXEC spa_GetAllUnapprovedLinkGen 2

--===========================================================================================
--This Procedure returns all outstanding link for each outstanding group
--Input Parameters:
-- gen_hedge_group_id: a list of book_ids


--===========================================================================================

CREATE PROCEDURE [dbo].[spa_GetAllUnapprovedLinkGen] 
	@gen_hedge_group_id VARCHAR(MAX)
AS

SET NOCOUNT ON

select 	glh.gen_link_id as [Gel Rel ID], glh.gen_hedge_group_id as [Gen Group ID], glh.gen_approved as Approved, 
	glh.used_ass_profile_id as [Used Assesment Type ID], glh.fas_book_id as [Book ID], glh.perfect_hedge as [Perfect Hedge], 
	glh.link_description as [Description], 
        glh.eff_test_profile_id as [Assessment Type ID], 
	dbo.FNADateFormat(glh.link_effective_date) as [Effective Date], glh.link_type_value_id [Relation Type ID], 
	glh.link_id as [Relation ID], glh.gen_status as Status, glh.process_id as [Process ID], 
	glh.create_user as [Created User], dbo.FNADateFormat(glh.create_ts) as [Created TS],
	glh.create_user as [Update User], dbo.FNADateFormat(glh.create_ts) as [Update TS]
	
from gen_fas_link_header glh 
where glh.gen_hedge_group_id IN (SELECT Item FROM [dbo].[SplitCommaSeperatedValues](@gen_hedge_group_id)) 
order by glh.gen_link_id



	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, 'Source Systems', 
				'spa_GetAllUnapprovedLinkGen', 'DB Error', 
				'Failed to select outstanding unapproved links.', ''









