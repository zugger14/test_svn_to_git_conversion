/****** Object:  StoredProcedure [dbo].[spa_var_plotting_data_whatif]    Script Date: 1-Nov-2012 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_var_plotting_data_whatif]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_var_plotting_data_whatif]
GO
/****** Object:  StoredProcedure [dbo].[spa_var_plotting_data_whatif]    Script Date: 1-Nov-2012 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
-- ===========================================================================================================
-- Author: sligal@pioneersolutionsglobal.com
-- Created date: 5-April-2013
-- Description: plotting operation for VAR whatif
-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_var_plotting_data_whatif]
	 @flag CHAR(1),
	 @var_criteria_id INT, 
	 @as_of_date DATETIME = NULL,
	 @counterparty VARCHAR(100) = NULL,
	 @measure INT = NULL,
     @role_id INT = NULL,
     @user_login_id VARCHAR(100) = NULL,
     @user_type VARCHAR(100) = NULL
AS
SET NOCOUNT ON

DECLARE @sql VARCHAR(MAX), @avg_mtm FLOAT, @sum_mtm FLOAT, @holding_period INT, @var_approach  INT, @x_title VARCHAR(50), @var_title VARCHAR(50),
	@vcMTM FLOAT, @mcMTM FLOAT, @allVaR FLOAT, @mtm_value FLOAT, @counterparty_id INT, @hold_to_maturity CHAR(1) -- updated for after decimal digit rounding.

IF OBJECT_ID('tempdb..#tmp_mtm') IS NOT NULL
	DROP TABLE #tmp_mtm
	
CREATE TABLE #tmp_mtm(mtm FLOAT, pdf FLOAT)

IF @var_criteria_id IS NOT NULL
BEGIN
	SELECT 
		 @var_approach = CASE WHEN wcm.[Var] = 'y' THEN wcm.var_approach ELSE 1522 END,
		 @holding_period = ISNULL(wcm.holding_days, 1),
		 @hold_to_maturity = ISNULL(mwc.hold_to_maturity, 'n')
	FROM maintain_whatif_criteria mwc 
	INNER JOIN [dbo].[whatif_criteria_measure] wcm ON mwc.criteria_id = wcm.criteria_id
	WHERE mwc.criteria_id = @var_criteria_id
END

IF @counterparty IS NOT NULL
BEGIN
	SELECT 
		 @counterparty_id = counterparty_id
	FROM [dbo].[pfe_results_whatif]
	WHERE criteria_id = @var_criteria_id
		AND counterparty = CAST(@counterparty AS VARCHAR)
END

IF @measure = '17351'
BEGIN
	SET @x_title = 'MTM'
	SET @var_title = CASE WHEN @hold_to_maturity = 'y' THEN 'HTM VaR' ELSE '1-Day VaR' END	
END
ELSE IF @measure = '17353'
BEGIN
	SET @x_title = 'Expected Earnings'
	SET @var_title = 'EaR'
END	
ELSE IF @measure = '17352'
BEGIN
	SET @x_title = 'Expected Cashflow'
	SET @var_title = 'CFaR'
END
ELSE IF @measure = '17355'
BEGIN
	SET @x_title = 'Expected Exposure'
	SET @var_title = 'PFE'
END	
ELSE IF @measure = '17357'
BEGIN
	SET @x_title = 'Gross Margin'
	SET @var_title = 'GMaR'
END
	

CREATE TABLE #new_mtm (new_mtm FLOAT, probab_den FLOAT)

IF @measure = '17355' --pfe
	SELECT @allVaR = ISNULL(SUM(pfe), 0) FROM pfe_results_whatif WHERE criteria_id = @var_criteria_id AND as_of_date = @as_of_date AND counterparty_id = @counterparty_id
ELSE IF @measure = '17352' --cfar
	SELECT @allVaR = ISNULL(cfar, 0) FROM cfar_results_whatif WHERE whatif_criteria_id = @var_criteria_id AND as_of_date = @as_of_date	
ELSE IF @measure = '17353' --ear
	SELECT @allVaR = ISNULL(ear, 0) FROM ear_results_whatif WHERE whatif_criteria_id = @var_criteria_id AND as_of_date = @as_of_date
ELSE IF @measure = '17357' --gmar
	SELECT @allVaR = ISNULL(gmar, 0) FROM gmar_results_whatif WHERE whatif_criteria_id = @var_criteria_id AND as_of_date = @as_of_date	
ELSE --var
	SELECT @allVaR = ISNULL(VAR, 0) FROM var_results_whatif WHERE whatif_criteria_id = @var_criteria_id AND as_of_date = @as_of_date


IF @allVaR IS NULL
	SET @allVaR = 0
ELSE
	SET @allVaR = @allVaR / SQRT(@holding_period)	
	
SET @sql = 'INSERT INTO #tmp_mtm (mtm, pdf)
SELECT 
	ISNULL(mtm_value, 0) AS mtm,
	ISNULL(probab_den, 0) AS pdf 
FROM 
	var_probability_density_whatif 
WHERE 1=1
	AND whatif_criteria_id = ' + CAST(@var_criteria_id AS VARCHAR) + ' 
	AND measure = ' + CAST(@measure AS VARCHAR) + '
	AND as_of_date = ''' + CAST(@as_of_date AS VARCHAR) + ''''
	
IF @counterparty IS NOT NULL	
	SET @sql = @sql + ' AND counterparty = (SELECT source_counterparty_id FROM source_counterparty WHERE counterparty_name = ''' + CAST(@counterparty AS VARCHAR) + ''')'

--PRINT(@sql)
EXEC(@sql)	
	
IF @flag = 's'
BEGIN
	SELECT mtm, pdf FROM #tmp_mtm ORDER BY mtm ASC
END
ELSE IF @flag ='m'
BEGIN
	--SELECT @var_approach,@measure
	SELECT @vcMTM = ISNULL(SUM(mtm_value), 0) FROM marginal_var_whatif WHERE whatif_criteria_id = @var_criteria_id AND as_of_date = @as_of_date
		
	IF @measure = '17355' --pfe
		SELECT @mcMTM = ISNULL(SUM(pfe), 0) FROM mtm_pfe_simulation_whatif WHERE whatif_criteria_id = @var_criteria_id AND as_of_date = @as_of_date AND counterparty_id = @counterparty_id
	ELSE IF @measure = '17352' --cfar
		SELECT @mcMTM = ISNULL(SUM(cash_flow), 0) FROM mtm_cfar_simulation_whatif WHERE whatif_criteria_id = @var_criteria_id AND as_of_date = @as_of_date
	ELSE IF @measure = '17353' --ear
		SELECT @mcMTM = ISNULL(SUM(earning), 0) FROM mtm_ear_simulation_whatif WHERE whatif_criteria_id = @var_criteria_id AND as_of_date = @as_of_date
	ELSE IF @measure = '17357' --gmar
		SELECT @mcMTM = ISNULL(SUM(cash_flow), 0) FROM mtm_gmar_simulation_whatif WHERE whatif_criteria_id = @var_criteria_id AND as_of_date = @as_of_date
	ELSE --var
		SELECT @mcMTM = ISNULL(SUM(mtm_value), 0) FROM mtm_var_simulation_whatif WHERE whatif_criteria_id = @var_criteria_id AND as_of_date = @as_of_date
--SELECT @mcMTM
	IF @measure = '17351'
	BEGIN
		IF @var_approach = '1520'
			SET @mtm_value = @vcMTM
		ELSE
			SET @mtm_value = @mcMTM	
	END
	ELSE
	BEGIN
		SELECT @mtm_value = AVG(mtm) FROM #tmp_mtm
	END		

	SET @sql = '	
	SELECT 
		MIN(mtm_value) xmin, 
		MAX(mtm_value) xmax, 
		0 ymin, 
		(MAX(probab_den)*1.1) ymax,
		' + CONVERT(VARCHAR(100), ROUND(@mtm_value, 4), 2) + ' mtm_avg,
		''' + CAST(@x_title AS VARCHAR) + ''' AS x_title,
		''' + CAST(@var_title AS VARCHAR) + ''' AS var_title,
		' + CONVERT(VARCHAR(100),
				CASE WHEN @measure = '17355' THEN 
					ROUND(@allVaR, 4) 
				ELSE 
					ROUND((@mtm_value - @allVaR), 4) 
				END, 2) 
		+ ' var_avg,
		' + CONVERT(VARCHAR(100), ROUND(@allVaR, 4), 2) + ' allVar
	FROM 
		var_probability_density_whatif
	WHERE 1 = 1
		AND measure = ' + CAST(@measure AS VARCHAR) + '
		AND whatif_criteria_id = ' + CAST(@var_criteria_id AS VARCHAR) + '
		AND as_of_date = ''' + CAST(@as_of_date AS VARCHAR) + ''''
		
	IF @counterparty IS NOT NULL	
		SET @sql = @sql + ' AND counterparty = (SELECT source_counterparty_id FROM source_counterparty WHERE counterparty_name = ''' + CAST(@counterparty AS VARCHAR) + ''')'
		
	--PRINT(@sql)
	EXEC(@sql)	
END
GO