IF OBJECT_ID(N'[dbo].[spa_var_measurement_criteria]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_var_measurement_criteria]
GO

/****** Object:  StoredProcedure [dbo].[spa_var_measurement_criteria]    Script Date: 07/04/2009 19:25:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
/*
 EXEC [spa_var_measurement_criteria] 's', null, 21, null
* */
CREATE PROCEDURE [dbo].[spa_var_measurement_criteria]
	@flag CHAR(1),
	@id VARCHAR(50) = NULL,
	@var_criteria_id INT = NULL,
	@book_id VARCHAR(500) = NULL
AS

DECLARE @sql VARCHAR(1000)

IF @flag = 's'
BEGIN
	SET @sql = 'SELECT	vmc.id [ID],
						vmc.var_criteria_id [Var Criteria ID],
						vmcd.name [VaR Description],
						ph2.entity_name [Subsidiary], 
						ph1.entity_name [Strategy] ,
						ph.entity_name [Book] 
				FROM  var_measurement_criteria vmc
               -- inner join var_measurement_criteria_detail vmcd1 on vmcd1.id=vmc.var_criteria_id
				LEFT OUTER JOIN portfolio_hierarchy ph ON vmc.book_id=ph.entity_id
				LEFT OUTER JOIN portfolio_hierarchy ph1 ON ph1.entity_id=  ph.parent_entity_id
				LEFT OUTER JOIN portfolio_hierarchy ph2 ON ph2.entity_id=  ph1.parent_entity_id
                LEFT OUTER JOIN var_measurement_criteria_detail vmcd on vmcd.id=vmc.var_criteria_id      
				WHERE 1 = 1 '

	IF @id IS NOT NULL 
	BEGIN 
		SET @sql = @sql + ' AND id=' + CAST(@id AS VARCHAR)
	END
  
	IF @var_criteria_id  IS NOT NULL 
	BEGIN 
		SET @sql = @sql + ' AND var_criteria_id =' + CAST(@var_criteria_id  AS VARCHAR)
	END
EXEC(@sql)
END
IF @flag = 'x'
BEGIN
	SET @sql = 'SELECT	vmc.id [ID],
						vmc.var_criteria_id [Var Criteria ID],
						vmcd.name [VaR Description],
						ph2.entity_id [Subsidiary], 
						ph1.entity_id [Strategy] ,
						ph.entity_id [Book] 
				FROM  var_measurement_criteria vmc
               -- inner join var_measurement_criteria_detail vmcd1 on vmcd1.id=vmc.var_criteria_id
				LEFT OUTER JOIN portfolio_hierarchy ph ON vmc.book_id=ph.entity_id
				LEFT OUTER JOIN portfolio_hierarchy ph1 ON ph1.entity_id=  ph.parent_entity_id
				LEFT OUTER JOIN portfolio_hierarchy ph2 ON ph2.entity_id=  ph1.parent_entity_id
                LEFT OUTER JOIN var_measurement_criteria_detail vmcd on vmcd.id=vmc.var_criteria_id      
				WHERE 1 = 1 '

	IF @id IS NOT NULL 
	BEGIN 
		SET @sql = @sql + ' AND id=' + CAST(@id AS VARCHAR)
	END
  
	IF @var_criteria_id  IS NOT NULL 
	BEGIN 
		SET @sql = @sql + ' AND var_criteria_id =' + CAST(@var_criteria_id  AS VARCHAR)
	END
EXEC(@sql)
END
ELSE IF @flag = 'a'
BEGIN
	SET @sql='SELECT id, var_criteria_id, book_id FROM var_measurement_criteria WHERE 1 = 1 '

	IF @id IS NOT NULL 
	BEGIN 
		SET @sql = @sql + ' AND id=' + CAST(@id AS VARCHAR)
	END
EXEC(@sql)
END
ELSE IF @flag = 'i'
BEGIN
	SET @sql = 'INSERT INTO var_measurement_criteria(var_criteria_id, book_id)
				select ' + CAST(@var_criteria_id AS VARCHAR) + ', fas_book_id 
				FROM fas_books where fas_book_id IN(' + @book_id  + ')'
	EXEC spa_print @sql
	EXEC(@sql)

	IF @@ERROR <> 0
	BEGIN
		EXEC spa_ErrorHandler @@ERROR
			, 'VaR criteria Measurement criteria'
			, 'spa_var_measurement_criteria'			
			, 'DB ERROR'
			, 'Insetion  OF VaR criteria Measurement criteria  failed.'
			, ''
		RETURN
	END
	ELSE 
		EXEC spa_ErrorHandler 0
			, 'VaR Criteria Measurement  Criteria'
			, 'spa_var_measurement_criteria'
			, 'Success'
			, 'VaR Criteria Measurement Criteria successfully inserted.'
			, ''
END
ELSE IF @flag = 'u'
BEGIN
	UPDATE	var_measurement_criteria 
		SET var_criteria_id = @var_criteria_id,
			book_id = @book_id
	WHERE id = @id
		
	IF @@ERROR <> 0
	BEGIN
		EXEC spa_ErrorHandler @@ERROR
			, 'VaR criteria Measurement criteria'
			, 'spa_var_measurement_criteria'
			, 'DB ERROR'
			, 'UPDATE  OF VaR criteria Measurement criteria  failed.'
			, ''
		RETURN
	END
	ELSE 
		EXEC spa_ErrorHandler 0
			, 'VaR Criteria Measurement Criteria'
			, 'spa_var_measurement_criteria'
			, 'Success'
			, 'VaR Criteria Measurement Criteria successfully updated.'
			, ''

END
ELSE IF @flag = 'd'
BEGIN
	SET @sql = 'DELETE FROM var_measurement_criteria WHERE id IN( ' + @id + ' )'
	EXEC(@sql)
	
	IF @@ERROR <> 0
	BEGIN
		EXEC spa_ErrorHandler @@ERROR
			, 'VaR criteria Measurement criteria'
			, 'spa_var_measurement_criteria'
			, 'DB ERROR'
			, 'Deletion  OF VaR criteria Measurement criteria  failed.'
			, ''
		RETURN
	END
	ELSE 
		EXEC spa_ErrorHandler 0
			, 'VaR Criteria Measurement Criteria'
			, 'spa_var_measurement_criteria'
			, 'Success'
			, 'VaR Criteria Measurement Criteria successfully deleted.'
			, ''
END
GO