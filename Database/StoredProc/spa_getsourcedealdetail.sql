IF OBJECT_ID(N'spa_getsourcedealdetail', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_getsourcedealdetail]
GO 

CREATE PROCEDURE [dbo].[spa_getsourcedealdetail]
	@flag CHAR(1),
	@source_deal_header_id INT = NULL,
	@group_deal_id VARCHAR(50) = NULL,
	@isBreakIndividual VARCHAR(1) = NULL
AS
DECLARE @sql_Select VARCHAR(8000)
-- If @flag = 'a'    and @group_deal_id is null  --Detail by Deal_header_id
-- begin
-- 	set @sql_select='
-- SELECT dh.source_deal_header_id ,dh.source_system_id ,dh.deal_id, 
-- 		dbo.FNADateFormat(dh.deal_date),
--  		dh.ext_deal_id ,dh.physical_financial_flag, 
-- 		dh.counterparty_id, 
-- 		dbo.FNADateFormat(dh.entire_term_start), 
-- 		dbo.FNADateFormat(dh.entire_term_end), dh.source_deal_type_id, 
-- 		dh.deal_sub_type_type_id,
-- 		dh.option_flag, dh.option_type, dh.option_excercise_type, 
-- 		source_book.source_book_name As Group1, 
-- 		source_book_1.source_book_name AS Group2, 
-- 	        source_book_2.source_book_name AS Group3, source_book_3.source_book_name AS Group4,
-- 		dh.description1,dh.description2,dh.description3,
-- 		dh.deal_category_value_id,dh.trader_id, source_system_book_map.fas_book_id,portfolio_hierarchy.parent_entity_id,
-- 		fas_strategy.hedge_type_value_id,static_data_value1.code as HedgeItemFlag,
-- 			static_data_value2.code as HedgeType,source_currency.currency_name as Currency,
-- 		dh.internal_deal_type_value_id,dh.internal_deal_subtype_value_id,dh.template_id,dh.structured_deal_id,dh.header_buy_sell_flag,
-- 		dh.broker_id,dh.generator_id, gis_cert_number, dh.gis_value_id, 
-- 	dbo.FNADateFormat(gis_cert_date) gis_cert_date, gen_cert_number,  
-- 		dbo.FNADateFormat(gen_cert_date) gen_cert_date, status_value_id, dbo.FNADateFormat(status_date) status_date,
-- 		assignment_type_value_id, compliance_year, dh.state_value_id,  dbo.FNADateFormat(assigned_date) assigned_date ,
-- 		 assigned_by,generation_source ,
-- 		isnull(dh.aggregate_environment, rg.aggregate_environment) aggregate_environment,
-- 		isnull(dh.aggregate_envrionment_comment, rg.aggregate_envrionment_comment) aggregate_envrionment_comment,
-- 	dh.create_user,dh.create_ts,dh.update_user,dh.update_ts,
-- 	dbo.FNAGetAssignmentDesc(5147) AssignmentDesc1, 
-- 	dbo.FNADEALRECExpiration(dh.source_deal_header_id, ''2005-01-01'', 5147) DEALRECExpiration1,
-- 	dbo.FNAGetAssignmentDesc(5146) AssignmentDesc2, 
-- 	dbo.FNADEALRECExpiration(dh.source_deal_header_id, ''2005-01-01'', 5146) DEALRECExpiration2,
-- 	case 	when (dh.source_deal_type_id <> 55) then NULL
-- 		when (dh.rec_price is null and dh.rec_formula_id is null) then rg.rec_price 
-- 		else dh.rec_price end rec_price,
-- 	case 	when (dh.source_deal_type_id <> 55) then NULL
-- 		when (dh.rec_price is null and dh.rec_formula_id is null) then rg.rec_formula_id 
-- 		else dh.rec_formula_id end rec_formula_id,
-- 	dbo.FNAFormulaFormat(f.formula, ''r'') formula,
-- 	ts.deal_volume block_volume
-- 
-- 	FROM source_deal dh INNER JOIN
-- 	           source_book ON dh.source_system_book_id1 = source_book.source_book_id INNER JOIN
--         	   source_book source_book_1 ON dh.source_system_book_id2 = source_book_1.source_book_id INNER JOIN
-- 		   source_book source_book_2 ON dh.source_system_book_id3 = source_book_2.source_book_id INNER JOIN
-- 		   source_book source_book_3 ON dh.source_system_book_id4 = source_book_3.source_book_id
-- 		LEFT OUTER JOIN rec_generator rg on dh.generator_id = rg.generator_id
-- 		inner join source_system_book_map on  source_system_book_map.source_system_book_id1= source_book.source_book_id 
-- 		inner join  portfolio_hierarchy ON portfolio_hierarchy.entity_id = source_system_book_map.fas_book_id
-- 		inner join fas_strategy ON fas_strategy.fas_strategy_id=portfolio_hierarchy.parent_entity_id
-- 		inner join static_data_value  static_data_value1 ON source_system_book_map.fas_deal_type_value_id=static_data_value1.value_id
-- 		inner join static_data_value  static_data_value2 ON fas_strategy.hedge_type_value_id=static_data_value2.value_id
-- 		left outer join(select source_system_book_map.fas_book_id as book_id 

-- 		FROM source_deal dh INNER JOIN
-- 	           source_book ON dh.source_system_book_id1 = source_book.source_book_id INNER JOIN
--         	   source_book source_book_1 ON dh.source_system_book_id2 = source_book_1.source_book_id INNER JOIN
-- 		   source_book source_book_2 ON dh.source_system_book_id3 = source_book_2.source_book_id INNER JOIN
-- 		   source_book source_book_3 ON dh.source_system_book_id4 = source_book_3.source_book_id
-- 		inner join source_system_book_map on  source_system_book_map.source_system_book_id1= source_book.source_book_id 
-- 		inner join  portfolio_hierarchy ON portfolio_hierarchy.entity_id = source_system_book_map.fas_book_id
-- 		where dh.source_deal_header_id='+ cast(@source_deal_header_id as varchar)+') books
-- 		on books.book_id=source_system_book_map.fas_book_id
-- 		left outer join	(Select entity_id,parent_entity_id from portfolio_hierarchy) strat 
-- 		on strat.entity_id=books.book_id
-- 		left outer join (select parent_entity_id as [Subsidiary Id],entity_id 
-- 		from portfolio_hierarchy)subs
-- 		on subs.entity_id=strat.parent_entity_id 
-- 		inner join fas_subsidiaries on fas_subsidiaries.fas_subsidiary_id=subs.[Subsidiary Id]
-- 		inner join source_currency   ON fas_subsidiaries.func_cur_value_id=source_currency.source_currency_id
-- 		LEFT OUTER JOIN formula_editor f on 
-- 		case 	when (dh.source_deal_type_id <> 55) then NULL
-- 			when (dh.rec_price is null and dh.rec_formula_id is null) then rg.rec_formula_id 
-- 			else dh.rec_formula_id end = f.formula_id
-- LEFT OUTER JOIN (SELECT source_deal_header_id, deal_volume
-- 				FROM         Transaction_staging
-- 				WHERE     (source_deal_header_id = '+ cast(@source_deal_header_id as varchar)+')) ts ON
-- 			dh.source_deal_header_id = ts.source_deal_header_id
-- 
-- 		where dh.source_deal_header_id='+ cast(@source_deal_header_id as varchar)
-- 	exec (@sql_select)
-- end
--else 
if @flag='e'  and @group_deal_id is null -- USed for Editable Grid Deal Detail
begin
		SELECT   source_deal_type_id INTO #expiration_deal_types
		FROM    source_deal_type
		WHERE   (expiration_applies = 'y')
		
		set @sql_select='select   a.source_deal_header_id,dbo.FNADateFormat(term_start) as TermStart,dbo.FNADateFormat(term_end) as TermEnd,
		Leg,
		case when ((a.internal_deal_type_value_id = 4 OR a.source_deal_type_id IN (select * from #expiration_deal_types))) then
			dbo.FNADEALRECExpiration(a.source_deal_header_id, contract_expiration_date, NULL) 
		else dbo.FNADateFormat(contract_expiration_date) end as ExpDate,
		case when fixed_float_leg=''f'' then ''Fixed'' else ''Float'' End as FixedFloat,
		case when buy_sell_flag =''b'' then ''Buy(Receive)'' else ''Sell(Pay)'' End as BuySell,
		case when a.curve_id is NULL then 0
		else 	source_price_curve_def.source_curve_type_value_id
		End as curve_type,
		case when a.curve_id is NULL then 0
		else 	source_price_curve_def.commodity_id
		End as commodity,	a.curve_id as [Index],
		case when ((a.internal_deal_type_value_id = 4 OR a.source_deal_type_id IN (select * from #expiration_deal_types)) and
			isnull(a.fixed_price, 0) = 0 and a.formula_id is null) then
				rg.contract_price 
		else fixed_price end as Price,
		case when ((a.internal_deal_type_value_id = 4 OR a.source_deal_type_id IN (select * from #expiration_deal_types)) and
			isnull(a.fixed_price, 0) = 0 and a.formula_id is null) then
				rg.contract_formula_id 
		else a.formula_id end as FormulaPrice,
		fixed_price_currency_id as Currency,option_strike_price as StrikePrice,
		deal_volume as Volume,
		deal_volume_uom_id as UOM,deal_volume_frequency as Frequency, 
		case when (a.internal_deal_type_value_id = 4 OR a.source_deal_type_id IN (select * from #expiration_deal_types)) then
			cast(dbo.FNARECBonus(a.source_deal_header_id) as varchar) 
		else block_description end as Bonus,
		deal_detail_description as HourEnding,
		dbo.FNAFormulaFormat(formula_editor.formula,''r'') as Formula

		from source_deal a 
		inner  join source_price_curve_def on 
		source_price_curve_def.source_curve_def_id=
		case when  a.curve_id is not null then a.curve_id
		else 32
		end
		--added to support RECs
--		left join (select source_deal_header_id, internal_deal_type_value_id, source_deal_type_id
--				from  source_deal) sdh on sdh.source_deal_header_id = a.source_deal_header_id
--		left outer join  deal_rec_properties drp on drp.source_deal_header_id = sdh.source_deal_header_id
		left outer join rec_generator rg on rg.generator_id = a.generator_id
		left outer join formula_editor on  
			case when ((a.internal_deal_type_value_id = 4 OR a.source_deal_type_id IN (select * from #expiration_deal_types)) and
			isnull(a.fixed_price, 0) = 0 and a.formula_id is null) then
				isnull(rg.contract_formula_id, -1) 
			else isnull(a.formula_id, -1) end = formula_editor.formula_id
		
		where a.source_deal_header_id='+cast(@source_deal_header_id as varchar)

	--	if @term_start is not null
	--	set @sql_select= @sql_select+ ' And term_start='''+@term_start+''''
	
	--	if @term_start is not null
	--	set @sql_select= @sql_select +' And term_end='''+@term_end+''''
		
		set @sql_select= @sql_select+ ' order by term_start,leg '
		

		exec(@sql_select)
end
-- #####################################
-- ################### For Group Wise ##################################
-- #######################################################
else If @flag = 'a'  --and @group_deal_id is not null --Detail by Group ID By
begin
	if @group_deal_id is not null 
		select top 1 @source_deal_header_id=source_deal_header_id from source_deal where
			structured_deal_id=@group_deal_id	
	
	set @sql_select='
	SELECT  dh.source_deal_header_id DealId,dh.source_system_id ,dh.deal_id, 
		dbo.FNADateFormat(dh.deal_date),
 		dh.ext_deal_id ,dh.physical_financial_flag, 
		dh.counterparty_id, 
		dbo.FNADateFormat(dh.entire_term_start), 
		dbo.FNADateFormat(dh.entire_term_end), dh.source_deal_type_id, 
		dh.deal_sub_type_type_id,
		dh.option_flag, dh.option_type, dh.option_excercise_type, 
		source_book.source_book_name As Group1, 
		source_book_1.source_book_name AS Group2, 
	        source_book_2.source_book_name AS Group3, 
		source_book_3.source_book_name AS Group4,
		dh.description1,dh.description2,dh.description3,
		dh.deal_category_value_id,dh.trader_id, source_system_book_map.fas_book_id,portfolio_hierarchy.parent_entity_id,
		fas_strategy.hedge_type_value_id,static_data_value1.code as HedgeItemFlag,
			static_data_value2.code as HedgeType,source_currency.currency_name as Currency,
		dh.internal_deal_type_value_id,dh.internal_deal_subtype_value_id,dh.template_id,dh.structured_deal_id,dh.header_buy_sell_flag,
		dh.broker_id,dh.generator_id, gis_cert_number, dh.gis_value_id, 
	dbo.FNADateFormat(gis_cert_date) gis_cert_date, gen_cert_number,  
		dbo.FNADateFormat(gen_cert_date) gen_cert_date, status_value_id, dbo.FNADateFormat(status_date) status_date,
		assignment_type_value_id, compliance_year, dh.state_value_id,  dbo.FNADateFormat(assigned_date) assigned_date ,
		 assigned_by,generation_source ,
		isnull(dh.aggregate_environment, rg.aggregate_environment) aggregate_environment,
		isnull(dh.aggregate_envrionment_comment, rg.aggregate_envrionment_comment) aggregate_envrionment_comment,
	dh.create_user,dh.create_ts,dh.update_user,dh.update_ts,
	dbo.FNAGetAssignmentDesc(5147) AssignmentDesc1, 
	dbo.FNADEALRECExpiration(dh.source_deal_header_id, ''2005-01-01'', 5147) DEALRECExpiration1,
	dbo.FNAGetAssignmentDesc(5146) AssignmentDesc2, 
	dbo.FNADEALRECExpiration(dh.source_deal_header_id, ''2005-01-01'', 5146) DEALRECExpiration2,
	case 	when (dh.source_deal_type_id <> 55) then NULL
		when (dh.rec_price is null and dh.rec_formula_id is null) then rg.rec_price 
		else dh.rec_price end rec_price,
	case 	when (dh.source_deal_type_id <> 55) then NULL
		when (dh.rec_price is null and dh.rec_formula_id is null) then rg.rec_formula_id 
		else dh.rec_formula_id end rec_formula_id,
	dbo.FNAFormulaFormat(f.formula, ''r'') formula,
	ts.deal_volume block_volume,source_system_book_map.fas_deal_type_value_id

	FROM source_deal dh INNER JOIN
	           source_book ON dh.source_system_book_id1 = source_book.source_book_id INNER JOIN
        	   source_book source_book_1 ON dh.source_system_book_id2 = source_book_1.source_book_id INNER JOIN
		   source_book source_book_2 ON dh.source_system_book_id3 = source_book_2.source_book_id INNER JOIN
		   source_book source_book_3 ON dh.source_system_book_id4 = source_book_3.source_book_id
		LEFT OUTER JOIN rec_generator rg on dh.generator_id = rg.generator_id
		inner join source_system_book_map on  source_system_book_map.source_system_book_id1= source_book.source_book_id 
		inner join  portfolio_hierarchy ON portfolio_hierarchy.entity_id = source_system_book_map.fas_book_id
		inner join fas_strategy ON fas_strategy.fas_strategy_id=portfolio_hierarchy.parent_entity_id
		inner join static_data_value  static_data_value1 ON source_system_book_map.fas_deal_type_value_id=static_data_value1.value_id
		inner join static_data_value  static_data_value2 ON fas_strategy.hedge_type_value_id=static_data_value2.value_id
		left outer join(select source_system_book_map.fas_book_id as book_id 
		FROM source_deal dh INNER JOIN
	           source_book ON dh.source_system_book_id1 = source_book.source_book_id INNER JOIN
        	   source_book source_book_1 ON dh.source_system_book_id2 = source_book_1.source_book_id INNER JOIN
		   source_book source_book_2 ON dh.source_system_book_id3 = source_book_2.source_book_id INNER JOIN
		   source_book source_book_3 ON dh.source_system_book_id4 = source_book_3.source_book_id
		inner join source_system_book_map on  source_system_book_map.source_system_book_id1= source_book.source_book_id 
		inner join  portfolio_hierarchy ON portfolio_hierarchy.entity_id = source_system_book_map.fas_book_id
		where dh.source_deal_header_id='+ cast(@source_deal_header_id as varchar)+') books
		on books.book_id=source_system_book_map.fas_book_id
		left outer join	(Select entity_id,parent_entity_id from portfolio_hierarchy) strat 
		on strat.entity_id=books.book_id
		left outer join (select parent_entity_id as [Subsidiary Id],entity_id 
		from portfolio_hierarchy)subs
		on subs.entity_id=strat.parent_entity_id 
		inner join fas_subsidiaries on fas_subsidiaries.fas_subsidiary_id=subs.[Subsidiary Id]
		inner join source_currency   ON fas_subsidiaries.func_cur_value_id=source_currency.source_currency_id
		LEFT OUTER JOIN formula_editor f on 
		case 	when (dh.source_deal_type_id <> 55) then NULL
			when (dh.rec_price is null and dh.rec_formula_id is null) then rg.rec_formula_id 
			else dh.rec_formula_id end = f.formula_id
LEFT OUTER JOIN (SELECT source_deal_header_id, deal_volume
				FROM         Transaction_staging
				WHERE     (source_deal_header_id = '+ cast(@source_deal_header_id as varchar)+')) ts ON
			dh.source_deal_header_id = ts.source_deal_header_id

		where dh.source_deal_header_id='+ cast(@source_deal_header_id as varchar)
	exec (@sql_select)
end
else if @flag='e'  and @group_deal_id is not null  -- USed for Editable Grid Deal Detail for Group ID
begin
	


		SELECT  source_deal_type_id INTO #expiration_deal_types_g
		FROM         source_deal_type
		WHERE     (expiration_applies = 'y')
		

		set @sql_select=' 
		select source_deal_header_id DealID,dbo.FNADateFormat(term_start) as TermStart,
		dbo.FNADateFormat(term_end) as TermEnd,
		Leg,
		case when ((a.internal_deal_type_value_id = 4 OR a.source_deal_type_id IN (select * from #expiration_deal_types_g))) then
		dbo.FNADEALRECExpiration(a.source_deal_header_id, contract_expiration_date, NULL) 
		else dbo.FNADateFormat(contract_expiration_date) end as ExpDate,
		case when fixed_float_leg=''f'' then ''Fixed'' else ''Float'' End as FixedFloat,
		case when buy_sell_flag =''b'' then ''Buy(Receive)'' else ''Sell(Pay)'' End as BuySell,
		case when a.curve_id is NULL then 0
		else 	source_price_curve_def.source_curve_type_value_id
		End as curve_type,
		case when a.curve_id is NULL then 0
		else 	source_price_curve_def.commodity_id
		End as commodity,	a.curve_id as [Index],
		case when ((a.internal_deal_type_value_id = 4 OR a.source_deal_type_id IN (select * from #expiration_deal_types_g)) and
			isnull(a.fixed_price, 0) = 0 and a.formula_id is null) then
				rg.contract_price 
		else fixed_price end as Price,
		case when ((a.internal_deal_type_value_id = 4 OR a.source_deal_type_id IN (select * from #expiration_deal_types_g)) and
			isnull(a.fixed_price, 0) = 0 and a.formula_id is null) then
				rg.contract_formula_id 
		else a.formula_id end as FormulaPrice,
		fixed_price_currency_id as Currency,option_strike_price as StrikePrice,
		deal_volume as Volume,
		deal_volume_uom_id as UOM,deal_volume_frequency as Frequency, 
		case when (a.internal_deal_type_value_id = 4 OR a.source_deal_type_id IN (select * from #expiration_deal_types_g)) then
			cast(dbo.FNARECBonus(a.source_deal_header_id) as varchar) 
		else block_description end as Bonus,
		deal_detail_description as HourEnding,
		dbo.FNAFormulaFormat(formula_editor.formula,''r'') as Formula 
		from source_deal a 
		inner  join source_price_curve_def on 
		source_price_curve_def.source_curve_def_id=
		case when  a.curve_id is not null then a.curve_id
		else 32
		end
		left outer join rec_generator rg on rg.generator_id = a.generator_id
		left outer join formula_editor on  
			case when ((a.internal_deal_type_value_id = 4 OR a.source_deal_type_id IN (select * from #expiration_deal_types_g)) and
			isnull(a.fixed_price, 0) = 0 and a.formula_id is null) then
				isnull(rg.contract_formula_id, -1) 
			else isnull(a.formula_id, -1) end = formula_editor.formula_id
		
		where  (a.status_value_id is null or a.status_value_id not in(5170,5179)) and a.structured_deal_id='''+@group_deal_id +''''

	
		set @sql_select= @sql_select+ ' order by term_start,leg '
		

		exec(@sql_select)

end







