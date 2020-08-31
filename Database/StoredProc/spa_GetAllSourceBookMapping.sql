IF OBJECT_ID(N'spa_GetAllSourceBookMapping', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_GetAllSourceBookMapping]
 GO 


--===========================================================================================
--This Procedure returns all source book mapping entries
--Input Parameters:
-- book_id Int


--===========================================================================================

-- DROP PROC spa_GetAllSourceBookMapping
-- EXEC spa_GetAllSourceBookMapping  10
-- EXEC spa_GetAllSourceBookMapping  10, 'h'
-- EXEC spa_GetAllSourceBookMapping  10, 'i'
-- EXEC spa_GetAllSourceBookMapping  NULL, NULL, 'a', 311

CREATE PROCEDURE [dbo].[spa_GetAllSourceBookMapping]  
	@book_id VARCHAR(500) = NULL,
	@hedge_item_flag CHAR(1) = NULL,
	@hedge_rel_type_flag CHAR(1) = NULL,
	@book_deal_type_map_id INT = NULL

AS
set nocount on

DECLARE @sql_stmt VARCHAR(5000), @debug_on char(1) = null

--########### Group Label

DECLARE @group1 VARCHAR(100),@group2 VARCHAR(100),@group3 VARCHAR(100),@group4 VARCHAR(100)
 IF EXISTS(SELECT group1,group2,group3,group4 FROM source_book_mapping_clm)
BEGIN	
	SELECT @group1=group1,@group2=group2,@group3=group3,@group4=group4 FROM source_book_mapping_clm
END
ELSE
BEGIN
	SET @group1='Group1'
	SET @group2='Group2'
	SET @group3='Group3'
	SET @group4='Group4'
 
END
--######## End

IF @hedge_rel_type_flag='Y'
	BEGIN
	SET @sql_stmt = '
	SELECT     source_system_book_map.book_deal_type_map_id AS ID, portfolio_hierarchy.entity_name +'' | '' +source_book.source_book_name +'' | ''+  
	         source_book_1.source_book_name +'' | ''+ source_book_2.source_book_name +'' | ''+ source_book_3.source_book_name +'' | ''+ deal_type.code as group1
	FROM       source_system_book_map INNER JOIN
	           source_book ON source_system_book_map.source_system_book_id1 = source_book.source_book_id INNER JOIN
	           source_book source_book_1 ON source_system_book_map.source_system_book_id2 = source_book_1.source_book_id INNER JOIN
	           source_book source_book_2 ON source_system_book_map.source_system_book_id3 = source_book_2.source_book_id INNER JOIN
	           source_book source_book_3 ON source_system_book_map.source_system_book_id4 = source_book_3.source_book_id INNER JOIN
	           static_data_value deal_type ON source_system_book_map.fas_deal_type_value_id = deal_type.value_id  INNER JOIN
		   portfolio_hierarchy ON portfolio_hierarchy.entity_id = source_system_book_map.fas_book_id
	WHERE  1=1 '+CASE WHEN @book_id IS NOT NULL THEN ' AND (source_system_book_map.fas_book_id IN (' + CAST(@book_id AS VARCHAR) + ')) ' ELSE '' END
	END
ELSE IF @hedge_rel_type_flag = 'a'
BEGIN
--	SELECT	source_system_book_id1, source_system_book_id2, source_system_book_id3, source_system_book_id4 
--	FROM	source_system_book_map
--	WHERE	book_deal_type_map_id = @book_deal_type_map_id
	SET @sql_stmt = '
	SELECT     source_book.source_book_id
				, source_book.source_book_name
				, source_book_1.source_book_id
				, source_book_1.source_book_name
				, source_book_2.source_book_id
				, source_book_2.source_book_name
				, source_book_3.source_book_id
				, source_book_3.source_book_name
	FROM       source_system_book_map INNER JOIN
	           source_book ON source_system_book_map.source_system_book_id1 = source_book.source_book_id INNER JOIN
	           source_book source_book_1 ON source_system_book_map.source_system_book_id2 = source_book_1.source_book_id INNER JOIN
	           source_book source_book_2 ON source_system_book_map.source_system_book_id3 = source_book_2.source_book_id INNER JOIN
	           source_book source_book_3 ON source_system_book_map.source_system_book_id4 = source_book_3.source_book_id INNER JOIN
	           static_data_value deal_type ON source_system_book_map.fas_deal_type_value_id = deal_type.value_id  INNER JOIN
		   portfolio_hierarchy ON portfolio_hierarchy.entity_id = source_system_book_map.fas_book_id
	WHERE     (source_system_book_map.book_deal_type_map_id = ' + CAST(@book_deal_type_map_id AS VARCHAR) + ') '
	EXEC spa_print @sql_stmt, @debug_on
	EXEC (@sql_stmt)
	RETURN
END


ELSE IF @hedge_rel_type_flag = 'v'--virtual storage
BEGIN
	SET @sql_stmt = '
	SELECT source_book.source_book_id
		, source_book.source_book_name
		, source_book_1.source_book_id
		, source_book_1.source_book_name
		, source_book_2.source_book_id
		, source_book_2.source_book_name
		, source_book_3.source_book_id
		, source_book_3.source_book_name
		, source_system_book_map.fas_book_id as [Fas Id]
		, ph1.entity_id [subsidiary id]
		, ph1.entity_name AS subsidiary
		, ph2.entity_id [strategy id]
		, ph2.entity_name AS strategy
		, ph3.entity_id [book id]
		, ph3.entity_name AS book
	FROM source_system_book_map 
		INNER JOIN source_book ON source_system_book_map.source_system_book_id1 = source_book.source_book_id 
		INNER JOIN source_book source_book_1 ON source_system_book_map.source_system_book_id2 = source_book_1.source_book_id 
		INNER JOIN source_book source_book_2 ON source_system_book_map.source_system_book_id3 = source_book_2.source_book_id 
		INNER JOIN source_book source_book_3 ON source_system_book_map.source_system_book_id4 = source_book_3.source_book_id 
		INNER JOIN static_data_value deal_type ON source_system_book_map.fas_deal_type_value_id = deal_type.value_id  
		INNER JOIN portfolio_hierarchy ph3 ON ph3.entity_id = source_system_book_map.fas_book_id
		INNER JOIN portfolio_hierarchy ph2 ON ph2.entity_id = ph3.parent_entity_id
		INNER JOIN portfolio_hierarchy ph1 ON ph1.entity_id = ph2.parent_entity_id
	WHERE (source_system_book_map.book_deal_type_map_id = ' + CAST(@book_deal_type_map_id AS VARCHAR) + ') '
	EXEC spa_print @sql_stmt, @debug_on
	EXEC (@sql_stmt)
	RETURN
END	
	
ELSE IF @hedge_rel_type_flag='s'
	BEGIN
		DECLARE @login_user VARCHAR(50)
		SET @login_user = dbo.FNADBUser()
	SET @sql_stmt = '
	SELECT     source_system_book_map.book_deal_type_map_id AS ID, portfolio_hierarchy.entity_name +'' | '' +source_book.source_book_name +'' | ''+  
	         source_book_1.source_book_name +'' | ''+ source_book_2.source_book_name +'' | ''+ source_book_3.source_book_name +'' | ''+ deal_type.code as group1
	FROM       source_system_book_map INNER JOIN
	           source_book ON source_system_book_map.source_system_book_id1 = source_book.source_book_id INNER JOIN
	           source_book source_book_1 ON source_system_book_map.source_system_book_id2 = source_book_1.source_book_id INNER JOIN
	           source_book source_book_2 ON source_system_book_map.source_system_book_id3 = source_book_2.source_book_id INNER JOIN
	           source_book source_book_3 ON source_system_book_map.source_system_book_id4 = source_book_3.source_book_id INNER JOIN
	           static_data_value deal_type ON source_system_book_map.fas_deal_type_value_id = deal_type.value_id  INNER JOIN
		   portfolio_hierarchy ON portfolio_hierarchy.entity_id = source_system_book_map.fas_book_id
	WHERE     (source_system_book_map.fas_book_id IN (
				SELECT	ph3.entity_id 
				FROM	portfolio_hierarchy ph1
						INNER JOIN portfolio_hierarchy ph2 
							ON ph2.parent_entity_id = ph1.entity_id
						INNER JOIN portfolio_hierarchy ph3 
							ON ph3.parent_entity_id = ph2.entity_id
						LEFT JOIN application_functional_users afu 
							ON (afu.entity_id = ph1.entity_id OR afu.entity_id IS NULL)  
							AND afu.function_id = 10131000
				WHERE	1=1 '
				--+ CASE WHEN @login_user = 'farrms_admin' THEN '' ELSE ' AND afu.login_id = ''' + @login_user + '''' END
				+ '
				UNION
				SELECT	DISTINCT ph3.entity_id 
				FROM	portfolio_hierarchy ph1
						INNER JOIN portfolio_hierarchy ph2 
							ON ph2.parent_entity_id = ph1.entity_id
						INNER JOIN portfolio_hierarchy ph3 
							ON ph3.parent_entity_id = ph2.entity_id
						LEFT JOIN application_functional_users afu 
							ON (afu.entity_id = ph1.entity_id OR afu.entity_id IS NULL) 
							AND afu.function_id = 10131000
						INNER JOIN application_security_role asr 
							ON afu.role_id = asr.role_id
						INNER JOIN application_role_user aru 
							ON aru.role_id = asr.role_id
				WHERE	1=1 '
				--+ CASE WHEN @login_user = 'farrms_admin' THEN '' ELSE ' AND aru.user_login_id = ''' + @login_user + '''' END
				+ '	
	
	)) '
	END
ELSE
	BEGIN
	SET @sql_stmt = '
		SELECT     source_system_book_map.book_deal_type_map_id AS ID, portfolio_hierarchy.entity_name AS Book,
	           source_book.source_book_name AS ['+@group1+'], 
	           source_book_1.source_book_name AS ['+@group2+'], source_book_2.source_book_name AS ['+@group3+'], 
		   source_book_3.source_book_name AS ['+@group4+'], deal_type.code As Type,fas_deal_type_value_id FasType
	FROM       source_system_book_map INNER JOIN
	           source_book ON source_system_book_map.source_system_book_id1 = source_book.source_book_id INNER JOIN
	           source_book source_book_1 ON source_system_book_map.source_system_book_id2 = source_book_1.source_book_id INNER JOIN
	           source_book source_book_2 ON source_system_book_map.source_system_book_id3 = source_book_2.source_book_id INNER JOIN
	           source_book source_book_3 ON source_system_book_map.source_system_book_id4 = source_book_3.source_book_id INNER JOIN
	           static_data_value deal_type ON source_system_book_map.fas_deal_type_value_id = deal_type.value_id  INNER JOIN
		   portfolio_hierarchy ON portfolio_hierarchy.entity_id = source_system_book_map.fas_book_id
	WHERE     (source_system_book_map.fas_book_id IN( ' + CAST(@book_id AS VARCHAR) + ')) '


	END

IF @hedge_item_flag IS NOT NULL 
BEGIN
	IF @hedge_item_flag = 'h'
		SET @sql_stmt = @sql_stmt + ' and source_system_book_map.fas_deal_type_value_id = 400'
	ELSE IF @hedge_item_flag = 'i'
		SET @sql_stmt = @sql_stmt + ' and source_system_book_map.fas_deal_type_value_id = 401'
	ELSE IF @hedge_item_flag = 'e'
		SET @sql_stmt = @sql_stmt + ' and source_system_book_map.fas_deal_type_value_id not in (400,401,402,404,409)'
END 
ELSE
		SET @sql_stmt = @sql_stmt + ' and source_system_book_map.fas_deal_type_value_id  in (400,401,402,404,409)'

EXEC spa_print @sql_stmt, @debug_on
EXEC (@sql_stmt)














