
if object_id('spa_rollover_forward_to_spot') is not null
	drop proc [dbo].spa_rollover_forward_to_spot
go
--select * from source_deal_detail

/*
[dbo].spa_rollover_forward_to_spot 's'

*/
create proc [dbo].spa_rollover_forward_to_spot
@flag char(1),
@book_deal_type_map_id varchar(200)=NULL, 
@counterparty int=null,
@commodity int =null,
@deal_id_from int = NULL, 
@deal_id_to int = NULL, 
@term_start datetime=null,
@term_end datetime=null,
@current_month datetime=null,
@process_deals varchar(500)=null

as


-----------Test -----------------------------------------------------

--
--declare 
--@flag char(1),
--@book_deal_type_map_id varchar(200), 
--@counterparty int,
--@commodity int ,
--@deal_id_from int, 
--@deal_id_to int , 
--@term_start datetime,
--@term_end datetime,
--@current_month datetime,
--@process_deals varchar(500)
--
--set @flag='p'
--set @book_deal_type_map_id =null
--set @counterparty =null
--set @commodity  =null
--set @deal_id_from  = NULL
--set @deal_id_to = NULL
--set @term_start=null
--set @term_end =null
--set @current_month='2009-03-02'
--set @process_deals='2723'
--
--drop table #tmp_deals
--drop table #tmp_Offset_deal

-------------------End Test




declare @sql_stmt varchar(max),@term_deal_type varchar(50),@spot_deal_type varchar(50)
declare @sql_Select varchar(max) --,@book_id int
set @term_deal_type='Term'
set @spot_deal_type='Spot'

if @flag='s'
	Begin
	
--		select @book_id=fas_book_id from source_system_book_map where book_deal_type_map_id  in(@book_deal_type_map_id)
--		
--		set @starategy_id=(Select parent_entity_id from portfolio_hierarchy where entity_id=@book_id)
--		set @sub_id=(select parent_entity_id as [Subsidiary Id] from portfolio_hierarchy where entity_id=@starategy_id)	

--########### Group Label
		declare @group1 varchar(100),@group2 varchar(100),@group3 varchar(100),@group4 varchar(100)
		if exists(select group1,group2,group3,group4 from source_book_mapping_clm)
		begin	
			select @group1=group1,@group2=group2,@group3=group3,@group4=group4 from source_book_mapping_clm
		end
		else
		begin
			set @group1='Group1'
			set @group2='Group2'
			set @group3='Group3'
			set @group4='Group4'
		 
		end
--######## End


		SET @sql_Select = 
				'select [ID],[Ref ID],dbo.FNADateFormat(deal_date) as Date
		  ,[Ext ID],[Physical Financial Flag] ,[Counterparty Name],[Term Start]
		  ,[Term End] ,[Deal Type]  ,[Deal Sub Type]  ,[Option Flag]
		  ,[Option Type]  ,[Excersice Type]   ,['+ @group1 +']
		  ,['+ @group2 +']   ,['+ @group3 +']
		  ,['+ @group4 +'] ,[Desc1]  ,[Desc2]
		  ,[Desc3]   ,[Deal Category Value ID]   ,[Trader Name]
		  ,[Hedge Item Flag]    ,[Hedge Type]     ,[Assignment Type]
		  ,[Legal Entity] from 
			(	SELECT  dh.source_deal_header_id AS ID,
				dh.deal_id AS [Ref ID], 
				dh.deal_date,
 				max(dh.ext_deal_id) as [Ext ID],
				max(case when dh.physical_financial_flag =''p'' then ''Physical''
					else ''Financial''
				End) as [Physical Financial Flag], 
				max(source_counterparty.counterparty_name) as [Counterparty Name],
					max(dbo.FNADateFormat(dh.entire_term_start)) as [Term Start], 
				max(dbo.FNADateFormat(dh.entire_term_end)) As [Term End],
				 max(sdt.source_deal_type_name) As [Deal Type], 
				max(sdt1.source_deal_type_name) AS [Deal Sub Type], 
					max(dh.option_flag) As [Option Flag], 
				max(dh.option_type) As [Option Type], 
				max(dh.option_excercise_type) As [Excersice Type],
 				max(source_book.source_book_name) As ['+ @group1 +'], 
				max(source_book_1.source_book_name) AS ['+ @group2 +'], 
				max(source_book_2.source_book_name) AS ['+ @group3 +'], 
				max(source_book_3.source_book_name) AS ['+ @group4 +'],
				max(dh.description1) As Desc1,
				max( dh.description2) As Desc2,
				max(dh.description3) as Desc3,
				max(dh.deal_category_value_id) as [Deal Category Value ID],
				max(source_traders.trader_name) as [Trader Name],
				max(static_data_value1.code) as [Hedge Item Flag],
				max(static_data_value2.code) as  [Hedge Type],
				max(case when dh.header_buy_sell_flag=''s'' and dh.assignment_type_value_id is not null then 
					sdv.code else 	
				case when dh.header_buy_sell_flag=''s'' and dh.assignment_type_value_id is null then
					''Sold'' else ''Banked'' end
				end) as [Assignment Type],
				max(dh.legal_entity) as [Legal Entity],
				max(case when isnull(sdd.process_deal_status,0) = 12502 or isnull(sdd.process_deal_status,0) = 12500 then 1 else 999999  end ) process_deal_status 
				FROM       source_deal_header dh inner join source_deal_detail sdd on dh.source_deal_header_id=sdd.source_deal_header_id
					--and sdd.deal_volume_frequency=''m''
					and dh.term_frequency=''m''
					inner join source_deal_header_template sdht  on sdht.template_id= dh.template_id and isnull(sdht.rollover_to_spot,''n'')=''y''
					inner join source_deal_type sdt on sdt.source_deal_type_id=dh.source_deal_type_id
					inner join source_deal_type sdt1 on sdt1.source_deal_type_id=dh.deal_sub_type_type_id
				 LEFT OUTER JOIN source_system_book_map sbmp ON dh.source_system_book_id1 = sbmp.source_system_book_id1 AND 
					   dh.source_system_book_id2 = sbmp.source_system_book_id2 AND dh.source_system_book_id3 = sbmp.source_system_book_id3 AND 
					   dh.source_system_book_id4 = sbmp.source_system_book_id4 LEFT OUTER JOIN
					   source_counterparty ON dh.counterparty_id = source_counterparty.source_counterparty_id LEFT OUTER JOIN
					   source_traders ON dh.trader_id = source_traders.source_trader_id LEFT OUTER JOIN
					   source_book ON dh.source_system_book_id1 = source_book.source_book_id LEFT OUTER JOIN
					   source_book source_book_1 ON dh.source_system_book_id2 = source_book_1.source_book_id LEFT OUTER JOIN
					   source_book source_book_2 ON dh.source_system_book_id3 = source_book_2.source_book_id LEFT OUTER JOIN
					   source_book source_book_3 ON dh.source_system_book_id4 = source_book_3.source_book_id 
				LEFT OUTER JOIN  portfolio_hierarchy ON portfolio_hierarchy.entity_id = sbmp.fas_book_id
				LEFT OUTER JOIN fas_strategy ON fas_strategy.fas_strategy_id=portfolio_hierarchy.parent_entity_id
				LEFT OUTER JOIN static_data_value  static_data_value1 ON sbmp.fas_deal_type_value_id=static_data_value1.value_id
				LEFT OUTER JOIN static_data_value  static_data_value2 ON fas_strategy.hedge_type_value_id=static_data_value2.value_id
				LEFT OUTER JOIN
				   fas_link_detail fld ON fld.source_deal_header_id = dh.source_deal_header_id 
				left outer join static_data_value sdv on sdv.value_id=dh.assignment_type_value_id
				left outer join rec_generator rg on rg.generator_id=dh.generator_id
				left outer join gis_certificate gis on gis.source_deal_header_id=sdd.source_deal_detail_id	
				left join source_price_curve_def spcd on sdd.curve_id=spcd.source_curve_def_id 	
				   WHERE  dh.physical_financial_flag=''p''  and sdt1.deal_type_id='''+ @term_deal_type + '''
				'

		--IF ONE deal id is known make the other the same
		If @deal_id_to IS NULL AND @deal_id_from IS NOT NULL
			SET @deal_id_to = @deal_id_from

		If @deal_id_from IS NULL AND @deal_id_to IS NOT NULL
			SET @deal_id_from = @deal_id_to

		IF (@deal_id_from IS NOT NULL) AND (@deal_id_to IS NOT NULL) 
			SET @sql_Select = @sql_Select + ' AND dh.source_deal_header_id BETWEEN ' + CAST(@deal_id_from As varchar)  + ' AND ' + CAST(@deal_id_to AS varchar) 

		IF (@term_start IS NOT NULL)
				SET @sql_Select = @sql_Select+ ' AND convert(varchar(10),sdd.term_start,120)>='''+convert(varchar(10),@term_start,120)+''''

			IF (@term_end IS NOT NULL)
				SET @sql_Select = @sql_Select+ ' AND convert(varchar(10),sdd.term_end,120)<='''+convert(varchar(10),@term_end,120)+''''


		If @deal_id_from IS NULL and @deal_id_to is null --only apply deal filters if deal id not given.
		BEGIN
		
			If @book_deal_type_map_id IS NOT NULL 
				SET @sql_Select = @sql_Select + ' AND sbmp.book_deal_type_map_id in( ' + @book_deal_type_map_id + ')'

	
			IF (@counterparty IS NOT NULL)
				SET @sql_Select = @sql_Select +' AND dh.counterparty_id='+cast(@counterparty as varchar)

			IF (@commodity IS NOT NULL)
				SET @sql_Select = @sql_Select +' AND spcd.commodity_id='+cast(@commodity as varchar)

			
		END
	exec spa_print @sql_Select, ' group by dh.source_deal_header_id,dh.deal_id, dh.deal_date ) bb where bb.process_deal_status=999999'
	exec(@sql_Select +' group by dh.source_deal_header_id,dh.deal_id, dh.deal_date ) bb where bb.process_deal_status=999999')

End
else if @flag='p'
begin
	BEGIN try
		BEGIN tran
		DECLARE @new_id int,@new_term datetime,@deal_volume_div int,@leg int,@frequency int,@st varchar(1000),@new_id_r int
		declare @deal_vol_sum float,@deal_vol int, @deal_vol_adj float,@sport_curve int
	
		create table #tmp_deals (source_deal_header_id int,term_start datetime,term_end datetime,leg int)
		set @st='insert into #tmp_deals (source_deal_header_id,term_start,term_end,leg)
		select sdh.source_deal_header_id,sdd.term_start,sdd.term_end,sdd.leg
					FROM  source_deal_header sdh inner join source_deal_detail sdd on sdh.source_deal_header_id=sdd.source_deal_header_id
						and isnull(sdd.process_deal_status,0)<>12502 and year(term_start)='+cast(year(@current_month) as varchar)+' and month(term_start)=' +cast(month(@current_month) as varchar)+ ' 
						and sdd.deal_volume_frequency=''m'' where sdh.source_deal_header_id in (' + @process_deals + ')'
		exec spa_print @st	
		exec(@st)
		if not exists(select * from #tmp_deals)
			RAISERROR ('DataNotFound', 16, 1 )
		create table #tmp_Offset_deal (header_deal_id int,new_id int,o_r varchar(1) COLLATE DATABASE_DEFAULT)
		declare @spot_deal_type_id int
		select @spot_deal_type_id=source_deal_type_id from source_deal_type where deal_type_id=@spot_deal_type
--			select * from #tmp_deals
--			order by source_deal_header_id,term_start,term_end,leg

		DECLARE b_cursor CURSOR FOR
			select * from #tmp_deals
			order by source_deal_header_id,term_start,term_end,leg

		OPEN b_cursor
		FETCH NEXT FROM b_cursor
		INTO @deal_id_from,@term_start,@term_end,@leg
		WHILE @@FETCH_STATUS = 0   
		BEGIN 
			------------------------Offset-----------------------------------------
			set @new_id=null
			select @new_id = new_id from #tmp_Offset_deal where  header_deal_id=@deal_id_from and o_r='o'
 			if @new_id is null
			begin

				INSERT INTO [dbo].[source_deal_header]
						   ([source_system_id]
						   ,[deal_id]
						   ,[deal_date]
						   ,[ext_deal_id]
						   ,[physical_financial_flag]
						   ,[structured_deal_id]
						   ,[counterparty_id]
						   ,[entire_term_start]
						   ,[entire_term_end]
						   ,[source_deal_type_id]
						   ,[deal_sub_type_type_id]
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
						   ,[internal_deal_type_value_id]
						   ,[internal_deal_subtype_value_id]
						   ,[template_id]
						   ,[header_buy_sell_flag]
						   ,[broker_id]
						   ,[generator_id]
						   ,[status_value_id]
						   ,[status_date]
						   ,[assignment_type_value_id]
						   ,[compliance_year]
						   ,[state_value_id]
						   ,[assigned_date]
						   ,[assigned_by]
						   ,[generation_source]
						   ,[aggregate_environment]
						   ,[aggregate_envrionment_comment]
						   ,[rec_price]
						   ,[rec_formula_id]
						   ,[rolling_avg]
						   ,[contract_id]
						   ,[create_user]
						   ,[create_ts]
						   ,[update_user]
						   ,[update_ts]
						   ,[legal_entity]
						   ,[internal_desk_id]
						   ,[product_id]
						   ,[internal_portfolio_id]
						   ,[commodity_id]
						   ,[reference]
						   ,[deal_locked]
						   ,[close_reference_id]
						   ,[block_type]
						   ,[block_define_id]
						   ,[granularity_id]
							,Pricing,deal_reference_type_id)
				SELECT
							[source_system_id]
						   ,cast([source_deal_header_id] as varchar)+'_OSet_' + replace(convert(varchar(7),@term_start,20),'-','')
						   ,[deal_date]
						   ,[deal_id]
						   ,[physical_financial_flag]
						   ,[structured_deal_id]
						   ,[counterparty_id]
						   ,@term_start,@term_end
						   ,[source_deal_type_id]
						   ,[deal_sub_type_type_id]
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
						   ,[trader_id] --
						   ,[internal_deal_type_value_id]
						   ,[internal_deal_subtype_value_id]
						   ,[template_id]
						   ,case WHEN [header_buy_sell_flag]='b' THEN 's' ELSE 'b' end --
						   ,[broker_id]
						   ,[generator_id]
						   ,[status_value_id]
						   ,[status_date]
						   ,[assignment_type_value_id]
						   ,[compliance_year]
						   ,[state_value_id]
						   ,[assigned_date]
						   ,[assigned_by]
						   ,[generation_source]
						   ,[aggregate_environment]
						   ,[aggregate_envrionment_comment]
						   ,[rec_price]
						   ,[rec_formula_id]
						   ,[rolling_avg]
						   ,[contract_id]
						   ,dbo.FNADBUser()
						   ,getdate()
						   ,dbo.FNADBUser()
						   ,getdate()
						   ,[legal_entity]
						   ,[internal_desk_id]
						   ,[product_id]
						   ,[internal_portfolio_id]
						   ,[commodity_id]
						   ,[reference]
						   ,[deal_locked]
						   ,[source_deal_header_id]
						   ,[block_type]
						   ,[block_define_id]
						   ,[granularity_id]
							,Pricing,12502
				from [dbo].[source_deal_header]
				WHERE [source_deal_header_id]=@deal_id_from
				SET @new_id = scope_identity() 
				EXEC spa_compliance_workflow 109,'i',@new_id,'Deal',null

				insert into #tmp_Offset_deal (header_deal_id,new_id,o_r) values ( @deal_id_from,@new_id,'o')
			end
			INSERT INTO [dbo].[source_deal_detail]
					   ([source_deal_header_id]
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
					   ,[volume_left]
					   ,[settlement_volume]
					   ,[settlement_uom]
					   ,[create_user]
					   ,[create_ts]
					   ,[update_user]
					   ,[update_ts]
					   ,[price_adder]
					   ,[price_multiplier]
					   ,[settlement_date]
					   ,[day_count_id]
					   ,[location_id],[meter_id]
						,physical_financial_flag
						,Booked,process_deal_status)
			SELECT
						@new_id
					   ,[term_start]
					   ,[term_end]
					   ,[Leg]
					   ,[contract_expiration_date]
					   ,[fixed_float_leg]
						,case WHEN [buy_sell_flag]='b' THEN 's' ELSE 'b' end
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
					   ,[volume_left]
					   ,[settlement_volume]
					   ,[settlement_uom]
					   ,dbo.FNADBUser()
					   ,getdate()
					   ,dbo.FNADBUser()
					   ,getdate()
					   ,[price_adder]
					   ,[price_multiplier]
					   ,[settlement_date]
					   ,[day_count_id]
					   ,[location_id],[meter_id],physical_financial_flag
						,Booked,12500 --offset
			FROM [dbo].[source_deal_detail]
			WHERE [source_deal_header_id]=@deal_id_from and term_start=@term_start and term_end=@term_end and leg=@leg


			------------------Rollover------------------------------
			set @new_id_r=null
			select @new_id_r = new_id from #tmp_Offset_deal where  header_deal_id=@deal_id_from and o_r='r'
 			if @new_id_r is null
			begin
				--print 'Rollover' + cast(@leg as varchar)
				INSERT INTO [dbo].[source_deal_header]
						   ([source_system_id]
						   ,[deal_id]
						   ,[deal_date]
						   ,[ext_deal_id]
						   ,[physical_financial_flag]
						   ,[structured_deal_id]
						   ,[counterparty_id]
						   ,[entire_term_start]
						   ,[entire_term_end]
						   ,[source_deal_type_id]
						   ,[deal_sub_type_type_id]
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
						   ,[internal_deal_type_value_id]
						   ,[internal_deal_subtype_value_id]
						   ,[template_id]
						   ,[header_buy_sell_flag]
						   ,[broker_id]
						   ,[generator_id]
						   ,[status_value_id]
						   ,[status_date]
						   ,[assignment_type_value_id]
						   ,[compliance_year]
						   ,[state_value_id]
						   ,[assigned_date]
						   ,[assigned_by]
						   ,[generation_source]
						   ,[aggregate_environment]
						   ,[aggregate_envrionment_comment]
						   ,[rec_price]
						   ,[rec_formula_id]
						   ,[rolling_avg]
						   ,[contract_id]
						   ,[create_user]
						   ,[create_ts]
						   ,[update_user]
						   ,[update_ts]
						   ,[legal_entity]
						   ,[internal_desk_id]
						   ,[product_id]
						   ,[internal_portfolio_id]
						   ,[commodity_id]
						   ,[reference]
						   ,[deal_locked]
						   ,[close_reference_id]
						   ,[block_type]
						   ,[block_define_id]
						   ,[granularity_id]
							,Pricing,deal_reference_type_id,term_frequency
					)
				SELECT		
							[source_system_id]
						   ,cast([source_deal_header_id] as varchar)+'_ROver_'+cast(@leg as varchar)+ '_' + replace(convert(varchar(7),@term_start,20),'-','')
						   ,[deal_date]
						   ,[deal_id]
						   ,[physical_financial_flag]
						   ,[structured_deal_id]
						   ,[counterparty_id]
						   ,@term_start
						   ,@term_end
						   ,[source_deal_type_id]
						   ,@spot_deal_type_id
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
						   ,[internal_deal_type_value_id]
						   ,[internal_deal_subtype_value_id]
						   ,[template_id]
						   ,[header_buy_sell_flag] 
						   ,[broker_id]
						   ,[generator_id]
						   ,[status_value_id]
						   ,[status_date]
						   ,[assignment_type_value_id]
						   ,[compliance_year]
						   ,[state_value_id]
						   ,[assigned_date]
						   ,[assigned_by]
						   ,[generation_source]
						   ,[aggregate_environment]
						   ,[aggregate_envrionment_comment]
						   ,[rec_price]
						   ,[rec_formula_id]
						   ,[rolling_avg]
						   ,[contract_id]
						   ,dbo.FNADBUser()
						   ,getdate()
						   ,dbo.FNADBUser()
						   ,getdate()
						   ,[legal_entity]
						   ,[internal_desk_id]
						   ,[product_id]
						   ,[internal_portfolio_id]
						   ,[commodity_id]
						   ,[reference]
						   ,[deal_locked]
						   ,[source_deal_header_id]
						   ,[block_type]
						   ,[block_define_id]
						   ,[granularity_id]
							,Pricing,12502,'d'
				from dbo.[source_deal_header]
				WHERE [source_deal_header_id]=@deal_id_from

				SET @new_id_r = scope_identity() 
				insert into #tmp_Offset_deal (header_deal_id,new_id,o_r) values ( @deal_id_from,@new_id_r,'r')
				EXEC spa_compliance_workflow 109,'i',@new_id,'Deal',null

			end
			select @frequency=datediff(day,@term_start,@term_end)

			set @frequency=@frequency+1
			set @deal_volume_div=@frequency
			select @deal_vol_sum = isnull(deal_volume,0) FROM [dbo].[source_deal_detail]
				WHERE [source_deal_header_id]=@deal_id_from and term_start=@term_start and term_end=@term_end and leg=@leg


			select @sport_curve=isnull(loc.pricing_index,sdd.curve_id) from source_deal_detail sdd inner join source_minor_location loc on sdd.location_id=loc.source_minor_location_id
				WHERE sdd.[source_deal_header_id]=@deal_id_from and sdd.term_start=@term_start and sdd.term_end=@term_end and sdd.leg=@leg



			set @deal_vol=round(@deal_vol_sum/@frequency,0)
			set @deal_vol_adj=@deal_vol_sum-(@deal_vol*(@frequency-1))
			set @new_term=@term_start

			while @frequency>0
			Begin
				INSERT INTO [dbo].[source_deal_detail]
						   ([source_deal_header_id]
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
						   ,[volume_left]
						   ,[settlement_volume]
						   ,[settlement_uom]
						   ,[create_user]
						   ,[create_ts]
						   ,[update_user]
						   ,[update_ts]
						   ,[price_adder]
						   ,[price_multiplier]
						   ,[settlement_date]
						   ,[day_count_id]
							,[location_id],[meter_id],physical_financial_flag,Booked,process_deal_status)
				SELECT
							@new_id_r
						   ,@new_term
						   ,@new_term
						   ,@leg
						   ,@new_term
						   ,[fixed_float_leg]
							,[buy_sell_flag]
						   ,isnull(@sport_curve,[curve_id])
						   ,[fixed_price]
						   ,[fixed_price_currency_id]
						   ,[option_strike_price]
						   ,@deal_vol
						   ,'d'
						   ,[deal_volume_uom_id]
						   ,[block_description]
						   ,[deal_detail_description]
						   ,[formula_id]
						   ,@deal_vol
						   ,[settlement_volume]
						   ,[settlement_uom]
						   ,dbo.FNADBUser()
						   ,getdate()
						   ,dbo.FNADBUser()
						   ,getdate()
						   ,[price_adder]
						   ,[price_multiplier]
						   ,[settlement_date]
						   ,[day_count_id]
						   ,[location_id],[meter_id],physical_financial_flag,Booked,12502
				FROM [dbo].[source_deal_detail]
				WHERE [source_deal_header_id]=@deal_id_from and term_start=@term_start and term_end=@term_end and leg=@leg
					EXEC spa_print 'Term_Start:', @new_term 
					EXEC spa_print	'Frequency:', @frequency
						
				set @new_term=dateadd(day,1,@new_term)
				set @frequency=@frequency-1
				if @frequency=1
					set @deal_vol =@deal_vol_adj
			End
			update source_deal_detail set process_deal_status=12502 where   source_deal_header_id=@deal_id_from and term_start=@term_start and term_end=@term_end and leg=@leg
			--print 'update'
		FETCH NEXT FROM b_cursor INTO @deal_id_from,@term_start,@term_end,@leg
	end
	CLOSE b_cursor
	DEALLOCATE  b_cursor
	EXEC spa_print 'end cursor'

	commit tran
	Exec spa_ErrorHandler 0, 'Deal Rollover', 
				'spa_rollover_forward2spot', 'Success', 
				'The process is successfully completed.', ''
	end try
	begin catch
		DECLARE @err varchar(1000),@err_no int
		if @@TRANCOUNT >0
		rollback tran
		set @err_no=-1
		if ERROR_message()='DataNotFound'
			SET @err='The selected deal has already been rollovered/term does not match with as of date.'
		else if ERROR_NUMBER()=2627
			SET @err='The Deal had already rollovered.'
		ELSE
		BEGIN
			select  @err=ERROR_MESSAGE()
			SELECT @err_no=error_number()
		END
		Exec spa_ErrorHandler @err_no, 'Deal rollover', 
					'spa_rollover_forward2spot', 'DB Error', 
					@err, ''

	end catch
end
