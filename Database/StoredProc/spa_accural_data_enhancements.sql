IF OBJECT_ID(N'[dbo].[spa_accural_data_enhancements]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_accural_data_enhancements]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

--EXEC spa_accural_data_enhancements '2013-12-11'

/***********************************************************
* Description: Accrual process data enhancements in order to fill missing allocation/actual data
* Date:   2/9/2016 
* Author: spneupane@pioneersolutionsglobal.com
*
* Changes
* Date				Modified By					Comments
************************************************************
*2015-02-09			spneupane					Initial Version - 
************************************************************/

CREATE PROCEDURE [dbo].[spa_accural_data_enhancements]
    @production_month DATE = NULL
AS
BEGIN
	--DECLARE @production_month DATE = '2013-04-11'
	-- Previous Month
	SET @production_month = DATEADD(MONTH,-1,@production_month)
	-- Start Of Month        
	SET @production_month = DATEADD(month, DATEDIFF(month, 0, @production_month), 0)


	IF OBJECT_ID('tempdb..#temp_meter_id') IS NOT NULL
		DROP TABLE tempdb..#temp_meter_id

	-- Generic Mapping Configuration for meter
	CREATE TABLE #temp_meter_id
	(
		meter_id           INT,
		formula_option     INT,
		number_of_days     INT,
		granularity        INT,
	)	
	INSERT INTO #temp_meter_id
	SELECT mi.meter_id ,
			gmv.clm2_value,
			ISNULL(gmv.clm3_value,0),
			mi.granularity
	FROM   generic_mapping_header gmh
		   INNER JOIN generic_mapping_values gmv
				ON  gmh.mapping_table_id = gmv.mapping_table_id
		   INNER JOIN meter_id mi
				ON  gmv.clm1_value = mi.meter_id
	WHERE  gmh.mapping_name = 'Data Enhancement Rule'

	--SELECT * FROM #temp_meter_id

	-- List of meter id and corresponding missed / exisiting dates
	-- This table can be helpfull determine changes for meter data

	IF OBJECT_ID('tempdb..#missing_dates') IS NOT NULL
		DROP TABLE tempdb..#missing_dates
	
	CREATE TABLE #missing_dates
	(
		meter_id       INT,
		meter_date     DATE,
		meter_data_id  INT,
		prod_date      DATE,
		copy_from      DATE
	)
	-- If copy from is null check data availablibilty

	INSERT INTO #missing_dates (meter_id, meter_date, rsmeter.meter_data_id, prod_date, copy_from)
	SELECT both.meter_id,both.meter_date, meter_data_id, both.prod_date, ISNULL(mv_15.prod_date , ISNULL(mv_hr.prod_date,mv_15.prod_date)) copy_from
	FROM   (
			   SELECT t.meter_id,
					  new_dt [meter_date],
					  mdh.prod_date
			   FROM   seq s
					  OUTER APPLY (
				   SELECT DATEADD(DAY, n - 1, @production_month) new_dt
			   ) rs_dt_breakdown
			   CROSS APPLY (
				   SELECT *
				   FROM   #temp_meter_id
				   WHERE  granularity = 982
			   ) t
			   INNER JOIN mv90_data md
						   ON  t.meter_id = md.meter_id
					  LEFT JOIN mv90_data_hour mdh
						   ON  md.meter_data_id = mdh.meter_data_id
						   AND mdh.prod_date = new_dt
			   WHERE  s.n < 33
					  AND MONTH(rs_dt_breakdown.new_dt) <= MONTH(@production_month)
					  AND new_dt BETWEEN md.from_date AND md.to_date
					  AND t.granularity = 982
			   UNION ALL
			   SELECT t.meter_id,
					  new_dt [meter_date],
					  mdm.prod_date
			   FROM   seq s
					  OUTER APPLY (
				   SELECT DATEADD(DAY, n - 1, @production_month) new_dt
			   ) rs_dt_breakdown
			   CROSS APPLY (
				   SELECT *
				   FROM   #temp_meter_id
                                   WHERE  granularity IN (987, 989)
			   ) t
			   INNER JOIN mv90_data md
						   ON  t.meter_id = md.meter_id
					  LEFT JOIN mv90_data_mins mdm
						   ON  md.meter_data_id = mdm.meter_data_id
						   AND mdm.prod_date = new_dt
			   WHERE  s.n < 33
					  AND MONTH(rs_dt_breakdown.new_dt) <= MONTH(@production_month)
					  AND new_dt BETWEEN md.from_date AND md.to_date
                                          AND t.granularity IN (987, 989)
		   ) both
	OUTER APPLY(
		SELECT TOP 1 mdh.prod_date 
		FROM mv90_data_mins mdh
		INNER JOIN mv90_data md ON md.meter_data_id = mdh.meter_data_id
		WHERE md.meter_id = both.meter_id
			AND mdh.prod_date < both.meter_date 				--find in previous date
			AND DAY(both.meter_date) = DAY(mdh.prod_date)		--for same day
		ORDER BY mdh.prod_date DESC
	) mv_15
	OUTER APPLY(
		SELECT TOP 1 mdh.prod_date 
		FROM mv90_data_hour mdh
		INNER JOIN mv90_data md ON md.meter_data_id = mdh.meter_data_id
		WHERE md.meter_id = both.meter_id
			AND mdh.prod_date < both.meter_date 				--find in previous date
			AND DAY(both.meter_date) = DAY(mdh.prod_date)		--for same day
		ORDER BY mdh.prod_date DESC
	) mv_hr	
	OUTER APPLY (
	-- Meter data id according to meter missing date
	SELECT DISTINCT md.meter_data_id FROM mv90_data md 
	WHERE md.meter_id = both.meter_id AND both.meter_date BETWEEN md.from_date AND md.to_date
	) rsmeter
	--WHERE (mv_15.prod_date IS NOT NULL OR mv_hr.prod_date IS NOT NULL)

	--SELECT * FROM #missing_dates
	
	DECLARE @meter_id INT, @formula_option INT, @number_of_days INT, @granularity INT

	DECLARE missing_meter_cursor CURSOR FAST_FORWARD READ_ONLY FOR
		--	Meter to be processed which has missing data
		SELECT DISTINCT t.meter_id, t.formula_option, t.number_of_days,t.granularity FROM #temp_meter_id t
		INNER JOIN #missing_dates md ON t.meter_id = md.meter_id
		WHERE md.prod_date IS NULL
	OPEN missing_meter_cursor

	FETCH FROM missing_meter_cursor INTO @meter_id, @formula_option, @number_of_days, @granularity
	WHILE @@FETCH_STATUS = 0
	BEGIN
		--SELECT @meter_id, @formula_option, @number_of_days, @granularity
		DECLARE @max_missing_date date, @min_missing_date date

		IF (@formula_option = 1)		-- Average Last # Of Days
		BEGIN

			DECLARE @start_date date
		
			SELECT @max_missing_date = MAX(meter_date) FROM #missing_dates WHERE meter_id = @meter_id AND prod_date IS NOT NULL
			SET @start_date = DATEADD(DAY,-@number_of_days + 1,@max_missing_date)
			--SELECT @max_missing_date, @start_date
			--SELECT DATEDIFF(DAY,@start_date, @max_missing_date), (@number_of_days * 24)
			IF (@granularity = 982)		-- Hourly
			BEGIN
				INSERT INTO mv90_data_hour(prod_date, meter_data_id, data_missing, Hr1, Hr2, Hr3, Hr4, Hr5, Hr6, Hr7, Hr8, Hr9, Hr10, Hr11, Hr12, Hr13, Hr14, Hr15, Hr16, Hr17, Hr18, Hr19, Hr20, Hr21, Hr22, Hr23, Hr24, Hr25)
				SELECT m.meter_date, m.meter_data_id, 'y' data_missing, Hr AS Hr1, Hr AS Hr2, Hr AS Hr3, Hr AS Hr4, Hr AS Hr5, Hr AS Hr6, Hr AS Hr7, Hr AS Hr8, Hr AS Hr9, Hr AS Hr10, Hr AS Hr11, Hr AS Hr12, Hr AS Hr13, Hr AS Hr14
					, Hr AS Hr15, Hr AS Hr16, Hr AS Hr17, Hr AS Hr18, Hr AS Hr19, Hr AS Hr20, Hr AS Hr21, Hr AS Hr22, Hr AS Hr23, Hr AS Hr24, NULL AS Hr25
				FROM #missing_dates m
					CROSS APPLY (
						SELECT  SUM(ISNULL(Hr1,0) + ISNULL(Hr2,0)+ ISNULL(Hr3,0)+ ISNULL(Hr4,0)+ ISNULL(Hr5,0)+ ISNULL(Hr6,0)+ ISNULL(Hr7,0)+ ISNULL(Hr8,0)+ ISNULL(Hr9,0)+ ISNULL(Hr10,0)+ ISNULL(Hr11,0)+ ISNULL(Hr12,0)+ ISNULL(Hr13,0)+ ISNULL(Hr14,0)+ ISNULL(Hr15,0)+ ISNULL(Hr16,0)+ ISNULL(Hr17,0)+ ISNULL(Hr18,0)+ ISNULL(Hr19,0)+ ISNULL(Hr20,0)+ ISNULL(Hr21,0)+ ISNULL(Hr22,0)+ ISNULL(Hr23,0)+ ISNULL(Hr24,0)+ ISNULL(Hr25,0)) / (@number_of_days * 24)   Hr  FROM mv90_data md
						INNER JOIN mv90_data_hour mdh ON md.meter_data_id = mdh.meter_data_id 
						AND mdh.prod_date BETWEEN @start_date AND @max_missing_date
						WHERE md.meter_id = @meter_id 
					) rs
				WHERE m.meter_id = @meter_id AND m.prod_date IS NULL
			END
			ELSE IF (@granularity IN (987, 989)) -- 15 Minutes / 30 Min
			BEGIN
			IF (@granularity = 987 ) -- 15 min
			BEGIN
				INSERT INTO mv90_data_mins(prod_date,meter_data_id,data_missing, Hr1_15, Hr1_30, Hr1_45, Hr1_60, Hr2_15, Hr2_30, Hr2_45, Hr2_60, Hr3_15, Hr3_30, Hr3_45, Hr3_60, Hr4_15, Hr4_30, Hr4_45, Hr4_60, Hr5_15, Hr5_30, Hr5_45
						, Hr5_60, Hr6_15, Hr6_30, Hr6_45, Hr6_60, Hr7_15, Hr7_30, Hr7_45, Hr7_60, Hr8_15, Hr8_30, Hr8_45, Hr8_60, Hr9_15, Hr9_30, Hr9_45, Hr9_60, Hr10_15, Hr10_30
						, Hr10_45, Hr10_60, Hr11_15, Hr11_30, Hr11_45, Hr11_60, Hr12_15, Hr12_30, Hr12_45, Hr12_60, Hr13_15, Hr13_30, Hr13_45, Hr13_60, Hr14_15, Hr14_30, Hr14_45
						, Hr14_60, Hr15_15, Hr15_30, Hr15_45, Hr15_60, Hr16_15, Hr16_30, Hr16_45, Hr16_60, Hr17_15, Hr17_30, Hr17_45, Hr17_60, Hr18_15, Hr18_30, Hr18_45, Hr18_60
						, Hr19_15, Hr19_30, Hr19_45, Hr19_60, Hr20_15, Hr20_30, Hr20_45, Hr20_60, Hr21_15, Hr21_30, Hr21_45, Hr21_60, Hr22_15, Hr22_30, Hr22_45, Hr22_60, Hr23_15
						, Hr23_30, Hr23_45, Hr23_60, Hr24_15, Hr24_30, Hr24_45, Hr24_60, Hr25_15, Hr25_30, Hr25_45, Hr25_60)
						
				SELECT m.meter_date, m.meter_data_id, 'y' data_missing, Hr AS Hr1_15, Hr AS Hr1_30, Hr AS Hr1_45, Hr AS Hr1_60, Hr AS Hr2_15, Hr AS Hr2_30, Hr AS Hr2_45, Hr AS Hr2_60, Hr AS Hr3_15, Hr AS Hr3_30, Hr AS Hr3_45, Hr AS Hr3_60, 
					Hr AS Hr4_15, Hr AS Hr4_30, Hr AS Hr4_45, Hr AS Hr4_60, Hr AS Hr5_15, Hr AS Hr5_30, Hr AS Hr5_45, Hr AS Hr5_60, Hr AS Hr6_15, Hr AS Hr6_30, Hr AS Hr6_45, Hr AS Hr6_60, 
					Hr AS Hr7_15, Hr AS Hr7_30, Hr AS Hr7_45, Hr AS Hr7_60, Hr AS Hr8_15, Hr AS Hr8_30, Hr AS Hr8_45, Hr AS Hr8_60, Hr AS Hr9_15, Hr AS Hr9_30, Hr AS Hr9_45, Hr AS Hr9_60, 
					Hr AS Hr10_15, Hr AS Hr10_30, Hr AS Hr10_45, Hr AS Hr10_60, Hr AS Hr11_15, Hr AS Hr11_30, Hr AS Hr11_45, Hr AS Hr11_60, Hr AS Hr12_15, Hr AS Hr12_30, Hr AS Hr12_45, 
					Hr AS Hr12_60, Hr AS Hr13_15, Hr AS Hr13_30, Hr AS Hr13_45, Hr AS Hr13_60, Hr AS Hr14_15, Hr AS Hr14_30, Hr AS Hr14_45, Hr AS Hr14_60, Hr AS Hr15_15, Hr AS Hr15_30, 
					Hr AS Hr15_45, Hr AS Hr15_60, Hr AS Hr16_15, Hr AS Hr16_30, Hr AS Hr16_45, Hr AS Hr16_60, Hr AS Hr17_15, Hr AS Hr17_30, Hr AS Hr17_45, Hr AS Hr17_60, Hr AS Hr18_15, 
					Hr AS Hr18_30, Hr AS Hr18_45, Hr AS Hr18_60, Hr AS Hr19_15, Hr AS Hr19_30, Hr AS Hr19_45, Hr AS Hr19_60, Hr AS Hr20_15, Hr AS Hr20_30, Hr AS Hr20_45, Hr AS Hr20_60, 
					Hr AS Hr21_15, Hr AS Hr21_30, Hr AS Hr21_45, Hr AS Hr21_60, Hr AS Hr22_15, Hr AS Hr22_30, Hr AS Hr22_45, Hr AS Hr22_60, Hr AS Hr23_15, Hr AS Hr23_30, Hr AS Hr23_45, 
					Hr AS Hr23_60, Hr AS Hr24_15, Hr AS Hr24_30, Hr AS Hr24_45, Hr AS Hr24_60, NULL AS Hr25_15, NULL AS Hr25_30, NULL AS Hr25_45, NULL AS Hr25_60
				FROM #missing_dates m
					CROSS APPLY (
						SELECT  SUM(ISNULL(Hr1_15, 0) + ISNULL(Hr1_30, 0) + ISNULL(Hr1_45, 0) + ISNULL(Hr1_60, 0) + ISNULL(Hr2_15, 0) + ISNULL(Hr2_30, 0) + ISNULL(Hr2_45, 0) + ISNULL(Hr2_60, 0) + 
							ISNULL(Hr3_15, 0) + ISNULL(Hr3_30, 0) + ISNULL(Hr3_45, 0) + ISNULL(Hr3_60, 0) + ISNULL(Hr4_15, 0) + ISNULL(Hr4_30, 0) + ISNULL(Hr4_45, 0) + ISNULL(Hr4_60, 0) + 
							ISNULL(Hr5_15, 0) + ISNULL(Hr5_30, 0) + ISNULL(Hr5_45, 0) + ISNULL(Hr5_60, 0) + ISNULL(Hr6_15, 0) + ISNULL(Hr6_30, 0) + ISNULL(Hr6_45, 0) + ISNULL(Hr6_60, 0) + 
							ISNULL(Hr7_15, 0) + ISNULL(Hr7_30, 0) + ISNULL(Hr7_45, 0) + ISNULL(Hr7_60, 0) + ISNULL(Hr8_15, 0) + ISNULL(Hr8_30, 0) + ISNULL(Hr8_45, 0) + ISNULL(Hr8_60, 0) + 
							ISNULL(Hr9_15, 0) + ISNULL(Hr9_30, 0) + ISNULL(Hr9_45, 0) + ISNULL(Hr9_60, 0) + ISNULL(Hr10_15, 0) + ISNULL(Hr10_30, 0) + ISNULL(Hr10_45, 0) + ISNULL(Hr10_60, 0) + 
							ISNULL(Hr11_15, 0) + ISNULL(Hr11_30, 0) + ISNULL(Hr11_45, 0) + ISNULL(Hr11_60, 0) + ISNULL(Hr12_15, 0) + ISNULL(Hr12_30, 0) + ISNULL(Hr12_45, 0) + ISNULL(Hr12_60, 0) + 
							ISNULL(Hr13_15, 0) + ISNULL(Hr13_30, 0) + ISNULL(Hr13_45, 0) + ISNULL(Hr13_60, 0) + ISNULL(Hr14_15, 0) + ISNULL(Hr14_30, 0) + ISNULL(Hr14_45, 0) + ISNULL(Hr14_60, 0) + 
							ISNULL(Hr15_15, 0) + ISNULL(Hr15_30, 0) + ISNULL(Hr15_45, 0) + ISNULL(Hr15_60, 0) + ISNULL(Hr16_15, 0) + ISNULL(Hr16_30, 0) + ISNULL(Hr16_45, 0) + ISNULL(Hr16_60, 0) + 
							ISNULL(Hr17_15, 0) + ISNULL(Hr17_30, 0) + ISNULL(Hr17_45, 0) + ISNULL(Hr17_60, 0) + ISNULL(Hr18_15, 0) + ISNULL(Hr18_30, 0) + ISNULL(Hr18_45, 0) + ISNULL(Hr18_60, 0) + 
							ISNULL(Hr19_15, 0) + ISNULL(Hr19_30, 0) + ISNULL(Hr19_45, 0) + ISNULL(Hr19_60, 0) + ISNULL(Hr20_15, 0) + ISNULL(Hr20_30, 0) + ISNULL(Hr20_45, 0) + ISNULL(Hr20_60, 0) + 
							ISNULL(Hr21_15, 0) + ISNULL(Hr21_30, 0) + ISNULL(Hr21_45, 0) + ISNULL(Hr21_60, 0) + ISNULL(Hr22_15, 0) + ISNULL(Hr22_30, 0) + ISNULL(Hr22_45, 0) + ISNULL(Hr22_60, 0) + 
							ISNULL(Hr23_15, 0) + ISNULL(Hr23_30, 0) + ISNULL(Hr23_45, 0) + ISNULL(Hr23_60, 0) + ISNULL(Hr24_15, 0) + ISNULL(Hr24_30, 0) + ISNULL(Hr24_45, 0) + ISNULL(Hr24_60, 0) + 
							ISNULL(Hr25_15, 0) + ISNULL(Hr25_30, 0) + ISNULL(Hr25_45, 0) + ISNULL(Hr25_60, 0)) / (@number_of_days * 24 * 4)   Hr  FROM mv90_data md
						INNER JOIN mv90_data_mins mdm ON md.meter_data_id = mdm.meter_data_id 
						AND mdm.prod_date BETWEEN @start_date AND @max_missing_date
						WHERE md.meter_id = @meter_id 
					) rs
				WHERE m.meter_id = @meter_id AND m.prod_date IS NULL
			END
			ELSE IF (@granularity = 989) -- 30 Min
			BEGIN
				INSERT INTO mv90_data_mins(prod_date,meter_data_id,data_missing, Hr1_15, Hr1_30, Hr1_45, Hr1_60, Hr2_15, Hr2_30, Hr2_45, Hr2_60, Hr3_15, Hr3_30, Hr3_45, Hr3_60, Hr4_15, Hr4_30, Hr4_45, Hr4_60, Hr5_15, Hr5_30, Hr5_45
						, Hr5_60, Hr6_15, Hr6_30, Hr6_45, Hr6_60, Hr7_15, Hr7_30, Hr7_45, Hr7_60, Hr8_15, Hr8_30, Hr8_45, Hr8_60, Hr9_15, Hr9_30, Hr9_45, Hr9_60, Hr10_15, Hr10_30
						, Hr10_45, Hr10_60, Hr11_15, Hr11_30, Hr11_45, Hr11_60, Hr12_15, Hr12_30, Hr12_45, Hr12_60, Hr13_15, Hr13_30, Hr13_45, Hr13_60, Hr14_15, Hr14_30, Hr14_45
						, Hr14_60, Hr15_15, Hr15_30, Hr15_45, Hr15_60, Hr16_15, Hr16_30, Hr16_45, Hr16_60, Hr17_15, Hr17_30, Hr17_45, Hr17_60, Hr18_15, Hr18_30, Hr18_45, Hr18_60
						, Hr19_15, Hr19_30, Hr19_45, Hr19_60, Hr20_15, Hr20_30, Hr20_45, Hr20_60, Hr21_15, Hr21_30, Hr21_45, Hr21_60, Hr22_15, Hr22_30, Hr22_45, Hr22_60, Hr23_15
						, Hr23_30, Hr23_45, Hr23_60, Hr24_15, Hr24_30, Hr24_45, Hr24_60, Hr25_15, Hr25_30, Hr25_45, Hr25_60)
						
				SELECT m.meter_date, m.meter_data_id,  'y' data_missing, Hr AS Hr1_15, NULL AS Hr1_30, Hr AS Hr1_45, NULL AS Hr1_60, Hr AS Hr2_15, NULL  AS Hr2_30, Hr AS Hr2_45, NULL  AS Hr2_60, Hr AS Hr3_15, NULL  AS Hr3_30, Hr AS Hr3_45, NULL AS Hr3_60, 
					Hr AS Hr4_15, NULL AS Hr4_30, Hr AS Hr4_45, NULL AS Hr4_60, Hr AS Hr5_15, NULL AS Hr5_30, Hr AS Hr5_45, NULL AS Hr5_60, Hr AS Hr6_15, NULL AS Hr6_30, Hr AS Hr6_45, NULL AS Hr6_60, 
					Hr AS Hr7_15, NULL AS Hr7_30, Hr AS Hr7_45, NULL AS Hr7_60, Hr AS Hr8_15, NULL AS Hr8_30, Hr AS Hr8_45, NULL AS Hr8_60, Hr AS Hr9_15, NULL AS Hr9_30, Hr AS Hr9_45, NULL AS Hr9_60, 
					Hr AS Hr10_15, NULL AS Hr10_30, Hr AS Hr10_45, NULL AS Hr10_60, Hr AS Hr11_15, NULL AS Hr11_30, Hr AS Hr11_45, NULL AS Hr11_60, Hr AS Hr12_15, NULL AS Hr12_30, Hr AS Hr12_45, 
					NULL AS Hr12_60, Hr AS Hr13_15, NULL AS Hr13_30, Hr AS Hr13_45, NULL AS Hr13_60, Hr AS Hr14_15, NULL AS Hr14_30, Hr AS Hr14_45, NULL AS Hr14_60, Hr AS Hr15_15, NULL AS Hr15_30, 
					Hr AS Hr15_45, NULL AS Hr15_60, Hr AS Hr16_15, NULL AS Hr16_30, Hr AS Hr16_45, NULL AS Hr16_60, Hr AS Hr17_15, NULL AS Hr17_30, Hr AS Hr17_45, NULL AS Hr17_60, Hr AS Hr18_15, 
					NULL AS Hr18_30, Hr AS Hr18_45, NULL AS Hr18_60, Hr AS Hr19_15, NULL AS Hr19_30, Hr AS Hr19_45, NULL AS Hr19_60, Hr AS Hr20_15, NULL AS Hr20_30, Hr AS Hr20_45, NULL AS Hr20_60, 
					Hr AS Hr21_15, NULL AS Hr21_30, Hr AS Hr21_45, NULL AS Hr21_60, Hr AS Hr22_15, NULL AS Hr22_30, Hr AS Hr22_45, NULL AS Hr22_60, Hr AS Hr23_15, NULL AS Hr23_30, Hr AS Hr23_45, 
					NULL AS Hr23_60, Hr AS Hr24_15, NULL AS Hr24_30, Hr AS Hr24_45, NULL AS Hr24_60, NULL AS Hr25_15, NULL AS Hr25_30, NULL AS Hr25_45, NULL AS Hr25_60
				FROM #missing_dates m
					CROSS APPLY (
						SELECT SUM(ISNULL(Hr1_15, 0) + ISNULL(Hr1_30, 0) + ISNULL(Hr1_45, 0) + ISNULL(Hr1_60, 0) + ISNULL(Hr2_15, 0) + ISNULL(Hr2_30, 0) + ISNULL(Hr2_45, 0) + ISNULL(Hr2_60, 0) + 
							ISNULL(Hr3_15, 0) + ISNULL(Hr3_30, 0) + ISNULL(Hr3_45, 0) + ISNULL(Hr3_60, 0) + ISNULL(Hr4_15, 0) + ISNULL(Hr4_30, 0) + ISNULL(Hr4_45, 0) + ISNULL(Hr4_60, 0) + 
							ISNULL(Hr5_15, 0) + ISNULL(Hr5_30, 0) + ISNULL(Hr5_45, 0) + ISNULL(Hr5_60, 0) + ISNULL(Hr6_15, 0) + ISNULL(Hr6_30, 0) + ISNULL(Hr6_45, 0) + ISNULL(Hr6_60, 0) + 
							ISNULL(Hr7_15, 0) + ISNULL(Hr7_30, 0) + ISNULL(Hr7_45, 0) + ISNULL(Hr7_60, 0) + ISNULL(Hr8_15, 0) + ISNULL(Hr8_30, 0) + ISNULL(Hr8_45, 0) + ISNULL(Hr8_60, 0) + 
							ISNULL(Hr9_15, 0) + ISNULL(Hr9_30, 0) + ISNULL(Hr9_45, 0) + ISNULL(Hr9_60, 0) + ISNULL(Hr10_15, 0) + ISNULL(Hr10_30, 0) + ISNULL(Hr10_45, 0) + ISNULL(Hr10_60, 0) + 
							ISNULL(Hr11_15, 0) + ISNULL(Hr11_30, 0) + ISNULL(Hr11_45, 0) + ISNULL(Hr11_60, 0) + ISNULL(Hr12_15, 0) + ISNULL(Hr12_30, 0) + ISNULL(Hr12_45, 0) + ISNULL(Hr12_60, 0) + 
							ISNULL(Hr13_15, 0) + ISNULL(Hr13_30, 0) + ISNULL(Hr13_45, 0) + ISNULL(Hr13_60, 0) + ISNULL(Hr14_15, 0) + ISNULL(Hr14_30, 0) + ISNULL(Hr14_45, 0) + ISNULL(Hr14_60, 0) + 
							ISNULL(Hr15_15, 0) + ISNULL(Hr15_30, 0) + ISNULL(Hr15_45, 0) + ISNULL(Hr15_60, 0) + ISNULL(Hr16_15, 0) + ISNULL(Hr16_30, 0) + ISNULL(Hr16_45, 0) + ISNULL(Hr16_60, 0) + 
							ISNULL(Hr17_15, 0) + ISNULL(Hr17_30, 0) + ISNULL(Hr17_45, 0) + ISNULL(Hr17_60, 0) + ISNULL(Hr18_15, 0) + ISNULL(Hr18_30, 0) + ISNULL(Hr18_45, 0) + ISNULL(Hr18_60, 0) + 
							ISNULL(Hr19_15, 0) + ISNULL(Hr19_30, 0) + ISNULL(Hr19_45, 0) + ISNULL(Hr19_60, 0) + ISNULL(Hr20_15, 0) + ISNULL(Hr20_30, 0) + ISNULL(Hr20_45, 0) + ISNULL(Hr20_60, 0) + 
							ISNULL(Hr21_15, 0) + ISNULL(Hr21_30, 0) + ISNULL(Hr21_45, 0) + ISNULL(Hr21_60, 0) + ISNULL(Hr22_15, 0) + ISNULL(Hr22_30, 0) + ISNULL(Hr22_45, 0) + ISNULL(Hr22_60, 0) + 
							ISNULL(Hr23_15, 0) + ISNULL(Hr23_30, 0) + ISNULL(Hr23_45, 0) + ISNULL(Hr23_60, 0) + ISNULL(Hr24_15, 0) + ISNULL(Hr24_30, 0) + ISNULL(Hr24_45, 0) + ISNULL(Hr24_60, 0) + 
							ISNULL(Hr25_15, 0) + ISNULL(Hr25_30, 0) + ISNULL(Hr25_45, 0) + ISNULL(Hr25_60, 0)) / (@number_of_days * 24 * 2)   Hr  FROM mv90_data md
						INNER JOIN mv90_data_mins mdm ON md.meter_data_id = mdm.meter_data_id 
						AND mdm.prod_date BETWEEN @start_date AND @max_missing_date
						WHERE md.meter_id = @meter_id 
					) rs
				WHERE m.meter_id = @meter_id AND m.prod_date IS NULL
			END
				
				-- Delete From Hourly for that meter and missing production date if exists
				DELETE mdh
				FROM   mv90_data_hour mdh
					   INNER JOIN #missing_dates md
							ON  mdh.meter_data_id = md.meter_data_id
							AND mdh.prod_date = md.meter_date
				WHERE  md.prod_date IS NULL
				
				-- Insert into mv90_data_hour from min data
				INSERT INTO mv90_data_hour(prod_date, meter_data_id, data_missing, Hr1, Hr2, Hr3, Hr4, Hr5, Hr6, Hr7, Hr8, Hr9, Hr10, Hr11, Hr12, Hr13, Hr14, Hr15, Hr16, Hr17, Hr18, Hr19, Hr20, Hr21, Hr22, Hr23, Hr24, Hr25)
				SELECT m.meter_date, m.meter_data_id,  'y' data_missing, Hr * 4  AS Hr1, Hr * 4  AS Hr2, Hr * 4  AS Hr3, Hr * 4  AS Hr4, Hr * 4  AS Hr5, Hr * 4  AS Hr6, Hr * 4  AS Hr7, Hr * 4  AS Hr8, Hr * 4  AS Hr9, Hr * 4  AS Hr10, Hr * 4  AS Hr11, Hr * 4  AS Hr12, Hr * 4  AS Hr13, Hr * 4  AS Hr14
					, Hr * 4  AS Hr15, Hr * 4  AS Hr16, Hr * 4  AS Hr17, Hr * 4  AS Hr18, Hr * 4  AS Hr19, Hr * 4  AS Hr20, Hr * 4  AS Hr21, Hr * 4  AS Hr22, Hr * 4  AS Hr23, Hr * 4  AS Hr24, NULL AS Hr25
				FROM #missing_dates m
					CROSS APPLY (
						SELECT SUM(ISNULL(Hr1_15, 0) + ISNULL(Hr1_30, 0) + ISNULL(Hr1_45, 0) + ISNULL(Hr1_60, 0) + ISNULL(Hr2_15, 0) + ISNULL(Hr2_30, 0) + ISNULL(Hr2_45, 0) + ISNULL(Hr2_60, 0) + 
							ISNULL(Hr3_15, 0) + ISNULL(Hr3_30, 0) + ISNULL(Hr3_45, 0) + ISNULL(Hr3_60, 0) + ISNULL(Hr4_15, 0) + ISNULL(Hr4_30, 0) + ISNULL(Hr4_45, 0) + ISNULL(Hr4_60, 0) + 
							ISNULL(Hr5_15, 0) + ISNULL(Hr5_30, 0) + ISNULL(Hr5_45, 0) + ISNULL(Hr5_60, 0) + ISNULL(Hr6_15, 0) + ISNULL(Hr6_30, 0) + ISNULL(Hr6_45, 0) + ISNULL(Hr6_60, 0) + 
							ISNULL(Hr7_15, 0) + ISNULL(Hr7_30, 0) + ISNULL(Hr7_45, 0) + ISNULL(Hr7_60, 0) + ISNULL(Hr8_15, 0) + ISNULL(Hr8_30, 0) + ISNULL(Hr8_45, 0) + ISNULL(Hr8_60, 0) + 
							ISNULL(Hr9_15, 0) + ISNULL(Hr9_30, 0) + ISNULL(Hr9_45, 0) + ISNULL(Hr9_60, 0) + ISNULL(Hr10_15, 0) + ISNULL(Hr10_30, 0) + ISNULL(Hr10_45, 0) + ISNULL(Hr10_60, 0) + 
							ISNULL(Hr11_15, 0) + ISNULL(Hr11_30, 0) + ISNULL(Hr11_45, 0) + ISNULL(Hr11_60, 0) + ISNULL(Hr12_15, 0) + ISNULL(Hr12_30, 0) + ISNULL(Hr12_45, 0) + ISNULL(Hr12_60, 0) + 
							ISNULL(Hr13_15, 0) + ISNULL(Hr13_30, 0) + ISNULL(Hr13_45, 0) + ISNULL(Hr13_60, 0) + ISNULL(Hr14_15, 0) + ISNULL(Hr14_30, 0) + ISNULL(Hr14_45, 0) + ISNULL(Hr14_60, 0) + 
							ISNULL(Hr15_15, 0) + ISNULL(Hr15_30, 0) + ISNULL(Hr15_45, 0) + ISNULL(Hr15_60, 0) + ISNULL(Hr16_15, 0) + ISNULL(Hr16_30, 0) + ISNULL(Hr16_45, 0) + ISNULL(Hr16_60, 0) + 
							ISNULL(Hr17_15, 0) + ISNULL(Hr17_30, 0) + ISNULL(Hr17_45, 0) + ISNULL(Hr17_60, 0) + ISNULL(Hr18_15, 0) + ISNULL(Hr18_30, 0) + ISNULL(Hr18_45, 0) + ISNULL(Hr18_60, 0) + 
							ISNULL(Hr19_15, 0) + ISNULL(Hr19_30, 0) + ISNULL(Hr19_45, 0) + ISNULL(Hr19_60, 0) + ISNULL(Hr20_15, 0) + ISNULL(Hr20_30, 0) + ISNULL(Hr20_45, 0) + ISNULL(Hr20_60, 0) + 
							ISNULL(Hr21_15, 0) + ISNULL(Hr21_30, 0) + ISNULL(Hr21_45, 0) + ISNULL(Hr21_60, 0) + ISNULL(Hr22_15, 0) + ISNULL(Hr22_30, 0) + ISNULL(Hr22_45, 0) + ISNULL(Hr22_60, 0) + 
							ISNULL(Hr23_15, 0) + ISNULL(Hr23_30, 0) + ISNULL(Hr23_45, 0) + ISNULL(Hr23_60, 0) + ISNULL(Hr24_15, 0) + ISNULL(Hr24_30, 0) + ISNULL(Hr24_45, 0) + ISNULL(Hr24_60, 0) + 
							ISNULL(Hr25_15, 0) + ISNULL(Hr25_30, 0) + ISNULL(Hr25_45, 0) + ISNULL(Hr25_60, 0)) / (@number_of_days * 24 * 4)   Hr  FROM mv90_data md
						INNER JOIN mv90_data_mins mdm ON md.meter_data_id = mdm.meter_data_id 
						AND mdm.prod_date BETWEEN @start_date AND @max_missing_date
						WHERE md.meter_id = @meter_id 
					) rs
				WHERE m.meter_id = @meter_id AND m.prod_date IS NULL
				
			END	
		END
		ELSE IF (@formula_option = 2)	-- Copy Last Available Data
		BEGIN
			--SELECT 'Copy Last Available Data'
			IF (@granularity = 982) -- Hourly
			BEGIN
				INSERT INTO mv90_data_hour(prod_date, meter_data_id, data_missing, Hr1, Hr2, Hr3, Hr4, Hr5, Hr6, Hr7, Hr8, Hr9, Hr10, Hr11, Hr12, Hr13, Hr14, Hr15, Hr16, Hr17, Hr18, Hr19, Hr20, Hr21, Hr22, Hr23, Hr24, Hr25)
				SELECT m.meter_date [prod_date], m.meter_data_id, 'y' data_missing, Hr1, Hr2, Hr3, Hr4, Hr5, Hr6, Hr7, Hr8, Hr9, Hr10, Hr11, Hr12, Hr13, Hr14, Hr15, Hr16, Hr17, Hr18, Hr19, Hr20, Hr21, Hr22, Hr23, Hr24, Hr25 FROM #missing_dates m
				INNER JOIN mv90_data md ON m.meter_id = md.meter_id
				INNER JOIN mv90_data_hour mdh ON md.meter_data_id = mdh.meter_data_id
				WHERE md.meter_id = @meter_id AND m.prod_date IS NULL
				AND m.copy_from = mdh.prod_date
			END
			ELSE IF (@granularity IN (987, 989)) -- 15 minutes / 30 Min
			BEGIN
				IF (@granularity = 987)
				BEGIN
					INSERT INTO mv90_data_mins(prod_date,meter_data_id,data_missing, Hr1_15, Hr1_30, Hr1_45, Hr1_60, Hr2_15, Hr2_30, Hr2_45, Hr2_60, Hr3_15, Hr3_30, Hr3_45, Hr3_60, Hr4_15, Hr4_30, Hr4_45, Hr4_60, Hr5_15, Hr5_30, Hr5_45
						, Hr5_60, Hr6_15, Hr6_30, Hr6_45, Hr6_60, Hr7_15, Hr7_30, Hr7_45, Hr7_60, Hr8_15, Hr8_30, Hr8_45, Hr8_60, Hr9_15, Hr9_30, Hr9_45, Hr9_60, Hr10_15, Hr10_30
						, Hr10_45, Hr10_60, Hr11_15, Hr11_30, Hr11_45, Hr11_60, Hr12_15, Hr12_30, Hr12_45, Hr12_60, Hr13_15, Hr13_30, Hr13_45, Hr13_60, Hr14_15, Hr14_30, Hr14_45
						, Hr14_60, Hr15_15, Hr15_30, Hr15_45, Hr15_60, Hr16_15, Hr16_30, Hr16_45, Hr16_60, Hr17_15, Hr17_30, Hr17_45, Hr17_60, Hr18_15, Hr18_30, Hr18_45, Hr18_60
						, Hr19_15, Hr19_30, Hr19_45, Hr19_60, Hr20_15, Hr20_30, Hr20_45, Hr20_60, Hr21_15, Hr21_30, Hr21_45, Hr21_60, Hr22_15, Hr22_30, Hr22_45, Hr22_60, Hr23_15
						, Hr23_30, Hr23_45, Hr23_60, Hr24_15, Hr24_30, Hr24_45, Hr24_60, Hr25_15, Hr25_30, Hr25_45, Hr25_60)
					
					SELECT m.meter_date [prod_date], m.meter_data_id, 'y' data_missing, Hr1_15, Hr1_30, Hr1_45, Hr1_60, Hr2_15, Hr2_30, Hr2_45, Hr2_60, Hr3_15, Hr3_30, Hr3_45, Hr3_60, Hr4_15, Hr4_30, Hr4_45, Hr4_60, Hr5_15, Hr5_30, Hr5_45, Hr5_60
						, Hr6_15, Hr6_30, Hr6_45, Hr6_60, Hr7_15, Hr7_30, Hr7_45, Hr7_60, Hr8_15, Hr8_30, Hr8_45, Hr8_60, Hr9_15, Hr9_30, Hr9_45, Hr9_60, Hr10_15, Hr10_30, Hr10_45, Hr10_60
						, Hr11_15, Hr11_30, Hr11_45, Hr11_60, Hr12_15, Hr12_30, Hr12_45, Hr12_60, Hr13_15, Hr13_30, Hr13_45, Hr13_60, Hr14_15, Hr14_30, Hr14_45, Hr14_60, Hr15_15, Hr15_30
						, Hr15_45, Hr15_60, Hr16_15, Hr16_30, Hr16_45, Hr16_60, Hr17_15, Hr17_30, Hr17_45, Hr17_60, Hr18_15, Hr18_30, Hr18_45, Hr18_60, Hr19_15, Hr19_30, Hr19_45, Hr19_60
						, Hr20_15, Hr20_30, Hr20_45, Hr20_60, Hr21_15, Hr21_30, Hr21_45, Hr21_60, Hr22_15, Hr22_30, Hr22_45, Hr22_60, Hr23_15, Hr23_30, Hr23_45, Hr23_60, Hr24_15
						, Hr24_30, Hr24_45, Hr24_60, Hr25_15, Hr25_30, Hr25_45, Hr25_60
					  FROM #missing_dates m
					INNER JOIN mv90_data md ON m.meter_id = md.meter_id
					INNER JOIN mv90_data_mins mdm ON md.meter_data_id = mdm.meter_data_id 
					AND m.copy_from = mdm.prod_date
					WHERE md.meter_id = @meter_id AND m.prod_date IS NULL
				END
				ELSE IF (@granularity = 989)
				BEGIN
					INSERT INTO mv90_data_mins(prod_date,meter_data_id,data_missing, Hr1_15, Hr1_30, Hr1_45, Hr1_60, Hr2_15, Hr2_30, Hr2_45, Hr2_60, Hr3_15, Hr3_30, Hr3_45, Hr3_60, Hr4_15, Hr4_30, Hr4_45, Hr4_60, Hr5_15, Hr5_30, Hr5_45
						, Hr5_60, Hr6_15, Hr6_30, Hr6_45, Hr6_60, Hr7_15, Hr7_30, Hr7_45, Hr7_60, Hr8_15, Hr8_30, Hr8_45, Hr8_60, Hr9_15, Hr9_30, Hr9_45, Hr9_60, Hr10_15, Hr10_30
						, Hr10_45, Hr10_60, Hr11_15, Hr11_30, Hr11_45, Hr11_60, Hr12_15, Hr12_30, Hr12_45, Hr12_60, Hr13_15, Hr13_30, Hr13_45, Hr13_60, Hr14_15, Hr14_30, Hr14_45
						, Hr14_60, Hr15_15, Hr15_30, Hr15_45, Hr15_60, Hr16_15, Hr16_30, Hr16_45, Hr16_60, Hr17_15, Hr17_30, Hr17_45, Hr17_60, Hr18_15, Hr18_30, Hr18_45, Hr18_60
						, Hr19_15, Hr19_30, Hr19_45, Hr19_60, Hr20_15, Hr20_30, Hr20_45, Hr20_60, Hr21_15, Hr21_30, Hr21_45, Hr21_60, Hr22_15, Hr22_30, Hr22_45, Hr22_60, Hr23_15
						, Hr23_30, Hr23_45, Hr23_60, Hr24_15, Hr24_30, Hr24_45, Hr24_60, Hr25_15, Hr25_30, Hr25_45, Hr25_60)
						
					SELECT m.meter_date [prod_date], m.meter_data_id, 'y' data_missing, Hr1_15, NULL Hr1_30, Hr1_45, NULL Hr1_60, Hr2_15, NULL Hr2_30, Hr2_45, NULL Hr2_60, Hr3_15, NULL Hr3_30, Hr3_45, NULL Hr3_60, Hr4_15, NULL Hr4_30, Hr4_45, NULL Hr4_60, Hr5_15, NULL Hr5_30, Hr5_45, NULL Hr5_60
						, Hr6_15, NULL Hr6_30, Hr6_45, NULL Hr6_60, Hr7_15, NULL Hr7_30, Hr7_45, NULL Hr7_60, Hr8_15, NULL Hr8_30, Hr8_45, NULL Hr8_60, Hr9_15, NULL Hr9_30, Hr9_45, NULL Hr9_60, Hr10_15, NULL Hr10_30, Hr10_45, NULL Hr10_60
						, Hr11_15, NULL Hr11_30, Hr11_45, NULL Hr11_60, Hr12_15, NULL Hr12_30, Hr12_45, NULL Hr12_60, Hr13_15, NULL Hr13_30, Hr13_45, NULL Hr13_60, Hr14_15, NULL Hr14_30, Hr14_45, NULL Hr14_60, Hr15_15, NULL Hr15_30
						, Hr15_45, NULL Hr15_60, Hr16_15, NULL Hr16_30, Hr16_45, NULL Hr16_60, Hr17_15, NULL Hr17_30, Hr17_45, NULL Hr17_60, Hr18_15, NULL Hr18_30, Hr18_45, NULL Hr18_60, Hr19_15, NULL Hr19_30, Hr19_45, NULL Hr19_60
						, Hr20_15, NULL Hr20_30, Hr20_45, NULL Hr20_60, Hr21_15, NULL Hr21_30, Hr21_45, NULL Hr21_60, Hr22_15, NULL Hr22_30, Hr22_45, NULL Hr22_60, Hr23_15, NULL Hr23_30, Hr23_45, NULL Hr23_60, Hr24_15
						, NULL Hr24_30, Hr24_45, NULL Hr24_60, NULL Hr25_15, NULL Hr25_30, NULL Hr25_45, NULL Hr25_60
					FROM #missing_dates m
						INNER JOIN mv90_data md 
							ON m.meter_id = md.meter_id
						INNER JOIN mv90_data_mins mdm 
							ON md.meter_data_id = mdm.meter_data_id 
							AND m.copy_from = mdm.prod_date
					WHERE md.meter_id = @meter_id AND m.prod_date IS NULL
				END
			
				-- Delete From Hourly for that meter and missing production date if exists
				DELETE mdh
				FROM   mv90_data_hour mdh
						INNER JOIN #missing_dates md
							ON  mdh.meter_data_id = md.meter_data_id
							AND mdh.prod_date = md.meter_date
				WHERE  md.prod_date IS NULL
			
				-- Insert into mv90_data_hour from min data
				INSERT INTO mv90_data_hour(prod_date, meter_data_id, data_missing, Hr1, Hr2, Hr3, Hr4, Hr5, Hr6, Hr7, Hr8, Hr9, Hr10, Hr11, Hr12, Hr13, Hr14, Hr15, Hr16, Hr17, Hr18, Hr19, Hr20, Hr21, Hr22, Hr23, Hr24, Hr25)
				SELECT m.meter_date [prod_date], m.meter_data_id, 'y' data_missing, 
						SUM(ISNULL(Hr1_15,0) +  ISNULL(Hr1_30,0) +  ISNULL(Hr1_45,0) + ISNULL(Hr1_60,0)) Hr1,
						SUM(ISNULL(Hr2_15,0) +  ISNULL(Hr2_30,0) +  ISNULL(Hr2_45,0) + ISNULL(Hr2_60,0)) Hr2,
						SUM(ISNULL(Hr3_15,0) +  ISNULL(Hr3_30,0) +  ISNULL(Hr3_45,0) + ISNULL(Hr3_60,0)) Hr3,
						SUM(ISNULL(Hr4_15,0) +  ISNULL(Hr4_30,0) +  ISNULL(Hr4_45,0) + ISNULL(Hr4_60,0)) Hr4,
						SUM(ISNULL(Hr5_15,0) +  ISNULL(Hr5_30,0) +  ISNULL(Hr5_45,0) + ISNULL(Hr5_60,0)) Hr5,
						SUM(ISNULL(Hr6_15,0) +  ISNULL(Hr6_30,0) +  ISNULL(Hr6_45,0) + ISNULL(Hr6_60,0)) Hr6,
						SUM(ISNULL(Hr7_15,0) +  ISNULL(Hr7_30,0) +  ISNULL(Hr7_45,0) + ISNULL(Hr7_60,0)) Hr7,
						SUM(ISNULL(Hr8_15,0) +  ISNULL(Hr8_30,0) +  ISNULL(Hr8_45,0) + ISNULL(Hr8_60,0)) Hr8,
						SUM(ISNULL(Hr9_15,0) +  ISNULL(Hr9_30,0) +  ISNULL(Hr9_45,0) + ISNULL(Hr9_60,0)) Hr9,
						SUM(ISNULL(Hr10_15,0) +  ISNULL(Hr10_30,0) +  ISNULL(Hr10_45,0) + ISNULL(Hr10_60,0)) Hr10,
						SUM(ISNULL(Hr11_15,0) +  ISNULL(Hr11_30,0) +  ISNULL(Hr11_45,0) + ISNULL(Hr11_60,0)) Hr11,
						SUM(ISNULL(Hr12_15,0) +  ISNULL(Hr12_30,0) +  ISNULL(Hr12_45,0) + ISNULL(Hr12_60,0)) Hr12,
						SUM(ISNULL(Hr13_15,0) +  ISNULL(Hr13_30,0) +  ISNULL(Hr13_45,0) + ISNULL(Hr13_60,0)) Hr13,
						SUM(ISNULL(Hr14_15,0) +  ISNULL(Hr14_30,0) +  ISNULL(Hr14_45,0) + ISNULL(Hr14_60,0)) Hr14,
						SUM(ISNULL(Hr15_15,0) +  ISNULL(Hr15_30,0) +  ISNULL(Hr15_45,0) + ISNULL(Hr15_60,0)) Hr15,
						SUM(ISNULL(Hr16_15,0) +  ISNULL(Hr16_30,0) +  ISNULL(Hr16_45,0) + ISNULL(Hr16_60,0)) Hr16,
						SUM(ISNULL(Hr17_15,0) +  ISNULL(Hr17_30,0) +  ISNULL(Hr17_45,0) + ISNULL(Hr17_60,0)) Hr17,
						SUM(ISNULL(Hr18_15,0) +  ISNULL(Hr18_30,0) +  ISNULL(Hr18_45,0) + ISNULL(Hr18_60,0)) Hr18,
						SUM(ISNULL(Hr19_15,0) +  ISNULL(Hr19_30,0) +  ISNULL(Hr19_45,0) + ISNULL(Hr19_60,0)) Hr19,
						SUM(ISNULL(Hr20_15,0) +  ISNULL(Hr20_30,0) +  ISNULL(Hr20_45,0) + ISNULL(Hr20_60,0)) Hr20,
						SUM(ISNULL(Hr21_15,0) +  ISNULL(Hr21_30,0) +  ISNULL(Hr21_45,0) + ISNULL(Hr21_60,0)) Hr21,
						SUM(ISNULL(Hr22_15,0) +  ISNULL(Hr22_30,0) +  ISNULL(Hr22_45,0) + ISNULL(Hr22_60,0)) Hr22,
						SUM(ISNULL(Hr23_15,0) +  ISNULL(Hr23_30,0) +  ISNULL(Hr23_45,0) + ISNULL(Hr23_60,0)) Hr23,
						SUM(ISNULL(Hr24_15,0) +  ISNULL(Hr24_30,0) +  ISNULL(Hr24_45,0) + ISNULL(Hr24_60,0)) Hr24,
						SUM(ISNULL(Hr25_15,0) +  ISNULL(Hr25_30,0) +  ISNULL(Hr25_45,0) + ISNULL(Hr25_60,0)) Hr25
					FROM #missing_dates m
				INNER JOIN mv90_data md ON m.meter_id = md.meter_id
				INNER JOIN mv90_data_mins mdm ON md.meter_data_id = mdm.meter_data_id 
				AND m.copy_from = mdm.prod_date
				WHERE md.meter_id = @meter_id AND m.prod_date IS NULL
				GROUP BY m.meter_date, m.meter_data_id
			END
		END
		
		/*
		SELECT * FROM mv90_data md INNER JOIN( 
			SELECT mdh.meter_data_id, SUM(ISNULL(Hr1,0) + ISNULL(Hr2,0)+ ISNULL(Hr3,0)+ ISNULL(Hr4,0)+ ISNULL(Hr5,0)+ ISNULL(Hr6,0)+ ISNULL(Hr7,0)+ ISNULL(Hr8,0)+ ISNULL(Hr9,0)+ ISNULL(Hr10,0)+ ISNULL(Hr11,0)+ ISNULL(Hr12,0)+ ISNULL(Hr13,0)+ ISNULL(Hr14,0)+ ISNULL(Hr15,0)+ ISNULL(Hr16,0)+ ISNULL(Hr17,0)+ ISNULL(Hr18,0)+ ISNULL(Hr19,0)+ ISNULL(Hr20,0)+ ISNULL(Hr21,0)+ ISNULL(Hr22,0)+ ISNULL(Hr23,0)+ ISNULL(Hr24,0)+ ISNULL(Hr25,0)) Volume_Sum
				FROM mv90_data_hour mdh
			INNER JOIN #missing_dates m 
				ON mdh.meter_data_id = m.meter_data_id
			WHERE m.prod_date IS NULL 			
			GROUP BY mdh.meter_data_id 
			) ts
			ON ts.meter_data_id = md.meter_data_id
			WHERE md.meter_id = @meter_id
		*/
		
		UPDATE md
			SET md.volume = ts.Volume_Sum 
			FROM mv90_data md INNER JOIN( 
					SELECT mdh.meter_data_id, SUM(ISNULL(Hr1,0) + ISNULL(Hr2,0)+ ISNULL(Hr3,0)+ ISNULL(Hr4,0)+ ISNULL(Hr5,0)+ ISNULL(Hr6,0)+ ISNULL(Hr7,0)+ ISNULL(Hr8,0)+ ISNULL(Hr9,0)+ ISNULL(Hr10,0)+ ISNULL(Hr11,0)+ ISNULL(Hr12,0)+ ISNULL(Hr13,0)+ ISNULL(Hr14,0)+ ISNULL(Hr15,0)+ ISNULL(Hr16,0)+ ISNULL(Hr17,0)+ ISNULL(Hr18,0)+ ISNULL(Hr19,0)+ ISNULL(Hr20,0)+ ISNULL(Hr21,0)+ ISNULL(Hr22,0)+ ISNULL(Hr23,0)+ ISNULL(Hr24,0)+ ISNULL(Hr25,0)) Volume_Sum
						FROM mv90_data_hour mdh
					INNER JOIN #missing_dates m 
						ON mdh.meter_data_id = m.meter_data_id
					WHERE mdh.prod_date = m.meter_date  			
					GROUP BY mdh.meter_data_id 
				) ts
			ON ts.meter_data_id = md.meter_data_id
			WHERE md.meter_id = @meter_id
			
							
		FETCH FROM missing_meter_cursor INTO @meter_id, @formula_option, @number_of_days, @granularity
	END

	CLOSE missing_meter_cursor
	DEALLOCATE missing_meter_cursor
END
GO