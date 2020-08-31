IF OBJECT_ID('spa_load_forecast_report') is not null
	DROP PROCEDURE [dbo].[spa_load_forecast_report]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**
	Selection of the data for Load Forecast Report

	Parameters			
	@profile_id			: Profile ID of forecast_profile
	@location_id		: Location ID of source_minor_location
	@term_start			: Term Start to specify date from 
	@term_end			: Term End to specify date to 
	@hour_from			: Hour from 
	@hour_to			: Hour to
	@grouping_option	: Grouping option to specify Report Option (s= summary, d = detail)
							
	@format				: format specify to Report Format (c= cross tab , r= regular )
	@round_value		: round value for rounding
	@ean				: ean for external_id
	@batch_process_id	: Batch Unique ID for batch process
	@batch_report_param : Batch params required for batch process.
	@enable_paging		: Specify whether to enable page or not.
	@page_size			: Size of page.
	@page_no			: Number of pages.

*/
CREATE PROCEDURE [dbo].[spa_load_forecast_report]
	@profile_id VARCHAR(MAX) = NULL,
	@location_id INT = NULL,
	@term_start DATETIME = NULL,
	@term_end DATETIME = NULL,
	@hour_from INT = NULL,
	@hour_to INT = NULL,
	@grouping_option CHAR(1) = NULL,
	@format CHAR(1) = NULL,
	@round_value CHAR(2) = '0',
	@ean VARCHAR(100) = NULL,
	@batch_process_id VARCHAR(250) = NULL,
	@batch_report_param VARCHAR(500) = NULL, 
	@enable_paging INT = 0,  --'1' = enable, '0' = disable
	@page_size INT = NULL,
	@page_no INT = NULL
AS


/*
	DECLARE @contextinfo VARBINARY(128)= CONVERT(VARBINARY(128), 'DEBUG_MODE_ON');
	SET CONTEXT_INFO @contextinfo;

DECLARE 

	@profile_id INT = 79,
	@location_id INT = NULL,
	@term_start DATETIME = '2017-03-12',
	@term_end DATETIME = '2017-11-05',
	@hour_from INT = NULL,
	@hour_to INT = NULL,
	@grouping_option CHAR(1) = 's',
	@format CHAR(1) = 'c',
	@round_value CHAR(2) = '0',
	@ean VARCHAR(100) = NULL,
	@batch_process_id VARCHAR(250) = NULL,
	@batch_report_param VARCHAR(500) = NULL, 
	@enable_paging INT = 0,  --'1' = enable, '0' = disable
	@page_size INT = NULL,
	@page_no INT = NULL
		--*/
	DECLARE @sqlStmt VARCHAR(MAX), @from INT, @to INT, @hours VARCHAR(MAX)
	SET @from = ISNULL(@hour_from, 1)
	SET @to = ISNULL(@hour_to, 24)
	SET @hours = ''


	BEGIN
	SET NOCOUNT ON
	/*******************************************1st Paging Batch START**********************************************/
	DECLARE @str_batch_table VARCHAR(8000)
	DECLARE @user_login_id VARCHAR(50)
	DECLARE @sql_paging VARCHAR(8000)
	DECLARE @is_batch BIT
			 
	SET @str_batch_table = ''
	SET @user_login_id = dbo.FNADBUser() 

	SET @is_batch = CASE WHEN @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL THEN 1 ELSE 0 END		

	IF @is_batch = 1
		SET @str_batch_table = ' INTO ' + dbo.FNAProcessTableName('batch_report', @user_login_id, @batch_process_id)

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
	/*******************************************1st Paging Batch END**********************************************/  

--create index indx_tmp_location_profile_location_id on #tmp_location_profile ([location_id])
--create index indx_tmp_location_profile_profile_id on #tmp_location_profile ([profile_id])


	IF OBJECT_ID('tempdb..#tmp_pivot_table') IS NOT NULL
	DROP TABLE #tmp_pivot_table
	
	CREATE TABLE #tmp_pivot_table(
		[profile_id] VARCHAR(100) COLLATE DATABASE_DEFAULT  NULL,
		[profile_name] VARCHAR(100) COLLATE DATABASE_DEFAULT  NULL,
		external_id VARCHAR(50) COLLATE DATABASE_DEFAULT  NULL,
       Location VARCHAR(100) COLLATE DATABASE_DEFAULT  NULL,
       Term DATETIME,
       hr1 NUMERIC(38, 20),
       hr2 NUMERIC(38, 20),
       hr3 NUMERIC(38, 20),
       hr4 NUMERIC(38, 20),
       hr5 NUMERIC(38, 20),
       hr6 NUMERIC(38, 20),
       hr7 NUMERIC(38, 20),
       hr8 NUMERIC(38, 20),
       hr9 NUMERIC(38, 20),
       hr10 NUMERIC(38, 20),
       hr11 NUMERIC(38, 20),
       hr12 NUMERIC(38, 20),
       hr13 NUMERIC(38, 20),
       hr14 NUMERIC(38, 20),
       hr15 NUMERIC(38, 20),
       hr16 NUMERIC(38, 20),
       hr17 NUMERIC(38, 20),
       hr18 NUMERIC(38, 20),
       hr19 NUMERIC(38, 20),
       hr20 NUMERIC(38, 20),
       hr21 NUMERIC(38, 20),
       hr22 NUMERIC(38, 20),
       hr23 NUMERIC(38, 20),
       hr24 NUMERIC(38, 20),
       hr25 NUMERIC(38, 20)
	)
	SET @sqlStmt = '
	INSERT INTO #tmp_pivot_table
	SELECT fp.profile_id [Profile ID],
		   fp.profile_name [Profile Name],
		   fp.external_id [External ID],
		   ' +  CASE WHEN @location_id IS NOT NULL THEN + ' sml.Location_Name [Location] ' ELSE 'NULL [Location]' END + '
	       ,ddh.term_date [Term],
	       ddh.hr1,
	       ddh.hr2,
	       ddh.hr3,
	       ddh.hr4,
	       ddh.hr5,
	       ddh.hr6,
	       ddh.hr7,
	       ddh.hr8,
	       ddh.hr9,
	       ddh.hr10,
	       ddh.hr11,
	       ddh.hr12,
	       ddh.hr13,
	       ddh.hr14,
	       ddh.hr15,
	       ddh.hr16,
	       ddh.hr17,
	       ddh.hr18,
	       ddh.hr19,
	       ddh.hr20,
	       ddh.hr21,
	       ddh.hr22,
	       ddh.hr23,
	       ddh.hr24,
	       ddh.hr25
	FROM   deal_detail_hour ddh
	--inner join #tmp_location_profile fp on ddh.profile_id=fp.profile_id
	INNER JOIN [forecast_profile] fp (nolock) 
					ON fp.profile_id =ddh.profile_id 
					AND isnull(fp.available,0)=1
				' +  CASE WHEN @location_id IS NOT NULL THEN + 'LEFT JOIN source_minor_location sml (nolock) 
					ON fp.profile_id = sml.profile_id 
					OR fp.profile_id = sml.proxy_profile_id ' ELSE '' END + '
		WHERE	fp.profile_id IS NOT NULL '
	--WHERE  1 = 1 '
	+ CASE WHEN @term_start IS NOT NULL THEN ' AND ddh.term_date >= ''' + CAST(@term_start AS VARCHAR) + '''' ELSE '' END
	+ CASE WHEN @term_end IS NOT NULL THEN ' AND ddh.term_date <= ''' + CAST(@term_end AS VARCHAR) + '''' ELSE '' END
	+ CASE WHEN @ean IS NOT NULL THEN '	AND fp.external_id ='''+@ean+'''' ELSE '' END 
	+ CASE WHEN @profile_id IS NOT NULL THEN '	AND fp.profile_id IN (' + @profile_id +' ) ' ELSE '' END
	+ CASE WHEN  @location_id IS NOT NULL THEN '	AND sml.source_minor_location_id = ' + CAST(@location_id AS VARCHAR) ELSE '' END
	EXEC spa_print @sqlStmt	
	EXEC(@sqlStmt)
	
--	SELECT * FROM #tmp_pivot_table	
	IF @format = 'c'
	BEGIN
		IF @grouping_option = 'd'
		BEGIN
			WHILE @from <= @to
			BEGIN
				SET @hours = @hours + 'CAST(hr' + CAST(@from AS VARCHAR) + ' AS NUMERIC(38, ' + @round_value + ')) [Hr' + CAST(@from AS VARCHAR) + '], '
				SET @from = @from + 1 
				IF @from > @to
				  BREAK
			   ELSE
				  CONTINUE
			END
			SET @hours = LEFT(@hours, LEN(@hours) - 1) + ' '
			IF (@location_id IS NOT NULL)
			BEGIN
				SET @sqlStmt = 'SELECT profile_name [Profile Name],
									location [Location],
									external_id [Profile ID],
									dbo.FNADateformat([Term]) [Term],
									' + @hours + @str_batch_table + ' 
							FROM #tmp_pivot_table 
			                ORDER BY [location],dbo.FNAStdDate([term])
							'	
			END
			ELSE
			BEGIN
				SET @sqlStmt = 'SELECT profile_name [Profile Name],
				                       external_id [Profile ID],
				                       dbo.FNADateformat([Term]) [Term],
				                       ' + @hours + @str_batch_table + '
				                FROM   #tmp_pivot_table
				                GROUP BY
				                       profile_name,
				                       external_id,
				                       [Term],
				                       [Hr1],
				                       [Hr2],
				                       [Hr3],
				                       [Hr4],
				                       [Hr5],
				                       [Hr6],
				                       [Hr7],
				                       [Hr8],
				                       [Hr9],
				                       [Hr10],
				                       [Hr11],
				                       [Hr12],
				                       [Hr13],
				                       [Hr14],
				                       [Hr15],
				                       [Hr16],
				                       [Hr18],
				                       [Hr17],
				                       [Hr19],
				                       [Hr20],
				                       [Hr21],
				                       [Hr22],
				                       [Hr23],
				                       [Hr24]
				                ORDER BY dbo.FNAStdDate([term])
							'	
			END
			EXEC spa_print @sqlStmt
			EXEC (@sqlStmt)
		END
		ELSE
		BEGIN
			SELECT @from = @from --added +1 make hour start from 1
			SELECT @to = @to
			IF EXISTS(SELECT * FROM #tmp_pivot_table)
			BEGIN
				WHILE @from <= @to
				BEGIN
					SET @hours = @hours + 'isnull(hr' + CAST(@from AS VARCHAR) + ',0) + '
					SET @from = @from + 1 
					IF @from > @to
					  BREAK
				   ELSE
					  CONTINUE
				END
				SET @hours = LEFT(@hours, LEN(@hours) -1)
				CREATE TABLE #tmp_calc_pvt_tbl(
					[profile_id] VARCHAR(200) COLLATE DATABASE_DEFAULT  NULL,
					[profile_name] VARCHAR(100) COLLATE DATABASE_DEFAULT  NULL,
					[external_id] VARCHAR(50) COLLATE DATABASE_DEFAULT  NULL,
					[location] VARCHAR(200) COLLATE DATABASE_DEFAULT  NULL,
					[Term] DATETIME,
					[Volume] NUMERIC(38,20)
				)
				
				SET @sqlStmt = 'INSERT INTO #tmp_calc_pvt_tbl (profile_id, profile_name, external_id, location, Term, volume) SELECT [profile_id], profile_name, external_id, location, Term, ' + @hours + ' AS [Volume] FROM #tmp_pivot_table'
				EXEC spa_print @sqlStmt
				EXEC(@sqlStmt)

				DECLARE @listCol VARCHAR(MAX)
				DECLARE @selectCol VARCHAR(MAX)
				SELECT  @listCol = STUFF(( SELECT  '], [' +  dbo.FNADateFormat(Term) 
							 FROM    #tmp_calc_pvt_tbl GROUP BY [Term] ORDER BY [Term] 
									FOR XML PATH('')), 1, 2, '') + ']'
									
				SELECT  @selectCol = STUFF(( SELECT  '], CAST([' + dbo.FNADateFormat(Term) + '] AS NUMERIC(38, ' + @round_value + ')) AS [' + dbo.FNADateFormat(Term)
							 FROM    #tmp_calc_pvt_tbl GROUP BY [Term] ORDER BY [Term] 
									FOR XML PATH('')), 1, 2, '') + ']'
				EXEC spa_print @selectCol
				
				IF (@location_id IS NOT NULL)
				BEGIN
					SET @sqlStmt  = 'SELECT [Profile Name], [Location],[Profile ID], ' + @selectCol + ' ' + @str_batch_table + ' FROM
								(
									SELECT profile_name [Profile Name], location [Location],external_id [Profile ID], dbo.FNADateFormat(Term) [Term], Volume FROM #tmp_calc_pvt_tbl 
								) DataTable
								PIVOT
								(
								  SUM(Volume)
								  FOR Term
								  IN ( ' + @listCol + ')
								) PivotTable'	
				END
				ELSE
				BEGIN

					SET @sqlStmt  = 'SELECT [Profile Name], [Profile ID], ' + @selectCol + ' ' + @str_batch_table + ' FROM
								(
									SELECT profile_name [Profile Name], external_id [Profile ID], dbo.FNADateFormat(Term) [Term], Volume FROM #tmp_calc_pvt_tbl 
								) DataTable
								PIVOT
								(
								  SUM(Volume)
								  FOR Term
								  IN ( ' + @listCol + ')
								) PivotTable'
				END					
				
				EXEC spa_print @sqlStmt
				EXEC (@sqlStmt)
			END
			ELSE
				BEGIN
					IF (@location_id IS NOT NULL)
					BEGIN
						SET @sqlStmt = 'SELECT [profile_name] [Profile Name], location [Location],external_id [Profile ID] '+ @str_batch_table+ ' FROM #tmp_pivot_table'	
					END
					ELSE
					BEGIN
						SET @sqlStmt = 'SELECT [profile_name] [Profile Name], external_id [Profile ID] '+ @str_batch_table+ ' FROM #tmp_pivot_table'
					END
					
					EXEC spa_print @sqlStmt
					EXEC (@sqlStmt)					
				END
		END		
		
	END
	ELSE
	BEGIN
		IF (@location_id IS NOT NULL)
		BEGIN
		
		SET @sqlStmt = 'SELECT unpvt.[profile_name] [Profile Name], location [Location], external_id [Profile ID], dbo.FNADateformat(term) [Term], ' 
						+ CASE WHEN @grouping_option = 'd' 
							THEN 'CASE 
									WHEN mv.date IS NOT NULL THEN mv.Hour
									ELSE unpvt.Hour
								END [Hour],
								CASE 
									WHEN mv3.[Hour] = CAST(unpvt.[Hour] AS INT) AND mv3.date = [term] THEN (CAST(Volume AS NUMERIC(38, ' + @round_value + ')) - ISNULL(unpvt.dd,0))
									ELSE CAST(Volume AS NUMERIC(38, ' + @round_value + '))
							   END [Volume]
								--unpvt.[Hour], 
								--CAST(Volume AS NUMERIC(38, ' + @round_value + ')) [Volume]
								' 
							ELSE ' CAST(SUM(Volume) AS NUMERIC(38, ' + @round_value + ')) [Volume]' END 
						+ @str_batch_table + ' FROM
						(SELECT 
							[profile_name], external_id, location, term, hr1 [1], hr2 [2], hr3 [3], hr4 [4], hr5 [5], hr6 [6], hr7 [7], hr8 [8], hr9 [9], hr10 [10], hr11 [11], hr12 [12], hr13 [13], hr14 [14], hr15 [15], hr16 [16], hr17 [17], hr18 [18], hr19 [19], hr20 [20], hr21 [21], hr22 [22], hr23 [23], hr24 [24], hr25 [25], hr25 [dd] FROM #tmp_pivot_table) p
						UNPIVOT
						(Volume for [Hour] IN
							([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23], [24], [25])
						) AS unpvt
						--LEFT JOIN mv90_DST mv ON ([Term])=(mv.date)
						CROSS JOIN 
						(
							SELECT var_value default_timezone_id FROM dbo.adiha_default_codes_values WHERE instance_no = 1 AND default_code_id = 36 AND seq_no = 1
						) df  
						INNER JOIN dbo.time_zones tz ON tz.timezone_id = df.default_timezone_id
						LEFT JOIN mv90_DST mv
							ON  ([Term]) = (mv.date)
							AND mv.insert_delete = ''i''
							AND CAST(unpvt.Hour AS INT) = 25
							AND mv.dst_group_value_id = tz.dst_group_value_id
					  -- LEFT JOIN mv90_DST mv1
							--ON  ([Term]) = (mv1.date)
							--AND mv1.insert_delete = ''d''
							--AND mv1.Hour = CAST(unpvt.Hour AS INT)
							--AND mv1.dst_group_value_id = tz.dst_group_value_id
					  -- LEFT JOIN mv90_DST mv2
							--ON  YEAR([Term]) = (mv2.YEAR)
							--AND mv2.insert_delete = ''d''
							--AND mv2.dst_group_value_id = tz.dst_group_value_id
					   LEFT JOIN mv90_DST mv3
							ON  YEAR([Term]) = (mv3.YEAR)
							AND mv3.insert_delete = ''i''
							AND mv3.dst_group_value_id = tz.dst_group_value_id
						WHERE 1 = 1 
						AND ( CASE 
								WHEN ''' + @grouping_option + ''' = ''d'' THEN CASE WHEN mv.date IS NOT NULL THEN mv.Hour ELSE unpvt.Hour END
								ELSE  unpvt.Hour
							END 
							BETWEEN ' + CAST(ISNULL(@hour_from,1) AS VARCHAR) + ' AND ' + CAST(ISNULL(@hour_to,24) AS VARCHAR) + 
						') 						 
						AND (
							   (CAST(unpvt.Hour AS INT) = 25 AND mv.date IS NOT NULL)
							   OR (CAST(unpvt.Hour AS INT) <> 25)
						   )
					   --AND (mv1.date IS NULL)
					   ' +
						CASE WHEN @grouping_option = 's' THEN ' GROUP BY profile_name,external_id,location,term ORDER BY location,CAST(term AS DATETIME) ' ELSE '' END +  
						CASE WHEN @grouping_option = 'd' THEN ' ORDER BY profile_name,location,CAST(term AS DATETIME), 
							CASE 
								WHEN mv.date IS NOT NULL THEN mv.Hour
								ELSE CAST(unpvt.Hour AS INT)
						   END' ELSE '' END
		END
		ELSE
		BEGIN
			SET @sqlStmt = 'SELECT unpvt.[profile_name] [Profile Name], external_id [Profile ID], dbo.FNADateformat(term) [Term], ' 
						+ CASE WHEN @grouping_option = 'd' 
							THEN 'CASE 
									WHEN mv.date IS NOT NULL THEN mv.Hour
									ELSE unpvt.Hour
								END [Hour],
							dbo.FNANumberFormat(	CASE 
									WHEN mv3.[Hour] = CAST(unpvt.[Hour] AS INT) AND mv3.date = [term] THEN (CAST(SUM(Volume) AS NUMERIC(38, ' + @round_value + ')) - ISNULL(SUM(unpvt.dd),0))
									ELSE CAST(SUM(Volume) AS NUMERIC(38, ' + @round_value + '))
							   END,''v'') [Volume]
								--unpvt.[Hour], 
								--CAST(Volume AS NUMERIC(38, ' + @round_value + ')) [Volume]
								' 
							ELSE 'dbo.FNANumberFormat( CAST(SUM(Volume) AS NUMERIC(38, ' + @round_value + ')), ''v'') [Volume]' END 
						+ @str_batch_table + ' FROM
						(SELECT 
							[profile_name], external_id, term, hr1 [1], hr2 [2], hr3 [3], hr4 [4], hr5 [5], hr6 [6], hr7 [7], hr8 [8], hr9 [9], hr10 [10], hr11 [11], hr12 [12], hr13 [13], hr14 [14], hr15 [15], hr16 [16], hr17 [17], hr18 [18], hr19 [19], hr20 [20], hr21 [21], hr22 [22], hr23 [23], hr24 [24], hr25 [25], hr25 [dd] FROM #tmp_pivot_table) p
						UNPIVOT
						(Volume for [Hour] IN
							([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23], [24], [25])
						) AS unpvt
						--LEFT JOIN mv90_DST mv ON ([Term])=(mv.date)
						CROSS JOIN 
						(
							SELECT var_value default_timezone_id FROM dbo.adiha_default_codes_values WHERE instance_no = 1 AND default_code_id = 36 AND seq_no = 1
						) df  
						INNER JOIN dbo.time_zones tz ON tz.timezone_id = df.default_timezone_id						
						LEFT JOIN mv90_DST mv
							ON  ([Term]) = (mv.date)
							AND mv.insert_delete = ''i''
							AND CAST(unpvt.Hour AS INT) = 25
							AND mv.dst_group_value_id = tz.dst_group_value_id
					  -- LEFT JOIN mv90_DST mv1
							--ON  ([Term]) = (mv1.date)
							--AND mv1.insert_delete = ''d''
							--AND mv1.Hour = CAST(unpvt.Hour AS INT)
							--AND mv1.dst_group_value_id = tz.dst_group_value_id
					  -- LEFT JOIN mv90_DST mv2
							--ON  YEAR([Term]) = (mv2.YEAR)
							--AND mv2.insert_delete = ''d''
							--AND mv2.dst_group_value_id = tz.dst_group_value_id
					   LEFT JOIN mv90_DST mv3
							ON  YEAR([Term]) = (mv3.YEAR)
							AND mv3.insert_delete = ''i''
							AND mv3.dst_group_value_id = tz.dst_group_value_id
						WHERE 1 = 1 
						AND ( CASE 
								WHEN ''' + @grouping_option + ''' = ''d'' THEN CASE WHEN mv.date IS NOT NULL THEN mv.Hour ELSE unpvt.Hour END
								ELSE  unpvt.Hour
							END 
							BETWEEN ' + CAST(ISNULL(@hour_from,1) AS VARCHAR) + ' AND ' + CAST(ISNULL(@hour_to,24) AS VARCHAR) + 
						') 						 
						AND (
							   (CAST(unpvt.Hour AS INT) = 25 AND mv.date IS NOT NULL)
							   OR (CAST(unpvt.Hour AS INT) <> 25)
						   )
					   --AND (mv1.date IS NULL)
					   ' +
						CASE WHEN @grouping_option = 's' THEN ' GROUP BY profile_name,external_id, term ORDER BY profile_name,CAST(term AS DATETIME) ' ELSE '' END +  
						CASE WHEN @grouping_option = 'd' THEN ' GROUP BY profile_name,external_id, term, mv3.date, mv.date,mv3.[Hour], mv.Hour, unpvt.Hour ORDER BY profile_name,CAST(term AS DATETIME), 

							CASE 
								WHEN mv.date IS NOT NULL THEN mv.Hour
								ELSE CAST(unpvt.Hour AS INT)
						   END' ELSE '' END	
		END				
		EXEC spa_print @sqlStmt
		EXEC(@sqlStmt)
	END			
END

/*******************************************2nd Paging Batch START**********************************************/
--update time spent and batch completion message in message board
IF @is_batch = 1
BEGIN
	SELECT @str_batch_table = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL)   
	EXEC(@str_batch_table)                   

	SELECT @str_batch_table = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, GETDATE(), 'spa_load_forecast_report', 'Load Forecast Report')         
	EXEC(@str_batch_table)        
	RETURN
END

--IF it is first call from paging, return total no. of rows and process id instead of actual data
IF @enable_paging = 1 AND @page_no IS NULL
BEGIN
	SET @sql_paging = dbo.FNAPagingProcess('t', @batch_process_id, @page_size, @page_no)
	EXEC(@sql_paging)
END
/*******************************************2nd Paging Batch END**********************************************/
