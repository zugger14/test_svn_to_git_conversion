
/****** Object:  StoredProcedure [dbo].[spa_import_deal_hourly_data]    Script Date: 12/11/2010 15:34:51 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_import_deal_hourly_data]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_import_deal_hourly_data]
GO
-- ===================================================================
-- Author:		bbajracharya@pioneersolutionsglobal.us
-- Create date: 2010-11-26
-- Description:	Imports hourly data of deal from a staging table. 
-- ===================================================================
CREATE PROCEDURE [dbo].[spa_import_deal_hourly_data]
	@temp_table_name	VARCHAR(100),  
	@job_name			VARCHAR(100),  
	@process_id			VARCHAR(100),
	@file_name			VARCHAR(100),
	@table_id			INT,
	@user_login_id		VARCHAR(50),
	@start_ts			DATETIME = NULL
AS

/*****************TEST DATA START******************************/

--DECLARE @temp_table_name VARCHAR(128)
--DECLARE @user_login_id VARCHAR(50)
--DECLARE @process_id VARCHAR(50)
--DECLARE @job_name VARCHAR(100)
--DECLARE @file_name VARCHAR(100)
--DECLARE @start_ts DATETIME
--DECLARE @table_id INT

--SET @temp_table_name = 'adiha_process.dbo.deal_detail_hour_csv_farrms_admin_0637FD6D_9293_4F19_B8E7_9F85BC7DA55D'
--SET @user_login_id = dbo.FNADBUser()
--SET @process_id = dbo.FNAGetNewID()
--SET @job_name = 'importdata_deal_detail_hour_' + @process_id
--SET @file_name = 'NewFormat_TestLocation'
--SET @table_id = 4036

--IF OBJECT_ID('tempdb..#temp_deal_detail_hour') IS NOT NULL
--	DROP TABLE #temp_deal_detail_hour
--IF OBJECT_ID('tempdb..#tmp_data_count') IS NOT NULL
--	DROP TABLE #tmp_data_count
--IF OBJECT_ID('tempdb..#tmp_missing_ean_no') IS NOT NULL
--	DROP TABLE #tmp_missing_ean_no
--IF OBJECT_ID('tempdb..#tmp_import_profiles') IS NOT NULL
--	DROP TABLE #tmp_import_profiles
--IF OBJECT_ID('tempdb..#tmp_location_profile') IS NOT NULL
--	DROP TABLE #tmp_location_profile


--/*****************TEST DATA END******************************/

SET NOCOUNT ON;

DECLARE @sql					VARCHAR(8000)
DECLARE @url					VARCHAR(5000)
DECLARE @desc					VARCHAR(1000)
DECLARE @error_code				CHAR(1)
DECLARE @total_count			INT
--DECLARE @start_ts				DATETIME
DECLARE @elapsed_sec			FLOAT
DECLARE @profile_id				INT
DECLARE @DEAL_DETAIL_HOUR_LRS	INT
DECLARE @DEAL_DETAIL_HOUR_CSV	INT

SET @DEAL_DETAIL_HOUR_LRS = 4035
SET @DEAL_DETAIL_HOUR_CSV = 4036

IF @start_ts IS NULL
	SET @start_ts = GETDATE()

CREATE TABLE #tmp_data_count(total_rows INT)
CREATE TABLE #tmp_missing_ean_no (ean_no VARCHAR(100) COLLATE DATABASE_DEFAULT)
CREATE TABLE #tmp_import_profiles (profile_id INT)


EXEC('INSERT INTO #tmp_data_count(total_rows) SELECT COUNT(*) FROM ' + @temp_table_name)
SELECT @total_count = total_rows FROM #tmp_data_count 

IF OBJECT_ID('tempdb..#temp_deal_detail_hour') IS NOT NULL
	DROP TABLE #temp_deal_detail_hour

BEGIN TRY
	IF @total_count = 0
	BEGIN
		SET @error_code = 'e'
		INSERT INTO source_system_data_import_status(process_id, code, module, source, [type], [description], recommendation) 
		VALUES (@process_id, 'Error', 'Import Deal Hourly Data', @file_name, 'Error', 'Staging table is empty.', 'Please import correct deal hourly data file.')
	END
	ELSE
	BEGIN
		BEGIN TRAN
		
		IF @table_id = @DEAL_DETAIL_HOUR_LRS
		BEGIN
			DECLARE @EAN_no VARCHAR(50), @prof_id INT
			--filename without extension is EAN no, remove extension if available. Handle multiple occurence of dot(.) as well.
			SET @EAN_no = LTRIM(RTRIM(LEFT(@file_name, CASE WHEN CHARINDEX('.', @file_name) > 0 THEN dbo.FNALastCharIndex('.', @file_name) - 1 ELSE DATALENGTH(@file_name) END)))	

			--get missing ean nos
			INSERT INTO #tmp_missing_ean_no (ean_no)
			SELECT @EAN_no FROM forecast_profile fp WHERE NOT EXISTS (SELECT external_id FROM forecast_profile WHERE external_id = @EAN_no)
			
			SELECT @profile_id = profile_id FROM forecast_profile fp WHERE fp.external_id = @EAN_no
			
			IF NOT EXISTS(SELECT 1 FROM #tmp_missing_ean_no)
			BEGIN
				--save profile id to be inserted in the tmep table
				INSERT INTO #tmp_import_profiles (profile_id)
				SELECT profile_id FROM forecast_profile fp WHERE fp.external_id = @EAN_no
				SELECT @prof_id = profile_id FROM #tmp_import_profiles
				--delete existing deal hourly data for incoming profiles
				--DELETE deal_detail_hour 
				--FROM deal_detail_hour ddh
				--INNER JOIN #tmp_import_profiles ip ON ddh.profile_id = ip.profile_id
							
				--LRS code
				DECLARE @factor FLOAT --mark this float to avoid overflow issue when volume values are integer
				SET @factor = 1.0
				
				--copy process table data into a temp table
				CREATE TABLE #tmp_deal_detail_hour
				(
					[term_date] [DATETIME] NOT NULL,
					[Hr1] [FLOAT] NULL,
					[Hr2] [FLOAT] NULL,
					[Hr3] [FLOAT] NULL,
					[Hr4] [FLOAT] NULL,
					[Hr5] [FLOAT] NULL,
					[Hr6] [FLOAT] NULL,
					[Hr7] [FLOAT] NULL,
					[Hr8] [FLOAT] NULL,
					[Hr9] [FLOAT] NULL,
					[Hr10] [FLOAT] NULL,
					[Hr11] [FLOAT] NULL,
					[Hr12] [FLOAT] NULL,
					[Hr13] [FLOAT] NULL,
					[Hr14] [FLOAT] NULL,
					[Hr15] [FLOAT] NULL,
					[Hr16] [FLOAT] NULL,
					[Hr17] [FLOAT] NULL,
					[Hr18] [FLOAT] NULL,
					[Hr19] [FLOAT] NULL,
					[Hr20] [FLOAT] NULL,
					[Hr21] [FLOAT] NULL,
					[Hr22] [FLOAT] NULL,
					[Hr23] [FLOAT] NULL,
					[Hr24] [FLOAT] NULL,
					[Hr25] [FLOAT] NULL
				)

				--TODO: Load OnPeak or Off Peak hour data only as defined in deal curve index
				SET @sql = 'INSERT INTO #tmp_deal_detail_hour
									(term_date,
									Hr1, Hr2, Hr3, Hr4, Hr5, Hr6, Hr7, Hr8, Hr9, Hr10, Hr11, Hr12, Hr13,
									Hr14, Hr15, Hr16, Hr17, Hr18, Hr19, Hr20, Hr21, Hr22, Hr23, Hr24
									)
								SELECT
									[dbo].[FNAClientToSqlDate](tmp.term_date) term_date, --date in YYMMDD format
									(vol1 + vol2 + vol3 + vol4 + vol5 + vol6 + vol7 + vol8 + vol9 + vol10 + vol11 + vol12) / (12 * ' + CAST(@factor AS VARCHAR(10)) + ') Hr1,
									(vol13 + vol14 + vol15 + vol16 + vol17 + vol18 + vol19 + vol20 + vol21 + vol22 + vol23 + vol24) / (12 * ' + CAST(@factor AS VARCHAR(10)) + ') Hr2,
									(vol25 + vol26 + vol27 + vol28 + vol29 + vol30 + vol31 + vol32 + vol33 + vol34 + vol35 + vol36) / (12 * ' + CAST(@factor AS VARCHAR(10)) + ') Hr3,
									(vol37 + vol38 + vol39 + vol40 + vol41 + vol42 + vol43 + vol44 + vol45 + vol46 + vol47 + vol48) / (12 * ' + CAST(@factor AS VARCHAR(10)) + ') Hr4,
									(vol49 + vol50 + vol51 + vol52 + vol53 + vol54 + vol55 + vol56 + vol57 + vol58 + vol59 + vol60) / (12 * ' + CAST(@factor AS VARCHAR(10)) + ') Hr5,
									(vol61 + vol62 + vol63 + vol64 + vol65 + vol66 + vol67 + vol68 + vol69 + vol70 + vol71 + vol72) / (12 * ' + CAST(@factor AS VARCHAR(10)) + ') Hr6,
									(vol73 + vol74 + vol75 + vol76 + vol77 + vol78 + vol79 + vol80 + vol81 + vol82 + vol83 + vol84) / (12 * ' + CAST(@factor AS VARCHAR(10)) + ') Hr7,
									(vol85 + vol86 + vol87 + vol88 + vol89 + vol90 + vol91 + vol92 + vol93 + vol94 + vol95 + vol96) / (12 * ' + CAST(@factor AS VARCHAR(10)) + ') Hr8,
									(vol97 + vol98 + vol99 + vol100 + vol101 + vol102 + vol103 + vol104 + vol105 + vol106 + vol107 + vol108) / (12 * ' + CAST(@factor AS VARCHAR(10)) + ') Hr9,
									(vol109 + vol110 + vol111 + vol112 + vol113 + vol114 + vol115 + vol116 + vol117 + vol118 + vol119 + vol120) / (12 * ' + CAST(@factor AS VARCHAR(10)) + ') Hr10,
									(vol121 + vol122 + vol123 + vol124 + vol125 + vol126 + vol127 + vol128 + vol129 + vol130 + vol131 + vol132) / (12 * ' + CAST(@factor AS VARCHAR(10)) + ') Hr11,
									(vol133 + vol134 + vol135 + vol136 + vol137 + vol138 + vol139 + vol140 + vol141 + vol142 + vol143 + vol144) / (12 * ' + CAST(@factor AS VARCHAR(10)) + ') Hr12,
									(vol145 + vol146 + vol147 + vol148 + vol149 + vol150 + vol151 + vol152 + vol153 + vol154 + vol155 + vol156) / (12 * ' + CAST(@factor AS VARCHAR(10)) + ') Hr13,
									(vol157 + vol158 + vol159 + vol160 + vol161 + vol162 + vol163 + vol164 + vol165 + vol166 + vol167 + vol168) / (12 * ' + CAST(@factor AS VARCHAR(10)) + ') Hr14,
									(vol169 + vol170 + vol171 + vol172 + vol173 + vol174 + vol175 + vol176 + vol177 + vol178 + vol179 + vol180) / (12 * ' + CAST(@factor AS VARCHAR(10)) + ') Hr15,
									(vol181 + vol182 + vol183 + vol184 + vol185 + vol186 + vol187 + vol188 + vol189 + vol190 + vol191 + vol192) / (12 * ' + CAST(@factor AS VARCHAR(10)) + ') Hr16,
									(vol193 + vol194 + vol195 + vol196 + vol197 + vol198 + vol199 + vol200 + vol201 + vol202 + vol203 + vol204) / (12 * ' + CAST(@factor AS VARCHAR(10)) + ') Hr17,
									(vol205 + vol206 + vol207 + vol208 + vol209 + vol210 + vol211 + vol212 + vol213 + vol214 + vol215 + vol216) / (12 * ' + CAST(@factor AS VARCHAR(10)) + ') Hr18,
									(vol217 + vol218 + vol219 + vol220 + vol221 + vol222 + vol223 + vol224 + vol225 + vol226 + vol227 + vol228) / (12 * ' + CAST(@factor AS VARCHAR(10)) + ') Hr19,
									(vol229 + vol230 + vol231 + vol232 + vol233 + vol234 + vol235 + vol236 + vol237 + vol238 + vol239 + vol240) / (12 * ' + CAST(@factor AS VARCHAR(10)) + ') Hr20,
									(vol241 + vol242 + vol243 + vol244 + vol245 + vol246 + vol247 + vol248 + vol249 + vol250 + vol251 + vol252) / (12 * ' + CAST(@factor AS VARCHAR(10)) + ') Hr21,
									(vol253 + vol254 + vol255 + vol256 + vol257 + vol258 + vol259 + vol260 + vol261 + vol262 + vol263 + vol264) / (12 * ' + CAST(@factor AS VARCHAR(10)) + ') Hr22,
									(vol265 + vol266 + vol267 + vol268 + vol269 + vol270 + vol271 + vol272 + vol273 + vol274 + vol275 + vol276) / (12 * ' + CAST(@factor AS VARCHAR(10)) + ') Hr23,
									(vol277 + vol278 + vol279 + vol280 + vol281 + vol282 + vol283 + vol284 + vol285 + vol286 + vol287 + vol288) / (12 * ' + CAST(@factor AS VARCHAR(10)) + ') Hr24
							FROM ' + @temp_table_name + ' tmp'
						
				EXEC spa_print @sql
				EXEC(@sql)
				
				--delete existing deal hourly data for incoming profiles
				DELETE deal_detail_hour
				FROM   deal_detail_hour ddh
						INNER JOIN #tmp_deal_detail_hour tddh
							ON  tddh.term_date = ddh.term_date
							AND ddh.profile_id = @prof_id
				
				--EXEC('SELECT * FROM ' + @temp_table_name)
				
				-- Taking the DST hour from the start DST date to the 25th hour of end DST date.				
				UPDATE #tmp_deal_detail_hour
				SET    Hr25 = (SELECT tmp.Hr3
								FROM   #tmp_deal_detail_hour tmp
									   INNER JOIN mv90_DST md
											ON  md.date = tmp.term_date
											AND md.insert_delete = 'd')
				FROM   #tmp_deal_detail_hour tmp
					   INNER JOIN mv90_DST md
							ON  md.date = tmp.term_date
							AND md.insert_delete = 'i'
								   
				-- sum of the DST hours in the Hr3 = Hr3 + Hr25   
				UPDATE #tmp_deal_detail_hour
				SET    Hr3 = Hr3 + Hr25
				FROM   #tmp_deal_detail_hour tmp
					   INNER JOIN mv90_DST md
							ON  md.date = tmp.term_date
							AND md.insert_delete = 'i'	
								   
				-- Clearing the third hour value from the DST start date.
				UPDATE #tmp_deal_detail_hour
				SET    Hr3 = NULL
				FROM   #tmp_deal_detail_hour tmp
					   INNER JOIN mv90_DST md
							ON  md.date = tmp.term_date
							AND md.insert_delete = 'd'				
				
				--insert new hourly data for each source_deal_detail_id
				INSERT INTO deal_detail_hour
							(term_date, profile_id,
							Hr1, Hr2, Hr3, Hr4, Hr5, Hr6, Hr7, Hr8, Hr9, Hr10, Hr11, Hr12, Hr13,
							Hr14, Hr15, Hr16, Hr17, Hr18, Hr19, Hr20, Hr21, Hr22, Hr23, Hr24, Hr25, partition_value
							)
					SELECT term_date, @profile_id,
							Hr1, Hr2, Hr3, Hr4, Hr5, Hr6, Hr7, Hr8, Hr9, Hr10, Hr11, Hr12, Hr13,
							Hr14, Hr15, Hr16, Hr17, Hr18, Hr19, Hr20, Hr21, Hr22, Hr23, Hr24, Hr25, @profile_id
					FROM #tmp_deal_detail_hour

			END
				
		END --@table_id = @DEAL_DETAIL_HOUR_LRS
		ELSE IF @table_id = @DEAL_DETAIL_HOUR_CSV
		BEGIN
			--get missing ean nos
			SET @sql = 'INSERT INTO #tmp_missing_ean_no (ean_no)
						SELECT ean_code 
						FROM ' + @temp_table_name  + ' tmp
						WHERE NOT EXISTS(SELECT external_id FROM forecast_profile WHERE external_id = ean_code)
						'
			EXEC (@sql)
			
			--delete the missing ean no data from the staging table
			SET @sql = 'DELETE tmp
						FROM ' + @temp_table_name  + ' tmp
						INNER JOIN #tmp_missing_ean_no AS ean
						ON ean.ean_no = tmp.ean_code'
			EXEC (@sql)
			
			--save profile id to be inserted in the tmep table
			SET @sql = 'INSERT INTO #tmp_import_profiles (profile_id)
						SELECT profile_id FROM forecast_profile fp
						INNER JOIN ( 
							SELECT DISTINCT ean_code FROM ' + @temp_table_name + ' 
						)tmp ON tmp.ean_code = fp.external_id'
			EXEC(@sql)
			
			--Added by Pawan
			--SELECT * INTO #temp_deal_detail_hour FROM deal_detail_hour WHERE 1 = 2

			SELECT term_date,profile_id,Hr1,Hr2,Hr3,Hr4,Hr5,Hr6,Hr7,Hr8,Hr9,Hr10,Hr11,Hr12,Hr13,Hr14,Hr15,Hr16,Hr17,Hr18,Hr19,Hr20,Hr21,Hr22,Hr23,Hr24,Hr25,partition_value,file_name
			INTO #temp_deal_detail_hour FROM deal_detail_hour WHERE 1 = 2 -- excluding rep_row_id as SELECT INTO doesn't copy the defauly propery		

			IF LEFT(@file_name, 4) = 'Old_'	--old format files are prefix with 'Old_'
			BEGIN
				--old format csv where DST hours appear as (1, 2, 3, 4, 5, ..., 23 for begin and 1, 2, 3, 4, 5, ...., 23, 24, 25 for end)
				SET @sql = 'INSERT INTO #temp_deal_detail_hour
							(	term_date, profile_id,
								Hr1, Hr2, Hr3, Hr4, Hr5, Hr6, Hr7, Hr8, Hr9, Hr10, Hr11, Hr12, Hr13,
								Hr14, Hr15, Hr16, Hr17, Hr18, Hr19, Hr20, Hr21, Hr22, Hr23, Hr24, Hr25, partition_value
							)
							SELECT [dbo].[FNAClientToSqlDate](date) term_date --date in YYMMDD format
								, profile_id
								, [1] Hr1, [2] Hr2, [3] Hr3, [4] Hr4, [5] Hr5, [6] Hr6
								, [7] Hr7, [8] Hr8, [9] Hr9, [10] Hr10, [11] Hr11, [12] Hr12
								, [13] Hr13, [14] Hr14, [15] Hr15, [16] Hr16, [17] Hr17, [18] Hr18
								, [19] Hr19, [20] Hr20, [21] Hr21, [22] Hr22, [23] Hr23, [24] Hr24, [25] Hr25
								, profile_id partition_value
							FROM
							(  SELECT fp.profile_id,
										tmp.date,
										(
											
											CASE 
											   WHEN (([dbo].[FNAClientToSqlDate](tmp.date) = md_start.date) AND tmp.hours > 2) THEN tmp.hours + 1
											   WHEN (([dbo].[FNAClientToSqlDate](tmp.date) = md_end.date)AND tmp.hours = 4) THEN 25
											   WHEN (([dbo].[FNAClientToSqlDate](tmp.date) = md_end.date)AND tmp.hours > 4) THEN tmp.hours - 1
											   ELSE tmp.hours
											END
											
											--CASE 
											--	-- Check if the Date is matched to the DST start date [2011-03-27]
											--	-- if true shift the data column hour from 3 to 4.
											--	WHEN (tmp.date = convert(varchar,md_start.date,103) AND tmp.hours > 2) THEN tmp.hours + 1
												
											--	-- Check if the Date is matched to the DST end date [2011-10-30]
											--	-- if true shift the data column hour from 4 to 25.
											--	WHEN (tmp.date = convert(varchar,md_end.date,103) AND tmp.hours = 4) THEN 25
												
											--	-- Check if the Date is matched to the DST end date [2011-10-30], 
											--	-- if true shift the data columns hour greater then 4 to backward count.
											--	WHEN (tmp.date = convert(varchar,md_end.date,103) AND tmp.hours > 4) THEN tmp.hours - 1
											--	ELSE tmp.hours
											--END
										) hours,
										tmp.vol
								FROM ' + @temp_table_name + ' tmp
									INNER JOIN forecast_profile fp ON tmp.ean_code = fp.external_id
									LEFT JOIN mv90_DST md_start ON md_start.[year] = YEAR([dbo].[FNAClientToSqlDate](tmp.date)) AND md_start.insert_delete = ''d''
									LEFT JOIN mv90_DST md_end ON md_end.[year] = YEAR([dbo].[FNAClientToSqlDate](tmp.date)) AND md_end.insert_delete = ''i''
							) p
							PIVOT
							(SUM(vol)
								 FOR [hours] IN 
								 (	[1], [2], [3], [4], [5], [6], 
									[7], [8], [9], [10], [11], [12], 
									[13], [14], [15], [16], [17], [18], 
									[19], [20], [21], [22], [23], [24], [25])
							) pvt'
			END
			ELSE
			BEGIN
				--new format csv where DST hours appear as (1, 2, 4, 5, ..., 23, 24 for begin and 1, 2, 3, 3, 4, 5, ...., 23, 24 for end)
			
				--add autonumber column (id) to DST 3rd hour handling			
				SET @sql = 'IF COL_LENGTH(''' + @temp_table_name + ''', ''id'') IS NULL ALTER TABLE ' + @temp_table_name + ' ADD id INT IDENTITY(1, 1);'
				EXEC(@sql)
				
				--first fix the DST hours by updating second 3rd hours DST to 25 for new CSV format
				SET @sql = 'UPDATE t
					SET t.[hours] = 25
					FROM ' + @temp_table_name + ' t
					INNER JOIN 
					(
						--get second 3rd DST hour
						SELECT MAX(tcsv.id) id FROM ' + @temp_table_name + ' tcsv
						INNER JOIN mv90_DST mv ON mv.date =[dbo].[FNAClientToSqlDate](tcsv.[date])
							AND insert_delete = ''i''
						WHERE tcsv.[hours] = 3
						GROUP BY tcsv.[date]
					) dst_hr ON t.id = dst_hr.id'
					
				EXEC spa_print @sql
				EXEC(@sql)
						
				SET @sql = 'INSERT INTO #temp_deal_detail_hour
							(	term_date, profile_id,
								Hr1, Hr2, Hr3, Hr4, Hr5, Hr6, Hr7, Hr8, Hr9, Hr10, Hr11, Hr12, Hr13,
								Hr14, Hr15, Hr16, Hr17, Hr18, Hr19, Hr20, Hr21, Hr22, Hr23, Hr24, Hr25, partition_value
							)
							SELECT [dbo].[FNAClientToSqlDate](date) term_date --date in YYMMDD format
								, profile_id
								, [1] Hr1, [2] Hr2, [3] Hr3, [4] Hr4, [5] Hr5, [6] Hr6
								, [7] Hr7, [8] Hr8, [9] Hr9, [10] Hr10, [11] Hr11, [12] Hr12
								, [13] Hr13, [14] Hr14, [15] Hr15, [16] Hr16, [17] Hr17, [18] Hr18
								, [19] Hr19, [20] Hr20, [21] Hr21, [22] Hr22, [23] Hr23, [24] Hr24, [25] Hr25
								, profile_id partition_value
							FROM
							(  SELECT fp.profile_id, tmp.date, tmp.hours, tmp.vol
								FROM ' + @temp_table_name + ' tmp
								INNER JOIN forecast_profile fp ON tmp.ean_code = fp.external_id
							) p
							PIVOT
							(SUM(vol)
								 FOR [hours] IN 
								 (	[1], [2], [3], [4], [5], [6], 
									[7], [8], [9], [10], [11], [12], 
									[13], [14], [15], [16], [17], [18], 
									[19], [20], [21], [22], [23], [24], [25])
							) pvt'
			END
				
			EXEC spa_print @sql
			EXEC(@sql)
			
			--delete existing deal hourly data for incoming profiles
			DELETE deal_detail_hour
			FROM   deal_detail_hour ddh
			       INNER JOIN #temp_deal_detail_hour ip
			            ON  ddh.profile_id = ip.profile_id
			            AND ip.term_date = ddh.term_date
			
			-- sum of the DST hours in the Hr3 = Hr3 + Hr25   
			UPDATE #temp_deal_detail_hour SET Hr3 = Hr3 + Hr25
			FROM   #temp_deal_detail_hour tmp
					INNER JOIN mv90_DST md ON  md.date = tmp.term_date AND md.insert_delete = 'i'

			INSERT INTO deal_detail_hour
			(	term_date, profile_id,
				Hr1, Hr2, Hr3, Hr4, Hr5, Hr6, Hr7, Hr8, Hr9, Hr10, Hr11, Hr12, Hr13,
				Hr14, Hr15, Hr16, Hr17, Hr18, Hr19, Hr20, Hr21, Hr22, Hr23, Hr24, Hr25, partition_value
			)
			SELECT term_date 
				, profile_id
				, Hr1, Hr2, Hr3, Hr4, Hr5, Hr6
				, Hr7, Hr8, Hr9, Hr10, Hr11, Hr12
				, Hr13, Hr14, Hr15,  Hr16, Hr17, Hr18
				, Hr19, Hr20, Hr21, Hr22, Hr23, Hr24, Hr25
				, profile_id partition_value
			FROM #temp_deal_detail_hour
			
			
		END --@table_id = @DEAL_DETAIL_HOUR_CSV
		ELSE
		BEGIN
			SET @desc = 'Invalid table_id:' + CAST(@table_id AS VARCHAR(10))
			EXEC spa_print @desc
			RAISERROR (@desc, -- Message text.
					   16, -- Severity.
					   1 -- State.
					);
		END
		
		IF EXISTS(SELECT 1 FROM #tmp_missing_ean_no tmen)
		BEGIN
			SET @error_code = 'e'
			INSERT INTO source_system_data_import_status(process_id, code, module, source, [type], [description], recommendation) 
			VALUES (@process_id, 'Error', 'Import Deal Hourly Data', @file_name, 'Error', 'EAN No not found in the system.', 'Please import correct deal hourly data file.')
			
			INSERT INTO source_system_data_import_status_detail(process_id, source, [type],[description]) 
			SELECT @process_id, @file_name, 'Data Error', 'EAN No: ' + ean_no + ' not found in the system.'
			FROM #tmp_missing_ean_no 
			
		END
		
		/********************************************Update total monthly volume START********************************************************/
		
		--update data availability flag
		UPDATE forecast_profile SET available = 1
		FROM forecast_profile fp
		INNER JOIN #tmp_import_profiles ip ON fp.profile_id = ip.profile_id
		
		
		EXEC spa_print 'Calculating Total Volume...'
		
		DECLARE @spa VARCHAR(1000)
		DECLARE @report_position_process_id VARCHAR(500)
		DECLARE @report_position_deals VARCHAR(150)

		SET @report_position_process_id = dbo.FNAGetNewID()
		SET @report_position_deals = dbo.FNAProcessTableName('report_position', @user_login_id, @report_position_process_id)
		EXEC ('CREATE TABLE ' + @report_position_deals + '(source_deal_header_id INT, action CHAR(1))')

		--SELECT * FROM #tmp_import_profiles
		
		CREATE TABLE #tmp_location_profile (
			  location_id INT NULL,
			  profile_id INT NULL,
			  profile_type INT,                                       
			  external_id VARCHAR(50) COLLATE DATABASE_DEFAULT
		)

		INSERT INTO #tmp_location_profile (
		    location_id,
		    profile_id,
		    profile_type,
		    external_id
		  )
		SELECT sml.source_minor_location_id,
		       ISNULL(fp.profile_id, fp1.profile_id) profile_id,
		       ISNULL(fp.profile_type, fp1.profile_type) profile_type,
		       ISNULL(fp.external_id, fp1.external_id) external_id
		FROM   source_minor_location sml(NOLOCK)
		       LEFT JOIN [forecast_profile] fp(NOLOCK)
		            ON  fp.profile_id = sml.profile_id
		            AND ISNULL(fp.available, 0) = 1
		       LEFT JOIN [forecast_profile] fp1(NOLOCK)
		            ON  fp1.profile_id = sml.proxy_profile_id
		            AND ISNULL(fp1.available, 0) = 1
		       INNER JOIN #tmp_import_profiles ip
		            ON  ip.profile_id = ISNULL(fp.profile_id, fp1.profile_id)
		WHERE  ISNULL(fp.profile_id, fp1.profile_id) IS NOT NULL --AND ISNULL(fp.profile_id, fp1.profile_id) = @profile_id
		
		--SELECT * FROM #tmp_location_profile
		EXEC('INSERT INTO ' + @report_position_deals + '(source_deal_header_id, action)
				SELECT DISTINCT source_deal_header_id, ''u'' FROM source_deal_detail sdd 
				INNER JOIN #tmp_location_profile tmp ON sdd.location_id = tmp.location_id')
	
		--EXEC('select * from '+@report_position_deals)
		
		IF EXISTS(SELECT 1 FROM source_deal_detail sdd INNER JOIN #tmp_location_profile tmp ON sdd.location_id = tmp.location_id)
			EXEC dbo.spa_update_deal_total_volume NULL, @report_position_process_id, 12
	    
	    /********************************************Update total monthly volume END********************************************************/


		
		SET @error_code = 's'		
		
		DECLARE @total_import_count INT		
		EXEC('INSERT INTO #tmp_data_count(total_rows) SELECT COUNT(*) FROM ' + @temp_table_name)
		SELECT @total_import_count = total_rows FROM #tmp_data_count 
				
		INSERT INTO source_system_data_import_status(process_id, code, module, source, [type], [description], recommendation) 
		VALUES(
		          @process_id,
		          'Success',
		          'Import Deal Hourly Data',
		          @file_name,
		          'Success',
		          'Total ' + CAST(@total_import_count AS VARCHAR(15)) + 
		          ' rows out of ' + CAST(@total_count AS VARCHAR(15)) + 
		          ' imported for file: ' + @file_name,
		          ''
		      )
		
		COMMIT TRAN
	END --data exists
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRAN
			
	DECLARE @error_msg VARCHAR(1000)
	
	SET @error_msg = 'Error: ' + ERROR_MESSAGE()
	SET @error_code = 'e'
	EXEC spa_print @error_msg
	
	INSERT INTO source_system_data_import_status(process_id, code, module, source, [type], [description], recommendation) 
	VALUES (@process_id, 'Error', 'Import Deal Hourly Data', @file_name, 'Error'
			, @error_msg, 'Please import correct deal hourly data file.')
END CATCH
				
--update message board

--incase of no error, mark as success
SET @error_code = ISNULL(@error_code, 's')
SET @elapsed_sec = DATEDIFF(SECOND, @start_ts, GETDATE())

SELECT @url = './dev/spa_html.php?__user_name__=' + @user_login_id + 
			  '&spa=exec spa_get_import_process_status ''' + @process_id + ''',''' + @user_login_id + ''''

SELECT @desc = '<a target="_blank" href="' + @url + '">' + 
			'Deal Hourly Data import process Completed' + 
			CASE WHEN (@error_code = 'e') THEN ' (ERRORS found)' ELSE '' END +
			'.(elapsed time:'+CAST(@elapsed_sec AS VARCHAR(100))+' sec)</a>'

EXEC  spa_message_board 'i', @user_login_id,
			NULL, 'Import Deal Hourly Data',
			@desc, '', '', @error_code, @job_name
	
EXEC spa_import_data_files_audit
	@flag = 'u',
	@process_id = @process_id, 
	@status = @error_code,
	@elapsed_time = @elapsed_sec		

