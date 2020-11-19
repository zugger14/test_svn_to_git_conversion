

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_create_revenue_report]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_create_revenue_report]
 

GO

CREATE procedure [dbo].[spa_create_revenue_report]
		@report_type char(1)='s', -- 'f' final , 'e' estimate, 'y' Year to date, 'v' estimate vs final
		@subsidiary_id varchar(max)=null,
		@strategy_id varchar(max)= null,
		@book_id varchar(max)= null,
		@as_of_date_from varchar(100)= null,
		@as_of_date_to varchar(100) =null,
		@prod_date_from varchar(100) =null,
		@prod_date_to varchar(100)= null,
		@counterparty_id int =null,
		@charge_type int =null,
		@customer_type int= null,
		@group_by char(1)= null,
		@options varchar = null,
		@batch_process_id varchar(50)=NULL,
		@batch_report_param varchar(500)=NULL   ,
		@enable_paging INT = NULL,   --'1'=enable, '0'=disable
		@page_size INT = NULL,
		@page_no INT = NULL

	AS
	SET NOCOUNT ON
	BEGIN

	--////////////////////////////Paging_Batch///////////////////////////////////////////
	EXEC spa_print	'@batch_process_id:', @batch_process_id 
	EXEC spa_print	'@batch_report_param:',	@batch_report_param

	DECLARE @str_batch_table            VARCHAR(MAX),
			@str_get_row_number         VARCHAR(100)
	DECLARE @temptablename              VARCHAR(100)
	DECLARE @is_batch                   BIT
	DECLARE @report_measurement_values  VARCHAR(128)
	DECLARE @sql_stmt                   VARCHAR(8000)
	DECLARE @link_id                    VARCHAR(300)
	DECLARE @link_id_to                 VARCHAR(300)
	DECLARE @as_of_date                 VARCHAR(200)
	DECLARE @Sql_final                  VARCHAR(MAX)
	DECLARE @user_login_id_batch        VARCHAR(100)

		IF @link_id IS NOT NULL AND @link_id_to IS NULL
			SET @link_id_to=@link_id
		IF @link_id IS NULL AND @link_id_to IS NOT NULL
			SET @link_id=@link_id_to



		set @str_batch_table=''
		SET @str_get_row_number=''
		SET @report_measurement_values=dbo.FNAGetProcessTableName(@as_of_date, 'report_measurement_values')

	IF @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL
		SET @is_batch = 1
	ELSE
		SET @is_batch = 0
	
	IF (@is_batch = 1 OR @enable_paging = 1)
	begin
		IF (@batch_process_id IS NULL)
			SET @batch_process_id = REPLACE(NEWID(), '-', '_')
	
		SET @user_login_id_batch = dbo.FNADBUser()	
		SET @temptablename = dbo.FNAProcessTableName('batch_report', @user_login_id_batch, @batch_process_id)
		exec spa_print '@temptablename:', @temptablename
		SET @str_batch_table=' INTO ' + @temptablename
		SET @str_get_row_number=', ROWID=IDENTITY(int,1,1)'


		IF @enable_paging = 1
		BEGIN
		
			IF @page_size IS not NULL
			begin
				declare @row_to int,@row_from int
				set @row_to=@page_no * @page_size
				if @page_no > 1 
					set @row_from =((@page_no-1) * @page_size)+1
				else
					set @row_from =@page_no
				set @sql_stmt=''
				--	select @temptablename
				--select * from adiha_process.sys.columns where [object_id]=object_id(@temptablename) and [name]<>'ROWID' ORDER BY column_id

				select @sql_stmt=@sql_stmt+',['+[name]+']' from adiha_process.sys.columns WITH(NOLOCK) where [object_id]=object_id(@temptablename) and [name]<>'ROWID' ORDER BY column_id
				SET @sql_stmt=SUBSTRING(@sql_stmt,2,LEN(@sql_stmt))
			
				set @sql_stmt='select '+@sql_stmt +'
					  from '+ @temptablename   +' 
					  where rowid between '+ cast(@row_from as varchar) +' and '+ cast(@row_to as varchar) 
				 
				--print(@sql_stmt)		
				exec(@sql_stmt)
				return
			END --else @page_size IS not NULL
		END --enable_paging = 1
	end

	--////////////////////////////End_Batch///////////////////////////////////////////



	 DECLARE @Sql_Select varchar(8000)
	 DECLARE @sql_Where varchar(8000)
	 DECLARE @gl_account_group_code int
	-- DECLARE @as_of_date varchar(100)
	 DECLARE @priormonth_value_id varchar(100)
	 set @priormonth_value_id='295381,295348,295514,295382'
	 set @gl_account_group_code=10004
	--******************************************************            
	--CREATE source book map table and build index            
	--*********************************************************            
IF @as_of_date_from IS NOT NULL AND @as_of_date_to IS NULL            
SET @as_of_date_to = @as_of_date_from            
IF @as_of_date_from IS NULL AND @as_of_date_to IS NOT NULL            
SET @as_of_date_from = @as_of_date_to      

IF @prod_date_from IS NOT NULL AND @prod_date_to IS NULL            
SET @prod_date_to = @prod_date_from            
IF @prod_date_from IS NULL AND @prod_date_to IS NOT NULL            
SET @prod_date_from = @prod_date_to      
 	           
set @as_of_date=@as_of_date_from

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
	IF @subsidiary_id IS NOT NULL            
	  SET @Sql_Where = @Sql_Where + ' AND stra.parent_entity_id IN  ( ' + @subsidiary_id + ') '             
	 IF @strategy_id IS NOT NULL            
	  SET @Sql_Where = @Sql_Where + ' AND (stra.entity_id IN(' + @strategy_id + ' ))'            
	 IF @book_id IS NOT NULL            
	  SET @Sql_Where = @Sql_Where + ' AND (book.entity_id IN(' + @book_id + ')) '            
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
				a.invoice_line_item_id,a.formula_id,
				cast(CAST(Year(a.prod_date) As Varchar)+''-''+ CAST(month(a.prod_date) As Varchar) +''-01'' as datetime) as prod_date,
				sum(case when show_value_id=1200 then (a.value) else NULL end) as volume,
				max(case when show_value_id=1200 then uom_id else NULL end) as uom_id,
				a.as_of_date,
				max(b.include_item) as include_item
			from
				calc_invoice_summary a
				left join formula_nested b on
				a.formula_id=b.formula_group_id
				and a.seq_number=b.sequence_order	
				left join calc_invoice_summary c on a.formula_id=c.formula_id and a.prod_date=c.prod_date
				and b.rate_id=c.seq_number and a.as_of_date=c.as_of_date
			where 1=1
				--and rg.legal_entity_value_id in('+@subsidiary_id+')
				and a.as_of_date<='''+cast(@as_of_date_to as varchar)+''''
				+case when @counterparty_id is not null then ' And a.counterparty_id='+cast(@counterparty_id as varchar) else '' end+
			'group by 
				a.invoice_line_item_id,a.formula_id,cast(CAST(Year(a.prod_date) As Varchar)+''-''+ CAST(month(a.prod_date) As Varchar) +''-01'' as datetime),
				a.as_of_date,uom_id
			'	
			exec(@Sql_Select)

--###########################################################

	create table #temp(
		counterparty_id int,
		contract_id int,
		counterparty_name varchar(100) COLLATE DATABASE_DEFAULT ,
		uom_id int,
		as_of_date datetime,
		prod_date datetime,
		volume float,
		adjustment_amount float,
		manual_input char(1) COLLATE DATABASE_DEFAULT ,
		invoice_line_item varchar(100) COLLATE DATABASE_DEFAULT ,
		finalized char(1) COLLATE DATABASE_DEFAULT ,
		gl_account_number varchar(100) COLLATE DATABASE_DEFAULT ,
		gl_account_name varchar(100) COLLATE DATABASE_DEFAULT ,
		technology varchar(100) COLLATE DATABASE_DEFAULT ,	
		invoice_line_item_id int,
		finalized_actual char(1) COLLATE DATABASE_DEFAULT ,
		UOM varchar(100) COLLATE DATABASE_DEFAULT 

		
	)	

if @report_type<>'v'
BEGIN
	set @Sql_Select='
	insert into #temp
	 select  
		distinct
		sc.source_counterparty_id,
		civv.contract_id,
		ISNULL(sc1.counterparty_name,sc.counterparty_name) as counterparty_name,
		--su.source_uom_id as uom,  
		case 
		--when (civ.value)=0 then ''''
		when (case 
		when civ.invoice_line_item_id=5259 then NULL
		when isnull(cfv.include_item,''n'')=''y'' then NULL
		when isnull(cfv.uom_id,-1)=-1 then NULL
		when isnull(civ.value,0)=0 then NULL
		when cfv.volume is not null then cfv.volume
		when civv.book_entries=''m'' then   
		case when isnull(civ.manual_input,'''')='''' and civ.price_or_formula=''f''  then civv.allocationvolume  
		when civ.manual_input=''y'' then civ.volume end else  ih.invoice_volume * cg.volume_mult end) IS NUll then '''' else su.source_uom_id end,  
		civv.as_of_date,
		civv.prod_date,
		(case 
		when civ.invoice_line_item_id=5259 then NULL
		when isnull(cfv.include_item,''n'')=''y'' then NULL
		when NULLIF(cfv.volume,0) is not null then cfv.volume
	    when civv.book_entries=''m'' then   
		case when isnull(civ.manual_input,'''')='''' and civ.price_or_formula=''f''  then NULLIF(civv.allocationvolume,0)  
		when civ.manual_input=''y'' then NULLIF(civ.volume,0) end else  ih.invoice_volume * cg.volume_mult end)* ISNULL(conv.conversion_factor,1) as volume,
		civ.value adjustment_amount ,
		civ.manual_input,
		ili.description+''(''+ili.code+'')'' as invoice_line_item,
		case when a.as_of_date is null then ''n'' else civ.finalized end as finalzed,
		--civv.finalized as finalzed,
		ISNULL(gsm1.gl_account_number,gsm.gl_account_number),     
		ISNULL(gsm1.gl_account_name,gsm.gl_account_name),
		sd1.code,
		civ.invoice_line_item_id,
		case when a.as_of_date is null then ''n'' else civ.finalized end as finalzed,
		su.uom_name
		
	from   
		rec_generator rg 
		INNER JOIN 
		(select distinct sub_entity_id from #ssbm) ssbm on ssbm.sub_entity_id=rg.legal_entity_value_id
		INNER JOIN
		contract_group cg on cg.contract_id=rg.ppa_contract_id   
		inner JOIN
		calc_invoice_volume_variance civv on civv.counterparty_id=rg.ppa_counterparty_id 
		INNER JOIN
 		(select max(as_of_date) as_of_date,counterparty_id,prod_date,contract_id from calc_invoice_volume_variance 
			where 1=1
			and as_of_date between dbo.FNAGetContractMonth(''' + @as_of_date_from  +''') and dbo.FNAGetContractMonth(''' + @as_of_date_to  +''')
			group by counterparty_id,prod_date,contract_id) a
 			on a.as_of_date=civv.as_Of_date and  a.counterparty_id=civv.counterparty_id 
		and a.contract_id=civv.contract_id and a.prod_date=civv.prod_date 
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
		left join contract_charge_type cct on cct.contract_charge_type_id=cg.contract_charge_type_id
		left join contract_charge_type_detail cctd on cctd.contract_charge_type_id=cct.contract_charge_type_id
		and cctd.prod_type=
		case when ISNULL(cg.term_start,'''')='''' then ''p'' 
			when dbo.fnagetcontractmonth(cg.term_start)<=dbo.fnagetcontractmonth(civv.prod_date) then ''p''
		  else ''t'' end	and cctd.invoice_line_item_id=civ.invoice_line_item_id 		

		left join adjustment_default_gl_codes adgc on adgc.default_gl_id =  case when ISNULL(civ.finalized,''n'')=''y'' then ISNULL(cgd.default_gl_id,cctd.default_gl_id)  else COALESCE(cgd.default_gl_id_estimates,cctd.default_gl_id_estimates,cgd.default_gl_id,cctd.default_gl_id) end 
		and adgc.fas_subsidiary_id=cg.sub_id  
		and ISNULL(adgc.estimated_actual,''z'')=case when adgc.estimated_actual is not null then case when  civ.finalized=''y'' then ''a'' else ''e'' end else ''z'' end
		left join adjustment_default_gl_codes adgc1 on adgc1.default_gl_id = civ.default_gl_id  
		and adgc1.fas_subsidiary_id=cg.sub_id  
		and ISNULL(adgc1.estimated_actual,''z'')=case when adgc1.estimated_actual is not null then case when  civ.finalized=''y'' then ''a'' else ''e'' end else ''z'' end
		LEFT JOIN invoice_lineitem_default_glcode ildg on ildg.invoice_line_item_id=civ.invoice_line_item_id   
		and ildg.sub_id=cg.sub_id  
		and ISNULL(ildg.estimated_actual,''z'')=case when ildg.estimated_actual is not null then case when  civ.finalized=''y'' then ''a'' else ''e'' end else ''z'' end
		left join adjustment_default_gl_codes adgc2 on adgc2.default_gl_id = ildg.default_gl_id  
		and adgc2.fas_subsidiary_id=cg.sub_id  
		and ISNULL(adgc2.estimated_actual,''z'')=case when adgc2.estimated_actual is not null then case when  civ.finalized=''y'' then ''a'' else ''e'' end else ''z'' end
		and ISNULL(ildg.estimated_actual,''z'')=ISNULL(adgc2.estimated_actual,''z'')
		left join adjustment_default_gl_codes_detail adgcd on adgcd.default_gl_id=COALESCE(adgc.default_gl_id,adgc1.default_gl_id,adgc2.default_gl_id)
		and dbo.FNAGetContractMonth(civv.as_of_date) between adgcd.term_start and adgcd.term_end

		left join gl_system_mapping gsm on gsm.gl_number_id=COALESCE(adgcd.debit_gl_number,adgc.debit_gl_number,adgc1.debit_gl_number,adgc2.debit_gl_number)	
		--and gsm.gl_code1_value_id='+cast(@gl_account_group_code as varchar)+'
		left join gl_system_mapping gsm1 on gsm1.gl_number_id=COALESCE(adgcd.credit_gl_number,adgc.credit_gl_number,adgc1.credit_gl_number,adgc2.credit_gl_number)	
		--and gsm1.gl_code1_value_id='+cast(@gl_account_group_code as varchar)+' 
		
		left join formula_editor fe on fe.formula_id=cgd.formula_id
		left join #calc_formula_value cfv on cfv.formula_id=fe.formula_id
		and dbo.fnagetcontractmonth(cfv.prod_date)=	dbo.FNAGetContractMonth(civv.prod_date)
		and cfv.as_of_date=civv.as_of_date and (cfv.volume is not null or cfv.include_item=''y'')
		left join source_uom su on su.source_uom_id = ISNULL(cfv.uom_id,civv.uom)
			--COALESCE(adgcd.uom_id,adgc.uom_id,adgc1.uom_id,adgc2.uom_id,cfv.uom_id,civ.uom_id,civv.uom)   

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
		LEFT JOIN static_data_value sd1 on sd1.value_id=rg.technology
	WHERE 1=1 
		  and isnull(civ.manual_input,''n'')=''n''	
	'
	+ case when @as_of_date_from is not null then ' And civv.as_of_date between '''+@as_of_date_from+''' and '''+@as_of_date_to+'''' else '' end
	+ case when @prod_date_from is not null then ' And civv.prod_date between '''+@prod_date_from+''' and '''+@prod_date_to+'''' else '' end
	+ case when @counterparty_id is not null then 
		' And (sc.source_counterparty_id='+cast(@counterparty_id as varchar)+' OR sc.netting_parent_counterparty_id='+cast(@counterparty_id as varchar)+')' else '' end
	+ case when @charge_type is not null then ' And civ.invoice_line_item_id='+cast(@charge_type as varchar) else '' end
	+ case when @customer_type is not null then ' And sc.type_of_entity='+cast(@customer_type as varchar) else '' end


	--print @Sql_Select
	exec(@Sql_Select)

--####### insert manual entries
set @Sql_Select='
	insert into #temp
	 select  
		--distinct
		sc.source_counterparty_id,
		civv.contract_id,
		ISNULL(sc1.counterparty_name,sc.counterparty_name) as counterparty_name,
		--su.source_uom_id as uom,  
		case when cgd.manual<>''y'' then ''''
		when (civ.volume  * cg.volume_mult) IS NUll then '''' else su.source_uom_id end,  
		civv.as_of_date,
		civ.prod_date,
		(civ.volume * cg.volume_mult )* ISNULL(conv.conversion_factor,1) as volume,
		civ.value adjustment_amount ,
		civ.manual_input,
		ili.description+''(''+ili.code+'')'' as invoice_line_item,
		civ.finalized  as finalzed,
		--civv.finalized as finalzed,
		ISNULL(gsm.gl_account_number,gsm1.gl_account_number),     
		ISNULL(gsm.gl_account_name,gsm1.gl_account_name),
		sd1.code,
		civ.invoice_line_item_id,
		COALESCE(civ1.finalized,civ.finalized,''n'') as finalized_actual,
		su.uom_name
	from   
		rec_generator rg 
		INNER JOIN 
		(select distinct sub_entity_id from #ssbm) ssbm on ssbm.sub_entity_id=rg.legal_entity_value_id
		INNER JOIN
		contract_group cg on cg.contract_id=rg.ppa_contract_id   
		inner JOIN
		calc_invoice_volume_variance civv on civv.counterparty_id=rg.ppa_counterparty_id 
		and as_of_date between dbo.FNAGetContractMonth(''' + @as_of_date_from  +''') and dbo.FNAGetContractMonth(''' + @as_of_date_to  +''')
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
			left join contract_charge_type cct on cct.contract_charge_type_id=cg.contract_charge_type_id
		left join contract_charge_type_detail cctd on cctd.contract_charge_type_id=cct.contract_charge_type_id
		and cctd.prod_type=
		case when ISNULL(cg.term_start,'''')='''' then ''p'' 
			when dbo.fnagetcontractmonth(cg.term_start)<=dbo.fnagetcontractmonth(civv.prod_date) then ''p''
		  else ''t'' end	and cctd.invoice_line_item_id=civ.invoice_line_item_id 		
	    left join adjustment_default_gl_codes adgc on adgc.default_gl_id =  case when ISNULL(civv.finalized,''n'')=''y'' then ISNULL(cgd.default_gl_id,cctd.default_gl_id)  else COALESCE(cgd.default_gl_id_estimates,cctd.default_gl_id_estimates,cgd.default_gl_id,cctd.default_gl_id) end 
		and adgc.fas_subsidiary_id=cg.sub_id  
		and ISNULL(adgc.estimated_actual,''z'')=case when adgc.estimated_actual is not null then case when  civv.finalized=''y'' then ''a'' else ''e'' end else ''z'' end
		left join adjustment_default_gl_codes adgc1 on adgc1.default_gl_id = case when  ISNULL(civv.finalized,''n'')=''y'' then civ.default_gl_id  else  civ.default_gl_id_estimate end
		and adgc1.fas_subsidiary_id=cg.sub_id  
		and ISNULL(adgc1.estimated_actual,''z'')=case when adgc1.estimated_actual is not null then case when  civv.finalized=''y'' then ''a'' else ''e'' end else ''z'' end
		LEFT JOIN invoice_lineitem_default_glcode ildg on ildg.invoice_line_item_id=civ.invoice_line_item_id   
		and ildg.sub_id=cg.sub_id  
		and ISNULL(ildg.estimated_actual,''z'')=case when ildg.estimated_actual is not null then case when  civv.finalized=''y'' then ''a'' else ''e'' end else ''z'' end
		left join adjustment_default_gl_codes adgc2 on adgc2.default_gl_id = ildg.default_gl_id  
		and adgc2.fas_subsidiary_id=cg.sub_id  
		and ISNULL(adgc2.estimated_actual,''z'')=case when adgc2.estimated_actual is not null then case when  civv.finalized=''y'' then ''a'' else ''e'' end else ''z'' end
		and ISNULL(ildg.estimated_actual,''z'')=ISNULL(adgc2.estimated_actual,''z'')
		left join adjustment_default_gl_codes_detail adgcd on adgcd.default_gl_id=COALESCE(adgc.default_gl_id,adgc1.default_gl_id,adgc2.default_gl_id)
		and dbo.FNAGetContractMonth(civv.as_of_date) between adgcd.term_start and adgcd.term_end

		left join gl_system_mapping gsm on gsm.gl_number_id=COALESCE(adgcd.debit_gl_number,adgc.debit_gl_number,adgc1.debit_gl_number,adgc2.debit_gl_number)	
		--and gsm.gl_code1_value_id='+cast(@gl_account_group_code as varchar)+'
		left join gl_system_mapping gsm1 on gsm1.gl_number_id=COALESCE(adgcd.credit_gl_number,adgc.credit_gl_number,adgc1.credit_gl_number,adgc2.credit_gl_number)	
		--and gsm1.gl_code1_value_id='+cast(@gl_account_group_code as varchar)+' 
		left join source_uom su on su.source_uom_id = COALESCE(civ.uom_id,adgcd.uom_id,adgc.uom_id,adgc1.uom_id,adgc2.uom_id)   
		LEFT  JOIN rec_volume_unit_conversion Conv ON              
		conv.from_source_uom_id= civ.uom_id 
		and conv.to_source_uom_id = COALESCE(adgcd.uom_id,adgc.uom_id,adgc1.uom_id,adgc2.uom_id,civv.uom)  
		and conv.state_value_id is null and conv.assignment_type_value_id is null  
		and conv.curve_id is null    
		LEFT JOIN source_counterparty sc1 on sc1.source_counterparty_id=sc.netting_parent_counterparty_id
		LEFT JOIN static_data_value sd1 on sd1.value_id=rg.technology
		left join calc_invoice_volume civ1 on civ1.finalized_id=civ.calc_detail_id
		and civ1.finalized=''y'' and dbo.fnagetcontractmonth(civv.as_of_date)<dbo.FNAGetContractMonth(''' + @as_of_date  +''')
	WHERE 1=1 
		    and isnull(civ.manual_input,''n'')=''y''	
			and civ.calc_detail_id not in(select isnull(finalized_id,'''') from calc_invoice_volume civ inner join calc_invoice_volume_variance civv 
			on civ.calc_id=civv.calc_id 
	 where  dbo.fnagetcontractmonth(civv.as_of_date)<dbo.FNAGetContractMonth(''' + @as_of_date  +'''))		

	'
	+ case when @as_of_date_from is not null then ' And civv.as_of_date between '''+@as_of_date_from+''' and '''+@as_of_date_to+'''' else '' end
	+ case when @prod_date_from is not null then ' And civv.prod_date between '''+@prod_date_from+''' and '''+@prod_date_to+'''' else '' end
	+ case when @counterparty_id is not null then 
		' And (sc.source_counterparty_id='+cast(@counterparty_id as varchar)+' OR sc.netting_parent_counterparty_id='+cast(@counterparty_id as varchar)+')' else '' end
	+ case when @charge_type is not null then ' And civ.invoice_line_item_id='+cast(@charge_type as varchar) else '' end
	+ case when @customer_type is not null then ' And sc.type_of_entity='+cast(@customer_type as varchar) else '' end
	--print @Sql_Select
	exec(@Sql_Select)



if @report_type='f' -- final report
BEGIN	
	if @group_by='c'
	begin
	set @Sql_final='
		select
				counterparty_name as [Counterparty],
				dbo.fnacontractmonthformat(prod_date) as [ProdMonth],
				gl_account_number as [Account Code],
				gl_account_name as [Description],
				invoice_line_item as [Charge Type],
				round(cast(Volume as decimal(20,0)),0) as [Actual Volume],
				case when Volume is null then '''' else UOM end as [UOM],
				round(adjustment_amount,2) as [Actual $]'
				+@str_batch_table+'
		from
			#temp
		where isnull(finalized,''n'')=''y''		
		order by 
			counterparty_name,prod_date'
		EXEC(@Sql_final)
	end
	else
	begin
	set @Sql_final='
		select
				
				gl_account_number as [Account Code],
				gl_account_name as [Description],
				dbo.fnacontractmonthformat(prod_date) as [ProdMonth],
				round(cast(sum(Volume) as decimal(20,0)),0) as [Actual Volume],
				case when sum(Volume) is null then '''' else max(UOM)  end as [UOM],
				round(sum(adjustment_amount),2) as [Actual $]
		from'+@str_batch_table+'
			#temp
		where isnull(finalized,''n'')=''y''	
		group by 
				--gl_account_number,gl_account_name,dbo.fnacontractmonthformat(prod_date)
			gl_account_number,gl_account_name,prod_date
		order by 
			--gl_account_name,dbo.fnadateformat(prod_date)
			gl_account_name,gl_account_number,prod_date'
		EXEC(@Sql_final)
	end

END

Else if @report_type='e' -- estimate report
BEGIN
	if @group_by='c'
		select
				counterparty_name as [Counterparty],
				dbo.fnacontractmonthformat(prod_date) as [ProdMonth],
				gl_account_number as [Account Code],
				gl_account_name as [Description],
				invoice_line_item as [Charge Type],
				round(cast(Volume as decimal(20,0)),0) as [Estimate Volume],
				case when Volume is null then '' else UOM end as [UOM],
				round(adjustment_amount,2) as [Estimate $]
		from
			#temp
		where isnull(finalized,'n')='n' and gl_account_number is not null
			
		order by 
			counterparty_name,prod_date
	else
		select
				gl_account_number as [Account Code],
				gl_account_name as [Description],
				dbo.fnacontractmonthformat(prod_date) as [ProdMonth],
				round(cast(sum(Volume) as decimal(20,0)),0) as [Estimate Volume],
				case when sum(Volume) is null then '' else  max(UOM) end as [UOM],
				round(sum(adjustment_amount),2) as [Estimate $]
		from
			#temp
		where isnull(finalized,'n')='n'		
		group by 
				gl_account_number,gl_account_name,dbo.fnacontractmonthformat(prod_date)
		order by 
			gl_account_name,dbo.fnacontractmonthformat(prod_date)
END

Else if @report_type='y' -- Year to Date Report
Begin
	if @group_by='c'
	begin

			set @Sql_Select='
			select
					T2.counterparty_name as [Counterparty],
					T2.gl_account_number as [Account Code],
					T2.gl_account_name as [Description],
					T2.invoice_line_item as [Charge Type],
					case when sum(T2.Volume) is null then '''' else max(T2.UOM) end as [UOM],'
			select 
			@Sql_Select=@Sql_Select+ 'round(sum(case when T2.prod_date='''+cast(prod_date as varchar)+''' then T2.Volume else NULL end),0) as [Actual Volume('+dbo.fnacontractmonthformat(prod_date)+')],
						round(SUM(case when T2.prod_date='''+cast(prod_date as varchar)+''' then T2.adjustment_amount else '''' end),2) as [Actual $('+dbo.fnacontractmonthformat(prod_date)+')],'
			from #temp	group by prod_date

		set @Sql_Select=@Sql_Select+
			 '  round(Sum(T2.Volume),0) as [YTD Volume],round(Sum(T2.adjustment_amount),2) as [YTD Actual $] from #temp GD 
			INNER JOIN (
				Select	counterparty_name,gl_account_number,gl_account_name,invoice_line_item,(UOM) UOM,prod_date,
				sum(volume) volume,sum(adjustment_amount) adjustment_amount
				from 
					#temp 
					where isnull(finalized,''n'')=''y''	
					group by 
						counterparty_name,gl_account_number,gl_account_name,invoice_line_item,prod_date,UOM
				
				) As T2
				on GD.counterparty_name=T2.counterparty_name
				and GD.gl_account_name=T2.gl_account_name
				and GD.invoice_line_item=T2.invoice_line_item
				and GD.prod_date=T2.prod_date

			group by 
				T2.counterparty_name,T2.gl_account_number,T2.gl_account_name,T2.invoice_line_item'
	end
	else
	begin
			set @Sql_Select='
			select
					T2.gl_account_number as [Account Code],
					T2.gl_account_name as [Description],
					case when sum(T2.Volume) is null then '''' else max(T2.UOM) end  as [UOM],'
			select 
			@Sql_Select=@Sql_Select+ 'SUM(case when T2.prod_date='''+cast(prod_date as varchar)+''' then T2.Volume else NULL end) as [Actual Volume('+dbo.fnacontractmonthformat(prod_date)+')],
						round(SUM(case when T2.prod_date='''+cast(prod_date as varchar)+''' then T2.adjustment_amount else 0 end),2) as [Actual $('+dbo.fnacontractmonthformat(prod_date)+')],'
			from #temp	group by prod_date

		set @Sql_Select=@Sql_Select+
			 '  Sum(T2.Volume) as [YTD Volume],round(Sum(T2.adjustment_amount),2) as [YTD Actual $] from #temp GD 
			INNER JOIN (
				Select	counterparty_name,gl_account_number,gl_account_name,invoice_line_item,UOM,prod_date,
				sum(volume) volume,sum(adjustment_amount) adjustment_amount
				from 
					#temp 
						where isnull(finalized,''n'')=''y''	
						group by 
						counterparty_name,gl_account_number,gl_account_name,invoice_line_item,UOM,prod_date
				
				) As T2
				on GD.counterparty_name=T2.counterparty_name
				and GD.gl_account_name=T2.gl_account_name
				and GD.invoice_line_item=T2.invoice_line_item
				and GD.prod_date=T2.prod_date
			group by 
				T2.gl_account_number,T2.gl_account_name'
	end
--print @Sql_Select
exec(@Sql_Select)

End
	
END
ELSE
BEGIN
	


set @Sql_Select='
	insert into #temp
	 select  
		distinct 
		sc.source_counterparty_id,
		civv.contract_id,
		ISNULL(sc1.counterparty_name,sc.counterparty_name) as counterparty_name,
		--su.source_uom_id as uom,  
		case	
		when (case 
		when civ.invoice_line_item_id=5259 then NULL
		when isnull(cfv.include_item,''n'')=''y'' then NULL
		--when isnull(cfv.uom_id,-1)=-1 then NULL
		when isnull(civ.value,0)=0 then NULL
		when cfv.volume is not null then cfv.volume
		when civv.book_entries=''m'' then   
		case when isnull(civ.manual_input,'''')='''' and civ.price_or_formula=''f''  then civv.allocationvolume  
		when civ.manual_input=''y'' then civ.volume end else  ih.invoice_volume * cg.volume_mult end) IS NUll then '''' else su.source_uom_id end,  
		civv.as_of_date,
		civv.prod_date,
		(case 
		when civ.invoice_line_item_id=5259 then NULL
		when isnull(cfv.include_item,''n'')=''y'' then NULL
		when NULLIF(cfv.volume,0) is not null then cfv.volume
	    when civv.book_entries=''m'' then   
		case when isnull(civ.manual_input,'''')='''' and civ.price_or_formula=''f''  then NULLIF(civv.allocationvolume,0)  
		when civ.manual_input=''y'' then NULLIF(civ.volume,0) end else  ih.invoice_volume * cg.volume_mult end)* ISNULL(conv.conversion_factor,1) as volume,
		case when civv.book_entries=''m'' then civ.value else ind.invoice_amount end adjustment_amount ,
		civ.manual_input,
		ili.description+''(''+ili.code+'')'' as invoice_line_item,
		case when a.as_of_date is null then ''n'' else civv.finalized end as finalzed,
		--civv.finalized as finalzed,
		ISNULL(gsm1.gl_account_number,gsm.gl_account_number),     
		ISNULL(gsm1.gl_account_name,gsm.gl_account_name),
		sd1.code,
		civ.invoice_line_item_id,
		case when a.as_of_date is null then ''n'' else civv.finalized end as finalzed,
		su.uom_name
		
	from   
		rec_generator rg 
		INNER JOIN 
		(select distinct sub_entity_id from #ssbm) ssbm on ssbm.sub_entity_id=rg.legal_entity_value_id
		INNER JOIN
		contract_group cg on cg.contract_id=rg.ppa_contract_id   
		inner JOIN
		calc_invoice_volume_variance civv on civv.counterparty_id=rg.ppa_counterparty_id 
		and (dbo.FNAGetContractMonth(civv.as_of_date)<=dbo.FNAGetContractMonth(''' + @as_of_date_from  +'''))
		--or (dbo.FNAGetContractMonth(civv.as_of_date)<=dbo.FNAGetContractMonth(''' + @as_of_date_from  +''') and dbo.FNAGetContractMonth(civv.as_of_date)>dateadd(month,-1,dbo.FNAGetContractMonth('''+@as_of_date_from+''')) and isnull(civv.finalized,''n'')=''y'') 
 		
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
		left join contract_charge_type cct on cct.contract_charge_type_id=cg.contract_charge_type_id
		left join contract_charge_type_detail cctd on cctd.contract_charge_type_id=cct.contract_charge_type_id
		and cctd.prod_type=
		case when ISNULL(cg.term_start,'''')='''' then ''p'' 
			when dbo.fnagetcontractmonth(cg.term_start)<=dbo.fnagetcontractmonth(civv.prod_date) then ''p''
		  else ''t'' end	and cctd.invoice_line_item_id=civ.invoice_line_item_id 		
	    left join adjustment_default_gl_codes adgc on adgc.default_gl_id =  case when ISNULL(civv.finalized,''n'')=''y'' then ISNULL(cgd.default_gl_id,cctd.default_gl_id)  else COALESCE(cgd.default_gl_id_estimates,cctd.default_gl_id_estimates,cgd.default_gl_id,cctd.default_gl_id) end 
		and adgc.fas_subsidiary_id=cg.sub_id  
		and ISNULL(adgc.estimated_actual,''z'')=case when adgc.estimated_actual is not null then case when  civv.finalized=''y'' then ''a'' else ''e'' end else ''z'' end
		left join adjustment_default_gl_codes adgc1 on adgc1.default_gl_id = civ.default_gl_id  
		and adgc1.fas_subsidiary_id=cg.sub_id  
		and ISNULL(adgc1.estimated_actual,''z'')=case when adgc1.estimated_actual is not null then case when  civv.finalized=''y'' then ''a'' else ''e'' end else ''z'' end
		LEFT JOIN invoice_lineitem_default_glcode ildg on ildg.invoice_line_item_id=civ.invoice_line_item_id   
		and ildg.sub_id=cg.sub_id  
		and ISNULL(ildg.estimated_actual,''z'')=case when ildg.estimated_actual is not null then case when  civv.finalized=''y'' then ''a'' else ''e'' end else ''z'' end
		left join adjustment_default_gl_codes adgc2 on adgc2.default_gl_id = ildg.default_gl_id  
		and adgc2.fas_subsidiary_id=cg.sub_id  
		and ISNULL(adgc2.estimated_actual,''z'')=case when adgc2.estimated_actual is not null then case when  civv.finalized=''y'' then ''a'' else ''e'' end else ''z'' end
		and ISNULL(ildg.estimated_actual,''z'')=ISNULL(adgc2.estimated_actual,''z'')
		left join adjustment_default_gl_codes_detail adgcd on adgcd.default_gl_id=COALESCE(adgc.default_gl_id,adgc1.default_gl_id,adgc2.default_gl_id)
		and dbo.FNAGetContractMonth(civv.as_of_date) between adgcd.term_start and adgcd.term_end
		left join gl_system_mapping gsm on gsm.gl_number_id=COALESCE(adgcd.debit_gl_number,adgc.debit_gl_number,adgc1.debit_gl_number,adgc2.debit_gl_number)	
		and gsm.gl_code1_value_id='+cast(@gl_account_group_code as varchar)+'
		left join gl_system_mapping gsm1 on gsm1.gl_number_id=COALESCE(adgcd.credit_gl_number,adgc.credit_gl_number,adgc1.credit_gl_number,adgc2.credit_gl_number)	
		and gsm1.gl_code1_value_id='+cast(@gl_account_group_code as varchar)+' 
		left join formula_editor fe on fe.formula_id=cgd.formula_id
		left join #calc_formula_value cfv on cfv.formula_id=fe.formula_id
		and dbo.fnagetcontractmonth(cfv.prod_date)=	dbo.FNAGetContractMonth(civv.prod_date)
		and cfv.as_of_date=civv.as_of_date and (cfv.volume is not null or cfv.include_item=''y'')
		left join source_uom su on su.source_uom_id = ISNULL(cfv.uom_id,civv.uom)
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
			--and dbo.FNAGetContractMonth(as_of_date) <= dbo.FNAGetContractMonth(''' + @as_of_date_from  +''')
			group by counterparty_id,prod_date,contract_id) a
 			on a.as_of_date=civv.as_Of_date and  a.counterparty_id=civv.counterparty_id 
		and a.contract_id=civv.contract_id and a.prod_date=civv.prod_date 
		LEFT JOIN static_data_value sd1 on sd1.value_id=rg.technology
	WHERE 1=1 
		  and isnull(civ.manual_input,''n'')=''n''	
	'
	+ case when @as_of_date_from is not null then ' And civv.as_of_date between '''+@as_of_date_from+''' and '''+@as_of_date_to+'''' else '' end
	+ case when @prod_date_from is not null then ' And civv.prod_date between '''+@prod_date_from+''' and '''+@prod_date_to+'''' else '' end
	+ case when @counterparty_id is not null then 
		' And (sc.source_counterparty_id='+cast(@counterparty_id as varchar)+' OR sc.netting_parent_counterparty_id='+cast(@counterparty_id as varchar)+')' else '' end
	+ case when @charge_type is not null then ' And civ.invoice_line_item_id='+cast(@charge_type as varchar) else '' end
	+ case when @customer_type is not null then ' And sc.type_of_entity='+cast(@customer_type as varchar) else '' end

	exec(@Sql_Select)
--select * from #temp where prod_date='2007-10-01'
--return
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
	[Counterparty] [varchar](100) COLLATE DATABASE_DEFAULT  ,
	[Account Code] [varchar](100) COLLATE DATABASE_DEFAULT  ,
	[Description] [varchar](100) COLLATE DATABASE_DEFAULT  ,
	[Production Month] Datetime ,
	[Charge Type] [varchar](100) COLLATE DATABASE_DEFAULT  ,
	[Unit of Measure] [varchar](250) COLLATE DATABASE_DEFAULT  ,
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
	Finalized char(1) COLLATE DATABASE_DEFAULT  NULL,
	as_of_date datetime null,
	current_volume float null,
	current_amount decimal(20,2) null,
	technology varchar(100) COLLATE DATABASE_DEFAULT ,
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
		su.uom_name as [Unit of Measure],
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
		tmp.invoice_line_item,su.uom_name,tmp.prod_date order by 
		tmp.counterparty_name,dbo.fnadateformat(tmp.prod_date) '

	
	exec(@Sql_Select+@sql_Where)


--####################################-------------------------------------------------------------------------
--- ######## insert Manual Entries
delete from #temp
set @Sql_Select='
	insert into #temp
	 select  
		--distinct
		sc.source_counterparty_id,
		civv.contract_id,
		ISNULL(sc1.counterparty_name,sc.counterparty_name) as counterparty_name,
		--su.source_uom_id as uom,  
		case when cgd.manual<>''y'' then ''''
		when (civ.volume  * cg.volume_mult) IS NUll then '''' else su.source_uom_id end,  
		civv.as_of_date,
		civ.prod_date,
		(civ.volume * cg.volume_mult )* ISNULL(conv.conversion_factor,1) as volume,
		civ.value adjustment_amount ,
		civ.manual_input,
		ili.description+''(''+ili.code+'')'' as invoice_line_item,
		civ.finalized  as finalzed,
		--civv.finalized as finalzed,
		ISNULL(gsm.gl_account_number,gsm1.gl_account_number),     
		ISNULL(gsm.gl_account_name,gsm1.gl_account_name),
		sd1.code,
		civ.invoice_line_item_id,
		COALESCE(civ1.finalized,civ.finalized,''n'') as finalized_actual,
		su.uom_name
	from   
		rec_generator rg 
		INNER JOIN 
		(select distinct sub_entity_id from #ssbm) ssbm on ssbm.sub_entity_id=rg.legal_entity_value_id
		INNER JOIN
		contract_group cg on cg.contract_id=rg.ppa_contract_id   
		inner JOIN
		calc_invoice_volume_variance civv on civv.counterparty_id=rg.ppa_counterparty_id 
		and (dbo.FNAGetContractMonth(civv.as_of_date)<=dbo.FNAGetContractMonth(''' + @as_of_date  +'''))
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
			left join contract_charge_type cct on cct.contract_charge_type_id=cg.contract_charge_type_id
		left join contract_charge_type_detail cctd on cctd.contract_charge_type_id=cct.contract_charge_type_id
		and cctd.prod_type=
		case when ISNULL(cg.term_start,'''')='''' then ''p'' 
			when dbo.fnagetcontractmonth(cg.term_start)<=dbo.fnagetcontractmonth(civv.prod_date) then ''p''
		  else ''t'' end	and cctd.invoice_line_item_id=civ.invoice_line_item_id 		
	    left join adjustment_default_gl_codes adgc on adgc.default_gl_id =  case when ISNULL(civv.finalized,''n'')=''y'' then ISNULL(cgd.default_gl_id,cctd.default_gl_id)  else COALESCE(cgd.default_gl_id_estimates,cctd.default_gl_id_estimates,cgd.default_gl_id,cctd.default_gl_id) end 
		and adgc.fas_subsidiary_id=cg.sub_id  
		and ISNULL(adgc.estimated_actual,''z'')=case when adgc.estimated_actual is not null then case when  civv.finalized=''y'' then ''a'' else ''e'' end else ''z'' end
		left join adjustment_default_gl_codes adgc1 on adgc1.default_gl_id = civ.default_gl_id  
		and adgc1.fas_subsidiary_id=cg.sub_id  
		and ISNULL(adgc1.estimated_actual,''z'')=case when adgc1.estimated_actual is not null then case when  civv.finalized=''y'' then ''a'' else ''e'' end else ''z'' end
		LEFT JOIN invoice_lineitem_default_glcode ildg on ildg.invoice_line_item_id=civ.invoice_line_item_id   
		and ildg.sub_id=cg.sub_id  
		and ISNULL(ildg.estimated_actual,''z'')=case when ildg.estimated_actual is not null then case when  civv.finalized=''y'' then ''a'' else ''e'' end else ''z'' end
		left join adjustment_default_gl_codes adgc2 on adgc2.default_gl_id = ildg.default_gl_id  
		and adgc2.fas_subsidiary_id=cg.sub_id  
		and ISNULL(adgc2.estimated_actual,''z'')=case when adgc2.estimated_actual is not null then case when  civv.finalized=''y'' then ''a'' else ''e'' end else ''z'' end
		and ISNULL(ildg.estimated_actual,''z'')=ISNULL(adgc2.estimated_actual,''z'')
		left join adjustment_default_gl_codes_detail adgcd on adgcd.default_gl_id=COALESCE(adgc.default_gl_id,adgc1.default_gl_id,adgc2.default_gl_id)
		and dbo.FNAGetContractMonth(civv.as_of_date) between adgcd.term_start and adgcd.term_end

		left join gl_system_mapping gsm on gsm.gl_number_id=COALESCE(adgcd.debit_gl_number,adgc.debit_gl_number,adgc1.debit_gl_number,adgc2.debit_gl_number)	
		and gsm.gl_code1_value_id='+cast(@gl_account_group_code as varchar)+'
		left join gl_system_mapping gsm1 on gsm1.gl_number_id=COALESCE(adgcd.credit_gl_number,adgc.credit_gl_number,adgc1.credit_gl_number,adgc2.credit_gl_number)	
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
	WHERE 1=1 
		    and isnull(civ.manual_input,''n'')=''y''	
--			and civ.calc_detail_id not in(select isnull(finalized_id,'''') from calc_invoice_volume civ inner join calc_invoice_volume_variance civv 
--			on civ.calc_id=civv.calc_id )		

			and civ.calc_detail_id not in(select isnull(finalized_id,'''') from calc_invoice_volume civ inner join calc_invoice_volume_variance civv 
			on civ.calc_id=civv.calc_id 
	 where  dbo.fnagetcontractmonth(civv.as_of_date)<dbo.FNAGetContractMonth(''' + @as_of_date  +'''))		

	'
	+ case when @as_of_date_from is not null then ' And civv.as_of_date between '''+@as_of_date_from+''' and '''+@as_of_date_to+'''' else '' end
	+ case when @prod_date_from is not null then ' And civv.prod_date between '''+@prod_date_from+''' and '''+@prod_date_to+'''' else '' end
	+ case when @counterparty_id is not null then 
		' And (sc.source_counterparty_id='+cast(@counterparty_id as varchar)+' OR sc.netting_parent_counterparty_id='+cast(@counterparty_id as varchar)+')' else '' end
	+ case when @charge_type is not null then ' And civ.invoice_line_item_id='+cast(@charge_type as varchar) else '' end
	+ case when @customer_type is not null then ' And sc.type_of_entity='+cast(@customer_type as varchar) else '' end
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
		su.uom_name as [Unit of Measure],
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
		tmp.invoice_line_item,su.uom_name,tmp.prod_date order by 
		tmp.counterparty_name,dbo.fnadateformat(tmp.prod_date) '
	
	--print @Sql_Select+@sql_Where
	exec(@Sql_Select+@sql_Where)

select 
	[Counterparty],
	[Production Month],
	[Charge Type],
	[Unit of Measure],
	cast(round(SUM([Estimate Reversal Volume]),0) as decimal(20,0)) as [Estimate Reversal Volume], 
	round(SUM(round([Estimate Reversal $],2,0)),2,0) [Estimate Reversal $], 
	cast(round(SUM([Prior Month Actual Volume]),0) as decimal(20,0)) [Prior Month Actual Volume],
	round(SUM(round([Prior Month Actual $],2,0)),2,0) [Prior Month Actual $], 
	cast(round(SUM([Current Month Estimate Volume]),0) as decimal(20,0)) [Current Month Estimate Volume],
	round(SUM(round([Current Month Estimates $],2,0)),2,0) [Current Month Estimates $], 
	cast(round(SUM([Variance Volume]),0) as decimal(20,0)) [Variance Volume], 
	round(SUM(round([Variance $],2,0)),2,0) [Variance $], 
	cast(round(SUM([Net Entry Volume]),0) as decimal(20,0)) [Net Entry Volume], 
	round(SUM(round([Net Entry $],2,0)),2,0) [Net Entry $]
from
(
	select 
		[Counterparty] ,
		dbo.fnacontractmonthformat([Production Month]) as [Production Month],
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
		and ([Estimate Reversal $]<>0 OR [Current Month Estimates $]<>0 OR [Prior Month Actual $]<>0)
		and ((isnull(finalized,'n')='y' and as_of_date between 
			dateadd(month,0,dbo.FNAGetContractMonth(@as_of_date)) and dateadd(month,0,dbo.FNAGetContractMonth(@as_of_date)))
		OR isnull(finalized,'n')='n' or isnull(finalized_actual,'n')='n')
	
) a
	group by [Counterparty],[Charge Type],[Production Month],[Unit of Measure]
	order by [Counterparty],[CHARGE TYPE],[Production Month]


END


if @is_batch = 1
begin
	exec spa_print '@str_batch_table'  
	 SELECT @str_batch_table=dbo.FNABatchProcess('u',@batch_process_id,@batch_report_param,GETDATE(),NULL,NULL)   
		   exec spa_print @str_batch_table
	 EXEC(@str_batch_table)                   
	        
	 SELECT @str_batch_table=dbo.FNABatchProcess('c',@batch_process_id,@batch_report_param,GETDATE(),'spa_create_revenue_report','Revenue Report')         
	 EXEC spa_print @str_batch_table
	 EXEC(@str_batch_table)        
	EXEC spa_print 'finsh spa_create_revenue_report'
	return
END

IF @enable_paging = 1
BEGIN
		IF @page_size IS NULL
		BEGIN
			set @sql_stmt='select count(*) TotalRow,'''+@batch_process_id +''' process_id  from '+ @temptablename
			EXEC spa_print @sql_stmt
			exec(@sql_stmt)
		END
		return
END 


END












