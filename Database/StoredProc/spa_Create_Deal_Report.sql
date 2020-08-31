IF OBJECT_ID(N'spa_Create_Deal_Report', N'P') IS NOT NULL
DROP PROCEDURE spa_Create_Deal_Report
 GO 

-- exec spa_Create_Deal_Report '9', NULL, NULL, '2006-03-28', '2008-03-22','n',NULL
--	exec spa_Create_Deal_Report NULL, 130019, NULL, '2001-02-20', '2008-03-20','y'
-- exec spa_Create_Deal_Report '473', NULL, NULL, '2001-12-25', '2008-01-25','y'
--exec spa_Create_Deal_Report '400', NULL, NULL, '2005-03-31', '2008-01-22','y'
--exec spa_Create_Deal_Report '54',NULL,NULL,'2002-08-28','2004-09-28','y'

--@book_deal_type_map_id is required and takes mustiple ids
--@deal_id_from, @deal_id_to are optional
--@deal_date_from, @deal_date_to are optional
--exec spa_Create_Deal_Report NULL, NULL, NULL, '2010-07-03', '2011-08-03','n',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'1',NULL,'276'
-- DROP PROC spa_Create_Deal_Report
-- exec spa_Create_Deal_Report '8', NULL, NULL, '2003-5-7' , '2004-6-7', 'n' 

CREATE PROC [dbo].[spa_Create_Deal_Report] 
	@book_deal_type_map_id	VARCHAR(200)		, 
	@deal_id_from			INT			= NULL	, 
	@deal_id_to				INT			= NULL	, 
	@deal_date_from			VARCHAR(10) = NULL	, 
	@deal_date_to			VARCHAR(10) = NULL	,
	@use_by_linking			CHAR(1)		= 'n'	,
	@deal_id				VARCHAR(50) = NULL	,
	@tenor_from				VARCHAR(50) = NULL	,
	@tenor_to				VARCHAR(50) = NULL	,
	@match					CHAR(1)		= 'n'	,
	@counterparty			VARCHAR(10) = NULL	,
	@index_group			VARCHAR(10) = NULL	,
	@index					VARCHAR(10) = NULL	,
	@commodity				VARCHAR(10) = NULL	,
	@contract				VARCHAR(10) = NULL	,
	@txtDescp1				VARCHAR(500) = NULL	,
	@txtDescp2				VARCHAR(500) = NULL	,
	@optBuySell				CHAR(1)		= 'a'   ,
	@hedge_item_flag		CHAR(1)		= NULL  ,
	@sub_id					INT			= NULL,
	@starategy_id			INT			= NULL,
	@book_id				INT			= NULL,
	@deal_idTo				VARCHAR(50) = NULL,
	@batch_process_id		VARCHAR(250) = NULL,
    @batch_report_param		VARCHAR(500) = NULL,
	@enable_paging			INT = 0,  --'1' = enable, '0' = disable
    @page_size				INT = NULL,
    @page_no				INT = NULL
		
AS

SET NOCOUNT ON

DECLARE @sql_Select VARCHAR(MAX)
DECLARE @sql_Where VARCHAR (2000)
DECLARE @sql_group_by VARCHAR (2000)

/*******************************************1st Paging Batch START**********************************************/
DECLARE @str_batch_table VARCHAR(8000)
DECLARE @user_login_id VARCHAR(50)
DECLARE @sql_paging VARCHAR(8000)
DECLARE @is_batch BIT
SET @str_batch_table = ''
SET @user_login_id = dbo.FNADBUser() 
SET @is_batch = CASE WHEN @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL THEN 1 ELSE 0 END 
IF @is_batch = 1
   SET @str_batch_table = ' INTO ' + dbo.FNAProcessTableName('batch_report', @user_login_id, @batch_process_id)
IF @enable_paging = 1 --paging processing
BEGIN
   IF @batch_process_id IS NULL
      SET @batch_process_id = dbo.FNAGetNewID()
   
   SET @str_batch_table = dbo.FNAPagingProcess('p', @batch_process_id, @page_size, @page_no)
   
   --retrieve data from paging table instead of main table
   IF @page_no IS NOT NULL 
   BEGIN
      SET @sql_paging = dbo.FNAPagingProcess('s', @batch_process_id, @page_size, @page_no) 
      EXEC (@sql_paging) 
      RETURN 
   END
END
/*******************************************1st Paging Batch END**********************************************/

--TO TEST UNCOMMENT THIS

-- declare @book_deal_type_map_id varchar(100)
-- declare @deal_id_from int 
-- declare @deal_id_to int 
-- declare @deal_date_from datetime 
-- declare @deal_date_to datetime 
--DECLARE @use_by_linking CHAR
-- 
-- SET @book_deal_type_map_id = '2, 8, 10'
-- 
-- set @deal_id_from = null
-- set @deal_id_to = null
-- set @deal_date_from = '1/1/2003'
-- set @deal_date_to = '7/1/2004'
-- set @use_by_linking = 'y'
-- END OF TO TEST UNCOMMENT THIS

--########### Group Label
DECLARE @group1  VARCHAR(100),
        @group2  VARCHAR(100),
        @group3  VARCHAR(100),
        @group4  VARCHAR(100)

IF EXISTS(
       SELECT group1,
              group2,
              group3,
              group4
       FROM   source_book_mapping_clm
   )
BEGIN
    SELECT @group1 = group1,
           @group2 = group2,
           @group3 = group3,
           @group4 = group4
    FROM   source_book_mapping_clm
END
ELSE
BEGIN
    SET @group1 = 'Group1'
    SET @group2 = 'Group2'
    SET @group3 = 'Group3'
    SET @group4 = 'Group4'
END
--######## End
IF @deal_id_to IS NULL
   AND @deal_id_from IS NOT NULL
    SET @deal_id_to = @deal_id_from

IF @deal_id_from IS NULL
   AND @deal_id_to IS NOT NULL
    SET @deal_id_from = @deal_id_to
    
IF @deal_id IS NULL
   AND @deal_idTo IS NOT NULL
    SET @deal_id = @deal_idTo

IF @deal_idTo IS NULL
   AND @deal_id IS NOT NULL
    SET @deal_idTo = @deal_id


CREATE TABLE #books
(
	fas_book_id            INT,
	book_deal_type_map_id  INT
) 

SET @sql_Select=
	'INSERT INTO #books
	 SELECT DISTINCT book.entity_id fas_book_id,
	        ssbm.book_deal_type_map_id
	 FROM   portfolio_hierarchy book(NOLOCK)
	        INNER JOIN Portfolio_hierarchy stra(NOLOCK)
	             ON  book.parent_entity_id = stra.entity_id
	        LEFT OUTER JOIN source_system_book_map ssbm
	             ON  ssbm.fas_book_id = book.entity_id
	 WHERE  ( fas_deal_type_value_id IS NULL
	            OR fas_deal_type_value_id BETWEEN 400 AND 401
	        )'
	+ CASE 
	       WHEN @sub_id IS NOT NULL THEN ' AND stra.parent_entity_id IN  ( ' + 
	            CAST(@sub_id AS VARCHAR) + ') '
	       ELSE ''
	  END
	+ 
	  CASE 
	       WHEN @starategy_id IS NOT NULL THEN ' AND stra.entity_id IN  ( ' + 
	            CAST(@starategy_id AS VARCHAR) + ') '
	       ELSE ''
	  END
	+ 
	  CASE 
	       WHEN @book_id IS NOT NULL THEN ' AND book.entity_id IN  ( ' + CAST(@book_id AS VARCHAR) 
	            + ') '
	       ELSE ''
	  END
	+ 
	  CASE 
	       WHEN @book_deal_type_map_id IS NOT NULL THEN 
	            'AND ssbm.book_deal_type_map_id IN  ( ' + @book_deal_type_map_id 
	            + ') '
	       ELSE ''
	  END 

exec spa_print @sql_Select
EXEC (@sql_Select)

IF @use_by_linking = 'n'
BEGIN

	SET @sql_Select = 
			'SELECT cast(round(isnull(sum(case when '''+@deal_date_from+''' between isnull(flh.link_effective_date,''1900-01-01'') and isnull(flh.link_end_date,''9999-01-01'') then isnull(fld.percentage_included,0) else 0 end), 0),2)  as varchar) as PercLinked, 
			sDH.source_deal_header_id AS DealID, 
			dbo.FNAHyperLinkText(10131010, sDH.deal_id, sDH.source_deal_header_id) SourceDealID,
--			sDH.deal_id AS SourceDealID, 
			dbo.FNADateFormat(sDH.deal_date) as DealDate, 
			dbo.FNADateFormat(sDH.deal_date) AS EffectiveDate, 
			dT.source_deal_type_name AS SourceDealType, 
	             	dSubT.source_deal_type_name AS SubDealType, sb1.source_book_name AS ['+ @group1 +'], 
	                sb2.source_book_name AS ['+ @group2 +'], sb3.source_book_name AS ['+ @group3 +'], 
	                sb4.source_book_name AS ['+ @group4 +'], 
			dbo.FNADateFormat(sDD.term_start)  AS TermStart, 
			dbo.FNADateFormat(sDD.term_end) AS TermEnd, 
			sDD.Leg AS Leg, 
	                CASE WHEN(sDD.fixed_float_leg = ''f'') THEN ''Fixed'' 
					WHEN(sDD.fixed_float_leg = ''t'') THEN ''Float'' 
					ELSE sDD.fixed_float_leg END AS FixedFloat, 
			sPCD.curve_name AS CurveName,
			dbo.FNARemoveTrailingZeroes(sDD.fixed_price) AS Price, 
			dbo.FNARemoveTrailingZeroes(sDD.option_strike_price) AS Strike, 
			sC.currency_name AS Currency, 
			case when  (sDD.buy_sell_flag= ''b'')  then ''Buy (Rec)'' else ''Sell (Pay)'' end BuySell,
	                dbo.FNARemoveTrailingZeroes(sDD.deal_volume) AS DealVolume, source_uom.uom_name AS DealUOM,
			CASE WHEN(sDD.deal_volume_frequency = ''m'') THEN ''Monthly''
					WHEN(sDD.deal_volume_frequency = ''d'') THEN ''Daily'' 
					ELSE sDD.deal_volume_frequency END AS VolumeFrequency
			 ' + @str_batch_table + ' 
			FROM   source_deal_detail sDD INNER JOIN
	                      source_deal_header sDH ON sDD.source_deal_header_id = sDH.source_deal_header_id INNER JOIN
	                      source_system_book_map sSBM ON sDH.source_system_book_id1 = sSBM.source_system_book_id1 AND 
	                      sDH.source_system_book_id2 = sSBM.source_system_book_id2 AND sDH.source_system_book_id3 = sSBM.source_system_book_id3 AND 
	                      sDH.source_system_book_id4 = sSBM.source_system_book_id4 
						  INNER JOIN #books fas_book_id ON fas_book_id.fas_book_id = ssbm.fas_book_id -- added for tree filter
						  LEFT JOIN #books ON #books.book_deal_type_map_id=sSBM.book_deal_type_map_id
						  LEFT OUTER JOIN
	                      source_currency sC ON sDD.fixed_price_currency_id = sC.source_currency_id LEFT OUTER JOIN
	                      source_price_curve_def sPCD ON sDD.curve_id = sPCD.source_curve_def_id  LEFT OUTER JOIN
	                      source_uom ON sDD.deal_volume_uom_id = source_uom.source_uom_id LEFT OUTER JOIN
	                      source_deal_type dT ON sDH.source_deal_type_id = dT.source_deal_type_id LEFT OUTER JOIN
	                      source_book sb4 ON sDH.source_system_book_id4 = sb4.source_book_id LEFT OUTER JOIN
	                      source_book sb3 ON sDH.source_system_book_id3 = sb3.source_book_id LEFT OUTER JOIN
	                      source_book sb2 ON sDH.source_system_book_id2 = sb2.source_book_id LEFT OUTER JOIN
	                      source_book sb1 ON sDH.source_system_book_id1 = sb1.source_book_id LEFT OUTER JOIN
	                      source_deal_type dSubT ON sDH.deal_sub_type_type_id = dSubT.source_deal_type_id LEFT OUTER JOIN
			      fas_link_detail fld ON fld.source_deal_header_id = sDH.source_deal_header_id left join 
				fas_link_header flh on fld.link_id=flh.link_id'
	SET @sql_Where = ' WHERE 1=1' 
	IF @book_deal_type_map_id IS NOT NULL
	SET @sql_Where =@sql_Where+' and sSBM.book_deal_type_map_id IN ( ' + @book_deal_type_map_id + ' )'
	
	SET @sql_group_by = ' group by 	sDH.source_deal_header_id, 
			sDH.deal_id, sDH.deal_date, sDH.deal_date,
			dT.source_deal_type_name, 	
			dSubT.source_deal_type_name, 
			sb1.source_book_name, 
	                sb2.source_book_name, 
			sb3.source_book_name, 
	                sb4.source_book_name, 
			dbo.FNADateFormat(sDD.term_start), 
			dbo.FNADateFormat(sDD.term_end), 
			sDD.Leg, 
	                sDD.fixed_float_leg, 
			sPCD.curve_name,
			sDD.fixed_price, 
			sDD.option_strike_price, 
			sC.currency_name, 
	                sDD.deal_volume, 
			sDD.buy_sell_flag,
			source_uom.uom_name,
			sDD.deal_volume_frequency'
	
	

	IF (@deal_id_from IS NOT NULL) AND (@deal_id_to IS NOT NULL) 
		SET @sql_Where = @sql_Where + ' AND sDH.source_deal_header_id BETWEEN ' + CAST(@deal_id_from AS VARCHAR)  + ' AND ' + CAST(@deal_id_to AS VARCHAR) 

--	IF (@deal_id_from IS NOT NULL) AND (@deal_id_to IS NOT NULL) 
--		SET @sql_Where = @sql_Where + ' AND PATINDEX(''%-%'',sDH.deal_id) =0 AND sDH.deal_id BETWEEN ' + CAST(@deal_id_from As varchar)  + ' AND ' + CAST(@deal_id_to AS varchar) 
	
	IF (@deal_date_from IS NOT NULL) AND (@deal_date_to IS NOT NULL)  AND @deal_id_from IS NULL AND  @deal_id IS NULL
		SET @sql_Where = @sql_Where + ' AND sDH.deal_date <= ''' + @deal_date_to + ''''
--		SET @sql_Where = @sql_Where + ' AND sDH.deal_date BETWEEN '''+ @deal_date_from + ''' and ''' + @deal_date_to + ''''

	IF (@deal_id IS NOT NULL) AND (@deal_idTo IS NOT NULL)
		SET @sql_Where = @sql_Where + ' AND sDH.deal_id between '''+ @deal_id + ''' and ''' + @deal_idTo + '''' 
	 exec spa_print @sql_Select, @sql_Where, @sql_group_by
	 EXEC (@sql_Select + @sql_Where + @sql_group_by)
	

END -- BEGIN
ELSE
BEGIN

SET @sql_Select = 
	'SELECT     
	ISNULL(MAX(outstanding.percentage_use), 0) AS PercLinked,
	dh.source_deal_header_id as DealId, 
	dbo.FNAHyperLinkText(10131010, dh.deal_id, dh.source_deal_header_id) SourceDealID,
--	dh.deal_id as RiskDealId, 
	dbo.FNADateFormat(dh.deal_date) as DealDate, 
	dbo.FNADateFormat(case when (max(flh.link_end_date) is not null AND max(flh.link_end_date) > max(dh.deal_date)) then max(flh.link_end_date) else max(dh.deal_date) end) as EffectiveDate,
	dh.physical_financial_flag, 
	source_counterparty.counterparty_name CptyName, 
        dbo.FNADateFormat(dh.entire_term_start) as TermStart, 
	dbo.FNADateFormat(dh.entire_term_end) As TermEnd, source_deal_type.source_deal_type_name As DealType, 
	source_deal_type_1.source_deal_type_name AS DealSubType, 
        dh.option_flag As OptionFlag, dh.option_type As OptionType, dh.option_excercise_type As ExcersiceType, 
	source_book.source_book_name As ['+ @group1 +'], 
	source_book_1.source_book_name AS ['+ @group2 +'], 
        source_book_2.source_book_name AS ['+ @group3 +'], source_book_3.source_book_name AS ['+ @group4 +'],
	max(dh.description1) As Desc1, max(dh.description2) As Desc2
	 ' + @str_batch_table + ' 
	 FROM source_deal_header dh
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = dh.source_deal_header_id 
		INNER JOIN source_system_book_map sbmp ON 
					dh.source_system_book_id1 = sbmp.source_system_book_id1 AND 
					dh.source_system_book_id2 = sbmp.source_system_book_id2 AND 
					dh.source_system_book_id3 = sbmp.source_system_book_id3 AND 
					dh.source_system_book_id4 = sbmp.source_system_book_id4 AND
					isnull(sdh.fas_deal_type_value_id,sbmp.fas_deal_type_value_id) = CASE WHEN ''' + @hedge_item_flag + ''' = ''h'' THEN 400 ELSE 401 END
		INNER JOIN #books ON #books.book_deal_type_map_id=sbmp.book_deal_type_map_id
		INNER JOIN source_counterparty ON dh.counterparty_id = source_counterparty.source_counterparty_id 
		INNER JOIN source_deal_type ON dh.source_deal_type_id = source_deal_type.source_deal_type_id 
		INNER JOIN source_book ON dh.source_system_book_id1 = source_book.source_book_id 
		INNER JOIN source_book source_book_1 ON dh.source_system_book_id2 = source_book_1.source_book_id 
		INNER JOIN source_book source_book_2 ON dh.source_system_book_id3 = source_book_2.source_book_id 
		INNER JOIN source_book source_book_3 ON dh.source_system_book_id4 = source_book_3.source_book_id 
		LEFT OUTER JOIN source_deal_type source_deal_type_1 ON dh.deal_sub_type_type_id = source_deal_type_1.source_deal_type_id 
		LEFT OUTER JOIN fas_link_detail fld ON fld.source_deal_header_id = dh.source_deal_header_id 
		LEFT JOIN fas_link_header flh on fld.link_id=flh.link_id
		LEFT OUTER JOIN	
			(
			SELECT 
					source_deal_header_id, 
					SUM(percentage_use) percentage_use 
				FROM (
						SELECT 
							dh.source_deal_header_id, 
							null link_end_date, 
							SUM(gfld.percentage_included) AS  percentage_use,
							MAX(''o'') src
						FROM source_deal_header dh 
							INNER JOIN gen_fas_link_detail gfld 
								ON gfld.deal_number = dh.source_deal_header_id 
							INNER JOIN gen_fas_link_header gflh 
								ON gflh.gen_link_id = gfld.gen_link_id
								AND gflh.gen_status = ''a''
						GROUP BY dh.source_deal_header_id, dh.deal_date
						UNION ALL
						SELECT source_deal_header_id,
							MAX(fas_link_header.link_end_date) link_effective_date, 
							SUM(CASE 
									WHEN CONVERT(VARCHAR (10), '''+ @deal_date_from + ''', 120) >= ISNULL(fas_link_header.link_end_date,''9999-01-01'') THEN 0 
									ELSE percentage_included 
								END
								) percentage_included, 
							MAX(''f'') 
						FROM fas_link_detail 
						INNER JOIN fas_link_header
							ON fas_link_detail.link_id = fas_link_header.link_id 
						GROUP BY source_deal_header_id
						UNION ALL
						SELECT 
							a.source_deal_header_id, 
							NULL link_effective_date, 
							SUM(a.[per_dedesignation]) [per_dedesignation], 
							MAX(''l'') src 
						FROM(
								SELECT 
									DISTINCT process_id, 
									source_deal_header_id, [per_dedesignation] 
								FROM [dbo].[dedesignated_link_deal]
							) a group by a.source_deal_header_id

					) used_per 
				GROUP BY used_per.source_deal_header_id
			) outstanding ON outstanding.source_deal_header_id = dh.source_deal_header_id
		LEFT OUTER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = sdd.curve_id
		
--		LEFT OUTER JOIN dbo.source_deal_detail_template dt ON dt.template_id = dh.template_id
--		LEFT OUTER JOIN source_commodity sc ON sc.source_commodity_id = dt.commodity_id
	WHERE   1=1'
	
	SET @sql_Where = ' ' 
	
	IF @book_deal_type_map_id IS NOT NULL 
		SET @sql_Where = @sql_Where + ' and sbmp.book_deal_type_map_id in( ' + @book_deal_type_map_id + ')' 

	IF (@deal_id_from IS NOT NULL) AND (@deal_id_to IS NOT NULL) 
		SET @sql_Where = @sql_Where + ' AND dh.source_deal_header_id BETWEEN ' + CAST(@deal_id_from AS VARCHAR)  + ' AND ' + CAST(@deal_id_to AS VARCHAR)
		
	IF (@deal_id IS NOT NULL) AND (@deal_idTo IS NOT NULL) 
		SET @sql_Where = @sql_Where + ' AND dh.deal_id BETWEEN ''' + @deal_id + ''' AND ''' + @deal_idTo + ''''
		--SET @sql_Where = @sql_Where + ' AND dh.deal_id = '''+ @deal_id + '''' 
		
	IF @deal_id_from IS NULL AND  @deal_id IS NULL AND @deal_id IS NULL AND @deal_idTo IS NULL
	BEGIN
		IF (@deal_date_from IS NOT NULL) AND (@deal_date_to IS NOT NULL)
--		SET @sql_Where = @sql_Where + ' AND dh.deal_date <= ''' + @deal_date_to + ''''
		SET @sql_Where = @sql_Where + ' AND dh.deal_date BETWEEN '''+ @deal_date_from + ''' and ''' + @deal_date_to + ''''
			
		IF @tenor_from IS NOT NULL AND @match = 'n' 
			SET @sql_Where = @sql_Where + ' AND sdd.term_start >= ''' + @tenor_from + ''''
			
		IF @tenor_to IS NOT NULL AND @match = 'n' 
			SET @sql_Where = @sql_Where + ' AND sdd.term_start <= ''' + @tenor_to + ''''
			
		IF @tenor_from IS NOT NULL AND @match = 'y' 
			SET @sql_Where = @sql_Where + ' AND dh.entire_term_start = ''' + @tenor_from + ''''
			
		IF @tenor_to IS NOT NULL AND @match = 'y' 
			SET @sql_Where = @sql_Where + ' AND dh.entire_term_end = ''' + @tenor_to + ''''
			
		IF @counterparty IS NOT NULL
			SET @sql_Where = @sql_Where +' AND dh.counterparty_id= ''' + @counterparty + ''''
				
		IF @index_group IS NOT NULL
			SET @sql_Where = @sql_Where + ' AND spcd.index_group= ''' + @index_group + ''''
			
		IF @index IS NOT NULL
			SET @sql_Where = @sql_Where + ' AND spcd.source_curve_def_id= ''' + @index + ''''
			
		IF @commodity IS NOT NULL
			SET @sql_Where = @sql_Where + ' AND spcd.commodity_id= ''' + @commodity + ''''
			
		IF @contract IS NOT NULL
			SET @sql_Where = @sql_Where + ' AND dh.contract_id= ''' + @contract + ''''
			
		IF @txtDescp1 IS NOT NULL
			SET @sql_Where = @sql_Where +' AND dh.description1 = ''' + @txtDescp1 + ''''

		IF @txtDescp2 IS NOT NULL
			SET @sql_Where = @sql_Where +' AND dh.description2 = ''' + @txtDescp2 + ''''
		
		IF @optBuySell IS NOT NULL
		BEGIN
			IF  @optBuySell = 'a'
			BEGIN
				SET @sql_Where = @sql_Where +' AND dh.header_buy_sell_flag IN (''b'',''s'')'
			END
			ELSE
				BEGIN
					SET @sql_Where = @sql_Where +' AND dh.header_buy_sell_flag = ''' + @optBuySell + ''''
				END
		END
	END 
			
	SET @sql_Select = @sql_Select + @sql_where + ' group by   dh.source_deal_header_id, 
		   dh.deal_id, dh.deal_date, dh.deal_date, dh.physical_financial_flag, source_counterparty.counterparty_name, 
			   dh.entire_term_start, dh.entire_term_end, source_deal_type.source_deal_type_name, 
		   source_deal_type_1.source_deal_type_name, 
			   dh.option_flag, dh.option_type, dh.option_excercise_type, source_book.source_book_name, 
		   source_book_1.source_book_name, 
			   source_book_2.source_book_name, source_book_3.source_book_name, dh.header_buy_sell_flag
			having     (ISNULL(MAX(outstanding.percentage_use), 0) < 1)'
			--having     (1 - sum(case when '''+@deal_date_from+'''>=isnull(flh.link_end_date,''9999-01-01'') then 0 else isnull(fld.percentage_included,0) end) - isnull(sum(outstanding.percentage_use), 0)) >= 0.01'
	EXEC spa_print @sql_Select
	EXEC(@sql_Select)
	
END

/*******************************************2nd Paging Batch START**********************************************/
--update time spent and batch completion message in message board
IF @is_batch = 1
BEGIN
   SELECT @str_batch_table = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL) 
   EXEC(@str_batch_table)    
   SELECT @str_batch_table = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, GETDATE(), 'spa_create_deal_report', 'Run Transaction Report') --TODO: modify sp and report name
   EXEC(@str_batch_table)  
   RETURN
END

--if it is first call from paging, return total no. of rows and process id instead of actual data
IF @enable_paging = 1 AND @page_no IS NULL
BEGIN
   SET @sql_paging = dbo.FNAPagingProcess('t', @batch_process_id, @page_size, @page_no)
   EXEC(@sql_paging)
END
/*******************************************2nd Paging Batch END**********************************************/

GO
