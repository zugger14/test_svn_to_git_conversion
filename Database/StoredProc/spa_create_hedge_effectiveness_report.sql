
IF  EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_create_hedge_effectiveness_report]') AND [type] IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_create_hedge_effectiveness_report]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[spa_create_hedge_effectiveness_report](
	@sub_entity_id	VARCHAR(MAX), 
	@strategy_entity_id VARCHAR(MAX), 
	@book_entity_id VARCHAR(MAX),
	@as_of_date VARCHAR(20), 
	@link_id VARCHAR(50) = NULL, 
	@link_id_to VARCHAR(50) = NULL, 
	@link_desc VARCHAR(250) = NULL, 
	@hedge_mtm VARCHAR(1) = 'h', 
	@disc_undis VARCHAR(1) = 'd', 
	@rounding INT = 2,
	@summary_detail VARCHAR(1) = 's',  --s means summary, d means detailed, j IS fo journal entries
	@source_deal_header_id INT=NULL, 
	@deal_id VARCHAR(255)=NULL,
	@batch_process_id VARCHAR(50) = NULL,
	@batch_report_param VARCHAR(500) = NULL   ,
	@enable_paging INT = NULL,   --'1'=enable, '0'=disable
	@page_size INT = NULL,
	@page_no INT = NULL
)

AS

/***************************Test data BEGIN**************************************
DECLARE @sub_entity_id VARCHAR(MAX)
DECLARE @strategy_entity_id VARCHAR(MAX)
DECLARE @book_entity_id VARCHAR(MAX)
DECLARE @link_id VARCHAR(50)
DECLARE @link_id_to VARCHAR(50)
DECLARE @link_desc VARCHAR(250)
DECLARE @hedge_mtm VARCHAR(1)
DECLARE @as_of_date VARCHAR(20)
DECLARE @disc_undis VARCHAR(1)
DECLARE @rounding INT
DECLARE @summary_detail VARCHAR(1)
DECLARE @source_deal_header_id INT
DECLARE @deal_id VARCHAR(255)
DECLARE @batch_process_id VARCHAR(50)
DECLARE @batch_report_param VARCHAR(500)
DECLARE @enable_paging INT
DECLARE @page_size INT
DECLARE @page_no INT

SET @sub_entity_id = '1471,1461,1341,1334,1275,1249,1323,1188,1301,1441,1266,1283,1305,1292,1328,1329,1256,1253,1492,1499,1261,1509,1508,1297,1376,1468,1488,1438,1316,1278'
SET @strategy_entity_id = '1472,1462,1342,1367,1393,1399,1452,1464,1467,1480,1335,1336,1337,1381,1387,1402,1477,1478,1276,1250,1324,1189,1190,1281,1295,1302,1384,1447,1442,1267,1268,1272,1284,1306,1293,1330,1332,1257,1254,1493,1495,1497,1500,1262,1264,1475,1298,1391,1412,1433,1377,1469,1489,1439,1317,1374,1389,1395,1425,1506,1520,1521,1522,1523,1536,1279'
SET @book_entity_id = '1473,1474,1463,1372,1368,1369,1394,1400,1453,1454,1465,1466,1487,1338,1339,1340,1382,1383,1388,1403,1479,1277,1251,1274,1325,1241,1246,1259,1243,1244,1245,1247,1248,1260,1282,1296,1303,1308,1309,1315,1364,1371,1385,1448,1269,1270,1273,1285,1286,1307,1294,1313,1314,1331,1333,1258,1255,1494,1496,1498,1501,1263,1265,1450,1476,1299,1386,1392,1397,1398,1401,1404,1411,1413,1436,1378,1380,1470,1490,1440,1318,1319,1320,1321,1322,1370,1373,1444,1445,1491,1375,1390,1396,1426,1507,1524,1525,1526,1527,1528,1529,1537,1280'
SET @as_of_date = '2015-03-31'
SET @link_id = NULL
SET @link_id_to = NULL
SET @link_desc = NULL
SET @hedge_mtm = 'h'
SET @disc_undis = 'd'
SET @rounding = '2'
SET @summary_detail = 's'
SET @source_deal_header_id = NULL
SET @deal_id = NULL

IF OBJECT_ID('tempdb..#books') IS NOT NULL
  DROP TABLE #books

IF OBJECT_ID('tempdb..#details') IS NOT NULL
  DROP TABLE #details

IF OBJECT_ID('tempdb..#deal_filter') IS NOT NULL
  DROP TABLE #deal_filter

IF OBJECT_ID('tempdb..#temp_summary_table') IS NOT NULL
  DROP TABLE #temp_summary_table

IF OBJECT_ID('tempdb..#temp_volume') IS NOT NULL
  DROP TABLE #temp_volume

IF OBJECT_ID('tempdb..#temp_deal_volume') IS NOT NULL
  DROP TABLE #temp_deal_volume
--*******************Test data END**************************************/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET NOCOUNT ON
SET CONCAT_NULL_YIELDS_NULL ON


DECLARE @Sql_WhereB VARCHAR(MAX)
DECLARE @Sql_SelectB VARCHAR(MAX)
DECLARE @Sql_Select VARCHAR(MAX)
DECLARE @str_batch_table VARCHAR(MAX), @str_get_row_number VARCHAR(100)
DECLARE @temptablename VARCHAR(500), @user_login_id VARCHAR(50), @flag CHAR(1)
DECLARE @is_batch BIT
DECLARE @report_measurement_values VARCHAR(128)
DECLARE @sql_stmt VARCHAR(8000)


IF @link_id IS NOT NULL AND @link_id_to IS NULL
	SET @link_id_to=@link_id
IF @link_id IS NULL AND @link_id_to IS NOT NULL
	SET @link_id=@link_id_to

SET @str_batch_table = ''
SET @str_get_row_number=''
SET @report_measurement_values=dbo.FNAGetProcessTableName(@as_of_date, 'report_measurement_values')

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
	SET @str_batch_table=' INTO ' + @temptablename
	SET @str_get_row_number = ', ROWID=IDENTITY(INT,1,1)'


	IF @enable_paging = 1
	BEGIN
		IF @page_size IS NOT NULL
		BEGIN
			DECLARE @row_to INT, @row_from INT
			SET @row_to = @page_no * @page_size
		
			IF @page_no > 1 
				SET @row_from = ((@page_no-1) * @page_size) + 1
			ELSE
				SET @row_from = @page_no

			SET @sql_stmt = ''
			
			SELECT @sql_stmt = @sql_stmt + ',[' + [name] + ']' FROM adiha_process.sys.columns WHERE [object_id] = OBJECT_ID(@temptablename) AND [name] <> 'ROWID' ORDER BY column_id
				 
			SET @sql_stmt = SUBSTRING(@sql_stmt, 2, LEN(@sql_stmt))			
			SET @sql_stmt='SELECT ' + @sql_stmt + ' FROM '+ @temptablename   + ' WHERE rowid BETWEEN '+ CAST(@row_from AS VARCHAR(50)) +' AND '+ CAST(@row_to AS VARCHAR(50)) 

			EXEC(@sql_stmt)
			RETURN
		END
	END
END

SET @Sql_WhereB = ''        

CREATE TABLE #books (fas_book_id INT)

SET @Sql_SelectB = '
INSERT INTO #books
SELECT DISTINCT book.entity_id fas_book_id 
FROM portfolio_hierarchy book (nolock) 
	INNER JOIN Portfolio_hierarchy stra (nolock) 
	ON book.parent_entity_id = stra.entity_id 
WHERE 1 = 1 
'  
              
IF @sub_entity_id IS NOT NULL        
  SET @Sql_WhereB = @Sql_WhereB + ' AND stra.parent_entity_id IN  ( ' + @sub_entity_id + ') '         

 IF @strategy_entity_id IS NOT NULL        
  SET @Sql_WhereB = @Sql_WhereB + ' AND (stra.entity_id IN(' + @strategy_entity_id + ' ))'        

 IF @book_entity_id IS NOT NULL        
  SET @Sql_WhereB = @Sql_WhereB + ' AND (book.entity_id IN(' + @book_entity_id + ')) '        
        
SET @Sql_SelectB=@Sql_SelectB+@Sql_WhereB        
     
EXEC (@Sql_SelectB)


CREATE TABLE #details(
	[as_of_date] DATETIME NOT NULL,
	fas_subsidiary_id INT NULL,
	fas_strategy_id INT NULL,
	fas_book_id INT NULL, 
	[link_id] INT NULL,
	[original_link_id] INT NULL,
	[link_type] VARCHAR(5) COLLATE DATABASE_DEFAULT  NOT NULL,
	[designation_type] VARCHAR(26) COLLATE DATABASE_DEFAULT  NOT NULL,
	[real_link_type] VARCHAR(5) COLLATE DATABASE_DEFAULT  NOT NULL,
	[link_effective_date] DATETIME NULL,
	[Book] VARCHAR(302) COLLATE DATABASE_DEFAULT  NULL,
	[hedge_volume] FLOAT NULL, 
	[item_volume] FLOAT NULL,
	[u_hedge_mtm] FLOAT NULL,
	[d_hedge_mtm] FLOAT NULL,
	[u_item_mtm] FLOAT NULL,
	[d_item_mtm] FLOAT NULL,
	[u_aoci] FLOAT NOT NULL,
	[d_aoci] FLOAT NOT NULL,
	[u_pnl_ineffectiveness] FLOAT NULL,
	[d_pnl_ineffectiveness] FLOAT NULL,
	[u_pnl_extrinsic] FLOAT NOT NULL,
	[d_pnl_extrinsic] FLOAT NULL,
	[link_type_value_id] [INT] NULL,
	[mtm_hedge] VARCHAR(1) COLLATE DATABASE_DEFAULT  NOT NULL,
	[dol_offset] FLOAT NULL,
	[link_desc] VARCHAR(100) COLLATE DATABASE_DEFAULT
) 

SELECT
	fld.link_id,
	hedge_or_item,
	SUM (sdd.deal_volume *
						CASE
							WHEN (sdd.buy_sell_flag = 's') THEN -1
							ELSE 1
						END
		) total_volume,
	SUM (sdd.deal_volume * fld.percentage_included *
													CASE
													WHEN (sdd.buy_sell_flag = 's') THEN -1
													ELSE 1
													END
		) volume_used,
		MAX(flh.link_effective_date) link_effective_date
INTO #temp_volume
FROM #books bk
	INNER JOIN fas_link_header flh
	  ON flh.fas_book_id = bk.fas_book_id
	INNER JOIN fas_link_detail fld
	  ON fld.link_id = flh.link_id
	INNER JOIN source_deal_detail sdd
	  ON sdd.source_deal_header_id = fld.source_deal_header_id
		AND sdd.leg = 1
WHERE sdd.term_start > @as_of_date
	AND flh.link_effective_date <= @as_of_date
GROUP BY fld.link_id, hedge_or_item

SET @Sql_SelectB =  '
		INSERT INTO #details
		SELECT
			rmv.as_of_date, 
			rmv.sub_entity_id, 
			rmv.strategy_entity_id, 
			rmv.book_entity_id,
		COALESCE(flh.original_link_id, flh.link_id, rmv.link_id) link_id, 
			rmv.link_id original_link_id,
			rmv.link_deal_flag,
		MAX(
			CASE WHEN (rmv.link_type_value_id IN (450, 451, 452) AND rmv.link_deal_flag=''l'') THEN ''Unhedged Deal''
				 WHEN (rmv.link_type_value_id=450) THEN ''Hedge'' 	 
				 WHEN (rmv.link_type_value_id=451) THEN ''DeDesignation Choice''
				 WHEN (rmv.link_type_value_id=452) THEN ''DeDesignation Not Probable'' ELSE ''MTM'' 
			END
			) designation_type,
			rmv.link_deal_flag real_link_type, 
			MAX(tvh.link_effective_date) link_effective_date, 
			--cd.buy_sell_flag,
			--spcd.curve_name, 
			MAX(sub.entity_name + ''/'' + stra.entity_name + ''/'' + book.entity_name) Book,
		MAX(tvh.volume_used) hedge_volume, 
		MAX(tvi.volume_used) item_volume, 
			--cd.percentage_included,
			SUM(rmv.u_hedge_mtm) u_hedge_mtm,
			SUM(rmv.d_hedge_mtm) d_hedge_mtm,
			SUM(rmv.u_item_mtm) u_item_mtm,
			SUM(rmv.d_item_mtm) d_item_mtm,
			SUM(rmv.u_aoci) u_aoci,
			SUM(rmv.d_aoci) d_aoci,
			SUM(rmv.u_pnl_ineffectiveness) u_pnl_ineffectiveness,
			SUM(rmv.d_pnl_ineffectiveness) d_pnl_ineffectiveness,
			SUM(rmv.u_pnl_extrinsic) u_pnl_extrinsic,
			SUM(rmv.d_pnl_extrinsic) d_pnl_extrinsic,
			MAX(rmv.link_type_value_id) link_type_value_id,
		MAX(CASE WHEN (rmv.link_deal_flag=''d'') THEN ''m'' ELSE ''h'' END) mtm_hedge, ' +			
	
		--CASE WHEN (@disc_undis = 'd') THEN ' -1*SUM(rmv.d_hedge_mtm)/SUM(rmv.d_item_mtm) ' ELSE ' -1*SUM(rmv.u_hedge_mtm)/SUM(rmv.u_item_mtm)  ' END + ' dol_offset, ' +
			
		(
		CASE 
			     WHEN (@disc_undis = 'd') THEN 
			       		'CASE WHEN SUM(rmv.d_item_mtm) = 0 THEN NULL			       			 
							  ELSE  -1*SUM(rmv.d_hedge_mtm)/SUM(rmv.d_item_mtm)
						 END'
			     ELSE 'CASE WHEN SUM(rmv.u_item_mtm) = 0 THEN NULL 
							 ELSE -1*SUM(rmv.u_hedge_mtm)/SUM(rmv.u_item_mtm)
						END'
		END
		)			
			+ ' dol_offset, ' +	
			
'			MAX(flh.link_description) link_desc
	FROM #books bk 
	INNER JOIN ' + @report_measurement_values + '  rmv 
		ON rmv.book_entity_id = bk.fas_book_id
	LEFT OUTER JOIN (SELECT * FROM #temp_volume tv WHERE hedge_or_item=''h'') tvh 
		ON tvh.link_id=rmv.link_id
	LEFT OUTER JOIN (SELECT * FROM #temp_volume tv WHERE hedge_or_item=''i'') tvi 
		ON tvi.link_id=rmv.link_id
	LEFT OUTER JOIN	fas_link_header flh 
		ON flh.link_id = rmv.link_id  
	LEFT OUTER JOIN portfolio_hierarchy sub 
		ON sub.entity_id = rmv.sub_entity_id 
	LEFT OUTER JOIN portfolio_hierarchy stra 
		ON stra.entity_id = rmv.strategy_entity_id 
	LEFT OUTER JOIN portfolio_hierarchy book 
		ON book.entity_id = rmv.book_entity_id 
	LEFT OUTER JOIN source_deaL_header sdh 
		ON sdh.source_deal_header_id = rmv.link_id AND rmv.link_deal_flag = ''d''
		WHERE 1=1 
		--AND cd.calc_type = ''m'' 
		AND((''' + ISNULL(@hedge_mtm, 'b') + ''' = ''m'' AND rmv.link_deal_flag = ''d'') OR (''' + ISNULL(@hedge_mtm, 'b') + ''' = ''h'' AND rmv.link_deal_flag = ''l'') OR (''' + ISNULL(@hedge_mtm, 'b') + ''' = ''b''))
		AND (rmv.term_month> dbo.FNAGetContractMonth(rmv.as_of_date)) 
		AND COALESCE(tvh.link_effective_date, sdh.deal_date) <= ''' + @as_of_date + ''' ' + 
		CASE WHEN (@link_id IS NULL) THEN '' ELSE ' AND COALESCE(CAST(flh.original_link_id AS float), CAST(flh.link_id AS float), rmv.link_id)  between  ' + @link_id + ' AND '+ @link_id_to END +
		' AND rmv.as_of_date = ''' + @as_of_date + '''' + 
	CASE WHEN @link_desc IS NOT NULL THEN ' AND flh.link_description like '''+replace(@link_desc,'*','%') + '%''' ELSE '' END +
	'GROUP BY  rmv.as_of_date,	rmv.sub_entity_id, rmv.strategy_entity_id, rmv.book_entity_id, COALESCE(flh.original_link_id, flh.link_id, rmv.link_id), rmv.link_id,rmv.link_deal_flag
'

EXEC (@Sql_SelectB)

CREATE TABLE #temp_deal_volume (
	source_deal_header_id INT,
	deal_description VARCHAR(100) COLLATE DATABASE_DEFAULT,
	deal_volume FLOAT, 
	volume_avail FLOAT
)

IF (@hedge_mtm='m' OR @hedge_mtm='b')
BEGIN
	INSERT INTO #temp_deal_volume(source_deal_header_id,deal_description,deal_volume, volume_avail)
	SELECT
		d.link_id source_deal_header_id,
		MAX(sdh.deal_id) + '  ' + MAX(spcd.curve_name) + ' ' + MIN(dbo.FNAContractMonthFormat(sdd.term_start)) + ':' + MAX(dbo.FNAContractMonthFormat(sdd.term_end)) + ' on ' + MAX(dbo.FNADateFormat(sdh.deal_date)) deal_description,
		SUM(sdd.deal_volume * CASE WHEN(sdd.buy_sell_flag='s') THEN -1 ELSE 1 END) deal_volume,
		SUM(sdd.deal_volume * (1-ISNULL(fld.per, 0)) * CASE WHEN(sdd.buy_sell_flag='s') THEN -1 ELSE 1 END) volume_avail
	FROM #details d
	INNER JOIN source_deal_detail sdd 
	ON d.link_id = sdd.source_deal_header_id 
			AND d.link_type='d' 
			AND sdd.leg = 1
	INNER JOIN source_deal_header sdh 
	ON sdh.source_deal_header_id = sdd.source_deal_header_id
	LEFT JOIN source_price_curve_def spcd 
	ON spcd.source_curve_def_id = sdd.curve_id 
	LEFT JOIN (SELECT source_deal_header_id, SUM(percentage_included) per FROM fas_link_detail WHERE hedge_or_item = 'h' GROUP BY source_deal_header_id) fld 
	ON fld.source_deal_header_id=sdh.source_deal_header_id	
	WHERE sdd.term_start > @as_of_date
	GROUP BY d.link_id
END


CREATE TABLE #deal_filter(link_id1 INT)

IF (@hedge_mtm='h')
BEGIN
	IF @source_deal_header_id IS NOT NULL 
		INSERT INTO #deal_filter
		SELECT DISTINCT d.link_id 
		FROM fas_link_detail d
		WHERE d.source_deal_header_id = @source_deal_header_id
	ELSE IF @deal_id IS NOT NULL
		INSERT INTO #deal_filter
		SELECT DISTINCT d.link_id 
		FROM fas_link_detail d
		INNER JOIN source_deal_header sdh 
		ON sdh.source_deal_header_id = d.source_Deal_header_id
		WHERE sdh.deal_id = @deal_id
	ELSE
		INSERT INTO #deal_filter
		SELECT distinct d.link_id FROM #details d
END
ELSE
BEGIN
	IF @source_deal_header_id IS NOT NULL 
		INSERT INTO #deal_filter
		SELECT DISTINCT source_deal_header_id 
		FROM source_deal_header
		WHERE source_deal_header_id = @source_deal_header_id
	ELSE IF @deal_id IS NOT NULL
		INSERT INTO #deal_filter
		SELECT DISTINCT source_deal_header_id 
		FROM source_deal_header
		WHERE deal_id = @deal_id
	ELSE
		INSERT INTO #deal_filter
		SELECT DISTINCT d.link_id 
		FROM #details d
END

DECLARE @url1 VARCHAR(2000)
DECLARE @url2 VARCHAR(2000)

--SET @url1 = 'EXEC spa_Create_Hedges_Measurement_Report ''''''''' +  @as_of_date + ''''''''',' + ISNULL('''''''''' + @sub_entity_id + '''''''''', 'NULL') + ', ' + ISNULL('''''''''' + @strategy_entity_id + '''''''''', 'NULL') + ', ' + ISNULL('''''''''' + @book_entity_id + '''''''''', 'NULL') + ', ''''''''d'''''''', ''''''''a'''''''', ''''''''c'''''''', ''''''''m'''''''','
--SET @url2 = ', '+ '''''''''2'''''''',NULL,''''''''n'''''''',NULL,NULL,NULL,NULL'

SET @url1 = 'EXEC spa_Create_Hedges_Measurement_Report ^' +  @as_of_date + '^,' + ISNULL('^' + @sub_entity_id + '^', 'NULL') + ', ' + ISNULL('^' + @strategy_entity_id + '^', 'NULL') + ', ' + ISNULL('^' + @book_entity_id + '^', 'NULL') + ', ^d^, ^a^, ^c^, ^m^,'
SET @url2 = ', '+ '^2^,NULL,^n^,NULL,NULL,NULL,NULL'

IF ISNULL(@summary_detail, 's') = 's'
BEGIN 
	CREATE TABLE #temp_summary_table(
		AsOfDate VARCHAR(50) COLLATE DATABASE_DEFAULT NULL,
		Book VARCHAR(MAX) COLLATE DATABASE_DEFAULT  NULL,
		[Rel ID] VARCHAR(MAX) COLLATE DATABASE_DEFAULT  NULL,
		[Description] VARCHAR(MAX) COLLATE DATABASE_DEFAULT  NULL,
		[Dollar Offset Ratio] FLOAT,
		[Derivative Volume] FLOAT,
		[Derivative MTM] FLOAT,
		[Hedged Item Volume] FLOAT,
		[Hedged Item MTM] FLOAT,
		[AOCI] FLOAT,
		[AOCI Locked] FLOAT,
		[Ineffectiveness] FLOAT,
		[Ineffectiveness Locked] FLOAT
	)
	SET @Sql_Select=' 
			INSERT INTO #temp_summary_table 
			SELECT 
			dbo.FNADateFormat(as_of_date) AsOfDate,
				MAX(Book) Book,'
				+ CASE WHEN @hedge_mtm = 'h' THEN '''<a href="javascript:open_report_in_viewport(''''' + @url1 + '''+ CAST(cd.link_id AS VARCHAR(50))+''' + @url2 + ''''')">'' + CAST(cd.link_id AS VARCHAR(50))	+ ''</a>''' ELSE 'NULL' END + ' [Rel ID],'
				+ CASE WHEN @hedge_mtm = 'h' THEN 
				 'dbo.FNATRMWinHyperlink(''a'', CASE WHEN (MAX(link_type) = ''d'') THEN 10131010 ELSE 10233700 END, MAX(ISNULL(link_desc, tdv.deal_description)), ABS(cd.link_id),null,null,null,null,null,null,null,null,null,null,null,0) '
				 ELSE 'NULL' END + ' [Description],
				ROUND(MAX(dol_offset), ' + CAST(@rounding AS VARCHAR) + ') [Dollar Offset Ratio],
				ROUND(SUM(ISNULL(' + CASE WHEN @hedge_mtm = 'h' THEN 'hedge_volume' ELSE 'tdv.volume_avail' END + ', 0)), ' + CAST(@rounding AS VARCHAR) + ') [Derivative Volume], 
				ROUND(SUM(CASE WHEN (''' + @disc_undis + ''' = ''u'') THEN u_hedge_mtm ELSE d_hedge_mtm END), ' + CAST(@rounding AS VARCHAR) + ') [Derivative MTM], 
				ROUND(SUM(ISNULL('+CASE WHEN @hedge_mtm='h' THEN 'item_volume' ELSE '0' END + ',0)), ' + CAST(@rounding AS VARCHAR)+') [Hedged Item Volume], 
				ROUND(SUM(CASE WHEN (''' + @disc_undis + ''' = ''u'') THEN u_item_mtm ELSE d_item_mtm END), ' + CAST(@rounding AS VARCHAR) + ') [Hedged Item MTM], 
				ROUND(SUM(CASE WHEN (link_type_value_id = 450) THEN CASE WHEN (''' + @disc_undis + ''' = ''u'') THEN u_aoci ELSE d_aoci END ELSE 0 END), ' + CAST(@rounding AS VARCHAR) + ') [AOCI],
				ROUND(SUM(CASE WHEN (link_type_value_id = 451) THEN CASE WHEN (''' + @disc_undis + ''' = ''u'') THEN u_aoci ELSE d_aoci END ELSE 0 END), ' + CAST(@rounding AS VARCHAR) + ') [AOCI Locked],
				ROUND(SUM(CASE WHEN (link_type_value_id = 450) THEN CASE WHEN (''' + @disc_undis + ''' = ''u'') THEN u_pnl_ineffectiveness+u_pnl_extrinsic ELSE d_pnl_ineffectiveness+d_pnl_extrinsic END ELSE 0 END), ' + CAST(@rounding AS VARCHAR) + ') [Ineffectiveness],
				ROUND(SUM(CASE WHEN (link_type_value_id IN (451, 452)) THEN CASE WHEN ('''+@disc_undis+'''= ''u'') THEN u_pnl_ineffectiveness+u_pnl_extrinsic ELSE d_pnl_ineffectiveness+d_pnl_extrinsic END ELSE 0 END), '+CAST(@rounding AS VARCHAR) + ') [Ineffectiveness Locked]
			FROM #details cd INNER JOIN #deal_filter df on link_id = df.link_id1
			LEFT JOIN #temp_deal_volume tdv 
			ON tdv.source_deal_header_id = cd.link_id
			GROUP BY as_of_date ' + CASE WHEN @hedge_mtm = 'h' THEN ', link_id ' ELSE '' END
	
	EXEC(@Sql_Select)

	IF @hedge_mtm='h'
		SET @Sql_Select = 'SELECT * ' + @str_get_row_number + @str_batch_table + ' FROM #temp_summary_table'
	ELSE
		SET @Sql_Select = 'SELECT AsOfDate, Book, [Derivative Volume], [Derivative MTM], [Hedged Item Volume], [Hedged Item MTM], [AOCI], [AOCI Locked], [Ineffectiveness], [Ineffectiveness Locked] ' + @str_get_row_number + @str_batch_table +' FROM #temp_summary_table'
	
	EXEC(@Sql_Select) 
END
ELSE IF ISNULL(@summary_detail, 's') = 'j'
BEGIN
	CREATE TABLE #temp_report_je(
		as_of_date VARCHAR(50) COLLATE DATABASE_DEFAULT  NULL,
		fas_subsidiary_id INT,
		fas_strategy_id INT,
		fas_book_id INT, 
		Book VARCHAR(100) COLLATE DATABASE_DEFAULT  NULL,
		[Rel ID] VARCHAR(500) COLLATE DATABASE_DEFAULT  NULL,
		[Designation Type] VARCHAR(50) COLLATE DATABASE_DEFAULT  NULL,
		[Ref Rel ID] VARCHAR(500) COLLATE DATABASE_DEFAULT  NULL,
		[Ref Deal ID] VARCHAR(300) COLLATE DATABASE_DEFAULT  NULL, 
		[Deal ID] VARCHAR(50) COLLATE DATABASE_DEFAULT  NULL, 
		[Term] VARCHAR(50) COLLATE DATABASE_DEFAULT  NULL,
		[Rel Eff Date] VARCHAR(50) COLLATE DATABASE_DEFAULT  NULL,
		[Buy/sell] VARCHAR(50) COLLATE DATABASE_DEFAULT  NULL,
		[Derivative Volume] FLOAT, 
		[Derivative MTM] FLOAT,
		[Hedged Item Volume] FLOAT,
		[Hedged Item MTM] FLOAT,
		[AOCI] FLOAT,
		[AOCI Locked] FLOAT,
		[Ineffectiveness] FLOAT,
		[Ineffectiveness Locked] FLOAT
	)

	INSERT INTO #temp_report_je 
	SELECT	
			dbo.FNADateFormat(as_of_date) AsOfDate, 
		fas_subsidiary_id, fas_strategy_id, 
		fas_book_id,
			Book,
		CASE 
			WHEN(link_type <> 'deal')
				THEN '<span style=cursor:hand onClick=openHyperLink(10233710,'+ CAST(link_id AS VARCHAR) + ')><font color=#0000ff><u>' + CAST(link_id AS VARCHAR) + '</u></font></span>' 
			ELSE '<span style=cursor:hand onClick=openHyperLink(10131010,'+ CAST(link_id AS VARCHAR) + ')><font color=#0000ff><u>' + CAST(link_id AS VARCHAR) + '</u></font></span>' 
		END [Rel Id],
			(designation_type) [Designation Type], 
			(original_link_id) [Ref Rel ID],			 
		--'<span style=cursor:hand onClick=openHyperLink(10131010,'+ CAST(source_deal_header_id AS VARCHAR)+')><font color=#0000ff><u>'+ CAST(deal_id AS VARCHAR)+'</u></font></span>' AS [Ref Deal ID],
			NULL,
			NULL,
			NULL,
			--source_deal_header_id [Deal ID], 
			--dbo.FNADateFormat(term_Start) [Term], 
			MAX(dbo.FNADateFormat(link_effective_date)) [Rel Eff Date],
			--buy_sell_flag [Buy/sell],
			NULL,
		ROUND(SUM(hedge_volume), @rounding) [Derivative Volume], 
		ROUND(SUM(CASE WHEN (@disc_undis = 'u') THEN u_hedge_mtm ELSE d_hedge_mtm END), @rounding) [Derivative MTM], 
		ROUND(SUM(item_volume), @rounding) [Hedged Item Volume], 
		ROUND(SUM(CASE WHEN (@disc_undis = 'u') THEN u_item_mtm ELSE d_item_mtm END), @rounding) [Hedged Item MTM], 
		ROUND(SUM(CASE WHEN (link_type_value_id = 450) THEN CASE WHEN (@disc_undis = 'u') THEN u_aoci ELSE d_aoci END ELSE 0 END), @rounding) [AOCI],
		ROUND(SUM(CASE WHEN (link_type_value_id = 451) THEN CASE WHEN (@disc_undis = 'u') THEN u_aoci ELSE d_aoci END ELSE 0 END), @rounding) [AOCI Locked],
		ROUND(SUM(CASE WHEN (link_type_value_id = 450) THEN CASE WHEN (@disc_undis = 'u') THEN u_pnl_ineffectiveness+u_pnl_extrinsic ELSE d_pnl_ineffectiveness+d_pnl_extrinsic END ELSE 0 END), @rounding) [Ineffectiveness],
		ROUND(SUM(CASE WHEN (link_type_value_id IN (451, 452)) THEN CASE WHEN (@disc_undis = 'u') THEN u_pnl_ineffectiveness+u_pnl_extrinsic ELSE d_pnl_ineffectiveness+d_pnl_extrinsic END ELSE 0 END), @rounding) [Ineffectiveness Locked]
	FROM #DETAILS INNER JOIN #deal_filter df on link_id = df.link_id1
	WHERE  1=1
	--AND hedge_or_item = 'h'
	GROUP BY dbo.FNADateFormat(as_of_date), fas_subsidiary_id, fas_strategy_id, fas_book_id, Book, link_type, link_id, link_type_value_id, designation_type, original_link_id
	ORDER BY designation_type, link_id, original_link_id
	
	SET @Sql_Select='SELECT * ' + @str_get_row_number + @str_batch_table +' FROM #temp_report_je'
	
	EXEC(@Sql_Select) 
END

IF @is_batch = 1
BEGIN
	 SELECT @str_batch_table=dbo.FNABatchProcess('u',@batch_process_id,@batch_report_param,GETDATE(),NULL,NULL)   
	 EXEC(@str_batch_table)                   
	        
	 SELECT @str_batch_table=dbo.FNABatchProcess('c',@batch_process_id,@batch_report_param,GETDATE(),'spa_create_hedge_effectiveness_report','Run Hedge Effectiveness Report')         
	 EXEC(@str_batch_table)        
	 RETURN
END

IF @enable_paging = 1
BEGIN
		IF @page_size IS NULL
		BEGIN
		SET @sql_stmt = 'SELECT count(*) TotalRow, ''' + @batch_process_id + ''' process_id  FROM ' + @temptablename
		EXEC(@sql_stmt)
		END
	RETURN
END 
GO
