IF OBJECT_ID(N'spa_create_maintain_deal_transfer_report', N'P') IS NOT NULL
DROP PROCEDURE spa_create_maintain_deal_transfer_report
 GO 


--exec spa_create_maintain_deal_transfer_report NULL, NULL, NULL, NULL, NULL, '2008-02-23',m,NULL,'d',NULL,'y'
-- exec spa_create_maintain_deal_transfer_report NULL, NULL, NULL, 184, NULL,'2008-08-13','a',NULL,'s',NULL,'y',NULL, NULL,NULL, 5,NULL,NULL,NULL,NULL

create PROC [dbo].[spa_create_maintain_deal_transfer_report] 
            @source_system_book_id1 int=NULL, 
			@source_system_book_id2 int=NULL, 
			@source_system_book_id3 int=NULL, 
			@source_system_book_id4 int=NULL, 
			@deal_date_from varchar(10) = NULL, 
			@deal_date_to varchar(10) = NULL,
			@type char(1) = 'n' ,-- n-> not mapped m-> mapped deals a->All
			@source_system_id int=null,
			@summary_option char(1)='s',--'s'- summary, 'd' detail
			@counterparty_id int=null,
			@use_create_date char(1)='n',	
            @deal_id varchar(50)=null, -- Source Deal Header ID
			@ref_id varchar(50)=null, -- DEAL ID 
			@exlc_group4 char(1)=null,
			@internal_desk_id int=null, ---NEW ADDED in ESSENT
			@product_id int=null,
			@internal_portfolio_id int=null,
			@commodity_id int=null,
			@reference varchar(200)=NUll, ---NEW ADDED in ESSENT
			@batch_process_id varchar(50)=NULL,
			@batch_report_param varchar(1000)=NULL
			

AS

SET NOCOUNT ON

Declare @sql_Select varchar(5000)
Declare @sql_Where varchar (5000)
Declare @sql_From varchar (5000)
Declare @sql_group_by varchar (2000)
Declare @sql_order_by varchar(2000)

DECLARE @str_batch_table varchar(max)        
SET @str_batch_table=''        
IF @batch_process_id is not null  
BEGIN      
	SELECT @str_batch_table=dbo.FNABatchProcess('s',@batch_process_id,@batch_report_param,NULL,NULL,NULL)   
	SET @str_batch_table = @str_batch_table
END

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
		
if @summary_option='s'
	SET @sql_Select = 
			'SELECT 
			sDH.source_deal_header_id AS [Deal ID], 
--		case when sSBM.book_deal_type_map_id is not null then dbo.FNAHyperLink(10131010, sDH.deal_id, sDH.source_deal_header_id,'''+isNull(@batch_process_id,'-1') +''') 
--					else sDH.deal_id end as SourceDealID,
			dbo.FNAHyperLink(10131010, sDH.deal_id, sDH.source_deal_header_id,'''+isNull(@batch_process_id,'-1') +''') as [Source Deal ID],
			sb1.source_book_name AS ['+ @group1 +'], 
            sb2.source_book_name AS ['+ @group2 +'], sb3.source_book_name AS ['+ @group3 +'], 
            sb4.source_book_name AS ['+ @group4 +'], 
			ssd.source_system_name [Source System],
			cast(round(isnull(sum(fld.percentage_included), 0),2) as varchar) as [Perc Linked], 
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
			[dbo].[FNARemoveTrailingZeroes](round(max(sDD.fixed_price), 2)) AS Price, 
			[dbo].[FNARemoveTrailingZeroes](round(max(sDD.option_strike_price), 2)) AS Strike, 
			max(sC.currency_name) AS Currency, 
			max(case when  (sDH.header_buy_sell_flag= ''b'')  then ''Buy (Rec)'' else ''Sell (Pay)'' end) as  [Buy Sell],
	        [dbo].[FNARemoveTrailingZeroes](round(sum(sDD.deal_volume), 2)) AS [Deal Volume], 
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
			cast(round(isnull(sum(fld.percentage_included), 0),2) as varchar) as [Perc Linked], 
			sDH.source_deal_header_id AS [Deal ID], 
			dbo.FNAHyperLink(10131010, sDH.deal_id, sDH.source_deal_header_id,'''+isNull(@batch_process_id,'-1') +''') as [Source Deal ID],

--			case when sSBM.book_deal_type_map_id is not null then dbo.FNAHyperLink(10131010, sDH.deal_id, sDH.source_deal_header_id,'''+isNull(@batch_process_id,'-1') +''') 
--				else sDH.deal_id end as SourceDealID,
--			sDH.deal_id AS SourceDealID, 
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
			[dbo].[FNARemoveTrailingZeroes](round(sDD.fixed_price, 2)) AS Price, 
			[dbo].[FNARemoveTrailingZeroes](round(sDD.option_strike_price, 2)) AS Strike, 
			sC.currency_name AS Currency, 
			case when  (sDD.buy_sell_flag= ''b'')  then ''Buy (Rec)'' else ''Sell (Pay)'' end [BuySell],
	                [dbo].[FNARemoveTrailingZeroes](round(sDD.deal_volume, 2)) AS [Deal Volume], source_uom.uom_name AS [Deal UOM],
			CASE WHEN(sDD.deal_volume_frequency = ''m'') THEN ''Monthly''
					WHEN(sDD.deal_volume_frequency = ''d'') THEN ''Daily'' 
					ELSE sDD.deal_volume_frequency END AS [Volume Frequency],
		sid.internal_desk_id [Internal Desk],sp.product_id [Product ID],sip.internal_portfolio_id [Portfolio ID],sc1.commodity_id [Commodity ID],sdh.reference [Reference]
		 '


	set @sql_From= '	FROM  source_deal_detail sDD INNER JOIN
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
						  LEFT OUTER JOIN source_internal_desk sid on sid.source_internal_desk_id=sdh.internal_desk_id 	
						  LEFT OUTER JOIN source_product sp on sp.source_product_id=sdh.product_id 
						  LEFT OUTER JOIN source_internal_portfolio sip on sip.source_internal_portfolio_id=sdh.internal_portfolio_id 
						  LEFT OUTER JOIN source_commodity sc1 on sc1.source_commodity_id=sdh.commodity_id
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
					+ case when @counterparty_id is not null then ' And sdh.counterparty_id='+cast(@counterparty_id as varchar)  else '' end	
	
	if @internal_desk_id is not null
		SET @sql_Where=@sql_Where +' and sdh.internal_desk_id='+cast(@internal_desk_id as varchar)
	if @product_id  is not null
		SET @sql_Where=@sql_Where +' and sdh.product_id ='+cast(@product_id  as varchar)
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
	EXEC (@sql_Select +' ' + @str_batch_table +' ' + @sql_From + @sql_Where + @sql_group_by + @sql_order_by )
	exec spa_print @sql_Select, ' ', @str_batch_table, ' ', @sql_From, @sql_Where, @sql_group_by, @sql_order_by 
--return

--*****************FOR BATCH PROCESSING**********************************            
IF  @batch_process_id is not null        
BEGIN        
 SELECT @str_batch_table=dbo.FNABatchProcess('u',@batch_process_id,@batch_report_param,GETDATE(),NULL,NULL)         
 EXEC(@str_batch_table)        
 declare @report_name varchar(100)        

 set @report_name='Run Mapped Deal Report'        
        
 SELECT @str_batch_table=dbo.FNABatchProcess('c',@batch_process_id,@batch_report_param,GETDATE(),'spa_Create_MTM_Period_Report',@report_name)         
 EXEC(@str_batch_table)        
        
END        

--********************************************************************   




