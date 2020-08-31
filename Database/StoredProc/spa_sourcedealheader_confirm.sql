/****** Object:  StoredProcedure [dbo].[spa_sourcedealheader_confirm]    Script Date: 05/18/2012 15:43:03 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_sourcedealheader_confirm]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_sourcedealheader_confirm]
GO

/****** Object:  StoredProcedure [dbo].[spa_sourcedealheader_confirm]    Script Date: 05/18/2012 15:43:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- exec spa_sourcedealheader_confirm 'e', null, NULL, NULL,  '2001-12-01', '2005-12-31', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL , 120,NULL, NULL, null, NULL ,NULL, NULL ,NULL ,NULL ,NULL ,NULL ,NULL,NULL ,NULL ,NULL ,NULL ,NULL ,NULL, 'c' 
--exec spa_sourcedealheader_confirm 's'

-- exec spa_sourcedealheader_confirm 's', '281', NULL, NULL, '2001-07-28', '2006-08-28', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,NULL,NULL,178, NULL,NULL, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL, NULL

/**************************************************************/
/*	Modified By:Pawan KC									*/
/*	Date: March 05, 2009									*/
/*	Modification:Change the	data type of deal_id_from and	*/
/*				 deal_id_to from int to varchar				*/
/*	Purpose		:To large value of Deal ID  				*/
/*************************************************************/


CREATE proc [dbo].[spa_sourcedealheader_confirm]        
@flag char(1),--'s' default, 'e'- exceptions        
@subbook_id varchar(200)=NULL,         
@deal_id_from varchar(100) = NULL,         
@deal_id_to varchar(100) = NULL,         
@deal_date_from varchar(10) = NULL,         
@deal_date_to varchar(10) = NULL,        
@source_deal_header_id VARCHAR(MAX)=NULL,        
@source_system_id int=NULL,        
@deal_id varchar(50)=NULL,        
@deal_date varchar(50)=NULL,        
@ext_deal_id varchar(50)=NULL,        
@physical_financial_flag char(1)=NULL,        
@structured_deal_id varchar(50)=NULL,        
@counterparty_id VARCHAR(MAX)=NULL,        
@entire_term_start varchar(10)=NULL,        
@entire_term_end varchar(10)=NULL,        
@source_deal_type_id int=NULL,        
@deal_sub_type_type_id int=NULL,        
@option_flag char(1)=NULL,        
@option_type char(1)=NULL,        
@option_excercise_type char(1)=NULL,        
@source_system_book_id1 int=NULL,        
@source_system_book_id2 int=NULL,        
@source_system_book_id3 int=NULL,        
@source_system_book_id4 int=NULL,        
@description1 varchar(100)=NULL,        
@description2 varchar(100)=NULL,        
@description3 varchar(100)=NULL,        
@deal_category_value_id int=NULL,        
@trader_id int=NULL,        
@internal_deal_type_value_id int=NULL,        
@internal_deal_subtype_value_id int= NULL,        
@book_id_int int=NULL,        
@template_id int = NULL,        
@process_id varchar(100)=NULL,        
@header_buy_sell_flag varchar(1)=NULL,        
@broker_id int=NULL,        
--Added the following for REC deals        
@generator_id int = NULL ,        
@gis_cert_number varchar (250) = NULL ,        
@gis_value_id int = NULL ,        
@gis_cert_date datetime = NULL ,        
@gen_cert_number varchar (250) = NULL ,        
@gen_cert_date datetime = NULL ,        
@status_value_id int = NULL,        
@status_date datetime = NULL ,        
@assignment_type_value_id int = NULL ,        
@compliance_year int = NULL ,        
@state_value_id int = NULL ,        
@assigned_date datetime = NULL ,        
@assigned_by varchar (50) = NULL,        
@confirm_type varchar(50) = NULL,        
@deal_locked char(1)=null,        
@subsidiary_id VARCHAR(5000)=NULL,        
@strategy_id VARCHAR(5000)=NULL,        
@book_id VARCHAR(5000)=NULL,        
@locked_unlocked_deals VARCHAR(30)=NULL,        
@deal_status VARCHAR(500) = NULL,
@history_status CHAR(1) = NULL,
--@subsidiary_id INT = NULL,
@batch_process_id VARCHAR(250) = NULL,
@batch_report_param VARCHAR(500) = NULL, 
@enable_paging INT = 0,		--'1' = enable, '0' = disable
@page_size INT = NULL,
@page_no INT = NULL        
        
AS         
SET NOCOUNT ON;

/*******************************************1st Paging Batch START**********************************************/
DECLARE @str_batch_table VARCHAR (8000)
DECLARE @user_login_id VARCHAR (50)
DECLARE @sql_paging VARCHAR (8000)
DECLARE @is_batch BIT
 
SET @str_batch_table = ''
SET @user_login_id = dbo.FNADBUser()
SET @is_batch = CASE WHEN @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL THEN 1 ELSE 0 END
 
IF @is_batch = 1 
BEGIN 
	SET @str_batch_table = ' INTO ' + dbo.FNAProcessTableName('batch_report', @user_login_id, @batch_process_id) 
END
 
IF @enable_paging = 1 --paging processing 
BEGIN 
	IF @batch_process_id IS NULL 
	BEGIN 
		SET @batch_process_id = dbo.FNAGetNewID() 
		SET @str_batch_table = dbo.FNAPagingProcess ('p', @batch_process_id, @page_size, @page_no) 
	END 
	--retrieve data from paging table instead of main table
 
	IF @page_no IS NOT NULL 
	BEGIN 
		SET @sql_paging = dbo.FNAPagingProcess ('s', @batch_process_id, @page_size, @page_no) 
		EXEC (@sql_paging)  
		RETURN
	END
END
 
/*******************************************1st Paging Batch END**********************************************/

Declare @sql_Select VARCHAR(max)        
Declare @copy_source_deal_header_id int        
Declare @starategy_id int        
Declare @sub_id int        
Declare @temp_count int        
Declare @temp_count1 int        
Declare @tempheadertable varchar(100)        
Declare @tempdetailtable varchar(100)        
--Declare @user_login_id varchar(100)        
DECLARE @baseload_block_define_id VARCHAR(100)
        
        
--IF @book_id IS NULL        
-- SET @book_id = @book_id        
        
CREATE TABLE #books ( fas_book_id int,book_deal_type_map_id INT,source_system_book_id1 int,source_system_book_id2 INT,source_system_book_id3 INT,source_system_book_id4  int,fas_deal_type_value_id int)          
        
SET @sql_Select=                
 'INSERT INTO  #books        
        
 SELECT distinct ssbm.fas_book_id,ssbm.book_deal_type_map_id fas_book_id,source_system_book_id1,        
  source_system_book_id2,source_system_book_id3,source_system_book_id4,ssbm.fas_deal_type_value_id  FROM portfolio_hierarchy book (nolock) INNER JOIN        
        
   Portfolio_hierarchy stra (nolock) ON book.parent_entity_id = stra.entity_id LEFT OUTER JOIN                    
        
   source_system_book_map ssbm ON ssbm.fas_book_id = book.entity_id                 
        
 WHERE (fas_deal_type_value_id IS NULL OR fas_deal_type_value_id BETWEEN 400 AND 401) '           
        
                      
        
 IF @subsidiary_id IS NOT NULL                
        
   SET @sql_Select = @sql_Select + ' AND stra.parent_entity_id IN  ( ' + @subsidiary_id + ') '                 
        
 IF @strategy_id IS NOT NULL          
        
   SET @sql_Select = @sql_Select + ' AND (stra.entity_id IN(' + @strategy_id + ' ))'                
        
 IF @book_id IS NOT NULL                
        
   SET @sql_Select = @sql_Select + ' AND (book.entity_id IN(' + @book_id + ')) '                
        
                
        
 EXEC(@sql_Select)         
        

SELECT @baseload_block_define_id = CAST(value_id AS VARCHAR(10)) FROM static_data_value WHERE [TYPE_ID] = 10018 AND code LIKE 'Base Load' -- External Static Data

        
if @flag='s'        
Begin        
         
         
 set @starategy_id=(Select parent_entity_id from portfolio_hierarchy where entity_id=@book_id_int)        
 set @sub_id=(select parent_entity_id as [Subsidiary Id] from portfolio_hierarchy where entity_id=@starategy_id)         
        
 --print @sub_id        
 --print @subbook_id        
        --print @sub_id        
         
 SET @sql_Select =         
   'SELECT DISTINCT dbo.FNAHyperLinkText(10131010, dh.source_deal_header_id, dh.source_deal_header_id) AS [Deal ID],       
           --' + CASE WHEN @confirm_type IS NOT NULL THEN 'sdv2.code' ELSE 'sdv2.value_id' END + ' [Confirm Status],        
           CASE WHEN MAX(deal_status.Code) IS NULL THEN ''New'' ELSE MAX(deal_status.Code) END [Deal Status],        
           MAX(sdv2.code) [Confirm Status],        
           MAX(dbo.FNADateFormat(dh.deal_date)) AS [Deal Date],        
           MAX(source_deal_type.source_deal_type_name) As [Deal Type],        
           MAX(dh.deal_id) AS [Reference ID],        
           MAX(source_counterparty.counterparty_name) [Counterparty],        
           MAX(dh.header_buy_sell_flag) [Buy/Sell Flag],        
           MAX(dbo.FNADateFormat(dh.entire_term_start)) as [Term Start],        
           MAX(dbo.FNADateFormat(dh.entire_term_end)) As [Term End],        
           dbo.FNARemoveTrailingZeroes(MAX(sdd.deal_volume)) [Volume],        
           CASE WHEN MAX(sdd.deal_volume_frequency) = ''h'' THEN  (MAX(sdd.deal_volume*ISNULL(sdd.multiplier,1)*ISNULL(sdd.volume_multiplier2,1))) * MAX(hbt.volume_mult)
			    WHEN MAX(sdd.deal_volume_frequency) IN(''t'', ''m'') THEN SUM((sdd.total_volume) * (ISNULL(conv.conversion_factor, 1))) / MAX(DATEDIFF(d, dh.entire_term_start, dh.entire_term_end)  + 1 )
			    WHEN MAX(sdd.deal_volume_frequency) = ''d'' THEN MAX(sdd.deal_volume*ISNULL(sdd.multiplier,1)*ISNULL(sdd.volume_multiplier2,1)) END [Daily Volume],
           dbo.FNARemoveTrailingZeroes(ROUND(CAST(SUM(sdd.total_volume* CAST(ISNULL(conv.conversion_factor, 1) AS NUMERIC(38,20) ) ) AS NUMERIC(38,20)), 2)) [Total Contract Volume],        
           MAX(uom.uom_name) as [Volume UOM],        
           max(block_definition.code) [Block Definition],        
           dbo.FNAAddThousandSeparator(CAST(MAX(sdd.fixed_price) AS numeric(38,20))) [Price],        
           MAX(pu.uom_name) [Price UOM],        
           MAX(sml.Location_Name) [Delivery Location],        
           MAX(source_traders.trader_name) AS [Trader Name],        
           MAX(sdv.code) AS [Deal Category],        
           MAX(cg.contract_name) [Contract],        
           sdht.deal_rules AS [Deal Rules],        
     sdht.confirm_rule as [Confirm Rules],        
     dh.source_deal_header_id as [Source Deal Header ID],        
     MAX(dh.counterparty_id) [Counterparty ID],        
     CASE         
          WHEN MAX(dh.deal_locked) = ''y'' THEN ''Yes''        
          ELSE ''No''        
     END AS [Physical Deal Locked],
     max(dh.deal_status) as [Deal Status ID]   ' + @str_batch_table + '    
    FROM source_deal_header dh         
   INNER JOIN source_deal_detail sdd on sdd.source_deal_header_id = dh.source_deal_header_id         
   INNER JOIN #books ssbm ON dh.source_system_book_id1 = ssbm.source_system_book_id1         
     AND dh.source_system_book_id2 = ssbm.source_system_book_id2         
     AND dh.source_system_book_id3 = ssbm.source_system_book_id3         
     AND dh.source_system_book_id4 = ssbm.source_system_book_id4         
   INNER JOIN source_counterparty ON dh.counterparty_id = source_counterparty.source_counterparty_id         
   INNER JOIN source_traders ON dh.trader_id = source_traders.source_trader_id         
   INNER JOIN source_deal_type ON dh.source_deal_type_id = source_deal_type.source_deal_type_id         
   INNER JOIN source_book ON dh.source_system_book_id1 = source_book.source_book_id         
   INNER JOIN source_book source_book_1 ON dh.source_system_book_id2 = source_book_1.source_book_id       
   INNER JOIN source_book source_book_2 ON dh.source_system_book_id3 = source_book_2.source_book_id         
   INNER JOIN source_book source_book_3 ON dh.source_system_book_id4 = source_book_3.source_book_id         
   INNER JOIN  portfolio_hierarchy ON portfolio_hierarchy.entity_id = ssbm.fas_book_id        
   INNER JOIN fas_strategy ON fas_strategy.fas_strategy_id = portfolio_hierarchy.parent_entity_id        
   LEFT join source_currency   ON sdd.fixed_price_currency_id=source_currency.source_currency_id        
   LEFT join deal_confirmation_rule dcr ON dcr.counterparty_id = dh.counterparty_id        
     AND isnull(dcr.buy_sell_flag,dh.header_buy_sell_flag) = dh.header_buy_sell_flag        
     AND ISNULL(dcr.commodity_id, 0) = (CASE WHEN dcr.commodity_id IS NULL THEN 0 ELSE ISNULL(dh.commodity_id, 0) END)        
     AND ISNULL(dcr.contract_id, 0) = (CASE WHEN dcr.contract_id IS NULL THEN 0 ELSE ISNULL(dh.contract_id, 0) END)        
     AND ISNULL(dcr.deal_type_id, 0) = (CASE WHEN dcr.deal_type_id IS NULL THEN 0 ELSE ISNULL(dh.source_deal_type_id, 0) END)        
   LEFT JOIN source_deal_header_template sdht on  sdht.template_id = dh.template_id        
   LEFT OUTER JOIN        
             source_deal_type source_deal_type_1 ON dh.deal_sub_type_type_id = source_deal_type_1.source_deal_type_id LEFT OUTER JOIN        
      fas_link_detail fld ON fld.source_deal_header_id = dh.source_deal_header_id         
   LEFT OUTER JOIN (SELECT source_deal_header_id, type, as_of_date, confirm_status_id AS confirm_status_id,        
      update_user,update_ts,is_confirm        
     FROM         confirm_status_recent) confirm_status ON        
    dh.source_deal_header_id = confirm_status.source_deal_header_id        
   LEFT JOIN static_data_value sdv2 ON sdv2.value_id = isnull(confirm_status.type, 17200)        
   LEFT JOIN (        
    SELECT id, deal_type_id, hour, minute        
    FROM deal_lock_setup dl        
    INNER JOIN application_role_user aru ON dl.role_id = aru.role_id        
    WHERE aru.user_login_id = dbo.FNADBUser()        
            
   ) dls ON ((dls.deal_type_id = source_deal_type.source_deal_type_id AND ISNULL(dh.deal_locked, ''n'') <> ''y'') OR dls.deal_type_id IS NULL)        
              
   left outer join rec_generator rg on rg.generator_id=dh.generator_id        
   --LEFT JOIN source_deal_detail_hour sddh ON sdd.source_deal_detail_id = sddh.source_deal_detail_id        
   LEFT JOIN static_data_value deal_status ON deal_status.value_id = dh.deal_status        
   LEFT JOIN static_data_value sdv ON sdv.value_id = dh.deal_category_value_id        
   LEFT JOIN source_uom uom ON uom.source_uom_id = sdd.deal_volume_uom_id        
   LEFT JOIN source_uom pu ON sdd.price_uom_id = pu.source_uom_id        
   LEFT JOIN contract_group cg ON cg.contract_id = dh.contract_id        
   LEFT JOIN source_minor_location sml ON sdd.location_id = sml.source_minor_location_id        
   LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = sdd.curve_id  
   LEFT JOIN static_data_value block_definition ON block_definition.value_id = COALESCE(spcd.block_define_id,dh.block_define_id) AND block_definition.type_id = 10018         
   
 ' + CASE 
          WHEN (@history_status IS NOT NULL) THEN 
               'INNER JOIN (SELECT scs.[status], a.source_deal_header_id
							FROM save_confirm_status scs
							CROSS APPLY 
										 (SELECT max(CREATE_ts) [time], source_deal_header_id
										  FROM save_confirm_status
										  GROUP BY source_deal_header_id) a 
						  WHERE a.source_deal_header_id = scs.source_deal_header_id
						  AND a.[time] = scs.create_ts) scs1 ON scs1.source_deal_header_id = dh.source_deal_header_id'
		  ELSE ''
     END +
   
  ' OUTER APPLY (SELECT MAX(hbt.volume_mult - CASE WHEN add_dst_hour>0 THEN 1 ELSE 0 END) volume_mult FROM hour_block_term hbt 
	WHERE hbt.block_define_id = COALESCE(spcd.block_define_id,dh.block_define_id,'+@baseload_block_define_id+') AND hbt.block_type = COALESCE(spcd.block_type,dh.block_type,12000)
    --AND DATEPART(dw, hbt.term_date) NOT IN (1,7) 
    AND hbt.term_date BETWEEN sdd.term_start AND sdd.term_end ) hbt
       
   LEFT JOIN rec_volume_unit_conversion conv         
      ON conv.from_source_uom_id = spcd.display_uom_id        
      AND conv.to_source_uom_id = sdd.deal_volume_uom_id        
   WHERE 1 = 1 
   
   '        
END        
        
else if @flag='e' --exceptions        
Begin        
         
         
 set @starategy_id=(Select parent_entity_id from portfolio_hierarchy where entity_id=@book_id_int)        
 set @sub_id=(select parent_entity_id as [Subsidiary Id] from portfolio_hierarchy where entity_id=@starategy_id)         
        
 --print @sub_id        
 --print @subbook_id        
        --print @sub_id        
         
        
        
        
        
 SET @sql_Select =         
   'SELECT  DISTINCT         
   dbo.FNAHyperLinkText(10131010,cast(dh.source_deal_header_id as varchar),cast(dh.source_deal_header_id as varchar)) as [Deal ID],        
   sdv2.code [Confirm Status],            
   --dh.ext_deal_id AS [Source Deal ID],         
   dbo.FNADateFormat(dh.deal_date) as [Deal Date],        
   dh.deal_id as [Ref ID],        
   case when dh.physical_financial_flag =''p'' then ''Physical''        
    else ''Financial''        
   End        
   as Type,         
   source_counterparty.counterparty_name [Counterparty],         
          --dbo.FNADateFormat(dh.entire_term_start) as [Term Start],         
   --dbo.FNADateFormat(dh.entire_term_end) As TermEnd, source_deal_type.source_deal_type_name As [Deal Type],         
   source_deal_type_1.source_deal_type_name AS [Deal Sub Type],         
          [dbo].FNAGetAbbreviationDef(dh.option_flag) As [Option Flag], [dbo].FNAGetAbbreviationDef(dh.option_type) As [Option Type],         
   [dbo].FNAGetAbbreviationDef(dh.option_excercise_type) As [Exercise Type],            
   source_book.source_book_name As Group1,         
   sdv.code [Deal Category],        
   source_traders.trader_name as [Trader Name],static_data_value1.code as [Hedge/Item Flag],       
   static_data_value2.code as  [Hedge Type],        
--   source_currency.currency_name as Currency,        
   (        
    CASE WHEN dh.deal_locked = ''y'' THEN ''Yes''        
    ELSE         
     CASE WHEN dls.id IS NOT NULL THEN        
      CASE WHEN DATEADD(mi, dls.hour * 60 + dls.minute, ISNULL(dh.update_ts, dh.create_ts)) < GETDATE() THEN ''Yes''        
      ELSE ''No'' END        
     ELSE ''No''        
     END        
    END        
   ) AS [Deal Locked]        
   ' + @str_batch_table + '         
   FROM            
    #books b INNER JOIN        
    source_system_book_map ssbm ON ssbm.fas_book_id = b.fas_book_id INNER JOIN        
    source_deal_header dh ON dh.source_system_book_id1 = ssbm.source_system_book_id1 AND         
    dh.source_system_book_id2 = ssbm.source_system_book_id2 AND         
    dh.source_system_book_id3 = ssbm.source_system_book_id3 AND         
    dh.source_system_book_id4 = ssbm.source_system_book_id4         
    INNER JOIN source_deal_detail sdd on sdd.source_deal_header_id = dh.source_deal_header_id         
    INNER JOIN source_counterparty ON dh.counterparty_id = source_counterparty.source_counterparty_id INNER JOIN        
         source_traders ON dh.trader_id = source_traders.source_trader_id INNER JOIN        
      source_deal_type ON dh.source_deal_type_id = source_deal_type.source_deal_type_id INNER JOIN        
             source_book ON dh.source_system_book_id1 = source_book.source_book_id INNER JOIN        
             source_book source_book_1 ON dh.source_system_book_id2 = source_book_1.source_book_id INNER JOIN        
             source_book source_book_2 ON dh.source_system_book_id3 = source_book_2.source_book_id INNER JOIN        
             source_book source_book_3 ON dh.source_system_book_id4 = source_book_3.source_book_id         
   inner join  portfolio_hierarchy ON portfolio_hierarchy.entity_id = ssbm.fas_book_id        
   inner join fas_strategy ON fas_strategy.fas_strategy_id=portfolio_hierarchy.parent_entity_id        
   inner join  portfolio_hierarchy ph1 ON ph1.entity_id = fas_strategy.fas_strategy_id        
   inner join static_data_value  static_data_value1 ON isnull(dh.fas_deal_type_value_id,ssbm.fas_deal_type_value_id)=static_data_value1.value_id        
   inner join static_data_value  static_data_value2 ON fas_strategy.hedge_type_value_id=static_data_value2.value_id        
   LEFT  join fas_subsidiaries on fas_subsidiaries.fas_subsidiary_id=ph1.parent_entity_id        
   --inner join source_currency   ON fas_subsidiaries.func_cur_value_id=source_currency.source_currency_id        
   inner join source_currency  ON sdd.fixed_price_currency_id=source_currency.source_currency_id        
   LEFT OUTER JOIN        
             source_deal_type source_deal_type_1 ON dh.deal_sub_type_type_id = source_deal_type_1.source_deal_type_id LEFT OUTER JOIN        
      fas_link_detail fld ON fld.source_deal_header_id = dh.source_deal_header_id         
   LEFT OUTER JOIN (SELECT source_deal_header_id, type, as_of_date, confirm_status_id AS confirm_status_id        
     FROM         confirm_status_recent) confirm_status ON        
    dh.source_deal_header_id = confirm_status.source_deal_header_id        
   LEFT OUTER JOIN static_data_value sdv2 ON sdv2.value_id = ISNULL(confirm_status.type,17200)        
   left outer join rec_generator rg on rg.generator_id=dh.generator_id        
   LEFT JOIN (        
    SELECT id, deal_type_id, hour, minute        
    FROM deal_lock_setup dl        
    INNER JOIN application_role_user aru ON dl.role_id = aru.role_id        
    WHERE aru.user_login_id = dbo.FNADBUser()        
            
   ) dls ON ((dls.deal_type_id = source_deal_type.source_deal_type_id AND ISNULL(dh.deal_locked, ''n'') <> ''y'') OR dls.deal_type_id IS NULL)        
           
   LEFT JOIN static_data_value sdv ON sdv.value_id = dh.deal_category_value_id        
   --left outer join source_deal_detail sdd on sdd.source_deal_header_id=dh.source_deal_header_id         
   --left outer join gis_certificate gis on gis.source_deal_header_id=sdd.source_deal_detail_id         
      WHERE   1 = 1 '        
        
   if @locked_unlocked_deals is not NULL        
   set @sql_Select = @sql_Select + ' and         
           
    CASE WHEN dh.deal_locked = ''y'' THEN ''Yes''        
  ELSE         
     CASE WHEN dls.id IS NOT NULL THEN        
      CASE WHEN DATEADD(mi, dls.hour * 60 + dls.minute, ISNULL(dh.update_ts, dh.create_ts)) < GETDATE() THEN ''Yes''        
      ELSE ''No'' END        
     ELSE ''No''        
     END        
    END        
    = case '''+cast(@locked_unlocked_deals as varchar)+''' when ''l'' then ''Yes'' else ''No'' end'        
END        
ELSE        
BEGIN        
         
 --select @book_id=fas_book_id from source_system_book_map where book_deal_type_map_id  in(@subbook_id)        
         
 set @starategy_id=(Select parent_entity_id from portfolio_hierarchy where entity_id=@book_id)        
 set @sub_id=(select parent_entity_id as [Subsidiary Id] from portfolio_hierarchy where entity_id=@starategy_id)         
        
 --print @sub_id        
 --print @subbook_id        
--print @sub_id        
 SET @sql_Select =         
   'SELECT dh.source_deal_header_id AS [Deal ID],        
   sdv2.code ConfirmStatus,        
   --dh.source_system_id as SourceSystemId,        
   dh.deal_id AS SourceDealID,         
   dbo.FNADateFormat(dh.deal_date) as DealDate,        
           
    dh.ext_deal_id as RefId,        
   case         
    when dh.physical_financial_flag =''p'' then ''Physical''        
    when dh.physical_financial_flag =''b'' then ''Both''        
    else ''Financial''        
   End        
   as Type,         
   source_counterparty.counterparty_name CptyName,         
   dh.deal_locked as DealLocked        
   ' + @str_batch_table + '         
   FROM            
      source_deal_header dh INNER JOIN            
             source_system_book_map ssbm ON dh.source_system_book_id1 = ssbm.source_system_book_id1 AND         
             dh.source_system_book_id2 = ssbm.source_system_book_id2 AND dh.source_system_book_id3 = ssbm.source_system_book_id3 AND         
             dh.source_system_book_id4 = ssbm.source_system_book_id4         
     INNER JOIN source_deal_detail sdd on sdd.source_deal_header_id = dh.source_deal_header_id         
     INNER JOIN  source_counterparty ON dh.counterparty_id = source_counterparty.source_counterparty_id INNER JOIN        
             source_traders ON dh.trader_id = source_traders.source_trader_id INNER JOIN        
      source_deal_type ON dh.source_deal_type_id = source_deal_type.source_deal_type_id INNER JOIN        
             source_book ON dh.source_system_book_id1 = source_book.source_book_id INNER JOIN        
             source_book source_book_1 ON dh.source_system_book_id2 = source_book_1.source_book_id INNER JOIN        
             source_book source_book_2 ON dh.source_system_book_id3 = source_book_2.source_book_id INNER JOIN        
             source_book source_book_3 ON dh.source_system_book_id4 = source_book_3.source_book_id         
   inner join  portfolio_hierarchy ON portfolio_hierarchy.entity_id = ssbm.fas_book_id        
   inner join fas_strategy ON fas_strategy.fas_strategy_id=portfolio_hierarchy.parent_entity_id        
   inner join static_data_value  static_data_value1 ON isnull(dh.fas_deal_type_value_id,ssbm.fas_deal_type_value_id)=static_data_value1.value_id        
   inner join static_data_value  static_data_value2 ON fas_strategy.hedge_type_value_id=static_data_value2.value_id        
   inner  join fas_subsidiaries on fas_subsidiaries.fas_subsidiary_id='+cast(@sub_id as varchar)+'        
   --inner join source_currency   ON fas_subsidiaries.func_cur_value_id=source_currency.source_currency_id        
   inner join source_currency  ON sdd.fixed_price_currency_id=source_currency.source_currency_id        
   LEFT OUTER JOIN        
             source_deal_type source_deal_type_1 ON dh.deal_sub_type_type_id = source_deal_type_1.source_deal_type_id LEFT OUTER JOIN        
      fas_link_detail fld ON fld.source_deal_header_id = dh.source_deal_header_id         
   LEFT OUTER JOIN (SELECT     source_deal_header_id, type, as_of_date, confirm_status_id AS confirm_status_id        
     FROM         confirm_status) confirm_status ON        
    dh.source_deal_header_id = confirm_status.source_deal_header_id        
   LEFT OUTER JOIN stati_data_value sdv2 ON sdv2.value_id = ISNULL(confirm_status.type,17200)        
   left outer join rec_generator rg on rg.generator_id=dh.generator_id        
   --left outer join source_deal_detail sdd on sdd.source_deal_header_id=dh.source_deal_header_id         
   --left outer join gis_certificate gis on gis.source_deal_header_id=sdd.source_deal_detail_id         
    WHERE 1 = 1 '        
  if @source_deal_header_id is not null        
  SET @sql_Select = @sql_Select + ' AND dh.source_deal_header_id in (' + @source_deal_header_id +')'        
        
END        
        
        
 If @deal_id_to IS NULL        
  SET @deal_id_to = @deal_id_from        
        
 IF (@subbook_id IS NOT NULL)         
  SET @sql_Select = @sql_Select + ' AND ssbm.book_deal_type_map_id in( ' + @subbook_id + ')'        
 if @deal_id_from is not NULL        
 begin        
  SET @sql_Select = @sql_Select + ' AND dh.source_deal_header_id BETWEEN ' + CAST(@deal_id_from As varchar)  + ' AND ' + CAST(@deal_id_to AS varchar)         
  IF (@deal_locked = 'l' )        
    SET @sql_Select = @sql_Select + ' AND dh.deal_locked = ''y'''        
          
  IF (@deal_locked = 'u' )        
    SET @sql_Select = @sql_Select + ' AND (dh.deal_locked = ''n'' OR dh.deal_locked IS NULL)'        
          
 END         
           
IF (@deal_id_from IS NULL) AND (@deal_id_to IS  NULL)         
begin        
  --Begin is coment as @deal_id_from and  @deal_id_to was not allowing other filters to work so it is commented Mukesh        
  --SET @sql_Select = @sql_Select + ' AND dh.deal_id BETWEEN ' + CAST(@deal_id_from As varchar)  + ' AND ' + CAST(@deal_id_to AS varchar)         
          
--  SET @sql_Select = @sql_Select + ' AND PATINDEX(''%-%'',dh.deal_id) =0 AND dh.deal_id BETWEEN ' + CAST(@deal_id_from As varchar)  + ' AND ' + CAST(@deal_id_to AS varchar)         
          
  IF (@deal_date_from IS NOT NULL) AND (@deal_date_to IS NOT NULL)         
  SET @sql_Select = @sql_Select + ' AND dh.deal_date BETWEEN '''+ @deal_date_from + ''' and ''' + @deal_date_to + ''''        
        
         
  IF (@physical_financial_flag ='p' OR @physical_financial_flag ='f' )        
   SET @sql_Select = @sql_Select + ' AND dh.physical_financial_flag='''+@physical_financial_flag+''''        
           
        
  IF (@counterparty_id IS NOT NULL)        
  SET @sql_Select = @sql_Select +' AND dh.counterparty_id IN ('+cast(@counterparty_id as varchar) + ')'       
        
  IF (@entire_term_start IS NOT NULL)        
  SET @sql_Select = @sql_Select+ ' AND dh.entire_term_start>='''+@entire_term_start+''''        
        
  IF (@entire_term_end IS NOT NULL)        
  SET @sql_Select = @sql_Select+ ' AND dh.entire_term_end<='''+@entire_term_end+''''        
        
  IF (@source_deal_type_id IS NOT NULL)        
  SET @sql_Select = @sql_Select +' AND dh.source_deal_type_id='+cast(@source_deal_type_id  as varchar)        
        
  IF (@deal_sub_type_type_id IS NOT NULL)        
  SET @sql_Select = @sql_Select +' AND dh.deal_sub_type_type_id='+cast(@deal_sub_type_type_id  as varchar)        
        
        
  IF (@deal_category_value_id IS NOT NULL)        
  SET @sql_Select = @sql_Select +' AND dh.deal_category_value_id='+cast(@deal_category_value_id  as varchar)        
        
  IF (@trader_id IS NOT NULL)        
  SET @sql_Select = @sql_Select +' AND dh.trader_id='+cast(@trader_id  as varchar)        
        
  IF (@description1 IS NOT NULL)        
  SET @sql_Select = @sql_Select +' AND dh.description1 like ''%'+@description1+'%'''        
        
  IF (@description2 IS NOT NULL)        
  SET @sql_Select = @sql_Select +' AND dh.description2 like ''%'+@description2+'%'''        
        
  IF (@description3 IS NOT NULL)        
   SET @sql_Select = @sql_Select +' AND dh.description3 like ''%'+@description3+'%'''        
        
  IF (@structured_deal_id  IS NOT NULL)        
   SET @sql_Select = @sql_Select +' AND dh.structured_deal_id like ''%'+@structured_deal_id +'%'''        
        
 IF (@deal_locked = 'l' )        
    SET @sql_Select = @sql_Select + ' AND dh.deal_locked = ''y'''        
          
  IF (@deal_locked = 'u' )        
    SET @sql_Select = @sql_Select + ' AND (dh.deal_locked = ''n'' OR dh.deal_locked IS NULL)'        
            
  ----====Added the following filter for REC deals        
  --IF ASSIGNMENT TYPE IS NOT NULL THEN IT IS ASSIGNED FOR COMPLIANCE        
  SET @sql_Select = @sql_Select +' AND dh.assignment_type_value_id IS NULL '           
        
  IF (@generator_id IS NOT NULL)        
   SET @sql_Select = @sql_Select +' AND dh.generator_id='+cast(@generator_id  as varchar)        
          
  if @gis_value_id is not null        
   SET @sql_Select = @sql_Select +' AND rg.gis_value_id='+ cast(@gis_value_id as varchar)        
  if @gen_cert_date is not null        
   SET @sql_Select = @sql_Select +' AND rg.registration_date='''+ @gen_cert_date +''''        
  if @gen_cert_number is not null        
   SET @sql_Select = @sql_Select +' AND rg.gis_account_number='''+ @gen_cert_number +''''        
  if @gis_cert_date is not null        
   SET @sql_Select = @sql_Select +' AND gis.gis_cert_date='''+ @gis_cert_date +''''        
  IF (@status_value_id IS NOT NULL)        
   SET @sql_Select = @sql_Select +' AND dh.status_value_id='+cast(@status_value_id  as varchar)        
  IF (@status_date IS NOT NULL)        
   SET @sql_Select = @sql_Select +' AND dh.status_date='''+ dbo.FNAGetSQLStandardDate(@status_date) + ''''        
  IF (@assignment_type_value_id IS NOT NULL)        
   SET @sql_Select = @sql_Select +' AND isnull(dh.assignment_type_value_id, 5149) ='+cast(@assignment_type_value_id  as varchar)        
  IF (@compliance_year IS NOT NULL)        
   SET @sql_Select = @sql_Select +' AND dh.compliance_year='+cast(@compliance_year  as varchar)        
  IF (@state_value_id IS NOT NULL)        
   SET @sql_Select = @sql_Select +' AND dh.state_value_id='+cast(@state_value_id  as varchar)        
  IF (@assigned_date IS NOT NULL)        
   SET @sql_Select = @sql_Select +' AND dh.assigned_date='''+ dbo.FNAGetSQLStandardDate(@assigned_date) + ''''        
  IF (@assigned_by IS NOT NULL)        
   SET @sql_Select = @sql_Select +' AND dh.assigned_by='''+ @assigned_by + ''''        
  IF (@header_buy_sell_flag IS NOT NULL)        
   SET @sql_Select = @sql_Select +' AND dh.header_buy_sell_flag='''+ @header_buy_sell_flag + ''''        
        
  if @source_deal_header_id is not null        
  SET @sql_Select = @sql_Select + ' AND dh.source_deal_header_id in (' + @source_deal_header_id +')'        
        
--  IF @confirm_type IS NOT NULL  -- exceptions)        
--  BEGIN        
--   if (@confirm_type = 'n')        
--    SET @sql_Select = @sql_Selecrt +' AND confirm_status.type IS NULL OR confirm_status.type=''n'' OR confirm_status.type NOT IN(''v'',''w'',''r'')'        
--   else        
--    SET @sql_Select = @sql_Select +' AND ISNULL(confirm_status.type,''n'') IN (''' + @confirm_type + ''') '        
--  end        
        
  IF @confirm_type IS NOT NULL  -- exceptions)        
  BEGIN        
   SET @sql_Select = @sql_Select +' AND ISNULL(confirm_status.type, 17200) IN (' + @confirm_type + ') '        
  END        
          
  IF (@deal_status IS NOT NULL)        
  SET @sql_Select = @sql_Select + 'AND dh.deal_status IN (' + @deal_status + ')'        
  
	IF (@history_status IS NOT NULL)        
		SET @sql_Select = @sql_Select + 'AND scs1.status = ''' + @history_status + ''''    
end           
        
IF @flag = 's'        
 SET @sql_Select = @sql_Select +         
     ' Group By dh.source_deal_header_id, dh.entire_term_start, dh.entire_term_end,sdht.deal_rules,        
     sdht.confirm_rule  ORDER BY  [Deal ID] '        
else        
 set @sql_Select = @sql_Select + ' ORDER BY  [Deal ID]'        
        
        
 --print ISNULL(@sql_Select, 'NULL')        
 EXEC(@sql_Select)        
        
if @flag='l'        
Begin        
        
   update source_deal_header set        
    deal_locked=@deal_locked        
    where source_deal_header_id = @source_deal_header_id        
           
    If @@ERROR <> 0        
     Begin         
     Exec spa_ErrorHandler @@ERROR, 'Source Deal Locked Updated',         
           
       'spa_sourcedealheader', 'DB Error',         
           
       'Failed Source Deal Locked Updated.', 'Failed Updating Record'        
     End        
     Else        
     Begin        
     Exec spa_ErrorHandler 0, 'Source Deal Header  table',         
          
      'spa_sourcedealheader', 'Success',         
          
      'Source deal  record successfully updated.', ''        
        END        
           
End 

/*******************************************2nd Paging Batch START**********************************************/
	--update time spent and batch completion message in message board
 
	IF @is_batch = 1 
	BEGIN
		SELECT @str_batch_table = dbo.FNABatchProcess ('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL)
		EXEC (@str_batch_table)
 
		SELECT @str_batch_table = dbo.FNABatchProcess ('c', @batch_process_id, @batch_report_param, GETDATE(), 'spa_sourcedealheader_confirm', 'Deal Confirm Report')
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


