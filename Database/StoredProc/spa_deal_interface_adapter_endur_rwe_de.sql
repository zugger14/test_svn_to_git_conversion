
IF EXISTS (SELECT * FROM sys.objects WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[spa_deal_interface_adapter_endur_rwe_de]') AND TYPE IN (N'P', N'PC'))
    DROP PROCEDURE [dbo].[spa_deal_interface_adapter_endur_rwe_de]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[spa_deal_interface_adapter_endur_rwe_de]
@process_id VARCHAR(100) = NULL
AS

BEGIN
	
UPDATE adiha_process.dbo.stage_deals_rwe_de
	SET 
		proj_index_curve_id = REPLACE(proj_index_curve_id,'#', '_'),
		proj_index_name = REPLACE(proj_index_name, '#', '_') 
		--pay_index=REPLACE(pay_index,'#','_'), 
		--receive_index=REPLACE(receive_index,'#','_'),
		--portfolio_name=REPLACE(portfolio_name,'#','_'),
		--portfolio_long_name = REPLACE(portfolio_long_name, '#', '_'),
		--strategy=REPLACE(strategy,'#','_'),
		--external_indicator=REPLACE(external_indicator,'#','_'),
		--physical_financial_flag=right([physical_financial_flag],3)

/************************ 
* Source System
*************************/
DECLARE @source_system_id INT 
SET @source_system_id = 2

/************************ 
* Populate currencies
*************************/
DECLARE @currency_id_usd   INT, @currency_id_gbp   INT, @currency_id_eur   INT
		
IF NOT EXISTS (SELECT * FROM source_currency WHERE currency_id LIKE 'USD' AND source_system_id = @source_system_id)
	INSERT INTO source_currency(source_system_id, currency_id, currency_name, currency_desc) 
	VALUES (@source_system_id,'USD','USD','USD')
IF NOT EXISTS (SELECT * FROM source_currency WHERE currency_id LIKE 'GBP' AND source_system_id = @source_system_id)
	INSERT INTO source_currency(source_system_id, currency_id, currency_name, currency_desc) 
	VALUES (@source_system_id,'GBP','GBP','GBP')
IF NOT EXISTS (SELECT * FROM source_currency WHERE currency_id LIKE 'EUR' AND source_system_id = @source_system_id)
	INSERT INTO source_currency(source_system_id, currency_id, currency_name, currency_desc) 
	VALUES (@source_system_id,'EUR','EUR','EUR')

IF NOT EXISTS (SELECT * FROM source_currency WHERE currency_id='UNKNOWN' AND source_system_id = @source_system_id)
	INSERT INTO source_currency(source_system_id, currency_id, currency_name, currency_desc) 
	VALUES (@source_system_id,'UNKNOWN','UNKNOWN','UNKNOWN')

-- new currency insert i.e price_currency_id for sdd.fixed_price_currency_id
INSERT INTO source_currency(source_system_id, currency_id, currency_name, currency_desc)
	SELECT DISTINCT @source_system_id,
	       sd.price_currency_id,
	       sd.ccy,
	       sd.ccy
	FROM   adiha_process.dbo.stage_deals_rwe_de sd 
	LEFT JOIN source_currency sc ON sd.price_currency_id = sc.currency_id AND sc.source_system_id = @source_system_id 
	WHERE sc.currency_id IS NULL 


-- new currency insert i.e proj_index_currency for spcd.source_currency_id
INSERT INTO source_currency(source_system_id, currency_id, currency_name, currency_desc)
	SELECT DISTINCT @source_system_id,
	       sd.proj_index_currency,
	       sd.proj_index_currency,
	       sd.proj_index_currency
	FROM   adiha_process.dbo.stage_deals_rwe_de sd 
	LEFT JOIN source_currency sc ON sd.proj_index_currency = sc.currency_id AND sc.source_system_id = @source_system_id 
	WHERE sc.currency_id IS NULL 



--INSERT INTO source_currency (source_system_id, currency_id, currency_name, currency_desc)
--	SELECT DISTINCT @source_system_id, 
--	       SUBSTRING(curve_id_name, CHARINDEX('.', curve_id_name) + 1, 3),
--	       SUBSTRING(curve_id_name, CHARINDEX('.', curve_id_name) + 1, 3),
--	       SUBSTRING(curve_id_name, CHARINDEX('.', curve_id_name) + 1, 3)
--	FROM   adiha_process.dbo.stage_deals_rwe_de sd 
--	LEFT JOIN source_currency sc ON sc.currency_id = SUBSTRING(curve_id_name,CHARINDEX('.',curve_id_name)+1,3) 
--		 AND sc.source_system_id = @source_system_id 
--	WHERE sc.currency_id IS NULL AND LEN(curve_id_name)-CHARINDEX('.',curve_id_name,1)=3

SELECT @currency_id_usd = source_currency_id FROM source_currency WHERE currency_id LIKE 'USD' AND source_system_id = @source_system_id
SELECT @currency_id_gbp = source_currency_id FROM source_currency WHERE currency_id LIKE 'GBP'  AND source_system_id = @source_system_id
SELECT @currency_id_eur = source_currency_id FROM source_currency WHERE currency_id LIKE 'EUR'  AND source_system_id = @source_system_id

/************************ 
* Populate UOM
*************************/
DECLARE @uom_id_metric_ton  INT,
        @uom_id_m3          INT,
        @uom_id_mwh         INT
        -- DECLARE @uom_unknown        INT
			
IF NOT EXISTS (SELECT * FROM source_uom WHERE uom_id LIKE 'Metric Tons' AND source_system_id = @source_system_id)
	INSERT INTO source_uom(source_system_id, uom_id, uom_name, uom_desc) 
	VALUES (@source_system_id,'Metric Tons','Metric Tons','Metric Tons')

IF NOT EXISTS (SELECT * FROM source_uom WHERE uom_id LIKE 'Therms' AND source_system_id = @source_system_id)
	INSERT INTO source_uom(source_system_id, uom_id, uom_name, uom_desc) 
	VALUES (@source_system_id,'Therms','Therms','Therms')

IF NOT EXISTS (SELECT * FROM source_uom WHERE uom_id LIKE 'MWh' AND source_system_id = @source_system_id)
	INSERT INTO source_uom(source_system_id, uom_id, uom_name, uom_desc) 
	VALUES (@source_system_id,'MWh','MWh','MWh')

--IF NOT EXISTS (SELECT * FROM source_uom WHERE uom_id = 'UNKNOWN' AND source_system_id = @source_system_id)
--	INSERT INTO source_uom(source_system_id, uom_id, uom_name, uom_desc) 
--	VALUES (@source_system_id,'UNKNOWN','UNKNOWN','UNKNOWN')

SELECT @uom_id_metric_ton = source_uom_id FROM source_uom WHERE uom_id LIKE 'Metric Tons' AND source_system_id = @source_system_id
SELECT @uom_id_m3 = source_uom_id FROM source_uom WHERE uom_id LIKE 'Therms' AND source_system_id = @source_system_id
SELECT @uom_id_mwh = source_uom_id FROM source_uom WHERE uom_id LIKE 'MWh' AND source_system_id = @source_system_id
--SELECT @uom_unknown = source_uom_id FROM source_uom WHERE uom_id = 'UNKNOWN' AND source_system_id = @source_system_id


-- uom of source deal detail
INSERT INTO source_uom (source_system_id, uom_id, uom_name, uom_desc) 
SELECT DISTINCT @source_system_id, sd.unit, sd.unit, sd.unit 
FROM adiha_process.dbo.stage_deals_rwe_de sd
LEFT JOIN source_uom su ON su.uom_id = sd.unit AND su.source_system_id = @source_system_id
WHERE su.uom_id IS NULL


-- uom of price curve
INSERT INTO source_uom (source_system_id, uom_id, uom_name, uom_desc) 
SELECT DISTINCT @source_system_id, sd.proj_index_uom, sd.proj_index_uom, sd.proj_index_uom 
FROM adiha_process.dbo.stage_deals_rwe_de sd
LEFT JOIN source_uom su ON su.uom_id = sd.proj_index_uom AND su.source_system_id = @source_system_id
WHERE su.uom_id IS NULL


/* Script to create book structure */
DECLARE @subs_id  INT,
        @stra_id  INT 
/*
-- Subsidiary --
IF NOT EXISTS (SELECT * FROM portfolio_hierarchy ph WHERE entity_name='RWEST-UK' AND hierarchy_level=2)
BEGIN
	INSERT INTO portfolio_hierarchy (entity_name,entity_type_value_id,hierarchy_level,parent_entity_id) VALUES ('RWEST-UK',525,2,NULL)
	SET @subs_id = IDENT_CURRENT('portfolio_hierarchy')
END 
ELSE 
BEGIN7
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
DECLARE @commodity_id_coal   INT,
        @commodity_id_gas    INT,
        @commodity_id_power  INT 
		
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
	SELECT DISTINCT @source_system_id,
	       sd.proj_index_group_commodity,
	       sd.proj_index_group_commodity,
	       sd.proj_index_group_commodity
	FROM   adiha_process.dbo.stage_deals_rwe_de sd 
	LEFT JOIN source_commodity sc ON sc.commodity_id = sd.proj_index_group_commodity 
		 AND sc.source_system_id = @source_system_id 
	WHERE sc.commodity_id IS NULL 


/* Trader */
INSERT INTO source_traders (source_system_id, trader_id, trader_name, trader_desc)
	SELECT DISTINCT @source_system_id,
		   sd.trader_id,
		   sd.trader_name,
		   sd.trader_name
	FROM   adiha_process.dbo.stage_deals_rwe_de sd 
	LEFT JOIN source_traders st ON sd.trader_id = st.trader_id AND st.source_system_id = @source_system_id 
	WHERE st.trader_id IS NULL 


/* Broker */

--INSERT INTO source_brokers(source_system_id, broker_id, broker_name, broker_desc) 
--	SELECT DISTINCT @source_system_id,
--		   sd.broker_name,
--		   sd.broker_name,
--		   sd.broker_name
--	FROM adiha_process.dbo.stage_deals_rwe_de sd
--	LEFT JOIN source_brokers sb ON sb.broker_id = sd.broker_name AND sb.source_system_id = @source_system_id
--	WHERE sb.broker_id IS NULL
INSERT INTO source_counterparty (source_system_id, counterparty_id, counterparty_name, counterparty_desc, int_ext_flag, is_active)
	SELECT DISTINCT @source_system_id,
	       sd.broker_name,
	       sd.broker_name,
	       sd.broker_name,
	       'b',
		   'y'
	FROM   adiha_process.dbo.stage_deals_rwe_de sd 
	LEFT JOIN source_counterparty sc ON sd.broker_name = sc.counterparty_id AND sc.source_system_id = @source_system_id 
	WHERE sc.counterparty_id IS NULL 


/* Counterparty */
CREATE TABLE #tmp_source_cp(source_system_id INT, counterparty_id VARCHAR(50) COLLATE DATABASE_DEFAULT, counterparty_name VARCHAR(100) COLLATE DATABASE_DEFAULT,
							counterparty_desc VARCHAR(200) COLLATE DATABASE_DEFAULT, int_ext_flag CHAR(1) COLLATE DATABASE_DEFAULT, is_active CHAR(1) COLLATE DATABASE_DEFAULT)
							
INSERT INTO source_counterparty (source_system_id, counterparty_id, counterparty_name, counterparty_desc, int_ext_flag, is_active)
OUTPUT INSERTED.source_system_id, INSERTED.counterparty_id, INSERTED.counterparty_name, INSERTED.counterparty_desc, INSERTED.int_ext_flag, INSERTED.is_active
INTO #tmp_source_cp
SELECT DISTINCT @source_system_id source_system_id,
	       sd.counterparty_id counterparty_id,
	       sd.ext_bunit counterparty_name,
	       sd.ext_bunit counterparty_desc,
	       'e' int_ext_flag,
		   'y'
FROM   adiha_process.dbo.stage_deals_rwe_de sd 
LEFT JOIN source_counterparty sc ON sd.counterparty_id = sc.counterparty_id AND sc.source_system_id = @source_system_id
WHERE sc.counterparty_id IS NULL

IF EXISTS(SELECT 1 FROM #tmp_source_cp)
BEGIN
	INSERT INTO source_system_data_import_status(process_id, code, [module], [source], [type], [description], recommendation) 
	SELECT @process_id, 'Success', 'Import Data', 'RWE Deal', 'CounterParty', ' A new counterparty has been inserted. ID: ' 
			+ counterparty_id + ' , Name: ' + counterparty_name, NULL FROM #tmp_source_cp
END

/* Price Curves */
INSERT INTO source_price_curve_def (source_system_id, curve_id, curve_name, curve_des, market_value_id, market_value_desc, commodity_id, source_currency_id, source_curve_type_value_id, uom_id, Granularity, is_active)
	SELECT DISTINCT @source_system_id,
	       sd.proj_index_curve_id,
	       sd.proj_index_name,
	       sd.proj_index_name,
	       sd.proj_index_curve_id,
	       sd.proj_index_curve_id,
	       sc1.source_commodity_id,
	       sc.source_currency_id,
	       575,	-- Commodity Curve
	       --CASE 
	       --     WHEN sd.portfolio_name LIKE 'FI_UKPWR' THEN @uom_id_mwh
	       --     WHEN sd.portfolio_name LIKE 'FI_COAL' THEN @uom_id_metric_ton
	       --     WHEN sd.portfolio_name LIKE 'FI_UKGAS' THEN @uom_id_m3
	       --     ELSE @uom_UNKNOWN
	       --END,
	       
	       su.source_uom_id, 
	       
	       980 -- Granularity: Monthly
		   , 'y'
	FROM   adiha_process.dbo.stage_deals_rwe_de sd 
	LEFT JOIN dbo.source_price_curve_def spcd ON sd.proj_index_curve_id = spcd.curve_id AND spcd.source_system_id = @source_system_id
	LEFT JOIN source_currency sc ON sd.proj_index_currency = sc.currency_id AND sc.source_system_id = @source_system_id 
	LEFT JOIN source_commodity sc1 ON sc1.commodity_id=sd.proj_index_group_commodity AND sc1.source_system_id = @source_system_id
	LEFT JOIN source_uom su ON su.uom_id = sd.proj_index_uom AND su.source_system_id = @source_system_id
	
	WHERE spcd.curve_id IS NULL 

/* source minor location   */
	INSERT INTO source_minor_location(source_system_id, Location_Name, location_id)
		SELECT DISTINCT @source_system_id, sd.proj_index_name, sd.proj_index_name  
		FROM  adiha_process.dbo.stage_deals_rwe_de sd
		LEFT JOIN source_minor_location sml ON sml.Location_Name = sd.proj_index_name AND sml.source_system_id = @source_system_id
		WHERE sml.Location_Name IS NULL



--BOOK Identifiers----

/* Portfolio Name (Source Book 1) */
INSERT INTO source_book (source_system_id, source_system_book_id, source_system_book_type_value_id, source_book_name, source_book_desc)
	SELECT DISTINCT @source_system_id,
	       sd.portfolio_id,
	       50,
	       sd.int_portfolio,
	       sd.int_portfolio
	FROM   adiha_process.dbo.stage_deals_rwe_de sd
	LEFT OUTER JOIN source_book sb ON sd.portfolio_id = sb.source_system_book_id 
		AND sb.source_system_id = @source_system_id
		AND source_system_book_type_value_id = 50
	WHERE sb.source_system_book_id IS NULL AND sd.portfolio_id IS NOT NULL


/* Counterparty Group (Source Book 2) */
INSERT INTO source_book (source_system_id, source_system_book_id, source_system_book_type_value_id, source_book_name, source_book_desc)
                SELECT DISTINCT @source_system_id,
                       (CASE WHEN LOWER(sd.counterparty_group) = 'external' AND sc.int_ext_flag = 'i' THEN sd.ext_legal ELSE sd.counterparty_group END) source_system_book_id,
                       51,
                       (CASE WHEN LOWER(sd.counterparty_group) = 'external' AND sc.int_ext_flag = 'i' THEN sd.ext_legal ELSE sd.counterparty_group END) source_book_name,
                       (CASE WHEN LOWER(sd.counterparty_group) = 'external' AND sc.int_ext_flag = 'i' THEN sd.ext_legal ELSE sd.counterparty_group END) source_book_desc
                FROM   adiha_process.dbo.stage_deals_rwe_de sd
                LEFT JOIN source_counterparty sc ON sd.ext_bunit = sc.counterparty_name
                LEFT JOIN source_book sb ON (CASE WHEN LOWER(sd.counterparty_group) = 'external' AND sc.int_ext_flag = 'i' THEN sd.ext_legal ELSE sd.counterparty_group END) = sb.source_system_book_id 
                                AND sb.source_system_id = @source_system_id
                                AND source_system_book_type_value_id = 51
                WHERE sb.source_system_book_id IS NULL AND sd.counterparty_group IS NOT NULL

			--SELECT DISTINCT @source_system_id,
			--       (CASE WHEN LOWER(sd.counterparty_group) = 'external' AND sc.int_ext_flag = 'i' THEN sd.ext_bunit ELSE sd.counterparty_group END) source_system_book_id,
			--       51,
			--       (CASE WHEN LOWER(sd.counterparty_group) = 'external' AND sc.int_ext_flag = 'i' THEN sd.ext_bunit ELSE sd.counterparty_group END) source_book_name,
			--       (CASE WHEN LOWER(sd.counterparty_group) = 'external' AND sc.int_ext_flag = 'i' THEN sd.ext_bunit ELSE sd.counterparty_group END) source_book_desc
			--FROM   adiha_process.dbo.stage_deals_rwe_de sd
			--LEFT JOIN source_book sb ON sd.counterparty_group = sb.source_system_book_id 
			--	AND sb.source_system_id = @source_system_id
			--	AND source_system_book_type_value_id = 51
			--LEFT JOIN source_counterparty sc ON sd.ext_bunit = sc.counterparty_name
			--WHERE sb.source_system_book_id IS NULL AND sd.counterparty_group IS NOT NULL


/* Commodity Name (Source Book 3) */
INSERT INTO source_book (source_system_id, source_system_book_id, source_system_book_type_value_id, source_book_name, source_book_desc)
	SELECT DISTINCT @source_system_id,
		   sd.ins_type,
		   52,
		   sd.ins_type,
		   sd.ins_type
	FROM   adiha_process.dbo.stage_deals_rwe_de sd
	LEFT OUTER JOIN source_book sb ON sd.ins_type = sb.source_system_book_id 
		AND sb.source_system_id = @source_system_id
		AND source_system_book_type_value_id = 52
	WHERE sb.source_system_book_id IS NULL AND sd.ins_type IS NOT NULL

/* Instrument Type (Source Book 4) */
INSERT INTO source_book (source_system_id, source_system_book_id, source_system_book_type_value_id, source_book_name, source_book_desc)
	SELECT DISTINCT @source_system_id,
	       sd.proj_index_group_commodity,
	       53,
	       sd.proj_index_group_commodity,
	       sd.proj_index_group_commodity
	FROM   adiha_process.dbo.stage_deals_rwe_de sd
	LEFT OUTER JOIN source_book sb ON sd.proj_index_group_commodity = sb.source_system_book_id 
		AND sb.source_system_id = @source_system_id
		AND source_system_book_type_value_id = 53
	WHERE sb.source_system_book_id IS NULL AND sd.proj_index_group_commodity IS NOT NULL
/*
/* Source System Book Map */
IF (OBJECT_ID('tempdb..#source_book_map') IS NOT NULL)
    DROP TABLE #source_book_map

--SELECT @source_system_id ssi 
CREATE TABLE #source_book_map
(
	fas_book_id             INT,
	portfolio_name          VARCHAR(50) COLLATE DATABASE_DEFAULT,
	external_indicator      CHAR(1) COLLATE DATABASE_DEFAULT,
	fas_deal_type_value_id  INT
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

*/

/*
INSERT INTO source_system_book_map (fas_book_id, source_system_book_id1, source_system_book_id2, source_system_book_id3, source_system_book_id4, fas_deal_type_value_id)
SELECT DISTINCT 
	sbm.fas_book_id, sb1.source_book_id, sb2.source_book_id strategy, sb3.source_book_id curve_id, sb4.source_book_id, sbm.fas_deal_type_value_id
FROM adiha_process.dbo.stage_deals_rwe_de sd
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
--IF EXISTS( 	SELECT 1 FROM adiha_process.dbo.stage_deals_rwe_de sd LEFT JOIN source_deal_type sdt 
--			ON sd.[type] = sdt.deal_type_id AND sdt.sub_type = 'n' AND sdt.source_system_id = @source_system_id 
--			WHERE sdt.deal_type_id IS NULL AND sd.[type] IS NULL )
--BEGIN
--	INSERT INTO source_system_data_import_status(process_id, code, [module], [source], [type], [description], recommendation) 
--	SELECT @process_id, 'Error', 'Import Data', 'RWE Deal', 'DealType', ' Data error for Deal type:NULL', NULL
--END
--ELSE
--BEGIN
	INSERT INTO source_deal_type (source_system_id, deal_type_id, source_deal_type_name, source_deal_desc, sub_type)
	SELECT DISTINCT @source_system_id,
		   sd.[type],
		   sd.[type],
		   sd.[type],
		   'n' sub_type
	FROM adiha_process.dbo.stage_deals_rwe_de sd
		LEFT JOIN source_deal_type sdt ON sd.[type] = sdt.deal_type_id AND sdt.sub_type = 'n' AND sdt.source_system_id = @source_system_id 
	WHERE sdt.deal_type_id IS NULL 

--END


/* Deal Subtype */
INSERT INTO source_deal_type (source_system_id, deal_type_id, source_deal_type_name, source_deal_desc, sub_type)
	SELECT DISTINCT @source_system_id,
		   sd.[ins_sub_type],
		   sd.[ins_sub_type],
		   sd.[ins_sub_type],
		   'y' sub_type
	FROM adiha_process.dbo.stage_deals_rwe_de sd
		LEFT JOIN source_deal_type sdt ON sd.[ins_sub_type] = sdt.deal_type_id AND sdt.sub_type = 'y' AND sdt.source_system_id = @source_system_id
	WHERE sdt.deal_type_id IS NULL  AND sd.ins_sub_type IS NOT null

--IF NOT EXISTS (SELECT * FROM source_deal_type WHERE source_system_id = @source_system_id AND deal_type_id = 'Term')
--	INSERT INTO source_deal_type (source_system_id, deal_type_id, source_deal_type_name, source_deal_desc, sub_type) 
--	VALUES (@source_system_id, 'Term', 'Term', 'Term', 'y')

--SELECT * FROM source_deal_type WHERE source_system_id = @source_system_id 


/* Contract Group*/
INSERT INTO contract_group(source_system_id,source_contract_id, contract_name,contract_desc )
SELECT DISTINCT @source_system_id, sd.contract, sd.contract, sd.contract  
FROM adiha_process.dbo.stage_deals_rwe_de sd
LEFT JOIN contract_group cg ON cg.contract_name = sd.contract and cg.source_system_id = @source_system_id 
WHERE cg.contract_name IS NULL AND sd.[contract] IS NOT NULL

/*Map contract with counterparty*/
INSERT INTO counterparty_contract_address (contract_id, counterparty_id)
SELECT DISTINCT cg.contract_id, sc.source_counterparty_id FROM 
adiha_process.dbo.stage_deals_rwe_de sd
LEFT JOIN contract_group cg ON cg.contract_name = sd.contract
LEFT JOIN source_counterparty sc ON sd.counterparty_id = sc.counterparty_id
LEFT JOIN counterparty_contract_address cca ON cg.contract_id = cca.contract_id AND cca.counterparty_id = sc.source_counterparty_id
WHERE cca.counterparty_contract_address_id IS NULL AND sd.contract IS NOT NULL

/* source legal entity */
INSERT INTO source_legal_entity(source_system_id, legal_entity_id,
            legal_entity_name, legal_entity_desc)
	SELECT DISTINCT @source_system_id,
		   sd.[int_legal],
		   sd.[int_legal],
		   sd.[int_legal]
	FROM adiha_process.dbo.stage_deals_rwe_de sd
		LEFT JOIN source_legal_entity sle ON sd.[int_legal] = sle.legal_entity_id  AND sle.source_system_id = @source_system_id
	WHERE sle.legal_entity_id IS NULL AND sd.[int_legal] IS NOT NULL 

/* internal portfolio */
INSERT INTO source_internal_portfolio(source_system_id, internal_portfolio_id,
            internal_portfolio_name, internal_portfolio_desc)
	SELECT DISTINCT @source_system_id,
		   sd.[Int_Bunit],
		   sd.[Int_Bunit],
		   sd.[Int_Bunit]
	FROM adiha_process.dbo.stage_deals_rwe_de sd
		LEFT JOIN source_internal_portfolio sip ON sd.[Int_Bunit] = sip.internal_portfolio_id AND sip.source_system_id = @source_system_id
	WHERE sip.internal_portfolio_id IS NULL  AND sd.[Int_Bunit] IS NOT NULL
	
/* internal desk */
INSERT INTO source_internal_desk(source_system_id, internal_desk_id,
            internal_desk_name, internal_desk_desc)
	SELECT DISTINCT @source_system_id,
		   sd.[ext_legal],
		   sd.[ext_legal],
		   sd.[ext_legal]
	FROM adiha_process.dbo.stage_deals_rwe_de sd
		LEFT JOIN source_internal_desk si ON  sd.[ext_legal] = si.internal_desk_id AND si.source_system_id = @source_system_id
	WHERE si.internal_desk_id IS NULL AND sd.[ext_legal] IS NOT NULL
	
/* source_product */
INSERT INTO source_product(source_system_id, product_id, product_name,
            product_desc)
	SELECT DISTINCT @source_system_id,
		   sd.[ext_portfolio],
		   sd.[ext_portfolio],
		   sd.[ext_portfolio]
	FROM adiha_process.dbo.stage_deals_rwe_de sd
		LEFT JOIN source_product sp ON  sd.[ext_portfolio] = sp.product_id AND sp.source_system_id = @source_system_id
	WHERE sp.product_id IS NULL AND sd.[ext_portfolio] IS NOT NULL
	            	
DECLARE @projection_index_mapping_id INT
SELECT @projection_index_mapping_id = mapping_table_id FROM generic_mapping_header WHERE mapping_name = 'Projection Index Group'
-- UOM conversion logic via mapping tables
INSERT INTO #proj_index_mapping(source_book_id, source_book_name, vol_uom, price_uom, to_uom)
SELECT sb1.source_book_id source_book_id, MAX(sb1.source_book_name) source_book_name, su1.source_uom_id vol_uom, su2.source_uom_id price_uom, gmv.clm2_value to_uom
FROM adiha_process.dbo.stage_deals_rwe_de c1 
LEFT JOIN source_uom su1 ON su1.uom_id = c1.unit
LEFT JOIN source_uom su2 ON su2.uom_id = c1.price_uom
LEFT JOIN source_book sb1 ON sb1.source_book_name = c1.proj_index_group_commodity 
LEFT JOIN generic_mapping_values gmv ON gmv.clm1_value = sb1.source_book_id AND gmv.mapping_table_id = @projection_index_mapping_id-- for project index group
WHERE sb1.source_system_book_type_value_id = 53
GROUP BY sb1.source_book_id, su1.source_uom_id,su2.source_uom_id, gmv.clm2_value


DELETE FROM stage_sdd_rwe_de

INSERT INTO [dbo].[stage_sdd_rwe_de]
  (
    [deal_id],
    [source_system_id],
    [term_start],
    [term_end],
    [Leg],
    [contract_expiration_date],
    [fixed_float_leg],
    [buy_sell_flag],
    [curve_id],
    [fixed_price],
    [fixed_price_currency_id],
    [option_strike_price],
    [deal_volume],
    [deal_volume_frequency],
    [deal_volume_uom_id],
    [block_description],
    [deal_detail_description],
    [formula_id],
    [deal_date],
    [ext_deal_id],
    [physical_financial_flag],
    [structured_deal_id],
    [counterparty_id],
    [source_deal_type_id],
    [source_deal_sub_type_id],
    [option_flag],
    [option_type],
    [option_excercise_type],
    [source_system_book_id1],
    [source_system_book_id2],
    [source_system_book_id3],
    [source_system_book_id4],
    [description1],
    [description2],
    [description3],
    [description4],
    [deal_category_value_id],
    [trader_id],
    [header_buy_sell_flag],
    [broker_id],
    [contract_id],
    [legal_entity],
    [table_code],
    [reference],
    [file_name],
    [file_as_of_date],
    [trade_status],
    [folder_endur_or_user],
    [curve_id_name],
    [internal_portfolio_id],
    [internal_desk_id],
    [product_id],
    [settlement_date],
    [option_settlement_date]
  )
SELECT c.reference_code [deal_id],
       @source_system_id [source_system_id],
       c.[start_date] [term_start],
       c.end_date [term_end],
       NULL [leg], --leg will be updated by another logic 
       c.maturity_date [contract_expiration_date],
       c.fix_float [fixed_float_leg],
       c.pay_rec [buy_sell_flag],
       c.proj_index_curve_id [curve_id], -- CASE WHEN c.fix_float = 'F' THEN NULL ELSE c.proj_index_curve_id END [curve_id],
       CONVERT( NUMERIC(38,4), (CASE WHEN pc.put_call IS NOT NULL THEN c.option_premium ELSE c.price END) / ISNULL(rvuc2.conversion_factor, 1) ), --c.price [fixed_price],
       c.price_currency_id [fixed_price_currency_id],
       c.option_strike_price [option_strike_price],
       CONVERT( NUMERIC(38,2), ABS(c.position) * ISNULL(rvuc.conversion_factor, 1)) [deal_volume],
       c.deal_vol_type [deal_volume_frequency],
       CASE WHEN rvuc.rec_volume_unit_conversion_id IS NULL THEN c.unit ELSE p.to_uom_name END [deal_volume_uom_id],
       NULL [block_description],
       NULL [deal_detail_description],
       NULL [formula_id],
       c.trade_date [deal_date],
       NULL [ext_deal_id],
       CASE WHEN c.[type] = 'PHY' THEN 'p' ELSE 'f' END  [physical_financial_flag],
       NULL [structured_deal_ID],
       c.counterparty_id [counterparty_id],
       a.[type] [source_deal_type_id],
       c.ins_sub_type [source_deal_sub_type_id],
       CASE WHEN c.put_call IS NULL THEN 'n' ELSE 'y' END [option_flag],
       CASE c.put_call WHEN 'Call' THEN 'c' WHEN 'Put' THEN 'p' ELSE NULL END [option_type],
       NULL [option_exercise_type],
       ISNULL(c.portfolio_id, -1) [source_system_book_id1],
       (CASE WHEN LOWER(c.counterparty_group) = 'external' AND sc.int_ext_flag = 'i' THEN c.ext_legal ELSE ISNULL(c.counterparty_group, -2) END) [source_system_book_id2],
       ISNULL(c.ins_type, -3) [source_system_book_id3],
       ISNULL(c.proj_index_group_commodity, -4) [source_system_book_id4],
       c.reporting_group_name [description1],
       c.ins_reference [description2],
       c.tran_number [description3],
       c.offset_tran_num description4,
       NULL [deal_category_value_id],
       c.trader_id [trader_id],
       c.buy_sell_flag [header_buy_sell_flag],
       c.broker_name [broker_id],
       c.[contract] [contract_id],
       c.int_legal [legal_entity],
       NULL [table_code],
	   c.reference [reference],
       c.[file_name],
       CONVERT(VARCHAR(10), c.file_as_of_date, 120) [file_as_of_date],
       c.[status] trade_status,
       c.folder_endur_or_user [folder_endur_or_user],
       c.proj_index_name [curve_id_name], --CASE WHEN c.fix_float = 'F' THEN NULL ELSE c.proj_index_name END [curve_id_name],
       c.Int_Bunit [internal_portfolio_id],
       c.ext_legal [internal_desk_id],
       c.ext_portfolio [product_id],
       c.payment_date [settlement_date],
       c.premium_settlement_date [option_settlement_date]
FROM   adiha_process.dbo.stage_deals_rwe_de c 
LEFT JOIN (
SELECT pp.source_book_name source_book_name, pp.source_book_id source_book_id, MAX(pp.to_uom) to_uom, MAX(s.uom_id) to_uom_name FROM #proj_index_mapping pp 
LEFT JOIN source_uom s ON s.source_uom_id = pp.to_uom
GROUP BY pp.source_book_name, pp.source_book_id
) p ON p.source_book_name = c.proj_index_group_commodity
LEFT JOIN source_uom su ON su.uom_id = c.unit
LEFT JOIN rec_volume_unit_conversion rvuc ON rvuc.from_source_uom_id = su.source_uom_id AND rvuc.to_source_uom_id = p.to_uom
LEFT JOIN source_uom su2 ON su2.uom_id = c.price_uom
LEFT JOIN rec_volume_unit_conversion rvuc2 ON rvuc2.from_source_uom_id = su2.source_uom_id AND rvuc2.to_source_uom_id = p.to_uom
LEFT JOIN (
	SELECT reference_code, MAX([type]) [type] FROM adiha_process.dbo.stage_deals_rwe_de GROUP BY reference_code 
	) a ON c.reference_code = a.reference_code
LEFT JOIN (
	SELECT reference_code, MAX(put_call) [put_call] FROM adiha_process.dbo.stage_deals_rwe_de GROUP BY reference_code
	) pc ON c.reference_code = pc.reference_code	
LEFT JOIN source_counterparty sc ON c.ext_bunit = sc.counterparty_name  AND sc.source_system_id = @source_system_id AND sc.int_ext_flag <> 'b' -- all counterparty except broker
 

-- leg creation logic.
-- increment leg for every new term, but give priority to Physical leg instead of Financial
UPDATE dbo.stage_sdd_rwe_de SET leg = n.leg
FROM dbo.stage_sdd_rwe_de ssrd
INNER JOIN (
		SELECT deal_id, term_start, term_end, row_id
			, ROW_NUMBER() OVER(PARTITION BY deal_id, term_start, term_end ORDER BY physical_financial_flag DESC,fixed_float_leg DESC, row_id) leg
		FROM dbo.stage_sdd_rwe_de        
) n ON -- ssrd.deal_id = n.deal_id AND ssrd.term_start = n.term_start
	--AND ssrd.term_end = n.term_end
	--AND 
	ssrd.row_id = n.row_id


END
