IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_getemissionprofile]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_getemissionprofile]
 GO 


-- exec spa_getemissionprofile 'r', null, 401, '94,95', NULL, NULL, null, NULL, NULL
--spa_getemissionprofile 's',NULL,401
--exec spa_getemissionprofile 's',NULL, 401, 106, NULL
-- spa_getemissionprofile 'a',69,null,144
CREATE proc [dbo].[spa_getemissionprofile]
@flag char(1),
@source_deal_header_id int=NULL,
@fas_deal_type_value_id int=null,
@sub_entity_id varchar(100)=NULL,
@strategy_entity_id varchar(100)=NULL,
@fas_book_id varchar(100)=NULL,
@year int=null,
@counterparty_id int=null,
@source_deal_type_id int=null,
@deal_sub_type_type_id int=null,
@trader_id int=null,
@curve_id int=null,
@deal_volume float=null,
@deal_volume_uom_id int=null,
@state_value_id int=null,
@book_deal_type_map_id int=null,
@assignment_type_value_id int=null,
@generator_id int=null,
@term_start datetime=null,
@term_end datetime=null,
@frequency_type char(1)=null,
@deal_date datetime = null


as
Declare @sql_Select varchar(8000)

declare @source_system_id int/*,@deal_date varchar(20),@assigned_date varchar(20)*/

if @flag in ('s')
begin

		set @sql_select='Select dh.source_deal_header_id [Deal ID],state.code Jurisdiction, assign.code Compliance,
		dbo.FNAdateformat(dh.entire_term_start) [Term Start],
		dbo.FNAdateformat(dh.entire_term_end) [Term End],
		spc.curve_name [Env Product],sdd.deal_volume Volume, uom.uom_name UOM,
		dbo.FNAdateformat(dh.deal_date) [Deal Date]		
		from source_deal_header dh join source_deal_detail sdd on
		dh.source_deal_header_id=sdd.source_deal_header_id
		inner join source_system_book_map sbmp ON dh.source_system_book_id1 = sbmp.source_system_book_id1 AND 
	        	dh.source_system_book_id2 = sbmp.source_system_book_id2 AND 
			dh.source_system_book_id3 = sbmp.source_system_book_id3 AND 
		        dh.source_system_book_id4 = sbmp.source_system_book_id4 
		inner join portfolio_hierarchy ph on ph.entity_id=sbmp.fas_book_id 
		inner join portfolio_hierarchy phs ON phs.entity_id=ph.parent_entity_id
		left outer join static_data_value state on dh.state_value_id=state.value_id  
		left outer  join static_data_value assign on assign.value_id=dh.assignment_type_value_id 
		left outer join source_price_curve_def spc on spc.source_curve_def_id=sdd.curve_id 
		left outer join source_uom uom on uom.source_uom_id=sdd.deal_volume_uom_id  
		where sbmp.fas_deal_type_value_id='+cast(@fas_deal_type_value_id as varchar)

		if @source_deal_header_id is not null
		set @sql_select=@sql_select + '	and dh.source_deal_header_id='+cast(@source_deal_header_id as varchar)
		
		if @fas_book_id is not null
		set @sql_select=@sql_select + ' and sbmp.fas_book_id in('+@fas_book_id  +')'

		if @sub_entity_id is not null
		set @sql_select=@sql_select + ' and phs.parent_entity_id in('+@sub_entity_id  +')'

		if @strategy_entity_id is not null
		set @sql_select=@sql_select + ' and phs.entity_id in('+@strategy_entity_id  +')'

		if @year is not null
		set @sql_select=@sql_select + ' and (year(sdd.term_start)='+cast(@year as varchar) +' and year(sdd.term_end)='+cast(@year as varchar) +')'
	
		set @sql_select= @sql_select+ ' order by dh.source_deal_header_id desc '

		exec(@sql_select)

		EXEC spa_print @sql_select
end
if @flag in ('r')
begin

		set @sql_select='Select phsub.entity_name Sub, 
					--dh.compliance_year Year, 
					datepart(yy,dh.entire_term_start) AS [Year],
					assign.code Compliance,
					state.code Jurisdiction, 
					spc.curve_name [Env Product], 
					dbo.FNARemoveTrailingZeroes(sum(sdd.deal_volume)) Volume, 
					uom.uom_name UOM
		
		from source_deal_header dh  join source_deal_detail sdd on
		dh.source_deal_header_id=sdd.source_deal_header_id
		inner join source_system_book_map sbmp ON dh.source_system_book_id1 = sbmp.source_system_book_id1 AND 
	        	dh.source_system_book_id2 = sbmp.source_system_book_id2 AND 
			dh.source_system_book_id3 = sbmp.source_system_book_id3 AND 
		        dh.source_system_book_id4 = sbmp.source_system_book_id4 
		inner join portfolio_hierarchy ph on ph.entity_id=sbmp.fas_book_id 
		inner join portfolio_hierarchy phs ON phs.entity_id=ph.parent_entity_id
		inner join portfolio_hierarchy phsub ON phsub.entity_id=phs.parent_entity_id

		left outer join static_data_value state on dh.state_value_id=state.value_id  
		left outer  join static_data_value assign on assign.value_id=dh.assignment_type_value_id 
		left outer join source_price_curve_def spc on spc.source_curve_def_id=sdd.curve_id 
		left outer join source_uom uom on uom.source_uom_id=sdd.deal_volume_uom_id  
		where sbmp.fas_deal_type_value_id='+cast(@fas_deal_type_value_id as varchar)

		if @source_deal_header_id is not null
		set @sql_select=@sql_select + '	and dh.source_deal_header_id='+cast(@source_deal_header_id as varchar)
		
		if @fas_book_id is not null
		set @sql_select=@sql_select + ' and sbmp.fas_book_id in('+@fas_book_id  +')'

		if @sub_entity_id is not null
		set @sql_select=@sql_select + ' and phs.parent_entity_id in('+@sub_entity_id  +')'

		if @strategy_entity_id is not null
		set @sql_select=@sql_select + ' and phs.entity_id in('+@strategy_entity_id  +')'

		if @year is not null
		set @sql_select=@sql_select + ' and (year(sdd.term_start)='+cast(@year as varchar) +' and year(sdd.term_end)='+cast(@year as varchar) +')'
		
		set @sql_select = @sql_select + ' group by phsub.entity_name, state.code, assign.code, dh.entire_term_start, spc.curve_name, uom.uom_name '

		exec(@sql_select)

		EXEC spa_print @sql_select
end
else if @flag='a'
begin
	select 	

		dh.source_deal_header_id,
		counterparty_id,
		source_deal_type_id,
		deal_sub_type_type_id,
		sbmp.book_deal_type_map_id,
		trader_id,
		curve_id,
		sdd.deal_volume,
		sdd.deal_volume_uom_id,
		compliance_year,
		state_value_id,
		assignment_type_value_id,
		sbmp.fas_book_id,
		dh.generator_id,
		sdd.deal_volume_frequency,
		dbo.FNADateformat(dh.entire_term_start),
		dbo.FNADateformat(dh.entire_term_end),
		dbo.FNADateformat(dh.deal_date)

		from source_deal_header dh join source_deal_detail sdd on
		dh.source_deal_header_id=sdd.source_deal_header_id
		left outer join source_system_book_map sbmp ON dh.source_system_book_id1 = sbmp.source_system_book_id1 AND 
        	dh.source_system_book_id2 = sbmp.source_system_book_id2 AND dh.source_system_book_id3 = sbmp.source_system_book_id3 AND 
	        dh.source_system_book_id4 = sbmp.source_system_book_id4 
		where dh.source_deal_header_id=@source_deal_header_id
end
else if @flag='i'
begin


declare @deal_id varchar(50)

set @deal_id=cast(isNUll(IDENT_CURRENT('source_deal_header')+1,1) as varchar)+'-EMS'

	select @source_system_id=f.source_system_id
	from portfolio_hierarchy b join fas_strategy f on f.fas_strategy_id=b.parent_entity_id
	where b.entity_id=@fas_book_id
	
--	set @deal_date=cast(year(@term_start) as varchar) +'-01'+'-01'
--	set @term_end=cast(@year as varchar) +'-12'+'-31'
--	set @term_start=@deal_date
--	set @deal_date=@term_start
--	set @assigned_date=@deal_date
	
	
	
	
		insert source_deal_header(
			deal_id,
			source_system_id,
			deal_date,
			physical_financial_flag,
			
			counterparty_id,
			entire_term_start,
			entire_term_end,
			source_deal_type_id,
			deal_sub_type_type_id,
			option_flag,
			source_system_book_id1,
			source_system_book_id2,
			source_system_book_id3,
			source_system_book_id4,
			trader_id,
			internal_deal_type_value_id,
			header_buy_sell_flag,
			compliance_year,
			state_value_id,
			assigned_date,
			assignment_type_value_id,
			deal_category_value_id,
			generator_id
			
		)
		select @deal_id,
			@source_system_id,
			@deal_date,
			'f',
			
			@counterparty_id,
			@term_start,
			@term_end,
			@source_deal_type_id,
			@deal_sub_type_type_id,
			'n',
			source_system_book_id1,
			source_system_book_id2,
			source_system_book_id3,
			source_system_book_id4,
			@trader_id,
			4,
			's',
			@year,
			@state_value_id,
			@term_start,
			@assignment_type_value_id,
			475,
			@generator_id
			
		FROM 
		source_system_book_map where book_deal_type_map_id=@book_deal_type_map_id
		
		set @source_deal_header_id=SCOPE_IDENTITY()

insert source_deal_detail(
		source_deal_header_id,
		term_start,
		term_end,
		leg,
		contract_expiration_date,
		fixed_float_leg,
		buy_sell_flag,
		curve_id,
		deal_volume,
		deal_volume_frequency,
		deal_volume_uom_id		
		)
		select @source_deal_header_id,
		@term_start,
		@term_end,
		1,
		@term_end,
		't',
		's',
		@curve_id,
		@deal_volume,
		@frequency_type,
		@deal_volume_uom_id
		

	If @@ERROR <> 0
	BEGIN
		
		Exec spa_ErrorHandler @@ERROR, 'spa_getemissionprofile' , 
				'EMS Deal', 'Error', 'Error on creating Emission Profile', ''
		RETURN
	END
	Else
	BEGIN
		Select 	'Success' ErrorCode, 
			'spa_getemissionprofile' Module, 
			'EMS Deal' Area, 
			 '' Status, 
			'Emission Profile successfully created.' Message, 
			'' Recommendation
	
		RETURN
	END

end
else if @flag='u'
begin

	
--	set @deal_date=cast(YEAR(@term_start)   as varchar) +'-01'+'-01'
	set @term_end=cast(YEAR(@term_start)    as varchar) +'-12'+'-31'
--	set @term_start=@deal_date
--	set @assigned_date=@deal_date
	
declare @book1 int, @book2 int, @book3 int,@book4 int
		select @book1=source_system_book_id1,@book2=source_system_book_id2,
		@book3=source_system_book_id3,@book4=source_system_book_id4
		from source_system_book_map where book_deal_type_map_id=@book_deal_type_map_id


		UPDATE source_deal_header
		SET 
			deal_date=@deal_date,
			counterparty_id=@counterparty_id,
			entire_term_start=@term_start,
			entire_term_end=@term_end,
			source_deal_type_id=@source_deal_type_id,
			deal_sub_type_type_id=@deal_sub_type_type_id,
			source_system_book_id1=@book1,
			source_system_book_id2=@book2,
			source_system_book_id3=@book3,
			source_system_book_id4=@book4,
			trader_id=@trader_id,
			compliance_year=@year,
			state_value_id=@state_value_id,
			assigned_date=@term_start,
			assignment_type_value_id=@assignment_type_value_id,
			generator_id=@generator_id
		WHERE source_deal_header_id=@source_deal_header_id
		
		update source_deal_detail
		set term_start=@term_start,
		term_end=@term_end,
		contract_expiration_date=@term_end,
		curve_id=@curve_id,
		deal_volume=@deal_volume,
		deal_volume_uom_id=@deal_volume_uom_id,
		deal_volume_frequency=@frequency_type
		where source_deal_header_id=@source_deal_header_id
		
		
	If @@ERROR <> 0
	BEGIN
		
		Exec spa_ErrorHandler @@ERROR, 'spa_getemissionprofile' , 
				'EMS Deal', 'Error', 'Error on updating Emission Profile', ''
		RETURN
	END
	Else
	BEGIN
		Select 	'Success' ErrorCode, 
			'spa_getemissionprofile' Module, 
			'EMS Deal' Area, 
			 '' Status, 
			'Emission Profile successfully saved.' Message, 
			'' Recommendation
	
		RETURN
	END

end
ELSE IF @flag = 'd'
BEGIN


	
	DECLARE @min_date datetime
	DECLARE @max_date_closed datetime
	
	select @min_date = min(as_of_date) from report_measurement_values_inventory
	where link_id= @source_deal_header_id
	
	select  @max_date_closed  = max(as_of_date) from close_measurement_books
	
	if @max_date_closed IS NOT NULL AND @min_date IS NOT NULL AND
	    @min_date <= @max_date_closed
	BEGIN
		Select 	'Error' ErrorCode, 
			'spa_emissionprofile' Module, 
			'EMS Deal' Area, 
			 'Error' Status, 
			'Accounting book already closed as of ' + dbo.FNADateFormat(@max_date_closed) + 
				'. Can not delete the transactions as they have accounting entries.' Message, 
			'' Recommendation
	
		RETURN
	END

	
	DELETE FROM DEAL_REC_ASSIGNMENT_AUDIT WHERE
	SOURCE_DEAL_HEADER_ID = @source_deal_header_id
	
	
	DELETE FROM TRANSACTION_STAGING WHERE SOURCE_DEAL_HEADER_ID= @source_deal_header_id
	
	DELETE FROM report_measurement_values_inventory WHERE
	link_id = @source_deal_header_id
	
	DELETE FROM calcprocess_inventory_deals WHERE
	SOURCE_DEAL_HEADER_ID  = @source_deal_header_id
	
	DELETE FROM confirm_status WHERE
	SOURCE_DEAL_HEADER_ID = @source_deal_header_id
	
	DELETE FROM GIS_CERTIFICATE WHERE
	SOURCE_DEAL_HEADER_ID = @source_deal_header_id
	
	DELETE FROM SOURCE_DEAL_detail WHERE
	SOURCE_DEAL_HEADER_ID = @source_deal_header_id

	DELETE FROM SOURCE_DEAL_header WHERE
	SOURCE_DEAL_HEADER_ID = @source_deal_header_id

	If @@ERROR <> 0
	BEGIN
		
		  Exec spa_ErrorHandler @@ERROR, 'spa_emissionprofile' , 
		    'EMS Deal', 'Error', 'Error found while deleting Emission Profile', ''
		  RETURN
	 END
	 Else
	 BEGIN
		  Select  'Success' ErrorCode, 
		   'spa_emissionprofile' Module, 
		   'EMS Deal' Area, 
		    '' Status, 
		   'Emission Profile successfully deleted.' Message, 
		   '' Recommendation
	 	  RETURN
	 END


END













