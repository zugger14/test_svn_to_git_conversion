IF OBJECT_ID(N'spa_msmt_excp_assmt_values_quarter', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_msmt_excp_assmt_values_quarter]
GO 

--drop proc spa_msmt_excp_assmt_values_quarter

CREATE PROCEDURE [dbo].[spa_msmt_excp_assmt_values_quarter] 
	@process_id varchar(50)
AS

SELECT  dbo.FNADateFormat(msmt_excp_assmt_values_quarter.as_of_date) AsOfDate, 
	CASE when (msmt_excp_assmt_values_quarter.calc_type = 'd') then 'De-Designation' else 'Designation' end as Type, 
	sub.entity_name AS Subsidiary, 
	stra.entity_name AS Strategy, 
        book.entity_name AS Book,
	link_id As RelID,  
        cast(round(use_assessment_values, 2) as varchar) AS AssmtValue, 
	cast(round(use_additional_assessment_values, 2) as varchar) AS AddAssmtValue, 
        dbo.FNADateFormat(assessment_date) AS AssmtDate, 
	assmt_beyond_quarter AS BeyondQuarter, 
	msmt_excp_assmt_values_quarter.create_user AS CreatedUser,
	dbo.FNADateFormat(msmt_excp_assmt_values_quarter.create_ts) AS CreatedTS
FROM    msmt_excp_assmt_values_quarter INNER JOIN
        portfolio_hierarchy sub ON msmt_excp_assmt_values_quarter.fas_subsidiary_id = sub.entity_id INNER JOIN
	portfolio_hierarchy stra ON msmt_excp_assmt_values_quarter.fas_strategy_id = stra.entity_id INNER JOIN
        portfolio_hierarchy book ON msmt_excp_assmt_values_quarter.fas_book_id = book.entity_id
WHERE   process_id = @process_id
ORDER BY sub.entity_name, stra.entity_name, book.entity_name, link_id