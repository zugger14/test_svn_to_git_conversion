/* added to delete sp which has no schema name 'dbo' start */
IF OBJECT_ID(N'spa_GetAllSourceBookMapping_hedge_item', N'P') IS NOT NULL
    DROP PROCEDURE spa_GetAllSourceBookMapping_hedge_item
GO 
/* added to delete sp which has no schema name 'dbo' end */

IF OBJECT_ID(N'dbo.spa_GetAllSourceBookMapping_hedge_item', N'P') IS NOT NULL
    DROP PROCEDURE dbo.spa_GetAllSourceBookMapping_hedge_item
GO 

CREATE PROCEDURE dbo.spa_GetAllSourceBookMapping_hedge_item
	@flag CHAR(1),
	@sub_id INT = NULL,
	@hedge_item_flag CHAR(1) = NULL,
	@book_deal_type_map_id INT = NULL
AS
SET NOCOUNT ON
BEGIN
	DECLARE @separator VARCHAR(5)

	IF @flag = 'b' OR @flag = 'p'
	BEGIN
		SET @separator = '|' 
	END
	ELSE
	BEGIN
		SET @separator = 'xxx'
	END

	IF @flag = 's' OR @flag = 'p'
	BEGIN
		DECLARE @sql_stmt  VARCHAR(5000),
				@group1    VARCHAR(100),
				@group2    VARCHAR(100),
				@group3    VARCHAR(100),
				@group4    VARCHAR(100),
				@alias_name VARCHAR(20)
		
		IF @flag = 's'
		BEGIN
			SET @alias_name = 'group1' 
		END
		ELSE
		BEGIN
			SET @alias_name = 'SBM'
		END

		IF EXISTS(
			   SELECT group1,
					  group2,
					  group3,
					  group4
			   FROM   source_book_mapping_clm
		   )
		BEGIN
			SELECT @group1 = group1,
				   @group2 = group2,
				   @group3 = group3,
				   @group4 = group4
			FROM   source_book_mapping_clm
		END
		ELSE
		BEGIN
			SET @group1 = 'Group1'
			SET @group2 = 'Group2'
			SET @group3 = 'Group3'
			SET @group4 = 'Group4'
		END
		
		/*******************to get all book id for subsidiary from @book_id start********************************************/
		
		DECLARE @book_ids VARCHAR(MAX)
		
		SELECT @book_ids = STUFF((SELECT ',' + CAST(book.entity_id AS VARCHAR(10))FROM   portfolio_hierarchy sub
								  INNER JOIN portfolio_hierarchy stra
									   ON  stra.parent_entity_id = sub.entity_id
								  INNER JOIN portfolio_hierarchy book
									   ON  book.parent_entity_id = stra.entity_id
									   AND sub.entity_id = @sub_id 
										   FOR XML PATH('')),1,1,'')
			
		
		SET @sql_stmt = 'SELECT source_system_book_map.book_deal_type_map_id AS ID
								, source_book.source_book_name + ''' + @separator + '''
								+ source_book_1.source_book_name +''' + @separator + '''
								+ source_book_2.source_book_name + ''' + @separator + ''' 
								+ source_book_3.source_book_name + ''' + @separator + ''' 
								+ deal_type.code AS ' + @alias_name + '
						FROM   source_system_book_map 
						INNER JOIN source_book ON source_system_book_map.source_system_book_id1 = source_book.source_book_id 
						INNER JOIN source_book source_book_1 ON source_system_book_map.source_system_book_id2 = source_book_1.source_book_id 
						INNER JOIN source_book source_book_2 ON source_system_book_map.source_system_book_id3 = source_book_2.source_book_id 
						INNER JOIN source_book source_book_3 ON source_system_book_map.source_system_book_id4 = source_book_3.source_book_id 
						INNER JOIN static_data_value deal_type ON source_system_book_map.fas_deal_type_value_id = deal_type.value_id  
						INNER JOIN portfolio_hierarchy ON portfolio_hierarchy.entity_id = source_system_book_map.fas_book_id
						WHERE source_system_book_map.fas_book_id IN (' + CAST(@book_ids AS VARCHAR(MAX)) + ')'
		
		--PRINT @sql_stmt
		IF @hedge_item_flag IS NOT NULL
		BEGIN
			IF @hedge_item_flag = 'h'
				SET @sql_stmt = @sql_stmt + 
					' AND source_system_book_map.fas_deal_type_value_id = 400'
			ELSE 
			IF @hedge_item_flag = 'i'
				SET @sql_stmt = @sql_stmt + 
					' AND source_system_book_map.fas_deal_type_value_id = 401'
					--ELSE IF @hedge_item_flag = 'e'
					--    SET @sql_stmt = @sql_stmt + ' AND source_system_book_map.fas_deal_type_value_id NOT IN (400, 401, 402, 404, 409)'
		END
		ELSE
			SET @sql_stmt = @sql_stmt + 
				' AND source_system_book_map.fas_deal_type_value_id  IN (400, 401, 402, 404, 405, 406, 407, 408, 409, 410, 411)'
		
		SET @sql_stmt = @sql_stmt + 
			' ORDER BY source_book.source_book_name, source_book_1.source_book_name, source_book_2.source_book_name, source_book_3.source_book_name'
		
		--PRINT @sql_stmt
		EXEC (@sql_stmt)
	END
	ELSE IF @flag = 'a' OR @flag = 'b'
	BEGIN
		SELECT	source_system_book_map.book_deal_type_map_id AS ID,
				source_book.source_book_name + @separator 
			   + source_book_1.source_book_name + @separator 
			   + source_book_2.source_book_name + @separator 
			   + source_book_3.source_book_name + @separator 
			   + deal_type.code AS group1
			   , sub.entity_id
			   , sub.entity_name
			   , sub.hierarchy_level
		FROM   source_system_book_map
		INNER JOIN source_book ON source_system_book_map.source_system_book_id1 = source_book.source_book_id
		INNER JOIN source_book source_book_1 ON  source_system_book_map.source_system_book_id2 = source_book_1.source_book_id
		INNER JOIN source_book source_book_2 ON  source_system_book_map.source_system_book_id3 = source_book_2.source_book_id
		INNER JOIN source_book source_book_3 ON  source_system_book_map.source_system_book_id4 = source_book_3.source_book_id
		INNER JOIN static_data_value deal_type ON  source_system_book_map.fas_deal_type_value_id = deal_type.value_id
		INNER JOIN portfolio_hierarchy ON  portfolio_hierarchy.entity_id = source_system_book_map.fas_book_id
		INNER JOIN portfolio_hierarchy stra ON stra.entity_id = portfolio_hierarchy.parent_entity_id
		INNER JOIN portfolio_hierarchy sub ON sub.entity_id = stra.parent_entity_id
		WHERE book_deal_type_map_id = @book_deal_type_map_id
				AND source_system_book_map.fas_deal_type_value_id = CASE WHEN @hedge_item_flag = 'h' THEN 400 ELSE 401 END 
	END
ELSE IF @flag = 'x'
	BEGIN
		
		IF EXISTS(
			   SELECT group1,
					  group2,
					  group3,
					  group4
			   FROM   source_book_mapping_clm
		   )
		BEGIN
			SELECT @group1 = group1,
				   @group2 = group2,
				   @group3 = group3,
				   @group4 = group4
			FROM   source_book_mapping_clm
		END
		ELSE
		BEGIN
			SET @group1 = 'Group1'
			SET @group2 = 'Group2'
			SET @group3 = 'Group3'
			SET @group4 = 'Group4'
		END
		
		/*******************to get all book id for subsidiary from @book_id start********************************************/
		
		SELECT @book_ids = STUFF((SELECT ',' + CAST(book.entity_id AS VARCHAR(10))FROM   portfolio_hierarchy sub
								  INNER JOIN portfolio_hierarchy stra
									   ON  stra.parent_entity_id = sub.entity_id
								  INNER JOIN portfolio_hierarchy book
									   ON  book.parent_entity_id = stra.entity_id
									   AND sub.entity_id = @sub_id 
										   FOR XML PATH('')),1,1,'')
			
		
		SET @sql_stmt = 'SELECT source_system_book_map.book_deal_type_map_id AS ID
								, source_book.source_book_name + '' | ''
								+ source_book_1.source_book_name +'' | ''
								+ source_book_2.source_book_name + '' | '' 
								+ source_book_3.source_book_name + '' |  '' 
								+ deal_type.code AS group1
						FROM   source_system_book_map 
						INNER JOIN source_book ON source_system_book_map.source_system_book_id1 = source_book.source_book_id 
						INNER JOIN source_book source_book_1 ON source_system_book_map.source_system_book_id2 = source_book_1.source_book_id 
						INNER JOIN source_book source_book_2 ON source_system_book_map.source_system_book_id3 = source_book_2.source_book_id 
						INNER JOIN source_book source_book_3 ON source_system_book_map.source_system_book_id4 = source_book_3.source_book_id 
						INNER JOIN static_data_value deal_type ON source_system_book_map.fas_deal_type_value_id = deal_type.value_id  
						INNER JOIN portfolio_hierarchy ON portfolio_hierarchy.entity_id = source_system_book_map.fas_book_id
						WHERE source_system_book_map.fas_book_id IN (' + CAST(@book_ids AS VARCHAR(MAX)) + ')'
		
		IF @hedge_item_flag IS NOT NULL
		BEGIN
			IF @hedge_item_flag = 'h'
				SET @sql_stmt = @sql_stmt + 
					' AND source_system_book_map.fas_deal_type_value_id = 400'
			ELSE 
			IF @hedge_item_flag = 'i'
				SET @sql_stmt = @sql_stmt + 
					' AND source_system_book_map.fas_deal_type_value_id = 401'
					--ELSE IF @hedge_item_flag = 'e'
					--    SET @sql_stmt = @sql_stmt + ' AND source_system_book_map.fas_deal_type_value_id NOT IN (400, 401, 402, 404, 409)'
		END
		ELSE
			SET @sql_stmt = @sql_stmt + 
				' AND source_system_book_map.fas_deal_type_value_id  IN (400, 401, 402, 404, 405, 406, 407, 408, 409, 410, 411)'
		
		SET @sql_stmt = @sql_stmt + 
			' ORDER BY source_book.source_book_name, source_book_1.source_book_name, source_book_2.source_book_name, source_book_3.source_book_name'
		
		EXEC spa_print @sql_stmt
		EXEC (@sql_stmt)
	END
END

	