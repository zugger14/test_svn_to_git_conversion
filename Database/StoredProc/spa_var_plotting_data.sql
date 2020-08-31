/****** Object:  StoredProcedure [dbo].[spa_var_plotting_data]    Script Date: 1-Nov-2012 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_var_plotting_data]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_var_plotting_data]
GO
/****** Object:  StoredProcedure [dbo].[spa_var_plotting_data]    Script Date: 1-Nov-2012 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
-- ===========================================================================================================
-- Author: sbohara@pioneersolutionsglobal.com
-- Created date: 1-Nov-2012
-- Description: plotting operation
-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_var_plotting_data]
	 @flag CHAR(1),
	 @var_criteria_id INT, 
	 @as_of_date DATETIME = NULL,
	 @counterparty VARCHAR(100) = NULL,
     @role_id INT = NULL,
     @user_login_id VARCHAR(100) = NULL,
     @user_type VARCHAR(100) = NULL
AS
SET NOCOUNT ON

DECLARE @sql VARCHAR(MAX), @avg_mtm FLOAT, @sum_mtm FLOAT, @holding_period INT, @var_approach  INT, @measure INT, @x_title VARCHAR(50), @var_title VARCHAR(50),
	@vcMTM FLOAT, @mcMTM FLOAT, @allVaR FLOAT, @mtm_value FLOAT, @counterparty_id INT, @hold_to_maturity CHAR(1) -- updated for after decimal digit rounding.

IF OBJECT_ID('tempdb..#tmp_mtm') IS NOT NULL
	DROP TABLE #tmp_mtm
	
CREATE TABLE #tmp_mtm(mtm FLOAT, pdf FLOAT)	

IF @var_criteria_id IS NOT NULL
BEGIN
	SELECT 
		 @var_approach = var_approach,
		 @measure = measure,
		 @holding_period = ISNULL(holding_period, 1),
		 @hold_to_maturity = ISNULL(hold_to_maturity, 'n')
	FROM [dbo].[var_measurement_criteria_detail]
	WHERE id = @var_criteria_id
END

IF @counterparty IS NOT NULL
BEGIN
	SELECT 
		 @counterparty_id = counterparty_id
	FROM [dbo].[pfe_results]
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
	SET @var_title = 'EaR' --edited as per reqrmt on 4/29/2013
END	
ELSE IF @measure = '17352'
BEGIN
	SET @x_title = 'Expected Cashflow'
	SET @var_title = 'CFaR' --edited as per reqrmt on 4/29/2013
END
ELSE IF @measure = '17355'
BEGIN
	SET @x_title = 'Expected Exposure'
	SET @var_title = 'PFE' --edited as per reqrmt on 4/29/2013
END	
ELSE IF @measure = '17357'
BEGIN
	SET @x_title = 'Gross Margin'
	SET @var_title = 'GMaR' --edited as per reqrmt on 4/29/2013
END	
	

IF @measure = '17355'
	SELECT @allVaR = ISNULL(SUM(pfe), 0) FROM pfe_results WHERE criteria_id = @var_criteria_id AND as_of_date = @as_of_date AND counterparty_id = @counterparty_id
ELSE
	IF @measure = '17357'
		SELECT @allVaR = ISNULL(gmar, 0) FROM gmar_results WHERE criteria_id = @var_criteria_id AND as_of_date = @as_of_date
	ELSE
		SELECT @allVaR = ISNULL(VAR, 0) FROM var_results WHERE var_criteria_id = @var_criteria_id AND as_of_date = @as_of_date


IF @allVaR IS NULL
	SET @allVaR = 0
ELSE
	SET @allVaR = @allVaR / SQRT(@holding_period)
	
	SET @sql = 'INSERT INTO #tmp_mtm (mtm, pdf)
		SELECT 
			ISNULL(mtm_value, 0) AS mtm,
			ISNULL(probab_den, 0) AS pdf 
		FROM 
			var_probability_density 
		WHERE 1=1
			AND var_criteria_id = ' + CAST(@var_criteria_id AS VARCHAR) + ' 
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
	
	SELECT @vcMTM = ISNULL(SUM(mtm_value), 0) FROM marginal_var WHERE var_criteria_id = @var_criteria_id AND as_of_date = @as_of_date
		
	IF @measure = '17355'
		SELECT @mcMTM = ISNULL(SUM(mtm_value), 0) FROM mtm_var_simulation WHERE var_criteria_id = @var_criteria_id AND as_of_date = @as_of_date AND counterparty_id = @counterparty_id
	ELSE
		SELECT @mcMTM = ISNULL(SUM(mtm_value), 0) FROM mtm_var_simulation WHERE var_criteria_id = @var_criteria_id AND as_of_date = @as_of_date

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
		var_probability_density
	WHERE 1 = 1
		AND var_criteria_id = ' + CAST(@var_criteria_id AS VARCHAR) + '
		AND as_of_date = ''' + CAST(@as_of_date AS VARCHAR) + ''''
		
	IF @counterparty IS NOT NULL	
		SET @sql = @sql + ' AND counterparty = (SELECT source_counterparty_id FROM source_counterparty WHERE counterparty_name = ''' + CAST(@counterparty AS VARCHAR) + ''')'
		
	--PRINT(@sql)
	EXEC(@sql)	
END
GO