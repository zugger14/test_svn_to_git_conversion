IF OBJECT_ID(N'spa_msmt_excp_test_range', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_msmt_excp_test_range]
GO 

--drop proc spa_msmt_excp_test_range

CREATE PROCEDURE [dbo].[spa_msmt_excp_test_range]
	@process_id VARCHAR(50)
AS

SELECT  dbo.FNADateFormat(msmt_excp_test_range.as_of_date) AsOfDate, 
	CASE when (msmt_excp_test_range.calc_type = 'd') then 'De-Designation' else 'Designation' end as Type, 
	sub.entity_name AS Subsidiary, 
	stra.entity_name AS Strategy, 
        book.entity_name AS Book, 
	missing_test_range_from AS MissingTestRangeFrom1,
	missing_test_range_to AS MissingTestRangeTo1,
	missing_add_test_range_from AS MissingTestRangeFrom2,
	missing_add_test_range_to AS MissingTestRangeTo2,
	missing_add_test_range_from2 AS MissingTestRangeFrom3,
	missing_add_test_range_to2 AS MissingTestRangeTo3,
	msmt_excp_test_range.create_user AS CreatedUser, 
	dbo.FNADateFormat(msmt_excp_test_range.create_ts) AS CreatedTS
FROM    msmt_excp_test_range INNER JOIN
        portfolio_hierarchy sub ON msmt_excp_test_range.fas_subsidiary_id = sub.entity_id INNER JOIN
	portfolio_hierarchy stra ON msmt_excp_test_range.fas_strategy_id = stra.entity_id INNER JOIN
        portfolio_hierarchy book ON msmt_excp_test_range.fas_book_id = book.entity_id
WHERE   process_id = @process_id
ORDER By sub.entity_name, stra.entity_name, book.entity_name