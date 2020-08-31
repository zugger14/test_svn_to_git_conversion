IF OBJECT_ID('[dbo].[spa_export_hedge_item]') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_export_hedge_item]
GO 

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**
This SP is used to get Gen fas link header and detail
	Parameters: 
	@book_id 			: Book entity ids
	@as_of_date  		: Date to run process
	@batch_process_id  	: Batch Unique id
	@batch_report_param : Batch parameters
	@enable_paging  	: Enable paging
	@page_size    		: Page size
	@page_no  			: page number
*/

CREATE PROCEDURE [dbo].[spa_export_hedge_item]
	@book_id VARCHAR(MAX) = NULL,
	@as_of_date VARCHAR(20) = NULL,
	@batch_process_id VARCHAR(50) = NULL,
	@batch_report_param VARCHAR(500) = NULL ,
	@enable_paging INT = NULL, --'1'=enable, '0'=disable
	@page_size INT = NULL,
	@page_no INT = NULL
AS

/*------------------Debug Section-----------------------
DECLARE @book_id VARCHAR(MAX) = NULL,
		@as_of_date VARCHAR(20) = NULL,
		@batch_process_id VARCHAR(50) = NULL,
		@batch_report_param VARCHAR(500) = NULL ,
		@enable_paging INT = NULL, --'1'=enable, '0'=disable
		@page_size INT = NULL,
		@page_no INT = NULL
SELECT  @book_id = '859,867,857,858,888,886,889,870,890,887,878,864,865,860,866,869,872,873,874,877,861,862,863,868,854,855,856,871,875,876,669,670,671,672,673,674,675,676,677,795,678,679,680,681,682,683,881,817,818,819,820,821,822,823,824,885,825,837,792,684,685,686,687,688,689,690,691,692,693,694,695,696,697,698,796,797,699,700,702,703,704,705,706,707,708,709,710,711,712,713,714,715,716,786,717,718,719,720,721,722,723,725,726,727,728,729,730,731,732,733,734,735,736,737,738,739,740,741,742,743,744,745,747,748,749,750,751,752,753,754,755,756,757,758,759,760,761,762,763,764,765,766,767,768,769,770,771,772,773,774,775,826,827,828,829,830,831,832,833,834,835,836,776,884,803,777,778,779,780,781,782,783,784,785',
		@as_of_date = '2017-02-01'
------------------------------------------------------*/

SET NOCOUNT ON
--////////////////////////////Paging_Batch///////////////////////////////////////////
EXEC spa_print	'@batch_process_id:', atch_process_id 
EXEC spa_print	'@batch_report_param:',	@batch_report_param

DECLARE @str_batch_table VARCHAR(MAX),@str_get_row_number VARCHAR(100)
DECLARE @temptablename VARCHAR(100),@user_login_id VARCHAR(50), @flag CHAR(1)
DECLARE @is_batch BIT
DECLARE @report_measurement_values VARCHAR(100)
DECLARE @sql_stmt VARCHAR(8000)

SET @str_batch_table = ''
SET @str_get_row_number = ''
SET @report_measurement_values = dbo.FNAGetProcessTableName(@as_of_date, 'export_hedge_item')

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
	EXEC spa_print '@temptablename:', @temptablename
	SET @str_batch_table=' INTO ' + @temptablename
	SET @str_get_row_number=', ROWID=IDENTITY(int,1,1)'

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
			SET @sql_stmt=''

			SELECT @sql_stmt=@sql_stmt+',['+[name]+']' FROM adiha_process.sys.columns WHERE [OBJECT_ID] = OBJECT_ID(@temptablename) AND [name] <> 'ROWID' ORDER BY column_id
			SET @sql_stmt = SUBSTRING(@sql_stmt, 2, LEN(@sql_stmt))
			
			SET @sql_stmt = 'SELECT ' + @sql_stmt + '
							FROM ' + @temptablename + ' 
							WHERE rowid BETWEEN '+ CAST(@row_from AS VARCHAR) + ' AND ' + CAST(@row_to AS VARCHAR) 
				 
			EXEC spa_print @sql_stmt		
			EXEC(@sql_stmt)
			RETURN
		END --else @page_size IS not NULL
	END --enable_paging = 1
END

BEGIN	
	DECLARE @book1 VARCHAR(250)
	DECLARE @book2 VARCHAR(250)
	DECLARE @book3 VARCHAR(250)
	DECLARE @book4 VARCHAR(250)

	SELECT @book1 = group1 FROM source_book_mapping_clm
	SELECT @book2 = group2 FROM source_book_mapping_clm
	SELECT @book3 = group3 FROM source_book_mapping_clm
	SELECT @book4 = group4 FROM source_book_mapping_clm

	DECLARE @sql VARCHAR(MAX)
	SET @sql = '
			SELECT     	
				flh.gen_hedge_group_id AS [Gen Group ID],
	 			ISNULL(MAX(ghg.gen_hedge_group_name),'''') AS [Gen Group Name],
				fld.deal_number AS [Deal ID], 
				fld.percentage_included AS [Perc Included],
				dbo.FNADateFormat(MAX(flh.link_effective_date)) [Eff Date], 
				dbo.FNADateFormat(sdh.deal_date) AS [Deal Date], 
				CASE 
					WHEN fld.hedge_or_item = ''i'' THEN ''Item''
					WHEN fld.hedge_or_item = ''h'' THEN ''Hedge''
					ELSE '''' END AS [Hedge/Item],
				MAX(sdd.Leg) AS Leg, 
				dbo.FNADateFormat(MIN(sdd.term_start)) AS [Term Start], 
				dbo.FNADateFormat(MAX(sdd.term_end)) AS [Term End], 
				sdh.deal_id AS [Reference ID], 
				MAX((CASE sdd.fixed_float_leg WHEN ''f'' THEN ''Fixed'' ELSE ''Float'' END)) AS [Fixed/Float], 
				MAX(CASE sdh.header_buy_sell_flag WHEN ''b'' THEN ''Buy (Receive)'' ELSE ''Sell (Pay)'' END) AS [Buy/Sell], 
				dbo.FNARemoveTrailingZeroes(ROUND(SUM(sdd.deal_volume)/COUNT(sdd.Leg), 2)) AS Volume, 
				dbo.FNARemoveTrailingZeroes(CAST(fld.percentage_included * (SUM(sdd.deal_volume)/COUNT(sdd.Leg)) AS NUMERIC(18, 2))) [Matched Volume],
				dbo.FNARemoveTrailingZeroes(SUM(sdd.deal_volume)/COUNT(sdd.Leg)-(fld.percentage_included * (SUM(sdd.deal_volume)/COUNT(sdd.Leg)))) [Available Volume],
				MAX(CASE sdd.deal_volume_frequency WHEN ''m'' THEN ''Monthly'' ELSE ''Daily'' END) AS Frequency, 
				MAX(source_uom.uom_name) AS UOM, 
				MAX(source_price_curve_def.curve_name) AS [Index],
				dbo.FNARemoveTrailingZeroes(ROUND(AVG(CASE WHEN sdd.fixed_price=0 THEN NULL ELSE sdd.fixed_price END),3)) Price, 
				ISNULL(dbo.FNARemoveTrailingZeroes(AVG(sdd.option_strike_price)),'''') [Strike Price],
				MAX(source_currency.currency_name) AS Currency,  
				Book1.source_book_name AS [' + @book1 + '], 
				Book2.source_book_name AS [' + @book2 + '],
				Book3.source_book_name AS [' + @book3 + '],
				Book4.source_book_name AS [' + @book4 + '],
				CASE sdh.option_type WHEN ''c'' THEN ''Call'' WHEN ''p'' THEN ''Put'' ELSE '''' END AS [Option Type], 
				ISNULL (CASE sdh.option_excercise_type WHEN ''e'' THEN ''European'' WHEN ''a'' THEN ''American'' ELSE sdh.option_excercise_type END, '''') AS [Exercise Type],
				IIF(MAX(flh.gen_approved) = ''y'', ''Yes'', ''No'') [Approved Status]
			' + @str_batch_table + '	
			FROM gen_fas_link_detail fld 
 			INNER JOIN gen_fas_link_header flh ON fld.gen_link_id = flh.gen_link_id 
			INNER JOIN (SELECT source_deal_header_id, deal_date, deal_id,  header_buy_sell_flag, option_type, option_excercise_type,
						source_system_book_id1, source_system_book_id2, source_system_book_id3, source_system_book_id4
						,''s'' src
					FROM source_deal_header 
					UNION ALL
					SELECT gdh1.gen_deal_header_id, gdh1.deal_date, gdh1.deal_id, gdd1.buy_sell_flag, gdh1.option_type, gdh1.option_excercise_type,
						gdh1.source_system_book_id1, gdh1.source_system_book_id2, gdh1.source_system_book_id3, gdh1.source_system_book_id4,''f'' src
					FROM gen_deal_header gdh1
					INNER JOIN gen_deal_detail gdd1 ON  gdd1.gen_deal_header_id = gdh1.gen_deal_header_id) sdh 
						ON fld.deal_number = sdh.source_deal_header_id 
							AND sdh.src = ISNULL(fld.deal_id_source, ''s'')
					INNER JOIN source_book Book1 ON sdh.source_system_book_id1 = Book1.source_book_id 
					INNER JOIN source_book Book2 ON sdh.source_system_book_id2 = Book2.source_book_id 
					INNER JOIN source_book Book3 ON sdh.source_system_book_id3 = Book3.source_book_id 
					INNER JOIN source_book Book4 ON sdh.source_system_book_id4 = Book4.source_book_id 
					INNER JOIN (SELECT source_deal_header_id, option_strike_price, fixed_price, deal_volume_frequency, Leg, deal_volume,  
									fixed_float_leg, term_end, term_start, deal_volume_uom_id, curve_id, fixed_price_currency_id,''s'' src
								FROM source_deal_detail 
								UNION ALL 
								SELECT gen_deal_header_id, option_strike_price, fixed_price, deal_volume_frequency, Leg, deal_volume,
									fixed_float_leg, term_end, term_start, deal_volume_uom_id, curve_id, fixed_price_currency_id,''f'' src
								FROM gen_deal_detail
					) sdd ON fld.deal_number = sdd.source_deal_header_id AND sdd.src = ISNULL(fld.deal_id_source, ''s'')
			INNER JOIN source_uom ON sdd.deal_volume_uom_id = source_uom.source_uom_id 
			LEFT JOIN source_price_curve_def ON sdd.curve_id = source_price_curve_def.source_curve_def_id 
			LEFT JOIN source_currency ON source_currency.source_currency_id = sdd.fixed_price_currency_id
			LEFT JOIN gen_fas_link_detail_dicing fldd ON fld.gen_link_id = fldd.link_id -- and  fld.deal_number = fldd.source_deal_header_id
			LEFT JOIN source_deal_header gen_sdh ON gen_sdh.source_deal_header_id = fld.deal_number
			LEFT JOIN gen_hedge_group ghg ON ghg.gen_hedge_group_id = flh.gen_hedge_group_id
			WHERE  1 = 1 
				AND sdd.Leg = 1 
				' + CASE WHEN @book_id IS NULL THEN '' ELSE ' AND flh.fas_book_id IN (' + @book_id + ')' END + '
				AND flh.gen_status <> ''r''
			GROUP BY fld.deal_number,sdh.deal_id,fld.percentage_included,fld.gen_link_id,
						dbo.FNADateFormat(sdh.deal_date),Book1.source_book_name,Book2.source_book_name,
						Book3.source_book_name, Book4.source_book_name,sdh.option_type,sdh.option_excercise_type
						,flh.gen_hedge_group_id,fld.gen_link_id,fld.hedge_or_item
			ORDER BY flh.gen_hedge_group_id,fld.gen_link_id,fld.hedge_or_item
		'

	EXEC spa_print @sql
	EXEC (@sql)	
END

IF @is_batch = 1
BEGIN
	EXEC spa_print '@str_batch_table'  
	SELECT @str_batch_table=dbo.FNABatchProcess('u', @batch_process_id,@batch_report_param, GETDATE(), NULL, NULL)   
	EXEC spa_print @str_batch_table
	EXEC(@str_batch_table)                   
	    
	SELECT @str_batch_table=dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, GETDATE(), 'spa_export_hedge_item', 'Run Gen Link Report')         
	EXEC spa_print @str_batch_table
	EXEC(@str_batch_table)        
	EXEC spa_print 'finsh spa_export_hedge_item'
	RETURN
END

IF @enable_paging = 1
BEGIN
	IF @page_size IS NULL
	BEGIN
		SET @sql_stmt = 'SELECT COUNT(1) TotalRow, ''' + @batch_process_id + ''' process_id FROM ' + @temptablename
		EXEC spa_print @sql_stmt
		EXEC(@sql_stmt)
	END
	RETURN
END 

GO