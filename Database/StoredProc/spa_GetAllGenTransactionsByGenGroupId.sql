IF OBJECT_ID(N'spa_GetAllGenTransactionsByGenGroupId', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_GetAllGenTransactionsByGenGroupId]
GO 

-- EXEC spa_GetAllGenTransactionsByGenGroupId 'h', 3
-- EXEC spa_GetAllGenTransactionsByGenGroupId 'i', 3

--===========================================================================================
--This Procedure returns all outstanding transactions for outstanding gen links
--Input Parameters:
-- hedge_item_flag: 'h' is for hedge and 'i' for item
-- gen_link_id


--===========================================================================================

CREATE PROCEDURE [dbo].[spa_GetAllGenTransactionsByGenGroupId] 
	@hedge_item_flag CHAR, 
	@gen_hedge_group_id INT
AS

SET NOCOUNT ON

IF @hedge_item_flag = 'h'
BEGIN
select sdd.source_deal_header_id as DealHeaderID, 
	dbo.FNADateFormat(sdd.term_start) as TermStart, dbo.FNADateFormat(sdd.term_end) as TermEnd, 
	sdd.Leg as Leg, dbo.FNADateFormat(sdd.contract_expiration_date) as ExpirationDate, 
	case when (sdd.fixed_float_leg = 'f') then  'Fixed' else 'Float' End as FixedFloatLeg, 
	case when (sdd.buy_sell_flag = 'b') then 'Buy' else 'Sell' end as BuySellFlag, 
        spcd.curve_name as [Index], cast(round(sdd.fixed_price, 2) as varchar) as FixedPrice, 
	sc.currency_name as CurID, cast(round(sdd.option_strike_price, 2) as varchar) as StrikePrice, 
	cast(round(sdd.deal_volume, 2) as varchar) as Volume, 
	case when (sdd.deal_volume_frequency = 'm') then  'Monthly' else 'Daily' end as Frequency, 
        su.uom_name as UOM, sdd.block_description as BolckDesc, 
	--sdd.internal_deal_type_value_id as InternalTypeID, 
	--sdd.internal_deal_subtype_value_id as InternalSubTypeID, 
	sdd.deal_detail_description as [Desc], 
        sdd.create_user as CreatedUser, dbo.FNADateFormat(sdd.create_ts) as CreatedTS, 
	sdd.update_user as UpdatedUser, dbo.FNADateFormat(sdd.update_ts) as UpdatedTS

-- from source_deal_detail sdd, 
-- gen_fas_link_detail gld 
-- where 	sdd.source_deal_header_id = gld.deal_number and gld.hedge_or_item = @hedge_item_flag 
-- and gld.gen_link_id = @gen_link_id 
-- order by sdd.source_deal_header_id, sdd.contract_expiration_date


FROM    source_deal_detail sdd INNER JOIN
        gen_fas_link_detail gld ON sdd.source_deal_header_id = gld.deal_number INNER JOIN
        gen_fas_link_header ON gld.gen_link_id = gen_fas_link_header.gen_link_id INNER JOIN
        gen_hedge_group ON gen_fas_link_header.gen_hedge_group_id = gen_hedge_group.gen_hedge_group_id
	LEFT OUTER JOIN  source_price_curve_def spcd on spcd.source_curve_def_id = sdd.curve_id
	LEFT OUTER JOIN source_currency sc ON sc.source_currency_id = sdd.fixed_price_currency_id
	LEFT OUTER JOIN source_uom su  ON su.source_uom_id = sdd.deal_volume_uom_id
	
WHERE   (gld.hedge_or_item = @hedge_item_flag) AND (gen_hedge_group.gen_hedge_group_id = @gen_hedge_group_id)
ORDER BY sdd.source_deal_header_id, sdd.contract_expiration_date
END
ELSE
BEGIN
select sdd.gen_deal_header_id as DealHeaderID, 
	dbo.FNADateFormat(sdd.term_start) as TermStart, dbo.FNADateFormat(sdd.term_end) as TermEnd, 
	sdd.Leg as Leg, dbo.FNADateFormat(sdd.contract_expiration_date) as ExpirationDate, 
	case when (sdd.fixed_float_leg = 'f') then  'Fixed' else 'Float' End as FixedFloatLeg, 
	case when (sdd.buy_sell_flag = 'b') then 'Buy' else 'Sell' end as BuySellFlag, 
        spcd.curve_name as [Index], 
	cast(round(sdd.fixed_price, 2) as varchar) as FixedPrice, 
	sc.currency_name as CurID, 
	cast(round(sdd.option_strike_price, 2) as varchar) as StrikePrice, 
	cast(round(sdd.deal_volume, 2) as varchar) as Volume, 
	case when (sdd.deal_volume_frequency = 'm') then  'Monthly' else 'Daily' end as Frequency, 
        su.uom_name as UOM, 
	sdd.block_description as BolckDesc, 
	--sdd.internal_deal_type_value_id as InternalTypeID, sdd.internal_deal_subtype_value_id as InternalSubTypeID, 
	sdd.deal_detail_description as [Desc], 
        sdd.create_user as CreatedUser, dbo.FNADateFormat(sdd.create_ts) as CreatedTS

-- from source_deal_detail sdd, 
-- gen_fas_link_detail gld 
-- where 	sdd.source_deal_header_id = gld.deal_number and gld.hedge_or_item = @hedge_item_flag 
-- and gld.gen_link_id = @gen_link_id 
-- order by sdd.source_deal_header_id, sdd.contract_expiration_date


FROM	gen_deal_detail sdd INNER JOIN
        gen_fas_link_detail gld ON sdd.gen_deal_header_id = gld.deal_number INNER JOIN
        gen_fas_link_header ON gld.gen_link_id = gen_fas_link_header.gen_link_id INNER JOIN
        gen_hedge_group ON gen_fas_link_header.gen_hedge_group_id = gen_hedge_group.gen_hedge_group_id
	LEFT OUTER JOIN  source_price_curve_def spcd on spcd.source_curve_def_id = sdd.curve_id
	LEFT OUTER JOIN source_currency sc ON sc.source_currency_id = sdd.fixed_price_currency_id
	LEFT OUTER JOIN source_uom su  ON su.source_uom_id = sdd.deal_volume_uom_id

WHERE   (gld.hedge_or_item = @hedge_item_flag) AND (gen_hedge_group.gen_hedge_group_id = @gen_hedge_group_id)
ORDER BY sdd.gen_deal_header_id, sdd.contract_expiration_date


END


	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, 'Source Systems', 
				'spa_GetAllGenTransactions', 'DB Error', 
				'Failed to select outstanding transactions.', ''













