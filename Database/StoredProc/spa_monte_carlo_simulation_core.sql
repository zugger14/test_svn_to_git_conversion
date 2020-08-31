IF OBJECT_ID('spa_monte_carlo_simulation_core') IS NOT NULL
DROP PROC dbo.spa_monte_carlo_simulation_core

GO
CREATE PROC dbo.spa_monte_carlo_simulation_core
	@as_of_date DATETIME
	, @term_start DATETIME
	, @term_end DATETIME
	, @no_simulation INT
	, @model_id INT
	, @risk_ids VARCHAR(1000)
	, @all_risk VARCHAR(1)
	, @purge VARCHAR(1)
	, @criteria_id INT = NULL
	, @run_source_type INT
	, @process_id VARCHAR(100) = NULL
	, @param VARCHAR(MAX) = NULL
AS 

/*
--========================--
--Modified by: Shushil Bohara
--Midified dt: 11-Jul-2012
--========================--
-------------------------Test Start------------------------------------------------
--EXEC spa_monte_carlo_simulation_core '2012-04-12', '2013-01-01', '2013-03-01', 10, NULL, '105,138', NULL, 'n',null
--exec [dbo].[spa_monte_carlo_simulation_core] '2012-04-12','2013-01-01','2013-03-01',100,null,90,null,null,null
DECLARE 
	@as_of_date DATETIME= '2019-04-30'
	, @term_start DATETIME = '2019-05-01'
	, @term_end DATETIME = '2019-06-30'
	, @no_simulation INT = 28
	, @model_id INT = NULL
	, @risk_ids VARCHAR(1000) ='7176'
	, @all_risk VARCHAR(1) = NULL
	, @purge VARCHAR(1) = 'y'
	, @criteria_id INT = 0
	, @run_source_type INT = 1521
	, @process_id VARCHAR(100) = 'C3ABE9DC_555E_47DA_B09C_B9B3EDB440EB'
	, @param VARCHAR(MAX) = NULL
 
 
 
DROP TABLE  #as_of_date_point1
DROP TABLE  #tmp_data_drift
DROP TABLE  #tmp_data_curve
DROP TABLE  #tmp_data_vol
DROP TABLE  #tmp_term_monte
DROP TABLE #tmp_risk1
--DROP TABLE #tmp_err1
DROP TABLE #tmp_data_vol
DROP TABLE #tmp_data_drift
close tblCursor_risk
	DEALLOCATE tblCursor_risk
			close tblCursor
		DEALLOCATE tblCursor
		
DROP TABLE  #tmp_data_drift 
DROP TABLE  #tmp_data_curve 
DROP TABLE  #tmp_data_vol 
		
		
		
--*/
--------------------------end test--------------------------------------------------------
DECLARE @st_where_book VARCHAR(1000),@source_book_mapping_id INT,@curve_as_of_date DateTime
DECLARE @st_stmt VARCHAR(8000),@st_where VARCHAR(8000),@module VARCHAR(100),@source VARCHAR(100)
DECLARE @use_cor_rnd INT
SELECT @use_cor_rnd = ISNULL(var_value, 1) FROM adiha_default_codes_values where default_code_id = 58
DECLARE @no_days_yr FLOAT
SET @no_days_yr=1/1.0

DECLARE @user_name VARCHAR(50)
SET @user_name=dbo.fnadbuser()
DECLARE @url VARCHAR(500)
DECLARE @desc VARCHAR(500)
DECLARE @errorMsg VARCHAR(200)
DECLARE @errorcode VARCHAR(1),@call_from_var_monte varchar(1)
DECLARE @url_desc VARCHAR(500),@desc1 VARCHAR(1000),@source_curve_id INT=4505
DECLARE @is_raise_error INT = 0 --for raising error at last
DECLARE @cid INT
DECLARE @date_available DATETIME  

--New declaration for revaluation process
DECLARE @revaluation CHAR(1) = NULL
SET @revaluation = CASE WHEN @criteria_id > 0 THEN 'y' ELSE 'n' END

SET @url=''
SET @desc=''
SET @errorMsg=''
SET @errorcode='e'
SET @url_desc=''
SET @desc1=''
set @call_from_var_monte='n'

IF @process_id IS NULL
	SET @process_id = REPLACE(NEWID(),'-','_')
else 
	set @call_from_var_monte='y'
	
DECLARE @random_no VARCHAR(128)
--Volatility shift value enhance
DECLARE @relative_volatility CHAR(1) = 'n'

DECLARE @curve_detail VARCHAR(128)
SET @curve_detail = dbo.FNAProcessTableName('Curve_Detail', @user_name, @process_id)

--CREATE TABLE #tmp_err1 ( curve_id INT,term_start DateTime,curve_source_value_id INT        )
CREATE TABLE #tmp_risk1 (curve_id INT,Granularity VARCHAR(1) COLLATE DATABASE_DEFAULT , [volatility] VARCHAR(50) COLLATE DATABASE_DEFAULT ,	[drift] VARCHAR(50) COLLATE DATABASE_DEFAULT  ,[data_series] INT ,[curve_source] INT,seed VARCHAR(50) COLLATE DATABASE_DEFAULT , volatility_source INT)	
CREATE TABLE #tmp_data_drift ( curve_id INT,term_start DateTime,value FLOAT   )
CREATE TABLE #tmp_data_curve ( curve_id INT,term_start DateTime,value FLOAT , is_dst TINYINT)
CREATE TABLE #tmp_data_vol ( curve_id INT,term_start DateTime,value FLOAT   )
IF OBJECT_ID('tempdb..#tmp_data_all') IS NOT NULL
	DROP TABLE #tmp_data_all
IF OBJECT_ID('tempdb..#tmp_curve_info') IS NOT NULL
	DROP TABLE #tmp_curve_info

BEGIN TRY

DECLARE 
	@confidence_interval  INT ,
	@holding_period  INT ,
	@price_curve_source  INT 

SET @source = 'Price Simulation'
SET @module = 'Price.Simulation'

SET @st_where=''

SET @holding_period=ISNULL(@holding_period,1)
SET @st_where_book = ''

CREATE TABLE #tmp_term_monte (   term_start DateTime,  curve_id INT, curve_source_value_id INT, is_dst TINYINT)

CREATE TABLE #as_of_date_point1 (   row_id INT IDENTITY(1, 1),  as_of_date DateTime   );

WITH user_rec(as_of_date,cnt)AS
(
	SELECT CAST('1900-01-01' AS date) , 0 AS cnt
	UNION ALL 
	SELECT DATEADD(day,(cnt+1),CAST('1900-01-01' AS date)), cnt+1 FROM user_rec r 
	WHERE cnt +1< ISNULL(@no_simulation, 30)
)
INSERT INTO  #as_of_date_point1 (as_of_date)
SELECT as_of_date FROM user_rec
OPTION (MAXRECURSION 0)

CREATE NONCLUSTERED INDEX indx_aodp_as_of_date ON #as_of_date_point1(as_of_date) --WITH (data_compression=page)
	
SET @price_curve_source = ISNULL(@price_curve_source, 4500)

IF @model_id IS NOT NULL
	SET @st_where=@st_where+' and spcd.monte_carlo_model_parameter_id='+CAST(@model_id AS VARCHAR)	

IF ((@risk_ids IS NOT NULL) AND (@model_id IS NOT NULL))
	SET @st_where=@st_where+' OR spcd.source_curve_def_id in  ('+@risk_ids+')'
IF ((@risk_ids IS NOT NULL) AND (@model_id IS NULL))
	SET @st_where=@st_where+' AND spcd.source_curve_def_id in ('+@risk_ids+')'	
 
SET @st_stmt = '
	INSERT into #tmp_risk1 (curve_id,Granularity, [volatility] , [drift] ,[data_series] ,[curve_source],seed, volatility_source)
	SELECT curve_id,
		Granularity,
		volatility,
		drift,
		data_series,
		curve_source,
		seed,
		volatility_source
	FROM ' + @curve_detail + '
	WHERE 1 = 1 ' +
	CASE WHEN @risk_ids IS NOT NULL THEN ' AND curve_id IN ('+@risk_ids+')' ELSE '' END

EXEC spa_print @st_stmt
EXEC(@st_stmt)

SELECT DISTINCT 
		@relative_volatility = ISNULL(mcmp.relative_volatility, 'n') 
	FROM source_price_curve_def spcd
	INNER JOIN #tmp_risk1 ci ON ci.curve_id = spcd.source_curve_def_id
	INNER JOIN monte_carlo_model_parameter mcmp ON spcd.monte_carlo_model_parameter_id = mcmp.monte_carlo_model_parameter_id
		AND mcmp.relative_volatility = 'y'
		
--validation for simulation model null for all curve selected
--IF (NOT EXISTS (SELECT * FROM #tmp_risk1 tr))
--BEGIN
--	EXEC spa_print 'here' 
--	INSERT  INTO fas_eff_ass_test_run_log	( process_id, code, module, source, type, description, nextsteps)
--	SELECT @process_id, 'Error', @module, @source, 'simulation_model', 'Simulation Model not found for Curve ID:'
--			+ spcd.curve_name , 'Please check data.'
--	FROM source_price_curve_def spcd 
--	WHERE spcd.source_curve_def_id IN (@risk_ids)
			
--END



--SET @st_stmt = 'INSERT into #tmp_term_monte (term_start,curve_id, curve_source_value_id)
--	SELECT 	t.term_start,r.curve_id, r.curve_source	from #tmp_risk1 r
--	cross apply
--	 [dbo].[FNATermBreakdown] (r.Granularity,'''+CONVERT(VARCHAR(11),@term_start,120) +''','''+CONVERT(VARCHAR(11),@term_end,120) +''') t

	--Start Curve Granularity Enhancement
	SELECT  curve_id, granularity, t.term_start INTO #tmp_curve_info FROM (
	SELECT clm1_value curve_id
		,CASE clm2_value 
			when 982 then 'h'	when 981 then 'd' when 980 then 'm' 
			WHEN 991 THEN 'q' WHEN 992 THEN 's' WHEN 993 THEN 'a' ELSE 'w'
		END granularity
	FROM generic_mapping_values g
	INNER JOIN dbo.SplitCommaSeperatedValues(@risk_ids) tt ON g.clm1_value = tt.item  
	INNER JOIN generic_mapping_header h ON g.mapping_table_id=h.mapping_table_id
	AND h.mapping_name= 'Curve Granularity') m
	CROSS APPLY [dbo].[FNATermBreakdown] (m.granularity, @term_start,@term_end) t
	--End Curve Granularity Enhancement
	IF OBJECT_ID('tempdb..#tmp_curve_value') IS NOT NULL 
	DROP TABLE #tmp_curve_value

	SELECT spc_inner.source_curve_def_id, maturity_date, spc_max_date.curve_source_value_id, spc_inner.is_dst 
	INTO #tmp_curve_value
	FROM source_price_curve spc_inner
	INNER JOIN (SELECT MAX(as_of_date) max_as_of_date, source_curve_def_id,spc_max_inner.curve_source_value_id
	            FROM source_price_curve spc_max_inner
	            INNER JOIN #tmp_risk1 tr_inner ON spc_max_inner.source_curve_def_id = tr_inner.curve_id 
	            WHERE as_of_date <= @as_of_date  
					AND tr_inner.curve_source = spc_max_inner.curve_source_value_id
	            GROUP BY source_curve_def_id,spc_max_inner.curve_source_value_id
				) spc_max_date ON spc_inner.as_of_date = spc_max_date.max_as_of_date
		AND spc_max_date.source_curve_def_id = spc_inner.source_curve_def_id 
		AND spc_max_date.curve_source_value_id=spc_inner.curve_source_value_id
    
	--Stored most recent and supplied as_of_date to join while inserting into delta table below
	IF OBJECT_ID('tempdb..#tmp_date_info') IS NOT NULL
		DROP TABLE #tmp_date_info
	 
	SELECT MAX(as_of_date) max_as_of_date, @as_of_date as_of_date
	INTO #tmp_date_info
	FROM source_price_curve spc_max_inner
	INNER JOIN #tmp_risk1 tr_inner ON spc_max_inner.source_curve_def_id = tr_inner.curve_id 
	WHERE as_of_date <= @as_of_date  
		AND tr_inner.curve_source = spc_max_inner.curve_source_value_id
	GROUP BY source_curve_def_id,spc_max_inner.curve_source_value_id

	CREATE INDEX [IX_PT_tmp_curve_value_source_curve_def_id_maturity_date_curve_source_value_id] ON [#tmp_curve_value] ([source_curve_def_id], [maturity_date], [curve_source_value_id]) INCLUDE ([is_dst])		

SET @st_stmt = 'INSERT into #tmp_term_monte (term_start, curve_id, curve_source_value_id, is_dst)
	--case 1: custom as_of_date
	SELECT t.term_start, r.curve_id, r.curve_source, spc_custom_date.is_dst
	FROM #tmp_risk1 r
	CROSS APPLY [dbo].[FNATermBreakdown] (r.Granularity, ''' + CONVERT(VARCHAR(11), @term_start, 120) + ''',''' + CONVERT(VARCHAR(11), @term_end, 120) + ''') t
	INNER JOIN source_price_curve spc_custom_date ON spc_custom_date.source_curve_def_id = r.curve_id 
		AND spc_custom_date.as_of_date = CASE WHEN ISDATE(r.seed) = 1 THEN r.seed ELSE ''1990-01-01'' END
		AND t.term_start = spc_custom_date.maturity_date and r.curve_source	=spc_custom_date.curve_source_value_id

	UNION ALL
	
	--case 2: latest as_of_date
	SELECT t.term_start, r.curve_id, r.curve_source	, spc_latest.is_dst
	FROM #tmp_risk1 r
	CROSS APPLY [dbo].[FNATermBreakdown] (r.Granularity, ''' + CONVERT(VARCHAR(11), @term_start, 120) + ''',''' + CONVERT(VARCHAR(11), @term_end, 120) + ''') t
	INNER JOIN #tmp_curve_value spc_latest ON  spc_latest.maturity_date = t.term_start
			AND spc_latest.source_curve_def_id = r.curve_id and spc_latest.curve_source_value_id=r.curve_source
	WHERE (CASE WHEN ISDATE(r.seed) = 1 THEN ''1990-01-01'' ELSE r.seed END) = ''e''
	
	UNION ALL
	 
	----case 3: use custom value
	SELECT 	t.term_start, r.curve_id, r.curve_source, 0	
	FROM #tmp_risk1 r
	CROSS APPLY [dbo].[FNATermBreakdown] (r.Granularity, ''' + CONVERT(VARCHAR(11), @term_start, 120) + ''',''' + CONVERT(VARCHAR(11), @term_end, 120) + ''') t
     WHERE (CASE WHEN ISDATE(r.seed) = 1 THEN ''e'' ELSE r.seed END) <> ''e'''
	
	exec spa_print @st_stmt
	EXEC(@st_stmt)
	
--validate data missing
	IF ((NOT EXISTS(SELECT TOP 1 1 FROM #tmp_term_monte )) OR ((SELECT COUNT(DISTINCT(curve_id)) FROM #tmp_risk1) <> (SELECT COUNT(DISTINCT(curve_id)) FROM #tmp_term_monte))) 
	BEGIN
		 INSERT  INTO fas_eff_ass_test_run_log	( process_id,code,module,source,type,description,nextsteps)
			SELECT DISTINCT	@process_id,'Error',@module,@source,'Price_Curve_Maturity_Date','Price Curve is not found for As_of_Date: '
				+ dbo.FNADateFormat(@as_of_date)+ '; Curve_ID: ' + spcd.curve_id + '.', 'Please check data.'
			FROM #tmp_risk1 tr
			INNER JOIN source_price_curve_def spcd ON tr.curve_id = spcd.source_curve_def_id
			AND spcd.source_curve_def_id IN(
								SELECT DISTINCT(curve_id) curve_id FROM #tmp_risk1
								EXCEPT
								SELECT DISTINCT(curve_id) curve_id FROM #tmp_term_monte
								)	
				
		--RAISERROR ( 'CatchError', 16, 1 )
		SET @is_raise_error = 1
	END
	--Start Curve Granularity Enhancement
	IF EXISTS(SELECT TOP 1 1 FROM #tmp_curve_info)
	BEGIN	
		SELECT ttm.* INTO #tmp_data_all FROM #tmp_term_monte ttm 
		INNER JOIN #tmp_curve_info tci ON ttm.curve_id = tci.curve_id
		WHERE CONVERT(varchar(10),ttm.term_start, 120) = tci.term_start
		
		DELETE ttm FROM #tmp_term_monte ttm
		INNER JOIN #tmp_data_all ta ON ttm.curve_id = ta.curve_id 
		WHERE NOT EXISTS(
			SELECT * FROM #tmp_data_all ta WHERE ttm.curve_source_value_id = ta.curve_source_value_id
			AND ttm.term_start = ta.term_start
		)
	END	
--End Curve Granularity Enhancement	
	
DECLARE @curve_id INT 
		,@volatility VARCHAR(50) 
		,@drift VARCHAR(50) 
		,@data_series INT 
		,@curve_source INT
		,@seed VARCHAR(50)
		,@curve_process_id varchar(250)
		,@volatility_source INT

--CURSOR start here
--updated for multiple delete while performing purge 1/7/2013

IF @purge = 'y'
BEGIN
	IF @revaluation = 'y'
	BEGIN
		SET @st_stmt='
			DELETE spsd FROM [dbo].[source_price_simulation_delta_whatif] spsd
			WHERE spsd.run_date < ''' + CONVERT(VARCHAR(10), @as_of_date, 120) + '''
			AND spsd.curve_source_value_id = CASE WHEN ' + CAST(@run_source_type AS VARCHAR) + '= 1521 THEN 10639 ELSE 4500 END'
		
		EXEC spa_print @st_stmt		 
		EXEC(@st_stmt)

		DELETE spsd FROM [dbo].[source_price_simulation_delta_whatif] spsd 
		WHERE spsd.run_date = @as_of_date 
		and spsd.criteria_id = @criteria_id
	END
	ELSE
	BEGIN
		SET @st_stmt='
		DELETE [dbo].[source_price_curve_simulation] FROM [dbo].[source_price_curve_simulation] spc
		WHERE spc.run_date <= ''' + CONVERT(VARCHAR(10), @as_of_date, 120) + '''
		AND spc.curve_source_value_id = CASE WHEN ' + CAST(@run_source_type AS VARCHAR) + '= 1521 THEN 10639 ELSE 4500 END'
		
		EXEC spa_print @st_stmt		 
		EXEC(@st_stmt)
	
		SET @st_stmt='
			DELETE [dbo].[source_price_simulation_delta] FROM [dbo].[source_price_simulation_delta] spsd
			WHERE spsd.run_date <= ''' + CONVERT(VARCHAR(10), @as_of_date, 120) + '''
			AND spsd.curve_source_value_id = CASE WHEN ' + CAST(@run_source_type AS VARCHAR) + '= 1521 THEN 10639 ELSE 4500 END'
		
		EXEC spa_print @st_stmt	 
		EXEC(@st_stmt)
	END	
END

	SELECT @cid = curve_id FROM #tmp_risk1
	--For Historical Price Simulation
	IF @run_source_type = 1521
	BEGIN
		IF OBJECT_ID('tempdb..#avai_sim_as_of_date') IS NOT NULL
		DROP TABLE #avai_sim_as_of_date

		CREATE TABLE #avai_sim_as_of_date(source_curve_def_id INT, as_of_date DATE, sno_as_of_date INT)

		SET @st_stmt = 'INSERT INTO #avai_sim_as_of_date
				SELECT *, ROW_NUMBER() OVER (ORDER BY as_of_date desc) AS sno_as_of_date 
				FROM (
				SELECT TOP ' + CAST(@no_simulation+1 AS VARCHAR) + ' * FROM (
					SELECT DISTINCT
						spc.source_curve_def_id,  
						spc.as_of_date
					FROM #tmp_term_monte a
					LEFT JOIN source_price_curve spc ON a.curve_id = spc.source_curve_def_id   
						AND a.term_start=spc.maturity_date
						AND spc.as_of_date < ''' + CAST(@as_of_date AS VARCHAR) + ''' 
						AND spc.curve_source_value_id = a.curve_source_value_id
				) a ORDER BY a.as_of_date desc
				) b ORDER BY b.as_of_date'
				 
			exec spa_print @st_stmt
			EXEC(@st_stmt)

		IF ((SELECT COUNT(DISTINCT as_of_date) tot FROM #avai_sim_as_of_date) < @no_simulation)
		BEGIN
			INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, source, TYPE, description, nextsteps) 
			SELECT @process_id,'Error','Price Simulation', 'Historical Simulation', 'Price_Simulation', 'Historical price is not sufficient for As of Date:'+ CONVERT(VARCHAR(10), @as_of_date, 120) + '.','Please check data.'
						
			RAISERROR ('CatchError', 16, 1)
		END

		IF OBJECT_ID('tempdb..#curve_matrix') IS NOT NULL
		DROP TABLE #curve_matrix

		SELECT dp.as_of_date, 
			dp.source_curve_def_id AS curve_id, 
			spc.maturity_date AS term_start, 
			spc.curve_value,
			dp.sno_as_of_date,
			ROW_NUMBER() OVER (PARTITION BY dp.source_curve_def_id,spc.as_of_date ORDER BY spc.maturity_date) sno_maturity,
			data_series,
			cur.curve_value AS cur_price,
			RANK() OVER(PARTITION BY spc.maturity_date ORDER BY dp.as_of_date DESC) rnk 
		INTO #curve_matrix
		FROM source_price_curve_def spcd
		INNER JOIN #tmp_term_monte ttm ON ttm.curve_id = spcd.source_curve_def_id
		INNER JOIN #avai_sim_as_of_date dp ON dp.source_curve_def_id = spcd.source_curve_def_id
		INNER JOIN source_price_curve spc ON spc.source_curve_def_id = dp.source_curve_def_id  
			AND spc.maturity_date = ttm.term_start
			AND spc.curve_source_value_id = ttm.curve_source_value_id
			and dp.as_of_date = spc.as_of_date
		INNER JOIN monte_carlo_model_parameter mcmp ON mcmp.monte_carlo_model_parameter_id = spcd.monte_carlo_model_parameter_id
		OUTER APPLY(SELECT curve_value
					FROM source_price_curve spc
					WHERE spc.as_of_date = @as_of_date
					AND spc.source_curve_def_id = ttm.curve_id
					AND spc.maturity_date = ttm.term_start
					AND spc.curve_source_value_id = 4500) cur

		IF OBJECT_ID('tempdb..#return_matrix') IS NOT NULL
		DROP TABLE #return_matrix

		SELECT @as_of_date AS run_date, 
			t1.curve_id, 
			t1.term_start, 
			t2.as_of_date,
			CASE t1.data_series
				WHEN 1560 THEN t1.curve_value
				WHEN 1561 THEN t2.curve_value - t1.curve_value
				WHEN 1562 THEN (t2.curve_value - t1.curve_value) / NULLIF(t1.curve_value, 0)
				WHEN 1563 THEN EXP(log(t2.curve_value / NULLIF(t1.curve_value,0)))-1
			ELSE 9999
			END curve_value_delta,
			t2.cur_price AS curve_value,
			t2.rnk
		INTO #return_matrix
		FROM #curve_matrix t1 
		INNER JOIN #curve_matrix t2 ON t1.sno_as_of_date = 
									CASE WHEN t1.data_series = 1560 THEN t2.sno_as_of_date ELSE t2.sno_as_of_date + 1 END
			AND t1.term_start = t2.term_start 
			AND t1.curve_id = t2.curve_id

		IF EXISTS (SELECT TOP 1 1 FROM #return_matrix WHERE curve_value IS NULL)
		BEGIN
			INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, source, TYPE, description, nextsteps) 
			SELECT @process_id,'Error','Price Simulation', 'Historical Simulation', 'Price_Simulation', 'Forward price is missing for As of Date:'+ CONVERT(VARCHAR(10), @as_of_date, 120) + '.','Please check data.'
						
			RAISERROR ('CatchError', 16, 1)
		END

		INSERT INTO source_price_simulation_delta (
			run_date,
			source_curve_def_id,
			as_of_date,
			Assessment_curve_type_value_id,
			curve_source_value_id,
			maturity_date,
			is_dst,
			curve_value_main,
			curve_value_sim,
			curve_value_avg,
			curve_value_delta,
			curve_value_avg_delta,
			create_user,
			create_ts
		)
		SELECT run_date,
			curve_id,
			DATEADD(DAY, rnk-1, '1900-01-01') AS as_of_date,
			77,
			10639,
			term_start,
			0,
			curve_value,
			(curve_value+curve_value_delta),
			rm1.curve_value_avg,
			curve_value_delta,
			((curve_value+curve_value_delta)-rm1.curve_value_avg),
			@user_name,
			GETDATE()
		FROM #return_matrix rm
		OUTER APPLY(SELECT AVG(curve_value+curve_value_delta) curve_value_avg
					FROM #return_matrix rm1
					WHERE rm1.curve_id = rm.curve_id
					AND rm1.term_start = rm.term_start
					AND rm1.run_date = rm.run_date) rm1
	END
	ELSE
	BEGIN
		DECLARE tblCursor_risk CURSOR FOR
			SELECT curve_id, [volatility] ,	[drift] ,[data_series] ,curve_source,seed, volatility_source FROM #tmp_risk1
		FOR  READ ONLY

		OPEN  tblCursor_risk
		FETCH NEXT FROM tblCursor_risk INTO @curve_id, @volatility ,@drift ,@data_series ,@curve_source,@seed, @volatility_source
		WHILE @@FETCH_STATUS = 0
		BEGIN
		--TRUNCATE TABLE #tmp_err1
	
			TRUNCATE TABLE #tmp_data_drift
			TRUNCATE TABLE #tmp_data_curve
			TRUNCATE TABLE #tmp_data_vol 
			--select @curve_id, @volatility ,@drift ,@data_series ,@curve_source,@seed
	
			set @curve_process_id=@process_id+'_'+isnull(CAST(@curve_id as varchar),'')
	
			SET @random_no = dbo.FNAProcessTableName('RAND', @user_name, @curve_process_id)

	 
			EXEC('if object_id('''+@random_no+''') is not null
				drop table ' + @random_no)
			--SET @st_stmt='create TABLE '+ @random_no + ' (curve_id INT, risk_id INT, as_of_date DATETIME,term_start DATETIME, rnd_value AS (dbo.FNARandNumber()),curve_value FLOAT,exp_rtn_value FLOAT,vol_value float, is_dst TINYINT)'
			SET @st_stmt='create TABLE '+ @random_no + ' (curve_id INT, risk_id INT, as_of_date DATETIME,term_start DATETIME, ' + CASE WHEN @use_cor_rnd = 0 THEN 'rnd_value AS (dbo.FNARandNumber())' ELSE 'rnd_value FLOAT' END + ', curve_value FLOAT,exp_rtn_value FLOAT,vol_value float, is_dst TINYINT)'
			exec spa_print @st_stmt
			EXEC(@st_stmt)
			exec spa_print @random_no	 
	 
			DECLARE @term_start_max DATETIME
			DECLARE @term_end_max DATETIME
			IF @relative_volatility = 'y'
			BEGIN
				SET @term_start_max = @term_start
				SET @term_end_max = @term_end 
			END
			ELSE
			BEGIN
				SELECT @term_start_max = MIN(term_start) from #tmp_term_monte WHERE curve_id=@curve_id
				SELECT @term_end_max = MAX(term_start) from #tmp_term_monte WHERE curve_id=@curve_id	
			END		
	
	 
			IF @volatility='c'
				EXEC [dbo].[spa_calc_vol_cor_job]
					@as_of_date,
					@price_curve_source  = @curve_source,
					@var_criteria_id = NULL,
					@process_id  = @curve_process_id,
					@curve_ids  = @curve_id,
					@term_start  = @term_start_max,
					@term_end  = @term_end_max,
					@daily_return_data_series  = @data_series,
					@data_points = 30,
					@what_if = 'n',
					@calc_only_vol_cor  = 'y',
					@calc_option = 'v',
					@curve_ids1  = NULL,
					@whatif_criteria_id  = NULL,
					@calc_type  = 'r',
					@tbl_name  = NULL,
					@measurement_approach  = NULL,
					@conf_interval  = NULL,
					@hold_period  = NULL,
					@volatility_source = @volatility_source

			SET @st_stmt='insert into #tmp_data_vol ( curve_id ,term_start,value)
				select DISTINCT ISNULL(risk_spcd.source_curve_def_id,spcd.source_curve_def_id), t.term_start 
				,CAST('+ CASE WHEN ISNUMERIC(@volatility)=1 THEN @volatility + '/SQRT(252)' ELSE ' 
				v.value/sqrt(case v.granularity
				when 706	then 252 --	Annually
				when 700	then 1 --	Daily
				when 703	then 21--	Monthly
				when 704	then 63 --	Quarterly
				when 705	then 126 --	Semi-annually
				when 701	then 5 --	Weekly
				else 1 end) ' END +' as float) FROM #tmp_term_monte t 
				left join source_price_curve_def spcd on t.curve_id=spcd.source_curve_def_id
				LEFT JOIN source_price_curve_def risk_spcd ON risk_spcd.source_curve_def_id = spcd.risk_bucket_id 
					AND spcd.risk_bucket_id IS NOT NULL '
				+CASE WHEN  ISNUMERIC(@volatility)=1 THEN '' 
				ELSE  ' 
					LEFT JOIN	dbo.curve_volatility v ON v.curve_source_value_id='+CAST(ISNULL(@volatility_source, @curve_source) AS VARCHAR)+'
						and v.curve_id=isnull(risk_spcd.source_curve_def_id,spcd.source_curve_def_id)  and v.term = 
						CASE risk_spcd.Granularity 
							WHEN 982 THEN t.term_start WHEN 981 THEN t.term_start WHEN 980 THEN convert(varchar(8),t.term_start,120)+''01''
							WHEN 991 THEN cast(convert(varchar(5),t.[term_start],120)+ cast(case datepart(q, t.term_start) when 1 then 1 when 2 then 4 when 3 then 7 when 4 then 10 end as varchar)+''-01'' as date)
							 WHEN 992 THEN cast(convert(varchar(5),t.[term_start],120)+ cast(case when month(t.term_start) < 7 then 1 else 7 end as varchar)+''-01'' as date)
							  WHEN 993 THEN cast(convert(varchar(5),t.[term_start],120)+ ''01-01'' as date) ELSE  t.term_start
								 END
						and v.as_of_date=''' + CASE WHEN ISDATE(@volatility) = 1 THEN @volatility ELSE CONVERT(VARCHAR(10),@as_of_date,120) END + ''' '
				END
				+ ' where isnull(risk_spcd.source_curve_def_id,spcd.source_curve_def_id)='+CAST(@curve_id AS  VARCHAR)+'
				OR (risk_spcd.source_curve_def_id IS NOT NULL and spcd.source_curve_def_id = '+CAST(@curve_id AS VARCHAR)+')'

			EXEC spa_print @st_stmt
			EXEC(@st_stmt)

			IF @drift='c'
				EXEC [dbo].[spa_calc_vol_cor_job]
					@as_of_date,
					@price_curve_source  = @curve_source,
					@var_criteria_id = NULL,
					@process_id  = @curve_process_id,
					@curve_ids  = @curve_id,
					@term_start  = @term_start_max,
					@term_end  = @term_end_max,
					@daily_return_data_series  = @data_series,
					@data_points = 30,
					@what_if = 'n',
					@calc_only_vol_cor  = 'y',
					@calc_option = 'd',
					@curve_ids1  = NULL,
					@whatif_criteria_id  = NULL,
					@calc_type  = 'r',
					@tbl_name  = NULL,
					@measurement_approach  = NULL,
					@conf_interval  = NULL,
					@hold_period  = NULL,
					@volatility_source = @volatility_source


			SET @st_stmt='insert into #tmp_data_drift ( curve_id ,term_start ,value   )
				select DISTINCT ISNULL(risk_spcd.source_curve_def_id,spcd.source_curve_def_id), t.term_start  
				,CAST('+ CASE WHEN ISNUMERIC(@drift)=1 THEN @drift + '/252' ELSE 
				' v.value/(case v.granularity
				when 706	then 252 --	Annually
				when 700	then 1 --	Daily
				when 703	then 21--	Monthly
				when 704	then 63 --	Quarterly
				when 705	then 126 --	Semi-annually
				when 701	then 5 --	Weekly
				else 1 end) ' END +' as float)
				FROM #tmp_term_monte t 
				LEFT JOIN source_price_curve_def spcd on t.curve_id=spcd.source_curve_def_id
				LEFT JOIN source_price_curve_def risk_spcd ON risk_spcd.source_curve_def_id = spcd.risk_bucket_id 
						AND spcd.risk_bucket_id IS NOT NULL '
				+CASE WHEN  ISNUMERIC(@drift)=1 THEN '' 
					ELSE  ' 
						left join  dbo.expected_return v ON v.curve_source_value_id='+CAST(ISNULL(@volatility_source, @curve_source) AS VARCHAR)+'
						and v.curve_id=isnull(risk_spcd.source_curve_def_id,spcd.source_curve_def_id)  and v.term =
						CASE risk_spcd.Granularity 
							WHEN 982 THEN t.term_start WHEN 981 THEN t.term_start WHEN 980 THEN convert(varchar(8),t.term_start,120)+''01''
							WHEN 991 THEN cast(convert(varchar(5),t.[term_start],120)+ cast(case datepart(q, t.term_start) when 1 then 1 when 2 then 4 when 3 then 7 when 4 then 10 end as varchar)+''-01'' as date)
							 WHEN 992 THEN cast(convert(varchar(5),t.[term_start],120)+ cast(case when month(t.term_start) < 7 then 1 else 7 end as varchar)+''-01'' as date)
							  WHEN 993 THEN cast(convert(varchar(5),t.[term_start],120)+ ''01-01'' as date) ELSE  t.term_start
				END
						and v.as_of_date=''' + CASE WHEN ISDATE(@drift) = 1 THEN @drift ELSE CONVERT(VARCHAR(10),@as_of_date,120) END + ''' '
				END
				+ ' where ISNULL(risk_spcd.source_curve_def_id,spcd.source_curve_def_id)='+CAST(@curve_id AS VARCHAR) + '
				OR (risk_spcd.source_curve_def_id IS NOT NULL and spcd.source_curve_def_id = '+CAST(@curve_id AS VARCHAR)+')'
		
			EXEC spa_print @st_stmt
			EXEC(@st_stmt)

			SET @st_stmt='insert into #tmp_data_curve ( curve_id ,term_start ,value, is_dst)
			select t.curve_id,t.term_start,'+CASE WHEN ISNUMERIC(@seed)=1 THEN @seed	WHEN  @seed='e' THEN '  p.curve_value '	ELSE  ' spc.curve_value'	END
			 +'	 value, t.is_dst 
			FROM #tmp_term_monte t '
			+CASE WHEN  ISNUMERIC(@seed)=1 THEN '' 
				WHEN  @seed='e' THEN ' outer apply  (select top(1) spc.curve_value from dbo.source_price_curve spc	where spc.source_curve_def_id=t.curve_id and spc.curve_source_value_id=t.curve_source_value_id and t.term_start=spc.maturity_date and t.is_dst = spc.is_dst and spc.as_of_date<=''' + CONVERT(VARCHAR(10),@as_of_date,120) + ''' order by spc.as_of_date desc) p '
				ELSE ' left join  dbo.source_price_curve spc ON spc.source_curve_def_id=t.curve_id and spc.curve_source_value_id=t.curve_source_value_id and t.term_start=spc.maturity_date and t.is_dst = spc.is_dst and spc.as_of_date=''' + @seed + ''' '
			END+ ' where t.curve_id='+CAST(@curve_id as varchar)
	
			EXEC spa_print @st_stmt
			EXEC(@st_stmt)

		--validate data missing

			IF ISNUMERIC(@drift)<>1
			BEGIN 
				IF NOT EXISTS(SELECT TOP 1 1 FROM #tmp_data_drift) 
				BEGIN
					INSERT  INTO fas_eff_ass_test_run_log(process_id,code,module,source,type,description,nextsteps)
					SELECT DISTINCT @process_id,'Error',@module,@source,'Expected_return_As_of_Date','Expected return value is not found for As_of_Date:'
						+ dbo.FNADateFormat(@as_of_date)+ '.','Please check data.'
					--RAISERROR ( 'CatchError', 16, 1 )
					SET @is_raise_error = 1
			   END
		   END

			IF ISNUMERIC(@volatility)<>1
			BEGIN 
				IF NOT EXISTS(SELECT TOP 1 1 FROM #tmp_data_vol) 
				BEGIN
					INSERT  INTO fas_eff_ass_test_run_log(process_id,code,module,source,type,description,nextsteps)
					SELECT DISTINCT @process_id,'Error',@module,@source,'volatility_As_of_Date','Volatility Data is not found for As_of_Date:'
						+ dbo.FNADateFormat(@as_of_date)+ '.','Please check data.'
						
					--RAISERROR ( 'CatchError', 16, 1 )
					SET @is_raise_error = 1
			   END;
			END

			IF NOT EXISTS(SELECT TOP 1 1 FROM #tmp_data_curve) 
			BEGIN
				 INSERT  INTO fas_eff_ass_test_run_log	( process_id,code,module,source,type,description,nextsteps)
					SELECT DISTINCT	@process_id,'Error',@module,@source,'Price_Curve_Maturity_Date','Price Curve is not found for As_of_Date:'
						+ dbo.FNADateFormat(@as_of_date)+ '.',	'Please check data.'
				FROM    #tmp_data_curve t
				INNER JOIN source_price_curve_def spcd ON t.curve_id = spcd.source_curve_def_id
				INNER JOIN static_data_value s ON s.value_id = @volatility_source
				WHERE value IS NULL 
		
				--RAISERROR ( 'CatchError', 16, 1 )
				SET @is_raise_error = 1
			END


			IF EXISTS (SELECT TOP 1 1 FROM #tmp_data_drift WHERE value IS NULL) 
			BEGIN
				INSERT  INTO fas_eff_ass_test_run_log(process_id,code,module,source,type,description,nextsteps)
				SELECT DISTINCT @process_id,'Error',@module,@source,'Expected_return_As_of_Date','Expected return value is not found for As_of_Date:'
					+ dbo.FNADateFormat(@as_of_date)+ '; Curve_ID:' + spcd.curve_id+ '; Maturity Date: '+ dbo.FNADateFormat(term_start) + '.','Please check data.'
				FROM    #tmp_data_drift t
					INNER JOIN source_price_curve_def spcd ON t.curve_id = spcd.source_curve_def_id 
				WHERE value IS NULL
		
				--RAISERROR ( 'CatchError', 16, 1 )
				SET @is_raise_error = 1
		   END
			IF EXISTS(SELECT TOP 1 1 FROM #tmp_data_vol WHERE value IS NULL) 
			BEGIN
				INSERT  INTO fas_eff_ass_test_run_log(process_id,code,module,source,type,description,nextsteps)
				SELECT DISTINCT @process_id,'Error',@module,@source,'volatility_As_of_Date','Volatility value is not found for As_of_Date:'
					+ dbo.FNADateFormat(@as_of_date)+ '; Curve_ID:' + spcd.curve_id+ '; Maturity Date: '+ dbo.FNADateFormat(term_start) + '.','Please check data.'
				FROM    #tmp_data_vol t INNER JOIN source_price_curve_def spcd ON t.curve_id = spcd.source_curve_def_id 
				WHERE value IS NULL
		
				--RAISERROR ( 'CatchError', 16, 1 )
				SET @is_raise_error = 1
		   END;

			IF EXISTS(SELECT TOP 1 1 FROM #tmp_data_curve WHERE value IS NULL) 
			BEGIN
				 INSERT  INTO fas_eff_ass_test_run_log	( process_id,code,module,source,type,description,nextsteps)
					SELECT DISTINCT	@process_id,'Error',@module,@source,'Price_Curve_Maturity_Date','Price Curve is not found for As_of_Date:'
						+ dbo.FNADateFormat(@as_of_date)+ '; Curve_ID:'+ spcd.curve_id+ '; Maturity Date: '+ dbo.FNADateFormat(term_start)+ '; Curve Price Source:'
						+ s.code + '.',	'Please check data.'
				FROM    #tmp_data_curve t
				INNER JOIN source_price_curve_def spcd ON t.curve_id = spcd.source_curve_def_id
				INNER JOIN static_data_value s ON s.value_id = @volatility_source
				WHERE value IS NULL 
		
				--RAISERROR ( 'CatchError', 16, 1 )
				SET @is_raise_error = 1
			END
		
			--New Price Shift Enhancement for Revaluation Start
			--DT: 2-Feb-2015 - sbohara
			DECLARE @whatif_shift VARCHAR(250), @whatif_shift_new VARCHAR(250)
	
			SET @whatif_shift= dbo.FNAProcessTableName('whatif_shift', @user_name, @process_id)
			SET @whatif_shift_new= dbo.FNAProcessTableName('whatif_shift_new', @user_name, @process_id)
	
			IF @revaluation = 'y'
			BEGIN
				IF OBJECT_ID('tempdb..#whatif_shift_mtm') IS NOT NULL DROP TABLE #whatif_shift_mtm
				IF OBJECT_ID('tempdb..#whatif_shift_mtm_new') IS NOT NULL DROP TABLE #whatif_shift_mtm_new

				CREATE TABLE #whatif_shift_mtm(curve_id INT,curve_shift_val FLOAT ,curve_shift_per FLOAT, shift_by CHAR(1) COLLATE DATABASE_DEFAULT )
				CREATE TABLE #whatif_shift_mtm_new(curve_id INT,curve_shift_val FLOAT ,curve_shift_per FLOAT, shift_by CHAR(1) COLLATE DATABASE_DEFAULT )

				IF OBJECT_ID(@whatif_shift) IS NOT NULL
					EXEC('INSERT INTO #whatif_shift_mtm(curve_id,curve_shift_val ,curve_shift_per, shift_by) SELECT curve_id,curve_shift_val, curve_shift_per, shift_by FROM ' + @whatif_shift)
				IF OBJECT_ID(@whatif_shift_new) IS NOT NULL
					EXEC('INSERT INTO #whatif_shift_mtm_new(curve_id,curve_shift_val ,curve_shift_per, shift_by) SELECT curve_id,curve_shift_val ,curve_shift_per, shift_by FROM '+@whatif_shift_new)
	
				IF OBJECT_ID('tempdb..#tmp_as_of_date') IS NOT NULL DROP TABLE #tmp_as_of_date
				SELECT 
					spc.source_curve_def_id,
					MAX(spc.as_of_date) as_of_date
				INTO #tmp_as_of_date	
				FROM source_price_curve spc
				INNER JOIN #whatif_shift_mtm_new wsmn ON spc.source_curve_def_id = wsmn.curve_shift_val
				WHERE as_of_date <= @as_of_date AND curve_source_value_id = @price_curve_source
				GROUP BY spc.source_curve_def_id

				IF OBJECT_ID('tempdb..#source_price_curve') IS NOT NULL DROP TABLE #source_price_curve
				SELECT  
					DATEDIFF(MM, taod.as_of_date, maturity_date) id, 
					wsm.curve_id source_curve_def_id, 
					spc.as_of_date, 
					spc.curve_source_value_id, 
					spc.maturity_date, 
					spc.curve_value,
					spcd.Granularity
				INTO #source_price_curve	 
				FROM source_price_curve spc
				INNER JOIN #tmp_as_of_date taod ON taod.source_curve_def_id = spc.source_curve_def_id
					AND taod.as_of_date = spc.as_of_date
				INNER JOIN source_price_curve_def spcd ON spc.source_curve_def_id = spcd.source_curve_def_id
					AND spcd.Granularity = 980
				INNER JOIN #whatif_shift_mtm_new wsm ON spcd.source_curve_def_id = wsm.curve_shift_val
				WHERE spc.curve_source_value_id	= 4500
					AND DATEDIFF(MM, taod.as_of_date, maturity_date) >= 0
				ORDER BY spc.maturity_date	
	
				IF OBJECT_ID('tempdb..#min_id') IS NOT NULL DROP TABLE #min_id	
				SELECT
					source_curve_def_id, 
					MIN(id) min_id
				INTO #min_id	
				FROM #source_price_curve GROUP BY source_curve_def_id	
	
				IF OBJECT_ID('tempdb..#tmp_data_curve_one') IS NOT NULL DROP TABLE #tmp_data_curve_one
				SELECT 
					CASE WHEN mi.min_id >= DATEDIFF(MM, @as_of_date, term_start) THEN mi.min_id ELSE DATEDIFF(MM, @as_of_date, term_start) END id, 
					tc.* 
				INTO #tmp_data_curve_one 
				FROM #tmp_data_curve tc
				INNER JOIN #whatif_shift_mtm_new wsm ON tc.curve_id = wsm.curve_id
				INNER JOIN #tmp_as_of_date taod ON taod.source_curve_def_id = wsm.curve_shift_val
					AND DATEDIFF(MM, @as_of_date, term_start) >= 0
				LEFT JOIN #min_id mi ON tc.curve_id	= mi.source_curve_def_id
				ORDER BY CONVERT(VARCHAR(7), tc.term_start, 120)
	
				DELETE tc FROM #tmp_data_curve tc
				INNER JOIN #whatif_shift_mtm_new wsm ON tc.curve_id = wsm.curve_id

				UPDATE 
					tco SET value = CASE wsm.shift_by WHEN 'c' THEN tco.value*(1+spc.curve_value/100) ELSE tco.value+spc.curve_value END
				FROM #tmp_data_curve_one tco
				INNER JOIN #source_price_curve spc ON tco.id = spc.id
					AND tco.curve_id = spc.source_curve_def_id
				INNER JOIN #whatif_shift_mtm_new wsm ON spc.source_curve_def_id = wsm.curve_id

				IF EXISTS(SELECT 1 FROM #whatif_shift_mtm)
					UPDATE tdc SET tdc.value = CASE WHEN wsm.shift_by = 'v' THEN (tdc.value+wsm.curve_shift_val) ELSE (tdc.value*wsm.curve_shift_per) END
					FROM #tmp_data_curve tdc
					INNER JOIN #whatif_shift_mtm wsm ON wsm.curve_id = tdc.curve_id
	 
				INSERT INTO #tmp_data_curve
				SELECT curve_id, term_start, value, is_dst 
				FROM #tmp_data_curve_one 
				--New Shift Enhancement End
			END
			---------------------------------------------------------------------
			--generating price curve and saving it in source_price_curve
			-----------------------------------------------------------------------
			--Oprimized by Shushilbohara
			--Inserting Data Directly Instead of Using Cursor 
			--Random number generated by function using view
			IF @use_cor_rnd = 0
			BEGIN
				SET @st_stmt='
				INSERT INTO '+ @random_no + ' (curve_id, risk_id, as_of_date, term_start,  curve_value, exp_rtn_value, vol_value, is_dst)
				SELECT cur.curve_id, cur.risk_id, dt.as_of_date, cur.term_start,  cur.curve_value, cur.exp_rtn_value, cur.vol_value, 
					cur.is_dst
				FROM
				#as_of_date_point1 dt
				CROSS JOIN (
					SELECT c.curve_id, ISNULL(risk_spcd.source_curve_def_id, spcd.source_curve_def_id) risk_id, c.term_start, c.value curve_value, 
						d.value exp_rtn_value, v.value vol_value, c.is_dst
					FROM #tmp_data_curve c 
					LEFT JOIN source_price_curve_def spcd on c.curve_id = spcd.source_curve_def_id
					LEFT JOIN source_price_curve_def risk_spcd ON risk_spcd.source_curve_def_id = spcd.risk_bucket_id 
						AND spcd.risk_bucket_id IS NOT NULL
					LEFT JOIN #tmp_data_drift d ON ISNULL(risk_spcd.source_curve_def_id,spcd.source_curve_def_id)=d.curve_id AND d.term_start=
						CASE risk_spcd.Granularity 
						WHEN 982 THEN c.term_start WHEN 981 THEN c.term_start WHEN 980 THEN convert(VARCHAR(8), c.term_start, 120) + ''01''
						WHEN 991 THEN cast(convert(VARCHAR(5), c.[term_start], 120) + cast(case datepart(q, c.term_start) when 1 then 1 when 2 then 4 when 3 then 7 when 4 then 10 end as VARCHAR)+''-01'' as date)
						WHEN 992 THEN cast(convert(VARCHAR(5),c.[term_start],120)+ cast(case when month(c.term_start) < 7 then 1 else 7 end as VARCHAR)+''-01'' as date)
						WHEN 993 THEN cast(convert(VARCHAR(5),c.[term_start],120)+ ''01-01'' as date) ELSE  c.term_start
						END
					LEFT JOIN #tmp_data_vol v ON ISNULL(risk_spcd.source_curve_def_id,spcd.source_curve_def_id)=v.curve_id 
						AND v.term_start=
						CASE risk_spcd.Granularity 
						WHEN 982 THEN c.term_start WHEN 981 THEN c.term_start WHEN 980 THEN convert(VARCHAR(8),c.term_start,120)+''01''
						WHEN 991 THEN cast(convert(VARCHAR(5),c.[term_start],120)+ cast(case datepart(q, c.term_start) when 1 then 1 when 2 then 4 when 3 then 7 when 4 then 10 end as VARCHAR)+''-01'' as date)
						WHEN 992 THEN cast(convert(VARCHAR(5),c.[term_start],120)+ cast(case when month(c.term_start) < 7 then 1 else 7 end as VARCHAR)+''-01'' as date)
						WHEN 993 THEN cast(convert(VARCHAR(5),c.[term_start],120)+ ''01-01'' as date) ELSE  c.term_start
						END
					) cur
				WHERE 1 = 1 
					AND cur.curve_value IS NOT NULL 
					AND cur.exp_rtn_value IS NOT NULL 
					AND cur.vol_value IS NOT NULL'
	
				exec spa_print @st_stmt
				EXEC(@st_stmt)
			END
			ELSE
			BEGIN
				IF @revaluation = 'y'
					SELECT @date_available = ISNULL(MAX(run_date), @as_of_date) FROM matrix_multiplication_value_whatif WHERE run_date <= @as_of_date AND criteria_id = @criteria_id
				ELSE
					SELECT @date_available = ISNULL(MAX(run_date), @as_of_date) FROM matrix_multiplication_value WHERE run_date <= @as_of_date
		
				SET @st_stmt = '
				INSERT INTO '+ @random_no + ' (curve_id, risk_id, as_of_date, term_start,  rnd_value, curve_value, exp_rtn_value, vol_value, is_dst)
				SELECT cur.curve_id, ISNULL(cur.risk_id, cur.curve_id) risk_id, dt.as_of_date, cur.term_start,  mmv.cor_rnd_value, cur.curve_value, cur.exp_rtn_value, cur.vol_value, 
					cur.is_dst
				FROM matrix_multiplication_value' + CASE WHEN @revaluation = 'y' THEN '_whatif' ELSE '' END + ' mmv
				INNER JOIN #as_of_date_point1 dt ON dt.as_of_date = mmv.as_of_date
				INNER JOIN (
					SELECT c.curve_id, risk_spcd.source_curve_def_id risk_id, c.term_start, c.value curve_value, 
						d.value exp_rtn_value, v.value vol_value, c.is_dst
					FROM #tmp_data_curve c 
					LEFT JOIN source_price_curve_def spcd on c.curve_id = spcd.source_curve_def_id
					LEFT JOIN source_price_curve_def risk_spcd ON risk_spcd.source_curve_def_id = spcd.risk_bucket_id 
						AND spcd.risk_bucket_id IS NOT NULL
					LEFT JOIN #tmp_data_drift d ON ISNULL(risk_spcd.source_curve_def_id,spcd.source_curve_def_id)=d.curve_id AND d.term_start=
						CASE risk_spcd.Granularity 
						WHEN 982 THEN c.term_start WHEN 981 THEN c.term_start WHEN 980 THEN convert(VARCHAR(8), c.term_start, 120) + ''01''
						WHEN 991 THEN cast(convert(VARCHAR(5), c.[term_start], 120) + cast(case datepart(q, c.term_start) when 1 then 1 when 2 then 4 when 3 then 7 when 4 then 10 end as VARCHAR)+''-01'' as date)
						WHEN 992 THEN cast(convert(VARCHAR(5),c.[term_start],120)+ cast(case when month(c.term_start) < 7 then 1 else 7 end as VARCHAR)+''-01'' as date)
						WHEN 993 THEN cast(convert(VARCHAR(5),c.[term_start],120)+ ''01-01'' as date) ELSE  c.term_start
						END
					LEFT JOIN #tmp_data_vol v ON ISNULL(risk_spcd.source_curve_def_id,spcd.source_curve_def_id)=v.curve_id 
						AND v.term_start=
						CASE risk_spcd.Granularity 
						WHEN 982 THEN c.term_start WHEN 981 THEN c.term_start WHEN 980 THEN convert(VARCHAR(8),c.term_start,120)+''01''
						WHEN 991 THEN cast(convert(VARCHAR(5),c.[term_start],120)+ cast(case datepart(q, c.term_start) when 1 then 1 when 2 then 4 when 3 then 7 when 4 then 10 end as VARCHAR)+''-01'' as date)
						WHEN 992 THEN cast(convert(VARCHAR(5),c.[term_start],120)+ cast(case when month(c.term_start) < 7 then 1 else 7 end as VARCHAR)+''-01'' as date)
						WHEN 993 THEN cast(convert(VARCHAR(5),c.[term_start],120)+ ''01-01'' as date) ELSE  c.term_start
						END
					) cur ON mmv.term_start = cur.term_start
					AND mmv.curve_id = ISNULL(cur.risk_id, cur.curve_id)
					AND cur.curve_value IS NOT NULL 
					AND cur.exp_rtn_value IS NOT NULL 
					AND cur.vol_value IS NOT NULL
				WHERE 1 = 1
				AND mmv.run_date = ''' + CAST(@date_available AS VARCHAR) + ''''
				+ CASE WHEN @revaluation = 'y' THEN ' AND mmv.criteria_id = ' + CAST(@criteria_id AS VARCHAR) + '' ELSE '' END
	
				EXEC spa_print @st_stmt
				EXEC(@st_stmt)
			END
			--EXEC('CREATE NONCLUSTERED INDEX indx_rnd_date_curve ON ' + @random_no + ' (as_of_date, curve_id, term_start)')-- WITH (data_compression=page)')
			EXEC('CREATE INDEX [IX_PT_RAND_curve_id_term_start] ON ' + @random_no + ' ([curve_id], [term_start]) INCLUDE ([as_of_date])')
			--updated for multiple delete while performing purge 1/7/2013
			IF @revaluation <> 'y'
			BEGIN
				SET @st_stmt='
					DELETE [dbo].[source_price_curve_simulation] FROM [dbo].[source_price_curve_simulation] spc WITH (NOLOCK)
						 JOIN ' + @random_no + ' dt ON dt.as_of_date = spc.as_of_date 
							AND spc.run_date = ''' + CONVERT(VARCHAR(10), @as_of_date, 120) + '''
							AND spc.source_curve_def_id = dt.curve_id 
							AND dt.term_start = spc.maturity_date 
							AND spc.curve_source_value_id = ' + CAST(@source_curve_id AS VARCHAR)
					
				exec spa_print @st_stmt		 
				EXEC(@st_stmt)
			END

			IF OBJECT_ID('tempdb..#spcs') IS NOT NULL
			DROP TABLE #spcs	

			CREATE TABLE #spcs 
			(
			[run_date] [date] NULL,
			[source_curve_def_id] [int] NOT NULL,
			[as_of_date] [date] NOT NULL,
			[Assessment_curve_type_value_id] [int] NOT NULL,
			[curve_source_value_id] [int] NOT NULL,
			[maturity_date] [datetime] NOT NULL,
			[curve_value] [float] NOT NULL,
			[curve_value_main] [float] NOT NULL,
			[is_dst] [tinyint] NOT NULL)
	
			exec spa_print @random_no
			SET @st_stmt='
				INSERT INTO #spcs--[dbo].[source_price_curve_simulation]
					(run_date,
					[source_curve_def_id]
					,[as_of_date]
					,[Assessment_curve_type_value_id]
					,[curve_source_value_id]
					,[maturity_date]
					,[curve_value_main]
					,[curve_value]
					,is_dst
					)
				select '''+CONVERT(VARCHAR(10),@as_of_date,120)+''' ,curve_id,as_of_date ,77,'+CAST(@source_curve_id AS VARCHAR) +',term_start,curve_value,'
				+ CASE WHEN @data_series=1562 THEN ' 
					curve_value
					+( curve_value 
						*(
							(exp_rtn_value* (CAST('+CAST(@holding_period AS VARCHAR) +' AS FLOAT)/'+CAST(@no_days_yr AS VARCHAR) + '))
							+ (' + CASE WHEN @use_cor_rnd = 0 THEN 'dbo.FNANormSInv(rnd_value)' ELSE 'rnd_value' END + '
							* vol_value *SQRT((CAST('+CAST(@holding_period AS VARCHAR) +' AS FLOAT)/'+CAST(@no_days_yr AS VARCHAR) +'))
							)
						)
					)'
				WHEN @data_series=1563 THEN ' 
					curve_value * exp(
						((exp_rtn_value-((vol_value*vol_value)/2))*(CAST('+CAST(@holding_period AS VARCHAR) +' AS FLOAT)/'+CAST(@no_days_yr AS VARCHAR) + '))
						+ (' + CASE WHEN @use_cor_rnd = 0 THEN 'dbo.FNANormSInv(rnd_value)' ELSE 'rnd_value' END + ' 
						* vol_value *SQRT(CAST('+CAST(@holding_period AS VARCHAR) +' AS FLOAT)/'+CAST(@no_days_yr AS VARCHAR) +'))
					)'
					END +' val, is_dst
			
				FROM 	'+ @random_no 
	
			exec spa_print @st_stmt
			EXEC(@st_stmt)
	
		CREATE INDEX [IX_PT_spcs_run_date_source_curve_def_id_curve_source_value_id_maturity_date_is_dst] ON [#spcs] ([run_date], [source_curve_def_id], [curve_source_value_id], [maturity_date], [is_dst]) INCLUDE ([as_of_date], [Assessment_curve_type_value_id], [curve_value])	
	
			--moved from bottom
			IF @revaluation <> 'y'
			BEGIN
				INSERT INTO [dbo].[source_price_curve_simulation]
						(run_date,
						[source_curve_def_id]
						,[as_of_date]
						,[Assessment_curve_type_value_id]
						,[curve_source_value_id]
						,[maturity_date]
						,[curve_value]
						,[create_user]
						,[create_ts]
						,is_dst
						)
				SELECT 
						run_date,
						[source_curve_def_id]
						,[as_of_date]
						,[Assessment_curve_type_value_id]
						,[curve_source_value_id]
						,[maturity_date]
						,[curve_value]
						,'farrms_admin'
						,GETDATE()
						,is_dst
				FROM #spcs
			END
	
			--Enhancement 
			IF @revaluation = 'y'
			BEGIN
				SET @st_stmt='
					DELETE s 
						FROM source_price_simulation_delta_whatif s WITH (NOLOCK)
						WHERE s.run_date = ''' + CONVERT(VARCHAR(10), @as_of_date, 120) + '''
							AND s.source_curve_def_id = ' + CAST(@risk_ids AS VARCHAR) + '
							AND s.curve_source_value_id = ' + CAST(@source_curve_id AS VARCHAR) + '
							AND s.criteria_id = ' + CAST(@criteria_id AS VARCHAR)

				EXEC spa_print @st_stmt
				EXEC(@st_stmt)
			END
			ELSE
			BEGIN
				SET @st_stmt='
					DELETE s 
					FROM source_price_simulation_delta s WITH (NOLOCK)
					INNER JOIN ' + @random_no + ' dt ON s.as_of_date = dt.as_of_date
						AND s.run_date = ''' + CONVERT(VARCHAR(10), @as_of_date, 120) + '''
						AND s.source_curve_def_id = dt.curve_id
						AND s.maturity_date = dt.term_start
						AND s.curve_source_value_id = ' + CAST(@source_curve_id AS VARCHAR) + '
						and s.is_dst = dt.is_dst'

				exec spa_print @st_stmt
				EXEC(@st_stmt)
			END
			--- Optimization doen by Santosh 
			IF OBJECT_ID('tempdb..#tdc') IS NOT NULL
				DROP TABLE #tdc
			IF OBJECT_ID('tempdb..#tdc1') IS NOT NULL
				DROP TABLE #tdc1

			SELECT DISTINCT curve_id INTO #tdc FROM #tmp_data_curve

			CREATE INDEX IX_PT_test_tdc ON #tdc(curve_id)
	
			SELECT DISTINCT AVG(curve_value) curve_value, source_curve_def_id, run_date, maturity_date
			INTO #tdc1
			FROM #spcs WITH (NOLOCK) 
			WHERE curve_source_value_id = 4505
				AND run_date = @as_of_date
				AND source_curve_def_id = @curve_id
			GROUP BY  source_curve_def_id,run_date,maturity_date

			CREATE INDEX ix_test_tt ON #tdc1 (source_curve_def_id) INCLUDE (run_date,maturity_date)
	
			DECLARE @des_table_name VARCHAR(100)
			SET @des_table_name = CASE WHEN @revaluation = 'y' THEN 'source_price_simulation_delta_whatif' ELSE 'source_price_simulation_delta' END
	
				SET @st_stmt='
				INSERT INTO ' + @des_table_name + '(' + CASE WHEN @revaluation = 'y' THEN 'criteria_id,' ELSE '' END + '
					run_date, source_curve_def_id, as_of_date, Assessment_curve_type_value_id, curve_source_value_id, maturity_date, is_dst,
					curve_value_sim, curve_value_main, curve_value_avg, curve_value_delta, curve_value_avg_delta, create_user, create_ts
					)
				SELECT ' + CASE WHEN @revaluation = 'y' THEN CAST(@criteria_id AS VARCHAR) + ',' ELSE '' END + ' spcs.run_date, spcs.source_curve_def_id, spcs.as_of_date, spcs.Assessment_curve_type_value_id, spcs.curve_source_value_id,
					spcs.maturity_date, spcs.is_dst, spcs.curve_value curve_value_sim, spcs.curve_value_main, av.curve_value curve_value_avg,
					spcs.curve_value-spcs.curve_value_main curve_value_delta, spcs.curve_value-av.curve_value curve_value_avg_delta, ''' + @user_name + ''' create_user,
					GETDATE() create_ts
				FROM source_price_curve spc WITH (NOLOCK)
				INNER JOIN #tdc c ON spc.source_curve_def_id = c.curve_id
				INNER JOIN #tmp_date_info tdi ON tdi.max_as_of_date = spc.as_of_date
				INNER JOIN #spcs spcs WITH (NOLOCK) ON c.curve_id = spcs.source_curve_def_id
					AND tdi.as_of_date = spcs.run_date 
					AND spc.maturity_date = spcs.maturity_date
					AND spcs.is_dst = spc.is_dst 
					AND spc.curve_source_value_id = 4500 
					AND spcs.curve_source_value_id = 4505
					AND spcs.source_curve_def_id = ' + cast(@curve_id as varchar) + '
					AND spcs.run_date = ''' + CONVERT(VARCHAR(10), @as_of_date, 120) + '''  
				INNER JOIN #tdc1 av ON 	av.source_curve_def_id = spcs.source_curve_def_id
					AND av.run_date = spcs.run_date 
						AND av.maturity_date = spcs.maturity_date'
	
				exec spa_print @st_stmt
				EXEC(@st_stmt)
		

			FETCH NEXT FROM tblCursor_risk INTO @curve_id, @volatility ,@drift ,@data_series ,@curve_source,@seed, @volatility_source
		END
		CLOSE tblCursor_risk
		DEALLOCATE tblCursor_risk
	END
	
	--validation for curve_ids whose simulation model is null
	IF (EXISTS(SELECT item FROM dbo.SplitCommaSeperatedValues(@risk_ids) scsv
				LEFT JOIN #tmp_risk1 tr ON tr.curve_id = scsv.item
				WHERE tr.curve_id IS NULL))
	BEGIN
		INSERT  INTO fas_eff_ass_test_run_log	( process_id, code, module, source, type, description, nextsteps)
		SELECT @process_id, 'Error', @module, @source, 'simulation_model', 'Simulation Model not found for Curve ID:'
				+ spcd.curve_name , 'Please check data.'
		FROM (SELECT item FROM dbo.SplitCommaSeperatedValues(@risk_ids) scsv
				LEFT JOIN #tmp_risk1 tr ON tr.curve_id = scsv.item
				WHERE tr.curve_id IS NULL) scsv
		INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = scsv.item
	
		--RAISERROR ( 'CatchError', 16, 1 )
		SET @is_raise_error = 1
	   
	END
	IF @is_raise_error = 1 OR EXISTS(SELECT TOP 1 1 FROM fas_eff_ass_test_run_log f WHERE f.process_id = @process_id)
	BEGIN
		RAISERROR ( 'CatchError', 16, 1 )
	END
	ELSE
	BEGIN
		EXEC spa_print 'finish Price Simulation '
		SET @desc='Price Simulation process is completed for ' + dbo.FNAUserDateFormat(@as_of_date, @user_name) + '.'
		SET @errorcode='s'
		--SELECT @url = './dev/spa_html.php?__user_name__=' + @user_name + 
		--			'&spa=exec spa_get_VaR_report ''v'',null,null,''' + CAST(YEAR(@as_of_date) AS VARCHAR) + '-' + cast(month(@as_of_date) AS VARCHAR) + '-' + CAST(day(@as_of_date) AS VARCHAR) +''',' + cast(@var_criteria_id as varchar)

		EXEC spa_print @errorcode
		EXEC spa_print @process_id
	END


-------------------End error Trapping--------------------------------------------------------------------------
END TRY

BEGIN CATCH
	EXEC spa_print 'Catch Error'
	--if @@TRANCOUNT>0
	--	rollback
	EXEC spa_print @process_id
	SET @errorcode='e'
	--EXEC spa_print  ERROR_LINE()
	IF ERROR_MESSAGE()='CatchError'
	BEGIN
		IF EXISTS(SELECT TOP 1 1 FROM fas_eff_ass_test_run_log f WHERE f.process_id = @process_id AND code = 'Error' AND module IN ('Cholesky Decomposition','Matrix Multiplication'))
		AND NOT EXISTS(SELECT TOP 1 1 FROM fas_eff_ass_test_run_log f WHERE f.process_id = @process_id AND code = 'Error' AND module IN ('Monte.Carlo.Simulation'))
			SET @desc='Price Simulation Calculation process is completed for ' + dbo.FNAUserDateFormat(@as_of_date, @user_name) + ' with warnings.'
		ELSE
			SET @desc='Price Simulation Calculation process is completed for ' + dbo.FNAUserDateFormat(@as_of_date, @user_name) + ' (ERRORS found).'
				
		EXEC spa_print @desc
		--SELECT * FROM fas_eff_ass_test_run_log WHERE process_id=@process_id
	END
	ELSE
	BEGIN
		SET @desc='Price Simulation process critical error found ( Errr Description:'+  ERROR_MESSAGE() + '; Line no: ' + CAST(ERROR_LINE() AS VARCHAR) + ').'
		EXEC spa_print @desc
	END

	SELECT @url = './dev/spa_html.php?__user_name__=' + @user_name + 
				'&spa=exec spa_fas_eff_ass_test_run_log ''' + @process_id + ''',''y'''

END CATCH

SET @url_desc = '' 

IF @errorcode ='e'
BEGIN
	SELECT @desc = '<a target="_blank" href="' + @url + '">' + @desc + '.</a>'

	SET @url_desc='<a href="../../dev/spa_html.php?spa=spa_fas_eff_ass_test_run_log '''+@process_id+'''">Click here...</a>'
		SELECT 'Error' ErrorCode, 'Price Simulation' module, 
			'spa_monte_carlo_simulation_core' area, 'DB Error' status, 
		'Price Simulation process completed with error, Please view this report. '+@url_desc message, '' recommendation
END
ELSE
BEGIN
--	select @desc = '<a target="_blank" href="' + @url + '">' + @desc + '.</a>'
	
	EXEC spa_ErrorHandler 0, 'VaR_Simulation Calculation', 
				'Price_Simulation', 'Success', 
				@desc, ''
END


--SELECT @url = './dev/spa_html.php?__user_name__=' + @user_name + 
--			'&spa=exec spa_fas_eff_ass_test_run_log ''' + @MTMProcessTableName + ''',''m'''

SELECT @desc1 = '<a target="_blank" href="' + @url + '">View MTM</a>'

SELECT @url = './dev/spa_html.php?__user_name__=' + @user_name + 
			'&spa=exec spa_fas_eff_ass_test_run_log ''' + @random_no + ''',''r'''

SELECT @desc1 =@desc1+ ';  <a target="_blank" href="' + @url + '">Curve Price.</a>'
SELECT @desc1=''
	
UPDATE tbl_sims_status SET sims_status = 'C', update_ts = GETDATE() WHERE curve_id = @cid AND process_id = @process_id

IF (NOT EXISTS(SELECT 1 FROM tbl_sims_status WHERE process_id = @process_id AND sims_status = 'R')	)

BEGIN 	
	EXEC spa_message_board 'i', 
		@user_name,
		NULL, 
		'Price_Simulation',
		@desc, 
		@desc1, 
		'', 
		@errorcode, 
		'Price_Simulation',
		NULL,
		@process_id
END 		
GO
