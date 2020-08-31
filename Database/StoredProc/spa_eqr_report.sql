IF OBJECT_ID(N'spa_eqr_report', N'P') IS NOT NULL
DROP PROC [dbo].[spa_eqr_report]
GO
set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

CREATE procedure [dbo].[spa_eqr_report]
		@sub_entity_id varchar(100) ,
		@strategy_entity_id varchar(100),
		@book_entity_id varchar(100),
		@as_of_date varchar(100),
		@counterparty_id int,
		@technology int,
		@summary_option char(1)='t', -- 't' transaction 'c' detail,
	--	@show_estimate_report char(1)='n',
		@settlement_accountant varchar(100)=null,
		@prod_date_From varchar(100)=null,
		@prod_date_To varchar(100)=null
	AS
	SET NOCOUNT ON 
	BEGIN

	 DECLARE @Sql_Select varchar(MAX)
	 DECLARE @sql_Where varchar(8000)
	 DECLARE @energy_line_item_id int
	 DECLARE @transmissions_line_item varchar(100)
	
	set @transmissions_line_item='295428,295445,295494,295485,295495,295399' 	
	set @energy_line_item_id=295352
	--******************************************************            
	--CREATE source book map table and build index            
	--*********************************************************            
	           
	CREATE TABLE #ssbm(            
	 source_system_book_id1 int,            
	 source_system_book_id2 int,            
	 source_system_book_id3 int,            
	 source_system_book_id4 int,            
	 fas_deal_type_value_id int,            
	 book_deal_type_map_id int,            
	 fas_book_id int,            
	 stra_book_id int,            
	 sub_entity_id int            
	)            
	----------------------------------     
	SET @Sql_Where=''       
	SET @Sql_Select=            
		'INSERT INTO #ssbm            
			SELECT            
			 source_system_book_id1,source_system_book_id2,source_system_book_id3,source_system_book_id4,fas_deal_type_value_id,            
			 book_deal_type_map_id,book.entity_id fas_book_id,book.parent_entity_id stra_book_id, stra.parent_entity_id sub_entity_id             
			FROM            
			 source_system_book_map ssbm             
			INNER JOIN            
			 portfolio_hierarchy book (nolock)             
			ON             
			 ssbm.fas_book_id = book.entity_id             
			INNER JOIN            
			 Portfolio_hierarchy stra (nolock)            
			 ON            
			 book.parent_entity_id = stra.entity_id             
		            
		WHERE 1=1 '            
		IF @sub_entity_id IS NOT NULL            
		  SET @Sql_Where = @Sql_Where + ' AND stra.parent_entity_id IN  ( ' + @sub_entity_id + ') '             
		 IF @strategy_entity_id IS NOT NULL            
		  SET @Sql_Where = @Sql_Where + ' AND (stra.entity_id IN(' + @strategy_entity_id + ' ))'            
		 IF @book_entity_id IS NOT NULL            
		  SET @Sql_Where = @Sql_Where + ' AND (book.entity_id IN(' + @book_entity_id + ')) '            
		SET @Sql_Select=@Sql_Select+@Sql_Where       

	EXEC (@Sql_Select)            
	--------------------------------------------------------------            
	CREATE  INDEX [IX_PH1] ON [#ssbm]([source_system_book_id1])                  
	CREATE  INDEX [IX_PH2] ON [#ssbm]([source_system_book_id2])                  
	CREATE  INDEX [IX_PH3] ON [#ssbm]([source_system_book_id3])                  
	CREATE  INDEX [IX_PH4] ON [#ssbm]([source_system_book_id4])                  
	CREATE  INDEX [IX_PH5] ON [#ssbm]([fas_deal_type_value_id])                  
	CREATE  INDEX [IX_PH6] ON [#ssbm]([fas_book_id])                  
	CREATE  INDEX [IX_PH7] ON [#ssbm]([stra_book_id])                  
	CREATE  INDEX [IX_PH8] ON [#ssbm]([sub_entity_id])                  
	-- select * from #ssbm
--return           
	--******************************************************            
	--End of source book map table and build index            
	--*********************************************************   
-- calc formula value

declare @convert_uom_id int
declare @convert_uom_id_2 int
set @convert_uom_id=24
set @convert_uom_id_2=33

	 create table #calc_formula_value 
			(
				invoice_line_item_id int,
				formula_id int,
				prod_date datetime,
				volume float,
				price float,
				uom_id int,
				as_of_date datetime,
				transmission_charge float,
				contract_id int,counterparty_id int
			)


			set @Sql_Select ='
			insert into #calc_formula_value
			select
					a.invoice_line_item_id,a.formula_id,
					cast(CAST(Year(a.prod_date) As Varchar)+''-''+ CAST(month(a.prod_date) As Varchar) +''-01'' as datetime) as prod_date,
					sum(case when show_value_id=1200 then (a.value) else NULL end) as volume,
					sum(case when show_value_id=1201 then (a.value) else NULL end) as Price,
					(b.uom_id) as uom_id,
					a.as_of_date,
					NULL,a.contract_id,a.counterparty_id
					
				from
					calc_invoice_summary a
					left join formula_nested b on
					a.formula_id=b.formula_group_id
					and a.seq_number=b.sequence_order
					left join rec_generator rg on rg.ppa_counterparty_id=a.counterparty_id
				where 1=1
						and rg.legal_entity_value_id in('+@sub_entity_id+')
						and a.as_of_date<='''+cast(@as_of_date as varchar)+''''+
						case when @counterparty_id is not null then ' And a.counterparty_id='+cast(@counterparty_id as varchar) else '' end+
				' group by 
					a.invoice_line_item_id,a.formula_id,cast(CAST(Year(a.prod_date) As Varchar)+''-''+ CAST(month(a.prod_date) As Varchar) +''-01'' as datetime),
					a.as_of_date,b.uom_id,b.rate_id,a.contract_id,a.counterparty_id '
			
		--	EXEC spa_print @Sql_Select	
			exec(@Sql_Select)
---------------

set @Sql_Select=
'update 
	a
set a.transmission_Charge=b.[value]

	from
		#calc_formula_value a
		inner join calc_invoice_volume_variance c 
		on a.prod_date=c.prod_date
		and a.counterparty_id=c.counterparty_id
		and a.contract_id=c.contract_id and a.as_of_date=c.as_of_date
		left join  calc_invoice_volume	b 
		on b.calc_id=c.calc_id and b.invoice_line_item_id in('+@transmissions_line_item+')'	


	exec(@Sql_Select)
	set @Sql_Where=''

	if @as_of_date is not null    
		set @Sql_Where=' and  CIVV.[as_of_date]<='''+@as_of_date+''''
	if @counterparty_id is not null    
		set @Sql_Where=@Sql_Where+' and  sc.[source_counterparty_id]='+ cast(@counterparty_id as varchar)
	if @technology is not null    
		set @Sql_Where=@Sql_Where+' and  rg.[technology]='+cast(@technology as varchar)
	if @settlement_accountant is not null    
		set @Sql_Where=@Sql_Where+' and  cg.[settlement_accountant]='''+@settlement_accountant+''''
	if @prod_date_from is not null and @prod_date_To is not null   
		set @Sql_Where=@Sql_Where+' and  civv.prod_date between '''+@prod_date_From+''' and '''+@prod_date_To+''''



if @summary_option='t'
	set @Sql_Select='
		SELECT  distinct 
				''T''+replicate(''0'',2-len(cast(datepart(mm,CIVV.[prod_date]) as varchar)))+cast(datepart(mm,CIVV.[prod_date]) as varchar)+right(cast(datepart(yy,CIVV.[prod_date]) as varchar),2)+cast(sc.[source_counterparty_id] as varchar) TranID,
				replace(fs.entity_name,''Xcel Energy <br>'','''') [SellerCompanyName],
				sc.[counterparty_name] CustomerCompanyName,
				sc.[customer_duns_number] [CustomerDunsNumber],
				cg.[ferct_tarrif_reference] [FerctTarrifReference],
				cg.[contract_service_agreement_id] [ContractServiceAgreementID],
				pf.entity_name+''-'' +replicate(''0'',2-len(cast(datepart(mm,CIVV.[prod_date]) as varchar)))+cast(datepart(mm,CIVV.[prod_date]) as varchar)+right(cast(datepart(yy,CIVV.[prod_date]) as varchar),2)+cast(sc.[source_counterparty_id] as varchar) TranID1,
				cast(year(CIVV.[prod_date]) as varchar)+RIGHT(''00''+cast(Month(CIVV.[prod_date]) as varchar),2)+''010000'' TransactionBeginDate,
				cast(year(CIVV.[prod_date]) as varchar)+RIGHT(''00''+cast(Month(CIVV.[prod_date]) as varchar),2)+RIGHT(''00''+cast(day(dbo.FNADateFormat(dateadd(d,-1,dateadd(m,1,CIVV.[prod_date])))) as varchar),2)+''2359'' TransactionEndDate,
				sdv2.code [TimeZone],
				sd_control.code [PointOfDeliveryControlArea],
				cg.[point_of_delivery_specific_location] [PointOfDeliverySpecificLocation],
				sdv3.[code] [ClassName],
				sd_term.code [TermName],
				inc_value.code as [IncrementName],
				sd_peaking.code [IncrementPeakingName],
				sdv4.code [Product Name],
				case when civ.price_or_formula=''p'' then 1 
					 else round(case when cfv.volume is not null then cfv.volume 
									 else civ.[Volume]	 
									 end,0)*ISNULL(Conv1.conversion_factor,1)
					 end TransactionQuantity,
				case when civ.price_or_formula=''p'' then civ.value 
					 else round(case when cfv.price is not null then cfv.price 
									 else (civ.[value]/case when cfv.volume is not null then 
																 case when cfv.volume=0 then 1 
																	  else cfv.volume 
																 end 
															else case when civ.Volume=0 then 1 
																	  else civ.[Volume] end 
															end ) 
									end,5)*ISNULL(Conv1.conversion_factor,1)
					end Price,
				case when civ.price_or_formula=''p'' then ''FLAT RATE'' else  
						su1.uom_name end Units,
				case when cgd.invoice_line_item_id='+cast(@energy_line_item_id as varchar)+' then isnull(cfv.transmission_charge,0)
					 else '''' 
					 end [TotalTransmissionCharge],
--				round(civ.value,2)+case when cgd.invoice_line_item_id='+cast(@energy_line_item_id as varchar)+' then isnull(cfv.transmission_charge,0) 
--								   else 0 end TransactionCharge
				(case when civ.price_or_formula=''p'' then 1 
					 else round(case when cfv.volume is not null then cfv.volume 
									 else civ.[Volume]	 
									 end,0)*ISNULL(Conv1.conversion_factor,1)
					 end*
				case when civ.price_or_formula=''p'' then civ.value 
					 else round(case when cfv.price is not null then cfv.price 
									 else (civ.[value]/case when cfv.volume is not null then 
																 case when cfv.volume=0 then 1 
																	  else cfv.volume 
																 end 
															else case when civ.Volume=0 then 1 
																	  else civ.[Volume] end 
															end ) 
									end,5)*ISNULL(Conv1.conversion_factor,1)
					end)+
				case when cgd.invoice_line_item_id='+cast(@energy_line_item_id as varchar)+' then isnull(cfv.transmission_charge,0)
					 else 0
					 end as TransactionCharge
			FROM 
				[rec_generator] rg inner join [source_counterparty] sc on rg.[ppa_counterparty_id]=sc.[source_counterparty_id]
				inner join [contract_group] cg on cg.[contract_id]=rg.ppa_contract_id
				left join [contract_group_detail] cgd on cg.[contract_id]=cgd.contract_id
				inner join calc_invoice_volume_variance civv on rg.ppa_counterparty_id=civv.counterparty_id
				and cg.contract_id=civv.contract_id and rg.generator_id=civv.generator_id 
				inner JOIN
					(select max(as_of_date) as_of_date,counterparty_id,prod_date,contract_id from calc_invoice_volume_variance 
					group by counterparty_id,prod_date,contract_id) a
 					on a.as_of_date=civv.as_Of_date and  a.counterparty_id=civv.counterparty_id 
					and a.contract_id=civv.contract_id and a.prod_date=civv.prod_date 
				left join calc_invoice_volume civ on CIVV.[calc_id]=civ.[calc_id]
				and civ.invoice_line_item_id=cgd.invoice_line_item_id
				left join fas_subsidiaries fs on cg.[sub_id]=fs.fas_subsidiary_id 
				left join portfolio_hierarchy pf on fs.fas_subsidiary_id=pf.entity_id
				inner join (select distinct sub_entity_id from #ssbm) ssbm on ssbm.sub_entity_id=cg.[sub_id]
				left join static_data_value sdv1 on civ.[invoice_line_item_id]=sdv1.value_id and sdv1.type_id=10019
				left join static_data_value sdv2 on cg.[time_zone]=sdv2.value_id
				left join formula_nested fe on fe.formula_group_id=cgd.formula_id
				left join #calc_formula_value cfv on cfv.formula_id=fe.formula_group_id
				and dbo.fnagetcontractmonth(cfv.prod_date)=	dbo.FNAGetContractMonth(civv.prod_date)
				and cfv.as_of_date=civv.as_of_date and (cfv.volume is not null)
				left join #calc_formula_value cfv1 on cfv1.formula_id=fe.formula_group_id
				and dbo.fnagetcontractmonth(cfv1.prod_date)=dbo.FNAGetContractMonth(civv.prod_date)
				and cfv1.as_of_date=civv.as_of_date and (cfv1.price is not null)
				left join source_uom su on su.source_uom_id=isnull(cfv.uom_id,cg.[volume_uom])
				left join source_currency scur on scur.source_currency_id=cg.[currency] 
				left join static_data_value sdv3 on sdv3.value_id = cgd.class_name
				left join static_data_value sdv4 on sdv4.value_id = cgd.eqr_product_name and sdv4.type_id = 10077
				left join static_data_value sd_term on sd_term.value_id=cg.Term_name
				left join static_data_value sd_peaking on sd_peaking.value_id=cgd.increment_peaking_name
				left join static_data_value inc_value on inc_value.value_id=cg.increment_name
				left join static_data_value sd_control on cg.[point_of_delivery_control_area]=sd_control.value_id
				LEFT OUTER JOIN rec_volume_unit_conversion Conv1 ON            
					 Conv1.from_source_uom_id  = isnull(cfv.uom_id,cg.[volume_uom])
					 AND Conv1.to_source_uom_id = cgd.units_for_rate       
					 And Conv1.state_value_id is null
					 AND conv1.assignment_type_value_id is null
					 AND conv1.curve_id is null
--				LEFT OUTER JOIN rec_volume_unit_conversion Conv2 ON            
--					 Conv2.from_source_uom_id  = isnull(cfv.uom_id,cg.[volume_uom])
--					 AND Conv2.to_source_uom_id = '+cast(@convert_uom_id_2 as varchar)+'         
--					 And Conv2.state_value_id is null
--					 AND Conv2.assignment_type_value_id is null
--					 AND Conv2.curve_id is null
				left join source_uom su1 on su1.source_uom_id=COALESCE(Conv1.to_source_uom_id,cfv.uom_id,cg.[volume_uom])
--				left join source_uom su2 on su2.source_uom_id=Conv2.to_source_uom_id
				where 1=1 and  cgd.eqr_product_name is not null and civ.invoice_line_item_id not in('+@transmissions_line_item+')'
				+@Sql_Where+
			' Order by replace(fs.entity_name,''Xcel Energy <br>'',''''),sc.[counterparty_name] '

ELSE IF @summary_option='c'
	set @Sql_Select='
			SELECT  DISTINCT 
				cg.UD_Contract_id [ContractID],
				replace(fs.entity_name,''Xcel Energy <br>'','''') SellerCompanyName,
				sc.[counterparty_name] CustomerCompanyName,
				sc.[customer_duns_number] [CustomerDunsNumber],
				cg.contract_affiliate ContractAffiliate,
				cg.[ferct_tarrif_reference] [FerctTarrifReference],
				cg.[contract_service_agreement_id] [ContractServiceAgreementID],
				dbo.FNADateFormat(cg.term_start) ContractExecutionDate,
				dbo.FNADateFormat(cg.contract_date) ContractCommencementDate,
				dbo.FNADateFormat(cg.term_end) ContractTerminationDate,
				dbo.FNADateFormat(cg.term_end) ActualTerminationDate,
				cg.extension_provision_description ExtensionProvisionDescription,
				sdv3.code ClassName,
				sdv6.code TermName,
				sdv7.code IncrementName,
				sdv4.code IncrementPeakingName,
				sdv5.code ProductTypeName,
				sdv8.code [Product Name],
				round(case when cfv.volume is not null then cfv.volume else civ.[Volume] end,0) Quantity,
				case when civ.price_or_formula=''p'' then ''Flat Rate'' else su.uom_id end UnitsForContract,
				round(case when cfv.price is not null then cfv.price else (civ.[value]/ case when civ.Volume=0 then 1 else case when cfv.volume is not null then cfv.volume else civ.[Volume] end end ) end,5) Rate,
				''rate_minimum'' [Rate Minimum],
				''rate_maximum'' [Rate Maximum],
				cgd.rate_description RateDescription,
				case when civ.price_or_formula=''p'' then ''Flat Rate'' else scur.currency_id+''/''+su.uom_id end UnitsForRate,
				cg.point_of_receipt_control_area PointOfReceiptControlArea,
				cg.point_of_receipt_specific_location PointOfReceiptSpecificLocation,
				cg.[point_of_delivery_control_area] [PointOfDeliveryControlArea],
				cg.[point_of_delivery_specific_location] [PointOfDeliverySpecificLocation],
				cgd.begin_date BeginDate,
				cgd.end_date EndDate,
				sdv2.code [TimeZone]
			FROM 
				[rec_generator] rg inner join [source_counterparty] sc on rg.[ppa_counterparty_id]=sc.[source_counterparty_id]
				inner join [contract_group] cg on cg.[contract_id]=rg.ppa_contract_id
				left join [contract_group_detail] cgd on cg.[contract_id]=cgd.contract_id
				inner join calc_invoice_volume_variance civv on rg.ppa_counterparty_id=civv.counterparty_id
				and cg.contract_id=civv.contract_id and rg.generator_id=civv.generator_id 
				inner JOIN
					(select max(as_of_date) as_of_date,counterparty_id,prod_date,contract_id from calc_invoice_volume_variance 
					group by counterparty_id,prod_date,contract_id) a
 					on a.as_of_date=civv.as_Of_date and  a.counterparty_id=civv.counterparty_id 
					and a.contract_id=civv.contract_id and a.prod_date=civv.prod_date 
				left join calc_invoice_volume civ on CIVV.[calc_id]=civ.[calc_id]
				and civ.invoice_line_item_id=cgd.invoice_line_item_id
				left join fas_subsidiaries fs on cg.[sub_id]=fs.fas_subsidiary_id 
				left join portfolio_hierarchy pf on fs.fas_subsidiary_id=pf.entity_id
				inner join (select distinct sub_entity_id from #ssbm) ssbm on ssbm.sub_entity_id=cg.[sub_id]
				left join static_data_value sdv1 on civ.[invoice_line_item_id]=sdv1.value_id and sdv1.type_id=10019
				left join static_data_value sdv2 on cg.[time_zone]=sdv2.value_id
				left join formula_nested fe on fe.formula_group_id=cgd.formula_id
				left join #calc_formula_value cfv on cfv.formula_id=fe.formula_group_id
				and dbo.fnagetcontractmonth(cfv.prod_date)=	dbo.FNAGetContractMonth(civv.prod_date)
				and cfv.as_of_date=civv.as_of_date and (cfv.volume is not null)
				left join #calc_formula_value cfv1 on cfv1.formula_id=fe.formula_group_id
				and dbo.fnagetcontractmonth(cfv1.prod_date)=dbo.FNAGetContractMonth(civv.prod_date)
				and cfv1.as_of_date=civv.as_of_date and (cfv1.price is not null)
				left join source_uom su on su.source_uom_id=isnull(cfv.uom_id,cg.[volume_uom])
				left join source_currency scur on scur.source_currency_id=cg.[currency] 
				left join static_data_value sdv3 on sdv3.value_id = cgd.class_name
				left join static_data_value sdv4 on sdv4.value_id = cgd.increment_peaking_name
				left join static_data_value sdv5 on sdv5.value_id = cgd.product_type_name
				left join static_data_value sdv6 on sdv6.value_id = cg.term_name
				left join static_data_value sdv7 on sdv7.value_id = cg.increment_name
				left join static_data_value sdv8 on sdv8.value_id = cgd.eqr_product_name and sdv8.type_id = 10077
			where 1=1'
				+@Sql_Where+
				' Order by replace(fs.entity_name,''Xcel Energy <br>'',''''),sc.[counterparty_name] '
	exec(@Sql_Select)
end



























