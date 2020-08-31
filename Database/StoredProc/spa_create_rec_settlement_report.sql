
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_create_rec_settlement_report]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_create_rec_settlement_report]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**
	Use to get rec settlement report. 

	Parameter
	@sub_entity_id : Sub Entity Id
	@strategy_entity_id : Strategy Entity Id
	@book_entity_id : Book Entity Id
	@book_deal_type_map_id : Book Deal Type Map Id
	@source_deal_header_id : Source Deal Header Id
	@deal_date_from : Deal Date From
	@deal_date_to : Deal Date To
	@counterparty_id : Counterparty Id
	@summary_option : s summary, d detail
	@INT_ext_flag : i INTernal, e external, b both
	@type : 'c' current, 'a' adjustment,  null  both
	@feeder_deal_id : Feeder Deal Id
	@prod_month : Prod Month
	@payment_ins_header_id : Payment Ins Header Id
	@rfp_report : Rfp Report
	@contract_id : Contract Id
	@estimate_calculation : Estimate Calculation
	@template_id : Template Id
	@invoice_type : Invoice Type
	@netting_group_id : Netting Group Id
	@statement_type : Statement Type
	@settlement_date : Settlement Date
	@calc_id : Calc Id
*/

CREATE PROCEDURE [dbo].[spa_create_rec_settlement_report]
		@sub_entity_id VARCHAR(100)=null, 
		@strategy_entity_id VARCHAR(100) = NULL, 
		@book_entity_id VARCHAR(100) = NULL, 
		@book_deal_type_map_id VARCHAR(5000) = null,
		@source_deal_header_id VARCHAR(5000)  = null,
		@deal_date_from VARCHAR(20),
		@deal_date_to VARCHAR(20),
		@counterparty_id VARCHAR(MAX),
		@summary_option VARCHAR(1), --s summary, d detail, 
		@INT_ext_flag VARCHAR(1),  -- i INTernal, e external, b both
		@type VARCHAR(1) =  null, --'c' means current, 'a' means adjustment, AND null means both						
		@feeder_deal_id VARCHAR(50)= NULL,
		@prod_month VARCHAR(20)=NULL	,
		@payment_ins_header_id INT=NULL,
		@rfp_report CHAR(1)='n',
		@contract_id VARCHAR(MAX)=NULL,
		@estimate_calculation CHAR(1)='n',
		@template_id VARCHAR(100)=NULL,
		@invoice_type CHAR(1) = NULL,
		@netting_group_id INT = NULL,
		@statement_type INT = NULL,
		@settlement_date VARCHAR(20) = NULL,
		@calc_id INT = NULL
		
AS
SET NOCOUNT ON 
/**************************TEST CODE START************************				
DECLARE	@sub_entity_id	VARCHAR(100)	=	NULL
DECLARE	@strategy_entity_id	VARCHAR(100)	=	NULL
DECLARE	@book_entity_id	VARCHAR(100)	=	NULL
DECLARE	@book_deal_type_map_id	VARCHAR(5000)	=	NULL
DECLARE	@source_deal_header_id	VARCHAR(5000)	=	NULL
DECLARE	@deal_date_from	VARCHAR(20)	=	'2014-01-31'
DECLARE	@deal_date_to	VARCHAR(20)	=	NULL
DECLARE	@counterparty_id	INT	=	1825
DECLARE	@summary_option	VARCHAR(1)	=	'i'
DECLARE	@INT_ext_flag	VARCHAR(1)	=	'e'
DECLARE	@type	VARCHAR(1)	=	NULL
DECLARE	@feeder_deal_id	VARCHAR(50)	=	NULL
DECLARE	@prod_month	VARCHAR(20)	=	'2014-01-01'
DECLARE	@payment_ins_header_id	INT	=	NULL
DECLARE	@rfp_report	CHAR(1)	=	NULL
DECLARE	@contract_id	INT	=	1201
DECLARE	@estimate_calculation	CHAR(1)	=	'n'
DECLARE	@template_id	VARCHAR(100)	=	NULL
DECLARE	@invoice_type	CHAR(1)	=	'i'
DECLARE	@netting_group_id	INT	=	-1
DECLARE	@statement_type	INT	=	NULL
DECLARE	@settlement_date	VARCHAR(20)	=	'1900-01-01'
IF OBJECT_ID(N'tempdb..#calc_formula_taxes', N'U') IS NOT NULL
	DROP TABLE	#calc_formula_taxes			
IF OBJECT_ID(N'tempdb..#calc_formula_value', N'U') IS NOT NULL
	DROP TABLE	#calc_formula_value			
IF OBJECT_ID(N'tempdb..#temp_c', N'U') IS NOT NULL
	DROP TABLE	#temp_c			
--**************************TEST CODE END************************/	

	DECLARE @sql_stmt VARCHAR(MAX)
	DECLARE @sql_stmt1 VARCHAR(MAX)
	DECLARE @sql_stmt_group VARCHAR(MAX)
	DECLARE @sql_stmt_where VARCHAR(MAX)
	DECLARE @interrupt_date VARCHAR(20)
	DECLARE @date_stmt VARCHAR(250)
	DECLARE @table_calc_invoice_volume_variance VARCHAR(50)
	DECLARE @table_calc_formula_value VARCHAR(50)
	DECLARE @table_calc_invoice_volume VARCHAR(50)
	DECLARE @sql VARCHAR(5000)

	IF @statement_type = 21502
		SET @invoice_type = NULL
		
	IF @template_id IS NOT NULL 
		SET @contract_id = NULL
	IF @estimate_calculation='y'
		BEGIN
			SET @table_calc_invoice_volume_variance = 'calc_invoice_volume_variance_estimates'
			SET @table_calc_invoice_volume = 'calc_invoice_volume_estimates'
			SET @table_calc_formula_value = 'calc_formula_value_estimates'
		END
	ELSE
		BEGIN
			SET @table_calc_invoice_volume_variance = 'calc_invoice_volume_variance'
			SET @table_calc_invoice_volume = 'calc_invoice_volume'
			SET @table_calc_formula_value = 'calc_formula_value'
		END
		

	IF @deal_date_to IS NULL
		SET @deal_date_to = @deal_date_from


	SET @date_stmt = ' BETWEEN ''' + dbo.FNAGetContractMonth(@deal_date_from)  + ''' AND ''' + 
		dbo.FNAGetContractMonth(@deal_date_to) + ''''

	-- check if netting calc id exists or not; used for attachment
		DECLARE @is_netting_group_exists INT 
		IF EXISTS (SELECT 1
		FROM
			calc_invoice_volume_variance civv
			INNER JOIN calc_invoice_volume_variance civv1 
			on civv1.calc_id = civv.netting_calc_id
		WHERE civv.netting_calc_id = @calc_id
		)
		BEGIN
			SET @is_netting_group_exists = 1
			SET @calc_id = -1
		END

	IF @calc_id = -1
		SET @calc_id = NULL

	CREATE TABLE #temp_c(
		[Order] INT,
		[Line Item] VARCHAR(500) COLLATE DATABASE_DEFAULT,
		[ProductionMonth] VARCHAR(500) COLLATE DATABASE_DEFAULT,
		[volume] MONEY,
		[UOM] VARCHAR(20) COLLATE DATABASE_DEFAULT,
		[price] VARCHAR(100) COLLATE DATABASE_DEFAULT,
		[VALUE] FLOAT,
		[debit_gl_number] INT,
		[credit_gl_number] INT,
		[other_var] CHAR(1) COLLATE DATABASE_DEFAULT,
		[group_by] VARCHAR(500) COLLATE DATABASE_DEFAULT,
		[deal_id]  NVARCHAR(100) COLLATE DATABASE_DEFAULT,
		[source_deal_header_id] INT,		
		[deal_date] DATETIME,
		[trade_type] VARCHAR(100) COLLATE DATABASE_DEFAULT,
		[Indexname] VARCHAR(100) COLLATE DATABASE_DEFAULT,		
		[fixed_price] FLOAT,
		[settled_price] FLOAT,
		[currency] VARCHAR(10) COLLATE DATABASE_DEFAULT,
		invoice_line_item_id INT,
		location VARCHAR(500) COLLATE DATABASE_DEFAULT,
		country VARCHAR(50) COLLATE DATABASE_DEFAULT,
		prod_date_to VARCHAR(20) COLLATE DATABASE_DEFAULT,
		calc_id INT	,
		counterparty NVARCHAR(100) COLLATE DATABASE_DEFAULT,
		entire_term_start DATETIME,
		entire_term_end DATETIME,
		description1 VARCHAR(100) COLLATE DATABASE_DEFAULT,
		contract_value FLOAT,
		market_value FLOAT,
		buy_sell CHAR(5) COLLATE DATABASE_DEFAULT,
		summary_prod_date DATETIME,	
		tax_summed FLOAT,		
		header_buy_sell_flag char(1) COLLATE DATABASE_DEFAULT,
		alias VARCHAR(200) COLLATE DATABASE_DEFAULT,		
       [deal_info] VARCHAR(100) COLLATE DATABASE_DEFAULT,
       [Indexcurvename]VARCHAR(100) COLLATE DATABASE_DEFAULT
	)


	CREATE TABLE #calc_formula_value(
		invoice_line_item_id INT,
		formula_id INT,
		prod_date DATETIME,
		as_of_date DATETIME,
		volume FLOAT,
		Price FLOAT,
		uom_id INT,
		include_item CHAR(1) COLLATE DATABASE_DEFAULT,
		deal_id INT,
		value FLOAT,
		invoice_type CHAR(1) COLLATE DATABASE_DEFAULT,
		calc_id INT,
		source_deal_header_id INT
	)
	
	CREATE TABLE #calc_formula_taxes(
		tax_summed FLOAT,
		source_deal_header_id INT
	)	
	
	SET  @sql_stmt = '	
		INSERT INTO #calc_formula_value
		SELECT
			cfv.invoice_line_item_id,
			cfv.formula_id,
			--cast(CAST(Year(civv.prod_date) AS VARCHAR)+''-''+ CAST(month(civv.prod_date) AS VARCHAR) +''-01'' AS datetime) AS prod_date,
			cfv.prod_date,
			civv.as_of_date,
			SUM(ISNULL(cfv.volume, '''')) AS volume,
			SUM(ISNULL(CASE WHEN fn.show_VALUE_id=1201 THEN (cfv.[VALUE]) ELSE NULL END, '''')) AS Price,
			civv.uom AS uom_id,
			MAX(ISNULL(fn.include_item, '''')) AS include_item,
			(cfv.deal_id) AS deal_id,
			sum(cfv.value),
			civv.invoice_type,
			civv.calc_id,
			cfv.source_deal_header_id
		FROM
			'+@table_calc_invoice_volume_variance+' civv 
			INNER JOIN calc_invoice_volume civ ON civ.calc_id=civv.calc_id 
			INNER JOIN '+@table_calc_formula_value+' cfv ON civv.calc_id=cfv.calc_id  
				AND civ.invoice_line_item_id=cfv.invoice_line_item_id
			LEFT JOIN formula_nested fn ON fn.formula_group_id=ISNULL(cfv.formula_id,-1) AND fn.sequence_order=cfv.seq_number
		WHERE
			ISNULL(civ.manual_input,''n'')=''n'' 
			AND civv.counterparty_id IN (SELECT item FROM dbo.SplitCommaSeperatedValues(''' + @counterparty_id + ''') )
			AND civv.as_of_date=('''+CAST(@deal_date_from AS VARCHAR)+''')
			AND civv.prod_date=('''+CAST(@prod_month AS VARCHAR)+''')
			AND cfv.is_final_result = ''y'''
			+case when @invoice_type IS NOT NULL then ' AND civv.invoice_type='''+@invoice_type+'''' else '' end+  
			+CASE WHEN @netting_group_id IS NOT NULL THEN ' AND ISNULL(civv.netting_group_id,-1)='+CAST(@netting_group_id AS VARCHAR) ELSE '' END+
			+CASE WHEN @settlement_date IS NOT NULL THEN ' AND civv.settlement_date='''+@settlement_date+'''' ELSE '' END +
			+CASE WHEN @contract_id IS NOT NULL THEN ' AND civv.contract_id IN (SELECT item FROM dbo.SplitCommaSeperatedValues(''' + @contract_id + '''))' ELSE '' END+  
			+CASE WHEN @calc_id IS NOT NULL THEN ' AND civv.calc_id='''+CAST(@calc_id AS VARCHAR)+'''' ELSE '' END+'  
			
		GROUP BY 
			cfv.invoice_line_item_id,cfv.formula_id,cfv.prod_date,--cast(CAST(Year(civv.prod_date) AS VARCHAR)+''-''+ CAST(month(civv.prod_date) AS VARCHAR) +''-01'' AS datetime),
			civv.as_of_date,civv.uom,(cfv.deal_id),civv.invoice_type,civv.calc_id,cfv.source_deal_header_id
		ORDER BY cfv.formula_id '
	EXEC(@sql_stmt)
	
	SET  @sql_stmt = '	INSERT INTO #calc_formula_taxes
						SELECT ROUND(SUM(ISNULL(p.tax_summed, '''')), 2) [tax_summed],
						       p.source_deal_header_id
						FROM   (
						           SELECT SUM(ISNULL(cfv.[value], '''')) [tax_summed],
						                  MAX(ISNULL(cfv.source_deal_header_id, sdd.source_deal_header_id)) [source_deal_header_id]
						           FROM   calc_formula_value cfv
						           INNER JOIN calc_invoice_volume_variance civv ON  civv.calc_id = cfv.calc_id
								   INNER JOIN static_data_value sd ON  sd.value_id = cfv.invoice_line_item_id
						           LEFT JOIN formula_nested fn 
										ON  fn.formula_group_id = cfv.formula_id 
										AND fn.sequence_order = cfv.seq_number
						           LEFT JOIN contract_group cg ON  cg.contract_id = cfv.contract_id
						           LEFT JOIN source_uom su ON  cg.volume_uom = su.source_uom_id
						           LEFT JOIN source_deal_detail sdd ON  sdd.source_deal_detail_id = cfv.deal_id
						           WHERE  civv.counterparty_id IN (SELECT item FROM dbo.SplitCommaSeperatedValues(''' + @counterparty_id + '''))
						                  AND YEAR(cfv.prod_date) = YEAR('' '+CAST(@prod_month AS VARCHAR)+' '')
						                  AND MONTH(cfv.prod_date) = MONTH('' '+CAST(@prod_month AS VARCHAR)+' '')
						                  AND civv.as_of_date = '''+CAST(@deal_date_from AS VARCHAR)+'''
						                  AND sd.description IN (''commodity charge'')
						                  AND civv.contract_id IN (SELECT item FROM dbo.SplitCommaSeperatedValues(''' + @contract_id + '''))
						                  AND civv.invoice_type = '''+@invoice_type+'''
						           GROUP BY ISNULL(cfv.source_deal_header_id, sdd.source_deal_header_id)

									UNION

									SELECT SUM(ISNULL(cfv.[value], '''')) [tax_summed]
										, MAX(ISNULL(cfv.source_deal_header_id, sdd.source_deal_header_id)) [source_deal_header_id]
									FROM calc_formula_value cfv
									INNER JOIN calc_invoice_volume_variance civv ON civv.calc_id = cfv.calc_id
									INNER JOIN static_data_value sd ON sd.value_id = cfv.invoice_line_item_id
									LEFT JOIN formula_nested fn ON fn.formula_group_id = cfv.formula_id
										AND fn.sequence_order = cfv.seq_number
									LEFT JOIN contract_group cg ON cg.contract_id = cfv.contract_id
									LEFT JOIN source_uom su ON cg.volume_uom = su.source_uom_id
									LEFT JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = cfv.deal_id
									WHERE civv.counterparty_id IN (SELECT item FROM dbo.SplitCommaSeperatedValues(''' + @counterparty_id + ''')) 
										AND YEAR(cfv.prod_date) = YEAR('''+CAST(@prod_month AS VARCHAR)+''')
										AND MONTH(cfv.prod_date) = MONTH('''+CAST(@prod_month AS VARCHAR)+''')
										AND civv.as_of_date = '''+CAST(@deal_date_from AS VARCHAR)+'''
										AND sd.description IN (''nmgrt'')
										AND civv.contract_id IN (SELECT item FROM dbo.SplitCommaSeperatedValues(''' + @contract_id + '''))
										AND civv.invoice_type = '''+@invoice_type+'''
									GROUP BY ISNULL(cfv.source_deal_header_id, sdd.source_deal_header_id)

									UNION

									SELECT SUM(ISNULL(cfv.[value], '''')) [tax_summed]
										, MAX(ISNULL(cfv.source_deal_header_id, sdd.source_deal_header_id)) [source_deal_header_id]
									FROM calc_formula_value cfv
									INNER JOIN calc_invoice_volume_variance civv ON civv.calc_id = cfv.calc_id
									INNER JOIN static_data_value sd ON sd.value_id = cfv.invoice_line_item_id
									LEFT JOIN formula_nested fn ON fn.formula_group_id = cfv.formula_id
										AND fn.sequence_order = cfv.seq_number
									LEFT JOIN contract_group cg ON cg.contract_id = cfv.contract_id
									LEFT JOIN source_uom su ON cg.volume_uom = su.source_uom_id
									LEFT JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = cfv.deal_id
									WHERE civv.counterparty_id IN (SELECT item FROM dbo.SplitCommaSeperatedValues(''' + @counterparty_id + '''))
										AND YEAR(cfv.prod_date) = YEAR('''+CAST(@prod_month AS VARCHAR)+''')
										AND MONTH(cfv.prod_date) = MONTH('''+CAST(@prod_month AS VARCHAR)+''')
										AND civv.as_of_date = '''+CAST(@deal_date_from AS VARCHAR)+'''
										AND sd.description IN (''county tax'')
										AND civv.contract_id IN (SELECT item FROM dbo.SplitCommaSeperatedValues(''' + @contract_id + '''))
										AND civv.invoice_type = '''+@invoice_type+'''
										and cfv.seq_number not in (1)
									GROUP BY ISNULL(cfv.source_deal_header_id, sdd.source_deal_header_id)
						) p GROUP BY source_deal_header_id'
	--PRINT @sql_stmt
	EXEC(@sql_stmt)
				
	
	SET  @sql_stmt = 
		'
		INSERT INTO #temp_c
		SELECT
			MAX(ISNULL(cgd.sequence_order,cctd.sequence_order)) AS [Order],
			CASE WHEN CAST(cgd.alias AS VARCHAR(100)) is null THEN ili.description ELSE sdv1.code END AS [line Item],			
			CASE WHEN cpt.int_ext_flag = ''b'' THEN (dbo.FNAGetContractMonth(civv.prod_date)) ELSE (COALESCE(sdd1.term_start,sdd.term_start,dbo.FNAGetContractMonth(civv.prod_date))) END ProdMonth,		
			'
			+ CASE WHEN @calc_id IS NULL THEN 'SUM(ISNULL(cfv.volume,civ.volume)) AS Volume,
			MAX(su.uom_name) UOM,
			ABS(SUM(ISNULL(CASE WHEN ih.invoice_id IS NOT NULL AND ind.invoice_amount<>0 THEN  ind.invoice_amount else ISNULL(cfv.value,civ.value) END, ''''))/(CASE WHEN SUM(ISNULL(cfv.volume,civ.volume)) = 0 THEN 1 ELSE SUM(ISNULL(cfv.volume,civ.volume)) END)) as Rate,
			 '
			ELSE
			'
			(SUM(ISNULL(CASE
					WHEN ISNULL(cfv.include_item,''n'')=''y'' THEN ''''
					WHEN ih.invoice_id IS NOT NULL THEN  ih.invoice_volume
					WHEN cfv.volume is not null THEN ISNULL(cfv.volume,civ.volume)
					WHEN ISNULL(civ.VALUE,0)=0 THEN ''''  
					WHEN ISNULL(civ.manual_input,'''')='''' AND civ.price_or_formula=''f'' 
					THEN ISNULL(cfv.volume,civ.volume)
					WHEN civ.manual_input=''y''  THEN cast(civ.Volume AS VARCHAR)  
					ELSE '''' END, ''''))) AS Volume,
			
			MAX(su.uom_name) UOM,
			ABS(max(ISNULL(cfv.value,civ.value))/
				NULLIF((round(max(case
				when isnull(cfv.include_item,''n'')=''y'' then ''''
				WHEN ih.invoice_id IS NOT NULL THEN  ih.invoice_volume
				when cfv.volume is not null then ISNULL(cfv.volume,civ.volume)
				when isnull(civ.value,0)=0 then ''''  
				when isnull(civ.manual_input,'''')='''' and civ.price_or_formula=''f'' 
				then ISNULL(cfv.volume,civ.volume)
				when civ.manual_input=''y''  then cast(civ.Volume as varchar) 
			ELSE '''' END),2,0)),0)) as  Rate,
			' END +
			'
			SUM(ISNULL(CASE WHEN ih.invoice_id IS NOT NULL AND ind.invoice_amount<>0 THEN  ind.invoice_amount else ISNULL(cfv.value,civ.value) END, '''')) AS Total,
			COALESCE(adgcd.debit_gl_number,adgc.debit_gl_number,adgc1.debit_gl_number,adgc2.debit_gl_number) debit_gl_number,   
			COALESCE(adgcd.credit_gl_number,adgc.credit_gl_number,adgc1.credit_gl_number,adgc2.credit_gl_number) credit_gl_number,
			''n'' ,
			sdv.description,
			sdh.deal_id,
			sdh.source_deal_header_id,           
			MAX(sdh.deal_date) deal_date,
			CASE WHEN CAST(cgd.alias AS VARCHAR(10)) is null THEN ili.description ELSE CAST(cgd.alias AS VARCHAR(10)) END AS [Trade Type],	
			MAX(com.commodity_name) IndexName,			
			MAX(ISNULL(sdd.fixed_price,sdd1.fixed_price)) fixed_price,
			ABS(CASE 
				WHEN MAX(sdh.option_flag)=''y'' THEN '''' 
				WHEN SUM(civ.VALUE)=0 THEN 0 ELSE (ISNULL(NULLIF(SUM(CASE 
			WHEN civv.book_entries=''i'' AND ind.invoice_amount<>0 THEN  ind.invoice_amount else
				(civ.VALUE) END),0),1)-MAX(sdd.fixed_price))/NULLIF((SUM(CASE
				WHEN ISNULL(cfv.include_item,''n'')=''y'' THEN ''''
				WHEN cfv.volume is not null THEN civ.volume
				WHEN civv.book_entries=''i'' THEN  civv.invoicevolume
				WHEN ISNULL(civ.VALUE,0)=0 THEN ''''  
				WHEN ISNULL(civ.manual_input,'''')='''' AND civ.price_or_formula=''f'' 
				THEN civ.volume
				WHEN civ.manual_input=''y''  THEN cast(civ.Volume AS VARCHAR) 
				ELSE '''' END)),0)+MAX(sdd.fixed_price) END) AS settled_price,
			MAX(ISNULL(sc.currency_name, sc1.currency_name)) Currency,MAX(cgd.invoice_line_item_id) invoice_line_item_id,
			MAX(sml.location_name) location,MAX(sdv_country.description) country,
			MAX(COALESCE(sdd1.term_end,sdd.term_end,civv.prod_date_to)) prod_date_to,
			'+ CASE WHEN @statement_type = 21502 THEN 'civv.calc_id' ELSE 'NULL' END+' calc_id,		
			MAX(cpt1.counterparty_name) [Counterparty],
			MAX(sdh.entire_term_start) entire_term_start,
			MAX(sdh.entire_term_end) entire_term_end,MAX(sdh.description1)description1,
			MAX(sds.contract_value)contract_value,MAX(sds.market_value)market_value,
			MAX(ISNULL(sdd.buy_sell_flag,sdd1.buy_sell_flag)) buy_sell,
			MAX(civv.prod_date) summary_prod_date,
			ABS(SUM(CASE WHEN ih.invoice_id IS NOT NULL AND ind.invoice_amount<>0 THEN  ind.invoice_amount else ISNULL(cfv.value,civ.value) END) - cf_tax.tax_summed) tax_summed,
			sdh.header_buy_sell_flag,
			sdv1.code [alias], concat(sdh.source_deal_header_id,''('',sdh.deal_id,'')''),
            MAX(spcd.curve_name) IndexCurveName 
			FROM  '		
			SET @sql_stmt1='
			'+@table_calc_invoice_volume_variance+' civv 
			LEFT JOIN contract_group cg ON cg.contract_id=civv.contract_id'
			SET @sql_stmt=@sql_stmt+@sql_stmt1+' '

			+ CASE WHEN (@rfp_report='y') THEN  
			' INNER JOIN (select max(as_of_date) as_of_date,counterparty_id,prod_date,contract_id,netting_group_id from '+@table_calc_invoice_volume_variance+' where finalized=''y'' group by counterparty_id,prod_date,contract_id,netting_group_id) a ON a.as_of_date=civv.as_Of_date AND  a.counterparty_id=civv.counterparty_id
					AND ISNULL(a.netting_group_id,a.contract_id)=ISNULL(civv.netting_group_id,civv.contract_id)
					AND a.prod_date=civv.prod_date ' 
			  ELSE 
				' AND (civv.as_of_date) = (''' + @deal_date_from  +''') ' END+ '
			LEFT JOIN '+@table_calc_invoice_volume+' civ on civ.calc_id=civv.calc_id AND ISNULL(civ.manual_input,''n'')=''n''	
			LEFT JOIN source_counterparty cpt ON cpt.source_counterparty_id = civv.counterparty_id 
			LEFT JOIN contract_group_detail cgd on cgd.contract_id = cg.contract_id 
				AND cgd.prod_type=
					CASE WHEN ISNULL(cg.term_start,'''')=''''	 THEN ''p''
					WHEN dbo.FNAGetContractMonth(cg.term_start)<=dbo.FNAGetContractMonth(civv.prod_date) THEN ''p''
					ELSE ''t'' END AND cgd.invoice_line_item_id=civ.invoice_line_item_id 
					--AND ISNULL(cgd.deal_type,0)=ISNULL(civ.deal_type_id,0)
					AND ((cgd.INT_END_month is not null
					AND dbo.FNAGetContractMonth(civv.prod_date)<cast(CASE WHEN cgd.INT_END_month=12 THEN 
					cast(year(civv.prod_date) AS VARCHAR) ELSE cast(year(civv.prod_date)+1 AS VARCHAR) END +''-''+cast(cgd.INT_END_month AS VARCHAR)+''-01'' AS datetime))
					or cgd.INT_END_month is null)
			LEFT JOIN static_data_value sdv1 ON sdv1.value_id = cast(cgd.alias as varchar(100)) 
			LEFT JOIN contract_charge_type cct on cct.contract_charge_type_id=ISNULL(cgd.contract_template,cg.contract_charge_type_id)
			LEFT JOIN contract_charge_type_detail cctd on cctd.ID=ISNULL(cgd.contract_component_template,cct.contract_charge_type_id)
				AND cctd.contract_charge_type_id = cct.contract_charge_type_id
				AND cctd.prod_type=
					CASE WHEN ISNULL(cg.term_start,'''')='''' THEN ''p'' 
						 WHEN dbo.fnagetcontractmonth(cg.term_start)<=dbo.fnagetcontractmonth(civv.prod_date) THEN ''p''
						 ELSE ''t'' END	AND cctd.invoice_line_item_id=civ.invoice_line_item_id 		

			'+
			CASE WHEN @payment_ins_header_id is not null THEN 
			' INNER JOIN payment_instruction_detail pid on pid.calc_detail_id=civ.calc_detail_id
			  INNER JOIN payment_instruction_header pih on pid.payment_ins_header_id=pih.payment_ins_header_id 
			  AND pih.payment_ins_header_id='+cast(@payment_ins_header_id AS VARCHAR) ELSE '' END +	
			' LEFT JOIN invoice_header ih on ih.counterparty_id=civv.counterparty_id  
					AND ih.contract_id=cg.contract_id AND ISNULL(cgd.include_invoice,''n'')=''y''
					AND ih.production_month=civv.prod_date
					AND ih.as_of_date>=civv.as_of_date AND civv.invoice_type=''r''
			OUTER APPLY(SELECT SUM(invoice_amount) invoice_amount FROM invoice_detail WHERE invoice_id=ih.invoice_id AND invoice_line_item_id=civ.invoice_line_item_id) ind
			LEFT JOIN static_data_VALUE ili on ili.VALUE_id = civ.invoice_line_item_id 
			LEFT JOIN adjustment_default_gl_codes adgc on adgc.default_gl_id =  CASE WHEN ISNULL(civv.finalized,''n'')=''y'' THEN ISNULL(cgd.default_gl_id,cctd.default_gl_id)  ELSE COALESCE(cgd.default_gl_id_estimates,cctd.default_gl_id_estimates,cgd.default_gl_id,cctd.default_gl_id) END 
				AND adgc.fas_subsidiary_id=cg.sub_id  
				AND ISNULL(adgc.estimated_actual,''z'')=CASE WHEN adgc.estimated_actual is not null THEN CASE WHEN  civv.finalized=''y'' THEN ''a'' ELSE ''e'' END ELSE ''z'' END
			LEFT JOIN adjustment_default_gl_codes adgc1 on adgc1.default_gl_id = civ.default_gl_id  
				AND adgc1.fas_subsidiary_id=cg.sub_id  
				AND ISNULL(adgc1.estimated_actual,''z'')=CASE WHEN adgc1.estimated_actual is not null THEN CASE WHEN  civv.finalized=''y'' THEN ''a'' ELSE ''e'' END ELSE ''z'' END
			LEFT JOIN invoice_lineitem_default_glcode ildg on ildg.invoice_line_item_id=civ.invoice_line_item_id   
				AND ildg.sub_id=cg.sub_id  
				AND ISNULL(ildg.estimated_actual,''z'')=CASE WHEN ildg.estimated_actual is not null THEN CASE WHEN  civv.finalized=''y'' THEN ''a'' ELSE ''e'' END ELSE ''z'' END
			LEFT JOIN adjustment_default_gl_codes adgc2 on adgc2.default_gl_id = ildg.default_gl_id  
				AND adgc2.fas_subsidiary_id=cg.sub_id  
				AND ISNULL(adgc2.estimated_actual,''z'')=CASE WHEN adgc2.estimated_actual is not null THEN CASE WHEN  civv.finalized=''y'' THEN ''a'' ELSE ''e'' END ELSE ''z'' END
				AND ISNULL(ildg.estimated_actual,''z'')=ISNULL(adgc2.estimated_actual,''z'')
			LEFT JOIN adjustment_default_gl_codes_detail adgcd on adgcd.default_gl_id=COALESCE(adgc.default_gl_id,adgc1.default_gl_id,adgc2.default_gl_id)
				AND dbo.FNAGetContractMonth(civv.as_of_date) between adgcd.term_start AND adgcd.term_END
			--LEFT JOIN formula_nested fe on fe.formula_group_id=ISNULL(cgd.formula_id,cctd.formula_id) AND 1=2
			LEFT JOIN #calc_formula_value cfv on 
				--((cfv.formula_id=ISNULL(cgd.formula_id,cctd.formula_id) AND cfv.formula_id IS NOT NULL) OR (cfv.formula_id IS NULL))
				--AND 
				cfv.invoice_line_item_id = civ.invoice_line_item_id
				AND cfv.calc_id = civv.calc_id
			LEFT JOIN static_data_VALUE sdv on sdv.VALUE_id = ISNULL(cgd.group_by,cctd.group_by)
			LEFT JOIN source_deal_detail sdd on sdd.source_deal_detail_id=cfv.deal_id	
			LEFT JOIN source_deal_header sdh on sdh.source_deal_header_id=ISNULL(sdd.source_deal_header_id,cfv.source_deal_header_id)	
			OUTER APPLY(select MAX(curve_id) curve_id,MAX(location_id)location_id,MAX(term_start) term_start,MAX(leg) leg,MAX(term_end) term_end,MAX(buy_sell_flag) buy_sell_flag,MAX(fixed_price) fixed_price,MAX(fixed_price_currency_id) fixed_price_currency_id,MAX(deal_volume_uom_id) deal_volume_uom_id FROM source_deal_detail WHERE source_deal_header_id=sdh.source_deal_header_id
				AND ((YEAR(term_start)=YEAR(cfv.prod_date) AND MONTH(term_start)=MONTH(cfv.prod_date) AND cpt.int_ext_flag <> ''b'') OR (cpt.int_ext_flag = ''b''))
			) sdd1
			LEFT JOIN source_deal_type sdt ON sdt.source_deal_type_id=sdh.source_deal_type_id
			LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id=ISNULL(sdd.curve_id,sdd1.curve_id)
			LEFT JOIN source_uom su on su.source_uom_id = COALESCE(spcd.display_uom_id,spcd.uom_id,sdd.deal_volume_uom_id,sdd1.deal_volume_uom_id,cfv.uom_id,civv.uom,cg.volume_uom)
			LEFT JOIN source_uom su1 on su1.source_uom_id = civ.uom_id
			LEFT JOIN source_currency sc ON sc.source_currency_id = COALESCE(sdd.fixed_price_currency_id,sdd1.fixed_price_currency_id,cg.currency)
			LEFT JOIN source_currency sc1 ON sc1.source_currency_id = cgd.currency	
			LEFT JOIN source_minor_location sml ON sml.source_minor_Location_id = ISNULL(sdd.location_id,sdd1.location_id)
			LEFT JOIN source_commodity com ON com.source_commodity_id=sdh.commodity_id 
			LEFT JOIN static_data_value sdv_country ON sdv_country.value_id = sml.country 
			LEFT JOIN source_counterparty cpt1 ON cpt1.source_counterparty_id = sdh.counterparty_id 
			LEFT JOIN #calc_formula_taxes cf_tax on cf_tax.source_deal_header_id = sdh.source_deal_header_id
			LEFT JOIN source_deal_settlement sds ON sds.source_deal_header_id=sdh.source_deal_header_id AND sds.leg=ISNULL(sdd.leg,sdd1.leg) AND sds.term_start=ISNULL(sdd.term_start,sdd1.term_start) AND sds.term_end=ISNULL(sdd.term_end,sdd1.term_end) AND sds.set_type = ''s'''
		+CASE WHEN @template_id IS NOT NULL THEN  ' JOIN settlement_netting_group_detail sngd on sngd.contract_detail_id=cgd.[id] 
													 AND sngd.netting_group_id='+CAST(@template_id AS VARCHAR) ELSE '' END			
		SET @sql_stmt_where='
		WHERE 1=1 AND ISNULL(cgd.is_true_up,''n'')=''n'''
			+case when @invoice_type IS NOT NULL then ' AND civv.invoice_type='''+@invoice_type+'''' else '' end+
			+CASE WHEN @netting_group_id IS NOT NULL THEN ' AND ISNULL(civv.netting_group_id,-1)='+CAST(@netting_group_id AS VARCHAR) ELSE '' END+'
			AND ISNULL(hideInInvoice,''s'') <> ''d''				
			AND civv.prod_date=('''+@prod_month+''')
			AND (civv.as_of_date) = (''' + @deal_date_from  +''') ' 
			+CASE WHEN @contract_id IS NOT NULL THEN ' AND civv.contract_id IN (SELECT item FROM dbo.SplitCommaSeperatedValues(''' + @contract_id + '''))' ELSE '' END
			+CASE WHEN @calc_id IS NOT NULL THEN ' AND civv.calc_id='+CAST(@calc_id AS VARCHAR) ELSE '' END
			IF @counterparty_id  is not null 
				IF exists(select * from rec_generator where ppa_counterparty_id IN (SELECT item FROM dbo.SplitCommaSeperatedValues(@counterparty_id)) AND ppa_contract_id is not null)
					SET @sql_stmt_where=@sql_stmt_where + ' AND civv.counterparty_id IN (SELECT item FROM dbo.SplitCommaSeperatedValues(''' + @counterparty_id + '''))  '
				else
					SET @sql_stmt_where=@sql_stmt_where + ' AND civv.counterparty_id IN (SELECT item FROM dbo.SplitCommaSeperatedValues(''' + @counterparty_id + '''))  '
		   +CASE WHEN @settlement_date IS NOT NULL THEN ' AND civv.settlement_date='''+@settlement_date+'''' ELSE '' END 
		 SET @sql_stmt_group='
			GROUP BY 
			ili.description,--dbo.FNAGetContractMonth(civv.prod_date),
			cgd.alias,ili.description, 
			sdv1.code ,	
			COALESCE(adgcd.debit_gl_number,adgc.debit_gl_number,adgc1.debit_gl_number,adgc2.debit_gl_number),   
			COALESCE(adgcd.credit_gl_number,adgc.credit_gl_number,adgc1.credit_gl_number,adgc2.credit_gl_number), cf_tax.tax_summed, sdh.header_buy_sell_flag,
			sdv.description,sdh.source_deal_header_id,sdh.deal_id,cpt.int_ext_flag,CASE WHEN cpt.int_ext_flag = ''b'' THEN (dbo.FNAGetContractMonth(civv.prod_date)) ELSE (COALESCE(sdd1.term_start,sdd.term_start,dbo.FNAGetContractMonth(civv.prod_date))) END'
			+ CASE WHEN @statement_type = 21502 THEN ',civv.calc_id' ELSE '' END


	--PRINT @sql_stmt
	--PRINT @sql_stmt_where
	--PRINT @sql_stmt_group

	EXEC(@sql_stmt+@sql_stmt_where+@sql_stmt_group)

-- ########### Insert Manual adjustments from settlement
	SET  @sql_stmt = '
			INSERT INTO #temp_c
			select 
				99999,
				ili.code + CASE WHEN civ.remarks IS NOT NULL THEN ''('' + civ.remarks + '')'' ELSE '''' END AS [line Item],
				--civ.remarks AS  [Remarks],		
				dbo.FNAGetContractMonth(civ.prod_date) [Remarks],
				SUM(civ.Volume) AS Volume,
				MAX(su1.uom_name) AS UOM,
				ABS(SUM((civ.VALUE/CASE WHEN civ.Volume=0 THEN 1 ELSE civ.Volume END))) AS  Price,
				SUM(civ.VALUE) AS Value,
				COALESCE(adgcd.debit_gl_number,adgc.debit_gl_number,adgc1.debit_gl_number,adgc2.debit_gl_number) debit_gl_number,   
				COALESCE(adgcd.credit_gl_number,adgc.credit_gl_number,adgc1.credit_gl_number,adgc2.credit_gl_number) credit_gl_number,
				''n'',
				'''',
				ili.code,
				NULL,NULL,NULL,NULL,NULL,NULL,
				MAX(ISNULL(sc1.currency_name, sc2.currency_name)) Currency,
				MAX(civ.invoice_line_item_id) invoice_line_item_id,NULL,''Adjustments'',
				MAX(civv.prod_date_to) prod_date_to,
				'+ CASE WHEN @statement_type = 21502 THEN 'civv.calc_id' ELSE 'NULL' END+' calc_id,
				MAX(sc.counterparty_name) [Counterparty],
				NULL entire_term_start,
				NULL entire_term_end,NULL description1,NULL contract_value, NULL market_value, NULL buy_sell,
				MAX(civ.prod_date) summary_prod_date,
				NULL [tax_summed],
				CASE WHEN  SUM(civ.VALUE) >0 THEN ''b'' ELSE ''s'' END header_buy_sell_flag
				, sdv1.code [alias] 
				,NULL,NULL
			FROM '
				+@table_calc_invoice_volume_variance+ ' civv 
				    LEFT JOIN source_counterparty sc ON civv.counterparty_id= sc.source_counterparty_id 
					LEFT JOIN source_counterparty sc_parent on sc_parent.source_counterparty_id=sc.netting_parent_counterparty_id
					LEFT JOIN source_counterparty sc_parent1 on sc_parent1.netting_parent_counterparty_id=sc.netting_parent_counterparty_id
					LEFT JOIN contract_group cg on cg.contract_id=civv.contract_id'	
		SET @sql_stmt = @sql_stmt +
				' LEFT JOIN '+@table_calc_invoice_volume+' civ on civ.calc_id=civv.calc_id '
				+ CASE WHEN (@rfp_report='y') THEN ' AND (civv.as_of_date) = (''' + @deal_date_from  +''') ' 	ELSE 
					' AND dbo.FNAGetContractMonth(civ.inv_prod_date) = dbo.FNAGetContractMonth(''' + @prod_month  +''') ' END +
				' LEFT JOIN contract_group_detail cgd on cgd.contract_id = cg.contract_id 
					AND cgd.prod_type=
 						CASE WHEN ISNULL(cg.term_start,'''')=''''	 THEN ''p''
 						WHEN dbo.FNAGetContractMonth(cg.term_start)<=dbo.FNAGetContractMonth(civv.prod_date) THEN ''p''
 						ELSE ''t'' END AND cgd.invoice_line_item_id=civ.invoice_line_item_id 
 				LEFT JOIN static_data_value sdv1 ON sdv1.value_id = CAST(cgd.alias as varchar(10)) 
				LEFT JOIN contract_charge_type cct on cct.contract_charge_type_id=cg.contract_charge_type_id
				LEFT JOIN contract_charge_type_detail cctd on cctd.contract_charge_type_id=cct.contract_charge_type_id
					AND cctd.prod_type=
						 CASE WHEN ISNULL(cg.term_start,'''')='''' THEN ''p'' 
						 WHEN dbo.fnagetcontractmonth(cg.term_start)<=dbo.fnagetcontractmonth(civv.prod_date) THEN ''p''
						 ELSE ''t'' END	AND cctd.invoice_line_item_id=civ.invoice_line_item_id '+
				CASE WHEN @payment_ins_header_id is not null THEN 
				' INNER JOIN payment_instruction_detail pid on pid.calc_detail_id=civ.calc_detail_id
				  INNER JOIN payment_instruction_header pih on pid.payment_ins_header_id=pih.payment_ins_header_id 
				  AND pih.payment_ins_header_id='+cast(@payment_ins_header_id AS VARCHAR) ELSE '' END +	
				' LEFT JOIN static_data_VALUE ili on ili.VALUE_id = civ.invoice_line_item_id 
				LEFT JOIN adjustment_default_gl_codes adgc on adgc.default_gl_id = CASE WHEN ISNULL(civ.finalized,''n'')=''y'' THEN ISNULL(cgd.default_gl_id,cctd.default_gl_id)  ELSE COALESCE(cgd.default_gl_id_estimates,cctd.default_gl_id_estimates,cgd.default_gl_id,cctd.default_gl_id) END 
					AND adgc.fas_subsidiary_id=cg.sub_id
					AND ISNULL(adgc.estimated_actual,''z'')=CASE WHEN adgc.estimated_actual is not null THEN CASE WHEN  civ.finalized=''y'' THEN ''a'' ELSE ''e'' END  ELSE ''z'' END
				LEFT JOIN adjustment_default_gl_codes adgc1 on adgc1.default_gl_id = civ.default_gl_id  
					AND adgc1.fas_subsidiary_id=cg.sub_id  
					AND ISNULL(adgc1.estimated_actual,''z'')=CASE WHEN adgc1.estimated_actual is not null THEN CASE WHEN  civ.finalized=''y'' THEN ''a'' ELSE ''e'' END ELSE ''z'' END
				LEFT JOIN invoice_lineitem_default_glcode ildg on ildg.invoice_line_item_id=civ.invoice_line_item_id   
					AND ildg.sub_id=cg.sub_id  
					AND ISNULL(ildg.estimated_actual,''z'')=CASE WHEN ildg.estimated_actual is not null THEN CASE WHEN  civ.finalized=''y'' THEN ''a'' ELSE ''e'' END ELSE ''z'' END
				LEFT JOIN adjustment_default_gl_codes adgc2 on adgc2.default_gl_id = ildg.default_gl_id  
					AND adgc2.fas_subsidiary_id=cg.sub_id  
					AND ISNULL(adgc2.estimated_actual,''z'')=CASE WHEN adgc2.estimated_actual is not null THEN CASE WHEN  civ.finalized=''y'' THEN ''a'' ELSE ''e'' END ELSE ''z'' END
					AND ISNULL(ildg.estimated_actual,''z'')=ISNULL(adgc2.estimated_actual,''z'')
				LEFT JOIN adjustment_default_gl_codes_detail adgcd on adgcd.default_gl_id=COALESCE(adgc.default_gl_id,adgc1.default_gl_id,adgc2.default_gl_id)
					AND dbo.FNAGetContractMonth(civv.as_of_date) between adgcd.term_start AND adgcd.term_END
				LEFT JOIN source_uom su1 on su1.source_uom_id = ISNULL(civ.uom_id,cg.volume_uom)
				LEFT JOIN source_currency sc1 ON sc1.source_currency_id = cg.currency
				LEFT JOIN source_currency sc2 ON sc2.source_currency_id = cgd.currency
			WHERE 1=1  
				AND ISNULL(civ.manual_input,''n'')=''y'' '	
				+ CASE WHEN (@rfp_report='y') THEN  ' AND civ.finalized=''y'' ' ELSE '' END +
				+ CASE WHEN (@rfp_report='y') THEN '' ELSE ' AND (civv.as_of_date) = (''' + @deal_date_from  +''')' END+'
				AND civ.calc_detail_id not in(select ISNULL(finalized_id,'''') from calc_invoice_volume civ INNER JOIN calc_invoice_volume_variance civv 
							on civ.calc_id=civv.calc_id)'
				IF @counterparty_id  is not null 
					IF exists(select * from rec_generator where ppa_counterparty_id IN (SELECT item FROM dbo.SplitCommaSeperatedValues(@counterparty_id)) AND ppa_contract_id is not null)
						SET @sql_stmt=@sql_stmt + ' AND sc.source_counterparty_id IN (SELECT item FROM dbo.SplitCommaSeperatedValues(''' + @counterparty_id + ''')) '
					else
						SET @sql_stmt=@sql_stmt + ' AND civv.counterparty_id IN (SELECT item FROM dbo.SplitCommaSeperatedValues(''' + @counterparty_id + ''')) '
				SET @sql_stmt=@sql_stmt
				+case when @invoice_type IS not null then ' AND civv.invoice_type='''+@invoice_type+'''' else '' end+ 
				+CASE WHEN @contract_id IS NOT NULL THEN ' AND civv.contract_id IN (SELECT item FROM dbo.SplitCommaSeperatedValues(''' + @contract_id + '''))' ELSE '' END+
				--+CASE WHEN @calc_id IS NOT NULL THEN ' AND civv.calc_id='+CAST(@calc_id AS VARCHAR) ELSE '' END+'
			' GROUP BY 
				 dbo.FNAGetContractMonth(civ.prod_date),ili.code,ili.description,dbo.FNADateFormat(civ.inv_prod_date),dbo.FNAGetContractMonth(civ.prod_date),
				 COALESCE(adgcd.debit_gl_number,adgc.debit_gl_number,adgc1.debit_gl_number,adgc2.debit_gl_number),   
				 COALESCE(adgcd.credit_gl_number,adgc.credit_gl_number,adgc1.credit_gl_number,adgc2.credit_gl_number),civ.remarks, sdv1.code'
				 + CASE WHEN @statement_type = 21502 THEN ',civv.calc_id' ELSE '' END

	--PRINT(@sql_stmt)
	EXEC(@sql_stmt)
	
	IF @summary_option='i'
		SELECT 
			[Line Item],
			dbo.FNADateFormat(dbo.FNAGetContractMonth(summary_prod_date))[Production Month],
			SUM((NULLIF(cast(volume AS FLOAT),0))) AS Volume,
			UOM,
			ABS(SUM(round(round(VALUE,2,0),2,0))/NULLIF(SUM(round(volume,0)),0)) Price,
			SUM(round(round(VALUE,2,0),2,0)) [Value]
		FROM
			#temp_c 
		WHERE
			other_var='n'
			AND [Line Item] IS NOT NULL
			AND ([Price] IS NOT NULL AND [Volume] <> 0 AND [VALUE] <> 0)
		GROUP BY [Line Item],dbo.FNAGetContractMonth(summary_prod_date),UOM				
		ORDER BY 1

	ELSE IF @summary_option='g' --g for generate invoice
		SELECT [Order]
			,[Line Item]
			,[ProductionMonth]
			,ISNULL([volume], 0) [volume]
			,[UOM]
			,ISNULL([price], 0) [price]
			,ISNULL([VALUE], 0) [VALUE]
			,[debit_gl_number]
			,[credit_gl_number]
			,[other_var]
			,[group_by]
			,[deal_id]
			,[source_deal_header_id]
			
			,deal_date
			,trade_type
			,Indexname
			
			,fixed_price
			,settled_price
			,currency
			,invoice_line_item_id
			,[location]
			,country
			,prod_date_to
			,calc_id
			,counterparty
			,entire_term_start
			,entire_term_end
			,description1
			,contract_value
			,market_value
			,buy_sell
			,summary_prod_date
			,tax_summed
			,header_buy_sell_flag
			,alias
            ,[deal_info]
            ,Indexcurvename
		FROM #temp_c WHERE [Line Item] IS NOT NULL
		ORDER BY [Order] 
	ELSE
		SELECT * FROM #temp_c WHERE [Line Item] IS NOT NULL AND ([Price] IS NOT NULL AND [Volume] <> 0 AND [VALUE] <> 0) 
		ORDER BY [Order]




