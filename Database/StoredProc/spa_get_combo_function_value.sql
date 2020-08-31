/****** Object:  StoredProcedure [dbo].[spa_get_combo_function_value]    Script Date: 06/25/2012 11:13:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_get_combo_function_value]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_get_combo_function_value]
GO

-- ===========================================================================================================
-- Author: dmanandhar@pioneersolutionsglobal.com
-- Create date: 2012-06-21
-- Description: Retruns value of the function

-- Params:
-- 
-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_get_combo_function_value]
    @combo_function_id INT,
    @source_deal_header_id INT = NULL,
    @source_deal_detail_id INT = NULL
AS

DECLARE @sql VARCHAR(MAX)

IF @combo_function_id = 9999000
BEGIN
    SET @sql = 'SELECT subs.entity_name
                FROM   source_deal_header sdh
                       INNER JOIN source_deal_detail sdd
                            ON  sdh.source_deal_header_id = sdd.source_deal_header_id
                       LEFT OUTER JOIN source_system_book_map ssbm
                            ON  ssbm.source_system_book_id1 = sdh.source_system_book_id1
                            AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
                            AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
                            AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
                       LEFT OUTER JOIN portfolio_hierarchy book
                            ON  book.entity_id = ssbm.fas_book_id
                       LEFT OUTER JOIN portfolio_hierarchy strat
                            ON  strat.entity_id = book.parent_entity_id
                       LEFT OUTER JOIN portfolio_hierarchy subs
                            ON  subs.entity_id = strat.parent_entity_id
                WHERE 1 = 1 '  
	IF @source_deal_header_id IS NOT NULL 
	BEGIN
		SET @sql = @sql + ' AND sdh.source_deal_header_id = ' + CAST(@source_deal_header_id AS VARCHAR(10)) 		
	END  
	ELSE IF @source_deal_detail_id IS NOT NULL 
	BEGIN
		SET @sql = @sql + ' AND sdd.source_deal_detail_id = ' + CAST(@source_deal_detail_id AS VARCHAR(10)) 		
	END
	
	exec spa_print @sql
	EXEC(@sql)
			
    
END


GO


