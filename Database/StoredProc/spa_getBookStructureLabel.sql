IF EXISTS (SELECT 1 FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[spa_getBookStructureLabel]') AND [type] IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_getBookStructureLabel]
GO

CREATE PROC [dbo].[spa_getBookStructureLabel] 	
	@field_id VARCHAR(255), 
	@field_value VARCHAR(MAX),
	@book_structure VARCHAR(MAX) OUTPUT
AS
BEGIN
	IF @field_id = 'book_id'
	BEGIN
		SELECT @book_structure = sub.entity_name + '||' + stra.entity_name + '||' + book.entity_name + '||NULL'
		FROM portfolio_hierarchy book
		INNER JOIN portfolio_hierarchy stra ON stra.entity_id = book.parent_entity_id AND stra.hierarchy_level = 1
		INNER JOIN portfolio_hierarchy sub ON sub.entity_id = stra.parent_entity_id AND sub.hierarchy_level = 2
		INNER JOIN dbo.SplitCommaSeperatedValues(@field_value) a ON book.entity_id = a.item
		WHERE  book.hierarchy_level = 0	
	END
	ELSE IF @field_id = 'subbook_id' OR @field_id = 'book_structure'
	BEGIN
		IF OBJECT_ID('tempdb..#tmp_book_str') IS NOT NULL 
			DROP TABLE #tmp_book_str

		SELECT  subsidiary_id = sub.entity_id
				, strategy_id = stra.entity_id
				, book_id = book.entity_id
				, subbook_id = ssbm.book_deal_type_map_id
				, subsidiary = sub.entity_name, strategy = stra.entity_name, book = book.entity_name, logical_name = ssbm.logical_name
		INTO #tmp_book_str
		FROM source_system_book_map ssbm
			INNER JOIN portfolio_hierarchy book ON book.entity_id = ssbm.fas_book_id AND book.hierarchy_level = 0
			INNER JOIN portfolio_hierarchy stra ON stra.entity_id = book.parent_entity_id AND stra.hierarchy_level = 1
			INNER JOIN portfolio_hierarchy sub ON sub.entity_id = stra.parent_entity_id AND sub.hierarchy_level = 2
			inner join dbo.SplitCommaSeperatedValues(@field_value) scsv on scsv.item = ssbm.book_deal_type_map_id
		
		select @book_structure = isnull(subsidiary.subsidiary + '||' + strategy.strategy + '||' + book.book + '||' + logical_name.logical_name, '')
		from (
		SELECT STUFF(
			(SELECT distinct ','  + cast(m.subsidiary_id AS varchar(100))
			from #tmp_book_str m
			FOR XML PATH(''))
		, 1, 1, '') subsidiary_id
		) subsidiary_id
		cross join (
			SELECT STUFF(
			(SELECT distinct ','  + cast(m.strategy_id AS varchar(100))
			from #tmp_book_str m
			FOR XML PATH('')) 
		, 1, 1, '') strategy_id
		) strategy_id
		cross join (
			SELECT STUFF(
			(SELECT distinct ','  + cast(m.book_id AS varchar(100))
			from #tmp_book_str m
			FOR XML PATH('')) 
		, 1, 1, '') book_id
		) book_id
		cross join (
			SELECT STUFF(
			(SELECT distinct ','  + cast(m.subbook_id AS varchar(100))
			from #tmp_book_str m
			FOR XML PATH('')) 
		, 1, 1, '') sub_book_id
		) sub_book_id
		cross join (
			SELECT STUFF(
			(SELECT distinct ','  + m.subsidiary
			from #tmp_book_str m
			FOR XML PATH('')) 
		, 1, 1, '') subsidiary
		) subsidiary
		cross join (
			SELECT STUFF(
			(SELECT distinct ','  + strategy
			from #tmp_book_str m
			FOR XML PATH('')) 
		, 1, 1, '') strategy
		) strategy
		cross join (
			SELECT STUFF(
			(SELECT distinct ','  + m.book
			from #tmp_book_str m
			FOR XML PATH('')) 
		, 1, 1, '') book
		) book
		cross join (
			SELECT STUFF(
			(SELECT distinct ','  + m.logical_name
			from #tmp_book_str m
			FOR XML PATH('')) 
		, 1, 1, '') logical_name
		) logical_name
	END

END