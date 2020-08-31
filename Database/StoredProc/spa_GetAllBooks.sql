IF OBJECT_ID(N'spa_GetAllBooks', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_GetAllBooks]
GO 

CREATE PROCEDURE [dbo].[spa_GetAllBooks]
	@strategy_id INT = NULL
AS
	IF @strategy_id IS NOT NULL
	    SELECT book.entity_id AS book_id,
	           book.entity_name AS NAME
	    FROM   portfolio_hierarchy stra
	           INNER JOIN portfolio_hierarchy sub
	                ON  stra.parent_entity_id = sub.entity_id
	           INNER JOIN portfolio_hierarchy book
	                ON  book.parent_entity_id = stra.entity_id
	                AND sub.entity_id = @strategy_id
	ELSE
	    SELECT entity_id,
	           entity_name
	    FROM   portfolio_hierarchy
	    WHERE  entity_type_value_id = 527
	    ORDER BY entity_name
