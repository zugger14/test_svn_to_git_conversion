IF OBJECT_ID(N'[dbo].[spa_GetItemsChangesDueToRepricing]', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_GetItemsChangesDueToRepricing]
GO 

-- EXEC spa_GetItemsChangesDueToRepricing 35
-- EXEC spa_GetItemsChangesDueToRepricing 64

--===========================================================================================
--this procedure returns what  would be changed when repricing occurrs in the current link

--===========================================================================================
-- drop proc spa_GetItemsChangesDueToRepricing
CREATE PROCEDURE [dbo].[spa_GetItemsChangesDueToRepricing]
	@hedge_or_item VARCHAR(1),
	@link_id INT
AS

SET NOCOUNT ON

If @hedge_or_item= 'i'
	select sdd.source_deal_header_id as DealHeaderID, 
		cast(round(gld.percentage_included, 2) as varchar) FromPerIncluded ,
		0 as ToPerIncluded ,
		dbo.FNADateFormat(sdd.term_start) as TermStart, dbo.FNADateFormat(sdd.term_end) as TermEnd, 
		sdd.Leg as Leg, dbo.FNADateFormat(sdd.contract_expiration_date) as ExpirationDate, 
		sdd.fixed_float_leg as FixedFloatLeg, sdd.buy_sell_flag as BuySellFlag, 
	        sdd.curve_id as [Index], cast(round(sdd.fixed_price, 2) as varchar) as FixedPrice, 
		sdd.fixed_price_currency_id as CurID, cast(round(sdd.option_strike_price, 2) as varchar) as StrikePrice, 
		cast(round(sdd.deal_volume, 2) as varchar) as Volume, sdd.deal_volume_frequency as Frequency, 
	        sdd.deal_volume_uom_id as UOM, sdd.block_description as BolckDesc, 
		--sdd.internal_deal_type_value_id as InternalTypeID, sdd.internal_deal_subtype_value_id as InternalSubTypeID, 
		sdd.deal_detail_description as [Desc], 
	        sdd.create_user as CreatedUser, dbo.FNADateFormat(sdd.create_ts) as CreatedTS, 
		sdd.update_user as UpdatedUser, dbo.FNADateFormat(sdd.update_ts) as UpdatedTS
	
	FROM         fas_link_detail gld INNER JOIN
	        source_deal_detail sdd on sdd.source_deal_header_id = gld.source_deal_header_id
	WHERE     (gld.hedge_or_item = 'i') AND (gld.link_id = @link_id)
	ORDER BY sdd.source_deal_header_id, sdd.contract_expiration_date
Else
	select sdd.source_deal_header_id as DealHeaderID, 
		cast(round(gld.percentage_included, 2) as varchar) PerIncluded ,
		dbo.FNADateFormat(sdd.term_start) as TermStart, dbo.FNADateFormat(sdd.term_end) as TermEnd, 
		sdd.Leg as Leg, dbo.FNADateFormat(sdd.contract_expiration_date) as ExpirationDate, 
		sdd.fixed_float_leg as FixedFloatLeg, sdd.buy_sell_flag as BuySellFlag, 
	        sdd.curve_id as [Index], cast(round(sdd.fixed_price, 2) as varchar) as FixedPrice, 
		sdd.fixed_price_currency_id as CurID, cast(round(sdd.option_strike_price, 2) as varchar) as StrikePrice, 
		cast(round(sdd.deal_volume, 2) as varchar) as Volume, sdd.deal_volume_frequency as Frequency, 
	        sdd.deal_volume_uom_id as UOM, sdd.block_description as BolckDesc, 
		--sdd.internal_deal_type_value_id as InternalTypeID, sdd.internal_deal_subtype_value_id as InternalSubTypeID, 
		sdd.deal_detail_description as [Desc], 
	        sdd.create_user as CreatedUser, dbo.FNADateFormat(sdd.create_ts) as CreatedTS, 
		sdd.update_user as UpdatedUser, dbo.FNADateFormat(sdd.update_ts) as UpdatedTS
	
	FROM         fas_link_detail gld INNER JOIN
	        source_deal_detail sdd on sdd.source_deal_header_id = gld.source_deal_header_id
	WHERE     (gld.hedge_or_item = 'h') AND (gld.link_id = @link_id)
	ORDER BY sdd.source_deal_header_id, sdd.contract_expiration_date



	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, 'Source Systems', 
				'spa_GetAllGenTransactions', 'DB Error', 
				'Failed to select outstanding transactions.', ''












