IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_get_entity_description]') AND TYPE in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_get_entity_description]
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**
	Get portfolio entity description with entity id and hierarchy level
	Parameters
	@sub_id				: List of Portfolio entity ID
	@hierarchy_level	: Portfolio hierarchy level
*/
CREATE PROC [dbo].[spa_get_entity_description] @sub_id VARCHAR(500) = NULL, @hierarchy_level INT = 1
	
AS

DECLARE @entity_name VARCHAR(250)
DECLARE @all_entity_ids VARCHAR(250)

CREATE TABLE [#temp] (
	[sub_entity_id] [int] NOT NULL ,
	[sub_entity_name] [varchar] (100) COLLATE DATABASE_DEFAULT NOT NULL
) 

SET @all_entity_ids = ''

DECLARE @sql VARCHAR(5000)
SET @sql = '
INSERT INTO #temp 
SELECT entity_id sub_entity_id, entity_name as sub_entity_name 
FROM portfolio_hierarchy 
WHERE entity_id IN (' + ISNULL(@sub_id, '-999999') + ')
'
EXEC(@sql)

IF @hierarchy_level = 2
BEGIN
	DECLARE a_cursor CURSOR
	FOR
	SELECT sub_entity_name AS sub_entity_name
	FROM #temp
	INNER JOIN fas_subsidiaries fs 
		ON fs.fas_subsidiary_id = #temp.sub_entity_id
	LEFT OUTER JOIN source_currency sc 
		ON fs.func_cur_value_id = sc.source_currency_id
	ORDER BY sub_entity_name

	OPEN a_cursor

	FETCH NEXT
	FROM a_cursor
	INTO @entity_name

	WHILE @@FETCH_STATUS = 0 -- book
	BEGIN
		IF @all_entity_ids <> ''
			SET @all_entity_ids = @all_entity_ids + ', '
		SET @all_entity_ids = @all_entity_ids + @entity_name

		FETCH NEXT
		FROM a_cursor
		INTO @entity_name
	END -- end book

	CLOSE a_cursor

	DEALLOCATE a_cursor

	SELECT @all_entity_ids AS ids
END
ELSE
BEGIN
	DECLARE a_cursor CURSOR
	FOR
	SELECT sub_entity_name AS sub_entity_name
	FROM #temp
	ORDER BY sub_entity_name

	OPEN a_cursor

	FETCH NEXT
	FROM a_cursor
	INTO @entity_name

	WHILE @@FETCH_STATUS = 0 -- book
	BEGIN
		IF @all_entity_ids <> ''
			SET @all_entity_ids = @all_entity_ids + ', '
		SET @all_entity_ids = @all_entity_ids + @entity_name

		FETCH NEXT
		FROM a_cursor
		INTO @entity_name
	END -- end book

	CLOSE a_cursor

	DEALLOCATE a_cursor

	SELECT @all_entity_ids AS ids
END







