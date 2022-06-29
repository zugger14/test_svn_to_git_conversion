

IF OBJECT_ID(N'spa_monte_carlo_simulation', N'P') IS NOT NULL
	DROP PROC dbo.spa_monte_carlo_simulation
GO
/************************************************************
 * Author ; Santosh Gupta
 * Time: 1/31/2014 11:00:08 AM
 * Description : Monte calro wrapper SP
 ************************************************************/
/****** Object:  StoredProcedure [dbo].[spa_monte_carlo_simulation]    Script Date: 1/29/2014 4:18:14 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[spa_monte_carlo_simulation]
	 @as_of_date DATETIME
	, @term_start DATETIME
	, @term_end DATETIME
	, @no_simulation INT
	, @model_id INT
	, @risk_ids VARCHAR(1000)
	, @all_risk VARCHAR(1)
	, @purge VARCHAR(1)
    , @run_cor_decom VARCHAR(1)
    , @criteria_id INT = NULL
	, @run_source_type INT
	, @batch_process_id VARCHAR(100) = NULL
	, @batch_report_param VARCHAR(MAX) = NULL
AS 

/*
DECLARE
	 @as_of_date DATETIME = '2019-04-30'
	, @term_start DATETIME = '2019-05-01'
	, @term_end DATETIME = '2019-07-01'
	, @no_simulation INT = 3000
	, @model_id INT
	, @risk_ids VARCHAR(1000) = '7176'
	, @all_risk VARCHAR(1)
	, @purge VARCHAR(1) = 'y'
    , @run_cor_decom VARCHAR(1) = 'n'
    , @criteria_id INT = NULL
	, @run_source_type INT = NULL
	, @batch_process_id VARCHAR(100) = NULL
	, @batch_report_param VARCHAR(MAX) = NULL
--*/

BEGIN
	DECLARE @st_where_book  VARCHAR(1000),
	        @st_where       VARCHAR(8000)
	
	DECLARE @st_stmt        VARCHAR(8000),
	        @spa            VARCHAR(2000),
	        @user_login_id  VARCHAR(2000),
	        @job_name       VARCHAR(2000),
			@user_name		VARCHAR(50),
			@curve_info		VARCHAR(128),
			@curve_detail   VARCHAR(128),
			@process_id		VARCHAR(100) 
	--SET @risk_ids = '239,240,241,242,246,245,250,238,249,244,247,237'
	IF @risk_ids = ''
		SET @risk_ids = NULL
		
	SET @process_id = @batch_process_id
	SET @user_name = dbo.FNADBUser()
	SET @criteria_id = ISNULL(@criteria_id, 0)
	SET @run_source_type = ISNULL(@run_source_type, 1522)
	SET @run_cor_decom = CASE WHEN @run_source_type = 1521 THEN 'N' ELSE 'Y' END

	IF @process_id IS NULL
		SET @process_id = dbo.FNAGetNewID()
	
	SET @curve_info = dbo.FNAProcessTableName('Curve_Info', @user_name, @process_id)
	SET @curve_detail = dbo.FNAProcessTableName('Curve_Detail', @user_name, @process_id)--Used only in spa_monte_carlo_simulation_core
	
--SELECT @risk_ids	
	
	IF OBJECT_ID('tempdb..#tmp_curve_info') IS NOT NULL
		DROP TABLE #tmp_curve_info

	SELECT item AS curve_id
	INTO #tmp_curve_info
	FROM dbo.FNASplit(@risk_ids, ',')
	
	SET @risk_ids = NULL
	
	SELECT @risk_ids = COALESCE(@risk_ids + ',', '') + CAST(spcd.source_curve_def_id AS VARCHAR)
	FROM(
		SELECT CASE WHEN spcd.Granularity IN (993,980,991,992) THEN 
				spcd.source_curve_def_id 
			ELSE 
				COALESCE(spcd1.source_curve_def_id, spcd2.source_curve_def_id, spcd3.source_curve_def_id)
			END AS source_curve_def_id
		FROM #tmp_curve_info AS tci
		INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = tci.curve_id
		LEFT JOIN source_price_curve_def spcd1 ON spcd1.source_curve_def_id = spcd.proxy_source_curve_def_id
			AND spcd1.Granularity IN (993,980,991,992)
		LEFT JOIN source_price_curve_def spcd2 ON spcd2.source_curve_def_id = spcd.monthly_index
			AND spcd2.Granularity IN (993,980,991,992)
		LEFT JOIN source_price_curve_def spcd3 ON spcd3.source_curve_def_id = spcd.proxy_curve_id3
			AND spcd3.Granularity IN (993,980,991,992)) spcd 
	GROUP BY spcd.source_curve_def_id

	SET @st_where = ''
	IF @model_id IS NOT NULL
	    SET @st_where = @st_where + ' and spcd.monte_carlo_model_parameter_id=' + 
	        CAST(@model_id AS VARCHAR)	
	
	IF ((@risk_ids IS NOT NULL) AND (@model_id IS NOT NULL))
	    SET @st_where = @st_where + ' OR spcd.source_curve_def_id in  (' + @risk_ids
	        + ')'
	
	IF ((@risk_ids IS NOT NULL) AND (@model_id IS NULL))
	    SET @st_where = @st_where + ' AND spcd.source_curve_def_id in (' + @risk_ids
	        + ')'	
	
	IF OBJECT_ID('tempdb..#tmp_risk1') IS NOT NULL
	    DROP TABLE #tmp_risk1
	
	CREATE TABLE #tmp_risk1
	(
		id              INT IDENTITY(1, 1),
		curve_id        INT,
		Granularity     VARCHAR(1) COLLATE DATABASE_DEFAULT ,
		[volatility]    VARCHAR(50) COLLATE DATABASE_DEFAULT ,
		[drift]         VARCHAR(50) COLLATE DATABASE_DEFAULT ,
		[data_series]   INT,
		[curve_source]  INT,
		seed            VARCHAR(50) COLLATE DATABASE_DEFAULT ,
		volatility_source INT,
		risk_bucket_id INT
	)	
	
	SET @st_stmt = 
	    '
	INSERT into #tmp_risk1 (curve_id,Granularity, [volatility], [drift] ,[data_series] ,[curve_source],seed, volatility_source)
		SELECT  DISTINCT spcd.source_curve_def_id curve_id,
		CASE spcd.Granularity 
			when 982 then ''h''	when 981 then ''d'' when 980 then ''m'' 
			WHEN 991 THEN ''q'' WHEN 992 THEN ''s'' WHEN 993 THEN ''a'' ELSE ''w''
		end Granularity, m.volatility, m.drift, m.data_series, m.curve_source, m.seed, ISNULL(m.volatility_source, m.curve_source)
		FROM source_price_curve_def spcd 
		LEFT JOIN monte_carlo_model_parameter m ON m.monte_carlo_model_parameter_id = spcd.monte_carlo_model_parameter_id
		WHERE 1 = 1 ' + @st_where
	
	EXEC spa_print @st_stmt
	EXEC (@st_stmt)
	
	
	UPDATE tr SET volatility = t.volatility, 
		drift = t.drift, 
		data_series = t.data_series, 
		curve_source = t.curve_source, 
		seed = t.seed,
		volatility_source = t.volatility_source
	FROM #tmp_risk1 tr
	OUTER APPLY(SELECT TOP 1 * FROM #tmp_risk1) t
	
	--SELECT * FROM #tmp_risk1 RETURN	
		
	IF NOT EXISTS(SELECT TOP 1 1 FROM #tmp_risk1)
	BEGIN
		DECLARE @desc VARCHAR(500), @url VARCHAR(500), @url_desc VARCHAR(500)
		INSERT  INTO fas_eff_ass_test_run_log(process_id,code,module,source,type,description,nextsteps)
		SELECT DISTINCT @process_id,'Error','Price Simulation','Price Simulation','Monte Carlo Model','Simulation parameters not defined or curves not found for As of Date:'
			+ dbo.FNADateFormat(@as_of_date)+ '.','Please check data.'
		
		SET @desc='Price Simulation Calculation process is completed for ' + dbo.FNAUserDateFormat(@as_of_date, @user_name) + ' (ERRORS found).'
		SELECT @url = './dev/spa_html.php?__user_name__=' + @user_name + 
				'&spa=exec spa_fas_eff_ass_test_run_log ''' + @process_id + ''',''y'''
		
		SELECT @desc = '<a target="_blank" href="' + @url + '">' + @desc + '.</a>'
		
		SET @url_desc='<a href="../../dev/spa_html.php?spa=spa_fas_eff_ass_test_run_log '''+@process_id+'''">Click here...</a>'
		SELECT 'Error' ErrorCode, 'Price Simulation' module, 
			'spa_monte_carlo_simulation' area, 'DB Error' status, 
		'Price Simulation process completed with error, Please view this report. '+@url_desc message, '' recommendation
		
		EXEC  spa_message_board 'i', @user_name,
			NULL, 'Run_Price_Simulation',
			@desc, '', '', 'e', 'Run_Price_Simulation',NULL,@process_id
					
		RETURN 		

	END

	IF EXISTS(SELECT TOP 1 1 FROM dbo.SplitCommaSeperatedValues(@risk_ids) tt WHERE NOT EXISTS(SELECT curve_id FROM #tmp_risk1 WHERE curve_id = item))
	BEGIN
		INSERT  INTO fas_eff_ass_test_run_log(process_id,code,module,source,type,description,nextsteps)
		SELECT DISTINCT @process_id,'Error','Price Simulation','Price Simulation','Monte Carlo Model','Risk Factor Model is not mapped for Curve ID:'
			+ CAST(item AS VARCHAR) + '.','Please check data.'
		FROM dbo.SplitCommaSeperatedValues(@risk_ids) tt WHERE NOT EXISTS(SELECT curve_id FROM #tmp_risk1 WHERE curve_id = item)	
	END 
	--Cholesky decomposition and matrix multiplication enhancement start
	IF OBJECT_ID(@curve_info) IS NOT NULL
		EXEC('DROP TABLE ' + @curve_info)

	SET @st_stmt = '
		SELECT DISTINCT tr.curve_id,
			tr.volatility_source,
			ISNULL(spcd.risk_bucket_id, tr.curve_id) risk_bucket_id
		INTO ' + @curve_info + '
		FROM #tmp_risk1 tr
		INNER JOIN source_price_curve_def spcd ON tr.curve_id = spcd.source_curve_def_id'
	
	EXEC spa_print @st_stmt
	EXEC (@st_stmt)


	--SET @risk_ids = ''
	--SELECT @risk_ids = @risk_ids + CAST([curve_id] AS VARCHAR) + ',' FROM #tmp_risk1
	
--SELECT @as_of_date, @term_start, @term_end, @no_simulation, @criteria_id, @process_id, @purge	
	IF @run_cor_decom = 'y'
	BEGIN
		EXEC spa_calc_matrix_multiplication @as_of_date, @term_start, @term_end, @no_simulation, @criteria_id, @process_id, @purge

		--IF EXISTS(SELECT * FROM fas_eff_ass_test_run_log WHERE process_id = @process_id AND code ='Error' AND source <> 'Price Simulation')
			--RETURN
	END
	--Cholesky decomposition and matrix multiplication enhancement end
	IF OBJECT_ID(@curve_detail) IS NOT NULL
		EXEC('DROP TABLE ' + @curve_detail)

	SET @st_stmt = '
		SELECT curve_id,
			Granularity,
			volatility,
			drift,
			data_series,
			curve_source,
			seed,
			volatility_source
		INTO ' + @curve_detail + '
		FROM #tmp_risk1 tr'
	
	EXEC spa_print @st_stmt
	EXEC (@st_stmt)
 	
	SET @user_login_id = ISNULL(@user_login_id, dbo.FNADBUser())

	--select * from #tmp_risk1
	DECLARE @i    INT = 1,
	        @ii   INT = 1,
	        @cid  INT
	
	SELECT @i = COUNT(*)
	FROM   #tmp_risk1
	---- -Drop all indexes 
	WHILE (@ii <= @i)
	BEGIN
	    SELECT @cid = curve_id
	    FROM   #tmp_risk1
	    WHERE  id = @ii
	    EXEC spa_print @cid
	  
		IF (@ii = 1)
			SET @purge = ISNULL(@purge,'n')
		ELSE
			SET @purge = 'n'
	    --exec  spa_monte_carlo_simulation @as_of_date,@term_start,@term_end,@no_simulation,@model_id,@cid,@all_risk,@purge
	    SET @spa = 'spa_monte_carlo_simulation_core 
			''' + CONVERT(VARCHAR(10), @as_of_date, 120) + ''', 
			''' + CONVERT(VARCHAR(10), @term_start, 120) + ''',
			''' + CONVERT(VARCHAR(10), @term_end, 120) + ''',
			' + CAST(@no_simulation AS varchar(10)) + ', 
			NULL,
			''' + CAST(@cid AS VARCHAR(10)) + ''',
			''' + cast(ISNULL(@all_risk,'n') as varchar(1))+ ''',
			''' + cast(ISNULL(@purge,'n') as varchar(1)) + ''',
			' + CAST(@criteria_id AS VARCHAR) + ',
			' + CAST(@run_source_type AS VARCHAR) + ',
			''' + @process_id + ''''

	    --select @spa
	    SET @job_name = 'FARRMS- Price Simulation_' + isnull(cast(@cid as varchar(10)),'_') + '_' + isnull(cast(@criteria_id as varchar(10)),'_') + '_' +  @process_id  
	    EXEC spa_run_sp_as_job @job_name,
	         @spa,
	         'FARRMS- Price Simulation_',
	         @user_login_id
			   
	         INSERT INTO tbl_sims_status (process_id, curve_id,sims_STATUS,create_user) VALUES (@process_id, @cid, 'R', @user_login_id)
	    
	 --   select @job_name
		--select @user_login_id
	    
	    SET @ii = @ii + 1
	END
END
