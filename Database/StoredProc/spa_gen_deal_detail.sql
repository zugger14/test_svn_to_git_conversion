IF OBJECT_ID(N'spa_gen_deal_detail', N'P') IS NOT NULL
DROP PROCEDURE spa_gen_deal_detail
 GO 




CREATE PROCEDURE spa_gen_deal_detail 

@flag as char(1),

@gen_deal_header_id as int, 

@term_start as datetime, 

@term_end as datetime = NULL, 

@leg as int, 

@fixed_price as float=NULL, 

@volume as float=NULL, 

@uom as VARCHAR(50)=NULL, 

@frequency as char(1)=NULL


AS


Declare @errorCode as int

Begin



if @flag='u'

Begin

	

	update gen_deal_detail set fixed_price = @fixed_price where gen_deal_header_id = @gen_deal_header_id 

	and term_start = dbo.FNACovertToSTDDate(@term_start) and term_end = dbo.FNACovertToSTDDate(@term_end) and leg = @leg

	

	update gen_deal_detail set deal_volume = @volume, deal_volume_uom_id = @uom, deal_volume_frequency = @frequency where 

	gen_deal_header_id = @gen_deal_header_id and term_start = dbo.FNACovertToSTDDate(@term_start) and

	 term_end = dbo.FNACovertToSTDDate(@term_end) 

		
	Set @errorCode = @@ERROR

	If @errorCode <> 0

		Exec spa_ErrorHandler @errorCode, 'GenDealDetail',

				'spa_gen_deal_detail', 'Error',

				'Failed to update Gen Deal Detail data.', ''

	Else

		Exec spa_ErrorHandler 0, 'StaticDataMgmt',

				'spa_gen_deal_detail', 'Success',

				'Gen Deal Detail data value updated.', ''

	

end
else if @flag='s'
	begin
		select 
			gen_deal_header_id,
			dbo.FNADateFormat(term_start) as TermStart,
			dbo.FNADateFormat(term_end) as TermEnd,
			Leg,
			dbo.FNADateFormat(contract_expiration_date) as ExpirationDate,
			fixed_float_leg,
			buy_sell_flag,
			curve_id,
			cast(round(fixed_price, 2) as varchar) as fixed_price,
			fixed_price_currency_id,
			option_strike_price,
			cast(round(deal_volume, 2) as varchar) as deal_volume,
			deal_volume_frequency,
			deal_volume_uom_id,
			block_description,
			internal_deal_type_value_id,
			internal_deal_subtype_value_id,
			deal_detail_description
			 from gen_deal_detail where gen_deal_header_id = @gen_deal_header_id And term_start = dbo.FNACovertToSTDDate(@term_start) and leg = @leg

	end
	


End




