IF OBJECT_ID(N'[dbo].[spa_match_deal_volume]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_match_deal_volume]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===============================================================================================================
-- Author: aamatya@pioneersolutionsglobal.com
-- Create date: 2018-11-30
-- Description: Match deal volume

-- ===============================================================================================================
CREATE PROCEDURE [dbo].[spa_match_deal_volume]
@flag CHAR(1) = NULL,
@sub_id VARCHAR(MAX)= NULL,
@stra_id VARCHAR(MAX)= NULL,
@book_id VARCHAR(MAX)= NULL, 
@sub_book_id VARCHAR(MAX)= NULL,
@source_deal_header_id VARCHAR(MAX)= NULL,
@source_deal_detail_id VARCHAR(MAX)= NULL,
@source_deal_detail_id_2 VARCHAR(MAX)= NULL,
@deal_type VARCHAR(1000)= NULL,
@tenor_from DATETIME= NULL,
@tenor_to DATETIME= NULL,
@approach INT= NULL,
@margin_product INT= NULL,
@buy_sell CHAR(1) = NULL,	
@perfect_volume_match CHAR(1)= NULL,
@best_match_only CHAR(1)= NULL,
@batch_process_id VARCHAR(250) = NULL,
@batch_report_param VARCHAR(500) = NULL, 
@enable_paging INT = 0,  --'1' = enable, '0' = disable
@page_size INT = NULL,
@page_no INT = NULL
AS

SET NOCOUNT ON

--DECLARE @contextinfo VARBINARY(128)= CONVERT(VARBINARY(128), 'DEBUG_MODE_ON');
--SET CONTEXT_INFO @contextinfo;

DECLARE @sql VARCHAR(MAX)
DECLARE @sql1 VARCHAR(MAX)
 --SET @source_deal_header_id = '11706,11707,11708,11709,11710,11711,11712', 
  
IF OBJECT_ID(N'tempdb..#books') IS NOT NULL
	DROP TABLE #books
IF OBJECT_ID(N'tempdb..#temp_deals') IS NOT NULL
	DROP TABLE #temp_deals
IF OBJECT_ID(N'tempdb..#buy_sell_deals') IS NOT NULL
	DROP TABLE #buy_sell_deals
  
DECLARE @str_batch_table VARCHAR (8000)
DECLARE @user_login_id VARCHAR (50)
DECLARE @is_batch BIT
SET @margin_product = NULLIF(@margin_product, '') 
SET @str_batch_table = ''
SET @user_login_id = dbo.FNADBUser() 
SET @is_batch = CASE WHEN @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL THEN 1 ELSE 0 END 
 
IF @is_batch = 1
BEGIN
	SET @str_batch_table = ' INTO ' + dbo.FNAProcessTableName('batch_report', @user_login_id, @batch_process_id)
END

IF @flag = 'g'
BEGIN 
	SET @sql = 'SELECT a.deal_id, a.source_deal_detail_id, a.deal_ref_id, a.deal_date, a.term_start, a.term_end, a.counterparty, a.location_name, a.[index], a.volume, a.match_volume, a.volume_left, a.uom, a.price, MIN(a.ord) FROM ('
	SET @sql += '
		SELECT	
			sdh.source_deal_header_id	[deal_id],
			sdd.source_deal_detail_id   [source_deal_detail_id],
			sdh.deal_id					[deal_ref_id],
			dbo.FNADateFormat(sdh.deal_date) [deal_date],
			dbo.FNADateFormat(sdd.term_start) [term_start],
			dbo.FNADateFormat(sdd.term_end) [term_end],
			MAX(sc.counterparty_name)		[counterparty],
			MAX(sml.Location_Name)           [location_name], 
			MAX(spcd.curve_id)               [index],
			CAST(dbo.FNARemoveTrailingZeroes(ROUND(sdd.deal_volume, 2)) AS decimal(10,2)) [volume],
			CAST(dbo.FNARemoveTrailingZeroes(ROUND(SUM(mdv.match_vol), 2)) AS decimal(10,2)) [match_volume],
			--CAST(dbo.FNARemoveTrailingZeroes(ROUND(sdd.volume_left, 2)) AS decimal(10,2)) [volume_left],
			CAST(dbo.FNARemoveTrailingZeroes(ROUND(ISNULL(sdd.deal_volume, 0) - ISNULL(SUM(mdv.match_vol), 0), 2)) AS decimal(10,2)) [volume_left],
			MAX(su.uom_name)                 [uom],                  
			CAST(dbo.FNARemoveTrailingZeroes(ROUND(sdd.fixed_price, 2)) AS decimal(10,2)) [price],
			1 [ord]
		FROM source_deal_header sdh 
		INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
		INNER JOIN source_deal_detail sdd1 ON sdd1.term_start = sdd.term_start
			AND sdd1.buy_sell_flag <> sdd.buy_sell_flag
		INNER JOIN source_deal_header sdh1 ON sdh1.source_deal_header_id = sdd1.source_deal_header_id 
			AND sdh1.deal_date = sdh.deal_date
			AND sdh1.source_deal_type_id = sdh.source_deal_type_id 
			AND sdh1.source_system_book_id1 = sdh.source_system_book_id1 
			AND sdh1.source_system_book_id2 = sdh.source_system_book_id2
			AND sdh1.source_system_book_id3 = sdh.source_system_book_id3
			AND sdh1.source_system_book_id4 = sdh.source_system_book_id4

		INNER JOIN source_deal_type sdt ON sdt.source_deal_type_id = sdh.source_deal_type_id
		INNER JOIN source_counterparty sc ON sc.source_counterparty_id = sdh.counterparty_id
		LEFT JOIN  source_minor_location sml ON sml.source_minor_location_id = sdd.location_id
		LEFT JOIN  source_uom su ON su.source_uom_id = sdd.deal_volume_uom_id
		LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = sdd.curve_id 

		LEFT JOIN match_deal_volume mdv ON sdd.source_deal_detail_id = CASE WHEN sdd.buy_sell_flag = ''b'' THEN mdv.buy_source_deal_detail_id ELSE mdv.sell_source_deal_detail_id END

		WHERE sdd1.source_deal_detail_id = ' + @source_deal_detail_id + 'AND NULLIF(sdd.deal_volume, 0) IS NOT NULL '
		+ CASE WHEN NULLIF(@perfect_volume_match, 'n') IS NOT NULL THEN ' AND sdd.deal_volume = sdd1.deal_volume' ELSE '' END +'
		GROUP BY sdh.source_deal_header_id, sdd.source_deal_detail_id, sdh.deal_id, sdh.deal_date, sdd.term_start, sdd.term_end, sdd.deal_volume, sdd.volume_left, sdd.fixed_price HAVING ISNULL(sdd.deal_volume, 0) - ISNULL(SUM(mdv.match_vol), 0) <> 0
		'

	IF NULLIF(@source_deal_detail_id, '') IS NOT NULL AND ISNULL(@best_match_only, 'y') = 'y' -- Best match only
	BEGIN
		SET @sql += ') a WHERE a.volume_left <> 0 GROUP BY a.deal_id, a.source_deal_detail_id, a.deal_ref_id, a.deal_date, a.term_start, a.term_end, a.counterparty, a.location_name, a.[index], a.volume, a.match_volume, a.volume_left, a.uom, a.price'
		EXEC(@sql)
		RETURN
	END
	ELSE IF NULLIF(@source_deal_detail_id, '') IS NOT NULL AND ISNULL(@best_match_only, 'y') = 'n' 
	BEGIN
		DECLARE @deal_volume VARCHAR(100) , @term_start DATETIME
		IF NULLIF(@perfect_volume_match, 'n') IS NOT NULL
		BEGIN
			SELECT @deal_volume = deal_volume FROM source_deal_detail WHERE source_deal_detail_id = @source_deal_detail_id
		END

		SELECT @term_start = term_start FROM source_deal_detail WHERE source_deal_detail_id = @source_deal_detail_id

		SET @buy_sell = CASE WHEN @buy_sell = 'b' THEN 's' ELSE 'b' END
		SET @sql += '
		UNION
		'
	END
	ELSE
		SET @sql = 'SELECT a.deal_id, a.source_deal_detail_id, a.deal_ref_id, a.deal_date, a.term_start, a.term_end, a.counterparty, a.location_name, a.[index], a.volume, a.match_volume, a.volume_left, a.uom, a.price, MIN(a.ord)  FROM ('

	IF OBJECT_ID('tempdb..#books1') IS NOT NULL
		DROP TABLE #books1

	CREATE TABLE #books1 (
		[entity_id] INT,
		source_system_book_id1 INT,
		source_system_book_id2 INT,
		source_system_book_id3 INT,
		source_system_book_id4 INT
	)

	SET @sql1 = 'INSERT INTO #books1
	SELECT DISTINCT book.entity_id,
			ssbm.source_system_book_id1,
			ssbm.source_system_book_id2,
			ssbm.source_system_book_id3,
			ssbm.source_system_book_id4
	FROM   portfolio_hierarchy book(NOLOCK)
			INNER JOIN Portfolio_hierarchy stra(NOLOCK)
				ON  book.parent_entity_id = stra.entity_id
			INNER JOIN source_system_book_map ssbm
				ON  ssbm.fas_book_id = book.entity_id
	WHERE  (fas_deal_type_value_id IS NULL OR fas_deal_type_value_id BETWEEN 400 AND 401) ' +
	CASE WHEN @sub_id IS NOT NULL THEN ' AND stra.parent_entity_id IN  (' + @sub_id + ') ' ELSE '' END +
	CASE WHEN @stra_id IS NOT NULL THEN ' AND stra.entity_id IN(' + @stra_id  + ')' ELSE '' END +
	CASE WHEN @book_id IS NOT NULL THEN ' AND book.entity_id IN(' + @book_id  + ')' ELSE '' END +
	CASE WHEN @sub_book_id IS NOT NULL THEN ' AND ssbm.book_deal_type_map_id IN (' + @sub_book_id  + ')' ELSE '' END 
	EXEC(@sql1)

	SET @sql += '
		SELECT	
			sdh.source_deal_header_id	[deal_id],
			sdd.source_deal_detail_id   [source_deal_detail_id],
			sdh.deal_id					[deal_ref_id],
			dbo.FNADateFormat(sdh.deal_date) [deal_date],
			dbo.FNADateFormat(sdd.term_start) [term_start],
			dbo.FNADateFormat(sdd.term_end) [term_end],
			MAX(sc.counterparty_name)		[counterparty],
			MAX(sml.Location_Name)           [location_name], 
			MAX(spcd.curve_id)               [index],
			CAST(dbo.FNARemoveTrailingZeroes(ROUND(sdd.deal_volume, 2)) AS decimal(10,2)) [volume],
			CAST(dbo.FNARemoveTrailingZeroes(ROUND(SUM(mdv.match_vol), 2)) AS decimal(10,2)) [match_volume],
			--CAST(dbo.FNARemoveTrailingZeroes(ROUND(sdd.volume_left, 2)) AS decimal(10,2)) [volume_left],
			CAST(dbo.FNARemoveTrailingZeroes(ROUND(ISNULL(sdd.deal_volume, 0) - ISNULL(SUM(mdv.match_vol), 0), 2)) AS decimal(10,2)) [volume_left],
			MAX(su.uom_name)                 [uom],                  
			CAST(dbo.FNARemoveTrailingZeroes(ROUND(sdd.fixed_price, 2)) AS decimal(10,2)) [price],
			2 [ord]
		FROM source_deal_header sdh 
		INNER JOIN #books1 b on sdh.source_system_book_id1=b.source_system_book_id1 
			AND sdh.source_system_book_id2=b.source_system_book_id2 
			AND sdh.source_system_book_id3=b.source_system_book_id3 
			AND sdh.source_system_book_id4=b.source_system_book_id4
		INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
		INNER JOIN source_deal_type sdt ON sdt.source_deal_type_id = sdh.source_deal_type_id
		INNER JOIN source_counterparty sc ON sc.source_counterparty_id = sdh.counterparty_id
		LEFT JOIN  source_minor_location sml ON sml.source_minor_location_id = sdd.location_id
		LEFT JOIN  source_uom su ON su.source_uom_id = sdd.deal_volume_uom_id
		LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = sdd.curve_id 

		LEFT JOIN match_deal_volume mdv ON sdd.source_deal_detail_id = ' + CASE WHEN @buy_sell = 'b' THEN 'mdv.buy_source_deal_detail_id' ELSE 'mdv.sell_source_deal_detail_id' END + ''
		
		+ CASE WHEN @margin_product IS NOT NULL THEN '
			INNER JOIN user_defined_deal_fields uddf ON uddf.source_deal_header_id = sdh.source_deal_header_id
			INNER JOIN user_defined_deal_fields_template uddft ON uddft.template_id = sdh.template_id AND uddft.udf_template_id = uddf.udf_template_id
			' ELSE '' END + '
		WHERE NULLIF(sdd.deal_volume, 0) IS NOT NULL '
		+ CASE WHEN @deal_type IS NOT NULL THEN ' and sdh.source_deal_type_id in ('+@deal_type+')' ELSE '' END + ''
		
		+ CASE WHEN NULLIF(@source_deal_detail_id, '') IS NOT NULL AND ISNULL(@best_match_only, 'y') = 'n' THEN 'AND sdd.term_start = ''' + CONVERT(VARCHAR(10),@term_start, 121) + '''' WHEN @tenor_from IS NOT NULL AND @tenor_to IS NOT NULL THEN ' AND sdd.term_start BETWEEN ''' + CONVERT(VARCHAR(10),@tenor_from, 121)+ ''' AND ''' + CONVERT(VARCHAR(10), @tenor_to, 121) + ''' ' ELSE '' END +'' 

		+ CASE WHEN @buy_sell IS NOT NULL THEN ' AND sdd.buy_sell_flag in ('''+@buy_sell+''')' ELSE '' END + ''
		+ CASE WHEN @margin_product IS NOT NULL THEN 'AND uddft.field_label = ''Margin Product'' AND uddf.udf_value = ''' + CAST(@margin_product AS VARCHAR) + '''' ELSE '' END +

		+ CASE WHEN NULLIF(@perfect_volume_match, 'n') IS NOT NULL AND NULLIF(@source_deal_detail_id, '') IS NOT NULL THEN ' AND sdd.deal_volume = ' +@deal_volume  ELSE '' END +

		' GROUP BY  sdh.source_deal_header_id,sdd.source_deal_detail_id,sdh.deal_id,sdh.deal_date,sdd.term_start,sdd.term_end,sdd.deal_volume,sdd.volume_left,sdd.fixed_price HAVING ISNULL(sdd.deal_volume, 0) - ISNULL(SUM(mdv.match_vol), 0) <> 0
		) a WHERE a.volume_left <> 0 

		GROUP BY a.deal_id, a.source_deal_detail_id, a.deal_ref_id, a.deal_date, a.term_start, a.term_end, a.counterparty, a.location_name, a.[index], a.volume, a.match_volume, a.volume_left, a.uom, a.price

		ORDER BY MIN(a.ord), a.deal_date
		' + CASE WHEN @approach = 21100 THEN 'ASC' ELSE 'DESC' END

	EXEC(@sql)
	PRINT @sql
END
ELSE IF @flag='c' 
BEGIN

CREATE TABLE #books ( fas_book_id INT, source_system_book_id1 INT ,source_system_book_id2 INT,source_system_book_id3 INT,source_system_book_id4 INT,
sub_id INT, stra_id INT, book_id INT, subbook_id INT,
sub_name VARCHAR(100), stra_name VARCHAR(100), book_name VARCHAR(100), subbook_name VARCHAR(100)
)

SET @sql = 
'   INSERT INTO #books
    SELECT DISTINCT book.entity_id,
           ssbm.source_system_book_id1,
           ssbm.source_system_book_id2,
           ssbm.source_system_book_id3,
           ssbm.source_system_book_id4,
		   stra.parent_entity_id,
		   stra.entity_id,
		   book.entity_id,
		   ssbm.book_deal_type_map_id,
		 
		   stra.entity_name,
		   stra.entity_name,
		   book.entity_name,
		   ssbm.logical_name
		   
		   FROM  portfolio_hierarchy book(NOLOCK)
           INNER JOIN Portfolio_hierarchy stra(NOLOCK)
                ON  book.parent_entity_id = stra.entity_id
           INNER JOIN source_system_book_map ssbm
                ON  ssbm.fas_book_id = book.entity_id
    WHERE  (fas_deal_type_value_id IS NULL OR fas_deal_type_value_id BETWEEN 400 AND 401)  ' 
        
IF @sub_id IS NOT NULL   
	SET @sql = @sql + ' AND stra.parent_entity_id IN  ( '+ @sub_id + ') '              
IF @stra_id IS NOT NULL   
	SET @sql = @sql + ' AND (stra.entity_id IN('  + @stra_id + ' ))'           
IF @book_id IS NOT NULL   
	SET @sql = @sql + ' AND (book.entity_id IN('   + @book_id + ')) '   
IF @sub_book_id IS NOT NULL
	SET @sql = @sql + ' AND ssbm.book_deal_type_map_id IN (' + @sub_book_id + ' ) '

----print ( @sql)    
EXEC ( @sql) 

 --select * from #books

 CREATE TABLE #temp_deals(source_deal_header_id INT)

SET @sql = '
	insert into #temp_deals(source_deal_header_id) 
		select sdh.source_deal_header_id from dbo.source_deal_header sdh 
		inner join #books b on sdh.source_system_book_id1=b.source_system_book_id1 and sdh.source_system_book_id2=b.source_system_book_id2 
		and sdh.source_system_book_id3=b.source_system_book_id3 and sdh.source_system_book_id4=b.source_system_book_id4' 
		+ CASE WHEN @margin_product IS NOT NULL THEN '
		INNER JOIN user_defined_deal_fields uddf ON uddf.source_deal_header_id = sdh.source_deal_header_id
		INNER JOIN user_defined_deal_fields_template uddft ON uddft.template_id = sdh.template_id AND uddft.udf_template_id = uddf.udf_template_id
		' ELSE '' END + '

		WHERE  1 = 1 '
		+ CASE WHEN @deal_type is not null then ' and sdh.source_deal_type_id in ('+@deal_type+')' ELSE '' END
		+ CASE WHEN @source_deal_header_id is not null then ' and sdh.source_deal_header_id in ('+@source_deal_header_id+')' ELSE '' END
		+ CASE WHEN @margin_product IS NOT NULL THEN 'AND uddft.field_label = ''Margin Product'' AND uddf.udf_value = ''' + CAST(@margin_product AS VARCHAR) + '''' ELSE '' END

EXEC(@sql)

--select * from #temp_deals

CREATE TABLE #buy_sell_deals(id INT IDENTITY(1,1), source_deal_header_id INT, source_deal_detail_id INT, term_start DATETIME, deal_date DATETIME, buy_sell_flag CHAR(1), deal_volume NUMERIC(38,20))
 
SET @sql = '
INSERT INTO #buy_sell_deals(source_deal_header_id, source_deal_detail_id, term_start, deal_date, buy_sell_flag, deal_volume)
SELECT sdd.source_deal_header_id,sdd.source_deal_detail_id, sdd.term_start, sdh.deal_date, sdd.buy_sell_flag, COALESCE(rs_buy_mdv_latest.buy_outstanding_vol, rs_sell_mdv_latest.sell_outstanding_vol, sdd.deal_volume)
FROM source_deal_header sdh
INNER JOIN #temp_deals t ON t.source_deal_header_id = sdh.source_deal_header_id
INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
OUTER APPLY(
	SELECT TOP 1 mdv.buy_outstanding_vol 
	FROM match_deal_volume mdv 
	where mdv.buy_source_deal_detail_id = sdd.source_deal_detail_id
		AND sdd.buy_sell_flag = ''b''		
		ORDER BY mdv.create_ts desc) rs_buy_mdv_latest
OUTER APPLY(
	SELECT TOP 1 mdv.sell_outstanding_vol 
		FROM match_deal_volume mdv 
		where mdv.sell_source_deal_detail_id = sdd.source_deal_detail_id 
			AND sdd.buy_sell_flag = ''s''
		ORDER BY mdv.create_ts desc) rs_sell_mdv_latest

WHERE 1 = 1  '
+ CASE WHEN @tenor_from IS NOT NULL AND @tenor_to IS NOT NULL THEN ' AND sdd.term_start BETWEEN ''' + CONVERT(VARCHAR(10),@tenor_from, 121)+ ''' AND ''' + CONVERT(VARCHAR(10), @tenor_to, 121) + ''' ' ELSE '' END

--print(@sql)
EXEC(@sql)

 -- select * from #buy_sell_deals
 
-- select *  from #buy_sell_deals order by buy_Sell_flag, deal_date
 --return
 --select * from  match_deal_volume

SET @sql = '
DECLARE @_source_deal_header_id INT, @_source_deal_detail_id INT, @_term_start DATETIME, @_deal_date DATETIME, @_deal_volume NUMERIC(38,20)
DECLARE @_source_deal_header_id_s INT, @_source_deal_detail_id_s INT, @_term_start_s DATETIME, @_deal_date_s DATETIME, @_deal_volume_s NUMERIC(38,20), @sql2 VARCHAR(MAX)
declare @c int = 2
While(@c>0)
BEGIN

	DECLARE match_vol CURSOR FOR  

	SELECT b.source_deal_header_id, b.source_deal_detail_id, b.term_start, b.deal_date, b.deal_volume 
	FROM #buy_sell_deals b
	WHERE b.buy_sell_flag = ''b'' AND CAST(b.deal_volume AS INT) <> 0
	ORDER BY deal_date ' + CASE WHEN @approach = 21100 THEN 'asc' ELSE 'desc' END + '
		 		 
	OPEN match_vol  
	FETCH NEXT FROM match_vol INTO @_source_deal_header_id, @_source_deal_detail_id, @_term_start, @_deal_date, @_deal_volume
		
	WHILE @@FETCH_STATUS = 0  
	BEGIN

	-----------
		DECLARE match_vol_s CURSOR FOR  
			SELECT s.source_deal_header_id, s.source_deal_detail_id, s.term_start, s.deal_date, s.deal_volume 
			FROM #buy_sell_deals s
			WHERE s.buy_sell_flag = ''s'' AND CAST(s.deal_volume AS INT) <> 0
			ORDER BY deal_date ' + CASE WHEN @approach = 21100 THEN 'asc' ELSE 'desc' END + '
		OPEN match_vol_s  
		FETCH NEXT FROM match_vol_s INTO @_source_deal_header_id_s, @_source_deal_detail_id_s, @_term_start_s, @_deal_date_s, @_deal_volume_s

		WHILE @@FETCH_STATUS = 0  
		BEGIN

			IF @c = 1 OR @_deal_date = @_deal_date_s
			BEGIN
			 if EXISTS(select 1 FROM #buy_sell_deals where source_deal_detail_id = @_source_deal_detail_id AND cast(deal_volume as INT) = 0)
					break;

				if @_term_start = @_term_start_s   
					AND NOT EXISTS(SELECT 1 FROM match_deal_volume WHERE buy_source_deal_detail_id = @_source_deal_detail_id AND sell_source_deal_detail_id = @_source_deal_detail_id_s 
					AND term_start = @_term_start AND buy_outstanding_vol = 0 )
				BEGIN
					SELECT @_deal_volume = deal_volume FROM #buy_sell_deals WHERE buy_sell_flag = ''b'' AND source_deal_detail_id = @_source_deal_detail_id

		 			SET @sql2 = ''
					INSERT INTO match_deal_volume( buy_source_deal_detail_id, sell_source_deal_detail_id, term_start, match_vol, buy_outstanding_vol, sell_outstanding_vol)
					SELECT '' + CAST(@_source_deal_detail_id AS VARCHAR) + '', '' + CAST(@_source_deal_detail_id_s AS VARCHAR) + '', '''''' + CONVERT(VARCHAR(10),@_term_start, 121) + '''''', volm.vol,
					('' + CAST(@_deal_volume AS VARCHAR) + '' - volm.vol) buy_outstanding_vol,
					('' + CAST(@_deal_volume_s AS VARCHAR) + '' - volm.vol) sell_outstanding_vol
					FROM 
					(SELECT (SELECT ABS(MIN(v)) FROM (VALUES ('' + CAST(@_deal_volume AS VARCHAR) + ''), ('' + CAST(@_deal_volume_s AS VARCHAR) + '')) AS value(v)) vol) volm  WHERE 1 = 1 ''
					+ CASE WHEN ''' + ISNULL(@perfect_volume_match, '') + ''' = ''y'' THEN '' AND  '' + CAST(@_deal_volume AS VARCHAR) + '' = '' + CAST(@_deal_volume_s AS VARCHAR) + '' '' ELSE '''' END

					--print @sql2
					EXEC(@sql2)

 
 					 update bs set bs.deal_volume = mdv.buy_outstanding_vol 
					from #buy_sell_deals bs 
					INNER JOIN match_Deal_volume mdv ON mdv.buy_source_deal_detail_id = @_source_deal_detail_id
					and  mdv.sell_source_deal_detail_id = @_source_deal_detail_id_s
					WHERE bs.buy_sell_flag = ''b''
					and bs.source_deal_detail_id = @_source_deal_detail_id
 
 					 update bs set bs.deal_volume = mdv.sell_outstanding_vol 
					from #buy_sell_deals bs 
					INNER JOIN match_Deal_volume mdv ON mdv.buy_source_deal_detail_id = @_source_deal_detail_id
					and  mdv.sell_source_deal_detail_id = @_source_deal_detail_id_s
					WHERE bs.buy_sell_flag = ''s''
					and bs.source_deal_detail_id = @_source_deal_detail_id_s

  				END
			END

			FETCH NEXT FROM match_vol_s INTO @_source_deal_header_id_s, @_source_deal_detail_id_s, @_term_start_s, @_deal_date_s, @_deal_volume_s
		END
		CLOSE match_vol_s
		DEALLOCATE match_vol_s

		-------------
		 --  select * from #buy_sell_deals order by buy_sell_flag, deal_date
		 --return

 		 FETCH NEXT FROM match_vol INTO @_source_deal_header_id, @_source_deal_detail_id, @_term_start, @_deal_date, @_deal_volume
	END
	CLOSE match_vol
	DEALLOCATE match_vol
	set @c = @c -1
END

'

EXEC(@sql)


IF @is_batch = 1
BEGIN
 	SELECT @str_batch_table = dbo.FNABatchProcess ('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL) 
 	EXEC (@str_batch_table)

	EXEC  spa_message_board 'u', @user_login_id, NULL, 'Close Deals',  'Close Deals calculation process completed without errors.', '', '', 's', NULL,NULL,@batch_process_id,NULL,'n',NULL,'n', NULL, NULL

	RETURN
END

END
 --select *  from #buy_sell_deals order by buy_Sell_flag, deal_date

 ELSE IF @flag = 'm'  -- Manually deal matched.
 BEGIN
		DECLARE @_source_deal_detail_id_b INT, @_source_deal_detail_id_s INT, @_term_start DATETIME, @_deal_volume INT, @_deal_volume_s INT
		BEGIN TRY
		BEGIN TRAN
			SELECT @_source_deal_detail_id_b = sdd.source_deal_detail_id, 
					@_term_start = sdd.term_start,
					@_deal_volume = sdd.deal_volume - ISNULL(mdv.match_vol, 0)
			FROM source_deal_detail sdd
			OUTER APPLY (SELECT SUM(ISNULL(mdv.match_vol, 0)) match_vol
						FROM match_deal_volume mdv 
						WHERE mdv.buy_source_deal_detail_id = sdd.source_deal_detail_id) mdv
			--LEFT JOIN match_deal_volume mdv ON mdv.buy_source_deal_detail_id = sdd.source_deal_detail_id
			WHERE source_deal_detail_id IN (@source_deal_detail_id, @source_deal_detail_id_2) AND buy_sell_flag = 'b'

			SELECT @_source_deal_detail_id_s = sdd.source_deal_detail_id, 
					@_deal_volume_s = sdd.deal_volume - ISNULL(mdv.match_vol, 0) 
			FROM source_deal_detail sdd
			OUTER APPLY (SELECT SUM(ISNULL(mdv.match_vol, 0)) match_vol
						FROM match_deal_volume mdv 
						WHERE mdv.sell_source_deal_detail_id = sdd.source_deal_detail_id) mdv
			--LEFT JOIN match_deal_volume mdv ON mdv.sell_source_deal_detail_id = sdd.source_deal_detail_id
			WHERE source_deal_detail_id IN (@source_deal_detail_id, @source_deal_detail_id_2) AND buy_sell_flag = 's'
			
			--SELECT @_source_deal_detail_id_b, @_source_deal_detail_id_s
			IF EXISTS (SELECT 1 FROM match_deal_volume WHERE buy_source_deal_detail_id = @_source_deal_detail_id_b AND sell_source_deal_detail_id = @_source_deal_detail_id_s AND term_start = CONVERT(VARCHAR(10),@_term_start, 121))
			BEGIN
				SET @flag = 'e';
			END
			ELSE
			BEGIN
				SET @sql = '
					INSERT INTO match_deal_volume( buy_source_deal_detail_id, sell_source_deal_detail_id, term_start, match_vol, buy_outstanding_vol, sell_outstanding_vol)
					SELECT ' + CAST(@_source_deal_detail_id_b AS VARCHAR) + ',' + CAST(@_source_deal_detail_id_s AS VARCHAR) + ',''' + CONVERT(VARCHAR(10),@_term_start, 121) + ''', volm.vol, 
					(' + CAST(@_deal_volume AS VARCHAR) + ' - volm.vol) buy_outstanding_vol,
					(' + CAST(@_deal_volume_s AS VARCHAR) + ' - volm.vol) sell_outstanding_vol
					 FROM
					(SELECT (SELECT ABS(MIN(v)) FROM (VALUES (' + CAST(@_deal_volume AS VARCHAR) + '), (' + CAST(@_deal_volume_s AS VARCHAR) + ')) AS value(v)) vol) volm'

				EXEC (@sql)
			END

    		COMMIT
			IF @flag ='e'
			BEGIN
				EXEC spa_ErrorHandler -1
				, 'match_deal_volume'
				, 'spa_match_deal_volume'
				, 'DB ERROR'
				, 'Deal already matched.'
				, ''
			END
			ELSE
			BEGIN
				DECLARE @id VARCHAR(100) = @source_deal_detail_id + ',' + @source_deal_detail_id_2
				EXEC spa_ErrorHandler 0
					, 'match_deal_volume'
					, 'spa_match_deal_volume'
					, 'Success'
					, 'Deal has been successfully matched.'
					, @id
					
			END
		END TRY
		BEGIN CATCH
    		IF @@TRANCOUNT > 0
				ROLLBACK
			DECLARE @err_msg VARCHAR(MAX)
			SET @err_msg = error_message()
			EXEC spa_ErrorHandler -1
				, 'match_deal_volume'
				, 'spa_match_deal_volume'
				, 'DB ERROR'
				, @err_msg
				, ''
		END CATCH
	
 END 

