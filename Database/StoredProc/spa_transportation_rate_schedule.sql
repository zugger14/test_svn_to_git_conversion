IF OBJECT_ID(N'spa_transportation_rate_schedule',N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_transportation_rate_schedule]
GO 

/**
	Stored procedure to Insert/Update/Delete Rates in "transportation_rate_schedule" table.

	Parameters
	@flag: Operational flag
	@id: ID			
	@rate_schedule_id: Rate schedule id
	@rate_type_id: Rate type
	@rate: Rate
	@user_name: User name
	@effective_date: Effective Date
	@uom_id: UOM id
	@code: Code
	@description: Description
	@for: For value
*/
CREATE PROC [dbo].[spa_transportation_rate_schedule]	
	@flag AS CHAR(1),	
	@id INT=NULL,				
	@rate_schedule_id INT=NULL,
	@rate_type_id INT=NULL,
	@rate FLOAT=NULL,
	@user_name VARCHAR(50)=NULL,
	@effective_date VARCHAR(10) = NULL,
	@uom_id INT = NULL,
	@code INT = NULL,
	@description VARCHAR(50) = NULL,
	@for CHAR(1) = NULL
AS 
 SET NOCOUNT ON
DECLARE @Sql_Select VARCHAR(5000)

IF @rate IS NULL
	set @rate=0;

IF @flag='i'
BEGIN
	DECLARE @cont1 VARCHAR(100)
	SELECT @cont1= COUNT(*) FROM transportation_rate_schedule WHERE rate_schedule_id=@rate_schedule_id AND rate_type_id = @rate_type_id AND effective_date=@effective_date
	IF (@cont1>0)
	BEGIN
		SELECT 'Error', 'Combination of ''Effective Date'' and ''Charge Type'' already exsists for the selected ''Rate Schedule''.', 
			'spa_transportation_rate_schedule', 'DB Error', 
			'Combination of ''Effective Date'' and ''Charge Type'' already exsists for the selected ''Rate Schedule''.', ''
		RETURN
	END	

	INSERT INTO transportation_rate_schedule
			(
			rate_schedule_id,
			rate_type_id,
			rate,
			create_user,
			create_ts,
			update_user,
			update_ts,
			effective_date,
			uom_id
			)
		VALUES
			(										
			@rate_schedule_id,
			@rate_type_id,		
			@rate,
			@user_name,
			GETDATE(),
			@user_name,
			GETDATE(),
			@effective_date,
			@uom_id
			)

			IF @@Error <> 0
			EXEC spa_ErrorHandler @@Error, 'TransportationRateSchedule', 
					'spa_transportation_rate_schedule', 'DB Error', 
					'Failed to insert transportation rate.', ''
			ELSE
			EXEC spa_ErrorHandler 0, 'TransportationRateSchedule', 
					'spa_transportation_rate_schedule', 'Success', 
					'Transportation Rate inserted.', ''
					
		
END

ELSE IF @flag='a' 
BEGIN
	SELECT id,rate_schedule_id,rate_type_id,rate,CONVERT(VARCHAR,effective_date,101) [effective_date],uom_id FROM transportation_rate_schedule  WHERE id=@id

END

ELSE IF @flag='s' 
BEGIN
	SET @Sql_Select='
			SELECT trs.id,
				trs.rate_schedule_id,
				sdv.value_id AS [Charge Type],
				trs.zone_from,
				trs.zone_to,
				trs.begin_date,
				trs.end_date, 
				CONVERT(VARCHAR(10), trs.effective_date, 120) [Effective Date],
				trs.rate AS Rate,
				'+ CASE 
					WHEN @for = 's' THEN 'trs.rate_granularity, ' 
					ELSE ''
				  END + '
				trs.formula_id,
				trs.formula_name,
				scu.source_currency_id currency_id,		
				su.source_uom_id AS [UOM],
				'+ CASE 
					WHEN @for = 's' THEN 'trs.billing_frequency, ' 
					ELSE ''
				  END + '
				trs.payment_date,
				trs.payment_calendar,
				trs.settlement_date,
				trs.settlement_calendar,
				trs.rate_schedule_type,
				trs.counterparty_id,
				trs.contract_id,
				trs.rec_pay
			FROM transportation_rate_schedule trs
			INNER JOIN static_data_value sdv
				ON sdv.value_id = trs.rate_type_id
			INNER JOIN transportation_rate_category sdv1
				ON sdv1.value_id = trs.rate_schedule_id
			LEFT JOIN source_uom su
				ON su.source_uom_id = trs.uom_id
			LEFT JOIN formula_editor fe
				ON fe.formula_id = trs.formula_id
			LEFT JOIN source_currency scu
				ON scu.source_currency_id = trs.currency_id
			WHERE 1 = 1 
			' +
						CASE 
							WHEN @rate_schedule_id IS NULL THEN '0' 
							ELSE ' AND trs.rate_schedule_id='+ CAST(@rate_schedule_id AS VARCHAR) 
						END

	
	IF @rate_type_id IS NOT NULL
		SET @Sql_Select = @Sql_Select + ' AND trs.rate_type_id='+ CAST(@rate_type_id AS VARCHAR)

	IF @effective_date IS NOT NULL 
		SET @Sql_Select = @Sql_Select + ' AND trs.effective_date='+ dbo.FNASingleQuote(@effective_date)
	
	SET @Sql_Select = @Sql_Select + ' ORDER BY sdv.value_id ASC, trs.effective_date DESC'

	--PRINT @Sql_Select
	EXEC(@Sql_Select)
	
END
ELSE IF @flag='v' 
BEGIN
	SET @Sql_Select='
			SELECT trs.id,
				trs.rate_schedule_id,
				sdv.value_id AS [Charge Type],
				trs.zone_from,
				trs.zone_to,
				trs.begin_date,
				trs.end_date,
				CONVERT(VARCHAR(10), trs.effective_date, 120) [Effective Date],
				trs.rate AS Rate,
				'+ CASE 
					WHEN @for = 's' THEN 'trs.rate_granularity, ' 
					ELSE ''
				  END + '
				trs.formula_id,
				trs.formula_name,
				scu.source_currency_id currency_id,
				su.source_uom_id AS [UOM],
				'+ CASE 
					WHEN @for = 's' THEN 'trs.billing_frequency, ' 
					ELSE ''
				  END + '
				trs.payment_date,
				trs.payment_calendar,
				trs.settlement_date,
				trs.settlement_calendar,
				trs.rate_schedule_type,
				trs.counterparty_id,
				trs.contract_id,
				trs.rec_pay
			FROM variable_charge trs
			INNER JOIN static_data_value sdv
				ON sdv.value_id = trs.rate_type_id
			INNER JOIN transportation_rate_category sdv1
				ON sdv1.value_id = trs.rate_schedule_id
			LEFT JOIN source_uom su
				ON su.source_uom_id = trs.uom_id
			LEFT JOIN formula_editor fe
				ON fe.formula_id = trs.formula_id
			LEFT JOIN source_currency scu
				ON scu.source_currency_id = trs.currency_id
			WHERE 1 = 1 
			' +
						CASE 
							WHEN @rate_schedule_id IS NULL THEN '0' 
							ELSE ' AND trs.rate_schedule_id='+ CAST(@rate_schedule_id AS VARCHAR) 
						END

	
	IF @rate_type_id IS NOT NULL
		SET @Sql_Select = @Sql_Select + ' AND trs.rate_type_id='+ CAST(@rate_type_id AS VARCHAR)

	IF @effective_date IS NOT NULL 
		SET @Sql_Select = @Sql_Select + ' AND trs.effective_date='+ dbo.FNASingleQuote(@effective_date)
	
	SET @Sql_Select = @Sql_Select + ' ORDER BY sdv.value_id ASC, trs.effective_date DESC'

	--PRINT @Sql_Select
	EXEC(@Sql_Select)
	
END
ELSE IF @flag='l'  --list in grid
BEGIN
	SET @Sql_Select='SELECT 
					CONVERT(VARCHAR,trs.effective_date,101) [Effective Date],						
					sdv.Description AS [Charge Type],trs.rate AS Rate,					
					su.uom_desc AS [UOM]
						FROM transportation_rate_schedule trs
					 INNER JOIN static_data_value sdv ON sdv.value_id =trs.rate_type_id
					 INNER JOIN static_data_value sdv1 ON sdv1.value_id =trs.rate_schedule_id
					 LEFT JOIN source_uom su ON su.source_uom_id =trs.uom_id
					 WHERE 1=1' +	
						CASE 
							WHEN @rate_schedule_id IS NULL THEN '0' 
							ELSE ' AND trs.rate_schedule_id='+ CAST(@rate_schedule_id AS VARCHAR) 
						END
	IF @rate_type_id IS NOT NULL
		SET @Sql_Select = @Sql_Select + ' AND trs.rate_type_id='+ CAST(@rate_type_id AS VARCHAR)
	IF @effective_date IS NOT NULL
		SET @Sql_Select = @Sql_Select + ' AND trs.effective_date='+ dbo.FNASingleQuote(@effective_date)

	--PRINT @Sql_Select
	EXEC(@Sql_Select)
	
END

ELSE IF @flag = 'u'
BEGIN
	DECLARE @cont VARCHAR(100)
	SELECT @cont= COUNT(*) FROM transportation_rate_schedule WHERE rate_schedule_id=@rate_schedule_id AND rate_type_id = @rate_type_id AND effective_date=@effective_date AND id <>@id
	IF (@cont>0)
	BEGIN
		SELECT 'Error', 'Combination of ''Effective Date'' and ''Charge Type'' already exsists for the selected ''Rate Schedule''.', 
			'spa_transportation_rate_schedule', 'DB Error', 
			'Combination of ''Effective Date'' and ''Charge Type'' already exsists for the selected ''Rate Schedule''.', ''
		RETURN
	END
	UPDATE transportation_rate_schedule SET rate_schedule_id=@rate_schedule_id, rate_type_id = @rate_type_id, rate = @rate,
	update_user=@user_name, update_ts=GETDATE(),
	effective_date=@effective_date,
	uom_id= @uom_id
	WHERE id = @id
	
	IF @@Error <> 0
		EXEC spa_ErrorHandler @@Error, 'TransportationRateSchedule', 
				'spa_transportation_rate_schedule', 'DB Error', 
				'Failed to update transportation rate.', ''
		ELSE
		EXEC spa_ErrorHandler 0, 'TransportationRateSchedule', 
				'spa_transportation_rate_schedule', 'Success', 
				'Transportation Rate updated.', ''

END

ELSE IF @flag = 'd'
BEGIN
	DELETE FROM transportation_rate_schedule
	WHERE 	id=@id

	IF @@ERROR <> 0
		EXEC spa_ErrorHandler @@ERROR, "TransportationRateSchedule", 
				"spa_transportation_rate_schedule", "DB Error", 
				"Delete of transportation rate failed.", ''
	ELSE
		EXEC spa_ErrorHandler 0, 'TransportationRateSchedule', 
				'spa_transportation_rate_schedule', 'Success', 
				'Transportation rate sucessfully deleted', ''
END
ELSE IF @flag='c'  --list in combo (transportation)
BEGIN
	SELECT	value_id,
		code [Name]
		FROM   transportation_rate_category
	WHERE contract_type IS NULL OR contract_type = 't'
END
ELSE IF @flag='e'  --list in combo (storage)
BEGIN
	SELECT	value_id,
		code [Name]
		FROM   transportation_rate_category
	WHERE contract_type = 's'
END
