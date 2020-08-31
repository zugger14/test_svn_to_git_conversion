/****** Object:  StoredProcedure [dbo].[spa_view_volatility_and_correlation]    Script Date: 03/16/2009 15:59:34 ******/
IF OBJECT_ID(N'[dbo].[spa_view_volatility_and_correlation]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_view_volatility_and_correlation]
GO
--  EXEC spa_view_volatility_and_correlation 'c', null, 112, '2013-01-01', NULL, '2012-06-22','4500'
CREATE PROC [dbo].[spa_view_volatility_and_correlation]
	@report_type CHAR(1),
	@index_from INT,
	@index_to INT,
	@term_from DateTime,
	@term_to DateTime,
	@as_of_date DateTime,
	@curve_source_value_id INT, --rest of 5 parameters added for pagination
	@batch_process_id VARCHAR(250) = NULL,
	@batch_report_param VARCHAR(500) = NULL, 
	@enable_paging INT = 0,  --'1' = enable, '0' = disable
	@page_size INT = NULL,
	@page_no INT = NULL
AS
SET NOCOUNT ON
DECLARE @sql VARCHAR(5000)
/*
========================--
Modified by: Shushil Bohara
Midified dt: 4-Jul-2012
========================--
declare	@report_type char(1),
@index_from int,
@index_to int,
@curve_source_value_id INT,
@term_from datetime,
@term_to datetime,
@as_of_date datetime
DECLARE @sql VARCHAR(5000)
			
SET @as_of_date = '2012-6-22'
set @index_from=5
set @index_to =97
set @term_from = '2012-6-1'
set @term_to = '2013-12-1'
set @report_type='v'

--drop table #tmp
--select * from source_price_curve_def
--*/
--EXEC spa_view_volatility_and_correlation 'v', 138, 90, '2013-01-01', '2013-03-01', '2012-04-12','4500'

--### Pagination Code Start
DECLARE @str_batch_table VARCHAR(8000)
DECLARE @user_login_id VARCHAR(50)
DECLARE @sql_paging VARCHAR(8000)
DECLARE @is_batch BIT

IF @batch_process_id IS NULL
	SET @batch_process_id = REPLACE(NEWID(), '-', '_')
 
SET @str_batch_table = ''
SET @user_login_id = dbo.FNADBUser() 
 
IF @enable_paging = 1 --paging processing
BEGIN
   IF @batch_process_id IS NULL
      SET @batch_process_id = dbo.FNAGetNewID()
 
   SET @str_batch_table = dbo.FNAPagingProcess('p', @batch_process_id, @page_size, @page_no)
 
   --retrieve data from paging table instead of main table
   IF @page_no IS NOT NULL 
   BEGIN
      SET @sql_paging = dbo.FNAPagingProcess('s', @batch_process_id, @page_size, @page_no) 
      EXEC (@sql_paging) 
      RETURN 
   END
END
--### Pagination Code End

DECLARE @no_of_trading_days_year INT
SET @no_of_trading_days_year = 252--to calculate annual value
SET @as_of_date=ISNULL(@as_of_date,GETDATE())

DECLARE @risk_id INT, @risk_id1 INT
SELECT  @risk_id = isnull(risk_bucket_id,@index_from) FROM source_price_curve_def WHERE source_curve_def_id = @index_from
SELECT  @risk_id1 = isnull(risk_bucket_id,@index_to) FROM source_price_curve_def WHERE source_curve_def_id = @index_to

IF @report_type='v' --Volatiliy
BEGIN
	SELECT @as_of_date=ISNULL(max(as_of_date),@as_of_date) FROM curve_volatility WHERE as_of_date <= @as_of_date
	--SELECT @as_of_date
	SET @sql = 'SELECT  dbo.FNADateFormat(cv.as_of_date) [As of Date]
						,'+case when @index_from IS NOT NULL or @index_to IS NOT NULL then   'isnull(spcd_org.curve_name,spcd.curve_name) ' 
						else 'spcd.curve_name' end +' [Index]
						,dbo.FNADateFormat(cv.term) [Term]
						,sdv1.code Granularity
						,sdv.code [Volatility Source]
						,cv.[value] [Value at Granularity]
						,CASE cv.granularity 
							WHEN 700 THEN
								(cv.value*SQRT(' + CAST(@no_of_trading_days_year AS VARCHAR) +'))
							WHEN 701 THEN
								(cv.value*SQRT(52))           -- 52 weeks in a year
							WHEN 703 THEN						
								(cv.value*SQRT(12))			  -- 12 months in a year	
							WHEN 704 THEN
								(cv.value*SQRT(4))			  -- 4 quarters in a year	
						END	[Annual Value]
				' + @str_batch_table + '		
				FROM  curve_volatility cv 
				JOIN source_price_curve_def spcd ON spcd.source_curve_def_id=cv.curve_id
				join static_data_value sdv on sdv.value_id=cv.curve_source_value_id
				left join static_data_value sdv1 on sdv1.value_id=cv.granularity
				LEFT JOIN source_price_curve_def spcd_org ON spcd.source_curve_def_id = isnull(spcd_org.risk_bucket_id,spcd_org.source_curve_def_id)'
				+ CASE WHEN @index_from IS NOT NULL THEN ' AND ( spcd_org.source_curve_def_id = ' + CAST(@index_from AS VARCHAR) +
				  CASE WHEN @index_to IS NULL	THEN ')' ELSE '' END ELSE '' END
				+ CASE WHEN @index_to IS NOT NULL THEN 
					 CASE WHEN @index_from IS NULL THEN ' AND ( ' ELSE ' OR ' END + ' spcd_org.source_curve_def_id = ' + CAST(@index_to AS VARCHAR) + ')'
				 ELSE '' END
				+'
				WHERE cv.as_of_date=''' + CONVERT(VARCHAR(10), @as_of_date, 120) + ''''
	--PRINT (@SQL)
	
	IF @index_from IS NOT NULL AND @index_to IS NOT NULL
		SET @sql= @sql + ' AND cv.curve_id IN( ' + CAST(@risk_id AS VARCHAR) + ', ' + isnull(CAST(@risk_id1 AS VARCHAR), @risk_id) + ')'
	IF @index_from IS NOT NULL AND @index_to IS NULL
		SET @sql= @sql + ' AND cv.curve_id =' + CAST(@risk_id AS VARCHAR)
	IF @index_from IS NULL AND @index_to IS NOT NULL
		SET @sql= @sql + ' AND cv.curve_id = ' + CAST(@risk_id1 AS VARCHAR)
	 
	IF @term_from IS NOT NULL  AND @term_to IS NOT NULL
		SET @sql = @sql + ' AND cv.term  BETWEEN ''' + CONVERT(VARCHAR(10), @term_from, 120) + ''' AND ''' + CONVERT(VARCHAR(10), @term_to, 120) + ''''
	
	
	IF @term_from IS NOT NULL AND @term_to IS NULL
		SET @sql = @sql + ' AND cv.term >= ''' + CONVERT(VARCHAR(10), @term_from, 120) + ''''
	
	IF @term_to IS NOT NULL AND @term_from IS NULL
		SET @sql = @sql + ' AND cv.term <= ''' + CONVERT(VARCHAR(10), @term_to, 120) + ''''
		
	IF @curve_source_value_id IS NOT NULL 
		SET @sql = @sql + ' AND cv.curve_source_value_id='''+ CAST(@curve_source_value_id AS VARCHAR)+'''' 
	

	SET @sql= @sql + ' order by [Index],cv.as_of_date,cv.term'

	--print (@as_of_date)
	exec spa_print @sql
	EXEC(@sql)
END

ELSE IF @report_type='b' --correlation
BEGIN
	SELECT @as_of_date = ISNULL(max(as_of_date),@as_of_date) FROM curve_correlation WHERE as_of_date <= @as_of_date 

	SET @sql ='SELECT	dbo.FNADateFormat(cc.as_of_date) [As of Date]
						,'+case when @index_from IS NOT NULL or @index_to IS NOT NULL then  'isnull(spcd_org.curve_name,spcd.curve_name) ' else 'spcd.curve_name' end +' [Index From]
							,'+case when @index_from IS NOT NULL or @index_to IS NOT NULL then  'isnull(spcd_org2.curve_name,spcd2.curve_name) ' else 'spcd2.curve_name' end +' [Index To]
						, dbo.FNADateFormat(cc.term1) [Term From]
						, dbo.FNADateFormat(cc.term2) [Term To]
						,sdv.code [Volatility Source]
						, cc.value [Value]
				' + @str_batch_table + '		
				FROM  curve_correlation cc 
				JOIN source_price_curve_def spcd ON spcd.source_curve_def_id=cc.curve_id_from
				JOIN source_price_curve_def spcd2 ON spcd2.source_curve_def_id=cc.curve_id_to
				JOIN static_data_value sdv on sdv.value_id=cc.curve_source_value_id
				LEFT JOIN source_price_curve_def spcd_org ON spcd.source_curve_def_id = isnull(spcd_org.risk_bucket_id,spcd_org.source_curve_def_id)'
				+ CASE WHEN @index_from IS NOT NULL THEN ' AND ( spcd_org.source_curve_def_id = ' + CAST(@index_from AS VARCHAR) +
				  CASE WHEN @index_to IS NULL	THEN ')' ELSE '' END ELSE '' END
				+ CASE WHEN @index_to IS NOT NULL THEN 
					 CASE WHEN @index_from IS NULL THEN ' AND ( ' ELSE ' OR ' END + ' spcd_org.source_curve_def_id = ' + CAST(@index_to AS VARCHAR) + ')'
				 ELSE '' END
				+'
				LEFT JOIN source_price_curve_def spcd_org2 ON spcd2.source_curve_def_id = isnull(spcd_org2.risk_bucket_id,spcd_org2.source_curve_def_id)'
				+ CASE WHEN @index_from IS NOT NULL THEN ' AND ( spcd_org2.source_curve_def_id = ' + CAST(@index_from AS VARCHAR) +
				  CASE WHEN @index_to IS NULL	THEN ')' ELSE '' END ELSE '' END
				+ CASE WHEN @index_to IS NOT NULL THEN 
					 CASE WHEN @index_from IS NULL THEN ' AND ( ' ELSE ' OR ' END + ' spcd_org2.source_curve_def_id = ' + CAST(@index_to AS VARCHAR) + ')'
				 ELSE '' END
				+'				
				WHERE cc.as_of_date=''' + CONVERT(VARCHAR(10), @as_of_date, 120) + ''''
	

	IF @index_from IS NOT NULL
		SET @sql= @sql+' AND cc.curve_id_from IN( ' + CAST(@risk_id AS VARCHAR) + ', ' + isnull(CAST(@risk_id1 AS VARCHAR), @risk_id) + ')'

	IF @risk_id1 IS NOT NULL
		SET @sql= @sql+' AND cc.curve_id_to IN( ' + isnull(CAST(@risk_id AS VARCHAR), @risk_id1) + ',' + CAST(@risk_id1 AS VARCHAR) + ')'
	 
	IF @term_from IS NOT NULL AND @term_to IS NOT NULL
	BEGIN
		SET @sql = @sql + ' AND cc.term1  BETWEEN ''' + CONVERT(VARCHAR(10), @term_from, 120) + ''' AND ''' + CONVERT(VARCHAR(10), @term_to, 120) + ''''
		SET @sql = @sql + ' AND cc.term2  BETWEEN ''' + CONVERT(VARCHAR(10), @term_from, 120) + ''' AND ''' + CONVERT(VARCHAR(10), @term_to, 120) + ''''
	END
	
	IF @term_from IS NOT NULL AND @term_to IS NULL
	BEGIN
		SET @sql = @sql + ' AND cc.term1 >= ''' + CONVERT(VARCHAR(10), @term_from, 120) + ''''
		SET @sql = @sql + ' AND cc.term2 >= ''' + CONVERT(VARCHAR(10), @term_from, 120) + ''''
	END
		
	
	IF @term_to IS NOT NULL AND @term_from IS NULL
	BEGIN
		SET @sql = @sql + ' AND cc.term1 <= ''' + CONVERT(VARCHAR(10), @term_to, 120) + ''''
		SET @sql = @sql + ' AND cc.term2 <= ''' + CONVERT(VARCHAR(10), @term_to, 120) + ''''
	END
	
	IF @curve_source_value_id IS NOT NULL 
		SET @sql = @sql + ' AND cc.curve_source_value_id='''+ CAST(@curve_source_value_id AS VARCHAR)+'''' 	
	--IF @term_from IS NOT NULL 
	--BEGIN
	--	SELECT @term_from
	--	SET @sql= @sql + ' AND cc.term1 >= ''' + CONVERT(VARCHAR(10), @term_from, 120) + '''' 
	--END
	
	--IF @term_to IS NOT NULL 
	--BEGIN
	--	SELECT @term_to
	--	SET @sql = @sql + ' AND cc.term2 <= ''' + CONVERT(VARCHAR(10), @term_to, 120) + '''' 
	--END
	
	SET @sql= @sql + ' ORDER BY [index from], [index to],cc.term1, cc.term2'


	EXEC spa_print @SQL
	EXEC(@SQL)
END
ELSE IF @report_type='c' --covariance
BEGIN
	SELECT @as_of_date=ISNULL(max(as_of_date),@as_of_date) FROM curve_correlation WHERE as_of_date<=@as_of_date

	SELECT cor.curve_id_from,cor.curve_id_to, sdv.code, cor.term1,cor.term2,(STDEV_Value1*STDEV_Value2*cor.value) Covar_value
	INTO #tmp FROM (
		SELECT t1.curve_id X_curve_id ,t2.curve_id Y_curve_id ,t1.term X_term_start,t2.term Y_term_start, 
		t1.Value STDEV_Value1, t2.Value STDEV_Value2, t1.curve_source_value_id
		FROM (SELECT * FROM curve_volatility WHERE as_of_date=@as_of_date AND curve_source_value_id=@curve_source_value_id) t1 CROSS JOIN (SELECT * FROM curve_volatility WHERE as_of_date=@as_of_date AND curve_source_value_id=@curve_source_value_id) t2
		) Vol
	INNER JOIN static_data_value sdv on sdv.value_id=vol.curve_source_value_id
	INNER JOIN curve_correlation Cor ON vol.X_curve_id=cor.curve_id_from 
		AND vol.curve_source_value_id = cor.curve_source_value_id
		AND vol.Y_curve_id=cor.curve_id_to 
		AND vol.X_term_start=cor.term1
		AND vol.Y_term_start=cor.term2
		AND  cor.as_of_date=@as_of_date	

	SET @sql = 'SELECT	
						'+case when @index_from IS NOT NULL or @index_to IS NOT NULL then  'isnull(spcd_org.curve_name,spcd.curve_name) ' else 'spcd.curve_name' end +' [Index From]
							,'+case when @index_from IS NOT NULL or @index_to IS NOT NULL then  'isnull(spcd_org2.curve_name,spcd2.curve_name) ' else 'spcd2.curve_name' end +' [Index To]
						, dbo.FNADateFormat(cc.term1) [Term From]
						, dbo.FNADateFormat(cc.term2) [Term To]
						,cc.code [Volatility Source]
						, Covar_value [Value]
				' + @str_batch_table + '		
				FROM  #tmp cc 
				JOIN source_price_curve_def spcd ON spcd.source_curve_def_id=cc.curve_id_from
				JOIN source_price_curve_def spcd2 ON spcd2.source_curve_def_id=cc.curve_id_to
				LEFT JOIN source_price_curve_def spcd_org ON spcd.source_curve_def_id = isnull(spcd_org.risk_bucket_id,spcd_org.source_curve_def_id)'
				+ CASE WHEN @index_from IS NOT NULL THEN ' AND ( spcd_org.source_curve_def_id = ' + CAST(@index_from AS VARCHAR) +
				  CASE WHEN @index_to IS NULL	THEN ')' ELSE '' END ELSE '' END
				+ CASE WHEN @index_to IS NOT NULL THEN 
					 CASE WHEN @index_from IS NULL THEN ' AND ( ' ELSE ' OR ' END + ' spcd_org.source_curve_def_id = ' + CAST(@index_to AS VARCHAR) + ')'
				 ELSE '' END
				+'
				LEFT JOIN source_price_curve_def spcd_org2 ON spcd2.source_curve_def_id = isnull(spcd_org2.risk_bucket_id,spcd_org2.source_curve_def_id)'
				+ CASE WHEN @index_from IS NOT NULL THEN ' AND ( spcd_org2.source_curve_def_id = ' + CAST(@index_from AS VARCHAR) +
				  CASE WHEN @index_to IS NULL	THEN ')' ELSE '' END ELSE '' END
				+ CASE WHEN @index_to IS NOT NULL THEN 
					 CASE WHEN @index_from IS NULL THEN ' AND ( ' ELSE ' OR ' END + ' spcd_org2.source_curve_def_id = ' + CAST(@index_to AS VARCHAR) + ')'
				 ELSE '' END
				+'								
				WHERE 1 = 1 ' 

	IF @index_from IS NOT NULL
		SET @sql= @sql+' AND cc.curve_id_from IN( ' + CAST(@risk_id AS VARCHAR) + ', ' + isnull(CAST(@risk_id1 AS VARCHAR), @risk_id) + ')'

	IF @index_to IS NOT NULL
		SET @sql= @sql+' AND cc.curve_id_to IN( ' + isnull(CAST(@risk_id AS VARCHAR), @risk_id1) + ', ' + CAST(@risk_id1 AS VARCHAR) + ')'
	
	IF @term_from IS NOT NULL 
	BEGIN
		SET @sql= @sql+' AND cc.term1>=''' + CONVERT(VARCHAR(10), @term_from, 120) + '''' 
	END
	IF @term_from IS NOT NULL AND @term_to IS NOT NULL
	BEGIN
		SET @sql = @sql + ' AND cc.term1  BETWEEN ''' + CONVERT(VARCHAR(10), @term_from, 120) + ''' AND ''' + CONVERT(VARCHAR(10), @term_to, 120) + ''''
		SET @sql = @sql + ' AND cc.term2  BETWEEN ''' + CONVERT(VARCHAR(10), @term_from, 120) + ''' AND ''' + CONVERT(VARCHAR(10), @term_to, 120) + ''''
	END
	
	IF @term_from IS NOT NULL AND @term_to IS NULL
	BEGIN
		SET @sql = @sql + ' AND cc.term1 >= ''' + CONVERT(VARCHAR(10), @term_from, 120) + ''''
		SET @sql = @sql + ' AND cc.term2 >= ''' + CONVERT(VARCHAR(10), @term_from, 120) + ''''
	END
		
	
	IF @term_to IS NOT NULL AND @term_from IS NULL
	BEGIN
		SET @sql = @sql + ' AND cc.term1 <= ''' + CONVERT(VARCHAR(10), @term_to, 120) + ''''
		SET @sql = @sql + ' AND cc.term2 <= ''' + CONVERT(VARCHAR(10), @term_to, 120) + ''''
	END
		
	--IF @term_to IS NOT NULL 
	--BEGIN
	--	SET @sql= @sql+' AND cc.term2<=''' + CONVERT(VARCHAR(10), @term_to, 120) + '''' 
	--END

	SET @sql= @sql+' order by [index from],[index to],cc.term1,cc.term2'
	exec spa_print @SQL
	EXEC(@SQL)
END
IF @report_type = 'r' --expected return
BEGIN
	SELECT @as_of_date = ISNULL(max(as_of_date),@as_of_date) FROM expected_return WHERE as_of_date <= @as_of_date

	SET @sql = 'SELECT	dbo.FNADateFormat(cv.as_of_date) [As of Date]
						,'+case when @index_from IS NOT NULL or @index_to IS NOT NULL then  'isnull(spcd_org.curve_name,spcd.curve_name) ' else 'spcd.curve_name' end +' [Index]
						, dbo.FNADateFormat(cv.term) [Term]
						, sdv1.code Granularity
						,sdv.code [Volatility Source]
						, cv.[value] [Value at Granularity]
						,CASE cv.granularity 
							WHEN 700 THEN
								(cv.value*(' + CAST(@no_of_trading_days_year AS VARCHAR) +'))
							WHEN 701 THEN
								(cv.value*52)		-- 52 weeks in a year 
							WHEN 703 THEN
								(cv.value*12)		-- 12 months in a year
							WHEN 704 THEN
								(cv.value*4)		-- 4 quarters in a year
						END	[Annual Value]
				' + @str_batch_table + '		
				FROM  expected_return cv 
				JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = cv.curve_id
				JOIN static_data_value sdv ON sdv.value_id = cv.curve_source_value_id
				LEFT JOIN static_data_value sdv1 ON sdv1.value_id = cv.granularity
				LEFT JOIN source_price_curve_def spcd_org ON spcd.source_curve_def_id = isnull(spcd_org.risk_bucket_id,spcd_org.source_curve_def_id)'
				+ CASE WHEN @index_from IS NOT NULL THEN ' AND ( spcd_org.source_curve_def_id = ' + CAST(@index_from AS VARCHAR) +
				  CASE WHEN @index_to IS NULL	THEN ')' ELSE '' END ELSE '' END
				+ CASE WHEN @index_to IS NOT NULL THEN 
					 CASE WHEN @index_from IS NULL THEN ' AND ( ' ELSE ' OR ' END + ' spcd_org.source_curve_def_id = ' + CAST(@index_to AS VARCHAR) + ')'
				 ELSE '' END
				+'
				WHERE cv.as_of_date=''' + CONVERT(VARCHAR(10), @as_of_date, 120) + ''''
				
				
			
				
				
	
	IF @index_from IS NOT NULL AND @index_to IS NOT NULL
		SET @sql = @sql + ' AND cv.curve_id IN( ' + CAST(@risk_id AS VARCHAR) + ', ' + isnull(CAST(@risk_id1 AS VARCHAR), @risk_id) + ')'
	
	IF @index_from IS NOT NULL AND @index_to IS NULL
		SET @sql = @sql + ' AND cv.curve_id =' + CAST(@risk_id AS VARCHAR)
	
	IF @risk_id IS NULL AND @index_to IS NOT NULL
		SET @sql = @sql + ' AND cv.curve_id = ' + CAST(@risk_id1 AS VARCHAR)

	IF @term_from IS NOT NULL  AND @term_to IS NOT NULL
		SET @sql = @sql + ' AND cv.term  BETWEEN ''' + CONVERT(VARCHAR(10), @term_from, 120) + ''' AND ''' + CONVERT(VARCHAR(10), @term_to, 120) + ''''
	
	IF @term_from IS NOT NULL AND @term_to IS NULL
		SET @sql = @sql + ' AND cv.term >= ''' + CONVERT(VARCHAR(10), @term_from, 120) + ''''
	
	IF @term_to IS NOT NULL AND @term_from IS NULL
		SET @sql = @sql + ' AND cv.term <= ''' + CONVERT(VARCHAR(10), @term_to, 120) + ''''
 
	--IF @term_from IS NOT NULL 
	--	SET @sql = @sql + ' AND cv.term  BETWEEN ''' + CONVERT(VARCHAR(10), @term_from, 120) + ''' AND ''' + CONVERT(VARCHAR(10), @term_to, 120) + ''''
	
	IF @curve_source_value_id IS NOT NULL 
	BEGIN
		SET @sql = @sql + ' AND cv.curve_source_value_id=''' + CAST(@curve_source_value_id AS VARCHAR) + '''' 
	END

	SET @sql= @sql + ' ORDER BY [index], cv.as_of_date, cv.term'

	--print (@as_of_date)
	exec spa_print @sql
	EXEC(@sql)
END
--### Pagination Code Start
IF @enable_paging = 1 AND @page_no IS NULL
BEGIN
   SET @sql_paging = dbo.FNAPagingProcess('t', @batch_process_id, @page_size, @page_no)
   EXEC(@sql_paging)
END
--### Pagination Code End