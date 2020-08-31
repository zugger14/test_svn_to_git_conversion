/*
* date: 29 oct 2013
* purpose: update for whatif configuration
* params:
	@flag char(1) : Operation flag 'a' => select values for distinct row
	@book_deal_type_map_id int : book deal type map id to update source system book id values.
	
*/

IF OBJECT_ID(N'[dbo].[spa_whatif_configuration]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_whatif_configuration]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_whatif_configuration]
    @flag CHAR(1),
    @book_deal_type_map_id INT,
    @template_id INT
AS
 
DECLARE @SQL VARCHAR(MAX)
 
IF @flag = 'a'
BEGIN
    --SELECT A MATCHED ROW FROM THE TABLE
    SELECT	DISTINCT sub.entity_id [sub_id]
			, ssbm.book_deal_type_map_id
			, sdhwh.template_id
	FROM source_deal_header_whatif_hypo sdhwh
	INNER JOIN source_system_book_map ssbm on ssbm.book_deal_type_map_id = sdhwh.book_deal_type_map_id
	INNER JOIN portfolio_hierarchy book ON  book.entity_id = ssbm.fas_book_id
	INNER JOIN portfolio_hierarchy stra ON  stra.entity_id = book.parent_entity_id
	INNER JOIN portfolio_hierarchy sub ON  sub.entity_id = stra.parent_entity_id
END
ELSE IF @flag = 'u'
BEGIN TRY
    --UPDATE STATEMENT GOES HERE
    BEGIN TRAN
    
    UPDATE sdhwh
    SET sdhwh.book_deal_type_map_id = @book_deal_type_map_id,
		sdhwh.source_system_book_id1 = s.ss1,
		sdhwh.source_system_book_id2 = s.ss2,
		sdhwh.source_system_book_id3 = s.ss3,
		sdhwh.source_system_book_id4 = s.ss4,
		sdhwh.template_id = @template_id
	FROM source_deal_header_whatif_hypo sdhwh
	CROSS JOIN (SELECT ssbm.source_system_book_id1 ss1,ssbm.source_system_book_id2 ss2
				,ssbm.source_system_book_id3 ss3,ssbm.source_system_book_id4 ss4
				FROM source_system_book_map ssbm 
				WHERE ssbm.book_deal_type_map_id = @book_deal_type_map_id) s
	
	COMMIT
	EXEC spa_ErrorHandler 0
		, 'whatif_configuration'
		, 'spa_whatif_configuration'
		, 'Success'
		, 'Successfully updated whatif configuration.'
		, ''
END TRY
BEGIN CATCH
	ROLLBACK
	
	EXEC spa_ErrorHandler -1
		, 'whatif_configuration'
		, 'spa_whatif_configuration'
		, 'DB Error'
		, 'Failed to update whatif configuration.'
		, ''
END CATCH

