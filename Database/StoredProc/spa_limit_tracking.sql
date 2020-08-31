IF OBJECT_ID('[dbo].[spa_limit_tracking]','p') IS NOT NULL
	DROP PROC [dbo].[spa_limit_tracking]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/***********************************MODIFICATION HISTORY**************************************/
/*AUTHOR		:  VISHWAS KHANAL															 */	
/*DATE			:  02.FEB.2009																 */
/*DESCRIPTION   :  Added the parameters @actionChecked and @proceed and used them in the flag*/
/*				:  'i','u' and 'a'															 */
/*PURPOSE		:  TRM Demo																	 */
/*********************************************************************************************/
/***********************************MODIFICATION HISTORY**************************************/
/*AUTHOR		:  Pawan KC																	 */	
/*DATE			:  06.March.2009															 */
/*DESCRIPTION   :  Added the parameter @limit_option used it to filter the limit types		 */
/*				:  between 'Position and tenor' OR 'Others' 								 */
/*********************************************************************************************/


--select * from limit_tracking
--exec spa_limit_tracking 'i',NULL ,  'trtr',  'b',  1,  69,  NULL,  NULL,  978, 214, '56', '56'
--exec spa_limit_tracking 's',6
CREATE PROC [dbo].[spa_limit_tracking]	
	@flag AS CHAR(1),					
	@id INT = NULL,				
	@limit_name VARCHAR(50) = NULL,
	@limit_for VARCHAR(1) = NULL,
	@trader_id INT = NULL,
	@sub_id INT = NULL,
	@strategy_id INT = NULL,
	@book_id INT = NULL,
	@limit_type INT = NULL,
	@curve_id INT = NULL,
	@limit_value VARCHAR (50) = NULL,
	@var_crit_det_id INT = NULL,
	@counterparty_id INT = NULL,
	@actionChecked CHAR(1) = NULL,
	@proceed CHAR(1) = NULL,
	@limit_option CHAR(1) = NULL

AS 

DECLARE @Sql VARCHAR(5000)
DECLARE @tmp_limit_id INT

IF @flag='i'
BEGIN
	IF EXISTS (SELECT 1 FROM limit_tracking WHERE limit_name = @limit_name)
	BEGIN
		EXEC spa_ErrorHandler -1
			, 'LimitTracking'
			, 'spa_limit_tracking'
			, 'DB Error'
			, 'Limit Name already exists.'
			, ''
		RETURN
	END
	INSERT INTO limit_tracking (
		limit_name,
		limit_for,		
		trader_id,
		limit_type,
		limit_value,
		var_crit_det_id,
		Counterparty_id,
		actionChecked,
		proceed
	)
	VALUES (
		@limit_name,
		@limit_for,		
		@trader_id,
		@limit_type,
		@limit_value,
		@var_crit_det_id,
		@counterparty_id,
		@actionChecked,
		@proceed
	)
        
	SET @tmp_limit_id= SCOPE_IDENTITY()

	IF @@ERROR <> 0
	EXEC spa_ErrorHandler @@ERROR, 'LimitTracking', 
			'spa_limit_tracking', 'DB Error', 
			'Failed to insert Limit Tracking data value.',''
	ELSE
	EXEC spa_ErrorHandler 0, 'LimitTracking ', 
			'spa_limit_tracking', 'Success', 
			'Limit Tracking data value inserted.',@tmp_limit_id
END
ELSE IF @flag = 'a'
BEGIN
	SELECT limit_id,
		limit_name,
		limit_for,		
		trader_id,
		limit_value,		
		limit_type,
		var_crit_det_id,
		Counterparty_id,
		actionChecked,
		proceed
	FROM limit_tracking WHERE limit_id = @id
END
ELSE IF @flag = 's'
BEGIN
	SET @Sql = '
		SELECT limit_id [ID],
			dbo.FNAHyperLinkText(10181310, limit_name, lt.limit_id) AS [Limit Name],
			CASE WHEN (limit_for = ''t'') THEN ''Trader''
				WHEN (limit_for = ''b'') THEN ''Book'' 
				WHEN (limit_for = ''c'') THEN ''Counterparty''
			END [Limit For],
			st.trader_name [Trader Name],
			limit_value [Limit Value],
			sdv.code [Limit Type],
			vmc.name[Criteria Name],
			sc.counterparty_name AS [Counterparty]
		FROM limit_tracking lt
		LEFT JOIN source_traders st on st.source_trader_id = lt.trader_id
		LEFT JOIN static_data_value sdv on sdv.value_id = lt.limit_type
		LEFT JOIN source_counterparty sc on sc.source_counterparty_id = lt.counterparty_id
		LEFT JOIN var_measurement_criteria_detail vmc on vmc.id = lt.var_crit_det_id
		WHERE 1 = 1 '
	IF @trader_id IS NOT NULL
	BEGIN
		SET @Sql = @Sql + 'AND lt.trader_id = ' + CAST(@trader_id AS VARCHAR)
	END
	IF @limit_type IS NOT NULL
	BEGIN
		SET @Sql = @Sql + 'AND lt.limit_type = ' + CAST(@limit_type AS VARCHAR)
	END
	IF @counterparty_id IS NOT NULL
	BEGIN
		SET @Sql = @Sql + 'AND lt.counterparty_id = ' + CAST(@counterparty_id AS VARCHAR)
	END
	IF @trader_id IS NOT NULL
	BEGIN
		SET @Sql = @Sql + 'AND lt.trader_id = ' + CAST(@trader_id AS VARCHAR)
	END
	IF @id IS NOT NULL
	BEGIN
		SET @Sql = @Sql + 'AND lt.limit_id = ' + CAST(@id AS VARCHAR)
	END
	IF @limit_for IS NOT NULL
	BEGIN
		SET @Sql = @Sql + 'AND lt.limit_for = ''' + @limit_for + ''''
	END
	IF @limit_option IS NOT NULL
	BEGIN
		IF @limit_option = 'o'
		BEGIN
			SET @Sql = @Sql + 'AND lt.limit_type != 1581'
		END
		ELSE IF @limit_option='p'
		BEGIN
			SET @Sql = @Sql + 'AND lt.limit_type = 1581'
		END
	END
	EXEC spa_print @Sql
	EXEC(@Sql)
END
ELSE IF @flag = 'u'
BEGIN
	IF EXISTS (SELECT 1 FROM limit_tracking WHERE limit_name = @limit_name AND limit_id <> @id)
	BEGIN
		EXEC spa_ErrorHandler -1
			, 'LimitTracking'
			, 'spa_limit_tracking'
			, 'DB Error'
			, 'Limit Name already exists.'
			, ''
		RETURN
	END
	
	UPDATE limit_tracking
	SET limit_name = @limit_name,
		limit_for = @limit_for,				
		trader_id = @trader_id,
		limit_type = @limit_type,
		limit_value = @limit_value,
		var_crit_det_id = @var_crit_det_id,
		Counterparty_id = @counterparty_id,
		actionChecked = @actionChecked,
		proceed = @proceed
	WHERE limit_id = @id

	IF @@ERROR <> 0
		EXEC spa_ErrorHandler @@ERROR, 'LimitTracking', 
			'spa_limit_tracking', 'DB Error', 
			'Failed to update Limit Tracking data value.', ''
	ELSE
		EXEC spa_ErrorHandler 0, 'LimitTracking ', 
			'spa_limit_tracking', 'Success', 
			'Limit Tracking data value updated.', ''
END
ELSE IF @flag = 'd'
BEGIN
	DELETE FROM limit_tracking WHERE limit_id = @id

	IF @@ERROR <> 0
		EXEC spa_ErrorHandler @@ERROR, 'LimitTracking', 
			'spa_limit_tracking', 'DB Error', 
			'Failed to delete Limit Tracking data value.', ''
	ELSE
		EXEC spa_ErrorHandler 0, 'LimitTracking ', 
			'spa_limit_tracking', 'Success', 
			'Limit delete data value updated.', ''
END

GO