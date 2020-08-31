/****** Object:  StoredProcedure [dbo].[spa_getsourcedefinitionfromsourcesystem]    Script Date: 04/10/2009 17:08:31 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_getsourcedefinitionfromsourcesystem]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_getsourcedefinitionfromsourcesystem]
/****** Object:  StoredProcedure [dbo].[spa_getsourcedefinitionfromsourcesystem]    Script Date: 04/10/2009 17:08:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- exec spa_getsourcedefinitionfromsourcesystem 's', null, 8, 575, 11

CREATE PROCEDURE [dbo].[spa_getsourcedefinitionfromsourcesystem]
	@flag CHAR(1),
	@source_system_id INT,
	@source_type INT,
	@curve_type VARCHAR(10)=NULL,
	@commodity_id VARCHAR(10)=NULL,
	@location_id INT = NULL,
	@deal_sub_type INT = NULL, 
	@source_uom_id INT = NULL
AS 

SET NOCOUNT ON

if @source_type=1 --counterparty
	Begin
		SELECT  source_counterparty.source_counterparty_id AS source_counterparty_id, 
        source_counterparty.counterparty_name
	FROM    source_counterparty INNER JOIN
	        source_system_description ON 
		source_counterparty.source_system_id = source_system_description.source_system_id
	where @source_system_id=source_system_description.source_system_id

	end

else if @source_type=2 --trader
	Begin
		SELECT  source_traders.source_trader_id AS source_trader_id, 
        source_traders.trader_name as trader_name
	FROM    source_traders INNER JOIN
	        source_system_description ON 
		source_traders.source_system_id = source_system_description.source_system_id
	where @source_system_id=source_system_description.source_system_id

	end

else if @source_type=3 --dealtype
	Begin
		SELECT  source_deal_type.source_deal_type_id AS source_deal_type_id, 
        source_deal_type.source_deal_type_name as source_deal_type_name
	FROM    source_deal_type INNER JOIN
	        source_system_description ON 
		source_deal_type.source_system_id = source_system_description.source_system_id
	where isnull(@source_system_id,2)=source_system_description.source_system_id and    (sub_type='n' or sub_type is null )
	order by source_deal_type.source_deal_type_name
	end

else if @source_type=4 --source_uom
	Begin
		SELECT  source_uom.source_uom_id AS source_uom_id, 
        source_uom.uom_name as uom_name
	FROM    source_uom INNER JOIN
	        source_system_description ON 
		source_uom.source_system_id = source_system_description.source_system_id
	where @source_system_id = source_system_description.source_system_id
	AND source_uom.source_uom_id = case when @source_uom_id IS NULL THEN source_uom.source_uom_id ELSE @source_uom_id END 

	end

else if @source_type=5 --source_price_curve_def
	Begin
	
	/*
		SELECT  source_price_curve_def.source_curve_def_id AS source_curve_def_id, 
        source_price_curve_def.curve_name as curve_name
	FROM    source_price_curve_def INNER JOIN
	        source_system_description ON 
		source_price_curve_def.source_system_id = source_system_description.source_system_id
	where @source_system_id=source_system_description.source_system_id
	*/

	select value_id,code from static_data_value where type_id=575
	end

else if @source_type=6 --source_price_curve
	Begin
	DECLARE @pricing_index INT
		if @flag='m'   --bring the meters for the particular location
		Begin
			SELECT 
				smlm.meter_id,mi.recorderid
			FROM 
				source_minor_location_meter smlm
				join source_minor_location sml ON sml.source_minor_location_id = smlm.source_minor_location_id
				LEFT JOIN meter_id mi ON mi.meter_id=smlm.meter_id
			where 
				sml.source_minor_location_id = @location_id
		End

		IF @deal_sub_type = 1	-- Spot
			SELECT @pricing_index=
				sml.pricing_Index from source_minor_location sml
				join source_price_curve_def spcd on spcd.source_curve_def_id = sml.pricing_Index
				where source_minor_location_id = @location_id
		ELSE					-- Term
			SELECT @pricing_index=
				sml.term_Pricing_Index from source_minor_location sml
				join source_price_curve_def spcd on spcd.source_curve_def_id = sml.term_Pricing_Index
				where source_minor_location_id = @location_id
				
		
		if @location_id is null OR (@pricing_index IS NULL)
		BEGIN
			SELECT '', '' UNION ALL
			SELECT  source_price_curve_def.source_curve_def_id AS source_curve_def_id, 
					source_price_curve_def.curve_name AS curve_name
			FROM source_price_curve_def 
			INNER JOIN source_system_description ON source_price_curve_def.source_system_id = source_system_description.source_system_id
			WHERE @source_system_id=source_system_description.source_system_id 
				AND (source_curve_type_value_id = ISNULL(CAST(@curve_type AS INT), source_curve_type_value_id))
				AND (commodity_id = ISNULL(CAST(@commodity_id AS INT), commodity_id))
			--ORDER BY source_price_curve_def.curve_name ASC
--			SELECT NULL AS term_pricing_index,'' AS curve_name
			
		END
		ELSE
		Begin			
			IF @deal_sub_type = 1	-- Spot
				SELECT sml.pricing_Index, spcd.curve_name from source_minor_location sml
					join source_price_curve_def spcd on spcd.source_curve_def_id = sml.pricing_Index
					where source_minor_location_id = @location_id
			ELSE					-- Term
				SELECT sml.term_Pricing_Index, spcd.curve_name from source_minor_location sml
					join source_price_curve_def spcd on spcd.source_curve_def_id = sml.term_Pricing_Index
					where source_minor_location_id = @location_id
								
		End
	
	end

else if @source_type=7 --source_currency
	Begin
	

		SELECT  source_currency.source_currency_id AS source_currency_id, 
	        source_currency.currency_id as currency_id
		FROM    source_currency INNER JOIN
		        source_system_description ON 
			source_currency.source_system_id = source_system_description.source_system_id
		where @source_system_id=source_system_description.source_system_id



	end


else if @source_type=8 --source_commodity
Begin
SELECT  source_commodity.source_commodity_id AS source_commodity_id, 
	source_commodity.commodity_name + case when source_system_name='farrms' then '' else '.' + source_system_name end  as commodity_id
	FROM    source_commodity INNER JOIN
	        source_system_description ON 
		source_commodity.source_system_id = source_system_description.source_system_id
	where source_commodity.source_system_id = isnull(@source_system_id,source_commodity.source_system_id) 
	order by source_system_name + '.' + source_commodity.commodity_name 

end
else if @source_type=9 --source_deal Sub
Begin
	
	
SELECT  source_deal_type.source_deal_type_id AS source_deal_type_id, 
        source_deal_type.source_deal_type_name as source_deal_type_name
	FROM    source_deal_type INNER JOIN
	        source_system_description ON 
		source_deal_type.source_system_id = source_system_description.source_system_id
	where @source_system_id=source_system_description.source_system_id and  sub_type='y'

end






