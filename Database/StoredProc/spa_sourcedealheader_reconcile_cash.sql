IF OBJECT_ID(N'spa_sourcedealheader_reconcile_cash', N'P') IS NOT NULL
DROP PROCEDURE spa_sourcedealheader_reconcile_cash
 GO 

--exec spa_sourcedealheader_reconcile_cash s,NULL,NULL,'','',NULL,NULL,NULL,NULL,' ',NULL,2,'2006-01-01','2006-03-31',NULL,NULL,'','','',NULL,NULL,'','','',NULL,'',''
CREATE proc [dbo].[spa_sourcedealheader_reconcile_cash]
@flag char(1)='s',
@deal_id_from int = NULL, 
@deal_id_to int = NULL, 
@deal_date_from varchar(100) = NULL, 
@deal_date_to varchar(100) = NULL,
@source_system_book_id1 int = NULL,
@source_system_book_id2 int = NULL,
@source_system_book_id3 int = NULL,
@source_system_book_id4 int = NULL,
@physical_financial_flag char(1)=NULL,
@structured_deal_id varchar(50)=NULL,
@counterparty_id int=NULL,
@entire_term_start varchar(10)=NULL,
@entire_term_end varchar(10)=NULL,
@source_deal_type_id int=NULL,
@deal_sub_type_type_id int=NULL,

@description1 varchar(100)=NULL,
@description2 varchar(100)=NULL,
@description3 varchar(100)=NULL,
@deal_category_value_id int=NULL,
@trader_id int=NULL,
@book_id varchar(100)=NULL,
@header_buy_sell_flag varchar(1)=NULL,
@sort_by varchar(100)=NULL,
@cash_settlement_id varchar(200)= NULL,
@sub_entity_id varchar(500)=NULL,
@strategy_entity_id varchar(500)=NULL





as

Begin

declare @sqlStmt varchar(8000)  
declare @sqlStmt1 varchar(8000)
declare @url varchar(1000)
declare @url1 varchar(1000)
declare @user_login_id varchar(50)


if @deal_id_from = '' set @deal_id_from = NULL
if @deal_id_to = '' set @deal_id_to = NULL
if @deal_date_from = '' set @deal_date_from = NULL 
if @deal_date_to = '' set @deal_date_to = NULL
if @source_system_book_id1 = '' set @source_system_book_id1 = NULL
if @source_system_book_id2 = '' set @source_system_book_id2 = NULL
if @source_system_book_id3 = '' set @source_system_book_id3 = NULL
if @source_system_book_id4 = '' set @source_system_book_id4 = NULL
if @physical_financial_flag = '' set @physical_financial_flag = NULL
if @structured_deal_id = '' set @structured_deal_id = NULL
if @counterparty_id = '' set @counterparty_id = NULL
if @entire_term_start = '' set @entire_term_start = NULL
if @entire_term_end = '' set @entire_term_end = NULL
if @source_deal_type_id = '' set @source_deal_type_id = NULL
if @deal_sub_type_type_id = '' set @deal_sub_type_type_id = NULL
if @description1 = '' set @description1 = NULL
if @description2 = '' set @description2 = NULL
if @description3 = '' set @description3 = NULL
if @deal_category_value_id = '' set @deal_category_value_id = NULL
if @trader_id = '' set @trader_id = NULL
if @book_id = '' set @book_id = NULL
if @header_buy_sell_flag = '' set @header_buy_sell_flag = NULL
if @sort_by = '' set @sort_by = NULL
if @cash_settlement_id = '' set @cash_settlement_id = NULL
if @sub_entity_id = '' set @sub_entity_id = NULL
if @strategy_entity_id = '' set @strategy_entity_id = NULL



If @deal_id_to IS NULL AND @deal_id_from IS NOT NULL
		set @deal_id_to = @deal_id_from

	If @deal_id_from IS NULL AND @deal_id_to IS NOT NULL
		set @deal_id_from = @deal_id_to

set @user_login_id=dbo.fnadbuser()
 
SELECT @url = './spa_html.php?__user_name__=' + @user_login_id + 
	'&spa=exec spa_sourcedealheader_reconcile_cash b,' +ISNULL(cast(@deal_id_from as varchar),'NULL')+ ',' + 
	  ISNULL(cast(@deal_id_to as varchar),'NULL') + ',' +''''''+
	  cast(ISNULL(@deal_date_from,'')  as varchar)+'''''' +','+
     ''''''+cast(ISNULL(@deal_date_to,'') as varchar)+''''''  + ',' +
      ISNULL(cast(@source_system_book_id1 as varchar),'NULL') + ',' +
      ISNULL(cast(@source_system_book_id2 as varchar),'NULL') +','  +
      ISNULL(cast(@source_system_book_id3 as varchar),'NULL') +','  +
      ISNULL(cast(@source_system_book_id4 as varchar),'NULL') +','  + 
      ''''''+ISNULL(@physical_financial_flag,'')+'''''' +','+
      ISNULL(cast(@structured_deal_id as varchar),'NULL')



   set @url1=''''''+ISNULL(@entire_term_start,'')+'''''' +','+
      ''''''+ISNULL(@entire_term_end,'')+'''''' +','+
      ISNULL(cast(@source_deal_type_id as varchar),'NULL')+','+
      ISNULL(cast(@deal_sub_type_type_id as varchar),'NULL')+','+
      ''''''+ISNULL(@description1,'')+'''''' +','+
      ''''''+ISNULL(@description2,'')+'''''' +','+
      ''''''+ISNULL(@description3,'')+'''''' +','+
      ISNULL(cast(@deal_category_value_id as varchar),'NULL')+','+
      ISNULL(cast(@trader_id as varchar),'NULL')+ ','+
      ''''''+cast(ISNULL(@book_id ,'') as varchar)+'''''' +',' +
      ''''''+ISNULL(@header_buy_sell_flag,'')+'''''' +','+
      ''''''+ISNULL(@sort_by,'')+''''''+','+
      ISNULL(cast(@cash_settlement_id as varchar),'NULL')+','+
      ''''''+cast(ISNULL(@sub_entity_id,'') as VARCHAR(500))+''''''+','+
      ''''''+cast(ISNULL(@strategy_entity_id,'') as VARCHAR(500))+''''''

EXEC spa_print @url
EXEC spa_print @url1
--return
--exec spa_sourcedealheader_reconcile_cash r, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 2, '2006-01-01', '2006-03-31', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,NULL,NULL

if @flag='r' or @flag='b' or @flag='s'
begin
	if @flag='r' 

        set @sqlStmt1 ='SELECT 
				''<a target="_blank" href="' + @url + ',''+cast(sc.source_counterparty_id as varchar)+'','+@url1 + '">''+
			   sc.counterparty_name+''.</a>''  [Counterparty],       
			   Dbo.FNADateFormat(min(sdps.term_start)) [TermStart],
			   Dbo.FNADateFormat(max(sdps.term_end)) [TermEnd],
			   --max(dbo.FNAHyperLinkText(10131000,sdh.deal_id, cast(sdps.source_deal_header_id as varchar))) [RefID],
			   max(scrr.currency_name) [Currency],       
			   round(sum(isnull(sdps.und_pnl, 0)),2) [Settlement],
			   round(sum(isnull(sdcs.cash_received, 0)),2) [Cash],
			   round(sum(sdcs.cash_variance),2) [Variance]'
       
	  else if @flag='s'

		set @sqlStmt1 ='SELECT   
			   sdps.source_deal_header_id [Deal ID],
			   sc.counterparty_name [Counterparty],
			   max(sdh.description3) [Ref ID2 ],
			   Dbo.FNADateFormat(isnull(max(sdcs.as_of_date), dbo.FNAGetContractMonth(getdate()))) [AsofDate],
			   Dbo.FNADateFormat(sdps.term_start) [TermStart],
			   Dbo.FNADateFormat(sdps.term_end) [TermEnd],
			   max(scrr.currency_name) [Currency],       
			   round(sum(sdps.und_pnl), 2) [Settlement],
			   round(sum(sdcs.cash_received), 2) [Cash],
			   round(sum(sdcs.cash_variance), 2) [Variance],
			   max(sdcs.description) [Description],
			   max(sdps.pnl_currency_id) [source_currency_id],
			   sdcs.source_deal_settlement_id [ID],
			   max(sdh.deal_id) [deal_id1]'	
			
	 else if @flag='b'
			
			set @sqlStmt1 ='SELECT 
			   sc.counterparty_name [Counterparty],
			   Dbo.FNADateFormat(sdps.term_start) [TermStart],
			   Dbo.FNADateFormat(sdps.term_end) [TermEnd],
			   --sdps.source_deal_header_id [Deal ID],
			   (dbo.FNAHyperLinkText(10241000, sdps.source_deal_header_id, sdps.source_deal_header_id)) [Deal ID],
			   max(dbo.FNAHyperLinkText(10131000,sdh.deal_id, cast(sdps.source_deal_header_id as varchar))) [RefID],
			   max(sdh.description3) [RefID2 ],
			   Dbo.FNADateFormat(sdcs.as_of_date) [AsofDate],
			   max(scrr.currency_name) [Currency],       
			   round(sum(isnull(sdps.und_pnl, 0)), 2) [Settlement],
			   round(sum(isnull(sdcs.cash_received, 0)), 2) [Cash],
			   round(sum(isnull(sdcs.cash_variance, 0)), 2) [Variance],
			   max(sdcs.description) [Description] '     


		set @sqlStmt1 =@sqlStmt1+' FROM source_deal_pnl_settlement sdps 
				INNER JOIN
				 source_deal_header sdh on sdps.source_deal_header_id = sdh.source_deal_header_id 
				INNER JOIN
				 source_counterparty sc on sc.source_counterparty_id=sdh.counterparty_id  
				LEFT OUTER JOIN
				 source_deal_cash_settlement sdcs on sdps.source_deal_header_id = sdcs.source_deal_header_id
				 and sdps.term_start=sdcs.term_start
				LEFT OUTER JOIN
				 source_currency scrr on sdps.pnl_currency_id = scrr.source_currency_id
				LEFT OUTER JOIN (select max(fas_book_id) fas_booK_id,source_system_book_id1,source_system_book_id2,source_system_book_id3,source_system_book_id4
								  from source_system_book_map where fas_deal_type_value_id=400 group by source_system_book_id1,source_system_book_id2,source_system_book_id3,source_system_book_id4)
				 ssbm on sdh.source_system_book_id1 = ssbm.source_system_book_id1 and
				 sdh.source_system_book_id2 = ssbm.source_system_book_id2 and
				 sdh.source_system_book_id3 = ssbm.source_system_book_id3 and
				 sdh.source_system_book_id4 = ssbm.source_system_book_id4 
				INNER JOIN
					portfolio_hierarchy book on book.entity_id = ssbm.fas_book_id 
				INNER JOIN
					portfolio_hierarchy stra on stra.entity_id = book.parent_entity_id
				INNER JOIN
					portfolio_hierarchy sub on sub.entity_id = stra.parent_entity_id
				INNER JOIN
					fas_strategy fs on fs.fas_strategy_id = stra.entity_id 

				  where 1=1 '



			If (@deal_id_from IS NOT NULL) AND (@deal_id_to IS NOT NULL) 
				set @sqlStmt1 = @sqlStmt1 + ' AND sdps.source_deal_header_id BETWEEN ' + CAST(@deal_id_from As varchar)  + ' AND ' + CAST(@deal_id_to AS varchar) 

		if(@deal_date_from is not  null)
		    set @sqlStmt1 = @sqlStmt1 +' AND sdps.term_start <= ''' +@deal_date_from+ ''''

		if (@entire_term_start IS NOT NULL)
			   set @sqlStmt1 = @sqlStmt1 + ' AND sdps.term_start >= '''+@entire_term_start+ ''''

		if (@entire_term_end IS NOT NULL)
			   set @sqlStmt1 = @sqlStmt1 + ' AND sdps.term_start <= '''+@entire_term_end+ ''''

		if(@source_system_book_id1 is not null)
			   set @sqlStmt1 = @sqlStmt1 + ' AND sdh.source_system_book_id1 = ' + cast(@source_system_book_id1 as varchar)

		if(@source_system_book_id2 is not null)
			   set @sqlStmt1 = @sqlStmt1 + ' AND sdh.source_system_book_id2 = ' + cast(@source_system_book_id2 as varchar)

		if(@source_system_book_id3 is not null)
			   set @sqlStmt1 = @sqlStmt1 + ' AND sdh.source_system_book_id3 = ' + cast(@source_system_book_id3 as varchar)

		if(@source_system_book_id4 is not null)
			   set @sqlStmt1 = @sqlStmt1 + ' AND sdh.source_system_book_id4 = ' + cast(@source_system_book_id4 as varchar)

		if (@physical_financial_flag IS NOT NULL)
			  set @sqlStmt1 = @sqlStmt1 + ' AND sdh.physical_financial_flag='''+@physical_financial_flag+''''
				
		if (@counterparty_id IS NOT NULL)
			  set @sqlStmt1 = @sqlStmt1 +' AND sdh.counterparty_id='+cast(@counterparty_id as varchar)

		
		if (@source_deal_type_id IS NOT NULL)
			   set @sqlStmt1 = @sqlStmt1 +' AND sdh.source_deal_type_id='+cast(@source_deal_type_id  as varchar)

		if (@deal_sub_type_type_id IS NOT NULL)
			  set @sqlStmt1 = @sqlStmt1 +' AND sdh.deal_sub_type_type_id='+cast(@deal_sub_type_type_id  as varchar)

		if (@deal_category_value_id IS NOT NULL)
				set @sqlStmt1 = @sqlStmt1 +' AND sdh.deal_category_value_id='+cast(@deal_category_value_id  as varchar)

		if (@trader_id IS NOT NULL)
				set @sqlStmt1 = @sqlStmt1 +' AND sdh.trader_id='+cast(@trader_id  as varchar)

		if (@description1 IS NOT NULL)
				set @sqlStmt1 = @sqlStmt1 +' AND sdh.description1 like ''%'+@description1+'%'''

		if (@description2 IS NOT NULL)
				set @sqlStmt1 = @sqlStmt1 +' AND sdh.description2 like ''%'+@description2+'%'''

		if (@description3 IS NOT NULL)
				set @sqlStmt1 = @sqlStmt1 +' AND sdh.description3 like ''%'+@description3+'%'''

		if (@structured_deal_id  IS NOT NULL)
				set @sqlStmt1 = @sqlStmt1 +' AND sdh.deal_id like ''%'+@structured_deal_id +'%'''

		if (@header_buy_sell_flag IS NOT NULL)
				set @sqlStmt1 = @sqlStmt1 +' AND sdh.header_buy_sell_flag='''+ @header_buy_sell_flag + ''''

		if(@sub_entity_id is not null)
		       
			   set @sqlStmt1 = @sqlStmt1 +' AND sub.entity_id in  ('+ @sub_entity_id+')'

		if(@strategy_entity_id is not null)
		       
			   set @sqlStmt1 = @sqlStmt1 +' AND stra.entity_id  in  ('+@strategy_entity_id+')'

		if (@book_id IS NOT NULL)
				set @sqlStmt1 = @sqlStmt1 +' AND ssbm.fas_book_id in ('+@book_id+')'

		
		if @flag='r'
			set @sqlStmt1=@sqlStmt1+' group by   sc.counterparty_name,sc.source_counterparty_id  
									 order by sc.counterparty_name,TermStart,TermEnd '

		else if @flag='s'
		begin
			set @sqlStmt1=@sqlStmt1+' group by    sdps.source_deal_header_id,sc.counterparty_name,
					   sdh.description1,sdcs.as_of_date,sdps.term_start,
					   sdps.term_end,scrr.currency_name,sdcs.source_deal_settlement_id,sdcs.cash_received,sdcs.cash_variance,sdcs.description'
			if @sort_by='l'
				set @sqlStmt1 = @sqlStmt1 +'  order by sdps.source_deal_header_id desc, sdps.term_start  '
			else
				set @sqlStmt1 = @sqlStmt1 +'  order by sdps.source_deal_header_id asc, sdps.term_start'
		end

		else if @flag='b'
		begin
			set @sqlStmt1=@sqlStmt1+' 
			group by    sdps.source_deal_header_id, sc.counterparty_name, sdcs.as_of_date, sdps.term_start, sdps.term_end
			'

			set @sqlStmt1 = @sqlStmt1 +'  order by sc.counterparty_name,  sdps.term_start, sdps.source_deal_header_id  desc'
		
		end

		EXEC spa_print @sqlStmt1
		exec(@sqlStmt1)

end

Else if @flag='d'
begin
set @sqlStmt ='delete from source_deal_cash_settlement where source_deal_settlement_id in('+@cash_settlement_id+')'

exec(@sqlStmt)
If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, 'Reconcile Cash Derrivative', 
				'spa_sourcedealheader_reconcile_cash', 'DB Error', 
				'Failed to delete data.', ''
	
		Exec spa_ErrorHandler 0, 'Reconcile Cash Derrivative', 
				'spa_sourcedealheader_reconcile_cash', 'Success', 
				'Data deleted successfully.', ''

end
End
