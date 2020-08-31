IF OBJECT_ID('spa_generate_hour_block_term') IS NOT NULL
	DROP PROC [dbo].[spa_generate_hour_block_term]
GO

CREATE PROCEDURE dbo.spa_generate_hour_block_term 
	@block_define_id INT = NULL, 
	@year_from INT = NULL, 
	@year_to INT = NULL,
	@process_id VARCHAR(50) = NULL,
	@user_login_id VARCHAR(40) = NULL
AS

/*
--test case start
--exec spa_generate_hour_block_term null,2000,2030
DECLARE @block_define_id INT, @year_from INT, @year_to INT ,@process_id varchar(50),@user_login_id VARCHAR(40)
SELECT @block_define_id =null, @year_from=2000, @year_to=2030,@user_login_id='farrms_admin'
DROP TABLE #hour_block_term
DROP TABLE #block_days
--select * from hour_block_term where term_start='2011-10-01' order by block_define_id,block_type,term_date
--SELECT * FROM holiday_block
--SELECT * FROM  hour_block_term
--SELECT * FROM #hour_block_term WHERE block_define_id=291949 AND block_type=12001 AND term_date='2012-05-26'
--SELECT * FROM #hour_block_term WHERE block_define_id=291949 AND block_type=12001 AND term_date='2012-05-26'


--*/

DECLARE  @from_dt DATETIME, @to_dt DATETIME
IF @year_from IS NOT NULL AND @year_to IS NOT NULL
BEGIN
	SELECT @from_dt = CAST(@year_from AS VARCHAR) + '-01-01' , 
			@to_dt = CAST(CAST(@year_to+1 AS VARCHAR) + '-01-01' AS DATETIME) - 1
END
ELSE
BEGIN
	SELECT @from_dt = MIN([term_start]),
			@to_dt = MAX([term_start]) 
	FROM hour_block_term
END

CREATE TABLE #block_days (dst_group_value_id int,block_type INT, day_date DATETIME, weekdays TINYINT, no_of_days_in_month TINYINT)

INSERT INTO #block_days (dst_group_value_id,block_type,day_date,weekdays ,no_of_days_in_month)
SELECT bt.value_id, 12000 block_type,td.day_date,td.weekdays ,td.no_of_days_in_month 
FROM (SELECT value_id  FROM static_data_value sdv  WHERE sdv.[type_id] = 102200
) bt
CROSS APPLY dbo.FNAGetDayWiseDate(@from_dt, @to_dt) td


CREATE INDEX indx_block_days_1 ON #block_days (dst_group_value_id,block_type,weekdays)
CREATE INDEX indx_block_days_2 ON #block_days (day_date)

SELECT hb.block_value_id block_define_id, 12000 block_type, td.day_date term_date, hg.hol_date,
		ISNULL(CASE WHEN dst.[hour] = 1  AND  dst.insert_delete = 'd' AND ISNULL(hb.dst_applies,'n') = 'y' THEN 0 ELSE CASE WHEN hg.hol_date IS NULL THEN hb.hr1 ELSE  hol_b.hr1 END END * hb1.mult, 1) AS Hr1,
		ISNULL(CASE WHEN dst.[hour] = 2  AND  dst.insert_delete = 'd' AND ISNULL(hb.dst_applies,'n') = 'y' THEN 0 ELSE CASE WHEN hg.hol_date IS NULL THEN hb.hr2 ELSE  hol_b.hr2 END END * hb1.mult, 1) AS Hr2,
		ISNULL(CASE WHEN dst.[hour] = 3  AND  dst.insert_delete = 'd' AND ISNULL(hb.dst_applies,'n') = 'y' THEN 0 ELSE CASE WHEN hg.hol_date IS NULL THEN hb.hr3 ELSE  hol_b.hr3 END END * hb1.mult, 1) AS Hr3,
		ISNULL(CASE WHEN dst.[hour] = 4  AND  dst.insert_delete = 'd' AND ISNULL(hb.dst_applies,'n') = 'y' THEN 0 ELSE CASE WHEN hg.hol_date IS NULL THEN hb.hr4 ELSE  hol_b.hr4 END END * hb1.mult, 1) AS Hr4,
		ISNULL(CASE WHEN dst.[hour] = 5  AND  dst.insert_delete = 'd' AND ISNULL(hb.dst_applies,'n') = 'y' THEN 0 ELSE CASE WHEN hg.hol_date IS NULL THEN hb.hr5 ELSE  hol_b.hr5 END END * hb1.mult, 1) AS Hr5,
		ISNULL(CASE WHEN dst.[hour] = 6  AND  dst.insert_delete = 'd' AND ISNULL(hb.dst_applies,'n') = 'y' THEN 0 ELSE CASE WHEN hg.hol_date IS NULL THEN hb.hr6 ELSE  hol_b.hr6 END END * hb1.mult, 1) AS Hr6,
		ISNULL(CASE WHEN dst.[hour] = 7  AND  dst.insert_delete = 'd' AND ISNULL(hb.dst_applies,'n') = 'y' THEN 0 ELSE CASE WHEN hg.hol_date IS NULL THEN hb.hr7 ELSE  hol_b.hr7 END END * hb1.mult, 1) AS Hr7,
		ISNULL(CASE WHEN dst.[hour] = 8  AND  dst.insert_delete = 'd' AND ISNULL(hb.dst_applies,'n') = 'y' THEN 0 ELSE CASE WHEN hg.hol_date IS NULL THEN hb.hr8 ELSE  hol_b.hr8 END END * hb1.mult, 1) AS Hr8,
		ISNULL(CASE WHEN dst.[hour] = 9  AND  dst.insert_delete = 'd' AND ISNULL(hb.dst_applies,'n') = 'y' THEN 0 ELSE CASE WHEN hg.hol_date IS NULL THEN hb.hr9 ELSE  hol_b.hr9 END END * hb1.mult, 1) AS Hr9,
		ISNULL(CASE WHEN dst.[hour] = 10  AND dst.insert_delete = 'd' AND ISNULL(hb.dst_applies,'n') = 'y' THEN 0 ELSE CASE WHEN hg.hol_date IS NULL THEN hb.hr10 ELSE  hol_b.hr10 END END * hb1.mult, 1) AS Hr10,
		ISNULL(CASE WHEN dst.[hour] = 11  AND dst.insert_delete = 'd' AND ISNULL(hb.dst_applies,'n') = 'y' THEN 0 ELSE CASE WHEN hg.hol_date IS NULL THEN hb.hr11 ELSE  hol_b.hr11 END END * hb1.mult, 1) AS Hr11,
		ISNULL(CASE WHEN dst.[hour] = 12  AND dst.insert_delete = 'd' AND ISNULL(hb.dst_applies,'n') = 'y' THEN 0 ELSE CASE WHEN hg.hol_date IS NULL THEN hb.hr12 ELSE  hol_b.hr12 END END * hb1.mult, 1) AS Hr12,
		ISNULL(CASE WHEN dst.[hour] = 13  AND dst.insert_delete = 'd' AND ISNULL(hb.dst_applies,'n') = 'y' THEN 0 ELSE CASE WHEN hg.hol_date IS NULL THEN hb.hr13 ELSE  hol_b.hr13 END END * hb1.mult, 1) AS Hr13,
		ISNULL(CASE WHEN dst.[hour] = 14  AND dst.insert_delete = 'd' AND ISNULL(hb.dst_applies,'n') = 'y' THEN 0 ELSE CASE WHEN hg.hol_date IS NULL THEN hb.hr14 ELSE  hol_b.hr14 END END * hb1.mult, 1) AS Hr14,
		ISNULL(CASE WHEN dst.[hour] = 15  AND dst.insert_delete = 'd' AND ISNULL(hb.dst_applies,'n') = 'y' THEN 0 ELSE CASE WHEN hg.hol_date IS NULL THEN hb.hr15 ELSE  hol_b.hr15 END END * hb1.mult, 1) AS Hr15,
		ISNULL(CASE WHEN dst.[hour] = 16  AND dst.insert_delete = 'd' AND ISNULL(hb.dst_applies,'n') = 'y' THEN 0 ELSE CASE WHEN hg.hol_date IS NULL THEN hb.hr16 ELSE  hol_b.hr16 END END * hb1.mult, 1) AS Hr16,
		ISNULL(CASE WHEN dst.[hour] = 17  AND dst.insert_delete = 'd' AND ISNULL(hb.dst_applies,'n') = 'y' THEN 0 ELSE CASE WHEN hg.hol_date IS NULL THEN hb.hr17 ELSE  hol_b.hr17 END END * hb1.mult, 1) AS Hr17,
		ISNULL(CASE WHEN dst.[hour] = 18  AND dst.insert_delete = 'd' AND ISNULL(hb.dst_applies,'n') = 'y' THEN 0 ELSE CASE WHEN hg.hol_date IS NULL THEN hb.hr18 ELSE  hol_b.hr18 END END * hb1.mult, 1) AS Hr18,
		ISNULL(CASE WHEN dst.[hour] = 19  AND dst.insert_delete = 'd' AND ISNULL(hb.dst_applies,'n') = 'y' THEN 0 ELSE CASE WHEN hg.hol_date IS NULL THEN hb.hr19 ELSE  hol_b.hr19 END END * hb1.mult, 1) AS Hr19,
		ISNULL(CASE WHEN dst.[hour] = 20  AND dst.insert_delete = 'd' AND ISNULL(hb.dst_applies,'n') = 'y' THEN 0 ELSE CASE WHEN hg.hol_date IS NULL THEN hb.hr20 ELSE  hol_b.hr20 END END * hb1.mult, 1) AS Hr20,
		ISNULL(CASE WHEN dst.[hour] = 21  AND dst.insert_delete = 'd' AND ISNULL(hb.dst_applies,'n') = 'y' THEN 0 ELSE CASE WHEN hg.hol_date IS NULL THEN hb.hr21 ELSE  hol_b.hr21 END END * hb1.mult, 1) AS Hr21,
		ISNULL(CASE WHEN dst.[hour] = 22  AND dst.insert_delete = 'd' AND ISNULL(hb.dst_applies,'n') = 'y' THEN 0 ELSE CASE WHEN hg.hol_date IS NULL THEN hb.hr22 ELSE  hol_b.hr22 END END * hb1.mult, 1) AS Hr22,
		ISNULL(CASE WHEN dst.[hour] = 23  AND dst.insert_delete = 'd' AND ISNULL(hb.dst_applies,'n') = 'y' THEN 0 ELSE CASE WHEN hg.hol_date IS NULL THEN hb.hr23 ELSE  hol_b.hr23 END END * hb1.mult, 1) AS Hr23,
		ISNULL(CASE WHEN dst.[hour] = 24  AND dst.insert_delete = 'd' AND ISNULL(hb.dst_applies,'n') = 'y' THEN 0 ELSE CASE WHEN hg.hol_date IS NULL THEN hb.hr24 ELSE  hol_b.hr24 END END * hb1.mult, 1) AS Hr24,
		----excludiding dst apply
		CAST(ISNULL(CASE WHEN hg.hol_date IS NULL THEN hb.hr1 ELSE  hol_b.hr1 END * hb1.mult, 1) AS VARCHAR) + 
		CAST(ISNULL(CASE WHEN hg.hol_date IS NULL THEN hb.hr2 ELSE  hol_b.hr2 END * hb1.mult, 1) AS VARCHAR) +
		CAST(ISNULL(CASE WHEN hg.hol_date IS NULL THEN hb.hr3 ELSE  hol_b.hr3 END * hb1.mult, 1) AS VARCHAR) +
		CAST(ISNULL(CASE WHEN hg.hol_date IS NULL THEN hb.hr4 ELSE  hol_b.hr4 END * hb1.mult, 1) AS VARCHAR) +
		CAST(ISNULL(CASE WHEN hg.hol_date IS NULL THEN hb.hr5 ELSE  hol_b.hr5 END * hb1.mult, 1) AS VARCHAR) +
		CAST(ISNULL(CASE WHEN hg.hol_date IS NULL THEN hb.hr6 ELSE  hol_b.hr6 END * hb1.mult, 1) AS VARCHAR) +
		CAST(ISNULL(CASE WHEN hg.hol_date IS NULL THEN hb.hr7 ELSE  hol_b.hr7 END * hb1.mult, 1) AS VARCHAR) +
		CAST(ISNULL(CASE WHEN hg.hol_date IS NULL THEN hb.hr8 ELSE  hol_b.hr8 END * hb1.mult, 1) AS VARCHAR) +
		CAST(ISNULL(CASE WHEN hg.hol_date IS NULL THEN hb.hr9 ELSE  hol_b.hr9 END * hb1.mult, 1) AS VARCHAR) +
		CAST(ISNULL(CASE WHEN hg.hol_date IS NULL THEN hb.hr10 ELSE  hol_b.hr10 END	* hb1.mult, 1) AS VARCHAR) +
		CAST(ISNULL(CASE WHEN hg.hol_date IS NULL THEN hb.hr11 ELSE  hol_b.hr11 END	* hb1.mult, 1) AS VARCHAR) +
		CAST(ISNULL(CASE WHEN hg.hol_date IS NULL THEN hb.hr12 ELSE  hol_b.hr12 END	* hb1.mult, 1) AS VARCHAR) +
		CAST(ISNULL(CASE WHEN hg.hol_date IS NULL THEN hb.hr13 ELSE  hol_b.hr13 END	* hb1.mult, 1) AS VARCHAR) +
		CAST(ISNULL(CASE WHEN hg.hol_date IS NULL THEN hb.hr14 ELSE  hol_b.hr14 END	* hb1.mult, 1) AS VARCHAR) +
		CAST(ISNULL(CASE WHEN hg.hol_date IS NULL THEN hb.hr15 ELSE  hol_b.hr15 END	* hb1.mult, 1) AS VARCHAR) +
		CAST(ISNULL(CASE WHEN hg.hol_date IS NULL THEN hb.hr16 ELSE  hol_b.hr16 END	* hb1.mult, 1) AS VARCHAR) +
		CAST(ISNULL(CASE WHEN hg.hol_date IS NULL THEN hb.hr17 ELSE  hol_b.hr17 END	* hb1.mult, 1) AS VARCHAR) +
		CAST(ISNULL(CASE WHEN hg.hol_date IS NULL THEN hb.hr18 ELSE  hol_b.hr18 END	* hb1.mult, 1) AS VARCHAR) +
		CAST(ISNULL(CASE WHEN hg.hol_date IS NULL THEN hb.hr19 ELSE  hol_b.hr19 END	* hb1.mult, 1) AS VARCHAR) +
		CAST(ISNULL(CASE WHEN hg.hol_date IS NULL THEN hb.hr20 ELSE  hol_b.hr20 END	* hb1.mult, 1) AS VARCHAR) +
		CAST(ISNULL(CASE WHEN hg.hol_date IS NULL THEN hb.hr21 ELSE  hol_b.hr21 END	* hb1.mult, 1) AS VARCHAR) +
		CAST(ISNULL(CASE WHEN hg.hol_date IS NULL THEN hb.hr22 ELSE  hol_b.hr22 END	* hb1.mult, 1) AS VARCHAR) +
		CAST(ISNULL(CASE WHEN hg.hol_date IS NULL THEN hb.hr23 ELSE  hol_b.hr23 END	* hb1.mult, 1) AS VARCHAR) +
		CAST(ISNULL(CASE WHEN hg.hol_date IS NULL THEN hb.hr24 ELSE  hol_b.hr24 END	* hb1.mult, 1) AS VARCHAR) org_hr_value,
		CONVERT(VARCHAR(8), td.day_date, 120) + '01' [term_start],hb.[dst_applies], 		
		CASE WHEN dst.insert_delete = 'i' AND ISNULL(hb.dst_applies,'n') = 'y' THEN  ISNULL(dst.[hour],0) WHEN dst.insert_delete = 'd' AND ISNULL(hb.dst_applies,'n') = 'y' THEN -1 * ISNULL(dst.[hour],0) ELSE 0 END  add_dst_hour,td.dst_group_value_id
INTO #hour_block_term 
FROM #block_days td
INNER JOIN hourly_block hb ON hb.week_day = td.weekdays  --AND  hb.onpeak_offpeak = 'p' 
LEFT JOIN mv90_DST dst ON dst.[date] = td.day_date  and dst.dst_group_value_id=td.dst_group_value_id
LEFT JOIN holiday_group hg ON hg.hol_group_value_Id = hb.holiday_value_id AND (td.day_date = hg.hol_date) 
LEFT JOIN holiday_block hol_b ON hol_b.block_value_id = hb.block_value_id
OUTER APPLY(SELECT CASE WHEN ISNULL(from_month,1) < ISNULL(to_month,12) THEN
				CASE WHEN MONTH(td.day_date) BETWEEN ISNULL(from_month,1) AND ISNULL(to_month,12) THEN 1 ELSE 0 END
			ELSE
				CASE WHEN MONTH(td.day_date) <= ISNULL(to_month,12) THEN 1 WHEN  MONTH(td.day_date) >= ISNULL(from_month,1) THEN 1 ELSE 0 END
			END mult FROM hourly_block WHERE block_value_id = hb.block_value_id AND week_day= hb.week_day) hb1
	--AND hol_b.onpeak_offpeak = CASE WHEN (td.block_type) = 12000 THEN 'p'   WHEN (td.block_type) = 12001 THEN 'o' END
WHERE @block_define_id IS NULL OR hb.block_value_id = @block_define_id

--order by block_type,block_value_id,td.day_date
CREATE INDEX indx_tmp_hour_block_term  ON #hour_block_term (dst_group_value_id,term_date,block_type,block_define_id)

DELETE p 
FROM hour_block_term p INNER JOIN #hour_block_term t ON t.term_date = p.term_date 
	AND t.block_type = p.block_type AND p.block_define_id = t.block_define_id

INSERT INTO  hour_block_term ([block_define_id], [block_type], [term_date], [hol_date]
								, [Hr1], [Hr2], [Hr3], [Hr4], [Hr5], [Hr6], [Hr7], [Hr8], [Hr9], [Hr10]
								, [Hr11], [Hr12], [Hr13], [Hr14], [Hr15], [Hr16], [Hr17], [Hr18], [Hr19], [Hr20]
								, [Hr21], [Hr22], [Hr23], [Hr24], [term_start], [volume_mult], add_dst_hour, [dst_applies], org_hr_value,dst_group_value_id)
SELECT	block_define_id, [block_type], [term_date], [hol_date], [Hr1], [Hr2], [Hr3], [Hr4], [Hr5], [Hr6]
		, [Hr7], [Hr8], [Hr9], [Hr10], [Hr11], [Hr12], [Hr13], [Hr14], [Hr15], [Hr16], [Hr17]
		, [Hr18], [Hr19], [Hr20], [Hr21], [Hr22], [Hr23], [Hr24], [term_start]
		, ([Hr1] + [Hr2] + [Hr3] + [Hr4] + [Hr5] + [Hr6] + [Hr7] + [Hr8] + [Hr9] + [Hr10] + [Hr11] + [Hr12] + [Hr13] + [Hr14] + [Hr15]
		+ [Hr16] + [Hr17] + [Hr18] + [Hr19] + [Hr20] + [Hr21] + [Hr22] + [Hr23] + [Hr24])
		+ CASE WHEN SUBSTRING(CAST([Hr1] AS VARCHAR) + CAST([Hr2] AS VARCHAR) + CAST([Hr3] AS VARCHAR) + CAST([Hr4] AS VARCHAR)
							+ CAST([Hr5] AS VARCHAR)
							+ CAST([Hr6] AS VARCHAR) + CAST([Hr7] AS VARCHAR) + CAST([Hr8] AS VARCHAR) + CAST([Hr9] AS VARCHAR)
							+ CAST([Hr10] AS VARCHAR) + CAST([Hr11] AS VARCHAR) + CAST([Hr12] AS VARCHAR) + CAST([Hr13] AS VARCHAR)
							+ CAST([Hr14] AS VARCHAR) + CAST([Hr15] AS VARCHAR) + CAST([Hr16] AS VARCHAR) + CAST([Hr17] AS VARCHAR)
							+ CAST([Hr18] AS VARCHAR) + CAST([Hr19] AS VARCHAR) + CAST([Hr20] AS VARCHAR) + CAST([Hr21] AS VARCHAR) 
							+ CAST([Hr22] AS VARCHAR) + CAST([Hr23] AS VARCHAR) + CAST([Hr24] AS VARCHAR)
							, ABS(add_dst_hour),1) = '1' THEN 1 ELSE 0 
		  END [volume_mult]
		 , CASE WHEN add_dst_hour > 0 THEN CASE WHEN SUBSTRING(CAST([Hr1] AS VARCHAR) + CAST([Hr2] AS VARCHAR) + CAST([Hr3] AS VARCHAR)
																+ CAST([Hr4] AS VARCHAR) + CAST([Hr5] AS VARCHAR) + CAST([Hr6] AS VARCHAR)
																+ CAST([Hr7] AS VARCHAR) + CAST([Hr8] AS VARCHAR) + CAST([Hr9] AS VARCHAR)
																+ CAST([Hr10] AS VARCHAR) + CAST([Hr11] AS VARCHAR) + CAST([Hr12] AS VARCHAR)
																+ CAST([Hr13] AS VARCHAR) + CAST([Hr14] AS VARCHAR) + CAST([Hr15] AS VARCHAR)
																+ CAST([Hr16] AS VARCHAR) + CAST([Hr17] AS VARCHAR) + CAST([Hr18] AS VARCHAR)
																+ CAST([Hr19] AS VARCHAR) + CAST([Hr20] AS VARCHAR)+ CAST([Hr21] AS VARCHAR)
																+ CAST([Hr22] AS VARCHAR) + CAST([Hr23] AS VARCHAR)+ CAST([Hr24] AS VARCHAR)
																, add_dst_hour, 1) = '1' THEN add_dst_hour ELSE 0 END
			ELSE add_dst_hour END add_dst_hour
		, [dst_applies]
		, SUBSTRING(org_hr_value, ABS(add_dst_hour), 1) org_hr_value,dst_group_value_id
FROM #hour_block_term -- WHERE term_date='2011-03-27'

IF ISNULL(@process_id, '') <> ''
BEGIN
	DECLARE @sql VARCHAR(MAX),@job_name VARCHAR(1000)
	
	SET @user_login_id = ISNULL(@user_login_id,dbo.fnadbuser())
	SET @sql = 'spa_update_deal_total_volume NULL,''' + CAST(@process_id AS VARCHAR(50)) + ''''
	SET @job_name = 'update_total_volume_block_define_' + @process_id 
	
	EXEC spa_run_sp_as_job @job_name, @sql, 'update_total_volume', @user_login_id 
END