

IF OBJECT_ID(N'dbo.spa_calculate_premium_fees', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_calculate_premium_fees]
GO 

CREATE PROCEDURE [dbo].[spa_calculate_premium_fees]
	@as_of_date DATETIME, --'2012-05-31' -- last day of month
	@fee_premium INT, -- 1:premium, 2: fee
	@counterparty_id INT = NULL,
	@book_ids VARCHAR(MAX) = NULL
	
AS

DECLARE @run_as_of_date DATETIME = @as_of_date
SET @as_of_date = DATEADD(m,1,@as_of_date)

--SET @as_of_date = CAST(CONVERT(CHAR(7), @as_of_date, 126) + '-01' AS DATETIME)

--declare @aod varchar(30) = '2012-05-31'
DECLARE @Sql_WhereB VARCHAR(MAX)
DECLARE @Sql_SelectB VARCHAR(1500)
SET @Sql_WhereB = ''  

IF OBJECT_ID('tempdb..#books') IS NOT NULL
	DROP TABLE #books

CREATE TABLE #books (fas_book_id INT,source_system_book_id1 INT,
source_system_book_id2 INT,
source_system_book_id3 INT,
source_system_book_id4 INT,	fas_deal_type_value_id INT ,
book_deal_type_map_id INT,
sub_id INT
) 

CREATE TABLE #line_item_premium_fees(
	as_of_date DATETIME
	, book_id INT
	, counterparty_id INT
	, tou INT
	, line_item VARCHAR(128) COLLATE DATABASE_DEFAULT
	, [value] NUMERIC(38,20)
	, line_item_type VARCHAR(50) COLLATE DATABASE_DEFAULT
)


SET @Sql_SelectB=        
'INSERT INTO  #books 
(fas_book_id, source_system_book_id1, source_system_book_id2, source_system_book_id3, source_system_book_id4, fas_deal_type_value_id, book_deal_type_map_id, sub_id) 
	SELECT DISTINCT book.entity_id fas_book_id, source_system_book_id1, source_system_book_id2, source_system_book_id3, source_system_book_id4,
	fas_deal_type_value_id, ssbm.book_deal_type_map_id, stra.parent_entity_id
	FROM portfolio_hierarchy book (nolock) INNER JOIN
	Portfolio_hierarchy stra (nolock) ON book.parent_entity_id = stra.entity_id INNER JOIN          
	source_system_book_map ssbm ON ssbm.fas_book_id = book.entity_id  '

EXEC (@Sql_SelectB)

--select * from #books
DECLARE @sql1 VARCHAR(MAX)

IF @fee_premium = 1
BEGIN
	 ------ Risk premium
	 --capture all as_of_date
	SET @sql1 = '
	INSERT INTO #line_item_premium_fees(as_of_date, book_id, counterparty_id, tou, line_item, [value], line_item_type)
	SELECT ifbs.term_start, b.fas_book_id, sdh.counterparty_id, NULL tou, ifbs.field_name, SUM(ifbs.value) sum_value, ''Premium'' line_item_type
	FROM index_fees_breakdown_settlement ifbs
	INNER JOIN static_data_value sdv on sdv.value_id = ifbs.field_id
	INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = ifbs.source_deal_header_id
	INNER JOIN #books b ON sdh.source_system_book_id1 = b.source_system_book_id1
		AND sdh.source_system_book_id2 = b.source_system_book_id2 
		AND sdh.source_system_book_id3 = b.source_system_book_id3
		AND sdh.source_system_book_id4 = b.source_system_book_id4
	WHERE sdv.type_id = 5500 AND sdv.category_id = 2 AND MONTH(ifbs.term_start) = MONTH(''' + CONVERT(VARCHAR(10),@as_of_date, 126) + ''') AND YEAR(ifbs.term_start) = YEAR(''' + CONVERT(VARCHAR(10),@as_of_date, 126) + ''') 
	'
	+ CASE WHEN @counterparty_id IS NOT NULL THEN ' AND sdh.counterparty_id = ' + CAST(@counterparty_id AS VARCHAR(10)) ELSE '' END
	+ CASE WHEN @book_ids IS NOT NULL THEN ' AND b.fas_book_id in ( ' + @book_ids + ')' ELSE '' END
	+ '
	GROUP BY b.fas_book_id, sdh.counterparty_id, ifbs.field_id, ifbs.field_name, ifbs.term_start
	ORDER BY b.fas_book_id, sdh.counterparty_id, ifbs.field_id

	'
	exec spa_print @sql1
	EXEC(@sql1)

END
--select * from source_deal_header where source_deal_header_id = 4867
ELSE IF @fee_premium = 2
BEGIN
	---------Feess.
	--capture all as_of_date
	SET @sql1 = '
	INSERT INTO #line_item_premium_fees(as_of_date, book_id, counterparty_id, tou, line_item, [value], line_item_type)
	SELECT ifbs.term_start, b.fas_book_id, sdh.counterparty_id, NULL tou, ifbs.field_name, SUM(ifbs.value) sum_value, ''Fees'' line_item_type
	FROM index_fees_breakdown_settlement ifbs
	INNER JOIN static_data_value sdv on sdv.value_id = ifbs.field_id
	INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = ifbs.source_deal_header_id
	INNER JOIN #books b ON sdh.source_system_book_id1 = b.source_system_book_id1
		AND sdh.source_system_book_id2 = b.source_system_book_id2 
		AND sdh.source_system_book_id3 = b.source_system_book_id3
		AND sdh.source_system_book_id4 = b.source_system_book_id4
	WHERE sdv.type_id = 5500 and sdv.category_id IS NULL AND MONTH(ifbs.term_start) = MONTH(''' + CONVERT(VARCHAR(10),@as_of_date, 126) + ''') AND YEAR(ifbs.term_start) = YEAR(''' + CONVERT(VARCHAR(10),@as_of_date, 126) + ''')
	'
	+ CASE WHEN @counterparty_id IS NOT NULL THEN ' AND sdh.counterparty_id = ' + CAST(@counterparty_id AS VARCHAR(10)) ELSE '' END
	+ CASE WHEN @book_ids IS NOT NULL THEN ' AND b.fas_book_id IN (' + @book_ids + ')' ELSE '' END
	+ '
	GROUP BY b.fas_book_id, sdh.counterparty_id, ifbs.field_id, ifbs.field_name, ifbs.term_start
	ORDER BY b.fas_book_id, sdh.counterparty_id, ifbs.field_id
	'

	exec spa_print @sql1
	EXEC(@sql1)

END

--DEBUG, uncomment in PROD code as it may give error in the caller SP
--SELECT * FROM #line_item_premium_fees

--Find out maximum as of date per line_item _type, per book, per CP for same month, same year of as_of_date
SELECT CASE @fee_premium WHEN 1 THEN 20303 WHEN 2 THEN 20304 END item_type, @run_as_of_date as_of_date, dbo.FNAGetContractMonth(MAX(li_max_aod.max_as_of_date)) as_of_date, li.book_id, li.counterparty_id, MAX(li.tou) tou, li.line_item, SUM(li.[value]) [value], li.line_item_type
FROM #line_item_premium_fees li
INNER JOIN (
	SELECT MAX(as_of_date) max_as_of_date, book_id, counterparty_id, line_item_type
	FROM #line_item_premium_fees
	GROUP BY book_id, counterparty_id, line_item_type
) li_max_aod ON li.as_of_date = li_max_aod.max_as_of_date
	AND li.counterparty_id = li_max_aod.counterparty_id
	AND li.book_id = li_max_aod.book_id
	AND li.line_item_type = li_max_aod.line_item_type
GROUP BY li.book_id, li.counterparty_id, li.line_item, li.line_item_type
