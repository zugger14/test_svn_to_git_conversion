IF  EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_setup_fees_grid_data]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].spa_setup_fees_grid_data
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**
	To load data in volume grid and related combo fields

	Parameters
	@flag: Operational Flag
	@source_fee_id : source fee id
	@jurisdiction_id : Jurisdiction id
*/
CREATE PROC [dbo].spa_setup_fees_grid_data
 @flag CHAR(1),
 @source_fee_id INT  = NULL,
 @jurisdiction_id INT = NULL
 AS
BEGIN
	SET NOCOUNT ON
	
	IF @flag = 's'
	BEGIN
		SELECT sc.counterparty_id AS counterparty,sdv.code AS fees,sf.source_fee_id, sf.fee_name,cg.[contract_name] AS contract
			FROM source_fee sf 
			LEFT JOIN static_data_value AS sdv ON sdv.value_id = sf.fees
			LEFT JOIN source_counterparty AS sc ON sc.source_counterparty_id = sf.counterparty
			LEFT JOIN contract_group AS cg ON cg.contract_id = sf.[contract]
	END
	
	--flag f for fees
	IF @flag = 'f'
	BEGIN
		SELECT value_id,code FROM static_data_value AS sdv WHERE sdv.[type_id] = 5500 AND sdv.value_id IN (307473,10000170,10000169)
	END

	--flag z for fees (new requirement)
	IF @flag = 'z'
	BEGIN
		SELECT value_id, code FROM static_data_value sdv
		INNER JOIN user_defined_fields_template udft
			ON udft.field_name = sdv.value_id 
		WHERE sdv.[type_id] = 5500 and udft.deal_udf_type = 'c'
	END
	
	--flag t for type
	IF @flag = 't'
	BEGIN
		SELECT '1' id,'Fixed' value UNION SELECT '2' id,'Variable' value UNION select '3' id,'Tiered' value
		
	END
	
	--flag c for counterparty
	IF @flag = 'c'
	BEGIN
		SELECT source_counterparty_id,IIF(counterparty_id = counterparty_name, counterparty_id, counterparty_id + ' - ' +counterparty_name) FROM source_counterparty
		
	END
	
	--flag a for contract
	IF @flag = 'a'
	BEGIN
		SELECT contract_id,[contract_name] FROM contract_group 
		
	END
	
	-- flag b for commodity 
	IF @flag = 'b'
	BEGIN
		SELECT source_commodity_id,commodity_name FROM source_commodity 
		
	END
	
	--flag l for location
	IF @flag = 'l'
	BEGIN
		SELECT source_minor_location_id,Location_Name FROM source_minor_location 
		
	END
	
	--flag l for location
	IF @flag = 'd'
	BEGIN
		SELECT source_deal_type_id,source_deal_type_name FROM source_deal_type 
		
	END
	
	-- e flag for loading data in product grid
	IF @flag = 'e'
	BEGIN
		SELECT * FROM source_fee_product AS sftp WHERE sftp.source_fee_id = @source_fee_id
	END
	
	-- k flag for loading data in volume grid
	IF @flag = 'k'
	BEGIN
		SELECT sfv.volume_id
			, sfv.source_fee_id
			, sfv.effective_date
			, sfv.[value]
			, sfv.subsidiary
			, sfv.deal_type
			, sfv.buy_sell
			, sfv.index_market
			, sfv.commodity
			, sfv.location
			, sfv.product
			, sfv.jurisdiction
			, sfv.tier
			, sfv.[type]
			, sfv.from_volume
			, sfv.to_volume
			, sfv.minimum_value
			, sfv.maximum_value
			, sfv.uom
			, sfv.currency
            , sfv.aggressor_initiator
			, sfv.rec_pay
		FROM source_fee_volume AS sfv WHERE sfv.source_fee_id = @source_fee_id
	END
	
	-- g flag for loading data in value grid
	IF @flag = 'g'
	BEGIN
		SELECT * FROM source_fee_tiered_value AS sftv WHERE sftv.source_fee_id = @source_fee_id
	END
	
	-- u flag for loading data in uom combo
	IF @flag = 'u'
	BEGIN
		SELECT source_uom_id,uom_name FROM source_uom
	END

	-- u flag for loading data in uom combo
	IF @flag = 'h'
	BEGIN
		SELECT source_currency_id,currency_name FROM source_currency
	END
	
	-- Added flag x For Loading data in 'Index' Combo
	IF @flag = 'x'
	BEGIN
		SELECT spcd.source_curve_def_id, spcd.curve_name FROM source_price_curve_def AS spcd
	END

	-- 'j' flag used to load values in a dependent combo (tier)
	ELSE IF @flag = 'j'
	BEGIN
		SELECT sdv.value_id AS id, sdv.code AS [value]
		FROM static_data_value sdv
		INNER JOIN state_properties_details spd ON spd.tier_id = sdv.value_id
		WHERE sdv.[type_id] = 15000
			AND spd.state_value_id = @jurisdiction_id
		GROUP BY sdv.value_id, sdv.code
	END


END
 