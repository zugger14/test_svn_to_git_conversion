
/****** Object:  StoredProcedure [dbo].[spa_create_rec_invoice_report]    Script Date: 01/11/2010 19:40:32 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_create_rec_invoice_report]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_create_rec_invoice_report]
/****** Object:  StoredProcedure [dbo].[spa_create_rec_invoice_report]    Script Date: 01/11/2010 19:40:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spa_create_rec_invoice_report]
		@sub_entity_id VARCHAR(100)=null, 
		@strategy_entity_id VARCHAR(100) = NULL, 
		@book_entity_id VARCHAR(100) = NULL, 
		@book_deal_type_map_id VARCHAR(5000) = null,
		@source_deal_header_id VARCHAR(5000)  = null,
		@deal_date_from VARCHAR(20),
		@deal_date_to VARCHAR(20),
		@counterparty_id int,
		@summary_option VARCHAR(1), --r means retain/save, 'd' for generate Invoice
		@int_ext_flag VARCHAR(1),
		@save_invoice_id int = null,
		@detail_option VARCHAR(1) = 's', --pass 'd' for detail, 's' for summary AND 't' for total,'f'-rfp report
		@prod_month VARCHAR(20)=null,
		@payment_ins_header_id int=null,
		@rfp_report char(1)='n',
		@contract_id int=null,
		@show_volume char(1) = NULL,
		@estimate_calculation CHAR(1)='n',
		@template_id VARCHAR(100)=NULL,
		@invoice_status INT= NULL,
		@invoice_line_item_id varchar(5000) = NULL,
		@invoice_type CHAR(1) = NULL,
		@netting_group_id INT = NULL,
		@statement_type INT = NULL,
		@settlement_date VARCHAR(20) = NULL,
		@calc_id INT = NULL
AS
SET NOCOUNT ON 

	DECLARE @gl_account_group_code int
	DECLARE @error_desc VARCHAR(250)
	DECLARE @next_invoice_number VARCHAR(50)
	DECLARE @save_invoice_id_next int


	SET @gl_account_group_code=10005
	IF @calc_id = -1
		SET @calc_id = NULL

--	IF @save_invoice_id IS NOT NULL
--		SELECT @deal_date_from=as_of_date,@prod_month=term_month FROM save_invoice WHERE save_invoice_id=@save_invoice_id
--
--	SET @save_invoice_id=NULL

--
--IF @show_volume is not null AND @show_volume = 'y'
--BEGIN
--
--SELECT onpeak_volume, offpeak_volume, metervolume FROM calc_invoice_volume_variance 
--WHERE
--counterparty_id = @counterparty_id 
--AND contract_id = @contract_id
--AND dbo.FNAGetcontractMonth(prod_date) = dbo.FNAGetContractMonth(@prod_month)
--AND dbo.FNAGetcontractMonth(as_of_date) =  dbo.FNAGetContractMonth(@deal_date_from)
--
--return
--END


	IF @summary_option = 'r' 
	BEGIN
		IF (SELECT count(*) FROM save_invoice WHERE	counterparty_id = @counterparty_id AND as_of_date = dbo.FNAGetContractMonth(@deal_date_from)
				AND term_month=dbo.FNAGetContractMonth(@prod_month)
				AND isnull(status, 20700) <> 20704) = 1
		BEGIN
			SET @error_desc = 'Invoice for this Counterparty for Period ' + dbo.FNADateFormat(@deal_date_from)
					+ ' is already created. Please void it first IF you want to save it again.'
			EXEC spa_ErrorHandler 1, 'Save Invoice', 
					'spa_create_rec_invoice_report', 'Error', @error_desc, ''

			RETURN
		END
	END

-- Check to see IF contract is defined for the counterparty

--	SELECT @contract_id=ppa_contract_id FROM rec_generator WHERE ppa_counterparty_id=@counterparty_id 
--	IF @contract_id is null
--	SELECT @contract_id=contract_id FROM source_deal_header sdh inner join source_deal_detail sdd
--	on sdh.source_deal_header_id=sdd.source_deal_header_id
--	WHERE sdd.source_deal_detail_id=@source_deal_header_id

--SELECT @contract_id

	-- used for template charge level
	IF @summary_option = 'c' 
	BEGIN
		DECLARE @_sql_statement VARCHAR(MAX)
		SET @_sql_statement = '
			select 
				COALESCE(sdv02.code, sdv01.code, sdv.code) [Line Item]
				,dbo.FNAGetContractMonth(civ.prod_date) [Production Month]
				,COALESCE(sdv02.code, sdv01.code, sdv.code) [Line_Item]
				,dbo.FNAGetContractMonth(civ.prod_date) [Production_Month]
				--,dbo.FNADateFormat(civv.prod_date_to)
				,dbo.FNAGetFirstLastDayOfMonth(civ.prod_date,''l'')  prod_date_to
				,civ.Volume volume
				,su.uom_name uom
				,civ.value Total
				,scu.currency_id [currency]
				,CASE WHEN civ.volume = 0 OR civ.value = 0 THEN 0 ELSE (civ.value / civ.volume) END [Rate]
			from calc_invoice_volume civ
			inner join calc_invoice_volume_variance civv ON civv.calc_id = civ.calc_id AND (civ.volume <> 0 OR civ.value <> 0)
			inner join static_data_value sdv on sdv.value_id = civ.invoice_line_item_id
			left join contract_group cg on cg.contract_id = civv.contract_id
			left join  source_uom su on su.source_uom_id = cg.volume_uom
			left join  source_currency scu on scu.source_currency_id = cg.currency
			left join contract_group_detail cgd on cgd.contract_id = cg.contract_id AND cgd.invoice_line_item_id = civ.invoice_line_item_id
			left join static_data_value sdv01 on sdv01.value_id = cgd.alias
			left join contract_charge_type cct1 on cct1.contract_charge_type_id = cg.contract_charge_type_id 
			left join contract_charge_type_detail cctd1 on cctd1.contract_charge_type_id = cct1.contract_charge_type_id AND cctd1.invoice_line_item_id = civ.invoice_line_item_id
			left join static_data_value sdv02 on sdv02.value_id = cctd1.alias
			
			where 1 =1
			' +case when @invoice_type IS NOT NULL then ' AND civv.invoice_type='''+@invoice_type+'''' else '' end
			+' AND ISNULL(cgd.hideInInvoice,''s'') <> ''d'' '	
			+CASE WHEN @netting_group_id IS NOT NULL THEN ' AND ISNULL(civv.netting_group_id,-1)='+CAST(@netting_group_id AS VARCHAR) ELSE '' END
			+ ' AND civv.prod_date=('''+@prod_month+''')
			AND (civv.as_of_date) = (''' + @deal_date_from  +''') ' 
			+CASE WHEN @contract_id IS NOT NULL THEN ' AND civv.contract_id='+CAST(@contract_id AS VARCHAR) ELSE '' END
			+CASE WHEN @calc_id IS NOT NULL THEN ' AND civv.calc_id='+CAST(@calc_id AS VARCHAR) ELSE '' END
			+CASE WHEN @counterparty_id IS NOT NULL THEN ' AND civv.counterparty_id IN (' + cast(@counterparty_id AS VARCHAR) + ')' ELSE '' END
		    +CASE WHEN @settlement_date IS NOT NULL THEN ' AND civv.settlement_date='''+@settlement_date+'''' ELSE '' END 
			
		    + ' order by sdv.code'

		--PRINT(@_sql_statement)

		EXEC(@_sql_statement)
	END
	ELSE
	BEGIN



	CREATE TABLE #temp1 (
		[Order] int,
		[invoice_line_item] VARCHAR(100) COLLATE DATABASE_DEFAULT ,
		[ProductionMonth] VARCHAR(500) COLLATE DATABASE_DEFAULT ,
		[Volume] [Float] ,
		[UOM] [VARCHAR] (50) COLLATE DATABASE_DEFAULT ,
		[Price] [FLoat] ,
		[Value] [Float],
		adj_debit_number int,
		adj_credit_number int,
		other_var char(1) COLLATE DATABASE_DEFAULT ,
		group_by VARCHAR(100) COLLATE DATABASE_DEFAULT ,
		deal_id NVARCHAR(100) COLLATE DATABASE_DEFAULT ,
		source_deal_header_id INT,
		deal_date DATETIME,
		trade_type VARCHAR(100) COLLATE DATABASE_DEFAULT ,
		Indexname VARCHAR(100) COLLATE DATABASE_DEFAULT ,
		fixed_price FLOAT,
		settled_price FLOAT,
		currency VARCHAR(10) COLLATE DATABASE_DEFAULT ,
		invoice_line_item_id INT,
		location VARCHAR(500) COLLATE DATABASE_DEFAULT ,
		country VARCHAR(50) COLLATE DATABASE_DEFAULT ,
		prod_date_to VARCHAR(20) COLLATE DATABASE_DEFAULT ,
		calc_id INT,
		counterparty NVARCHAR(100) COLLATE DATABASE_DEFAULT ,
		entire_term_start DATETIME,
		entire_term_end DATETIME,
		description1 VARCHAR(100) COLLATE DATABASE_DEFAULT ,
		contract_value FLOAT,
		market_value FLOAT,
		buy_sell CHAR(5) COLLATE DATABASE_DEFAULT ,
		summary_prod_date DATETIME,
		tax_summed FLOAT,
		header_buy_sell_flag char(1) COLLATE DATABASE_DEFAULT 
		, alias VARCHAR(100) COLLATE DATABASE_DEFAULT,  -- for alias combobox define on contract detail window
		deal_info  NVARCHAR(100) COLLATE DATABASE_DEFAULT ,
		Indexcurvename VARCHAR(100) COLLATE DATABASE_DEFAULT 	
	) ON [PRIMARY]

	



	--IF @save_invoice_id IS NULL OR @summary_option = 'r' 
	--BEGIN 
		INSERT #temp1
		EXEC spa_create_rec_settlement_report
				@sub_entity_id, 
				@strategy_entity_id, 
				@book_entity_id, 
				@book_deal_type_map_id,
				@source_deal_header_id,
				@deal_date_from,
				@deal_date_to,
				@counterparty_id,
				'g', --g for generate invoice
				@int_ext_flag,
				NULL,
				NULL,
				@prod_month,
				@payment_ins_header_id,
				@rfp_report,
				@contract_id,
				@estimate_calculation,
				@template_id,
				@invoice_type,
				@netting_group_id,
				@statement_type,
				@settlement_date,
				@calc_id
		
	--END
			IF @detail_option = 's'
			BEGIN
			IF @statement_type = 21502 -- for netting
				SELECT
					'Invoice' AS [type],
					sc.counterparty_name AS counterparty,
					fs_counterparty.counterparty_name AS parent_counterparty,
					civv.invoice_number AS invoice_number,
					tmp.Total AS total,
					tmp.volume AS Volume 					
				FROM 
					calc_invoice_Volume_variance civv
					LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = civv.counterparty_id
					LEFT JOIN contract_group cg ON cg.contract_id = civv.contract_id
					LEFT JOIN fas_subsidiaries fs ON  cg.sub_id = fs.fas_subsidiary_id
					LEFT JOIN source_counterparty fs_counterparty ON  fs.counterparty_id = fs_counterparty.source_counterparty_id
					OUTER APPLY
						(SELECT SUM(volume) volume,SUM(Value) Total,CASE WHEN Value<0 THEN 'r' ELSE 'i' END AS inv_type 
							FROM #temp1 WHERE CASE WHEN Value<0 THEN 'r' ELSE 'i' END = civv.invoice_type
							GROUP BY CASE WHEN Value<0 THEN 'r' ELSE 'i' END
						) tmp
						
				WHERE
					civv.counterparty_id = @counterparty_id
					AND civv.contract_id = @contract_id
					AND civv.as_of_date = @deal_date_from
					AND civv.prod_date = @prod_month	
					AND civv.settlement_date = @settlement_date	
					AND civv.invoice_type = tmp.inv_type				
					
			ELSE
				SELECT 	 
					invoice_line_item [Line Item], 
	      			#temp1.ProductionMonth AS [Production Month],
	      			CASE WHEN Volume=0 THEN '' ELSE volume  END AS Volume, 
					UOM,
					CASE WHEN ISNULL(NULLIF(Volume,0),'')='' THEN cast(price AS VARCHAR) 
						 WHEN price<>0 THEN price
						 WHEN round(round(Value,2,0),2,0)/round(volume,0) = -1 THEN '' 
						 ELSE round(round(Value,2,0),2,0)/round(volume,0) 
					END AS Rate, 
					spc.curve_value as Indexcurvevalue,
					round(round(Value,2,0),2,0) AS Total,
					ISNULL(gl.gl_account_number,gl1.gl_account_number) AS gl_account_number,
					CASE WHEN [Order] = -1 THEN 0 
						 WHEN [order]=0 THEN -1 ELSE [order] END 
					AS [Order],
					group_by AS [GroupBy] ,
					deal_id [DealID],
					deal_info [Deal_info],
					deal_date,
					trade_type,
					Indexname,
					Indexcurvename,
					fixed_price,
					settled_price,
					currency,
					location,
					country,
					counterparty,
					dbo.FNADateFormat(#temp1.entire_term_start) entire_term_start,
					dbo.FNADateFormat(#temp1.entire_term_end) entire_term_end,
					description1,
					contract_value ,
					market_value,
					CASE WHEN buy_sell ='b' THEN 'Buy' ELSE 'Sell' END buy_sell,
					#temp1.prod_date_to [prod_date_to],
					tax_summed,
					header_buy_sell_flag
					, alias
				FROM #temp1 
					LEFT JOIN gl_system_mapping gl ON gl.gl_number_id=#temp1.adj_debit_number AND gl.gl_code1_value_id=@gl_account_group_code
					LEFT JOIN gl_system_mapping gl1 on gl1.gl_number_id=#temp1.adj_credit_number AND gl1.gl_code1_value_id=@gl_account_group_code
					LEFT JOIN source_price_curve_def spcd on #temp1.Indexcurvename =  spcd.curve_name
					LEFT JOIN source_price_curve spc on spcd.source_curve_def_id = spc.source_curve_def_id and spc.as_of_date = @deal_date_from and spc.maturity_date = #temp1.ProductionMonth
				ORDER BY CASE WHEN [Order] = -1 THEN 9999 ELSE [Order] END
			END
			ELSE IF @detail_option = 'f'	
			BEGIN
				SELECT 	
					ISNULL(gl.gl_account_name,gl1.gl_account_name) [Line Item], 
					dbo.FNAContractMonthFormat(ProductionMonth)	ProductionMonth,
		      		MAX(CASE WHEN Volume=0 THEN '' ELSE volume  END) AS Volume, MAX(UOM),
					MAX(CASE WHEN Price=0 THEN '' ELSE CASE WHEN ISNULL(NULLIF(Volume,0),'')='' THEN cast(price AS VARCHAR) WHEN price<>0 THEN price	
						ELSE round(round(Value,2,0),2,0)/round(volume,0) END END) AS Price, 
					SUM(round(round(Value,2,0),2,0)) AS value,
					ISNULL(gl.gl_account_number,gl1.gl_account_number) AS gl_account_number
					, alias
				FROM #temp1 
					LEFT JOIN gl_system_mapping gl on gl.gl_number_id=#temp1.adj_debit_number AND gl.gl_code1_value_id=@gl_account_group_code
					LEFT JOIN gl_system_mapping gl1 on gl1.gl_number_id=#temp1.adj_credit_number AND gl1.gl_code1_value_id=@gl_account_group_code
				WHERE
					ProductionMonth is not null
				GROUP BY 
					ISNULL(gl.gl_account_name,gl1.gl_account_name),dbo.FNAContractMonthFormat(ProductionMonth),ISNULL(gl.gl_account_number,gl1.gl_account_number)
			END

		END
