/****** Object:  StoredProcedure [dbo].[spa_create_hedge_relationship_report]    Script Date: 03/09/2010 10:16:33 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_create_hedge_relationship_report]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_create_hedge_relationship_report]
GO
/****** Object:  StoredProcedure [dbo].[spa_create_hedge_relationship_report]    Script Date: 03/09/2010 10:16:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- exec spa_create_hedge_relationship_report  '2001-02-01', '2010-03-01', '36', NULL, NULL, NULL, 'n', 'y', NULL, NULL,'n'

-- exec spa_create_hedge_relationship_report  '2001-02-01', '2010-03-01', '36', NULL, NULL, NULL, 'n', 'y', NULL, NULL,'n', null, 'PD04001,PD05001'
-- exec spa_create_hedge_relationship_report '2001-09-30', '2007-10-30', '30', '122', NULL, NULL, 'n', 'y', NULL, NULL,'n'

CREATE PROCEDURE [dbo].[spa_create_hedge_relationship_report] 	@as_of_date_from varchar(50), 
							@as_of_date_to varchar(50),
							@sub_entity_id varchar(MAX), 
							@strategy_entity_id varchar(MAX) = NULL, 
							@book_entity_id varchar(MAX) = NULL, 
							@link_id varchar(MAX) = NULL,
							@fully_dedesignated char(1)=NULL,
							@link_active char(1)=NULL,
							@link_id_from int =  NULL,
							@link_id_to int = NULL,
							@eff_date_is_create_date varchar(1) = NULL,
							@source_deal_header_id varchar(500)=NULL,
							@deal_id varchar(500)=NULL,
							@round_value CHAR(1) = '0', 
							@batch_process_id VARCHAR(250) = NULL,
							@batch_report_param VARCHAR(500) = NULL, 
							@enable_paging INT = 0,		--'1' = enable, '0' = disable
							@page_size INT = NULL,
							@page_no INT = NULL 
	

AS
/*******************************************1st Paging Batch START**********************************************/
SET NOCOUNT ON 
 
DECLARE @str_batch_table  VARCHAR(8000)
DECLARE @user_login_id    VARCHAR(50)
DECLARE @sql_paging       VARCHAR(8000)
DECLARE @is_batch         BIT
SET @str_batch_table = ''
SET @user_login_id = dbo.FNADBUser() 
SET @is_batch = CASE 
                     WHEN @batch_process_id IS NOT NULL AND @batch_report_param 
                          IS NOT NULL THEN 1
                     ELSE 0
                END 

IF @is_batch = 1
BEGIN
    SET @str_batch_table = ' INTO ' + dbo.FNAProcessTableName('batch_report', @user_login_id, @batch_process_id)
END

IF @enable_paging = 1 --paging processing
BEGIN
    IF @batch_process_id IS NULL
    BEGIN
        SET @batch_process_id = dbo.FNAGetNewID()
	END   
        SET @str_batch_table = dbo.FNAPagingProcess ('p', @batch_process_id, @page_size, @page_no)
       
    --retrieve data from paging table instead of main table    
    IF @page_no IS NOT NULL
    BEGIN
        SET @sql_paging = dbo.FNAPagingProcess ('s', @batch_process_id, @page_size, @page_no)         
        EXEC (@sql_paging)         
        RETURN
    END
END/*******************************************1st Paging Batch END**********************************************/
-- Declare @link_id varchar(100)
-- Declare @as_of_date varchar(50), @sub_entity_id varchar(100), 
-- 	@strategy_entity_id varchar(100), 
-- 	@book_entity_id varchar(100)


-- SET @as_of_date = '2003-1-31'
-- --SET @link_id = '16'
-- set @sub_entity_id = '1'
-- set @strategy_entity_id = '3'
-- set @book_entity_id = '10'


DECLARE @sql_stmt As varchar(max)
DECLARE @sql_stmt_summary As varchar(max)

--########### Group Label
declare @group1 varchar(100),@group2 varchar(100),@group3 varchar(100),@group4 varchar(100)
 if exists(select group1,group2,group3,group4 from source_book_mapping_clm)
begin	
	select @group1=group1,@group2=group2,@group3=group3,@group4=group4 from source_book_mapping_clm
end
else
begin
	set @group1='Group 1'
	set @group2='Group 2'
	set @group3='Group 3'
	set @group4='Group 4'
 
end
--######## End

IF @deal_id = '' OR @deal_id IS NULL
	SET @deal_id = NULL
--ELSE
--BEGIN
--	set @deal_id = replace(@deal_id, ' ', '')
--	set @deal_id = '''' + replace(@deal_id, ',', ''',''') + ''''
--END


SET @sql_stmt = 'SELECT     	
				MAX(sub.entity_name) Subsidiary,
				MAX(strategy.entity_name) Strategy,
				MAX(book.entity_name) Book,
				--dbo.FNAHyperLinkText(61,flh.link_id, flh.link_id)  RelID,
				dbo.FNATRMWinHyperlink(''a'', 10233700, flh.link_id, ABS(flh.link_id),null,null,null,null,null,null,null,null,null,null,null,0) [Link ID],
				MAX(flh.original_link_id) [Dedesignated Link ID],
				CASE 	WHEN (MAX(flh.link_type_value_id) = 450) THEN ''Designation'' 
					WHEN (MAX(flh.link_type_value_id) = 451) THEN ''De-Designation Choice''  				
					ELSE ''De-Designation Not Prob'' END as [Relationship Type Name],
				dbo.FNADateFormat(MAX(flh.link_effective_date)) as [Effective Date],
				CASE WHEN (MAX(flh.perfect_hedge) = ''y'') THEN ''Yes'' else ''No'' end [Perfect Hedge],
				case when (MAX(fld.hedge_or_item) = ''h'') then ''Hedge'' else ''Item'' end [Transaction Type],
				MAX(sdh.deal_id) AS [Reference ID], 
			    dbo.FNATRMWinHyperlink(''a'', 10131010, fld.source_deal_header_id, ABS(fld.source_deal_header_id),null,null,null,null,null,null,null,null,null,null,null,0) [Deal ID],
			    --dbo.FNAHyperLinkText(120, cast(fld.source_deal_header_id as varchar), cast(fld.source_deal_header_id as varchar)) AS DealID, 
				CAST(CAST (MAX(fld.percentage_included) AS NUMERIC(38,' + @round_value + ')) AS VARCHAR(100)) [Percentage Included], 
				dbo.FNADateFormat(MAX(sdh.deal_date)) AS [Deal Date], 
				MAX(source_deal_detail.Leg) AS Leg, 
				MAX(source_price_curve_def.curve_name) AS [Index], 
                dbo.FNADateFormat(MIN(source_deal_detail.term_start)) AS [Term Start], 
				dbo.FNADateFormat(MAX(source_deal_detail.term_end)) AS [Term End], 
				(case MAX(source_deal_detail.buy_sell_flag) when ''b'' then ''Buy'' Else ''Sell'' end) AS [Buy/Sell], 
				CAST(CAST (sum(source_deal_detail.deal_volume) AS NUMERIC(38,' + @round_value + ')) AS VARCHAR(100)) Volume, 
				CAST(CAST (sum(source_deal_detail.deal_volume*fld.percentage_included) AS NUMERIC(38,' + @round_value + ')) AS VARCHAR(100)) [Allocated Volume], 
				MAX(source_uom.uom_name) AS UOM, 
--				cast(round(sum(source_deal_detail.deal_volume)/max(source_deal_detail.Leg), 2) as varchar) AS Volume, 
                (case MAX(source_deal_detail.deal_volume_frequency) when ''m'' then ''Monthly'' Else ''Daily'' end) AS Frequency, 
			    CAST(CAST (sum(source_deal_detail.fixed_price) AS NUMERIC(38,' + @round_value + ')) AS VARCHAR(100)) AS Price, 
				MAX(Book1.source_book_name) AS ['+@group1+'], 
				MAX(Book2.source_book_name) AS ['+@group2+'], 
				MAX(Book3.source_book_name) AS ['+@group3+'], 
                MAX(Book4.source_book_name) AS ['+@group4+'], 
				dbo.FNADateFormat(MAX(flh.create_ts)) as  [Created On],
				MAX(flh.create_user) as  [Created By]
				' + @str_batch_table +' 
FROM         	fas_link_detail fld INNER JOIN
				fas_link_header flh ON flh.link_id = fld.link_id INNER JOIN
                      		source_deal_header sdh ON fld.source_deal_header_id = sdh.source_deal_header_id INNER JOIN
                      		source_book Book1 ON sdh.source_system_book_id1 = Book1.source_book_id INNER JOIN
                      		source_book Book2 ON sdh.source_system_book_id2 = Book2.source_book_id INNER JOIN
                      		source_book Book3 ON sdh.source_system_book_id3 = Book3.source_book_id INNER JOIN
                      		source_book Book4 ON sdh.source_system_book_id4 = Book4.source_book_id INNER JOIN 
				source_system_book_map sbm ON 	sbm.source_system_book_id1 = sdh.source_system_book_id1 AND 
					                      	sbm.source_system_book_id2 = sdh.source_system_book_id2 AND 
								sbm.source_system_book_id3 = sdh.source_system_book_id3 AND 
					                      	sbm.source_system_book_id4 = sdh.source_system_book_id4 INNER JOIN 
				portfolio_hierarchy book ON book.entity_id = flh.fas_book_id INNER JOIN
				portfolio_hierarchy strategy ON book.parent_entity_id = strategy.entity_id INNER JOIN
				portfolio_hierarchy sub ON strategy.parent_entity_id = sub.entity_id INNER JOIN
                      		source_deal_detail ON sdh.source_deal_header_id = source_deal_detail.source_deal_header_id INNER JOIN
                      		source_uom ON source_deal_detail.deal_volume_uom_id = source_uom.source_uom_id LEFT OUTER JOIN
                      		source_price_curve_def ON source_deal_detail.curve_id = source_price_curve_def.source_curve_def_id
                      		'+
			CASE 
				WHEN  @deal_id IS NOT NULL THEN 'INNER JOIN dbo.SplitCommaSeperatedValues(''' + @deal_id + ''') ref_ids ON ref_ids.item =  sdh.deal_id'
				ELSE ''
			END
		+'
			WHERE 1=1'


IF @source_deal_header_id IS NULL AND @deal_id IS NULL AND @link_id_from IS NULL AND @link_id_to IS NULL 
BEGIN
	IF @eff_date_is_create_date <> 'y'
			SET @sql_stmt = @sql_stmt + ' AND source_deal_detail.leg = 1 AND (flh.link_effective_date between  CONVERT(DATETIME, ''' + ISNULL(@as_of_date_from, '') + ''' , 102) AND CONVERT(DATETIME, ''' + ISNULL(@as_of_date_to, '') + ''' , 102)) '
	ELSE
			SET @sql_stmt = @sql_stmt + ' AND source_deal_detail.leg = 1 AND (CONVERT(DATETIME, dbo.FNAGetSQLStandardDate(flh.create_ts), 102)  between  CONVERT(DATETIME, ''' +  ISNULL(@as_of_date_from, '') + ''' , 102) AND CONVERT(DATETIME, ''' + ISNULL(@as_of_date_to, '') + ''' , 102)) '

	If @link_active IS NOT NULL
		SET @sql_stmt = @sql_stmt + ' AND flh.link_active = ''' + @link_active + ''''
	
	If @link_id IS NOT NULL
		SET @sql_stmt = @sql_stmt + ' AND flh.link_id IN (' + @link_id + ')'
	ELSE
	BEGIN
		IF @sub_entity_id IS NOT NULL
			SET @sql_stmt = @sql_stmt + ' AND sub.entity_id IN (' + @sub_entity_id + ')'
		IF @strategy_entity_id IS NOT NULL
			SET @sql_stmt = @sql_stmt + ' AND strategy.entity_id IN (' + @strategy_entity_id + ')'
		IF @book_entity_id IS NOT NULL
			SET @sql_stmt = @sql_stmt + ' AND book.entity_id IN (' + @book_entity_id + ')'
	
	END
	
	IF @fully_dedesignated IS NOT NULL AND @fully_dedesignated = 'y' 	
		SET @sql_stmt = @sql_stmt + ' and flh.link_type_value_id <> 450 '
	ELSE IF @fully_dedesignated IS NOT NULL AND @fully_dedesignated = 'n'
		SET @sql_stmt = @sql_stmt + ' and flh.link_type_value_id = 450 '
END
ELSE
BEGIN
	IF @eff_date_is_create_date = 'y'
		SET @sql_stmt = @sql_stmt + ' AND source_deal_detail.leg = 1 AND (CONVERT(DATETIME, dbo.FNAGetSQLStandardDate(flh.create_ts), 102)  between  CONVERT(DATETIME, ''' + @as_of_date_from + ''' , 102) AND CONVERT(DATETIME, ''' + @as_of_date_to + ''' , 102)) '
	ELSE
		SET @sql_stmt = @sql_stmt + ' AND source_deal_detail.leg = 1'
	
	IF @source_deal_header_id IS NOT NULL
		set @sql_stmt = @sql_stmt + ' AND fld.source_deal_header_id IN (' + @source_deal_header_id + ')'

--	IF @deal_id is not null
--		set @sql_stmt = @sql_stmt + ' AND sdh.deal_id IN (' + @deal_id + ')'
END





IF @link_id_from IS NOT NULL and @link_id_to IS NOT NULL
	SET @sql_stmt = @sql_stmt + ' and flh.link_id BETWEEN ' + cast(@link_id_from as varchar) + ' and  ' + cast(@link_id_to as varchar)
	
ELSE IF @link_id_from IS NOT NULL AND @link_id_to IS NULL
	SET @sql_stmt = @sql_stmt + ' and flh.link_id >=' + CAST(@link_id_from AS VARCHAR)
	
ELSE IF @link_id_from IS NULL AND @link_id_to IS NOT NULL
	SET @sql_stmt = @sql_stmt + ' and flh.link_id <=' + CAST(@link_id_to AS VARCHAR)
		
--print @sql_stmt
--return


SET @sql_stmt = @sql_stmt + ' GROUP BY flh.link_id, fld.source_deal_header_id
ORDER BY flh.link_id, fld.source_deal_header_id'


EXEC spa_print '**', @sql_stmt

exec (@sql_stmt)

If @@ERROR <> 0
	Exec spa_ErrorHandler @@ERROR, 'Fas Link detail table', 
			'spa_fas_link)detail', 'DB Error', 
			'Failed to select Link detail record.', ''

/*******************************************2nd Paging Batch START**********************************************/
--update time spent and batch completion message in message board 
IF @is_batch = 1 
BEGIN 
	SELECT @str_batch_table = dbo.FNABatchProcess ('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL)  
	EXEC (@str_batch_table) 
	SELECT @str_batch_table = dbo.FNABatchProcess ('c', @batch_process_id, @batch_report_param, 
				   GETDATE(), 'spa_create_hedge_relationship_report', 'Hedging Relationship Report')
	EXEC (@str_batch_table) 
	RETURN 
END 
--if it is first call from paging, return total no. of rows and process id instead of actual data 
IF @enable_paging = 1 AND @page_no IS NULL 
BEGIN 
	SET @sql_paging = dbo.FNAPagingProcess ('t', @batch_process_id, @page_size, @page_no) 
	EXEC (@sql_paging) 
END
 
/*******************************************2nd Paging Batch END**********************************************/
 
GO











