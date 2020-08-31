
/****** Object:  StoredProcedure [dbo].[spa_sourcedealtemp]    Script Date: 06/29/2011 16:18:28 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_sourcedealtemp]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_sourcedealtemp]
GO

/****** Object:  StoredProcedure [dbo].[spa_sourcedealtemp]    Script Date: 06/29/2011 16:18:28 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*      
      
exec spa_sourcedealtemp 'e', NULL,2002, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
  
    
 NULL, NULL, NULL, NULL, NULL, ''      
 Modification History      
 Modified By:Pawan KC      
 Modified Date:26/03/3009      
 Description: Removed option_type from selection and insertion of source_deal_header in the v block      
       
 Modification History      
 Modified By:Pawan KC      
 Modified Date:30/03/3009      
 Description: Mapped template_id in the v flag block while inserting the source deal header      
*/      
      
--select * from  source_deal_header      
--spa_sourcedealtemp 'a',NULL,9674 ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL      
--,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'5D7AF6D9_273F_471D_8A4D_839E0F8AC6BA'      
      
CREATE proc [dbo].[spa_sourcedealtemp]      
@flag char(1),      
@book_deal_type_map_id varchar(200)=NULL,       
@source_deal_header_id int=NULL,      
@source_system_id int=NULL,      
@counterparty_id int=NULL,      
@entire_term_start varchar(10)=NULL,      
@entire_term_end varchar(10)=NULL,      
@source_deal_type_id int=NULL,      
@deal_sub_type_type_id int=NULL,      
@deal_category_value_id int=NULL,      
@trader_id int=NULL,      
@internal_deal_type_value_id int=NULL,      
@internal_deal_subtype_value_id int= NULL,      
@book_id int=NULL,      
@template_id int = NULL,      
@term_start varchar(10)=NULL,      
@term_end varchar(10)=NULL,      
@leg int=NULL,      
@contract_expiration_date varchar(10)=NULL,      
@fixed_float_leg char(1)=NULL,      
@buy_sell_flag char(1)=NULL,      
@curve_id int=NULL,      
@fixed_price numeric(38,20)=NULL,      
@fixed_price_currency_id int=NULL,      
@option_flag char(1)=NULL,      
@option_strike_price numeric(38,20)=NULL,      
@deal_volume numeric(38,20)=NULL,      
@deal_volume_frequency char(1)=NULL,      
@deal_volume_uom_id int=NULL,      
@block_description varchar(100)=NULL,      
@deal_detail_description varchar(100)=NULL,      
@term_start1 varchar(10)=NULL,      
@term_end1 varchar(10)=NULL,      
@leg1 int=NULL,      
@formula_id int=NULL,      
@sell_curve_id int=NULL,      
@sell_fixed_price numeric(38,20)=NULL,      
@sell_fixed_price_currency_id int=NULL,      
@sell_option_strike_price numeric(38,20)=NULL,      
@sell_deal_volume float=NULL,      
@sell_deal_volume_frequency char(1)=NULL,      
@sell_deal_volume_uom_id int=NULL,      
@sell_fixed_float_leg char(1)=NULL,      
@sell_formula_id int=NULL,      
@process_id varchar(100)=NULL,      
@deal_date varchar(10)=NULL,      
@frequency_type char(1)=NULL,      
@broker_id int=NULL,      
@hour_from int=NULL,      
@hour_to int=NULL,      
@source_deal_detail_id varchar(1000)=null,      
@deal_id varchar(1000)=null,      
@physical_financial_flag CHAR(1)=NULL,      
@option_type CHAR(1)=null,      
@option_excercise_type CHAR(1)=null,      
@options_term_start VARCHAR(20)=null,      
@options_term_end VARCHAR(20)=null,      
@exercise_date VARCHAR(20)=null,      
@round_value char(2)='9',      
@deleted_deal VARCHAR(1)='n'      
      
as      
      
EXEC spa_print @deal_id      
Declare @sql_Select varchar(max)      
Declare @copy_source_deal_header_id int      
Declare @starategy_id int      
Declare @sub_id int      
declare @term_start_value varchar(10)      
declare @term_end_value varchar(10)      
--Declare @book_id int      
      
declare @source_book_id1 int      
declare @source_book_id2 int      
declare @source_book_id3 int      
declare @source_book_id4 int      
declare @new_deal_id varchar(20)      
declare @new_source_system_id int      
--declare @frequency_type varchar(1)      
declare @frequency int      
declare @new_buy_sell varchar(10)      
Declare @new_entire_term_end varchar(10)      
      
      
Declare @tempheadertable varchar(128)   
Declare @tempdetailtable varchar(128)      
Declare @user_login_id varchar(100)      
Declare @val varchar(100)      
Declare @leg_no int      
      
set @user_login_id=dbo.FNADBUser()      
--set @user_login_id='urbaral'      
    
 if @process_id is NULL      
 Begin      
  set @process_id=REPLACE(newid(),'-','_')      
        
 End      
 set @tempheadertable=dbo.FNAProcessTableName('source_deal_header_temp', @user_login_id,@process_id)      
 set @tempdetailtable=dbo.FNAProcessTableName('source_deal_detail_temp', @user_login_id,@process_id)      
       

IF ISNULL(@round_value,'')=''
	SET @round_value=4
	
	       
declare @max_leg int,@buy_sell char(1),@label_index varchar(50),@label_price varchar(50)      
If @flag = 'a'  --select temp header data      
 begin      
       
       
 DECLARE @commodity_id INT,      
   @product_id INT,      
   @deal_type INT        
    DECLARE @header_deal_date DATETIME       
    DECLARE @max_effective_date DATETIME       
    DECLARE @broker_unit_price FLOAT,      
   @broker_fixed_price FLOAT       
 DECLARE @broker_effective_date DATETIME,      
   @broker_deal_type INT,      
   @broker_commodity INT,      
   @broker_product INT,      
   @sdeal VARCHAR(1000)       
          
          
    IF(ISNULL(@deleted_deal,'n')='y')      
  BEGIN      
      SELECT       
   @header_deal_date = deal_date,      
   @commodity_id = commodity_id,      
   @deal_type = source_deal_type_id,      
   @broker_id = broker_id      
  FROM delete_source_deal_header WHERE source_deal_header_id = @source_deal_header_id       
  END      
    ELSE      
  BEGIN      
         SELECT       
   @header_deal_date = deal_date,      
   @commodity_id = commodity_id,      
   @deal_type = source_deal_type_id,      
   @broker_id = broker_id      
  FROM source_deal_header WHERE source_deal_header_id = @source_deal_header_id       
     END      
        
       
 SELECT TOP 1 @product_id = curve_id FROM source_deal_detail WHERE source_deal_header_id = @source_deal_header_id ORDER BY leg, term_start      
       
        
    SELECT  @max_effective_date = ISNULL(MAX(effective_date),'1900-01-01')      
    FROM    broker_fees bf      
    WHERE   effective_date <= @header_deal_date      
            AND counterparty_id = @broker_id      
        
      
      
 SELECT DISTINCT       
 TOP 1      
  @broker_unit_price = bf.unit_price,      
  @broker_fixed_price = bf.fixed_price,      
  @broker_effective_date = bf.effective_Date,       
  @broker_deal_type = bf.deal_type,       
  @broker_commodity = bf.commodity,       
  @broker_product = bf.product       
 FROM    broker_fees bf      
 INNER JOIN source_deal_header sdh ON ISNULL(bf.counterparty_id,-1) = ISNULL(@broker_id,-1)      
  AND ISNULL(bf.commodity,-1) = CASE WHEN bf.commodity IS NULL THEN ISNULL(bf.commodity,-1) ELSE @commodity_id END      
  AND ISNULL(bf.deal_type,-1) = CASE WHEN bf.deal_type IS NULL THEN ISNULL(bf.deal_type,-1) ELSE @deal_type END      
  AND ISNULL(bf.product,-1) = CASE WHEN bf.product IS NULL THEN ISNULL(bf.product,-1) ELSE @product_id END      
  AND bf.effective_date = @max_effective_date      
 ORDER BY bf.effective_Date DESC, bf.deal_type, bf.commodity, bf.product      
        
      
         
        
        
-- set @sql_select='SELECT dh.source_deal_header_id DetailId,dh.source_system_id ,dh.deal_id,       
--  dbo.FNAGetSQLStandardDate(dh.deal_date) deal_date,      
--   dh.ext_deal_id ,dh.physical_financial_flag,       
--  dh.counterparty_id,       
--  dbo.FNAGetSQLStandardDate(dh.entire_term_start) entire_term_start,       
--  dbo.FNAGetSQLStandardDate(dh.entire_term_end) entire_term_end, dh.source_deal_type_id,       
--  dh.deal_sub_type_type_id,       
--  dh.option_flag, dh.option_type, dh.option_excercise_type,       
--  source_book.source_book_name As Group1,       
--  source_book_1.source_book_name AS Group2,       
--         source_book_2.source_book_name AS Group3, source_book_3.source_book_name AS Group4,      
--  dh.description1,dh.description2,dh.description3,      
--  dh.deal_category_value_id,dh.trader_id, source_system_book_map.fas_book_id,portfolio_hierarchy.parent_entity_id,      
--  fas_strategy.hedge_type_value_id,static_data_value1.code as HedgeItemFlag,      
--   static_data_value2.code as HedgeType,source_currency.currency_name as Currency,      
--      
--  dh.internal_deal_type_value_id,dh.internal_deal_subtype_value_id,dh.template_id,dh.structured_deal_id,dh.header_buy_sell_flag,      
--  dh.broker_id,      
-- dh.generator_id, status_value_id, dbo.FNAGetSQLStandardDate(status_date) status_date,      
--  assignment_type_value_id, compliance_year, dh.state_value_id,  dbo.FNAGetSQLStandardDate(assigned_date) assigned_date ,      
--   assigned_by,generation_source ,      
--  isnull(dh.aggregate_environment, rg.aggregate_environment) aggregate_environment,      
--  isnull(dh.aggregate_envrionment_comment, rg.aggregate_envrionment_comment) aggregate_envrionment_comment,      
-- dh.create_user,dh.create_ts,dh.update_user,dh.update_ts,      
-- dbo.FNAGetAssignmentDesc(5147) AssignmentDesc1,       
-- dbo.FNADEALRECExpiration(dh.source_deal_header_id, ''2005-01-01'', 5147) DEALRECExpiration1,      
-- dbo.FNAGetAssignmentDesc(5146) AssignmentDesc2,       
-- dbo.FNADEALRECExpiration(dh.source_deal_header_id, ''2005-01-01'', 5146) DEALRECExpiration2,      
-- case        
--  --when (dh.source_deal_type_id <> 55) then NULL      
--  when (dh.rec_price is null and dh.rec_formula_id is null) then rg.rec_price       
--  else dh.rec_price end rec_price,      
-- case        
--  --when (dh.source_deal_type_id <> 55) then NULL      
--  when (dh.rec_price is null and dh.rec_formula_id is null) then rg.rec_formula_id       
--  else dh.rec_formula_id end rec_formula_id,      
-- dbo.FNAFormulaFormat(f.formula, ''r'') formula,      
-- source_system_book_map.fas_deal_type_value_id,sdt.disable_gui_groups,dh.rolling_avg,sdht.template_name,dh.contract_id      
--  FROM source_deal_header dh LEFT OUTER JOIN rec_generator rg on dh.generator_id = rg.generator_id       
--  LEFT OUTER JOIN formula_editor f on       
--  case  when (dh.source_deal_type_id <> 55) then NULL      
--   when (dh.rec_price is null and dh.rec_formula_id is null) then rg.rec_formula_id       
--   else dh.rec_formula_id end = f.formula_id      
--   INNER JOIN       
--            source_book ON dh.source_system_book_id1 = source_book.source_book_id INNER JOIN      
--            source_book source_book_1 ON dh.source_system_book_id2 = source_book_1.source_book_id INNER JOIN      
--     source_book source_book_2 ON dh.source_system_book_id3 = source_book_2.source_book_id INNER JOIN      
--     source_book source_book_3 ON dh.source_system_book_id4 = source_book_3.source_book_id      
--  inner join source_system_book_map on  source_system_book_map.source_system_book_id1= source_book.source_book_id       
--  inner join  portfolio_hierarchy ON portfolio_hierarchy.entity_id = source_system_book_map.fas_book_id      
--  inner join fas_strategy ON fas_strategy.fas_strategy_id=portfolio_hierarchy.parent_entity_id      
--  inner join static_data_value  static_data_value1 ON source_system_book_map.fas_deal_type_value_id=static_data_value1.value_id      
--  inner join static_data_value  static_data_value2 ON fas_strategy.hedge_type_value_id=static_data_value2.value_id      
--  left outer join(select source_system_book_map.fas_book_id as book_id       
--  FROM source_deal_header dh       
--   INNER JOIN       
--            source_book ON dh.source_system_book_id1 = source_book.source_book_id INNER JOIN      
--            source_book source_book_1 ON dh.source_system_book_id2 = source_book_1.source_book_id INNER JOIN      
--     source_book source_book_2 ON dh.source_system_book_id3 = source_book_2.source_book_id INNER JOIN      
--     source_book source_book_3 ON dh.source_system_book_id4 = source_book_3.source_book_id      
--inner join source_system_book_map on  source_system_book_map.source_system_book_id1= source_book.source_book_id       
--  and source_system_book_map.source_system_book_id2= source_book_1.source_book_id     
--  and source_system_book_map.source_system_book_id3= source_book_2.source_book_id       
--  and source_system_book_map.source_system_book_id4= source_book_3.source_book_id       
--inner join  portfolio_hierarchy ON portfolio_hierarchy.entity_id = source_system_book_map.fas_book_id      
--  where dh.source_deal_header_id='+cast(@source_deal_header_id as varchar)+') books      
--  on books.book_id=source_system_book_map.fas_book_id      
--  left outer join (Select entity_id,parent_entity_id from portfolio_hierarchy) strat       
--  on strat.entity_id=books.book_id      
--  left outer join (select parent_entity_id as [Subsidiary Id],entity_id       
--  from portfolio_hierarchy)subs      
--  on subs.entity_id=strat.parent_entity_id       
--  inner join fas_subsidiaries on fas_subsidiaries.fas_subsidiary_id=subs.[Subsidiary Id]      
--  inner join source_currency   ON fas_subsidiaries.func_cur_value_id=source_currency.source_currency_id      
--  join source_deal_type sdt on sdt.source_deal_type_id=dh.source_deal_type_id  left outer join source_deal_header_template sdht      
--  on sdht.template_id=dh.template_id       
--  where dh.source_deal_header_id='+cast(@source_deal_header_id as varchar)      
      
set @sql_select='SELECT dh.source_deal_header_id DetailId,dh.source_system_id ,dh.deal_id,       
  dbo.FNAGetSQLStandardDate(dh.deal_date) deal_date,      
   dh.ext_deal_id ,dh.physical_financial_flag,       
  dh.counterparty_id,       
  dbo.FNAGetSQLStandardDate(dh.entire_term_start) entire_term_start,       
  dbo.FNAGetSQLStandardDate(dh.entire_term_end) entire_term_end, dh.source_deal_type_id,       
  dh.deal_sub_type_type_id,       
  dh.option_flag, dh.option_type, dh.option_excercise_type,       
  source_book.source_book_name As Group1,       
  source_book_1.source_book_name AS Group2,       
     source_book_2.source_book_name AS Group3, source_book_3.source_book_name AS Group4,      
  dh.description1,dh.description2,dh.description3,      
  dh.deal_category_value_id,dh.trader_id, ssbm.fas_book_id,portfolio_hierarchy.parent_entity_id,      
  fas_strategy.hedge_type_value_id,static_data_value1.code as HedgeItemFlag,      
   static_data_value2.code as HedgeType,source_currency.currency_name as Currency,      
      
  dh.internal_deal_type_value_id,dh.internal_deal_subtype_value_id,dh.template_id,dh.structured_deal_id,dh.header_buy_sell_flag,      
  dh.broker_id,      
 dh.generator_id, status_value_id, dbo.FNAGetSQLStandardDate(status_date) status_date,      
  assignment_type_value_id, compliance_year, dh.state_value_id,  dbo.FNAGetSQLStandardDate(assigned_date) assigned_date ,      
   assigned_by,generation_source ,      
  isnull(dh.aggregate_environment, rg.aggregate_environment) aggregate_environment,      
  isnull(dh.aggregate_envrionment_comment, rg.aggregate_envrionment_comment) aggregate_envrionment_comment,      
 dh.create_user,dbo.FNADateTimeFormat(dh.create_ts,1),dh.update_user,dbo.FNADateTimeFormat(dh.update_ts,1),      
 dbo.FNAGetAssignmentDesc(5147) AssignmentDesc1,       
 dbo.FNADEALRECExpiration(dh.source_deal_header_id, ''2005-01-01'', 5147) DEALRECExpiration1,      
 dbo.FNAGetAssignmentDesc(5146) AssignmentDesc2,       
 dbo.FNADEALRECExpiration(dh.source_deal_header_id, ''2005-01-01'', 5146) DEALRECExpiration2,      
 case  when (dh.rec_price is null and dh.rec_formula_id is null) then rg.rec_price       
  else dh.rec_price end rec_price,      
 case         
  when (dh.rec_price is null and dh.rec_formula_id is null) then rg.rec_formula_id       
  else dh.rec_formula_id end rec_formula_id,      
 dbo.FNAFormulaFormat(f.formula, ''r'') formula,      
 ssbm.fas_deal_type_value_id,sdt.disable_gui_groups,dh.rolling_avg,
 sdht.template_name+CASE WHEN ssd.source_system_id = 2 THEN '''' ELSE ''.''+ssd.source_system_name END ,
 dh.contract_id,      
 dh.legal_entity,      
 dh.source_system_book_id1,dh.source_system_book_id2,dh.source_system_book_id3,dh.source_system_book_id4,      
 dh.internal_desk_id,dh.product_id,dh.internal_portfolio_id,dh.commodity_id,dh.reference,      
 isNull(sdht.allow_edit_term,''n'') allow_edit_term,      
       
 (      
  CASE WHEN deal_locked = ''y'' THEN ''Yes''      
  ELSE       
   CASE WHEN dls.id IS NOT NULL THEN      
    CASE WHEN DATEADD(mi, dls.hour * 60 + dls.minute, ISNULL(dh.update_ts, dh.create_ts)) < GETDATE() THEN ''Yes''      
    ELSE ''No'' END      
   ELSE ''No''      
   END      
  END      
 ) AS deal_locked,       
       
 close_reference_id,      
 dh.block_type,dh.block_define_id,dh.granularity_id,dh.pricing [Pricing],sdd.process_deal_status,      
    sdv_con_stat.code ConfirmStatus,      
      dbo.FNAGetSQLStandardDate(ConfirmStatusDate),      
      ConfirmUser,      
      dh.unit_fixed_flag,         
    ISNULL(dh.broker_unit_fees,' + case when @broker_unit_price is null then 'NULL' else cast(@broker_unit_price as varchar) end + '),      
    ISNULL(dh.broker_fixed_cost,'+ case when @broker_fixed_price is null then 'NULL' else cast(@broker_fixed_price as varchar) end + '),      
      dh.broker_currency_id,dh.deal_status,      
      dbo.FNADateformat(dh.option_settlement_date) option_settlement_date,      
      isNull(sdht.term_end_flag,''n'') term_end_flag,      
      ssbm.book_deal_type_map_id,      
      parentC.counterparty_name parent_counterparty,
      deal_reference_type_id,
      sdht.deal_rules,
      sdht.confirm_rule
  FROM ' +CASE WHEN isnull(@deleted_deal,'n')='y' then  'delete_source_deal_header' ELSE 'source_deal_header' END +' dh LEFT OUTER JOIN rec_generator rg on dh.generator_id = rg.generator_id       
  LEFT OUTER JOIN formula_editor f on       
  case  when (dh.source_deal_type_id <> 55) then NULL      
   when (dh.rec_price is null and dh.rec_formula_id is null) then rg.rec_formula_id       
   else dh.rec_formula_id end = f.formula_id      
   INNER JOIN       
            source_book ON dh.source_system_book_id1 = source_book.source_book_id       
  INNER JOIN ' +CASE WHEN isnull(@deleted_deal,'n')='y' then  'delete_source_deal_detail' ELSE 'source_deal_detail' END +' sdd on sdd.source_deal_header_id=dh.source_deal_header_id      
  INNER JOIN      
            source_book source_book_1 ON dh.source_system_book_id2 = source_book_1.source_book_id INNER JOIN      
     source_book source_book_2 ON dh.source_system_book_id3 = source_book_2.source_book_id INNER JOIN      
     source_book source_book_3 ON dh.source_system_book_id4 = source_book_3.source_book_id      
  left outer join source_system_book_map ssbm on  ssbm.source_system_book_id1= dh.source_system_book_id1      
     and ssbm.source_system_book_id2= dh.source_system_book_id2       
  and ssbm.source_system_book_id3= dh.source_system_book_id3      
  and ssbm.source_system_book_id4= dh.source_system_book_id4       
  left outer join  portfolio_hierarchy ON portfolio_hierarchy.entity_id = ssbm.fas_book_id      
  left outer join fas_strategy ON fas_strategy.fas_strategy_id=portfolio_hierarchy.parent_entity_id      
  left outer join static_data_value  static_data_value1 ON ssbm.fas_deal_type_value_id=static_data_value1.value_id      
  left outer join static_data_value  static_data_value2 ON fas_strategy.hedge_type_value_id=static_data_value2.value_id      
  left outer join static_data_value  static_data_value3 ON static_data_value3.value_id=dh.pricing      
  left outer join  portfolio_hierarchy strat ON strat.entity_id = fas_strategy.fas_strategy_id      
  left outer join  portfolio_hierarchy subs ON subs.entity_id = strat.parent_entity_id      
  left outer join fas_subsidiaries on fas_subsidiaries.fas_subsidiary_id=subs.entity_id      
  left outer join source_currency ON fas_subsidiaries.func_cur_value_id=source_currency.source_currency_id      
  left outer join source_deal_type sdt on sdt.source_deal_type_id=dh.source_deal_type_id        
  left outer join source_deal_header_template sdht on sdht.template_id=dh.template_id          
  LEFT JOIN source_system_description ssd ON ssd.source_system_id = dh.source_system_id      
  LEFT JOIN (      
    SELECT id, deal_type_id, hour, minute      
    FROM deal_lock_setup dl      
    INNER JOIN application_role_user aru ON dl.role_id = aru.role_id      
    WHERE aru.user_login_id = dbo.FNADBUser()      
          
   ) dls ON ((dls.deal_type_id = sdt.source_deal_type_id AND ISNULL(dh.deal_locked, ''n'') <> ''y'') OR dls.deal_type_id IS NULL)                
  LEFT OUTER JOIN (SELECT source_deal_header_id, type, as_of_date AS ConfirmStatusDate, confirm_status_id AS confirm_status_id, update_user [ConfirmUser]      
     FROM         confirm_status_recent) confirm_status ON      
    dh.source_deal_header_id = confirm_status.source_deal_header_id      
  LEFT OUTER JOIN static_data_value sdv_con_stat ON sdv_con_stat.value_id = isnull(confirm_status.type, 17200)  
  LEFT OUTER JOIN dbo.source_counterparty cp ON cp.source_counterparty_id  = dh.counterparty_id 
  LEFT OUTER JOIN dbo.source_counterparty parentC ON parentC.source_counterparty_id  = cp.parent_counterparty_id  
  where dh.source_deal_header_id='+cast(@source_deal_header_id as varchar)      
 EXEC spa_print @sql_select      
 exec(@sql_select)      
 end       
   
else if @flag='s'      
 Begin      
 select @max_leg=max(leg),@buy_sell=max(buy_sell_flag) from source_deal_detail       
  where source_deal_header_id=@source_deal_header_id      
 set @label_index='Index'      
 set @label_price='Price'      
 if @max_leg=1 and @buy_sell='b'      
 begin      
  set @label_index='Buy Index'      
  set @label_price='Price'      
 end      
 else if @max_leg=1 and @buy_sell='s'      
 begin      
  set @label_index='Sell Index'      
  set @label_price='Price'      
 end      
  --print 'asas'      
 set @sql_select='      
 select  a.source_deal_detail_id,      
 dbo.FNADateFormat(term_start) as TermStart,       
 dbo.FNADateFormat(term_end) as TermEnd,      
-- CONVERT(VARCHAR(10),term_start,120) as TermStart,       
-- CONVERT(VARCHAR(10),term_end,120) as TermEnd,      
  Leg,       
  dbo.FNADateFormat(contract_expiration_date)  as ExpDate,      
--  CONVERT(VARCHAR(10),contract_expiration_date,120)  as ExpDate,      
  case when fixed_float_leg=''f'' then ''Fixed'' else ''Float'' End as [Fixed/Float],      
  case when buy_sell_flag =''b'' then ''Buy(Receive)'' else ''Sell(Pay)'' End as [Buy/Sell],      
  pcd.source_curve_type_value_id curve_type,       
  pcd.commodity_id  as commodity,      
--  CASE WHEN       
--   a.physical_financial_flag = ''p'' THEN ''Physical''      
--  ELSE      
--   ''Financial''      
--  END AS [Physical/Financial],      
  a.physical_financial_flag AS [Physical/Financial],      
  a.location_id as Location,       
  a.curve_id as  ['+@label_index+'],      
  ROUND(dbo.FNARemoveTrailingZeroes(CAST(deal_volume AS numeric(38,20))),'+@round_value+') as Volume,   
  deal_volume_frequency as Frequency,      
  deal_volume_uom_id as UOM,      
   ROUND(dbo.FNARemoveTrailingZeroes(CAST(total_volume AS numeric(38,9))),'+@round_value+') as [TotalVolume],      
  capacity as Capacity,      
        
  case  when sdt.expiration_applies =''y'' and      
   ( a.fixed_price is null and a.formula_id is null)  then       
    dbo.FNARemoveTrailingZeroes(CAST(rg.contract_price AS numeric(38,15))) else       
   dbo.FNARemoveTrailingZeroes(CAST(fixed_price AS numeric(38,15))) end as ['+@label_price+'],      
  dbo.FNARemoveTrailingZeroes(CAST(fixed_cost AS numeric(38,15))) AS [Fixed Cost],      
  fixed_cost_currency_id,      
--  dbo.FNAFormulaFormat(fe.formula,''r'') as Formula,      
  fe.formula_id as Formula,      
  formula_currency_id,      
  dbo.FNARemoveTrailingZeroes(ROUND(option_strike_price,9)) as OptionStrike,      
  --round(price_adder,4) PriceAdder,      
  dbo.FNARemoveTrailingZeroes(price_adder) PriceAdder,      
  adder_currency_id,      
  --round(ISNULL(price_multiplier,1),4) Multiplier,      
  dbo.FNARemoveTrailingZeroes(ISNULL(price_multiplier,1)) PriceMultiplier,      
  dbo.FNARemoveTrailingZeroes(ISNULL(multiplier,1)) multiplier,      
  fixed_price_currency_id as Currency,      
        
  dbo.FNARemoveTrailingZeroes(price_adder2) PriceAdder2,      
  price_adder_currency2,      
  dbo.FNARemoveTrailingZeroes(ISNULL(volume_multiplier2,1)) VolumeMultiplier2,        
  meter_id as [Meter],      
  upper(pay_opposite) as [Pay Opposite],      
  ISNULL(dbo.FNADateFormat(a.settlement_date),dbo.FNADateFormat(contract_expiration_date)) [Payment Date],      
--  ISNULL(CONVERT(VARCHAR(10),a.settlement_date,120),CONVERT(VARCHAR(10),contract_expiration_date,120)) [Payment Date],      
  case  when sdt.expiration_applies =''y'' then      
   cast(dbo.FNARECBonus(h.source_deal_header_id) as varchar)  else       
   block_description end as Bonus,      
         
         
  deal_detail_description as HourEnding,      
  case  when sdt.expiration_applies =''y'' and (a.fixed_price is null and a.formula_id is null) then       
    rg.contract_formula_id else       
   a.formula_id end as [FormulaPrice],      
  a.day_count_id [Day count]      
        
  from source_deal_detail a join      
  source_deal_header h on      
  a.source_deal_header_id=h.source_deal_header_id join      
  source_deal_type sdt on sdt.source_deal_type_id=h.source_deal_type_id       
  left outer join source_price_curve_def pcd on pcd.source_curve_def_id=a.curve_id       
  left outer join rec_generator rg on rg.generator_id=h.generator_id      
  left outer join formula_editor fe on fe.formula_id=a.formula_id      
  where a.source_deal_header_id='+cast(@source_deal_header_id as varchar)      
      
  if @term_start is not null      
  set @sql_select= @sql_select+ ' And term_start='''+@term_start+''''      
       
  if @term_start is not null      
  set @sql_select= @sql_select +' And term_end='''+@term_end+''''      
        
  set @sql_select= @sql_select+ ' order by term_start,leg '      
        
  EXEC spa_print @sql_select      
      
  exec(@sql_select)      
        
 END      
       
else if @flag='p'      
 Begin      
 select @max_leg=max(leg),@buy_sell=max(buy_sell_flag) from source_deal_detail       
  where source_deal_header_id=@source_deal_header_id      
 set @label_index='Index'      
 set @label_price='Price'      
 if @max_leg=1 and @buy_sell='b'      
 begin      
  set @label_index='Buy Index'      
  set @label_price='Price'      
 end      
 else if @max_leg=1 and @buy_sell='s'      
 begin      
  set @label_index='Sell Index'      
  set @label_price='Price'      
 end      
  --print 'asas'      
 set @sql_select='      
  select  a.source_deal_detail_id,      
  term_start as TermStart,       
  term_end as TermEnd,      
  Leg,       
  contract_expiration_date  as ExpDate,      
  case when fixed_float_leg=''f'' then ''Fixed'' else ''Float'' End as [Fixed/Float],      
  case when buy_sell_flag =''b'' then ''Buy(Receive)'' else ''Sell(Pay)'' End as [Buy/Sell],      
  pcd.source_curve_type_value_id curve_type,       
  pcd.commodity_id  as commodity,      
  a.physical_financial_flag AS [Physical/Financial],      
  a.location_id as Location,       
  a.curve_id as  ['+@label_index+'],      
  ROUND(dbo.FNARemoveTrailingZeroes(CAST(deal_volume AS numeric(38,20))),'+@round_value+') as Volume,      
  deal_volume_frequency as Frequency,      
  deal_volume_uom_id as UOM,      
    ROUND(dbo.FNARemoveTrailingZeroes(CAST(total_volume AS numeric(38,9))),'+@round_value+') as [TotalVolume],    
  capacity as Capacity,      
        
  case  when sdt.expiration_applies =''y'' and      
   ( a.fixed_price is null and a.formula_id is null)  then       
    dbo.FNARemoveTrailingZeroes(CAST(rg.contract_price AS numeric(38,15))) else       
   dbo.FNARemoveTrailingZeroes(CAST(fixed_price AS numeric(38,15))) end as ['+@label_price+'],      
  dbo.FNARemoveTrailingZeroes(CAST(fixed_cost AS numeric(38,15))) AS [Fixed Cost],      
  fixed_cost_currency_id,      
  fe.formula_id as Formula,      
  formula_currency_id,      
  dbo.FNARemoveTrailingZeroes(ROUND(option_strike_price,9)) as OptionStrike,      
  dbo.FNARemoveTrailingZeroes(price_adder) PriceAdder,      
  adder_currency_id,      
  dbo.FNARemoveTrailingZeroes(ISNULL(price_multiplier,1)) PriceMultiplier,      
  dbo.FNARemoveTrailingZeroes(ISNULL(multiplier,1)) multiplier,      
  fixed_price_currency_id as Currency,      
        
  dbo.FNARemoveTrailingZeroes(price_adder2) PriceAdder2,      
  price_adder_currency2,      
  dbo.FNARemoveTrailingZeroes(ISNULL(volume_multiplier2,1)) VolumeMultiplier2,        
  a.meter_id as [Meter],      
  upper(pay_opposite) as [Pay Opposite],      
  ISNULL(a.settlement_date,contract_expiration_date) [Payment Date],      
  case  when sdt.expiration_applies =''y'' then      
   cast(dbo.FNARECBonus(h.source_deal_header_id) as varchar)  else       
   block_description end as Bonus,      
         
         
  deal_detail_description as HourEnding,      
  case  when sdt.expiration_applies =''y'' and (a.fixed_price is null and a.formula_id is null) then       
    rg.contract_formula_id else       
   a.formula_id end as [FormulaPrice],      
  a.day_count_id [Day count]      
  ,case when source_Major_Location.location_name is null then '''' else source_Major_Location.location_name + '' -> '' end +  sml.Location_Name LocationName    
  ,pcd.curve_name CurveName      
  ,a.settlement_currency as [Sett.Currency],      
  a.standard_yearly_volume AS [SYV],
    a.price_uom_id [Price UOM],
   a.category Category,
   a.profile_code PROFILE,
   a.pv_party [PR Party],
   mi.recorderid [Meter_Name]      
  from ' +CASE WHEN isnull(@deleted_deal,'n')='y' then  'delete_source_deal_detail' ELSE 'source_deal_detail' END +' a join      
  ' +CASE WHEN isnull(@deleted_deal,'n')='y' then  'delete_source_deal_header' ELSE 'source_deal_header' END +' h on      
  a.source_deal_header_id=h.source_deal_header_id join      
  source_deal_type sdt on sdt.source_deal_type_id=h.source_deal_type_id       
  left outer join source_price_curve_def pcd on pcd.source_curve_def_id=a.curve_id       
  left outer join rec_generator rg on rg.generator_id=h.generator_id      
  left outer join formula_editor fe on fe.formula_id=a.formula_id      
  LEFT OUTER JOIN source_minor_location sml ON sml.source_minor_location_id = a.location_id
  LEFT JOIN source_Major_Location ON sml.source_Major_Location_Id=source_Major_Location.source_major_location_ID    
  LEFT JOIN meter_id mi ON mi.meter_id = a.meter_id	
  where a.source_deal_header_id='+cast(@source_deal_header_id as varchar)      
      
  if @term_start is not null      
  set @sql_select= @sql_select+ ' And term_start='''+@term_start+''''      
       
  if @term_start is not null      
  set @sql_select= @sql_select +' And term_end='''+@term_end+''''      
        
  set @sql_select= @sql_select+ ' order by term_start,leg '      
        
  EXEC spa_print @sql_select      
      
  exec(@sql_select)      
        
 End      
      
else if @flag='g' -- NON Edit Grid      
 BEGIN      
        
 IF ISNULL(@deleted_deal,'n')='y'      
  SELECT @max_leg=max(leg),@buy_sell=max(buy_sell_flag),@option_flag=max(option_flag)       
  FROM delete_source_deal_detail sdd JOIN delete_source_deal_header sdh ON sdh.source_deal_header_id=sdd.source_deal_header_id      
  WHERE sdd.source_deal_header_id=@source_deal_header_id      
 ELSE      
  SELECT @max_leg=max(leg),@buy_sell=max(buy_sell_flag),@option_flag=max(option_flag)       
  FROM source_deal_detail sdd JOIN source_deal_header sdh ON sdh.source_deal_header_id=sdd.source_deal_header_id      
  WHERE sdd.source_deal_header_id=@source_deal_header_id      
      
 set @label_index='Index'      
 set @label_price='Price'      
 if @max_leg=1 and @buy_sell='b'      
 begin      
  set @label_index='Buy Index'      
  set @label_price='Sell Price'      
 end      
 else if @max_leg=1 and @buy_sell='s'      
 begin      
  set @label_index='Sell Index'      
  set @label_price='Buy Price'      
 end      
      
        
 DECLARE @term_label VARCHAR(20)      
       
       
 IF isnull(@deleted_deal,'n')='y'      
  SELECT       
   @term_label = CASE sdht.term_end_flag       
    WHEN 'y' THEN 'Term'       
    ELSE 'Term Start' END      
  FROM delete_source_deal_header sdh      
  LEFT outer JOIN source_deal_header_template sdht      
  ON  sdh.template_id = sdht.template_id      
  WHERE  sdh.source_deal_header_id = @source_deal_header_id       
 else      
  SELECT       
   @term_label = CASE sdht.term_end_flag       
    WHEN 'y' THEN 'Term'       
    ELSE 'Term Start' END      
  FROM source_deal_header sdh      
  LEFT outer JOIN source_deal_header_template sdht      
  ON  sdh.template_id = sdht.template_id      
  WHERE  sdh.source_deal_header_id = @source_deal_header_id       
       
 DECLARE @deal_volume_frequency_column VARCHAR(50)      
 IF @deal_volume_frequency IS NULL BEGIN      
  SET @deal_volume_frequency_column = 'deal_volume_frequency'                                       
    END ELSE BEGIN      
  SET @deal_volume_frequency_column = ''''+@deal_volume_frequency+''''      
    END      
         
 set @sql_select='      
  select       
   a.source_deal_detail_id,      
   CASE sdht.term_end_flag WHEN ''y'' THEN cast(datepart(YY,term_start)AS varchar)      
   else dbo.FNADateFormat(term_start) END ['+@term_label+'],       
   dbo.FNADateFormat(term_end) as TermEnd,      
   Leg,       
   case when sdt.expiration_applies =''y'' then dbo.FNADEALRECExpiration(a.source_deal_detail_id, contract_expiration_date, NULL)       
    else dbo.FNADateFormat(contract_expiration_date) end as ExpDate,      
   case when fixed_float_leg=''f'' then ''Fixed'' else ''Float'' End as [Fixed/Float],      
   case when a.buy_sell_flag =''b'' then ''Buy(Receive)'' else ''Sell(Pay)'' End as [Buy/Sell],      
   --pcd.curve_name curve_type,      
   -- sco.commodity_name as commodity,      
         
   CASE WHEN a.physical_financial_flag = ''p'' THEN ''Physical'' ELSE ''Financial'' END AS [Physical/Financial],      
   dbo.FNAHyperLinkText2(10102514,case when source_Major_Location.location_name is null then '''' else source_Major_Location.location_name + '' -> '' end + sml.location_name,''''''u'''''',cast(sml.source_minor_Location_Id as varchar)) AS Location,
   --case when source_Major_Location.location_name is null then '''' else source_Major_Location.location_name + '' -> '' end + sml.location_name AS Location,    
   --pcd.curve_name+ISNULL(''@@@''+dbo.FNAFormulaFormat(fe1.formula,''r''),'''') as  ['+@label_index+'],      
   dbo.FNAHyperLinkText2(10102610,pcd.curve_name+ISNULL(''@@@''+dbo.FNAFormulaFormat(fe1.formula,''r''),''''),CAST(pcd.source_curve_def_id AS VARCHAR),''''''u'''''') AS ['+@label_index+'], 
      --ROUND(dbo.FNARemoveTrailingZeroes(CAST(deal_volume AS numeric(38,20))),'+@round_value+') as Volume,
      dbo.FNAAddThousandSeparator(ROUND(CAST(deal_volume AS numeric(38,20)),'+@round_value+')) as Volume,
     
   CASE '+ @deal_volume_frequency_column + '      
     WHEN ''d'' THEN ''Daily''      
     WHEN ''m'' THEN ''Monthly''      
     WHEN ''h'' THEN ''Hourly''      
     WHEN ''w'' THEN ''Weekly''      
     WHEN ''q'' THEN ''Quarterly''      
     WHEN ''s'' THEN ''Semi-Annually''      
     WHEN ''a'' THEN ''Annually''      
     WHEN ''t'' THEN ''Term''      
   END as [Volume Frequency],      
            
   uom.uom_name as [Volume UOM],      
   --ROUND(dbo.FNARemoveTrailingZeroes(CAST(a.total_volume AS numeric(38,9))),'+@round_value+') AS [TotalVolume],
   dbo.FNAAddThousandSeparator(ROUND(CAST(a.total_volume AS numeric(38,9)),'+@round_value+')) AS [TotalVolume],
   su.uom_name as [Position UOM],       
   a.capacity as [Capacity],      
--   dbo.FNARemoveTrailingZeroes(a.fixed_price) Price,      
--   dbo.FNARemoveTrailingZeroes(CAST(a.fixed_price AS numeric(38,20))) as Price,      
   case  when sdt.expiration_applies =''y'' and      
   ( a.fixed_price is null and a.formula_id is null)  then       
    dbo.FNARemoveTrailingZeroes(CAST(rg.contract_price AS numeric(38,20))) else       
   --dbo.FNARemoveTrailingZeroes(CAST(fixed_price AS numeric(38,20))) end as Price,      
   -- dbo.FNARemoveTrailingZeroes(CAST(fixed_cost AS numeric(38,20))) AS [Fixed Cost],  
   dbo.FNAAddThousandSeparator(CAST(fixed_price AS numeric(38,20))) end as Price,      
    dbo.FNAAddThousandSeparator(CAST(fixed_cost AS numeric(38,20))) AS [Fixed Cost],      
    
   scfc.currency_name as [Fixed Cost Currency],      
    dbo.FNAFormulaFormat(fe.formula,''r'') as Formula,      
   scfr.currency_name as [Formula Currency],      
    '+CASE WHEN ISNULL(@option_flag,'n')='y' THEN ' dbo.FNARemoveTrailingZeroes(ROUND(Option_strike_Price,9))' ELSE 'NULL' END+' AS OptionStrike,      
   --round(price_adder,4) PriceAdder,      
   dbo.FNARemoveTrailingZeroes(price_adder) PriceAdder,        
   scpa.currency_name as [Adder Currency],       
   dbo.FNARemoveTrailingZeroes(ISNULL(multiplier,1)) [Volume Multiplier],      
   dbo.FNARemoveTrailingZeroes(ISNULL(price_multiplier,1)) [Price Multiplier],      
    sc.currency_name as [Price Currency],      
    dbo.FNARemoveTrailingZeroes(price_adder2) PriceAdder2,        
   scpa1.currency_name as [Adder Currency2],      
   dbo.FNARemoveTrailingZeroes(ISNULL(volume_multiplier2,1)) [Volume Multiplier2],       
    mi.recorderid AS [Meter],      
    upper(a.pay_opposite) as [PayOpposite],      
    ISNULL(dbo.FNADateFormat(a.settlement_date),dbo.FNADateFormat(contract_expiration_date)) [Payment Date],      
    case  when sdt.expiration_applies =''y'' then      
   cast(dbo.FNARECBonus(h.source_deal_header_id) as varchar)  else       
   block_description end as Bonus,      
   sdv.code [Day Count],      
   sml.source_minor_location_id,      
   a.curve_id,      
   setcur.currency_name as [Sett.Currency],      
   a.standard_yearly_volume AS [SYV] ,
	CASE 
		   WHEN a.standard_yearly_volume IS NOT NULL AND ISNULL(sml.calculation_method,''t'') = ''p'' AND ISNULL(pcd.curve_tou,18900) = 18901 THEN ''Offpeak''
		   WHEN a.standard_yearly_volume IS NOT NULL AND ISNULL(sml.calculation_method,''t'') = ''p'' AND ISNULL(pcd.curve_tou,18900) = 18900 THEN ''Peak''
		   WHEN a.standard_yearly_volume IS NOT NULL AND ISNULL(sml.calculation_method,''t'') = ''t'' THEN ''Total''
		   ELSE ''''
	  END AS [TOU SYV],
    pu.uom_name [Price UOM],
    sdvc.code Category,
    sdvp.Code Profile,
    sdvpv.code [PR Party]
        
  from ' +CASE WHEN isnull(@deleted_deal,'n')='y' then  'delete_source_deal_detail' ELSE 'source_deal_detail' END +' a join      
  ' +CASE WHEN isnull(@deleted_deal,'n')='y' then  'delete_source_deal_header' ELSE 'source_deal_header' END +' h on      
  a.source_deal_header_id=h.source_deal_header_id join      
  source_deal_type sdt on sdt.source_deal_type_id=h.source_deal_type_id       
  left outer join source_price_curve_def pcd on pcd.source_curve_def_id=a.curve_id       
  left outer join rec_generator rg on rg.generator_id=h.generator_id      
  left outer join formula_editor fe on fe.formula_id=a.formula_id      
  left outer join source_commodity sco on sco.source_commodity_id=pcd.commodity_id      
  left outer join source_currency sc on sc.source_currency_id=a.fixed_price_currency_id      
  left outer join source_uom uom on uom.source_uom_id=a.deal_volume_uom_id       
  left outer join static_data_value sdv on sdv.value_id=a.day_count_id      
  LEFT OUTER JOIN source_minor_location sml ON sml.source_minor_location_id = a.location_id       
  LEFT OUTER JOIN meter_id mi ON mi.meter_id = a.meter_id      
  LEFT OUTER JOIN source_deal_header_template sdht on sdht.template_id=h.template_id       
  LEFT OUTER JOIN source_currency scfc on scfc.source_currency_id=a.fixed_cost_currency_id      
  LEFT OUTER JOIN source_currency scfr on scfr.source_currency_id=a.formula_currency_id      
  LEFT OUTER JOIN source_currency scpa on scpa.source_currency_id=a.adder_currency_id      
  LEFT OUTER JOIN source_currency scpa1 on scpa1.source_currency_id=a.price_adder_currency2      
  LEFT OUTER JOIN formula_editor fe1 on fe1.formula_id=pcd.formula_id      
  LEFT OUTER JOIN source_currency setcur on setcur.source_currency_id=a.settlement_currency      
  LEFT JOIN source_Major_Location ON sml.source_Major_Location_Id = source_Major_Location.source_major_location_ID
  LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = a.curve_id
  LEFT JOIN source_uom su ON ISNULL(spcd.display_uom_id,spcd.uom_id) = su.source_uom_id   
  	LEFT JOIN source_uom pu ON a.price_uom_id = pu.source_uom_id  
	LEFT OUTER JOIN static_data_value sdvc on sdvc.value_id=a.category
	LEFT OUTER JOIN static_data_value sdvpv on sdvpv.value_id=a.pv_party
	LEFT OUTER JOIN static_data_value sdvp on sdvp.value_id=a.profile_code  
  where a.source_deal_header_id='+cast(@source_deal_header_id as varchar)      
  if @term_start is not null      
  set @sql_select= @sql_select+ ' And term_start='''+@term_start+''''      
       
  if @term_start is not null      
  set @sql_select= @sql_select +' And term_end='''+@term_end+''''      
        
  set @sql_select= @sql_select+ ' order by term_start,leg '      
        
      
  EXEC spa_print @sql_select      
      
  exec(@sql_select)      
      
 End      
      
else if @flag='e' -- Export from TOOL BAR EDIT GRID (Deal Detail      
 Begin      
      
 -- Check if leg 1      
       
 SELECT @max_leg = MAX(leg), @buy_sell = MAX(buy_sell_flag) FROM source_deal_detail       
  WHERE source_deal_header_id=@source_deal_header_id      
 SET @label_index='Index'      
 SET @label_price='Price'      
 IF @max_leg=1 and @buy_sell='b'      
 BEGIN      
  SET @label_index='Buy Index'      
  SET @label_price='Price'      
 END      
 ELSE IF @max_leg=1 and @buy_sell='s'      
 BEGIN      
  SET @label_index='Sell Index'      
  SET @label_price='Price'      
 END      
 DECLARE @sql_Select2 VARCHAR(MAX)
      
 SET @sql_select='SELECT [ID],
                         [TermStart] AS [Term Start],
                         [TermEnd] AS [Term End],
                         [Leg],
                         [ExpDate] AS [Expiration Date],
                         [FixedFloat] AS [FixedFloat],
                         [BuySell],
                         [curve_type] AS [Curve Type],
                         [commodity] AS [Commodity],
                         [Physical/Financial] AS [PhysicalFinancial],
                         [Location],
                         ['+@label_index+'],
                         [Volume],
                         [Frequency],
                         [UOM],
                         [TotalVolume],
                         [Position UOM],
                         [Capacity],
                         ['+@label_price+'],
                         [Fixed Cost],
                         [Fixed Cost Currency],
                         [Formula Price],
                         [Formula Currency],
                         [OptionStrike] AS [OptStrikePrice],
                         [PriceAdder],
                         [Adder Currency],
                         VolumeMultiplier,
                         [PriceMultiplier],
                         [Currency],
                         [PriceAdder2],
                         [AdderCurrency2],
                         VolumeMultiplier2,
                         [Meter],
                         [Pay Opposite],
                         [Payment Date],
                         [Formula],
                         [Sett.Currency],
                         SYV,
                         [TOU SYV],
                        [Price UOM],
                        Category,
                        PROFILE ,
                        [PR Party]      
					 FROM(SELECT DISTINCT a.source_deal_detail_id AS [ID],      
						dbo.FNADateFormat(term_start) AS TermStart,      
						dbo.FNADateFormat(term_end) AS TermEnd,      
						Leg,       
						CASE WHEN sdt.expiration_applies =''y'' THEN dbo.FNADEALRECExpiration(a.source_deal_detail_id, contract_expiration_date, NULL)       
						 ELSE dbo.FNADateFormat(contract_expiration_date) END AS ExpDate,      
						CASE WHEN fixed_float_leg=''f'' THEN ''Fixed'' else ''Float'' END as FixedFloat,     
						CASE WHEN buy_sell_flag =''b'' THEN ''Buy(Receive)'' else ''Sell(Pay)'' End as BuySell,      
						--pcd.source_curve_type_value_id curve_type,        
						--pcd.curve_name curve_type,       
						sdv2.code curve_type,      
						sco.commodity_name  AS commodity,      
						a.physical_financial_flag AS [Physical/Financial],      
						sml.location_name as Location,      
						pcd.curve_name as ['+@label_index+'],      
						--ROUND(dbo.FNARemoveTrailingZeroes(CAST(deal_volume AS numeric(38,9))),'+@round_value+') as Volume,
						dbo.FNAAddThousandSeparator(ROUND(CAST(deal_volume AS numeric(38,20)),'+@round_value+')) as Volume,
						CASE WHEN deal_volume_frequency=''d'' THEN ''Daily''      
						 WHEN deal_volume_frequency=''m'' THEN ''Monthly''      
						 WHEN deal_volume_frequency=''h'' THEN ''Hourly''      
						 WHEN deal_volume_frequency=''w'' THEN ''Weekly''      
						 WHEN deal_volume_frequency=''q'' THEN ''Quarterly''      
						 WHEN deal_volume_frequency=''s'' THEN ''Semi-Annually''      
						 WHEN deal_volume_frequency=''a'' THEN ''Annually''      
						 WHEN deal_volume_frequency=''t'' THEN ''Term''      
					   END as [Frequency],      
						--deal_volume_frequency as Frequency,      
						uom.uom_name as UOM,      
						--ROUND(dbo.FNARemoveTrailingZeroes(CAST(a.total_volume AS numeric(38,9))),'+@round_value+') as [TotalVolume],
						dbo.FNAAddThousandSeparator(ROUND(CAST(a.total_volume AS numeric(38,9)),'+@round_value+')) AS [TotalVolume],
						su.uom_name as [Position UOM],          
						dbo.FNARemoveTrailingZeroes(a.capacity) as Capacity,      
						CASE WHEN sdt.expiration_applies =''y'' AND ( a.fixed_price is null and a.formula_id is null)  THEN       
						 dbo.FNARemoveTrailingZeroes(rg.contract_price)       
						ELSE       
						--dbo.FNARemoveTrailingZeroes(fixed_price) end as ['+@label_price+'],      
						--dbo.FNARemoveTrailingZeroes(fixed_cost) AS [Fixed Cost],  
						dbo.FNAAddThousandSeparator(CAST(fixed_price AS numeric(38,20))) end as Price,      
						dbo.FNAAddThousandSeparator(CAST(fixed_cost AS numeric(38,20))) AS [Fixed Cost],      
					        
						scfc.currency_name as [Fixed Cost Currency],      
						dbo.FNARemoveTrailingZeroes(ROUND(CASE WHEN sdt.expiration_applies =''y'' AND (a.fixed_price is null AND a.formula_id is null)       
						 THEN rg.contract_formula_id ELSE a.formula_id end,9)) AS [Formula Price],      
						scfr.currency_name as [Formula Currency],      
						dbo.FNARemoveTrailingZeroes(option_strike_price) as OptionStrike,      
						dbo.FNARemoveTrailingZeroes(price_adder) PriceAdder,      
						scpa.currency_name as [Adder Currency],      
						dbo.FNARemoveTrailingZeroes(ISNULL(multiplier,1)) VolumeMultiplier,      
						dbo.FNARemoveTrailingZeroes(ISNULL(price_multiplier,1)) PriceMultiplier,      
						sc.currency_name as Currency,      
						dbo.FNARemoveTrailingZeroes(price_adder2) PriceAdder2,      
						scpa1.currency_name as [AdderCurrency2],      
						dbo.FNARemoveTrailingZeroes(ISNULL(volume_multiplier2,1)) VolumeMultiplier2,      
						mi.recorderid AS [Meter],      
						upper(a.pay_opposite) as [Pay Opposite],      
						ISNULL(dbo.FNADateFormat(a.settlement_date),dbo.FNADateFormat(contract_expiration_date)) [Payment Date],      
						CASE WHEN sdt.expiration_applies =''y'' THEN CAST(dbo.FNARECBonus(h.source_deal_header_id) AS VARCHAR) ELSE block_description END AS Bonus,      
						deal_detail_description as HourEnding,      
						dbo.FNAFormulaFormat(fe.formula,''r'') AS Formula,      
						sdv.code as [Day Count] ,      
						setcur.currency_name as [Sett.Currency],      
						a.standard_yearly_volume AS [SYV],
						CASE 
                               WHEN a.standard_yearly_volume IS NOT NULL AND ISNULL(sml.calculation_method,''t'') = ''p'' AND ISNULL(pcd.curve_tou,18900) = 18901 THEN ''Offpeak''
                               WHEN a.standard_yearly_volume IS NOT NULL AND ISNULL(sml.calculation_method,''t'') = ''p'' AND ISNULL(pcd.curve_tou,18900) = 18900 THEN ''Peak''
                               WHEN a.standard_yearly_volume IS NOT NULL AND ISNULL(sml.calculation_method,''t'') = ''t'' THEN ''Total''
                               ELSE ''''
                          END AS [TOU SYV],
						pu.uom_name [Price UOM],
						sdvc.code Category,
						sdvp.Code Profile,
						sdvpv.code [PR Party]'
						
set @sql_Select2 =  ' FROM ' +CASE WHEN isnull(@deleted_deal,'n')='y' then  'delete_source_deal_detail' ELSE 'source_deal_detail' END +' a       
     JOIN ' +CASE WHEN isnull(@deleted_deal,'n')='y' then  'delete_source_deal_header' ELSE 'source_deal_header' END +' h on a.source_deal_header_id=h.source_deal_header_id       
     JOIN source_deal_type sdt on sdt.source_deal_type_id=h.source_deal_type_id       
     LEFT OUTER JOIN source_price_curve_def pcd on pcd.source_curve_def_id=a.curve_id       
     LEFT OUTER JOIN rec_generator rg on rg.generator_id=h.generator_id      
     LEFT OUTER JOIN formula_editor fe on fe.formula_id=a.formula_id      
     LEFT OUTER JOIN source_currency sc on sc.source_currency_id=a.fixed_price_currency_id      
     LEFT OUTER JOIN source_commodity sco on sco.source_commodity_id=pcd.commodity_id      
     LEFT OUTER JOIN source_uom uom on uom.source_uom_id=a.deal_volume_uom_id      
     LEFT OUTER JOIN source_minor_location sml ON sml.source_minor_location_id = a.location_id       
     LEFT OUTER JOIN meter_id mi ON mi.meter_id = a.meter_id      
     LEFT OUTER JOIN static_data_value sdv on sdv.value_id=a.day_count_id      
     LEFT JOIN static_data_value sdv2 ON pcd.source_curve_type_value_id = sdv2.value_id      
     LEFT OUTER JOIN source_currency scfc on scfc.source_currency_id=a.fixed_cost_currency_id      
     LEFT OUTER JOIN source_currency scfr on scfr.source_currency_id=a.formula_currency_id      
     LEFT OUTER JOIN source_currency scpa on scpa.source_currency_id=a.adder_currency_id      
     LEFT OUTER JOIN source_currency scpa1 on scpa1.source_currency_id=a.price_adder_currency2      
     LEFT OUTER JOIN source_currency setcur on setcur.source_currency_id=a.settlement_currency 
	LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = a.curve_id
	LEFT JOIN source_uom su ON ISNULL(spcd.display_uom_id,spcd.uom_id) = su.source_uom_id    
	LEFT JOIN source_uom pu ON a.price_uom_id = pu.source_uom_id  
	LEFT OUTER JOIN static_data_value sdvc on sdvc.value_id=a.category
	LEFT OUTER JOIN static_data_value sdvpv on sdvpv.value_id=a.pv_party
	LEFT OUTER JOIN static_data_value sdvp on sdvp.value_id=a.profile_code    
    WHERE a.source_deal_header_id='+ CAST(@source_deal_header_id AS VARCHAR)      
      
 IF @term_start IS NOT NULL      
 SET @sql_select2= @sql_select2+ ' AND term_start='''+@term_start+''''      
      
 IF @term_start IS NOT NULL      
 SET @sql_select2= @sql_select2 +' AND term_end='''+@term_end+''''      
       
 SET @sql_select2= @sql_select2+ ')aa ORDER BY id ASC'      
       
 EXEC spa_print @sql_select, @sql_select2      
 EXEC(@sql_select + @sql_select2)      
End      
--       
-- else if @flag='b'      
--  Begin      
--        
--  set @sql_select='select * into '+@tempheadertable+' from source_deal_header where source_deal_header_id='+cast(@source_deal_header_id as varchar)      
--  exec(@sql_select)      
--        
--  set @sql_select='select * into '+@tempdetailtable+' from source_deal_detail where source_deal_header_id='+cast(@source_deal_header_id as varchar)      
--  EXEC spa_print @sql_select      
--  exec(@sql_select)      
--        
--  If @@ERROR <> 0      
--       
--   Exec spa_ErrorHandler @@ERROR, 'Source Deal Detail  table',       
--       
--     'spa_sourcedealdetail', 'DB Error',       
--       
--     'Failed updating record.',@process_id      
--       
--       
--   Else      
--       
--   Exec spa_ErrorHandler 0, 'Source Deal Header  table',       
--       
--     'spa_sourcedealdetail', 'Success',       
--       
--     'Source deal detail  record successfully updated.',@process_id      
--       
-- End      
else if @flag='f' -- COPY Deal      
Begin      
 declare @copy_source_deal_id int      
       
       
 select @new_deal_id=cast(@source_deal_header_id as varchar)+'_Pawan' + case when count(deal_id) > 0 then cast(count(deal_id)+1 as varchar)      
 else '' end from source_deal_header      
 where deal_id=cast(@source_deal_header_id as varchar)+'_Pawan'      
      
      
      
 begin tran      
 insert into source_deal_header(source_system_id, deal_id, deal_date, ext_deal_id, physical_financial_flag, structured_deal_id, counterparty_id, entire_term_start, entire_term_end,       
                      source_deal_type_id, deal_sub_type_type_id, option_flag, option_type, option_excercise_type, source_system_book_id1, source_system_book_id2,       
                      source_system_book_id3, source_system_book_id4, description1, description2, description3, deal_category_value_id, trader_id,       
                      internal_deal_type_value_id, internal_deal_subtype_value_id, template_id, header_buy_sell_flag, broker_id, generator_id, status_value_id,       
                      status_date, assignment_type_value_id, compliance_year, state_value_id, assigned_date, assigned_by, generation_source, aggregate_environment,       
                      aggregate_envrionment_comment, rec_price, rec_formula_id, rolling_avg,pricing,deal_status,option_settlement_date)      
 select   source_system_id, @new_deal_id, deal_date, ext_deal_id, physical_financial_flag, structured_deal_id, counterparty_id, entire_term_start, entire_term_end,       
                      source_deal_type_id, deal_sub_type_type_id, option_flag, option_type, option_excercise_type, source_system_book_id1, source_system_book_id2,       
                      source_system_book_id3, source_system_book_id4, description1, description2, description3, deal_category_value_id, trader_id,       
                      internal_deal_type_value_id, internal_deal_subtype_value_id, template_id, header_buy_sell_flag, broker_id, generator_id, status_value_id,       
                      status_date, assignment_type_value_id, compliance_year, state_value_id, assigned_date, assigned_by, generation_source, aggregate_environment,       
                      aggregate_envrionment_comment, rec_price, rec_formula_id, rolling_avg,pricing,deal_status,option_settlement_date      
 from source_deal_header where source_deal_header_id=@source_deal_header_id      
 set @copy_source_deal_id=SCOPE_IDENTITY()      
       
  EXEC spa_compliance_workflow 109,'i',@copy_source_deal_id,'Deal',null      
      
  insert  into source_deal_detail (source_deal_header_id,      
      term_start,      
      term_end,      
      leg,      
      contract_expiration_date,      
      fixed_float_leg,      
      buy_sell_flag,      
      curve_id,      
      fixed_price,      
      fixed_price_currency_id,      
      option_strike_price,      
      deal_volume,      
      deal_volume_frequency,      
      deal_volume_uom_id,      
      block_description,      
      deal_detail_description,formula_id      
      ,price_adder,      
   price_multiplier,
   settlement_currency,
   standard_yearly_volume,
   price_uom_id,
   category,
   pv_party,
   profile_code
   )      
    select @copy_source_deal_id,      
      term_start,      
      term_end,      
      leg,      
      contract_expiration_date,      
      fixed_float_leg,      
      buy_sell_flag,      
      curve_id,      
      fixed_price,      
      fixed_price_currency_id,      
      option_strike_price,      
      deal_volume,      
      deal_volume_frequency,      
      deal_volume_uom_id,      
      block_description,      
      deal_detail_description,formula_id,price_adder,      
	   price_multiplier ,
	   settlement_currency,
	   standard_yearly_volume,
      price_uom_id,
   category,
   pv_party,
   profile_code     
       from source_deal_detail       
      where source_deal_header_id=@source_deal_header_id      
       
   If @@ERROR <> 0      
 Begin      
   Exec spa_ErrorHandler @@ERROR, 'Source Deal Header  table',       
       
     'spa_sourcedealheader', 'DB Error',       
       
     'Failed copying record.', ''      
   Rollback Tran      
   End      
   Else      
   Begin      
      
    Exec spa_ErrorHandler 0, 'Source Deal Header  table',       
        
      'spa_sourcedealheader', 'Success',       
        
      '', @copy_source_deal_id      
    Commit Tran      
   End      
       
        
End      
else if @flag='e'      
 Begin      
  set @sql_select='insert into '+@tempdetailtable+' (source_deal_header_id,      
  term_start,      
  term_end,      
  leg,      
  contract_expiration_date,      
  fixed_float_leg,      
  buy_sell_flag,      
  curve_id,      
  dbo.FNARemoveTrailingZeroes(fixed_price)) fixed_price,      
  fixed_price_currency_id,      
  dbo.FNARemoveTrailingZeroes(option_strike_price) option_strike_price,      
  dbo.FNARemoveTrailingZeroes(deal_volume),      
  deal_volume_frequency,      
  deal_volume_uom_id,      
  block_description,      
  deal_detail_description)      
  select source_deal_header_id,      
  dateadd(month,1,term_start),      
  dbo.FNALastDayInDate(dateadd(month,1,term_end)),      
  leg,      
  dbo.FNALastDayInDate(dateadd(month,1,term_end)),      
  fixed_float_leg,      
  buy_sell_flag,      
  curve_id,      
  dbo.FNARemoveTrailingZeroes(fixed_price),      
  fixed_price_currency_id,      
  dbo.FNARemoveTrailingZeroes(option_strike_price),      
  dbo.FNARemoveTrailingZeroes(deal_volume)      
  deal_volume_frequency,      
  deal_volume_uom_id,      
  block_description,      
  deal_detail_description from '+@tempdetailtable+'      
  where term_start=(select max(term_start) from '+@tempdetailtable+' where source_deal_header_id='+cast(@source_deal_header_id as varchar)+') and      
  term_end=(select max(term_end) from '+@tempdetailtable+' where source_deal_header_id='+cast(@source_deal_header_id as varchar)+')       
  and source_deal_header_id='+cast(@source_deal_header_id as varchar)      
       
      
  Exec(@sql_select)      
  If @@ERROR <> 0      
  Begin        
      
  Exec spa_ErrorHandler @@ERROR, 'Source Deal Detail  table',       
      
    'spa_sourcedealdetail', 'DB Error',       
      
    'Failed inserting record.', ''      
  End      
  Else      
  Begin      
         
           
   set @sql_select='Declare @term_end_value varchar(10)      
   select @term_end_value=(select dbo.FNACovertToSTDDate(max(term_end)) from       
   '+@tempdetailtable+' where source_deal_header_id='+cast(@source_deal_header_id as varchar)+')      
   update '+@tempheadertable+' set entire_term_end=@term_end_value where      
   source_deal_header_id='+cast(@source_deal_header_id as varchar)+'      
   set @term_end_value=dbo.FNADateFormat(@term_end_value)         
   Exec spa_ErrorHandler 0, ''Source Deal Header  table'',       
   ''spa_sourcedealdetail'', ''Success'',@term_end_value,''''      
   EXEC spa_print @term_end_value '      
   Exec(@sql_select)   
  End      
 End       
else if @flag='t'      
begin      
 SELECT @max_leg=MAX(leg),@buy_sell=MAX(buy_sell_flag) FROM source_deal_detail_template WHERE template_id=@template_id      
 SET @label_index='Index'      
 SET @label_price='Price'      
 IF @max_leg=1 AND @buy_sell='b'      
 BEGIN      
  SET @label_index='Buy Index'      
  SET @label_price='Price'      
 END      
 ELSE IF @max_leg=1 AND @buy_sell='s'      
 BEGIN      
  SET @label_index='Sell Index'      
  SET @label_price='Price'      
 END      
      
 set @sql_select='      
  select       
   '''+ dbo.FNADateFormat(@entire_term_start) +''' TermStart,       
   '''+ dbo.FNADateFormat(@entire_term_end) +''' TermEnd,      
   Leg,      
   case when fixed_float_leg=''f'' then ''Fixed'' else ''Float'' end [Fixed/Float],      
   case when buy_sell_flag =''b''  then ''Buy(Receive)'' else ''Sell(Pay)'' End [Buy/Sell],      
   curve_type,      
   commodity_id,      
   CASE WHEN       
    physical_financial_flag = ''p'' THEN ''Physical''      
   ELSE ''Financial'' END [Physical/Financial],      
   location_id [Location],      
   curve_id as ['+@label_index +'],      
   null Volume,      
   deal_volume_frequency [Volume Frequency],      
   deal_volume_uom_id [Volume UOM],      
   null as Capacity,      
   null as ['+@label_price +'],      
   null as [Fixed Cost],      
   null as [Fixed Cost Currency],      
   formula Formula,      
   null as [Formula Currency],      
   null [Opt.StrikePrice],      
   NULL [Price Adder],      
   null as [Adder Currency],       
   null [Volume Multiplier],      
   null [Price Multiplier],      
   currency_id Currency,      
   null as [Price Adder2],      
   null as [Price Adder Currency 2],      
   null as [Volume Multiplier 2],      
   meter_id [Meter],      
   upper(pay_opposite) as [Pay Opposite],      
   day_count [Day Count],      
   strip_months_from [StripMonthFrom],      
   lag_months [LagMonths],      
   strip_months_to [StripMonthTo],      
   conversion_factor [ConvFactor],      
   curve_type [CurveType],      
   NULL as LocationName,      
   NULL as CurveName ,    
   settlement_currency as [Sett.Currency],      
   standard_yearly_volume as [SYV] ,
   price_uom_id [PriceUOM],
   category Category,
   profile_code ProfileCode,
   pv_party [PR Party]   
   from source_deal_detail_template 
  where template_id='+cast(@template_id as varchar)      
        
 EXEC spa_print @sql_Select      
 exec(@sql_select)      
      
       
end      
--else if @flag='c' -- copy deal detail ////bka      
--begin      
--      
--declare @bif_leg int      
--      
--select @max_leg=max(leg),@deal_volume=sum(deal_volume)/max(leg) from source_deal_detail       
--  where source_deal_header_id=@source_deal_header_id      
--select @bif_leg=leg from source_deal_detail where source_deal_detail_id=@source_deal_detail_id      
--      
--set @sql_select='      
--select dbo.FNADateFormat(min(sdd.term_start)) AS TermStart,       
--  dbo.FNADateFormat(max(sdd.term_end)) AS TermEnd,'+      
--  case when @source_deal_detail_id is not null then ' 1 ' else ' sdd.Leg ' end+      
--' AS Leg,      
--case when buy_sell_flag =''b''       
-- then ''Buy(Receive)'' else ''Sell(Pay)'' End BuySell,      
--max(pcd.source_curve_type_value_id) curve_type,max(pcd.commodity_id) commodity_id,      
-- max(sdd.curve_id) [Index],max(deal_volume) AS Volume,      
--max(deal_volume_frequency) Frequency,      
--max(deal_volume_uom_id) UOM,      
--avg(sdd.fixed_price) as Price,      
----cast(round(avg(sdd.fixed_price), 2) as varchar) as Price,      
--max(fixed_price_currency_id) Currency,max(option_strike_price) [Opt.StrikePrice],      
-- null Formula,      
--max((case sdd.fixed_float_leg when ''f'' then ''Fixed'' Else ''Float'' end)) AS FixedFloat,      
--max(day_count_id) day_count_id,max(price_adder) price_adder, max(ISNULL(price_multiplier,1)) price_multiplier,      
--CASE WHEN       
--   max(physical_financial_flag) = ''p'' THEN ''Physical''      
--  ELSE      
--   ''Financial''      
--END AS [Physical/Financial],      
--      
--max(location_id) Location ,      
--max(meter_id) Meter      
--from       
-- source_deal_detail sdd left outer join       
--source_price_curve_def pcd on pcd.source_curve_def_id=sdd.curve_id        
--where source_deal_header_id='+cast(@source_deal_header_id as varchar)      
--+ case when @source_deal_detail_id is not null then ' And leg='+cast(@bif_leg as varchar) else '' end +      
--' group by Leg,buy_sell_flag order by leg '      
--      
--print @sql_select      
--exec(@sql_select)      
--end      
      
else if @flag='c' -- copy deal detail ////bka      
begin      
      
declare @bif_leg int      
      
select @max_leg=max(leg),@deal_volume=sum(deal_volume)/max(leg) from source_deal_detail       
  where source_deal_header_id=@source_deal_header_id      
select @bif_leg=leg from source_deal_detail where source_deal_detail_id=@source_deal_detail_id      
      
set @sql_select='      
select       
 dbo.FNADateFormat(min(sdd.term_start)) AS [Term Start],       
 dbo.FNADateFormat(max(sdd.term_end)) AS [Term End],      
 '+case when @source_deal_detail_id is not null then ' 1 ' else ' sdd.Leg ' end+' AS Leg,      
 max((case sdd.fixed_float_leg when ''f'' then ''Fixed'' Else ''Float'' end)) AS [Fixed/Float],      
 max(case when buy_sell_flag =''b'' then ''Buy(Receive)'' else ''Sell(Pay)'' End) [Buy/Sell],      
       
 max(pcd.source_curve_type_value_id) curve_type,max(pcd.commodity_id) commodity_id,      
 CASE WHEN max(physical_financial_flag) = ''p'' THEN ''Physical'' ELSE ''Financial'' END AS [Physical/Financial],      
 max(sdd.location_id) Location,      
 max(sdd.curve_id) [Index],      
 dbo.FNARemoveTrailingZeroes(max(deal_volume)) AS Volume,      
 max(deal_volume_frequency) Frequency,      
 max(deal_volume_uom_id) UOM,      
 --dbo.FNARemoveTrailingZeroes(MAX(ISNULL(capacity, 1)))      
 NULL [Capacity],      
 --dbo.FNARemoveTrailingZeroes(avg(sdd.fixed_price)) as Price,      
 NULL [Price],      
 --cast(round(avg(sdd.fixed_price), 2) as varchar) as Price,      
 --dbo.FNARemoveTrailingZeroes(max(fixed_cost))       
 NULL [Fixed Cost],      
 max(fixed_cost_currency_id) [Fixed Cost Currency],      
 max(sdd.formula_id) [Formula],      
 max(formula_currency_id) [Formula Currency],      
 --dbo.FNARemoveTrailingZeroes(max(option_strike_price))      
 NULL [Opt. Strike Price],      
 --dbo.FNARemoveTrailingZeroes(max(price_adder))      
 NULL [Price Adder],       
 max(adder_currency_id) [Adder Currency],      
 --dbo.FNARemoveTrailingZeroes(max(ISNULL(multiplier,1)))      
 NULL [Volume Multiplier],      
 --dbo.FNARemoveTrailingZeroes(max(ISNULL(price_multiplier,1))) [Price Multiplier],      
 NULL  [Price Multiplier],      
 max(fixed_price_currency_id) [Price Currency],      
 --dbo.FNARemoveTrailingZeroes(MAX(price_adder2))      
 NULL [Price Adder2],      
    MAX(price_adder_currency2) [Adder Currency2],      
    --dbo.FNARemoveTrailingZeroes(MAX(ISNULL(volume_multiplier2, 1)))      
    NULL [Volume Multiplier2],      
 max(sdd.meter_id) Meter,      
 max(sdd.pay_opposite) as [Pay Opposite],      
 -- Strip Month From      
 -- Lag Months      
 -- Strip Month To      
 max(day_count_id) [Day Count],      
 MAX(sml.location_name) LocationName,      
 MAX(pcd.curve_name) [Curve Name],  
 max(sdd.settlement_currency) as [Sett.Currency],      
 NULL  AS [SYV], --max(sdd.standard_yearly_volume) AS [SYV],
 max(price_uom_id) as [Price UOM],
max(category) Category, 
max(sdd.profile_code) as [Profile Code],
max(pv_party) [PR Party] 
,MAX(formula_curve_id) formula_curve_id
,MAX(fe.formula) formula_string
from       
 source_deal_detail sdd left outer join       
source_price_curve_def pcd on pcd.source_curve_def_id=sdd.curve_id
LEFT JOIN formula_editor fe ON fe.formula_id = sdd.formula_id  
LEFT JOIN source_minor_location sml ON sml.source_minor_location_id = sdd.location_id      
where source_deal_header_id='+cast(@source_deal_header_id as varchar)      
+ case when @source_deal_detail_id is not null then ' And leg='+cast(@bif_leg as varchar) else '' end +      
' group by Leg order by leg '      
      
      
EXEC spa_print @sql_select      
exec(@sql_select)      
END      
      
      
else if @flag='m' -- copy deal detail from post tool bar////bka COPY deals for EFP      
--Print 'I M HERE'      
begin      
Declare @deal_name_temp as varchar(200)      
DECLARE @tmp_source_deal_type_id1 int      
DECLARE @tmp_deal_sub_type_type_id1 int      
DECLARE @temp_status as varchar(200)      
DECLARE @tmp_template_id int      
DECLARE @ref_id as varchar(2000)      
DECLARE @tmp_vol as int      
DECLARE @buy_sell_tmp as varchar(10)      
DECLARE @curve_id_tmp as int      
      
      
 if @internal_deal_subtype_value_id='9'      
        set @deal_name_temp='_EFP'      
    else if @internal_deal_subtype_value_id='10'      
   set @deal_name_temp='_Trigger'      
      
   SELECT @tmp_source_deal_type_id1=deal_type_id,@tmp_deal_sub_type_type_id1=deal_sub_type_id ,@tmp_template_id=template_id      
      FROM default_deal_post_values       
      WHERE internal_deal_type_subtype_id=@internal_deal_subtype_value_id       
      
 select @temp_status=process_deal_status  from source_deal_header sdh      
 INNER JOIN [source_deal_detail] sdd on sdd.source_deal_header_id=sdh.source_deal_header_id      
 where sdh.source_deal_header_id = cast(@source_deal_header_id as varchar)       
--and internal_deal_type_subtype_id=@internal_deal_subtype_value_id       
 EXEC spa_print @temp_status      
      
   if @temp_status is null OR @temp_status <>12505      
    BEGIN      
      
  select @new_deal_id=cast(@source_deal_header_id as varchar)+@deal_name_temp + case when count(deal_id) > 0 then cast(count(deal_id)+1 as varchar)      
  else '' end from source_deal_header      
  where deal_id=cast(@source_deal_header_id as varchar)+@deal_name_temp      
          
        
   begin tran      
   declare @new_source_deal_id int      
         
         
          
      
      
 set  @ref_id=cast(isNUll(IDENT_CURRENT('source_deal_header')+1,1) as varchar)+'-farrms'      
      
     INSERT INTO [dbo].[source_deal_header] (      
   [source_system_id]      
           ,[deal_id]      
           ,[deal_date]      
           ,[physical_financial_flag]      
           ,[counterparty_id] ---????????      
           ,[entire_term_start]      
           ,[entire_term_end]      
     ,[header_buy_sell_flag]      
           ,[source_deal_type_id]      
           ,[deal_sub_type_type_id]      
           ,[option_flag]      
           ,[option_type]      
           ,[source_system_book_id1]      
           ,[source_system_book_id2]      
           ,[source_system_book_id3]      
           ,[source_system_book_id4]      
           ,[description1]      
           ,[description2]      
           ,[description3]      
           ,[deal_category_value_id]       
           ,[trader_id]      
           ,[internal_deal_type_value_id]      
           ,[internal_deal_subtype_value_id]      
           ,[template_id]      
         ,broker_id      
           ,[create_user]      
           ,[create_ts]      
           ,[update_user]      
           ,[update_ts]      
   ,contract_id,deal_reference_type_id,[close_reference_id]      
         
 )      
     select      
           2      
           ,@new_deal_id      
           ,sdh.deal_date      
           ,t.physical_financial_flag      
           ,@counterparty_id      
           ,sdh.entire_term_start      
           ,sdh.entire_term_end      
           ,CASE       
    WHEN @internal_deal_subtype_value_id='9'      
    THEN      
     CASE      
      WHEN sdh.header_buy_sell_flag ='b'      
      then 's' else 'b'      
     END       
        
    WHEN @internal_deal_subtype_value_id='10'      
    THEN      
     CASE      
      WHEN sdh.header_buy_sell_flag ='b'      
      then 'b' else 's'      
     END       
   End       
         
     ,@tmp_source_deal_type_id1      
           ,@tmp_deal_sub_type_type_id1      
           ,t.option_flag      
           ,t.option_type      
           ,sdh.source_system_book_id1      
           ,sdh.source_system_book_id2      
           ,sdh.source_system_book_id3      
           ,sdh.source_system_book_id4      
           ,t.description1      
           ,t.description2      
           ,t.description3      
           ,475      
           ,@trader_id      
           ,t.internal_deal_type_value_id      
           ,t.internal_deal_subtype_value_id      
           ,@tmp_template_id              
           ,@broker_id      
           ,dbo.fnadbuser()      
           ,getdate()      
           ,dbo.fnadbuser()      
           ,getdate()      
   ,sdh.contract_id,12505,sdh.source_deal_header_id      
 from [dbo].[source_deal_header_template] t       
 inner join source_deal_header sdh  on  sdh.source_deal_header_id=@source_deal_header_id      
    where t.template_id=@tmp_template_id      
      
   set @new_source_deal_id=SCOPE_IDENTITY()
  --print @new_source_deal_id       
    EXEC spa_compliance_workflow 109,'i',@new_source_deal_id,'Deal',null      
      
  select @tmp_vol=deal_volume,@buy_sell_tmp=buy_sell_flag,@curve_id_tmp=curve_id from source_deal_detail        
        where  source_deal_header_id=@source_deal_header_id and source_deal_detail_id in(select * from  SplitCommaSeperatedValues(@source_deal_detail_id))      
      
       
      
INSERT INTO [dbo].[source_deal_detail]      
           ([source_deal_header_id]      
           ,[term_start]      
           ,[term_end]      
           ,[Leg]      
           ,[contract_expiration_date]      
           ,[fixed_float_leg]      
           ,[buy_sell_flag]      
           ,[curve_id]      
           ,[fixed_price]      
           ,[fixed_price_currency_id]      
           ,[deal_volume]      
           ,[deal_volume_frequency]      
           ,[deal_volume_uom_id]      
           ,[block_description]                 
           ,[create_user]      
           ,[create_ts]      
           ,[update_user]      
           ,[update_ts]      
           ,[location_id]      
     ,[physical_financial_flag],process_deal_status,
        price_uom_id,
   category,
   pv_party,
   profile_code      
  )      
     SELECT       
           @new_source_deal_id      
            ,sdh.entire_term_start      
           ,sdh.entire_term_end      
           ,td.leg      
           ,sdh.entire_term_end      
           ,td.fixed_float_leg      
           ,CASE       
    WHEN @internal_deal_subtype_value_id='9'      
    THEN      
     CASE      
      WHEN sdh.header_buy_sell_flag ='b'      
      then 's' else 'b'      
     END       
        
    WHEN @internal_deal_subtype_value_id='10'      
    THEN      
     CASE      
      WHEN sdh.header_buy_sell_flag ='b'      
      then 'b' else 's'      
     END       
   End       
           ,@curve_id_tmp      
           ,@fixed_price      
           ,td.currency_id      
           ,@tmp_vol      
           ,td.deal_volume_frequency      
           ,td.[deal_volume_uom_id] --      
           ,td.block_description                 
            ,dbo.fnadbuser()      
           ,getdate()      
           ,dbo.fnadbuser()      
           ,getdate()      
           ,td.location_id      
     ,td.physical_financial_flag,12505,
        price_uom_id,
   category,
   pv_party,
   profile_code      
  FROM [dbo].[source_deal_detail_template] td       
inner join source_deal_header sdh  on  sdh.source_deal_header_id=@source_deal_header_id      
    where td.template_id=@tmp_template_id      
      
    INSERT INTO [dbo].[user_defined_deal_fields]      
         ([source_deal_header_id]      
         ,[udf_template_id]      
         ,[udf_value]      
         ,[create_user]      
         ,[create_ts])      
     select      
         @new_source_deal_id      
         ,udf.[udf_template_id]      
         ,@fixed_price      
         ,dbo.fnadbuser()      
         ,getdate()      
     FROM [dbo].[user_defined_deal_fields_template] udf where udf.template_id=@tmp_template_id      
      
      
---############### Update th EDF field in the original deal.      
   UPDATE a      
    SET a.[udf_value]=@fixed_price      
   FROM      
    [user_defined_deal_fields] a,      
    [user_defined_deal_fields_template] b      
   WHERE      
    a.source_deal_header_id=@source_deal_header_id      
    AND a.udf_template_id=b.udf_template_id      
    --AND b.template_id=@tmp_template_id      
           
      
      
    If @@ERROR <> 0      
    Begin      
    Exec spa_ErrorHandler @@ERROR, 'Source Deal Header  table',       
        
      'spa_sourcedealheader', 'DB Error',       
        
      'Failed copying record.', ''      
    Rollback Tran      
    End      
    Else      
    Begin      
      
                    update [source_deal_detail] set process_deal_status=12505 where [source_deal_header_id]=@source_deal_header_id      
     Exec spa_ErrorHandler 0, 'Source Deal Header  table',       
         
       'spa_sourcedealheader', 'Success',       
         
       '', @new_source_deal_id      
     Commit Tran      
    End      
  END      
  Else      
  BEGIN      
         
    Exec spa_ErrorHandler -1, 'Deal already posted.',       
           
         'spa_sourcedealheader', 'DB Error',       
           
         'Deal already posted.', ''      
        
      
      
  END      
end      
else if @flag='b' -- Logic for blotter mode to get dail deatil      
begin      
     select source_deal_header_id from source_deal_header where deal_id=@deal_id      
End      
      
      
else if @flag='v' -- Logic for exercise deals      
      
BEGIN      
  DECLARE @tmp_source_deal_type_id int      
  DECLARE @tmp_deal_sub_type_type_id int      
  DECLARE @tmp_src_deal_detail_id int      
  DECLARE @tmp_tmeplate_name varchar(200)      
        
  SELECT @tmp_tmeplate_name=template_name FROM source_deal_header_template      
  WHERE template_id =(SELECT template_id FROM source_deal_header      
           WHERE source_deal_header_id=@source_deal_header_id )      
        
   EXEC spa_print @tmp_tmeplate_name      
      
  SELECT @tmp_src_deal_detail_id=source_deal_detail_id  FROM deal_exercise_detail      
  WHERE source_deal_detail_id=@source_deal_detail_id      
        
  IF(@tmp_src_deal_detail_id IS NULL)      
  BEGIN      
      
   BEGIN TRY       
         
    SET @deal_name_temp='_Options'      
          
    BEGIN TRAN      
        
    IF @physical_financial_flag='p'      
    BEGIN      
      
     SELECT @new_deal_id=cast(@source_deal_header_id AS VARCHAR)+@deal_name_temp + CASE WHEN count(deal_id) > 0 THEN cast(count(deal_id)+1 AS VARCHAR)      
     ELSE '' END       
     FROM source_deal_header      
     WHERE deal_id like cast(@source_deal_header_id AS VARCHAR(20))+@deal_name_temp+'%'      
      
     SELECT @tmp_source_deal_type_id=deal_type_id,@tmp_deal_sub_type_type_id=deal_sub_type_id       
     FROM default_deal_post_values       
     WHERE internal_deal_type_subtype_id=14      
          
     EXEC spa_print @tmp_source_deal_type_id      
     EXEC spa_print @tmp_deal_sub_type_type_id      
      
     EXEC spa_print @new_deal_id      
           
           
     INSERT INTO source_deal_header(source_system_id, deal_id, deal_date, ext_deal_id, physical_financial_flag, structured_deal_id, counterparty_id, entire_term_start, entire_term_end,       
            source_deal_type_id, deal_sub_type_type_id, option_flag, /*option_type,*/ option_excercise_type, source_system_book_id1, source_system_book_id2,       
            source_system_book_id3, source_system_book_id4, description1, description2, description3, deal_category_value_id, trader_id,       
            internal_deal_type_value_id, internal_deal_subtype_value_id,template_id,header_buy_sell_flag, broker_id, generator_id, status_value_id,       
            status_date, assignment_type_value_id, compliance_year, state_value_id, assigned_date, assigned_by, generation_source, aggregate_environment,       
            aggregate_envrionment_comment, rec_price, rec_formula_id, rolling_avg,pricing,[close_reference_id],deal_reference_type_id)      
      (SELECT   source_system_id, @new_deal_id, deal_date, ext_deal_id, @physical_financial_flag, structured_deal_id, counterparty_id, entire_term_start, entire_term_end,       
            @tmp_source_deal_type_id, @tmp_deal_sub_type_type_id, 'n', /*@option_type,*/ @option_excercise_type, source_system_book_id1, source_system_book_id2,       
            source_system_book_id3, source_system_book_id4, description1, description2, description3, deal_category_value_id, trader_id,       
            internal_deal_type_value_id, internal_deal_subtype_value_id,      
            CASE      
            WHEN @tmp_tmeplate_name LIKE '%Options Future%'      
             THEN 174      
            WHEN @tmp_tmeplate_name LIKE '%Options Swing Swap%'      
             THEN 178      
            ELSE  174      
             END AS template_id,      
            CASE       
            WHEN @option_type='c'       
             THEN header_buy_sell_flag      
            ELSE       
             CASE       
              WHEN header_buy_sell_flag='b'       
               THEN 's'       
               ELSE 'b'       
             END      
            END AS header_buy_sell_flag,       
            broker_id, generator_id, status_value_id,       
            status_date, assignment_type_value_id, compliance_year, state_value_id, assigned_date, assigned_by, generation_source, aggregate_environment,       
            aggregate_envrionment_comment, rec_price, rec_formula_id, rolling_avg,pricing,source_deal_header_id,12506      
      FROM source_deal_header       
      WHERE source_deal_header_id=@source_deal_header_id)      
            
      SET @new_source_deal_id=SCOPE_IDENTITY()
               
      EXEC spa_compliance_workflow 109,'i',@new_source_deal_id,'Deal',null      
      
      SELECT * FROM  SplitCommaSeperatedValues(@source_deal_detail_id)       
      
      INSERT  INTO source_deal_detail (source_deal_header_id,      
             term_start,      
             term_end,      
             leg,      
             contract_expiration_date,      
             fixed_float_leg,      
             buy_sell_flag,      
             curve_id,      
             fixed_price,      
             fixed_price_currency_id,      
             deal_volume,      
             deal_volume_frequency,      
             deal_volume_uom_id,      
             block_description,      
             deal_detail_description,formula_id,      
             price_adder,      
             price_multiplier,      
             physical_financial_flag,process_deal_status)      
      SELECT @new_source_deal_id,      
        term_start,      
        term_end,      
        leg,      
        contract_expiration_date,      
        fixed_float_leg,      
        CASE WHEN @option_type='c' THEN buy_sell_flag       
          ELSE CASE WHEN buy_sell_flag='b' THEN 's' ELSE 'b' END END      
        AS buy_sell_flag,      
        curve_id,      
        option_strike_price,--fixed_price,      
        fixed_price_currency_id,      
        deal_volume,      
        deal_volume_frequency,      
        deal_volume_uom_id,      
        block_description,      
        deal_detail_description,formula_id,price_adder,      
        price_multiplier,'p',12506      
             
     FROM source_deal_detail       
        WHERE source_deal_header_id=@source_deal_header_id AND source_deal_detail_id IN (SELECT Item FROM  SplitCommaSeperatedValues(@source_deal_detail_id))      
     END      
          
      
     INSERT INTO deal_exercise_detail(source_deal_detail_id,exercise_date,term_start,term_end,exercise_deal_id)      
     SELECT      
       @source_deal_detail_id,      
       @exercise_date,      
       @options_term_start,      
       @options_term_end,       
       ISNULL(@new_source_deal_id,NULL)      
             
     EXEC spa_ErrorHandler 0, 'Source Deal Header  table',       
        'spa_sourcedealtemp', 'Success',       
  '', @new_source_deal_id      
     COMMIT TRAN      
             
   END TRY      
   BEGIN CATCH       
      
   IF @@ERROR <> 0      
    BEGIN      
     EXEC spa_ErrorHandler -1, 'Source Deal Header  table',       
       'spa_sourcedealtemp', 'DB Error',       
       'Failed copying record.', ''      
     ROLLBACK TRAN      
    END      
   END CATCH       
  END      
  ELSE      
   BEGIN      
     EXEC spa_ErrorHandler -1, 'The Selected Deal is Already Exercised.',       
      'spa_sourcedealtemp', 'DB Error',       
      'The Selected Deal is Already Exercised.',''      
   END      
END      
/*      
ELSE IF @flag='v' -- Logic for exercise deals      
--Print 'I M HERE'      
BEGIN      
        set @deal_name_temp='_Options'      
BEGIN TRAN      
       
  SELECT @new_deal_id=CAST(@source_deal_header_id AS VARCHAR)+@deal_name_temp +       
   CASE WHEN count(deal_id) > 0       
     THEN cast(count(deal_id)+1 AS VARCHAR)      
    ELSE ''       
   END       
  FROM source_deal_header      
  WHERE deal_id=cast(@source_deal_header_id AS VARCHAR(20))+ @deal_name_temp      
        
      
  INSERT INTO source_deal_header(      
        source_system_id, deal_id, deal_date, ext_deal_id, physical_financial_flag, structured_deal_id, counterparty_id,      
        entire_term_start, entire_term_end,source_deal_type_id, deal_sub_type_type_id, option_flag, option_type,option_excercise_type,      
        source_system_book_id1, source_system_book_id2,source_system_book_id3,source_system_book_id4, description1,       
        description2, description3, deal_category_value_id, trader_id,internal_deal_type_value_id, internal_deal_subtype_value_id,      
        template_id, header_buy_sell_flag, broker_id, generator_id, status_value_id,status_date, assignment_type_value_id,       
        compliance_year, state_value_id, assigned_date, assigned_by, generation_source, aggregate_environment,aggregate_envrionment_comment,       
        rec_price, rec_formula_id, rolling_avg,pricing)      
   (SELECT   source_system_id, @new_deal_id, deal_date, ext_deal_id,physical_financial_flag, structured_deal_id, counterparty_id,       
       entire_term_start, entire_term_end, source_deal_type_id, deal_sub_type_type_id, option_flag, @option_type, @option_excercise_type,      
       source_system_book_id1, source_system_book_id2,source_system_book_id3, source_system_book_id4, description1,       
       description2, description3, deal_category_value_id, trader_id,internal_deal_type_value_id, internal_deal_subtype_value_id,       
       template_id,CASE WHEN header_buy_sell_flag='b' THEN 's' ELSE 'b' END AS header_buy_sell_flag, broker_id, generator_id, status_value_id, status_date, assignment_type_value_id,       
       compliance_year, state_value_id, assigned_date, assigned_by, generation_source, aggregate_environment,aggregate_envrionment_comment,      
       rec_price, rec_formula_id, rolling_avg,pricing      
    FROM source_deal_header       
    WHERE source_deal_header_id=@source_deal_header_id)      
         
   set @new_source_deal_id=scope_IDENTITY()      
        
   INSERT  INTO source_deal_detail (source_deal_header_id,      
      term_start,      
      term_end,      
      leg,      
      contract_expiration_date,      
      fixed_float_leg,      
      buy_sell_flag,      
      curve_id,      
      fixed_price,      
      fixed_price_currency_id,      
      option_strike_price,      
      deal_volume,      
      deal_volume_frequency,      
      deal_volume_uom_id,      
      block_description,      
      deal_detail_description,      
      formula_id,      
      price_adder,      
      price_multiplier)      
    SELECT @new_source_deal_id,      
      term_start,      
      term_end,      
      leg,      
      contract_expiration_date,      
      fixed_float_leg,      
      @buy_sell_flag,      
      curve_id,      
      @fixed_price,      
      fixed_price_currency_id,      
      option_strike_price,      
      deal_volume,      
      deal_volume_frequency,      
      deal_volume_uom_id,      
      block_description,      
      deal_detail_description,formula_id,price_adder,      
      price_multiplier      
           
     FROM source_deal_detail       
     WHERE source_deal_header_id=@source_deal_header_id       
     AND source_deal_detail_id =@source_deal_detail_id      
  --END      
       
      
  INSERT INTO deal_exercise_detail(source_deal_detail_id,exercise_date,term_start,term_end,exercise_deal_id)      
   SELECT      
    @source_deal_detail_id,      
    @exercise_date,      
    @options_term_start,      
    @options_term_end,       
    ISNULL(@new_source_deal_id,NULL)      
      
  If @@ERROR <> 0      
   BEGIN      
    Exec spa_ErrorHandler @@ERROR, 'Source Deal Header  table',       
     'spa_sourcedealheader', 'DB Error',       
     'Failed copying record.', ''      
    Rollback Tran      
   END      
  ELSE      
   BEGIN      
    Exec spa_ErrorHandler 0, 'Source Deal Header  table',       
     'spa_sourcedealheader', 'Success',       
     '', @new_source_deal_id      
    Commit Tran      
   END      
END      
*/      
      
ELSE IF @flag='l' -- Index for Legs      
BEGIN      
 SELECT       
  sdd.leg [Leg],pcd.curve_name [Index]       
 FROM source_deal_detail sdd      
 INNER JOIN source_deal_header sdh ON sdd.source_deal_header_id = sdh.source_deal_header_id      
 left outer join source_price_curve_def pcd on pcd.source_curve_def_id=sdd.curve_id       
 WHERE sdd.source_deal_header_id = @source_deal_header_id      
 GROUP BY sdd.leg,pcd.curve_name      
END 

else if @flag='x' -- cut deal logic same as copy deal detail except Buy/Sell value is toggle and Deal Type is set to Gas Pipeline Cut      
begin      
      
declare @bif_leg_x int      
      
select @max_leg=max(leg),@deal_volume=sum(deal_volume)/max(leg) from source_deal_detail       
  where source_deal_header_id=@source_deal_header_id      
select @bif_leg_x=leg from source_deal_detail where source_deal_detail_id=@source_deal_detail_id      
      
set @sql_select='      
select       
 dbo.FNADateFormat(min(sdd.term_start)) AS [Term Start],       
 dbo.FNADateFormat(max(sdd.term_end)) AS [Term End],      
 '+case when @source_deal_detail_id is not null then ' 1 ' else ' sdd.Leg ' end+' AS Leg,      
 max((case sdd.fixed_float_leg when ''f'' then ''Fixed'' Else ''Float'' end)) AS [Fixed/Float],      
 --max(case when buy_sell_flag =''b'' then ''Buy(Receive)'' else ''Sell(Pay)'' End) [Buy/Sell],      
 max(case when buy_sell_flag =''s'' then ''Buy(Receive)'' else ''Sell(Pay)'' End) [Buy/Sell],        
 max(pcd.source_curve_type_value_id) curve_type,max(pcd.commodity_id) commodity_id,      
 CASE WHEN max(physical_financial_flag) = ''p'' THEN ''Physical'' ELSE ''Financial'' END AS [Physical/Financial],      
 max(location_id) Location,      
 max(sdd.curve_id) [Index],      
 --NULL AS Volume, 
 dbo.FNARemoveTrailingZeroes(max(deal_volume)) AS Volume,      
 max(deal_volume_frequency) Frequency,      
 max(deal_volume_uom_id) UOM,  
 --NULL [Capacity],   --      
 dbo.FNARemoveTrailingZeroes(MAX(ISNULL(capacity, 1))) Capacity, 
 --NULL [Price],             
 dbo.FNARemoveTrailingZeroes(avg(sdd.fixed_price)) as Price,     
 ----cast(round(avg(sdd.fixed_price), 2) as varchar) as Price, 
 --NULL [Fixed Cost],           
 dbo.FNARemoveTrailingZeroes(max(fixed_cost))[Fixed Cost],       
 max(fixed_cost_currency_id) [Fixed Cost Currency],      
 max(sdd.formula_id) [Formula],      
 max(formula_currency_id) [Formula Currency],     
 --NULL [Opt. Strike Price],           
 dbo.FNARemoveTrailingZeroes(max(option_strike_price)) [Opt. Strike Price], 
 --NULL [Price Adder],        
 dbo.FNARemoveTrailingZeroes(max(price_adder)) [Price Adder],      
 max(adder_currency_id) [Adder Currency], 
 --NULL [Volume Multiplier],            
 dbo.FNARemoveTrailingZeroes(max(ISNULL(multiplier,1)))  [Volume Multiplier],       
 --NULL  [Price Multiplier],         
 dbo.FNARemoveTrailingZeroes(max(ISNULL(price_multiplier,1))) [Price Multiplier],
 max(fixed_price_currency_id) [Price Currency],     
 --NULL [Price Adder2],            
 dbo.FNARemoveTrailingZeroes(MAX(price_adder2))  [Price Adder2],
 MAX(price_adder_currency2) [Adder Currency2],     
 --NULL [Volume Multiplier2],           
 dbo.FNARemoveTrailingZeroes(MAX(ISNULL(volume_multiplier2, 1))) [Volume Multiplier2],
 max(meter_id) Meter,      
 max(sdd.pay_opposite) as [PayOpposite],      
 -- Strip Month From      
 -- Lag Months      
 -- Strip Month To      
 max(day_count_id) [Day Count],      
 NULL LocationName,      
 NULL CurveName,  
 max(sdd.settlement_currency) as [Sett.Currency],      
 --NULL  AS [SYV], 
 max(sdd.standard_yearly_volume) AS [SYV],
 max(price_uom_id) PriceUom,
max(category) Category, 
max(profile_code) ProfileCode,
max(pv_party) [PR Party] 
,MAX(formula_curve_id) formula_curve_id
from       
 source_deal_detail sdd left outer join       
source_price_curve_def pcd on pcd.source_curve_def_id=sdd.curve_id        
where source_deal_header_id='+cast(@source_deal_header_id as varchar)      
+ case when @source_deal_detail_id is not null then ' And leg='+cast(@bif_leg_x as varchar) else '' end +      
' group by Leg order by leg '      
      
      
EXEC spa_print @sql_select   
exec(@sql_select)      
END      
--Check if deal exists in source_deal_header.
ELSE IF @flag = 'h'
BEGIN
	IF NOT EXISTS (SELECT 1 FROM source_deal_header dh WHERE dh.source_deal_header_id=@source_deal_header_id)
	BEGIN
		EXEC spa_ErrorHandler
			-1,
			'Source Deal Header table',
			'spa_sourcedealtemp',
			'Error',
			'Deal not found. It has been deleted.',
			''
		RETURN
	END
	ELSE
	BEGIN		
		EXEC spa_ErrorHandler
			0,
			'Source Deal Header table',
			'spa_sourcedealtemp',
			'Success',
			@source_deal_header_id,
			'n'		
	END	 
END
GO


