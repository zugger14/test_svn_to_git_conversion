
--spa_sourcedealtemp_detail @flag='g',@source_deal_header_id=1    
IF OBJECT_ID(N'[dbo].[spa_sourcedealtemp_detail]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_sourcedealtemp_detail]
GO

CREATE PROC [dbo].[spa_sourcedealtemp_detail]          
@flag CHAR(1),          
@book_deal_type_map_id VARCHAR(200) = NULL,           
@source_deal_header_id INT = NULL,          
@source_system_id INT = NULL,          
@counterparty_id INT = NULL,          
@entire_term_start VARCHAR(10) = NULL,          
@entire_term_end VARCHAR(10) = NULL,          
@source_deal_type_id INT = NULL,          
@deal_sub_type_type_id INT = NULL,          
@deal_category_value_id INT = NULL,          
@trader_id INT = NULL,          
@internal_deal_type_value_id INT = NULL,          
@internal_deal_subtype_value_id INT = NULL,          
@book_id INT = NULL,          
@template_id INT = NULL,          
@term_start VARCHAR(10) = NULL,          
@term_end VARCHAR(10) = NULL,          
@leg INT = NULL,          
@contract_expiration_date VARCHAR(10) = NULL,          
@fixed_float_leg CHAR(1) = NULL,          
@buy_sell_flag CHAR(1) = NULL,          
@curve_id INT = NULL,          
@fixed_price NUMERIC(38, 20) = NULL,          
@fixed_price_currency_id INT = NULL,          
@option_flag CHAR(1) = NULL,          
@option_strike_price NUMERIC(38, 20) = NULL,          
@deal_volume NUMERIC(38, 20) = NULL,          
@deal_volume_frequency CHAR(1) = NULL,          
@deal_volume_uom_id INT = NULL,          
@block_description VARCHAR(100) = NULL,          
@deal_detail_description VARCHAR(100) = NULL,          
@term_start1 VARCHAR(10) = NULL,          
@term_end1 VARCHAR(10) = NULL,          
@leg1 INT = NULL,          
@formula_id INT = NULL,          
@sell_curve_id INT = NULL,          
@sell_fixed_price NUMERIC(38, 20) = NULL,          
@sell_fixed_price_currency_id INT = NULL,          
@sell_option_strike_price NUMERIC(38, 20) = NULL,          
@sell_deal_volume FLOAT = NULL,          
@sell_deal_volume_frequency CHAR(1) = NULL,          
@sell_deal_volume_uom_id INT = NULL,          
@sell_fixed_float_leg CHAR(1) = NULL,          
@sell_formula_id INT = NULL,          
@process_id VARCHAR(100) = NULL,          
@deal_date VARCHAR(10) = NULL,          
@frequency_type CHAR(1) = NULL,          
@broker_id INT = NULL,          
@hour_from INT = NULL,          
@hour_to INT = NULL,          
@source_deal_detail_id VARCHAR(1000) = NULL,          
@deal_id VARCHAR(1000) = NULL,          
@physical_financial_flag CHAR(1) = NULL,          
@option_type CHAR(1) = NULL,          
@option_excercise_type CHAR(1) = NULL,          
@options_term_start VARCHAR(20) = NULL,          
@options_term_end VARCHAR(20) = NULL,          
@exercise_date VARCHAR(20) = NULL,          
@round_value CHAR(2) = '2',          
@deleted_deal VARCHAR(1) = 'n',          
@call_from_paging CHAR(1) = 'n'     --- if called from spa_sourcedealtemp_detail_paging      
AS         

set nocount on 

/*  
----------------Test  
declare @flag char(1),          
@book_deal_type_map_id varchar(200),           
@source_deal_header_id int,          
@source_system_id int,          
@counterparty_id int,          
@entire_term_start varchar(10),          
@entire_term_end varchar(10),          
@source_deal_type_id int,          
@deal_sub_type_type_id int,          
@deal_category_value_id int,          
@trader_id int,          
@internal_deal_type_value_id int,          
@internal_deal_subtype_value_id int,          
@book_id int,          
@template_id int ,          
@term_start varchar(10),          
@term_end varchar(10),          
@leg int,          
@contract_expiration_date varchar(10),          
@fixed_float_leg char(1),          
@buy_sell_flag char(1),          
@curve_id int,          
@fixed_price numeric(38,20),          
@fixed_price_currency_id int,          
@option_flag char(1),          
@option_strike_price numeric(38,20),          
@deal_volume numeric(38,20),          
@deal_volume_frequency char(1),          
@deal_volume_uom_id int,          
@block_description varchar(100),          
@deal_detail_description varchar(100),          
@term_start1 varchar(10),          
@term_end1 varchar(10),          
@leg1 int,          
@formula_id int,          
@sell_curve_id int,          
@sell_fixed_price numeric(38,20),          
@sell_fixed_price_currency_id int,          
@sell_option_strike_price numeric(38,20),          
@sell_deal_volume float,          
@sell_deal_volume_frequency char(1),          
@sell_deal_volume_uom_id int,          
@sell_fixed_float_leg char(1),          
@sell_formula_id int,          
@process_id varchar(100),          
@deal_date varchar(10),          
@frequency_type char(1),          
@broker_id int,          
@hour_from int,          
@hour_to int,          
@source_deal_detail_id varchar(1000),          
@deal_id varchar(1000),          
@physical_financial_flag CHAR(1),          
@option_type CHAR(1),          
@option_excercise_type CHAR(1),          
@options_term_start VARCHAR(20),          
@options_term_end VARCHAR(20),          
@exercise_date VARCHAR(20),          
@round_value char(2)='9',          
@deleted_deal VARCHAR(1)='n',          
@call_from_paging CHAR(1)='n'     --- if called from spa_sourcedealtemp_detail_paging      
    
  set @flag='g'  
  set @source_deal_header_id=4261  
  set @call_from_paging='n'  
  drop table #tempDeal  
  drop table #temp_uddf  
  --*/  
   
DECLARE @sql_Select VARCHAR(MAX)          
DECLARE @copy_source_deal_header_id INT          
DECLARE @starategy_id INT          
DECLARE @sub_id INT          
DECLARE @term_start_value VARCHAR(10)          
DECLARE @term_end_value VARCHAR(10)          
--Declare @book_id int          
          
DECLARE @source_book_id1 INT          
DECLARE @source_book_id2 INT          
DECLARE @source_book_id3 INT          
DECLARE @source_book_id4 INT          
DECLARE @new_deal_id VARCHAR(20)          
DECLARE @new_source_system_id INT          
--declare @frequency_type varchar(1)          
DECLARE @frequency INT          
DECLARE @new_buy_sell VARCHAR(10)          
DECLARE @new_entire_term_end VARCHAR(10)          
          
          
DECLARE @tempheadertable VARCHAR(128)       
DECLARE @tempdetailtable VARCHAR(128)          
DECLARE @user_login_id VARCHAR(100)          
DECLARE @val VARCHAR(100)          
DECLARE @leg_no INT          
DECLARE @buy_label VARCHAR(20)
DECLARE @sell_label VARCHAR(20) 
DECLARE @source_deal_type_name VARCHAR(100)       
DECLARE @price_round_value VARCHAR(10)


SELECT @source_deal_type_name = sdt.source_deal_type_name
FROM   source_deal_header sdh
INNER JOIN source_deal_type sdt ON sdh.source_deal_type_id = sdt.source_deal_type_id
WHERE  sdh.source_deal_header_id = @source_deal_header_id

IF @source_deal_type_name = 'Transport' OR @source_deal_type_name = 'Gas Pipeline Cut' OR @source_deal_type_name = 'Capacity NG'
	OR @source_deal_type_name = 'TRANSMISSION'
BEGIN
	SET @buy_label = 'Delivery'
	SET @sell_label = 'Receipt'
END	 
ELSE IF (@source_deal_type_name = 'Capacity Release')
BEGIN
	SET @buy_label = 'Receipt'
	SET @sell_label = 'Delivery'
END
ELSE
BEGIN
	SET @buy_label = 'Buy(Receive)'
	SET @sell_label = 'Sell(Pay)'		 
END     
          
SET @user_login_id=dbo.FNADBUser()          
--set @user_login_id='urbaral'          
        
 IF @process_id IS NULL          
 BEGIN          
  SET @process_id=REPLACE(NEWID(),'-','_')          
            
 END          
 SET @tempheadertable=dbo.FNAProcessTableName('source_deal_header_temp', @user_login_id,@process_id)          
 SET @tempdetailtable=dbo.FNAProcessTableName('source_deal_detail_temp', @user_login_id,@process_id)          
           
    
IF ISNULL(@round_value,'')=''    
 SET @round_value=5    
 
 SET @price_round_value= 5    
            
DECLARE @max_leg INT,@buy_sell CHAR(1),@label_index VARCHAR(50),@label_price VARCHAR(50)          
IF @flag = 'a'  --select temp header data          
 BEGIN          
           
           
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
            
           
 SELECT TOP 1 @product_id = curve_id FROM source_deal_detail WHERE source_deal_header_id = @source_deal_header_id ORDER BY Leg, term_start          
           
            
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
          
SET @sql_select=
		'SELECT dh.source_deal_header_id DetailId,dh.source_system_id ,dh.deal_id,           
	  dbo.FNAGetSQLStandardDate(dh.deal_date) deal_date, dh.ext_deal_id ,dh.physical_financial_flag,           
	  dh.counterparty_id, dbo.FNAGetSQLStandardDate(dh.entire_term_start) entire_term_start,           
	  dbo.FNAGetSQLStandardDate(dh.entire_term_end) entire_term_end, dh.source_deal_type_id,           
	  dh.deal_sub_type_type_id, dh.option_flag, dh.option_type, dh.option_excercise_type,           
	  dh.source_system_book_id1 As Group1, dh.source_system_book_id2 AS Group2,           
	  dh.source_system_book_id3 AS Group3, dh.source_system_book_id4 AS Group4,          
	  dh.description1,dh.description2,dh.description3,          
	  dh.deal_category_value_id,dh.trader_id, ssbm.fas_book_id,portfolio_hierarchy.parent_entity_id,          
	  fas_strategy.hedge_type_value_id,static_data_value1.code as HedgeItemFlag,          
	  static_data_value2.code as HedgeType,source_currency.currency_name as Currency,               
	  dh.internal_deal_type_value_id,dh.internal_deal_subtype_value_id,dh.template_id,dh.structured_deal_id,dh.header_buy_sell_flag,          
	  dh.broker_id, dh.generator_id, dh.status_value_id, dbo.FNAGetSQLStandardDate(dh.status_date) status_date,          
	  dh.assignment_type_value_id, dh.compliance_year, dh.state_value_id,  dbo.FNAGetSQLStandardDate(dh.assigned_date) assigned_date ,     
	   dh.assigned_by,dh.generation_source ,          
	  isnull(dh.aggregate_environment, rg.aggregate_environment) aggregate_environment,          
	  isnull(dh.aggregate_envrionment_comment, rg.aggregate_envrionment_comment) aggregate_envrionment_comment,          
	 dh.create_user,dbo.FNADateTimeFormat(dh.create_ts,1) create_ts,dh.update_user,dbo.FNADateTimeFormat(dh.update_ts,1) update_ts,          
	 dbo.FNAGetAssignmentDesc(5147) AssignmentDesc1,           
	 dbo.FNADEALRECExpiration(dh.source_deal_header_id, sdd.contract_expiration_date, 5147) DEALRECExpiration1,          
	 dbo.FNAGetAssignmentDesc(5146) AssignmentDesc2,           
	 dbo.FNADEALRECExpiration(dh.source_deal_header_id, sdd.contract_expiration_date, 5146) DEALRECExpiration2,          
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
	  CASE WHEN dh.deal_locked = ''y'' THEN ''Yes''          
	  ELSE           
	   CASE WHEN dls.id IS NOT NULL THEN          
		CASE WHEN DATEADD(mi, dls.hour * 60 + ISNULL(dls.minute,0), ISNULL(dh.update_ts, dh.create_ts)) < GETDATE() THEN ''Yes''          
		ELSE ''No'' END          
	   ELSE ''No''          
	   END          
	  END          
	 ) AS deal_locked,dh.close_reference_id,          
	 dh.block_type,dh.block_define_id,dh.granularity_id,dh.pricing [Pricing],sdd.process_deal_status,          
		sdv_con_stat.value_id ConfirmStatus,          
		  dbo.FNAGetSQLStandardDate(ConfirmStatusDate) ConfirmStatusDate,          
		  ConfirmUser,          
		  dh.unit_fixed_flag,             
		ISNULL(dh.broker_unit_fees,' + CASE WHEN @broker_unit_price IS NULL THEN 'NULL' ELSE CAST(@broker_unit_price AS VARCHAR) END + '),          
		ISNULL(dh.broker_fixed_cost,'+ CASE WHEN @broker_fixed_price IS NULL THEN 'NULL' ELSE CAST(@broker_fixed_price AS VARCHAR) END + '),          
		  dh.broker_currency_id,dh.deal_status,          
		  dbo.FNADateformat(dh.option_settlement_date) option_settlement_date,          
		  isNull(sdht.term_end_flag,''n'') term_end_flag,          
		  ssbm.book_deal_type_map_id,          
		  parentC.counterparty_name parent_counterparty,    
		  dh.deal_reference_type_id,    
		  sdht.field_template_id,
		  subs.entity_name,
		  sdht.deal_rules,
		  sdht.confirm_rule,
		  dh.timezone_id
	  FROM ' +CASE WHEN ISNULL(@deleted_deal,'n')='y' THEN  'delete_source_deal_header' ELSE 'source_deal_header' END +' dh LEFT OUTER JOIN rec_generator rg on dh.generator_id = rg.generator_id           
	  LEFT OUTER JOIN formula_editor f on           
	  case  when (dh.source_deal_type_id <> 55) then NULL          
	   when (dh.rec_price is null and dh.rec_formula_id is null) then rg.rec_formula_id           
	   else dh.rec_formula_id end = f.formula_id          
	   INNER JOIN source_book ON dh.source_system_book_id1 = source_book.source_book_id           
	  INNER JOIN ' +CASE WHEN ISNULL(@deleted_deal,'n')='y' THEN  'delete_source_deal_detail' ELSE 'source_deal_detail' END +' sdd on sdd.source_deal_header_id=dh.source_deal_header_id          
	  INNER JOIN source_book source_book_1 ON dh.source_system_book_id2 = source_book_1.source_book_id INNER JOIN          
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
	  where dh.source_deal_header_id='+CAST(@source_deal_header_id AS VARCHAR)          
 EXEC spa_print @sql_select          
 EXEC(@sql_select)          
 END           
       
ELSE IF @flag='s'          
 BEGIN          
 SELECT @max_leg=MAX(Leg),@buy_sell=MAX(buy_sell_flag) FROM source_deal_detail           
  WHERE source_deal_header_id=@source_deal_header_id          
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
  --print 'asas'          
 SET @sql_select='          
			select  a.source_deal_detail_id,          
			dbo.FNADateFormat(term_start) as TermStart,           
			dbo.FNADateFormat(term_end) as TermEnd,          
			-- CONVERT(VARCHAR(10),term_start,120) as TermStart,           
			-- CONVERT(VARCHAR(10),term_end,120) as TermEnd,          
			Leg,           
			dbo.FNADateFormat(contract_expiration_date)  as ExpDate,          
			--  CONVERT(VARCHAR(10),contract_expiration_date,120)  as ExpDate,          
			case when fixed_float_leg=''f'' then ''Fixed'' else ''Float'' End as [Fixed/Float],          
			CASE 
			WHEN h.source_deal_type_id = 93 then   
					CASE WHEN a.buy_sell_flag = ''s'' THEN '''+ @buy_label + ''' 
						 ELSE ''' + @sell_label + ''' 
					END
			ELSE  CASE WHEN a.buy_sell_flag = ''b'' THEN '''+ @buy_label + ''' ELSE ''' + @sell_label + ''' END 
			END  as [Buy/Sell],          
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
			--pcd.source_curve_def_id as  ['+@label_index+'],          
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
			block_description end as Bonus,deal_detail_description as HourEnding,          
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
			where a.source_deal_header_id='+CAST(@source_deal_header_id AS VARCHAR)          
          
  IF @term_start IS NOT NULL          
  SET @sql_select= @sql_select+ ' AND term_start='''+@term_start+''''          
           
  IF @term_start IS NOT NULL          
  SET @sql_select= @sql_select +' AND term_end='''+@term_end+''''          
            
  SET @sql_select= @sql_select+ ' ORDER BY term_start, leg '          
            
  EXEC spa_print @sql_select          
          
  EXEC(@sql_select)          
            
 END          
           
ELSE IF @flag='p' --show in editable grid
BEGIN          
	SELECT @max_leg = MAX(Leg), @buy_sell = MAX(buy_sell_flag) 
	FROM source_deal_detail           
	WHERE source_deal_header_id = @source_deal_header_id          
	
	SET @label_index = 'Index'          
	SET @label_price = 'Price'          
	
	IF @max_leg = 1 AND @buy_sell = 'b'          
	BEGIN          
		SET @label_index = 'Buy Index'          
		SET @label_price = 'Price'          
	END          
	ELSE IF @max_leg = 1 AND @buy_sell = 's'          
	BEGIN        
		SET @label_index = 'Sell Index'          
		SET @label_price = 'Price'          
	END   
 
 
	SET @sql_select='          
					SELECT  a.source_deal_detail_id,          
							term_start as TermStart,           
							term_end as TermEnd,          
							Leg,           
							contract_expiration_date  as ExpDate,          
							--case when fixed_float_leg=''f'' then ''Fixed'' else ''Float'' End as [Fixed/Float],          
							fixed_float_leg as [Fixed/Float],
							--case when buy_sell_flag =''b'' then ''Buy(Receive)'' else ''Sell(Pay)'' End as [Buy/Sell],          
							buy_sell_flag as [Buy/Sell],          
							pcd.source_curve_type_value_id curve_type,           
							pcd.commodity_id  as commodity,          
							a.physical_financial_flag AS [Physical/Financial],          
							a.location_id as Location,           
							--a.curve_id as  ['+@label_index+'],  
							--spcd.[curve_name]  as  ['+@label_index+'],  
							pcd.source_curve_def_id as ['+@label_index+'],          
							ROUND(dbo.FNARemoveTrailingZeroes(CAST(deal_volume AS numeric(38,20))),'+@round_value+') as Volume,          
							deal_volume_frequency as Frequency,          
							deal_volume_uom_id as UOM,          
							ROUND(dbo.FNARemoveTrailingZeroes(CAST(total_volume AS numeric(38,9))),'+@round_value+') as [TotalVolume],        
							capacity as Capacity,
							case  when sdt.expiration_applies =''y'' and          
							( a.fixed_price is null and a.formula_id is null)  then           
							dbo.FNARemoveTrailingZeroes(round(CAST(rg.contract_price AS numeric(38,15)),'+@price_round_value+')) else           
							dbo.FNARemoveTrailingZeroes(round(CAST(fixed_price AS numeric(38,15)),'+@price_round_value+')) end as ['+@label_price+'],          
							dbo.FNARemoveTrailingZeroes(CAST(fixed_cost AS numeric(38,15))) AS [Fixed Cost],          
							fixed_cost_currency_id,          
							fe.formula_id as Formula,          
							formula_currency_id,          
							dbo.FNARemoveTrailingZeroes(ROUND(option_strike_price,9)) as OptionStrike,          
							dbo.FNARemoveTrailingZeroes(price_adder) PriceAdder,          
							adder_currency_id,          
							--dbo.FNARemoveTrailingZeroes(ISNULL(price_multiplier,1)) PriceMultiplier,          
							--dbo.FNARemoveTrailingZeroes(ISNULL(multiplier,1)) Multiplier, 
							dbo.FNARemoveTrailingZeroes(price_multiplier) PriceMultiplier,          
							dbo.FNARemoveTrailingZeroes(multiplier) Multiplier, 
							fixed_price_currency_id as Currency,               
							dbo.FNARemoveTrailingZeroes(price_adder2) PriceAdder2,          
							price_adder_currency2,          
							--dbo.FNARemoveTrailingZeroes(ISNULL(volume_multiplier2,1)) VolumeMultiplier2,  
							dbo.FNARemoveTrailingZeroes(volume_multiplier2) VolumeMultiplier2,            
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
							a.pv_party [Pv Party],
							a.formula_curve_id [Formula Curve ID],
							a.[lock_deal_detail],
							a.[status],
							0 [counter] 
					FROM ' + CASE WHEN ISNULL(@deleted_deal,'n') = 'y' THEN 'delete_source_deal_detail' ELSE 'source_deal_detail' END +' a 
					INNER JOIN ' + CASE WHEN ISNULL(@deleted_deal,'n') = 'y' THEN 'delete_source_deal_header' ELSE 'source_deal_header' END + ' h ON a.source_deal_header_id=h.source_deal_header_id 
					INNER join source_deal_type sdt on sdt.source_deal_type_id = h.source_deal_type_id           
					LEFT OUTER JOIN source_price_curve_def pcd on pcd.source_curve_def_id = a.curve_id           
					LEFT OUTER JOIN rec_generator rg on rg.generator_id = h.generator_id          
					LEFT OUTER JOIN formula_editor fe on fe.formula_id = a.formula_id          
					LEFT OUTER JOIN source_minor_location sml ON sml.source_minor_location_id = a.location_id    
					LEFT JOIN source_Major_Location ON sml.source_Major_Location_Id = source_Major_Location.source_major_location_ID        
					LEFT OUTER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = a.curve_id  
					WHERE a.source_deal_header_id = ' + CAST(@source_deal_header_id AS VARCHAR(100))          

	   
	IF @term_start IS NOT NULL          
		SET @sql_select= @sql_select+ ' AND term_start='''+@term_start+''''          
	       
	IF @term_start IS NOT NULL          
		SET @sql_select= @sql_select +' AND term_end='''+@term_end+''''          
	        
	SET @sql_select= @sql_select + ' ORDER BY term_start,leg '          
	        
	EXEC spa_print @sql_select          
	EXEC(@sql_select)          
	        
END          
          
ELSE IF @flag='g' -- NON Edit Grid   
BEGIN          
            
	IF ISNULL(@deleted_deal,'n')='y'          
		SELECT @max_leg=MAX(Leg),@buy_sell=MAX(buy_sell_flag),@option_flag=MAX(option_flag)           
		FROM delete_source_deal_detail sdd JOIN delete_source_deal_header sdh ON sdh.source_deal_header_id=sdd.source_deal_header_id          
		WHERE sdd.source_deal_header_id=@source_deal_header_id          
	ELSE          
		SELECT @max_leg=MAX(Leg),@buy_sell=MAX(buy_sell_flag),@option_flag=MAX(option_flag)           
		FROM source_deal_detail sdd JOIN source_deal_header sdh ON sdh.source_deal_header_id=sdd.source_deal_header_id          
		WHERE sdd.source_deal_header_id=@source_deal_header_id          
    
    
	DECLARE @position_uom VARCHAR(100)

	SELECT @position_uom = CASE 
				WHEN spcd.display_uom_id IS NULL THEN su.uom_name
				ELSE su1.uom_name
		   END
	FROM   source_price_curve_def spcd
		   LEFT JOIN source_uom su
				ON  spcd.uom_id = su.source_uom_id
		   LEFT JOIN source_uom su1
				ON  spcd.display_uom_id = su1.source_uom_id
		   INNER JOIN source_deal_detail sdd
				ON  spcd.source_curve_def_id = sdd.curve_id
	WHERE  sdd.source_deal_header_id = @source_deal_header_id
        
	SET @label_index='Index'          
	SET @label_price='Price'          
	
	IF @max_leg=1 AND @buy_sell='b'          
	BEGIN          
		SET @label_index='Buy Index'          
		SET @label_price='Sell Price'          
	END          
	ELSE IF @max_leg=1 AND @buy_sell='s'          
	BEGIN          
		SET @label_index='Sell Index'          
		SET @label_price='Buy Price'          
	END          
            
	DECLARE @term_label VARCHAR(20)          
           
           
	IF ISNULL(@deleted_deal,'n')='y'          
		SELECT  @term_label = CASE sdht.term_end_flag           
							WHEN 'y' THEN 'Term'           
							ELSE 'Term Start' END          
		FROM delete_source_deal_header sdh          
		LEFT OUTER JOIN source_deal_header_template sdht ON  sdh.template_id = sdht.template_id          
		WHERE  sdh.source_deal_header_id = @source_deal_header_id           
	ELSE          
		SELECT @term_label = CASE sdht.term_end_flag        
							WHEN 'y' THEN 'Term'           
							ELSE 'Term Start' END          
		FROM source_deal_header sdh          
		LEFT OUTER JOIN source_deal_header_template sdht ON sdh.template_id = sdht.template_id          
		WHERE sdh.source_deal_header_id = @source_deal_header_id           
           
	DECLARE @deal_volume_frequency_column VARCHAR(50)          
	
	IF @deal_volume_frequency IS NULL BEGIN          
		SET @deal_volume_frequency_column = 'deal_volume_frequency'                                           
	END 
	ELSE 
	BEGIN          
		SET @deal_volume_frequency_column = '''' + @deal_volume_frequency + ''''          
	END          
   
CREATE TABLE #tempDeal(    
 [source_deal_detail_id] [INT] NOT NULL,    
 [source_deal_header_id] [INT] NOT NULL,    
 [term_start] VARCHAR(50) COLLATE DATABASE_DEFAULT NOT NULL,    
 [term_end] VARCHAR(50) COLLATE DATABASE_DEFAULT NOT NULL,    
 [Leg] [INT] NOT NULL,    
 [contract_expiration_date] VARCHAR(50) COLLATE DATABASE_DEFAULT NOT NULL,    
 [fixed_float_leg] [VARCHAR](50) COLLATE DATABASE_DEFAULT NOT NULL,    
 [buy_sell_flag] [VARCHAR](50) COLLATE DATABASE_DEFAULT NOT NULL,    
 [curve_id] [VARCHAR](500) COLLATE DATABASE_DEFAULT NULL,    
 [fixed_price] [NUMERIC](38, 20) NULL,    
 [fixed_price_currency_id] [VARCHAR](50) COLLATE DATABASE_DEFAULT NULL,    
 [option_strike_price] [NUMERIC](38, 20) NULL,    
 [deal_volume] [NUMERIC](38, 20) NULL,    
 [deal_volume_frequency] [VARCHAR](50) COLLATE DATABASE_DEFAULT NOT NULL,    
 [deal_volume_uom_id] [VARCHAR](50) COLLATE DATABASE_DEFAULT NOT NULL,    
 [block_description] [VARCHAR](100) COLLATE DATABASE_DEFAULT NULL,    
 [deal_detail_description] [VARCHAR](100) COLLATE DATABASE_DEFAULT NULL,    
 [formula_id] [VARCHAR](500) COLLATE DATABASE_DEFAULT NULL,    
 [volume_left] [FLOAT] NULL,    
 [settlement_volume] [FLOAT] NULL,    
 [settlement_uom] [VARCHAR](50) COLLATE DATABASE_DEFAULT NULL,    
 [create_user] [VARCHAR](50) COLLATE DATABASE_DEFAULT NULL,    
 [create_ts] [VARCHAR](50) COLLATE DATABASE_DEFAULT NULL,    
 [update_user] [VARCHAR](50) COLLATE DATABASE_DEFAULT NULL,    
 [update_ts] [VARCHAR](50) COLLATE DATABASE_DEFAULT NULL,    
 [price_adder] [NUMERIC](38, 20) NULL,    
 [price_multiplier] [NUMERIC](38, 20) NULL,    
 [settlement_date] [VARCHAR](50)  NULL,    
 [day_count_id] [VARCHAR](50) COLLATE DATABASE_DEFAULT NULL,    
 [location_id] [VARCHAR](500) COLLATE DATABASE_DEFAULT NULL,    
 [meter_id] [VARCHAR](50) COLLATE DATABASE_DEFAULT NULL,    
 [physical_financial_flag] [VARCHAR](50) COLLATE DATABASE_DEFAULT NULL,    
 [Booked] [VARCHAR](50) COLLATE DATABASE_DEFAULT NULL,    
 [process_deal_status] [VARCHAR](50) COLLATE DATABASE_DEFAULT NULL,    
 [fixed_cost] [NUMERIC](38, 20) NULL,    
 [multiplier] [NUMERIC](38, 20) NULL,    
 [adder_currency_id] [VARCHAR](50) COLLATE DATABASE_DEFAULT NULL,    
 [fixed_cost_currency_id] [VARCHAR](50) COLLATE DATABASE_DEFAULT NULL,    
 [formula_currency_id] [VARCHAR](50) COLLATE DATABASE_DEFAULT NULL,    
 [price_adder2] [NUMERIC](38, 20) NULL,    
 [price_adder_currency2] [VARCHAR](50) COLLATE DATABASE_DEFAULT NULL,    
 [volume_multiplier2] [NUMERIC](38, 20) NULL,    
 [total_volume] [NUMERIC](38, 20) NULL,    
 [pay_opposite] [VARCHAR](50) COLLATE DATABASE_DEFAULT NULL,    
 [capacity] [NUMERIC](38, 20) NULL,    
 [settlement_currency] [VARCHAR](50) COLLATE DATABASE_DEFAULT NULL,    
 [standard_yearly_volume] [FLOAT] NULL,    
 [formula_curve_id] [VARCHAR](500) COLLATE DATABASE_DEFAULT NULL,    
 [price_uom_id] [VARCHAR](50) COLLATE DATABASE_DEFAULT NULL,    
 [Category] [VARCHAR](50) COLLATE DATABASE_DEFAULT NULL,    
 [profile_code] [VARCHAR](50) COLLATE DATABASE_DEFAULT NULL,    
 [pv_party] [VARCHAR](50) COLLATE DATABASE_DEFAULT NULL,
 [lock_deal_detail] [VARCHAR](50) COLLATE DATABASE_DEFAULT NULL,
 [status] [VARCHAR](50) COLLATE DATABASE_DEFAULT NULL
)    
 
SET @sql_select=' insert into #tempDeal([source_deal_detail_id]    
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
      ,[pv_party]
	  ,[lock_deal_detail]
	  ,[status])       
 select a.[source_deal_detail_id]    
      ,a.[source_deal_header_id]    
     , dbo.FNAGetDisplayFormat(a.term_start,null,h.template_id,''term_start'') term_start  
     , dbo.FNAGetDisplayFormat(a.term_end,null,h.template_id,''term_end'') term_end  
      ,a.[Leg]    
      ,dbo.FNADateFormat(a.contract_expiration_date) [contract_expiration_date]    
      ,case when fixed_float_leg=''f'' then ''Fixed'' else ''Float'' End         
       , CASE 
			WHEN h.source_deal_type_id = 93 then   
					CASE WHEN a.buy_sell_flag = ''s'' THEN '''+ @buy_label + ''' 
						 ELSE ''' + @sell_label + ''' 
					END
			ELSE  CASE WHEN a.buy_sell_flag = ''b'' THEN '''+ @buy_label + ''' ELSE ''' + @sell_label + ''' END 
         END     
      , dbo.FNAHyperLinkText(10102610, spcd.[curve_name], a.curve_id)     
      , case  when sdt.expiration_applies =''y'' and          
   ( a.fixed_price is null and a.formula_id is null)  then           
    dbo.FNARemoveTrailingZeroes(round(CAST(rg.contract_price AS numeric(38,20)), ' + @price_round_value + '))     
   else           
    dbo.FNARemoveTrailingZeroes(round(CAST(fixed_price AS numeric(38,20)), ' + @price_round_value + ')) END [fixed_price]    
      ,sc.currency_name [fixed_price_currency_id]    
      ,a.[option_strike_price]    
      ,dbo.FNARemoveTrailingZeroes(ROUND(a.deal_volume, ' + @round_value + ') )  [deal_volume]    
      ,        
   CASE '+ @deal_volume_frequency_column + '          
     WHEN ''x'' THEN ''15 Minutes''          
     WHEN ''y'' THEN ''30 Minutes''
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
      ,su.uom_name  [settlement_uom]    
      ,a.[create_user]    
      ,a.[create_ts]    
      ,a.[update_user]    
      ,a.[update_ts]    
      ,a.[price_adder]    
      ,a.[price_multiplier]    
      ,ISNULL(dbo.FNADateFormat(a.settlement_date),dbo.FNADateFormat(a.contract_expiration_date)) settlement_date    
      ,sdv.code [day_count_id]    
      ,dbo.FNAHyperLinkText(10102510, sml.location_name, a.location_id) [location_id]  
      ,mi.recorderid [meter_id]    
      ,CASE WHEN a.physical_financial_flag = ''p'' THEN ''Physical'' ELSE ''Financial'' END  [physical_financial_flag]    
      ,a.[Booked]    
      ,a.[process_deal_status]    
      ,dbo.FNARemoveTrailingZeroes(CAST(fixed_cost AS numeric(38,20))) [fixed_cost]    
      ,a.[multiplier]    
      ,scpa.currency_name [adder_currency_id]    
      ,scfc.currency_name [fixed_cost_currency_id]    
      ,scfr.currency_name [formula_currency_id]    
      ,dbo.FNARemoveTrailingZeroes(price_adder2) [price_adder2]    
      ,scpa1.currency_name [price_adder_currency2]    
      --,dbo.FNARemoveTrailingZeroes(ISNULL(volume_multiplier2,1)) [volume_multiplier2] 
      ,dbo.FNARemoveTrailingZeroes(volume_multiplier2) [volume_multiplier2]    
      ,dbo.FNARemoveTrailingZeroes(ROUND(a.[total_volume], ' + @round_value + ')) [total_volume]   
      ,a.[pay_opposite]    
      ,a.[capacity]    
      ,setcur.currency_name [settlement_currency]    
      ,a.[standard_yearly_volume]    
      ,dbo.FNAHyperLinkText(10102610, spcd2.[curve_name], spcd2.source_curve_def_id)
      ,pu.uom_name [price_uom_id]    
      ,sdvc.code [category]    
      ,sdvp.Code [profile_code]    
      ,sdvpv.code [pv_party]
	  , CASE WHEN a.lock_deal_detail = ''n'' THEN ''No'' WHEN a.lock_deal_detail = ''y'' THEN ''Yes'' ELSE '''' END lock_deal_detail
      , schk.code [Status] 
  FROM ' +CASE WHEN ISNULL(@deleted_deal,'n')='y' THEN  'delete_source_deal_detail' ELSE 'source_deal_detail' END +' a join          
  ' +CASE WHEN ISNULL(@deleted_deal,'n')='y' THEN  'delete_source_deal_header' ELSE 'source_deal_header' END +' h on          
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
  LEFT JOIN source_price_curve_def spcd2 ON spcd2.source_curve_def_id = a.formula_curve_id   
  LEFT JOIN source_uom su ON spcd.display_uom_id = su.source_uom_id       
  LEFT JOIN source_uom pu ON a.price_uom_id = pu.source_uom_id
  LEFT OUTER JOIN static_data_value sdvc on sdvc.value_id=a.category    
  LEFT OUTER JOIN static_data_value sdvpv on sdvpv.value_id=a.pv_party    
  LEFT OUTER JOIN static_data_value sdvp on sdvp.value_id=a.profile_code    
  LEFT OUTER JOIN static_data_value schk ON schk.value_id = a.status  
  where a.source_deal_header_id='+CAST(@source_deal_header_id AS VARCHAR)          
  IF @term_start IS NOT NULL          
  SET @sql_select= @sql_select+ ' And term_start='''+@term_start+''''          
           
  IF @term_start IS NOT NULL          
  SET @sql_select= @sql_select +' And term_end='''+@term_end+''''          
            
  SET @sql_select= @sql_select+ ' ORDER BY term_start,leg '          
     EXEC spa_print 'ck'    
             
  EXEC spa_print @sql_select          
  EXEC(@sql_select)     

   IF @call_from_paging = 'y' --- if called from paging sps
   BEGIN
       SELECT source_deal_detail_id,
              term_start,
              term_end,
              Leg,
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
              Category,
              profile_code,
              pv_party,
              lock_deal_detail,
              [status]
       FROM   #tempDeal
       
       RETURN
   END 
       
         
  DECLARE @field_template_id INT    
  --SELECT @field_template_id=field_template_id FROM source_deal_header sdh JOIN dbo.source_deal_header_template tem ON sdh.template_id=tem.template_id    
  --WHERE sdh.source_deal_header_id=@source_deal_header_id     
   
   
  IF @deleted_deal = 'n'
  BEGIN  
	  SELECT @field_template_id = field_template_id FROM source_deal_header sdh JOIN dbo.source_deal_header_template tem ON sdh.template_id=tem.template_id    
	  WHERE sdh.source_deal_header_id = @source_deal_header_id  
  END 
  ELSE 
  BEGIN 
  	  SELECT @field_template_id = field_template_id FROM delete_source_deal_header dsdh JOIN dbo.source_deal_header_template tem ON dsdh.template_id=tem.template_id    
	  WHERE dsdh.source_deal_header_id = @source_deal_header_id  
  END  
  
     
	DECLARE @udf_field     VARCHAR(5000),
	        @udf_value     VARCHAR(MAX),
	        @udf_join      VARCHAR(MAX),
	        @udf_field_id  VARCHAR(MAX)
	
	SET @udf_field = ''    
	SET @udf_value = ''  
	SET @udf_join = '' 
	SET @udf_field_id = ''
	
	SELECT @udf_field = @udf_field + ' UDF___' + CAST(udf_temp.udf_template_id AS VARCHAR) + ' VARCHAR(1000),',
	       @udf_value = @udf_value + ' UDF___' + CAST(udf_temp.udf_template_id AS VARCHAR) + '=u.[' + CAST(udf_temp.udf_template_id AS VARCHAR) + '],',
	       @udf_field_id = @udf_field_id + '[' + CAST(d.field_id AS VARCHAR) + '],'
	FROM   maintain_field_template_detail d
	       JOIN user_defined_fields_template udf_temp
	            ON  d.field_id = udf_temp.udf_template_id
	       JOIN user_defined_deal_fields_template uddft
	            ON  uddft.field_name = udf_temp.field_name
	            AND uddft.template_id = @template_id
	WHERE  field_template_id = @field_template_id
	       AND udf_or_system = 'u'
	       AND udf_temp.udf_type = 'd'
	       AND d.field_template_id = @field_template_id
	       AND uddft.leg = 1

  CREATE TABLE #udf_table(udf_template_id INT, udf_id VARCHAR(255) COLLATE DATABASE_DEFAULT, udf_code VARCHAR(1000) COLLATE DATABASE_DEFAULT)
  
  IF LEN(@udf_field)>1    
  BEGIN
  	DECLARE @udf_template_id INT, @udf_sql_string VARCHAR(5000), @field_type VARCHAR(30)
  	
	SET @udf_field = LEFT(@udf_field, LEN(@udf_field) -1)    
	SET @udf_value = LEFT(@udf_value, LEN(@udf_value) -1)   
	SET @udf_field_id = LEFT(@udf_field_id, LEN(@udf_field_id) -1)
	
	EXEC spa_print 'ALTER TABLE #tempDeal add ', @udf_field
	EXEC ('ALTER TABLE #tempDeal add '+ @udf_field)
	
	--store UDF key, values in a temp table
	EXEC spa_print '@source_deal_header_id: ', @source_deal_header_id 
	BEGIN TRY
		DECLARE cur_udf_value CURSOR LOCAL FOR
		SELECT DISTINCT udddf.udf_template_id, ISNULL(NULLIF(udft.sql_string, ''), uds.sql_string) sql_string, udft.Field_type
		FROM source_deal_detail sdd 
		LEFT JOIN user_defined_deal_detail_fields udddf ON sdd.source_deal_detail_id = udddf.source_deal_detail_id
		LEFT JOIN user_defined_deal_fields_template uddft ON uddft.udf_template_id = udddf.udf_template_id
		LEFT JOIN user_defined_fields_template udft ON uddft.field_name = udft.field_name
		LEFT JOIN udf_data_source uds ON uds.udf_data_source_id = udft.data_source_type_id 
		WHERE source_deal_header_id = @source_deal_header_id
			AND uddft.Field_type IN( 'd', 'w')

		OPEN cur_udf_value;

		FETCH NEXT FROM cur_udf_value INTO @udf_template_id, @udf_sql_string, @field_type
		WHILE @@FETCH_STATUS = 0
		BEGIN
			exec spa_print 'Now processing udf_template_id: ', @udf_template_id, ' with source: ', @udf_sql_string
			
			IF @field_type = 'w'
			BEGIN
				INSERT INTO #udf_table(udf_id, udf_code)
				SELECT fe.formula_id,dbo.FNAFormulaFormat(fe.formula,'r') AS [Formula] FROM formula_editor fe
			END
			ELSE
			BEGIN
				INSERT INTO #udf_table(udf_id, udf_code)
				EXEC spa_execute_query @udf_sql_string
			END
			
			--save udf_tempalate_id			
			UPDATE #udf_table SET udf_template_id = @udf_template_id WHERE udf_template_id IS NULL
				
			FETCH NEXT FROM cur_udf_value INTO @udf_template_id, @udf_sql_string, @field_type
		END;

		CLOSE cur_udf_value;
		DEALLOCATE cur_udf_value; 
	END TRY
	BEGIN CATCH
		IF CURSOR_STATUS('local', 'cur_udf_value') >= 0 
		BEGIN
			CLOSE cur_udf_value
			DEALLOCATE cur_udf_value;
		END
		
		--EXEC spa_print ERROR_MESSAGE()
	END CATCH
  END	--UDF processing end
 
  

	SELECT udft2.udf_template_id,
		uddf.source_deal_detail_id,
		CASE 
			WHEN udft.Field_type = 'a' THEN dbo.FNADateFormat(uddf.udf_value) 
			WHEN udft.Field_type = 'c' AND uddf.udf_value = 'y' THEN 'Yes'
			WHEN udft.Field_type = 'c' AND uddf.udf_value = 'n' THEN 'No'
			--if field type is dropdown, fetch code instead of key to show in non-edit grid
			WHEN udft.Field_type IN('d', 'w') THEN ut.udf_code
			ELSE uddf.udf_value
		END udf_value INTO #temp_uddf
	FROM   user_defined_deal_detail_fields uddf
	INNER JOIN user_defined_deal_fields_template udft
		ON  uddf.udf_template_id = udft.udf_template_id
	INNER JOIN source_deal_detail sdd
		ON  sdd.source_deal_detail_id = uddf.source_deal_detail_id
	INNER JOIN user_defined_fields_template udft2
		ON udft2.field_name = udft.field_name
	LEFT JOIN #udf_table ut
		ON ut.udf_template_id = uddf.udf_template_id
		AND udft.Field_type IN('d', 'w')
		AND ut.udf_id = uddf.udf_value
	WHERE  sdd.source_deal_header_id = @source_deal_header_id  
   
       
    --DECLARE @listCol VARCHAR(2000)  
	--SELECT  @listCol = STUFF(( SELECT DISTINCT '],[' + LTRIM(udf_user_field_id)
	--                           FROM   #temp_uddf
	--                           ORDER BY
	--                                  '],[' + LTRIM(udf_user_field_id) FOR XML 
	--                                  PATH('')  
	--						), 1, 2, ''
	--						) + ']' 
	--PRINT @listcol   

	DECLARE @query2 VARCHAR(4000)  
	
	IF @udf_value <> '' AND @udf_field_id <> ''
	BEGIN
		SET @query2 = 'UPDATE #tempDeal SET ' + @udf_value + ' from #tempDeal t join (  
					SELECT * FROM   
					(SELECT source_deal_detail_id,udf_template_id,udf_value from #temp_uddf) src    
					PIVOT (max(udf_value) FOR udf_template_id   
					IN (' + @udf_field_id + ')) AS pvt) u   
					ON t.source_deal_detail_id=u.source_deal_detail_id  
					'  
		exec spa_print @query2  
		EXEC(@query2) 
	END
    
	SELECT sdd.source_deal_detail_id,
	       CASE 
	            WHEN spcd.display_uom_id IS NULL THEN su.uom_name
	            ELSE su1.uom_name
	       END uom_name INTO #tmp_curve_uom_map
	FROM   source_price_curve_def spcd
	       LEFT JOIN source_uom su
	            ON  spcd.uom_id = su.source_uom_id
	       LEFT JOIN source_uom su1
	            ON  spcd.display_uom_id = su1.source_uom_id
	       INNER JOIN source_deal_detail sdd
	            ON  spcd.source_curve_def_id = sdd.curve_id
	WHERE  sdd.source_deal_header_id = @source_deal_header_id
	 
   
	DECLARE @sql_pre          VARCHAR(MAX),
		  @farrms_field_id  VARCHAR(100),
		  @default_label    VARCHAR(100),
		  @data_type		VARCHAR(100),
		  @buy_sell_flag_check CHAR(1)
		  
	SELECT @buy_sell_flag_check = buy_sell_flag FROM #tempDeal WHERE Leg = 1
	
	SET @sql_pre = ''    
	DECLARE dealCur CURSOR FORWARD_ONLY READ_ONLY 
	FOR
	SELECT farrms_field_id,
		 default_label
	FROM   (
      		SELECT	CASE WHEN d.display_format = 19204 AND d.display_format IS NOT NULL THEN 'dbo.FNAGetDisplayFormatVolume(' + f.farrms_field_id + ', NULL, ' +  CAST(st.template_id AS VARCHAR(100)) + ', ''' + f.farrms_field_id + ''')' ELSE  f.farrms_field_id END AS farrms_field_id,
					CASE WHEN @buy_sell_flag_check = 'S' THEN ISNULL(NULLIF(d.sell_label, ''), d.field_caption) 
					WHEN @buy_sell_flag_check = 'B' THEN ISNULL(NULLIF(d.buy_label, ''), d.field_caption)
					ELSE d.field_caption END default_label,
					d.deal_update_seq_no
			FROM   maintain_field_template_detail d
				JOIN maintain_field_deal f
					 ON  d.field_id = f.field_id
			LEFT JOIN dbo.source_deal_header_template st ON st.field_template_id = d.field_template_id 
			WHERE  f.header_detail = 'd'
				AND d.field_template_id = @field_template_id
				AND st.template_id = @template_id
				AND ISNULL(d.udf_or_system, 's') = 's'
				AND ISNULL(d.hide_control, 'n') = 'n' 
				AND ISNULL(d.update_required, 'n') = 'y'                        
			UNION     
			SELECT	DISTINCT 'UDF___' + CAST(f.udf_template_id AS VARCHAR),
					CASE WHEN @buy_sell_flag_check = 'S' THEN ISNULL(NULLIF(d.sell_label, ''), d.field_caption) 
					WHEN @buy_sell_flag_check = 'B' THEN ISNULL(NULLIF(d.buy_label, ''), d.field_caption)
					ELSE d.field_caption END default_label,
					d.deal_update_seq_no
			FROM   maintain_field_template_detail d
				JOIN user_defined_fields_template f
					 ON  d.field_id = f.udf_template_id
				 JOIN user_defined_deal_fields_template uddft 
				ON uddft.field_name = f.field_name
				AND uddft.template_id = @template_id 
			WHERE  d.field_template_id = @field_template_id
				AND f.udf_type = 'd'
				AND d.udf_or_system = 'u'
				AND ISNULL(d.hide_control, 'n') = 'n'
				AND ISNULL(d.update_required, 'n') = 'y' 
			) l
	ORDER BY ISNULL(l.deal_update_seq_no, 10000)
 
	OPEN dealCur    
	FETCH NEXT FROM dealCur INTO @farrms_field_id,@default_label                            
	WHILE @@FETCH_STATUS = 0
	BEGIN
	
	--SET @data_type_var = CAST(SQL_VARIANT_PROPERTY(@farrms_field_id, 'BaseType') AS VARCHAR(100))
	
	--IF   @data_type_var LIKE 'numeric%' OR @data_type_var LIKE 'int%' OR @data_type_var LIKE 'float%'
	--	 SET @sql_pre = @sql_pre + ' dbo.FNARemoveTrailingZeroes( ' + @farrms_field_id + ') AS [' + @default_label + '],'
	--ELSE 

		SET @sql_pre = @sql_pre + ' ' + @farrms_field_id + ' AS [' + @default_label + '],'    
		IF @farrms_field_id = 'total_volume' OR @farrms_field_id = 'dbo.FNAGetDisplayFormatVolume(total_volume, NULL, '+ CAST(@template_id AS VARCHAR(100))+ ', ''total_volume'')'
		BEGIN
			ALTER TABLE #tempDeal ADD position_uom VARCHAR(50)
			
			UPDATE td
			SET    td.position_uom = tcum.uom_name
			FROM   #tempDeal td
			       INNER JOIN #tmp_curve_uom_map tcum
			            ON  td.source_deal_detail_id = tcum.source_deal_detail_id	
			
			--SET @sql_pre = @sql_pre + '''' + ISNULL(@position_uom, '') + ''' AS [Position UOM],'  
			SET @sql_pre = @sql_pre + 'position_uom [Position UOM],';                                                 	
		END
		FETCH NEXT FROM dealCur INTO @farrms_field_id,@default_label
	END    
	CLOSE dealCur    
	DEALLOCATE dealCur  
  
	IF LEN(@sql_pre) > 1    
	BEGIN    
		SET @sql_pre=LEFT(@sql_pre,LEN(@sql_pre)-1)    
	END     
	ELSE  
		SET @sql_pre='*'  

--SELECT * FROM #tempDeal 
	EXEC spa_print   'SELECT source_deal_header_id, source_deal_detail_id,', @sql_pre, ' FROM #tempDeal t order by t.source_deal_detail_id'
	EXEC('SELECT t.source_deal_header_id, t.source_deal_detail_id,'+ @sql_pre +' FROM #tempDeal t ORDER BY  dbo.FNAClientToSqlDate(term_start), leg ')    
END    -- end of -- NON Edit Grid        
          
ELSE IF @flag='e' -- Export from TOOL BAR EDIT GRID (Deal Detail          
 BEGIN          
          
 -- Check if leg 1          
 SELECT @max_leg = MAX(Leg),
        @buy_sell = MAX(buy_sell_flag)
 FROM source_deal_detail           
 WHERE source_deal_header_id = @source_deal_header_id          
          
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
          
    CREATE TABLE #tempDealDetail(    
 [source_deal_detail_id] [INT] NOT NULL,    
 [source_deal_header_id] [INT] NOT NULL,    
 [term_start] VARCHAR(50) COLLATE DATABASE_DEFAULT NOT NULL,    
 [term_end] VARCHAR(50) COLLATE DATABASE_DEFAULT NOT NULL,    
 [Leg] [INT] NOT NULL,    
 [contract_expiration_date] VARCHAR(50) COLLATE DATABASE_DEFAULT NOT NULL,    
 [fixed_float_leg] VARCHAR(50) COLLATE DATABASE_DEFAULT NOT NULL,    
 [buy_sell_flag] VARCHAR(50) COLLATE DATABASE_DEFAULT NOT NULL,    
 [curve_id] VARCHAR(150) COLLATE DATABASE_DEFAULT NULL,    
 [fixed_price] [NUMERIC](38, 20) NULL,    
 [fixed_price_currency_id] VARCHAR(50) COLLATE DATABASE_DEFAULT NULL,    
 [option_strike_price] [NUMERIC](38, 20) NULL,    
 [deal_volume] [NUMERIC](38, 20) NULL,    
 [deal_volume_frequency] VARCHAR(50) COLLATE DATABASE_DEFAULT NOT NULL,    
 [deal_volume_uom_id] VARCHAR(50) COLLATE DATABASE_DEFAULT NOT NULL,    
 [block_description] [VARCHAR](100) COLLATE DATABASE_DEFAULT NULL,    
 [deal_detail_description] [VARCHAR](100) COLLATE DATABASE_DEFAULT NULL,    
 [formula_id] VARCHAR(150) COLLATE DATABASE_DEFAULT NULL,    
 [volume_left] [FLOAT] NULL,    
 [settlement_volume] [FLOAT] NULL,    
 [settlement_uom] VARCHAR(50) COLLATE DATABASE_DEFAULT NULL,    
 [create_user] [VARCHAR](50) COLLATE DATABASE_DEFAULT NULL,    
 [create_ts] [DATETIME] NULL,    
 [update_user] [VARCHAR](50) COLLATE DATABASE_DEFAULT NULL,    
 [update_ts] [DATETIME] NULL,    
 [price_adder] [NUMERIC](38, 20) NULL,    
 [price_multiplier] [NUMERIC](38, 20) NULL,    
 [settlement_date] [DATETIME] NULL,    
 [day_count_id] VARCHAR(150) COLLATE DATABASE_DEFAULT NULL,    
 [location_id] VARCHAR(150) COLLATE DATABASE_DEFAULT NULL,    
 [meter_id] VARCHAR(50) COLLATE DATABASE_DEFAULT NULL,    
 [physical_financial_flag] VARCHAR(50) COLLATE DATABASE_DEFAULT NULL,    
 [Booked] VARCHAR(50) COLLATE DATABASE_DEFAULT NULL,    
 [process_deal_status] VARCHAR(50) COLLATE DATABASE_DEFAULT NULL,    
 [fixed_cost] [NUMERIC](38, 20) NULL,    
 [multiplier] [NUMERIC](38, 20) NULL,    
 [adder_currency_id] VARCHAR(50) COLLATE DATABASE_DEFAULT NULL,    
 [fixed_cost_currency_id] VARCHAR(50) COLLATE DATABASE_DEFAULT NULL,    
 [formula_currency_id]VARCHAR(50) COLLATE DATABASE_DEFAULT NULL,    
 [price_adder2] [NUMERIC](38, 20) NULL,    
 [price_adder_currency2] VARCHAR(50) COLLATE DATABASE_DEFAULT NULL,    
 [volume_multiplier2] [NUMERIC](38, 20) NULL,    
 [total_volume] [NUMERIC](38, 20) NULL,    
 [pay_opposite] VARCHAR(50) COLLATE DATABASE_DEFAULT NULL,    
 [capacity] [NUMERIC](38, 20) NULL,    
 [settlement_currency] VARCHAR(50) COLLATE DATABASE_DEFAULT NULL,    
 [standard_yearly_volume] [FLOAT] NULL,    
 [formula_curve_id] VARCHAR(50) COLLATE DATABASE_DEFAULT NULL,    
 [price_uom_id] VARCHAR(50) COLLATE DATABASE_DEFAULT NULL,    
 [Category]VARCHAR(50) COLLATE DATABASE_DEFAULT NULL,    
 [profile_code] VARCHAR(50) COLLATE DATABASE_DEFAULT NULL,    
 [pv_party] VARCHAR(50) COLLATE DATABASE_DEFAULT NULL,
 lock_deal_detail  VARCHAR(50) COLLATE DATABASE_DEFAULT NULL,
 [status]  VARCHAR(50) COLLATE DATABASE_DEFAULT NULL
     
)    
    
    
 SET @sql_select='SELECT [ID],[TermStart] AS [Term Start],[TermEnd] AS [Term End],[Leg],[ExpDate] AS [Expiration Date],[FixedFloat] AS [Fixed Float],          
 [BuySell] as [Buy/Sell],[curve_type] AS [Curve Type],[commodity] AS [Commodity],[Physical/Financial] AS [Physical/Financial],[Location],['+@label_index+'],[Volume],          
 [Frequency],[UOM],[TotalVolume] as [Total Volume],[Position UOM],[Capacity],['+@label_price+'],[Fixed Cost],[Fixed Cost Currency],[Formula Price],[Formula Currency],[OptionStrike] AS [Option Strike Price],[PriceAdder] as [Price Adder],[Adder Currency],VolumeMultiplier as [Volume Multiplier],
 [PriceMultiplier] as [Price Multiplier],[Currency],[PriceAdder2] as [Price Adder 2],[AdderCurrency2] as [Adder Currency 2], VolumeMultiplier2 as [Volume Multiplier 2],[Meter],          
 [Pay Opposite],[Payment Date],[Formula],[Sett.Currency] as [Settlement Currency], SYV ,[Price UOM],Category,Profile ,[Pv Party],  lock_deal_detail [Lock Deal Detai], [status] [Status]   
 FROM(    
 SELECT DISTINCT a.source_deal_detail_id AS [ID],          
    dbo.FNADateFormat(term_start) AS TermStart,          
    dbo.FNADateFormat(term_end) AS TermEnd,          
    Leg,           
    CASE WHEN sdt.expiration_applies =''y'' THEN dbo.FNADEALRECExpiration(a.source_deal_detail_id, contract_expiration_date, NULL)           
     ELSE dbo.FNADateFormat(contract_expiration_date) END AS ExpDate,          
    CASE WHEN fixed_float_leg=''f'' THEN ''Fixed'' else ''Float'' END as FixedFloat,         
    CASE 
		WHEN h.source_deal_type_id = 93 then   
				CASE WHEN a.buy_sell_flag = ''s'' THEN '''+ @buy_label + ''' 
					 ELSE ''' + @sell_label + ''' 
				END
		ELSE  CASE WHEN a.buy_sell_flag = ''b'' THEN '''+ @buy_label + ''' ELSE ''' + @sell_label + ''' END 
     END  as BuySell,          
    --pcd.source_curve_type_value_id curve_type,            
    --pcd.curve_name curve_type,           
    sdv2.code curve_type,          
    sco.commodity_name  AS commodity,          
    CASE WHEN a.physical_financial_flag = ''p'' THEN ''Physical'' ELSE ''Financial'' END AS [Physical/Financial],          
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
    sdvpv.code [Pv Party],
    CASE WHEN a.lock_deal_detail = ''n'' THEN ''No'' WHEN a.lock_deal_detail = ''y'' THEN ''Yes'' ELSE '''' END lock_deal_detail,
	[status].code [Status]             
    FROM ' +CASE WHEN ISNULL(@deleted_deal,'n') = 'y' THEN  'delete_source_deal_detail' ELSE 'source_deal_detail' END + ' a           
     JOIN ' +CASE WHEN ISNULL(@deleted_deal,'n') = 'y' THEN  'delete_source_deal_header' ELSE 'source_deal_header' END + ' h on a.source_deal_header_id=h.source_deal_header_id           
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
 LEFT OUTER JOIN static_data_value status on status.value_id = a.status
    WHERE a.source_deal_header_id='+ CAST(@source_deal_header_id AS VARCHAR)          
          
 IF @term_start IS NOT NULL          
 SET @sql_select= @sql_select+ ' AND term_start='''+@term_start+''''          
          
 IF @term_start IS NOT NULL          
 SET @sql_select= @sql_select +' AND term_end='''+@term_end+''''          
           
 SET @sql_select= @sql_select+ ')aa ORDER BY id ASC'          
           
 EXEC spa_print @sql_select          
 EXEC(@sql_select)          
END          
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
ELSE IF @flag='f' -- COPY Deal          
BEGIN          
 DECLARE @copy_source_deal_id INT          
           
           
 SELECT @new_deal_id=CAST(@source_deal_header_id AS VARCHAR)+'_Pawan' + CASE WHEN COUNT(Deal_ID) > 0 THEN CAST(COUNT(Deal_ID)+1 AS VARCHAR)          
 ELSE '' END FROM source_deal_header          
 WHERE Deal_ID=CAST(@source_deal_header_id AS VARCHAR)+'_Pawan'          
          
          
          
 BEGIN TRAN          
 INSERT INTO source_deal_header(source_system_id, Deal_ID, deal_date, ext_deal_id, physical_financial_flag, structured_deal_id, counterparty_id, entire_term_start, entire_term_end,           
                      source_deal_type_id, deal_sub_type_type_id, option_flag, option_type, option_excercise_type, source_system_book_id1, source_system_book_id2,           
                      source_system_book_id3, source_system_book_id4, description1, description2, description3, deal_category_value_id, trader_id,           
                      internal_deal_type_value_id, internal_deal_subtype_value_id, template_id, header_buy_sell_flag, broker_id, generator_id, status_value_id,           
                      status_date, assignment_type_value_id, compliance_year, state_value_id, assigned_date, assigned_by, generation_source, aggregate_environment,           
                      aggregate_envrionment_comment, rec_price, rec_formula_id, rolling_avg,Pricing,Deal_Status,option_settlement_date)          
 SELECT   source_system_id, @new_deal_id, deal_date, ext_deal_id, physical_financial_flag, structured_deal_id, counterparty_id, entire_term_start, entire_term_end,           
                      source_deal_type_id, deal_sub_type_type_id, option_flag, option_type, option_excercise_type, source_system_book_id1, source_system_book_id2,           
                      source_system_book_id3, source_system_book_id4, description1, description2, description3, deal_category_value_id, trader_id,           
                      internal_deal_type_value_id, internal_deal_subtype_value_id, template_id, header_buy_sell_flag, broker_id, generator_id, status_value_id,           
                      status_date, assignment_type_value_id, compliance_year, state_value_id, assigned_date, assigned_by, generation_source, aggregate_environment,           
                      aggregate_envrionment_comment, rec_price, rec_formula_id, rolling_avg,Pricing,Deal_Status,option_settlement_date          
 FROM source_deal_header WHERE source_deal_header_id=@source_deal_header_id          
 SET @copy_source_deal_id=SCOPE_IDENTITY()          
           
  EXEC spa_compliance_workflow 109,'i',@copy_source_deal_id,'Deal',NULL          
          
  INSERT  INTO source_deal_detail (source_deal_header_id,          
      term_start,          
      term_end,          
      Leg,          
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
   Category,    
   pv_party,    
   profile_code,
   lock_deal_detail,
	[status] 
   )          
    SELECT @copy_source_deal_id,          
      term_start,          
      term_end,          
      Leg,          
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
   Category,    
   pv_party,    
   profile_code
   , lock_deal_detail
   , [status]      
       FROM source_deal_detail           
      WHERE source_deal_header_id=@source_deal_header_id          
           
   IF @@ERROR <> 0          
 BEGIN          
   EXEC spa_ErrorHandler @@ERROR, 'Source Deal Header  table',           
           
     'spa_sourcedealheader', 'DB Error',           
           
     'Failed copying record.', ''          
   ROLLBACK TRAN          
   END          
   ELSE          
   BEGIN          
          
    EXEC spa_ErrorHandler 0, 'Source Deal Header  table',           
            
      'spa_sourcedealheader', 'Success',           
            
      '', @copy_source_deal_id          
    COMMIT TRAN          
   END          
           
            
END          
ELSE IF @flag='e'          
 BEGIN          
  SET @sql_select='insert into '+@tempdetailtable+' (source_deal_header_id,          
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
  where term_start=(select max(term_start) from '+@tempdetailtable+' where source_deal_header_id='+CAST(@source_deal_header_id AS VARCHAR)+') and          
  term_end=(select max(term_end) from '+@tempdetailtable+' where source_deal_header_id='+CAST(@source_deal_header_id AS VARCHAR)+')           
  and source_deal_header_id='+CAST(@source_deal_header_id AS VARCHAR)          
           
          
  EXEC(@sql_select)          
  IF @@ERROR <> 0          
  BEGIN            
          
  EXEC spa_ErrorHandler @@ERROR, 'Source Deal Detail  table',           
          
    'spa_sourcedealdetail', 'DB Error',           
          
    'Failed inserting record.', ''          
  END          
  ELSE          
  BEGIN          
             
               
   SET @sql_select='Declare @term_end_value varchar(10)          
   select @term_end_value=(select dbo.FNACovertToSTDDate(max(term_end)) from           
   '+@tempdetailtable+' where source_deal_header_id='+CAST(@source_deal_header_id AS VARCHAR)+')          
   update '+@tempheadertable+' set entire_term_end=@term_end_value where   
   source_deal_header_id='+CAST(@source_deal_header_id AS VARCHAR)+'          
   set @term_end_value=dbo.FNADateFormat(@term_end_value)             
   Exec spa_ErrorHandler 0, ''Source Deal Header  table'',           
   ''spa_sourcedealdetail'', ''Success'',@term_end_value,''''          
   EXEC spa_print @term_end_value '          
   EXEC(@sql_select)          
          
             
  END          
 END           
ELSE IF @flag='t'          
BEGIN          
 SELECT @max_leg=MAX(Leg),@buy_sell=MAX(buy_sell_flag) FROM source_deal_detail_template WHERE template_id=@template_id          
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
          
 SET @sql_select='          
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
   pv_party PvParty,  
    lock_deal_detail [Lock Deal Detail],
	[status] [Status]      
   from source_deal_detail_template     
  where template_id = ' + CAST(@template_id AS VARCHAR)          
            
 EXEC spa_print @sql_Select          
 EXEC(@sql_select)          
          
           
END          
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
          
ELSE IF @flag='c' -- copy deal detail ////bka          
BEGIN          
          
DECLARE @bif_leg INT          
          
SELECT @max_leg=MAX(Leg),@deal_volume=SUM(deal_volume)/MAX(Leg) FROM source_deal_detail           
  WHERE source_deal_header_id=@source_deal_header_id          
SELECT @bif_leg=Leg FROM source_deal_detail WHERE source_deal_detail_id=@source_deal_detail_id          
          
SET @sql_select='          
select           
 dbo.FNADateFormat(min(sdd.term_start)) AS TermStart,           
 dbo.FNADateFormat(max(sdd.term_end)) AS TermEnd,          
 '+CASE WHEN @source_deal_detail_id IS NOT NULL THEN ' 1 ' ELSE ' sdd.Leg ' END+' AS Leg,          
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
max(pv_party) PVParty,
max(lock_deal_detail),
MAX([status])  
   
from           
 source_deal_detail sdd left outer join           
source_price_curve_def pcd on pcd.source_curve_def_id=sdd.curve_id            
where source_deal_header_id='+CAST(@source_deal_header_id AS VARCHAR)          
+ CASE WHEN @source_deal_detail_id IS NOT NULL THEN ' And leg='+CAST(@bif_leg AS VARCHAR) ELSE '' END +          
' group by Leg order by leg '          
          
          
EXEC spa_print @sql_select          
EXEC(@sql_select)          
END          
          
          
ELSE IF @flag='m' -- copy deal detail from post tool bar////bka COPY deals for EFP          
--Print 'I M HERE'          
BEGIN          
DECLARE @deal_name_temp AS VARCHAR(200)          
DECLARE @tmp_source_deal_type_id1 INT          
DECLARE @tmp_deal_sub_type_type_id1 INT          
DECLARE @temp_status AS VARCHAR(200)          
DECLARE @tmp_template_id INT          
DECLARE @ref_id AS VARCHAR(2000)          
DECLARE @tmp_vol AS INT          
DECLARE @buy_sell_tmp AS VARCHAR(10)          
DECLARE @curve_id_tmp AS INT          
          
          
 IF @internal_deal_subtype_value_id='9'          
        SET @deal_name_temp='_EFP'          
    ELSE IF @internal_deal_subtype_value_id='10'          
   SET @deal_name_temp='_Trigger'          
          
   SELECT @tmp_source_deal_type_id1=deal_type_id,@tmp_deal_sub_type_type_id1=deal_sub_type_id ,@tmp_template_id=template_id          
      FROM default_deal_post_values           
      WHERE internal_deal_type_subtype_id=@internal_deal_subtype_value_id           
          
 SELECT @temp_status=process_deal_status  FROM source_deal_header sdh          
 INNER JOIN [source_deal_detail] sdd ON sdd.source_deal_header_id=sdh.source_deal_header_id          
 WHERE sdh.source_deal_header_id = CAST(@source_deal_header_id AS VARCHAR)           
--and internal_deal_type_subtype_id=@internal_deal_subtype_value_id           
 EXEC spa_print @temp_status          
          
   IF @temp_status IS NULL OR @temp_status <>12505          
    BEGIN          
          
  SELECT @new_deal_id=CAST(@source_deal_header_id AS VARCHAR)+@deal_name_temp + CASE WHEN COUNT(Deal_ID) > 0 THEN CAST(COUNT(Deal_ID)+1 AS VARCHAR)          
  ELSE '' END FROM source_deal_header          
  WHERE Deal_ID=CAST(@source_deal_header_id AS VARCHAR)+@deal_name_temp          
              
            
   BEGIN TRAN          
   DECLARE @new_source_deal_id INT          
             
             
              
          
          
 SET  @ref_id=CAST(ISNULL(IDENT_CURRENT('source_deal_header')+1,1) AS VARCHAR)+'-farrms'          
          
    INSERT INTO [dbo].[source_deal_header] (          
   [source_system_id]          
           ,[Deal_ID]          
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
     SELECT          
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
      THEN 's' ELSE 'b'          
     END           
            
    WHEN @internal_deal_subtype_value_id='10'          
    THEN          
     CASE          
      WHEN sdh.header_buy_sell_flag ='b'          
      THEN 'b' ELSE 's'          
     END           
   END           
             
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
           ,GETDATE()          
           ,dbo.fnadbuser()          
           ,GETDATE()          
   ,sdh.contract_id,12505,sdh.source_deal_header_id          
 FROM [dbo].[source_deal_header_template] t           
 INNER JOIN source_deal_header sdh  ON  sdh.source_deal_header_id=@source_deal_header_id          
    WHERE t.template_id=@tmp_template_id          
          
   SET @new_source_deal_id=SCOPE_IDENTITY()          
  --print @new_source_deal_id           
    EXEC spa_compliance_workflow 109,'i',@new_source_deal_id,'Deal',NULL          
          
  SELECT @tmp_vol=deal_volume,@buy_sell_tmp=buy_sell_flag,@curve_id_tmp=curve_id FROM source_deal_detail            
        WHERE  source_deal_header_id=@source_deal_header_id AND source_deal_detail_id IN(SELECT * FROM  SplitCommaSeperatedValues(@source_deal_detail_id))          
          
           
          
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
   Category,    
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
      THEN 's' ELSE 'b'          
     END           
            
    WHEN @internal_deal_subtype_value_id='10'          
    THEN          
     CASE          
      WHEN sdh.header_buy_sell_flag ='b'          
      THEN 'b' ELSE 's'          
     END           
   END           
           ,@curve_id_tmp          
           ,@fixed_price          
           ,td.currency_id          
           ,@tmp_vol          
           ,td.deal_volume_frequency          
           ,td.[deal_volume_uom_id] --          
           ,td.block_description                     
            ,dbo.fnadbuser()          
           ,GETDATE()          
           ,dbo.fnadbuser()          
           ,GETDATE()          
           ,td.location_id          
     ,td.physical_financial_flag,12505,    
        price_uom_id,    
   Category,    
   pv_party,    
   profile_code          
  FROM [dbo].[source_deal_detail_template] td           
INNER JOIN source_deal_header sdh  ON  sdh.source_deal_header_id=@source_deal_header_id          
    WHERE td.template_id=@tmp_template_id          
          
    INSERT INTO [dbo].[user_defined_deal_fields]          
         ([source_deal_header_id]          
         ,[udf_template_id]          
         ,[udf_value]          
         ,[create_user]          
         ,[create_ts])          
     SELECT          
         @new_source_deal_id          
         ,udf.[udf_template_id]          
         ,@fixed_price          
         ,dbo.fnadbuser()          
         ,GETDATE()          
     FROM [dbo].[user_defined_deal_fields_template] udf WHERE udf.template_id=@tmp_template_id          
          
          
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
               
          
          
    IF @@ERROR <> 0          
    BEGIN          
    EXEC spa_ErrorHandler @@ERROR, 'Source Deal Header  table',           
            
      'spa_sourcedealheader', 'DB Error',           
            
      'Failed copying record.', ''          
    ROLLBACK TRAN          
    END          
    ELSE          
    BEGIN          
          
                    UPDATE [source_deal_detail] SET process_deal_status=12505 WHERE [source_deal_header_id]=@source_deal_header_id          
     EXEC spa_ErrorHandler 0, 'Source Deal Header  table',           
             
       'spa_sourcedealheader', 'Success',           
             
       '', @new_source_deal_id          
     COMMIT TRAN          
    END          
  END          
  ELSE          
  BEGIN          
             
    EXEC spa_ErrorHandler -1, 'Deal already posted.',           
               
         'spa_sourcedealheader', 'DB Error',           
               
         'Deal already posted.', ''          
            
          
          
  END          
END          
ELSE IF @flag='b' -- Logic for blotter mode to get dail deatil          
BEGIN          
     SELECT source_deal_header_id FROM source_deal_header WHERE Deal_ID=@deal_id          
END          
          
          
ELSE IF @flag='v' -- Logic for exercise deals          
          
BEGIN          
  DECLARE @tmp_source_deal_type_id INT          
  DECLARE @tmp_deal_sub_type_type_id INT      
  DECLARE @tmp_src_deal_detail_id INT          
  DECLARE @tmp_tmeplate_name VARCHAR(200)          
            
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
          
     SELECT @new_deal_id=CAST(@source_deal_header_id AS VARCHAR)+@deal_name_temp + CASE WHEN COUNT(Deal_ID) > 0 THEN CAST(COUNT(Deal_ID)+1 AS VARCHAR)          
     ELSE '' END           
     FROM source_deal_header          
     WHERE Deal_ID LIKE CAST(@source_deal_header_id AS VARCHAR(20))+@deal_name_temp+'%'          
          
     SELECT @tmp_source_deal_type_id=deal_type_id,@tmp_deal_sub_type_type_id=deal_sub_type_id           
     FROM default_deal_post_values           
     WHERE internal_deal_type_subtype_id=14          
              
     EXEC spa_print @tmp_source_deal_type_id          
     EXEC spa_print @tmp_deal_sub_type_type_id          
          
     EXEC spa_print @new_deal_id          
               
               
     INSERT INTO source_deal_header(source_system_id, Deal_ID, deal_date, ext_deal_id, physical_financial_flag, structured_deal_id, counterparty_id, entire_term_start, entire_term_end,           
            source_deal_type_id, deal_sub_type_type_id, option_flag, /*option_type,*/ option_excercise_type, source_system_book_id1, source_system_book_id2,           
            source_system_book_id3, source_system_book_id4, description1, description2, description3, deal_category_value_id, trader_id,           
            internal_deal_type_value_id, internal_deal_subtype_value_id,template_id,header_buy_sell_flag, broker_id, generator_id, status_value_id,           
            status_date, assignment_type_value_id, compliance_year, state_value_id, assigned_date, assigned_by, generation_source, aggregate_environment,           
            aggregate_envrionment_comment, rec_price, rec_formula_id, rolling_avg,Pricing,[close_reference_id],deal_reference_type_id)          
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
            aggregate_envrionment_comment, rec_price, rec_formula_id, rolling_avg,Pricing,source_deal_header_id,12506          
      FROM source_deal_header           
      WHERE source_deal_header_id=@source_deal_header_id)          
                
      SET @new_source_deal_id=SCOPE_IDENTITY()          
                   
      EXEC spa_compliance_workflow 109,'i',@new_source_deal_id,'Deal',NULL          
          
      SELECT * FROM  SplitCommaSeperatedValues(@source_deal_detail_id)           
          
 INSERT  INTO source_deal_detail (source_deal_header_id,          
             term_start,          
             term_end,          
             Leg,          
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
        Leg,          
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
        WHERE source_deal_header_id=@source_deal_header_id AND source_deal_detail_id IN (SELECT item FROM  SplitCommaSeperatedValues(@source_deal_detail_id))          
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
  sdd.leg [Leg],pcd.curve_name [INDEX]           
 FROM source_deal_detail sdd   
 INNER JOIN source_deal_header sdh ON sdd.source_deal_header_id = sdh.source_deal_header_id          
 LEFT OUTER JOIN source_price_curve_def pcd ON pcd.source_curve_def_id=sdd.curve_id           
 WHERE sdd.source_deal_header_id = @source_deal_header_id          
 GROUP BY sdd.leg,pcd.curve_name          
END     
    
    
    
GO
