
/****** Object:  StoredProcedure [dbo].[spa_wind_pur_power_report]    Script Date: 11/30/2010 15:47:35 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_wind_pur_power_report]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_wind_pur_power_report]
/****** Object:  StoredProcedure [dbo].[spa_wind_pur_power_report]    Script Date: 11/30/2010 15:47:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[spa_wind_pur_power_report]
	@subsidiary_id VARCHAR(MAX) ,
	@strategy_id VARCHAR(MAX),
	@book_id VARCHAR(MAX),
	@as_of_date VARCHAR(100) = NULL,
	@counterparty_id INT = NULL,
	@technology INT = NULL,
	@settlement_accounts VARCHAR(100) = NULL,
	@show_estimated_report CHAR(1) = NULL,	
	@options CHAR(1) = NULL
	
	AS
SET NOCOUNT ON

	BEGIN

	------ To Test
	-- DECLARE @as_of_date varchar(100)
	-- DECLARE @technology int
	-- DECLARE @counterparty_id int
	-- DECLARE @generator_id int
	-- DECLARE @subsidiary_id varchar(100)             		
	-- DECLARE @strategy_id varchar(100)
	-- DECLARE @book_id varchar(100)

	-- SET @subsidiary_id='135,136'
	-- SET @as_of_date='2006-08-07'
	-- DROP TABLE #ssbm
	-- DROP TABLE #temp
	 DECLARE @Sql_Select varchar(8000)
	 DECLARE @sql_Where varchar(8000)
	 DECLARE @gl_account_group_code int
	 set @gl_account_group_code=10004
	--******************************************************            
	--CREATE source book map table and build index            
	--*********************************************************            
	           
	CREATE TABLE #ssbm(            
	 fas_book_id int,            
	 stra_book_id int,            
	 sub_entity_id int            
	)            
	----------------------------------     
	SET @Sql_Where=''       
	SET @Sql_Select=            
	'INSERT INTO #ssbm            
	SELECT            
		book.entity_id fas_book_id,book.parent_entity_id stra_book_id, stra.parent_entity_id sub_entity_id             
	FROM            
	 portfolio_hierarchy book (nolock)             
	INNER JOIN            
	 Portfolio_hierarchy stra (nolock)            
	 ON            
	  book.parent_entity_id = stra.entity_id             
	            
	WHERE 1=1 '            
	IF @subsidiary_id IS NOT NULL            
	  SET @Sql_Where = @Sql_Where + ' AND stra.parent_entity_id IN  ( ' + @subsidiary_id + ') '             
	 IF @strategy_id IS NOT NULL            
	  SET @Sql_Where = @Sql_Where + ' AND (stra.entity_id IN(' + @strategy_id + ' ))'            
	 IF @book_id IS NOT NULL            
	  SET @Sql_Where = @Sql_Where + ' AND (book.entity_id IN(' + @book_id + ')) '            
	SET @Sql_Select=@Sql_Select+@Sql_Where       

	EXEC (@Sql_Select)            
	--------------------------------------------------------------            
	CREATE  INDEX [IX_PH6] ON [#ssbm]([fas_book_id])                  
	CREATE  INDEX [IX_PH7] ON [#ssbm]([stra_book_id])                  
	CREATE  INDEX [IX_PH8] ON [#ssbm]([sub_entity_id])                  
	            
	--******************************************************            
	--End of source book map table and build index            
	--*********************************************************       
				 create table #calc_formula_value 
			(
				invoice_line_item_id int,
				formula_id int,
				prod_date datetime,
				volume float,
				uom_id int,
				as_of_date datetime,
				include_item char(1) COLLATE DATABASE_DEFAULT
			)
			set @Sql_Select ='
			insert into #calc_formula_value
			 select
				invoice_line_item_id,a.formula_id,
				cast(CAST(Year(a.prod_date) As Varchar)+''-''+ CAST(month(a.prod_date) As Varchar) +''-01'' as datetime) as prod_date,
				sum(case when show_value_id=1200 then (value) else NULL end) as volume,
				max(uom_id) as uom_id,
				a.as_of_date,
				max(b.include_item) as include_item	
			from
				calc_invoice_volume_variance civv inner join 
				calc_invoice_summary a on civv.calc_id=a.calc_id
				left join formula_nested b on
				a.formula_id=b.formula_group_id
				and a.seq_number=b.sequence_order
				LEFT JOIN contract_group cg ON cg.contract_id=civv.contract_id
			where 1=1
				and cg.sub_id in('+@subsidiary_id+')
				and civv.as_of_date<='''+cast(@as_of_date as varchar)+''''+
				case when @counterparty_id is not null then ' And a.counterparty_id='+cast(@counterparty_id as varchar) else '' end+
			'group by 
				invoice_line_item_id,a.formula_id,cast(CAST(Year(a.prod_date) As Varchar)+''-''+ CAST(month(a.prod_date) As Varchar) +''-01'' as datetime),
				a.as_of_date
			'	
			--print @Sql_Select
			exec(@Sql_Select)

	--###########################################################

	create table #temp(
		counterparty_id int,
		contract_id int,
		counterparty_name varchar(100) COLLATE DATABASE_DEFAULT,
		uom_id int,
		as_of_date datetime,
		prod_date datetime,
		volume float,
		adjustment_amount float,
		manual_input char(1) COLLATE DATABASE_DEFAULT,
		invoice_line_item varchar(100) COLLATE DATABASE_DEFAULT,
		finalized char(1) COLLATE DATABASE_DEFAULT,
		gl_account_number varchar(100) COLLATE DATABASE_DEFAULT,
		gl_account_name varchar(100) COLLATE DATABASE_DEFAULT,
		technology varchar(100) COLLATE DATABASE_DEFAULT,	
		invoice_line_item_id int,
		finalized_actual char(1) COLLATE DATABASE_DEFAULT
		
		
	)	


	set @Sql_Select='
	insert into #temp
	 select  
		distinct
		sc.source_counterparty_id,
		civv.contract_id,
		ISNULL(sc1.counterparty_name,sc.counterparty_name) as counterparty_name,
		case 
		when (case 
		when isnull(cfv.include_item,''n'')=''y'' then NULL
		when civ.invoice_line_item_id=5259 then NULL
       	when isnull(civ.manual_input,'''')='''' and civ.price_or_formula=''f''  then 
				case when civv.book_entries=''m'' then   civv.allocationvolume  else ih.invoice_volume end
	    when civ.manual_input=''y'' then civ.volume end  * cg.volume_mult ) IS NUll then '''' else su.source_uom_id end,  
		civv.as_of_date,
		civv.prod_date,
		(case 
		when isnull(cfv.include_item,''n'')=''y'' then ''''
		when civ.invoice_line_item_id=5259 then ''''
		When civ1.volume IS NOT NULL AND  ISNULL(civ.manual_input,''n'')=''n'' THEN ''''
		when cfv.volume is not null then cfv.volume
		when isnull(civ.manual_input,'''')='''' and civ.price_or_formula=''f''  then 
					case when civv.book_entries=''m'' then   civv.allocationvolume  else ih.invoice_volume end
		when civ.manual_input=''y'' AND ISNULL(civ.include_volume,''n'')=''y'' then civ.volume end
		 * cg.volume_mult )* ISNULL(conv.conversion_factor,1) as volume,
		case when civv.book_entries=''m'' then civ.value else ind.invoice_amount end adjustment_amount ,
		civ.manual_input,
		ili.description+''(''+ili.code+'')'' as invoice_line_item,
		case when a.as_of_date is null then ''n'' else civv.finalized end as finalzed,
		--civv.finalized as finalzed,
		ISNULL(gsm.gl_account_number,gsm1.gl_account_number),     
		ISNULL(gsm.gl_account_name,gsm1.gl_account_name),
		sd1.code,
		civ.invoice_line_item_id,
		case when a.as_of_date is null then ''n'' else civv.finalized end as finalzed
		
		
	from   
		rec_generator rg 
		INNER JOIN 
		(select distinct sub_entity_id from #ssbm) ssbm on ssbm.sub_entity_id=rg.legal_entity_value_id
		INNER JOIN
		contract_group cg on cg.contract_id=rg.ppa_contract_id   
		inner JOIN
		calc_invoice_volume_variance civv on civv.counterparty_id=rg.ppa_counterparty_id 
		and (dbo.FNAGetContractMonth(civv.as_of_date)<=dbo.FNAGetContractMonth(''' + @as_of_date  +'''))
		--or (dbo.FNAGetContractMonth(civv.as_of_date)<=dbo.FNAGetContractMonth(''' + @as_of_date  +''') and dbo.FNAGetContractMonth(civv.as_of_date)>dateadd(month,-1,dbo.FNAGetContractMonth('''+@as_of_date+''')) and isnull(civv.finalized,''n'')=''y'') 
 		AND cg.contract_id=civv.contract_id   
		LEFT JOIN
		calc_invoice_volume civ on civv.calc_id=civ.calc_id  
		--and dbo.FNAGetcontractMonth(civ.prod_date)=dbo.FNAGetcontractMonth(civv.prod_date)  
		LEFT JOIN
		invoice_header ih on ih.invoice_id=civv.invoice_id  
		LEFT JOIN
		invoice_detail ind on ind.invoice_id=ih.invoice_id 
		and ind.invoice_line_item_id=civ.invoice_line_item_id
		LEFT JOIN
		static_data_value ili on ili.value_id = civ.invoice_line_item_id
		INNER JOIN
		source_counterparty sc on sc.source_counterparty_id = civv.counterparty_id   
		LEFT JOIN
		contract_group_detail cgd on cgd.contract_id = cg.contract_id   
			and civ.invoice_line_item_id=cgd.invoice_line_item_id   
			and prod_type= case when ISNULL(cg.term_start,'''')='''' then ''p''  
					   when dbo.FNAGETCONTRACTMONTH(cg.term_start)<=dbo.FNAGETCONTRACTMONTH(civv.prod_date) then ''p''  
						   else ''t'' end 
		left join adjustment_default_gl_codes adgc on adgc.default_gl_id = cgd.default_gl_id  
		and adgc.fas_subsidiary_id=cg.sub_id  
		left join adjustment_default_gl_codes adgc1 on adgc1.default_gl_id = civ.default_gl_id  
		and adgc1.fas_subsidiary_id=cg.sub_id  
		LEFT JOIN invoice_lineitem_default_glcode ildg on ildg.invoice_line_item_id=civ.invoice_line_item_id   
		and ildg.sub_id=cg.sub_id  
		left join adjustment_default_gl_codes adgc2 on adgc2.default_gl_id = ildg.default_gl_id  
		and adgc2.fas_subsidiary_id=cg.sub_id  
		left join adjustment_default_gl_codes_detail adgcd on adgcd.default_gl_id=COALESCE(adgc.default_gl_id,adgc1.default_gl_id,adgc2.default_gl_id)
		and dbo.FNAGetContractMonth(civv.as_of_date) between adgcd.term_start and adgcd.term_end
		left join gl_system_mapping gsm on gsm.gl_number_id=COALESCE(adgcd.debit_gl_number,adgc.debit_gl_number,adgc1.debit_gl_number,adgc2.debit_gl_number)	
		and gsm.gl_code1_value_id='+cast(@gl_account_group_code as varchar)+'
		left join gl_system_mapping gsm1 on gsm.gl_number_id=COALESCE(adgcd.credit_gl_number,adgc.credit_gl_number,adgc1.credit_gl_number,adgc2.credit_gl_number)	
		and gsm1.gl_code1_value_id='+cast(@gl_account_group_code as varchar)+' 
		left join source_uom su on su.source_uom_id = COALESCE(adgcd.uom_id,adgc.uom_id,adgc1.uom_id,adgc2.uom_id)   
		left join formula_editor fe on fe.formula_id=cgd.formula_id
		left join #calc_formula_value cfv on cfv.formula_id=fe.formula_id
		and dbo.fnagetcontractmonth(cfv.prod_date)=	dbo.FNAGetContractMonth(civv.prod_date)
		and cfv.as_of_date=civv.as_of_date
		LEFT  JOIN rec_volume_unit_conversion Conv ON              
		conv.from_source_uom_id=  
		case 
		 when cfv.volume is not null then ISNULL(cfv.uom_id,civv.uom)
		 when civv.book_entries=''m'' then   
		 case when isnull(civ.manual_input,'''')='''' and civ.price_or_formula=''f'' and cgd.manual=''y'' then civv.uom  
		 when civ.manual_input=''y'' then civ.uom_id end  
		 else ih.uom_id end    
		and conv.to_source_uom_id = COALESCE(adgcd.uom_id,adgc.uom_id,adgc1.uom_id,adgc2.uom_id,civv.uom)  
		and conv.state_value_id is null and conv.assignment_type_value_id is null  
		and conv.curve_id is null    
		LEFT JOIN source_counterparty sc1 on sc1.source_counterparty_id=sc.netting_parent_counterparty_id
		left JOIN
 		(select max(as_of_date) as_of_date,counterparty_id,prod_date,contract_id from calc_invoice_volume_variance 
			where 1=1
			--and dbo.FNAGetContractMonth(as_of_date) <= dbo.FNAGetContractMonth(''' + @as_of_date  +''')
			group by counterparty_id,prod_date,contract_id) a
 			on a.as_of_date=civv.as_Of_date and  a.counterparty_id=civv.counterparty_id 
		and a.contract_id=civv.contract_id and a.prod_date=civv.prod_date 
		LEFT JOIN static_data_value sd1 on sd1.value_id=rg.technology
		OUTER APPLY(SELECT volume FROM calc_invoice_volume WHERE calc_id = civv.calc_id AND invoice_line_item_id = civ.invoice_line_item_id AND ISNULL(include_volume,''n'')=''y'') civ1
	WHERE 1=1 
		  --and civv.prod_date=''2007-11-01''	
		  and isnull(civ.manual_input,''n'')=''n''	
	'
	+ case when @counterparty_id is not null then 
		' And (sc.source_counterparty_id='+cast(@counterparty_id as varchar)+' OR sc.netting_parent_counterparty_id='+cast(@counterparty_id as varchar)+')' else '' end
	+ case when @technology is not null then ' And rg.technology='+cast(@technology as varchar) else '' end
	+ case when @show_estimated_report='y' then ' And civv.estimated=''y''' else '' end
	+ case when @settlement_accounts is not null then ' AND cg.settlement_accountant='''+@settlement_accounts+'''' else '' end 
	exec(@Sql_Select)

--select * from #temp where prod_date='2007-10-01'

create table #temp1(
		counterparty_id int,
		contract_id int,
		as_of_date datetime,
		prod_date datetime,
		invoice_line_item_id int
		
	)	

insert into #temp1
--select 
--		counterparty_id,contract_id,dateadd(m,-2,max(as_of_date)),prod_date,invoice_line_item_id
--		from #temp
--group by counterparty_id,contract_id,prod_date,invoice_line_item_id
--having count(*)>2
select 
		counterparty_id,contract_id,
		(select max(as_of_date) from #temp where as_of_date<max(a.as_of_date) and 
		counterparty_id=a.counterparty_id and contract_id=a.contract_id  
		and invoice_line_item_id=a.invoice_line_item_id
		and prod_date=a.prod_date )
		,prod_date,invoice_line_item_id
		from #temp a
group by counterparty_id,contract_id,prod_date,invoice_line_item_id
having count(*)>2 


delete a
	from #temp a,
		 #temp1 b
where
		a.counterparty_id=b.counterparty_id
		and a.contract_id=b.contract_id
		and a.invoice_line_item_id=b.invoice_line_item_id
		and a.prod_date=b.prod_date
		--and a.as_of_date<=b.as_of_date
		and a.as_of_date<b.as_of_date

delete from #temp1


--------------------------------------------------------------------
CREATE TABLE #temp_final(
	[Counterparty] [varchar](100) COLLATE DATABASE_DEFAULT ,
	[Account Code] [varchar](100) COLLATE DATABASE_DEFAULT ,
	[Description] [varchar](100) COLLATE DATABASE_DEFAULT ,
	[Production Month] Datetime ,
	[Charge Type] [varchar](100) COLLATE DATABASE_DEFAULT ,
	[Unit of Measure] [varchar](250) COLLATE DATABASE_DEFAULT ,
	[Estimate Reversal Volume] [float] NULL,
	[Estimate Reversal $] MONEY NULL,
	[Prior Month Actual Volume] [float] NULL,
	[Prior Month Actual $] MONEY NULL,
	[Current Month Estimate Volume] [float] NULL,
	[Current Month Estimates $] MONEY NULL,
	[Variance Volume] [float] NULL,
	[Variance $] MONEY NULL,
	[Net Entry Volume] [float] NULL,
	[Net Entry $] MONEY NULL,
	Finalized char(1) COLLATE DATABASE_DEFAULT NULL,
	as_of_date datetime null,
	current_volume float null,
	current_amount decimal(20,2) null,
	technology varchar(100) COLLATE DATABASE_DEFAULT,
	finalized_actual char(1) COLLATE DATABASE_DEFAULT
	
)

-------------------------------------------------------------------------
set @Sql_Select='
insert into #temp_final
		select tmp.counterparty_name as [Counterparty],
		max(tmp.gl_account_number) as [Account Code],
		max(tmp.gl_account_name) as [Description],
		dbo.fnadateformat(tmp.prod_date) as [Production Month],
		tmp.invoice_line_item as [Charge Type],
		su.uom_desc as [Unit of Measure],
		round(NULLIF(sum(case when tmp.as_of_date<=dateadd(month,-1,dbo.FNAGetContractMonth('''+@as_of_date+'''))   then tmp.volume else NULL end),0),0)  as [Estimate Reversal Volume],
		round(sum(round(case when tmp.as_of_date<=dateadd(month,-1,dbo.FNAGetContractMonth('''+@as_of_date+'''))   then tmp.adjustment_amount else 0 end,2,0)),2,0) as [Estimate Reversal $],
		
		round(NULLIF(sum(case when tmp.as_of_date<=dateadd(month,0,dbo.FNAGetContractMonth('''+@as_of_date+'''))  and isnull(tmp.finalized,''n'')=''y'' then tmp.volume else 0 end),0),0) as [Prior Month Actual Volume],
		round(sum(round(case when tmp.as_of_date<=dateadd(month,0,dbo.FNAGetContractMonth('''+@as_of_date+'''))  and isnull(tmp.finalized,''n'')=''y''  then tmp.adjustment_amount else 0 end,2,0)),2,0) as[Prior Month Actual $],
		round(NULLIF(sum(case when tmp.as_of_date=dbo.FNAGetContractMonth('''+@as_of_date+''') and isnull(tmp.finalized,''n'')=''n'' then tmp.volume else 0 end),0),0) as [Current Month Estimate Volume],
		round(sum(round(case when tmp.as_of_date=dbo.FNAGetContractMonth('''+@as_of_date+''') and isnull(tmp.finalized,''n'')=''n'' then tmp.adjustment_amount else 0 end,2,0)),2,0) as [Current Month Estimate $],
		NULL,
		NULL,
		NULL,
		NULL,
		max(tmp.finalized) as finalized,
		max(tmp.as_of_date),
		round(sum(tmp1.volume),0),
		round(round(sum(tmp1.adjustment_amount),2,0),2,0),
		max(tmp.technology),
		max(tmp.finalized_actual)
		
	from
		#temp tmp left join source_uom su on tmp.uom_id=su.source_uom_id 
		left join 
		(select max(as_of_date) as_of_date,counterparty_id,invoice_line_item,prod_date,contract_id from #temp 
			where dbo.FNAGetContractMonth(as_of_date) <= dbo.FNAGetContractMonth(''' + @as_of_date  +''')
			group by counterparty_id,prod_date,contract_id,invoice_line_item) a
 			on a.as_of_date=tmp.as_Of_date and  a.counterparty_id=tmp.counterparty_id 
			and a.contract_id=tmp.contract_id and a.prod_date=tmp.prod_date 
			and a.invoice_line_item=tmp.invoice_line_item
		left join #temp tmp1 on
			a.as_of_date=tmp1.as_Of_date and  a.counterparty_id=tmp1.counterparty_id 
			and a.contract_id=tmp1.contract_id and a.prod_date=tmp1.prod_date 
			and a.invoice_line_item=tmp1.invoice_line_item
	'

	set @sql_Where='
	
	group by 
		tmp.counterparty_name,tmp.counterparty_id,
		tmp.invoice_line_item,su.uom_desc,tmp.prod_date order by 
		tmp.counterparty_name,dbo.fnadateformat(tmp.prod_date) '

	
	exec(@Sql_Select+@sql_Where)


--####################################-------------------------------------------------------------------------
--- ######## insert Manual Entries
if @show_estimated_report<>'y'
BEGIN
delete from #temp
set @Sql_Select='
	insert into #temp
	 select  
		distinct
		sc.source_counterparty_id,
		civv.contract_id,
		ISNULL(sc1.counterparty_name,sc.counterparty_name) as counterparty_name,
		--su.source_uom_id as uom,  
--		case when cgd.manual<>''y'' then ''''
--		when (civ.volume  * cg.volume_mult) IS NUll then '''' else su.source_uom_id end,
		CASE WHEN ISNULL(civ.include_volume,''n'')=''y'' THEN case when (civ.volume  * cg.volume_mult) IS NUll then '''' else su.source_uom_id end ELSE NULL END,
		--su.source_uom_id,  
		civv.as_of_date,
		civ.prod_date,
		CASE WHEN ISNULL(civ.include_volume,''n'')=''y'' THEN (civ.volume * cg.volume_mult )* ISNULL(conv.conversion_factor,1) ELSE NULL END as volume,
		civ.value adjustment_amount ,
		civ.manual_input,
		ili.description+''(''+ili.code+'')''+CASE ISNULL(civ.status,''x'') WHEN ''a'' THEN ''(Adjusted)'' WHEN ''v'' THEN ''(Voided)'' ELSE '''' END as invoice_line_item,
		civ.finalized  as finalzed,
		--civv.finalized as finalzed,
		ISNULL(gsm.gl_account_number,gsm1.gl_account_number),     
		ISNULL(gsm.gl_account_name,gsm1.gl_account_name),
		sd1.code,
		civ.invoice_line_item_id,
		COALESCE(civ1.finalized,civ.finalized,''n'') as finalized_actual
		
	from   
		rec_generator rg 
		INNER JOIN 
		(select distinct sub_entity_id from #ssbm) ssbm on ssbm.sub_entity_id=rg.legal_entity_value_id
		INNER JOIN
		contract_group cg on cg.contract_id=rg.ppa_contract_id   
		inner JOIN
		calc_invoice_volume_variance civv on civv.counterparty_id=rg.ppa_counterparty_id 
		and (dbo.FNAGetContractMonth(civv.as_of_date)<=dbo.FNAGetContractMonth(''' + @as_of_date  +'''))
		--AND cg.contract_id=civv.contract_id  
		LEFT JOIN
		calc_invoice_volume civ on civv.calc_id=civ.calc_id  
		--and dbo.FNAGetcontractMonth(civ.prod_date)=dbo.FNAGetcontractMonth(civv.prod_date)  
		LEFT JOIN
		invoice_header ih on ih.invoice_id=civv.invoice_id  
		LEFT JOIN
		invoice_detail ind on ind.invoice_id=ih.invoice_id 
		and ind.invoice_line_item_id=civ.invoice_line_item_id
		LEFT JOIN
		static_data_value ili on ili.value_id = civ.invoice_line_item_id
		INNER JOIN
		source_counterparty sc on sc.source_counterparty_id = civv.counterparty_id   
		LEFT JOIN
		contract_group_detail cgd on cgd.contract_id = cg.contract_id   
			and civ.invoice_line_item_id=cgd.invoice_line_item_id   
			and prod_type= case when ISNULL(cg.term_start,'''')='''' then ''p''  
					   when dbo.FNAGETCONTRACTMONTH(cg.term_start)<=dbo.FNAGETCONTRACTMONTH(civv.prod_date) then ''p''  
						   else ''t'' end 
		left join adjustment_default_gl_codes adgc on adgc.default_gl_id = cgd.default_gl_id  
		and adgc.fas_subsidiary_id=cg.sub_id  
		left join adjustment_default_gl_codes adgc1 on adgc1.default_gl_id = civ.default_gl_id  
		and adgc1.fas_subsidiary_id=cg.sub_id  
		LEFT JOIN invoice_lineitem_default_glcode ildg on ildg.invoice_line_item_id=civ.invoice_line_item_id   
		and ildg.sub_id=cg.sub_id  
		left join adjustment_default_gl_codes adgc2 on adgc2.default_gl_id = ildg.default_gl_id  
		and adgc2.fas_subsidiary_id=cg.sub_id  
		left join adjustment_default_gl_codes_detail adgcd on adgcd.default_gl_id=COALESCE(adgc.default_gl_id,adgc1.default_gl_id,adgc2.default_gl_id)
		and dbo.FNAGetContractMonth(civv.as_of_date) between adgcd.term_start and adgcd.term_end
		left join gl_system_mapping gsm on gsm.gl_number_id=COALESCE(adgcd.debit_gl_number,adgc.debit_gl_number,adgc1.debit_gl_number,adgc2.debit_gl_number)	
		--and gsm.gl_code1_value_id='+cast(@gl_account_group_code as varchar)+'
		left join gl_system_mapping gsm1 on gsm.gl_number_id=COALESCE(adgcd.credit_gl_number,adgc.credit_gl_number,adgc1.credit_gl_number,adgc2.credit_gl_number)	
		and gsm1.gl_code1_value_id='+cast(@gl_account_group_code as varchar)+' 
		left join source_uom su on su.source_uom_id = COALESCE(adgcd.uom_id,adgc.uom_id,adgc1.uom_id,adgc2.uom_id)   
		LEFT  JOIN rec_volume_unit_conversion Conv ON              
		conv.from_source_uom_id= civ.uom_id 
		and conv.to_source_uom_id = COALESCE(adgcd.uom_id,adgc.uom_id,adgc1.uom_id,adgc2.uom_id,civv.uom)  
		and conv.state_value_id is null and conv.assignment_type_value_id is null  
		and conv.curve_id is null    
		LEFT JOIN source_counterparty sc1 on sc1.source_counterparty_id=sc.netting_parent_counterparty_id

--		left JOIN
-- 		(select max(as_of_date) as_of_date,counterparty_id,prod_date,contract_id from calc_invoice_volume_variance 
--			where 1=1
--			--and dbo.FNAGetContractMonth(as_of_date) <= dbo.FNAGetContractMonth(''' + @as_of_date  +''')
--			group by counterparty_id,prod_date,contract_id) a
-- 			on a.as_of_date=civv.as_Of_date and  a.counterparty_id=civv.counterparty_id 
--		and a.contract_id=civv.contract_id and a.prod_date=civv.prod_date 
--
		LEFT JOIN static_data_value sd1 on sd1.value_id=rg.technology
		left join calc_invoice_volume civ1 on civ1.finalized_id=civ.calc_detail_id
		and civ1.finalized=''y'' and dbo.fnagetcontractmonth(civv.as_of_date)<dbo.FNAGetContractMonth(''' + @as_of_date  +''')
		LEFT JOIN (select isnull(finalized_id,'''') finalized_id from calc_invoice_volume civ 
				inner join calc_invoice_volume_variance civv on civ.calc_id=civv.calc_id 
				where  dbo.fnagetcontractmonth(civv.as_of_date)<dbo.FNAGetContractMonth(''' + @as_of_date  +'''))	civ2
		ON civ.calc_detail_id=ISNULL(civ2.finalized_id,-1)
	WHERE 1=1 
		    and isnull(civ.manual_input,''n'')=''y''	
			and isnull(civ.show_in_invoice,''y'')=''y''	
			and civ2.finalized_id IS NULL
			and civv.prod_date BETWEEN DATEADD(m,-5,'''+@as_of_date+''') AND '''+@as_of_date+'''  
--			and civ.calc_detail_id not in(select isnull(finalized_id,'''') from calc_invoice_volume civ inner join calc_invoice_volume_variance civv 
--			on civ.calc_id=civv.calc_id )		

--			and civ.calc_detail_id not in(select isnull(finalized_id,'''') from calc_invoice_volume civ inner join calc_invoice_volume_variance civv 
--			on civ.calc_id=civv.calc_id 
--	 where  dbo.fnagetcontractmonth(civv.as_of_date)<dbo.FNAGetContractMonth(''' + @as_of_date  +'''))		

	'
	+ case when @counterparty_id is not null then 
		' And (sc.source_counterparty_id='+cast(@counterparty_id as varchar)+' OR sc.netting_parent_counterparty_id='+cast(@counterparty_id as varchar)+')' else '' end
	+ case when @technology is not null then ' And rg.technology='+cast(@technology as varchar) else '' end
	+ case when @settlement_accounts is not null then ' AND cg.settlement_accountant='''+@settlement_accounts+'''' else '' end 
	
	--print @Sql_Select
	exec(@Sql_Select)


insert into #temp1
select 
		counterparty_id,contract_id,dateadd(m,-2,max(as_of_date)),prod_date,invoice_line_item_id
		from #temp
		where finalized='n'
group by counterparty_id,contract_id,prod_date,invoice_line_item_id
having count(*)>2



delete a
	from #temp a,
		 #temp1 b
where
		a.counterparty_id=b.counterparty_id
		and a.contract_id=b.contract_id
		and a.invoice_line_item_id=b.invoice_line_item_id
		and a.prod_date=b.prod_date
		and a.as_of_date<=b.as_of_date


--select * from #temp where prod_date='2006-11-01'
-----##########################


	set @Sql_Select='
insert into #temp_final
		select tmp.counterparty_name as [Counterparty],
		max(tmp.gl_account_number) as [Account Code],
		max(tmp.gl_account_name) as [Description],
		dbo.fnadateformat(tmp.prod_date) as [Production Month],
		tmp.invoice_line_item as [Charge Type],
		su.uom_desc as [Unit of Measure],
		round(NULLIF(sum(case when tmp.as_of_date<=dateadd(month,-1,dbo.FNAGetContractMonth('''+@as_of_date+'''))    then tmp.volume else NULL end),0),0)  as [Estimate Reversal Volume],
		round(sum(round(case when tmp.as_of_date<=dateadd(month,-1,dbo.FNAGetContractMonth('''+@as_of_date+'''))    then tmp.adjustment_amount else 0 end ,2,0)),2,0) as [Estimate Reversal $],
		
		round(NULLIF(sum(case when tmp.as_of_date<=dateadd(month,0,dbo.FNAGetContractMonth('''+@as_of_date+'''))  and isnull(tmp.finalized,''n'')=''y'' then tmp.volume else 0 end),0),0) as [Prior Month Actual Volume],
		round(sum(round(case when tmp.as_of_date<=dateadd(month,0,dbo.FNAGetContractMonth('''+@as_of_date+'''))  and isnull(tmp.finalized,''n'')=''y''  then tmp.adjustment_amount else 0 end ,2,0)),2,0) as[Prior Month Actual $],
		
		round(NULLIF(sum(case when tmp.as_of_date<=dbo.FNAGetContractMonth('''+@as_of_date+''') and isnull(tmp.finalized_actual,''n'')=''n'' then tmp.volume else 0 end),0),0) as [Current Month Estimate Volume],
		round(sum(round(case when tmp.as_of_date<=dbo.FNAGetContractMonth('''+@as_of_date+''') and isnull(tmp.finalized_actual,''n'')=''n'' then tmp.adjustment_amount else 0 end ,2,0)),2,0) as [Current Month Estimate $],
		NULL,
		NULL,
		NULL,
		NULL,
		--tmp.finalized as finalized,
		min(tmp.finalized_actual) as finalized,
		--max(tmp.as_of_date),
		(tmp.as_of_date),
		round(sum(tmp.volume),0),
		round(round(sum(tmp.adjustment_amount),2,0),2,0),
		max(tmp.technology),
		max(tmp.finalized) as finalized_actual
		
	from
		#temp tmp left join source_uom su on tmp.uom_id=su.source_uom_id 
--		left join 
--		(select max(as_of_date) as_of_date,counterparty_id,invoice_line_item,prod_date,contract_id from #temp 
--			where dbo.FNAGetContractMonth(as_of_date) <= dbo.FNAGetContractMonth(''' + @as_of_date  +''')
--			group by counterparty_id,prod_date,contract_id,invoice_line_item) a
-- 			on a.as_of_date=tmp.as_Of_date and  a.counterparty_id=tmp.counterparty_id 
--			and a.contract_id=tmp.contract_id and a.prod_date=tmp.prod_date 
--			and a.invoice_line_item=tmp.invoice_line_item
--		left join #temp tmp1 on
--			a.as_of_date=tmp1.as_Of_date and  a.counterparty_id=tmp1.counterparty_id 
--			and a.contract_id=tmp1.contract_id and a.prod_date=tmp1.prod_date 
--			and a.invoice_line_item=tmp1.invoice_line_item
	'

	set @sql_Where='
	group by 
		--tmp.finalized
		tmp.as_of_date,
		tmp.counterparty_name,tmp.counterparty_id,
		tmp.invoice_line_item,su.uom_desc,tmp.prod_date order by 
		tmp.counterparty_name,dbo.fnadateformat(tmp.prod_date) '
	
	--print @Sql_Select+@sql_Where
	exec(@Sql_Select+@sql_Where)
END
--select * from #temp
--select * from #temp_final
--return

-----###################################################################


if @options='d'

select 
	[Counterparty],
	[Production Month],
	[Account Code],
	[Description] ,
	[Charge Type],
	[Unit of Measure],
	round(SUM([Estimate Reversal Volume]),0) as [Estimate Reversal Volume], 
	round(SUM(round([Estimate Reversal $],2,0)),2,0) [Estimate Reversal $], 
	round(SUM([Prior Month Actual Volume]),2) [Prior Month Actual Volume],
	round(SUM(round([Prior Month Actual $],2,0)),2,0) [Prior Month Actual $], 
	round(SUM([Current Month Estimate Volume]),0) [Current Month Estimate Volume],
	round(SUM(round([Current Month Estimates $],2,0)),2,0) [Current Month Estimates $], 
	round(SUM([Variance Volume]),0) [Variance Volume], 
	round(SUM(round([Variance $],2,0)),2,0) [Variance $], 
	round(SUM([Net Entry Volume]),0) [Net Entry Volume], 
	round(SUM(round([Net Entry $],2,0)),2,0) [Net Entry $]
from
(
	select 
		[Counterparty] ,
		dbo.fnadateformat([Production Month]) as [Production Month],
		[Account Code],
		[Description],
		[Charge Type],
		[Unit of Measure],
		case when as_of_date = dbo.FNAGetContractMonth(@as_of_date) 
			then [Estimate Reversal Volume] else case when [Unit of Measure] is not null then current_volume else NULL end end as [Estimate Reversal Volume],
		case when as_of_date = dbo.FNAGetContractMonth(@as_of_date) 
			then [Estimate Reversal $] else current_amount end as [Estimate Reversal $],
		[Prior Month Actual Volume],
		[Prior Month Actual $] [Prior Month Actual $],
		case when isnull(finalized,'n')='y' then NULL else ISNULL([Current Month Estimate Volume],case when [Unit of Measure] is not null then current_volume else NULL end)-ISNULL([Prior Month Actual Volume],0) end as [Current Month Estimate Volume],
		case when isnull(finalized,'n')='y' then 0 else ISNULL(NULLIF([Current Month Estimates $],0),current_amount)-[Prior Month Actual $] end as [Current Month Estimates $],
		
		ISNULL([Prior Month Actual Volume],0)- case when as_of_date = dbo.FNAGetContractMonth(@as_of_date) 
			then ISNULL([Estimate Reversal Volume],0) else case when [Unit of Measure] is not null then isnull(current_volume,0) else 0 end end  as [Variance Volume],
		[Prior Month Actual $]-case when as_of_date = dbo.FNAGetContractMonth(@as_of_date) 
			then [Estimate Reversal $] else current_amount end as [Variance $],
		
		ISNULL([Prior Month Actual Volume],0)+case when isnull(finalized,'n')='y' then 0 else ISNULL(ISNULL([Current Month Estimate Volume],case when [Unit of Measure] is not null then current_volume else NULL end),0)-ISNULL([Prior Month Actual Volume],0) end -case when as_of_date = dbo.FNAGetContractMonth(@as_of_date) 
			then ISNULL([Estimate Reversal Volume],0) else case when [Unit of Measure] is not null then ISNULL(current_volume,0) else 0 end end  as [Net Entry Volume],
		[Prior Month Actual $]+case when isnull(finalized,'n')='y' then 0 else ISNULL(NULLIF([Current Month Estimates $],0),current_amount)-[Prior Month Actual $] end-case when as_of_date = dbo.FNAGetContractMonth(@as_of_date) 
			then [Estimate Reversal $] else current_amount end as [Net Entry $]
	from 
		#temp_final
	where 1=1
		AND [Account Code] IS NOT NULL
		AND COALESCE(NULLIF([Estimate Reversal Volume],0),NULLIF([Current Month Estimate Volume],0), NULLIF([Prior Month Actual Volume],0),NULLIF([Estimate Reversal $],0),NULLIF([Current Month Estimates $],0), NULLIF([Prior Month Actual $],0)) IS NOT NULL
		and ((isnull(finalized,'n')='y' and as_of_date between 
			dateadd(month,0,dbo.FNAGetContractMonth(@as_of_date)) and dateadd(month,0,dbo.FNAGetContractMonth(@as_of_date)))
		OR isnull(finalized,'n')='n' or isnull(finalized_actual,'n')='n')
	
) a
	group by [Counterparty],[Account Code],[Description] ,	[Production Month],	[Charge Type],	[Unit of Measure]
	order by [Counterparty],cast([Production Month] as datetime) ,[CHARGE TYPE],[Account Code]	

else if @options='s'
select 
	[Account Code],
	[Description] ,
	[Charge Type],
	[Production Month],
	[Unit of Measure],
	round(SUM([Estimate Reversal Volume]),0) as [Estimate Reversal Volume], 
	round(SUM(round([Estimate Reversal $],2,0)),2,0) [Estimate Reversal $], 
	round(SUM([Prior Month Actual Volume]),0) [Prior Month Actual Volume],
	round(SUM(round([Prior Month Actual $],2,0)),2,0) [Prior Month Actual $], 
	round(SUM([Current Month Estimate Volume]),0) [Current Month Estimate Volume],
	round(SUM(round([Current Month Estimates $],2,0)),2,0) [Current Month Estimates $], 
	round(SUM([Variance Volume]),0) [Variance Volume], 
	round(SUM(round([Variance $],2,0)),2,0) [Variance $], 
	round(SUM([Net Entry Volume]),0) [Net Entry Volume], 
	round(SUM(round([Net Entry $],2,0)),2,0) [Net Entry $]
from
(
	select 
		[Counterparty] ,
		dbo.fnadateformat([Production Month]) as [Production Month],
		[Account Code],
		[Description],
		[Charge Type],
		[Unit of Measure],
		case when as_of_date = dbo.FNAGetContractMonth(@as_of_date) 
			then [Estimate Reversal Volume] else case when [Unit of Measure] is not null then current_volume else NULL end end as [Estimate Reversal Volume],
		case when as_of_date = dbo.FNAGetContractMonth(@as_of_date) 
			then [Estimate Reversal $] else current_amount end as [Estimate Reversal $],
		[Prior Month Actual Volume],
		[Prior Month Actual $] [Prior Month Actual $],
		case when isnull(finalized,'n')='y' then NULL else ISNULL([Current Month Estimate Volume],case when [Unit of Measure] is not null then current_volume else NULL end)-ISNULL([Prior Month Actual Volume],0) end as [Current Month Estimate Volume],
		case when isnull(finalized,'n')='y' then 0 else ISNULL(NULLIF([Current Month Estimates $],0),current_amount)-[Prior Month Actual $] end as [Current Month Estimates $],
		
		ISNULL([Prior Month Actual Volume],0)- case when as_of_date = dbo.FNAGetContractMonth(@as_of_date) 
			then ISNULL([Estimate Reversal Volume],0) else case when [Unit of Measure] is not null then isnull(current_volume,0) else 0 end end  as [Variance Volume],
		[Prior Month Actual $]-case when as_of_date = dbo.FNAGetContractMonth(@as_of_date) 
			then [Estimate Reversal $] else current_amount end as [Variance $],
		
		ISNULL([Prior Month Actual Volume],0)+case when isnull(finalized,'n')='y' then 0 else ISNULL(ISNULL([Current Month Estimate Volume],case when [Unit of Measure] is not null then current_volume else NULL end),0)-ISNULL([Prior Month Actual Volume],0) end -case when as_of_date = dbo.FNAGetContractMonth(@as_of_date) 
			then ISNULL([Estimate Reversal Volume],0) else case when [Unit of Measure] is not null then ISNULL(current_volume,0) else 0 end end  as [Net Entry Volume],
		[Prior Month Actual $]+case when isnull(finalized,'n')='y' then 0 else ISNULL(NULLIF([Current Month Estimates $],0),current_amount)-[Prior Month Actual $] end-case when as_of_date = dbo.FNAGetContractMonth(@as_of_date) 
			then [Estimate Reversal $] else current_amount end as [Net Entry $]
	from 
		#temp_final
	where 1=1
		AND COALESCE(NULLIF([Estimate Reversal Volume],0),NULLIF([Current Month Estimate Volume],0), NULLIF([Prior Month Actual Volume],0),NULLIF([Estimate Reversal $],0),NULLIF([Current Month Estimates $],0), NULLIF([Prior Month Actual $],0)) IS NOT NULL
		AND [Account Code] IS NOT NULL
		and ((isnull(finalized,'n')='y' and as_of_date between 
			dateadd(month,0,dbo.FNAGetContractMonth(@as_of_date)) and dateadd(month,0,dbo.FNAGetContractMonth(@as_of_date)))
		OR isnull(finalized,'n')='n' or isnull(finalized_actual,'n')='n')
	
) a
	group by [Account Code],[Description],[Charge Type],[Production Month],[Unit of Measure]
	order by [Account Code],[CHARGE TYPE],[Production Month]

else if @options='t'
select 
	[Technology],
	[Counterparty],
	[Production Month],
	[Account Code],
	[Description] ,
	[Charge Type],
	[Unit of Measure],
	round(SUM([Estimate Reversal Volume]),0) as [Estimate Reversal Volume], 
	round(SUM(round([Estimate Reversal $],2,0)),2,0) [Estimate Reversal $], 
	round(SUM([Prior Month Actual Volume]),0) [Prior Month Actual Volume],
	round(SUM(round([Prior Month Actual $],2,0)),2,0) [Prior Month Actual $], 
	round(SUM([Current Month Estimate Volume]),0) [Current Month Estimate Volume],
	round(SUM(round([Current Month Estimates $],2,0)),2,0) [Current Month Estimates $], 
	round(SUM([Variance Volume]),0) [Variance Volume], 
	round(SUM(round([Variance $],2,0)),2,0) [Variance $], 
	round(SUM([Net Entry Volume]),0) [Net Entry Volume], 
	round(SUM(round([Net Entry $],2,0)),2,0) [Net Entry $]
from
(
	select 
		[Technology],
		[Counterparty],
		dbo.fnadateformat([Production Month]) [Production Month],
		[Account Code],
		[Description],
		[Charge Type],
		[Unit of Measure],
		case when as_of_date = dbo.FNAGetContractMonth(@as_of_date) 
			then [Estimate Reversal Volume] else case when [Unit of Measure] is not null then current_volume else NULL end end as [Estimate Reversal Volume],
		case when as_of_date = dbo.FNAGetContractMonth(@as_of_date) 
			then [Estimate Reversal $] else current_amount end as [Estimate Reversal $],
		[Prior Month Actual Volume],
		[Prior Month Actual $] [Prior Month Actual $],
		case when isnull(finalized,'n')='y' then NULL else ISNULL([Current Month Estimate Volume],case when [Unit of Measure] is not null then current_volume else NULL end)-ISNULL([Prior Month Actual Volume],0) end as [Current Month Estimate Volume],
		case when isnull(finalized,'n')='y' then 0 else ISNULL(NULLIF([Current Month Estimates $],0),current_amount)-[Prior Month Actual $] end as [Current Month Estimates $],
		
		ISNULL([Prior Month Actual Volume],0)- case when as_of_date = dbo.FNAGetContractMonth(@as_of_date) 
			then ISNULL([Estimate Reversal Volume],0) else case when [Unit of Measure] is not null then isnull(current_volume,0) else 0 end end  as [Variance Volume],
		[Prior Month Actual $]-case when as_of_date = dbo.FNAGetContractMonth(@as_of_date) 
			then [Estimate Reversal $] else current_amount end as [Variance $],
		
		ISNULL([Prior Month Actual Volume],0)+case when isnull(finalized,'n')='y' then 0 else ISNULL(ISNULL([Current Month Estimate Volume],current_volume),0)-ISNULL([Prior Month Actual Volume],0) end -case when as_of_date = dbo.FNAGetContractMonth(@as_of_date) 
			then ISNULL([Estimate Reversal Volume],0) else case when [Unit of Measure] is not null then ISNULL(case when [Unit of Measure] is not null then current_volume else NULL end,0) else 0 end end  as [Net Entry Volume],
		[Prior Month Actual $]+case when isnull(finalized,'n')='y' then 0 else ISNULL(NULLIF([Current Month Estimates $],0),current_amount)-[Prior Month Actual $] end-case when as_of_date = dbo.FNAGetContractMonth(@as_of_date) 
			then [Estimate Reversal $] else current_amount end as [Net Entry $]
	from
		#temp_final
	where 1=1
		AND [Account Code] IS NOT NULL
		AND COALESCE(NULLIF([Estimate Reversal Volume],0),NULLIF([Current Month Estimate Volume],0), NULLIF([Prior Month Actual Volume],0),NULLIF([Estimate Reversal $],0),NULLIF([Current Month Estimates $],0), NULLIF([Prior Month Actual $],0)) IS NOT NULL
		and ((isnull(finalized,'n')='y' and as_of_date between 
		dateadd(month,0,dbo.FNAGetContractMonth(@as_of_date)) and dateadd(month,0,dbo.FNAGetContractMonth(@as_of_date)))
		OR isnull(finalized,'n')='n'  or isnull(finalized_actual,'n')='n')	
) a
	group by [Technology],[Counterparty],[Account Code],[Description] ,	[Production Month],	[Charge Type],	[Unit of Measure]
	order by technology,[Counterparty],cast([Production Month] as datetime),[CHARGE TYPE],[Account Code]

else if @options='c' -- by counterparty, production month
select 
	[Counterparty],
	[Production Month],
	[Account Code],
	[Description] ,
	[Charge Type],
	[Unit of Measure],
	round(SUM([Estimate Reversal Volume]),0) as [Estimate Reversal Volume], 
	round(SUM(round([Estimate Reversal $],2,0)),2,0) [Estimate Reversal $], 
	round(SUM([Prior Month Actual Volume]),0) [Prior Month Actual Volume],
	round(SUM(round([Prior Month Actual $],2,0)),2,0) [Prior Month Actual $], 
	round(SUM([Current Month Estimate Volume]),0) [Current Month Estimate Volume],
	round(SUM(round([Current Month Estimates $],2,0)),2,0) [Current Month Estimates $], 
	round(SUM([Variance Volume]),0) [Variance Volume], 
	round(SUM(round([Variance $],2,0)),2,0) [Variance $], 
	round(SUM([Net Entry Volume]),0) [Net Entry Volume], 
	round(SUM(round([Net Entry $],2,0)),2,0) [Net Entry $]
from
(
	select 
		[Counterparty],
		dbo.fnadateformat([Production Month]) [Production Month], 
		[Account Code],
		[Description],
		[Charge Type],
		[Unit of Measure],
		case when as_of_date = dbo.FNAGetContractMonth(@as_of_date) 
			then [Estimate Reversal Volume] else case when [Unit of Measure] is not null then current_volume else NULL end end as [Estimate Reversal Volume],
		case when as_of_date = dbo.FNAGetContractMonth(@as_of_date) 
			then [Estimate Reversal $] else current_amount end as [Estimate Reversal $],
		[Prior Month Actual Volume],
		[Prior Month Actual $] [Prior Month Actual $],
		case when isnull(finalized,'n')='y' then NULL else ISNULL([Current Month Estimate Volume],case when [Unit of Measure] is not null then current_volume else NULL end)-ISNULL([Prior Month Actual Volume],0) end as [Current Month Estimate Volume],
		case when isnull(finalized,'n')='y' then 0 else ISNULL(NULLIF([Current Month Estimates $],0),current_amount)-[Prior Month Actual $] end as [Current Month Estimates $],
		
		ISNULL([Prior Month Actual Volume],0)- case when as_of_date = dbo.FNAGetContractMonth(@as_of_date) 
			then ISNULL([Estimate Reversal Volume],0) else case when [Unit of Measure] is not null then isnull(current_volume,0) else 0 end end  as [Variance Volume],
		[Prior Month Actual $]-case when as_of_date = dbo.FNAGetContractMonth(@as_of_date) 
			then [Estimate Reversal $] else current_amount end as [Variance $],
		
		ISNULL([Prior Month Actual Volume],0)+case when isnull(finalized,'n')='y' then 0 else ISNULL(ISNULL([Current Month Estimate Volume],current_volume),0)-ISNULL([Prior Month Actual Volume],0) end -case when as_of_date = dbo.FNAGetContractMonth(@as_of_date) 
			then ISNULL([Estimate Reversal Volume],0) else case when [Unit of Measure] is not null then ISNULL(case when [Unit of Measure] is not null then current_volume else NULL end,0) else 0 end end  as [Net Entry Volume],
		[Prior Month Actual $]+case when isnull(finalized,'n')='y' then 0 else ISNULL(NULLIF([Current Month Estimates $],0),current_amount)-[Prior Month Actual $] end-case when as_of_date = dbo.FNAGetContractMonth(@as_of_date) 
			then [Estimate Reversal $] else current_amount end as [Net Entry $]

	from
		#temp_final
	where 1=1
		AND [Account Code] IS NOT NULL
		AND COALESCE(NULLIF([Estimate Reversal Volume],0),NULLIF([Current Month Estimate Volume],0), NULLIF([Prior Month Actual Volume],0),NULLIF([Estimate Reversal $],0),NULLIF([Current Month Estimates $],0), NULLIF([Prior Month Actual $],0)) IS NOT NULL
		and ((isnull(finalized,'n')='y' and as_of_date between 
		dateadd(month,0,dbo.FNAGetContractMonth(@as_of_date)) and dateadd(month,0,dbo.FNAGetContractMonth(@as_of_date)))
		OR isnull(finalized,'n')='n'  or isnull(finalized_actual,'n')='n')	
)a
	group by [Counterparty],[Account Code],[Description] ,	[Production Month],	[Charge Type],	[Unit of Measure]
	order by [Counterparty],cast([Production Month] as datetime),[CHARGE TYPE],[Account Code]
END


