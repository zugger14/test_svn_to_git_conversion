
/****** Object:  StoredProcedure [dbo].[spa_counterparty_limits_report]    Script Date: 02/08/2010 23:23:46 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_counterparty_limits_report]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_counterparty_limits_report]

/****** Object:  StoredProcedure [dbo].[spa_counterparty_limits_report]    Script Date: 02/08/2010 23:23:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[spa_counterparty_limits_report] 
	@summary_detail_option	CHAR(1)			='s',  -- 's'- summary, 'd' detail 
	@as_of_date				VARCHAR(20),
	@counterparty_ids		VARCHAR(max)	=	NULL,
	@risk_bucket_header_id	INT				=	NULL,
	@risk_bucket_detail_id	INT				=	NULL,
	@group_option			CHAR(1)			=	NULL,
	@group_limit			CHAR(1)			=	NULL,
	@risk_rating			INT				=	NULL,
	@debt_rating			INT				=	NULL,
	@industry_type1			INT				=	NULL,
	@industry_type2			INT				=	NULL,
	@sic_code				INT				=	NULL,
	@account_status			INT				=	NULL,
	@drill_counterparty		VARCHAR(500)	=	NULL,
	@drill_bucket			VARCHAR(30)		=	NULL,
	@drill_volume_limit_type VARCHAR(100)	=	NULL,	
	@volume					VARCHAR(500)	=	NULL,
	@term_start				VARCHAR(500)	=	NULL,
	@term_end				VARCHAR(500)	=	NULL,
	@purchase_sell			CHAR(1)			=	NULL
AS
SET NOCOUNT ON

/**********TEST SCRIPT START********************/
--DECLARE @as_of_date 			AS VARCHAR(20)
--DECLARE @counterparty_ids		AS VARCHAR(max)
--DECLARE @risk_bucket_header_id	AS INT			
--DECLARE @risk_bucket_detail_id	AS INT			
--DECLARE @tenor_bucket_value		AS INT			
--DECLARE @rating_id				AS INT			
--DECLARE @group_option	AS CHAR(1)		
--DECLARE @group_limit			AS CHAR(1)		
--DECLARE @risk_rating			AS INT			
--DECLARE @debt_rating			AS INT			
--DECLARE @industry_type1			AS INT			
--DECLARE @industry_type2			AS INT			
--DECLARE @sic_code				AS INT			
--DECLARE @account_status			AS INT
--
--SET @as_of_date = '2009-12-16'
--SET @risk_bucket_header_id = 1
--SET @group_option = 'c'
--SET @risk_bucket_detail_id = 1

/**********TEST SCRIPT END********************/


DECLARE @cols				NVARCHAR(2000)
DECLARE @sql				VARCHAR(MAX)
DECLARE @sql_group_by		VARCHAR(2000)
DECLARE @sql_order_by		VARCHAR(2000)
DECLARE @sql_esp_cols		VARCHAR(1000)
DECLARE @tenor_from			VARCHAR(100)
DECLARE @tenor_to			VARCHAR(100)

SET @sql_esp_cols = ''
SET @sql_order_by = ''

SET @purchase_sell=case @purchase_sell when 'p' then 'b' when 's' then 's' else null end

IF @summary_detail_option='s'
BEGIN
		IF DATEDIFF(month, @as_of_date, ISNULL(@term_start,'1900-1-1')) < 12
		BEGIN
			SET @tenor_from = DATEDIFF(month, @as_of_date, ISNULL(@term_start,'1900-1-1'))
		END
		ELSE IF DATEDIFF(month, @as_of_date, ISNULL(@term_start,'1900-1-1')) >= 12
		BEGIN
			SET @tenor_from = DATEDIFF(year, @as_of_date, ISNULL(@term_start,'1900-1-1'))*12
		END
			
			
		IF DATEDIFF(month, @as_of_date, ISNULL(@term_end,'2099-1-1')) < 12
		BEGIN
			SET @tenor_to = DATEDIFF(month, @as_of_date, ISNULL(@term_end,'2099-1-1'))
		END
		ELSE IF DATEDIFF(month, @as_of_date, ISNULL(@term_end,'2099-1-1')) >= 12
		BEGIN
			SET @tenor_to = DATEDIFF(year, @as_of_date, ISNULL(@term_end,'2099-1-1'))*12
		END
		
		CREATE TABLE #temp_risk_tenor_bucket_detail
			(	bucket_detail_id INT ,
				bucket_header_id INT,
				tenor_name VARCHAR(50) COLLATE DATABASE_DEFAULT,
				tenor_description VARCHAR(100) COLLATE DATABASE_DEFAULT,
				tenor_from INT,
				tenor_to INT,
				fromMonthYear CHAR(1) COLLATE DATABASE_DEFAULT,
				toMonthYear CHAR(1) COLLATE DATABASE_DEFAULT)
				
		INSERT INTO #temp_risk_tenor_bucket_detail(bucket_detail_id, bucket_header_id, tenor_name, tenor_description, tenor_from, tenor_to, fromMonthYear, toMonthYear)
		SELECT	rtbd.bucket_detail_id, rtbd.bucket_header_id, rtbd.tenor_name, rtbd.tenor_description,
				CASE WHEN rtbd.fromMonthYear= 'm' THEN rtbd.tenor_from ELSE rtbd.tenor_from*12 END,
				CASE WHEN rtbd.toMonthYear='m' THEN rtbd.tenor_to ELSE rtbd.tenor_to*12 END,
				rtbd.fromMonthYear, rtbd.toMonthYear
		  FROM risk_tenor_bucket_detail rtbd WHERE rtbd.bucket_header_id = @risk_bucket_header_id
		
		SELECT @cols = COALESCE(@cols + ', ', '') + '[' + t.tenor_name + ']'
			FROM #temp_risk_tenor_bucket_detail t
		WHERE	t.bucket_header_id = @risk_bucket_header_id
				AND t.bucket_detail_id = (CASE WHEN @risk_bucket_detail_id IS NOT NULL THEN @risk_bucket_detail_id ELSE t.bucket_detail_id END)
				AND t.tenor_to >= @tenor_from		
				AND	t.tenor_from <= @tenor_to 
		ORDER BY bucket_detail_id

		SET @cols = ISNULL(@cols, '[0]')

		IF @group_option = 'r' --Internal Rating
		BEGIN
			SET @sql_esp_cols = 'Rating'
			SET @sql_group_by = 'int_rating.value_id, clcr.purchase_sales, rtbd.bucket_detail_id'
			SET @sql_order_by = 'Rating, [Type]'
		END
		ELSE IF @group_option = 'd' --Detailed Report
		BEGIN
			SET @sql_esp_cols = 'sc.counterparty_name AS Counterparty, Rating'
			SET @sql_group_by = 'sc.source_counterparty_id, int_rating.value_id, clcr.purchase_sales, rtbd.bucket_detail_id'
			SET @sql_order_by = 'Counterparty, Rating, [Type]'
		END
		ELSE --default: c: counterparty
		BEGIN
			SET @sql_esp_cols = 'sc.counterparty_name AS Counterparty, Rating AS [Internal Rating]'
			SET @sql_group_by = 'sc.source_counterparty_id, int_rating.value_id, clcr.purchase_sales, rtbd.bucket_detail_id'
			SET @sql_order_by = 'Counterparty, [Type]'
		END
				
		--SELECT @cols
		SET @sql = 'SELECT ' + @sql_esp_cols + ', [Type], ' + @cols + '
					FROM
					(
					SELECT MAX(sc.source_counterparty_id) source_counterparty_id, MAX(int_rating.code) AS Rating
					, (CASE ISNULL(clcr.purchase_sales, '''') WHEN ''b'' THEN ''Purchases'' WHEN ''s'' THEN ''Sales'' ELSE ''Net'' END) AS [Type]
					, MAX(rtbd.tenor_name) AS tenor_name
					, MAX(clcr.credit_available) AS credit_available
					FROM counterparty_limit_calc_result clcr
					LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = clcr.counterparty_id
					LEFT JOIN #temp_risk_tenor_bucket_detail rtbd ON clcr.Buck_id = rtbd.bucket_detail_id
					LEFT JOIN counterparty_credit_info cci ON cci.Counterparty_id = sc.source_counterparty_id
					LEFT JOIN static_data_value limit_type ON limit_type.value_id = clcr.limit_type
					LEFT JOIN static_data_value int_rating ON int_rating.value_id = clcr.internal_rating
					LEFT JOIN static_data_value industry_type1 ON industry_type1.value_id = cci.industry_type1
					LEFT JOIN static_data_value industry_type2 ON int_rating.value_id = cci.industry_type2
					LEFT JOIN static_data_value sic ON sic.value_id = cci.sic_Code
					LEFT JOIN static_data_value debt_rating ON debt_rating.value_id = cci.debt_rating
					LEFT JOIN static_data_value account_status ON account_status.value_id = cci.account_status
					LEFT JOIN 
					(
						SELECT counterparty_id, internal_rating AS internal_rating
						, clcr.purchase_sales
						, SUM(clcr.credit_available) AS credit_available
						FROM counterparty_limit_calc_result clcr
						LEFT JOIN #temp_risk_tenor_bucket_detail rtbd ON clcr.buck_id = rtbd.bucket_detail_id					
						WHERE 1=1
						AND rtbd.bucket_header_id = ' + CAST(@risk_bucket_header_id AS VARCHAR)
						+ CASE WHEN @as_of_date IS NOT NULL THEN + ' AND clcr.as_of_date = ''' + @as_of_date + '''' ELSE '' END
						+ CASE WHEN @term_start IS NOT NULL THEN + ' AND rtbd.tenor_to >= ''' + @tenor_from + '''' ELSE '' END
						+ CASE WHEN @term_end IS NOT NULL THEN + ' AND rtbd.tenor_from <= ''' + @tenor_to + '''' ELSE '' END
						+ CASE WHEN @counterparty_ids IS NOT NULL THEN ' AND counterparty_id IN (' +  @counterparty_ids + ') ' ELSE '' END
						+ CASE WHEN @purchase_sell IS NOT NULL THEN ' AND clcr.purchase_sales =''' + @purchase_sell + ''' ' ELSE '' END
						+ ' GROUP BY counterparty_id, internal_rating, clcr.purchase_sales
						) allowed_limit ON clcr.counterparty_id = allowed_limit.counterparty_id
						AND ISNULL(clcr.internal_rating, '''') = ISNULL(allowed_limit.internal_rating, '''')
						AND ISNULL(clcr.purchase_sales, '''') = ISNULL(allowed_limit.purchase_sales, '''')
						
					WHERE 1=1
					AND rtbd.tenor_to >= ''' + @tenor_from +'''
					AND	rtbd.tenor_from <= ''' + @tenor_to + '''
					AND sc.int_ext_flag=''e''
					AND clcr.as_of_date = ''' + @as_of_date + ''''
		
		
		--apply filters
		IF @risk_bucket_header_id IS NOT NULL
			SET @sql = @sql + ' AND rtbd.bucket_header_id = ' + CAST(@risk_bucket_header_id AS VARCHAR)

		IF @risk_bucket_detail_id IS NOT NULL
			SET @sql = @sql + ' AND rtbd.bucket_detail_id IN (' + CAST(@risk_bucket_detail_id AS VARCHAR(30)) + ')'

		IF @counterparty_ids IS NOT NULL
			SET @sql = @sql + ' AND sc.source_counterparty_id IN (' + @counterparty_ids + ')'

		IF @risk_rating IS NOT NULL
			SET @sql = @sql + ' AND cci.risk_rating = ' + CAST(@risk_rating AS VARCHAR(20))

		IF @debt_rating IS NOT NULL
			SET @sql = @sql + ' AND cci.debt_rating = ' + CAST(@debt_rating AS VARCHAR(20))

		IF @industry_type1 IS NOT NULL
			SET @sql = @sql + ' AND cci.industry_type1 = ' + CAST(@industry_type1 AS VARCHAR(20))

		IF @industry_type2 IS NOT NULL
			SET @sql = @sql + ' AND cci.industry_type2 = ' + CAST(@industry_type2 AS VARCHAR(20))

		IF @sic_code IS NOT NULL
			SET @sql = @sql + ' AND cci.sic_code = ' + CAST(@sic_code AS VARCHAR(20))

		IF @account_status IS NOT NULL
			SET @sql = @sql + ' AND cci.account_status = ' + CAST(@account_status AS VARCHAR(20))

		IF @volume IS NOT NULL 
			SET @sql = @sql + ' AND ABS(ISNULL(allowed_limit.credit_available, 0.0)) > '+ @volume
		
		IF @purchase_sell IS NOT NULL
			SET @sql = @sql + ' AND clcr.purchase_sales =''' + @purchase_sell + ''''

		SET @sql =	@sql + ' 
					 GROUP BY ' + @sql_group_by	
				
			SET @sql =	@sql + ' 		
					) AS P 
					PIVOT
					(
						SUM(credit_available)								
						FOR tenor_name IN 
						(' + @cols + ')
					) AS pvt
					LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = pvt.source_counterparty_id '
					+ CASE WHEN ISNULL(@group_limit, 'v') <> 'v' THEN ' WHERE 1 = 2' ELSE '' end
	
		SET @sql =	@sql 	+ '
					ORDER BY ' + @sql_order_by

		exec spa_print @sql
		EXEC(@sql)
END
ELSE IF @summary_detail_option='d'
BEGIN

	CREATE TABLE #temp([ID] INT identity(1,1),[RowNo] INT,[Description] VARCHAR(500) COLLATE DATABASE_DEFAULT,[Formula_Str] VARCHAR(1000) COLLATE DATABASE_DEFAULT,[Formula] VARCHAR(1000) COLLATE DATABASE_DEFAULT,[Value] FLOAT)
	CREATE TABLE #temp_f(formula varchar(2000) COLLATE DATABASE_DEFAULT)  

	INSERT INTO #temp([RowNo],[Description],[Formula_Str],[Formula],[Value])
	SELECT 
		cfv.seq_number AS [RowNo],
		fn.description1 AS [Description],
		cfv.formula_str as [Formula_Str],
		dbo.FNAFormulaFormat(fe.formula,'r') AS [Formula],
		cfv.value AS [Value]
		
	FROM
		calc_formula_value cfv
		INNER JOIN counterparty_limits cl ON cl.counterparty_limit_id=cfv.counterparty_limit_id
		INNER JOIN risk_tenor_bucket_detail rtbd ON rtbd.bucket_detail_id=cl.bucket_detail_id
		INNER JOIN source_counterparty sc ON sc.source_counterparty_id=cfv.counterparty_id
		LEFT JOIN formula_nested fn On fn.formula_group_id=cfv.formula_id
				AND fn.sequence_order=cfv.seq_number
		LEFT JOIN formula_editor fe on fe.formula_id=fn.formula_id
	WHERE
		cfv.prod_date = @as_of_date
		AND sc.counterparty_name=LTRIM(RTRIM(@drill_counterparty))
		AND rtbd.tenor_name=LTRIM(RTRIM(@drill_bucket))
		AND cl.volume_limit_type=CASE  @drill_volume_limit_type WHEN 'Purchases' THEN 'b' WHEN 'Sales' THEN 's' END



	DECLARE @ID INT, @formula_str VARCHAR(1000)

	DECLARE cur1 CURSOR FOR
	SELECT 
		[ID],[Formula_Str] FROM #temp
	OPEN cur1
	FETCH NEXT FROM cur1 INTO @ID,@formula_str
	WHILE @@FETCH_STATUS=0
	BEGIN
		
		set @formula_str=replace(@formula_str,'','''')  
		
			INSERT INTO #temp_f(formula)  
			exec spa_drill_down_function_call @formula_str  

			update #temp SET formula_str=formula+'<br><em>'+(select formula FROM #temp_f)+'</b></em>'  WHERE [ID]=@ID
			DELETE FROM #temp_f  
		FETCH NEXT FROM cur1 INTO @ID,@formula_str
	END
			
	CLOSE cur1
	DEALLOCATE cur1
	
	SELECT  [RowNo] as [Row No],[Description],[Formula_Str] as [Formula],[Value] FROM #temp where 1=case when isnull(@group_limit,'v')<>'v' then 2 else 1 end

END


