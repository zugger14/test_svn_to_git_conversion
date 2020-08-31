IF OBJECT_ID(N'spa_sourcedealdetail', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_sourcedealdetail]
GO 

--exec spa_sourcedealdetail 'a', 55610, null, null, null,  null, null, 'b'

CREATE PROC [dbo].[spa_sourcedealdetail]
	@flag CHAR(1),
	@source_deal_header_id INT,
	@term_start VARCHAR(10) = NULL,
	@term_end VARCHAR(10) = NULL,
	@leg INT = NULL,
	@contract_expiration_date VARCHAR(10) = NULL,
	@fixed_float_leg CHAR(1) = NULL,
	@buy_sell_flag CHAR(1) = NULL,
	@curve_id INT = NULL,
	@fixed_price FLOAT = NULL,
	@fixed_price_currency_id INT = NULL,
	@option_strike_price FLOAT = NULL,
	@deal_volume FLOAT = NULL,
	@deal_volume_frequency CHAR(1) = NULL,
	@deal_volume_uom_id INT = NULL,
	@block_description VARCHAR(100) = NULL,
	@deal_detail_description VARCHAR(100) = NULL,
	@term_start1 VARCHAR(10) = NULL,
	@term_end1 VARCHAR(10) = NULL,
	@leg1 INT = NULL,
	@formula_id INT = NULL

AS

DECLARE @sql_select        VARCHAR(5000)
DECLARE @term_start_value  VARCHAR(10)
DECLARE @term_end_value    VARCHAR(10)

IF @flag='s'
	BEGIN
				
		SET  @sql_select='select source_deal_header_id,dbo.FNADateFormat(term_start) as TermStart,dbo.FNADateFormat(term_end) as TermEnd,
		Leg,dbo.FNADateFormat(contract_expiration_date) as ExpDate,
		case when fixed_float_leg=''f'' then ''Fixed''
		else ''Float''
		End
		as FixedFloat,
		case when buy_sell_flag =''b'' then ''Buy''
		else ''Sell''
		End
		
		as BuySell,curve_id as [Index],fixed_price as Price,source_deal_detail.formula_id as FormulaPrice,fixed_price_currency_id as Currency,option_strike_price as StrikePrice
		,deal_volume as Volume,
		deal_volume_uom_id as UOM,deal_volume_frequency as Frequency, block_description as BolckDesc,
		deal_detail_description as Description,dbo.FNAFormulaFormat(formula_editor.formula,''c'') as Formula
		from source_deal_detail  left join formula_editor on source_deal_detail.formula_id=formula_editor.formula_id
		where source_deal_header_id='+cast(@source_deal_header_id as varchar)

		if @term_start is not null
		set @sql_select= @sql_select+ ' And term_start='''+@term_start+''''
	
		if @term_start is not null
		set @sql_select= @sql_select +' And term_end='''+@term_end+''''
		
		set @sql_select= @sql_select+ ' order by term_start,leg'
		
		--print @sql_select

		exec(@sql_select)

	End

else if @flag='i'
	Begin
		insert into source_deal_detail (source_deal_header_id,
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
		deal_detail_description)
		select source_deal_header_id,
		dateadd(month,1,term_start),
		dbo.FNALastDayInDate(dateadd(month,1,term_end)),
		leg,
		dbo.FNALastDayInDate(dateadd(month,1,term_end)),
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
		deal_detail_description from source_deal_detail
		where term_start=(select max(term_start) from source_deal_detail where source_deal_header_id=@source_deal_header_id) and
		term_end=(select max(term_end) from source_deal_detail where source_deal_header_id=@source_deal_header_id) 
		and source_deal_header_id=@source_deal_header_id
	

	
		If @@ERROR <> 0
		Begin		

		Exec spa_ErrorHandler @@ERROR, 'Source Deal Detail  table', 

				'spa_sourcedealdetail', 'DB Error', 

				'Failed inserting record.', ''
		End
		Else
		Begin

			select @term_end_value=(select dbo.FNACovertToSTDDate(max(term_end)) from source_deal_detail where source_deal_header_id=@source_deal_header_id) 		
			update source_deal_header set entire_term_end=@term_end_value where
			source_deal_header_id=@source_deal_header_id
			
			set @term_end_value=dbo.FNADateFormat(@term_end_value)
	
			Exec spa_ErrorHandler 0, 'Source Deal Header  table', 

				'spa_sourcedealdetail', 'Success',@term_end_value,''
		End
	End

else if @flag='u' 
	Begin
		
		update source_deal_detail set
		term_start=@term_start,
		term_end=@term_end,
		leg=@leg,

		contract_expiration_date=@contract_expiration_date,
		fixed_float_leg=@fixed_float_leg,
		buy_sell_flag=@buy_sell_flag,
		curve_id=@curve_id,
		fixed_price=@fixed_price,
		fixed_price_currency_id=@fixed_price_currency_id,
		option_strike_price=@option_strike_price,
		deal_volume=@deal_volume,
		deal_volume_frequency=@deal_volume_frequency,
		deal_volume_uom_id=@deal_volume_uom_id,
		block_description=@block_description,
		--internal_deal_type_value_id=@internal_deal_type_value_id,
		--internal_deal_subtype_value_id=@internal_deal_subtype_value_id,
		deal_detail_description=@deal_detail_description,
		formula_id=@formula_id
		where source_deal_header_id=@source_deal_header_id and term_start=@term_start1
		and term_end=@term_end1 and leg=@leg1

		If @@ERROR <> 0

		Exec spa_ErrorHandler @@ERROR, 'Source Deal Detail  table', 

				'spa_sourcedealdetail', 'DB Error', 

				'Failed updating record.', ''


		Else

		Exec spa_ErrorHandler 0, 'Source Deal Header  table', 

				'spa_sourcedealdetail', 'Success', 

				'Source deal detail  record successfully updated.', ''

		
	End

ELSE IF @flag='c'
	Begin
	update source_deal_detail set
		contract_expiration_date=@contract_expiration_date,
		fixed_float_leg=@fixed_float_leg,
		buy_sell_flag=@buy_sell_flag,
		curve_id=@curve_id,
		fixed_price=@fixed_price,
		fixed_price_currency_id=@fixed_price_currency_id,
		option_strike_price=@option_strike_price,
		deal_volume=@deal_volume,
		deal_volume_frequency=@deal_volume_frequency,
		deal_volume_uom_id=@deal_volume_uom_id,
		block_description=@block_description,
		--internal_deal_type_value_id=@internal_deal_type_value_id,
		--internal_deal_subtype_value_id=@internal_deal_subtype_value_id,
		deal_detail_description=@deal_detail_description,
		formula_id=@formula_id
		where source_deal_header_id = @source_deal_header_id and
		term_start <> @term_start and term_end <> @term_end and leg=@leg

		If @@ERROR <> 0

		Exec spa_ErrorHandler @@ERROR, 'Source Deal Detail  table', 

				'spa_sourcedealdetail', 'DB Error', 

				'Failed updating record.', ''


		Else

		Exec spa_ErrorHandler 0, 'Source Deal Header  table', 

				'spa_sourcedealdetail', 'Success', 

				'Source deal detail  record successfully updated.', ''

		
	End

			
ELSE IF @flag='d'
	Begin

		
		if ((select count(*) from source_deal_detail where term_Start < @term_Start and source_deal_header_id=@source_deal_header_id)>0 AND  (select count( *) from source_deal_detail where  term_start > @term_start and source_deal_header_id=@source_deal_header_id) > 0)

				
		Begin
			Exec spa_ErrorHandler 1, 'Source Deal Detail  table', 
	
					'spa_sourcedealdetail', 'DB Error', 
	
					'Failed deleting record.', ''					
		End
		
		Else
		Begin
			delete from source_deal_detail
			where source_deal_header_id=@source_deal_header_id and term_start=@term_start
			and term_end=@term_end
	
			If @@ERROR <> 0
			Begin
			Exec spa_ErrorHandler @@ERROR, 'Source Deal Detail  table', 
	
					'spa_sourcedealdetail', 'DB Error', 
	
					'Failed deleting record.', ''
	
			End
			Else
			Begin
			set @term_start_value=(select dbo.FNACovertToSTDDate(min(term_start)) from source_deal_detail where source_deal_header_id=@source_deal_header_id) 
			set @term_end_value=(select dbo.FNACovertToSTDDate(max(term_end)) from source_deal_detail where source_deal_header_id=@source_deal_header_id) 
			
			
			update source_deal_header set entire_term_start=@term_start_value,entire_term_end=@term_end_value where
			source_deal_header_id=@source_deal_header_id
			
			
			set @term_start_value=dbo.FNADateFormat(@term_start_value)
			set @term_end_value=dbo.FNADateFormat(@term_end_value)
			
			Exec spa_ErrorHandler 0, 'Source Deal Header  table', 
						'spa_sourcedealdetail', 'Success', 
					@term_start_value,@term_end_value
			End
		End
	
	End

else if @flag='a'
Begin

		select source_deal_header_id,dbo.FNADateFormat(term_start) as TermStart,dbo.FNADateFormat(term_end) as TermEnd,
		Leg,dbo.FNADateFormat(contract_expiration_date) as ExpDate,
		 fixed_float_leg as FixedFloat,
		case when buy_sell_flag ='b' then 'Buy(Receive)'
		else 'Sell(Pay)'
		End
		as BuySell,source_deal_detail.curve_id as [Index],fixed_price as Price,
		source_deal_detail.formula_id as FormulaPrice,fixed_price_currency_id as Currency,option_strike_price as StrikePrice
		,deal_volume as Volume,deal_volume_uom_id as UOM,deal_volume_frequency as Frequency, block_description as BolckDesc,
		deal_detail_description as Description,dbo.FNAFormulaFormat(formula_editor.formula,'c') as Formula,
		case when source_deal_detail.curve_id is NULL then 0
		else source_price_curve_def.source_curve_type_value_id
		End as curve_type,
		source_price_curve_def.commodity_id,
		case when (deal_volume_frequency = 'h') then 3 when (deal_volume_frequency = 'd') then 4 else
			datediff(month,term_start,term_end) end as frequency
		from source_deal_detail  left join formula_editor on source_deal_detail.formula_id=formula_editor.formula_id
		inner join source_price_curve_def on 
		source_price_curve_def.source_curve_def_id=
		case when source_deal_detail.curve_id is not null then source_deal_detail.curve_id
		else 32
		End
	

		where source_deal_header_id=@source_deal_header_id and 
			buy_sell_flag = case when ((select max(leg) from  source_deal_detail where 
			source_deal_header_id=@source_deal_header_id) > 1) then @buy_sell_flag 
			else case when (@buy_sell_flag = 'b') then buy_sell_flag else 'k' end end
		

			

		Exec spa_ErrorHandler 0, 'Source Deal Header  table', 
						'spa_sourcedealdetail', 'Success', 
					'',''
End



