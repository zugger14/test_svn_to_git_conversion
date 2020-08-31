IF OBJECT_ID(N'spa_msmt_excp_pnl', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_msmt_excp_pnl]
GO

--drop proc spa_msmt_excp_pnl

CREATE PROCEDURE [dbo].[spa_msmt_excp_pnl] 
	@process_id varchar(50)
AS

SELECT  dbo.FNADateFormat(msmt_excp_pnl.as_of_date) AsOfDate, 
	CASE when (msmt_excp_pnl.calc_type = 'd') then 'De-Designation' else 'Designation' end as Type, 
	sub.entity_name AS Subsidiary, 
	stra.entity_name AS Strategy, 
        book.entity_name AS Book, 
	deal_id as DealID, 
	dbo.FNADateFormat(term_start) AS Term,
        dbo.FNADateFormat(pnl_date) AS PNLDate, 
        dbo.FNADateFormat(pnl_as_of_date) AS PNLAsOfDate, 
	missing_pnl As MissingPNL,
	cast(round(pnl_used, 0) as varchar) AS PNLUsed,
	missing_intrinsic_pnl As MissingIntrinsicPNL,
	cast(round(pnl_intrinisic_used, 0) as varchar) AS PNLIntrinsicUsed,
	missing_extrinisic_pnl As MissingExtrinsicPNL,
	cast(round(pnl_extrinsic_used, 0) as varchar) AS PNLExtrinsicUsed,	
	msmt_excp_pnl.create_user AS CreatedUser, 
	dbo.FNADateFormat(msmt_excp_pnl.create_ts) AS CreatedTS
FROM    msmt_excp_pnl INNER JOIN
        portfolio_hierarchy sub ON msmt_excp_pnl.fas_subsidiary_id = sub.entity_id INNER JOIN
	portfolio_hierarchy stra ON msmt_excp_pnl.fas_strategy_id = stra.entity_id INNER JOIN
        portfolio_hierarchy book ON msmt_excp_pnl.fas_book_id = book.entity_id
WHERE   process_id = @process_id
ORDER By sub.entity_name, stra.entity_name, book.entity_name, deal_id, term_start