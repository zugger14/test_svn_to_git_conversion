IF OBJECT_ID(N'spa_missing_static_data', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_missing_static_data]
 GO 

--  [spa_missing_static_data] 's',NULL,1

CREATE PROCEDURE [dbo].[spa_missing_static_data]
	@flag VARCHAR(1),
	@table_id INT = NULL,
	@frm_tbl INT = NULL
AS
DECLARE @st VARCHAR(8000)
--declare @tbl_name varchar(100)
--SELECT * FROM ssis_mtm_formate2_error_log
--SELECT * FROM ssis_mtm_formate1_error_log
--PRICE_REGION=POSITION_A
--SETTLEMENT_CURRENCY='eUR'
--UNIT_OF_MEASUREMENT='FX'
SET @st = ''
IF @flag = 's'
begin
	if isnull(@frm_tbl,2)=2
	BEGIN
		if @table_id=4017 or  @table_id is null   --	legal_entity
		begin
			set @st='
			select distinct legal_entity [Source Value],''legal_entity'' [Source Table] from ssis_mtm_formate2_error_log  l
			where isnull(legal_entity,'''')<>'''' and legal_entity not in (select [legal_entity_id]  from source_legal_entity
			where source_system_id=l.source_system_id)'

		end
		if @table_id=4000 or  @table_id is null	-- source_book
		begin
			if  @st<>''
				set @st=@st +' union all '
			set @st=@st +' select distinct ias39_scope [Source Value],''source_book'' [Source Table] from ssis_mtm_formate2_error_log  l
			where isnull(ias39_scope,'''')<>'''' and ias39_scope not in (select source_system_book_id from source_book
			where source_system_id=l.source_system_id and source_system_book_type_value_id=53)
			union all
			select distinct commodity_balance,''source_book''  [Source Table] from ssis_mtm_formate2_error_log  l
			where isnull(commodity_balance,'''')<>'''' and commodity_balance not in (select source_system_book_id from source_book
			where source_system_id=l.source_system_id and source_system_book_type_value_id=52)
			union all
			select distinct portfolio,''source_book'' from ssis_mtm_formate2_error_log  l
			where isnull(portfolio,'''')<>'''' and portfolio not in (select source_system_book_id from source_book
			where source_system_id=l.source_system_id and source_system_book_type_value_id=51)
			union all
			select distinct ias39_book,''source_book'' from ssis_mtm_formate2_error_log l
			where  isnull(ias39_book,'''')<>'''' and ias39_book not in (select source_system_book_id from source_book
			where source_system_id=l.source_system_id and source_system_book_type_value_id=50)
		'

		end
		if @table_id=4001	or  @table_id is null --source_commodity
		begin
			if  @st<>''
				set @st=@st +' union all '
			set @st=@st +'
			select distinct commodity [Source Value],''source_commodity''  [Source Table] from ssis_mtm_formate2_error_log l
			where isnull(commodity,'''')<>'''' and commodity not in (select commodity_id from source_commodity
			where source_system_id=l.source_system_id)
					'
		end
		if @table_id=4002 or  @table_id is null	--source_counterparty
		begin
			if  @st<>''
				set @st=@st +' union all '
			set @st=@st +'
			select distinct counterparty [Source Value],''source_counterparty'' [Source Table]  from ssis_mtm_formate2_error_log l
			where isnull(counterparty,'''')<>'''' and counterparty not in (select counterparty_id from source_counterparty
			where source_system_id=l.source_system_id)
			'
		end
		if @table_id=4003 or  @table_id is null	--source_currency
		begin
			if  @st<>''
				set @st=@st +' union all '
			set @st=@st +'
			select distinct settlement_currency [Source Value],''source_currency'' [Source Table] from ssis_mtm_formate2_error_log l
			where isnull(settlement_currency,'''')<>'''' and settlement_currency not in (select currency_id from source_currency
			where source_system_id=l.source_system_id) '

		end

		if @table_id=4007 or  @table_id is null	--source_deal_type
		begin
			if  @st<>''
				set @st=@st +' union all '
			set @st=@st +'
			select distinct ins_type [Source Value],''source_deal_type'' [Source Table] from ssis_mtm_formate2_error_log l
			where isnull(ins_type,'''')<>''''  and ins_type not in (select deal_type_id from source_deal_type
			where source_system_id=l.source_system_id)'
		end 
		if @table_id=4009 or  @table_id is null	--source_price_curve_def
		begin
			if  @st<>''
				set @st=@st +' union all '
			set @st=@st +'
			select distinct price_region [Source Value],''source_price_curve_def'' [Source Table] from ssis_mtm_formate2_error_log l
			where isnull(price_region,'''')<>'''' and  price_region not in (select curve_id from source_price_curve_def
			where source_system_id=l.source_system_id)'
		end
		if @table_id=4010 or  @table_id is null	--source_traders
		begin
			if  @st<>''
				set @st=@st +' union all '
			set @st=@st +'
			select distinct trader [Source Value],''source_traders'' [Source Table] from ssis_mtm_formate2_error_log l
			where isnull(trader,'''')<>''''  and trader not in (select trader_id from source_traders
			where source_system_id=l.source_system_id)'
		end
		if @table_id=4011 or  @table_id is null	--source_uom
		begin
			if  @st<>''
				set @st=@st +' union all '
			set @st=@st +'
			select distinct unit_of_measure [Source Value],''source_uom'' [Source Table] from ssis_mtm_formate2_error_log l
			where isnull(unit_of_measure,'''')<>'''' and unit_of_measure not in (select uom_id from source_uom
			where source_system_id=l.source_system_id)'
		end
		EXEC spa_print @st
		exec(@st)
	end

	ELSE

	BEGIN
	if @table_id=4017 or  @table_id is null   --	legal_entity
	begin
		set @st='
		select distinct legal_entity [Source Value],''legal_entity'' [Source Table] from ssis_mtm_formate1_error_log l
		where isnull(legal_entity,'''')<>'''' and legal_entity not in (select [legal_entity_id]  from source_legal_entity
		where source_system_id=l.source_system_id)'
	
	end
	if @table_id=4000 or  @table_id is null	-- source_book
	begin
		if  @st<>''
			set @st=@st +' union all '
		set @st=@st +' 
		select distinct INTERNAL_portfolio,''source_book'' [Source Table] from ssis_mtm_formate1_error_log l
		where isnull(INTERNAL_portfolio,'''')<>'''' and INTERNAL_portfolio not in (select source_system_book_id from source_book
		where source_system_id=l.source_system_id and source_system_book_type_value_id=51)
	'

	end
	if @table_id=4001	or  @table_id is null --source_commodity
	begin
		if  @st<>''
			set @st=@st +' union all '
		set @st=@st +'
		select distinct commodity [Source Value],''source_commodity''  [Source Table] from ssis_mtm_formate1_error_log l
		where isnull(commodity,'''')<>'''' and commodity not in (select commodity_id from source_commodity
		where source_system_id=l.source_system_id)
				'
	end
	if @table_id=4002 or  @table_id is null	--source_counterparty
	begin
		if  @st<>''
			set @st=@st +' union all '
		set @st=@st +'
		select distinct counterparty [Source Value],''source_counterparty'' [Source Table]  from ssis_mtm_formate1_error_log l
		where isnull(counterparty,'''')<>'''' and counterparty not in (select counterparty_id from source_counterparty
		where source_system_id=l.source_system_id)
		'
	end
	if @table_id=4003 or  @table_id is null	--source_currency
	begin
		if  @st<>''
			set @st=@st +' union all '
		set @st=@st +'
		select distinct currency_B [Source Value],''source_currency'' [Source Table] from ssis_mtm_formate1_error_log l
		where isnull(currency_B,'''')<>'''' and currency_B not in (select currency_id from source_currency
		where source_system_id=l.source_system_id) '

	end


	if @table_id=4007 or  @table_id is null	--source_deal_type
	begin
		if  @st<>''
			set @st=@st +' union all '
		set @st=@st +'
		select distinct type [Source Value],''source_deal_type'' [Source Table] from ssis_mtm_formate1_error_log l
		where isnull(type,'''')<>''''  and type not in (select deal_type_id from source_deal_type
		where source_system_id=l.source_system_id)'
	end 
	if @table_id=4009 or  @table_id is null	--source_price_curve_def
	begin
		if  @st<>''
			set @st=@st +' union all '
		set @st=@st +'
		select distinct price_region [Source Value],''source_price_curve_def'' [Source Table] from ssis_mtm_formate1_error_log l
		where isnull(price_region,'''')<>'''' and  price_region not in (select curve_id from source_price_curve_def
		where source_system_id=l.source_system_id)'
	end
	if @table_id=4010 or  @table_id is null	--source_traders
	begin
		if  @st<>''
			set @st=@st +' union all '
		set @st=@st +'
		select distinct trader [Source Value],''source_traders'' [Source Table] from ssis_mtm_formate1_error_log l
		where isnull(trader,'''')<>''''  and trader not in (select trader_id from source_traders
		where source_system_id=l.source_system_id)'
	end
--	if @table_id=4011 or  @table_id is null	--source_uom
--	begin
--		if  @st<>''
--			set @st=@st +' union all '
--		set @st=@st +'
--		select distinct unit_of_measure [Source Value],''source_uom'' [Source Table] from ssis_mtm_formate1_error_log l
--		where isnull(unit_of_measure,'''')<>'''' and unit_of_measure not in (select uom_id from source_uom
--		where source_system_id=l.source_system_id)'
--	end
	EXEC spa_print @st
	exec(@st)
	END
END



else if @flag='i'
begin
begin try
	begin tran
	if isnull(@frm_tbl,2)=2
	BEGIN
		if @table_id=4017 or  @table_id is null   --	legal_entity
		begin
				insert source_legal_entity(source_system_id,[legal_entity_id],[legal_entity_name],[legal_entity_desc])
				select distinct source_system_id,legal_entity,legal_entity,legal_entity from ssis_mtm_formate2_error_log l
				where isnull(legal_entity,'')<>'' and legal_entity not in (select [legal_entity_id] from source_legal_entity
				where source_system_id=l.source_system_id)
		end

		if @table_id=4000 or  @table_id is null	-- source_book
		begin
			insert source_book(source_system_id,source_system_book_id,
			source_system_book_type_value_id,source_book_name,source_book_desc)
			select distinct source_system_id,ias39_scope,53,ias39_scope,ias39_scope from ssis_mtm_formate2_error_log  l
			where isnull(ias39_scope,'')<>'' and ias39_scope not in (select source_system_book_id  from source_book
			where source_system_id=l.source_system_id and source_system_book_type_value_id=53)

			insert source_book(source_system_id,source_system_book_id,
			source_system_book_type_value_id,source_book_name,source_book_desc)
			select distinct source_system_id,commodity_balance,52,commodity_balance,commodity_balance from ssis_mtm_formate2_error_log  l
			where isnull(commodity_balance,'')<>'' and commodity_balance not in (select source_system_book_id from source_book
			where source_system_id=l.source_system_id and source_system_book_type_value_id=52)

			insert source_book(source_system_id,source_system_book_id,
			source_system_book_type_value_id,source_book_name,source_book_desc)
			select distinct source_system_id,portfolio,51,portfolio,portfolio from ssis_mtm_formate2_error_log  l
			where isnull(portfolio,'')<>'' and portfolio not in (select source_system_book_id from source_book
			where source_system_id=l.source_system_id and source_system_book_type_value_id=51)

			insert source_book(source_system_id,source_system_book_id,
			source_system_book_type_value_id,source_book_name,source_book_desc)
			select distinct source_system_id,ias39_book,50,ias39_book,ias39_book from ssis_mtm_formate2_error_log  l
			where isnull(ias39_book,'')<>'' and ias39_book not in (select source_system_book_id from source_book
			where source_system_id=l.source_system_id and source_system_book_type_value_id=50)
		end


		if @table_id=4001	or  @table_id is null --source_commodity
		begin
			insert into source_commodity(source_system_id,commodity_id,commodity_name,commodity_desc)
			select distinct source_system_id,commodity,commodity,commodity from ssis_mtm_formate2_error_log  l
			where isnull(commodity,'')<>'' and commodity not in (select commodity_id from source_commodity
			where source_system_id=l.source_system_id)

		end
		if @table_id=4002 or  @table_id is null	--source_counterparty
		begin
			insert source_counterparty(source_system_id,counterparty_id,counterparty_name,counterparty_desc,int_ext_flag)
			select distinct source_system_id,counterparty,counterparty,counterparty,'i' from ssis_mtm_formate2_error_log  l
			where isnull(counterparty,'')<>'' and counterparty not in (select counterparty_id from source_counterparty
			where source_system_id=l.source_system_id)
		end
		if @table_id=4003 or  @table_id is null	--source_currency
		begin
			insert into source_currency(source_system_id,currency_id,currency_name,currency_desc)
			select distinct source_system_id,settlement_currency,settlement_currency,settlement_currency from ssis_mtm_formate2_error_log  l
			where isnull(settlement_currency,'')<>'' and settlement_currency not in (select currency_id from source_currency
			where source_system_id=l.source_system_id)
		end

		if @table_id=4007 or  @table_id is null	--source_deal_type
		begin
			insert source_deal_type(source_system_id,deal_type_id,source_deal_type_name,source_deal_desc,sub_type)
			select distinct source_system_id,ins_type,ins_type,ins_type,'n' from ssis_mtm_formate2_error_log  l
			where isnull(ins_type,'')<>'' and ins_type not in (select deal_type_id from source_deal_type
			where source_system_id=l.source_system_id)
		end 

		if @table_id=4009 or  @table_id is null	--source_price_curve_def
		begin
			insert source_price_curve_def(source_system_id,curve_id,curve_name,curve_des,commodity_id,
			market_value_id,source_currency_id,source_curve_type_value_id,uom_id)
			select distinct source_system_id,price_region,price_region,price_region,2,price_region,2,575,2 from ssis_mtm_formate2_error_log  l
			where isnull(price_region,'')<>'' and price_region not in (select curve_id from source_price_curve_def
			where source_system_id=l.source_system_id)
		end
		if @table_id=4010 or  @table_id is null	--source_traders
		begin
			insert into source_traders(source_system_id,trader_id,trader_name,trader_desc)
			select distinct source_system_id,trader,trader,trader from ssis_mtm_formate2_error_log  l
			where  isnull(trader,'')<>'' and trader not in (select trader_id from source_traders
			where source_system_id=l.source_system_id)
		end
		if @table_id=4011 or  @table_id is null	--source_uom
		begin
			insert into source_uom(source_system_id,uom_id,uom_name,uom_desc)
			select distinct source_system_id,unit_of_measure,unit_of_measure,unit_of_measure from ssis_mtm_formate2_error_log  l
			where  isnull(unit_of_measure,'')<>'' and unit_of_measure not in (select uom_id from source_uom
			where source_system_id=l.source_system_id)
		end
	END

	ELSE
	BEGIN
		if @table_id=4017 or  @table_id is null   --	legal_entity
		begin
				insert source_legal_entity(source_system_id,[legal_entity_id],[legal_entity_name],[legal_entity_desc])
				select distinct source_system_id,legal_entity,legal_entity,legal_entity from ssis_mtm_formate1_error_log l
				where isnull(legal_entity,'''')<>'''' and legal_entity not in (select [legal_entity_id] from source_legal_entity
				where source_system_id=l.source_system_id)
		end

		if @table_id=4000 or  @table_id is null	-- source_book
		begin

			insert source_book(source_system_id,source_system_book_id,
			source_system_book_type_value_id,source_book_name,source_book_desc)
			select distinct source_system_id,INTERNAL_portfolio,51,INTERNAL_portfolio,INTERNAL_portfolio from ssis_mtm_formate1_error_log  l
			where isnull(INTERNAL_portfolio,'''')<>'''' and INTERNAL_portfolio not in (select source_system_book_id from source_book
			where source_system_id=l.source_system_id and source_system_book_type_value_id=51)
		end


		if @table_id=4001	or  @table_id is null --source_commodity
		begin
			insert into source_commodity(source_system_id,commodity_id,commodity_name,commodity_desc)
			select distinct source_system_id,commodity,commodity,commodity from ssis_mtm_formate1_error_log  l
			where isnull(commodity,'''')<>'''' and commodity not in (select commodity_id from source_commodity
			where source_system_id=l.source_system_id)
		end
		if @table_id=4002 or  @table_id is null	--source_counterparty
		begin
			insert source_counterparty(source_system_id,counterparty_id,counterparty_name,counterparty_desc,int_ext_flag)
			select distinct source_system_id,counterparty,counterparty,counterparty,'i' from ssis_mtm_formate1_error_log  l
			where isnull(counterparty,'''')<>'''' and counterparty not in (select counterparty_id from source_counterparty
			where source_system_id=l.source_system_id)
		end
		if @table_id=4003 or  @table_id is null	--source_currency
		begin
			insert into source_currency(source_system_id,currency_id,currency_name,currency_desc)
			select distinct source_system_id,currency_B,currency_B,currency_B from ssis_mtm_formate1_error_log  l
			where isnull(currency_B,'''')<>'''' and currency_B not in (select currency_id from source_currency
			where source_system_id=l.source_system_id)
		end

		if @table_id=4007 or  @table_id is null	--source_deal_type
		begin
			insert source_deal_type(source_system_id,deal_type_id,source_deal_type_name,source_deal_desc,sub_type)
			select distinct source_system_id,[type],[type],[type],'n' from ssis_mtm_formate1_error_log  l
			where isnull([type],'''')<>'''' and [type] not in (select deal_type_id from source_deal_type
			where source_system_id=l.source_system_id)
		end 

		if @table_id=4009 or  @table_id is null	--source_price_curve_def
		begin
			insert source_price_curve_def(source_system_id,curve_id,curve_name,curve_des,commodity_id,
			market_value_id,source_currency_id,source_curve_type_value_id,uom_id)
			select distinct source_system_id,price_region,price_region,price_region,2,price_region,2,575,2 from ssis_mtm_formate1_error_log  l
			where isnull(price_region,'''')<>'''' and price_region not in (select curve_id from source_price_curve_def
			where source_system_id=l.source_system_id)
		end
		if @table_id=4010 or  @table_id is null	--source_traders
		begin
			insert into source_traders(source_system_id,trader_id,trader_name,trader_desc)
			select distinct source_system_id,trader,trader,trader from ssis_mtm_formate1_error_log  l
			where  isnull(trader,'''')<>'''' and trader not in (select trader_id from source_traders
			where source_system_id=l.source_system_id)
		end
--		if @table_id=4011 or  @table_id is null	--source_uom
--		begin
--			insert into source_uom(source_system_id,uom_id,uom_name,uom_desc)
--			select distinct source_system_id,unit_of_measure,unit_of_measure,unit_of_measure from ssis_mtm_formate1_error_log  l
--			where  isnull(unit_of_measure,'''')<>'''' and unit_of_measure not in (select uom_id from source_uom
--			where source_system_id=l.source_system_id)
--		end
	END
	commit tran
	Exec spa_ErrorHandler 0, 'Missing Static Data', 
		'spa_missing_static_data', 'Success', 
		'Missing Static Data Successfuly Inserted', ''

end try
begin catch
	declare @msg varchar(1000)
	set @msg=ERROR_MESSAGE()
	set @msg='Error in Inserting ['+@msg+']'
	--EXEC spa_print ERROR_number()

	if @@TRANCOUNT>0
		rollback
		Exec spa_ErrorHandler @@ERROR, 'Missing Static Data', 
				'spa_missing_static_data', 'DB Error', 
				@msg, ''

end catch

end









