
/****** Object:  StoredProcedure [dbo].[spa_deal_interface_adapter]    Script Date: 09/11/2010 13:41:38 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_deal_interface_adapter]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_deal_interface_adapter]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[spa_deal_interface_adapter]
AS

BEGIN

--BEGIN TRAN


--UPDATE stage_sdd SET	curve_id=REPLACE(curve_id,'#','_'), 
--						payindex=REPLACE(payindex,'#','_'), 
--						receiveindex=REPLACE(receiveindex,'#','_'),
--						source_system_book_id3=REPLACE(source_system_book_id3,'#','_')

UPDATE adiha_process.dbo.stage_deals SET	curve_id=REPLACE(curve_id,'#','_'), 
						pay_index=REPLACE(pay_index,'#','_'), 
						receive_index=REPLACE(receive_index,'#','_'),
						portfolio_name=REPLACE(portfolio_name,'#','_'),
						strategy=REPLACE(strategy,'#','_'),
						external_indicator=REPLACE(external_indicator,'#','_'),
						physical_financial_flag=right([physical_financial_flag],3)

/************************ 
* Source System
*************************/
DECLARE @source_system_id INT 
SET @source_system_id=3 		


/************************ 
* Populate currencies
*************************/
DECLARE @currency_id_usd INT, 
		@currency_id_gbp INT,
		@currency_id_eur INT ,
		@currency_unknown int
		
--IF NOT EXISTS (SELECT * FROM source_currency WHERE currency_id LIKE 'USD' AND source_system_id = @source_system_id)
--INSERT INTO source_currency(source_system_id, currency_id, currency_name, currency_desc) VALUES (@source_system_id,'USD','USD','USD')
--IF NOT EXISTS (SELECT * FROM source_currency WHERE currency_id LIKE 'GBP' AND source_system_id = @source_system_id)
--INSERT INTO source_currency(source_system_id, currency_id, currency_name, currency_desc) VALUES (@source_system_id,'GBP','GBP','GBP')
--IF NOT EXISTS (SELECT * FROM source_currency WHERE currency_id LIKE 'EUR' AND source_system_id = @source_system_id)
--INSERT INTO source_currency(source_system_id, currency_id, currency_name, currency_desc) VALUES (@source_system_id,'EUR','EUR','EUR')
IF NOT EXISTS (SELECT * FROM source_currency WHERE currency_id='UNKNOWN' AND source_system_id = @source_system_id)
	INSERT INTO source_currency(source_system_id, currency_id, currency_name, currency_desc) VALUES (@source_system_id,'UNKNOWN','UNKNOWN','UNKNOWN')

INSERT INTO source_currency (source_system_id, currency_id, currency_name, currency_desc)
	SELECT DISTINCT @source_system_id,SUBSTRING(curve_id_name,CHARINDEX('.',curve_id_name)+1,3), SUBSTRING(curve_id_name,CHARINDEX('.',curve_id_name)+1,3), SUBSTRING(curve_id_name,CHARINDEX('.',curve_id_name)+1,3)  FROM adiha_process.dbo.stage_deals sd 
	LEFT JOIN source_currency sc ON sc.currency_id = SUBSTRING(curve_id_name,CHARINDEX('.',curve_id_name)+1,3) AND sc.source_system_id = @source_system_id 
	WHERE sc.currency_id IS NULL 
	and len(curve_id_name)-charindex('.',curve_id_name,1)=3



--SELECT @currency_id_usd = source_currency_id FROM source_currency WHERE currency_id LIKE 'USD' AND source_system_id = @source_system_id
--SELECT @currency_id_gbp = source_currency_id FROM source_currency WHERE currency_id LIKE 'GBP'  AND source_system_id = @source_system_id
--SELECT @currency_id_eur = source_currency_id FROM source_currency WHERE currency_id LIKE 'EUR'  AND source_system_id = @source_system_id
SELECT @currency_unknown = source_currency_id FROM source_currency WHERE currency_id = 'UNKNOWN'  AND source_system_id = @source_system_id
--

/************************ 
* Populate UOM
*************************/
DECLARE @uom_id_metric_ton INT, 
		@uom_id_m3 INT, 
		@uom_id_mwh INT ,@uom_unknown  int
		
		
IF NOT EXISTS (SELECT * FROM source_uom WHERE uom_id LIKE 'Metric Tons' AND source_system_id = @source_system_id)
INSERT INTO source_uom(source_system_id, uom_id, uom_name, uom_desc) VALUES (@source_system_id,'Metric Tons','Metric Tons','Metric Tons')

IF NOT EXISTS (SELECT * FROM source_uom WHERE uom_id LIKE 'Therms' AND source_system_id = @source_system_id)
INSERT INTO source_uom(source_system_id, uom_id, uom_name, uom_desc) VALUES (@source_system_id,'Therms','Therms','Therms')

IF NOT EXISTS (SELECT * FROM source_uom WHERE uom_id LIKE 'MWh' AND source_system_id = @source_system_id)
INSERT INTO source_uom(source_system_id, uom_id, uom_name, uom_desc) VALUES (@source_system_id,'MWh','MWh','MWh')

IF NOT EXISTS (SELECT * FROM source_uom WHERE uom_id = 'UNKNOWN' AND source_system_id = @source_system_id)
INSERT INTO source_uom(source_system_id, uom_id, uom_name, uom_desc) VALUES (@source_system_id,'UNKNOWN','UNKNOWN','UNKNOWN')


SELECT @uom_id_metric_ton = source_uom_id FROM source_uom WHERE uom_id LIKE 'Metric Tons' AND source_system_id = @source_system_id
SELECT @uom_id_m3 = source_uom_id FROM source_uom WHERE uom_id LIKE 'Therms' AND source_system_id = @source_system_id
SELECT @uom_id_mwh = source_uom_id FROM source_uom WHERE uom_id LIKE 'MWh' AND source_system_id = @source_system_id
SELECT @uom_unknown = source_uom_id FROM source_uom WHERE uom_id = 'UNKNOWN' AND source_system_id = @source_system_id


/*
* Script to create book structure
* */

DECLARE	@subs_id INT,	@stra_id INT 
/*
-- Subsidiary --
IF NOT EXISTS (SELECT * FROM portfolio_hierarchy ph WHERE entity_name='RWEST-UK' AND hierarchy_level=2)
BEGIN
	INSERT INTO portfolio_hierarchy (entity_name,entity_type_value_id,hierarchy_level,parent_entity_id) VALUES ('RWEST-UK',525,2,NULL)
	SET @subs_id = IDENT_CURRENT('portfolio_hierarchy')
END 
ELSE 
BEGIN
	SELECT @subs_id = entity_id FROM portfolio_hierarchy ph WHERE entity_name='RWEST-UK' AND hierarchy_level=2
END

IF NOT EXISTS (SELECT * FROM fas_subsidiaries fs WHERE fs.fas_subsidiary_id = @subs_id)
INSERT INTO fas_subsidiaries
(
	fas_subsidiary_id, 
	entity_type_value_id, 
	fs.disc_source_value_id, 
	disc_type_value_id, 
	fs.func_cur_value_id, 
	days_in_year, 
	long_term_months, 
	entity_category_id, 
	fs.entity_sub_category_id, 
	fs.utility_type_id, 
	fs.ownership_status, 
	fs.holding_company, 
	fs.contact_user_id, 
	fs.exclude_indirect_emissions,
	fs.organization_boundaries, 
	fs.discount_curve_id, 
	fs.risk_free_curve_id
)
SELECT 
	@subs_id,	650,	100,	128,	8,	365,	13,	1125,	1162,	1177,	'w',	'Y',	NULL /*'rwe'*/,	'n',	1102,	NULL,	NULL


IF NOT EXISTS (SELECT * FROM portfolio_hierarchy ph WHERE entity_name = 'Trading' AND ph.hierarchy_level=1 AND ph.parent_entity_id=@subs_id)
INSERT INTO portfolio_hierarchy (entity_name,entity_type_value_id,hierarchy_level,parent_entity_id) VALUES ('Trading',526,1,@subs_id)
SET @stra_id = SCOPE_IDENTITY()


IF NOT EXISTS (SELECT * FROM portfolio_hierarchy ph WHERE entity_name = 'Coal' AND ph.hierarchy_level=0 AND ph.parent_entity_id=@stra_id)
INSERT INTO portfolio_hierarchy (entity_name,entity_type_value_id,hierarchy_level,parent_entity_id) VALUES ('Coal',527,0,@stra_id)
IF NOT EXISTS (SELECT * FROM portfolio_hierarchy ph WHERE entity_name = 'Gas' AND ph.hierarchy_level=0 AND ph.parent_entity_id=@stra_id)
INSERT INTO portfolio_hierarchy (entity_name,entity_type_value_id,hierarchy_level,parent_entity_id) VALUES ('Gas',527,0,@stra_id)
IF NOT EXISTS (SELECT * FROM portfolio_hierarchy ph WHERE entity_name = 'Power' AND ph.hierarchy_level=0 AND ph.parent_entity_id=@stra_id)
INSERT INTO portfolio_hierarchy (entity_name,entity_type_value_id,hierarchy_level,parent_entity_id) VALUES ('Power',527,0,@stra_id)


IF NOT EXISTS (SELECT * FROM portfolio_hierarchy ph WHERE entity_name = 'Hedge' AND ph.hierarchy_level=1 AND ph.parent_entity_id=@subs_id)
INSERT INTO portfolio_hierarchy (entity_name,entity_type_value_id,hierarchy_level,parent_entity_id) VALUES ('Hedge',526,1,@subs_id)
SET @stra_id = SCOPE_IDENTITY()

IF NOT EXISTS (SELECT * FROM portfolio_hierarchy ph WHERE entity_name = 'Coal' AND ph.hierarchy_level=0 AND ph.parent_entity_id=@stra_id)
INSERT INTO portfolio_hierarchy (entity_name,entity_type_value_id,hierarchy_level,parent_entity_id) VALUES ('Coal',527,0,@stra_id)
IF NOT EXISTS (SELECT * FROM portfolio_hierarchy ph WHERE entity_name = 'Gas' AND ph.hierarchy_level=0 AND ph.parent_entity_id=@stra_id)
INSERT INTO portfolio_hierarchy (entity_name,entity_type_value_id,hierarchy_level,parent_entity_id) VALUES ('Gas',527,0,@stra_id)
IF NOT EXISTS (SELECT * FROM portfolio_hierarchy ph WHERE entity_name = 'Power' AND ph.hierarchy_level=0 AND ph.parent_entity_id=@stra_id)
INSERT INTO portfolio_hierarchy (entity_name,entity_type_value_id,hierarchy_level,parent_entity_id) VALUES ('Power',527,0,@stra_id)


IF NOT EXISTS (SELECT * FROM portfolio_hierarchy ph WHERE entity_name = 'Inter Group' AND ph.hierarchy_level=1 AND ph.parent_entity_id=@subs_id)
INSERT INTO portfolio_hierarchy (entity_name,entity_type_value_id,hierarchy_level,parent_entity_id) VALUES ('Inter Group',526,1,@subs_id)
SET @stra_id = SCOPE_IDENTITY()

IF NOT EXISTS (SELECT * FROM portfolio_hierarchy ph WHERE entity_name = 'Bafa Coal' AND ph.hierarchy_level=0 AND ph.parent_entity_id=@stra_id)
INSERT INTO portfolio_hierarchy (entity_name,entity_type_value_id,hierarchy_level,parent_entity_id) VALUES ('Bafa Coal',527,0,@stra_id)
IF NOT EXISTS (SELECT * FROM portfolio_hierarchy ph WHERE entity_name = 'Essent Coal' AND ph.hierarchy_level=0 AND ph.parent_entity_id=@stra_id)
INSERT INTO portfolio_hierarchy (entity_name,entity_type_value_id,hierarchy_level,parent_entity_id) VALUES ('Essent Coal',527,0,@stra_id)
IF NOT EXISTS (SELECT * FROM portfolio_hierarchy ph WHERE entity_name = 'Essent Gas' AND ph.hierarchy_level=0 AND ph.parent_entity_id=@stra_id)
INSERT INTO portfolio_hierarchy (entity_name,entity_type_value_id,hierarchy_level,parent_entity_id) VALUES ('Essent Gas',527,0,@stra_id)
IF NOT EXISTS (SELECT * FROM portfolio_hierarchy ph WHERE entity_name = 'Essent Power' AND ph.hierarchy_level=0 AND ph.parent_entity_id=@stra_id)
INSERT INTO portfolio_hierarchy (entity_name,entity_type_value_id,hierarchy_level,parent_entity_id) VALUES ('Essent Power',527,0,@stra_id)


INSERT INTO fas_strategy
(
fas_strategy_id, source_system_id, hedge_type_value_id, fx_hedge_flag, mes_gran_value_id, fs.gl_grouping_value_id, no_links, 
mes_cfv_value_id, fs.mes_cfv_values_value_id, fs.mismatch_tenor_value_id, fs.strip_trans_value_id, fs.asset_liab_calc_value_id,
fs.test_range_from,test_range_to,fs.include_unlinked_hedges,include_unlinked_items,fs.oci_rollout_approach_value_id,fs.organization_boundary_id,
fs.sub_entity, fs.rollout_per_type, gl_tenor_option
)
SELECT	entity_id, @source_system_id, 150, 'n', 176, 351, 'n', 200, 227, 250, 625, 277, 0.8, 1.2, 'y', 'n', 500, 1102, 'y', NULL, 'f' 
FROM portfolio_hierarchy ph 
LEFT OUTER JOIN fas_strategy fs ON ph.entity_id = fs.fas_strategy_id
WHERE parent_entity_id = @subs_id 
AND fs.fas_strategy_id IS NULL 


INSERT INTO fas_books (fas_book_id, no_link, hedge_item_same_sign, convert_uom_id)
SELECT	ph_book.entity_id [Book ID], 
		'n', 
		'n',
		CASE ph_book.entity_name 
			WHEN 'Coal' THEN	@uom_id_metric_ton
			WHEN 'Gas'	THEN	@uom_id_m3
			WHEN 'Power' THEN	@uom_id_mwh
			ELSE @uom_UNKNOWN
		END 
FROM portfolio_hierarchy ph_subs
INNER JOIN dbo.portfolio_hierarchy ph_stra ON ph_stra.parent_entity_id = ph_subs.entity_id
INNER JOIN dbo.portfolio_hierarchy ph_book ON ph_book.parent_entity_id = ph_stra.entity_id 
--INNER JOIN fas_books fb ON fb.fas_book_id = ph_book.entity_id
LEFT OUTER JOIN fas_books fb ON ph_book.entity_id = fb.fas_book_id
WHERE ph_subs.entity_id = @subs_id 
AND fb.fas_book_id IS NULL 


/*************** END ****************/

*/

/************************ 
* Populate Commodities
*************************/
DECLARE	@commodity_id_coal INT,
		@commodity_id_gas INT, 
		@commodity_id_power INT 
		
--IF NOT EXISTS (SELECT * FROM source_commodity WHERE commodity_id LIKE 'Coal' AND source_system_id = @source_system_id)
--INSERT INTO source_commodity (source_system_id, commodity_id, commodity_name, commodity_desc) VALUES (@source_system_id,'Coal','Coal','Coal')
--
--IF NOT EXISTS (SELECT * FROM source_commodity WHERE commodity_id LIKE 'Gas' AND source_system_id = @source_system_id)
--INSERT INTO source_commodity (source_system_id, commodity_id, commodity_name, commodity_desc) VALUES (@source_system_id,'Gas','Gas','Gas')
--
--IF NOT EXISTS (SELECT * FROM source_commodity WHERE commodity_id LIKE 'Power' AND source_system_id = @source_system_id)
--INSERT INTO source_commodity (source_system_id, commodity_id, commodity_name, commodity_desc) VALUES (@source_system_id,'Power','Power','Power')
--
--
--SELECT @commodity_id_coal = source_commodity_id FROM source_commodity WHERE commodity_id LIKE 'Coal' AND source_system_id = @source_system_id
--SELECT @commodity_id_gas = source_commodity_id FROM source_commodity WHERE commodity_id LIKE 'Gas' AND source_system_id = @source_system_id
--SELECT @commodity_id_power = source_commodity_id FROM source_commodity WHERE commodity_id LIKE 'Power' AND source_system_id = @source_system_id

INSERT INTO source_commodity (source_system_id, commodity_id, commodity_name, commodity_desc)
	SELECT DISTINCT @source_system_id, sd.portfolio_name, sd.portfolio_long_name, sd.portfolio_long_name  FROM adiha_process.dbo.stage_deals sd 
	LEFT JOIN source_commodity sc ON sc.commodity_id = sd.portfolio_name AND sc.source_system_id = @source_system_id 
	WHERE sc.commodity_id IS NULL 


/* Trader */
INSERT INTO source_traders (source_system_id, trader_id, trader_name, trader_desc)
SELECT DISTINCT @source_system_id, sd.trader_id, sd.trader_name, sd.trader_name  FROM adiha_process.dbo.stage_deals sd 
LEFT JOIN source_traders st ON sd.trader_id = st.trader_id AND st.source_system_id = @source_system_id 
WHERE st.trader_id IS NULL 


/* Counterparty */
INSERT INTO source_counterparty (source_system_id, counterparty_id, counterparty_name, counterparty_desc, int_ext_flag)
SELECT DISTINCT @source_system_id, sd.counterparty_name, sd.counterparty_name, sd.counterparty_name, 'e' FROM adiha_process.dbo.stage_deals sd 
LEFT JOIN source_counterparty sc ON sd.counterparty_name = sc.counterparty_id AND sc.source_system_id = @source_system_id 
WHERE sc.counterparty_id IS NULL 


/* Price Curves */
INSERT INTO source_price_curve_def (source_system_id, curve_id, curve_name, curve_des, market_value_id, market_value_desc, commodity_id, source_currency_id, source_curve_type_value_id, uom_id, Granularity)
SELECT DISTINCT @source_system_id, sd.curve_id, sd.curve_id_name, sd.curve_id_name, sd.curve_id, sd.curve_id_name,  
	sc1.source_commodity_id,
	ISNULL(sc.source_currency_id,@currency_unknown) source_currency_id,
	575, -- Commodity Curve
	CASE 
		WHEN sd.portfolio_name LIKE 'FI_UKPWR'	THEN @uom_id_mwh
		WHEN sd.portfolio_name LIKE 'FI_COAL'	THEN @uom_id_metric_ton
		WHEN sd.portfolio_name LIKE 'FI_UKGAS'	THEN @uom_id_m3
		ELSE @uom_UNKNOWN
	END,
	980	-- Granularity: Monthly
FROM adiha_process.dbo.stage_deals sd 
	LEFT JOIN dbo.source_price_curve_def spcd ON sd.curve_id = spcd.curve_id AND spcd.source_system_id = @source_system_id
	LEFT JOIN source_currency sc ON sc.currency_id=SUBSTRING(curve_id_name,CHARINDEX('.',curve_id_name)+1,3) AND sc.source_system_id = @source_system_id
	LEFT JOIN source_commodity sc1 ON sc1.commodity_id=sd.portfolio_name AND sc1.source_system_id = @source_system_id
WHERE spcd.curve_id IS NULL 


/* Portfolio Name (Source Book 1) */
INSERT INTO source_book (source_system_id, source_system_book_id, source_system_book_type_value_id, source_book_name, source_book_desc)
SELECT DISTINCT @source_system_id, portfolio_name, 50, portfolio_long_name, portfolio_long_name FROM adiha_process.dbo.stage_deals sd
LEFT OUTER JOIN source_book sb ON sd.portfolio_name = sb.source_system_book_id 
	AND sb.source_system_id = @source_system_id
	AND source_system_book_type_value_id = 50
WHERE sb.source_system_book_id IS NULL 


/* Strategy (Source Book 2) */
INSERT INTO source_book (source_system_id, source_system_book_id, source_system_book_type_value_id, source_book_name, source_book_desc)
SELECT DISTINCT @source_system_id, strategy, 51, strategy, strategy FROM adiha_process.dbo.stage_deals sd
LEFT OUTER JOIN source_book sb ON sd.strategy = sb.source_system_book_id 
	AND sb.source_system_id = @source_system_id
	AND source_system_book_type_value_id = 51
WHERE sb.source_system_book_id IS NULL 


/* Curve (Source Book 3) */
INSERT INTO source_book (source_system_id, source_system_book_id, source_system_book_type_value_id, source_book_name, source_book_desc)
SELECT DISTINCT @source_system_id, curve_id, 52, curve_id_name, curve_id_name FROM adiha_process.dbo.stage_deals sd
LEFT OUTER JOIN source_book sb ON sd.curve_id = sb.source_system_book_id 
	AND sb.source_system_id = @source_system_id
	AND source_system_book_type_value_id = 52
WHERE sb.source_system_book_id IS NULL 


/* External Indicator (Source Book 4) */
INSERT INTO source_book (source_system_id, source_system_book_id, source_system_book_type_value_id, source_book_name, source_book_desc)
SELECT DISTINCT @source_system_id, external_indicator, 53, external_indicator, external_indicator FROM adiha_process.dbo.stage_deals sd
LEFT OUTER JOIN source_book sb ON sd.external_indicator = sb.source_system_book_id 
	AND sb.source_system_id = @source_system_id
	AND source_system_book_type_value_id = 53
WHERE sb.source_system_book_id IS NULL 


/* Source System Book Map */
IF (OBJECT_ID('tempdb..#source_book_map') IS NOT NULL)
DROP TABLE #source_book_map

--SELECT @source_system_id ssi 
CREATE TABLE #source_book_map (
	fas_book_id INT,
	portfolio_name VARCHAR(50) COLLATE DATABASE_DEFAULT,
	external_indicator CHAR(1) COLLATE DATABASE_DEFAULT,
	fas_deal_type_value_id INT 
)

INSERT INTO #source_book_map 
SELECT 
	ph3.entity_id fas_book_id, 
	CASE 
		WHEN ph3.entity_name = 'Power' THEN 'FI_UKPWR' 
		WHEN ph3.entity_name = 'Coal' THEN 'FI_COAL' 
		WHEN ph3.entity_name = 'Gas' THEN 'FI_UKGAS'
	END portfolio_name,
	CASE 
		WHEN ph2.entity_name = 'Hedge' THEN 'y'
		WHEN ph2.entity_name = 'Trading' THEN 'n'
	END external_indicator,
	CASE 
		WHEN ph2.entity_name = 'Hedge' THEN 401	-- Hedged Items 
		WHEN ph2.entity_name = 'Trading' THEN 400	-- Hedging Instrument (Der)
	END fas_deal_type_value_id
FROM portfolio_hierarchy ph1
	INNER JOIN portfolio_hierarchy ph2 ON ph1.entity_id = ph2.parent_entity_id AND ph2.hierarchy_level = 1
	INNER JOIN portfolio_hierarchy ph3 ON ph2.entity_id = ph3.parent_entity_id AND ph3.hierarchy_level = 0
WHERE ph1.entity_name LIKE 'RWEST-UK'
	AND (ph2.entity_name IN ('Trading', 'Hedge') AND ph2.hierarchy_level = 1)
	AND (ph3.entity_name IN ('Gas','Coal','Power') AND ph3.hierarchy_level = 0)

/*
INSERT INTO source_system_book_map (fas_book_id, source_system_book_id1, source_system_book_id2, source_system_book_id3, source_system_book_id4, fas_deal_type_value_id)
SELECT DISTINCT 
	sbm.fas_book_id, sb1.source_book_id, sb2.source_book_id strategy, sb3.source_book_id curve_id, sb4.source_book_id, sbm.fas_deal_type_value_id
FROM adiha_process.dbo.stage_deals sd
	INNER JOIN source_book sb1 ON sb1.source_system_book_id = sd.portfolio_name AND sb1.source_system_book_type_value_id=50 AND sb1.source_system_id = @source_system_id
	INNER JOIN source_book sb2 ON sb2.source_system_book_id = sd.strategy AND sb2.source_system_book_type_value_id=51 AND sb2.source_system_id = @source_system_id
	INNER JOIN source_book sb3 ON sb3.source_system_book_id = sd.curve_id AND sb3.source_system_book_type_value_id=52 AND sb3.source_system_id = @source_system_id
	INNER JOIN source_book sb4 ON sb4.source_system_book_id = sd.external_indicator AND sb4.source_system_book_type_value_id=53 AND sb4.source_system_id = @source_system_id
	INNER JOIN #source_book_map sbm ON sbm.portfolio_name = sd.portfolio_name AND sbm.external_indicator = sd.external_indicator
	LEFT JOIN source_system_book_map ssbm 
	ON ssbm.source_system_book_id1 = sb1.source_book_id
	AND ssbm.source_system_book_id2 = sb2.source_book_id 
	AND ssbm.source_system_book_id3 = sb3.source_book_id 
	AND ssbm.source_system_book_id4 = sb4.source_book_id
WHERE ssbm.book_deal_type_map_id IS NULL  
*/

/* Deal Type */

INSERT INTO source_deal_type (source_system_id, deal_type_id, source_deal_type_name, source_deal_desc, sub_type)
SELECT DISTINCT @source_system_id, physical_financial_flag, physical_financial_flag, physical_financial_flag, 'n' sub_type
FROM adiha_process.dbo.stage_deals sd
	LEFT OUTER JOIN source_deal_type sdt ON sd.physical_financial_flag = sdt.deal_type_id
WHERE sdt.source_deal_type_id IS NULL 


/* Deal Subtype */
IF NOT EXISTS (SELECT * FROM source_deal_type WHERE source_system_id = @source_system_id AND deal_type_id = 'Term')
INSERT INTO source_deal_type (source_system_id, deal_type_id, source_deal_type_name, source_deal_desc, sub_type) 
VALUES (@source_system_id, 'Term', 'Term', 'Term', 'y')

--SELECT * FROM source_deal_type WHERE source_system_id = @source_system_id 

TRUNCATE table stage_sdd 

INSERT INTO [dbo].[stage_sdd]
           ([deal_id]
           ,[source_system_id]
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
           ,[deal_date]
           ,[ext_deal_id]
           ,[physical_financial_flag]
           ,[structured_deal_id]
           ,[counterparty_id]
           ,[source_deal_type_id]
           ,[source_deal_sub_type_id]
           ,[option_flag]
           ,[option_type]
           ,[option_excercise_type]
           ,[source_system_book_id1]
           ,[source_system_book_id2]
           ,[source_system_book_id3]
           ,[source_system_book_id4]
           ,[description1]
           ,[description2]
           ,[description3]
           ,[deal_category_value_id]
           ,[trader_id]
           ,[header_buy_sell_flag]
           ,[broker_id]
           ,[contract_id]
           ,[legal_entity]
           ,[table_code]
           ,[ExternalIndicator]
           ,[PayIndex]
           ,[ReceiveIndex]
           ,[filename]
           ,[fileAsOfDate]
           ,[trade_status]
           ,[folderEndurOrUser]
           ,[curve_id_name])
SELECT 
	c.deal_id, NULL source_system_id, [contract_expiration_date] term_start, NULL term_end,
	1 leg, c.cash_settlement_date, NULL fixed_float_leg, NULL buy_sell_flag, c.curve_id, c.fixed_price, NULL fixed_price_currency_id, 
	NULL option_strike_price, c.deal_volume, NULL deal_volume_frequency, 
	CASE c.portfolio_name WHEN 'FI_UKGAS' THEN 'Therms'
						WHEN 'FI_UKPWR' THEN 'MWh'
						WHEN 'FI_COAL' THEN 'Metric Tons'
					END  deal_volume_uom_id, NULL block_description, NULL deal_detail_description,
	NULL formula_id, c.deal_date, NULL ext_deal_id, NULL physical_financial_flag, NULL structured_deal_ID, c.counterparty_name, 
	c.physical_financial_flag source_deal_type_id, NULL source_deal_sub_type_id, NULL option_flag, NULL option_type, NULL option_exercise_type, 
	c.portfolio_name source_system_book_id1, c.strategy source_system_book_id2, c.curve_id source_system_book_id3, c.external_indicator source_system_book_id4,
	NULL description1, NULL description2, NULL description3, NULL deal_category_value_id, c.trader_id, NULL header_buy_sell_flag, NULL broker_id, 
	NULL contract_id, c.reporting_group_name legal_entity, NULL table_code, c.external_indicator, 
	c.pay_index, 
	c.receive_index,
	c.[filename],
	convert(VARCHAR(10),c.fileAsOfDate,120),trade_status,folderEndurOrUser,c.[curve_id_name]
FROM adiha_process.dbo.stage_deals c 

--COMMIT

END
