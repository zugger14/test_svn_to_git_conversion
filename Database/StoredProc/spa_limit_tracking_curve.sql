/****** Object:  StoredProcedure [dbo].[spa_limit_tracking_curve]    Script Date: 12/24/2008 18:18:03 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_limit_tracking_curve]') AND Type IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_limit_tracking_curve]
GO

--select * from limit_tracking_curve
--exec spa_limit_tracking_curve 's',18
CREATE PROCEDURE [dbo].[spa_limit_tracking_curve]
@flag CHAR(1),
@limit_tracking_curve_id INT,
@limit_id INT=NULL,
@curve_id INT=NULL,
@position_limit FLOAT=NULL,
@tenor_limit FLOAT=NULL,
@tenor_month_from INT=NULL,
@tenor_month_to INT=NULL,
@uom_id INT = NULL,
@granularity_id INT = NULL

AS

DECLARE @sql VARCHAR(2000)
IF @flag = 's'
BEGIN
	SET @sql = '
				SELECT	limit_tracking_curve_id [ID]
						, limit_id LimitId
						, ltc.curve_id CurveId
						, curve_name [Curve Name]
						, position_limit [Position Limit]
						, uom.uom_id [UOM]
						, granularity.code [Granularity]
						, tenor_limit [Tenor Limit]
						, tenor_month_from [Tenor Month From]
						, tenor_month_to [Tenor Month To] 
				 FROM	limit_tracking_curve ltc
				 LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = ltc.curve_id
				 LEFT JOIN source_uom uom ON uom.source_uom_id = ltc.uom_id
				 LEFT JOIN static_data_value granularity on granularity.value_id = ltc.granularity_id
				 WHERE 1 = 1'
    IF @limit_id IS NOT NULL
	BEGIN
		SET @sql = @sql + 'AND limit_id = ' + CAST(@limit_id AS VARCHAR)
	END

	IF @curve_id IS NOT NULL
	BEGIN
		SET @sql = @sql + 'AND limit_id = ' + CAST(@curve_id AS VARCHAR)
	END
	
	EXEC spa_print @sql
	EXEC (@sql)
END
ELSE IF @flag = 'a'
BEGIN
	SET @sql='
			SELECT	limit_tracking_curve_id
					,limit_id
					, curve_id
					, position_limit
					, tenor_limit 
					, tenor_month_from
					, tenor_month_to
					, uom_id
					, granularity_id
	        FROM limit_tracking_curve 
			WHERE 1 = 1'

	 IF @limit_tracking_curve_id IS NOT NULL
	BEGIN
		SET @sql = @sql + ' AND limit_tracking_curve_id = ' + CAST(@limit_tracking_curve_id AS VARCHAR)
	END
	EXEC (@sql)
END
ELSE IF @flag = 'i'
BEGIN
	INSERT INTO limit_tracking_curve
			(limit_id,curve_id,position_limit,tenor_limit, tenor_month_from, tenor_month_to, uom_id, granularity_id) 
	VALUES	(@limit_id,@curve_id,@position_limit,@tenor_limit, @tenor_month_from ,@tenor_month_to, @uom_id, @granularity_id)
	
	IF @@ERROR <> 0
	BEGIN
		EXEC spa_ErrorHandler @@ERROR
			, 'LIMIT Tracking Curve'
			, 'spa_limit_tracking_curve'
			, 'DB ERROR'
			, 'Insertion of counterparty_credit_info failed.'
			, ''
		RETURN
	END
	ELSE 
		EXEC spa_ErrorHandler 0
			, 'Counterparty Credit Info'
			, 'spa_limit_tracking_curve'
			, 'Success'
			, 'Counterparty Credit Info  successfully inserted.'
			, ''

END
ELSE IF @flag = 'u'
BEGIN
	UPDATE	limit_tracking_curve 
		SET limit_id = @limit_id,
			curve_id = @curve_id,
			position_limit = @position_limit,
			tenor_limit = @tenor_limit,
			tenor_month_from = @tenor_month_from,
			tenor_month_to = @tenor_month_to, 
			uom_id = @uom_id, 
			granularity_id = @granularity_id
	WHERE limit_tracking_curve_id = @limit_tracking_curve_id

	IF @@ERROR <> 0
	BEGIN
		EXEC spa_ErrorHandler @@ERROR
			, 'LIMIT Tracking Curve'
			, 'spa_limit_tracking_curve'
			, 'DB ERROR'
			, 'Update of counterparty_credit_info failed.'
			, ''
		RETURN
	END
		ELSE EXEC spa_ErrorHandler 0
			, 'Counterparty Credit Info'
			, 'spa_limit_tracking_curve'
			, 'Success'
			, 'Counterparty Credit Info  successfully updated.'
			, ''
END
ELSE IF @flag = 'd'
BEGIN
	DELETE FROM limit_tracking_curve WHERE limit_tracking_curve_id=@limit_tracking_curve_id
	IF @@ERROR <> 0
	BEGIN
		EXEC spa_ErrorHandler @@ERROR
			, 'LIMIT Tracking Curve'
			, 'spa_limit_tracking_curve'
			, 'DB ERROR'
			, 'Deletion of counterparty_credit_info failed.'
			, ''
		RETURN
	END
		ELSE EXEC spa_ErrorHandler 0
			, 'Counterparty Credit Info'
			, 'spa_limit_tracking_curve'
			, 'Success'
			, 'Counterparty Credit Info  successfully deleted.'
			, ''
END


