/****** Object:  StoredProcedure [dbo].[spa_limit_tracking_book]    Script Date: 07/04/2009 19:30:16 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_limit_tracking_book]') AND Type IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_limit_tracking_book]
/****** Object:  StoredProcedure [dbo].[spa_limit_tracking_book]    Script Date: 07/04/2009 19:30:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--select * from limit_tracking_book
--spa_limit_tracking_book 's',21,24
CREATE PROCEDURE [dbo].[spa_limit_tracking_book]
@flag CHAR(1),
@limit_tracking_book_id INT,
@limit_id INT=NULL,
@book_id VARCHAR(MAX)=NULL

AS

DECLARE @sql VARCHAR(2000)
IF @flag = 's'
BEGIN
	set @sql = '
				WITH entity_names(sub_id, stra_id, book_id) AS 
				(
					SELECT sub.entity_id, NULL, NULL  
					FROM portfolio_hierarchy sub WHERE sub.hierarchy_level = 2
					UNION ALL
					SELECT sub.entity_id,  stra.entity_id, NULL 
					FROM portfolio_hierarchy sub
					INNER JOIN portfolio_hierarchy stra ON stra.parent_entity_id= sub.entity_id 
					UNION ALL
					SELECT sub.entity_id,  stra.entity_id, book.entity_id 
					FROM portfolio_hierarchy sub
					INNER JOIN portfolio_hierarchy stra ON stra.parent_entity_id= sub.entity_id 
					INNER JOIN 	portfolio_hierarchy book ON book.parent_entity_id = stra.entity_id
				)

				SELECT ltd.limit_tracking_book_id, sub.entity_name AS [Subsidiary], stra.entity_name AS [Strategy], book.entity_name [Book]
				FROM limit_tracking_book ltd
				INNER JOIN portfolio_hierarchy ph ON ph.entity_id = ltd.book_id
				INNER JOIN entity_names en ON (
					(ph.hierarchy_level = 0 AND en.book_id = ltd.book_id)
					OR
					(ph.hierarchy_level = 1 AND en.stra_id = ltd.book_id AND en.book_id IS NULL)
					OR
					(ph.hierarchy_level = 2 AND en.sub_id = ltd.book_id AND en.stra_id IS NULL AND en.book_id IS NULL)	
				)
				LEFT JOIN portfolio_hierarchy sub ON sub.entity_id = en.sub_id
				LEFT JOIN portfolio_hierarchy stra ON stra.entity_id = en.stra_id
				LEFT JOIN portfolio_hierarchy book ON book.entity_id = en.book_id
				WHERE 1 = 1'
	--SET @sql = '
	--			SELECT  limit_tracking_book_id [ID],
	--					limit_id LimitId,
	--					book_id BookId,
	--					sub.entity_name [Subsidiary],
	--					stra.entity_name [Strategy],
	--					book.entity_name [Book] 
	--			FROM	limit_tracking_book ltb        
	--					LEFT OUTER JOIN  portfolio_hierarchy book ON book.entity_id= ltb.book_id AND book.hierarchy_level = 0
	--					LEFT OUTER JOIN  portfolio_hierarchy stra ON stra.entity_id= ltb.book_id AND stra.hierarchy_level = 1
	--					LEFT OUTER JOIN  portfolio_hierarchy sub ON sub.entity_id= ltb.book_id AND sub.hierarchy_level = 2 
	--			WHERE 1 = 1'
    IF @limit_id IS NOT NULL
	BEGIN
		SET @sql = @sql+ ' AND limit_id = ' + CAST(@limit_id AS VARCHAR)
	END
	EXEC spa_print @sql
	EXEC (@sql)
END
ELSE IF @flag = 'a'
BEGIN
	SET @sql = '
				SELECT	limit_tracking_book_id,limit_id
						,book_id
						,ph.entity_name 
				FROM	limit_tracking_book ltb
				LEFT OUTER JOIN portfolio_hierarchy ph ON ph.entity_id = ltb.book_id 
				WHERE 1 = 1'

	IF @limit_tracking_book_id IS NOT NULL
	BEGIN
		SET @sql = @sql + ' AND limit_tracking_book_id = ' + CAST(@limit_tracking_book_id AS VARCHAR)
	END
   EXEC (@sql)
END
ELSE IF @flag = 'i'
BEGIN
	CREATE TABLE #temp_book_ids (entity_id INT , limit_id INT)	
	INSERT INTO  #temp_book_ids (entity_id, limit_id) 
		(SELECT entity_id, @limit_id  FROM portfolio_hierarchy ph 
		INNER JOIN dbo.SplitCommaSeperatedValues(@book_id) scsv ON scsv.item = ph.entity_id)
	
	INSERT INTO limit_tracking_book(limit_id,book_id) 
	SELECT limit_id, entity_id FROM #temp_book_ids
	
	IF @@ERROR <> 0
	BEGIN
		EXEC spa_ErrorHandler @@ERROR, "LIMIT Tracking Curve", 
				"spa_limit_tracking_book", "DB ERROR", 
				"Insertion  OF counterparty_credit_info failed.", ''
		RETURN
	END

		ELSE EXEC spa_ErrorHandler 0, 'Counterparty Credit Info', 
				'spa_limit_tracking_book', 'Success', 
				'Counterparty Credit Info  successfully inserted.', ''

END
ELSE IF @flag='u'
BEGIN
	UPDATE	limit_tracking_book 
		SET limit_id = @limit_id,
			book_id = @book_id
		WHERE limit_tracking_book_id=@limit_tracking_book_id

		IF @@ERROR <> 0
		BEGIN
			EXEC spa_ErrorHandler @@ERROR, "LIMIT Tracking Curve", 
					"spa_limit_tracking_book", "DB ERROR", 
					"UPDATE  OF counterparty_credit_info failed.", ''
			RETURN
		END
		ELSE 
			EXEC spa_ErrorHandler 0, 'Counterparty Credit Info', 
				'spa_limit_tracking_book', 'Success', 
				'Counterparty Credit Info  successfully updated.', ''
END
ELSE IF @flag='d'
BEGIN
	DELETE FROM limit_tracking_book WHERE limit_tracking_book_id=@limit_tracking_book_id

	IF @@ERROR <> 0
	BEGIN
		EXEC spa_ErrorHandler @@ERROR, "LIMIT Tracking Curve", 
				"spa_limit_tracking_book", "DB ERROR", 
				"Deletion  OF counterparty_credit_info failed.", ''
		RETURN
	END

		ELSE EXEC spa_ErrorHandler 0, 'Counterparty Credit Info', 
				'spa_limit_tracking_book', 'Success', 
				'Counterparty Credit Info  successfully deleted.', ''
END