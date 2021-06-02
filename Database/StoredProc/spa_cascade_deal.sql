IF OBJECT_ID(N'spa_cascade_deal', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_cascade_deal]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**
This SP used cascade deal using generic mapping definition
	
	Parameters: 
	@parent_deal_ids : parent deal id 
	@max_as_of_date  : As of Date
	@result_output	 : Result output Tables

*/

CREATE PROC [dbo].[spa_cascade_deal]
	@parent_deal_ids VARCHAR(MAX), 
	@max_as_of_date DATETIME = NULL,
	@result_output VARCHAR(125) = NULL,
	@flag VARCHAR(1000)
AS

/*------------------Debug Section---------------------
DECLARE @contextinfo VARBINARY(128) = CONVERT(VARBINARY(128), 'DEBUG_MODE_ON')
SET CONTEXT_INFO @contextinfo
DECLARE @parent_deal_ids VARCHAR(1000)
DECLARE @max_as_of_date DATETIME =  '2019-12-27'
--SET  @max_as_of_date = '2020-03-27'
--SET  @max_as_of_date = '2020-09-28'

DECLARE @flag VARCHAR(1000)
DECLARE  @result_output VARCHAR(125) 

--SELECT @parent_deal_ids = '20,85,105,123,124,125,126,127,132,142,153,170,173,174,191,196,199,208,209,212,223,229,232,233,244,249,250,256,264,268,270,274,288,295,297,298,299,304,312,313,314,321,329,332,361,362,363,379,384,388,394,395,1066,1068,1080,1083,1108,1114,1117,1144,1147,1155,1161,1167,1170,1171,1174,1175,1199,1203,1205,1206,1207,1208,1209,1219,1223,1227,1229,1238,1241,1248,1249,1250,1252,1264,1271,1274,1304,1305,1317,1318,1328,1347,1350,1369,1378,1407,1410,1421,1422,1432,1433,1447,2006,2065,2091,2094,2103,2106,2121,2127,2128,2130,2147,2152,2160,2168,2177,2179,2181,2182,2184,2193,2228,2235,2237,2255,2259,2273,2287,2298,2308,2309,2310,2311,2317,2329,2339,2342,2349,2350,2363,2395,2398,2399,2405,2407,2412,2413,2419,2424,2432,2444,2446,2452,2476,2483,2484,2489,2493,2506,2511,2533,2553,2564,3022,3056,3079,3148,3149,3157,3164,3182,3197,3213,3223,3224,3279,3283,3293,3310,3345,3351,3372,3376,3380,3382,3395,3418,3425,3426,3436,3452,3457,3458,3471,3488,3491,3508,3509,3524,3525,3534,3535,3616,4077,4117,4118,4167,4168,4177,4183,4203,4204,4212,4214,4227,4231,4238,4249,4252,4253,4257,4260,4276,4278,4284,4288,4292,4302,4304,4311,4313,4320,4325,4326,4327,4332,4336,4346,4348,4367,4378,4380,4387,4388,4392,4393,4398,4402,4424,4434,4437,4438,4443,4444,4445,4453,4461,4467,4468,4480,4487,4491,4497,4502,4516,4520,4523,4524,4529,4534,4535,4536,4537,4541,4545,4548,4555,4559,4560,4579,4589,4590,4636,4637,5157,5174,5194,5208,5215,5246,5248,5251,5254,5258,5259,5263,5268,5286,5288,5289,5290,5294,5295,5299,5319,5323,5345,5393,5405,5410,5453,5456,5459,5461,5467,5468,5469,5472,5474,5475,5477,5484,5485,5498,5507,5514,6038,6050,6066,6067,6085,6109,6116,6138,6143,6147,6156,6162,6165,6167,6173,6192,6198,6199,6201,6202,6206,6211,6214,6215,6221,6224,6226,6231,6232,6242,6243,6249,6252,6259,6260,6276,6277,6285,6317,6325,6334,6348,6356,6364,6365,6371,6381,6382,6383,6384,6388,6393,6398,6416,6417,6418,6419,6427,6442,6445,6448,6472,6477,6479,6486,6501,6504,6515,6516,6522,6523,6526,6541,6555,7088,7101,7105,7107,7113,7114,7116,7117,7121,7126,7128,7132,7133,7134,7141,7142,7146,7150,7151,7153,7156,7163,7184,7187,7189,7191,7192,7200,7201,7210,7213,7233,7236,7241,7243,7248,7252,7254,7256,7282,7287,7288,7298,7300,7302,7310,7311,7312,7326,7329,7335,7337,7338,7346,7347,7351,7357,7361,7362,7363,7365,7378,7380,7385,7447,7456,7465,7471,7482,7485,8024,8114,8121,8145,8193,8197,8198,8204,8205,8218,8230,8242,8252,8262,8266,8267,8268,8269,8270,8271,8274,8277,8278,8288,8291,8292,8294,8313,8315,8316,8322,8323,8324,8325,8342,8344,8360,8371,8388,8391,8400,8404,8419,8420,8423,8426,8427,8434,8443,8444,8446,8449,8450,8451,8452,8453,8460,8463,8467,8485,8488,8512,8514,8537,8551,8552,8553,8560,8565,8567,8571,8576,8589,9178,9200,9221,9225,9233,9237,9243,9246,9247,9253,9254,9262,9265,9266,9268,9269,9271,9281,9286,9287,9288,9293,9305,9310,9320,9323,9325,9333,9334,9335,9340,9344,9346,9350,9357,9362,9369,9388,9396,9401,9403,9404,9416,9425,9427,9428,9432,9433,9438,9450,9458,9459,9461,9467,9472,9476,9499,9509,9511,9517,9524,9532,9536,9550,9557,9614,9641,10166,10185,10203,10219,10229,10268,10281,10284,10286,10307,10317,10330,10341,10343,10344,10355,10356,10357,10359,10360,10375,10378,10392,10393,10411,10452,10473,10492,10493,10494,10500,10508,10550,10574,10578,10583,10586,10588,10590,10609,10615,10619,10621,10627,10628,10640,10644,10681,10688,10689,10694,10701,10721,10725,10741,10743,10769,11231,11236,11269,11270,11306,11307,11309,11310,11311,11312,11314,11329,11336,11344,11352,11353,11355,11357,11365,11366,11367,11369,11370,11372,11393,11396,11402,11404,11405,11406,11413,11414,11438,11454,11460,11470,11473,11481,11503,11506,11507,11511,11515,11516,11525,11529,11533,11537,11547,11559,11563,11565,11578,11583,11584,11600,11603,11605,11616,11619,11629,11638,11639,11655,11658,11662,11673,11686,11693,11720,11721,12250,12275,12304,12364,12447,12450,12468,12470,12472,12474,12478,12482,12483,12490,12493,12499,12510,12518,12520,12521,12524,12525,12526,12527,12528,12531,12532,12537,12544,12545,12553,12556,12565,12566,12573,12601,12604,12621,12632,12666,12668,12669,12671,12678,12681,12712,12714,12721,12753,12774,12782,12796,12797,12798,12799,12807,12809,12816,12819,12821,12824,12832,12851,12852,12885,12901,12915,12928,12934,12958,12963,13494,13511,13525,13544,13599,13600,13601,13602,13612,13620,13621,13626,13627,13638,13641,13648,13667,13669,13674,13679,13682,13689,13694,13695,13696,13704,13724,13743,13758,13760,13775,13791,13796,13801,13812,13821,13833,13835,13844,13848,13866,13871,13872,13878,13890,13893,13905,13906,13909,13934,13935,13943,13945,13948,13952,13966,13974,13975,13976,13990,14537,14610,14639,14640,14644,14652,14655,14656,14658,14659,14667,14670,14671,14672,14677,14701,14703,14704,14711,14716,14717,14720,14737,14743,14749,14753,14772,14784,14813,14844,14846,14847,14863,14867,14883,14894,14923,14924,14926,14944,14962,14986,14990,14994,15014,15017,15020,15025,15047,15488,15497,15507,15511,15512,15537,15564,15571,15573,15578,15581,15582,15586,15606,15607,15612,15619,15623,15632,15650,15651,15656,15658,15667,15668,15669,15683,15685,15690,15707,15708,15714,15742,15745,15758,15759,15802,15803,15807,15808,15809,15812,15816,15833,15836,15858,15865,15869,15873,15878,15880,15896,15907,15910,15911,15913,15914,15915,15916,15929,15944,15955,15956'
SELECT @parent_deal_ids = '134398'
SELECT @parent_deal_ids = '170805'
SELECT @parent_deal_ids = '170923'

SET @flag = 'cascade'
--SET @flag = 'rewind_cascade'
--select *from static_data_value where type_id = 5600
--select deal_status, * from source_deal_header where source_deal_header_id=359
--update source_deal_header set deal_status=5604 where source_deal_header_id=359
----------------------------------------------------*/
  
SET NOCOUNT ON

DECLARE @user_name VARCHAR(30) = dbo.FNADBUser(),
		@process_id VARCHAR(100) = dbo.FNAGetNewID()

DECLARE @sdv_from_deal INT, @sdv_to_deal INT, @sql VARCHAR(MAX), @err_status VARCHAR(10) = 's', @url VARCHAR(3000), @url_desc VARCHAR(MAX), @term_start DATETIME,
		@term_end DATETIME, @source_deal_header_id INT, @parent_curve INT, @granularity INT, @deal_id VARCHAR(200), @deal_id_status INT, @mapping_name VARCHAR(100) = 'Cascading'
 
DECLARE @clm1_value VARCHAR(50), @clm2_value VARCHAR(50), @clm3_value VARCHAR(50), @clm4_value VARCHAR(50), @clm5_value VARCHAR(50), @clm6_value VARCHAR(50),
		@clm7_value VARCHAR(50), @clm8_value VARCHAR(50), @clm9_value VARCHAR(50), @clm10_value VARCHAR(50), @clm11_value VARCHAR(50)

DECLARE @after_update_process_table VARCHAR(300), @job_name VARCHAR(200), @job_process_id VARCHAR(200) = dbo.FNAGETNEWID()
DECLARE @error_message VARCHAR(1000)

IF OBJECT_ID(N'tempdb..#mapping') IS NOT NULL
	DROP TABLE #mapping

IF @flag = 'cascade'
BEGIN 
	CREATE TABLE #mapping (
		row_id INT IDENTITY(1, 1),
		gran VARCHAR(5) COLLATE DATABASE_DEFAULT,
		term_start DATETIME,
		term_end DATETIME,
		curve_id INT,
		deal_date DATETIME,
		deal_id VARCHAR(200) COLLATE DATABASE_DEFAULT,
		parent_deal_curve_gran INT,
		parent_term_start DATETIME,
		parent_term_end DATETIME,
		source_deal_header_id INT)

	IF OBJECT_ID(N'tempdb..#deal_info') IS NOT NULL
		DROP TABLE #deal_info

	CREATE TABLE #deal_info (
		source_deal_header_id INT,
		deal_id VARCHAR(200) COLLATE DATABASE_DEFAULT,
		curve_id INT,
		term_start DATETIME,
		term_end DATETIME,
		deal_status INT
	)
  
	IF OBJECT_ID(N'tempdb..#tmp_deals') IS NOT NULL
		DROP TABLE #tmp_deals

	CREATE TABLE #tmp_deals (
		row_id INT IDENTITY(1, 1),
		source_deal_header_id INT,
		curve_id INT
	)

	IF OBJECT_ID(N'tempdb..#tmp_header') IS NOT NULL
		DROP TABLE #tmp_header

	SET @sql = '
			INSERT INTO #deal_info (source_deal_header_id, deal_id, curve_id, term_start, term_end, deal_status)
			SELECT sdh.source_deal_header_id, sdh.deal_id, sdd.curve_id, sdh.entire_term_start, sdh.entire_term_end, sdh.deal_status
			FROM source_deal_header sdh
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
			INNER JOIN dbo.FNASplit(''' + @parent_deal_ids + ''', '','') dea ON dea.item = sdh.source_deal_header_id
			GROUP BY sdh.source_deal_header_id, sdh.deal_id, sdd.curve_id, sdh.entire_term_start, sdh.entire_term_end, sdh.deal_status
	'
	EXEC(@sql)

	--select * from #deal_info 
	--return 

	IF OBJECT_ID(N'tempdb..#curve_ids_value') IS NOT NULL
		DROP TABLE #curve_ids_value

	CREATE TABLE #curve_ids_value(curve_id INT,  source_deal_header_id INT, parent_curve INT, term_start DATETIME, curve_value NUMERIC(38, 10), maturity_date DATETIME, term_end DATETIME)

	IF OBJECT_ID(N'tempdb..#source_system_data_import_status') IS NOT NULL
		DROP TABLE #source_system_data_import_status

	CREATE TABLE #source_system_data_import_status (process_id VARCHAR(1000) COLLATE DATABASE_DEFAULT
													, code VARCHAR(1000) COLLATE DATABASE_DEFAULT
													, module VARCHAR(1000) COLLATE DATABASE_DEFAULT
													, source VARCHAR(1000) COLLATE DATABASE_DEFAULT
													, type VARCHAR(1000) COLLATE DATABASE_DEFAULT
													, [description] VARCHAR(1000) COLLATE DATABASE_DEFAULT
													, deal_id  VARCHAR(1000) COLLATE DATABASE_DEFAULT
													) 

	IF OBJECT_ID(N'tempdb..#child_deal_detail') IS NOT NULL
		DROP TABLE #child_deal_detail
	
	CREATE TABLE #child_deal_detail(term_start DATETIME, term_end DATETIME, parent_id INT, id VARCHAR(2) COLLATE DATABASE_DEFAULT)

	DECLARE c CURSOR FOR 
	SELECT source_deal_header_id, deal_id, curve_id, term_start, term_end, deal_status 
	FROM #deal_info
	GROUP BY source_deal_header_id, deal_id, curve_id, term_start, term_end, deal_status 
	OPEN c 
	FETCH NEXT FROM c INTO @source_deal_header_id, @deal_id, @parent_curve, @term_start, @term_end, @deal_id_status 
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @deal_id_status  = 5607
		BEGIN
			SET @err_status = 'e'
			SET @sql = '
				INSERT INTO #source_system_data_import_status (process_id, code, module, source, type, [description]) 
				SELECT ''' + @process_id + ''', ''Error'', ''Cascade deal'', ''Cascade deal'', ''Error'', ''Cannot disintegrate voided deal ' + @deal_id + '''
			'
			EXEC spa_print @sql
			EXEC(@sql)

			EXEC spa_print 'Cannot disintegrate voided deal ', @deal_id
			FETCH NEXT FROM c INTO @source_deal_header_id, @deal_id, @parent_curve, @term_start, @term_end, @deal_id_status
			CONTINUE
		END

		INSERT INTO #tmp_deals(source_deal_header_id, curve_id)
		SELECT @source_deal_header_id, @parent_curve
	
		--get max as of date 
		IF @max_as_of_date IS NULL 
		BEGIN 

			SELECT @max_as_of_date = MIN(TRY_CAST(gmv.clm11_value AS DATETIME))
			FROM generic_mapping_header gmh
			INNER JOIN generic_mapping_values gmv ON gmv.mapping_table_id = gmh.mapping_table_id
				AND @term_start  <= DATEADD(MONTH, CASE TRY_CAST(gmv.clm9_value AS INT) WHEN 1 THEN 12 WHEN 2 THEN 3 WHEN 3 THEN 6 END, TRY_CAST(gmv.clm11_value AS DATETIME))
			WHERE (TRY_CAST(gmv.clm2_value AS INT) IS NOT NULL AND gmv.clm2_value = @parent_curve)
				AND TRY_CAST(gmv.clm11_value AS DATETIME) IS NOT NULL AND TRY_CAST(gmv.clm11_value AS DATETIME) < @term_start
				AND gmh.mapping_name = @mapping_name
		END

		-- mapping logic changed
		SET @clm9_value = NULL
		SELECT TOP 1
			   @clm1_value = gmv.clm1_value, @clm2_value = gmv.clm2_value, @clm3_value = gmv.clm3_value, @clm4_value = gmv.clm4_value, @clm5_value = gmv.clm5_value,
			   @clm6_value = gmv.clm6_value, @clm7_value = gmv.clm7_value, @clm8_value = gmv.clm8_value, @clm9_value = gmv.clm9_value, @clm10_value = gmv.clm10_value,
			   @clm11_value = gmv.clm11_value	
		FROM generic_mapping_header gmh
		INNER JOIN generic_mapping_values gmv ON gmv.mapping_table_id = gmh.mapping_table_id
			AND @term_start  <= DATEADD(MONTH, CASE TRY_CAST(gmv.clm9_value AS INT) WHEN 1 THEN 12 WHEN 2 THEN 3 WHEN 3 THEN 6 END, TRY_CAST(gmv.clm11_value AS DATETIME))
		WHERE (TRY_CAST(gmv.clm2_value as INT) IS NOT NULL AND gmv.clm2_value = @parent_curve)
			AND TRY_CAST(gmv.clm11_value AS DATETIME) IS NOT NULL AND TRY_CAST(gmv.clm11_value AS DATETIME) = @max_as_of_date
			AND gmh.mapping_name = @mapping_name
		ORDER BY TRY_CAST(gmv.clm11_value AS DATETIME) ASC

		IF NOT EXISTS(SELECT 1 FROM generic_mapping_header gmh
					INNER JOIN generic_mapping_values gmv ON gmv.mapping_table_id = gmh.mapping_table_id
						AND @term_start  <= DATEADD(MONTH, CASE TRY_CAST(gmv.clm9_value AS INT) WHEN 1 THEN 12 WHEN 2 THEN 3 WHEN 3 THEN 6 END, TRY_CAST(gmv.clm11_value AS DATETIME))
					WHERE (TRY_CAST(gmv.clm2_value as INT) IS NOT NULL AND gmv.clm2_value = @parent_curve)
						AND TRY_CAST(gmv.clm11_value AS DATETIME) IS NOT NULL AND TRY_CAST(gmv.clm11_value AS DATETIME) = @max_as_of_date
						AND gmh.mapping_name = @mapping_name)
		BEGIN 
			DELETE FROM #tmp_deals WHERE source_deal_header_id = @source_deal_header_id
		END
		ELSE 
		BEGIN
			IF @clm9_value = 1 --@granularity = 993 --Annually
			BEGIN

				INSERT INTO #mapping (gran, term_start, term_end, curve_id, deal_date, deal_id, parent_deal_curve_gran, parent_term_start, parent_term_end, source_deal_header_id)
				--SELECT 'M' + CAST(ROW_NUMBER() OVER( ORDER BY term_start) AS VARCHAR) AS id,
				--	   a.term_start,
				--	   a.term_end, 
				--	   CASE ROW_NUMBER() OVER( ORDER BY term_start) WHEN 1 THEN @clm3_value
				--													WHEN 2 THEN @clm4_value
				--													WHEN 3 THEN @clm5_value
				--	   END,
				--	   @clm11_value,
				--	   @deal_id + '_' + 'M' + CAST(ROW_NUMBER() OVER( ORDER BY term_start) AS VARCHAR) + '_CASCADE',
				--	   993,
				--	   @term_start,
				--	   @term_end,
				--	   @source_deal_header_id
				--FROM dbo.[FNATermBreakdown]('m', @term_start, EOMONTH(DATEADD(m, 2, @term_start))) a
				--UNION ALL
				SELECT 'Q' + CAST(ROW_NUMBER() OVER( ORDER BY term_start) AS VARCHAR) AS id,
					   a.term_start,
					   a.term_end,
					   CASE ROW_NUMBER() OVER( ORDER BY term_start) WHEN 1 THEN @clm3_value
																	WHEN 2 THEN @clm4_value
																	WHEN 3 THEN @clm5_value
																	WHEN 4 THEN @clm6_value
					   END,
					   @clm11_value,
					   @deal_id + '_' + 'Q' + CAST(ROW_NUMBER() OVER( ORDER BY term_start) AS VARCHAR) + '_CASCADE',
					   993,
					   @term_start,
					   @term_end,
					   @source_deal_header_id
				FROM dbo.[FNATermBreakdown]('q', @term_start, @term_end) a
				--DELETE FROM #mapping WHERE gran = 'Q1'
			END 

			IF @clm9_value = 2 --@granularity = 991 --Quarterly
			BEGIN
				INSERT INTO #mapping(gran, term_start, term_end, curve_id, deal_date, deal_id, parent_deal_curve_gran, parent_term_start, parent_term_end, source_deal_header_id)
				SELECT 'M' + CAST(DATEPART(MONTH, term_start) AS VARCHAR(2)) AS id,
					   a.term_start,
					   a.term_end,
					   CASE ROW_NUMBER() OVER( ORDER BY term_start) WHEN 1 THEN @clm3_value
																	WHEN 2 THEN @clm4_value
																	WHEN 3 THEN @clm5_value
					   END,
					   @clm11_value,
					   @deal_id + '_' + 'M' + CAST(DATEPART(MONTH, term_start) AS VARCHAR(2)) + '_CASCADE',
					   991,
					   @term_start,
					   @term_end,
					   @source_deal_header_id
				FROM dbo.[FNATermBreakdown]('m', @term_start, @term_end) a
			END
			  
			IF @clm9_value = 3 --seasonally --six monthly
			BEGIN
				INSERT INTO #mapping (gran, term_start, term_end, curve_id, deal_date, deal_id, parent_deal_curve_gran, parent_term_start, parent_term_end, source_deal_header_id)
				--SELECT 'M' + CAST(ROW_NUMBER() OVER( ORDER BY term_start) AS VARCHAR) AS id,
				--	   a.term_start,
				--	   a.term_end, 
				--	   CASE ROW_NUMBER() OVER( ORDER BY term_start) WHEN 1 THEN @clm3_value
				--													WHEN 2 THEN @clm4_value
				--													WHEN 3 THEN @clm5_value
				--	   END,
				--	   @clm11_value,
				--	   @deal_id + '_' + 'M' + CAST(ROW_NUMBER() OVER( ORDER BY term_start) AS VARCHAR) + '_CASCADE',
				--	   3,
				--	   @term_start,
				--	   @term_end,
				--	   @source_deal_header_id
				--FROM dbo.[FNATermBreakdown]('m', @term_start, EOMONTH(DATEADD(m, 2, @term_start))) a
				--UNION ALL
				SELECT 'Q' + CAST(DATEPART(QUARTER, term_start) AS VARCHAR(2)) AS id,
					   a.term_start,
					   a.term_end,
					   CASE ROW_NUMBER() OVER( ORDER BY term_start) 
						   WHEN 2 THEN @clm4_value
						   WHEN 1 THEN @clm3_value ELSE NULL
					   END,
					   @clm11_value,
					   @deal_id + '_' + 'Q' + CAST(DATEPART(QUARTER, term_start) AS VARCHAR(2)) + '_CASCADE',
					   3,
					   @term_start,
					   @term_end,
					   @source_deal_header_id
				FROM dbo.[FNATermBreakdown]('q', @term_start, @term_end) a
		
				--DELETE FROM #mapping WHERE curve_id IS NULL --gran = 'Q1'
			END 

			INSERT INTO #curve_ids_value(curve_id, source_deal_header_id, parent_curve, term_start, curve_value, maturity_date, term_end)
			SELECT curve_id, @source_deal_header_id, @parent_curve, @term_start, MAX(curve_value), maturity_date, @term_end 
			FROM source_price_curve spc 
			INNER JOIN #deal_info di ON di.curve_id = spc.source_curve_def_id
			WHERE spc.as_of_date = @clm11_value 
				AND spc.maturity_date = @term_start
				AND di.source_deal_header_id = @source_deal_header_id
			GROUP BY di.source_deal_header_id, di.curve_id, spc.maturity_date

			INSERT INTO #child_deal_detail(term_start, term_end, parent_id, id)
			SELECT *, @source_deal_header_id parent_id, CASE WHEN @clm9_value = 2 THEN 'M' + CAST(DATEPART(MONTH, term_start) AS VARCHAR(2)) ELSE 'Q' + CAST(DATEPART(QUARTER, term_start) AS VARCHAR(2)) END id
			FROM dbo.[FNATermBreakdown]('m', @term_start, @term_end)

			IF NOT EXISTS(SELECT 1	FROM source_price_curve spc 
				INNER JOIN #deal_info di ON di.curve_id = spc.source_curve_def_id
				WHERE spc.as_of_date = @clm11_value AND spc.maturity_date = @term_start AND di.source_deal_header_id = @source_deal_header_id)
			BEGIN
				DELETE FROM #tmp_deals WHERE source_deal_header_id = @source_deal_header_id

				SET @err_status = 'e'
				SET @sql = '
					INSERT INTO #source_system_data_import_status (process_id, code, module, source, type, [description], deal_id ) 
					SELECT ''' + @process_id + ''', ''Error'', ''Cascade deal'', ''Cascade deal'', ''Error''
						, ''Cannot disintegrate ' + ISNULL(@deal_id, '') + ' deal with no curve value'', ' + CAST(@source_deal_header_id AS VARCHAR(100)) 
				EXEC spa_print @sql
				EXEC(@sql)
				EXEC spa_print 'Cannot disintegrate ', @deal_id
			END
		END
	FETCH NEXT FROM c INTO @source_deal_header_id, @deal_id, @parent_curve, @term_start, @term_end, @deal_id_status
	END
	CLOSE c
	DEALLOCATE c 

	SELECT DISTINCT [source_system_id], CAST([deal_id] AS VARCHAR(250)) [deal_id], [deal_date], [ext_deal_id], [physical_financial_flag], [structured_deal_id], [counterparty_id],
		   [entire_term_start], [entire_term_end], [source_deal_type_id], [deal_sub_type_type_id], [option_flag], [option_type], [option_excercise_type], [source_system_book_id1],
		   [source_system_book_id2], [source_system_book_id3], [source_system_book_id4], [description1], [description2], [description3], [deal_category_value_id], [trader_id],
		   [internal_deal_type_value_id], [internal_deal_subtype_value_id], [template_id], [header_buy_sell_flag], [broker_id], [generator_id], [status_value_id], [status_date],
		   [assignment_type_value_id], [compliance_year], [state_value_id], [assigned_date], [assigned_by], [generation_source], [aggregate_environment], [aggregate_envrionment_comment],
		   [rec_price], [rec_formula_id], [rolling_avg], [contract_id], [create_user], [create_ts], [update_user], [update_ts], [legal_entity], [internal_desk_id], [product_id],
		   [internal_portfolio_id], [commodity_id], [reference], [deal_locked], [close_reference_id], [block_type], [block_define_id], [granularity_id], [Pricing], [deal_reference_type_id],
		   [unit_fixed_flag], [broker_unit_fees], [broker_fixed_cost], [broker_currency_id], [deal_status], [term_frequency], [option_settlement_date], [verified_by], [verified_date],
		   [risk_sign_off_by], [risk_sign_off_date], [back_office_sign_off_by], [back_office_sign_off_date], [book_transfer_id], [confirm_status_type], [sub_book], [deal_rules], [confirm_rule],
		   [description4], [timezone_id], [pricing_type], CAST(0 AS INT) source_deal_header_id
	INTO #tmp_header
	FROM [dbo].[source_deal_header] 
	WHERE 1 = 2 

	IF OBJECT_ID('tempdb..#parent_source_deal_detail_id') IS NOT NULL 
		DROP TABLE #parent_source_deal_detail_id

	SELECT sdd.source_deal_detail_id, sdd.[source_deal_header_id], DATEDIFF(DAY, sdd.term_start, sdd.term_end) days_in_deal
		INTO #parent_source_deal_detail_id
	FROM source_deal_detail sdd
	INNER JOIN #curve_ids_value cidv ON cidv.source_deal_header_id = sdd.[source_deal_header_id]
	GROUP BY sdd.source_deal_detail_id, sdd.[source_deal_header_id],sdd.term_start, sdd.term_end
	--HAVING DATEDIFF(DAY, sdd.term_start, sdd.term_end) > 31 -- to exclude already cascaded deals
	
	IF OBJECT_ID('tempdb..#exclude_parent_source_deal_detail_id') IS NOT NULL 
		DROP TABLE #exclude_parent_source_deal_detail_id

	SELECT DISTINCT sdd.[source_deal_header_id] 
		INTO #exclude_parent_source_deal_detail_id
	FROM source_deal_detail sdd
	INNER JOIN #curve_ids_value cidv ON cidv.source_deal_header_id = sdd.[source_deal_header_id]
	GROUP BY sdd.source_deal_detail_id, sdd.[source_deal_header_id],sdd.term_start, sdd.term_end
	HAVING DATEDIFF(DAY, sdd.term_start, sdd.term_end) < 31 -- to exclude already cascaded deals

	--error handling
	INSERT INTO source_system_data_import_status (process_id, code, module, source, type, [description])
	SELECT process_id, code, module, source, type, [description]
	FROM #source_system_data_import_status
	WHERE deal_id NOT IN (SELECT source_deal_header_id FROM #exclude_parent_source_deal_detail_id)
	--select * from #exclude_parent_source_deal_detail_id
	--select * from #parent_source_deal_detail_id
	--select @clm9_value
	--select * from #curve_ids_value
	-- select * from #mapping
	----select * from #tmp_deals
	----select * from #exclude_parent_source_deal_detail_id
	--select * from #child_deal_detail
	-- return 

	BEGIN TRY
		BEGIN TRANSACTION
		INSERT INTO [dbo].[source_deal_header] (
			[source_system_id], [deal_id], [deal_date], [ext_deal_id], [physical_financial_flag], [structured_deal_id], [counterparty_id], [entire_term_start], [entire_term_end], [source_deal_type_id],
			[deal_sub_type_type_id], [option_flag], [option_type], [option_excercise_type], [source_system_book_id1], [source_system_book_id2], [source_system_book_id3], [source_system_book_id4],
			[description1], [description2], [description3], [deal_category_value_id], [trader_id], [internal_deal_type_value_id], [internal_deal_subtype_value_id], [template_id], [header_buy_sell_flag],
			[broker_id], [generator_id], [status_value_id], [status_date], [assignment_type_value_id], [compliance_year], [state_value_id], [assigned_date], [assigned_by], [generation_source], [aggregate_environment],
			[aggregate_envrionment_comment], [rec_price], [rec_formula_id], [rolling_avg], [contract_id], [create_user], [create_ts], [update_user], [update_ts], [legal_entity], [internal_desk_id], [product_id],
			[internal_portfolio_id], [commodity_id], [reference], [deal_locked], [close_reference_id], [block_type], [block_define_id], [granularity_id], [Pricing], [deal_reference_type_id], [unit_fixed_flag],
			[broker_unit_fees], [broker_fixed_cost], [broker_currency_id], [deal_status], [term_frequency], [option_settlement_date], [verified_by], [verified_date], [risk_sign_off_by], [risk_sign_off_date],
			[back_office_sign_off_by], [back_office_sign_off_date], [book_transfer_id], [confirm_status_type], [sub_book], [deal_rules], [confirm_rule], [description4], [timezone_id], [pricing_type]
		)
		OUTPUT inserted.[source_system_id], inserted.[deal_id], inserted.[deal_date], inserted.[ext_deal_id], inserted.[physical_financial_flag], inserted.[structured_deal_id], inserted.[counterparty_id],
			   inserted.[entire_term_start], inserted.[entire_term_end], inserted.[source_deal_type_id], inserted.[deal_sub_type_type_id], inserted.[option_flag], inserted.[option_type], inserted.[option_excercise_type],
			   inserted.[source_system_book_id1], inserted.[source_system_book_id2], inserted.[source_system_book_id3], inserted.[source_system_book_id4], inserted.[description1], inserted.[description2],
			   inserted.[description3], inserted.[deal_category_value_id], inserted.[trader_id], inserted.[internal_deal_type_value_id], inserted.[internal_deal_subtype_value_id], inserted.[template_id],
			   inserted.[header_buy_sell_flag], inserted.[broker_id], inserted.[generator_id], inserted.[status_value_id], inserted.[status_date], inserted.[assignment_type_value_id], inserted.[compliance_year],
			   inserted.[state_value_id], inserted.[assigned_date], inserted.[assigned_by], inserted.[generation_source], inserted.[aggregate_environment], inserted.[aggregate_envrionment_comment], inserted.[rec_price],
			   inserted.[rec_formula_id], inserted.[rolling_avg], inserted.[contract_id], inserted.[create_user], inserted.[create_ts], inserted.[update_user], inserted.[update_ts], inserted.[legal_entity],
			   inserted.[internal_desk_id], inserted.[product_id], inserted.[internal_portfolio_id], inserted.[commodity_id], inserted.[reference], inserted.[deal_locked], inserted.[close_reference_id],
			   inserted.[block_type], inserted.[block_define_id], inserted.[granularity_id], inserted.[Pricing], inserted.[deal_reference_type_id], inserted.[unit_fixed_flag], inserted.[broker_unit_fees],
			   inserted.[broker_fixed_cost], inserted.[broker_currency_id], inserted.[deal_status], inserted.[term_frequency], inserted.[option_settlement_date], inserted.[verified_by], inserted.[verified_date],
			   inserted.[risk_sign_off_by], inserted.[risk_sign_off_date], inserted.[back_office_sign_off_by], inserted.[back_office_sign_off_date], inserted.[book_transfer_id], inserted.[confirm_status_type],
			   inserted.[sub_book], inserted.[deal_rules], inserted.[confirm_rule], inserted.[description4], inserted.[timezone_id], inserted.[pricing_type], inserted.[source_deal_header_id]
		INTO #tmp_header
		SELECT DISTINCT
			   h.[source_system_id], m.deal_id, m.deal_date, td.source_deal_header_id, h.[physical_financial_flag], h.[structured_deal_id], h.[counterparty_id], m.term_start, m.term_end, h.[source_deal_type_id], 
			   h.[deal_sub_type_type_id], h.[option_flag], h.[option_type], h.[option_excercise_type], h.source_system_book_id1 , h.source_system_book_id2, h.source_system_book_id3, h.source_system_book_id4, 
			   h.[description1], h.[description2], m.curve_id, h.[deal_category_value_id], h.[trader_id], h.[internal_deal_type_value_id], h.[internal_deal_subtype_value_id], h.[template_id], h.[header_buy_sell_flag],
			   NULL [broker_id], h.[generator_id], h.[status_value_id], h.[status_date], h.[assignment_type_value_id], h.[compliance_year], h.[state_value_id], h.[assigned_date], h.[assigned_by], h.[generation_source], 
			   h.[aggregate_environment], h.[aggregate_envrionment_comment], h.[rec_price], h.[rec_formula_id], h.[rolling_avg],h.[contract_id], @user_name, GETDATE(),@user_name [update_user], GETDATE(), 
			   h.[legal_entity], h.[internal_desk_id], h.[product_id], h.[internal_portfolio_id], h.[commodity_id], h.[reference], h.[deal_locked], h.[close_reference_id], h.[block_type], h.[block_define_id], 
			   h.[granularity_id], h.[Pricing], h.[deal_reference_type_id], h.[unit_fixed_flag], h.[broker_unit_fees], h.[broker_fixed_cost], h.[broker_currency_id], h.[deal_status], h.[term_frequency], 
			   h.[option_settlement_date], h.[verified_by], h.[verified_date], h.[risk_sign_off_by], h.[risk_sign_off_date], h.[back_office_sign_off_by], h.[back_office_sign_off_date], h.[book_transfer_id], 
			   h.[confirm_status_type], h.[sub_book], h.[deal_rules], h.[confirm_rule], h.[source_deal_header_id] [description4], h.[timezone_id], h.[pricing_type]
		FROM #tmp_deals td
		INNER JOIN source_deal_header h ON h.source_deal_header_id = td.source_deal_header_id	 
		INNER JOIN #curve_ids_value cidv ON cidv.source_deal_header_id = h.[source_deal_header_id]
		CROSS JOIN #mapping m
		WHERE m.deal_id = h.deal_id + '_' + m.gran + '_CASCADE'
		ORDER BY m.term_start, h.source_deal_header_id 

		--select * from #tmp_header
		--rollback tran return 
 
		INSERT INTO [dbo].[source_deal_detail] (
			[source_deal_header_id], [term_start], [term_end], [Leg], [contract_expiration_date], [fixed_float_leg], [buy_sell_flag], [curve_id], [fixed_price], [fixed_price_currency_id],
			[option_strike_price], [deal_volume], [deal_volume_frequency], [deal_volume_uom_id], [block_description], [deal_detail_description], [formula_id], [volume_left], [settlement_volume],
			[settlement_uom], [create_user], [create_ts], [update_user], [update_ts], [price_adder], [price_multiplier], [settlement_date], [day_count_id], [location_id], [meter_id],
			[physical_financial_flag], [Booked], [process_deal_status], [fixed_cost], [multiplier], [adder_currency_id], [fixed_cost_currency_id], [formula_currency_id], [price_adder2],
			[price_adder_currency2], [volume_multiplier2] , [pay_opposite], [capacity], [settlement_currency], [standard_yearly_volume], [formula_curve_id], [price_uom_id],
			[category], [profile_code], [pv_party], [status], [lock_deal_detail], [detail_commodity_id], [position_uom]
		)
		SELECT DISTINCT th.[source_deal_header_id], cdd.[term_start] , cdd.[term_end], s.[Leg], cdd.[term_end] contract_expiration_date, s.[fixed_float_leg], s.[buy_sell_flag], m.[curve_id],
				ISNULL(cidv.curve_value, s.[fixed_price]) [fixed_price], s.[fixed_price_currency_id], s.[option_strike_price],
				CASE WHEN s.[deal_volume_frequency] = 't' THEN
						CASE WHEN m.parent_deal_curve_gran = 993 THEN ((DATEDIFF(DAY, th.[entire_term_start] , th.[entire_term_end]) + 1) * s.[deal_volume])/365
							 WHEN m.parent_deal_curve_gran = 991 THEN (DAY(EOMONTH(th.[entire_term_start])) * s.[deal_volume])/(DATEDIFF(DAY, m.parent_term_start, m.parent_term_end) + 1)
							 WHEN m.parent_deal_curve_gran = 3 THEN (DAY(EOMONTH(th.[entire_term_start])) * s.[deal_volume])/(DATEDIFF(DAY, m.parent_term_start, m.parent_term_end) + 1)
							 ELSE s.[deal_volume]
						END
					ELSE s.[deal_volume]
			   END [deal_volume],
			   s.[deal_volume_frequency], s.[deal_volume_uom_id], s.[block_description], s.[deal_detail_description], s.[formula_id], s.[volume_left], s.[settlement_volume], s.[settlement_uom], 
			   @user_name [create_user], GETDATE() [create_ts], @user_name [update_user], GETDATE() [update_ts], s.[price_adder], s.[price_multiplier], s.[settlement_date], s.[day_count_id], 
			   s. [location_id], s.[meter_id], s.[physical_financial_flag], s.[Booked], s.[process_deal_status], s.[fixed_cost], s.[multiplier], s.[adder_currency_id], s.[fixed_cost_currency_id], 
			   s.[formula_currency_id], s.[price_adder2], s.[price_adder_currency2], s.[volume_multiplier2] , s.[pay_opposite], s.[capacity], s.[settlement_currency], s.[standard_yearly_volume], 
			   s.[formula_curve_id], s.[price_uom_id], s.[category], s.[profile_code], s.[pv_party], s.[status], s.[lock_deal_detail]	, s.[detail_commodity_id], s.[position_uom]
		FROM [dbo].[source_deal_detail] s 
		INNER JOIN #tmp_header th ON th.ext_deal_id = s.source_deal_header_id 
		INNER JOIN #mapping m ON m.deal_id = th.deal_id
		INNER JOIN #child_deal_detail cdd ON cdd.parent_id = m.source_deal_header_id
			AND cdd.id = m.gran
		LEFT JOIN #curve_ids_value cidv ON cidv.source_deal_header_id = th.ext_deal_id
			
		/*
		UNION ALL  -- logic changed
		---- adding breakdown leg to the parent deal
		SELECT DISTINCT sdd.[source_deal_header_id], aa.[term_start], aa.[term_end], 1 [Leg], @clm11_value [contract_expiration_date], [fixed_float_leg]
			, sdd.[buy_sell_flag], sdd.[curve_id]
			, sdd.[fixed_price] [fixed_price] 
			, [fixed_price_currency_id],
			[option_strike_price], [deal_volume], [deal_volume_frequency], [deal_volume_uom_id], [block_description], [deal_detail_description], [formula_id], [volume_left], [settlement_volume],
			[settlement_uom], [create_user], [create_ts], [update_user], [update_ts], [price_adder], [price_multiplier], [settlement_date], [day_count_id], [location_id], [meter_id],
			[physical_financial_flag], [Booked], [process_deal_status], [fixed_cost], [multiplier], [adder_currency_id], [fixed_cost_currency_id], [formula_currency_id], [price_adder2],
			[price_adder_currency2], [volume_multiplier2] , [pay_opposite], [capacity], [settlement_currency], [standard_yearly_volume], [formula_curve_id], [price_uom_id],
			[category], [profile_code], [pv_party], [status], [lock_deal_detail], [detail_commodity_id], [position_uom]
 		FROM source_deal_detail sdd
		INNER JOIN #curve_ids_value cidv ON cidv.source_deal_header_id = sdd.[source_deal_header_id]
		CROSS APPLY(SELECT * FROM dbo.[FNATermBreakdown]('m', sdd.term_start, sdd.term_end)) aa
		WHERE aa.term_start NOT IN (SELECT sdd_inn.term_start FROM source_deal_detail sdd_inn 
									INNER JOIN #parent_source_deal_detail_id ps ON ps.source_deal_detail_id = sdd_inn.source_deal_detail_id
										AND sdd.source_deal_header_id NOT IN (SELECT source_deal_header_id FROM #exclude_parent_source_deal_detail_id))
			AND cidv.source_deal_header_id NOT IN (SELECT source_deal_header_id FROM #exclude_parent_source_deal_detail_id)
		*/
		
		--rollback tran
		--return 
				
		UPDATE sdd_inn 
		SET   --sdd_inn.term_end = dbo.FNAGetTermEndDate('m', sdd_inn.term_start, 0)	
			--, 
			sdd_inn.[contract_expiration_date] = @clm11_value
		FROM source_deal_detail sdd_inn
		INNER JOIN #parent_source_deal_detail_id ps ON ps.source_deal_detail_id = sdd_inn.source_deal_detail_id

		--rollback tran return

		UPDATE sdh
		SET 
			--sdh.deal_status = 5607
			sdh.pricing_type = 46701
		FROM source_deal_header sdh
		INNER JOIN #tmp_deals t ON t.source_deal_header_id = sdh.source_deal_header_id

		UPDATE sdd
		SET sdd.price_adder = ISNULL(cidv.curve_value, [fixed_price]) * -1
			, sdd.formula_curve_id = sdd.curve_id
			, sdd.physical_financial_flag = 'f'
			, sdd.location_id = NULL
			, sdd.shipper_code1 = NULL
			, sdd.shipper_code2 = NULL
		FROM source_deal_detail sdd
		INNER JOIN #curve_ids_value cidv ON cidv.source_deal_header_id = sdd.[source_deal_header_id]

 		DECLARE @volume_cut NUMERIC(38, 20)

		SELECT @volume_cut = volume_cut
		FROM (
			SELECT MAX(m.match_deal_volume_id) match_deal_volume_id, ISNULL(buy_outstanding_vol, sell_outstanding_vol) volume_cut
			FROM match_deal_volume m
			INNER JOIN source_deal_detail sdd ON IIF(sdd.buy_sell_flag = 'b', m.buy_source_deal_detail_id, m.sell_source_deal_detail_id) = sdd.source_deal_detail_id
			INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
			INNER JOIN dbo.SplitCommaSeperatedValues(@parent_deal_ids) i ON i.item = sdh.close_reference_id
			GROUP BY ISNULL(buy_outstanding_vol, sell_outstanding_vol)
		) a

		UPDATE sdd
		SET sdd.deal_volume = deal_volume - ISNULL(@volume_cut, 0)
		FROM source_deal_detail sdd
		INNER JOIN #tmp_header t ON sdd.source_deal_header_id = t.source_deal_header_id

		UPDATE sdd
		SET sdd.contract_expiration_date = ISNULL(hg.exp_date, sdd.term_end)
		FROM source_deal_detail sdd
		INNER JOIN #tmp_header t ON sdd.source_deal_header_id = t.source_deal_header_id
		INNER JOIN source_price_curve_Def spcd ON spcd.source_curve_def_id = sdd.curve_id AND spcd.granularity = 980
		INNER JOIN holiday_group hg ON hg.hol_group_value_id = spcd.exp_calendar_id AND hg.hol_date = sdd.term_start AND hg.hol_date_to = sdd.term_end

		--shipper code1
		--select * from  #tmp_header
		--/*
		--select *
		UPDATE sdd
		SET sdd.shipper_code1 = scmd1_default.shipper_code_mapping_detail_id
		FROM source_deal_detail sdd
		INNER JOIN #tmp_header t ON sdd.source_deal_header_id = t.source_deal_header_id
		INNER JOIN source_deal_header sddh ON sddh.source_deal_header_id = t.source_deal_header_id
		OUTER APPLY (SELECT counterparty_id FROM #tmp_header GROUP BY counterparty_id) sdh 
		INNER JOIN shipper_code_mapping scm ON scm.counterparty_id = sdh.counterparty_id						
		OUTER APPLY
		(SELECT scmd1_fil.shipper_code_mapping_detail_id FROM
			(SELECT * FROM
				(SELECT TOP 1 scmd1_def.shipper_code_mapping_detail_id , 
					scmd1_def.shipper_code1, 
					scmd1_def.effective_date,
					ROW_NUMBER() OVER (PARTITION BY shipper_code1 ORDER BY scmd1_def.effective_date DESC) rn
				FROM shipper_code_mapping_detail scmd1_def
				WHERE scmd1_def.location_id = sdd.location_id 
					AND scmd1_def.shipper_code_id = scm.shipper_code_id
					AND scmd1_def.effective_date <= CAST(sdd.term_start AS DATE)
					AND scmd1_def.is_active = 'y'
				ORDER BY scmd1_def.effective_date DESC
				) a WHERE rn =1
			) b 
			INNER JOIN shipper_code_mapping_detail scmd1_fil ON
				b.effective_date = scmd1_fil.effective_date  AND scmd1_fil.location_id = sdd.location_id 
				AND scmd1_fil.is_active = 'y' AND scmd1_fil.shipper_code_id = scm.shipper_code_id
			AND ISNULL(NULLIF(scmd1_fil.shipper_code1_is_default, ''), 'n') = 'y'
		) scmd1_default
		WHERE sddh.physical_financial_flag = 'p'

		--shipper code2
		UPDATE sdd
		SET shipper_code2 = scmd2_default.shipper_code_mapping_detail_id
		--select * 
		FROM source_deal_detail sdd
		INNER JOIN #tmp_header t ON sdd.source_deal_header_id = t.source_deal_header_id
		INNER JOIN source_deal_header sddh ON sddh.source_deal_header_id = t.source_deal_header_id
		OUTER APPLY (SELECT counterparty_id FROM #tmp_header GROUP BY counterparty_id) sdh 
		INNER JOIN shipper_code_mapping scm ON scm.counterparty_id = sdh.counterparty_id
		OUTER APPLY 
		( SELECT scmd2_fil.shipper_code_mapping_detail_id FROM
			(SELECT * FROM
				(SELECT TOP 1 scmd2_def.shipper_code_mapping_detail_id , 
					scmd2_def.shipper_code, 
					scmd2_def.effective_date,
					ROW_NUMBER() OVER (PARTITION BY scmd2_def.shipper_code ORDER BY scmd2_def.effective_date DESC) rn
				FROM shipper_code_mapping_detail scmd2_def
				WHERE scmd2_def.location_id = sdd.location_id 
					AND scmd2_def.effective_date <= CAST(sdd.term_start AS DATE)
					AND scmd2_def.shipper_code_id = scm.shipper_code_id
					AND scmd2_def.is_active = 'y'	
				ORDER BY scmd2_def.effective_date DESC
				) a WHERE rn =1
			) b 
			INNER JOIN shipper_code_mapping_detail scmd2_fil ON b.effective_date = scmd2_fil.effective_date 
			AND scmd2_fil.location_id = sdd.location_id  
				AND scmd2_fil.is_active = 'y' AND scmd2_fil.shipper_code_id = scm.shipper_code_id
			AND ISNULL(NULLIF(scmd2_fil.is_default, ''), 'n') = 'y'	
		) scmd2_default
		WHERE sddh.physical_financial_flag = 'p'
		 
		--- */
		UPDATE sdh
		SET sdh.close_reference_id = di.source_deal_header_id
		FROM source_deal_header sdh
		INNER JOIN #tmp_header t ON sdh.source_deal_header_id = t.source_deal_header_id
		INNER JOIN #deal_info di ON di.source_deal_header_id = sdh.source_deal_header_id

		--select * from  #tmp_header
		--rollback tran 
		--return 
		--select top 50 * from source_deal_header order by 1 desc 
		--rollback tran
		--return 

		COMMIT TRAN

		SET @after_update_process_table = dbo.FNAProcessTableName('after_insert_process_table', @user_name, @job_process_id)

		IF OBJECT_ID(@after_update_process_table) IS NOT NULL
		BEGIN
			EXEC('DROP TABLE ' + @after_update_process_table)
		END
				
		EXEC ('CREATE TABLE ' + @after_update_process_table + '(source_deal_header_id INT)')

		SET @sql = 'INSERT INTO ' + @after_update_process_table + '(source_deal_header_id) 
					SELECT source_deal_header_id FROM #tmp_header
					UNION 
					SELECT item source_deal_header_id FROM dbo.FNASplit(''' + @parent_deal_ids + ''', '','')'
		EXEC(@sql)
			
		SET @sql = 'spa_deal_insert_update_jobs ''i'', ''' + @after_update_process_table + ''''
		SET @job_name = 'spa_deal_insert_update_jobs_' + @job_process_id
 		
		EXEC spa_run_sp_as_job @job_name, @sql, 'spa_deal_insert_update_jobs', @user_name	

		IF @result_output IS NOT NULL
		BEGIN 
			SET @sql = ' SELECT * INTO ' + @result_output + ' FROM (
						SELECT ''Success'' ErrorCode, ''Deal Cascading'' Module, ''spa_cascade_deal'' Area, ''Success'' [Status]
								, ''Deal Cascading successfully completed.'' [Message], '''' Recommendation
						) z '
			EXEC(@sql)
		END 
		ELSE 
		BEGIN 
			SELECT 'Success' ErrorCode, 'Deal Cascading' Module, 'spa_cascade_deal' Area, 'Success' [Status], 'Deal Cascading successfully completed.' [Message], '' Recommendation
		END 
	END TRY
	BEGIN CATCH
		SET @error_message = ERROR_MESSAGE()
	
		IF @@TRANCOUNT > 0
			ROLLBACK

		SELECT 'Error' ErrorCode, 'Deal Cascading' Module, 'spa_cascade_deal' Area, 'Error' [Status], @error_message [Message], '' Recommendation
	END CATCH

	IF EXISTS(SELECT 1 FROM #tmp_header)
	BEGIN
		SET @sql = '
			INSERT INTO source_system_data_import_status(process_id, code, module, source, type, [description]) 
			SELECT DISTINCT ''' + @process_id + ''', ''success'', ''Cascade deals'', ''Cascade deals'', ''Success'', ''Cascade deal completed for index :'' + spcd.curve_id
			FROM #tmp_deals t
			INNER JOIN source_price_curve_Def spcd ON spcd.source_curve_def_id = t.curve_id
		'
		EXEC spa_print @sql
		EXEC(@sql)
	END

	SET @url = './dev/spa_html.php?__user_name__=' + @user_name + '&spa=EXEC spa_get_import_process_status ''' + @process_id + ''', ''' + @user_name + ''''        
	SET @url_desc = '<a target="_blank" href="' + @url + '">Deal Cascading process has been completed.</a> <br>' + CASE WHEN (@err_status = 'e') THEN ' (ERRORS found)' ELSE '' END       

	EXEC spa_message_board 'i', @user_name, NULL, 'Cascade Deals', @url_desc, '', '', @err_status, 'Cascade deal', NULL, @process_id
END
IF @flag = 'rewind_cascade'
BEGIN 
	BEGIN TRY 
		BEGIN TRAN

		IF OBJECT_ID('tempdb..#data_collection_reverse_cascade') IS NOT NULL
			DROP TABLE #data_collection_reverse_cascade

		IF OBJECT_ID('tempdb..#detail_collection_reverse_cascade') IS NOT NULL
			DROP TABLE #detail_collection_reverse_cascade

		-- collect cascaded deals
		;WITH REVERSE_CASCADE_CTE AS (
		SELECT sdh.source_deal_header_id, sdh.ext_deal_id 
		FROM source_deal_header sdh
		INNER JOIN dbo.FNASplit(@parent_deal_ids, ',') i ON i.item = sdh.source_deal_header_id
		UNION ALL
		SELECT e.source_deal_header_id, e.ext_deal_id
		FROM source_deal_header  e
		INNER JOIN REVERSE_CASCADE_CTE ecte ON CAST(ecte.source_deal_header_id AS VARCHAR(100)) = e.ext_deal_id
		)
		SELECT *, CASE WHEN source_deal_header_id IN(SELECT item FROM dbo.FNASplit(@parent_deal_ids, ',')) THEN 1 ELSE CASE WHEN ext_deal_id IN(@parent_deal_ids) THEN 2 ELSE 3 END END [level]
			INTO #data_collection_reverse_cascade
		FROM REVERSE_CASCADE_CTE

		--select * from #data_collection_reverse_cascade 
		--return 

		IF OBJECT_ID('tempdb..#min_parent_term_start') IS NOT NULL
			DROP TABLE #min_parent_term_start

		CREATE TABLE #min_parent_term_start (term_start DATETIME, term_end DATETIME, source_deal_header_id INT, leg INT, physical_financial_flag CHAR(1) COLLATE DATABASE_DEFAULT)

		-- get detail of cascasde deals
		SELECT sdh.source_deal_header_id, sdd.source_deal_detail_id, sdd.term_start, sdd.term_end, sdh.[level], sdd.leg, sdd.location_id, sdh.ext_deal_id
			INTO #detail_collection_reverse_cascade
		FROM #data_collection_reverse_cascade  sdh 
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
	
		--get parent deal term start and term end
		INSERT INTO #min_parent_term_start
		SELECT MIN(r.term_start) term_start, MAX(r.term_end) term_end, i.item, r.leg, MAX(sdh.physical_financial_flag) physical_financial_flag
		FROM #detail_collection_reverse_cascade r
		INNER JOIN dbo.FNASplit(@parent_deal_ids, ',') i ON i.item = r.source_deal_header_id
		INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = r.source_deal_header_id 
		GROUP BY i.item, r.leg, r.term_end
	
	 	--select * from #min_parent_term_start 
		--select * from #data_collection_reverse_cascade 
		--select * from #detail_collection_reverse_cascade
	
		DECLARE @report_position VARCHAR(1000)
		DECLARE @user_login_id VARCHAR(1000) = dbo.FNADBUser()
		SET @report_position = dbo.FNAProcessTableName('report_position', @user_login_id, @process_id)
 
		-- delete position of all parent leg except leg, also delete all child cascade deals position
		SET @sql = 'CREATE TABLE ' + @report_position + ' (source_deal_header_id INT, source_deal_detail_id INT)
				
					INSERT INTO ' + @report_position + ' 
					SELECT source_deal_header_id, source_deal_detail_id
					FROM (SELECT source_deal_header_id, source_deal_detail_id, term_start FROM #detail_collection_reverse_cascade dc
						EXCEPT 
						SELECT sdd.source_deal_header_id, sdd.source_deal_detail_id, sdd.term_start 
						FROM #detail_collection_reverse_cascade sdd
						INNER JOIN #min_parent_term_start m ON m.source_deal_header_id = sdd.source_deal_header_id
							AND sdd.Leg = m.leg
							AND sdd.term_start = m.term_start
					) z '
		EXEC spa_print @sql
		EXEC(@sql)
		--EXEC('select * from ' + @report_position)

		--select * from #min_parent_term_start
		--rollback tran
		--return 
		--position delete
		EXEC [dbo].[spa_maintain_transaction_job] @process_id, 7, NULL, @user_login_id

		--/*
		-- update parent leg 1 detail
		--SELECT 
		--	--* 
		UPDATE sdd
		SET		
			--sdd.term_start					= m.term_start,
			--sdd.term_end					= m.term_end,
			--sdd.contract_expiration_date	= m.term_end,
			sdd.price_adder 				= NULL,	
			sdd.formula_curve_id			= NULL
		FROM #min_parent_term_start m
		INNER JOIN source_deal_detail sdd ON m.source_deal_header_id = sdd.source_deal_header_id
			AND sdd.Leg = m.leg
			AND sdd.term_start = m.term_start

		-- update parent header
		UPDATE sdh
		SET 
			--* 
		sdh.pricing_type = 46700
		FROM #min_parent_term_start m
		INNER JOIN source_deal_detail sdd ON m.source_deal_header_id = sdd.source_deal_header_id
			AND sdd.Leg = m.leg
			AND sdd.term_start = m.term_start
		INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id

		--update detail physical_financial_flag
		UPDATE sdd
		SET sdd.physical_financial_flag = m.physical_financial_flag
		FROM #min_parent_term_start m
		INNER JOIN source_deal_detail sdd ON m.source_deal_header_id = sdd.source_deal_header_id
			AND sdd.Leg = m.leg
			AND sdd.term_start = m.term_start

		-- parent id location update start
		IF OBJECT_ID('tempdb..#parent_location_id') IS NOT NULL
			DROP TABLE #parent_location_id

		CREATE TABLE #parent_location_id (source_deal_header_id INT, location_id INT) 

		INSERT INTO #parent_location_id
		SELECT dc.ext_deal_id, MAX(sdd.location_id) location_id
		FROM #min_parent_term_start mp
		INNER JOIN #detail_collection_reverse_cascade dc ON CAST(mp.source_deal_header_id AS VARCHAR(1000)) = dc.ext_deal_id
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id =  dc.source_deal_detail_id
		WHERE mp.physical_financial_flag = 'p'
		GROUP BY dc.ext_deal_id

		--select * 
		UPDATE sdd
		SET sdd.location_id = pli.location_id
		FROM #parent_location_id pli 
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = pli.source_deal_header_id
		-- parent id location update end

		--*/
	
		--/*
		DECLARE @to_delete_deal_ids VARCHAR(MAX)

		--quaterly and monthly cascade deals to delete
		SELECT @to_delete_deal_ids = STUFF((SELECT DISTINCT ',' + CAST(tdi.source_deal_header_id AS VARCHAR(1000))
											FROM #data_collection_reverse_cascade tdi
 											WHERE  tdi.[level] > 1
											FOR XML PATH('')), 1, 1, '')

		--SELECT @to_delete_deal_ids
		EXEC spa_source_deal_header @flag = 'd', @deal_ids = @to_delete_deal_ids, @comments='cascasde rewind', @call_from = 'scheduling', @call_from_import = 'y'

		/*
		--delete other legs for parent
		SET @sql = '
					--SELECT * 
					DELETE sdd 
					FROM ' + @report_position + ' rp
					INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = rp.source_deal_detail_id 
					INNER JOIN dbo.FNASplit(''' + @parent_deal_ids + ''' , '','') i ON i.item = sdd.source_deal_header_id '

		EXEC spa_print @sql
		EXEC(@sql)
		*/
		SET @after_update_process_table = dbo.FNAProcessTableName('after_insert_process_table', @user_name, @job_process_id)

		IF OBJECT_ID(@after_update_process_table) IS NOT NULL
		BEGIN
			EXEC('DROP TABLE ' + @after_update_process_table)
		END
				
		EXEC ('CREATE TABLE ' + @after_update_process_table + '(source_deal_header_id INT)')

		SET @sql = 'INSERT INTO ' + @after_update_process_table + '(source_deal_header_id) 
					SELECT item source_deal_header_id FROM dbo.FNASplit(''' + @parent_deal_ids + ''', '','')'
		EXEC(@sql)
			
		SET @sql = 'spa_deal_insert_update_jobs ''i'', ''' + @after_update_process_table + ''''
		SET @job_name = 'spa_deal_insert_update_jobs_' + @job_process_id
 		
		EXEC spa_run_sp_as_job @job_name, @sql, 'spa_deal_insert_update_jobs', @user_name	

		SELECT 'Success' ErrorCode, 'Deal Cascading Rewind' Module, 'spa_cascade_deal' Area, 'Success' [Status], 'Deal Cascading Rewind successfully completed.' [Message], '' Recommendation
		--EXEC spa_message_board 'i', @user_name, NULL, 'Cascade Deals', @url_desc, '', '', 's', 'Cascade deal', NULL, @process_id

		--*/
		COMMIT TRAN 
		--ROLLBACK TRAN 
	END TRY 
	BEGIN CATCH
 		SET @error_message = ERROR_MESSAGE()
	
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN 

		SELECT 'Error' ErrorCode, 'Deal Cascading Rewind' Module, 'spa_cascade_deal' Area, 'Error' [Status], @error_message [Message], '' Recommendation
	END CATCH
END

GO
