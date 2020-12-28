IF OBJECT_ID(N'[dbo].[spa_eod_verify_missing_curve]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_eod_verify_missing_curve]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: rajiv@pioneersolutionsglobal.com
-- Create date: 2014-08-15
-- Description: check missing eod curve and restored it from previously available data
 -- Modified Date: 2019-01-22
-- Params:
-- @flag VARCHAR(1) - Operation flag
--				 'CHECK' for getting missing data
--				 'COPY' for copying data from previously 
--EXEC [spa_eod_verify_missing_curve] 'COPY',  '2014-07-29', 'aasa2323sasa'
-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_eod_verify_missing_curve]
    @flag VARCHAR(50),
    @as_of_date DATETIME,
    @process_id VARCHAR(100) = NULL
AS

/*
DECLARE @contextinfo VARBINARY(128)= CONVERT(VARBINARY(128), 'DEBUG_MODE_ON');
SET CONTEXT_INFO @contextinfo;

DECLARE @flag           CHAR(10) = 'COPY',
        @as_of_date     DATETIME = '2019-03-12',
        @process_id     VARCHAR(300) = dbo.FNAGETNEWID()
--*/
SET NOCOUNT ON 
IF OBJECT_ID('tempdb..#temp_all_curves') IS NOT NULL
	DROP TABLE #temp_all_curves
	
IF OBJECT_ID('tempdb..#temp_all_vol_cor_curves') IS NOT NULL
	DROP TABLE #temp_all_vol_cor_curves
	
IF OBJECT_ID('tempdb..#temp_validate_curves') IS NOT NULL
	DROP TABLE #temp_validate_curves

IF OBJECT_ID('tempdb..#temp_vol_cor_validate_curves') IS NOT NULL
	DROP TABLE #temp_vol_cor_validate_curves

IF OBJECT_ID('tempdb..#temp_copy_curves') IS NOT NULL
	DROP TABLE #temp_copy_curves

IF OBJECT_ID('tempdb..#temp_vol_cor_copy_curves') IS NOT NULL
	DROP TABLE #temp_vol_cor_copy_curves	

CREATE TABLE #temp_all_curves (
	[curve_id] INT,
	[holiday_calendar_id] INT,
	[holiday_curve_id] INT,
	[expiration_calendar_id] INT,
	[expiration_curve_id] INT,
	[expected_start_maturity] INT,
	[expected_end_maturity] INT,
	[forward_settle_flag] CHAR(1),
	[check_dst] CHAR(1),
	[granularity] INT,
	maturity_start_date DATETIME NULL,
	maturity_end_date DATETIME NULL,
	[Halt_process] CHAR(1)
)

CREATE TABLE #temp_all_vol_cor_curves (
	[curve_id_from]               INT,
	[curve_id_to]                 INT,
	[holiday_calendar_id]         INT,
	[expected_start_maturity]     INT,
	[expected_end_maturity]       INT,
	[vol_cor_flag]                CHAR(1),
	maturity_start_date           DATETIME NULL,
	maturity_end_date             DATETIME NULL,
	[Halt_process]					CHAR(1),
	[Copy Missing]				CHAR(1)
)


-- Generic Mapping EOD Price Copy 
INSERT INTO #temp_all_curves ([curve_id], [holiday_curve_id],[expiration_curve_id], [holiday_calendar_id],[expiration_calendar_id], [expected_start_maturity], [expected_end_maturity], [forward_settle_flag], [check_dst], [Halt_process], [granularity], maturity_start_date, maturity_end_date)	
SELECT gmv.clm1_value [curve_id],
       gmv.clm2_value [holiday_curve_id],
       gmv.clm3_value [expiration_curve_id],
       gmv.clm4_value [holiday_calendar_id],
       gmv.clm5_value [expiration_calendar_id],
       gmv.clm6_value [expected_start_maturity],
       gmv.clm7_value [expected_end_maturity],
       gmv.clm8_value [forward_settle_flag],
       gmv.clm9_value [check_dst],
	   gmv.clm10_value [Halt_process],
       spcd.Granularity [granularity],
       CASE WHEN spcd.Granularity IN (980, 10000289) THEN dbo.FNAContractMonthFormat(DATEADD(MONTH, CAST(ISNULL(NULLIF(gmv.clm6_value, ''), 0) AS INT), @as_of_date)) + '-01'
			WHEN spcd.Granularity = 982 THEN DATEADD(DAY, 1, DATEADD(MONTH, CAST(ISNULL(NULLIF(gmv.clm6_value, ''), 0) AS INT), @as_of_date)) 
			--DATEADD(HOUR, CAST(ISNULL(NULLIF(gmv.clm6_value, ''), 0) AS INT), @as_of_date)
			WHEN spcd.Granularity IN (981, 10000290) THEN DATEADD(DAY, CAST(ISNULL(NULLIF(gmv.clm6_value, ''), 0) AS INT), @as_of_date)
		END,
		CASE WHEN spcd.Granularity IN (980, 10000289) THEN dbo.FNAContractMonthFormat(DATEADD(MONTH, CAST(ISNULL(NULLIF(gmv.clm7_value, ''), 0) AS INT), @as_of_date)) + '-01'
			WHEN spcd.Granularity = 982 THEN DATEADD(HOUR, 23, DATEADD(MONTH, CAST(ISNULL(NULLIF(gmv.clm7_value, ''), 0) AS INT), @as_of_date))
			WHEN spcd.Granularity IN (981, 10000290) THEN DATEADD(DAY, CAST(ISNULL(NULLIF(gmv.clm7_value, ''), 0) AS INT), @as_of_date)
		END
FROM generic_mapping_values gmv
INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmv.mapping_table_id
INNER JOIN source_price_curve_def spcd ON CAST(spcd.source_curve_def_id AS VARCHAR(30)) = gmv.clm1_value
WHERE gmh.mapping_name = 'EOD Price Copy' 

INSERT INTO #temp_all_vol_cor_curves ([vol_cor_flag], [curve_id_from], [curve_id_to], [holiday_calendar_id], [expected_start_maturity], [expected_end_maturity], maturity_start_date, maturity_end_date,[Halt_process],[Copy Missing])
SELECT gmv.clm1_value [vol_cor_flag],
	   gmv.clm2_value [curve_id],
       gmv.clm3_value [curve_id_to],
       gmv.clm4_value [holiday_calendar_id],
       gmv.clm5_value [expected_start_maturity],
       gmv.clm6_value [expected_end_maturity],
       dbo.FNAContractMonthFormat(DATEADD(MONTH, CAST(ISNULL(NULLIF(gmv.clm5_value, ''), 0) AS INT), @as_of_date)) + '-01',
	   dbo.FNAContractMonthFormat(DATEADD(MONTH, CAST(ISNULL(NULLIF(gmv.clm6_value, ''), 0) AS INT), @as_of_date)) + '-01',
	   gmv.clm7_value [halt_process],
	   gmv.clm8_value [Copy Missing]
FROM generic_mapping_values gmv
INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmv.mapping_table_id
INNER JOIN source_price_curve_def spcd ON CAST(spcd.source_curve_def_id AS VARCHAR(30)) = gmv.clm2_value
LEFT JOIN source_price_curve_def spcd2 ON CAST(spcd2.source_curve_def_id AS VARCHAR(30)) = gmv.clm3_value
WHERE  gmh.mapping_name = 'EOD Vol/Cor Copy'  --AND gmv.generic_mapping_values_id = 1314



--SELECT gmv.*, gmh.* FROM generic_mapping_values gmv
--INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmv.mapping_table_id
--WHERE gmh.mapping_name = 'EOD Price Copy' 

--SELECT * FROM #temp_copy_curves
 
-- Copy Curve
EXEC spa_print 'collect'
SELECT * 
INTO #temp_copy_curves
FROM #temp_all_curves
WHERE holiday_curve_id IS NOT NULL OR expiration_curve_id IS NOT NULL

-- Validate Curve
SELECT tac.* 
INTO #temp_validate_curves
FROM #temp_all_curves tac
INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = tac.curve_id
WHERE spcd.formula_id IS NULL

DECLARE @curve_id INT
DECLARE @desc VARCHAR(8000)

IF OBJECT_ID('tempdb..#temp_maturity_date') IS NOT NULL 
	DROP TABLE #temp_maturity_date
	
IF OBJECT_ID('tempdb..#seq') IS NOT NULL 
	DROP TABLE #seq

IF OBJECT_ID('tempdb..#temp_missing_maturity_date') IS NOT NULL 
	DROP TABLE #temp_missing_maturity_date
	
IF OBJECT_ID('tempdb..#temp_avail_maturity_date') IS NOT NULL 
	DROP TABLE #temp_avail_maturity_date

IF OBJECT_ID('tempdb..#temp_erroneous_curve_holiday') IS NOT NULL 
	DROP TABLE #temp_erroneous_curve_holiday	

IF OBJECT_ID('tempdb..#temp_erroneous_curve_treasury') IS NOT NULL 
	DROP TABLE #temp_erroneous_curve_treasury
	
IF OBJECT_ID('tempdb..#temp_erroneous_curve_expiration') IS NOT NULL 
	DROP TABLE #temp_erroneous_curve_expiration

IF OBJECT_ID('tempdb..#temp_copy_curve_holiday') IS NOT NULL 
	DROP TABLE #temp_copy_curve_holiday

IF OBJECT_ID('tempdb..#temp_copy_curve_expiration') IS NOT NULL 
	DROP TABLE #temp_copy_curve_expiration
		
CREATE TABLE #temp_maturity_date (
	source_curve_def_id     INT,
	maturity_date           DATETIME,
	maturity_date_min       DATETIME,
	maturity_date_max       DATETIME,
	is_dst                  INT,
	copy_from				INT
)

CREATE TABLE #temp_missing_maturity_date (
	source_curve_def_id     INT,
	as_of_date              DATETIME,
	maturity_date           DATETIME,
	is_dst                  INT
)

CREATE TABLE #temp_avail_maturity_date (
	source_curve_def_id     INT,
	as_of_date              DATETIME,
	maturity_date           DATETIME,
	is_dst                  INT
)

CREATE TABLE #temp_erroneous_curve_holiday (
	source_curve_def_id                INT,
	as_of_date                         DATETIME,
	from_maturity_date                 DATETIME,
	to_maturity_date				   DATETIME
)

CREATE TABLE #temp_erroneous_curve_expiration (
	source_curve_def_id                INT,
	as_of_date                         DATETIME,
	from_maturity_date                 DATETIME,
	to_maturity_date				   DATETIME
)


CREATE TABLE #temp_erroneous_curve_treasury (
	source_curve_def_id                INT,
	as_of_date                         DATETIME,
	from_maturity_date                 DATETIME,
	to_maturity_date				   DATETIME
)
CREATE TABLE #temp_copy_curve_holiday (
	source_curve_def_id     INT,
	as_of_date              DATETIME,
	maturity_date           DATETIME,
	copy_from_curve         INT
)

CREATE TABLE #temp_copy_curve_expiration (
	source_curve_def_id     INT,
	as_of_date              DATETIME,
	maturity_date           DATETIME,
	copy_from_curve         INT
)

SELECT TOP 55000 IDENTITY(INT, 1, 1)  AS n
INTO #seq
FROM  seq s1
CROSS JOIN seq s2

IF CURSOR_STATUS('global','eod_price_copy_cursor') > = -1
BEGIN
	DEALLOCATE eod_price_copy_cursor
END

DECLARE eod_price_copy_cursor CURSOR FOR
SELECT tac.curve_id
FROM #temp_all_curves tac
INNER JOIN source_price_curve_def spcd ON tac.curve_id = spcd.source_curve_def_id
WHERE spcd.curve_id <> 'Bloomberg US Treasury Rates'
		
OPEN eod_price_copy_cursor
FETCH NEXT FROM eod_price_copy_cursor
INTO @curve_id
WHILE @@FETCH_STATUS = 0
BEGIN
	
	EXEC spa_print  '@curve_id = ' , @curve_id

	DELETE FROM #temp_maturity_date 
	DELETE FROM #temp_avail_maturity_date
	DELETE FROM #temp_missing_maturity_date
	
	DECLARE @maturity_date_start DATETIME
	DECLARE @maturity_date_end DATETIME
	DECLARE @granularity VARCHAR(10)
	DECLARE @forward_settle CHAR(1)
	DECLARE @check_dst CHAR(1)
	
	SELECT @maturity_date_start = maturity_start_date,
	       @maturity_date_end = maturity_end_date,
	       @granularity = CASE granularity WHEN 982 THEN 'HOUR' WHEN 981 THEN 'DAY' WHEN 980 THEN 'MONTH'  WHEN 10000289 THEN 'Month' WHEN 10000290 THEN 'DAY' END,
	       @forward_settle = forward_settle_flag,
	       @check_dst = ISNULL(check_dst, 'n')
	FROM   #temp_all_curves
	WHERE curve_id = @curve_id
	
	DECLARE @sql VARCHAR(5000)
	
	SET @sql = 'INSERT INTO #temp_maturity_date (source_curve_def_id, maturity_date, is_dst)
			SELECT ' + CAST(@curve_id AS VARCHAR(10)) + ', DATEADD(' + @granularity + ', n - 1, ''' + CONVERT(VARCHAR(200), @maturity_date_start, 121) + ''') maturity_date, 0
			FROM #seq
			WHERE DATEADD(' + @granularity + ', n - 1, ''' + CONVERT(VARCHAR(200), @maturity_date_start, 121) + ''') <= ''' + CONVERT(VARCHAR(200), @maturity_date_end, 121) + ''''
	EXEC spa_print @sql
	EXEC(@sql)
		
	IF @granularity = 'HOUR' AND @check_dst = 'y'
	BEGIN
		--add is_dst data with 'i'
		UPDATE tmd
		SET is_dst = 1
		FROM #temp_maturity_date tmd
		INNER JOIN mv90_DST md ON tmd.maturity_date = DATEADD(hh, [hour] - 1, md.date) 
		WHERE  md.insert_delete = 'i'
		
		INSERT INTO #temp_maturity_date(source_curve_def_id, maturity_date, is_dst)
		SELECT source_curve_def_id, maturity_date, 0 is_dst
		FROM #temp_maturity_date tmd
		INNER JOIN mv90_DST md ON tmd.maturity_date = DATEADD(hh, [hour] - 1, md.date) 
		WHERE  md.insert_delete = 'i'

		--delete is_dst data with d
		DELETE tmd
		FROM #temp_maturity_date tmd
		INNER JOIN mv90_DST md ON tmd.maturity_date = DATEADD(hh, [hour] - 1, md.date) 
		WHERE  md.insert_delete = 'd'
	END

	SET @sql = 'INSERT INTO #temp_avail_maturity_date (source_curve_def_id, as_of_date, maturity_date, is_dst)
				SELECT spc.source_curve_def_id,
					   spc.as_of_date,
					   spc.maturity_date,
					   spc.is_dst		   
				FROM source_price_curve_def spcd 
				INNER JOIN source_price_curve spc ON spcd.source_curve_def_id = spc.source_curve_def_id ' + 
				CASE WHEN @flag = 'CHECK' THEN  '
				OUTER APPLY(
					SELECT MAX(as_of_date) min_as_of_date 
					FROM source_price_curve spc1 
					WHERE spc1.source_curve_def_id = spcd.source_curve_def_id 
					AND spcd.effective_date = ''y'' 
					AND spc1.maturity_date = spc.maturity_date	
					AND spc1.as_of_date < ''' + CONVERT(VARCHAR(10), @as_of_date, 120) + '''
				) spc_min_as_of_date
				OUTER APPLY(
					SELECT as_of_date original_as_of_date 
					FROM source_price_curve spc1 
					WHERE spc1.source_curve_def_id = spcd.source_curve_def_id 
					AND spc1.maturity_date = spc.maturity_date	
					AND spc1.as_of_date = ''' + CONVERT(VARCHAR(10), @as_of_date, 120) + '''	
				) spc_actual_as_of_date '
				ELSE '' END + '
				WHERE spc.maturity_date BETWEEN ''' + CONVERT(VARCHAR(200), @maturity_date_start, 121) + ''' AND ''' + CONVERT(VARCHAR(200), @maturity_date_end, 121) + ''' 
				AND spc.source_curve_def_id = ' + CAST(@curve_id AS VARCHAR(20)) + '
				AND spc.curve_source_value_id = 4500 '

	--For @forward_settle = 's' AND @granularity = 'MONTH' and @flag ='CHECK' 
	--taking max as of date if passed as of date is not present on table is not required
	IF @forward_settle = 's' AND @granularity = 'MONTH'
	BEGIN
		SET @sql = @sql + ' AND CONVERT(VARCHAR(10), as_of_date, 120) <= ''' + CONVERT(VARCHAR(10), @as_of_date, 120) + ''''
	END
	ELSE 
	BEGIN
		SET @sql = @sql + ' AND CONVERT(VARCHAR(10), as_of_date, 120) = ' +
		CASE WHEN @flag = 'CHECK' THEN ' COALESCE(spc_actual_as_of_date.original_as_of_date, spc_min_as_of_date.min_as_of_date,''' + CONVERT(VARCHAR(10), @as_of_date, 120) + ''')'
		ELSE '''' + CONVERT(VARCHAR(10), @as_of_date, 120) + '''' END
	END
	EXEC spa_print @sql	
	EXEC (@sql)

	INSERT INTO #temp_missing_maturity_date (source_curve_def_id, as_of_date, maturity_date, is_dst)
	SELECT @curve_id, @as_of_date, tmd.maturity_date, tmd.is_dst
	FROM #temp_maturity_date tmd
	LEFT JOIN #temp_avail_maturity_date tamd ON  tamd.maturity_date = tmd.maturity_date AND tamd.is_dst = tmd.is_dst
	WHERE  tamd.maturity_date IS NULL

	IF @flag = 'CHECK'
	BEGIN
		INSERT INTO #temp_erroneous_curve_holiday (source_curve_def_id, as_of_date, from_maturity_date, to_maturity_date)
		SELECT spcd.source_curve_def_id, MAX(tmmd.as_of_date) as_of_date, MIN(tmmd.maturity_date) from_date, MAX(tmmd.maturity_date) to_date
		FROM #temp_missing_maturity_date tmmd
		INNER JOIN #temp_validate_curves tvc ON tmmd.source_curve_def_id = tvc.curve_id
		INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = tvc.curve_id
		LEFT JOIN holiday_group hg ON hg.hol_group_value_id = tvc.holiday_calendar_id AND tmmd.as_of_date = hg.hol_date
		WHERE hg.hol_group_ID IS NULL
		GROUP BY spcd.source_curve_def_id

		INSERT INTO #temp_erroneous_curve_expiration (source_curve_def_id, as_of_date, from_maturity_date, to_maturity_date)
		SELECT spcd.source_curve_def_id, MAX(tmmd.as_of_date) as_of_date, MIN(tmmd.maturity_date) from_date, MAX(tmmd.maturity_date) to_date
		FROM #temp_missing_maturity_date tmmd
		INNER JOIN #temp_validate_curves tvc ON tmmd.source_curve_def_id = tvc.curve_id
		INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = tvc.curve_id
		LEFT JOIN holiday_group hg ON hg.hol_group_value_id = tvc.expiration_calendar_id AND tmmd.maturity_date = hg.hol_date AND tmmd.as_of_date > hg.exp_date
		WHERE hg.hol_group_ID IS NULL 
		GROUP BY spcd.source_curve_def_id

		SELECT @desc = 'Price verification completed for run date ' + dbo.FNADateFormat(@as_of_date) + '.'			
				
	END	
	
	IF @flag = 'COPY'
	BEGIN

		INSERT INTO #temp_copy_curve_holiday (source_curve_def_id, as_of_date, maturity_date, copy_from_curve)
		SELECT spcd.source_curve_def_id, tamd.as_of_date, tmmd.maturity_date, tcc.holiday_curve_id
		FROM #temp_missing_maturity_date tmmd
		INNER JOIN #temp_copy_curves tcc ON tmmd.source_curve_def_id = tcc.curve_id
		INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = tcc.curve_id
		INNER JOIN holiday_group hg ON hg.hol_group_value_id = tcc.holiday_calendar_id AND tmmd.as_of_date = hg.hol_date
		OUTER APPLY (SELECT MAX(as_of_date) as_of_date
		             FROM   source_price_curve cp_spc
		             WHERE  tmmd.maturity_date = cp_spc.maturity_date
		                    AND cp_spc.source_curve_def_id = tcc.holiday_curve_id
		                    AND cp_spc.curve_source_value_id = 4500
		                    AND cp_spc.as_of_date < @as_of_date
		) tamd
		
		--select * from #temp_missing_maturity_date
		INSERT INTO #temp_copy_curve_expiration (source_curve_def_id, as_of_date, maturity_date, copy_from_curve)
		SELECT spcd.source_curve_def_id, tamd.as_of_date, tmmd.maturity_date, tcc.expiration_curve_id
		FROM #temp_missing_maturity_date tmmd
		INNER JOIN #temp_copy_curves tcc ON tmmd.source_curve_def_id = tcc.curve_id
		INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = tcc.curve_id
		INNER JOIN holiday_group hg ON hg.hol_group_value_id = tcc.expiration_calendar_id AND tmmd.maturity_date = hg.hol_date AND tmmd.as_of_date > hg.exp_date
		OUTER APPLY (SELECT MAX(as_of_date) as_of_date
		             FROM   source_price_curve cp_spc
		             WHERE  tmmd.maturity_date = cp_spc.maturity_date
		                    AND cp_spc.source_curve_def_id = tcc.expiration_curve_id
		                    AND cp_spc.as_of_date < @as_of_date
		                    AND cp_spc.curve_source_value_id = 4500
		) tamd
		
		EXEC spa_print  'COPY hol'
		
		INSERT INTO source_price_curve (
			source_curve_def_id,
			as_of_date,
			Assessment_curve_type_value_id,
			curve_source_value_id,
			maturity_date,
			curve_value,
			bid_value,
			ask_value,
			is_dst,
			create_user, 
			create_ts
			)
		SELECT tcch.source_curve_def_id,
				@as_of_date,
				spc.Assessment_curve_type_value_id,
				curve_source_value_id,
				tcch.maturity_date,
				spc.curve_value,
				spc.bid_value,
				spc.ask_value,
				spc.is_dst,
				dbo.FNADBUser(),
				GETDATE()
		FROM #temp_copy_curve_holiday tcch
		INNER JOIN source_price_curve spc 
			ON spc.source_curve_def_id = tcch.copy_from_curve
			AND spc.as_of_date = tcch.as_of_date
			AND spc.maturity_date = tcch.maturity_date
		LEFT JOIN #temp_copy_curve_expiration tcce
			ON tcch.source_curve_def_id = tcce.source_curve_def_id
			AND tcce.as_of_date = tcch.as_of_date
			AND tcce.maturity_date = tcch.maturity_date 
		WHERE tcch.source_curve_def_id = @curve_id AND tcce.source_curve_def_id IS NULL
		
		EXEC spa_print  'COPY exp'
		
		INSERT INTO source_price_curve (
		    source_curve_def_id,
		    as_of_date,
		    Assessment_curve_type_value_id,
		    curve_source_value_id,
		    maturity_date,
		    curve_value,
		    bid_value,
		    ask_value,
		    is_dst,
		    create_user,
		    create_ts
		  )
		SELECT tcce.source_curve_def_id,
		       @as_of_date,
		       spc.Assessment_curve_type_value_id,
		       curve_source_value_id,
		       tcce.maturity_date,
		       spc.curve_value,
		       spc.bid_value,
		       spc.ask_value,
		       spc.is_dst,
		       dbo.FNADBUser(),
		       GETDATE()
		FROM #temp_copy_curve_expiration tcce
		INNER JOIN source_price_curve spc 
			ON spc.source_curve_def_id = tcce.copy_from_curve
			AND spc.as_of_date = tcce.as_of_date
			AND spc.maturity_date = tcce.maturity_date
		WHERE tcce.source_curve_def_id = @curve_id

		/* Copy value from existing data if not present*/
		INSERT INTO source_price_curve (
		    source_curve_def_id,
		    as_of_date,
		    Assessment_curve_type_value_id,
		    curve_source_value_id,
		    maturity_date,
		    curve_value,
		    bid_value,
		    ask_value,
		    is_dst
		  )
		SELECT tmmd.source_curve_def_id
		       ,tmmd.as_of_date
		       ,tbl.Assessment_curve_type_value_id
		       ,tbl.curve_source_value_id
		       ,tmmd.maturity_date
		       ,tbl.curve_value
		       ,tbl.bid_value
		       ,tbl.ask_value
		       ,tbl.is_dst
		FROM #temp_missing_maturity_date tmmd
		CROSS APPLY (
			SELECT TOP 1 as_of_date, curve_source_value_id, curve_value ,bid_value ,ask_value ,tmmd.is_dst, Assessment_curve_type_value_id
			FROM source_price_curve
			WHERE maturity_date = tmmd.maturity_date
			AND source_curve_def_id = tmmd.source_curve_def_id
			AND as_of_date < tmmd.as_of_date
			ORDER BY as_of_date DESC
		) tbl
		LEFT JOIN source_price_curve spc
			ON spc.source_curve_def_id = tmmd.source_curve_def_id
			AND spc.as_of_date = tmmd.as_of_date
			AND spc.maturity_date = tmmd.maturity_date
		WHERE spc.source_curve_def_id IS NULL
	END	
	
	FETCH NEXT FROM eod_price_copy_cursor INTO @curve_id
END
CLOSE eod_price_copy_cursor
DEALLOCATE eod_price_copy_cursor

DECLARE @curve_id_from INT
DECLARE @curve_id_to INT

IF OBJECT_ID('tempdb..#temp_vol_cor_maturity_date') IS NOT NULL 
	DROP TABLE #temp_vol_cor_maturity_date

IF OBJECT_ID('tempdb..#temp_avail_vol_cor_maturity_date') IS NOT NULL 
	DROP TABLE #temp_avail_vol_cor_maturity_date
	
IF OBJECT_ID('tempdb..#temp_missing_vol_cor_maturity_date') IS NOT NULL 
	DROP TABLE #temp_missing_vol_cor_maturity_date

IF OBJECT_ID('tempdb..#temp_erroneous_vol_cor_curve_holiday') IS NOT NULL 
	DROP TABLE #temp_erroneous_vol_cor_curve_holiday	

IF OBJECT_ID('tempdb..#temp_copy_vol_cur_holiday') IS NOT NULL 
	DROP TABLE #temp_copy_vol_cur_holiday
	
CREATE TABLE #temp_erroneous_vol_cor_curve_holiday (
	curve_id_from            INT,
	curve_id_to              INT,
	as_of_date               DATETIME,
	from_maturity_date       DATETIME,
	to_maturity_date		 DATETIME,
	vol_cor_flag			 CHAR(1)
) 

CREATE TABLE #temp_copy_vol_cur_holiday (
	curve_id_from           INT,
	curve_id_to             INT,
	as_of_date              DATETIME,
	maturity_date           DATETIME,
	copy_from_curve         INT,
	vol_cor_flag			CHAR(1)
)
	
CREATE TABLE #temp_vol_cor_maturity_date (
	curve_id_from     INT,
	curve_id_to       INT,
	maturity_date     DATETIME
)

CREATE TABLE #temp_avail_vol_cor_maturity_date (
	curve_id_from     INT,
	curve_id_to       INT,
	as_of_date		  DATETIME,
	maturity_date     DATETIME
)

CREATE TABLE #temp_missing_vol_cor_maturity_date (
	curve_id_from     INT,
	curve_id_to       INT,
	as_of_date		  DATETIME,
	maturity_date     DATETIME
)

DECLARE eod_vol_cor_copy_cursor CURSOR FOR
SELECT curve_id_from, curve_id_to
FROM #temp_all_vol_cor_curves
		
OPEN eod_vol_cor_copy_cursor
FETCH NEXT FROM eod_vol_cor_copy_cursor
INTO @curve_id_from, @curve_id_to
WHILE @@FETCH_STATUS = 0
BEGIN
	DELETE FROM #temp_vol_cor_maturity_date
	DELETE FROM #temp_avail_vol_cor_maturity_date
	DELETE FROM #temp_missing_vol_cor_maturity_date
	DELETE FROM #temp_copy_vol_cur_holiday
	DECLARE @vol_cor CHAR(1)
	SELECT @maturity_date_start = maturity_start_date,
	       @maturity_date_end = maturity_end_date,
	       @vol_cor = vol_cor_flag
	FROM #temp_all_vol_cor_curves
	WHERE curve_id_from = @curve_id_from AND ISNULL(curve_id_to, '') = ISNULL(@curve_id_to, '')	
	
	--SELECT * FROM #temp_all_vol_cor_curves WHERE curve_id_from = @curve_id_from AND ISNULL(curve_id_to, '') = ISNULL(@curve_id_to, '')	

	SET @sql = 'INSERT INTO #temp_vol_cor_maturity_date (curve_id_from, curve_id_to, maturity_date)
				SELECT ' + CAST(@curve_id_from AS VARCHAR(10)) + ', ' + ISNULL(CAST(@curve_id_to AS VARCHAR(10)), 'NULL') + ',  DATEADD(MONTH, n - 1, ''' + CONVERT(VARCHAR(200), @maturity_date_start, 121) + ''') maturity_date
				FROM #seq
				WHERE DATEADD(MONTH, n - 1, ''' + CONVERT(VARCHAR(200), @maturity_date_start, 121) + ''') <= ''' + CONVERT(VARCHAR(200), @maturity_date_end, 121) + ''''
	
	EXEC spa_print @sql
	EXEC(@sql)
	
	SET @sql = 'INSERT INTO #temp_avail_vol_cor_maturity_date (curve_id_from, curve_id_to, as_of_date, maturity_date)
				SELECT ' + CAST(@curve_id_from AS VARCHAR(10)) + ', 
					   ' + ISNULL(CAST(@curve_id_to AS VARCHAR(10)), 'NULL') + ',
					   spc.as_of_date,
					   '
	
	IF @vol_cor = 'v'
	BEGIN
		SET @sql = @sql + ' spc.term FROM curve_volatility spc 
				WHERE spc.curve_id = ' + CAST(@curve_id_from AS VARCHAR(20)) + ' 
				AND spc.term BETWEEN ''' + CONVERT(VARCHAR(200), @maturity_date_start, 121) + ''' AND ''' + CONVERT(VARCHAR(200), @maturity_date_end, 121) + ''' 
				AND CONVERT(VARCHAR(10), as_of_date, 120) = ''' + CONVERT(VARCHAR(10), @as_of_date, 120) + '''
				AND spc.curve_source_value_id = 4500
				'
	END
	
	IF @vol_cor = 'c'
	BEGIN
		SET @sql = @sql + ' spc.term1 FROM curve_correlation spc 
				WHERE spc.curve_id_from = ' + CAST(@curve_id_from AS VARCHAR(20)) + ' AND spc.curve_id_to = ' + CAST(@curve_id_to AS VARCHAR(20)) + '
				AND spc.term1 BETWEEN ''' + CONVERT(VARCHAR(200), @maturity_date_start, 121) + ''' AND ''' + CONVERT(VARCHAR(200), @maturity_date_end, 121) + ''' 
				AND CONVERT(VARCHAR(10), as_of_date, 120) = ''' + CONVERT(VARCHAR(10), @as_of_date, 120) + '''
				AND spc.curve_source_value_id = 4500
				'
	END
	EXEC spa_print @sql
	EXEC(@sql)

	INSERT INTO #temp_missing_vol_cor_maturity_date (curve_id_from, curve_id_to, as_of_date, maturity_date)
	SELECT @curve_id_from, @curve_id_to, @as_of_date, tmd.maturity_date
	FROM #temp_vol_cor_maturity_date tmd
	LEFT JOIN #temp_avail_vol_cor_maturity_date tamd ON  tamd.maturity_date = tmd.maturity_date
	WHERE  tamd.maturity_date IS NULL
	
	IF @flag = 'CHECK'
	BEGIN
		IF @vol_cor = 'v'
		BEGIN
			INSERT INTO #temp_erroneous_vol_cor_curve_holiday (curve_id_from, curve_id_to, as_of_date, from_maturity_date, to_maturity_date, vol_cor_flag)
			SELECT cv.curve_id, NULL, MAX(tmmd.as_of_date) as_of_date, MIN(tmmd.maturity_date) from_date, MAX(tmmd.maturity_date) to_date, 'v'
			FROM #temp_missing_vol_cor_maturity_date tmmd
			INNER JOIN #temp_all_vol_cor_curves tvc ON tmmd.curve_id_from = tvc.curve_id_from
			INNER JOIN curve_volatility cv ON cv.curve_id = tvc.curve_id_from AND cv.curve_source_value_id = 4500
			LEFT JOIN holiday_group hg ON hg.hol_group_value_id = tvc.holiday_calendar_id AND tmmd.as_of_date = hg.hol_date
			WHERE hg.hol_group_ID IS NULL
			GROUP BY cv.curve_id
		END
		
		IF @vol_cor = 'c'
		BEGIN
			INSERT INTO #temp_erroneous_vol_cor_curve_holiday (curve_id_from, curve_id_to, as_of_date, from_maturity_date, to_maturity_date, vol_cor_flag)
			SELECT cc.curve_id_from, cc.curve_id_to, MAX(tmmd.as_of_date) as_of_date, MIN(tmmd.maturity_date) from_date, MAX(tmmd.maturity_date) to_date, 'c'
			FROM #temp_missing_vol_cor_maturity_date tmmd
			INNER JOIN #temp_all_vol_cor_curves tvc ON tmmd.curve_id_from = tvc.curve_id_from AND ISNULL(tmmd.curve_id_to, '') = ISNULL(tvc.curve_id_to, '')
			INNER JOIN curve_correlation cc ON cc.curve_id_from = tvc.curve_id_from AND cc.curve_source_value_id = 4500 AND cc.curve_id_to = tvc.curve_id_to
			LEFT JOIN holiday_group hg ON hg.hol_group_value_id = tvc.holiday_calendar_id AND tmmd.as_of_date = hg.hol_date
			WHERE hg.hol_group_ID IS NULL
			GROUP BY cc.curve_id_from, cc.curve_id_to
		END
	END
	
	IF @flag = 'COPY'
	BEGIN
		--SELECT * FROM #temp_missing_vol_cor_maturity_date
		--SELECT * FROM #temp_all_vol_cor_curves 
		IF @vol_cor = 'v'
		BEGIN
		DECLARE @insert_query VARCHAR(MAX)
		DECLARE @select_statement VARCHAR(MAX)
		SET @insert_query = ' INSERT INTO #temp_copy_vol_cur_holiday (curve_id_from, curve_id_to, as_of_date, maturity_date, copy_from_curve, vol_cor_flag)'
		 IF Exists(SELECT 1 FROM holiday_group hg INNER JOIN #temp_all_vol_cor_curves tcc ON  hg.hol_group_value_id = tcc.holiday_calendar_id where hol_date = @as_of_date)
		 BEGIN
			SET @select_statement = 'SELECT tcc.curve_id_from, NUll, tamd.as_of_date, tmmd.maturity_date, tcc.curve_id_from, ''v''
				FROM #temp_missing_vol_cor_maturity_date tmmd
			INNER JOIN #temp_all_vol_cor_curves tcc ON tmmd.curve_id_from = tcc.curve_id_from 
			INNER JOIN curve_volatility cv ON cv.curve_id = tcc.curve_id_from AND cv.curve_source_value_id = 4500  AND tmmd.maturity_date = cv.term
			INNER JOIN holiday_group hg ON hg.hol_group_value_id = tcc.holiday_calendar_id AND tmmd.as_of_date = hg.hol_date
			OUTER APPLY (SELECT MAX(as_of_date) as_of_date FROM curve_volatility cp_cv 
			WHERE tmmd.maturity_date = cp_cv.term AND cp_cv.curve_id = tcc.curve_id_from AND cp_cv.as_of_date < ''' +CONVERT(VARCHAR(10), @as_of_date, 120)+''') tamd
			 WHERE  tamd.as_of_date = cv.as_of_date AND tcc.vol_cor_flag =''v''AND tcc.curve_id_from= '+ CAST(@curve_id_from as varchar(40))
		 END
		 ELSE 
		 BEGIN
			SET @select_statement = 'SELECT tcc.curve_id_from, NUll, tamd.as_of_date, tmmd.maturity_date, tcc.curve_id_from, ''v''
				FROM #temp_missing_vol_cor_maturity_date tmmd
			INNER JOIN #temp_all_vol_cor_curves tcc ON tmmd.curve_id_from = tcc.curve_id_from
			INNER JOIN curve_volatility cv ON cv.curve_id = tcc.curve_id_from AND cv.curve_source_value_id = 4500 AND tmmd.maturity_date = cv.term
			OUTER APPLY (SELECT MAX(as_of_date) as_of_date FROM curve_volatility cp_cv
				 WHERE 
				 tmmd.maturity_date = cp_cv.term 
				 AND cp_cv.curve_id = tcc.curve_id_from 
				 AND cp_cv.curve_source_value_id = 4500
				 AND cp_cv.as_of_date < '''+ CONVERT(VARCHAR(10), @as_of_date, 120)+''') tamd
			WHERE   tcc.[Copy Missing] = ''y'' AND tamd.as_of_date = cv.as_of_date AND tcc.vol_cor_flag =''v''AND tcc.curve_id_from= '+  CAST(@curve_id_from as varchar(40))
		END 
		EXEC spa_print @insert_query
		EXEC spa_print @select_statement
		EXEC (@insert_query+@select_statement) 	

			EXEC spa_print 'COPY vol'
			INSERT INTO curve_volatility (
			    vol_cor_header_id,
			    as_of_date,
			    curve_id,
			    curve_source_value_id,
			    term,
			    [value],
			    create_user,
			    create_ts,
			    granularity,
			    strike_price
			  )
			SELECT cv.vol_cor_header_id,
			       @as_of_date,
			       cv.curve_id,
			       cv.curve_source_value_id,
			       cv.term,
			       cv.[value],
			       dbo.FNADBUser(),
			       GETDATE(),
			       cv.granularity,
			       cv.strike_price
			FROM curve_volatility cv
			INNER JOIN #temp_copy_vol_cur_holiday tcvch
			    ON  cv.curve_id = tcvch.curve_id_from
			    AND cv.term = tcvch.maturity_date
			    AND cv.as_of_date = tcvch.as_of_date
			WHERE  tcvch.curve_id_from = @curve_id_from AND cv.as_of_date < @as_of_date

		END
		
		IF @vol_cor = 'c'
		BEGIN
		DECLARE @insert_c VARCHAR(MAX)
		DECLARE @select_c VARCHAR(max)
		SET  @insert_c = 'INSERT INTO #temp_copy_vol_cur_holiday (curve_id_from, curve_id_to, as_of_date, maturity_date, copy_from_curve, vol_cor_flag)'
		 IF Exists(SELECT 1 FROM holiday_group hg INNER JOIN #temp_all_vol_cor_curves tcc ON  hg.hol_group_value_id = tcc.holiday_calendar_id where hol_date = @as_of_date)
		 BEGIN 
		 SET @select_c = 'SELECT tcc.curve_id_from, tcc.curve_id_to, tamd.as_of_date, tmmd.maturity_date, tcc.curve_id_from, ''c''
			FROM #temp_missing_vol_cor_maturity_date tmmd
			INNER JOIN #temp_all_vol_cor_curves tcc ON tmmd.curve_id_from = tcc.curve_id_from AND tmmd.curve_id_to = tcc.curve_id_to AND tcc.vol_cor_flag =''c''
			INNER JOIN curve_correlation cc ON cc.curve_id_from = tcc.curve_id_from AND cc.curve_source_value_id = 4500 AND cc.curve_id_to = tcc.curve_id_to 
			AND tmmd.maturity_date = cc.term1
			INNER JOIN holiday_group hg ON hg.hol_group_value_id = tcc.holiday_calendar_id AND tmmd.as_of_date = hg.hol_date
			OUTER APPLY (SELECT MAX(as_of_date) as_of_date
			             FROM   curve_correlation cp_cc
			             WHERE  tmmd.maturity_date = cp_cc.term1
			                    AND cp_cc.curve_id_from = tcc.curve_id_from
								AND cp_cc.curve_id_to = tcc.curve_id_to
								AND cp_cc.curve_source_value_id = 4500
								AND cp_cc.as_of_date < '''+CONVERT(VARCHAR(10), @as_of_date, 120)+'''
			) tamd WHERE tamd.as_of_date = cc.as_of_date AND tcc.curve_id_from= '+ CAST(@curve_id_from as varchar(40)) + ' AND tcc.curve_id_to= '+CAST(@curve_id_to as varchar(40))
		END
		ELSE 
		BEGIN 
		SET @select_c = '
			SELECT tcc.curve_id_from, tcc.curve_id_to, tamd.as_of_date, tmmd.maturity_date, tcc.curve_id_from, ''c''
			 FROM #temp_missing_vol_cor_maturity_date tmmd
			INNER JOIN #temp_all_vol_cor_curves tcc ON tmmd.curve_id_from = tcc.curve_id_from AND tmmd.curve_id_to = tcc.curve_id_to  AND tcc.vol_cor_flag =''c''
			INNER JOIN curve_correlation cc ON cc.curve_id_from = tcc.curve_id_from AND cc.curve_source_value_id = 4500 AND cc.curve_id_to = tcc.curve_id_to 
			AND tmmd.maturity_date = cc.term1
			OUTER APPLY (SELECT MAX(as_of_date) as_of_date
			             FROM   curve_correlation cp_cc
			             WHERE  tmmd.maturity_date = cp_cc.term1
			                    AND cp_cc.curve_id_from = tcc.curve_id_from
								AND cp_cc.curve_id_to = tcc.curve_id_to
								AND cp_cc.curve_source_value_id = 4500
								AND cp_cc.as_of_date < '''+CONVERT(VARCHAR(10), @as_of_date, 120)+'''
			) tamd WHERE tamd.as_of_date = cc.as_of_date AND tcc.[Copy Missing] = ''y'''
	END

	EXEC spa_print @insert_c
	EXEC spa_print @select_c

	EXEC(@insert_c+@select_c)


			EXEC spa_print 'COPY vol'
			INSERT INTO curve_correlation
			(
				-- id -- this column value is auto-generated
				vol_cor_header_id,
				as_of_date,
				curve_id_from,
				curve_id_to,
				term1,
				term2,
				curve_source_value_id,
				[value],
				create_user,
				create_ts
			)	
			SELECT cc.vol_cor_header_id,
			        @as_of_date,
			       cc.curve_id_from,
			       cc.curve_id_to,
			       cc.term1,
			       cc.term2,
			       cc.curve_source_value_id,
			       cc.[value],
			       dbo.FNADBUser(),
			       GETDATE()
		FROM   curve_correlation cc	
			INNER JOIN #temp_copy_vol_cur_holiday tcvch
			    ON  cc.curve_id_from = tcvch.curve_id_from
			    AND cc.curve_id_to = tcvch.curve_id_to
			    AND cc.term1 = tcvch.maturity_date
			    AND cc.as_of_date = tcvch.as_of_date
			WHERE  tcvch.curve_id_from = @curve_id_from AND tcvch.curve_id_to = @curve_id_to AND cc.as_of_date < @as_of_date



			
		END
	END	
	FETCH NEXT FROM eod_vol_cor_copy_cursor INTO @curve_id_from, @curve_id_to
END
CLOSE eod_vol_cor_copy_cursor
DEALLOCATE eod_vol_cor_copy_cursor


IF OBJECT_ID ('tempdb..#temp_treasury_data') IS NOT NULL
	DROP TABLE #temp_treasury_data

IF OBJECT_ID ('tempdb..#temp_treasury_check_date') IS NOT NULL
	DROP TABLE #temp_treasury_check_date

CREATE TABLE #temp_treasury_data (
	[curve_id]            INT,
	maturity_date         DATETIME,
	maturity_date_min     DATETIME,
	maturity_date_max     DATETIME
)

SET @curve_id = NULL

SELECT @curve_id = spcd.source_curve_def_id
FROM   source_price_curve_def spcd
WHERE spcd.curve_id = 'Bloomberg US Treasury Rates'

SELECT 95 no_of_date 
INTO #temp_treasury_check_date 
UNION ALL 
SELECT 187 UNION ALL
SELECT 369 UNION ALL
SELECT 735 UNION ALL
SELECT 1102 UNION ALL
SELECT 1466 UNION ALL
SELECT 1830 UNION ALL
SELECT 2561 UNION ALL
SELECT 2926 UNION ALL
SELECT 3293 UNION ALL
SELECT 3657 UNION ALL
SELECT 5484 UNION ALL
SELECT 7311 UNION ALL
SELECT 9135 UNION ALL
SELECT 10962

INSERT INTO #temp_treasury_data(curve_id, maturity_date, maturity_date_min, maturity_date_max)
SELECT @curve_id [source_curve_def_id],
	    DATEADD(DAY, no_of_date, @as_of_date) maturity_date,
	    DATEADD(DAY, no_of_date - 5, @as_of_date) maturity_date_min,
	    DATEADD(DAY, no_of_date + 5, @as_of_date) maturity_date_max	    
FROM #temp_treasury_check_date

INSERT INTO #temp_avail_maturity_date(source_curve_def_id, as_of_date, maturity_date)
SELECT  spc.source_curve_def_id,
		@as_of_date,
		maturity_date		   
FROM source_price_curve spc
WHERE as_of_date = @as_of_date AND spc.source_curve_def_id = @curve_id

INSERT INTO #temp_missing_maturity_date (source_curve_def_id, as_of_date, maturity_date)
SELECT tmd.curve_id      source_curve_def_id,
		@as_of_date            as_of_date,
		tmd.maturity_date		  
FROM #temp_treasury_data tmd
LEFT JOIN #temp_avail_maturity_date tamd
	ON  tamd.maturity_date BETWEEN tmd.maturity_date_min AND tmd.maturity_date_max
	AND tmd.curve_id = tamd.source_curve_def_id 
WHERE  tamd.maturity_date IS NULL 

IF @flag = 'CHECK'
BEGIN
	INSERT INTO #temp_erroneous_curve_holiday (source_curve_def_id, as_of_date, from_maturity_date, to_maturity_date)
	SELECT spcd.source_curve_def_id, MAX(tmmd.as_of_date) as_of_date, MIN(tmmd.maturity_date) from_date, MAX(tmmd.maturity_date) to_date
	FROM #temp_missing_maturity_date tmmd
	INNER JOIN #temp_validate_curves tvc ON tmmd.source_curve_def_id = tvc.curve_id
	INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = tvc.curve_id
	LEFT JOIN holiday_group hg ON hg.hol_group_value_id = tvc.holiday_calendar_id AND tmmd.as_of_date = hg.hol_date
	WHERE hg.hol_group_ID IS NULL
	GROUP BY spcd.source_curve_def_id


	INSERT INTO #temp_erroneous_curve_treasury (source_curve_def_id, as_of_date, from_maturity_date, to_maturity_date)
	SELECT spcd.source_curve_def_id, MAX(tmmd.as_of_date) as_of_date, MIN(tmmd.maturity_date) from_date, MAX(tmmd.maturity_date) to_date
	FROM #temp_missing_maturity_date tmmd
	INNER JOIN #temp_validate_curves tvc ON tmmd.source_curve_def_id = tvc.curve_id
	INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = tvc.curve_id
	LEFT JOIN holiday_group hg ON hg.hol_group_value_id = tvc.holiday_calendar_id AND tmmd.as_of_date = hg.hol_date
	WHERE hg.hol_group_ID IS NULL
	GROUP BY spcd.source_curve_def_id
	
END
ELSE IF @flag = 'COPY'
BEGIN
	IF OBJECT_ID('tempdb..#temp_prev_avail_as_of_date') IS NOT NULL
		DROP TABLE #temp_prev_avail_as_of_date
		
	SELECT MAX(as_of_date) as_of_date,
	       spc.source_curve_def_id curve_id,
	       MIN(DATEDIFF(DAY, as_of_date, @as_of_date)) days_diff
	INTO #temp_prev_avail_as_of_date
	FROM   source_price_curve spc
	WHERE  as_of_date < @as_of_date AND spc.source_curve_def_id = @curve_id
	GROUP BY spc.source_curve_def_id
	
	INSERT INTO #temp_copy_curve_holiday (source_curve_def_id, as_of_date, maturity_date, copy_from_curve)
	SELECT spc.source_curve_def_id, @as_of_date, DATEADD(DAY, tpa.days_diff, spc.maturity_date) maturity_date, tac.holiday_curve_id
	FROM   source_price_curve spc
	INNER JOIN #temp_missing_maturity_date tmmd
			ON  spc.maturity_date between DATEADD(DAY, -5, tmmd.maturity_date) and DATEADD(DAY, 5, tmmd.maturity_date)
		AND spc.source_curve_def_id = tmmd.source_curve_def_id
	INNER JOIN #temp_prev_avail_as_of_date tpa
		ON  tpa.as_of_date = spc.as_of_date
		AND spc.source_curve_def_id = tpa.curve_id
	OUTER APPLY (SELECT tac.holiday_curve_id FROM #temp_all_curves tac WHERE tac.curve_id = @curve_id) tac
	
	INSERT INTO source_price_curve (
		    source_curve_def_id,
		    as_of_date,
		    Assessment_curve_type_value_id,
		    curve_source_value_id,
		    maturity_date,
		    curve_value,
		    bid_value,
		    ask_value,
		    is_dst,
		    create_user,
		    create_ts
		  )
	SELECT tcch.source_curve_def_id,
		    @as_of_date,
		    spc.Assessment_curve_type_value_id,
		    curve_source_value_id,
		    tcch.maturity_date,
		    spc.curve_value,
		    spc.bid_value,
		    spc.ask_value,
		    spc.is_dst,
		    dbo.FNADBUser(),
		    GETDATE()
	FROM #temp_copy_curve_holiday tcch
	INNER JOIN source_price_curve spc 
		ON spc.source_curve_def_id = tcch.copy_from_curve
		AND spc.as_of_date = tcch.as_of_date
		AND spc.maturity_date = tcch.maturity_date
	WHERE tcch.source_curve_def_id = @curve_id
END

DECLARE @user_login_id VARCHAR(100)
DECLARE @url VARCHAR(8000)

SET @user_login_id = dbo.FNADBUser()

IF @flag = 'CHECK'
BEGIN
	BEGIN TRY 

	 -- SELECT * FROM source_system_data_import_status WHERE module = 'Price Verification' AND Process_id  = '21D1A179_67E9_4F24_943F_F2EE942418A8' 

		INSERT INTO source_system_data_import_status (
			Process_id,
			code,
			module,
			source,
			[type],
			[description],
			recommendation
		)		
		SELECT 
		@process_id [process_id], --'a',
		CASE WHEN ISNULL([Halt_process],'y') = 'n' THEN 
			'Success'
		ELSE  'Warning' END
		,
		'Price Verification',
		'Price Curve',
		'Price Missing',
		CASE WHEN spcd.curve_id = 'Bloomberg US Treasury Rates' THEN 'Treasury rates ' ELSE 'Price  ' END + 'missing for curve :- ' + spcd.curve_id + '. Terms:- ' + dbo.FNADateFormat(tech.from_maturity_date) + ' - ' + dbo.FNADateFormat(tech.to_maturity_date) + '.',
		'N/A.'
		FROM #temp_erroneous_curve_holiday tech
		INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = tech.source_curve_def_id
		INNER JOIN #temp_erroneous_curve_expiration tece ON tece.source_curve_def_id = tech.source_curve_def_id AND spcd.curve_id <> 'Bloomberg US Treasury Rates'
		INNER JOIN #temp_all_curves tac ON tac.curve_id = spcd.source_curve_def_id 
		UNION 
	
		SELECT 
		@process_id [process_id], --'a',
		CASE WHEN ISNULL(tac.[Halt_process],'y') = 'n' THEN 
			'Success'
		ELSE  'Warning' END,
		'Price Verification',
		CASE WHEN tech.vol_cor_flag = 'v' THEN 'Volatility' ELSE 'Correlation' END,
		CASE WHEN tech.vol_cor_flag = 'v' THEN 'Volatility' ELSE 'Correlation' END + ' Missing',
		CASE WHEN tech.vol_cor_flag = 'v' THEN 'Volatility' ELSE 'Correlation' END + '  missing for curve :- ' + spcd.curve_id + ISNULL(' Vs ' + spcd_to.curve_id, '') + ' . Terms:- ' + dbo.FNADateFormat(tech.from_maturity_date) + ' - ' + dbo.FNADateFormat(tech.to_maturity_date) + '.',
		'N/A.'
	FROM #temp_erroneous_vol_cor_curve_holiday tech
		INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = tech.curve_id_from
		LEFT JOIN source_price_curve_def spcd_to ON spcd_to.source_curve_def_id = tech.curve_id_to
		INNER JOIN #temp_all_vol_cor_curves tac on tac.curve_id_from = tech.curve_id_from AND tech.vol_cor_flag = tac.vol_cor_flag
	
		UNION  
	
		SELECT 
		@process_id [process_id], --'a',
		CASE WHEN ISNULL([Halt_process],'y') = 'n' THEN 
			'Success'
		ELSE  'Warning' END
		,
		'Price Verification',
		'Price Curve',
		'Price Missing',
		CASE WHEN spcd.curve_id = 'Bloomberg US Treasury Rates' THEN 'Treasury rates ' ELSE 'Price  ' END + 'missing for curve :- ' + spcd.curve_id + '. Terms:- ' + dbo.FNADateFormat(tech1.from_maturity_date) + ' - ' + dbo.FNADateFormat(tech1.to_maturity_date) + '.',
		'N/A.'
		FROM #temp_erroneous_curve_treasury tech1
		INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = tech1.source_curve_def_id
		INNER JOIN #temp_all_curves tac ON tac.curve_id = spcd.source_curve_def_id 

	
		--do not remove /dev here
		SELECT @url = './dev/spa_html.php?__user_name__=' + @user_login_id + '&spa=exec spa_get_import_process_status ''' + @process_id + ''',''' + @user_login_id + ''''
	
		DECLARE @type CHAR(1)
	
		IF EXISTS (SELECT 1 FROM source_system_data_import_status WHERE Process_id = @process_id AND module = 'Price Verification')
		BEGIN
			
			DECLARE @add_msg VARCHAR(1000) = ''
			IF EXISTS (SELECT 1 FROM source_system_data_import_status WHERE Process_id = @process_id AND module = 'Price Verification' AND code = 'Warning')
			BEGIN
				SET @type = 'e'
				SET @add_msg = ' with warning'
			END
			ELSE 
			BEGIN
				SET @type = 'w'
			END
				
			SELECT @desc = '<a target="_blank" href="' + @url + '">' + 'Price verification completed for run date  ' + dbo.FNADateFormat(@as_of_date) + @add_msg + '.</a>'
		
		END
		ELSE
		BEGIN
			SELECT @desc = 'Price verification completed for run date ' + dbo.FNADateFormat(@as_of_date) + '.'
			SET @type = 's'
		END
		
		EXEC spa_message_board 'i',
				@user_login_id,
				NULL,
				'Price Verification',
				@desc, 
				'',
				'', 
				@type,
				'Price Verification',
				NULL,
				@process_id
		
		DECLARE @return_status VARCHAR(100) = 'Success'
		--IF EXISTS (SELECT 1 FROM source_system_data_import_status WHERE Process_id = @process_id AND code = 'Warning')
		--BEGIN
		--	SET @return_status = 'Technical Error'
		--END
	
				
		 EXEC spa_ErrorHandler 0,
					'Verify Missing Curve',
					'spa_eod_verify_missing_curve',
					@return_status,
					@desc,
					''			
		END TRY
	BEGIN CATCH
			EXEC spa_ErrorHandler -1,
				'Verify Missing Curve',
				'spa_eod_verify_missing_curve',
				'Error',
				'Fail',
				''	
	END CATCH 				
END
IF @flag = 'COPY'
BEGIN
	BEGIN TRY

		--SELECT * FROM source_system_data_import_status WHERE  module = 'Price Copy' AND  process_id =  'B2CDBFFE_7FF9_497A_9668_742D4E195378'

		INSERT INTO source_system_data_import_status (
			Process_id,
			code,
			module,
			source,
			[type],
			[description],
			recommendation
		)		
		SELECT 
		@process_id [process_id], --'a',
		'Success',
		'Price Copy',
		'Price Curve',
		'Price Copy',
		CASE WHEN spcd.curve_id = 'Bloomberg US Treasury Rates' THEN 'Treasury rates ' ELSE 'Price  ' END + 'copied for curve :- ' + spcd.curve_id + '. Terms:- ' + dbo.FNADateFormat(MIN(tcch.maturity_date)) + ' - ' + dbo.FNADateFormat(MAX(tcch.maturity_date)) + '.',
		'N/A.'
		FROM #temp_copy_curve_holiday tcch
		INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = tcch.source_curve_def_id
		WHERE tcch.as_of_date IS NOT NULL
		GROUP BY spcd.curve_id
	
		UNION
	
		SELECT 
		@process_id [process_id], --'a',
		'Success',
		'Price Copy',
		'Price Curve',
		'Price Copy',
		'Price copied for curve :- ' + spcd.curve_id + '. Terms:- ' + dbo.FNADateFormat(MIN(tcce.maturity_date)) + ' - ' + dbo.FNADateFormat(MAX(tcce.maturity_date)) + '.',
		'N/A.'
		FROM #temp_copy_curve_expiration tcce
		INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = tcce.source_curve_def_id
		WHERE tcce.as_of_date IS NOT NULL
		GROUP BY spcd.curve_id
	
		UNION 

		SELECT 
		@process_id [process_id], --'a',
		'Success',
		'Price Copy',
		CASE WHEN tech.vol_cor_flag = 'v' THEN 'Volatility' ELSE 'Correlation' END,
		CASE WHEN tech.vol_cor_flag = 'v' THEN 'Volatility' ELSE 'Correlation' END + ' Copy',
		CASE WHEN tech.vol_cor_flag = 'v' THEN 'Volatility' ELSE 'Correlation' END + '  copied for curve :- ' + spcd.curve_id + ISNULL(' Vs ' + spcd_to.curve_id, '') + '. Terms:- ' + dbo.FNADateFormat(MIN(tech.maturity_date)) + ' - ' + dbo.FNADateFormat(MAX(tech.maturity_date)) + '.',
		'N/A.'
		FROM #temp_copy_vol_cur_holiday tech
		INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = tech.curve_id_from
		INNER JOIN source_price_curve_def spcd_to ON spcd_to.source_curve_def_id = tech.curve_id_to
		WHERE tech.as_of_date IS NOT NULL
		GROUP BY spcd.curve_id, spcd_to.curve_id, tech.vol_cor_flag

		--do not remove /dev here
		SELECT @url = './dev/spa_html.php?__user_name__=' + @user_login_id + '&spa=exec spa_get_import_process_status ''' + @process_id + ''',''' + @user_login_id + ''''
	
		IF EXISTS (SELECT 1 FROM source_system_data_import_status WHERE Process_id = @process_id AND module = 'Price Copy')
		BEGIN
			SELECT @desc = '<a target="_blank" href="' + @url + '">' + 'Price copy completed for run date ' + dbo.FNADateFormat(@as_of_date) + '.</a>'
		END
		ELSE
		BEGIN
			--SELECT @desc = 'Price copy completed for run date ' + dbo.FNADateFormat(@as_of_date) + '. No data is missing.'
			SELECT @desc = 'Price copy completed for run date ' + dbo.FNADateFormat(@as_of_date) + '.'
		END
		
		EXEC spa_message_board 'i',
				@user_login_id,
				NULL,
				'Price Copy',
				@desc,
				'',
				'',
				'',
				'Price Copy',
				NULL,
				@process_id
				
		EXEC spa_ErrorHandler 0,
				'Verify Missing Curve',
				'spa_eod_verify_missing_curve',
				'Success',
				@desc,
				''			
	END TRY
    BEGIN CATCH
        EXEC spa_ErrorHandler -1,
		'Verify Missing Curve',
		'spa_eod_verify_missing_curve',
		'Error',
		'Fail',
		''	
    END CATCH        			
END