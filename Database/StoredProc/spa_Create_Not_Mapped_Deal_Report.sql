IF OBJECT_ID(N'spa_Create_Not_Mapped_Deal_Report', N'P') IS NOT NULL
DROP PROCEDURE spa_Create_Not_Mapped_Deal_Report
 GO 


--exec spa_Create_Not_Mapped_Deal_Report NULL, NULL, NULL, NULL, NULL, '2008-02-23',m,NULL,'d',NULL,'y'
-- exec spa_create_Not_Mapped_Deal_Report NULL, NULL, NULL, 184, NULL,'2008-08-13','a',NULL,'s',NULL,'y',NULL, NULL,NULL, 5,NULL,NULL,NULL,NULL

create PROC [dbo].[spa_Create_Not_Mapped_Deal_Report] 
            @source_system_book_id1 int=NULL, 
			@source_system_book_id2 int=NULL, 
			@source_system_book_id3 int=NULL, 
			@source_system_book_id4 int=NULL, 
			@deal_date_from varchar(10) = NULL, 
			@deal_date_to varchar(10) = NULL,
			@type char(1) = 'n' ,-- n-> not mapped m-> mapped deals a->All
			@source_system_id int=null,
			@summary_option char(1)='s',--'s'- summary, 'd' detail
			@counterparty_id VARCHAR(MAX)=null,
			@use_create_date char(1)='n',	
            @deal_id varchar(50)=null, -- Source Deal Header ID
			@ref_id varchar(50)=null, -- DEAL ID 
			@exlc_group4 char(1)=null,
			@internal_desk_id int=null, ---NEW ADDED in ESSENT
			@product_id int=null,
			@internal_portfolio_id int=null,
			@commodity_id int=null,
			@reference varchar(200)=NUll, ---NEW ADDED in ESSENT
			@round_value CHAR(1) = 0,
			@batch_process_id VARCHAR(250) = NULL,
			@batch_report_param VARCHAR(500) = NULL, 
			@enable_paging INT = 0,  --'1' = enable, '0' = disable
			@page_size INT = NULL,
			@page_no INT = NULL
			

AS

SET NOCOUNT ON

Declare @sql_Select varchar(5000)
Declare @sql_Where varchar (5000)
Declare @sql_From varchar (5000)
Declare @sql_group_by varchar (2000)
Declare @sql_order_by varchar(2000)

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

select source_system_book_id1, source_system_book_id2, source_system_book_id3, 
							source_system_book_id4 INTO #ssbm from source_system_book_map
						
--########### Group Label
declare @group1 varchar(100),@group2 varchar(100),@group3 varchar(100),@group4 varchar(100)
 if exists(select group1,group2,group3,group4 from source_book_mapping_clm)
begin	
	select @group1=group1,@group2=group2,@group3=group3,@group4=group4 from source_book_mapping_clm
end
else
begin
	set @group1='Group1'
	set @group2='Group2'
	set @group3='Group3'
	set @group4='Group4'
end
--######## End
declare @operator4 varchar(10)
if @exlc_group4='y'		
	set @operator4 = ' not in '
else
	set @operator4 = ' in '
		
IF OBJECT_ID('tempdb..#product') IS NOT NULL
	DROP TABLE #product

CREATE TABLE #product (source_deal_header_id INT, udf_value INT)

INSERT into #product(source_deal_header_id, udf_value)
SELECT uddf.source_deal_header_id, CASE WHEN uddf.udf_value = '' THEN NULL ELSE uddf.udf_value END
	FROM  user_defined_deal_fields uddf 
	INNER JOIN user_defined_deal_fields_template uddft ON uddft.udf_template_id = uddf.udf_template_id 
WHERE uddft.field_name = -5720  -- product_id

IF OBJECT_ID('tempdb..#internal_desk') IS NOT NULL
	DROP TABLE #internal_desk

CREATE TABLE #internal_desk (source_deal_header_id INT, udf_value INT)

INSERT into #internal_desk(source_deal_header_id, udf_value)
SELECT uddf.source_deal_header_id, CASE WHEN uddf.udf_value = '' THEN NULL ELSE uddf.udf_value END  
	FROM  user_defined_deal_fields uddf 
	INNER JOIN user_defined_deal_fields_template uddft ON uddft.udf_template_id = uddf.udf_template_id 
WHERE uddft.field_name = -5716  -- internal desk
		
if @summary_option='s'
	SET @sql_Select = 
			'SELECT 
			sDH.source_deal_header_id AS [Deal ID], 
--		case when sSBM.book_deal_type_map_id is not null then dbo.FNAHyperLink(10131010, sDH.deal_id, sDH.source_deal_header_id,'''+isNull(@batch_process_id,'-1') +''') 
--					else sDH.deal_id end as SourceDealID,
			dbo.FNATRMWinHyperlink(''a'', 10131010, sDH.deal_id, ABS(sDH.source_deal_header_id),null,null,null,null,null,null,null,null,null,null,null,0) AS [Source Deal ID],
			sb1.source_book_name AS ['+ @group1 +'], 
            sb2.source_book_name AS ['+ @group2 +'], sb3.source_book_name AS ['+ @group3 +'], 
            sb4.source_book_name AS ['+ @group4 +'], 
			ssd.source_system_name [Source System],
			CAST(CAST(ISNULL(SUM(fld.percentage_included), 0) AS NUMERIC(38,' + @round_value + ')) AS VARCHAR(100)) AS [Perc Linked],
			dbo.FNADateFormat(sDH.deal_date) as [Deal Date], 
			dbo.FNADateFormat(sDH.deal_date) AS [Effective Date], 
			dT.source_deal_type_name AS [Source Deal Type], 
           	dSubT.source_deal_type_name AS [Sub Deal Type], 
			min(dbo.FNADateFormat(sDH.entire_term_start))  AS [Term Start], 
			max(dbo.FNADateFormat(sDH.entire_term_end)) AS [Term End], 
-- 			min(dbo.FNADateFormat(sDD.term_start))  AS [Term Start], 
-- 			max(dbo.FNADateFormat(sDD.term_end)) AS [Term End], 
			max(sDD.Leg) AS Leg, 
	               max( CASE WHEN(sDD.fixed_float_leg = ''f'') THEN ''Fixed'' 
					WHEN(sDD.fixed_float_leg = ''t'') THEN ''Float'' 
					ELSE sDD.fixed_float_leg END) AS [Fixed Float], 
			max(sPCD.curve_name) AS [Curve Name],
			CAST(CAST(max(sDD.fixed_price) AS NUMERIC(38,' + @round_value + ')) AS VARCHAR(100)) AS Price,
			CAST(CAST(max(sDD.option_strike_price) AS NUMERIC(38,' + @round_value + ')) AS VARCHAR(100)) AS Strike,
			max(sC.currency_name) AS Currency, 
			max(case when  (sDH.header_buy_sell_flag= ''b'')  then ''Buy (Rec)'' else ''Sell (Pay)'' end) as  [Buy Sell],
	     	CAST(CAST(sum(sDD.deal_volume) AS NUMERIC(38,' + @round_value + ')) AS VARCHAR(100)) AS [Deal Volume],
			max(source_uom.uom_name) AS [Deal UOM],
			max(CASE WHEN(sDD.deal_volume_frequency = ''m'') THEN ''Monthly''
					WHEN(sDD.deal_volume_frequency = ''d'') THEN ''Daily'' 
					ELSE sDD.deal_volume_frequency END) AS [Volume Frequency],
			sid.internal_desk_id [Internal Desk],sp.product_id [Product ID],sip.internal_portfolio_id [Portfolio ID],sc1.commodity_id [Commodity ID],sdh.Reference
			 '
else
	SET @sql_Select = 
			'SELECT 
			ssd.source_system_name [Source System],
			sb1.source_book_name AS ['+ @group1 +'], 
            sb2.source_book_name AS ['+ @group2 +'], sb3.source_book_name AS ['+ @group3 +'], 
            sb4.source_book_name AS ['+ @group4 +'], 
			CAST(CAST(ISNULL(SUM(fld.percentage_included), 0) AS NUMERIC(38,' + @round_value + ')) AS VARCHAR(100)) AS [Perc Linked],
			sDH.source_deal_header_id AS [Deal ID], 
			--dbo.FNAHyperLink(10131010, sDH.deal_id, sDH.source_deal_header_id,'''+isNull(@batch_process_id,'-1') +''') as [Source Deal ID],
			dbo.FNATRMWinHyperlink(''a'', 10131010, sDH.deal_id, ABS(sDH.source_deal_header_id),null,null,null,null,null,null,null,null,null,null,null,0) AS [Source Deal ID],

			--case when sSBM.book_deal_type_map_id is not null then dbo.FNAHyperLink(10131010, sDH.deal_id, sDH.source_deal_header_id,'''+isNull(@batch_process_id,'-1') +''') 
			--else sDH.deal_id end as SourceDealID,
			--sDH.deal_id AS [Source Deal ID], 
			dbo.FNADateFormat(sDH.deal_date) as [Deal Date], 
			dbo.FNADateFormat(sDH.deal_date) AS [Effective Date], 
			dT.source_deal_type_name AS [Source Deal Type], 
           	dSubT.source_deal_type_name AS [Sub Deal Type], 
			dbo.FNADateFormat(sDD.term_start)  AS [Term Start], 
			dbo.FNADateFormat(sDD.term_end) AS [Term End], 
			sDD.Leg AS Leg, 
	                CASE WHEN(sDD.fixed_float_leg = ''f'') THEN ''Fixed'' 
					WHEN(sDD.fixed_float_leg = ''t'') THEN ''Float'' 
					ELSE sDD.fixed_float_leg END AS [Fixed Float], 
			sPCD.curve_name AS [Curve Name],
			CAST(CAST(sDD.fixed_price AS NUMERIC(38,' + @round_value + ')) AS VARCHAR(100)) AS Price, 
			CAST(CAST(sDD.option_strike_price AS NUMERIC(38,' + @round_value + ')) AS VARCHAR(100)) AS Strike,
			sC.currency_name AS Currency, 
			case when  (sDD.buy_sell_flag= ''b'')  then ''Buy (Rec)'' else ''Sell (Pay)'' end [Buy Sell],
	                CAST(CAST(sDD.deal_volume AS NUMERIC(38,' + @round_value + ')) AS VARCHAR(100)) AS [Deal Volume],
					 source_uom.uom_name AS [Deal UOM],
			CASE WHEN(sDD.deal_volume_frequency = ''m'') THEN ''Monthly''
					WHEN(sDD.deal_volume_frequency = ''d'') THEN ''Daily'' 
					ELSE sDD.deal_volume_frequency END AS [Volume Frequency],
		sid.internal_desk_id [Internal Desk ID],sp.product_id [Product ID],sip.internal_portfolio_id [Portfolio ID],sc1.commodity_id [Commodity ID],sdh.Reference
			
		 '


	set @sql_From= ''+ @str_batch_table +'	FROM  source_deal_detail sDD INNER JOIN
	                      source_deal_header sDH ON sDD.source_deal_header_id = sDH.source_deal_header_id left OUTER JOIN
						  #ssbm sSBM ON sDH.source_system_book_id1 = sSBM.source_system_book_id1 AND 
	                      sDH.source_system_book_id2 = sSBM.source_system_book_id2 AND sDH.source_system_book_id3 = sSBM.source_system_book_id3 AND 
	                      sDH.source_system_book_id4 = sSBM.source_system_book_id4 LEFT OUTER JOIN
	                      source_currency sC ON sDD.fixed_price_currency_id = sC.source_currency_id LEFT OUTER JOIN
	                      source_price_curve_def sPCD ON sDD.curve_id = sPCD.source_curve_def_id  LEFT OUTER JOIN
	                      source_uom ON sDD.deal_volume_uom_id = source_uom.source_uom_id LEFT OUTER JOIN
	                      source_deal_type dT ON sDH.source_deal_type_id = dT.source_deal_type_id LEFT OUTER JOIN
	                      source_book sb4 ON sDH.source_system_book_id4 = sb4.source_book_id LEFT OUTER JOIN
	                      source_book sb3 ON sDH.source_system_book_id3 = sb3.source_book_id LEFT OUTER JOIN
	                      source_book sb2 ON sDH.source_system_book_id2 = sb2.source_book_id LEFT OUTER JOIN
	                      source_book sb1 ON sDH.source_system_book_id1 = sb1.source_book_id LEFT OUTER JOIN
	                      source_deal_type dSubT ON sDH.deal_sub_type_type_id = dSubT.source_deal_type_id LEFT OUTER JOIN
					       fas_link_detail fld ON fld.source_deal_header_id = sDH.source_deal_header_id 
						  LEFT OUTER JOIN source_system_description ssd on ssd.source_system_id=sdh.source_system_id
						  LEFT OUTER JOIN source_internal_portfolio sip on sip.source_internal_portfolio_id=sdh.internal_portfolio_id 
						  LEFT OUTER JOIN source_commodity sc1 on sc1.source_commodity_id=sdh.commodity_id
						  LEFT JOIN #product pd ON pd.source_deal_header_id = sdh.source_deal_header_id
						  LEFT OUTER JOIN source_product sp ON sp.source_product_id = pd.udf_value
						  LEFT JOIN #internal_desk id ON id.source_deal_header_id = sdh.source_deal_header_id
						  LEFT JOIN source_internal_desk sid ON sid.source_internal_desk_id = id.udf_value 						
						'

	--SET @sql_Where = ' WHERE sSBM.book_deal_type_map_id IN ( ' + @book_deal_type_map_id + ' )'
	SET @sql_Where =' Where 1=1 '
					+ case when @deal_id is not null then ' AND sdh.source_deal_header_id='+cast(@deal_id as varchar) else '' end
					+ case when @ref_id is not null then ' AND sdh.deal_id='''+cast(@ref_id as varchar) +'''' else '' end
                    + case when @source_system_book_id1 is not null then ' AND sdh.source_system_book_id1='+cast(@source_system_book_id1 as varchar) else '' end
					
					+ case when @source_system_book_id2 is not null then ' AND sdh.source_system_book_id2='+cast(@source_system_book_id2 as varchar) else '' end
					+ case when @source_system_book_id3 is not null then ' AND sdh.source_system_book_id3='+cast(@source_system_book_id3 as varchar) else '' end
					+ case when @source_system_book_id4 is not null then ' AND sdh.source_system_book_id4 '+ @operator4 +' ('+cast(@source_system_book_id4 as varchar) +')' else '' end
					+ case when (@deal_date_from IS NOT NULL) AND (@deal_date_to IS NOT NULL) then case when @use_create_date='y' then ' AND dbo.FNAConvertTZAwareDateFormat(sDH.create_ts,1) ' else ' AND sDH.deal_date ' end + 'BETWEEN '''+ @deal_date_from + ''' and ''' + @deal_date_to + ' 23:59:59''' 
						   when (@deal_date_from IS NULL) AND (@deal_date_to IS NOT NULL)	then case when @use_create_date='y' then ' AND dbo.FNAConvertTZAwareDateFormat(sDH.create_ts,1) ' else ' AND sDH.deal_date ' end + '<='''+ @deal_date_to +' 23:59:59''' else '' end
					/*+ case when (@deal_date_from IS NOT NULL) AND (@deal_date_to IS NOT NULL) then case when @use_create_date='y' then ' AND sDH.create_ts 'else ' AND sDH.deal_date ' end + 'BETWEEN '''+ @deal_date_from + ''' and ''' + @deal_date_to + ' 23:59:59''' 
						   when (@deal_date_from IS NULL) AND (@deal_date_to IS NOT NULL)	then case when @use_create_date='y' then ' AND sDH.create_ts ' else ' AND sDH.deal_date ' end + '<='''+ @deal_date_to +' 23:59:59''' else '' end
					*/
					+ case when @source_system_id is not null then ' AND sdh.source_system_id='+cast(@source_system_id as varchar) else '' end
					+ case when @type='m' then ' AND sSBM.source_system_book_id1 is not null' when @type='n' then  ' AND sSBM.source_system_book_id1 is null' else '' end
					+ case when @counterparty_id is not null then ' And sdh.counterparty_id IN ('+cast(@counterparty_id as varchar) + ')' else '' end	
	
	if @internal_desk_id is not null
		SET @sql_Where=@sql_Where +' AND id.udf_value = ''' + CAST(@internal_desk_id AS VARCHAR(20)) + ''''
	if @product_id  is not null
		SET @sql_Where=@sql_Where +' AND pd.udf_value = ''' + CAST(@product_id AS VARCHAR(20)) + ''''
	if @internal_portfolio_id  is not null
		SET @sql_Where=@sql_Where +' and sdh.internal_portfolio_id ='+cast(@internal_portfolio_id  as varchar)
	if @commodity_id  is not null
		SET @sql_Where=@sql_Where +' and sdh.commodity_id ='+cast(@commodity_id  as varchar)
	if @reference  is not null
		SET @sql_Where=@sql_Where +' and sdh.reference like '''+ @reference +'%'''



if @summary_option='s'
BEGIN
	SET @sql_group_by = ' group by 	sDH.source_deal_header_id, 
			sDH.deal_id, sDH.deal_date, 
			dT.source_deal_type_name, 	
			dSubT.source_deal_type_name, 
			sb1.source_book_name, 
	                sb2.source_book_name, 
			sb3.source_book_name, 
	                sb4.source_book_name, 
			ssd.source_system_name, --, sSBM.book_deal_type_map_id,
			sid.internal_desk_id,sp.product_id,sip.internal_portfolio_id,sc1.commodity_id,sdh.reference
	'

	SET @sql_order_by = ' ORDER by 	sb1.source_book_name, sb2.source_book_name, 
									sb3.source_book_name, sb4.source_book_name, 
									sDH.source_deal_header_id, sDH.deal_date 
								'

END
else
BEGIN
	SET @sql_group_by = ' group by 	sDH.source_deal_header_id, 
			sDH.deal_id, sDH.deal_date,
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
			sDD.deal_volume_frequency,ssd.source_system_name,
			sid.internal_desk_id,sp.product_id,sip.internal_portfolio_id,sc1.commodity_id,sdh.reference
		'


	SET @sql_order_by = ' ORDER by 	sb1.source_book_name, sb2.source_book_name, 
									sb3.source_book_name, sb4.source_book_name, 
									sDH.source_deal_header_id, sDH.deal_date 
						'

END	
	
--	IF (@deal_date_from IS NOT NULL) AND (@deal_date_to IS NOT NULL) 
--		SET @sql_Where = @sql_Where + ' AND sDH.deal_date BETWEEN '''+ @deal_date_from + ''' and ''' + @deal_date_to + ''''
	EXEC (@sql_Select  + @sql_From + @sql_Where + @sql_group_by + @sql_order_by )
   -- exec spa_print @sql_Select + @sql_From + @sql_Where + @sql_group_by + @sql_order_by 
--return

/*******************************************2nd Paging Batch START**********************************************/
 
--update time spent and batch completion message in message board
IF @is_batch = 1
BEGIN
   SELECT @sql_paging = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL) 
   EXEC(@sql_paging)
 
   --TODO: modify sp and report name
   SELECT @sql_paging = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, GETDATE(), 'spa_Create_Not_Mapped_Deal_Report', 'Not Mapped Deal Report')
   EXEC(@sql_paging)  
 
   RETURN
END
 
--if it is first call from paging, return total no. of rows and process id instead of actual data
IF @enable_paging = 1 AND @page_no IS NULL
BEGIN
  -- SELECT @batch_process_id, @page_size, @page_no
   SET @sql_paging = dbo.FNAPagingProcess('t', @batch_process_id, @page_size, @page_no)
   EXEC(@sql_paging)
END
 
/*******************************************2nd Paging Batch END**********************************************/
 
GO






