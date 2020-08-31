IF OBJECT_ID(N'[dbo].[spa_var_measurement_criteria_detail]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].spa_var_measurement_criteria_detail
GO

/****** Object:  StoredProcedure [dbo].[spa_var_measurement_criteria_detail]    Script Date: 06/11/2011 21:27:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_var_measurement_criteria_detail]
	@flag CHAR(1),
    @var_measure_criteria_id INT = NULL, 
    @var_measure_name VARCHAR(5000) = NULL,
    @measure INT = NULL,
    @var_approach INT = NULL,
    @category INT = NULL,
    @confidence_interval INT = NULL,
    @holding_days INT = NULL,
    @price_curve_source INT = NULL,
    @no_of_simulations INT = NULL,
    @market_credit_correlation INT = NULL,
    @data_series INT = NULL,
    @active_delta CHAR(1) = NULL,
    @active_notional CHAR(1) = NULL,
    @active CHAR(1) = NULL,
    @var_cor CHAR(1) = NULL,
    @trader INT = NULL,
    @as_of_date DATETIME = NULL,
    @tenor_type CHAR(1) = NULL,
    @tenor_from VARCHAR(10) = NULL,
    @tenor_to VARCHAR(10) = NULL,
    @hold_to_maturity CHAR(1) = NULL,
    @term_start DATETIME = NULL,
    @term_end DATETIME = NULL,
	@volatility_source INT = NULL,
	@filter_value  VARCHAR(MAX) = NULL
AS

SET NOCOUNT ON
DECLARE @idoc INT,
		@sql VARCHAR(MAX),
		@tmp_id  INT,
		@sql_select varchar(MAX)

SELECT @filter_value = NULLIF(NULLIF(@filter_value, '<FILTER_VALUE>'), '')

IF @flag = 's'
BEGIN
	SET @sql = '
	SELECT	vmcd.id [ID]
			, dbo.FNAHyperLinkText(10181210, name, id) AS [Name]
			, measure.code [Measure]
			, var_app.code [Approach]
			, category.code [Category] 
			, confidence.code [Confidence Interval]
			, vmcd.holding_period [Holding Period]
			, vmcd.simulation_days [Simulation Days]
			, price_curve_source.code [Price Curve Source]
			, daily_return_data_series.code [Data Series]
			, vmcd.market_credit_correlation [Market Credit Correlation]
			, CASE WHEN vmcd.include_options_delta = ''y'' THEN ''Yes'' ELSE ''No'' END [Delta]
			, CASE WHEN vmcd.include_options_notional = ''y'' THEN ''Yes'' ELSE ''No'' END [Notional]
			, CASE WHEN vmcd.active = ''y'' THEN ''Yes'' ELSE ''No'' END [Active]
			, CASE WHEN vmcd.vol_cor = NULL THEN ''''
					WHEN vmcd.vol_cor = ''r'' THEN ''Use Most Recent Value.''
					WHEN vmcd.vol_cor = ''v'' THEN ''Use Value As of Date.''
					ELSE '''' END [Var/Cor/Ret]
			, st.trader_name [Trader]
			, CASE WHEN vmcd.hold_to_maturity = ''y'' THEN ''Yes'' ELSE ''No'' END [Hold to Maturity]
			, vs.code [Volatility Source] 
	FROM var_measurement_criteria_detail vmcd
	LEFT JOIN static_data_value var_app ON var_app.value_id = vmcd.var_approach
	LEFT JOIN static_data_value category ON category.value_id = vmcd.category
	LEFT JOIN static_data_value confidence ON confidence.value_id = vmcd.confidence_interval
	LEFT JOIN static_data_value price_curve_source ON price_curve_source.value_id = vmcd.price_curve_source
	LEFT JOIN static_data_value daily_return_data_series ON daily_return_data_series.value_id = vmcd.daily_return_data_series
	LEFT JOIN static_data_value measure ON measure.value_id = vmcd.measure
	LEFT JOIN static_data_value vs ON vs.value_id = vmcd.volatility_source
	LEFT JOIN source_traders st ON st.source_trader_id = vmcd.trader
	WHERE 1 = 1 ' 
	
	IF @as_of_date IS NOT NULL 
	SET @sql  = @sql + 'AND dbo.FNACovertToSTDDate(vmcd.create_ts) <= ''' + CAST(@as_of_date AS VARCHAR(20)) + ''''
	
	IF @active IS NOT NULL
	SET @sql = @sql + ' AND vmcd.[active] = ''' + @active + ''''
	
	IF @category IS NOT NULL
	SET @sql = @sql + ' AND vmcd.category = ' + CAST(@category AS VARCHAR(500))  
	
	IF @measure IS NOT NULL
	SET @sql = @sql + ' AND vmcd.measure = ' + CAST(@measure AS VARCHAR(500))  
	
	--PRINT @sql 
	EXEC(@sql)
END
IF @flag = 'n'
BEGIN
	SET @sql = '
	SELECT	vmcd.id [ID], name AS [Name]
	FROM var_measurement_criteria_detail vmcd
	LEFT JOIN static_data_value var_app ON var_app.value_id = vmcd.var_approach
	LEFT JOIN static_data_value category ON category.value_id = vmcd.category
	LEFT JOIN static_data_value confidence ON confidence.value_id = vmcd.confidence_interval
	LEFT JOIN static_data_value price_curve_source ON price_curve_source.value_id = vmcd.price_curve_source
	LEFT JOIN static_data_value daily_return_data_series ON daily_return_data_series.value_id = vmcd.daily_return_data_series
	LEFT JOIN static_data_value measure ON measure.value_id = vmcd.measure
	LEFT JOIN static_data_value vs ON vs.value_id = vmcd.volatility_source
	LEFT JOIN source_traders st ON st.source_trader_id = vmcd.trader
	WHERE 1 = 1 ' 
	
	IF @as_of_date IS NOT NULL 
	SET @sql  = @sql + 'AND dbo.FNACovertToSTDDate(vmcd.create_ts) <= ''' + CAST(@as_of_date AS VARCHAR(20)) + ''''
	
	IF @active IS NOT NULL
	SET @sql = @sql + ' AND vmcd.[active] = ''' + @active + ''''
	
	IF @category IS NOT NULL
	SET @sql = @sql + ' AND vmcd.category = ' + CAST(@category AS VARCHAR(500))  
	
	IF @measure IS NOT NULL
	SET @sql = @sql + ' AND vmcd.measure = ' + CAST(@measure AS VARCHAR(500))  

	SET @sql = @sql + ' ORDER BY name ASC'
	
	--PRINT @sql 
	EXEC(@sql)
END
IF @flag = 'x'
BEGIN
	
	SELECT	vmcd.id [risk_measure_id]
			, [name]
			, measure.code [measure]
			, var_app.code [approach]
			, category.code [category] 
			, confidence.code [confidence_interval]
			, vmcd.holding_period [holding_period]
			, vmcd.simulation_days [simulation_days]
			, price_curve_source.code [price_curve_source]
			, daily_return_data_series.code [data_series]
	FROM var_measurement_criteria_detail vmcd
	LEFT JOIN static_data_value var_app ON var_app.value_id = vmcd.var_approach
	LEFT JOIN static_data_value category ON category.value_id = vmcd.category
	LEFT JOIN static_data_value confidence ON confidence.value_id = vmcd.confidence_interval
	LEFT JOIN static_data_value price_curve_source ON price_curve_source.value_id = vmcd.price_curve_source
	LEFT JOIN static_data_value daily_return_data_series ON daily_return_data_series.value_id = vmcd.daily_return_data_series
	LEFT JOIN static_data_value measure ON measure.value_id = vmcd.measure
	LEFT JOIN source_traders st ON st.source_trader_id = vmcd.trader
	WHERE 1 = 1 
	ORDER BY [name] ASC
	
	
END
IF @flag = 'g' --combo values for dhtmlx
BEGIN
	SET @sql = '
	SELECT	vmcd.id [ID]
			, vmcd.name [Measure]
	FROM var_measurement_criteria_detail vmcd
	LEFT JOIN static_data_value measure ON measure.value_id = vmcd.measure
	WHERE 1 = 1 AND active=''y'' AND measure.code = ''PFE''' 
	
	IF @measure IS NOT NULL
	SET @sql = @sql + ' AND vmcd.measure = ' + CAST(@measure AS VARCHAR(500))  
	
	EXEC(@sql)
END
ELSE IF  @flag = 'a'
BEGIN
	SELECT	vmcd.[name]
			, vmcd.category
			, vmcd.include_options_delta
			, vmcd.include_options_notional
			, vmcd.market_credit_correlation
			, vmcd.var_approach
			, vmcd.simulation_days
			, vmcd.confidence_interval
			, vmcd.holding_period
			, vmcd.price_curve_source
			, vmcd.daily_return_data_series
			, vmcd.[active]
			, vmcd.vol_cor
			, vmcd.measure
			, vmcd.trader
			, vmcd.tenor_type 
			, vmcd.tenor_from
			, vmcd.tenor_to
			, vmcd.hold_to_maturity
			, CAST(vmcd.term_start AS date) [term_start]
			, CAST(vmcd.term_end AS date) [term_end]
			, vmcd.volatility_source 			
	FROM var_measurement_criteria_detail vmcd
	WHERE vmcd.id = @var_measure_criteria_id 
END
ELSE IF @flag = 'c'
BEGIN
	DECLARE @copied_new_id INT
	-- insert into var_measurement_criteria_detail
	INSERT INTO var_measurement_criteria_detail
	(
	[name],
	category,
	include_options_delta,
	include_options_notional,
	market_credit_correlation,
	var_approach,
	simulation_days,
	confidence_interval,
	holding_period,
	price_curve_source,
	daily_return_data_series,
	[active],
	vol_cor,
	measure,
	trader,
	tenor_type,
	tenor_from,
	tenor_to,
	hold_to_maturity,
	term_start, 
	term_end,
	volatility_source
	)
	SELECT	'Copy of ' + [name],vmcd.category, vmcd.include_options_delta,
			vmcd.include_options_notional, vmcd.market_credit_correlation,
			vmcd.var_approach, vmcd.simulation_days, vmcd.confidence_interval,
			vmcd.holding_period, vmcd.price_curve_source, vmcd.daily_return_data_series,
			vmcd.[active], vmcd.vol_cor, vmcd.measure, vmcd.trader, vmcd.tenor_type, vmcd.tenor_from, vmcd.tenor_to, vmcd.hold_to_maturity
			,vmcd.term_start, vmcd.term_end, vmcd.volatility_source
	FROM var_measurement_criteria_detail vmcd
	WHERE vmcd.id = @var_measure_criteria_id
       
		
	SET @copied_new_id =  SCOPE_IDENTITY()
	
	--insert into var_measurement_criteria
	INSERT INTO var_measurement_criteria (var_criteria_id, book_id)
	SELECT @copied_new_id, vmc.book_id  FROM var_measurement_criteria vmc WHERE vmc.var_criteria_id = @var_measure_criteria_id
	
	INSERT INTO var_measurement_deal (var_criteria_id, deal_id)
	SELECT @copied_new_id, vmd.deal_id FROM var_measurement_deal vmd WHERE vmd.var_criteria_id = @var_measure_criteria_id
	
	IF @@ERROR <> 0
	BEGIN
		EXEC spa_ErrorHandler @@ERROR
			, 'VaR criteria Measurement Detail criteria'
			, 'spa_var_measurement_criteria_detail'
			, 'DB ERROR'
			, 'Copied  OF VaR criteria Measurement Detail criteria  failed.'
			, ''
		RETURN
	END
	ELSE 
		EXEC spa_ErrorHandler 0
			, 'VaR Criteria Measurement Detail Criteria'
			, 'spa_var_measurement_criteria_detail'
			, 'Success'
			, 'VaR Criteria Measurement Detail Criteria  successfully Copied.'
			, @copied_new_id
END
IF @flag = 'i'
BEGIN
	
	IF EXISTS(SELECT 1 FROM var_measurement_criteria_detail WHERE [name] = @var_measure_name)
	BEGIN
		EXEC spa_ErrorHandler -1
			, 'VaR Criteria Measurement Detail Criteria'
			, 'spa_var_measurement_criteria_detail'
			, 'DB Error'
			, 'VaR Criteria Name already exists.'
			, @copied_new_id
		RETURN
	END
	INSERT INTO var_measurement_criteria_detail
	(
		[name],
		category,
		include_options_delta,
		include_options_notional,
		market_credit_correlation,
		var_approach,
		simulation_days,
		confidence_interval,
		holding_period,
		price_curve_source,
		daily_return_data_series,
		[active],
		vol_cor,
		measure,
		trader,
		tenor_type,
		tenor_from,
		tenor_to,
		hold_to_maturity,
		term_start, 
		term_end,
		volatility_source
	)
	VALUES
	(
		@var_measure_name,
		@category,
		@active_delta,
		@active_notional,
		@market_credit_correlation,
		@var_approach,
		@no_of_simulations,
		@confidence_interval,
		@holding_days,
		@price_curve_source,
		@data_series,
		@active,
		@var_cor,
		@measure,
		@trader,
		@tenor_type,
		@tenor_from,
		@tenor_to,
		@hold_to_maturity,
		@term_start,
		@term_end,
		@volatility_source
	)

	IF @@ERROR <> 0
	BEGIN
		EXEC spa_ErrorHandler @@ERROR
			, 'VaR criteria Measurement Detail criteria'
			, 'spa_var_measurement_criteria_detail'
			, 'DB ERROR'
			, 'Insertion of VaR criteria Measurement Detail criteria failed.'
			, ''
		RETURN
	END
	ELSE 
	BEGIN
		SET @tmp_id =  SCOPE_IDENTITY()
		EXEC spa_ErrorHandler 0
			, 'VaR Criteria Measurement Detail Criteria'
			, 'spa_var_measurement_criteria_detail'
			, 'Success'
			, 'VaR Criteria Measurement Detail Criteria successfully inserted.'
			, @tmp_id
	END
END

ELSE IF @flag='u'
BEGIN TRY
	IF EXISTS(SELECT 1 FROM var_measurement_criteria_detail WHERE [name] = @var_measure_name AND id <> @var_measure_criteria_id)
	BEGIN
		EXEC spa_ErrorHandler -1
			, 'VaR Criteria Measurement Detail Criteria'
			, 'spa_var_measurement_criteria_detail'
			, 'DB Error'
			, 'VaR Criteria Name already exists.'
			, @copied_new_id
		RETURN
	END
	BEGIN TRAN
	UPDATE var_measurement_criteria_detail
	SET
		[name] = @var_measure_name,
		category = @category,
		include_options_delta = @active_delta,
		include_options_notional = @active_notional,
		market_credit_correlation = @market_credit_correlation,
		var_approach = @var_approach,
		simulation_days = @no_of_simulations,
		confidence_interval = @confidence_interval,
		holding_period = @holding_days,
		price_curve_source = @price_curve_source,
		daily_return_data_series = @data_series,
		[active] = @active,
		vol_cor = @var_cor,
		measure = @measure,
		trader = @trader,
		tenor_type = @tenor_type,
		tenor_from = @tenor_from,
		tenor_to = @tenor_to,
		hold_to_maturity = @hold_to_maturity,
		term_start = @term_start,
		term_end = @term_end,
		volatility_source = @volatility_source
	WHERE id = @var_measure_criteria_id
	
	IF @measure = 17355
	BEGIN
		DELETE FROM var_measurement_deal WHERE var_criteria_id = @var_measure_criteria_id
		DELETE FROM var_measurement_criteria WHERE var_criteria_id = @var_measure_criteria_id	
	END
	
	COMMIT
	
	EXEC spa_ErrorHandler 0
			, 'VaR Criteria Measurement Detail Criteria'
			, 'spa_var_measurement_criteria_detail'
			, 'Success'
			, 'VaR Criteria Measurement Detail Criteria successfully updated.'
			, @var_measure_criteria_id
	
END TRY
BEGIN CATCH
	ROLLBACK
	EXEC spa_ErrorHandler -1
			, 'VaR criteria Measurement Detail criteria'
			, 'spa_var_measurement_criteria_detail'
			, 'DB ERROR'
			, 'Update of VaR criteria Measurement Detail criteria failed.'
			, ''
END CATCH
ELSE IF @flag = 'd'
	BEGIN
	BEGIN TRAN
	DELETE ltc FROM limit_tracking_curve ltc 
	INNER JOIN limit_tracking lt ON lt.limit_id = ltc.limit_id
		AND lt.var_crit_det_id = @var_measure_criteria_id 
	
	DELETE cc FROM  curve_correlation cc
	INNER JOIN  vol_cor_header vch ON vch.id = cc.vol_cor_header_id
		AND vch.var_criteria_id = @var_measure_criteria_id
	DELETE cv 
	FROM  curve_volatility cv
		INNER JOIN  vol_cor_header vch ON vch.id = cv.vol_cor_header_id
			AND vch.var_criteria_id = @var_measure_criteria_id

	
	DELETE FROM vol_cor_header WHERE var_criteria_id = @var_measure_criteria_id	
	DELETE FROM dbo.limit_tracking WHERE var_crit_det_id = @var_measure_criteria_id
	DELETE FROM var_measurement_deal WHERE var_criteria_id = @var_measure_criteria_id
	DELETE FROM var_measurement_criteria WHERE var_criteria_id = @var_measure_criteria_id 
	DELETE FROM var_measurement_criteria_detail WHERE id = @var_measure_criteria_id
	
	IF @@ERROR <> 0
		BEGIN
		ROLLBACK
		EXEC spa_ErrorHandler -1
			, 'VaR criteria Measurement Detail criteria'
			, 'spa_var_measurement_criteria_detail'
			, 'DB ERROR'
			, 'Deletion of VaR criteria Measurement Detail criteria failed.'
			, ''
		RETURN
	END
	ELSE 
		COMMIT
		EXEC spa_ErrorHandler 0
			, 'VaR Criteria Measurement Detail Criteria'
			, 'spa_var_measurement_criteria_detail'
			, 'Success'
			, 'VaR Criteria Measurement Detail Criteria  successfully deleted.'
			, ''
	END

	ELSE IF @flag = 'b'
	BEGIN
		SET @sql_select = 'SELECT vmcd.id [value], vmcd.name [label] FROM var_measurement_criteria_detail vmcd' 
		IF @filter_value IS NOT NULL AND @filter_value <> '-1' 
		BEGIN
			 SET @sql_select += ' INNER JOIN dbo.SplitCommaSeperatedValues(''' + @filter_value + ''') s ON s.item = vmcd.id '
		END		
		SET @sql_select += ' WHERE vmcd.[active] = ''y'' order by vmcd.name asc'

		EXEC (@sql_select)
	END
GO