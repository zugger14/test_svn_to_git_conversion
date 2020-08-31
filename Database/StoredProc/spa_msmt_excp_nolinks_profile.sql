IF OBJECT_ID(N'spa_msmt_excp_nolinks_profile', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_msmt_excp_nolinks_profile]
GO 

--drop proc spa_msmt_excp_nolinks_profile

CREATE PROCEDURE [dbo].[spa_msmt_excp_nolinks_profile] 
	@process_id varchar(50)
AS

SELECT  dbo.FNADateFormat(msmt_excp_nolinks_profile.as_of_date) AsOfDate, 
	CASE when (msmt_excp_nolinks_profile.calc_type = 'd') then 'De-Designation' else 'Designation' end as Type, 
	sub.entity_name AS Subsidiary, 
	stra.entity_name AS Strategy, 
        book.entity_name AS Book, 
	msmt_excp_nolinks_profile.create_user AS CreatedUser, 
	dbo.FNADateFormat(msmt_excp_nolinks_profile.create_ts) AS CreatedTS
FROM    msmt_excp_nolinks_profile INNER JOIN
        portfolio_hierarchy sub ON msmt_excp_nolinks_profile.fas_subsidiary_id = sub.entity_id INNER JOIN
	portfolio_hierarchy stra ON msmt_excp_nolinks_profile.fas_strategy_id = stra.entity_id INNER JOIN
        portfolio_hierarchy book ON msmt_excp_nolinks_profile.fas_book_id = book.entity_id
WHERE   process_id = @process_id
ORDER By sub.entity_name, stra.entity_name, book.entity_name