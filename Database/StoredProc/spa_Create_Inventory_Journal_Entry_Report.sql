

/****** Object:  StoredProcedure [dbo].[spa_Create_Inventory_Journal_Entry_Report]    Script Date: 09/14/2009 17:12:44 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_Create_Inventory_Journal_Entry_Report]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_Create_Inventory_Journal_Entry_Report]
/****** Object:  StoredProcedure [dbo].[spa_Create_Inventory_Journal_Entry_Report]    Script Date: 09/14/2009 17:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[spa_Create_Inventory_Journal_Entry_Report]   
	@as_of_date varchar(50),   
	@as_of_date_to varchar(50) = NULL,   
	@subsidiary_id varchar(max),   
	@strategy_id varchar(max) = NULL,   
	@book_id varchar(max) = NULL,   
	@summary_option varchar(100) = '2222',   
	@report_type varchar(100)= '111',   
	@link_id varchar(500) = null,   
	@counterparty_id NVARCHAR(1000) = null,   
	@final_prior_months varchar(1) = 'y',   
	@reverse_prior_months varchar(1) = 'n',   
	@state_value_id int = null,   
	@as_of_date_drill varchar(50) = null,   
	@production_month_drill varchar(50) = null,   
	@Counterparty varchar(500) = NULL,   
	@gl_number varchar(250) = NULL,   
	@uom_id int=null,   
	@entries varchar(100)=null,   
	@technology varchar(100)=null,   
	@batch_process_id varchar(50)=NULL,   
	@batch_report_param varchar(1000)=NULL,
	@jde_report_type char(1)='a',   -- 'a' first report 'b' second report, 'c' third report
	@report_date varchar(100)=null,
	@inventory_report CHAR(1)='n',
	@cpt_type VARCHAR(100) = NULL  
AS
SET NOCOUNT ON    
--   
--   
-- declare @as_of_date varchar(50), @as_of_date_to varchar(50),   
-- @subsidiary_id varchar(100), @strategy_id varchar(100),   
-- @book_id varchar(100),   
-- @summary_option char(1),   
-- @report_type char(1), --NULL or 'j' means journal entry, 't' means table format   
-- @link_id varchar(250)   
if @report_date is null
set @report_date=dbo.fnalpad(cast(datepart(mm,getdate()) as varchar),2,'0')+dbo.fnalpad(cast(datepart(dd,getdate()) as varchar),2,'0')+cast(datepart(yy,getdate()) as varchar)+dbo.fnalpad(cast(datepart(hh,getdate()) as varchar),2,'0')+dbo.fnalpad(cast(datepart(mi,getdate()) as varchar),2,'0')

--*****************For batch processing********************************   
  
DECLARE @str_batch_table varchar(max)   
SET @str_batch_table=''   
IF @batch_process_id is not null   
SELECT @str_batch_table=dbo.FNABatchProcess('s',@batch_process_id,@batch_report_param,NULL,NULL,NULL)   
--***********************************************   
  
Declare @Sql_Select varchar(MAX)   
DECLARE @insert_stmt varchar(MAX)   
DECLARE @insert_stmt1 varchar(MAX)   

---- Create Books
--CREATE TABLE #sub(sub_id int) 
--
--SET @Sql_Select=        
--
--	'INSERT INTO  #sub(sub_id)
--		SELECT 
--			distinct sub.entity_id fas_book_id 
--		FROM 
--			portfolio_hierarchy book (nolock) 
--			INNER JOIN Portfolio_hierarchy stra (nolock) ON book.parent_entity_id = stra.entity_id 
--			INNER JOIN Portfolio_hierarchy sub (nolock) ON stra.parent_entity_id = sub.entity_id 
--			LEFT OUTER JOIN source_system_book_map ssbm ON ssbm.fas_book_id = book.entity_id         
--		WHERE 1=1 '                 
--		+ CASE WHEN @subsidiary_id IS NOT NULL THEN ' AND stra.parent_entity_id IN  ( ' + CAST(@subsidiary_id AS VARCHAR) + ') ' ELSE '' END
--		+ CASE WHEN @strategy_id IS NOT NULL THEN ' AND book.parent_entity_id IN  ( ' + CAST(@strategy_id AS VARCHAR) + ') ' ELSE '' END
--		+ CASE WHEN @book_id IS NOT NULL THEN ' AND book.entity_id IN  ( ' + CAST(@book_id AS VARCHAR) + ') ' ELSE '' END
--
--	
--	EXEC(@Sql_Select)


CREATE TABLE [#temp_MTM_JEP] (   
	[as_of_date] [datetime] NOT NULL ,   
	[sub_entity_id] [int] NULL ,   
	[strategy_entity_id] [int] NULL ,   
	[book_entity_id] [int] NULL,   
	[link_id] [varchar] (500) COLLATE DATABASE_DEFAULT  NULL ,   
	[term_month] [datetime] NULL ,   
	[Gl_Number] [int] NULL ,   
	[Counterparty] varchar(500) COLLATE DATABASE_DEFAULT  NULL,   
	volume float,   
	uom_name varchar(100) COLLATE DATABASE_DEFAULT ,   
	[Debit] [float] NOT NULL ,   
	[Credit] [float] NULL,   
	[Amount] [float] NULL,   
	uom_id int NULL ,
	Subledger_code varchar(20) COLLATE DATABASE_DEFAULT  null,  
	counterparty_id int null ,
	line_item varchar(100) COLLATE DATABASE_DEFAULT  null ,
	show_volume char(1) COLLATE DATABASE_DEFAULT  null,
	line_volume float null, 
	line_uom_id int null,
	gl_number_netting INT NULL,
	netting VARCHAR(10) COLLATE DATABASE_DEFAULT  NULL ,
	default_gl_id INT,
	invoice_line_item_id INT,
	estimate_actual CHAR(1) COLLATE DATABASE_DEFAULT ,
	contract_id INT,
	netting_group_id INT,
	netting_group_name VARCHAR(100) COLLATE DATABASE_DEFAULT 
)   
  

  
--SET @Sql_From = ' FROM report_measurement_values_inventory RMV INNER JOIN fas_strategy FS ON RMV.strategy_entity_id = FS.fas_strategy_id'   
--SET @Sql_From = ' FROM #temp RMV '   
--=======Undiscounted==========================================================================================   
declare @convert_uom_id int   
  
----DEFAULT UOM VALUES-------   
------------------------------   
--set @convert_uom_id = 1 -- to MW   
  
  
  
--The following will retrieve the most recent cumulative values from the report measurement values table   
CREATE TABLE #temp   
(   
	as_of_date datetime,   
	sub_entity_id int,   
	strategy_entity_id int,   
	book_entity_id int,   
	link_id varchar(500) COLLATE DATABASE_DEFAULT ,   
	term_month datetime,   
	gl_code_hedge_st_asset int,   
	gl_code_hedge_st_liability int,   
	gl_settlement int,   
	gl_inventory int,   
	u_hedge_mtm float,   
	u_rec_mtm float,   
	u_hedge_st_asset float,   
	u_hedge_st_liability float,   
	u_pnl_inventory float,   
	u_pnl_settlement float,   
	Counterparty varchar(500) COLLATE DATABASE_DEFAULT ,   
	volume float,   
	uom_name varchar(100) COLLATE DATABASE_DEFAULT ,   
	debit_gl_number int,   
	credit_gl_number int,   
	adjustment_amount float,   
	deal_id varchar(50) COLLATE DATABASE_DEFAULT ,   
	type varchar(10) COLLATE DATABASE_DEFAULT ,   
	u_sur_expense float,   
	u_inv_expense float,   
	u_exp_expense float,   
	u_revenue float,   
	u_liability float,   
	gl_code_sur_expense int,   
	gl_code_inv_expense int,   
	gl_code_exp_expense int,   
	gl_code_u_revenue int,   
	gl_code_liability int,   
	u_hedge_st_asset_units float,   
	u_hedge_st_liability_units float,   
	u_pnl_inventory_units float,   
	u_pnl_settlement_units float,   
	u_sur_expense_units float,   
	u_inv_expense_units float,   
	u_exp_expense_units float,   
	u_revenue_units float,   
	u_liability_units float,   
	uom_id int,   
	debit_volume_multiplier int,   
	credit_volume_multiplier int,   
	adjustment_type int,   
	remarks varchar(100) COLLATE DATABASE_DEFAULT ,   
	counterparty_id int ,
	Subledger_code varchar(20) COLLATE DATABASE_DEFAULT  null , 
	line_item varchar(100) COLLATE DATABASE_DEFAULT  null,
	show_volume char(1) COLLATE DATABASE_DEFAULT  null ,
	debit_gl_number_minus int,   
	credit_gl_number_minus int,
	netting_debit_gl_number INT,
	netting_credit_gl_number INT,
	netting_debit_gl_number_minus INT,
	netting_credit_gl_number_minus INT,
	default_gl_id INT,
	invoice_line_item_id INT,
	estimate_actual CHAR(1) COLLATE DATABASE_DEFAULT ,
	contract_id INT,
	netting_group_id INT,
	netting_group_name VARCHAR(100) COLLATE DATABASE_DEFAULT     
)   
  
-- select *   
-- into #temp   
-- from report_measurement_values_inventory where 1 = 2   
  


if @reverse_prior_months = 'y'   
	BEGIN   
		set @as_of_date_to = @as_of_date   
		set @as_of_date = dbo.FNADateFormat(dateadd(mm, -1, @as_of_date))   
  
	END   

	IF @as_of_date_to IS NULL
		SET @as_of_date_to = @as_of_date

	create table #calc_formula_value 
	(
		invoice_line_item_id int,
		formula_id int,
		prod_date datetime,
		volume float,
		uom_id int	,
		as_of_date datetime
	)

	
	set @insert_stmt ='
		insert into 
				#calc_formula_value
		 select
			a.invoice_line_item_id,
			cgd.formula_id,
			cast(CAST(Year(civv.prod_date) As Varchar)+''-''+ CAST(month(civv.prod_date) As Varchar) +''-01'' as datetime) as prod_date,
			sum(case when show_value_id=1200 then (value) else NULL end) as volume,
			max(b.uom_id),
			civv.as_of_date
		from
			calc_invoice_volume_variance civv
			LEFT JOIN calc_invoice_volume a ON civv.calc_id=a.calc_id
			LEFT JOIN contract_group_detail cgd ON cgd.contract_id=civv.contract_id
				AND cgd.invoice_line_item_id=a.invoice_line_item_id
			LEFT JOIN formula_nested b on b.formula_group_id=cgd.formula_id
				--and a.seq_number=b.sequence_order
		where 1=1
			and civv.sub_id in('+@subsidiary_id+')
			and civv.as_of_date<='''+cast(@as_of_date as varchar)+''''+
			case when @counterparty_id is not null then ' And civv.counterparty_id in('+cast(@counterparty_id as varchar(500))+')' else '' end+
		'group by 
			a.invoice_line_item_id,cgd.formula_id,
			cast(CAST(Year(civv.prod_date) As Varchar)+''-''+ CAST(month(civv.prod_date) As Varchar) +''-01'' as datetime),
			civv.as_of_date
		'	

	exec(@insert_stmt)

------------###################### Find out the charge types for Annual Interruptions to show after finalized
--

	create table #calc_invoice_volume_annual_rollover
	(	
		counterparty_id int,
		contract_id int,
		as_of_date datetime,
		prod_date datetime,
		[value] float,
		calc_id int,
		invoice_line_item_id int,
		manual_input char(1) COLLATE DATABASE_DEFAULT ,
		finalized char(1) COLLATE DATABASE_DEFAULT ,
		price_or_formula char(1) COLLATE DATABASE_DEFAULT ,
		uom_id int
	)

	set @Sql_Select =
		'
		insert into #calc_invoice_volume_annual_rollover
		select 
			a.counterparty_id,
			a.contract_id,
			--a.as_of_date,
			--a.prod_date,
			dbo.fnagetcontractmonth('''+cast(@as_of_date as varchar)+''') as_of_date,
			dbo.fnagetcontractmonth('''+cast(@as_of_date as varchar)+''') prod_date,
			civ.value,
			civ.calc_id,
			civ.invoice_line_item_id,
			civ.manual_input,
			a.finalized,
			civ.price_or_formula,
			civ.uom_id

		from
		(
		select 
			max(civv.as_of_date) as_of_date,
			max(civv.prod_date) prod_date,
			civv.counterparty_id,civv.contract_id,civ.invoice_line_item_id,
			max(isnull(civ1.finalized,''n'')) finalized

		from
			calc_invoice_volume civ 
			join calc_invoice_volume_variance civv on civv.calc_id=civ.calc_id
			join contract_group_detail cgd on cgd.contract_id=civv.contract_id
			and civ.invoice_line_item_id=cgd.invoice_line_item_id
			and cgd.hideininvoice=''f'' -- find the charge_type which need to show in invoice only after finalized
			--and month(civ.prod_date) between cgd.int_begin_month and cgd.int_end_month
			and civ.prod_date between 
				cast(cast(case when cgd.int_begin_month<cgd.int_end_month then year(civ.prod_date) else 
						  case when month(civ.prod_date)<cgd.int_begin_month then year(civ.prod_date)-1 else year(civ.prod_date) end end as varchar)+''-''+cast(cgd.int_begin_month as varchar)+''-01'' as datetime)
			and	cast(cast(case when cgd.int_begin_month<cgd.int_end_month then year(civ.prod_date) else 
						  case when month(civ.prod_date)<cgd.int_begin_month then year(civ.prod_date) else year(civ.prod_date)+1	 end end as varchar)+''-''+cast(cgd.int_end_month as varchar)+''-01'' as datetime)

			and civv.as_of_date<=dbo.fnagetcontractmonth('''+cast(@as_of_date as varchar)+''')
			'+case when @counterparty_id is not null then ' and (civv.counterparty_id in('+cast(@counterparty_id as varchar(500))+'))' else '' end +' 
			left join calc_invoice_volume_Variance civv1 on 
			civv1.counterparty_id=civv.counterparty_id and civv1.contract_id=civv.contract_id
			and civv1.prod_date<dbo.fnagetcontractmonth('''+cast(@as_of_date as varchar)+''')
			left join calc_invoice_volume civ1 on 
			civ1.calc_id=civv1.calc_id
			and civ1.invoice_line_item_id=civ.invoice_line_item_id
			group by civv.counterparty_id,civv.contract_id,civ.invoice_line_item_id
		) a
		join calc_invoice_volume_variance civv on civv.counterparty_id=a.counterparty_id
			 and civv.contract_id=a.contract_id
			 and civv.prod_date=a.prod_date
			 and civv.as_of_date=a.as_of_date	
		join calc_invoice_volume civ on civv.calc_id=civ.calc_id and civ.invoice_line_item_id=a.invoice_line_item_id
		where a.finalized=''n'''


	--print @Sql_Select
	exec(@Sql_Select)
-----------------###############################################

	set @insert_stmt = '
		insert into #temp   
		select 
			rmv.as_of_date, rmv.sub_entity_id, rmv.strategy_entity_id, rmv.book_entity_id,   
			-- cast(rmv.link_id as varchar) link_id,   
			cast(sdh.source_deal_header_id as varchar) link_id,   
			rmv.term_month, rmv.gl_code_hedge_st_asset, rmv.gl_code_hedge_st_liability,   
			rmv.gl_settlement, rmv.gl_inventory, rmv.u_hedge_mtm, rmv.u_rec_mtm,   
			rmv.u_hedge_st_asset,   
			rmv.u_hedge_st_liability,   
			rmv.u_pnl_inventory,   
			rmv.u_pnl_settlement,   
			sc.counterparty_name Counterparty,   
			case when ((sdd.buy_sell_flag = ''b'' and rmv.u_hedge_mtm > 0) OR   
			(sdd.buy_sell_flag = ''s'' and rmv.u_hedge_mtm < 0)) then -1 else 1 end *   
			sdd.deal_volume,   
			su.uom_name,   
			NULL, NULL, NULL,   
			sdh.deal_id,		
			case when (dbo.FNAGetContractMonth(rmv.term_month) = dbo.FNAGetContractMonth(rmv.as_of_date)) then ''Cur''   
			else ''Adj'' + case when (sdd.buy_sell_flag = ''s'' and sdh.ext_deal_id is not null) then ''-SR''   
			when (isnull(sdh.status_value_id, -1) = 5170) then ''-I''   
			when (isnull(sdh.status_value_id, -1) = 5179) then ''-IG''   
			when (isnull(sdh.status_value_id, -1) In (5177, 5178)) then ''-AG''   
			-- when (isnull(sdh.status_value_id, 5171) IN (5171, 5172)) then ''-A''   
			when (isnull(sdh.assignment_type_value_id, -1) = 5173) then ''-SC''   
			else '''' end   
			end as Type,   
			u_sur_expense, u_inv_expense, u_exp_expense, u_revenue, u_liability,   
			gl_code_sur_expense, gl_code_inv_expense, gl_code_exp_expense, gl_code_u_revenue, gl_code_liability,   
			u_hedge_st_asset_units, u_hedge_st_liability_units, u_pnl_inventory_units, u_pnl_settlement_units,   
			u_sur_expense_units, u_inv_expense_units, u_exp_expense_units, u_revenue_units, u_liability_units,   
			rmv.uom_id, 1 debit_volume_multiplier, 1 credit_volume_multiplier, NULL adjustment_type,NULL,   
			sc.source_counterparty_id  ,null,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,''a'',sdh.contract_id,NULL,NULL 
		from 
			report_measurement_values_inventory rmv left join   
			source_deal_detail sdd ON sdd.source_deal_detail_id = rmv.link_id left outer join   
			source_deal_header sdh on sdh.source_deal_header_id = sdd.source_deal_header_id left outer join   
			source_counterparty sc on sc.source_counterparty_id = sdh.counterparty_id left outer join   
			source_uom su on su.source_uom_id = ' + case when @convert_uom_id is null then '-1' else cast(@convert_uom_id as varchar) end + ' left outer join   
			rec_generator rg on rg.generator_id = sdh.generator_id ' +   
 
		case when (@summary_option = '6666') then   
		' where cast(dbo.FNAGetContractMonth(as_of_date) AS DATETIME) <= cast(dbo.FNAGetContractMonth(''' + @as_of_date +''') AS DATETIME)'   
		  
		when (@as_of_date_to is null) then   
		' where dbo.FNAGetContractMonth(as_of_date) = dbo.FNAGetContractMonth(''' + @as_of_date +''')'   
		  
		else   
		' where dbo.FNAGetContractMonth(as_of_date) between dbo.FNAGetContractMonth(''' + @as_of_date +''') AND   
		dbo.FNAGetContractMonth(''' + @as_of_date_to +''') '   
		-- ' where as_of_date between CONVERT(DATETIME, ''' + @as_of_date +''', 102) AND   
		-- CONVERT(DATETIME, ''' + @as_of_date_to +''', 102) '   
		end   
		If @technology is not null   
		SET @insert_stmt = @insert_stmt +' AND rg.technology in('+@technology+')'   
		IF @subsidiary_id IS NOT NULL   
		SET @insert_stmt = @insert_stmt + ' AND (RMV.sub_entity_id IN(' + @subsidiary_id + ' ))'   
		IF @strategy_id IS NOT NULL   
		SET @insert_stmt = @insert_stmt + ' AND (RMV.strategy_entity_id IN(' + @strategy_id + ' ))'   
		IF @book_id IS NOT NULL   
		SET @insert_stmt = @insert_stmt + ' AND (RMV.book_entity_id IN(' + @book_id + ')) '   
		  
		IF @link_id IS NOT NULL   
		SET @insert_stmt = @insert_stmt + ' AND RMV.link_id IN (' + @link_id + ') '   
		  
		IF @counterparty_id IS NOT NULL   
		SET @insert_stmt = @insert_stmt + ' AND sdh.counterparty_id IN (' + cast(@counterparty_id as NVARCHAR(1000)) + ') '   
		  
		IF @state_value_id IS NOT NULL   
		SET @insert_stmt = @insert_stmt + ' AND isnull(sdh.state_value_id, rg.state_value_id) IN (' + cast(@state_value_id as varchar) + ') '   
		  
		  
	-- EXEC spa_print @insert_stmt   
	exec (@insert_stmt)   


		--Insert Manual Entries   
	SET @insert_stmt =   
		'INSERT INTO #temp   
		select 
			as_of_date, cp.fas_subsidiary_id, NULL, NULL,   
			''Manual-'' + sc.counterparty_name + ''-'' + dbo.FNAContractMonthFormat(as_of_date) as link_id,   
			term_month, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, sc.counterparty_name Counterparty,   
			volume, su.uom_name,   
			isnull(ime.debit_gl_number, isnull(adgc.debit_gl_number, adgc2.debit_gl_number)) debit_gl_number,   
			isnull(ime.credit_gl_number, isnull(adgc.credit_gl_number, adgc2.credit_gl_number)) credit_gl_number,   
			adjustment_amount adjustment_amount,   
			'''' deal_id, ''Adj-M'' type,   
			NULL u_sur_expense, NULL u_inv_expense, NULL u_exp_expense, NULL u_revenue, NULL u_liability,   
			NULL gl_code_sur_expense, NULL gl_code_inv_expense, NULL gl_code_exp_expense, NULL gl_code_u_revenue,   
			NULL gl_code_liability,   
			  
			NULL u_hedge_st_asset_units, NULL u_hedge_st_liability_units, NULL u_pnl_inventory_units,   
			NULL u_pnl_settlement_units, NULL u_sur_expense_units, NULL u_inv_expense_units,   
			NULL u_exp_expense_units, NULL u_revenue_units, NULL u_liability_units, ime.uom_id,   
			adgc.debit_volume_multiplier, adgc.credit_volume_multiplier, ime.adjustment_type adjustment_type,NULL   
			,sc.source_counterparty_id ,null,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,''a'',NULL,NULL,NULL  
		from 
			inventory_manual_entries ime inner join   
			(select max(legal_entity_value_id) fas_subsidiary_id, ppa_counterparty_id from rec_generator group by ppa_counterparty_id) cp on   
			ime.counterparty_id = cp.ppa_counterparty_id inner join   
			source_counterparty sc on sc.source_counterparty_id = ime.counterparty_id inner join   
			source_uom su on su.source_uom_id = ime.uom_id left outer join   
			adjustment_default_gl_codes adgc on adgc.counterparty_id = ime.counterparty_id and   
			isnull(adgc.type, -1) = isnull(ime.type, -1) and   
			isnull(adgc.adjustment_type_id, -1) = isnull(ime.adjustment_type, -1) and   
			adgc.fas_subsidiary_id = cp.fas_subsidiary_id left outer join   
			(select fas_subsidiary_id, max(debit_gl_number) debit_gl_number, max(credit_gl_number) credit_gl_number,   
			type, adjustment_type_id   
			from adjustment_default_gl_codes   
			group by fas_subsidiary_id, type, adjustment_type_id) adgc2 on isnull(adgc2.type, -1) = isnull(ime.type, -1) and   
			isnull(adgc2.adjustment_type_id, -1) = isnull(ime.adjustment_type, -1) and   
			adgc2.fas_subsidiary_id = cp.fas_subsidiary_id 
		WHERE ' +   
		  
		case when (@as_of_date_to is null) then   
		  
		' dbo.FNAGetContractMonth(as_of_date) = dbo.FNAGetContractMonth(''' + @as_of_date +''')'   
		else   
		' dbo.FNAGetContractMonth(as_of_date) between dbo.FNAGetContractMonth(''' + @as_of_date +''') AND   
		dbo.FNAGetContractMonth(''' + @as_of_date_to +''') ' end +   
		case when (@counterparty_id IS NOT NULL) then   
		' AND ime.counterparty_id IN (' + cast(@counterparty_id as NVARCHAR(1000)) + ') ' else '' end   
		  
		--print @insert_stmt   
		exec (@insert_stmt)

----------------------------------------------------------------------   
----- Insert Prior Manual Entries from settlement   
		SET @insert_stmt =   
		'   
		INSERT INTO   #temp  
		select 
			distinct 
			dbo.FNAGetContractMonth(''' + @as_of_date + ''') as_of_date,   
			-- cast(rmv.link_id as varchar) link_id,
			rg.legal_entity_value_id, NULL, NULL,   
			ISNULL(sc1.counterparty_name,sc.counterparty_name) + '' - '' + ISNULL(al.code,ili.code) as link_id,   
			civ.prod_date term_month, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,   
			ISNULL(sc1.counterparty_name,sc.counterparty_name) Counterparty,   
			case when isnull(civ.include_volume,''n'')<>''y'' then '''' else
			(civ.volume * cg.volume_mult) * ISNULL(conv.conversion_factor,1) end as volume,   
			su.uom_name as uom,   
			COALESCE(adgcd.debit_gl_number,adgc.debit_gl_number,adgc_s.debit_gl_number,adgc1.debit_gl_number,adgc1_s.debit_gl_number,adgc2.debit_gl_number,adgc2_s.debit_gl_number) debit_gl_number,   
			COALESCE(adgcd.credit_gl_number,adgc.credit_gl_number,adgc_s.credit_gl_number,adgc1.credit_gl_number,adgc1_s.credit_gl_number,adgc2.credit_gl_number,adgc2_s.credit_gl_number) credit_gl_number,   
			civ.value adjustment_amount,   
			'''' deal_id, ''Adj-S'' type,   
			NULL u_sur_expense, NULL u_inv_expense, NULL u_exp_expense, NULL u_revenue, NULL u_liability,   
			NULL gl_code_sur_expense, NULL gl_code_inv_expense, NULL gl_code_exp_expense, NULL gl_code_u_revenue,   
			NULL gl_code_liability,   
			NULL u_hedge_st_asset_units, NULL u_hedge_st_liability_units, NULL u_pnl_inventory_units,   
			NULL u_pnl_settlement_units, NULL u_sur_expense_units, NULL u_inv_expense_units,   
			NULL u_exp_expense_units, NULL u_revenue_units, NULL u_liability_units,   
			case when (civ.volume * cg.volume_mult ) IS NUll then '''' else su.source_uom_id end,   
			COALESCE(adgcd.debit_volume_multiplier,adgc.debit_volume_multiplier,adgc_s.debit_volume_multiplier), 
			COALESCE(adgcd.credit_volume_multiplier,adgc.credit_volume_multiplier,adgc_s.credit_volume_multiplier),   
			ISNULL(adgc.adjustment_type_id,adgc_s.adjustment_type_id) adjustment_type,
			civ.remarks,   
			sc.source_counterparty_id ,cg.Subledger_code,ISNULL(al.description,ili.description),cgd.manual,
			COALESCE(adgc.debit_gl_number_minus,adgc_s.debit_gl_number_minus,adgc1.debit_gl_number_minus,adgc1_s.debit_gl_number_minus,adgc2.debit_gl_number_minus,adgc2_s.debit_gl_number_minus) debit_gl_number,   
			COALESCE(adgc.credit_gl_number_minus,adgc_s.credit_gl_number_minus,adgc1.credit_gl_number_minus,adgc1_s.credit_gl_number_minus,adgc2.credit_gl_number_minus,adgc2_s.credit_gl_number_minus) credit_gl_number,
			CASE WHEN COALESCE(cga.apply_netting_rule,cg.neting_rule,''n'') = ''n'' THEN NULL ELSE COALESCE(adgc.netting_debit_gl_number,adgc_s.netting_debit_gl_number,adgc1.netting_debit_gl_number,adgc1_s.netting_debit_gl_number,adgc2.netting_debit_gl_number,adgc2_s.netting_debit_gl_number) END netting_debit_gl_number,   
			CASE WHEN COALESCE(cga.apply_netting_rule,cg.neting_rule,''n'') = ''n'' THEN NULL ELSE COALESCE(adgc.netting_credit_gl_number,adgc_s.netting_credit_gl_number,adgc1.netting_credit_gl_number,adgc1_s.netting_credit_gl_number,adgc2.netting_credit_gl_number,adgc2_s.netting_credit_gl_number) END netting_credit_gl_number,
			CASE WHEN COALESCE(cga.apply_netting_rule,cg.neting_rule,''n'') = ''n'' THEN NULL ELSE COALESCE(adgc.netting_debit_gl_number_minus,adgc_s.netting_debit_gl_number_minus,adgc1.netting_debit_gl_number_minus,adgc1_s.netting_debit_gl_number_minus,adgc2.netting_debit_gl_number_minus,adgc2_s.netting_debit_gl_number_minus) END netting_debit_gl_number_minus,   
			CASE WHEN COALESCE(cga.apply_netting_rule,cg.neting_rule,''n'') = ''n'' THEN NULL ELSE COALESCE(adgc.netting_credit_gl_number_minus,adgc_s.netting_credit_gl_number_minus,adgc1.netting_credit_gl_number_minus,adgc1_s.netting_credit_gl_number_minus,adgc2.netting_credit_gl_number_minus,adgc2_s.netting_credit_gl_number_minus) END netting_credit_gl_number_minus,
			COALESCE(adgc.default_gl_id,adgc_s.default_gl_id,adgc1.default_gl_id,adgc1_s.default_gl_id,adgc2.default_gl_id,adgc2_s.default_gl_id),
			civ.invoice_line_item_id,CASE WHEN ISNULL(civ.finalized,''n'')=''y'' THEN ''a'' ELSE ''e'' END estimate_actual,civv.contract_id,netting_group.netting_group_id,netting_group.netting_group_name 
		from    
			calc_invoice_volume_variance civv
			OUTER APPLY(SELECT ngdc.source_contract_id contract_id,ng.netting_group_id,ng.netting_group_name FROM netting_group ng INNER JOIN netting_group_detail ngd ON ng.netting_group_id = ngd.netting_group_id
						INNER JOIN netting_group_detail_contract ngdc ON ngdc.netting_group_detail_id=ngd.netting_group_id WHERE ngd.source_counterparty_id= civv.counterparty_id
						AND ng.netting_group_id = ISNULL(civv.netting_group_id,-1)
						and civv.prod_date BETWEEN ISNULL(ng.effective_date,''1900-01-01'') AND ISNULL(ng.end_date,''9999-01-01'')
			) netting_group	
			INNER JOIN contract_group cg on cg.contract_id=ISNULL(netting_group.contract_id,civv.contract_id)   
			'+   
			case when (@as_of_date_to is null) then   
			' and dbo.FNAGetContractMonth(civv.as_of_date) < dbo.FNAGetContractMonth(''' + @as_of_date +''')'   
			else   
			' and dbo.FNAGetContractMonth(civv.as_of_date) < dbo.FNAGetContractMonth(''' + @as_of_date_to +''') ' end +   
			' left join calc_invoice_volume civ on civv.calc_id=civ.calc_id
			--LEFT JOIN calc_invoice_volume_detail civd on civd.calc_id=civv.calc_id
			--		 AND civd.invoice_line_item_id=civ.invoice_line_item_id
			LEFT JOIN   
			static_data_value ili on ili.value_id = civ.invoice_line_item_id inner join   
			source_counterparty sc on sc.source_counterparty_id = civv.counterparty_id   
			left join contract_group_detail cgd on cgd.contract_id = cg.contract_id   
			and civ.invoice_line_item_id=cgd.invoice_line_item_id   
			and prod_type= case when ISNULL(cg.term_start,'''')='''' then ''p''   
			when dbo.FNAGETCONTRACTMONTH(cg.term_start)<=dbo.FNAGETCONTRACTMONTH(civv.prod_date) then ''p''   
			else ''t'' end   
			left join contract_charge_type cct on cct.contract_charge_type_id=cg.contract_charge_type_id
			left join contract_charge_type_detail cctd on cctd.contract_charge_type_id=cct.contract_charge_type_id
			and civ.invoice_line_item_id=cctd.invoice_line_item_id   
			and cctd.prod_type=
			case when ISNULL(cg.term_start,'''')='''' then ''p'' 
				 when dbo.fnagetcontractmonth(cg.term_start)<=dbo.fnagetcontractmonth(civv.prod_date) then ''p''
				 else ''t'' end '	
			SET @insert_stmt1='   
			LEFT JOIN adjustment_default_gl_codes adgc on ISNULL(adgc.fas_subsidiary_id,-1)=ISNULL(cg.sub_id,-1)   
				AND adgc.default_gl_id = case when ISNULL(civ.finalized,''n'')=''y'' then ISNULL(cgd.default_gl_id,cctd.default_gl_id)
											  else COALESCE(cgd.default_gl_id_estimates,cctd.default_gl_id_estimates,cgd.default_gl_id,cctd.default_gl_id) end
				AND ISNULL(adgc.estimated_actual,''z'')=case when adgc.estimated_actual is not null then  case when ISNULL(civ.finalized,''n'')=''y''  then ''a'' else ''e'' end  else ''z'' end

			LEFT JOIN adjustment_default_gl_codes adgc_s on adgc_s.fas_subsidiary_id IS NULL
				AND adgc_s.default_gl_id = case when ISNULL(civ.finalized,''n'')=''y'' then ISNULL(cgd.default_gl_id,cctd.default_gl_id)
											  else COALESCE(cgd.default_gl_id_estimates,cctd.default_gl_id_estimates,cgd.default_gl_id,cctd.default_gl_id) end
				AND ISNULL(adgc_s.estimated_actual,''z'')=case when adgc_s.estimated_actual is not null then  case when ISNULL(civ.finalized,''n'')=''y''  then ''a'' else ''e'' end  else ''z'' end


			LEFT JOIN adjustment_default_gl_codes adgc1 ON ISNULL(adgc1.fas_subsidiary_id,-1)=ISNULL(cg.sub_id,-1)
				AND adgc1.default_gl_id = case when ISNULL(civ.finalized,''n'')=''y'' then civ.default_gl_id else civ.default_gl_id_estimate end   
				AND ISNULL(adgc1.estimated_actual,''z'')=case when adgc1.estimated_actual is not null then  case when ISNULL(civ.finalized,''n'')=''y''  then ''a'' else ''e'' end  else ''z'' end

			LEFT JOIN adjustment_default_gl_codes adgc1_s ON adgc1.fas_subsidiary_id IS NULL
				AND adgc1_s.default_gl_id = case when ISNULL(civ.finalized,''n'')=''y'' then civ.default_gl_id else civ.default_gl_id_estimate end   
				AND ISNULL(adgc1_s.estimated_actual,''z'')=case when adgc1_s.estimated_actual is not null then  case when ISNULL(civ.finalized,''n'')=''y''  then ''a'' else ''e'' end  else ''z'' end

			LEFT JOIN invoice_lineitem_default_glcode ildg ON ISNULL(ildg.sub_id,-1)=ISNULL(cg.sub_id,-1)
				AND ildg.invoice_line_item_id=civ.invoice_line_item_id
				AND ISNULL(ildg.estimated_actual,''z'')=case when ildg.estimated_actual is not null then  case when ISNULL(civ.finalized,''n'')=''y''  then ''a'' else ''e'' end  else ''z'' end

			LEFT JOIN invoice_lineitem_default_glcode ildg_s ON ildg_s.sub_id IS NULL
				AND ildg_s.invoice_line_item_id=civ.invoice_line_item_id	
				AND ISNULL(ildg_s.estimated_actual,''z'')=case when ildg_s.estimated_actual is not null then  case when ISNULL(civ.finalized,''n'')=''y''  then ''a'' else ''e'' end  else ''z'' end

			LEFT JOIN adjustment_default_gl_codes adgc2 on adgc2.default_gl_id = ISNULL(ildg.default_gl_id,ildg_s.default_gl_id)  
				AND ISNULL(adgc2.fas_subsidiary_id,-1)=ISNULL(cg.sub_id,-1)   
				--AND ISNULL(adgc2.estimated_actual,''z'')=COALESCE(ildg.estimated_actual,ildg_s.estimated_actual,''z'')
				AND ISNULL(adgc2.estimated_actual,''z'')=case when adgc2.estimated_actual is not null then case when ISNULL(civ.finalized,''n'')=''y''  then ''a'' else ''e'' end  else ''z'' end

			LEFT JOIN adjustment_default_gl_codes adgc2_s on adgc2_s.default_gl_id = ISNULL(ildg.default_gl_id,ildg_s.default_gl_id)   
				AND adgc2_s.fas_subsidiary_id IS NULL  
				--AND ISNULL(adgc2_s.estimated_actual,''z'')=COALESCE(ildg.estimated_actual,ildg_s.estimated_actual,''z'')
				AND ISNULL(adgc2_s.estimated_actual,''z'')=case when adgc2_s.estimated_actual is not null then case when ISNULL(civ.finalized,''n'')=''y''  then ''a'' else ''e'' end  else ''z'' end

			LEFT JOIN adjustment_default_gl_codes_detail adgcd on adgcd.default_gl_id=COALESCE(adgc.default_gl_id,adgc_s.default_gl_id,adgc1.default_gl_id,adgc1_s.default_gl_id,adgc2.default_gl_id,adgc2_s.default_gl_id)   
				AND dbo.FNAGetContractMonth(civv.prod_date) between adgcd.term_start and adgcd.term_end   
			LEFT JOIN source_uom su on su.source_uom_id = COALESCE(adgcd.uom_id,adgc.uom_id,adgc_s.uom_id,adgc1.uom_id,adgc1_s.uom_id,adgc2.uom_id,adgc2_s.uom_id)   
			LEFT JOIN rec_volume_unit_conversion Conv ON   
			conv.from_source_uom_id= civ.uom_id   
			and conv.to_source_uom_id = COALESCE(adgcd.uom_id,adgc.uom_id,adgc_s.uom_id,adgc1.uom_id,adgc1_s.uom_id,adgc2.uom_id,adgc2_s.uom_id)  
			and conv.state_value_id is null and conv.assignment_type_value_id is null   
			and conv.curve_id is null   
			LEFT JOIN source_counterparty sc1 on sc1.source_counterparty_id=sc.netting_parent_counterparty_id   
			LEFT JOIN rec_generator rg on rg.generator_id=civv.generator_id
			LEFT JOIN counterparty_contract_address cga ON cga.contract_id = cg.contract_id AND sc.source_counterparty_id = cga.counterparty_id
			LEFT JOIN  static_data_value al on al.value_id = cgd.alias 
			WHERE 1=1   
			and isnull(civ.finalized,''n'') <> ''y''   
			and isnull(civ.manual_input,''n'')=''y''   
			and civ.calc_detail_id not in(select isnull(finalized_id,'''') from calc_invoice_volume civ inner join calc_invoice_volume_variance civv   
			on civ.calc_id=civv.calc_id   
		where 
			dbo.fnagetcontractmonth(civv.as_of_date)<=dbo.FNAGetContractMonth(''' + @as_of_date_to +'''))   
		' +   
		case when (@counterparty_id IS NOT NULL) then   
		' And (sc.source_counterparty_id in('+cast(@counterparty_id as NVARCHAR(1000))+') OR sc.netting_parent_counterparty_id in('+cast(@counterparty_id as NVARCHAR(1000))+'))' else '' end   
		  
		+ case when (isnull(@technology,'')<>'') then   
		' AND rg.technology in('+@technology+')' else ' ' end   
		  
		+ case when (@entries='22') then   
		' AND civ.finalized=''y'' ' when @entries ='e' THEN  ' AND (civ.finalized<>''y'' or civv.finalized is null) ' ELSE '' end   
		--+CASE WHEN  @subsidiary_id IS NOT NULL THEN ' AND (ISNULL(civd.sub_id,rg.legal_entity_value_id) IN(' + @subsidiary_id + ' ))' ELSE '' END
  
--print @insert_stmt   
--print @insert_stmt1


if (@inventory_report='n')
	exec(@insert_stmt+@insert_stmt1)





-- Insert current manual input settlement   
  
	SET @insert_stmt =   
	'   
	INSERT INTO   
	#temp   
		select distinct 
			dbo.FNAGetContractMonth(''' + @as_of_date + ''') as_of_date,  
			-- cast(rmv.link_id as varchar) link_id, 
			ISNULL(rg.legal_entity_value_id,-1), 
			NULL, NULL,   
			ISNULL(sc1.counterparty_name,sc.counterparty_name) + '' - '' + ili.code as link_id,   
			civ.prod_date term_month, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,   
			ISNULL(sc1.counterparty_name,sc.counterparty_name) Counterparty,   
			case when isnull(civ.include_volume,''n'')<>''y'' then '''' else (civ.volume * cg.volume_mult) * ISNULL(conv.conversion_factor,1) end as volume,   
			su.uom_name as uom,   
			COALESCE(adgc1.debit_gl_number,adgc1_s.debit_gl_number) debit_gl_number,   
			COALESCE(adgc1.credit_gl_number,adgc1_s.credit_gl_number) credit_gl_number,   
			civ.value adjustment_amount,   
			'''' deal_id, ''Adj-S'' type,   
			NULL u_sur_expense, NULL u_inv_expense, NULL u_exp_expense, NULL u_revenue, NULL u_liability,   
			NULL gl_code_sur_expense, NULL gl_code_inv_expense, NULL gl_code_exp_expense, NULL gl_code_u_revenue,   
			NULL gl_code_liability,   
			NULL u_hedge_st_asset_units, NULL u_hedge_st_liability_units, NULL u_pnl_inventory_units,   
			NULL u_pnl_settlement_units, NULL u_sur_expense_units, NULL u_inv_expense_units,   
			NULL u_exp_expense_units, NULL u_revenue_units, NULL u_liability_units,   
			case when (civ.volume * cg.volume_mult ) IS NUll then '''' else su.source_uom_id end,   
			COALESCE(adgc1.debit_volume_multiplier,adgc1_s.debit_volume_multiplier), 
			COALESCE(adgc1.credit_volume_multiplier,adgc1_s.credit_volume_multiplier),   
			ISNULL(adgc1.adjustment_type_id,adgc1_s.adjustment_type_id) adjustment_type,
			civ.remarks,   
			sc.source_counterparty_id ,cg.Subledger_code,ili.description,''n'' manual,
			COALESCE(adgc1.debit_gl_number_minus,adgc1_s.debit_gl_number_minus) debit_gl_number,   
			COALESCE(adgc1.credit_gl_number_minus,adgc1_s.credit_gl_number_minus) credit_gl_number,
			CASE WHEN COALESCE(cga.apply_netting_rule,cg.neting_rule,''n'') = ''n'' THEN NULL ELSE COALESCE(adgc1.netting_debit_gl_number,adgc1_s.netting_debit_gl_number) END netting_debit_gl_number,   
			CASE WHEN COALESCE(cga.apply_netting_rule,cg.neting_rule,''n'') = ''n'' THEN NULL ELSE COALESCE(adgc1.netting_credit_gl_number,adgc1_s.netting_credit_gl_number) END netting_credit_gl_number,
			CASE WHEN COALESCE(cga.apply_netting_rule,cg.neting_rule,''n'') = ''n'' THEN NULL ELSE COALESCE(adgc1.netting_debit_gl_number_minus,adgc1_s.netting_debit_gl_number_minus) END netting_debit_gl_number_minus,   
			CASE WHEN COALESCE(cga.apply_netting_rule,cg.neting_rule,''n'') = ''n'' THEN NULL ELSE COALESCE(adgc1.netting_credit_gl_number_minus,adgc1_s.netting_credit_gl_number_minus) END netting_credit_gl_number_minus,
			COALESCE(adgc1.default_gl_id,adgc1_s.default_gl_id),
			civ.invoice_line_item_id,CASE WHEN ISNULL(civ.finalized,''n'')=''y'' THEN ''a'' ELSE ''e'' END estimate_actual,civv.contract_id,netting_group.netting_group_id,netting_group.netting_group_name  
		FROM    
			calc_invoice_volume_variance civv 
			OUTER APPLY(SELECT ngdc.source_contract_id contract_id,ng.netting_group_id,ng.netting_group_name FROM netting_group ng INNER JOIN netting_group_detail ngd ON ng.netting_group_id = ngd.netting_group_id
						INNER JOIN netting_group_detail_contract ngdc ON ngdc.netting_group_detail_id=ngd.netting_group_id WHERE ngd.source_counterparty_id= civv.counterparty_id
						AND ng.netting_group_id = ISNULL(civv.netting_group_id,-1)
						and civv.prod_date BETWEEN ISNULL(ng.effective_date,''1900-01-01'') AND ISNULL(ng.end_date,''9999-01-01'')
			) netting_group	
			INNER JOIN contract_group cg on cg.contract_id=ISNULL(netting_group.contract_id,civv.contract_id)   
			'+   
			case when (@as_of_date_to is null) then   
			' and (civv.as_of_date) <= (''' + @as_of_date +''')'   
			else   
			' and(civv.as_of_date) between (''' + @as_of_date +''') and (''' + @as_of_date_to +''') ' end +   
			' 
			LEFT JOIN calc_invoice_volume civ on civv.calc_id=civ.calc_id  
			--LEFT JOIN calc_invoice_volume_detail civd on civd.calc_id=civv.calc_id
			--		 AND civd.invoice_line_item_id=civ.invoice_line_item_id
			LEFT JOIN static_data_value ili on ili.value_id = civ.invoice_line_item_id inner join   
			source_counterparty sc on sc.source_counterparty_id = civv.counterparty_id   '
			
		SET @insert_stmt1 =   
			'LEFT JOIN adjustment_default_gl_codes adgc1 ON ISNULL(adgc1.fas_subsidiary_id,-1)=ISNULL(cg.sub_id,-1)
				AND adgc1.default_gl_id = case when ISNULL(civ.finalized,''n'')=''y'' then civ.default_gl_id else civ.default_gl_id_estimate end   
				AND ISNULL(adgc1.estimated_actual,''z'')=case when adgc1.estimated_actual is not null then  case when ISNULL(civ.finalized,''n'')=''y''  then ''a'' else ''e'' end  else ''z'' end
			LEFT JOIN adjustment_default_gl_codes adgc1_s ON adgc1.fas_subsidiary_id IS NULL
				AND adgc1_s.default_gl_id = case when ISNULL(civ.finalized,''n'')=''y'' then civ.default_gl_id else civ.default_gl_id_estimate end   
				AND ISNULL(adgc1_s.estimated_actual,''z'')=case when adgc1_s.estimated_actual is not null then  case when ISNULL(civ.finalized,''n'')=''y''  then ''a'' else ''e'' end  else ''z'' end
			LEFT JOIN source_uom su on su.source_uom_id = COALESCE(adgc1.uom_id,adgc1_s.uom_id)   
			LEFT JOIN rec_volume_unit_conversion Conv ON   
				conv.from_source_uom_id= civ.uom_id   
				and conv.to_source_uom_id = COALESCE(adgc1.uom_id,adgc1_s.uom_id)  
				and conv.state_value_id is null and conv.assignment_type_value_id is null   
				and conv.curve_id is null   
			LEFT JOIN source_counterparty sc1 on sc1.source_counterparty_id=sc.netting_parent_counterparty_id   
			LEFT JOIN rec_generator rg on rg.generator_id=civv.generator_id
			LEFT JOIN counterparty_contract_address cga ON cga.contract_id = cg.contract_id AND sc.source_counterparty_id = cga.counterparty_id

		WHERE 1=1   
			and isnull(civ.manual_input,''n'')=''y''   
			and civ.calc_detail_id not in(select isnull(finalized_id,'''') from calc_invoice_volume civ inner join calc_invoice_volume_variance civv   
			on civ.calc_id=civv.calc_id   
			where dbo.fnagetcontractmonth(civv.as_of_date)<=dbo.FNAGetContractMonth(''' + @as_of_date_to +'''))   
			' +   
			case when (@counterparty_id IS NOT NULL) then   
			' And (sc.source_counterparty_id in('+cast(@counterparty_id as NVARCHAR(1000))+') OR sc.netting_parent_counterparty_id in('+cast(@counterparty_id as NVARCHAR(1000))+'))' else '' end   
			  
			+ case when (isnull(@technology,'')<>'') then   
			' AND rg.technology in('+@technology+')' else ' ' end   
			  
			+ case when (@entries='22') then   
			' AND civ.finalized=''y'' ' WHEN @entries='11' THEN ' AND (ISNULL(civ.finalized,'''')<>''y'') ' ELSE '' end   
			 --+CASE WHEN  @subsidiary_id IS NOT NULL THEN ' AND (ISNULL(civd.sub_id,rg.legal_entity_value_id) IN(' + @subsidiary_id + ' ))'  ELSE '' END
	


	--print @insert_stmt   
if (@inventory_report='n')
	exec(@insert_stmt+@insert_stmt1)   


--######################################   


--Insert Prior Settlement Entries   
		SET @insert_stmt =   
		'   
		INSERT INTO #temp   
		select 
			distinct 
			dbo.FNAGetContractMonth(''' + @as_of_date + ''') as_of_date,
			ISNULL(rg.legal_entity_value_id,-1), 
			NULL, NULL,   
			ISNULL(sc1.counterparty_name,sc.counterparty_name) + '' - '' + ISNULL(al.code,ili.code) as link_id,   
			civ.prod_date term_month, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,   
			ISNULL(sc1.counterparty_name,sc.counterparty_name) Counterparty,   
			(case 
			when ISNULL(cgd.manual,cctd.manual)<>''y'' then ''''
			when civ.volume is not null then civ.volume
			when civv.book_entries=''m'' then   
			case when isnull(civ.manual_input,'''')='''' and civ.price_or_formula=''f'' then civv.allocationvolume   
			when civ.manual_input=''y'' then civ.volume end else ih.invoice_volume * cg.volume_mult end) * ISNULL(conv.conversion_factor,1) as volume,   
			su.uom_name as uom,   
			COALESCE(adgcd.debit_gl_number,adgc.debit_gl_number,adgc_s.debit_gl_number,adgc1.debit_gl_number,adgc1_s.debit_gl_number,adgc2.debit_gl_number,adgc2_s.debit_gl_number) debit_gl_number,   
			COALESCE(adgcd.credit_gl_number,adgc.credit_gl_number,adgc_s.credit_gl_number,adgc1.credit_gl_number,adgc1_s.credit_gl_number,adgc2.credit_gl_number,adgc2_s.credit_gl_number) credit_gl_number,   
			case when civv.book_entries=''m'' then isnull(civar.value,civ.value) else ind.invoice_amount end adjustment_amount,   
			'''' deal_id, ''Adj-S'' type,   
			NULL u_sur_expense, NULL u_inv_expense, NULL u_exp_expense, NULL u_revenue, NULL u_liability,   
			NULL gl_code_sur_expense, NULL gl_code_inv_expense, NULL gl_code_exp_expense, NULL gl_code_u_revenue,   
			NULL gl_code_liability,   
			NULL u_hedge_st_asset_units, NULL u_hedge_st_liability_units, NULL u_pnl_inventory_units,   
			NULL u_pnl_settlement_units, NULL u_sur_expense_units, NULL u_inv_expense_units,   
			NULL u_exp_expense_units, NULL u_revenue_units, NULL u_liability_units,   
			case when (case when civv.book_entries=''m'' then   
			case when isnull(civ.manual_input,'''')='''' and civ.price_or_formula=''f'' then civv.allocationvolume   
			when civ.manual_input=''y'' then civ.volume end else ih.invoice_volume * cg.volume_mult end) IS NUll then '''' else su.source_uom_id end,   
			COALESCE(adgcd.debit_volume_multiplier,adgc.debit_volume_multiplier,adgc_s.debit_volume_multiplier), 
			COALESCE(adgcd.credit_volume_multiplier,adgc.credit_volume_multiplier,adgc_s.credit_volume_multiplier),   
			ISNULL(adgc.adjustment_type_id,adgc_s.adjustment_type_id) adjustment_type,
			civ.remarks,
			sc.source_counterparty_id ,
			cg.Subledger_code,
			ISNULL(al.description,ili.description),
			cgd.manual,
			COALESCE(adgc.debit_gl_number_minus,adgc_s.debit_gl_number_minus,adgc1.debit_gl_number_minus,adgc1_s.debit_gl_number_minus,adgc2.debit_gl_number_minus,adgc2_s.debit_gl_number_minus) debit_gl_number,   
			COALESCE(adgc.credit_gl_number_minus,adgc_s.credit_gl_number_minus,adgc1.credit_gl_number_minus,adgc1_s.credit_gl_number_minus,adgc2.credit_gl_number_minus,adgc2_s.credit_gl_number_minus) credit_gl_number  
			CASE WHEN COALESCE(cga.apply_netting_rule,cg.neting_rule,''n'') = ''n'' THEN NULL ELSE COALESCE(adgc.netting_debit_gl_number,adgc_s.netting_debit_gl_number,adgc1.netting_debit_gl_number,adgc1_s.netting_debit_gl_number,adgc2.netting_debit_gl_number,adgc2_s.netting_debit_gl_number) END netting_debit_gl_number,   
			CASE WHEN COALESCE(cga.apply_netting_rule,cg.neting_rule,''n'') = ''n'' THEN NULL ELSE COALESCE(adgc.netting_credit_gl_number,adgc_s.netting_credit_gl_number,adgc1.netting_credit_gl_number,adgc1_s.netting_credit_gl_number,adgc2.netting_credit_gl_number,adgc2_s.netting_credit_gl_number) END netting_credit_gl_number,
			CASE WHEN COALESCE(cga.apply_netting_rule,cg.neting_rule,''n'') = ''n'' THEN NULL ELSE COALESCE(adgc.netting_debit_gl_number_minus,adgc_s.netting_debit_gl_number_minus,adgc1.netting_debit_gl_number_minus,adgc1_s.netting_debit_gl_number_minus,adgc2.netting_debit_gl_number_minus,adgc2_s.netting_debit_gl_number_minus) END netting_debit_gl_number_minus,   
			CASE WHEN COALESCE(cga.apply_netting_rule,cg.neting_rule,''n'') = ''n'' THEN NULL ELSE COALESCE(adgc.netting_credit_gl_number_minus,adgc_s.netting_credit_gl_number_minus,adgc1.netting_credit_gl_number_minus,adgc1_s.netting_credit_gl_number_minus,adgc2.netting_credit_gl_number_minus,adgc2_s.netting_credit_gl_number_minus) END netting_credit_gl_number_minus,
			COALESCE(adgc.default_gl_id,adgc_s.default_gl_id,adgc1.default_gl_id,adgc1_s.default_gl_id,adgc2.default_gl_id,adgc2_s.default_gl_id),
			civ.invoice_line_item_id,CASE WHEN ISNULL(civ.finalized,''n'')=''y'' THEN ''a'' ELSE ''e'' END estimate_actual,civv.contract_id,netting_group.netting_group_id,netting_group.netting_group_name  
		FROM  '
		SET @insert_stmt1= 
			' calc_invoice_volume_variance civv
			OUTER APPLY(SELECT ngdc.source_contract_id contract_id,ng.netting_group_id,ng.netting_group_name FROM netting_group ng INNER JOIN netting_group_detail ngd ON ng.netting_group_id = ngd.netting_group_id
						INNER JOIN netting_group_detail_contract ngdc ON ngdc.netting_group_detail_id=ngd.netting_group_id WHERE ngd.source_counterparty_id= civv.counterparty_id
						AND ng.netting_group_id = ISNULL(civv.netting_group_id,-1)
						and civv.prod_date BETWEEN ISNULL(ng.effective_date,''1900-01-01'') AND ISNULL(ng.end_date,''9999-01-01'')
			) netting_group	
			INNER JOIN contract_group cg on cg.contract_id=ISNULL(netting_group.contract_id,civv.contract_id)   
			'+   
			case when (@as_of_date_to is null) then   
			' and dbo.FNAGetContractMonth(civv.as_of_date) < dbo.FNAGetContractMonth(''' + @as_of_date +''')'   
			else   
			' and dbo.FNAGetContractMonth(civv.as_of_date) < dbo.FNAGetContractMonth(''' + @as_of_date_to +''') ' end +   
			'   
			INNER JOIN
				(select max(as_of_date) as_of_date,counterparty_id,prod_date,contract_id   
					from calc_invoice_volume_variance where 1=1 '+   
					case when (@as_of_date_to is null) then   
					' and dbo.FNAGetContractMonth(as_of_date) <= dbo.FNAGetContractMonth(''' + @as_of_date +''')'   
					else   
					' and dbo.FNAGetContractMonth(as_of_date) <= dbo.FNAGetContractMonth(''' + @as_of_date_to +''') ' end +   
					'   
					group by counterparty_id,prod_date,contract_id
				) a   
				on a.as_of_date=civv.as_Of_date and a.counterparty_id=civv.counterparty_id
				AND a.contract_id=civv.contract_id and a.prod_date=civv.prod_date   
			LEFT JOIN calc_invoice_volume civ on civv.calc_id=civ.calc_id   
			--LEFT JOIN calc_invoice_volume_detail civd on civd.calc_id=civv.calc_id
			--		 AND civd.invoice_line_item_id=civ.invoice_line_item_id
			LEFT JOIN #calc_invoice_volume_annual_rollover civar on civar.counterparty_id=civv.counterparty_id
				and civar.contract_id=civv.contract_id 
				and civar.prod_date=civv.prod_date	
			LEFT JOIN invoice_header ih on ih.invoice_id=civv.invoice_id   
			LEFT JOIN invoice_detail ind on ind.invoice_id=ih.invoice_id and ind.invoice_line_item_id=isnull(civar.invoice_line_item_id,civ.invoice_line_item_id) 
			LEFT JOIN static_data_value ili on ili.value_id = isnull(civar.invoice_line_item_id,civ.invoice_line_item_id)
			INNER JOIN source_counterparty sc on sc.source_counterparty_id = civv.counterparty_id
			LEFT JOIN contract_group_detail cgd on cgd.contract_id = cg.contract_id   
				and isnull(civar.invoice_line_item_id,civ.invoice_line_item_id)=cgd.invoice_line_item_id   
				and prod_type= case when ISNULL(cg.term_start,'''')='''' then ''p''   
									when dbo.FNAGETCONTRACTMONTH(cg.term_start)<=dbo.FNAGETCONTRACTMONTH(civv.prod_date) then ''p''   
									else ''t'' end   
			LEFT JOIN contract_charge_type cct on cct.contract_charge_type_id=cg.contract_charge_type_id
			LEFT JOIN contract_charge_type_detail cctd on cctd.contract_charge_type_id=cct.contract_charge_type_id
				and isnull(civar.invoice_line_item_id,civ.invoice_line_item_id)=cctd.invoice_line_item_id   
				and cctd.prod_type=case when ISNULL(cg.term_start,'''')='''' then ''p'' 
										when dbo.fnagetcontractmonth(cg.term_start)<=dbo.fnagetcontractmonth(civv.prod_date) then ''p''
										else ''t'' end	

			LEFT JOIN adjustment_default_gl_codes adgc on ISNULL(adgc.fas_subsidiary_id,-1)=ISNULL(cg.sub_id,-1)   
				AND adgc.default_gl_id = case when ISNULL(civ.finalized,''n'')=''y'' then ISNULL(cgd.default_gl_id,cctd.default_gl_id)
											  else COALESCE(cgd.default_gl_id_estimates,cctd.default_gl_id_estimates,cgd.default_gl_id,cctd.default_gl_id) end
				AND ISNULL(adgc.estimated_actual,''z'')=case when adgc.estimated_actual is not null then  case when ISNULL(civ.finalized,''n'')=''y''  then ''a'' else ''e'' end  else ''z'' end

			LEFT JOIN adjustment_default_gl_codes adgc_s on adgc_s.fas_subsidiary_id IS NULL
				AND adgc_s.default_gl_id = case when ISNULL(civ.finalized,''n'')=''y'' then ISNULL(cgd.default_gl_id,cctd.default_gl_id)
											  else COALESCE(cgd.default_gl_id_estimates,cctd.default_gl_id_estimates,cgd.default_gl_id,cctd.default_gl_id) end
				AND ISNULL(adgc_s.estimated_actual,''z'')=case when adgc_s.estimated_actual is not null then  case when ISNULL(civ.finalized,''n'')=''y''  then ''a'' else ''e'' end  else ''z'' end


			LEFT JOIN adjustment_default_gl_codes adgc1 ON ISNULL(adgc1.fas_subsidiary_id,-1)=ISNULL(cg.sub_id,-1)
				AND adgc1.default_gl_id = case when ISNULL(civ.finalized,''n'')=''y'' then civ.default_gl_id else civ.default_gl_id_estimate end   
				AND ISNULL(adgc1.estimated_actual,''z'')=case when adgc1.estimated_actual is not null then  case when ISNULL(civ.finalized,''n'')=''y''  then ''a'' else ''e'' end  else ''z'' end

			LEFT JOIN adjustment_default_gl_codes adgc1_s ON adgc1.fas_subsidiary_id IS NULL
				AND adgc1_s.default_gl_id = case when ISNULL(civ.finalized,''n'')=''y'' then civ.default_gl_id else civ.default_gl_id_estimate end   
				AND ISNULL(adgc1_s.estimated_actual,''z'')=case when adgc1_s.estimated_actual is not null then  case when ISNULL(civ.finalized,''n'')=''y''  then ''a'' else ''e'' end  else ''z'' end

			LEFT JOIN invoice_lineitem_default_glcode ildg ON ISNULL(ildg.sub_id,-1)=ISNULL(cg.sub_id,-1)
				AND ildg.invoice_line_item_id=isnull(civar.invoice_line_item_id,civ.invoice_line_item_id)	
				AND ISNULL(ildg.estimated_actual,''z'')=case when ildg.estimated_actual is not null then  case when ISNULL(civ.finalized,''n'')=''y''  then ''a'' else ''e'' end  else ''z'' end

			LEFT JOIN invoice_lineitem_default_glcode ildg_s ON ildg_s.sub_id IS NULL
				AND ildg_s.invoice_line_item_id=isnull(civar.invoice_line_item_id,civ.invoice_line_item_id)	
				AND ISNULL(ildg_s.estimated_actual,''z'')=case when ildg_s.estimated_actual is not null then  case when ISNULL(civ.finalized,''n'')=''y''  then ''a'' else ''e'' end  else ''z'' end

			LEFT JOIN adjustment_default_gl_codes adgc2 on adgc2.default_gl_id = ISNULL(ildg.default_gl_id,ildg_s.default_gl_id)  
				AND ISNULL(adgc2.fas_subsidiary_id,-1)=ISNULL(cg.sub_id,-1)   
				--AND ISNULL(adgc2.estimated_actual,''z'')=COALESCE(ildg.estimated_actual,ildg_s.estimated_actual,''z'')
				AND ISNULL(adgc2.estimated_actual,''z'')=case when adgc2.estimated_actual is not null then case when ISNULL(civ.finalized,''n'')=''y''  then ''a'' else ''e'' end  else ''z'' end

			LEFT JOIN adjustment_default_gl_codes adgc2_s on adgc2_s.default_gl_id = ISNULL(ildg.default_gl_id,ildg_s.default_gl_id)   
				AND adgc2_s.fas_subsidiary_id IS NULL  
				--AND ISNULL(adgc2_s.estimated_actual,''z'')=COALESCE(ildg.estimated_actual,ildg_s.estimated_actual,''z'')
				AND ISNULL(adgc2_s.estimated_actual,''z'')=case when adgc2_s.estimated_actual is not null then case when ISNULL(civ.finalized,''n'')=''y''  then ''a'' else ''e'' end  else ''z'' end

			LEFT JOIN adjustment_default_gl_codes_detail adgcd on adgcd.default_gl_id=COALESCE(adgc.default_gl_id,adgc_s.default_gl_id,adgc1.default_gl_id,adgc1_s.default_gl_id,adgc2.default_gl_id,adgc2_s.default_gl_id)   
				AND dbo.FNAGetContractMonth(civv.prod_date) between adgcd.term_start and adgcd.term_end   
			LEFT JOIN source_uom su on su.source_uom_id = COALESCE(adgcd.uom_id,adgc.uom_id,adgc_s.uom_id,adgc1.uom_id,adgc1_s.uom_id,adgc2.uom_id,adgc2_s.uom_id)   
			LEFT JOIN rec_volume_unit_conversion Conv ON conv.from_source_uom_id=
				case when civv.book_entries=''m'' then   
								case when isnull(isnull(civar.manual_input,civ.manual_input),'''')='''' and isnull(civar.price_or_formula,civ.price_or_formula)=''f'' then civv.uom   
									 when isnull(civar.manual_input,civ.manual_input)=''y'' then isnull(civar.uom_id,civ.uom_id) end   
						 else ih.uom_id end   
				AND conv.to_source_uom_id = COALESCE(adgcd.uom_id,adgc.uom_id,adgc_s.uom_id,adgc1.uom_id,adgc1_s.uom_id,adgc2.uom_id,adgc2_s.uom_id)   
				AND conv.state_value_id is null and conv.assignment_type_value_id is null   
				AND conv.curve_id is null   
			LEFT JOIN source_counterparty sc1 on sc1.source_counterparty_id=sc.netting_parent_counterparty_id   
			LEFT JOIN formula_editor fe on fe.formula_id=ISNULL(cgd.formula_id,cctd.formula_id)
			LEFT JOIN #calc_formula_value cfv on cfv.formula_id=fe.formula_id
				AND dbo.fnagetcontractmonth(cfv.prod_date)=	dbo.FNAGetContractMonth(civv.prod_date)
				AND cfv.as_of_date=civv.as_of_date
			LEFT JOIN rec_generator rg on civv.generator_id=rg.generator_id
			LEFT JOIN counterparty_contract_address cga ON cga.contract_id = cg.contract_id AND sc.source_counterparty_id = cga.counterparty_id
			LEFT JOIN  static_data_value al on al.value_id = cgd.alias
		WHERE 1=1   
			AND isnull(civ.finalized,'''') <> ''y''   
			AND isnull(civ.manual_input,''n'')=''n''   
			--AND ISNULL(cgd.hideininvoice,''s'') in (''s'') 
			' 
			+ CASE WHEN @cpt_type IS NOT NULL THEN ' AND sc.int_ext_flag=''' + @cpt_type + '''' ELSE '' END +
			case when (@counterparty_id IS NOT NULL) then   
			' And (sc.source_counterparty_id in('+cast(@counterparty_id as NVARCHAR(1000))+') OR sc.netting_parent_counterparty_id in('+cast(@counterparty_id as NVARCHAR(1000))+'))' else '' end   
			+ case when (isnull(@technology,'')<>'') then   
			' AND rg.technology in('+@technology+')' else ' ' end   
			+ case when (@entries='22') then   
			' AND ISNULL(civ.finalized,'''')=''y'' ' else   
			' ' END
			--+CASE WHEN @subsidiary_id IS NOT NULL THEN ' AND (ISNULL(civd.sub_id,rg.legal_entity_value_id) IN(' + @subsidiary_id + ' )) '  ELSE '' END  
		  
	--print @insert_stmt
	--print @insert_stmt1

	--if (@inventory_report='n')
	--exec(@insert_stmt+@insert_stmt1)   

	

--Insert Current Settlement Entries   
		SET @insert_stmt =   
		' INSERT INTO #temp   
		select distinct 
			dbo.FNAGetContractMonth(''' + @as_of_date + ''') as_of_date,
			ISNULL(rg.legal_entity_value_id,-1), NULL, NULL,   
			ISNULL(sc1.counterparty_name,sc.counterparty_name) + '' - '' + ISNULL(al.code,ili.code) as link_id,   
			civ.prod_date term_month, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,   
			ISNULL(sc1.counterparty_name,sc.counterparty_name) Counterparty,   
			(case 
			when ISNULL(cgd.manual,cctd.manual)<>''y'' then ''''
			when civ.volume is not null then civ.volume
			when civv.book_entries=''m'' then   
			case when isnull(civ.manual_input,'''')='''' and isnull(civar.price_or_formula,civ.price_or_formula)=''f'' then civv.allocationvolume   
			when civ.manual_input=''y'' then civ.volume end else ih.invoice_volume * cg.volume_mult end) * ISNULL(conv.conversion_factor,1) as volume,   
			su.uom_name as uom,   
			COALESCE(adgcd.debit_gl_number,adgc.debit_gl_number,adgc_s.debit_gl_number,adgc1.debit_gl_number,adgc1_s.debit_gl_number,adgc2.debit_gl_number,adgc2_s.debit_gl_number) debit_gl_number,   
			COALESCE(adgcd.credit_gl_number,adgc.credit_gl_number,adgc_s.credit_gl_number,adgc1.credit_gl_number,adgc1_s.credit_gl_number,adgc2.credit_gl_number,adgc2_s.credit_gl_number) credit_gl_number,   
			case when civv.book_entries=''m'' then isnull(civar.value,civ.value) else ind.invoice_amount end adjustment_amount,   
			'''' deal_id, ''Adj-S'' type,   
			NULL u_sur_expense, NULL u_inv_expense, NULL u_exp_expense, NULL u_revenue, NULL u_liability,   
			NULL gl_code_sur_expense, NULL gl_code_inv_expense, NULL gl_code_exp_expense, NULL gl_code_u_revenue,   
			NULL gl_code_liability,   
			NULL u_hedge_st_asset_units, NULL u_hedge_st_liability_units, NULL u_pnl_inventory_units,   
			NULL u_pnl_settlement_units, NULL u_sur_expense_units, NULL u_inv_expense_units,   
			NULL u_exp_expense_units, NULL u_revenue_units, NULL u_liability_units,   
			case when (case when civv.book_entries=''m'' then   
			case when isnull(civ.manual_input,'''')='''' and civ.price_or_formula=''f'' then civv.allocationvolume   
			when civ.manual_input=''y'' then civ.volume end else ih.invoice_volume * cg.volume_mult end) IS NUll then '''' else su.source_uom_id end,   
			COALESCE(adgcd.debit_volume_multiplier,adgc.debit_volume_multiplier,adgc_s.debit_volume_multiplier), 
			COALESCE(adgcd.credit_volume_multiplier,adgc.credit_volume_multiplier,adgc_s.credit_volume_multiplier),   
			ISNULL(adgc.adjustment_type_id,adgc_s.adjustment_type_id) adjustment_type,
			NULL,sc.source_counterparty_id ,cg.Subledger_code,ISNULL(al.description,ili.description),cgd.manual,
			COALESCE(adgc.debit_gl_number_minus,adgc_s.debit_gl_number_minus,adgc1.debit_gl_number_minus,adgc1_s.debit_gl_number_minus,adgc2.debit_gl_number_minus,adgc2_s.debit_gl_number_minus) debit_gl_number,   
			COALESCE(adgc.credit_gl_number_minus,adgc_s.credit_gl_number_minus,adgc1.credit_gl_number_minus,adgc1_s.credit_gl_number_minus,adgc2.credit_gl_number_minus,adgc2_s.credit_gl_number_minus) credit_gl_number,
			CASE WHEN COALESCE(cga.apply_netting_rule,cg.neting_rule,''n'') = ''n'' THEN NULL ELSE COALESCE(adgc.netting_debit_gl_number,adgc_s.netting_debit_gl_number,adgc1.netting_debit_gl_number,adgc1_s.netting_debit_gl_number,adgc2.netting_debit_gl_number,adgc2_s.netting_debit_gl_number) END netting_debit_gl_number,   
			CASE WHEN COALESCE(cga.apply_netting_rule,cg.neting_rule,''n'') = ''n'' THEN NULL ELSE COALESCE(adgc.netting_credit_gl_number,adgc_s.netting_credit_gl_number,adgc1.netting_credit_gl_number,adgc1_s.netting_credit_gl_number,adgc2.netting_credit_gl_number,adgc2_s.netting_credit_gl_number) END netting_credit_gl_number,
			CASE WHEN COALESCE(cga.apply_netting_rule,cg.neting_rule,''n'') = ''n'' THEN NULL ELSE COALESCE(adgc.netting_debit_gl_number_minus,adgc_s.netting_debit_gl_number_minus,adgc1.netting_debit_gl_number_minus,adgc1_s.netting_debit_gl_number_minus,adgc2.netting_debit_gl_number_minus,adgc2_s.netting_debit_gl_number_minus) END netting_debit_gl_number_minus,   
			CASE WHEN COALESCE(cga.apply_netting_rule,cg.neting_rule,''n'') = ''n'' THEN NULL ELSE COALESCE(adgc.netting_credit_gl_number_minus,adgc_s.netting_credit_gl_number_minus,adgc1.netting_credit_gl_number_minus,adgc1_s.netting_credit_gl_number_minus,adgc2.netting_credit_gl_number_minus,adgc2_s.netting_credit_gl_number_minus) END netting_credit_gl_number_minus,
			COALESCE(adgc.default_gl_id,adgc_s.default_gl_id,adgc1.default_gl_id,adgc1_s.default_gl_id,adgc2.default_gl_id,adgc2_s.default_gl_id),
			civ.invoice_line_item_id,CASE WHEN ISNULL(civ.finalized,''n'')=''y'' THEN ''a'' ELSE ''e'' END estimate_actual,civv.contract_id,netting_group.netting_group_id,netting_group.netting_group_name  
		FROM   
			calc_invoice_volume_variance civv
			OUTER APPLY(SELECT ngdc.source_contract_id contract_id,ng.netting_group_id,ng.netting_group_name FROM netting_group ng INNER JOIN netting_group_detail ngd ON ng.netting_group_id = ngd.netting_group_id
						INNER JOIN netting_group_detail_contract ngdc ON ngdc.netting_group_detail_id=ngd.netting_group_id WHERE ngd.source_counterparty_id= civv.counterparty_id
						AND ng.netting_group_id = ISNULL(civv.netting_group_id,-1)
						and civv.prod_date BETWEEN ISNULL(ng.effective_date,''1900-01-01'') AND ISNULL(ng.end_date,''9999-01-01'')
			) netting_group	
			INNER JOIN contract_group cg on cg.contract_id=ISNULL(netting_group.contract_id,civv.contract_id)   
			 '+   
			case when (@as_of_date_to is null) then   
			' and (civv.as_of_date) <= (''' + @as_of_date +''')'   
			else   
			' and (civv.as_of_date) between (''' + @as_of_date +''') and (''' + @as_of_date_to +''') ' end 
			

		SET @insert_stmt1 = 	
			'   
			left join calc_invoice_volume civ on civv.calc_id=civ.calc_id   
			--LEFT JOIN calc_invoice_volume_detail civd on civd.calc_id=civv.calc_id
			--		 AND civd.invoice_line_item_id=civ.invoice_line_item_id
			left join #calc_invoice_volume_annual_rollover civar on civar.counterparty_id=civv.counterparty_id
			and civar.contract_id=civv.contract_id and civar.prod_date=civv.prod_date and
			civar.invoice_line_item_id=civ.invoice_line_item_id'
			+ case when (@entries='22') then   
			' AND isnull(civ.finalized,''n'')=''y'' ' else  ' AND isnull(civ.finalized,''n'')=''n'' ' end+' 
			--and dbo.FNAGetcontractMonth(civ.prod_date)=dbo.FNAGetcontractMonth(civv.prod_date)   
			left join invoice_header ih on ih.invoice_id=civv.invoice_id   
			left join   
			invoice_detail ind on ind.invoice_id=ih.invoice_id and ind.invoice_line_item_id=isnull(civar.invoice_line_item_id,civ.invoice_line_item_id) left join   
			static_data_value ili on ili.value_id = isnull(civar.invoice_line_item_id,civ.invoice_line_item_id) inner join   
			source_counterparty sc on sc.source_counterparty_id = civv.counterparty_id   
			left join contract_group_detail cgd on cgd.contract_id = cg.contract_id   
			and isnull(civar.invoice_line_item_id,civ.invoice_line_item_id)=cgd.invoice_line_item_id   
			and prod_type= case when ISNULL(cg.term_start,'''')='''' then ''p''   
			when dbo.FNAGETCONTRACTMONTH(cg.term_start)<=dbo.FNAGETCONTRACTMONTH(civv.prod_date) then ''p''   
			else ''t'' end   
			left join contract_charge_type cct on cct.contract_charge_type_id=cg.contract_charge_type_id
			left join contract_charge_type_detail cctd on cctd.contract_charge_type_id=cct.contract_charge_type_id
			and isnull(civar.invoice_line_item_id,civ.invoice_line_item_id)=cctd.invoice_line_item_id   
			and cctd.prod_type=
			case when ISNULL(cg.term_start,'''')='''' then ''p'' 
				 when dbo.fnagetcontractmonth(cg.term_start)<=dbo.fnagetcontractmonth(civv.prod_date) then ''p''
				 else ''t'' end	

			LEFT JOIN adjustment_default_gl_codes adgc on ISNULL(adgc.fas_subsidiary_id,-1)=ISNULL(cg.sub_id,-1)   
				AND adgc.default_gl_id = case when ISNULL(civ.finalized,''n'')=''y'' then ISNULL(cgd.default_gl_id,cctd.default_gl_id)
											  else COALESCE(cgd.default_gl_id_estimates,cctd.default_gl_id_estimates,cgd.default_gl_id,cctd.default_gl_id) end
				AND ISNULL(adgc.estimated_actual,''z'')=case when adgc.estimated_actual is not null then  case when ISNULL(civ.finalized,''n'')=''y''  then ''a'' else ''e'' end  else ''z'' end

			LEFT JOIN adjustment_default_gl_codes adgc_s on adgc_s.fas_subsidiary_id IS NULL
				AND adgc_s.default_gl_id = case when ISNULL(civ.finalized,''n'')=''y'' then ISNULL(cgd.default_gl_id,cctd.default_gl_id)
											  else COALESCE(cgd.default_gl_id_estimates,cctd.default_gl_id_estimates,cgd.default_gl_id,cctd.default_gl_id) end
				AND ISNULL(adgc_s.estimated_actual,''z'')=case when adgc_s.estimated_actual is not null then  case when ISNULL(civ.finalized,''n'')=''y''  then ''a'' else ''e'' end  else ''z'' end


			LEFT JOIN adjustment_default_gl_codes adgc1 ON ISNULL(adgc1.fas_subsidiary_id,-1)=ISNULL(cg.sub_id,-1)
				AND adgc1.default_gl_id = case when ISNULL(civ.finalized,''n'')=''y'' then civ.default_gl_id else civ.default_gl_id_estimate end   
				AND ISNULL(adgc1.estimated_actual,''z'')=case when adgc1.estimated_actual is not null then  case when ISNULL(civ.finalized,''n'')=''y''  then ''a'' else ''e'' end  else ''z'' end

			LEFT JOIN adjustment_default_gl_codes adgc1_s ON adgc1.fas_subsidiary_id IS NULL
				AND adgc1_s.default_gl_id = case when ISNULL(civ.finalized,''n'')=''y'' then civ.default_gl_id else civ.default_gl_id_estimate end   
				AND ISNULL(adgc1_s.estimated_actual,''z'')=case when adgc1_s.estimated_actual is not null then  case when ISNULL(civ.finalized,''n'')=''y''  then ''a'' else ''e'' end  else ''z'' end

			LEFT JOIN invoice_lineitem_default_glcode ildg ON ISNULL(ildg.sub_id,-1)=ISNULL(cg.sub_id,-1)
				AND ildg.invoice_line_item_id=isnull(civar.invoice_line_item_id,civ.invoice_line_item_id)	
				AND ISNULL(ildg.estimated_actual,''z'')=case when ildg.estimated_actual is not null then  case when ISNULL(civ.finalized,''n'')=''y''  then ''a'' else ''e'' end  else ''z'' end

			LEFT JOIN invoice_lineitem_default_glcode ildg_s ON ildg_s.sub_id IS NULL
				AND ildg_s.invoice_line_item_id=isnull(civar.invoice_line_item_id,civ.invoice_line_item_id)	
				AND ISNULL(ildg_s.estimated_actual,''z'')=case when ildg_s.estimated_actual is not null then  case when ISNULL(civ.finalized,''n'')=''y''  then ''a'' else ''e'' end  else ''z'' end

			LEFT JOIN adjustment_default_gl_codes adgc2 on adgc2.default_gl_id = ISNULL(ildg.default_gl_id,ildg_s.default_gl_id)  
				AND ISNULL(adgc2.fas_subsidiary_id,-1)=ISNULL(cg.sub_id,-1)   
				--AND ISNULL(adgc2.estimated_actual,''z'')=COALESCE(ildg.estimated_actual,ildg_s.estimated_actual,''z'')
				AND ISNULL(adgc2.estimated_actual,''z'')=case when adgc2.estimated_actual is not null then case when ISNULL(civ.finalized,''n'')=''y''  then ''a'' else ''e'' end  else ''z'' end

			LEFT JOIN adjustment_default_gl_codes adgc2_s on adgc2_s.default_gl_id = ISNULL(ildg.default_gl_id,ildg_s.default_gl_id)   
				AND adgc2_s.fas_subsidiary_id IS NULL  
				--AND ISNULL(adgc2_s.estimated_actual,''z'')=COALESCE(ildg.estimated_actual,ildg_s.estimated_actual,''z'')
				AND ISNULL(adgc2_s.estimated_actual,''z'')=case when adgc2_s.estimated_actual is not null then case when ISNULL(civ.finalized,''n'')=''y''  then ''a'' else ''e'' end  else ''z'' end

			LEFT JOIN adjustment_default_gl_codes_detail adgcd on adgcd.default_gl_id=COALESCE(adgc.default_gl_id,adgc_s.default_gl_id,adgc1.default_gl_id,adgc1_s.default_gl_id,adgc2.default_gl_id,adgc2_s.default_gl_id)   
				AND dbo.FNAGetContractMonth(civv.prod_date) between adgcd.term_start and adgcd.term_end   

			LEFT JOIN source_uom su on su.source_uom_id = COALESCE(adgcd.uom_id,adgc.uom_id,adgc_s.uom_id,adgc1.uom_id,adgc1_s.uom_id,adgc2.uom_id,adgc2_s.uom_id)    

			LEFT JOIN rec_volume_unit_conversion Conv ON conv.from_source_uom_id=case when civv.book_entries=''m'' then   
			case when isnull(civ.manual_input,'''')='''' and civ.price_or_formula=''f'' then civv.uom   
			when civ.manual_input=''y'' then civ.uom_id end   
			else ih.uom_id end   
			and conv.to_source_uom_id = COALESCE(adgcd.uom_id,adgc.uom_id,adgc_s.uom_id,adgc1.uom_id,adgc1_s.uom_id,adgc2.uom_id,adgc2_s.uom_id)   
			and conv.state_value_id is null and conv.assignment_type_value_id is null   
			and conv.curve_id is null   

			LEFT JOIN source_counterparty sc1 on sc1.source_counterparty_id=sc.netting_parent_counterparty_id   
			left join formula_editor fe on fe.formula_id=ISNULL(cgd.formula_id,cctd.formula_id)
			left join #calc_formula_value cfv on cfv.formula_id=fe.formula_id
			and dbo.fnagetcontractmonth(cfv.prod_date)=	dbo.FNAGetContractMonth(civv.prod_date)
			and cfv.as_of_date=civv.as_of_date
			left join  rec_generator rg on civv.generator_id=rg.generator_id
			LEFT JOIN counterparty_contract_address cga ON cga.contract_id = cg.contract_id AND sc.source_counterparty_id = cga.counterparty_id
			LEFT JOIN  static_data_value al on al.value_id = cgd.alias
		WHERE 1=1   
			and isnull(civ.manual_input,''n'')=''n''   
			--AND ISNULL(cgd.hideininvoice,''s'') in (''s'')
			'    
			+ CASE WHEN @cpt_type IS NOT NULL THEN ' AND sc.int_ext_flag=''' + @cpt_type + '''' ELSE '' END +
			case when (@counterparty_id IS NOT NULL) then   
			' And (sc.source_counterparty_id in('+cast(@counterparty_id as NVARCHAR(1000))+') OR sc.netting_parent_counterparty_id in('+cast(@counterparty_id as NVARCHAR(1000))+'))' else '' end   
			+ case when (isnull(@technology,'')<>'') then   
			' AND rg.technology in('+@technology+')' else ' ' end   
			+ case when (@entries='22') then   
			' AND civ.finalized=''y'' ' WHEN @entries = '11' THEN ' AND ISNULL(civ.finalized,'''') <> ''y'' ' ELSE '' END
			--' AND ((ISNULL(civ.finalized,'''')=''y'' and b.as_of_date<>dbo.FNAGetContractMonth(''' + @as_of_date +''') and dbo.FNAGetContractMonth(civv.as_of_date) = dbo.FNAGetContractMonth(''' + @as_of_date +''')) OR ISNULL(civ.finalized,'''')<>''y'') ' end   
			--+CASE WHEN @subsidiary_id IS NOT NULL  THEN ' AND (ISNULL(civd.sub_id,rg.legal_entity_value_id) IN(' + @subsidiary_id + ' ))' ELSE '' END   
   
	--print @insert_stmt   
	--print @insert_stmt1   

	if (@inventory_report='n')
		exec (@insert_stmt+@insert_stmt1)   



--Insert Cash Received   
		SET @insert_stmt =   
		' INSERT INTO #temp   
		SELECT
			dbo.FNAGetContractMonth(''' + @as_of_date + ''') as_of_date,
			ISNULL(rg.legal_entity_value_id,-1), NULL, NULL,   
			ISNULL(sc1.counterparty_name,sc.counterparty_name) + '' - '' + ISNULL(al.code,ili.code) as link_id,   
			civ.prod_date term_month, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,   
			ISNULL(sc1.counterparty_name,sc.counterparty_name) Counterparty,   
			civ.volume as volume,   
			su.uom_name as uom,   
			COALESCE(adgcd.debit_gl_number,adgc.debit_gl_number,adgc_s.debit_gl_number,adgc2.debit_gl_number,adgc2_s.debit_gl_number) debit_gl_number,   
			COALESCE(adgcd.credit_gl_number,adgc.credit_gl_number,adgc_s.credit_gl_number,adgc2.credit_gl_number,adgc2_s.credit_gl_number) credit_gl_number,   
			icr.cash_received adjustment_amount,   
			'''' deal_id, ''Adj-S'' type,   
			NULL u_sur_expense, NULL u_inv_expense, NULL u_exp_expense, NULL u_revenue, NULL u_liability,   
			NULL gl_code_sur_expense, NULL gl_code_inv_expense, NULL gl_code_exp_expense, NULL gl_code_u_revenue,   
			NULL gl_code_liability,   
			NULL u_hedge_st_asset_units, NULL u_hedge_st_liability_units, NULL u_pnl_inventory_units,   
			NULL u_pnl_settlement_units, NULL u_sur_expense_units, NULL u_inv_expense_units,   
			NULL u_exp_expense_units, NULL u_revenue_units, NULL u_liability_units,   
			su.source_uom_id,   
			COALESCE(adgcd.debit_volume_multiplier,adgc.debit_volume_multiplier,adgc_s.debit_volume_multiplier), 
			COALESCE(adgcd.credit_volume_multiplier,adgc.credit_volume_multiplier,adgc_s.credit_volume_multiplier),   
			ISNULL(adgc.adjustment_type_id,adgc_s.adjustment_type_id) adjustment_type,
			NULL,sc.source_counterparty_id ,cg.Subledger_code,ISNULL(al.description,ili.description),cgd.manual,
			COALESCE(adgc.debit_gl_number_minus,adgc_s.debit_gl_number_minus,adgc2.debit_gl_number_minus,adgc2_s.debit_gl_number_minus) debit_gl_number,   
			COALESCE(adgc.credit_gl_number_minus,adgc_s.credit_gl_number_minus,adgc2.credit_gl_number_minus,adgc2_s.credit_gl_number_minus) credit_gl_number,
			CASE WHEN COALESCE(cga.apply_netting_rule,cg.neting_rule,''n'') = ''n'' THEN NULL ELSE COALESCE(adgc.netting_debit_gl_number,adgc_s.netting_debit_gl_number,adgc2.netting_debit_gl_number,adgc2_s.netting_debit_gl_number) END debit_gl_number,   
			CASE WHEN COALESCE(cga.apply_netting_rule,cg.neting_rule,''n'') = ''n'' THEN NULL ELSE COALESCE(adgc.netting_credit_gl_number,adgc_s.netting_credit_gl_number,adgc2.netting_credit_gl_number,adgc2_s.netting_credit_gl_number) END credit_gl_number,
			CASE WHEN COALESCE(cga.apply_netting_rule,cg.neting_rule,''n'') = ''n'' THEN NULL ELSE COALESCE(adgc.netting_debit_gl_number_minus,adgc_s.netting_debit_gl_number_minus,adgc2.netting_debit_gl_number_minus,adgc2_s.netting_debit_gl_number_minus) END debit_gl_number,   
			CASE WHEN COALESCE(cga.apply_netting_rule,cg.neting_rule,''n'') = ''n'' THEN NULL ELSE COALESCE(adgc.netting_credit_gl_number_minus,adgc_s.netting_credit_gl_number_minus,adgc2.netting_credit_gl_number_minus,adgc2_s.netting_credit_gl_number_minus) END credit_gl_number,
			COALESCE(adgc.default_gl_id,adgc_s.default_gl_id,adgc2.default_gl_id,adgc2_s.default_gl_id)	,			
			civ.invoice_line_item_id,CASE WHEN ISNULL(civ.finalized,''n'')=''y'' THEN ''a'' ELSE ''e'' END estimate_actual,civv.contract_id,netting_group.netting_group_id,netting_group.netting_group_name  
		FROM   
			calc_invoice_volume_variance civv
			OUTER APPLY(SELECT ngdc.source_contract_id contract_id,ng.netting_group_id,ng.netting_group_name FROM netting_group ng INNER JOIN netting_group_detail ngd ON ng.netting_group_id = ngd.netting_group_id
						INNER JOIN netting_group_detail_contract ngdc ON ngdc.netting_group_detail_id=ngd.netting_group_id WHERE ngd.source_counterparty_id= civv.counterparty_id
						AND ng.netting_group_id = ISNULL(civv.netting_group_id,-1)
						and civv.prod_date BETWEEN ISNULL(ng.effective_date,''1900-01-01'') AND ISNULL(ng.end_date,''9999-01-01'')
			) netting_group	
			INNER JOIN contract_group cg on cg.contract_id=ISNULL(netting_group.contract_id,civv.contract_id)   
			 '+   
			case when (@as_of_date_to is null) then   
			' and (civv.as_of_date) <= (''' + @as_of_date +''')'   
			else   
			' and (civv.as_of_date) between (''' + @as_of_date +''') and (''' + @as_of_date_to +''') ' end 
			

		SET @insert_stmt1 = 	
			'   
			INNER JOIN calc_invoice_volume civ on civv.calc_id=civ.calc_id   
			INNER JOIN invoice_cash_received icr ON icr.save_invoice_detail_id = civ.calc_detail_id
			INNER JOIN static_data_value ili on ili.value_id = civ.invoice_line_item_id
			INNER JOIN source_counterparty sc on sc.source_counterparty_id = civv.counterparty_id   
			LEFT JOIN contract_group_detail cgd on cgd.contract_id = cg.contract_id   
				AND civ.invoice_line_item_id=cgd.invoice_line_item_id   
				AND prod_type= case when ISNULL(cg.term_start,'''')='''' then ''p''   
							   WHEN dbo.FNAGETCONTRACTMONTH(cg.term_start)<=dbo.FNAGETCONTRACTMONTH(civv.prod_date) then ''p''   
							   ELSE ''t'' END   
			LEFT JOIN contract_charge_type cct on cct.contract_charge_type_id=cg.contract_charge_type_id
			LEFT JOIN contract_charge_type_detail cctd on cctd.contract_charge_type_id=cct.contract_charge_type_id
			AND civ.invoice_line_item_id = cctd.invoice_line_item_id   
			and cctd.prod_type=
			case when ISNULL(cg.term_start,'''')='''' then ''p'' 
				 when dbo.fnagetcontractmonth(cg.term_start)<=dbo.fnagetcontractmonth(civv.prod_date) then ''p''
				 else ''t'' end	
			LEFT JOIN adjustment_default_gl_codes adgc on ISNULL(adgc.fas_subsidiary_id,-1)=ISNULL(cg.sub_id,-1)   
				AND adgc.default_gl_id =  ISNULL(cgd.default_gl_code_cash_applied,cctd.default_gl_code_cash_applied)											  
				AND ISNULL(adgc.estimated_actual,''z'')=case when adgc.estimated_actual is not null then ''c'' else ''z'' end
			LEFT JOIN adjustment_default_gl_codes adgc_s on adgc_s.fas_subsidiary_id IS NULL
				AND adgc_s.default_gl_id = ISNULL(cgd.default_gl_code_cash_applied,cctd.default_gl_code_cash_applied)										
				AND ISNULL(adgc_s.estimated_actual,''z'')=case when adgc_s.estimated_actual is not null then ''c'' else ''z'' end
			LEFT JOIN invoice_lineitem_default_glcode ildg ON ISNULL(ildg.sub_id,-1)=ISNULL(cg.sub_id,-1)
				AND ildg.invoice_line_item_id = civ.invoice_line_item_id	
				AND ISNULL(ildg.estimated_actual,''z'')=case when ildg.estimated_actual is not null then ''c'' else ''z'' end
			LEFT JOIN invoice_lineitem_default_glcode ildg_s ON ildg_s.sub_id IS NULL
				AND ildg_s.invoice_line_item_id = civ.invoice_line_item_id	
				AND ISNULL(ildg_s.estimated_actual,''z'')=case when ildg_s.estimated_actual is not null then ''c'' else ''z'' end
			LEFT JOIN adjustment_default_gl_codes adgc2 on adgc2.default_gl_id = ISNULL(ildg.default_gl_id,ildg_s.default_gl_id)  
				AND ISNULL(adgc2.fas_subsidiary_id,-1)=ISNULL(cg.sub_id,-1)   
				AND ISNULL(adgc2.estimated_actual,''z'')=case when adgc2.estimated_actual is not null then ''c'' else ''z'' end
			LEFT JOIN adjustment_default_gl_codes adgc2_s on adgc2_s.default_gl_id = ISNULL(ildg.default_gl_id,ildg_s.default_gl_id)   
				AND adgc2_s.fas_subsidiary_id IS NULL  
				AND ISNULL(adgc2_s.estimated_actual,''z'')=case when adgc2_s.estimated_actual is not null then ''c'' else ''z'' end
			LEFT JOIN adjustment_default_gl_codes_detail adgcd on adgcd.default_gl_id=COALESCE(adgc.default_gl_id,adgc_s.default_gl_id,adgc2.default_gl_id,adgc2_s.default_gl_id)   
				AND dbo.FNAGetContractMonth(civv.prod_date) between adgcd.term_start and adgcd.term_end
			LEFT JOIN source_uom su on su.source_uom_id = COALESCE(adgcd.uom_id,adgc.uom_id,adgc_s.uom_id,adgc2.uom_id,adgc2_s.uom_id)    			
			LEFT JOIN source_counterparty sc1 on sc1.source_counterparty_id=sc.netting_parent_counterparty_id  
			LEFT JOIN rec_generator rg on civv.generator_id=rg.generator_id
			LEFT JOIN counterparty_contract_address cga ON cga.contract_id = cg.contract_id AND sc.source_counterparty_id = cga.counterparty_id
			LEFT JOIN  static_data_value al on al.value_id = cgd.alias
		WHERE 1=1 '    
			+ CASE WHEN @cpt_type IS NOT NULL THEN ' AND sc.int_ext_flag=''' + @cpt_type + '''' ELSE '' END 
			+ CASE WHEN (@counterparty_id IS NOT NULL) then   
			' And (sc.source_counterparty_id in('+cast(@counterparty_id as NVARCHAR(1000))+') OR sc.netting_parent_counterparty_id in('+cast(@counterparty_id as NVARCHAR(1000))+'))' else '' end   
			+ case when (isnull(@technology,'')<>'') then   
			' AND rg.technology in('+@technology+')' else ' ' end   
			+ case when (@entries='22') then   
			' AND civ.finalized=''y'' ' WHEN @entries='11' THEN	' AND ISNULL(civ.finalized,'''') <> ''y'' '  ELSE '' END
   
	--print @insert_stmt   
	--print @insert_stmt1   

	if (@inventory_report='n')
		exec (@insert_stmt+@insert_stmt1)   



--return   
--if as of date is not null but production month is null   
IF @as_of_date_drill IS NOT NULL AND @production_month_drill IS NULL   
	BEGIN   
		select dbo.FNADateFormat(as_of_date) AsOfDate, dbo.FNADateFormat(term_month) as ProductionMonth,   
		Counterparty,   
		sum(u_hedge_mtm) [Settlement Rec(+)/Pay(-)],   
		sum(u_hedge_st_asset) [AR Db(+)/Cr(-)],   
		sum(u_hedge_st_liability + u_liability) [Liability Db(+)/Cr(-)],   
		sum(u_pnl_inventory) [Inventory Db(+)/Cr(-)],   
		sum(u_pnl_settlement + u_sur_expense + u_inv_expense + u_exp_expense + u_revenue) [Expenses Db(+)/Cr(-)]   
		from #temp RMV   
		WHERE dbo.FNADateFormat(as_of_date) = isnull(@as_of_date_drill, dbo.FNADateFormat(as_of_date)) AND   
		dbo.FNADateFormat(term_month) = isnull(@production_month_drill, dbo.FNADateFormat(term_month))   
		group by as_of_date, term_month, Counterparty   
		  
		Return   
	END   
--print '######'   
--If both drill down are not null... but @gl_number is null   
IF @as_of_date_drill IS NOT NULL AND @production_month_drill IS NOT NULL AND @gl_number IS NULL   
	BEGIN   
		select dbo.FNADateFormat(as_of_date) AsOfDate, dbo.FNADateFormat(term_month) as ProductionMonth,   
		case when (adjustment_amount is null) then   
		dbo.FNAHyperLinkText(10131000, cast(link_id as varchar), cast(link_id as varchar))   
		else cast(link_id as varchar) end DealID,   
		RMV.deal_id RefDealID,   
		type Type,   
		Counterparty,   
		u_hedge_mtm [Settlement Rec(+)/Pay(-)],   
		u_rec_mtm [REC Value Long(-)/Short(+)],   
		u_hedge_st_asset [AR Db(+)/Cr(-)],   
		u_hedge_st_liability + u_liability [Liability Db(+)/Cr(-)],   
		u_pnl_inventory [Inventory Db(+)/Cr(-)],   
		  
		u_pnl_settlement + u_sur_expense + u_inv_expense + u_exp_expense + u_revenue [Expenses Db(+)/Cr(-)],   
		adjustment_amount [Adjustments Db],   
		adjustment_amount [Adjustments Cr]   
		from #temp RMV   
	  
		-- left outer join   
		-- source_deal_detail sdd on cast(sdd.source_deal_detail_id as varchar) = cast(RMV.link_id as varchar)   
		--deal_rec_properties drp on cast(sdh.source_deal_header_id as varchar) = link_id   
		WHERE dbo.FNADateFormat(as_of_date) = isnull(@as_of_date_drill, dbo.FNADateFormat(as_of_date)) AND   
		dbo.FNADateFormat(term_month) =isnull(@production_month_drill,dbo.FNADateFormat(term_month)) AND   
		Counterparty = isnull(@Counterparty, Counterparty)   
		-- ORDER BY case when (adjustment_amount is null) then   
		-- dbo.FNAHyperLinkText(120, cast(link_id as varchar), cast(link_id as varchar))   
		-- else link_id end   
		ORDER BY RMV.link_id   
		Return   
	END   
  
IF @as_of_date_drill IS NOT NULL AND @production_month_drill IS NOT NULL AND @gl_number IS NOT NULL   
	BEGIN   
		select dbo.FNADateFormat(as_of_date) AsOfDate, dbo.FNADateFormat(term_month) as ProductionMonth,   
		case when (adjustment_amount is null) then   
		dbo.FNAHyperLinkText(10131000, cast(link_id as varchar), cast(link_id as varchar))   
		else link_id end DealID,   
		RMV.deal_id RefDealID,   
		type Type,   
		Counterparty,   
		u_hedge_mtm [Settlement Rec(+)/Pay(-)],   
		u_rec_mtm [REC Value Long(-)/Short(+)],   
		u_hedge_st_asset [AR Dr(+)/Cr(-)],   
		u_hedge_st_liability + u_liability [Liability Dr(+)/Cr(-)],   
		u_pnl_inventory [Inventory Dr(+)/Cr(-)],   
		u_pnl_settlement + u_sur_expense + u_inv_expense + u_exp_expense + u_revenue [Expenses Dr(+)/Cr(-)],   
		adjustment_amount [Adjustments Dr],   
		adjustment_amount [Adjustments Cr]   
		  
		from #temp RMV left outer join   
		gl_system_mapping gsm on gsm.gl_account_number = @gl_number AND   
		(gsm.gl_number_id = isnull(RMV.gl_code_hedge_st_asset, -1) OR   
		gsm.gl_number_id = isnull(RMV.gl_code_hedge_st_liability, -1) OR   
		gsm.gl_number_id = isnull(RMV.gl_settlement, -1) OR   
		gsm.gl_number_id = isnull(RMV.gl_inventory, -1) OR   
		gsm.gl_number_id = isnull(RMV.gl_code_sur_expense, -1) OR   
		gsm.gl_number_id = isnull(RMV.gl_code_inv_expense, -1) OR   
		gsm.gl_number_id = isnull(RMV.gl_code_exp_expense, -1) OR   
		gsm.gl_number_id = isnull(RMV.gl_code_u_revenue, -1) OR   
		gsm.gl_number_id = isnull(RMV.gl_code_liability, -1))   
		-- left outer join   
		-- source_deal sdh on cast(sdh.source_deal_header_id as varchar) = case when (adjustment_amount is not null) then -1 else cast(link_id as int) end   
		-- deal_rec_properties drp on cast(sdh.source_deal_header_id as varchar) = case when (adjustment_amount is not null) then -1 else cast(link_id as int) end   
		  
		WHERE --dbo.FNADateFormat(as_of_date) = isnull(@as_of_date_drill, dbo.FNADateFormat(as_of_date)) AND   
		dbo.FNAGetContractMonth(term_month) = isnull(@production_month_drill, dbo.FNADateFormat(term_month)) AND   
		Counterparty = isnull(@Counterparty, Counterparty)   
		-- ORDER BY case when (adjustment_amount is null) then   
		-- dbo.FNAHyperLinkText(120, cast(link_id as varchar), cast(link_id as varchar))   
		-- else link_id end   
		ORDER BY RMV.link_id   
	Return   
END   
  
  
--Also implement adjusment vs current, show deal_id also   
--1 debit_volume_multiplier, 1 credit_volume_multiplier   
--select * from #temp   
-- select * from #temp_MTM_JEP   
--===============Manual Debit Entries===========================   
--A/P reduction   

insert INTO #temp_MTM_JEP   
SELECT   
		as_of_date,
		sub_entity_id,
		strategy_entity_id,
		book_entity_id,
		link_id,
		term_month,   
		Gl_Number,
		Counterparty,
		sum(volume),
		max(uom_name),
		sum(Debit),
		sum(Credit),
		sum(Amount),
		max(uom_id),
		max(Subledger_code ),
		counterparty_id,
		max(line_item),
		max(show_volume),
		sum(line_volume)line_volume,
		max(line_uom_id) line_uom_id,
		gl_number_netting,
		NULL,
		default_gl_id,
		invoice_line_item_id,
		estimate_actual,
		contract_id,netting_group_id,netting_group_name 
	FROM(   
			SELECT 
				as_of_date, 
				sub_entity_id,
				strategy_entity_id,
				book_entity_id,
				link_id, 
				term_month,   
				case when (adjustment_amount >= 0) then rmv.debit_gl_number else rmv.debit_gl_number_minus end AS Gl_Number,   
				Counterparty + case when (adjustment_amount >= 0) then   
										case when (isnull(COALESCE(RMV.remarks,adgcd.debit_remark,adgc.debit_remark), '') = '') then '' else ' (' + COALESCE(RMV.remarks,adgcd.debit_remark,adgc.debit_remark) + ')' end   
									else   
										case when (isnull(COALESCE(RMV.remarks,adgcd.credit_remark,adgc.credit_remark), '') = '') then '' else ' (' + COALESCE(RMV.remarks,adgcd.credit_remark,adgc.credit_remark) + ')' end   
								end Counterparty,   
				case when (adjustment_amount >= 0) then isnull(rmv.debit_volume_multiplier, 1) else -1 * isnull(rmv.credit_volume_multiplier, 1) end * abs(volume) volume,  
				case when( case when (adjustment_amount >= 0) then isnull(rmv.debit_volume_multiplier, 1) else -1 * isnull(rmv.credit_volume_multiplier, 1) end * abs(volume))<>0 then uom_name else NULL end as uom_name,   
				abs(adjustment_amount) Debit,   
				0 Credit,   
				adjustment_amount Amount,   
				case when( case when (adjustment_amount >= 0) then isnull(rmv.debit_volume_multiplier, 1)   
				else -1 * isnull(rmv.credit_volume_multiplier, 1) end * abs(volume))<>0 then rmv.uom_id else NULL end as uom_id ,RMV.Subledger_code,
				rmv.counterparty_id,line_item,show_volume,volume line_volume,rmv.uom_id line_uom_id,
				case when (adjustment_amount >= 0) then rmv.netting_debit_gl_number else rmv.netting_debit_gl_number_minus end AS gl_number_netting,
				RMV.default_gl_id,
				RMV.invoice_line_item_id,RMV.estimate_actual,RMV.contract_id,RMV.netting_group_id,RMV.netting_group_name 
			FROM #temp RMV LEFT OUTER JOIN   
				adjustment_default_gl_codes adgc   
				on adgc.adjustment_type_id = adjustment_type   
				and adgc.fas_subsidiary_id=rmv.sub_entity_id  
				and ISNULL(adgc.estimated_actual,'z')=case when adgc.estimated_actual is not null then 
													  case when (@entries='22') then 'a' else 'e' end else 'z' end
				left join adjustment_default_gl_codes_detail adgcd on adgcd.default_gl_id=adgc.default_gl_id and   
				term_month between adgcd.term_start and adgcd.term_end				  
			WHERE
				adjustment_amount is not null   
		) a   
	group by as_of_date, sub_entity_id, strategy_entity_id, book_entity_id, link_id, term_month,   
			 Gl_Number,Counterparty,counterparty_id,gl_number_netting,default_gl_id,invoice_line_item_id,estimate_actual,contract_id,netting_group_id,netting_group_name    
  


--===============Manual Credit Entries===========================   
--Expense   

	INSERT INTO #temp_MTM_JEP   
	SELECT   
		as_of_date, sub_entity_id, strategy_entity_id, book_entity_id, link_id, term_month,   
		Gl_Number,Counterparty,sum(volume)volume,max(uom_name)uom_name,sum(Debit)Debit,sum(Credit)Credit,
		sum(Amount)Amount,max(uom_id) uom_id ,max(Subledger_code),counterparty_id,max(line_item),max(show_volume),
		sum(line_volume) line_volume,max(line_uom_id) line_uom_id,
		gl_number_netting,
		NULL,
		default_gl_id,
		invoice_line_item_id,
		estimate_actual,
		contract_id,netting_group_id,netting_group_name 
	FROM
		(   
		SELECT 
			as_of_date, sub_entity_id, strategy_entity_id, book_entity_id, link_id, term_month,   
			case when (adjustment_amount >= 0) then rmv.credit_gl_number else rmv.credit_gl_number_minus end AS Gl_Number,   
			Counterparty + case when (adjustment_amount >= 0) then   
					case when (isnull(COALESCE(RMV.remarks,adgcd.credit_remark,adgc.credit_remark), '') = '') then '' else ' (' + COALESCE(RMV.remarks,adgcd.credit_remark,adgc.credit_remark) + ')' end   
					ELSE   
						case when (isnull(COALESCE(RMV.remarks,adgcd.debit_remark,adgc.debit_remark) , '') = '') then '' else ' (' + COALESCE(RMV.remarks,adgcd.debit_remark,adgc.debit_remark) + ')' end   
					end Counterparty,   
			case when (adjustment_amount >= 0) then isnull(rmv.credit_volume_multiplier, 1) else -1 * isnull(rmv.debit_volume_multiplier, 1) end * abs(volume) volume,		  
			case when ( case when (adjustment_amount >= 0) then isnull(rmv.credit_volume_multiplier, 1) else -1 * isnull(rmv.debit_volume_multiplier, 1) end * abs(volume))<>0 then uom_name else NULL end as uom_name,   
			0 Debit,   
			abs(adjustment_amount) Credit,   
			adjustment_amount Amount,   
			case when ( case when (adjustment_amount >= 0) then isnull(rmv.credit_volume_multiplier, 1)	else -1 * isnull(rmv.debit_volume_multiplier, 1) end * abs(volume))<>0 then rmv.uom_id else NULL end as uom_id ,
			RMV.Subledger_code,rmv.counterparty_id,line_item,show_volume,volume as line_volume,rmv.uom_id line_uom_id,
			case when (adjustment_amount >= 0) then rmv.netting_credit_gl_number else rmv.netting_credit_gl_number_minus end AS gl_number_netting,RMV.default_gl_id,
			RMV.invoice_line_item_id,RMV.estimate_actual,RMV.contract_id,RMV.netting_group_id,RMV.netting_group_name 
		FROM #temp RMV 
			LEFT OUTER JOIN	adjustment_default_gl_codes adgc ON adgc.adjustment_type_id = adjustment_type   
				and adgc.fas_subsidiary_id=rmv.sub_entity_id  
				and ISNULL(adgc.estimated_actual,'z')=case when adgc.estimated_actual is not null then 
										case when (@entries='22') then 'a' else 'e' end else 'z' end
			left join adjustment_default_gl_codes_detail adgcd on adgcd.default_gl_id=adgc.default_gl_id   
				AND term_month between adgcd.term_start and adgcd.term_end   
		WHERE adjustment_amount is not null   
	) a   
	group by as_of_date, sub_entity_id, strategy_entity_id, book_entity_id, link_id, term_month,   
	Gl_Number,Counterparty,counterparty_id ,gl_number_netting ,default_gl_id,invoice_line_item_id,estimate_actual,contract_id,netting_group_id,netting_group_name  
  


--===============AR===========================   

insert INTO #temp_MTM_JEP   
SELECT as_of_date, sub_entity_id, strategy_entity_id, book_entity_id, link_id, term_month,   
gl_code_hedge_st_asset AS Gl_Number, Counterparty,   
u_hedge_st_asset_units AS volume,   
uom_name,   
CASE WHEN (u_hedge_st_asset > 0) THEN u_hedge_st_asset ELSE 0 END AS Debit,   
CASE WHEN (u_hedge_st_asset <= 0) THEN -1 * + u_hedge_st_asset ELSE 0 END AS Credit,   
u_hedge_st_asset Amount,uom_id ,RMV.Subledger_code,counterparty_id,line_item,show_volume,0 ,0,NULL,NULL,NULL,invoice_line_item_id,'a',contract_id,netting_group_id,netting_group_name  
FROM #temp RMV   
where adjustment_amount is null   
  
--================AP============================   
  
insert INTO #temp_MTM_JEP   
SELECT as_of_date, sub_entity_id, strategy_entity_id, book_entity_id, link_id, term_month,   
gl_code_hedge_st_liability AS Gl_Number, Counterparty,   
u_hedge_st_liability_units AS volume,   
uom_name,   
CASE WHEN (u_hedge_st_liability > 0) THEN u_hedge_st_liability ELSE 0 END AS Debit,   
CASE WHEN (u_hedge_st_liability <= 0) THEN -1 * u_hedge_st_liability ELSE 0 END AS Credit,   
u_hedge_st_liability Amount,uom_id,RMV.Subledger_code,counterparty_id,line_item,show_volume,0,0,NULL,NULL,NULL,invoice_line_item_id,'a',contract_id,netting_group_id,netting_group_name        
FROM #temp RMV   
where adjustment_amount is null   
  
--================Other Liability============================   
  
insert INTO #temp_MTM_JEP   
SELECT as_of_date, sub_entity_id, strategy_entity_id, book_entity_id, link_id, term_month,   
gl_code_liability AS Gl_Number, Counterparty,   
u_liability_units AS volume,   
uom_name,   
CASE WHEN (u_liability > 0) THEN u_liability ELSE 0 END AS Debit,   
CASE WHEN (u_liability <= 0) THEN -1 * u_liability ELSE 0 END AS Credit,   
u_liability Amount,uom_id   ,RMV.Subledger_code,counterparty_id,line_item,show_volume,0,0,NULL,NULL,NULL,invoice_line_item_id,'a',contract_id,netting_group_id,netting_group_name     
FROM #temp RMV   
where adjustment_amount is null   
  
--================Revenue============================   
  
insert INTO #temp_MTM_JEP   
SELECT as_of_date, sub_entity_id, strategy_entity_id, book_entity_id, link_id, term_month,   
gl_code_u_revenue AS Gl_Number, Counterparty,   
u_revenue_units AS volume,   
uom_name,   
CASE WHEN (u_revenue > 0) THEN u_revenue ELSE 0 END AS Debit,   
CASE WHEN (u_revenue <= 0) THEN -1 * u_revenue ELSE 0 END AS Credit,   
u_revenue Amount,uom_id   ,RMV.Subledger_code,counterparty_id,line_item,show_volume,0 ,0,NULL,NULL,NULL,invoice_line_item_id,'a',contract_id,netting_group_id,netting_group_name    
FROM #temp RMV   
where adjustment_amount is null   
  
  
--========================Purchase Power Expense==================================   
  
insert INTO #temp_MTM_JEP   
SELECT as_of_date, sub_entity_id, strategy_entity_id, book_entity_id, link_id, term_month,   
  
gl_settlement AS Gl_Number, Counterparty,   
u_pnl_settlement_units AS volume,   
uom_name,   
CASE WHEN(u_pnl_settlement > 0) THEN u_pnl_settlement ELSE 0 END AS Debit,   
CASE WHEN(u_pnl_settlement <= 0) THEN -1 * u_pnl_settlement ELSE 0 END AS Credit,   
u_pnl_settlement Amount,uom_id   ,RMV.Subledger_code,counterparty_id,line_item,show_volume,0,0,NULL,NULL,NULL,invoice_line_item_id,'a' ,contract_id,netting_group_id,netting_group_name    
FROM #temp RMV   
where adjustment_amount is null   
  
--========================REC Surrender Expense==================================   
  
insert INTO #temp_MTM_JEP   
SELECT as_of_date, sub_entity_id, strategy_entity_id, book_entity_id, link_id, term_month,   
gl_code_sur_expense AS Gl_Number, Counterparty,   
u_sur_expense_units AS volume,   
uom_name,   
CASE WHEN(u_sur_expense > 0) THEN u_sur_expense ELSE 0 END AS Debit,   
CASE WHEN(u_sur_expense <= 0) THEN -1 * u_sur_expense ELSE 0 END AS Credit,   
u_sur_expense Amount,uom_id   ,RMV.Subledger_code,counterparty_id,line_item,show_volume,0,0,NULL,NULL,NULL,invoice_line_item_id,'a' ,contract_id,netting_group_id,netting_group_name    
FROM #temp RMV   
where adjustment_amount is null   
  
--========================REC Inventory Expense==================================   
  
insert INTO #temp_MTM_JEP   
SELECT as_of_date, sub_entity_id, strategy_entity_id, book_entity_id, link_id, term_month,   
gl_code_inv_expense AS Gl_Number, Counterparty,   
u_inv_expense_units AS volume,   
uom_name,   
CASE WHEN(u_inv_expense > 0) THEN u_inv_expense ELSE 0 END AS Debit,   
CASE WHEN(u_inv_expense <= 0) THEN -1 * u_inv_expense ELSE 0 END AS Credit,   
u_inv_expense Amount,uom_id  ,RMV.Subledger_code,counterparty_id,line_item,show_volume,0,0,NULL,NULL,NULL,invoice_line_item_id,'a' ,contract_id,netting_group_id,netting_group_name    
FROM #temp RMV   
where adjustment_amount is null   
  
--========================REC Expiration Expense==================================   
  
insert INTO #temp_MTM_JEP   
SELECT as_of_date, sub_entity_id, strategy_entity_id, book_entity_id, link_id, term_month,   
gl_code_exp_expense AS Gl_Number, Counterparty,   
u_exp_expense_units AS volume,   
uom_name,   
CASE WHEN(u_exp_expense > 0) THEN u_exp_expense ELSE 0 END AS Debit,   
CASE WHEN(u_exp_expense <= 0) THEN -1 * u_exp_expense ELSE 0 END AS Credit,   
u_exp_expense Amount,uom_id   ,RMV.Subledger_code,counterparty_id,line_item,show_volume,0,0,NULL,NULL,NULL,invoice_line_item_id,'a',contract_id,netting_group_id,netting_group_name     
FROM #temp RMV   
where adjustment_amount is null   
  
  
--======================== Inventory==================================   
  
insert INTO #temp_MTM_JEP   
SELECT as_of_date, sub_entity_id, strategy_entity_id, book_entity_id, link_id, term_month,   
gl_inventory AS Gl_Number, Counterparty,   
u_pnl_inventory_units AS volume,   
uom_name,   
CASE WHEN(u_pnl_inventory > 0) THEN u_pnl_inventory ELSE 0 END AS Debit,   
CASE WHEN(u_pnl_inventory <= 0) THEN -1 * u_pnl_inventory ELSE 0 END AS Credit,   
u_pnl_inventory Amount,uom_id   ,RMV.Subledger_code,counterparty_id,line_item,show_volume,0,0,NULL,NULL,NULL,invoice_line_item_id,'a',contract_id,netting_group_id,netting_group_name     
FROM #temp RMV   
where adjustment_amount is null   
  
--==================================   
--=======================   

-- select sum(volume) from #temp_MTM_JEP where gl_number = 300   
  
DELETE FROM #temp_MTM_JEP WHERE (DEBIT = 0 AND CREDIT = 0 AND volume = 0)   
--OR GL_NUMBER IS NULL   

--- Netting Logic
	SELECT 
		 as_of_date,term_month,counterparty_id,gl_number_netting,amount,default_gl_id
	INTO 
		#temp_netting
	FROM
		#temp_MTM_JEP
	WHERE
		gl_number_netting IS NOT NULL



	INSERT INTO #temp_MTM_JEP
	SELECT
		tmj.[as_of_date] ,   
		tmj.[sub_entity_id],   
		tmj.[strategy_entity_id],   
		tmj.[book_entity_id] ,   
		tmj.[link_id]  ,   
		tmj.[term_month],   
		tmj.[Gl_Number] ,   
		tmj.[Counterparty] ,   
		tmj.volume ,   
		tmj.uom_name ,   
		CASE WHEN tmj.[Credit] < ABS(tn.Amount) THEN tmj.[Credit] ELSE ABS(tn.Amount) END  ,
		CASE WHEN tmj.[Debit] < ABS(tn.Amount) THEN tmj.[Debit] ELSE ABS(tn.Amount) END  ,
		tn.[Amount]  ,   
		tmj.uom_id   ,
		tmj.Subledger_code ,  
		tmj.counterparty_id  ,
		tmj.line_item ,
		tmj.show_volume ,
		tmj.line_volume  , 
		tmj.line_uom_id  ,
		tmj.gl_number_netting,
		'' ,
		tn.default_gl_id,
		tmj.invoice_line_item_id,
		tmj.estimate_actual,
		tmj.contract_id,
		tmj.netting_group_id,
		tmj.netting_group_name 
	FROM
		#temp_netting tn
		INNER JOIN #temp_MTM_JEP tmj ON tn.gl_number_netting = tmj.Gl_Number
			AND tn.as_of_date = tmj.as_of_date
			AND tn.term_month = tmj.term_month
			AND tn.counterparty_id = tmj.counterparty_id	
			AND tn.default_gl_id = tmj.default_gl_id			

 
DECLARE @rounding_points int   
set @rounding_points = 2   
  
--select distinct term_month, as_of_date, Counterparty from #temp_MTM_JEP   

  
set @report_type = isnull(@report_type, '111')   
  

IF @summary_option ='2222'   
BEGIN   
	IF @report_type = '111'   
		SELECT 
			dbo.FNADateFormat(as_of_date) [As Of Date],   
			isnull(gsm.gl_account_number, 'Undefined') AS [GL Number],   
			isnull(gsm.gl_account_name, case when (tempRMV.Gl_Number = -1) then '-1.Earnings (Realized)' else '-2.Cash' end) AS [Account Name],   
			CASE WHEN(SUM(tempRMV.Debit) >= SUM(tempRMV.Credit)) THEN   
			round((SUM(tempRMV.Debit) - SUM(tempRMV.Credit)), @rounding_points)   
			ELSE 0 END AS [Debit Amount],   
			CASE WHEN (SUM(tempRMV.Debit) <= SUM(tempRMV.Credit)) THEN   
			round((SUM(tempRMV.Credit) - SUM(tempRMV.Debit)), @rounding_points)   
			ELSE 0 END AS [Credit Amount]   
		FROM #temp_MTM_JEP tempRMV(NOLOCK) LEFT OUTER JOIN   
			gl_system_mapping gsm(NOLOCK) ON isnull(tempRMV.Gl_Number, -1) = gsm.gl_number_id   
			  
			GROUP BY as_of_date, isnull(gsm.gl_account_number, 'Undefined'),   
			isnull(gsm.gl_account_name, case when (tempRMV.Gl_Number = -1) then '-1.Earnings (Realized)' else '-2.Cash' end)   
			HAVING abs(SUM(tempRMV.Debit) - SUM(tempRMV.Credit)) > 0.01   
			Else   
			select dbo.FNADateFormat(as_of_date) [As Of Date],   
			sum(u_hedge_mtm) [Settlement Rec(+)/Pay(-)],   
			sum(u_hedge_st_asset) [Account Receivable Dr(+)/Cr(-)],   
			sum(u_hedge_st_liability + u_liability) [Account Payable Dr(+)/Cr(-)],   
			sum(u_pnl_inventory) [Inventory Dr(+)/Cr(-)],   
			sum(u_pnl_settlement + u_sur_expense + u_inv_expense + u_exp_expense + u_revenue) [Expenses Dr(+)/Cr(-)]   
		from 
			#temp RMV   
			group by as_of_date   
END   
  
IF @summary_option ='3333'   
	IF @report_type = '111'   
	SELECT 
		dbo.FNADateFormat(as_of_date) [As Of Date],   
		dbo.FNADateFormat(term_month) as [Production Month],  
		Counterparty,   
		isnull(gsm.gl_account_number, 'Undefined') AS [GL Number],   
		isnull(gsm.gl_account_name, case when (tempRMV.Gl_Number = -1) then '-1.Earnings (Realized)' else '-2.Cash' end) AS [Account Name],   
		CASE WHEN(SUM(tempRMV.Debit) >= SUM(tempRMV.Credit)) THEN   
		round((SUM(tempRMV.Debit) - SUM(tempRMV.Credit)), @rounding_points)   
		ELSE 0 END AS [Debit Amount],   
		CASE WHEN (SUM(tempRMV.Debit) <= SUM(tempRMV.Credit)) THEN   
		round((SUM(tempRMV.Credit) - SUM(tempRMV.Debit)), @rounding_points)   
		ELSE 0 END AS [Credit Amount]   
	FROM 
		#temp_MTM_JEP tempRMV(NOLOCK) 
		LEFT OUTER JOIN gl_system_mapping gsm(NOLOCK) ON isnull(tempRMV.Gl_Number, -1) = gsm.gl_number_id 	  
	GROUP BY 
		term_month, as_of_date, isnull(gsm.gl_account_number, 'Undefined'),   
		isnull(gsm.gl_account_name, case when (tempRMV.Gl_Number = -1) then '-1.Earnings (Realized)' else '-2.Cash' end),Counterparty   
	HAVING 
		abs(SUM(tempRMV.Debit) - SUM(tempRMV.Credit)) > 0.01   
	ORDER BY 
		dbo.FNADateFormat(as_of_date), dbo.FNADateFormat(term_month),Counterparty   
Else   
	SELECT 
		dbo.FNADateFormat(as_of_date) [As Of Date], dbo.FNADateFormat(term_month) as [Production Month],   
		Counterparty,   
		sum(u_hedge_mtm) [Settlement Rec(+)/Pay(-)],   
		sum(u_hedge_st_asset) [Account Receivable Dr(+)/Cr(-)],   
		sum(u_hedge_st_liability + u_liability) [Account Payable Dr(+)/Cr(-)],   
		sum(u_pnl_inventory) [Inventory Dr(+)/Cr(-)],   
		sum(u_pnl_settlement + u_sur_expense + u_inv_expense + u_exp_expense + u_revenue) [Expenses Dr(+)/Cr(-)]   
	FROM 
		#temp RMV   
	GROUP BY 
		as_of_date, term_month, Counterparty   
	ORDER BY  
		dbo.FNADateFormat(as_of_date), dbo.FNADateFormat(term_month),Counterparty   
  
--print @summary_option   
  
--Trial Balance Report   
IF @summary_option ='6666'   
  
	SELECT   
		isnull(pre.[Bus Unit.Object.Subsidiary], cur.[Bus Unit.Object.Subsidiary]) [GL Number],   
		isnull(pre.[Account Description], cur.[Account Description]) [Account Description],   
		round(sum(isnull(pre.[Prior Period Amount], 0)), @rounding_points) as [Prior Cumulative Amount],   
		sum(isnull(pre.[Prior Period Units],0)) as [Prior Cumulative Units],   
		round(sum(isnull(cur.[Current Period Amount], 0)), @rounding_points) as [Current Amount],   
		sum(isnull(cur.[Current Period Units],0)) as [Current Units],   
		round(sum(isnull(pre.[Prior Period Amount], 0)) +   
		sum(isnull(cur.[Current Period Amount], 0)), @rounding_points) as [Ending Amount],   
		sum(isnull(pre.[Prior Period Units],0)) +   
		sum(isnull(cur.[Current Period Units],0)) as [Ending Units]   
	FROM   
		(
			SELECT 
				isnull(gsm.gl_account_number, '-1') AS [Bus Unit.Object.Subsidiary],   
				isnull(gsm.gl_account_name, case when (tempRMV.Gl_Number = -1)   
				then '-1.Earnings (Realized)' else '-2.Cash' end) AS [Account Description],   
				round(SUM(tempRMV.Debit) + (-1 * SUM(tempRMV.Credit)), @rounding_points) as [Prior Period Amount],   
				sum(volume) [Prior Period Units]			  
			FROM 
				#temp_MTM_JEP tempRMV(NOLOCK) 
				LEFT OUTER JOIN gl_system_mapping gsm(NOLOCK) ON isnull(tempRMV.Gl_Number, -1) = gsm.gl_number_id			  
			WHERE cast(dbo.FNAGetContractMonth(as_of_date) AS DATETIME) <   
				cast(dbo.FNAGetContractMonth(@as_of_date) AS DATETIME)   
				GROUP BY isnull(gsm.gl_account_number, '-1'),   
				isnull(gsm.gl_account_name, case when (tempRMV.Gl_Number = -1)   
				then '-1.Earnings (Realized)' else '-2.Cash' end)   
		) pre   
		FULL OUTER JOIN   
		(   
			SELECT 
				isnull(gsm.gl_account_number, '-1') AS [Bus Unit.Object.Subsidiary],   
				isnull(gsm.gl_account_name, case when (tempRMV.Gl_Number = -1)   
				then '-1.Earnings (Realized)' else '-2.Cash' end) AS [Account Description],   
				round(SUM(tempRMV.Debit) + (-1 * SUM(tempRMV.Credit)), @rounding_points) as [Current Period Amount],   
				sum(volume) [Current Period Units] 			  
			FROM 
				#temp_MTM_JEP tempRMV(NOLOCK) 
				LEFT OUTER JOIN gl_system_mapping gsm(NOLOCK) ON isnull(tempRMV.Gl_Number, -1) = gsm.gl_number_id  			  
			WHERE 
				dbo.FNAGetContractMonth(as_of_date) = dbo.FNAGetContractMonth(@as_of_date)   
			GROUP BY isnull(gsm.gl_account_number, '-1'),   
					isnull(gsm.gl_account_name, case when (tempRMV.Gl_Number = -1) then '-1.Earnings (Realized)' else '-2.Cash' end)   
		) cur ON cur.[Bus Unit.Object.Subsidiary] = pre.[Bus Unit.Object.Subsidiary]   
	GROUP BY 
		 isnull(pre.[Bus Unit.Object.Subsidiary], cur.[Bus Unit.Object.Subsidiary]),   
		 isnull(pre.[Account Description], cur.[Account Description])   
	  

 
IF @summary_option ='5555' 
	BEGIN
	
	IF @entries = 'b'
		SELECT 
				isnull(gsm.gl_account_number, '-1') AS [GL Number],   
				ISNULL(tempRMV.netting,'') + isnull(gsm.gl_account_name, case when (tempRMV.Gl_Number = -1)   
				then '-1.Earnings (Realized)' else '-2.Cash' end)  AS [Account Description],   
				-- SUM(tempRMV.Debit) + (-1 * SUM(tempRMV.Credit)) as [Amount],   
				case when SUM(tempRMV.Debit)>SUM(tempRMV.Credit) then round(SUM(round(tempRMV.Debit,2,0))-SUM(round(tempRMV.Credit,2,0)), 2,0) else 0 end as [Debit Amount],   
				case when SUM(tempRMV.Credit)>SUM(tempRMV.Debit) then round(SUM(round(tempRMV.Credit,2,0))-SUM(round(tempRMV.Debit,2,0)), 2,0) else 0 end [Credit Amount],   
				SUM(tempRMV.Debit) + (SUM(tempRMV.Credit)) as [Amount],   
				case when SUM(tempRMV.Debit)>SUM(tempRMV.Credit) then 'Debit' ELSE 'Credit' END AS [Type],
				Counterparty+'('+line_item+')' [Remarks],   
				dbo.FNAContractMonthFormat(term_month) as [Cost Object],   
				'X' [Cost Object Type],   
				case when sum(volume)=0 then NULL else round(sum(volume), 0) end as [Units],   
				case when sum(volume)=0 then NULL else su.uom_desc end [Units of Measurement],   
				'' [Subledger Type],   
				max(tempRMV.Subledger_code) [Subledger],
				tempRMV.counterparty_id,
				tempRMV.invoice_line_item_id,
				term_month,
				tempRMV.estimate_actual,
				tempRMV.contract_id,
				tempRMV.Counterparty,
				cg.contract_name contract,
				tempRMV.as_of_date,
				tempRMV.netting_group_id,
				tempRMV.netting_group_name 	  
			FROM 
				#temp_MTM_JEP tempRMV(NOLOCK) 
				LEFT OUTER JOIN gl_system_mapping gsm(NOLOCK) ON isnull(tempRMV.Gl_Number, -1) = gsm.gl_number_id   
				LEFT JOIN source_uom su on su.source_uom_id = tempRMV.uom_id
				LEFT JOIN contract_group cg ON tempRMV.contract_id = cg.contract_id		  
			WHERE 
				isnull(gsm.gl_account_number, '-1') = isnull(@gl_number ,isnull(gsm.gl_account_number, '-1'))	  
				AND gsm.gl_account_number is not null	
			GROUP BY 
				isnull(gsm.gl_account_number, '-1'),   
				ISNULL(tempRMV.netting,'') + isnull(gsm.gl_account_name, case when (tempRMV.Gl_Number = -1)   
				then '-1.Earnings (Realized)' else '-2.Cash' end) ,   
				Counterparty+'('+line_item+')', dbo.FNAContractMonthFormat(term_month), su.uom_desc ,
				tempRMV.uom_id,tempRMV.invoice_line_item_id,tempRMV.counterparty_id,term_month,tempRMV.estimate_actual,tempRMV.contract_id,cg.contract_name,tempRMV.Counterparty,tempRMV.as_of_date,tempRMV.netting_group_id,
				tempRMV.netting_group_name 	  	    
				HAVING abs(SUM(tempRMV.Debit) - SUM(tempRMV.Credit)) > 0.01  

	  ELSE
		SELECT 
			isnull(gsm.gl_account_number, '-1') AS [GL Number],   
			ISNULL(tempRMV.netting,'') + isnull(gsm.gl_account_name, case when (tempRMV.Gl_Number = -1)   
			then '-1.Earnings (Realized)' else '-2.Cash' end)  AS [Account Description],   
			-- SUM(tempRMV.Debit) + (-1 * SUM(tempRMV.Credit)) as [Amount],   
			case when SUM(tempRMV.Debit)>SUM(tempRMV.Credit) then round(SUM(round(tempRMV.Debit,2,0))-SUM(round(tempRMV.Credit,2,0)), 2,0) else 0 end as [Debit Amount],   
			case when SUM(tempRMV.Credit)>SUM(tempRMV.Debit) then round(SUM(round(tempRMV.Credit,2,0))-SUM(round(tempRMV.Debit,2,0)), 2,0) else 0 end [Credit Amount],   
			-- round(SUM(tempRMV.Debit) + (-1 * SUM(tempRMV.Credit)), 3) as [Amount],   
			-- round(SUM(tempRMV.Debit) + (SUM(tempRMV.Credit)), 3) as [Amount],   
			Counterparty+'('+line_item+')' [Remarks],   
			dbo.FNAContractMonthFormat(term_month) as [Cost Object],   
			'X' [Cost Object Type],   
			case when sum(volume)=0 then NULL else round(sum(volume), 0) end as [Units],   
			case when sum(volume)=0 then NULL else su.uom_desc end [Units of Measurement],   
			'' [Subledger Type],   
			max(Subledger_code) [Subledger]	  
		FROM 
			#temp_MTM_JEP tempRMV(NOLOCK) 
			LEFT OUTER JOIN gl_system_mapping gsm(NOLOCK) ON isnull(tempRMV.Gl_Number, -1) = gsm.gl_number_id   
			LEFT JOIN source_uom su on su.source_uom_id = tempRMV.uom_id		  
		WHERE 
			isnull(gsm.gl_account_number, '-1') = isnull(@gl_number ,isnull(gsm.gl_account_number, '-1'))	  
			AND gsm.gl_account_number is not null	  
		GROUP BY 
			isnull(gsm.gl_account_number, '-1'),   
			ISNULL(tempRMV.netting,'') + isnull(gsm.gl_account_name, case when (tempRMV.Gl_Number = -1)   
			then '-1.Earnings (Realized)' else '-2.Cash' end) ,   
			Counterparty+'('+line_item+')', dbo.FNAContractMonthFormat(term_month), su.uom_desc ,tempRMV.uom_id 
			HAVING abs(SUM(tempRMV.Debit) - SUM(tempRMV.Credit)) > 0.01  
		ORDER BY Counterparty+'('+line_item+')' ASC, dbo.FNAContractMonthFormat(term_month) asc   
		
	RETURN 
end  

IF @summary_option ='5555' AND @as_of_date_to IS NOT NULL   
		SELECT 
			dbo.FNADateFormat(as_of_date) [AsOfDate],   
			isnull(gsm.gl_account_number, '-1') AS [Bus Unit.Object.Subsidiary],   
			isnull(gsm.gl_account_name, case when (tempRMV.Gl_Number = -1)   
			then '-1.Earnings (Realized)' else '-2.Cash' end) AS [Account Description],   
			-- SUM(tempRMV.Debit) + (-1 * SUM(tempRMV.Credit)) as [Amount],   
			case when SUM(tempRMV.Debit)>SUM(tempRMV.Credit) then round(SUM(round(tempRMV.Debit,2,0))-SUM(round(tempRMV.Credit,2,0)), 2,0) else 0 end as [Dr Amount],   
			case when SUM(tempRMV.Credit)>SUM(tempRMV.Debit) then round(SUM(round(tempRMV.Credit,2,0))-SUM(round(tempRMV.Debit,2,0)), 2,0) else 0 end [Cr Amount],   
			-- round(SUM(tempRMV.Debit) + (-1 * SUM(tempRMV.Credit)), 3) as [Amount],   
			-- round(SUM(tempRMV.Debit) + (SUM(tempRMV.Credit)), 3) as [Amount],   
			Counterparty+'('+line_item+')' [Remark],   
			dbo.FNAContractMonthFormat(term_month) as [Cost Object1],   
			'X' [Cost Object Type],   
			round(max(volume), 2) [Units],   
			case when isnull(sum(volume),'')='' then '' else su.uom_desc end [Units of Measure],   
			'' [Subledger Type],   
			max(Subledger_code) [Subledger]		  
		FROM 
			#temp_MTM_JEP tempRMV(NOLOCK)
			LEFT OUTER JOIN gl_system_mapping gsm(NOLOCK) ON isnull(tempRMV.Gl_Number, -1) = gsm.gl_number_id   
			LEFT JOIN source_uom su on su.source_uom_id = tempRMV.uom_id		  
		WHERE 
			isnull(gsm.gl_account_number, '-1') = isnull(@gl_number ,isnull(gsm.gl_account_number, '-1'))   
			AND cast(dbo.FNAGetContractMonth(as_of_date) as DATETIME) <=   
			case when (@as_of_date = '1990-01-01') then   
			cast(dbo.FNAGetContractMonth(dateadd(mm, -1, @as_of_date_to)) as DATETIME)   
			else cast(dbo.FNAGetContractMonth(@as_of_date_to)as DATETIME) end   
			and gsm.gl_account_number is not null   
			GROUP BY as_of_date, isnull(gsm.gl_account_number, '-1'),   
			isnull(gsm.gl_account_name, case when (tempRMV.Gl_Number = -1)   
			then '-1.Earnings (Realized)' else '-2.Cash' end),   
			Counterparty, dbo.FNAContractMonthFormat(term_month), su.uom_desc   
		ORDER BY as_of_date, Counterparty ASC, dbo.FNAContractMonthFormat(term_month) asc   
  
  
IF @summary_option ='4444'   
	IF @report_type = '111'   
		SELECT dbo.FNADateFormat(as_of_date) [As Of Date],   
			dbo.FNADateFormat(term_month) as [Production Month],   
			Counterparty,   
			isnull(gsm.gl_account_number, 'Undefined') AS [GL Number],   
			isnull(gsm.gl_account_name, case when (tempRMV.Gl_Number = -1) then '-1.Earnings (Realized)' else '-2.Cash' end) AS [Account Name],   
			case when SUM(tempRMV.Debit)>SUM(tempRMV.Credit) then round(SUM(round(tempRMV.Debit,2,0))-SUM(round(tempRMV.Credit,2,0)), 2,0) else 0 end as [Debit Amount],   
			case when SUM(tempRMV.Credit)>SUM(tempRMV.Debit) then round(SUM(round(tempRMV.Credit,2,0))-SUM(round(tempRMV.Debit,2,0)), 2,0) else 0 end [Credit Amount]
		FROM 
			#temp_MTM_JEP tempRMV(NOLOCK)
			LEFT JOIN gl_system_mapping gsm(NOLOCK) ON isnull(tempRMV.Gl_Number, -1) = gsm.gl_number_id   
		  
		WHERE term_month < dbo.FNAGetContractMonth(as_of_date)   
		  
		GROUP BY as_of_date, term_month, Counterparty, isnull(gsm.gl_account_number, 'Undefined'),   
		isnull(gsm.gl_account_name, case when (tempRMV.Gl_Number = -1) then '-1.Earnings (Realized)' else '-2.Cash' end)   
		HAVING abs(SUM(tempRMV.Debit) - SUM(tempRMV.Credit)) > 0.01   
	ELSE   
		select 
			dbo.FNADateFormat(as_of_date) [As Of Date], dbo.FNADateFormat(term_month) as [Production Month],   
			case when (max(adjustment_amount) is null) then   
			dbo.FNAHyperLinkText(10131000, cast(link_id as varchar), cast(link_id as varchar))   
			else link_id end [Sources],   
			deal_id [Ref Deal ID],
			type Type,   
			Counterparty,		  
			sum(u_hedge_mtm) [Settlement Rec(+)/Pay(-)],   
			sum(u_rec_mtm) [REC Value Long(-)/Short(+)],   
			sum(u_hedge_st_asset) [Account Receivable Dr(+)/Cr(-)],   
			sum(u_hedge_st_liability + u_liability) [Account Payable Dr(+)/Cr(-)],   
			sum(u_pnl_inventory) [Inventory Dr(+)/Cr(-)],   
			sum(u_pnl_settlement + u_sur_expense + u_inv_expense + u_exp_expense + u_revenue) [Expenses Dr(+)/Cr(-)],   
			sum(adjustment_amount) [Debit Adjusments],   
			sum(adjustment_amount) [Credit Adjusments]   
		from 
			#temp RMV   
		WHERE 
			term_month < dbo.FNAGetContractMonth(as_of_date)   
		group by as_of_date, term_month, link_id, Counterparty, deal_id, type   
  
  
IF @summary_option ='1111'   
	IF @report_type = '111'   
		SELECT 
				isnull(gsm.gl_account_number, 'Undefined') AS [GL Number],   
				isnull(gsm.gl_account_name, case when (tempRMV.Gl_Number = -1) then '-1.Earnings (Realized)' else '-2.Cash' end) AS [Account Name],   
				CASE WHEN(SUM(tempRMV.Debit) >= SUM(tempRMV.Credit)) THEN   
				round((SUM(tempRMV.Debit) - SUM(tempRMV.Credit)), @rounding_points)   
				ELSE 0 END AS [Debit Amount],   
				CASE WHEN (SUM(tempRMV.Debit) <= SUM(tempRMV.Credit)) THEN   
				round((SUM(tempRMV.Credit) - SUM(tempRMV.Debit)), @rounding_points)   
				ELSE 0 END AS [Credit Amount]   
			FROM 
				#temp_MTM_JEP tempRMV(NOLOCK) 
				LEFT OUTER JOIN	gl_system_mapping gsm(NOLOCK) ON isnull(tempRMV.Gl_Number, -1) = gsm.gl_number_id   
			GROUP BY 
				isnull(gsm.gl_account_number, 'Undefined'),   
				isnull(gsm.gl_account_name, case when (tempRMV.Gl_Number = -1) then '-1.Earnings (Realized)' else '-2.Cash' end)   
				HAVING abs(SUM(tempRMV.Debit) - SUM(tempRMV.Credit)) > 0.01   
				Else   
				select   
				sum(u_hedge_mtm) [Settlement Rec(+)/Pay(-)],   
				sum(u_hedge_st_asset) [Account Receivable Dr(+)/Cr(-)],   
				sum(u_hedge_st_liability + u_liability) [Account Payable Dr(+)/Cr(-)],   
				sum(u_pnl_inventory) [Inventory Dr(+)/Cr(-)],   
				sum(u_pnl_settlement + u_sur_expense + u_inv_expense + u_exp_expense + u_revenue) [Expenses Dr(+)/Cr(-)]   
			FROM 
			#temp RMV   
  


IF @summary_option ='j' 
BEGIN

create table #line_item(line_item varchar(100) COLLATE DATABASE_DEFAULT )
insert into #line_item(line_item)
select [description] from static_data_value 
	where value_id in (295346,295347,295350,295351,295363,295375,295377,295494,295500,295492,295352,295353,295358,295359,295360,295364,295373,295374,295378,295379,295380,295388,295389,295393,295394,295397,295398,295447,295483,295838,295345,295361,295368,295369,295829,295830,295486)

if @jde_report_type='a'		

		select
			 cast('CEINV'  as char(10))[EDI User ID],
			cast('STR'+dbo.fnalpad(cast(datepart(mm,tempRMV.[as_of_date]) as varchar),2,'0')+cast(datepart(yy,tempRMV.[as_of_date]) as varchar)+'.'+isnull(si.invoice_number,'0000') as char(22)) [EDI Transaction Number],
			--cast('1' as char(7)) [EDI Line Number],
			cast(row_number() OVER (PARTITION BY tempRMV.counterparty_id order by tempRMV.counterparty_id) as char(7)) as [EDI Line Number],
			--cast('STR'+dbo.fnalpad(cast(datepart(mm,getdate()) as varchar),2,'0')+dbo.fnalpad(cast(datepart(dd,getdate()) as varchar),2,'0')+cast(datepart(yy,getdate()) as varchar)+dbo.fnalpad(cast(datepart(hh,getdate()) as varchar),2,'0')+dbo.fnalpad(cast(datepart(mi,getdate()) as varchar),2,'0') as char(15)) [EDI Batch Number],
			cast('STR'+@report_date  as char(15)) [EDI Batch Number],
			cast(dbo.fnaGeogian2Julian(tempRMV.as_of_date) as char(6)) [EDI Transmission Date],
			'B' [EDI Send/Receive Indicator],
			'0' [Processed],
			'A' [EDI Transaction Action],
			'J' [EDI Transaction Type],
			cast(fs.tax_payer_id as char(5)) [Document Company],
			cast(' ' as CHAR(2)) [Document Type],
			cast(dbo.fnaGeogian2Julian(getdate()) as char(6)) [G/L Date],
			cast(dbo.fnaGeogian2Julian(getdate()) as char(6)) [Service/Tax Date],
			cast(fs.tax_payer_id as char(5)) [Company],
			cast(isnull(gsm.gl_account_number,'') as char(29)) [Account Number -input],
			'2' [Account Mode-GL],
			cast(isnull(left(gsm.gl_account_number,charindex('.',gsm.gl_account_number,1)-1),'') as char(12)) [Cost Center / BU],
			cast(isnull(right(gsm.gl_account_number,len(gsm.gl_account_number)-charindex('.',gsm.gl_account_number,1)),'') as char(6)) [Object],
			cast(isnull(case when charindex('.',gsm.gl_account_number,charindex('.',gsm.gl_account_number)+1)>1 then substring(gsm.gl_account_number,charindex('.',gsm.gl_account_number,charindex('.',gsm.gl_account_number)+1)+1,len(gsm.gl_account_number)) else '' end,'') as char(8)) [Subsidiary],
			cast(isnull(tempRMV.Subledger_code,'') as char(8)) [Subledger] ,
			'X' [Subledger Type],
			'AA' [Ledger Type],
			'20' [Century],
			case when tempRMV.amount<0 then '0' else '-' end +RIGHT('000000000000000'+cast(cast((cast(isnull(abs(round(tempRMV.amount,2,0)),0)*100 as money)) as decimal(20,0)) as varchar(100)),14) [Line Amount],
	--		case when show_volume='y' then case when tempRMV.line_volume<=0 then cast(' ' as char(15)) else RIGHT('00000000000000'+cast(cast(isnull(tempRMV.line_volume,0) as decimal(20,0)) as varchar(20)) ,15) end else  cast(' ' as char(15)) end [Units],			
	--		case when show_volume='y' then cast(isnull(su.uom_desc,'') as char(4)) else  cast(' ' as char(4)) end [Unit of Measure],

			case when li.line_item is not null then case when tempRMV.line_volume<=0 then cast(' ' as char(15)) else RIGHT('00000000000000'+cast(cast(isnull(tempRMV.line_volume,0) as decimal(20,0)) as varchar(20))+'00' ,15) end else  cast(' ' as char(15)) end [Units],			
			case when li.line_item is not null then case when tempRMV.line_volume<=0 then cast(' ' as char(4)) else cast(isnull(su.uom_desc,'') as char(4)) end else  cast(' ' as char(4)) end [Unit of Measure],

			cast(isnull(pf.entity_name,'')+' '+isnull(tempRMV.counterparty,'') as char(30)) [Explanation],
			cast(tempRMV.line_item +' '+dbo.fnalpad(cast(datepart(mm,tempRMV.term_month) as varchar),2,'0')+'/'+right(cast(datepart(yy,tempRMV.term_month) as varchar),2) as char(30)) [Remark],
			cast(' ' as char(8)) [Reference 1],
			cast(' ' as char(8)) [Reference 2],
			cast(ltrim(rtrim(isnull(cg.UD_contract_id,''))) as char(8)) as [Customer Number]
		from 
			#temp_MTM_JEP tempRMV(NOLOCK)  
			INNER JOIN gl_system_mapping gsm(NOLOCK) ON isnull(tempRMV.Gl_Number, -1) = gsm.gl_number_id   
			left join source_uom su on su.source_uom_id = tempRMV.line_uom_id 
			left join fas_subsidiaries fs on tempRMV.[sub_entity_id]=fs.fas_subsidiary_id 
			left join portfolio_hierarchy pf on fs.fas_subsidiary_id=pf.entity_id
			left join (select counterparty_id,min([status]) [status],
			max(invoice_number) invoice_number,(term_month) term_month,
			max(update_ts)update_ts from save_invoice where [status]='s'  
		group by counterparty_id, term_month) si on si.counterparty_id=tempRMV.counterparty_id
		--and si.as_of_date=tempRMV.as_of_date 
		and si.term_month=tempRMV.term_month 
		left join rec_generator rg on rg.ppa_counterparty_id=tempRMV.counterparty_id
		left join contract_group cg  on cg.contract_id=rg.ppa_contract_id
		left join #line_item li on li.line_item=tempRMV.line_item
		--order by [EDI Line Number]
		
		--where gsm.gl_code1_value_id=10004  

		else if @jde_report_type='b' --- JDE Report Format 2
		select
			cast('CEINV'  as char(10))[EDI User ID],
			cast('STR'+dbo.fnalpad(cast(datepart(mm,tempRMV.[as_of_date]) as varchar),2,'0')+cast(datepart(yy,tempRMV.[as_of_date]) as varchar)+'.'+isnull(si.invoice_number,'0000') as char(22)) [EDI Transaction Number],
			cast(row_number() OVER (PARTITION BY tempRMV.counterparty_id order by tempRMV.counterparty_id) as char(7)) as [EDI Line Number],
			--cast('STR'+dbo.fnalpad(cast(datepart(mm,getdate()) as varchar),2,'0')+dbo.fnalpad(cast(datepart(dd,getdate()) as varchar),2,'0')+cast(datepart(yy,getdate()) as varchar)+dbo.fnalpad(cast(datepart(hh,getdate()) as varchar),2,'0')+dbo.fnalpad(cast(datepart(mi,getdate()) as varchar),2,'0') as char(15)) [EDI Batch Number],
			cast('STR'+@report_date  as char(15)) [EDI Batch Number],
			cast(dbo.fnaGeogian2Julian(tempRMV.as_of_date) as char(6)) [EDI Transmission Date],
			'0' [Processed],
			'A' [EDI Transaction Action],
			'I' [EDI Transaction Type],
			'I' [Batch File Discount Handling Flag],
			cast(isnull(cg.UD_contract_id,'') as char(8)) as [Customer Number],
			'RI' [Document Type],
			cast(dbo.fnaGeogian2Julian(isnull(si.update_ts,getdate())) as char(6)) [G/L Date],
			cast(dbo.fnaGeogian2Julian(isnull(si.update_ts,getdate())) as char(6)) [Invoice Date],
			cast(dbo.fnaGeogian2Julian(dbo.FNAInvoiceDueDate(isNUll(si.update_ts,getdate()),invoice_due_date, NULL,cg.payment_days)) as char(6)) [Date Due],
			cast(dbo.fnaGeogian2Julian(dbo.FNAInvoiceDueDate(isNUll(si.update_ts,getdate()),invoice_due_date, NULL,cg.payment_days)) as char(6)) [Discount Date Due],
			cast(dbo.fnaGeogian2Julian(getdate()) as char(6)) [Service/Tax Date],
			cast(fs.tax_payer_id as char(5)) [Company],
			cast('EM' as char(4)) as [GL Class],
			'2' [Account Mode-GL],
			cast(fs.tax_payer_id as char(12)) [Cost Center / BU],
			'20' [Century],
			'Y' as [Balanced Journal Entry],
			' ' as [Pay Status Code],
			--RIGHT('00000000000000'+cast(cast(round(cast(isnull(tempRMV.amount,0)*100 as money),0,2) as decimal(20,0)) as varchar(100)),15) [Line Amount],
			RIGHT('00000000000000'+cast(cast(abs(tempRMV.amount) as decimal(20,0)) as varchar(100)),15) [Line Amount],
			case when tempRMV.volume<=0 then cast('000000000000000' as char(15)) else RIGHT('00000000000000'+cast(cast(isnull(tempRMV.volume,0) as decimal(20,0)) as varchar(20))+'00' ,15) end [Units],			
			cast('KH' as char(4)) [Unit of Measure],
			cast('STR'+dbo.fnalpad(cast(datepart(mm,tempRMV.[as_of_date]) as varchar),2,'0')+cast(datepart(yy,tempRMV.[as_of_date]) as varchar)+isnull(si.invoice_number,'0000') as char(25)) as [Legacy Reference Field],
			cast(isnull(pf.entity_name,'')+' '+ltrim(rtrim(isnull(tempRMV.counterparty,''))) as char(40)) [Alpha Explanation],
			--cast(' ' as char(40)) [Alpha Explanation],
			cast('Sales for '+dbo.fnalpad(cast(datepart(mm,tempRMV.term_month) as varchar),2,'0')+'/'+right(cast(datepart(yy,tempRMV.term_month) as varchar),2) as char(30)) [Remark]
			
--		,tempRMV.counterparty_id
--into zzz_temp_b
		from  (select tmp.counterparty_id,counterparty_name counterparty,as_of_date,term_month,sub_entity_id,
				sum((cast(isnull(round(amount,2,0),0)*100 as money))) amount,
				sum(volume) volume,max(uom_id) uom_id,max(gl_number) gl_number,max(uom_name) uom_name,max(subledger_code) subledger_code 	
				from #temp_MTM_JEP  tmp left join source_counterparty sc on sc.source_counterparty_id=tmp.counterparty_id
				where credit<>0 group by tmp.counterparty_id,counterparty_name,as_of_date,term_month,sub_entity_id)
				tempRMV inner JOIN   
		gl_system_mapping gsm(NOLOCK) ON isnull(tempRMV.Gl_Number, -1) = gsm.gl_number_id   
		left join source_uom su on su.source_uom_id = tempRMV.uom_id 
		left join fas_subsidiaries fs on tempRMV.[sub_entity_id]=fs.fas_subsidiary_id 
		left join portfolio_hierarchy pf on fs.fas_subsidiary_id=pf.entity_id
		left join rec_generator rg on rg.ppa_counterparty_id=tempRMV.counterparty_id
		left join contract_group cg  on cg.contract_id=rg.ppa_contract_id
		left join (select counterparty_id,min([status]) [status],
		max(invoice_number) invoice_number,(term_month) term_month,
		max(update_ts)update_ts from save_invoice where [status]='s'  
		group by counterparty_id, term_month)si on si.counterparty_id=tempRMV.counterparty_id  
		--and si.as_of_date=tempRMV.as_of_date 
		and si.term_month=tempRMV.term_month
		
		else if @jde_report_type='c' -- JDE Report Format 3
		select
			cast('CEINV'  as char(10))[EDI User ID],
			cast('STR'+dbo.fnalpad(cast(datepart(mm,tempRMV.[as_of_date]) as varchar),2,'0')+cast(datepart(yy,tempRMV.[as_of_date]) as varchar)+'.'+isnull(si.invoice_number,'0000') as char(22)) [EDI Transaction Number],
			cast(row_number() OVER (PARTITION BY tempRMV.counterparty_id order by tempRMV.counterparty_id) as char(7)) as [EDI Line Number],
			--cast('STR'+dbo.fnalpad(cast(datepart(dd,getdate()) as varchar),2,'0')+dbo.fnalpad(cast(datepart(mm,getdate()) as varchar),2,'0')+cast(datepart(yy,getdate()) as varchar)+dbo.fnalpad(cast(datepart(hh,getdate()) as varchar),2,'0')+dbo.fnalpad(cast(datepart(mi,getdate()) as varchar),2,'0') as char(15)) [EDI Batch Number],
			cast('STR'+@report_date  as char(15)) [EDI Batch Number],
			'X' [Cost Object Type 1],
			cast(dbo.fnacontractmonthformat(tempRMV.term_month) as char(12)) as [Cost Object 1],
			cast( ' ' as char(1))[Cost Object Type 2],
			cast( ' ' as char(12))[Cost Object 2],
			cast( ' ' as char(1))[Cost Object Type 3],
			cast( ' ' as char(12))[Cost Object 3],
			cast( ' ' as char(1))[Cost Object Type 4],
			cast( ' ' as char(12))[Cost Object 4]
		from #temp_MTM_JEP tempRMV(NOLOCK) inner JOIN   
		gl_system_mapping gsm(NOLOCK) ON isnull(tempRMV.Gl_Number, -1) = gsm.gl_number_id   
		left join source_uom su on su.source_uom_id = tempRMV.uom_id 
		left join fas_subsidiaries fs on tempRMV.[sub_entity_id]=fs.fas_subsidiary_id 
		left join portfolio_hierarchy pf on fs.fas_subsidiary_id=pf.entity_id
		left join (select counterparty_id,min([status]) [status],
		max(invoice_number) invoice_number,(term_month) term_month,
		max(update_ts)update_ts from save_invoice where [status]='s'  
		group by counterparty_id, term_month) si on si.counterparty_id=tempRMV.counterparty_id 
		--and si.as_of_date=tempRMV.as_of_date 
		and si.term_month=tempRMV.term_month and si.status='s'
	else if @jde_report_type='d'
		select distinct counterparty_id,as_of_date from 
				#temp_MTM_JEP
end

--*****************FOR BATCH PROCESSING**********************************   
IF @batch_process_id is not null   
BEGIN   
SELECT @str_batch_table=dbo.FNABatchProcess('u',@batch_process_id,@batch_report_param,GETDATE(),NULL,NULL)   
EXEC(@str_batch_table)   
  
SELECT @str_batch_table=dbo.FNABatchProcess('c',@batch_process_id,@batch_report_param,GETDATE(),'spa_Create_Inventory_Journal_Entry_Report','Inventory Journal Entry Report')   
EXEC(@str_batch_table)   
  
END   
--********************************************************************   

