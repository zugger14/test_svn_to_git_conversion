
IF EXISTS (SELECT 1 FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[spa_Create_MTM_Measurement_Report]') AND [type] IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_Create_MTM_Measurement_Report]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[spa_Create_MTM_Measurement_Report] 
	@as_of_date VARCHAR(50), 
	@sub_entity_id VARCHAR(MAX), 
	@strategy_entity_id VARCHAR(MAX) = NULL, 
	@book_entity_id VARCHAR(MAX) = NULL, 
	@discount_option CHAR(1), 
	@settlement_option CHAR(1), 
	@report_type CHAR(1), 
	@summary_option CHAR(1),
	@link_id VARCHAR(500) = NULL,
	@round_value VARCHAR(1) = '0',
	@legal_entity VARCHAR(50) = NULL,
	@what_if VARCHAR(10)=NULL,
	@source_deal_header_id VARCHAR(500)=NULL,
	@deal_id VARCHAR(500)=NULL,	
	@term_start DATETIME=NULL,
	@term_end DATETIME=NULL,
	@batch_process_id VARCHAR(50)=NULL,	
	@batch_report_param VARCHAR(1000)=NULL,
	@enable_paging INT=0,  --'1'=enable, '0'=disable
	@page_size INT =NULL,
	@page_no INT=NULL

AS

/**************************TEST CODE START************************				
DECLARE	@as_of_date	VARCHAR(50)	=	'2015-03-31'
DECLARE	@sub_entity_id	VARCHAR(MAX)	=	'1403,1523,1350,1188,1530,1266,1281,1278,1356,1393,1537,1486,1301,1332,1261,1544,1318,1466,1249'
DECLARE	@strategy_entity_id	VARCHAR(MAX)	=	'1404,1407,1410,1413,1415,1419,1423,1426,1428,1437,1442,1524,1351,1352,1189,1190,1531,1532,1267,1268,1272,1282,1283,1284,1357,1520,1394,1396,1398,1400,1538,1487,1489,1302,1313,1333,1342,1545,1547,1319,1325,1467,1471,1250'
DECLARE	@book_entity_id	VARCHAR(MAX)	=	'1405,1406,1408,1411,1414,1416,1418,1440,1441,1498,1500,1501,1502,1503,1508,1420,1424,1495,1496,1427,1429,1438,1439,1443,1525,1519,1354,1241,1246,1259,1243,1244,1245,1247,1248,1260,1533,1534,1269,1270,1273,1292,1293,1294,1295,1296,1297,1299,1300,1288,1289,1290,1291,1285,1286,1287,1358,1359,1360,1521,1395,1397,1399,1401,1402,1539,1540,1488,1490,1303,1304,1305,1306,1307,1309,1310,1311,1312,1497,1314,1315,1316,1317,1337,1339,1512,1355,1513,1535,1546,1548,1320,1321,1322,1323,1324,1522,1326,1327,1328,1329,1330,1331,1468,1469,1470,1472,1473,1474,1251'
DECLARE	@discount_option	CHAR(1)	=	'd'
DECLARE	@settlement_option	CHAR(1)	=	'a'
DECLARE	@report_type	CHAR(1)	=	'a'
DECLARE	@summary_option	CHAR(1)	=	'b'
DECLARE	@link_id	VARCHAR(500)	=	NULL
DECLARE	@round_value	VARCHAR(1)	=	'2'
DECLARE	@legal_entity	VARCHAR(50)	=	NULL
DECLARE	@what_if	VARCHAR(10)	=	NULL
DECLARE	@source_deal_header_id	VARCHAR(500)	=	NULL
DECLARE	@deal_id	VARCHAR(500)	=	NULL
DECLARE	@term_start	DATETIME	=	NULL
DECLARE	@term_end	DATETIME	=	NULL
DECLARE	@batch_process_id	VARCHAR(50)		
DECLARE	@batch_report_param	VARCHAR(1000)		
DECLARE	@enable_paging	INT		
DECLARE	@page_size	INT		
DECLARE	@page_no	INT		
IF OBJECT_ID(N'tempdb..#aaaaaa', N'U') IS NOT NULL
	DROP TABLE	#aaaaaa			
IF OBJECT_ID(N'tempdb..#RMV', N'U') IS NOT NULL
	DROP TABLE	#RMV			
--**************************TEST CODE END************************/				
SET NOCOUNT ON

DECLARE @Sql_Select VARCHAR(5000)
DECLARE @Sql_From VARCHAR(5000)
DECLARE @Sql_Where VARCHAR(5000)
DECLARE @Sql_Where1 VARCHAR(5000)
DECLARE @Sql_GpBy VARCHAR(5000)
DECLARE @Sql_OrderBy VARCHAR(5000)

SET @Sql_OrderBy = ''

--*****************For batch processing********************************    
IF @term_start IS NOT NULL AND @term_end IS NULL
	SET @term_end = @term_start
IF @term_start IS NULL AND @term_end IS NOT NULL
	SET @term_start = @term_end

DECLARE @str_batch_table VARCHAR(MAX), @str_get_row_number VARCHAR(100)
DECLARE @temptablename VARCHAR(128), @user_login_id VARCHAR(50), @flag CHAR(1)
DECLARE @is_batch BIT
DECLARE @sql_stmt VARCHAR(5000)

SET @str_batch_table=''
SET @str_get_row_number=''

IF @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL
	SET @is_batch = 1
ELSE
	SET @is_batch = 0
	
IF (@is_batch = 1 OR @enable_paging = 1)
BEGIN
	IF (@batch_process_id IS NULL)
		SET @batch_process_id = REPLACE(NEWID(), '-', '_')
		
	SET @user_login_id = dbo.FNADBUser()	
	SET @temptablename = dbo.FNAProcessTableName('batch_report', @user_login_id, @batch_process_id)
	SET @str_batch_table=', ROWID = IDENTITY(INT,1,1) INTO ' + @temptablename
	
	IF @enable_paging = 1
	BEGIN
		IF @page_size IS NOT NULL
		BEGIN
			DECLARE @row_to INT, @row_from INT
			SET @row_to = @page_no * @page_size

			IF @page_no > 1 
				SET @row_from = ((@page_no-1) * @page_size)+1
			ELSE
				SET @row_from = @page_no
			SET @sql_stmt = ''

			SELECT @sql_stmt = @sql_stmt + ',[' + [name] + ']' 
			FROM adiha_process.sys.columns 
			WHERE [OBJECT_ID] = OBJECT_ID(@temptablename) 
				AND [name] <> 'ROWID' 
			ORDER BY column_id
			
			SET @sql_stmt = SUBSTRING(@sql_stmt,2,LEN(@sql_stmt))
			
			SET @sql_stmt = 'SELECT ' + @sql_stmt + '
							 FROM ' + @temptablename   + ' 
							 WHERE rowid BETWEEN ' + CAST(@row_from AS VARCHAR(25)) + ' 
								AND '+ CAST(@row_to AS VARCHAR(25)) 
			
			EXEC (@sql_stmt)
			RETURN
		END
	END
END

DECLARE @Sql VARCHAR(MAX), @deal_id1 VARCHAR(1000)

IF @deal_id = '' OR @deal_id IS NULL
	SET @deal_id1 = NULL
ELSE
BEGIN
	SET @deal_id1 = REPLACE(@deal_id, ' ', '')
	SET @deal_id1 = '''' + REPLACE(@deal_id1, ',', ''',''') + ''''
END

--END of Retrieve Results IN Temp Table

SELECT * 
INTO #RMV 
FROM report_measurement_values 
WHERE 1 = 2

SET @Sql_Select = ' 
					INSERT INTO #RMV 
					SELECT RMV.* 
					FROM ' + dbo.FNAGetProcessTableName(@as_of_date, 'report_measurement_values') + ' RMV 
						INNER JOIN fas_books fb 
							ON fb.fas_book_id = RMV.book_entity_id 
						INNER JOIN fas_strategy FS 
							ON RMV.strategy_entity_id = FS.fas_strategy_id 
				  '

SET @Sql_Where1 = ' WHERE RMV.as_of_date = ''' + @as_of_date  +''''
SET @Sql_Where = ' AND RMV.link_deal_flag = ''d'' AND (RMV.sub_entity_id IN( ' + @sub_entity_id + ')) '

IF @strategy_entity_id IS NOT NULL
	SET @Sql_Where = @Sql_Where + ' AND (RMV.strategy_entity_id IN(' + @strategy_entity_id + ' ))'

IF @book_entity_id IS NOT NULL
	SET @Sql_Where = @Sql_Where + ' AND (RMV.book_entity_id IN(' + @book_entity_id + '))'

IF @link_id IS NOT NULL
	SET @Sql_Where = @Sql_Where + ' AND (RMV.link_id IN (' + @link_id + ') AND RMV.link_deal_flag = ''d'')' 	

IF @legal_entity IS NOT NULL
	SET @Sql_Where = @Sql_Where + ' AND (fb.legal_entity IN(' + @legal_entity + ')) '

IF @settlement_option = 'f'
	SET @Sql_Where = @Sql_Where + ' AND rmv.term_month > ''' + @as_of_date  + ''''
ELSE IF @settlement_option = 'c'
	SET @Sql_Where = @Sql_Where + ' AND rmv.term_month >= ''' + dbo.FNAGetContractMonth(@as_of_date)  + ''''
ELSE IF @settlement_option = 's'
	SET @Sql_Where = @Sql_Where + ' AND rmv.term_month <= ''' + dbo.FNAGetContractMonth(@as_of_date) + ''''

IF @report_type = 'c' 
	SET @Sql_Where = @Sql_Where + ' AND FS.hedge_type_value_id = 150'

IF @report_type = 'f' 
	SET @Sql_Where = @Sql_Where + ' AND FS.hedge_type_value_id = 151'

IF @report_type = 'm' 
	SET @Sql_Where = @Sql_Where + ' AND FS.hedge_type_value_id = 152'

IF @report_type IS NULL OR  @report_type = 'a'
	SET @Sql_Where = @Sql_Where + ' AND FS.hedge_type_value_id IN (150, 151, 152)'

IF (@term_start IS NOT NULL)
	SET @Sql_Where = @Sql_Where +' AND CONVERT(VARCHAR(10), rmv.term_month, 120) >= ''' + CONVERT(VARCHAR(10), @term_start, 120) + ''''

IF (@term_end IS NOT NULL)
	SET @Sql_Where = @Sql_Where +' AND CONVERT(VARCHAR(10), rmv.term_month, 120)<= ''' + CONVERT(VARCHAR(10), @term_end, 120) + ''''

EXEC (@Sql_Select + @Sql_Where1 + @Sql_Where)

SET @Sql_Select = '
					INSERT INTO #RMV 
					SELECT RMV.* 
					FROM report_measurement_values_expired RMV 
						INNER JOIN fas_books fb 
							ON fb.fas_book_id = RMV.book_entity_id 
						INNER JOIN fas_strategy FS 
							ON RMV.strategy_entity_id = FS.fas_strategy_id 
				  '

SET @Sql_Where1 = ' WHERE (RMV.as_of_date < CONVERT(DATETIME, ''' + @as_of_date  + ''', 102)) '

EXEC (@Sql_Select + @Sql_Where1 + @Sql_Where)

--END of Retrieve Results IN Temp Table

SET @Sql_Select = 'SELECT MAX(dbo.FNADateFormat(RMV.valuation_date)) [Valuation Date], 
						  PH.entity_name AS Sub, 
						  PH2.entity_name AS Strategy, 
						  PH3.entity_name AS Book, '

IF @summary_option = 'd'
	SET @Sql_Select = @Sql_Select  + ' dbo.FNAHyperLinkText(10131010,
									   (CAST(RMV.link_id AS VARCHAR) + '' ('' + sdh.deal_id +  '')''), 
									   RMV.link_id) AS [DealID],
									   CASE WHEN(RMV.hedge_item_flag =''h'') THEN ''Derivative'' ELSE ''Item'' END AS [HedgeOrItem], 
									   dbo.FNAContractMonthFormat(rmv.term_month) AS [Expiration],
									 '

--IF @discount_option='u'
	SET @Sql_Select = @Sql_Select  + ' 
										ROUND(SUM(RMV.' + @discount_option + '_hedge_mtm), ' + @round_value + ') AS [CFV], 
										ROUND(SUM(RMV.' + @discount_option + '_hedge_st_asset), ' + @round_value + ') AS [STAsset(+DB)], 
										ROUND(SUM(RMV.' + @discount_option + '_hedge_lt_asset), ' + @round_value + ') AS [LTAsset(+DB)], 
										ROUND(SUM(RMV.' + @discount_option + '_hedge_st_liability), ' + @round_value + ') AS [STLiability(+CR)], 
										ROUND(SUM(RMV.' + @discount_option + '_hedge_lt_liability), ' + @round_value + ')  AS [LTLiability(+CR)], 
										ROUND(SUM(RMV.' + @discount_option + '_total_pnl), ' + @round_value + ') AS [PNL(+CR)], 
										ROUND(SUM(RMV.' + @discount_option + '_pnl_settlement), ' + @round_value + ') AS [Earnings(+CR)],
										ROUND(SUM(rmv.' + @discount_option + '_cash), ' + @round_value + ') AS [Cash(+DB)] '

SET @Sql_From = ' FROM portfolio_hierarchy PH 
				  INNER JOIN #RMV RMV 
					 ON PH.entity_id = RMV.sub_entity_id 
				  INNER JOIN portfolio_hierarchy PH2 
					 ON RMV.strategy_entity_id = PH2.entity_id 
				  INNER JOIN portfolio_hierarchy PH3 
					 ON RMV.book_entity_id = PH3.entity_id 
				  INNER JOIN source_deal_header sdh 
					 ON sdh.source_deal_header_id = RMV.link_id 
				WHERE 1 = 1
				' +
CASE 
	WHEN (@source_deal_header_id IS NOT NULL) THEN ' AND sdh.source_deal_header_id IN (' + @source_deal_header_id + ') AND link_deal_flag = ''d''' 
	ELSE ''
END +
CASE 
	WHEN (@deal_id1 IS NOT NULL) THEN ' AND sdh.deal_id IN (' + @deal_id1 + ') AND link_deal_flag=''d''' 
	ELSE '' 
END

SET @Sql_GpBy = ' GROUP BY PH.entity_name, PH2.entity_name, PH3.entity_name'
SET @Sql_OrderBy = ' ORDER BY PH.entity_name, PH2.entity_name, PH3.entity_name'

IF @summary_option = 'd'
BEGIN
	SET @Sql_GpBy = @Sql_GpBy  + ', RMV.link_id, sdh.deal_id, RMV.hedge_item_flag, RMV.term_month'
	SET @Sql_OrderBy = @Sql_OrderBy  + ', RMV.link_id, sdh.deal_id, RMV.term_month'
END

IF @summary_option = 'm' 
BEGIN
	CREATE TABLE #temp_final(
		[Valuation Date] VARCHAR(20) COLLATE DATABASE_DEFAULT ,
		[Sub] VARCHAR(100) COLLATE DATABASE_DEFAULT   NOT NULL,
		[Strategy] VARCHAR(100) COLLATE DATABASE_DEFAULT   NOT NULL,
		[Book] VARCHAR(100) COLLATE DATABASE_DEFAULT   NOT NULL,
		[Der/Item] VARCHAR(4) COLLATE DATABASE_DEFAULT   NOT NULL,
		[Deal Ref ID] VARCHAR(50) COLLATE DATABASE_DEFAULT   NULL,
		[Deal ID] VARCHAR(500) COLLATE DATABASE_DEFAULT   NULL,
		[Rel ID] VARCHAR(500) COLLATE DATABASE_DEFAULT   NULL,
		[DeDesig Rel ID] VARCHAR(500) COLLATE DATABASE_DEFAULT   NULL,
		[Rel Type] VARCHAR(500) COLLATE DATABASE_DEFAULT   NULL,
		[Counterparty] VARCHAR(100) COLLATE DATABASE_DEFAULT   NOT NULL,
		[Deal Date] VARCHAR(50) COLLATE DATABASE_DEFAULT   NULL,
		[Rel Eff Date] VARCHAR(50) COLLATE DATABASE_DEFAULT   NULL,
		[DeDesig Date] VARCHAR(50) COLLATE DATABASE_DEFAULT   NULL,
		[Term] VARCHAR(50) COLLATE DATABASE_DEFAULT   NULL,
		[%] FLOAT NOT NULL,
		[Total Volume] FLOAT NOT NULL,
		[Volume Used] FLOAT NOT NULL,
		[UOM] VARCHAR(100) COLLATE DATABASE_DEFAULT   NULL,
		[Index] VARCHAR(100) COLLATE DATABASE_DEFAULT   NULL,
		[DF] FLOAT NOT NULL,
		[Deal Price] FLOAT NULL,
		[Market Price] FLOAT NULL,
		[Inception Price] FLOAT NULL,
		[Currency] VARCHAR(100) COLLATE DATABASE_DEFAULT   NULL,
		[Cum FV] FLOAT NULL,
		[Cum INT FV] FLOAT NULL,
		[Incpt FV] FLOAT NULL,
		[Incpt INT FV] FLOAT NULL,
		[Cum Hedge FV] FLOAT NULL,
		[Hedge AOCI Ratio] FLOAT NULL,
		[Dollar Offset Ratio] FLOAT NULL,
		[Test] VARCHAR(509) COLLATE DATABASE_DEFAULT   NULL,
		[AOCI] FLOAT NULL,
		[PNL] FLOAT NULL,
		[AOCI Released] FLOAT NOT NULL,
		[PNL Settled] FLOAT NULL)

	INSERT INTO #temp_final 
	EXEC spa_msmt_link_drill_down @discount_option, @as_of_date, NULL, @settlement_option, @sub_entity_id, @strategy_entity_id, 
								  @book_entity_id, @round_value, @legal_entity, NULL, @link_id, @source_deal_header_id, @deal_id, 
								  @report_type, 'y'
	
	EXEC('SELECT * ' + @str_get_row_number+' '+ @str_batch_table +  ' FROM #temp_final')
END
ELSE
BEGIN 
	SET @Sql = @Sql_Select + @str_batch_table +  @Sql_From + @Sql_GpBy + @Sql_OrderBy 
	EXEC(@Sql)
END

--*****************FOR BATCH PROCESSING**********************************     
IF @is_batch = 1
BEGIN
	SELECT @str_batch_table = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL)         
	EXEC(@str_batch_table)
	DECLARE @report_name VARCHAR(100)        

	SET @report_name='Run Measurement Report'        
	        
	SELECT @str_batch_table = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, GETDATE(), 'spa_Create_MTM_Measurement_Report', @report_name)         
	EXEC(@str_batch_table)        
	RETURN
END

IF @enable_paging = 1
BEGIN
	IF @page_size IS NULL
	BEGIN
		SET @Sql_Select = 'SELECT count(*) TotalRow, ''' + @batch_process_id + ''' process_id  FROM ' + @temptablename
		EXEC(@Sql_Select)
	END
END 
--********************************************************************
