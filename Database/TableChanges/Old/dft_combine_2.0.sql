/****** Object:  UserDefinedFunction [dbo].[FNAGetTemplateFieldName]    Script Date: 12/20/2011 00:27:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAGetTemplateFieldName]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAGetTemplateFieldName]
GO


/****** Object:  UserDefinedFunction [dbo].[FNAGetTemplateFieldName]    Script Date: 12/20/2011 00:27:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--SELECT dbo.FNAGetTemplateFieldName(2,'h')
CREATE FUNCTION [dbo].[FNAGetTemplateFieldName] 
(
	@field_template_id INT,
	@header_detail CHAR(1)
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @return_value VARCHAR(MAX),@farrms_field_id VARCHAR(150)
	SET @return_value=''
	DECLARE dealCur CURSOR  FORWARD_ONLY READ_ONLY FOR
	SELECT mfd.farrms_field_id
	FROM maintain_field_deal mfd JOIN maintain_field_template_detail mftd 
	ON mftd.field_id = mfd.field_id 
	WHERE mftd.field_template_id=@field_template_id
	AND ISNULL(udf_or_system,'s')='s'
	AND header_detail=@header_detail
	AND CASE WHEN @header_detail='h' THEN field_group_id ELSE '1' END IS NOT NULL 
	AND mfd.farrms_field_id NOT IN ('source_deal_header_id','source_deal_detail_id',
	'create_user','create_ts','update_user','update_ts','template_id')
		
		OPEN dealCur
		FETCH NEXT FROM dealCur into @farrms_field_id
		WHILE @@FETCH_STATUS = 0
		BEGIN
		
				set @return_value=@return_value+' '+ @farrms_field_id +' ,'		
			
			FETCH NEXT FROM dealCur into @farrms_field_id
		end
		close dealCur
		deallocate dealCur
		if len(@return_value)>1
		BEGIN
			set @return_value=left(@return_value,len(@return_value)-1)
		end 
		RETURN @return_value
END


GO





/****** Object:  UserDefinedFunction [dbo].[FNAGetTemplateFieldTable]    Script Date: 12/20/2011 00:26:45 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAGetTemplateFieldTable]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAGetTemplateFieldTable]
GO


/****** Object:  UserDefinedFunction [dbo].[FNAGetTemplateFieldTable]    Script Date: 12/20/2011 00:26:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


create FUNCTION [dbo].[FNAGetTemplateFieldTable](
   @field_template_id INT,
   @header_detail CHAR(1)
) RETURNS @List TABLE (farrms_field_id VARCHAR(100),default_value VARCHAR(100))

BEGIN

	INSERT INTO @List 
	SELECT mfd.farrms_field_id,mftd.default_value
	FROM maintain_field_deal mfd JOIN maintain_field_template_detail mftd 
	ON mftd.field_id = mfd.field_id 
	WHERE mftd.field_template_id=@field_template_id
	AND ISNULL(udf_or_system,'s')='s'
	AND header_detail=@header_detail
	AND CASE WHEN @header_detail='h' THEN field_group_id ELSE '1' END IS NOT NULL 
	AND mfd.farrms_field_id NOT IN ('source_deal_header_id','source_deal_detail_id',
	'create_user','create_ts','update_user','update_ts','template_id')
		
	
	OPTION(MAXRECURSION 0)
RETURN
END



GO




/****** Object:  StoredProcedure [dbo].[spa_sourcedealtemp_detail]    Script Date: 12/20/2011 00:25:47 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_sourcedealtemp_detail]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_sourcedealtemp_detail]
GO

/****** Object:  StoredProcedure [dbo].[spa_Transpose]    Script Date: 12/20/2011 00:25:47 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_Transpose]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_Transpose]
GO

/****** Object:  StoredProcedure [dbo].[spa_InsertDealXmlBlotterV2]    Script Date: 12/20/2011 00:25:47 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_InsertDealXmlBlotterV2]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_InsertDealXmlBlotterV2]
GO



/****** Object:  StoredProcedure [dbo].[spa_sourcedealtemp_detail]    Script Date: 12/20/2011 00:25:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



--spa_sourcedealtemp_detail @flag='g',@source_deal_header_id=1
CREATE proc [dbo].[spa_sourcedealtemp_detail]      
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
@deleted_deal VARCHAR(1)='n',      
@call_from_paging CHAR(1)='n'     --- if called from spa_sourcedealtemp_detail_paging  
as      

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
      
set @sql_select='SELECT dh.source_deal_header_id DetailId,dh.source_system_id ,dh.deal_id,       
  dbo.FNAGetSQLStandardDate(dh.deal_date) deal_date,      
   dh.ext_deal_id ,dh.physical_financial_flag,       
  dh.counterparty_id,       
  dbo.FNAGetSQLStandardDate(dh.entire_term_start) entire_term_start,       
  dbo.FNAGetSQLStandardDate(dh.entire_term_end) entire_term_end, dh.source_deal_type_id,       
  dh.deal_sub_type_type_id,       
  dh.option_flag, dh.option_type, dh.option_excercise_type,       
  dh.source_system_book_id1 As Group1,       
  dh.source_system_book_id2 AS Group2,       
  dh.source_system_book_id3 AS Group3, dh.source_system_book_id4 AS Group4,      
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
 ssbm.fas_deal_type_value_id,sdt.disable_gui_groups,dh.rolling_avg,sdht.template_name+''.''+ssd.source_system_name,dh.contract_id,      
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
    sdv_con_stat.value_id ConfirmStatus,      
      dbo.FNAGetSQLStandardDate(ConfirmStatusDate) ConfirmStatusDate,      
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
      sdht.field_template_id
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
 print @sql_select      
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
        
  print @sql_select      
      
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
   a.pv_party [Pv Party]      
  from ' +CASE WHEN isnull(@deleted_deal,'n')='y' then  'delete_source_deal_detail' ELSE 'source_deal_detail' END +' a join      
  ' +CASE WHEN isnull(@deleted_deal,'n')='y' then  'delete_source_deal_header' ELSE 'source_deal_header' END +' h on      
  a.source_deal_header_id=h.source_deal_header_id join      
  source_deal_type sdt on sdt.source_deal_type_id=h.source_deal_type_id       
  left outer join source_price_curve_def pcd on pcd.source_curve_def_id=a.curve_id       
  left outer join rec_generator rg on rg.generator_id=h.generator_id      
  left outer join formula_editor fe on fe.formula_id=a.formula_id      
  LEFT OUTER JOIN source_minor_location sml ON sml.source_minor_location_id = a.location_id
  LEFT JOIN source_Major_Location ON sml.source_Major_Location_Id=source_Major_Location.source_major_location_ID    

  where a.source_deal_header_id='+cast(@source_deal_header_id as varchar)      
      
  if @term_start is not null      
  set @sql_select= @sql_select+ ' And term_start='''+@term_start+''''      
       
  if @term_start is not null      
  set @sql_select= @sql_select +' And term_end='''+@term_end+''''      
        
  set @sql_select= @sql_select+ ' order by term_start,leg '      
        
  print @sql_select      
      
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

-- set @sql_select='      
--  select       
--   a.source_deal_detail_id,      
--   CASE sdht.term_end_flag WHEN ''y'' THEN cast(datepart(YY,term_start)AS varchar)      
--   else dbo.FNADateFormat(term_start) END ['+@term_label+'],       
--   dbo.FNADateFormat(term_end) as term_end_flag,      
--   Leg,       
--   case when sdt.expiration_applies =''y'' then dbo.FNADEALRECExpiration(a.source_deal_detail_id, contract_expiration_date, NULL)       
--    else dbo.FNADateFormat(contract_expiration_date) end as ExpDate,      
--   case when fixed_float_leg=''f'' then ''Fixed'' else ''Float'' End as [Fixed/Float],      
--   case when a.buy_sell_flag =''b'' then ''Buy(Receive)'' else ''Sell(Pay)'' End as [Buy/Sell],               
--   CASE WHEN a.physical_financial_flag = ''p'' THEN ''Physical'' ELSE ''Financial'' END AS [Physical/Financial],      
--   dbo.FNAHyperLinkText2(10102510,case when source_Major_Location.location_name is null then '''' else source_Major_Location.location_name + '' -> '' end + sml.location_name,''''''u'''''',cast(sml.source_minor_Location_Id as varchar)) AS Location,
--     dbo.FNAHyperLinkText2(10102610,pcd.curve_name+ISNULL(''@@@''+dbo.FNAFormulaFormat(fe1.formula,''r''),''''),CAST(pcd.source_curve_def_id AS VARCHAR),''''''u'''''') AS ['+@label_index+'], 
--      ROUND(dbo.FNARemoveTrailingZeroes(CAST(deal_volume AS numeric(38,20))),'+@round_value+') as Volume,
      
--   CASE '+ @deal_volume_frequency_column + '      
--     WHEN ''d'' THEN ''Daily''      
--     WHEN ''m'' THEN ''Monthly''      
--     WHEN ''h'' THEN ''Hourly''      
--     WHEN ''w'' THEN ''Weekly''      
--     WHEN ''q'' THEN ''Quarterly''      
--     WHEN ''s'' THEN ''Semi-Annually''      
--     WHEN ''a'' THEN ''Annually''      
--     WHEN ''t'' THEN ''Term''      
--   END as [Volume Frequency],      
            
--   uom.uom_name as UOM,      
--   ROUND(dbo.FNARemoveTrailingZeroes(CAST(a.total_volume AS numeric(38,9))),'+@round_value+') AS [TotalVolume],
--   su.uom_name as [Position UOM],       
--   a.capacity as [Capacity],      
----   dbo.FNARemoveTrailingZeroes(a.fixed_price) Price,      
----   dbo.FNARemoveTrailingZeroes(CAST(a.fixed_price AS numeric(38,20))) as Price,      
--   case  when sdt.expiration_applies =''y'' and      
--   ( a.fixed_price is null and a.formula_id is null)  then       
--    dbo.FNARemoveTrailingZeroes(CAST(rg.contract_price AS numeric(38,20))) else       
--   dbo.FNARemoveTrailingZeroes(CAST(fixed_price AS numeric(38,20))) end as Price,      
--    dbo.FNARemoveTrailingZeroes(CAST(fixed_cost AS numeric(38,20))) AS [Fixed Cost],      
--   scfc.currency_name as [Fixed Cost Currency],      
--    dbo.FNAFormulaFormat(fe.formula,''r'') as Formula,      
--   scfr.currency_name as [Formula Currency],      
--    '+CASE WHEN ISNULL(@option_flag,'n')='y' THEN ' dbo.FNARemoveTrailingZeroes(ROUND(Option_strike_Price,9))' ELSE 'NULL' END+' AS OptionStrike,      
--   --round(price_adder,4) PriceAdder,      
--   dbo.FNARemoveTrailingZeroes(price_adder) PriceAdder,        
--   scpa.currency_name as [Adder Currency],       
--   dbo.FNARemoveTrailingZeroes(ISNULL(multiplier,1)) [Volume Multiplier],      
--   dbo.FNARemoveTrailingZeroes(ISNULL(price_multiplier,1)) [Price Multiplier],      
--    sc.currency_name as [Price Currency],      
--    dbo.FNARemoveTrailingZeroes(price_adder2) PriceAdder2,        
--   scpa1.currency_name as [Adder Currency2],      
--   dbo.FNARemoveTrailingZeroes(ISNULL(volume_multiplier2,1)) [Volume Multiplier2],       
--    mi.recorderid AS [Meter],      
--    upper(a.pay_opposite) as [PayOpposite],      
--    ISNULL(dbo.FNADateFormat(a.settlement_date),dbo.FNADateFormat(contract_expiration_date)) [Payment Date],      
--    case  when sdt.expiration_applies =''y'' then      
--   cast(dbo.FNARECBonus(h.source_deal_header_id) as varchar)  else       
--   block_description end as Bonus,      
--   sdv.code [Day Count],      
--   sml.source_minor_location_id,      
--   a.curve_id,      
--   setcur.currency_name as [Sett.Currency],      
--   a.standard_yearly_volume AS [SYV] ,
--    pu.uom_name [Price UOM],
--    sdvc.code Category,
--    sdvp.Code Profile,
--    sdvpv.code [Pv Party]
CREATE TABLE #tempDeal(
	[source_deal_detail_id] [int] NOT NULL,
	[source_deal_header_id] [int] NOT NULL,
	[term_start] VARCHAR(50) NOT NULL,
	[term_end] VARCHAR(50) NOT NULL,
	[Leg] [int] NOT NULL,
	[contract_expiration_date] varchar(50) NOT NULL,
	[fixed_float_leg] [varchar](50) NOT NULL,
	[buy_sell_flag] [varchar](50) NOT NULL,
	[curve_id] [varchar](150) NULL,
	[fixed_price] [numeric](38, 20) NULL,
	[fixed_price_currency_id] [varchar](50) NULL,
	[option_strike_price] [numeric](38, 20) NULL,
	[deal_volume] [numeric](38, 20) NULL,
	[deal_volume_frequency] [varchar](50) NOT NULL,
	[deal_volume_uom_id] [varchar](50) NOT NULL,
	[block_description] [varchar](100) NULL,
	[deal_detail_description] [varchar](100) NULL,
	[formula_id] [varchar](500) NULL,
	[volume_left] [float] NULL,
	[settlement_volume] [float] NULL,
	[settlement_uom] [varchar](50) NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [varchar](50) NULL,
	[update_user] [varchar](50) NULL,
	[update_ts] [varchar](50) NULL,
	[price_adder] [numeric](38, 20) NULL,
	[price_multiplier] [numeric](38, 20) NULL,
	[settlement_date] [varchar](50) NULL,
	[day_count_id] [varchar](50) NULL,
	[location_id] [varchar](100) NULL,
	[meter_id] [varchar](50) NULL,
	[physical_financial_flag] [varchar](50) NULL,
	[Booked] [varchar](50) NULL,
	[process_deal_status] [varchar](50) NULL,
	[fixed_cost] [numeric](38, 20) NULL,
	[multiplier] [numeric](38, 20) NULL,
	[adder_currency_id] [varchar](50) NULL,
	[fixed_cost_currency_id] [varchar](50) NULL,
	[formula_currency_id] [varchar](50) NULL,
	[price_adder2] [numeric](38, 20) NULL,
	[price_adder_currency2] [varchar](50) NULL,
	[volume_multiplier2] [numeric](38, 20) NULL,
	[total_volume] [numeric](38, 20) NULL,
	[pay_opposite] [varchar](50)NULL,
	[capacity] [numeric](38, 20) NULL,
	[settlement_currency] [varchar](50) NULL,
	[standard_yearly_volume] [float] NULL,
	[formula_curve_id] [varchar](50) NULL,
	[price_uom_id] [varchar](50) NULL,
	[category] [varchar](50) NULL,
	[profile_code] [varchar](50) NULL,
	[pv_party] [varchar](50) NULL
)

set @sql_select=' insert into #tempDeal([source_deal_detail_id]
      ,[source_deal_header_id]
      ,[term_start]
      ,[term_end]
      ,[Leg]
      ,[contract_expiration_date]
      ,[fixed_float_leg]
      ,[buy_sell_flag]
      ,[curve_id]
      ,[fixed_price]
      ,[fixed_price_currency_id]
      ,[option_strike_price]
      ,[deal_volume]
      ,[deal_volume_frequency]
      ,[deal_volume_uom_id]
      ,[block_description]
      ,[deal_detail_description]
      ,[formula_id]
      ,[volume_left]
      ,[settlement_volume]
      ,[settlement_uom]
      ,[create_user]
      ,[create_ts]
      ,[update_user]
      ,[update_ts]
      ,[price_adder]
      ,[price_multiplier]
      ,[settlement_date]
      ,[day_count_id]
      ,[location_id]
      ,[meter_id]
      ,[physical_financial_flag]
      ,[Booked]
      ,[process_deal_status]
      ,[fixed_cost]
      ,[multiplier]
      ,[adder_currency_id]
      ,[fixed_cost_currency_id]
      ,[formula_currency_id]
      ,[price_adder2]
      ,[price_adder_currency2]
      ,[volume_multiplier2]
      ,[total_volume]
      ,[pay_opposite]
      ,[capacity]
      ,[settlement_currency]
      ,[standard_yearly_volume]
      ,[formula_curve_id]
      ,[price_uom_id]
      ,[category]
      ,[profile_code]
      ,[pv_party])   
	select a.[source_deal_detail_id]
      ,a.[source_deal_header_id]
       ,dbo.FNADateFormat(a.term_start) [term_start]
      ,dbo.FNADateFormat(a.term_end) [term_end]
      ,a.[Leg]
      ,dbo.FNADateFormat(a.contract_expiration_date) [contract_expiration_date]
      ,case when fixed_float_leg=''f'' then ''Fixed'' else ''Float'' End     
       ,  case when a.buy_sell_flag =''b'' then ''Buy(Receive)'' else ''Sell(Pay)'' END 
      ,pcd.[curve_id]
      , case  when sdt.expiration_applies =''y'' and      
			( a.fixed_price is null and a.formula_id is null)  then       
				dbo.FNARemoveTrailingZeroes(CAST(rg.contract_price AS numeric(38,20))) 
			else       
				dbo.FNARemoveTrailingZeroes(CAST(fixed_price AS numeric(38,20))) END [fixed_price]
      ,sc.currency_name [fixed_price_currency_id]
      ,a.[option_strike_price]
      ,ROUND(dbo.FNARemoveTrailingZeroes(CAST(a.deal_volume AS numeric(38,9))),'+@round_value+')  [deal_volume]
      ,    
   CASE '+ @deal_volume_frequency_column + '      
     WHEN ''d'' THEN ''Daily''      
     WHEN ''m'' THEN ''Monthly''      
     WHEN ''h'' THEN ''Hourly''      
     WHEN ''w'' THEN ''Weekly''      
     WHEN ''q'' THEN ''Quarterly''      
     WHEN ''s'' THEN ''Semi-Annually''      
     WHEN ''a'' THEN ''Annually''      
     WHEN ''t'' THEN ''Term''      
   END [deal_volume_frequency]
      ,uom.uom_name [deal_volume_uom_id]
      ,a.[block_description]
      ,a.[deal_detail_description]
      ,dbo.FNAFormulaFormat(fe.formula,''r'')  [formula_id]
      ,a.[volume_left]
      ,a.[settlement_volume]
      ,a.[settlement_uom]
      ,a.[create_user]
      ,a.[create_ts]
      ,a.[update_user]
      ,a.[update_ts]
      ,a.[price_adder]
      ,a.[price_multiplier]
      ,ISNULL(dbo.FNADateFormat(a.settlement_date),dbo.FNADateFormat(a.contract_expiration_date)) settlement_date
      ,sdv.code [day_count_id]
      ,sml.location_name [location_id]
      ,mi.recorderid [meter_id]
      ,CASE WHEN a.physical_financial_flag = ''p'' THEN ''Physical'' ELSE ''Financial'' END  [physical_financial_flag]
      ,a.[Booked]
      ,a.[process_deal_status]
      ,dbo.FNARemoveTrailingZeroes(CAST(fixed_cost AS numeric(38,20))) [fixed_cost]
      ,a.[multiplier]
      ,a.[adder_currency_id]
      ,scfc.currency_name [fixed_cost_currency_id]
      ,scfr.currency_name [formula_currency_id]
      ,dbo.FNARemoveTrailingZeroes(price_adder2) [price_adder2]
      ,scpa1.currency_name [price_adder_currency2]
      ,dbo.FNARemoveTrailingZeroes(ISNULL(volume_multiplier2,1)) [volume_multiplier2]
      ,a.[total_volume]
      ,a.[pay_opposite]
      ,a.[capacity]
      ,setcur.currency_name [settlement_currency]
      ,a.[standard_yearly_volume]
      ,a.[formula_curve_id]
      ,pu.uom_name [price_uom_id]
      ,sdvc.code [category]
      ,sdvp.Code [profile_code]
      ,sdvpv.code [pv_party]         
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
     PRINT 'ck'      
  PRINT @sql_select      
  exec(@sql_select) 
  
   IF @call_from_paging='y' --- if called from paging sps
   BEGIN 
   
      
	SELECT source_deal_detail_id,
					term_start,
					term_end,
					leg,
					contract_expiration_date,
					fixed_float_leg,
					buy_sell_flag,
					NULL curve_type,
					NULL commodity,
					physical_financial_flag,
					location_id,
					curve_id,
					deal_volume,
					deal_volume_frequency,
					deal_volume_uom_id,
					total_volume,
					capacity,
					fixed_price,
					fixed_cost,
					fixed_cost_currency_id,
					NULL formula_price,
					formula_currency_id,
					option_strike_price,
					price_adder,
					adder_currency_id,
					price_multiplier,
					multiplier,	
					fixed_price_currency_id,
					price_adder2,
					price_adder_currency2,
					volume_multiplier2,
					meter_id,
					pay_opposite,
					settlement_date,
					NULL bonus,
					NULL hour_ending,
					formula_id,
					day_count_id,
					location_id,
					NULL curve_name,
					settlement_currency,
				standard_yearly_volume,
					price_uom_id,
				category,
				profile_code,
				pv_party
				FROM #tempDeal
   RETURN 
   END 
   
     
  DECLARE @field_template_id INT
  SELECT @field_template_id=field_template_id FROM source_deal_header sdh JOIN dbo.source_deal_header_template tem ON sdh.template_id=tem.template_id
  WHERE sdh.source_deal_header_id=@source_deal_header_id 
 
 DECLARE @udf_field VARCHAR(5000)
 SET @udf_field=''
  SELECT @udf_field=@udf_field+' UDF___'+CAST(udf_template_id AS VARCHAR)+' VARCHAR(100),' FROM maintain_field_template_detail d JOIN 
  user_defined_fields_template udf_temp ON d.field_id = udf_temp.udf_template_id 
  WHERE field_template_id=1 AND udf_or_system='u'
  AND udf_temp.udf_type='d'  AND d.field_template_id=@field_template_id 
  if LEN(@udf_field)>1
  BEGIN
   SET @udf_field=LEFT(@udf_field,LEN(@udf_field)-1)
   exec ('ALTER TABLE #tempDeal add '+ @udf_field)
  end 
  
		declare @sql_pre varchar(max),@farrms_field_id varchar(100),@default_label varchar(100)
		SET @sql_pre=''
		DECLARE dealCur CURSOR  FORWARD_ONLY READ_ONLY FOR
		
		SELECT farrms_field_id,default_label FROM (
		SELECT f.farrms_field_id,ISNULL(d.field_caption,f.default_label) default_label,d.seq_no
		FROM maintain_field_template_detail d JOIN maintain_field_deal f ON d.field_id=f.field_id   
		WHERE f.header_detail='d' AND d.field_template_id=@field_template_id   AND ISNULL(d.udf_or_system,'s')='s'
		UNION ALL 
		SELECT 'UDF___'+CAST(udf_template_id AS VARCHAR),ISNULL(d.field_caption,f.Field_label) default_label ,d.seq_no
		FROM maintain_field_template_detail d JOIN user_defined_fields_template f ON d.field_id=f.udf_template_id   
		WHERE d.field_template_id=@field_template_id  AND f.udf_type='d'  AND d.udf_or_system='u'
		) l
		ORDER BY ISNULL(l.seq_no,10000) 
		OPEN dealCur
		FETCH NEXT FROM dealCur into @farrms_field_id,@default_label
		WHILE @@FETCH_STATUS = 0
		BEGIN
			set @sql_pre=@sql_pre+' '+ @farrms_field_id +' AS ['+ @default_label +'],'						
			FETCH NEXT FROM dealCur into @farrms_field_id,@default_label
		end
		close dealCur
		deallocate dealCur
		if len(@sql_pre)>1
		begin
			set @sql_pre=left(@sql_pre,len(@sql_pre)-1)
		end 
		exec('SELECT '+ @sql_pre +' FROM #tempDeal')
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
      
    CREATE TABLE #tempDealDetail(
	[source_deal_detail_id] [int] NOT NULL,
	[source_deal_header_id] [int] NOT NULL,
	[term_start] VARCHAR(50) NOT NULL,
	[term_end] VARCHAR(50) NOT NULL,
	[Leg] [int] NOT NULL,
	[contract_expiration_date] varchar(50) NOT NULL,
	[fixed_float_leg] VARCHAR(50) NOT NULL,
	[buy_sell_flag] VARCHAR(50) NOT NULL,
	[curve_id] VARCHAR(150) NULL,
	[fixed_price] [numeric](38, 20) NULL,
	[fixed_price_currency_id] VARCHAR(50)  NULL,
	[option_strike_price] [numeric](38, 20) NULL,
	[deal_volume] [numeric](38, 20) NULL,
	[deal_volume_frequency] VARCHAR(50) NOT NULL,
	[deal_volume_uom_id] VARCHAR(50) NOT NULL,
	[block_description] [varchar](100) NULL,
	[deal_detail_description] [varchar](100) NULL,
	[formula_id] VARCHAR(150) NULL,
	[volume_left] [float] NULL,
	[settlement_volume] [float] NULL,
	[settlement_uom] VARCHAR(50) NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) NULL,
	[update_ts] [datetime] NULL,
	[price_adder] [numeric](38, 20) NULL,
	[price_multiplier] [numeric](38, 20) NULL,
	[settlement_date] [datetime] NULL,
	[day_count_id] VARCHAR(150) NULL,
	[location_id] VARCHAR(150) NULL,
	[meter_id] VARCHAR(50) NULL,
	[physical_financial_flag] VARCHAR(50) NULL,
	[Booked] VARCHAR(50) NULL,
	[process_deal_status] VARCHAR(50) NULL,
	[fixed_cost] [numeric](38, 20) NULL,
	[multiplier] [numeric](38, 20) NULL,
	[adder_currency_id] VARCHAR(50) NULL,
	[fixed_cost_currency_id] VARCHAR(50) NULL,
	[formula_currency_id]VARCHAR(50) NULL,
	[price_adder2] [numeric](38, 20) NULL,
	[price_adder_currency2] VARCHAR(50) NULL,
	[volume_multiplier2] [numeric](38, 20) NULL,
	[total_volume] [numeric](38, 20) NULL,
	[pay_opposite] VARCHAR(50) NULL,
	[capacity] [numeric](38, 20) NULL,
	[settlement_currency] VARCHAR(50) NULL,
	[standard_yearly_volume] [float] NULL,
	[formula_curve_id] VARCHAR(50) NULL,
	[price_uom_id] VARCHAR(50) NULL,
	[category]VARCHAR(50) NULL,
	[profile_code] VARCHAR(50) NULL,
	[pv_party] VARCHAR(50) NULL
)


 SET @sql_select='SELECT [ID],[TermStart] AS [Term Start],[TermEnd] AS [Term End],[Leg],[ExpDate] AS [Expiration Date],[FixedFloat] AS [FixedFloat],      
 [BuySell],[curve_type] AS [Curve Type],[commodity] AS [Commodity],[Physical/Financial] AS [PhysicalFinancial],[Location],['+@label_index+'],[Volume],      
 [Frequency],[UOM],[TotalVolume],[Position UOM],[Capacity],['+@label_price+'],[Fixed Cost],[Fixed Cost Currency],[Formula Price],[Formula Currency],[OptionStrike] AS [OptStrikePrice],[PriceAdder],[Adder Currency],VolumeMultiplier,[PriceMultiplier],[Currency],[PriceAdder2],[AdderCurrency2],VolumeMultiplier2,[Meter],      
 [Pay Opposite],[Payment Date],[Formula],[Sett.Currency],SYV ,[Price UOM],Category,Profile ,[Pv Party]      
 FROM(
 SELECT DISTINCT a.source_deal_detail_id AS [ID],      
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
     ROUND(dbo.FNARemoveTrailingZeroes(CAST(deal_volume AS numeric(38,9))),'+@round_value+') as Volume,
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
    ROUND(dbo.FNARemoveTrailingZeroes(CAST(a.total_volume AS numeric(38,9))),'+@round_value+') as [TotalVolume],
    su.uom_name as [Position UOM],          
    dbo.FNARemoveTrailingZeroes(a.capacity) as Capacity,      
    CASE WHEN sdt.expiration_applies =''y'' AND ( a.fixed_price is null and a.formula_id is null)  THEN       
     dbo.FNARemoveTrailingZeroes(rg.contract_price)       
    ELSE       
     dbo.FNARemoveTrailingZeroes(fixed_price) end as ['+@label_price+'],      
    dbo.FNARemoveTrailingZeroes(fixed_cost) AS [Fixed Cost],      
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
    pu.uom_name [Price UOM],
    sdvc.code Category,
    sdvp.Code Profile,
    sdvpv.code [Pv Party]
       
    FROM ' +CASE WHEN isnull(@deleted_deal,'n')='y' then  'delete_source_deal_detail' ELSE 'source_deal_detail' END +' a       
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
 SET @sql_select= @sql_select+ ' AND term_start='''+@term_start+''''      
      
 IF @term_start IS NOT NULL      
 SET @sql_select= @sql_select +' AND term_end='''+@term_end+''''      
       
 SET @sql_select= @sql_select+ ')aa ORDER BY id ASC'      
       
 PRINT @sql_select      
 EXEC(@sql_select)      
End      
--       
-- else if @flag='b'      
--  Begin      
--        
--  set @sql_select='select * into '+@tempheadertable+' from source_deal_header where source_deal_header_id='+cast(@source_deal_header_id as varchar)      
--  exec(@sql_select)      
--        
--  set @sql_select='select * into '+@tempdetailtable+' from source_deal_detail where source_deal_header_id='+cast(@source_deal_header_id as varchar)      
--  PRINT @sql_select      
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
 set @copy_source_deal_id=@@identity      
       
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
   print @term_end_value '      
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
   case when fixed_float_leg=''f'' then ''Fixed'' else ''Float'' end [FixedFloat],      
   case when buy_sell_flag =''b''  then ''Buy(Receive)'' else ''Sell(Pay)'' End [BuySell],      
   curve_type,      
   commodity_id,      
   CASE WHEN       
    physical_financial_flag = ''p'' THEN ''Physical''      
   ELSE ''Financial'' END [Physical/Financial],      
   location_id [Location],      
   curve_id as ['+@label_index +'],      
   null Volume,      
   deal_volume_frequency Frequency,      
   deal_volume_uom_id UOM,      
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
   pv_party PvParty   
   from source_deal_detail_template 
  where template_id='+cast(@template_id as varchar)      
        
 PRINT @sql_Select      
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
 dbo.FNADateFormat(min(sdd.term_start)) AS TermStart,       
 dbo.FNADateFormat(max(sdd.term_end)) AS TermEnd,      
 '+case when @source_deal_detail_id is not null then ' 1 ' else ' sdd.Leg ' end+' AS Leg,      
 max((case sdd.fixed_float_leg when ''f'' then ''Fixed'' Else ''Float'' end)) AS FixedFloat,      
 max(case when buy_sell_flag =''b'' then ''Buy(Receive)'' else ''Sell(Pay)'' End) BuySell,      
       
 max(pcd.source_curve_type_value_id) curve_type,max(pcd.commodity_id) commodity_id,      
 CASE WHEN max(physical_financial_flag) = ''p'' THEN ''Physical'' ELSE ''Financial'' END AS [Physical/Financial],      
 max(location_id) Location,      
 max(sdd.curve_id) [Index],      
 NULL AS Volume, --dbo.FNARemoveTrailingZeroes(max(deal_volume)) AS Volume,      
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
 max(meter_id) Meter,      
 max(sdd.pay_opposite) as [PayOpposite],      
 -- Strip Month From      
 -- Lag Months      
 -- Strip Month To      
 max(day_count_id) [Day Count],      
 NULL LocationName,      
 NULL CurveName,  
 max(sdd.settlement_currency) as [Sett.Currency],      
 NULL  AS [SYV], --max(sdd.standard_yearly_volume) AS [SYV],
 max(price_uom_id) PriceUom,
max(category) Category, 
max(profile_code) ProfileCode,
max(pv_party) PVParty 
from       
 source_deal_detail sdd left outer join       
source_price_curve_def pcd on pcd.source_curve_def_id=sdd.curve_id        
where source_deal_header_id='+cast(@source_deal_header_id as varchar)      
+ case when @source_deal_detail_id is not null then ' And leg='+cast(@bif_leg as varchar) else '' end +      
' group by Leg order by leg '      
      
      
print @sql_select      
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
 print @temp_status      
      
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
      
   set @new_source_deal_id=scope_IDENTITY()      
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
        
   print @tmp_tmeplate_name      
      
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
          
     PRINT @tmp_source_deal_type_id      
     PRINT @tmp_deal_sub_type_type_id      
      
     PRINT @new_deal_id      
           
           
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
            
      SET @new_source_deal_id=scope_IDENTITY()      
               
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





GO

/****** Object:  StoredProcedure [dbo].[spa_Transpose]    Script Date: 12/20/2011 00:25:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--spa_Transpose 'source_deal_header_template','template_id=''57'''
CREATE  PROC [dbo].[spa_Transpose] 
@TableName VARCHAR(200),
@where VARCHAR(200)=NULL 
AS 
 declare @TableSchema sysname

SET @TableSchema='dbo'
 DECLARE @N INT 
 
  DECLARE @cols TABLE( 
    idx INT NOT NULL IDENTITY(1, 1) PRIMARY KEY, 
    col VARCHAR(150) NOT NULL ) 
 
  INSERT INTO @cols 
  SELECT COLUMN_NAME  AS col 
  FROM   INFORMATION_SCHEMA.COLUMNS 
  WHERE  TABLE_NAME = @TableName

  SET @N = @@ROWCOUNT 
    
  DECLARE @collist nvarchar(max),@fieldlist nvarchar(max)  
 
 SELECT @collist = COALESCE(@collist + ',', '') + QUOTENAME(col),@fieldlist=COALESCE(@fieldlist + ',', '') + QUOTENAME(col)  +' varchar(150)'
 FROM   @cols   
 PRINT  @collist
 PRINT  @fieldlist
 
   CREATE TABLE #tempTable( 
    idx INT NOT NULL IDENTITY(1, 1) PRIMARY KEY
   ) 
   
  EXEC('alter table #tempTable add '+ @fieldlist) 

	IF @where IS NOT NULL 
		SET @where=' where '+ @where 
	ELSE 
		SET @where=' '
		 
   EXEC('INSERT  #tempTable('+ @collist +')
   select '+@collist+' from '+@TableName+' '+ @where +'
   ')

DECLARE @dynsql varchar(max) 
set @dynsql='SELECT col, colval 
FROM (SELECT '+ @collist +'
FROM #tempTable ) p 
UNPIVOT
(ColVal FOR Col IN ('+ @collist +'))
AS unpvt '

PRINT (@dynsql) 
EXEC (@dynsql) 

GO

/****** Object:  StoredProcedure [dbo].[spa_InsertDealXmlBlotterV2]    Script Date: 12/20/2011 00:25:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_InsertDealXmlBlotterV2]
	@flag  VARCHAR(2),
	@book_deal_type_map_id INT,
	@template_id VARCHAR(10),	
	@xmlValue varchar(max)=NULL

AS

/*
DECLARE @flag  VARCHAR(2),
	@source_deal_type_id INT,		-- Not used
	@deal_sub_type_type_id INT,		-- Not used
									-- source_deal_type_id and deal_sub_type_type_id can be obtained from template_id
	@book_deal_type_map_id VARCHAR(50),
	@template_id VARCHAR(10),		-- Not used : Obtained from XML (xmlValue)
	@fas_book_id INT,
	@counterparty_id INT,
	@trader_id INT,
	@broker_id INT,
	@include_tax CHAR(1),
	@option_flag CHAR(1),
	@xmlValue varchar(max),
	@contract_id INT,
	@copy_deal_header_id INT,
	@option_type CHAR(1) ,
	@exercise_type CHAR(1) ,
	@insert_process_table VARCHAR(1)

--exec spa_InsertDealXmlBlotter 'i',NULL,NULL,53,'32',80,  24,6,NULL,'73oea0v0msn1j2o8u606216rp7','n', '<Root><PSRecordset  edit_grid0="1" edit_grid1="32" edit_grid2="" edit_grid3="04-07-2011" edit_grid4="b" edit_grid5="17" edit_grid6="21" edit_grid7="d" edit_grid8="01-08-2011" edit_grid9="01-08-2011" edit_grid10="h" edit_grid11="1321323" edit_grid12="1" edit_grid13="" edit_grid14="24" edit_grid15="" edit_grid16="1" edit_grid17="" edit_grid18="y" edit_grid19="24" edit_grid20="" edit_grid21="6" edit_grid22="" edit_grid23="" edit_grid24="" edit_grid25="" edit_grid26="" edit_grid27="" edit_grid28="0" edit_grid29="" edit_grid30="" edit_grid31="" edit_grid32="" edit_grid33="" edit_grid34="" fixed_float="t" physical_financial_flag="p"></PSRecordset><PSRecordset  edit_grid0="2" edit_grid1="32" edit_grid2="" edit_grid3="04-07-2011" edit_grid4="b" edit_grid5="17" edit_grid6="21" edit_grid7="d" edit_grid8="01-08-2011" edit_grid9="01-08-2011" edit_grid10="h" edit_grid11="1321323" edit_grid12="1" edit_grid13="" edit_grid14="24" edit_grid15="" edit_grid16="1" edit_grid17="" edit_grid18="y" edit_grid19="24" edit_grid20="" edit_grid21="6" edit_grid22="" edit_grid23="" edit_grid24="" edit_grid25="" edit_grid26="" edit_grid27="" edit_grid28="" edit_grid29="" edit_grid30="" edit_grid31="" edit_grid32="" edit_grid33="" edit_grid34="" fixed_float="t" physical_financial_flag="p"></PSRecordset><PSRecordset  edit_grid0="3" edit_grid1="32" edit_grid2="" edit_grid3="04-07-2011" edit_grid4="b" edit_grid5="17" edit_grid6="21" edit_grid7="d" edit_grid8="01-08-2011" edit_grid9="01-08-2011" edit_grid10="h" edit_grid11="1321323" edit_grid12="1" edit_grid13="" edit_grid14="24" edit_grid15="" edit_grid16="1" edit_grid17="" edit_grid18="y" edit_grid19="24" edit_grid20="" edit_grid21="6" edit_grid22="" edit_grid23="" edit_grid24="" edit_grid25="" edit_grid26="" edit_grid27="" edit_grid28="" edit_grid29="" edit_grid30="" edit_grid31="" edit_grid32="" edit_grid33="" edit_grid34="" fixed_float="t" physical_financial_flag="p"></PSRecordset><PSRecordset  edit_grid0="4" edit_grid1="32" edit_grid2="" edit_grid3="04-07-2011" edit_grid4="b" edit_grid5="17" edit_grid6="21" edit_grid7="d" edit_grid8="01-08-2011" edit_grid9="01-08-2011" edit_grid10="h" edit_grid11="1321323" edit_grid12="1" edit_grid13="" edit_grid14="24" edit_grid15="" edit_grid16="1" edit_grid17="" edit_grid18="y" edit_grid19="24" edit_grid20="" edit_grid21="6" edit_grid22="" edit_grid23="" edit_grid24="" edit_grid25="" edit_grid26="" edit_grid27="" edit_grid28="" edit_grid29="" edit_grid30="" edit_grid31="" edit_grid32="" edit_grid33="" edit_grid34="" fixed_float="t" physical_financial_flag="p"></PSRecordset><PSRecordset  edit_grid0="5" edit_grid1="32" edit_grid2="" edit_grid3="04-07-2011" edit_grid4="b" edit_grid5="17" edit_grid6="21" edit_grid7="d" edit_grid8="01-08-2011" edit_grid9="01-08-2011" edit_grid10="h" edit_grid11="1321323" edit_grid12="1" edit_grid13="" edit_grid14="24" edit_grid15="" edit_grid16="1" edit_grid17="" edit_grid18="y" edit_grid19="24" edit_grid20="" edit_grid21="6" edit_grid22="" edit_grid23="" edit_grid24="" edit_grid25="" edit_grid26="" edit_grid27="" edit_grid28="" edit_grid29="" edit_grid30="" edit_grid31="" edit_grid32="" edit_grid33="" edit_grid34="" fixed_float="t" physical_financial_flag="p"></PSRecordset><PSRecordset  edit_grid0="6" edit_grid1="32" edit_grid2="" edit_grid3="04-07-2011" edit_grid4="b" edit_grid5="17" edit_grid6="21" edit_grid7="d" edit_grid8="01-08-2011" edit_grid9="01-08-2011" edit_grid10="h" edit_grid11="1321323" edit_grid12="1" edit_grid13="" edit_grid14="24" edit_grid15="" edit_grid16="1" edit_grid17="" edit_grid18="y" edit_grid19="24" edit_grid20="" edit_grid21="6" edit_grid22="" edit_grid23="" edit_grid24="" edit_grid25="" edit_grid26="" edit_grid27="" edit_grid28="" edit_grid29="" edit_grid30="" edit_grid31="" edit_grid32="" edit_grid33="" edit_grid34="" fixed_float="t" physical_financial_flag="p"></PSRecordset><PSRecordset  edit_grid0="7" edit_grid1="32" edit_grid2="" edit_grid3="04-07-2011" edit_grid4="b" edit_grid5="17" edit_grid6="21" edit_grid7="d" edit_grid8="01-08-2011" edit_grid9="01-08-2011" edit_grid10="h" edit_grid11="1321323" edit_grid12="1" edit_grid13="" edit_grid14="24" edit_grid15="" edit_grid16="1" edit_grid17="" edit_grid18="y" edit_grid19="24" edit_grid20="" edit_grid21="6" edit_grid22="" edit_grid23="" edit_grid24="" edit_grid25="" edit_grid26="" edit_grid27="" edit_grid28="" edit_grid29="" edit_grid30="" edit_grid31="" edit_grid32="" edit_grid33="" edit_grid34="" fixed_float="t" physical_financial_flag="p"></PSRecordset><PSRecordset  edit_grid0="8" edit_grid1="32" edit_grid2="" edit_grid3="04-07-2011" edit_grid4="b" edit_grid5="17" edit_grid6="21" edit_grid7="d" edit_grid8="01-08-2011" edit_grid9="01-08-2011" edit_grid10="h" edit_grid11="1321323" edit_grid12="1" edit_grid13="" edit_grid14="24" edit_grid15="" edit_grid16="1" edit_grid17="" edit_grid18="y" edit_grid19="24" edit_grid20="" edit_grid21="6" edit_grid22="" edit_grid23="" edit_grid24="" edit_grid25="" edit_grid26="" edit_grid27="" edit_grid28="" edit_grid29="" edit_grid30="" edit_grid31="" edit_grid32="" edit_grid33="" edit_grid34="" fixed_float="t" physical_financial_flag="p"></PSRecordset><PSRecordset  edit_grid0="9" edit_grid1="32" edit_grid2="" edit_grid3="04-07-2011" edit_grid4="b" edit_grid5="17" edit_grid6="21" edit_grid7="d" edit_grid8="01-08-2011" edit_grid9="01-08-2011" edit_grid10="h" edit_grid11="1321323" edit_grid12="1" edit_grid13="" edit_grid14="24" edit_grid15="" edit_grid16="1" edit_grid17="" edit_grid18="y" edit_grid19="24" edit_grid20="" edit_grid21="6" edit_grid22="" edit_grid23="" edit_grid24="" edit_grid25="" edit_grid26="" edit_grid27="" edit_grid28="" edit_grid29="" edit_grid30="" edit_grid31="" edit_grid32="" edit_grid33="" edit_grid34="" fixed_float="t" physical_financial_flag="p"></PSRecordset><PSRecordset  edit_grid0="10" edit_grid1="32" edit_grid2="" edit_grid3="04-07-2011" edit_grid4="b" edit_grid5="17" edit_grid6="21" edit_grid7="d" edit_grid8="01-08-2011" edit_grid9="01-08-2011" edit_grid10="h" edit_grid11="1321323" edit_grid12="1" edit_grid13="" edit_grid14="24" edit_grid15="" edit_grid16="1" edit_grid17="" edit_grid18="y" edit_grid19="24" edit_grid20="" edit_grid21="6" edit_grid22="" edit_grid23="" edit_grid24="" edit_grid25="" edit_grid26="" edit_grid27="" edit_grid28="" edit_grid29="" edit_grid30="" edit_grid31="" edit_grid32="" edit_grid33="" edit_grid34="" fixed_float="t" physical_financial_flag="p"></PSRecordset></Root>',  NULL,NULL,null,null,NULL

SELECT 
	@flag='i' ,
	@source_deal_type_id=NULL ,		-- Not used
	@deal_sub_type_type_id=NULL ,		-- Not used
									-- source_deal_type_id and deal_sub_type_type_id can be obtained from template_id
	@book_deal_type_map_id=1 ,
	@template_id='67',		-- Not used : Obtained from XML (xmlValue)
	@fas_book_id= 158,
	@xmlValue= '<Root><PSRecordset> <header  deal_date="2011-12-19" physical_financial_flag="f" trader_id="6" source_deal_type_id="2" counterparty_id="4" header_buy_sell_flag="s" deal_id="t111" udf___5="" row_id="1"/><detail  term_start="2012-01-01" term_end="2012-12-31" curve_id="76" deal_volume="11" deal_volume_uom_id="6" location_id="1" deal_volume_frequency="m" row_id="1"/></PSRecordset><PSRecordset> <header  deal_date="2011-12-19" physical_financial_flag="f" trader_id="6" source_deal_type_id="2" counterparty_id="4" header_buy_sell_flag="s" deal_id="t222" udf___5="" row_id="2"/><detail  term_start="2012-01-01" term_end="2012-12-31" curve_id="76" deal_volume="22" deal_volume_uom_id="6" location_id="1" deal_volume_frequency="m" row_id="2"/></PSRecordset></Root>' ,
	@contract_id=null ,
	@copy_deal_header_id=null ,
	@option_type= null ,
	@exercise_type= null ,
	@insert_process_table =NULL
--DROP TABLE adiha_process.dbo.deal_header_Anoop_123	
--DROP TABLE adiha_process.dbo.deal_header_Anoop_123 	
DROP TABLE adiha_process.dbo.temp_header_Anoop_123
DROP TABLE adiha_process.dbo.temp_detail_Anoop_123
DROP TABLE adiha_process.dbo.report_position_Anoop_123 
drop table #field_template
DROP TABLE #temp_check
DROP TABLE #temp_deal_deatil
DROP TABLE #temp_deal_header
DROP TABLE #template_field_default
DELETE source_deal_detail WHERE source_deal_header_id IN (SELECT source_deal_header_id FROM source_deal_header WHERE deal_id IN ('tf102','tf101'))
DELETE source_deal_header WHERE deal_id IN ('tf102','tf101')
--drop table #temp_header
--drop table #source_deals
--drop table #udf_log */

DECLARE @process_id VARCHAR(50)
SET @process_id = REPLACE(NEWID(),'-','_')
--SET @process_id = '123'


	DECLARE @tempheadertable VARCHAR(MAX),@tempdetailtable VARCHAR(MAX), @user_login_id VARCHAR(100)
	SET  @user_login_id=dbo.FNADBUser()
	SET @tempheadertable=dbo.FNAProcessTableName('deal_header', @user_login_id,@process_id)
	SET @tempdetailtable=dbo.FNAProcessTableName('deal_detail', @user_login_id,@process_id)

	--EXEC('select * into '+@tempheadertable+' from source_deal_header where 1=2')
	--EXEC('select * into '+@tempdetailtable+' from source_deal_detail where 1=2')
	DECLARE @temp_header VARCHAR(150),@temp_detail VARCHAR(150)
	SET @temp_header=dbo.FNAProcessTableName('temp_header', @user_login_id,@process_id)
	SET @temp_detail=dbo.FNAProcessTableName('temp_detail', @user_login_id,@process_id)

DECLARE @sql VARCHAR(8000),@header_temp_field VARCHAR(MAX),@detail_temp_field VARCHAR(MAX) 
DECLARE @desc VARCHAR(500)

	
DECLARE @doc VARCHAR(1000),@field_template_id INT 
SELECT @field_template_id=field_template_id FROM dbo.source_deal_header_template WHERE template_id=@template_id

CREATE TABLE #field_template(
	[farrms_field_id] VARCHAR(50),
	[field_group_id] [int] NULL,
	[default_label] varchar(100),
	[seq_no] [int] NULL,
	field_type CHAR(1),
	data_type VARCHAR(50),
	[validation_id] [int] NULL,
	header_detail CHAR(1),
	system_requried CHAR(1),
	sql_string VARCHAR(5000),
	field_size VARCHAR(50),
	system_is_disable CHAR(1),
	window_function_id VARCHAR(500),
	field_template_detail_id INT,
	[udf_or_system] [char](1) NULL,
	[is_disable] [char](1) NULL,
	[insert_required] [char](1) NULL,
	hide_control CHAR(1),
	[default_value] [varchar](150) NULL,
	[min_value] [float] NULL,
	[max_value] [float] NULL,
	[field_id] VARCHAR(50) NULL,
	)
INSERT #field_template
EXEC spa_template_deal_field_format 'm',NULL,NULL,67,NULL


DECLARE @farrms_field_id VARCHAR(100),@xml_field VARCHAR(8000),@sql_xml VARCHAR(MAX),@header_detail CHAR(1),
@xml_field_detail VARCHAR(8000),@sql_detail VARCHAR(MAX),@header_udf_field VARCHAR(MAX), @detail_udf_field VARCHAR(MAX),@udf_or_system CHAR(1)
SET @header_temp_field=''
SET @xml_field=''
SET @detail_temp_field=''
SET @xml_field_detail=''
SET @header_udf_field=''
SET @detail_udf_field=''
		DECLARE dealCur CURSOR  FORWARD_ONLY READ_ONLY FOR
		SELECT farrms_field_id,header_detail,udf_or_system FROM #field_template
		OPEN dealCur
		FETCH NEXT FROM dealCur into @farrms_field_id,@header_detail,@udf_or_system
		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF @header_detail='h'
			BEGIN 
				IF @udf_or_system='s'
					set @header_temp_field=@header_temp_field+' '+ @farrms_field_id +' ,'		
				ELSE
					set @header_udf_field=@header_udf_field+' '+ @farrms_field_id +' ,'		
					
				set @xml_field=@xml_field+' '+ @farrms_field_id +' varchar(150) ''@'+ @farrms_field_id +''','		
			END 
			ELSE
			BEGIN 
				IF @udf_or_system='s'
					set @detail_temp_field=@detail_temp_field+' '+ @farrms_field_id +' ,'		
				ELSE
					set @detail_udf_field=@detail_udf_field+' '+ @farrms_field_id +' ,'		
					
						
				set @xml_field_detail=@xml_field_detail+' '+ @farrms_field_id +' varchar(150) ''@'+ @farrms_field_id +''','		
			END 
			FETCH NEXT FROM dealCur into @farrms_field_id,@header_detail,@udf_or_system
		end
		close dealCur
		deallocate dealCur
		if len(@header_temp_field)>1
		BEGIN
			set @header_temp_field=@header_temp_field+' row_id'
			set @detail_temp_field=@detail_temp_field+' row_id'
		
			IF LEN(@header_udf_field)>1
				set @header_udf_field=left(@header_udf_field,len(@header_udf_field)-1)
		
			IF LEN(@detail_udf_field)>1
				set @detail_udf_field=left(@detail_udf_field,len(@detail_udf_field)-1)
			
		end 
		if len(@xml_field)>1
		BEGIN
			set @xml_field=@xml_field+' row_id int ''@row_id'''
			set @xml_field_detail=@xml_field_detail+'  row_id int ''@row_id'''
			
		end 	



--CREATE TABLE #temp_header(id INT)
--CREATE TABLE #udf_log (deal_header_id INT, template_id INT )

-------------------------------------------------------------------
SET @sql_xml='
DECLARE @idoc INT
EXEC sp_xml_preparedocument @idoc OUTPUT, '''+ @xmlValue+'''
 SELECT '+ @header_temp_field + CASE WHEN LEN(@header_udf_field)>1 THEN ','+ @header_udf_field ELSE '' END  +'	
INTO '+@temp_header+'
FROM   OPENXML (@idoc, ''/Root/PSRecordset/header'',2)
WITH ( '+@xml_field+'	
)
EXEC sp_xml_removedocument @idoc
'
PRINT @sql_xml
EXEC(@sql_xml)
--EXEC('SELECT * FROM '+ @temp_header )

SET @sql_xml='
DECLARE @idoc2 INT
EXEC sp_xml_preparedocument @idoc2 OUTPUT, '''+ @xmlValue+'''
 SELECT '+ @detail_temp_field + CASE WHEN LEN(@detail_udf_field)>1 THEN ','+ @detail_udf_field ELSE '' END +'	
INTO '+@temp_detail+'
FROM   OPENXML (@idoc2, ''/Root/PSRecordset/detail'',2)
WITH ( '+@xml_field_detail+'	
)
EXEC sp_xml_removedocument @idoc2
'
PRINT 'detail'
PRINT @sql_xml
EXEC(@sql_xml)


EXEC('delete '+ @temp_detail +' where row_id in (select row_id from  '+ @temp_header +'  where deal_id is null or rtrim(ltrim(deal_id))='''')')
EXEC('delete '+ @temp_header +' where deal_id is null or rtrim(ltrim(deal_id))=''''')

---VALIDATION
DECLARE @temp_deal_id VARCHAR(50)
	CREATE TABLE #temp_check(
	temp_id VARCHAR(50)
	)
	EXEC('insert #temp_check 
	SELECT sd.deal_id FROM source_deal_header sdh  INNER JOIN '+ @temp_header +' sd ON sd.deal_id=sdh.deal_id AND sd.deal_id<>''''
	')
	SELECT @temp_deal_id=temp_id FROM #temp_check
	
		IF(@temp_deal_id IS NOT NULL)
		BEGIN
			EXEC spa_ErrorHandler -1, 'Error', 
					'spa_InsertDealXmlBlotter', 'DB Error', 
					'Deal with same ID has already been inserted.', ''
						
			RETURN
		END
		
----Get Default value from Deal Template		
	CREATE TABLE #template_field_default(
		sno INT IDENTITY(1,1),
		col VARCHAR(150),
		colval VARCHAR(200)
	)
	DECLARE @where VARCHAR(100)
	SET @where='template_id='+ @template_id 
	INSERT #template_field_default
	EXEC spa_Transpose 'source_deal_header_template',@where
	
	UPDATE #template_field_default SET col='header_buy_sell_flag' WHERE col='buy_sell_flag'
			
	DECLARE @default_value	VARCHAR(150),@create_field VARCHAR(MAX)
	
	SET @create_field =''
		
	SELECT @create_field =@create_field +farrms_field_id +' VARCHAR(100) ' + 
		 case when ISNULL(d.colval,default_value) is not null then ' default '''+ ISNULL(d.colval,default_value) +''',' else ',' end 
		 FROM FNAGetTemplateFieldTable(@field_template_id,'h') f LEFT OUTER JOIN #template_field_default  d 
		 ON f.farrms_field_id=d.col 
		 WHERE f.farrms_field_id NOT IN ('template_id')
	
	
	CREATE TABLE #temp_deal_header(
		sno INT IDENTITY(1,1)
	)
	exec('ALTER TABLE #temp_deal_header add '+ @create_field +' row_id int')

	exec('insert #temp_deal_header('+@header_temp_field +')
	select '+ @header_temp_field+' from '+ @temp_header +' a                    
	') 
	
	-----Deal Detail Templates
	DELETE #template_field_default
	
	INSERT #template_field_default
	EXEC spa_Transpose 'source_deal_detail_template',@where

	SET @create_field=''
	
	SELECT @create_field =@create_field +farrms_field_id +' VARCHAR(100) ' + 
		 case when ISNULL(d.colval,default_value) is not null then ' default '''+ ISNULL(d.colval,default_value) +''',' else ',' end 
		 FROM FNAGetTemplateFieldTable(@field_template_id,'d') f LEFT OUTER JOIN #template_field_default  d 
		 ON f.farrms_field_id=d.col 

	 CREATE TABLE #temp_deal_deatil(
		sno INT IDENTITY(1,1)
	 )
	 
	 exec('ALTER TABLE #temp_deal_deatil add '+ @create_field +' row_id int')

	exec('insert #temp_deal_deatil('+ @detail_temp_field +')
	select '+ @detail_temp_field+' from '+ @temp_detail +' a 
	')
---- Default value End

	
	update #temp_deal_header
	set source_system_book_id1=ssbm.source_system_book_id1,
	source_system_book_id2=ssbm.source_system_book_id2,
	source_system_book_id3=ssbm.source_system_book_id3,
	source_system_book_id4=ssbm.source_system_book_id4
	from #temp_deal_header t join source_system_book_map ssbm ON ssbm.book_deal_type_map_id=@book_deal_type_map_id 
	
	update #temp_deal_header
	set entire_term_end=d.term_start,
	entire_term_start=d.term_end
	from #temp_deal_header h join #temp_deal_deatil d ON h.row_id=d.row_id
	
	--deal_category_value_id
	
	SET @create_field =''
	SELECT @create_field =@create_field +farrms_field_id +',' FROM FNAGetTemplateFieldTable(@field_template_id,'h') j 
	SET @create_field=LEFT(@create_field,LEN(@create_field)-1)
	
	SET @sql='insert source_deal_header('+ @create_field +',template_id)
	select '+@create_field +','+@template_id+' from #temp_deal_header'
	PRINT @sql
	EXEC(@sql)
		 			
		 			
	DECLARE @detailcollist varchar(max)
	SELECT @detailcollist = COALESCE(@detailcollist + ',', '') + QUOTENAME(farrms_field_id)
	FROM   FNAGetTemplateFieldTable(@field_template_id,'d')
	WHERE farrms_field_id NOT IN ('term_start','term_end','contract_expiration_date',
	'settlement_date','deal_volume','physical_financial_flag','buy_sell_flag')
--

DECLARE @term_frequency VARCHAR(1),@entire_term_start DATETIME ,@entire_term_end DATETIME ,@row_id INT ,@adder INT,@frequency INT,
@new_entire_term_end DATETIME,@volume_frequency INT , @count INT,@contract_expiration_date DATETIME, @settlement_date DATETIME ,
@price_adder_currency2 INT, @volume_multiplier2 FLOAT, @fixed_float_leg CHAR(1), @index VARCHAR(10),
@source_deal_header_id INT,@vol numeric(38,20) ,@physical_financial_flag CHAR(1),@buy_sell_flag CHAR(1),@temp_source_deal_header_id VARCHAR(MAX)

SET @count=0
				
	DECLARE b_cursor CURSOR FOR
	SELECT deal_volume_frequency,CAST(term_start AS DATETIME),CAST(term_end AS DATETIME),t.row_id,curve_id,
	sdh.source_deal_header_id,deal_volume,ISNULL(t.physical_financial_flag,sdh.physical_financial_flag),ISNULL(t.buy_sell_flag,sdh.header_buy_sell_flag)  
	FROM #temp_deal_deatil t JOIN #temp_deal_header h ON t.row_id=h.row_id
	JOIN source_deal_header sdh ON h.deal_id=sdh.deal_id 
	OPEN b_cursor
		FETCH NEXT FROM b_cursor
		INTO	@term_frequency ,@entire_term_start  ,@entire_term_end  ,@row_id ,@index,@source_deal_header_id,@vol ,@physical_financial_flag,@buy_sell_flag
				
		WHILE @@FETCH_STATUS = 0   
		BEGIN 
		--@frequency1,@b_s_flag,@expt_date,@index,@capacity,@price,@fixed_cost,@currency,@formula,@pay_opposite,@vol,@uom,@entire_term_start,@entire_term_end,@term_frequency,@source_deal_header_id, @option_strike_price,@price_adder,@volume_multiplier ,@price_multiplier,@price_adder2 , @price_adder_currency2 ,@volume_multiplier2 ,@location_id,@contract_expiration_date,@physical_financial_flag,@fixed_float
		SET  @temp_source_deal_header_id = COALESCE(@temp_source_deal_header_id + ',', '') + CAST(@source_deal_header_id AS VARCHAR)
		
			SET @adder=1
			IF @term_frequency='m' 
				 SELECT @frequency=DATEDIFF(month,@entire_term_start,@entire_term_end)
			ELSE IF @term_frequency='q'
			BEGIN
				SELECT @frequency=DATEDIFF(month,@entire_term_start,@entire_term_end)	
				SELECT @frequency=ROUND(@frequency/3,0)
			END
			ELSE IF @term_frequency='s'
			BEGIN
				SELECT @frequency=DATEDIFF(month,@entire_term_start,@entire_term_end)	
				SELECT 	@frequency=ROUND(@frequency/6,0)
			END
			ELSE IF @term_frequency='a'
			BEGIN
				SELECT @frequency=DATEDIFF(month,@entire_term_start,@entire_term_end)	
				SELECT 	@frequency=ROUND(@frequency/12,0)
			END
			ELSE IF @term_frequency='d'
				SELECT @frequency=DATEDIFF(day,@entire_term_start,@entire_term_end)
			ELSE IF @term_frequency='h'
				SELECT @frequency=0
			ELSE IF @term_frequency='w'
			BEGIN
				SELECT @frequency=DATEDIFF(week,@entire_term_start,@entire_term_end)	
			END
					--  select @frequency=isnull(@hour_to, @hour_from) -@hour_from

			SET @new_entire_term_end = @entire_term_end
			SET @frequency = @frequency + 1
			SET @volume_frequency = @frequency
			PRINT @frequency
			WHILE @frequency > 0
			BEGIN
			
				IF (@frequency - 1) > 0
				BEGIN
					SET @entire_term_end = dbo.FNAGetTermEndDate(@term_frequency,@entire_term_start,0)
				END 
				ELSE
					SET @entire_term_end = @new_entire_term_end				

				DECLARE @deal_volume_div FLOAT
				SET @deal_volume_div=1
				PRINT '-----#########'
				PRINT 	@deal_volume_div
				PRINT '####################'

				SET @contract_expiration_date=NULL
				SET @settlement_date=NULL
						 
				SELECT  
					@settlement_date=COALESCE(hd.settlement_date,hd.exp_date,@entire_term_end),
					@contract_expiration_date=COALESCE(hd.exp_date,hd2.exp_date,@entire_term_end)
				FROM  
					 source_price_curve_def spcd 
					 LEFT JOIN holiday_group hd ON spcd.exp_calendar_id=hd.hol_group_value_id AND hd.hol_date=@entire_term_start
					 LEFT JOIN holiday_group hd2 ON spcd.exp_calendar_id=hd2.hol_group_value_id	
					 AND hd2.hol_date=dbo.FNAGetContractMonth(@entire_term_start)
				WHERE source_curve_def_id=@index						 

				IF @settlement_date IS NULL
				   SET @settlement_date=@entire_term_end
				IF @contract_expiration_date IS NULL
				   SET @contract_expiration_date=@entire_term_end
				

				IF @price_adder_currency2 < 1 
					SET @price_adder_currency2 = NULL

				SET @sql='
						insert into source_deal_detail
						 (
							source_deal_header_id,
							term_start,
							term_end,
							contract_expiration_date,
							settlement_date,
							deal_volume,
							physical_financial_flag,buy_sell_flag,
							'+@detailcollist +'
						 )
						SELECT '+ CAST(@source_deal_header_id  AS VARCHAR) +','''+ 
						CAST(@entire_term_start AS VARCHAR)+''','''+ 
						CAST(@entire_term_end AS VARCHAR) +''','''+ 
						CAST(@contract_expiration_date AS VARCHAR) +''','''+ 
						CAST(@settlement_date AS VARCHAR) +''','+ 
					   ISNULL(CAST((@vol / @deal_volume_div) AS VARCHAR), 'null') +','''+
					   @physical_financial_flag +''','''+ @buy_sell_flag +''','+
						@detailcollist +' from #temp_deal_deatil where row_id='+CAST(@row_id AS VARCHAR)
	   
				PRINT @entire_term_end
				PRINT @sql	
				PRINT @source_deal_header_id
				EXEC(@sql)
				SET @count=@count+1
				SET @entire_term_start = dbo.FNAGetTermStartDate(@term_frequency,@entire_term_start,1)					
				SET @frequency=@frequency-1
									
				
			END

		

			--IF ISNULL(@insert_process_table,'n')='n'
			--BEGIN
			--	EXEC spa_compliance_workflow 109,'i',@source_deal_header_id,'Deal',NULL
			--	EXEC spa_compliance_workflow 112,'i',@source_deal_header_id
			--END

			--PRINT 'before spa_deal_transfer_auto'
			--INSERT INTO #tt (code ,description) EXEC spa_deal_transfer_auto @source_deal_header_id
			--PRINT 'after spa_deal_transfer_auto'
			--IF EXISTS (SELECT 'x' FROM #tt WHERE code<0)
			--BEGIN
			--	SELECT @desc=description FROM #tt WHERE code<0
			--	RAISERROR ( 'CatchError', 16, 1 )
			--END	 
			--DELETE FROM #tt

			FETCH NEXT FROM b_cursor
			INTO @term_frequency ,@entire_term_start  ,@entire_term_end  ,@row_id ,@index,@source_deal_header_id,@vol ,@physical_financial_flag,@buy_sell_flag
			
		END
	
		CLOSE b_cursor
		DEALLOCATE  b_cursor
		PRINT 'end cursor'
		
		PRINT @temp_source_deal_header_id


	DECLARE @report_position_deals VARCHAR(300)

	SET @report_position_deals = dbo.FNAProcessTableName('report_position', @user_login_id,@process_id)

	EXEC ('CREATE TABLE ' + @report_position_deals + '( source_deal_header_id INT, action CHAR(1))')
	
	SET @sql = 'INSERT INTO ' + @report_position_deals + '(source_deal_header_id,action) 
	SELECT item,''i'' from dbo.splitCommaSeperatedValues('''+@temp_source_deal_header_id+''')'
	EXEC(@sql)
	
	exec spa_update_deal_total_volume NULL, @process_id  ,0,null,@user_login_id,'y'
	
	
				
		EXEC spa_ErrorHandler 0, 'Success', 
						'spa_InsertDealXmlBlotter', 'Success', 
						'The Deals are successfully saved.', @temp_source_deal_header_id	
GO


/****** Object:  StoredProcedure [dbo].[spa_UpdateFromXml]    Script Date: 12/20/2011 01:10:08 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_UpdateFromXml]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_UpdateFromXml]
GO

/****** Object:  StoredProcedure [dbo].[spa_DoTransaction]    Script Date: 12/20/2011 01:10:08 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_DoTransaction]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_DoTransaction]
GO

/****** Object:  StoredProcedure [dbo].[spa_source_minor_location]    Script Date: 12/20/2011 01:10:08 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_source_minor_location]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_source_minor_location]
GO

/****** Object:  StoredProcedure [dbo].[spa_source_minor_location_paging]    Script Date: 12/20/2011 01:10:09 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_source_minor_location_paging]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_source_minor_location_paging]
GO


/****** Object:  StoredProcedure [dbo].[spa_UpdateFromXml]    Script Date: 12/20/2011 01:10:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE procedure [dbo].[spa_UpdateFromXml]  
 @xmlValue TEXT,  
 @process_id VARCHAR(200),  
 @call_from varchar(10)=NULL,-- call from settlement  
 @source_deal_header_id INT = NULL,  
 @not_confirmed CHAR(1),  -- Deal Confirm Status  
 @deal_date varchar(20) = NULL,  
 @save CHAR(1) = 'n'  
AS  
 /*
declare @xmlValue varchar(max),  
 @process_id VARCHAR(200),  
 @call_from varchar(10),-- call from settlement  
 @source_deal_header_id INT ,  
 @not_confirmed CHAR(1),  -- Deal Confirm Status  
 @deal_date varchar(20) ,  
 @save CHAR(1)  
  
  
select  @xmlValue ='<Root><PSRecordset  source_deal_detail_id="44" fixed_float_leg="t" term_start="01-01-2011" term_end="31-01-2011" 
contract_expiration_date="31-01-2011" leg="1" deal_detail_description="" buy_sell_flag="b" source_deal_header_id="2" 
fixed_price_currency_id="2" deal_volume_frequency="h" deal_volume_uom_id="1" volume_left="" curve_id="76" 
fixed_price="56.75" block_description="" formula_id="" pv_party="292048"></PSRecordset>
<PSRecordset  source_deal_detail_id="43" fixed_float_leg="t" term_start="01-02-2011" term_end="28-02-2011" 
contract_expiration_date="28-02-2011" leg="1" deal_detail_description="" buy_sell_flag="b" source_deal_header_id="2" 
fixed_price_currency_id="5" deal_volume_frequency="h" deal_volume_uom_id="1" volume_left="" curve_id="76" 
fixed_price="56.75" block_description="" formula_id="" pv_party="292048"></PSRecordset><PSRecordset  
source_deal_detail_id="45" fixed_float_leg="t" term_start="01-03-2011" term_end="31-03-2011" contract_expiration_date="31-03-2011" 
leg="1" deal_detail_description="" buy_sell_flag="b" source_deal_header_id="2" fixed_price_currency_id="2" 
deal_volume_frequency="h" deal_volume_uom_id="1" volume_left="" curve_id="76" fixed_price="56.75" block_description="" formula_id="" 
pv_party="292048"></PSRecordset></Root>'
SET @process_id='7FF694FD_7549_4CE0_82E6_651D8BC8A5EC'  
set @call_from=null-- call from settlement  
SET @source_deal_header_id =2 
set @not_confirmed ='y'  -- Deal Confirm Status  
set @deal_date= '25-06-2010'
set @save ='y'  
  
drop table #ztbl_xmlvalue  
drop table #tbl_olddata  
drop table #scs_error_handler  
drop table #handle_sp_return_update  
  
  
  
--*/  
SET NOCOUNT ON  
DECLARE @sql VARCHAR(8000)  
DECLARE @tempdetailtable varchar(100)  
DECLARE @user_login_id varchar(100)  
DECLARE @convert_uom_id int  
DECLARE @convert_settlement_uom_id INT  
DECLARE @count_new INT, @count_unchanged INT  
DECLARE @url VARCHAR(5000)  
DECLARE @job_name VARCHAR(100)  
  
DECLARE @spa VARCHAR(8000)   
--DECLARE @report_position_process_id VARCHAR(200)  
  
  
SET @convert_uom_id=24  
SET @convert_settlement_uom_id=27  
  
SET @user_login_id=dbo.FNADBUser()  
  
CREATE TABLE #handle_sp_return_update(  
   [ErrorCode] VARCHAR(100),  
   [Module]  VARCHAR(500),  
   [Area]  VARCHAR(100),  
   [Status] VARCHAR(100),  
   [Message] VARCHAR(500),  
   [Recommendation] VARCHAR(500)    
  )    
  
DECLARE @idoc int  
DECLARE @doc varchar(1000)  
  
--Calculate MTM from Deal options. 0 means do not calculate, 1 calculate  
 DECLARE @calculate_MTM_from_deal INT  
 SELECT    
  @calculate_MTM_from_deal =  var_value  
 FROM  
   adiha_default_codes_values  
 WHERE       
  (instance_no = 1) AND (default_code_id = 41) AND (seq_no = 1)  
  
  
EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlValue  
  
DECLARE @format varchar(20)  
DECLARE @date_style INT   
  
SELECT @format = date_format from APPLICATION_USERS AU INNER JOIN   
  REGION r ON r.region_id = AU.region_id AND AU.user_login_id = dbo.FNADBUser()  
  
set @date_style = CASE    
      WHEN (@format = 'mm/dd/yyyy') THEN 102  
      WHEN (@format = 'mm-dd-yyyy') THEN 110  
      WHEN (@format = 'dd/mm/yyyy') THEN 103  
      WHEN (@format = 'dd.mm.yyyy') THEN 104  
      WHEN (@format = 'dd-mm-yyyy') THEN 105  
     END  
  
  
  
-----------------------------------------------------------------  
SELECT  
 source_deal_detail_id,  
 dbo.FNACovertToSTDDate(term_start) AS term_start,  
 dbo.FNACovertToSTDDate(term_end) AS term_end,  
-- term_start,  
-- term_end,   
 leg,  
 dbo.FNACovertToSTDDate(contract_expiration_date) AS contract_expiration_date,  
-- contract_expiration_date,   
 fixed_float_leg,  
 buy_sell_flag,  
 physical_financial_flag,  
 location_id,  
 curve_id,  
 deal_volume,  
 deal_volume_frequency,  
 deal_volume_uom_id,  
 capacity,  
 fixed_price,  
 fixed_cost,  
 NULLIF(fixed_cost_currency_id,'')fixed_cost_currency_id,  
 formula_id,  
 NULLIF(formula_currency_id,'')formula_currency_id,  
 option_strike_price,  
 price_adder,  
 NULLIF(adder_currency_id,'')adder_currency_id,  
 price_multiplier,  
 multiplier,  
 fixed_price_currency_id,  
 price_adder2,  
 NULLIF(price_adder_currency2,'')price_adder_currency2,  
 volume_multiplier2,  
 meter_id,  
 pay_opposite,  
 dbo.FNACovertToSTDDate(settlement_date) AS settlement_date,  
-- settlement_date,   
 block_description ,
    settlement_currency  ,
    standard_yearly_volume  ,
      price_uom_id ,  
  category ,
  profile_code , 
  pv_party ,
  deal_detail_description   
INTO   
 #ztbl_xmlvalue  
FROM     
 OPENXML (@idoc, '/Root/PSRecordset',2)  
 WITH (  
  source_deal_detail_id INT    '@source_deal_detail_id',  
  term_start VARCHAR(20)     '@term_start',  
  term_end  VARCHAR(20)     '@term_end',  
  leg  CHAR(5)       '@leg',  
  contract_expiration_date VARCHAR(20) '@contract_expiration_date',  
  fixed_float_leg  CHAR(1)    '@fixed_float_leg',    
  buy_sell_flag  CHAR(1)     '@buy_sell_flag',  
  physical_financial_flag VARCHAR(100) '@physical_financial_flag',  
  location_id INT       '@location_id',    
  curve_id  VARCHAR(100)     '@curve_id',  
  deal_volume  VARCHAR(100)    '@deal_volume',  
  deal_volume_frequency  CHAR(1)   '@deal_volume_frequency',  
  deal_volume_uom_id  VARCHAR(100)  '@deal_volume_uom_id',    
  capacity VARCHAR(100)     '@capacity',  
  fixed_price  VARCHAR(100)    '@fixed_price',    
  fixed_cost FLOAT      '@fixed_cost',  
  fixed_cost_currency_id INT    '@fixed_cost_currency_id',  
  formula_id VARCHAR(100)     '@formula_id',  
  formula_currency_id INT     '@formula_currency_id',  
  option_strike_price float    '@option_strike_price',  
  price_adder VARCHAR(100)    '@price_adder', --  
  adder_currency_id INT     '@adder_currency_id',  
  multiplier VARCHAR(100)     '@multiplier', --  
  price_multiplier VARCHAR(100)   '@price_multiplier', --     
  fixed_price_currency_id  VARCHAR(100) '@fixed_price_currency_id',    
  price_adder2 VARCHAR(100)    '@price_adder2', --  
  price_adder_currency2 INT    '@price_adder_currency2',  
  volume_multiplier2 VARCHAR(100)   '@volume_multiplier2', --  
  meter_id INT       '@meter_id',  
  pay_opposite VARCHAR(100)    '@pay_opposite',  
  settlement_date  VARCHAR(20)   '@settlement_date',  
  block_description VARCHAR(100)  '@block_description'  ,
  settlement_currency int  '@settlement_currency'  ,
  standard_yearly_volume float  '@standard_yearly_volume', 
  price_uom_id  int   '@price_uom_id',  
  category int  '@category'  ,
  profile_code int  '@profile_code', 
  pv_party int  '@pv_party',
  deal_detail_description VARCHAR(200) '@deal_detail_description'
  
--  hour_ending        '@edit_grid26'  
--        
--  bonus  VARCHAR(100)   '@edit_grid24',  
--  deal_detail_description  VARCHAR(100) '@edit_grid25'  
 )  

UPDATE #ztbl_xmlvalue SET capacity=NULL WHERE capacity=''  
UPDATE #ztbl_xmlvalue SET curve_id=NULL WHERE curve_id=''  
UPDATE #ztbl_xmlvalue SET price_adder=NULL WHERE price_adder=''  
UPDATE #ztbl_xmlvalue SET price_adder2=NULL WHERE price_adder2=''  
UPDATE #ztbl_xmlvalue SET fixed_price=NULL WHERE fixed_price=''  
update #ztbl_xmlvalue set location_id = NULL where physical_financial_flag = 'f'  
UPDATE #ztbl_xmlvalue SET fixed_cost=NULL WHERE fixed_cost=''  
UPDATE #ztbl_xmlvalue SET option_strike_price=NULL WHERE option_strike_price=''  
UPDATE #ztbl_xmlvalue SET volume_multiplier2=NULL WHERE volume_multiplier2 = ''  
UPDATE #ztbl_xmlvalue SET multiplier=NULL WHERE multiplier = ''  
UPDATE #ztbl_xmlvalue SET price_multiplier=NULL WHERE price_multiplier = ''
UPDATE #ztbl_xmlvalue SET settlement_currency=NULL WHERE settlement_currency = ''
UPDATE #ztbl_xmlvalue SET standard_yearly_volume=NULL WHERE standard_yearly_volume = ''  
UPDATE #ztbl_xmlvalue SET price_uom_id=NULL WHERE price_uom_id = ''  
UPDATE #ztbl_xmlvalue SET category=NULL WHERE category = ''
UPDATE #ztbl_xmlvalue SET profile_code=NULL WHERE profile_code = ''
UPDATE #ztbl_xmlvalue SET pv_party=NULL WHERE pv_party = ''  


DECLARE @report_position_deals VARCHAR(300)  
  
DECLARE @report_position_process_id VARCHAR(500)  
SET @report_position_process_id = REPLACE(newid(),'-','_')  
  
SET @report_position_deals = dbo.FNAProcessTableName('report_position', @user_login_id,@report_position_process_id)  
EXEC ('CREATE TABLE ' + @report_position_deals + '( source_deal_header_id INT, action CHAR(1))')  
   
  
IF NOT EXISTS (  
 SELECT 1 FROM source_deal_detail sdd   
	 INNER JOIN #ztbl_xmlvalue z  
	  ON  z.term_start = sdd.term_start   
	  AND z.term_end = sdd.term_end   
	  AND z.leg = sdd.leg   
	  AND isnull(sdd.buy_sell_flag ,'b')  = isnull(z.buy_sell_flag ,'b') 
	  and isnull(sdd.formula_id,-1)=isnull(z.formula_id,-1)
	  and isnull(sdd.curve_id,-1)=isnull(z.curve_id,-1)  
	  and isnull(sdd.location_id,-1)=isnull(z.location_id,-1)
	  AND ISNULL(sdd.deal_volume,0) = ISNULL(z.deal_volume,0)  
	  AND isnull(sdd.deal_volume_frequency,'m') = ISNULL(z.deal_volume_frequency,'m')  
	  AND ISNULL(sdd.multiplier,1) = ISNULL(z.multiplier,1)  
	  AND ISNULL(sdd.volume_multiplier2,1) = ISNULL(z.volume_multiplier2,1)  
	  AND ISNULL(sdd.pay_opposite,'x') = ISNULL(z.pay_opposite,'x')  
 WHERE sdd.source_deal_header_id = @source_deal_header_id   
)  
BEGIN  
  
 SET @sql = 'INSERT INTO ' + @report_position_deals + '(source_deal_header_id,action) SELECT ' + CAST(@source_deal_header_id AS VARCHAR) + ',''u'''  
 PRINT @sql   
 EXEC (@sql)   
END  
  
--#########################################  
-- Logic Added to see if the deal is already assigned or the updated deal is an assigned deal.  
--#########################################  
  
--##### Fisrt check to see if the Deal has been manually assigned and volume is changed. If so then Give error  
      
IF Exists  
 (  
 select *   
 from   
    #ztbl_xmlvalue tmp  
       INNER JOIN source_deal_detail sdd on tmp.source_deal_detail_id=sdd.source_deal_detail_id  
    INNER JOIN source_deal_header sdh on sdh.source_deal_header_id=sdd.source_deal_header_id  
    INNER JOIN assignment_audit assign on assign.source_deal_header_id_from=sdd.source_deal_detail_id  
    LEFT JOIN rec_generator rg on  rg.generator_id=sdh.generator_id   
    LEFT JOIN rec_generator_assignment gen_assign  
     on rg.generator_id=gen_assign.generator_id and  
     ((sdd.term_start between gen_assign.term_start and gen_assign.term_end) OR  
     (sdd.term_end between gen_assign.term_start and gen_assign.term_end))    
 where 1=1  
    and sdd.deal_volume<>sdd.volume_left and sdd.deal_volume>0    
    and assign.assigned_by <>'Auto Assigned'    
    and assign.assigned_volume<>0  
 )  
 BEGIN  
  
 select   
  @source_deal_header_id = source_deal_header_id   
 from source_deal_detail sdd   
 INNER JOIN #ztbl_xmlvalue z  
  ON z.source_deal_detail_id = sdd.source_deal_detail_id   
  
    
   set @url='<a href="../../dev/spa_html.php?spa=exec spa_create_lifecycle_of_recs '''+ dbo.FNADateFormat(getdate()) +''',NULL,'+cast(@source_deal_header_id as varchar)+'">Click here...</a>'  
  
  
   select 'Error' ErrorCode, 'Source Deal Detail' Module,   
     'spa_UpdateFromXml' Area, 'Error' Status,   
    'Deal ID: '+ cast(@source_deal_header_id as varchar) +' is already assigned, Please remove all the assigned deals first to Update .<br> Please view this report '+@url Message, '' Recommendation  
  RETURN   
  
 END  
  
--## Check to see if the deal is assigned deal. If so then give error  
IF Exists  
 (select * from #ztbl_xmlvalue tmp  
     inner join source_deal_detail sdd on tmp.source_deal_detail_id=sdd.source_deal_detail_id  
     inner join assignment_audit assign on assign.source_deal_header_id=sdd.source_deal_detail_id  
 )  
 BEGIN  
  
  
  select @source_deal_header_id=source_deal_header_id   
    from source_deal_detail sdd where source_deal_detail_id in(select source_deal_detail_id from #ztbl_xmlvalue)  
  
    set @url='<a href="../../dev/spa_html.php?spa=exec spa_create_lifecycle_of_recs '''+ dbo.FNADateFormat(getdate()) +''',NULL,'+cast(@source_deal_header_id as varchar)+'">Click here...</a>'  
    select 'Error' ErrorCode, 'Source Deal Detail' Module,   
      'spa_UpdateFromXml' Area, 'Error' Status,   
     'Deal ID: '+ cast(@source_deal_header_id as varchar) +' is an assigned deal. You cannot update the assigned deal ' Message, '' Recommendation  
  RETURN   
  
 END  
----#################################  
  
     
create table #tbl_olddata  
(  
 source_deal_detail_id INT,  
 term_start DATETIME,  
 term_end  DATETIME,  
 leg  CHAR(1),  
 contract_expiration_date DATETIME,  
 fixed_float_leg  CHAR(1),  
 buy_sell_flag  CHAR(1),  
 physical_financial_flag VARCHAR(100),  
 location_id INT,  
 curve_id  VARCHAR(100),  
 deal_volume  numeric(30,10),  
 deal_volume_frequency  CHAR(1),  
 deal_volume_uom_id  VARCHAR(100),  
 capacity FLOAT,  
 fixed_price  numeric(30,10),  
 fixed_cost FLOAT,  
 fixed_cost_currency_id INT,  
 formula_id  VARCHAR(100),  
 formula_currency_id INT,  
 option_strike_price  FLOAT,      
 price_adder  float,  
 adder_currency_id INT,  
 price_multiplier  float,  
 multiplier FLOAT,  
 fixed_price_currency_id  VARCHAR(100),  
 price_adder2  float,  
 price_adder_currency2 INT,  
 volume_multiplier2  float,  
 meter_id INT,  
 pay_opposite VARCHAR(100),  
 settlement_date  DATETIME,  
 block_description VARCHAR(100) ,
   price_uom_id  int ,  
  category int   ,
  profile_code int , 
  pv_party int 
)  
   
   
   
set @sql=  
'  
insert into #tbl_olddata  
select  
 t.source_deal_detail_id,  
 t.term_start,  
 t.term_end,  
 t.leg, --   
 t.contract_expiration_date,  
 t.fixed_float_leg, --  
 t.buy_sell_flag,  
   
 case   
  when t.physical_financial_flag=''Physical'' then ''p''   
  when t.physical_financial_flag=''p'' then ''p''   
  else ''f'' end,  
 t.location_id,  
   
 CASE WHEN ISNUMERIC(t.curve_id)=1 THEN t.curve_id ELSE NULL END,  
 '+ case when @call_from='s' then ' floor(t.deal_volume * conv.conversion_factor) ' else ' t.deal_volume ' end +',  
 --deal_volume=floor(z.deal_volume * '+ case when @call_from='s' then ' conv.conversion_factor ' else '1' end +'),  
 t.deal_volume_frequency,  
 '+ case when @call_from='s' then CAST(@convert_uom_id as varchar) else 't.deal_volume_uom_id' end +',  
 --deal_volume_uom_id=z.deal_volume_uom_id,  
 cast(t.capacity as numeric(38,20)),  
 CAST(t.fixed_price AS NUMERIC(38,20)),  
 CAST(t.fixed_cost AS NUMERIC(38,20)),  
 CASE WHEN ISNUMERIC(t.fixed_cost_currency_id)=1 THEN t.fixed_cost_currency_id ELSE NULL END,  
 CASE WHEN ISNUMERIC(t.formula_id)=0 THEN NULL ELSE t.formula_id END,  
 CASE WHEN ISNUMERIC(t.formula_currency_id)=1 THEN t.formula_currency_id ELSE NULL END,  
 CAST(t.option_strike_price AS NUMERIC(38,20)),  
 t.price_adder,  
 CASE WHEN ISNUMERIC(t.adder_currency_id)=1 THEN t.adder_currency_id ELSE NULL END,  
 case when isnull(t.price_multiplier,-1)=-1 then 1 else t.price_multiplier end,  
 case when isnull(t.multiplier,-1)=-1 then 1 else t.multiplier end,  
 CASE WHEN ISNUMERIC(t.fixed_price_currency_id)=1 THEN t.fixed_price_currency_id ELSE NULL END,  
 t.price_adder2,  
 CASE WHEN ISNUMERIC(t.price_adder_currency2)=1 THEN t.price_adder_currency2 ELSE NULL END,  
 case when isnull(t.volume_multiplier2,-1)=-1 then 1 else t.volume_multiplier2 end,  
 t.meter_id,  
 t.pay_opposite,  
 t.settlement_date,  
 t.block_description ,
 t.price_uom_id ,  
 t.category   ,
 t.profile_code  , 
 t.pv_party  
FROM   
 #ztbl_xmlvalue z   
 join source_deal_detail t on t.source_deal_detail_id=z.source_deal_detail_id  
 left join rec_volume_unit_conversion Conv ON Conv.from_source_uom_id = z.deal_volume_uom_id             
  AND Conv.to_source_uom_id = '+ISNULL(CAST(@convert_uom_id as varchar),'NULL')+'              
  And Conv.state_value_id IS NULL  
  AND Conv.assignment_type_value_id is null  
  AND Conv.curve_id is null   
 left join rec_volume_unit_conversion Conv1 ON Conv1.from_source_uom_id = z.deal_volume_uom_id             
  AND Conv1.to_source_uom_id = '+ISNULL(CAST(@convert_settlement_uom_id as varchar),'NULL')+'              
  And Conv1.state_value_id IS NULL  
  AND Conv1.assignment_type_value_id is null  
  AND Conv1.curve_id is null    
WHERE   
 1=1 '  
   
print @sql  
exec(@sql)  
  
  
  
SELECT @count_new = COUNT('x') FROM #ztbl_xmlvalue  
   
SELECT   
 @count_unchanged = count('x')   
FROM #ztbl_xmlvalue new  
 INNER JOIN #tbl_olddata old  
  ON old.source_deal_detail_id = new.source_deal_detail_id  
  and isnull(old.deal_volume,-1) = isnull(new.deal_volume,-1)  
  and old.deal_volume_uom_id = new.deal_volume_uom_id  
  AND isnull(old.capacity,-1) = isnull(new.capacity,-1)  
  AND isnull(old.fixed_cost,-1) = isnull(new.fixed_cost,-1)  
  AND isnull(old.fixed_price,-1) = isnull(new.fixed_price,-1)  
  AND isnull(old.option_strike_price,-1) = isnull(new.option_strike_price,-1)  
  and isnull(old.price_adder,-1) = isnull(new.price_adder,-1)  
  and isnull(old.price_multiplier,-1) = isnull(new.price_multiplier,-1)  
  AND isnull(old.curve_id,-1) = isnull(new.curve_id,-1)  
  AND isnull(old.buy_sell_flag,-1) = isnull(new.buy_sell_flag,-1)  
  AND isnull(old.fixed_cost_currency_id,-1) = isnull(new.fixed_cost_currency_id,-1)  
  AND isnull(old.formula_currency_id,-1) = isnull(new.formula_currency_id,-1)  
  AND isnull(old.adder_currency_id,-1) = isnull(new.adder_currency_id,-1)  
  AND isnull(old.multiplier,-1) = isnull(new.multiplier,-1)  
--    
  and isnull(old.price_adder2,-1) = isnull(new.price_adder2,-1)  
  AND isnull(old.price_adder_currency2,-1) = isnull(new.price_adder_currency2,-1)  
  and isnull(old.volume_multiplier2,-1) = isnull(new.volume_multiplier2,-1)  
  AND isnull(old.pay_opposite,-1) = isnull(new.pay_opposite,-1)  
  AND isnull(old.block_description,-1) = isnull(new.block_description,-1)  

  AND isnull(old.price_uom_id,-1) = isnull(new.price_uom_id,-1)  
  and isnull(old.category,-1) = isnull(new.category,-1)  
  AND isnull(old.profile_code,-1) = isnull(new.profile_code,-1)  
  AND isnull(old.pv_party,-1) = isnull(new.pv_party,-1)  
    
if @count_new <> @count_unchanged  
begin   
 set @not_confirmed = 'y'  
end  
    
if @not_confirmed = 'y'  
BEGIN  
   
 declare @tempdate datetime  
 SET @tempdate = GETDATE()  
   
   
 CREATE TABLE #scs_error_handler(  
  error_code VARCHAR(20),  
  module VARCHAR(100),  
  area VARCHAR(100),  
  status VARCHAR(20),  
  msg VARCHAR(100),  
  recommendation VARCHAR(100)  
 )  
   
 INSERT INTO #scs_error_handler (  
  error_code,  
  module,  
  area,  
  status,  
  msg,  
  recommendation  
 )   
  
 -- 'deal' -> call_from flag  
 exec spa_confirm_status 'i',null,@source_deal_header_id,17200,@tempdate,NULL,NULL,NULL,'d'  
   
 IF EXISTS (SELECT 'x' FROM #scs_error_handler WHERE error_code LIKE 'Error')  
 BEGIN  
  RAISERROR('CatchError',16,1)  
 END  
END  
  
--BEGIN TRY  
BEGIN TRAN  
  
-- if @deal_date is not null  
--  update source_deal_header set deal_date = @deal_date where source_deal_header_id = @source_deal_header_id  
  
 declare @source_deal_detail_tmp varchar(300)  
 DECLARE @expiration_date VARCHAR(50)  
 DECLARE @fixed_float_flag VARCHAR(50)  
 DECLARE @location VARCHAR(50)  
 DECLARE @index VARCHAR(50)  
 DECLARE @volume VARCHAR(50)  
 DECLARE @volume_frequency VARCHAR(50)  
 DECLARE @UOM VARCHAR(50)  
 DECLARE @price VARCHAR(50)  
 DECLARE @formula VARCHAR(50)  
 DECLARE @option_strike_price VARCHAR(50)  
 DECLARE @multiplier VARCHAR(50)  
 DECLARE @currency VARCHAR(50)  
 DECLARE @meter VARCHAR(50)  
   
   
 IF @process_id IS NOT NULL AND @process_id <> 'undefined'  
 BEGIN  
  SET @user_login_id=dbo.FNADBUser()  
  SET @source_deal_detail_tmp=dbo.FNAProcessTableName('paging_sourcedealtemp', @user_login_id,@process_id)  
  SET @expiration_date = 'contract_expiration_date'  
  SET @fixed_float_flag = 'fixed_float_leg'  
  SET @location = 'location_id'  
  SET @index = 'curve_id'  
  SET @volume = 'deal_volume'  
  SET @volume_frequency = 'deal_volume_frequency'  
  SET @UOM = 'deal_volume_uom_id'  
  SET @price = 'fixed_price'  
  SET @formula = 'formula_id'  
  SET @option_strike_price = 'option_strike_price'  
  SET @multiplier = 'price_multiplier'  
  SET @currency = 'fixed_price_currency_id'  
  SET @meter = 'meter'  
 END  
 ELSE  
 BEGIN  
  SET @source_deal_detail_tmp = 'source_deal_detail'  
  SET @expiration_date = 'contract_expiration_date'  
  SET @fixed_float_flag = 'fixed_float_leg'  
  SET @location = 'location_id'  
  SET @index = 'curve_id'  
  SET @volume = 'deal_volume'  
  SET @volume_frequency = 'deal_volume_frequency'  
  SET @UOM = 'deal_volume_uom_id'  
  SET @price = 'fixed_price'  
  SET @formula = 'formula_id'  
  SET @option_strike_price = 'option_strike_price'  
  SET @multiplier = 'price_multiplier'  
  SET @currency = 'fixed_price_currency_id'  
  SET @meter = 'meter_id'  
 END  
  
   
 IF @process_id IS NOT NULL AND @process_id <> 'undefined'      
 BEGIN
	 SET @sql = 'UPDATE ' + @source_deal_detail_tmp   
	   + ' SET ' + @fixed_float_flag + ' = CASE ' + @fixed_float_flag + '   
		WHEN ''Float'' THEN ''t''   
		WHEN ''Fixed'' THEN ''f''  
		ELSE ' + @fixed_float_flag + ' END'  
	 PRINT @sql  
	 EXEC (@sql)  
 END
  
   
 declare @call_breakdown bit  
   
   
 IF EXISTS (  
  SELECT 1 FROM source_deal_detail sdd   
  left JOIN #ztbl_xmlvalue z  
   ON  z.term_start = sdd.term_start   
   AND z.term_end = sdd.term_end   
   AND z.leg = sdd.leg   
   and sdd.formula_id=z.formula_id AND sdd.pay_opposite=z.pay_opposite  
   AND sdd.buy_sell_flag = z.buy_sell_flag  
   AND ISNULL(sdd.multiplier,1) = ISNULL(z.multiplier,1)  
   AND ISNULL(sdd.volume_multiplier2,1) = ISNULL(z.volume_multiplier2,1)  
  WHERE sdd.source_deal_header_id = @source_deal_header_id and z.term_start is null   
    
 )  
 BEGIN  
  set @call_breakdown=1  
  PRINT 'test'  
    
 end   
  
  
 set @sql = '  
  UPDATE t  
   SET   
   term_start = z.term_start,  
   term_end = z.term_end,  
   leg = z.leg, --   
   '+@expiration_date+' = z.contract_expiration_date,  
   '+@fixed_float_flag+' = z.fixed_float_leg,  
   buy_sell_flag = z.buy_sell_flag,  
   physical_financial_flag =   
    case   
     when z.physical_financial_flag = ''Physical'' then ''p''   
     when z.physical_financial_flag = ''p'' then ''p''   
     else ''f'' end,  
   '+@location+' = z.location_id,  
   '+@index+' = CASE WHEN ISNUMERIC(z.curve_id) = 1 THEN z.curve_id ELSE NULL END,  
   '+@volume+' = z.deal_volume ,  
   '+@volume_frequency+' = z.deal_volume_frequency,  
   '+@UOM+' = z.deal_volume_uom_id,  
   capacity = cast(z.capacity as numeric(38,20)),  
   '+@price+' = z.fixed_price,  
   fixed_cost = z.fixed_cost,  
   '+@formula+' = CASE WHEN ISNUMERIC(z.formula_id) = 0 THEN NULL ELSE z.formula_id END,  
   '+@option_strike_price+' = z.option_strike_price,  
   price_adder = z.price_adder,  
   '+@multiplier+' = case when isnull(cast(z.price_multiplier as numeric(38,20)),-1) = -1 then 1 else cast(z.price_multiplier as numeric(38,20)) end,  
   '+@currency+' = CASE WHEN ISNUMERIC(z.fixed_price_currency_id) = 1 THEN z.fixed_price_currency_id ELSE NULL END,  
   price_adder2 = z.price_adder2,  
   volume_multiplier2 = case when isnull(cast(z.volume_multiplier2 as numeric(38,20)),-1) = -1 then 1 else cast(z.volume_multiplier2 as numeric(38,20)) end,  
   '+@meter+' = z.meter_id,  
   pay_opposite = z.pay_opposite,  
   settlement_date = z.settlement_date,  
   fixed_cost_currency_id = z.fixed_cost_currency_id,  
   formula_currency_id = z.formula_currency_id,  
   adder_currency_id = z.adder_currency_id,  
   price_adder_currency2 = z.price_adder_currency2,  
   multiplier = z.multiplier,      
   deal_detail_description=z.deal_detail_description,     
   settlement_volume = z.deal_volume*conv1.conversion_factor  ,
   block_description=z.block_description  ,
    settlement_currency=z.settlement_currency,
    standard_yearly_volume=z.standard_yearly_volume,
  price_uom_id=z.price_uom_id,
    category=z.category,
    profile_code=z.profile_code,
    pv_party=z.pv_party
  FROM #ztbl_xmlvalue z   
   join '+ @source_deal_detail_tmp +' t on t.source_deal_detail_id=z.source_deal_detail_id  
   left join rec_volume_unit_conversion Conv ON Conv.from_source_uom_id = z.deal_volume_uom_id             
    AND Conv.to_source_uom_id = '+ISNULL(CAST(@convert_uom_id as varchar),'NULL')+'              
    And Conv.state_value_id IS NULL  
    AND Conv.assignment_type_value_id is null  
    AND Conv.curve_id is null   
   left join rec_volume_unit_conversion Conv1 ON Conv1.from_source_uom_id = z.deal_volume_uom_id             
    AND Conv1.to_source_uom_id = '+ISNULL(CAST(@convert_settlement_uom_id as varchar),'NULL')+'              
    And Conv1.state_value_id IS NULL  
    AND Conv1.assignment_type_value_id is null  
    AND Conv1.curve_id is null    
'  
   
 PRINT @sql  
 EXEC(@sql)  
   
--######################### Changes Made for (IBT) transferred Deals  
-- if the deal is transferred and offset deal is updated, then update the volume of New transferred deal also or vice versa  
-- UPDATE sdd1  
-- SET  
--  sdd1.deal_volume=z.deal_volume,  
--  sdd1.fixed_price=z.fixed_price,  
--  sdd1.fixed_cost=z.fixed_cost,  
--  sdd1.curve_id=z.curve_id,  
--  sdd1.fixed_price_currency_id=z.fixed_price_currency_id,  
--  sdd1.option_strike_price=z.option_strike_price,  
--  sdd1.deal_volume_frequency=z.deal_volume_frequency,  
--  sdd1.deal_volume_uom_id=z.deal_volume_uom_id,  
--  sdd1.price_adder=z.price_adder,  
--  sdd1.price_multiplier=z.price_multiplier  
-- FROM  
--  #ztbl_xmlvalue z   
--  INNER JOIN source_deal_detail sdd on sdd.source_deal_detail_id=z.source_deal_detail_id  
--  INNER JOIN source_deal_header sdh on sdh.source_deal_header_id=sdd.source_deal_header_id  
--  LEFT JOIN  source_deal_header sdh1 on sdh1.close_reference_id=sdh.source_deal_header_id  
--   AND sdh1.deal_reference_type_id=12503  
--  LEFT JOIN source_deal_detail sdd1 on sdd1.source_deal_header_id=sdh1.source_deal_header_id  
--   AND sdd1.term_start=sdd.term_start AND sdd1.leg=sdd1.leg  
--  
---- vice versa  
--  
-- UPDATE sdd1  
-- SET  
--  sdd1.deal_volume=z.deal_volume,  
--  sdd1.fixed_price=z.fixed_price,  
--  sdd1.fixed_cost=z.fixed_cost,  
--  sdd1.curve_id=z.curve_id,  
--  sdd1.fixed_price_currency_id=z.fixed_price_currency_id,  
--  sdd1.option_strike_price=z.option_strike_price,  
--  sdd1.deal_volume_frequency=z.deal_volume_frequency,  
--  sdd1.deal_volume_uom_id=z.deal_volume_uom_id,  
--  sdd1.price_adder=z.price_adder,  
--  sdd1.price_multiplier=z.price_multiplier  
-- FROM  
--  #ztbl_xmlvalue z   
--  INNER JOIN source_deal_detail sdd on sdd.source_deal_detail_id=z.source_deal_detail_id  
--  INNER JOIN source_deal_header sdh on sdh.source_deal_header_id=sdd.source_deal_header_id  
--  LEFT JOIN  source_deal_header sdh1 on sdh1.source_deal_header_id=sdh.close_reference_id  
--   AND sdh.deal_reference_type_id=12503  
--  LEFT JOIN source_deal_detail sdd1 on sdd1.source_deal_header_id=sdh1.source_deal_header_id  
--   AND sdd1.term_start=sdd.term_start AND sdd1.leg=sdd1.leg   
--     
--   
  
  
IF @save = 'y'  
BEGIN  
  
/*  
set @sql='  
  UPDATE t  
   SET   
   term_start = dob.FNAStdDate(z.term_start),  
   term_end = dob.FNAStdDate(z.term_end),  
   leg = CAST(z.leg AS INT),   
   contract_expiration_date=dob.FNAStdDate(z.' + @expiration_date + '),  
   fixed_float_leg = CAST(z.' + @fixed_float_flag + ' AS CHAR(1)),  
   buy_sell_flag= CAST(z.buy_sell_flag AS CHAR(1)),  
   physical_financial_flag = CAST(z.physical_financial_flag AS CHAR(1)),  
   location_id = CAST(z.' + @location + ' AS INT),  
   curve_id = CAST(z.' + @index + ' AS INT),  
   deal_volume = CAST(z.' + @volume + ' AS NUMERIC(38,20)),  
   deal_volume_frequency = CAST(z.' + @volume_frequency + ' AS CHAR(1)),  
   deal_volume_uom_id = CAST(z.' + @UOM + ' AS INT),  
   capacity = cast(z.capacity as numeric(38,20)),  
   fixed_price = CAST(z.' + @price + ' AS NUMERIC(38,20)),  
   fixed_cost = CAST(z.fixed_cost AS NUMERIC(38,20)),  
   formula_id = CAST(z.' + @formula + ' AS INT),  
   option_strike_price = CAST(z.' + @option_strike_price + ' AS NUMERIC(38,20)),  
   price_adder = CAST(z.price_adder AS NUMERIC(38,20)),  
   price_multiplier = CAST(z.price_multiplier AS NUMERIC(38,20)),  
   fixed_price_currency_id = CAST(z.' + @currency + ' AS INT),  
   price_adder2 = CAST(z.price_adder2 AS NUMERIC(38,20)),  
   volume_multiplier2 = CAST(z.volume_multiplier2 AS NUMERIC(38,20)),  
   meter_id = CAST(z.' + @meter + ' AS INT),  
   pay_opposite = z.pay_opposite,  
   settlement_date = dob.FNAStdDate(z.settlement_date),  
   settlement_volume = CAST(z.settlement_volume AS FLOAT),  
   fixed_cost_currency_id = CAST(z.fixed_cost_currency_id AS INT),  
   formula_currency_id = CAST(z.formula_currency_id AS INT),  
   adder_currency_id = CAST(z.adder_currency_id AS INT),  
   price_adder_currency2 = CAST(z.price_adder_currency2 AS INT),  
   multiplier = CAST(z.multiplier AS NUMERIC(38,20))  
   --block_description=CAST(z.block_description as varchar)     
  FROM   
   '+ @source_deal_detail_tmp +' z   
   join source_deal_detail t on t.source_deal_detail_id=z.source_deal_detail_id  
  '  
  
  
*/  
  
  IF @process_id IS NOT NULL AND @process_id <> 'undefined'  
	BEGIN   
	 set @sql='  
	  UPDATE t  
	   SET   
	   term_start = z.term_start,  
	   term_end = z.term_end,  
	   leg = CAST(z.leg AS INT),   
	   contract_expiration_date=z.' + @expiration_date + ',  
	   fixed_float_leg = CAST(z.' + @fixed_float_flag + ' AS CHAR(1)),  
	   buy_sell_flag= CAST(z.buy_sell_flag AS CHAR(1)),  
	   physical_financial_flag = CAST(z.physical_financial_flag AS CHAR(1)),  
	   location_id = CAST(z.' + @location + ' AS INT),  
	   curve_id = CAST(z.' + @index + ' AS INT),  
	   deal_volume = CAST(z.' + @volume + ' AS NUMERIC(38,20)),  
	   deal_volume_frequency = CAST(z.' + @volume_frequency + ' AS CHAR(1)),  
	   deal_volume_uom_id = CAST(z.' + @UOM + ' AS INT),  
	   capacity = cast(z.capacity as numeric(38,20)),  
	   fixed_price = CAST(z.' + @price + ' AS NUMERIC(38,20)),  
	   fixed_cost = CAST(z.fixed_cost AS NUMERIC(38,20)),  
	   formula_id = CAST(z.' + @formula + ' AS INT),  
	   option_strike_price = CAST(z.' + @option_strike_price + ' AS NUMERIC(38,20)),  
	   price_adder = CAST(z.price_adder AS NUMERIC(38,20)),  
	   price_multiplier = CAST(z.price_multiplier AS NUMERIC(38,20)),  
	   fixed_price_currency_id = CAST(z.' + @currency + ' AS INT),  
	   price_adder2 = CAST(z.price_adder2 AS NUMERIC(38,20)),  
	   volume_multiplier2 = CAST(z.volume_multiplier2 AS NUMERIC(38,20)),  
	   meter_id = CAST(z.' + @meter + ' AS INT),  
	   pay_opposite = z.pay_opposite,  
	   settlement_date = z.settlement_date,  
	   settlement_volume = CAST(z.settlement_volume AS FLOAT),  
	   fixed_cost_currency_id = CAST(z.fixed_cost_currency_id AS INT),  
	   formula_currency_id = CAST(z.formula_currency_id AS INT),  
	   adder_currency_id = CAST(z.adder_currency_id AS INT),  
	   price_adder_currency2 = CAST(z.price_adder_currency2 AS INT),  
	   multiplier = CAST(z.multiplier AS NUMERIC(38,20))  ,
	   settlement_currency=z.settlement_currency,
		 standard_yearly_volume=z.standard_yearly_volume,
		 price_uom_id=z.price_uom_id,
		category=z.category,
		profile_code=z.profile_code,
		pv_party=z.pv_party,
	   block_description=CAST(z.block_description as varchar)  ,
	   deal_detail_description=z.deal_detail_description
	  FROM  ' + @source_deal_detail_tmp + ' z 
	      join source_deal_detail t on t.source_deal_detail_id=z.source_deal_detail_id  
	  '  
	 PRINT @sql  
	 EXEC(@sql)   
    
 DECLARE @deal_reference_type_id INT   
 SELECT @deal_reference_type_id = deal_reference_type_id FROM source_deal_header WHERE source_deal_header_id = @source_deal_header_id  
 PRINT @deal_reference_type_id  
 --IF @deal_reference_type_id IS NULL   
    
  SET @sql = 'UPDATE sdd2  
  SET  
   sdd2.deal_volume = CAST(z.' + @volume + ' AS NUMERIC(38,20)),  
   sdd2.fixed_price = CAST(z.' + @price + ' AS NUMERIC(38,20)),  
   sdd2.fixed_cost = CAST(z.fixed_cost AS NUMERIC(38,20)),  
   sdd2.curve_id = CAST(z.' + @index + ' AS INT),  
   sdd2.fixed_price_currency_id = CAST(z.' + @currency + ' AS INT),  
   sdd2.option_strike_price = CAST(z.' + @option_strike_price + ' AS NUMERIC(38,20)),  
   sdd2.deal_volume_frequency = CAST(z.' + @volume_frequency + ' AS CHAR(1)),  
   sdd2.deal_volume_uom_id = CAST(z.' + @UOM + ' AS INT),  
   sdd2.capacity = cast(z.capacity as numeric(38,20)),  
   sdd2.price_adder = CAST(z.price_adder AS NUMERIC(38,20)),  
   sdd2.price_multiplier = CAST(z.price_multiplier AS NUMERIC(38,20)),  
   sdd2.fixed_cost_currency_id = CAST(z.fixed_cost_currency_id AS INT),  
   sdd2.price_adder2 = CAST(z.price_adder2 AS NUMERIC(38,20)),  
   sdd2.volume_multiplier2 = CAST(z.volume_multiplier2 AS NUMERIC(38,20)),  
   sdd2.formula_currency_id = CAST(z.formula_currency_id AS INT),  
   sdd2.adder_currency_id = CAST(z.adder_currency_id AS INT),  
   sdd2.price_adder_currency2 = CAST(z.price_adder_currency2 AS INT),  
   sdd2.multiplier =  CAST(z.multiplier AS NUMERIC(38,20)),  
   sdd2.pay_opposite = z.pay_opposite,
   sdd2.settlement_currency=z.settlement_currency,
   sdd2.standard_yearly_volume=z.standard_yearly_volume,
   sdd2.price_uom_id=z.price_uom_id,
   sdd2.category=z.category,
   sdd2.profile_code=z.profile_code,
   sdd2.pv_party=z.pv_party,
   sdd2.buy_sell_flag = CASE WHEN  z.buy_sell_flag =''b'' THEN ''s'' ELSE ''b'' END
   --sdd2.block_description=z.block_description  
  FROM ' + @source_deal_detail_tmp + ' z  
  INNER JOIN source_deal_detail sdd1 ON sdd1.source_deal_detail_id = z.source_deal_detail_id  
  INNER JOIN source_deal_header sdh1 ON sdh1.source_deal_header_id = sdd1.source_deal_header_id  
  INNER JOIN source_deal_header sdh2 ON sdh2.close_reference_id = sdh1.source_deal_header_id  
   AND sdh2.deal_reference_type_id IN (12500,12503) -- Offset Deal  
  INNER JOIN source_deal_detail sdd2 ON sdd2.source_deal_header_id = sdh2.source_deal_header_id
	AND sdd2.leg = sdd1.leg
	AND sdd2.term_start = sdd1.term_start '
    
  PRINT @sql
  --EXEC(@sql)  
  

     
 END   
    
 ---###########################################  
 DECLARE @source_deal_detail_id INT  
 select @source_deal_detail_id=source_deal_detail_id from source_deal_detail where source_deal_header_id=@source_deal_header_id  
 exec spa_update_gis_certificate_no_monthly @source_deal_detail_id   
   
   
  
--- Calulate MTM based on configuration  
  
  
END   
  
SET @process_id = REPLACE(newid(),'-','_')  
  
IF ISNULL(@call_breakdown,0)=1  
BEGIN  
 PRINT 'EXEC spa_deal_position_breakdown ''u'',' + cast(@source_deal_header_id AS VARCHAR)  
 INSERT INTO #handle_sp_return_update EXEC spa_deal_position_breakdown 'u', @source_deal_header_id   
 IF EXISTS(SELECT 1 FROM #handle_sp_return_update WHERE [ErrorCode]='Error')  
 BEGIN  
  DECLARE @msg_err VARCHAR(1000),@recom_err VARCHAR(1000)  
  SELECT   @msg_err=[Message], @recom_err=[Recommendation] FROM #handle_sp_return_update WHERE [ErrorCode]='Error'  
    
  EXEC spa_ErrorHandler -1,  
     'Source Deal Detail Table',  
     'spa_UpdateFromXml',  
     'DB Error',  
     @msg_err,  
     @recom_err   
   
  ROLLBACK TRAN  
   
  RETURN  
 END   
  
END  
--rollback  
COMMIT  TRAN  
   
IF @calculate_MTM_from_deal=1  
BEGIN  
 DECLARE @as_of_date DATETIME  
 SELECT @as_of_date= as_of_date FROM module_asofdate where module_type=15500  
   
   
-- SET @process_id = REPLACE(newid(),'-','_')  
 SET @job_name = 'mtm_' + @process_id  
      
 SET @spa = 'spa_calc_mtm NULL, NULL, NULL, NULL, '   
     + CASE WHEN @source_deal_header_id IS NULL THEN 'NULL' ELSE CAST(@source_deal_header_id AS VARCHAR) END + ','   
     + CASE WHEN @as_of_date IS NULL THEN 'NULL' ELSE '''' + CAST(@as_of_date AS VARCHAR) + '''' END   
     + ',4500,4500,NULL,'  
     + CASE WHEN @user_login_id IS NULL THEN 'NULL' ELSE '''' + CAST(@user_login_id AS VARCHAR) + '''' END   
     + ',77,NULL'  
   
 EXEC spa_run_sp_as_job @job_name, @spa,'MTM' ,@user_login_id  
  
-- EXEC spa_calc_mtm NULL, NULL, NULL, NULL, @source_deal_header_id, @as_of_date, 4500, 4500, NULL, @user_login_id, 77, NULL  
END  
  
EXEC spa_ErrorHandler 0,  
     'Source Deal Detail Temp Table',  
     'spa_getXml',  
     'Success',  
     'Deal is saved successfully.',  
     @report_position_process_id  
--END TRY  
--BEGIN CATCH  
-- BEGIN  
--  ROLLBACK TRAN  
--  EXEC spa_ErrorHandler @@ERROR,  
--       'Source Deal Detail Temp Table',  
--       'spa_getXml',  
--       'DB Error',  
--       'Failed Updating record.',  
--       'Failed Updating Record'  
-- END  
--END CATCH  
DROP TABLE #ztbl_xmlvalue  
DROP TABLE #tbl_olddata  


GO

/****** Object:  StoredProcedure [dbo].[spa_DoTransaction]    Script Date: 12/20/2011 01:10:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[spa_DoTransaction]
	@flag char(1),
	@counterparty	int=null,
	@trader			INT	=null,
	@dealtype		INT	=null,
	@deal_date	  VARCHAR(20)=null,
	@xml		  varchar(max)=null

AS
PRINT 'lllllllllllllllllllllllllllllllll'
------------------------test
/*
--exec spa_DoTransaction 'u',636,493,983,'03/01/2009', '<Root><PSRecordset edit_grid1="11336" edit_grid2="2009-03-01" edit_grid3="2009-03-31" edit_grid4="1" edit_grid5="2009-03-31" edit_grid6="t" edit_grid7="s" edit_grid10="242" edit_grid11="" edit_grid12="" edit_grid13="2" edit_grid14="" edit_grid15="900" edit_grid16="3" edit_grid17="m" edit_grid18="" edit_grid19="" edit_grid20="Physical" edit_grid21="3"></PSRecordset></Root>'
--exec spa_DoTransaction 'u',636,493,983,'03/01/2009', '<Root><PSRecordset edit_grid1="11335" edit_grid2="2009-03-01" edit_grid3="2009-03-31" edit_grid4="1" edit_grid5="2009-03-31" edit_grid6="t" edit_grid7="s" edit_grid10="246" edit_grid11="" edit_grid12="" edit_grid13="2" edit_grid14="" edit_grid15="900" edit_grid16="3" edit_grid17="m" edit_grid18="" edit_grid19="" edit_grid20="Physical" edit_grid21="3"></PSRecordset></Root>'
declare	@counterparty	int,@flag varchar(1),
	@trader			INT	,
	@dealtype		INT	,
	@deal_date	  DATETIME,
	@xml		  varchar(max)
set @flag='i'
set @counterparty=621
set 	@trader		=5
set 	@dealtype	=984
set 	@deal_date	='2009-01-22'
set @xml='
<Root><PSRecordset  edit_grid1="01-01-2011" edit_grid2="31-12-2011" edit_grid3="1" edit_grid4="t" edit_grid5="b" edit_grid8="f" edit_grid9="" edit_grid10="468" edit_grid11="134" edit_grid12="m" edit_grid13="26" edit_grid14="" edit_grid15="" edit_grid16="" edit_grid17="" edit_grid18="" edit_grid19="1" edit_grid20="10" edit_grid21="" edit_grid22="" edit_grid23="" edit_grid24="" edit_grid25="" edit_grid26="" template_id="192"></PSRecordset></Root>'

drop table #tmp
drop table #source_deals
drop table #tmpb
drop table #tmp1
drop table #tmp_upd
---------------------------
--*/


DECLARE @idoc           INT
DECLARE @process        VARCHAR(1) --d=restrict, p=warning		
DECLARE @vol_c_b        FLOAT,
        @vol_t_b        FLOAT,
        @vol_c_s        FLOAT,
        @vol_t_s        FLOAT,
        @ten_c_limit    INT,
        @ten_t_limit    INT

DECLARE @vol_c_limit_b  FLOAT,
        @vol_t_limit_b  FLOAT,
        @vol_c_limit_s  FLOAT,
        @vol_t_limit_s  FLOAT,
        @tenor          INT

DECLARE @desc           VARCHAR(1000),
        @ComExists      VARCHAR(1),
        @dealExists     VARCHAR(1),
        @CommodityID    INT,
        @frequency      INT

DECLARE @tmp_msg_c      VARCHAR(1000),
        @tmp_msg_t      VARCHAR(1000),
        @buy_sell_flag  VARCHAR(1)

SELECT @tmp_msg_c = counterparty_name
FROM   source_counterparty
WHERE  source_counterparty_id = @counterparty

SELECT @tmp_msg_t = trader_name
FROM   source_traders
WHERE  source_trader_id = @trader

DECLARE @term_start               DATETIME,
        @term_end                 DATETIME,
        @deal_volume_frequency    VARCHAR(1),
        @deal_volume_b            FLOAT,
        @deal_volume_s            FLOAT,
        @indexID                  INT

DECLARE @leg                      INT,
        @fixed_float_flag         CHAR(1),
        @physical_financial_flag  CHAR(1),
        @location_id              INT,
        @deal_volume              FLOAT

DECLARE @uom                      INT,
        @price                    FLOAT,
        @formula_id               VARCHAR(100),
        @opt_strike_price         FLOAT,
        @price_adder              FLOAT,
        @price_multiplier         FLOAT

DECLARE @currency_id              INT,
        @meter_id                 INT,
        @day_count                INT,
        @strip_month_from         TINYINT,
        @lag_months               TINYINT,
        @strip_month_to           TINYINT,
        @conv_factor              FLOAT     

DECLARE @st_sql                   VARCHAR(5000)

EXEC sp_xml_preparedocument @idoc OUTPUT, @xml
CREATE TABLE #tmp (
	term_start  DATETIME,
	term_end  DATETIME,
	leg INT,
	fixed_float_flag CHAR(1),
	buy_sell_flag  CHAR(1),	 
	physical_financial_flag CHAR(1),
	location_id INT,
	curve_id  VARCHAR(100) ,	 
	deal_volume  FLOAT ,
	deal_volume_frequency  CHAR(1),
	uom INT,
	price FLOAT,
	fixed_cost FLOAT,
	fixed_cost_currency_id INT,
	formula_id  VARCHAR(100),
	formula_currency_id INT,
	opt_strike_price FLOAT,
	price_adder FLOAT,
	adder_currency_id INT,
	price_multiplier FLOAT,
	multiplier FLOAT,
	currency_id INT,
	meter_id int,
	day_count INT,
	strip_month_from TINYINT,
	lag_months TINYINT,
	strip_month_to TINYINT,
	conv_factor FLOAT,
	
	counterparty int,trader int,deal_date Datetime
)

IF @flag='c' OR @flag='i'
BEGIN

	INSERT INTO #tmp (
		term_start,term_end,
		leg,fixed_float_flag,buy_sell_flag,physical_financial_flag,location_id,curve_id,
		deal_volume,deal_volume_frequency,uom,price,fixed_cost,fixed_cost_currency_id,formula_id,formula_currency_id,opt_strike_price,
		price_adder,adder_currency_id,price_multiplier,multiplier,currency_id,meter_id,day_count,
		strip_month_from,lag_months,strip_month_to,conv_factor,		
		counterparty ,trader ,deal_date 	
	)
	SELECT 
		dbo.FNAStdDate(term_start) AS term_start,dbo.FNAStdDate(term_end) AS term_end
		,leg,fixed_float_flag,buy_sell_flag,physical_financial_flag,location_id,curve_id,
		deal_volume,deal_volume_frequency,uom,price,fixed_cost,fixed_cost_currency_id,formula_id,formula_currency_id,opt_strike_price,
		price_adder,adder_currency_id,price_multiplier,multiplier,currency_id,meter_id,day_count,
		strip_month_from,lag_months,strip_month_to,conv_factor,		
		@counterparty,@trader,@deal_date AS deal_date 
	FROM   OPENXML (@idoc, '/Root/PSRecordset',2)
		 WITH ( 
				term_start  VARCHAR(20)			'@term_start',
				term_end  VARCHAR(20)			'@term_end',
				leg INT							'@leg',
				fixed_float_flag CHAR(1)		'@fixed_float_flag',
				buy_sell_flag  CHAR(1)			'@buy_sell_flag',
				physical_financial_flag CHAR(1)	'@physical_financial_flag',
				location_id INT 				'@location_id',
				curve_id  VARCHAR(100)			'@curve_id',	 
				deal_volume  FLOAT				'@deal_volume',
				deal_volume_frequency  CHAR(1)  '@deal_volume_frequency',
				uom INT							'@deal_volume_uom_id',
				capacity FLOAT					'@capacity',
				price float						'@fixed_price',
				fixed_cost FLOAT				'@fixed_cost',
				fixed_cost_currency_id INT		'@fixed_cost_currency_id',
				formula_id VARCHAR(100)	        '@formula_id',
				formula_currency_id INT	        '@formula_currency_id',
				opt_strike_price float			'@option_strike_price',
				price_adder float				'@price_adder',
				adder_currency_id INT			'@adder_currency_id',
				multiplier float				'@multiplier',
				price_multiplier FLOAT			'@price_multiplier',				
				currency_id INT					'@fixed_price_currency_id',
				
				price_adder2 float				'@price_adder2',
				price_adder_currency2 INT		'@price_adder_currency2',
				volume_multiplier2 float		'@volume_multiplier2',
				
				meter_id int					'@meter_id',
				pay_opposite CHAR				'@pay_opposite',
				
				day_count int					'@day_count_id',
				strip_month_from tinyint        '@strip_month_from', -- NOT Clear
				lag_months tinyint				'@lag_months',
				strip_month_to tinyint			'@strip_month_to',
				conv_factor float				'@conv_factor'
			)
			
		

			
END
ELSE IF @flag='u'
begin
	SELECT 
		source_deal_detail_id,
		dbo.FNAStdDate(term_start) AS term_start,
		dbo.FNAStdDate(term_end) AS term_end,
--		term_start,
--		term_end, 
		leg,
		dbo.FNAStdDate(exp_date) AS exp_date,
--		exp_date,
		fixed_float_flag,
		buy_sell_flag,
		physical_financial_flag,
		location_id,
		curve_id,
		deal_volume,
		deal_volume_frequency,
		uom,
		capacity,
		price,
		fixed_cost,
		fixed_cost_currency_id,
		formula_id,
		formula_currency_id,
		opt_strike_price,
		price_adder,
		adder_currency_id,
		price_multiplier,
		multiplier,
		currency_id,
		price_adder2,
		price_adder_currency2,
		volume_multiplier2,		
		meter_id,
		pay_opposite,
		dbo.FNAStdDate(settlement_date) AS settlement_date
--		settlement_date 
	into #tmp_upd
	FROM   OPENXML (@idoc, '/Root/PSRecordset',2)
			 WITH ( 
				source_deal_detail_id  INT		'@source_deal_detail_id',
				term_start  VARCHAR(20)			'@term_start',
				term_end  VARCHAR(20)			'@term_end',
				leg INT							'@leg',
				exp_date VARCHAR(20)			'@contract_expiration_date',
				fixed_float_flag CHAR(1)		'@fixed_float_flag',
				buy_sell_flag  CHAR(1)			'@buy_sell_flag',
				physical_financial_flag CHAR(1)	'@physical_financial_flag',
				location_id INT					'@location_id',
				curve_id  VARCHAR(100)			'@curve_id',
				deal_volume  FLOAT				'@deal_volume',
				deal_volume_frequency  CHAR(1)	'@deal_volume_frequency',
				uom INT							'@deal_volume_uom_id',
				capacity FLOAT					'@capacity',
				price float						'@fixed_price',
				fixed_cost FLOAT				'@fixed_cost',
				fixed_cost_currency_id INT		'@fixed_cost_currency_id',
				formula_id VARCHAR(100)	        '@formula_id',
				formula_currency_id INT	        '@formula_currency_id',
				opt_strike_price float			'@option_strike_price',
				price_adder float				'@price_adder',
				adder_currency_id INT			'@adder_currency_id',
				price_multiplier float			'@price_multiplier',
				multiplier FLOAT				'@multiplier',				
				currency_id INT					'@fixed_price_currency_id',			
				price_adder2 float				'@price_adder2',
				price_adder_currency2 INT		'@price_adder_currency2',
				volume_multiplier2 float		'@volume_multiplier2',			
				meter_id int					'@meter_id',
				pay_opposite CHAR				'@pay_opposite',
				settlement_date	VARCHAR(20)		'@settlement_date'
--				bonus				25
--				hour_ending			26
				
			)


	SELECT MIN(Z.term_start) term_start,
	       MAX(Z.term_end) term_end,
	       MAX(Z.deal_volume_frequency) deal_volume_frequency,
	       MAX(Z.buy_sell_flag) buy_sell_flag_new,
	       MAX(t.buy_sell_flag) buy_sell_flag_old,
	       SUM(
	           CASE 
	                WHEN z.buy_sell_flag = 's' THEN -1
	                ELSE 1
	           END * z.deal_volume
	       ) deal_volume_new,
	       SUM(
	           CASE 
	                WHEN t.buy_sell_flag = 's' THEN -1
	                ELSE 1
	           END * t.deal_volume
	       ) deal_volume_old,
	       MAX(t.curve_id) curve_id_old,
	       MAX(z.curve_id) curve_id_new,
	       MAX(sdh.trader_id) trader_id_old,
	       @trader trader_id_new,
	       MAX(sdh.counterparty_id) counterparty_id_old,
	       @counterparty counterparty_id_new INTO #tmp1
	FROM   #tmp_upd z
	       JOIN source_deal_detail t
	            ON  t.source_deal_detail_id = z.source_deal_detail_id
	       INNER JOIN source_deal_header sdh
	            ON  t.source_deal_header_id = sdh.source_deal_header_id
	GROUP BY
	       z.leg
	


	INSERT INTO #tmp
	  (
	    term_start,
	    term_end,
	    buy_sell_flag,
	    curve_id,
	    deal_volume,
	    deal_volume_frequency,
	    counterparty,
	    trader,
	    deal_date
	  )
	SELECT term_start,
	       term_end,
	       buy_sell_flag_new,
	       curve_id_new curve_id,
	       CASE 
	            WHEN curve_id_old <> curve_id_new OR buy_sell_flag_old <> 
	                 buy_sell_flag_new OR counterparty_id_old <> 
	                 counterparty_id_new OR trader_id_old <> trader_id_new THEN 
	                 ABS(ISNULL(deal_volume_new, 0))
	            ELSE ABS(ISNULL(deal_volume_new, 0)) -ABS(ISNULL(deal_volume_old, 0))
	       END
	       deal_volume,
	       deal_volume_frequency,
	       @counterparty,
	       @trader,
	       dbo.FNAStdDate(@deal_date)
	FROM   #tmp1

--	select * from #tmp_upd
--	select * from #tmp
--	select * from #tmp1

end
ELSE IF @flag='b'
begin
	create table #source_deals (
		row_no int ,
		clm0 varchar(100), --deal_id
		clm1 varchar(100), --deal_date
		clm2 varchar(100), --buy/sell
		clm3 varchar(100),  --location_id
		clm4 varchar(100),  --index
		clm5 varchar(100), --frequency 
		clm6 varchar(100), --term_start
		clm7 varchar(100), --term end 
		clm8 varchar(100),  --volume
		clm9 varchar(100), --uom
		clm10 varchar(100), --price
		clm11 varchar(100), --currency
		clm12 varchar(100), --counteryparty
		clm13 varchar(100), --broker
		clm14 varchar(100), --trader
		clm15 varchar(30), --contract
		clm16 varchar(100), --option_strike_price
		clm17 varchar(100), --price_adder
		clm18 varchar(100) --price_multipier
	)

		insert into #source_deals
		exec spa_sourcedealheader_xml_2table @xml
		delete from #source_deals where  row_no in ( select row_no from   #source_deals where clm1='undefined' OR clm2='undefined' 
					OR clm5='undefined' OR clm6 is NULL OR clm7 is NULL OR clm8 is NULL OR clm9 is NULL OR clm12='undefined' OR clm14='undefined' 
						 OR clm9='undefined')

		update #source_deals  set clm13=null where clm13='undefined'
        update #source_deals  set clm3=null where clm3='undefined'
        update #source_deals  set clm15=null where clm15='undefined'
		update #source_deals  set clm4=null where clm4='undefined'
		update #source_deals  set clm10=null where clm10 is NULL OR  rtrim(ltrim(clm10))='NULL' 

		select max(clm6) term_start,max(clm7) term_end,max(clm2) buy_sell_flag_new,max(sdd.buy_sell_flag) buy_sell_flag_old,max(clm4) curve_id_new
		,sum(case when clm2='b' then 1 else -1 end * a.clm8) deal_volume_new,max(clm5) deal_volume_frequency
		,sum(case when sdd.buy_sell_flag='b' then 1 else -1 end * isnull(sdd.deal_volume,0)) deal_volume_old,max(sdd.curve_id) curve_id_old
		,max(clm12) counterparty,max(clm14) trader,max(clm1) deal_date
		into #tmpb 
from #source_deals a left join  source_deal_header sdh  on  sdh.deal_id=a.clm0
		left join source_deal_detail sdd on sdd.source_deal_header_id=sdh.source_deal_header_id
		group by a.clm0


	INSERT INTO #tmp (term_start,term_end,buy_sell_flag,curve_id,deal_volume,deal_volume_frequency,counterparty,trader,deal_date )
	select  term_start,term_end,buy_sell_flag_new,curve_id_new curve_id,
	CASE WHEN curve_id_old<>curve_id_new or buy_sell_flag_old<>buy_sell_flag_new THEN
		 ABS(ISNULL(deal_volume_new,0))
	ELSE	
		 abs(ISNULL(deal_volume_new,0))-abs(ISNULL(deal_volume_old,0)) end
	deal_volume,deal_volume_frequency,counterparty,trader,deal_date 
	from 	#tmpb

end

--select * from #tmp

exec sp_xml_removedocument @idoc

--DECLARE b_cursor CURSOR FOR 
--select  term_start,term_end,deal_volume_frequency,CASE WHEN buy_sell_flag='b' THEN deal_volume ELSE 0 END deal_volume_b
--,CASE WHEN buy_sell_flag='s' THEN deal_volume ELSE 0 END deal_volume_s,curve_id,counterparty,trader,deal_date,buy_sell_flag
--from 	#tmp order by term_start,term_end


DECLARE b_cursor CURSOR FOR 
select  
	--term_start,term_end,deal_volume_frequency,CASE WHEN buy_sell_flag='b' THEN deal_volume ELSE 0 END deal_volume_b,CASE WHEN buy_sell_flag='s' THEN deal_volume ELSE 0 END deal_volume_s,curve_id,counterparty,trader,deal_date,buy_sell_flag
	term_start,term_end,
	leg,fixed_float_flag,buy_sell_flag,physical_financial_flag,location_id,curve_id,
	CASE WHEN buy_sell_flag='b' THEN deal_volume ELSE 0 END deal_volume_b,CASE WHEN buy_sell_flag='s' THEN deal_volume ELSE 0 END deal_volume_s,
	deal_volume_frequency,uom,price,formula_id,opt_strike_price,
	price_adder,price_multiplier,currency_id,meter_id,day_count,
	strip_month_from,lag_months,strip_month_to,conv_factor,		
	counterparty,trader,deal_date 
from 	#tmp order by term_start,term_end

OPEN b_cursor
--FETCH NEXT FROM b_cursor
--INTO @term_start,@term_end, @deal_volume_frequency,@deal_volume_b,@deal_volume_s,@indexID,@counterparty,@trader,@deal_date,@buy_sell_flag

FETCH NEXT FROM b_cursor
--INTO @term_start,@term_end, @deal_volume_frequency,@deal_volume_b,@deal_volume_s,@indexID,@counterparty,@trader,@deal_date,@buy_sell_flag
INTO 
	@term_start,@term_end,
	@leg,@fixed_float_flag,@buy_sell_flag,@physical_financial_flag,@location_id, @indexID,
	@deal_volume_b,@deal_volume_s,@deal_volume_frequency,@uom,@price,@formula_id,@opt_strike_price,
	@price_adder,@price_multiplier,@currency_id,@meter_id,@day_count,
	@strip_month_from,@lag_months,@strip_month_to,@conv_factor,		
	@counterparty,@trader,@deal_date 
	
WHILE @@FETCH_STATUS = 0   
BEGIN 
	SELECT @ComExists= null, @dealExists= null,@process=null,@vol_c_b=null,@vol_t_b=null,@vol_c_s=null,@vol_t_s=null,@ten_c_limit=null,@ten_t_limit=null,
	@vol_c_limit_b=null,@vol_t_limit_b=null,@tenor=null,@desc=null,@vol_c_limit_s=null,@vol_t_limit_s=null


	---------------------counterparty_credit_block_trading
	SELECT @CommodityID = commodity_id FROM source_price_curve_def
	WHERE source_curve_def_id = @indexID

		select 		@ComExists=max(case when ccbt.comodity_id=@CommodityID	 then 'y' else 'n' end	) ,
			@dealExists	=max(case when ccbt.deal_type_id=@dealtype then 'y' else 'n' end	) 
		from 
		counterparty_credit_info scpi inner join counterparty_credit_block_trading ccbt 
		on ccbt.counterparty_credit_info_id=scpi.counterparty_credit_info_id
		and Counterparty_id=@Counterparty
	if ISNULL(@ComExists,'n')='y' 
	begin
		CLOSE b_cursor
		DEALLOCATE  b_cursor
		select @desc='The commodity in the index:'+ curve_name + ' is not allowed to transact for the counterparty:'+ @tmp_msg_c +'.' from source_price_curve_def where source_curve_def_id=@indexid
		goto aaa
	end

	if ISNULL(@dealExists,'n')='y'
	begin
		CLOSE b_cursor
		DEALLOCATE  b_cursor
		select @desc='The Deal type is not allowed to transact for the counterparty:'+ @tmp_msg_c +'.' from source_price_curve_def where source_curve_def_id=@indexid
		goto aaa
	end



--	select @process=min(isnull(proceed,'p')),
--	@vol_c_limit_b=min(case when counterparty_id= @counterparty and ltc.position_limit>0 then ltc.position_limit else null end)
--	,@vol_t_limit_b=min(case when trader_id= @trader and ltc.position_limit>0 then ltc.position_limit else null end)
--	,@vol_c_limit_s=max(case when counterparty_id= @counterparty and ltc.position_limit<0 then ltc.position_limit else null end)
--	,@vol_t_limit_s=max(case when trader_id= @trader and ltc.position_limit<0 then ltc.position_limit else null end)
--	,@ten_c_limit=min(case when counterparty_id= @counterparty then ltc.tenor_limit else null end)
--	,@ten_t_limit =min(case when trader_id= @trader then ltc.tenor_limit else null end)
--	from limit_tracking lt inner join limit_tracking_curve ltc on lt.limit_id=ltc.limit_id and lt.actionChecked='y' and limit_type=1581
--	and ltc.curve_id=@indexID 




		if @deal_volume_frequency='m' 
			select @frequency=datediff(month,@term_start,@term_end)
		else if @deal_volume_frequency='q'
		Begin
			 select @frequency=datediff(month,@term_start,@term_end)	
			 select @frequency=round(@frequency/3,0)
		End
		else if @deal_volume_frequency='s'
		Begin
			select @frequency=datediff(month,@term_start,@term_end)	
			select 	@frequency=round(@frequency/6,0)
		End
		else if @deal_volume_frequency='a'
		Begin
			select @frequency=datediff(month,@term_start,@term_end)	
			select 	@frequency=round(@frequency/12,0)
		End
		else if @deal_volume_frequency='d'
			select @frequency=datediff(day,@term_start,@term_end)
		else if @deal_volume_frequency='w'
			select @frequency=round(datediff(day,@term_start,@term_end)/7,0)
		else if @deal_volume_frequency='h'
			select @frequency=0
		set @frequency=@frequency+1


--------------------------------------------------------------------------------------------------------------------
--validating fot counterparty
		select @process=min(isnull(proceed,'p')),
		@vol_c_limit_b=min(case when ltc.position_limit>0 then ltc.position_limit else null end)
		,@vol_c_limit_s=max(case when  ltc.position_limit<0 then ltc.position_limit else null end)
		,@ten_c_limit=min(ltc.tenor_limit)
		from limit_tracking lt inner join limit_tracking_curve ltc on lt.limit_id=ltc.limit_id and lt.actionChecked='y' and limit_type=1581
		and ltc.curve_id=@indexID and counterparty_id= @counterparty

--	select @process '@process',@vol_c_limit_b '@vol_c_limit_b'
--	,@vol_t_limit_b '@vol_t_limit_b'
--	,@vol_c_limit_s '@vol_c_limit_s'
--	,@vol_t_limit_s '@vol_t_limit_s'
--	,@ten_c_limit '@ten_c_limit'
--	,@ten_t_limit '@ten_t_limit'
--
	if  @process is not null
	begin
--SELECT @indexID,@counterparty
		select 
		@vol_c_b=sum(case when  buy_sell_flag='b' then sdd.deal_volume else null end) 	
		,@vol_c_s=sum(case when  buy_sell_flag='s' then sdd.deal_volume else null end)
		from source_deal_header sdh inner join source_deal_detail sdd 
		on sdh.source_deal_header_id=sdd.source_deal_header_id   and sdd.curve_id=@indexID
		and sdh.counterparty_id= @counterparty

--	select	@vol_c_b	 '@vol_c_b'
--		,@vol_t_b '@vol_t_b'
--		,@vol_c_s '@vol_c_s'
--		,@vol_t_s '@vol_t_s'


		if @buy_sell_flag='b'
		begin 
			if @vol_c_limit_b is not null
			begin
				if @vol_c_limit_b<isnull(@vol_c_b ,0)
				begin
					CLOSE b_cursor
					DEALLOCATE  b_cursor
					select @desc='The buying volume of the index:'+ curve_name + ' exceeded the limit before this transaction for the counterparty:'+ @tmp_msg_c +'.' from source_price_curve_def where source_curve_def_id=@indexid
					goto aaa
				END
			--	SELECT @deal_volume_b,@frequency
				set @vol_c_b=isnull(@vol_c_b,0)+(@deal_volume_b*@frequency)
				if @vol_c_limit_b<@vol_c_b
				begin
					CLOSE b_cursor
					DEALLOCATE  b_cursor
					select @desc='The buying volume of the index:'+ curve_name + ' exceeded the limit for the counterparty:'+ @tmp_msg_c +' by '+cast(abs(@vol_c_limit_b-@vol_c_b) as varchar)+'.' from source_price_curve_def where source_curve_def_id=@indexid
					goto aaa
				end
			end
		end
		if @buy_sell_flag='s'
		begin 
			if @vol_c_limit_s is not null
			begin
				if abs(@vol_c_limit_s)<@vol_c_s 
				begin
					CLOSE b_cursor
					DEALLOCATE  b_cursor
					select @desc='The selling volume of the index:'+ curve_name + ' exceeded the limit before this transaction for the counterparty:'+ @tmp_msg_c +'.' from source_price_curve_def where source_curve_def_id=@indexid
					goto aaa
				end
				set @vol_c_s=abs(isnull(@vol_c_s,0))+abs((@deal_volume_s*@frequency))
				if abs(@vol_c_limit_s)<abs(@vol_c_s)
				begin
					CLOSE b_cursor
					DEALLOCATE  b_cursor
					select @desc='The selling volume of the index:'+ curve_name + ' exceeded the limit for the counterparty:'+ @tmp_msg_c +' by '+cast(abs(abs(@vol_c_limit_s)-@vol_c_s) as varchar)+'.' from source_price_curve_def where source_curve_def_id=@indexid
					goto aaa
				end
			end
		end

		SELECT @term_start = dbo.FNAFindLastFrequencyDate (@term_start,@term_end,@deal_volume_frequency)
		SELECT @tenor = DATEDIFF(DAY,@deal_date,@term_start)
		if @ten_c_limit<@tenor 
		begin
			CLOSE b_cursor
			DEALLOCATE  b_cursor
			select @desc='The Tenor of the index:'+ curve_name + ' exceeded the limit for the counterparty:'+ @tmp_msg_c +' by '+cast(abs(@tenor-@ten_c_limit) as varchar) +'.' from source_price_curve_def where source_curve_def_id=@indexid
			goto aaa
		end
	end 
	set @process=null
	select @process=min(isnull(proceed,'p')),
	@vol_t_limit_b=min(case when  ltc.position_limit>0 then ltc.position_limit else null end)
	,@vol_t_limit_s=max(case when ltc.position_limit<0 then ltc.position_limit else null end)
	,@ten_t_limit =min(ltc.tenor_limit)
	from limit_tracking lt inner join limit_tracking_curve ltc on lt.limit_id=ltc.limit_id and lt.actionChecked='y' and limit_type=1581
	and ltc.curve_id=@indexID  and trader_id= @trader
/*
	select @process_vol_b=min(isnull(proceed,'p')),
	@process_vol_s=min(case when  ltc.position_limit>0 then ltc.position_limit else null end)
	,@vol_t_limit_s=max(case when ltc.position_limit<0 then ltc.position_limit else null end)
	,@ten_t_limit =min(ltc.tenor_limit)
	from limit_tracking lt inner join limit_tracking_curve ltc on lt.limit_id=ltc.limit_id and lt.actionChecked='y' and limit_type=1581
	and ltc.curve_id=@indexID  and trader_id= @trader

	select min(case when  ltc.position_limit>0 then ltc.position_limit else null end) l_v_b
	,max(case when  ltc.position_limit<0 then ltc.position_limit else null end) l_v_s
	from limit_tracking lt inner join limit_tracking_curve ltc on lt.limit_id=ltc.limit_id and lt.actionChecked='y' and limit_type=1581
	and ltc.curve_id=@indexID  and trader_id= @trader

select * from  limit_tracking
select * from limit_tracking_curve
*/
--------------------------------------------------------------------------------------------------------------------------------
--validating fot trader


	if  @process is not null
	begin
		select 
		@vol_t_b=sum(case when buy_sell_flag='b' then sdd.deal_volume else null end)
		,@vol_t_s=sum(case when buy_sell_flag='s' then sdd.deal_volume else null end)
		from source_deal_header sdh inner join source_deal_detail sdd 
		on sdh.source_deal_header_id=sdd.source_deal_header_id   and sdd.curve_id=@indexID
		and sdh.trader_id= @trader

		if @buy_sell_flag='b'
		begin 
		if @vol_t_limit_b is not null
			begin
				if @vol_t_limit_b<@vol_t_b 
				begin
					CLOSE b_cursor
					DEALLOCATE  b_cursor
					select @desc='The buying volume of the index:'+ curve_name + ' exceeded the limit before this transaction for the trader:'+ @tmp_msg_t +'.' from source_price_curve_def where source_curve_def_id=@indexid
					goto aaa
				end
				set @vol_t_b=isnull(@vol_t_b,0)+(@deal_volume_b*@frequency)
				if @vol_t_limit_b<@vol_t_b
				begin
					CLOSE b_cursor
					DEALLOCATE  b_cursor
					select @desc='The buying volume of the index:'+ curve_name + ' exceeded the limit for the trader:'+ @tmp_msg_t +' by '+cast(abs(@vol_t_limit_b-@vol_t_b ) as varchar)+'.' from source_price_curve_def where source_curve_def_id=@indexid
					goto aaa
				end
			end
		end
		if @buy_sell_flag='s'
		begin 
			if @vol_t_limit_s is not null
			begin
				if abs(@vol_t_limit_s)<abs(@vol_t_s )
				begin
					CLOSE b_cursor
					DEALLOCATE  b_cursor
					select @desc='The selling volume of the index:'+ curve_name + ' exceeded the limit before this transaction for the trader:'+ @tmp_msg_t +'.' from source_price_curve_def where source_curve_def_id=@indexid
					goto aaa
				end
				set @vol_t_s=abs(isnull(@vol_t_s,0))+abs((@deal_volume_s*@frequency))
				if abs(@vol_t_limit_s)<@vol_t_s
				begin
					CLOSE b_cursor
					DEALLOCATE  b_cursor
					select @desc='The selling volume of the index:'+ curve_name + ' exceeded the limit for the trader:'+ @tmp_msg_t +' by '+cast(abs(abs(@vol_t_limit_s)-@vol_t_s)  as varchar)+'.' from source_price_curve_def where source_curve_def_id=@indexid
					goto aaa
				end
			end
		end
		SELECT @term_start = dbo.FNAFindLastFrequencyDate (@term_start,@term_end,@deal_volume_frequency)
		SELECT @tenor = DATEDIFF(DAY,@deal_date,@term_start)

		if @ten_t_limit<@tenor
		begin
			CLOSE b_cursor
			DEALLOCATE  b_cursor
			select @desc='The Tenor of the index:'+ curve_name + ' exceeded the limit for the trader:'+ @tmp_msg_t +' by '+cast(abs(@tenor-@ten_t_limit) as varchar) +'.' from source_price_curve_def where source_curve_def_id=@indexid
			goto aaa
		end
----------------------------------------end trader validation

	end
--	FETCH NEXT FROM b_cursor
--	INTO @term_start,@term_end, @deal_volume_frequency,@deal_volume_b,@deal_volume_s,@indexID,@counterparty,@trader,@deal_date,@buy_sell_flag

	FETCH NEXT FROM b_cursor
--	INTO @term_start,@term_end, @deal_volume_frequency,@deal_volume_b,@deal_volume_s,@indexID,@counterparty,@trader,@deal_date,@buy_sell_flag
	INTO
		@term_start,@term_end,
		@leg,@fixed_float_flag,@buy_sell_flag,@physical_financial_flag,@location_id, @indexID,
		@deal_volume_b,@deal_volume_s,@deal_volume_frequency,@uom,@price,@formula_id,@opt_strike_price,
		@price_adder,@price_multiplier,@currency_id,@meter_id,@day_count,
		@strip_month_from,@lag_months,@strip_month_to,@conv_factor,		
		@counterparty,@trader,@deal_date 
		
end
CLOSE b_cursor
DEALLOCATE  b_cursor

	
aaa:
SELECT @desc desc_err, @process Process				



GO

/****** Object:  StoredProcedure [dbo].[spa_source_minor_location]    Script Date: 12/20/2011 01:10:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*
	Modified By:Pawan KC
	Modification Date:23/03/2009
	Description: Added Parameters @owner,@operator,@contract,@volume,@uom,@region,@is_pool,@term_pricing_index
				 as Tables source_minor_location,minor_location_detail are merged and Made necessary changes in the i,u,a,d blocks.
*/


CREATE PROC [dbo].[spa_source_minor_location]
    @flag VARCHAR(1),
    @source_minor_location_ID VARCHAR(500) = NULL,
    @source_system_id [int] = NULL,
    @source_major_location_ID VARCHAR(500) = NULL,
    @Location_Name VARCHAR(100) = NULL,
    @Location_Description VARCHAR(50) = NULL,
    @Meter_ID VARCHAR(100) = NULL,
    @Pricing_Index INT = NULL,
    @Commodity_id INT = NULL,
    @location_type INT = NULL,
    @time_zone INT = NULL,
    @owner VARCHAR(100) = NULL,
    @operator VARCHAR(100) = NULL,
    @contract INT = NULL,
    @volume FLOAT = NULL,
    @uom INT = NULL,
    @region INT = NULL,
    @is_pool CHAR(1) = NULL,
    @term_pricing_index INT = NULL,
    @bid_offer_formulator_id INT = NULL,
    @profile INT = NULL,
    @proxy_profile INT = NULL,
    @grid_value_id INT = NULL,
    @country INT = NULL,
    @is_active VARCHAR(1) = NULL,
    @call_from VARCHAR(1) = NULL
AS 
    DECLARE @Sql_Select VARCHAR(3000),
        @msg_err VARCHAR(2000)

    IF @source_system_id IS NULL 
        SET @source_system_id = 2

    BEGIN TRY

        IF @flag = 'i' 
            BEGIN
                INSERT  INTO [dbo].source_minor_location
					(
						[source_system_id]
						,[source_major_location_ID]
						,[Location_Name]
						,[Location_Description]
						,[Meter_ID]
						,[Pricing_Index]
						,[Commodity_id]
						,[location_type]
						,[time_zone]
						,[owner]
						,[operator]
						,[contract]
						,[volume]
						,[uom]
						,[region]
						,[is_pool]
						,[term_pricing_index]
						,[bid_offer_formulator_id]
						,[profile_id]
						,[proxy_profile_id]
						,[create_user]
						,[create_ts]
						,[update_user]
						,[update_ts]
						,[grid_value_id]
						,[country]
						,[is_active]
	                  )
                VALUES  (
						@source_system_id
						,@source_major_location_ID
						,@Location_Name
						,@Location_Description
						,@Meter_ID
						,@Pricing_Index
						,@Commodity_id
						,@location_type
						,@time_zone
						,@owner
						,@operator
						,@contract
						,@volume
						,@uom
						,@region
						,@is_pool
						,@term_pricing_index
						,@bid_offer_formulator_id
						,@profile
						,@proxy_profile
						,dbo.FNADBUser()
						,GETDATE()
						,dbo.FNADBUser()
						,GETDATE()
						,@grid_value_id
						,@country
						,@is_active
	                  )
                SET @source_minor_location_id = SCOPE_IDENTITY() 
				
                IF @@ERROR <> 0 
                    EXEC spa_ErrorHandler @@ERROR, "Source Minor Location",
                        "spa_source_minor_location", "DB Error",
                        "Insert of Source Minor Location data failed.", ''
                ELSE 
                    EXEC spa_ErrorHandler 0, 'Source Minor Location',
                        'spa_source_minor_location', 'Success',
                        'Source Minor Location data successfully inserted.',
                        @source_minor_location_id
            END

        ELSE 
            IF @flag = 'u' 
                UPDATE  [dbo].source_minor_location
                SET     [source_system_id] = @source_system_id
                        ,[source_major_location_ID] = @source_major_location_ID
                        ,[Location_Name] = @Location_Name
                        ,[Location_Description] = @Location_Description
                        ,[Meter_ID] = @Meter_ID
                        ,[Pricing_Index] = @Pricing_Index
                        ,[Commodity_id] = @Commodity_id
                        ,[location_type] = @location_type
                        ,[time_zone] = @time_zone
                        ,[owner] = @owner
                        ,[operator] = @operator
                        ,[contract] = @contract
                        ,[volume] = @volume
                        ,[uom] = @uom
                        ,[region] = @region
                        ,[is_pool] = @is_pool
                        ,[term_pricing_index] = @term_pricing_index
                        ,[bid_offer_formulator_id] =@bid_offer_formulator_id
                        ,[profile_id] = @profile
                        ,[proxy_profile_id] = @proxy_profile
                        ,update_user = dbo.FNADBUser()
						,update_ts = GETDATE()
						,grid_value_id = @grid_value_id
						,country = @country,
						is_active = @is_active
                WHERE   source_minor_location_ID = @source_minor_location_ID
                                  

            ELSE 
                IF @flag = 's' OR @flag = 'l'
                    BEGIN
                    	
                    	IF @flag = 's'
                    	BEGIN	
							SET @Sql_Select = ' 	
							SELECT s.source_minor_location_ID [ID]
								   ,case when source_Major_Location.location_name is null then '''' else source_Major_Location.location_name + '' -> '' end +  S.[Location_Name] as [Name]
								  ,S.[Location_Description] as [Description]
								  ,S.[Meter_ID]as[Meter ID]
								  ,spcd.curve_name [Spot Index]
								  ,spcd1.curve_name [Term Index]
								  ,source_commodity.[Commodity_id] [Commodity ID]
								  ,sdv.[code] as [Location Type] 
								  ,sdv1.[code] as [Time Zone]
								  ,s.bid_offer_formulator_id
								  ,S.[create_user] [Created User]
								  ,dbo.FNADateTimeFormat(S.[create_ts],1) [Created Date]
								  ,S.[update_user] [Updated User]
								  ,dbo.FNADateTimeFormat(S.[update_ts],1)  [Updated Date]
							FROM [dbo].source_minor_location S
							LEFT JOIN source_price_curve_def spcd ON S.[Pricing_Index]=spcd.source_curve_def_id
							LEFT JOIN source_price_curve_def spcd1 ON S.[term_pricing_index]=spcd1.source_curve_def_id
							left JOIN source_commodity ON S.Commodity_id=source_commodity.source_commodity_id
							LEFT JOIN source_Major_Location ON S.source_Major_Location_Id=source_Major_Location.source_major_location_ID
							LEFT JOIN static_data_value sdv ON Sdv.value_id=S.location_type
							LEFT JOIN static_data_value sdv1 ON Sdv1.value_id=S.time_zone
							WHERE 1=1
							'
						END 
						ELSE IF @flag = 'l'
						BEGIN
							SET @Sql_Select = ' 	
							SELECT s.source_minor_location_ID [ID]
								   ,case when source_Major_Location.location_name is null then '''' else source_Major_Location.location_name + '' -> '' end +  S.[Location_Name] as [Name]
								  ,S.[Location_Description] as [Description]
								  ,spcd.curve_name [Spot Index]
								  ,spcd1.curve_name [Term Index]
								  ,source_commodity.[Commodity_id] [Commodity ID]
								  ,sdv.[code] as [Location Type]
								  ,source_major_location.location_name [Location Group]
								  ,sdv1.[code] as [Time Zone]
								  ,sdv2.code [Grid]
								  ,S.[create_user] [Created User]
								  ,dbo.FNADateTimeFormat(S.[create_ts],1) [Created Date]
								  ,S.[update_user] [Updated User]
								  ,dbo.FNADateTimeFormat(S.[update_ts],1)  [Updated Date]
								  ,S.[is_active]
								 
								 
							FROM [dbo].source_minor_location S
							LEFT JOIN source_price_curve_def spcd ON S.[Pricing_Index] = spcd.source_curve_def_id
							LEFT JOIN source_price_curve_def spcd1 ON S.[term_pricing_index] = spcd1.source_curve_def_id
							left JOIN source_commodity ON S.Commodity_id = source_commodity.source_commodity_id
							LEFT JOIN source_Major_Location ON S.source_Major_Location_Id = source_Major_Location.source_major_location_ID
							LEFT JOIN static_data_value sdv ON Sdv.value_id = S.location_type
							LEFT JOIN static_data_value sdv1 ON Sdv1.value_id = S.time_zone
							LEFT JOIN static_data_value sdv2 ON sdv2.value_id = s.grid_value_id
							WHERE 1=1
							'							
						END
						IF @call_from IS NOT NULL 
						SET @Sql_Select = @Sql_Select + 'AND s.is_active = ''y'''
						
						IF @is_active = 'y' 
						SET @Sql_Select = @Sql_Select + 'AND s.is_active = ''y'''
						
                        IF @source_system_id IS NOT NULL 
                        SET @Sql_Select = @Sql_Select + ' AND s.source_system_id=' + CONVERT(VARCHAR(20), @source_system_id)
                                
                        IF @Location_Name IS NOT NULL 
						SET @Sql_Select = @Sql_Select + ' AND s.location_name LIKE ''' + @Location_Name + ''''
						
						IF @Commodity_id IS NOT NULL 
						SET @Sql_Select = @Sql_Select + ' AND s.commodity_id=' + CONVERT(VARCHAR(20), @Commodity_id)
						
						IF @region IS NOT NULL  
						SET @Sql_Select = @Sql_Select + ' AND s.region=' + CONVERT(VARCHAR(20), @region)
						
						IF @source_major_location_ID IS NOT NULL 
						SET @Sql_Select = @Sql_Select + ' AND s.source_Major_Location_Id=' + CONVERT(VARCHAR(20), @source_major_location_ID)
						
						IF @Pricing_Index IS NOT NULL 
						SET @Sql_Select = @Sql_Select + ' AND s.pricing_index=' + CONVERT(VARCHAR(20), @Pricing_Index)
						
						IF @term_pricing_index IS NOT NULL 
						SET @Sql_Select = @Sql_Select + ' AND s.term_pricing_index=' + CONVERT(VARCHAR(20), @term_pricing_Index)
						
						IF @profile IS NOT NULL 
						SET @Sql_Select = @Sql_Select + ' AND s.profile_id = ' + CAST(@profile AS VARCHAR)
						
						IF @proxy_profile IS NOT NULL 
						SET @Sql_Select = @Sql_Select + ' AND s.proxy_profile_id=' + CAST(@proxy_profile as VARCHAR)
						
						
                        PRINT ( @SQL_select )
                        BEGIN TRY
                        	EXEC ( @SQL_select)
                        END TRY
                        BEGIN CATCH
                        	
                        		SELECT
                        			ERROR_NUMBER() AS ErrorNumber,
                        			ERROR_SEVERITY() AS ErrorSeverity,
                        			ERROR_STATE() AS ErrorState,
                        			ERROR_PROCEDURE() AS ErrorProcedure,
                        			ERROR_LINE() AS ErrorLine,
                        			ERROR_MESSAGE() AS ErrorMessage
                        	
                        END CATCH
--                        EXEC ( @SQL_select)
                    END
	------------------ Below is the section for interactive scheduling and delivery --------
	-- Author: Milan Lamichhane
	-- Date: 02/06/2009
	----------------------------------------------------------------------------------------
	ELSE IF @flag = 'm'
	BEGIN
		SELECT
			MAX(sml.source_minor_location_id) [source_minor_location_id],
			sml.location_name,
			SUM(CASE buy_sell_flag
					WHEN 's' THEN 
						(sdd.deal_volume * -1)
					ELSE
						sdd.deal_volume
					END) [deal_volume],
			MAX(sml.x_position) [x_position],
			MAX(sml.y_position) [y_position]
			,d.source_curve_def_id,d.curve_name
		FROM 
			source_minor_location sml
		LEFT JOIN
			source_deal_detail sdd
		ON
			sml.source_minor_location_id = sdd.location_id
		LEFT JOIN source_price_curve_def d ON d.source_curve_def_id=sml.Pricing_Index	

		GROUP BY
			sml.location_name
			,d.source_curve_def_id,d.curve_name
		ORDER BY
			sml.location_name
	END
	------------- end interactive section -------------------
                    ELSE 
                        IF @flag = 'd' 
                            BEGIN	
                                DELETE  [dbo].source_minor_location_meter
                                WHERE   source_minor_location_id = @source_Minor_location_id
                                DELETE  [dbo].source_minor_location
                                WHERE   source_Minor_location_id = @source_Minor_location_id
                            END
                        ELSE 
                            IF @flag = 'a' 
                                SELECT  [source_minor_location_ID],
                                        [source_system_id],
                                        [source_major_location_ID],
                                        [Location_Name],
                                        [Location_Description],
                                        [Meter_ID],
                                        [Pricing_Index],
                                        [Commodity_id],
                                        [location_type],
                                        time_zone,
                                        [owner],
                                        [operator],
                                        [contract],
                                        [volume],
                                        [uom],
                                        [region],
                                        [is_pool],
                                        [term_pricing_index],
                                        [bid_offer_formulator_id]
                                        ,[profile_id]
                                        ,[proxy_profile_id]
                                        ,[grid_value_id]
                                        ,[country],is_active
                                FROM    [dbo].source_minor_location
                                WHERE   source_minor_location_ID = @source_minor_location_ID
                            ELSE 
                                IF @flag = 'm' --used in deal_entry
                                    SELECT DISTINCT
                                            source_minor_location_ID,
                                            CASE WHEN ISNULL(jor.[Location_Name],
                                                             '') = '' THEN ''
                                                 ELSE jor.[Location_Name]
                                                      + ', '
                                            END + ISNULL(nor.[Location_Name],
                                                         '') Location_Name
                                    FROM    source_major_location jor
                                            RIGHT JOIN source_minor_location nor ON nor.Location_Name = jor.Location_Name

                                ELSE 
                                    IF @flag = 'f'  --get the the minor location of the corresponding major location
                                        BEGIN
                                            SET @Sql_Select = 'SELECT source_minor_location_id,location_name [Location Name] from source_minor_location where source_major_location_id in('
                                                + CAST(@source_major_location_ID AS VARCHAR)
                                                + ')'
                                            EXEC ( @Sql_Select
                                                )
                                        END
                                    ELSE 
                                        IF @flag = 'p'  --get the the index of the corresponding minor location
                                            BEGIN
                                                SET @Sql_Select = 'SELECT spcd.source_curve_def_id,spcd.curve_name from source_minor_location sml
								join source_price_curve_def spcd on spcd.source_curve_def_id = sml.Pricing_Index
								where source_minor_location_id in('
                                                    + CAST(@source_minor_location_id AS VARCHAR)
                                                    + ')'
                                                EXEC ( @Sql_Select
                                                    )
                                            END

                                        ELSE 
                                            IF @flag = 'g' 
                                                SELECT  source_minor_location_id,
                                                        location_name
                                                FROM    source_minor_location 

        DECLARE @msg VARCHAR(2000)
        SELECT  @msg = ''
        IF @flag = 'i' 
            SET @msg = 'Data Successfully Inserted.'
        ELSE 
            IF @flag = 'u' 
                SET @msg = 'Data Successfully Updated.'
            ELSE 
                IF @flag = 'd' 
                    SET @msg = 'Data Successfully Deleted.'

        IF @msg <> '' 
            EXEC spa_ErrorHandler 0, 'source_minor_location table',
                'spa_minor_location', 'Success', @msg, ''
    END TRY
    BEGIN CATCH
        DECLARE @error_number INT
        SET @error_number = ERROR_NUMBER()
        SET @msg_err = ''


        IF @flag = 'i' 
			IF @error_number=2627
				begin
					SET @msg_err = 'The selected location details already exist'
			    end
			ELSE 
				BEGIN
					SET @msg_err = 'Fail Insert Data.'
				end
        ELSE 
            IF @flag = 'u' 
                IF @error_number=2627
				begin
					SET @msg_err = 'The selected location details already exist'
			    end
			ELSE 
				BEGIN
					SET @msg_err = 'Fail Insert Data.'
				end
            ELSE 
                IF @flag = 'd' 
                    SET @msg_err = 'Fail Delete Data.'


	--SET  @msg_err=@msg_err +'(Err_No:' +cast(@error_number as varchar) + '; Description:' + error_message() +'.'
        EXEC spa_ErrorHandler @error_number, 'source_minor_location table',
            'spa_source_minor_location', 'DB Error', @msg_err, ''
    END CATCH
GO

/****** Object:  StoredProcedure [dbo].[spa_source_minor_location_paging]    Script Date: 12/20/2011 01:10:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[spa_source_minor_location_paging]
    @flag VARCHAR(1),
    @source_minor_location_ID VARCHAR(500) = NULL,
    @source_system_id [int] = NULL,
    @source_major_location_ID VARCHAR(500) = NULL,
    @Location_Name VARCHAR(100) = NULL,
    @Location_Description VARCHAR(25) = NULL,
    @Meter_ID VARCHAR(100) = NULL,
    @Pricing_Index INT = NULL,
    @Commodity_id INT = NULL,
    @location_type INT = NULL,
    @time_zone INT = NULL,
    @owner VARCHAR(100) = NULL,
    @operator VARCHAR(100) = NULL,
    @contract INT = NULL,
    @volume FLOAT = NULL,
    @uom INT = NULL,
    @region INT = NULL,
    @is_pool CHAR(1) = NULL,
    @term_pricing_index INT = NULL,
    @bid_offer_formulator_id INT = NULL,
    @profile INT = NULL,
    @proxy_profile INT = NULL,
    @grid_value_id INT = NULL,
	@process_id_paging VARCHAR(200) = NULL, 
	@page_size INT = NULL,
	@page_no INT = NULL,
	@country INT = NULL,
	@call_from VARCHAR(1) = NULL,
	@is_active VARCHAR(1) = NULL
AS 


DECLARE @user_login_id  VARCHAR(50),
        @tempTable      VARCHAR(MAX)
 
DECLARE @flag_paging    CHAR(1)

SET @user_login_id = dbo.FNADBUser()

IF @process_id_paging IS NULL
BEGIN
    SET @flag_paging = 'i'
    SET @process_id_paging = REPLACE(NEWID(), '-', '_')
END

SET @tempTable = dbo.FNAProcessTableName(
        'paging_source_minor_location',
        @user_login_id,
        @process_id_paging
    )

PRINT @tempTable

DECLARE @sql VARCHAR(MAX)



IF @flag_paging = 'i'
BEGIN
    IF @flag = 'l'
    BEGIN
        SET @sql = 'CREATE TABLE ' + @tempTable + 
            ' (
			sno INT IDENTITY(1,1), 
			
			ID VARCHAR(50),
			Name VARCHAR(100),
			Description VARCHAR(100),
			[Spot Index] VARCHAR(100),
			[Term Index] VARCHAR(100),
			[Commodity ID] VARCHAR(50),
			[Location Type] VARCHAR(500),
			[Location Group] VARCHAR(100),
			[Time Zone] VARCHAR(500),
			[Grid] VARCHAR(100),
			[Created User] VARCHAR(50),
			[Created Date] VARCHAR(50),
			[Updated User] VARCHAR(50),
			[Updated Date] VARCHAR(50),
			[is_active] VARCHAR(1)
		)'
        
        PRINT @sql 
        EXEC (@sql)
        
        
        SET @sql = 'INSERT ' + @tempTable + 
            '(
					ID,
					Name,
					Description,
					[Spot Index],
					[Term Index],
					[Commodity ID],
					[Location Type],
					[Location Group],
					[Time Zone]
					,[Grid]
					,[Created User],
					[Created Date],
					[Updated User],
					[Updated Date],
					is_active
		)' +
            ' EXEC spa_source_minor_location ' +
            dbo.FNASingleQuote(@flag) + ',' +
            dbo.FNASingleQuote(@source_minor_location_ID) + ',' +
            dbo.FNASingleQuote(@source_system_id) + ',' +
            dbo.FNASingleQuote(@source_major_location_ID) + ',' +
            dbo.FNASingleQuote(@Location_Name) + ',' +
            dbo.FNASingleQuote(@Location_Description) + ',' +
            dbo.FNASingleQuote(@Meter_ID) + ',' +
            dbo.FNASingleQuote(@Pricing_Index) + ',' +
            dbo.FNASingleQuote(@Commodity_id) + ',' +
            dbo.FNASingleQuote(@location_type) + ',' +
            dbo.FNASingleQuote(@time_zone) + ',' +
            dbo.FNASingleQuote(@owner) + ',' +
            dbo.FNASingleQuote(@operator) + ',' +
            dbo.FNASingleQuote(@contract) + ',' +
            dbo.FNASingleQuote(@volume) + ',' +
            dbo.FNASingleQuote(@uom) + ',' +
            dbo.FNASingleQuote(@region) + ',' +
            dbo.FNASingleQuote(@is_pool) + ',' +
            dbo.FNASingleQuote(@term_pricing_index) + ',' +
            dbo.FNASingleQuote(@bid_offer_formulator_id) + ',' +
            dbo.FNASingleQuote(@profile) + ',' +
            dbo.FNASingleQuote(@proxy_profile) + ',' +
            dbo.FNASingleQuote(@grid_value_id) + ',' + 
            dbo.FNASingleQuote(@country) + ',' + 
            dbo.FNASingleQuote(@call_from) + ',' +
            dbo.FNASingleQuote(@is_active)
        
        PRINT @sql 
        EXEC (@sql)
        
        SET @sql = 'select count(*) TotalRow,''' + @process_id_paging + ''' process_id  from ' + @tempTable
        
        PRINT @sql
        EXEC (@sql)
    END
   
END

ELSE
BEGIN
	
	DECLARE @row_from INT, @row_to INT 
	SET @row_to = @page_no * @page_size 
	IF @page_no > 1 
	SET @row_from = ((@page_no-1) * @page_size) + 1
	ELSE 
	SET @row_from = @page_no

    IF @flag = 'l'
    BEGIN
        SET @sql = 
            'SELECT 
			ID,
			Name,
			Description,
			[Spot Index],
			[Term Index],
			[Commodity ID],
			[Location Type],
			[Location Group],
			[Time Zone]
			,[Grid]
			,[Created User],
			[Created Date],
			[Updated User],
			[Updated Date],
			is_active
			
		            FROM ' + @tempTable
            + ' WHERE sno BETWEEN ' + CAST(@row_from AS VARCHAR) + ' AND ' + 
            CAST(@row_to AS VARCHAR) + ' ORDER BY sno ASC'
            
		PRINT @sql 
		EXEC (@sql)               
    END
END
GO


