IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_SettlementExport_final]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_SettlementExport_final]
GO
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[spa_SettlementExport_final] 
		@flag CHAR = NULL 
	, @counterparty_id  VARCHAR(250)  = NULL	
	, @contract_id  VARCHAR(250) = NULL
	,@as_of_date datetime = NULL
	, @invoice_date DATETIME = NULL
	
	, @type VARCHAR(250) = NULL 
	,@process_id VARCHAR(250) = NULL
	,@calc_id VARCHAR(240) = ''
	, @batch_process_id    VARCHAR(250) = NULL
	, @batch_report_param  VARCHAR(500) = NULL
	
AS
/*

	Declare		@flag CHAR = NULL 
	, @counterparty_id  VARCHAR(250)  = NULL	
	, @contract_id  VARCHAR(250) = NULL
	,@as_of_date datetime = NULL
	, @invoice_date DATETIME = NULL
	
	, @type VARCHAR(250) = NULL 
	,@process_id VARCHAR(250) = NULL
	,@calc_id VARCHAR(240) = ''
	, @batch_process_id    VARCHAR(250) = NULL
	, @batch_report_param  VARCHAR(500) = NULL
	--SELECT @flag='s',@counterparty_id='7980',@contract_id='655',@as_of_date='2016-08-05',@invoice_date='2016-04-04',@calc_id='38203'
	SELECT  @flag='s',@counterparty_id='6781',@contract_id='5361',@as_of_date='2017-01-31',@invoice_date='2017-02-02',@calc_id='12450'
		
--*/


SET NOCOUNT ON;
	DECLARE @contract_type VARCHAR(200)
	DECLARE @str_batch_table VARCHAR (8000)
	DECLARE @acount_id NVARCHAR(MAX) 
	DECLARE @costCenter NVARCHAR(MAX) 
	DECLARE @taxCode NVARCHAR(MAX) 
	DECLARE @allocation NVARCHAR(MAX)   
	DECLARE @text NVARCHAR(MAX) 
	DECLARE @customer_id NVARCHAR(MAX) 
	DECLARE @bank_id NVARCHAR(MAX)
	DECLARE @extension_field NVARCHAR(MAX)
	DECLARE @documnent_header NVARCHAR(MAX)
	DECLARE @process_table VARCHAR(500) 
	SELECT @str_batch_table = CASE WHEN @batch_process_id IS NULL THEN '' ELSE [dbo].[FNABatchProcess]('s',@batch_process_id,@batch_report_param,GETDATE(),NULL,NULL)        END 
	DECLARE @validate VARCHAR(500)
	DECLARE @user VARCHAR(100)  = dbo.FNADBUser()
	DECLARE @query VARCHAR(MAX)
	DECLARE @sql VARCHAR(MAX)
	DECLARE @vat INT 
	DECLARE @external_type_id INT --2203
	DECLARE @external_type_id1 INT--2201n
	DECLARE @external_type_id2 INT --2202
--IF @batch_process_id IS NOT NULL
--BEGIN
--	SELECT @str_batch_table = dbo.FNABatchProcess('s', @batch_process_id, @batch_report_param, NULL, NULL, NULL)
--END
IF OBJECT_ID('tempdb..#sap_export_data') IS NOT NULL
	DROP TABLE #sap_export_data

IF OBJECT_ID('tempdb..#temp_sap_detail') IS NOT NULL
	DROP TABLE #temp_sap_detail

IF OBJECT_ID('tempdb..#detail') IS NOT NULL
	DROP TABLE #detail

IF OBJECT_ID('tempdb..#header') IS NOT NULL
	DROP TABLE #header

IF OBJECT_ID('tempdb..#summary') IS NOT NULL
	DROP TABLE #summary

IF OBJECT_ID('tempdb..#count') IS NOT NULL
	DROP TABLE #count

IF OBJECT_ID('tempdb..#validate') IS NOT NULL
	DROP TABLE #validate

IF OBJECT_ID('tempdb..#summary_with_count') IS NOT NULL
	DROP TABLE #summary_with_count

IF OBJECT_ID('tempdb..#civv1') IS NOT NULL
	DROP TABLE #civv1

IF object_id('tempdb..#refresh_grid') IS NOT NULL
	DROP TABLE #refresh_grid

IF object_id('tempdb..#sap_export_data') IS NOT NULL
	DROP TABLE #sap_export_exception_data

IF object_id('tempdb..#counterparty') IS NOT NULL
	DROP TABLE #counterparty

IF object_id('tempdb..#contract') IS NOT NULL
	DROP TABLE #contract

IF object_id('tempdb..#sap_export_exception_data') IS NOT NULL
	DROP TABLE #sap_export_exception_data
IF object_id('tempdb..#sap_tax_mapping1') IS NOT NULL
	DROP TABLE #sap_tax_mapping1
IF object_id('tempdb..#sap_gl_mapping_invoicing') IS NOT NULL
	DROP TABLE  #sap_gl_mapping_invoicing


IF OBJECT_ID('tempdb..#gsp_group_info') IS NOT NULL 
	DROP TABLE #gsp_group_info

IF object_id('tempdb..#sap_tax_mapping') IS NOT NULL
	DROP TABLE #sap_tax_mapping

IF object_id('tempdb..#calc_id') IS NOT NULL
    DROP TABLE #calc_id	
IF object_id('tempdb..#vat') IS NOT NULL
    DROP TABLE #vat	
IF object_id('tempdb..#vat1') IS NOT NULL
    DROP TABLE #vat1
IF object_id('tempdb..#sap_gl_mapping_invoicing1') IS NOT NULL
    DROP TABLE #sap_gl_mapping_invoicing1
IF object_id('tempdb..#counterparty_primary') IS NOT NULL
    DROP TABLE #counterparty_primary

	SELECT value_id
	INTO #vat
	FROM static_Data_value sdv
	INNER JOIN static_data_type sdt ON sdt.type_id = sdv.type_id
	WHERE sdt.type_name = 'Contract Components'
		AND (
			code LIKE '% VAT%'
			OR code LIKE 'VAT%'
			)

IF object_id('tempdb..#delta') IS NOT NULL
    DROP TABLE #delta
IF object_id('tempdb..#double_booking') IS NOT NULL
    DROP TABLE #double_booking 


	
	SELECT value_id
	INTO #delta
	FROM static_data_value sdv
	INNER JOIN static_data_type sdt ON sdt.type_id = sdv.type_id
	WHERE sdt.type_name = 'Contract Components'
		AND sdv.code LIKE '%Delta%'


SELECT value_id INTO #VAT1 FROM static_data_value  sdv INNER JOIN static_data_type sdt ON sdt.type_id = sdv.type_id 
WHERE code IN  ('Consumption at Meter level','Consumption at Grid level','Consumption Including Gridlosses')  AND type_name ='Contract Components'

Declare @primary_counterparty VARCHAR(25)
SELECT @primary_counterparty =counterparty_id FROM  fas_subsidiaries where fas_subsidiary_id = -1


	SELECT @vat = value_id
	FROM static_Data_value sdv
	INNER JOIN static_data_type sdt ON sdt.type_id = sdv.type_id
	WHERE sdt.type_name = 'Contract Components'
		AND sdv.code = 'VAT'

	SELECT @external_type_id = value_id
	FROM static_data_value sdv
	INNER JOIN static_Data_type sdt ON sdt.type_id = sdv.type_id
	WHERE sdt.type_name = 'Counterparty External ID'
		AND sdv.code = 'SAP Payable ID (Creditor)'

	SELECT @external_type_id1 = value_id
	FROM static_data_value sdv
	INNER JOIN static_Data_type sdt ON sdt.type_id = sdv.type_id
	WHERE sdt.type_name = 'Counterparty External ID'
		AND sdv.code = 'Entrepot number'
	
	SELECT @external_type_id2 = value_id
	FROM static_data_value sdv
	INNER JOIN static_Data_type sdt ON sdt.type_id = sdv.type_id
	WHERE sdt.type_name = 'Counterparty External ID'
	AND sdv.code = 'SAP Receivable ID (Debtor)'

CREATE TABLE #sap_export_exception_data (
	row_id NVARCHAR(MAX) COLLATE DATABASE_DEFAULT NULL
	,column_name NVARCHAR(MAX) COLLATE DATABASE_DEFAULT NULL
	,counter_party NVARCHAR(MAX) COLLATE DATABASE_DEFAULT NULL
	,contract_name NVARCHAR(MAX) COLLATE DATABASE_DEFAULT NULL
	,recomendation NVARCHAR(MAX) COLLATE DATABASE_DEFAULT NULL
	)


CREATE TABLE #calc_id(
	 calc_id INT
	,counterparty_id INT
	,contract_id INT
	,as_of_date DATETIME 
	,invoice_date DATETIME
	
)

CREATE TABLE #counterparty (item INT)

CREATE TABLE #contract (item INT)

CREATE TABLE #temp_sap_detail (
	[column_1] VARCHAR(250) COLLATE DATABASE_DEFAULT
	,[column_2] VARCHAR(250) COLLATE DATABASE_DEFAULT
	,[column_3] VARCHAR(250) COLLATE DATABASE_DEFAULT
	,[column_4] VARCHAR(250) COLLATE DATABASE_DEFAULT
	,[column_5] VARCHAR(250) COLLATE DATABASE_DEFAULT
	,[column_6] VARCHAR(250) COLLATE DATABASE_DEFAULT
	,[column_7] VARCHAR(250) COLLATE DATABASE_DEFAULT
	,[column_8] VARCHAR(250) COLLATE DATABASE_DEFAULT
	,[column_9] VARCHAR(250) COLLATE DATABASE_DEFAULT
	,[column_10] VARCHAR(250) COLLATE DATABASE_DEFAULT
	,[column_11] VARCHAR(250) COLLATE DATABASE_DEFAULT
	,[column_12] VARCHAR(250) COLLATE DATABASE_DEFAULT
	,[column_13] VARCHAR(250) COLLATE DATABASE_DEFAULT
	,[column_14] VARCHAR(250) COLLATE DATABASE_DEFAULT
	,[column_15] VARCHAR(250) COLLATE DATABASE_DEFAULT
	,[Order_detail] VARCHAR(250) COLLATE DATABASE_DEFAULT
	,[Buy_sell_d] VARCHAR(250) COLLATE DATABASE_DEFAULT
	,invoice_number VARCHAR(250) COLLATE DATABASE_DEFAULT
	,line_item VARCHAR(250) COLLATE DATABASE_DEFAULT
	,Gl_account_vat VARCHAR(250) COLLATE DATABASE_DEFAULT
	,[Buy_sell_h] VARCHAR(250) COLLATE DATABASE_DEFAULT
	,row_type VARCHAR(250) COLLATE DATABASE_DEFAULT
	,source_counterparty_id INT
	,contract_id INT
	,PartnerID VARCHAR(250) COLLATE DATABASE_DEFAULT
	,[ProfitCenter] VARCHAR(250) COLLATE DATABASE_DEFAULT
	,[grouping] VARCHAR(250) COLLATE DATABASE_DEFAULT
	,entity_gas VARCHAR(250) COLLATE DATABASE_DEFAULT
	,product_group VARCHAR(250) COLLATE DATABASE_DEFAULT
	,calc_id VARCHAR(250) COLLATE DATABASE_DEFAULT
	,self_billing VARCHAR(10) COLLATE DATABASE_DEFAULT
	)

CREATE TABLE #header (
	[column_1] VARCHAR(250) COLLATE DATABASE_DEFAULT
	,[column_2] VARCHAR(250) COLLATE DATABASE_DEFAULT
	,[column_3] VARCHAR(250) COLLATE DATABASE_DEFAULT
	,[column_4] VARCHAR(250) COLLATE DATABASE_DEFAULT
	,[column_5] VARCHAR(250) COLLATE DATABASE_DEFAULT
	,[column_6] VARCHAR(250) COLLATE DATABASE_DEFAULT
	,[column_7] VARCHAR(250) COLLATE DATABASE_DEFAULT
	,[column_8] VARCHAR(250) COLLATE DATABASE_DEFAULT
	,[column_9] VARCHAR(250) COLLATE DATABASE_DEFAULT
	,[column_10] VARCHAR(250) COLLATE DATABASE_DEFAULT
	,[column_11] VARCHAR(250) COLLATE DATABASE_DEFAULT
	,[column_12] VARCHAR(250) COLLATE DATABASE_DEFAULT
	,[column_13] VARCHAR(250) COLLATE DATABASE_DEFAULT
	,[column_14] VARCHAR(250) COLLATE DATABASE_DEFAULT
	,[column_15] VARCHAR(250)COLLATE DATABASE_DEFAULT
	,[ORDER] VARCHAR(10) COLLATE DATABASE_DEFAULT
	,[distinct_value] VARCHAR(250) COLLATE DATABASE_DEFAULT
	,[invoice_number] VARCHAR(250) COLLATE DATABASE_DEFAULT
	,[row_type] VARCHAR(10) COLLATE DATABASE_DEFAULT
	,source_counterparty_id INT
	,contract_ID INT
	,PartnerID VARCHAR(250) COLLATE DATABASE_DEFAULT
	,[ProfitCenter] VARCHAR(250) COLLATE DATABASE_DEFAULT
	,entity_gas VARCHAR(250) COLLATE DATABASE_DEFAULT
	,product_group VARCHAR(250) COLLATE DATABASE_DEFAULT
	,calc_id VARCHAR(250) COLLATE DATABASE_DEFAULT
	)
CREATE TABLE #detail (
	[column_1] VARCHAR(250) COLLATE DATABASE_DEFAULT
	,[column_2] VARCHAR(250) COLLATE DATABASE_DEFAULT
	,[column_3] VARCHAR(250) COLLATE DATABASE_DEFAULT
	,[column_4] VARCHAR(250) COLLATE DATABASE_DEFAULT
	,[column_5] VARCHAR(250) COLLATE DATABASE_DEFAULT
	,[column_6] VARCHAR(250) COLLATE DATABASE_DEFAULT
	,[column_7] VARCHAR(250) COLLATE DATABASE_DEFAULT
	,[column_8] VARCHAR(250) COLLATE DATABASE_DEFAULT
	,[column_9] VARCHAR(250) COLLATE DATABASE_DEFAULT
	,[column_10] VARCHAR(250) COLLATE DATABASE_DEFAULT
	,[column_11] VARCHAR(250) COLLATE DATABASE_DEFAULT
	,[column_12] VARCHAR(250) COLLATE DATABASE_DEFAULT
	,[column_13] VARCHAR(250) COLLATE DATABASE_DEFAULT
	,[column_14] VARCHAR(250) COLLATE DATABASE_DEFAULT
	,[column_15] VARCHAR(250) COLLATE DATABASE_DEFAULT
	,[ORDER] VARCHAR(10) COLLATE DATABASE_DEFAULT
	,[distinct_value] VARCHAR(250) COLLATE DATABASE_DEFAULT
	,[invoice_number] VARCHAR(250) COLLATE DATABASE_DEFAULT
	,[row_type] VARCHAR(10) COLLATE DATABASE_DEFAULT
	,source_counterparty_id INT
	,contract_ID INT
	,PartnerID VARCHAR(250) COLLATE DATABASE_DEFAULT
	,[ProfitCenter] VARCHAR(250) COLLATE DATABASE_DEFAULT
	,grouping VARCHAR(250) COLLATE DATABASE_DEFAULT
	,entity_gas VARCHAR(250) COLLATE DATABASE_DEFAULT
	,product_group VARCHAR(250) COLLATE DATABASE_DEFAULT
	,calc_id VARCHAR(250) COLLATE DATABASE_DEFAULT
	,self_billing VARCHAR(10) COLLATE DATABASE_DEFAULT
	)

	CREATE TABLE #sap_tax_mapping (
	generic_mapping_values_id INT
	,invoice_line_item_id VARCHAR(250) COLLATE DATABASE_DEFAULT 
	,alias VARCHAR(250) COLLATE DATABASE_DEFAULT
	,clm1_value VARCHAR(250) COLLATE DATABASE_DEFAULT
	,clm2_value VARCHAR(250) COLLATE DATABASE_DEFAULT
	,clm3_value VARCHAR(250) COLLATE DATABASE_DEFAULT
	,clm4_value VARCHAR(250) COLLATE DATABASE_DEFAULT
	,clm5_value VARCHAR(250) COLLATE DATABASE_DEFAULT
	,clm6_value VARCHAR(250) COLLATE DATABASE_DEFAULT
	,clm7_value VARCHAR(250) COLLATE DATABASE_DEFAULT
	,clm8_value VARCHAR(250) COLLATE DATABASE_DEFAULT
	,clm9_value VARCHAR(250) COLLATE DATABASE_DEFAULT
	,product_group VARCHAR(250) COLLATE DATABASE_DEFAULT
	,region VARCHAR(250) COLLATE DATABASE_DEFAULT
	,VAT_Code VARCHAR(250) COLLATE DATABASE_DEFAULT
	,VAT_GL_Account VARCHAR(250) COLLATE DATABASE_DEFAULT
	--,VAT_CODE_buy VARCHAR(250) COLLATE DATABASE_DEFAULT
	--,VAT_GL_Account_buy VARCHAR(250) COLLATE DATABASE_DEFAULT
	,curve VARCHAR(250) COLLATE DATABASE_DEFAULT
	,calc_id VARCHAR(250) COLLATE DATABASE_DEFAULT
	,entity VARCHAR(50) COLLATE DATABASE_DEFAULT DEFAULT 'EET'
	)

IF NULLIF(@counterparty_id, '') IS NOT NULL
BEGIN
	INSERT INTO #counterparty (item)
	SELECT item
	FROM dbo.SplitCommaSeperatedValues(@counterparty_id)
END
ELSE IF NULLIF(@calc_id, '') IS NOT NULL 
BEGIN
	INSERT INTO #counterparty (item)
	SELECT counterparty_id FROM Calc_invoice_Volume_variance where calc_id = @calc_id
END
ELSE
BEGIN
	INSERT INTO #counterparty (item)
	SELECT source_counterparty_id
	FROM source_counterparty
	WHERE int_ext_flag <> 'b'
END

IF NULLIF(@contract_id, '') IS NOT NULL
BEGIN
	INSERT INTO #contract (item)
	SELECT item
	FROM dbo.SplitCommaSeperatedValues(@contract_id)
END
ELSE IF NULLIF(@calc_id, '') IS NOT NULL 
BEGIN
	INSERT INTO #contract (item)
	SELECT contract_id FROM Calc_invoice_Volume_variance where calc_id = @calc_id
END
ELSE
BEGIN
	INSERT INTO #contract (item)
	SELECT contract_id
	FROM contract_group
END


IF NULLIF(@calc_id, '') IS NULL
BEGIN
	INSERT INTO #calc_id (
		calc_id
		,counterparty_id
		,contract_id
		,as_of_date
		,invoice_date
		)
	SELECT calc_id
		,counterparty_id
		,contract_id
		,as_of_date
		,settlement_date
	FROM Calc_invoice_Volume_variance civv
	INNER JOIN #counterparty c ON c.item = civv.counterparty_id
	INNER JOIN #contract c1 ON c1.item = civv.contract_id
	WHERE as_of_date = @as_of_date
		AND settlement_date = @invoice_date
		AND netting_calc_id IS NULL
END
ELSE
BEGIN
	INSERT INTO #calc_id (
		calc_id
		,counterparty_id
		,contract_id
		,as_of_date
		,invoice_date
		)
	SELECT @calc_id
		,counterparty_id
		,contract_id
		,CAST(@as_of_date AS DATETIME)
		,CAST(@invoice_date AS DATETIME)
	FROM Calc_invoice_Volume_variance
	WHERE calc_id = @calc_id
END

SELECT @contract_type = CASE 
		WHEN MAX(standard_contract) = 'y'
			THEN ISNULL(sdv.code, 'Standard')
		ELSE ISNULL(sdv.code, 'Non-Standard')
		END
FROM contract_group cg
INNER JOIN Calc_invoice_Volume_variance civv ON civv.contract_id = cg.contract_id --AND civv.calc_id = @calc_id
INNER JOIN #calc_id ci ON ci.calc_id = civv.calc_id
LEFT JOIN static_data_value sdv ON cg.contract_type_def_id = sdv.value_id
LEFT JOIN static_data_type sdt ON sdt.type_id = sdv.type_id
	AND sdt.type_name = 'Contract Type'
GROUP BY sdv.code

IF @process_id IS NULL
BEGIN
	SELECT @process_id = dbo.FNAGETnewID()
END

SET @process_table = dbo.FNAProcesstablename('SAP_final', @user, @process_id)

DECLARE @table_name VARCHAR(300)

SELECT @table_name = 'SAP_final_' + @user + '_' + @process_id

IF @flag = 's' OR @flag = 'z'
BEGIN
	EXEC (
		'IF EXISTS(SELECT 1 FROM adiha_process.sys.tables WHERE  name =  ' + '''' + @table_name + ''')
			DROP TABLE ' + @process_table
		)
CREATE TABLE #sap_export_data (
	source_counterparty_id INT NULL
	,[2120_hardcode] VARCHAR(100) COLLATE DATABASE_DEFAULT NULL 
	,[TA_hardcode] VARCHAR(50) COLLATE DATABASE_DEFAULT
	,[prod_date] DATETIME NULL
	,[Year] VARCHAR(10) COLLATE DATABASE_DEFAULT NULL
	,[currency_id] VARCHAR(50) COLLATE DATABASE_DEFAULT NULL
	,[Buy_sell_h] VARCHAR(50) COLLATE DATABASE_DEFAULT NULL
	,[invoice_number] VARCHAR(100) COLLATE DATABASE_DEFAULT NULL
	,[Blank_1] VARCHAR(10) COLLATE DATABASE_DEFAULT NULL
	,[Blank_2] VARCHAR(10) COLLATE DATABASE_DEFAULT NULL
	,[UOM] VARCHAR(200) COLLATE DATABASE_DEFAULT NULL
	,[delivery_period] VARCHAR(6) COLLATE DATABASE_DEFAULT NULL
	,[Buy_sell_d] VARCHAR(50) COLLATE DATABASE_DEFAULT NULL
	,[BLank] VARCHAR(200) COLLATE DATABASE_DEFAULT NULL
	,[2120_hardcode2] VARCHAR(100) COLLATE DATABASE_DEFAULT NULL
	,[Blank_3] VARCHAR(10) COLLATE DATABASE_DEFAULT NULL
	,[external_value] VARCHAR(100) COLLATE DATABASE_DEFAULT NULL
	,[payable_id] VARCHAR(100) COLLATE DATABASE_DEFAULT NULL
	,[Gl_account_vat] VARCHAR(100) COLLATE DATABASE_DEFAULT NULL
	,[Gl_account] INT NULL
	,[Cost_encoding] VARCHAR(100) COLLATE DATABASE_DEFAULT NULL
	,[Blank_4] VARCHAR(10) COLLATE DATABASE_DEFAULT NULL
	,[Blank_5] VARCHAR(10) COLLATE DATABASE_DEFAULT NULL
	,[Blank_6] VARCHAR(10)COLLATE DATABASE_DEFAULT NULL
	,[Value-D] FLOAT NULL
	,[line_item] INT NULL
	,[VAT_code] VARCHAR(200) COLLATE DATABASE_DEFAULT NULL
	,[Blank_7] VARCHAR(10) COLLATE DATABASE_DEFAULT NULL
	,[Blank_8] VARCHAR(10) COLLATE DATABASE_DEFAULT NULL
	,[counterparty_country] VARCHAR(200) COLLATE DATABASE_DEFAULT NULL
	,[PNL_BUYSELL] VARCHAR(200) COLLATE DATABASE_DEFAULT NULL
	,[counterparty_pnl_buysell] VARCHAR(5000) COLLATE DATABASE_DEFAULT NULL
	,[gl_ac_blnc_est] VARCHAR(200) COLLATE DATABASE_DEFAULT NULL
	,[Volume] FLOAT NULL
	,[bank_id] VARCHAR(200) COLLATE DATABASE_DEFAULT NULL 
	,[partner_bank_id] VARCHAR(200) COLLATE DATABASE_DEFAULT NULL
	,[0_hardcoded2] INT NULL
	,[invoice_date] DATETIME NULL
	,as_of_date DATETIME NULL
	,contract_id INT NULL
	,current_year_general_ledger VARCHAR(250) COLLATE DATABASE_DEFAULT
	,currrent_year_cost_center VARCHAR(250) COLLATE DATABASE_DEFAULT
	,region VARCHAR(250) COLLATE DATABASE_DEFAULT
	,contract_name VARCHAR(250) COLLATE DATABASE_DEFAULT
	,tax VARCHAR(250) COLLATE DATABASE_DEFAULT
	,current_year_profit_center VARCHAR(250) COLLATE DATABASE_DEFAULT
	,partnerID VARCHAR(250) COLLATE DATABASE_DEFAULT
	,Last_Year_General_Ledger VARCHAR(250) COLLATE DATABASE_DEFAULT
	,entity_gas VARCHAR(250) COLLATE DATABASE_DEFAULT
	,product_group VARCHAR(250) COLLATE DATABASE_DEFAULT
	,Tax_buy VARCHAR(250) COLLATE DATABASE_DEFAULT
	,tax_code_buy VARCHAR(250) COLLATE DATABASE_DEFAULT
	,Tax_sale VARCHAR(250) COLLATE DATABASE_DEFAULT
	,tax_code_sale VARCHAR(250) COLLATE DATABASE_DEFAULT
	,calc_id VARCHAR(250) COLLATE DATABASE_DEFAULT
	,double_booking VARCHAR(250) COLLATE DATABASE_DEFAULT
	,counterparty_type VARCHAR(10) COLLATE DATABASE_DEFAULT
	,ic_with_fiscal VARCHAR(25) COLLATE DATABASE_DEFAULT
	,self_billing VARCHAR(25) COLLATE DATABASE_DEFAULT
	--,Last_year_cost_center VARCHAR(250) COLLATE DATABASE_DEFAULT
	--,Last_year_profit_center VARCHAR(250) COLLATE DATABASE_DEFAULT
	)


SELECT MAX(civv.as_of_date) as_of_date
	,prod_date
	,settlement_date
	,civv.counterparty_id
	,civv.contract_id
INTO #civv1
FROM calc_invoice_volume_variance civv
INNER JOIN #counterparty c ON c.item = civv.counterparty_id
INNER JOIN #contract c1 ON c1.item = civv.contract_id
INNER JOIN #calc_id ci ON ci.calc_id = civv.calc_id
WHERE civv.as_of_date = @as_of_date
GROUP BY prod_date
	,settlement_date
	,civv.counterparty_id
	,civv.contract_id

IF @contract_type = '_Standard'
BEGIN
	IF OBJECT_ID('tempdb..#void_unvoid') IS NOT NULL 
		DROP TABLE #void_unvoid

	IF OBJECT_ID('tempdb..#voided_unvoided_pivot') IS NOT NULL 
		DROP TABLE #voided_unvoided_pivot
	IF OBJECT_ID('tempdb..#status_void') IS NOT NULL 
		DROP TABLE #status_void

		
	SELECT ISNULL(status,'u')status,civv.as_of_date,civv.prod_date,civv.settlement_date,civv.counterparty_id,civv.contract_id,civv.calc_id,CASE WHEN status = 'v' THEN 2 ELSE 1 END num_status,civv.invoice_type
	INTO #void_unvoid
	 from #civv1 civv1 
			INNER JOIN Calc_invoice_Volume_variance civv ON civv.as_of_date = civv1.as_of_date
				AND civv.prod_date = civv1.prod_date
				AND civv.settlement_date = civv1.settlement_date
				AND civv.counterparty_id = civv1.counterparty_id
				AND civv.contract_id = civv1.contract_id
			INNER JOIN calc_invoice_volume civ ON civ.calc_id = civv.calc_id


	SELECT  as_of_date,prod_date,settlement_date,counterparty_id,contract_id,
	[u]  unvoided_calc,[v] voided_calc,invoice_type
	INTO #voided_unvoided_pivot
	FROM
	(SELECT status,as_of_date,prod_date,settlement_date,counterparty_id,contract_id,calc_id,invoice_type
		FROM #void_unvoid) AS SourceTable 
	PIVOT
	(
	MAX(calc_id)
	FOR status IN ([u],[v])
	) AS PivotTable
	WHERE invoice_type = 'i'
	SELECT CASE WHEN MAX(a.num_status) ='2' THEN 'v' ELSE 'u' END status,a.as_of_date,a.prod_date,a.settlement_date,a.counterparty_id,a.contract_id,b.voided_calc,b.unvoided_calc 
	INTO #status_void
	FROM #void_unvoid a  INNER JOIN #voided_unvoided_pivot b ON
				a.as_of_date = b.as_of_date
				AND a.prod_date = b.prod_date
				AND a.settlement_date = b.settlement_date
				AND a.counterparty_id = b.counterparty_id
				AND a.contract_id = b.contract_id
	GROUP BY a.as_of_date,a.prod_date,a.settlement_date,a.counterparty_id,a.contract_id,b.voided_calc,b.unvoided_calc

	 
	

	--	INNER JOIN calc_formula_value cfv ON cfv.calc_id = civv.calc_id
	INSERT INTO #sap_export_data (
		source_counterparty_id
		,[2120_hardcode]
		,[TA_hardcode]
		,[prod_date]
		,[Year]
		,[currency_id]
		,[Buy_sell_h]
		,[invoice_number]
		,[Blank_1]
		,[Blank_2]
		,[UOM]
		,[delivery_period]
		,[Buy_sell_d]
		,[BLank]
		,[2120_hardcode2]
		,[Blank_3]
		,[external_value]
		,[payable_id]
		,[Gl_account_vat]
		,[Gl_account]
		,[Cost_encoding]
		,[Blank_4]
		,[Blank_5]
		,[Blank_6]
		,[Value-D]
		,[line_item]
		,[VAT_code]
		,[Blank_7]
		,[Blank_8]
		,[counterparty_country]
		,[PNL_BUYSELL]
		,[counterparty_pnl_buysell]
		,[gl_ac_blnc_est]
		,[Volume]
		,[bank_id]
		,[partner_bank_id]
		,[0_hardcoded2]
		,[invoice_date]
		,as_of_date
		,contract_id
		,calc_id
		)
	SELECT sc2.source_counterparty_id
		,2120
		,'DR'
		,civv.settlement_date
		,YEAR(GETDATE()) [Year]
		,sc.currency_id
		,isnull(sb_2.source_book_name,'') + ' ' + CAST(MONTH(CAST(civv.prod_date AS VARCHAR(100))) AS VARCHAR(200)) + '-' + CAST(YEAR(CAST(civv.prod_date AS VARCHAR(100))) AS VARCHAR(200)) [Buy/sell-h]
		,civv.invoice_number
		,--NL011952
		''
		,''
		,MAX(su1.uom_name)
		,cast(YEAR(civv.prod_date) AS VARCHAR) + RIGHT('0' + CAST(month(civv.prod_date) AS VARCHAR), 2) delivery_period
		,
		--detail
		/*sequence number grouped by Buy/Sell*/
		/*sequence group by BSCHL,SHKZG,BURKS,FILLER,HKONT,KOSTL*/
		CASE 
			WHEN sum(cfv.value) > 0
				THEN 50
			ELSE 40
			END [Buy/sell-d]
		,''
		,2120
		,''
		,cea.external_value
		,cea2.external_value AS payable_id
		,gsm.gl_account_number [Gl account vat]
		,sdv101.code [Gl account]
		,sdv_clm11_value.code [Cost encoding]
		,''
		,''
		,''
		, CASE WHEN MAX(vi.status) <> 'v' THEN 1 ELSE -1 END * ROUND(sum(civ.value), 2) [Value-D]
		,civ.invoice_line_item_id
		,sdv_clm6_value.code [VAT code]
		,''
		,''
		,
		-- sc2.counterparty_name + ' ' + sb_3.source_book_name 
		cea.external_value [counterparty/country]
		,sc2.counterparty_name + ' ' + gmv2.clm7_value + ' ' + cg.contract_name + ' ' + CAST(MONTH(CAST(civv.prod_date AS VARCHAR(100))) AS VARCHAR(200)) + '-' + CAST(YEAR(CAST(civv.prod_date AS VARCHAR(100))) AS VARCHAR(200)) [PNL/BUYSELL]
		,sc2.counterparty_name + ' ' + sb_2.source_book_name + ' ' + CAST(MONTH(CAST(civv.prod_date AS VARCHAR(100))) AS VARCHAR(200)) + '-' + CAST(YEAR(CAST(civv.prod_date AS VARCHAR(100))) AS VARCHAR(200)) [counterparty_pnl_buysell]
		,sdv_clm12_value.[description]
		,CASE 
			WHEN civ.invoice_line_item_id = 293317
				THEN 0
			ELSE ROUND(sum(cfv.Volume), 3)
			END AS Volume
		,
		-- summary
		/*sequence number grouped by Buy/Sell*/
		max(cbi.reference) [bank_id]
		,max(cbi1.reference) [partner_bank_id]
		,0
		,Convert(DATETIME,ISNULL(dbo.FNADateFormat(civv.payment_date),
 dbo.FNADateFormat(dbo.FNAInvoiceDueDate( 
 CASE WHEN cg.invoice_due_date = '20023'  OR cg.invoice_due_date = '20024'
 THEN civv.finalized_date 
 ELSE civv.prod_date END
 , cg.invoice_due_date, cg.holiday_calendar_id, cg.payment_days))),103) [invoice_date]
		,civv.as_of_date
		,civv.contract_id
		,civv.calc_id
FROM calc_invoice_volume_variance civv
	INNER JOIN #counterparty c ON c.item = civv.counterparty_id
	INNER JOIN #contract c1 ON c1.item = civv.contract_id
	INNER JOIN #civv1 civv1 ON civv.as_of_date = civv1.as_of_date
		AND civv.prod_date = civv1.prod_date
		AND civv.settlement_date = civv1.settlement_date
		AND civv.counterparty_id = civv1.counterparty_id
		AND civv.contract_id = civv1.contract_id
--	INNER JOIN #calc_id ci ON ci.calc_id = civv.calc_id
	INNER JOIN #status_void vi On civv.calc_id = vi.unvoided_calc
	INNER JOIN calc_invoice_volume civ ON civv.calc_id = civ.calc_id
	--LEFT JOIN calc_formula_value cfv ON cfv.calc_id = civv.calc_id
	--	AND cfv.invoice_line_item_id = civ.invoice_line_item_id
	OUTER APPLY( SELECT TOP 1 * FROM calc_formula_value c WHERE c.calc_id = civv.calc_id
	 AND c.invoice_line_item_id = civ.invoice_line_item_id
	
	)cfv
	LEFT JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = cfv.deal_id
	LEFT JOIN source_deal_header sdh ON sdh.source_deal_header_id = ISNULL(sdd.source_deal_header_id, cfv.source_deal_header_id)
	OUTER APPLY (
		SELECT MAX(fixed_price_currency_id) fixed_price_currency_id
		FROM source_deal_detail
		WHERE source_deal_header_id = sdh.source_deal_header_id
		) sdd1
	LEFT JOIN source_system_book_map ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
		AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
		AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
		AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
	LEFT JOIN source_book sb ON sb.source_book_id = ssbm.fas_book_id
	LEFT JOIN contract_group cg ON CAST(civv.contract_id AS VARCHAR(100)) = cg.contract_id
	LEFT JOIN source_currency sc ON  ISNULL(cg.currency, sdd1.fixed_price_currency_id) = 
                sc.source_currency_id
	LEFT JOIN source_commodity sc1 ON CAST(sdh.commodity_id AS VARCHAR(100)) = sc1.source_commodity_id
	
	LEFT JOIN source_counterparty sc2 ON civv.counterparty_id = sc2.source_counterparty_id
	LEFT JOIN fas_subsidiaries fs ON fs.fas_subsidiary_id = cg.sub_id
	LEFT JOIN counterparty_epa_account cea ON sc2.source_counterparty_id = cea.counterparty_id
		AND cea.external_type_id = 2202--@external_type_id2
	LEFT JOIN static_data_value country_sdv ON sc2.country = country_sdv.value_id
	LEFT JOIN generic_mapping_header gmh ON gmh.mapping_name = 'EFET VAT Rule Mapping'
	LEFT JOIN generic_mapping_header gmh2 ON gmh2.mapping_name = 'SAP GL Code Mapping'
	LEFT JOIN generic_mapping_definition gmd ON gmd.mapping_table_id = gmh.mapping_table_id
	LEFT JOIN generic_mapping_definition gmd2 ON gmd2.mapping_table_id = gmh2.mapping_table_id
	LEFT JOIN counterparty_epa_account cea1 ON sc2.source_counterparty_id = cea1.counterparty_id
		AND cea1.external_type_id = 2201--@external_type_id1
	LEFT JOIN counterparty_epa_account cea2 ON sc2.source_counterparty_id = cea2.counterparty_id
		AND cea2.external_type_id = 2203--@external_type_id
	LEFT JOIN generic_mapping_values gmv ON gmv.mapping_table_id = gmh.mapping_table_id
		AND gmv.clm1_value = CAST(ssbm.source_system_book_id2 AS VARCHAR(100))
		AND gmv.clm2_value = CAST(ssbm.source_system_book_id3 AS VARCHAR(100))
		AND gmv.clm3_value = CAST(sc2.region AS VARCHAR(100))
		AND gmv.clm4_value = CASE 
			WHEN cea1.external_value IS NULL
				THEN 'n'
			ELSE 'y'
			END
	LEFT JOIN generic_mapping_values gmv2 ON gmv2.mapping_table_id = gmh2.mapping_table_id
		AND gmv2.clm1_value = CAST(ssbm.source_system_book_id1 AS VARCHAR(100))
		AND gmv2.clm2_value = CAST(ssbm.source_system_book_id2 AS VARCHAR(100))
		AND gmv2.clm3_value = CAST(ssbm.source_system_book_id3 AS VARCHAR(100))
		AND gmv2.clm4_value = CAST(sdh.contract_id AS VARCHAR(100))
		AND gmv2.clm5_value = CAST(sc.source_currency_id AS VARCHAR(100))
		AND gmv2.clm6_value = 's'
	LEFT JOIN static_data_value sdv101 ON sdv101.value_id = gmv2.clm9_value
		AND sdv101.type_id = 29800
	LEFT JOIN gl_system_mapping gsm ON CAST(gsm.gl_number_id AS VARCHAR(100)) = gmv.clm7_value
	LEFT JOIN static_data_value sdv_clm11_value ON CAST(sdv_clm11_value.value_id AS VARCHAR(100)) = gmv2.clm11_value
	LEFT JOIN static_data_value sdv_clm6_value ON CAST(sdv_clm6_value.value_id AS VARCHAR(100)) = gmv.clm6_value
	LEFT JOIN static_data_value sdv_clm12_value ON CAST(sdv_clm12_value.value_id AS VARCHAR(100)) = gmv2.clm12_value
	LEFT JOIN source_book sb_3 ON sb_3.source_book_id = sdh.source_system_book_id3
	LEFT JOIN source_book sb_2 ON sb_2.source_book_id = sdh.source_system_book_id2
	LEFT JOIN counterparty_bank_info cbi ON cbi.counterparty_id = fs.counterparty_id
		AND cbi.currency = cg.currency
	LEFT JOIN source_counterparty sc3 ON sc2.source_counterparty_id = sc3.source_counterparty_id
	LEFT JOIN counterparty_bank_info cbi1 ON sc3.source_counterparty_id = cbi1.counterparty_id
		AND cbi1.currency = cg.currency
	LEFT JOIN source_uom su1 ON su1.source_uom_id = ISNULL(civ.uom_id, cg.volume_uom)  
	--WHERE 1 = 1
	----	AND cfv.is_final_result = 'y'
	--	AND civv.invoice_type = 'i'
	--	AND ISNULL(civv.finalized, 'n') = CASE 
	--		WHEN @flag = 's' --or @flag ='z'
	--			THEN 'y'
	--		ELSE 'n'
	--		END
	WHERE civv.invoice_type = 'i' --AND cfv.is_final_result = 'y'
		AND ( ISNULL(civv.finalized, 'n')  = 
				CASE WHEN vi.status <> 'v' THEN
					--ISNULL(civv.finalized, 'n') = 
					CASE 
						WHEN @flag = 's' 
							THEN 'y'
						ELSE 'n'
						END
				ELSE  ISNULL(civv.finalized, 'n')  END
			OR 
			ISNULL(civ.STATUS, 'n') =
			CASE WHEN vi.status <> 'v' THEN
				 CASE 
					WHEN @flag = 's'
						THEN 'v'
					ELSE 'n'
					END
			ELSE ISNULL(civ.STATUS, 'n') END )
		AND civv.settlement_date = @invoice_date
		AND civv.as_of_date = @as_of_date
		--AND cfv.value  <> 0
	GROUP BY civv.prod_date
		,sc.currency_id
		,civv.invoice_type
		,sc2.counterparty_name
		,country_sdv.code
		,cg.contract_name
		,gmv2.clm7_value
		,sdv_clm11_value.code
		,gsm.gl_account_number
		,sdv_clm12_value.[description]
		,sb_3.source_book_name
		,civv.settlement_date
		,civv.invoice_number
		,sdv_clm6_value.code
		,cea.external_value
		,gmv2.clm7_value
		,sdv101.code
		,civ.invoice_line_item_id
		,sb_2.source_book_name
		,cea2.external_value
		,sc2.source_counterparty_id
		,civv.as_of_date
		,civv.contract_id
		,civv.calc_id
		,civv.payment_date,cg.invoice_due_date,civv.finalized_date,cg.holiday_calendar_id,cg.payment_days

INSERT INTO #temp_sap_detail (
	[column_1]
	,[column_2]
	,[column_3]
	,[column_4]
	,[column_5]
	,[column_6]
	,[column_7]
	,[column_8]
	,[column_9]
	,[column_10]
	,[column_11]
	,[column_12]
	,[column_13]
	,[column_14]
	,[column_15]
	,[Order_detail]
	,[Buy_sell_d]
	,invoice_number
	,line_item
	,Gl_account_vat
	,[Buy_sell_h]
	,row_type
	,source_counterparty_id
	,contract_id
	,grouping
	,[calc_id]
	)
SELECT [column_1]
	,[column_2]
	,[column_3]
	,[column_4]
	,[column_5]
	,[column_6]
	,[column_7]
	,[column_8]
	,[column_9]
	,[column_10]
	,[column_11]
	,[column_12]
	,[column_13]
	,[column_14]
	,[column_15]
	,[Order_detail]
	,[Buy_sell_d]
	,invoice_number
	,line_item
	,Gl_account_vat
	,[Buy_sell_h]
	,row_type
	,source_counterparty_id
	,contract_id
	,grouping
	,[calc_id]
FROM   
	(
          SELECT 'I' [column_1]
			,'' [column_2]
			,MAX(sed.external_value) [column_3]
			,MAX(sed.[BLank]) [column_4]
			,MAX(replace(CONVERT(VARCHAR(10), sed.invoice_date, 102), '.', '-')) [column_5]
			,'' [column_6]
			,CAST(SUM(CAST(sed.[Value-D] AS NUMERIC(38, 2))) AS VARCHAR(200)) [column_7]
			,'' [column_8]
			,'' [column_9]
			,MAX(sed.[bank_id]) [column_10]
			,--bank id
			MAX(sed.partner_bank_id) [column_11]
			,--partner
			max(sed.[counterparty_pnl_buysell]) [column_12]
			,SUM(round(sed.Volume, 3)) [column_13]
			,MAX(sed.UOM) [column_14]
			,MAX(sed.delivery_period) [column_15]
			,2 [Order_detail]
			,max(sed.[Buy_sell_d]) [Buy_sell_d]
			,MAX(sed.invoice_number) invoice_number
			,MAX(sed.line_item + sed.line_item) line_item
			,MAX(sed.Gl_account_vat) Gl_account_vat
			,MAX(sed.[Buy_sell_h]) [Buy_sell_h]
			,'a' AS row_type
			,source_counterparty_id
			,contract_ID
			,'' [grouping]
			,[calc_id]
		FROM #sap_export_data sed
		GROUP BY sed.[Buy_sell_d]
			,sed.[Buy_sell_h]
			,sed.invoice_number
			,source_counterparty_id
			,contract_ID
			,[calc_id]
       UNION ALL
           SELECT 'I' [column_1]
			,CAST(sed.[Gl_account] AS VARCHAR(100)) [column_2]
			,sed.[Blank_3] [column_3]
			,sed.[Blank_4] [column_4]
			,sed.[Blank_5] [column_5]
			,sed.Cost_encoding [column_6]
			,CAST((CAST(sed.[Value-D] * - 1 AS NUMERIC(38, 2))) AS VARCHAR(200)) [column_7]
			,sed.vat_code[column_8]
			,sed.payable_id [column_9]
			,sed.Blank_6 [column_10]
			,sed.Blank_8 [column_11]
			,sed.PNL_BUYSELL [column_12]
			,ROUND(sed.Volume, 3) [column_13]
			,sed.UOM [column_14]
			,sed.delivery_period [column_15]
			,2 [Order_detail]
			,sed.[Buy_sell_d]
			,sed.invoice_number
			,sed.line_item line_item
			,sed.Gl_account_vat
			,sed.[Buy_sell_h]
			,'b' AS row_type
			,source_counterparty_id
			,contract_ID
			,CASE 
				WHEN line_item <> @VAT
					THEN 'withoutvat'
				ELSE 'withvat'
				END [grouping]
			,[calc_id]
		FROM #sap_export_data sed
       ) a
ORDER BY
       a.[Order_detail],
       a.invoice_number,[grouping],[calc_id],
       a.line_item DESC


	 
	INSERT INTO #header (
		[column_1]
		,[column_2]
		,[column_3]
		,[column_4]
		,[column_5]
		,[column_6]
		,[column_7]
		,[column_8]
		,[column_9]
		,[column_10]
		,[column_11]
		,[column_12]
		,[column_13]
		,[column_14]
		,[column_15]
		,[ORDER]
		,[distinct_value]
		,[invoice_number]
		,[row_type]
		,source_counterparty_id
		,contract_ID
		,[calc_id]
		)
SELECT 'H' [column_1],
       CAST(sed.[2120_hardcode] AS VARCHAR(50)) [column_2],
       CAST(sed.TA_hardcode AS VARCHAR(50)) [column_3],
       replace(CONVERT(VARCHAR(10), sed.prod_date, 102),'.', '-') [column_4],
       CAST(sed.[Year] AS VARCHAR(100)) [column_5],
       replace(CONVERT(VARCHAR(10), GETDATE(), 102),'.', '-') [column_6],
       CAST(sed.currency_id AS VARCHAR(50)) [column_7],
       sed.[Buy_sell_h] [column_8],
       sed.[invoice_number] [column_9],
       '' [column_10],
       '' [column_11],
       '' [column_12],
       NULL [column_13],
	   '' [column_14],
	   '' [column_15],
       1 [Order]
      , ROW_NUMBER() OVER(ORDER BY sed.[Buy_sell_h]) [distinct_value],
      sed.[invoice_number],
	  '' row_type,source_counterparty_id,
				  contract_ID,[calc_id]
FROM   #sap_export_data sed
WHERE ISNULL(line_item,'') NOT IN (SELECT value_id FROM #vat) AND ISNULL(line_item,'') NOT IN (SELECT value_Id FROM #delta)
GROUP BY
       sed.[invoice_number],
       sed.[Buy_sell_h],
       sed.TA_hardcode,
       sed.prod_date,
       sed.currency_id,
       sed.[Year],sed.[2120_hardcode],source_counterparty_id,contract_ID,[calc_id]
	
		INSERT INTO #detail([column_1],[column_2],[column_3],[column_4],[column_5],[column_6],[column_7],[column_8],[column_9],
		[column_10],[column_11],[column_12],[column_13],[column_14],[column_15],[ORDER],[distinct_value],[invoice_number],contract_ID,[calc_id],source_counterparty_id,row_type)
		SELECT 'I' [column_1],
		sap_union.[column_2],
		sap_union.[column_3],
		sap_union.[column_4],
		sap_union.[column_5],
		sap_union.[column_6],
		CAST(SUM(CAST(sap_union.[column_7] AS numeric(38,4))) AS VARCHAR(200))[column_7],
		sap_union.[column_8],
		sap_union.[column_9],
		sap_union.[column_10],
		sap_union.[column_11],
		sap_union.[column_12],
		CAST(SUM(CAST(sap_union.[column_13] AS FLOAT)) AS VARCHAR(200))[column_13],
		sap_union.[column_14],
		sap_union.[column_15],
		2 [Order]
		, h.[distinct_value], 
		sap_union.[invoice_number] ,
		h.contract_ID,sap_union.[calc_id],h.source_counterparty_id,sap_union.row_type
FROM   #temp_sap_detail sap_union
		INNER JOIN  #header h ON h.[column_9]= sap_union.[invoice_number]
		AND ISNULL(h.source_counterparty_id,0) = ISNULL(sap_union.source_counterparty_id,0)
					AND ISNULL(h.contract_id,0) = ISNULL(sap_union.contract_id,0)
					AND h.calc_id = sap_union.calc_id
		GROUP BY 
		sap_union.[column_2],
		sap_union.[column_3],
		sap_union.[column_4],
		sap_union.[column_5],
		sap_union.[column_6], 
		sap_union.[column_8],
		sap_union.[column_9],
		sap_union.[column_10],
		sap_union.[column_11],
		sap_union.[column_12],
		sap_union.[column_14],sap_union.[column_15],h.[distinct_value], sap_union.[invoice_number] ,sap_union.[row_type],h.source_counterparty_id,h.contract_ID,grouping,sap_union.[calc_id],h.source_counterparty_id,sap_union.row_type
	
	
	END
	ELSE IF @contract_type = 'Non-Standard' OR @contract_type = 'Standard'
	BEGIN
		
		DECLARE @template_id INT 
		DECLARE @function_id VARCHAR(200) 
		DECLARE @gsp_group VARCHAR(40) 

SELECT @function_id = function_id  FROM application_functions WHERE function_name = 'Setup Non-Standard Contract'
SELECT @gsp_group = application_ui_field_id FROM application_ui_template_definition WHERE application_function_id = @function_id  AND field_id = 'GSP_Group'

		SELECT sdv.value_id
	   ,sdv.type_id
	   ,sdv.code
	   ,primary_field_object_id
	INTO #gsp_group_info
FROM application_ui_template aut 
	INNER JOIN application_ui_template_group autg ON autg.application_ui_template_id = aut.application_ui_template_id
	INNER JOIN application_ui_template_fields autf ON autf.application_group_id = autg.application_group_id
	INNER JOIN maintain_udf_static_data_detail_values msddv ON msddv.application_field_id = autf.application_field_id
	INNER JOIN #contract c1 ON primary_field_object_Id = c1.item
	INNER JOIN static_data_value sdv ON sdv.value_id = msddv.static_data_udf_values
	INNER JOIN static_data_type sdt ON sdt.type_id = sdv.type_id and sdt.type_name = 'GSP Group'
WHERE application_function_id = @function_id  
	  AND autg.active_flag = 'y' 
	  AND autg.group_name = 'Detail' 
	  AND autf.application_ui_field_id = @gsp_group 



		SELECT @template_id = contract_charge_type_id  FROM contract_group cg
	INNER JOIN #calc_id ci ON ci.contract_id = cg.contract_id
	
	SELECT cea.counterparty_id
					,external_type_id
					,external_value
		INTO #double_booking
				FROM counterparty_epa_account cea
				INNER JOIN static_data_value sdv_cea ON sdv_cea.value_id = cea.external_type_id
				INNER JOIN static_data_type sdt_cea ON sdt_cea.type_id = sdv_cea.type_id
					AND sdt_cea.type_name = 'Counterparty External ID'
				INNER JOIN #calc_id ci ON ci.counterparty_id = cea.counterparty_id
				WHERE
					 cea.external_type_id = sdv_cea.value_id
					AND sdv_cea.code = 'Double Booking'

DECLARE @double_booking CHAR(1)
DECLARE @entrepot_number CHAR(1) 
DECLARE @ic_with_fiscal CHAR(1) 

SELECT @double_booking = CASE WHEN ISNULL(external_value,'NO') ='NO' THEN 'n' ELSE 'y' END FROM #double_booking	

Select @entrepot_number =  CASE WHEN ISNULL(external_value,'NO') ='NO' THEN 'n' ELSE 'y' END FROM source_counterparty sc1 
				INNER JOIN counterparty_epa_account cea ON cea.counterparty_id = sc1.source_counterparty_id
				INNER JOIN static_data_value sdv_cea ON cea.external_type_id = sdv_cea.value_id
				INNER JOIN static_data_type sdt_cea ON sdt_cea.type_id = sdv_cea.type_id
							AND sdt_cea.type_name = 'Counterparty External ID'
				INNER JOIN #calc_id ci ON ci.counterparty_id = cea.counterparty_id
							AND cea.external_type_id = sdv_cea.value_id
							AND sdv_cea.code = 'Entrepot number'


Select @ic_with_fiscal =  CASE WHEN ISNULL(external_value,'NO') ='NO' THEN 'n' ELSE 'y' END    FROM source_counterparty sc1 
				INNER JOIN counterparty_epa_account cea ON cea.counterparty_id = sc1.source_counterparty_id
				INNER JOIN static_data_value sdv_cea ON cea.external_type_id = sdv_cea.value_id
				INNER JOIN static_data_type sdt_cea ON sdt_cea.type_id = sdv_cea.type_id
							AND sdt_cea.type_name = 'Counterparty External ID'
				INNER JOIN #calc_id ci ON ci.counterparty_id = cea.counterparty_id
							AND cea.external_type_id = sdv_cea.value_id
							AND sdv_cea.code='IC within Fiscal Unit'


		SELECT gmv.mapping_table_id
			,ghm.mapping_name
			,gmv.clm1_value
			,gmv.clm2_value
			,gmv.clm3_value
			,gmv.clm4_value
			,gmv.clm5_value
			,gmv.clm6_value
			,gmv.clm7_value
			,gmv.clm8_value
			,gmv.clm9_value
			,gmv.clm10_value
			,gmv.clm11_value
			,gmv.clm12_value
			,gmv.clm13_value
			,gmv.clm14_value
			,gmv.clm15_value
			,gmv.clm16_value
			,CASE 
				WHEN gmv.clm1_value = 'a'
					THEN 'Accrual'
				ELSE 'Invoicing'
				END [process]
			,CASE 
				WHEN gmv.clm2_value = 's'
					THEN 'Self Billing'
				ELSE 'Outbound'
				END [subprocess]
			,sdv_p.code [country]
			,
			CASE 
				WHEN gmv.clm5_value = sc.source_counterparty_id
					THEN 'Retail'
				ELSE  'EET'
				END 
				[Entity]
			,sdv_b.code [product_group]
			,sdv_r.code [products]
			,sdv_s.code [Current_Year_General_Ledger]
			,sdv_t.code [current_year_cost_center]
			,sdv_u.code [Current_Year_Profit_Center]
			,sdv_v.code [Last_Year_General_Ledger]
			,sdv_w.code [Last_Year_Cost_Center]
			,sdv_x.code [Last_Year_Profit_Center]
			,CASE 
				WHEN gmv1.clm3_value = 'e'
					THEN 'External'
				ELSE 'Internal'
				END [IC_EXT]
			,CASE 
				WHEN gmv1.clm4_value = 'n'
					THEN 'No'
				ELSE 'Yes'
				END [SAP]
			,gmv1.clm5_value [doc_type]
			,sdv_y.code [region]
			,CASE 
				WHEN gmv2.clm3_value = 'n'
					THEN 'No'
				ELSE 'Yes'
				END [Entrepot-number]
			,CASE 
				WHEN gmv2.clm4_value = 'n'
					THEN 'No'
				ELSE 'Yes'
				END [IC]
			,spcd.curve_name [Curve]
			,spcd.source_curve_def_id [Curve_id]
			 ,--CASE WHEN  ISNULL(cg.self_billing, 'n') ='n' THEN  sdv_z.code ELSE sdv_c.code END 
			 sdv_z.code  [VAT_Code]
			,sdv_a.code [VAT_GL_Account]
			--,sdv_c.code [VAT_Code_Buy]
			--,sdv_d.code [VAT_GL_Account_Buy]
			,sc.source_counterparty_id
			,sc.counterparty_id
			,cg.contract_id
			,cg.contract_name
			,@as_of_date as_of_date
			,ISNULL(b.external_value,'No') Double_booking
			,gmv2.clm2_value region_id
			,a.invoice_line_item_id
			,ISNULL(cgd.invoice_line_item_id,cctd.invoice_line_item_id) invoice_line_item
			, ISNULL(c.external_value,'')  entity_code
			, CASE WHEN sc.int_ext_flag = 'i' THEN  ISNULL(d.external_value,'') ELSE '' END entity_code_cpty
			,CASE WHEN gmv.clm3_value = 'b' THEN 'Broker'
			WHEN gmv.clm3_value = 'i' THEN 'Internal'
			WHEN gmv.clm3_value = 'e' THEN 'External' 
			ELSE '' END non_efet_IC_Ext
			,sdv_g.code [GSP_group]
			,sdv_cbal.code[current_year_balance_center]
			,sdv_lbal.code[last_year_balance_center]
			,@ic_with_fiscal ic_with_fiscal
			,ISNULL(cg.self_billing, 'n') self_billing
	INTO #sap_gl_mapping_invoicing1

 FROM generic_mapping_header ghm
		INNER JOIN generic_mapping_values gmv ON gmv.mapping_table_id = ghm.mapping_table_id
			AND mapping_name = 'Non EFET SAP GL Mapping'
		CROSS APPLY (
			SELECT civv.calc_id
				,civv.as_of_date
				,civv.counterparty_id
				,civv.contract_id
				,civv.prod_date
				,civv.finalized
				,civ.invoice_line_item_id
				,civ.status
		FROM calc_invoice_volume_variance civv 
				INNER JOIN #calc_id	ci ON ci.calc_id = civv.calc_id
				INNER JOIN calc_invoice_volume civ ON civ.calc_id = civv.calc_id
			
			WHERE --civv.calc_id = @calc_id--36349 AND
				 gmv.clm1_value =CASE WHEN @flag ='z' THEN 'i' 
					ELSE CASE 
						WHEN ISNULL(civv.finalized,'n') ='y' OR ISNULL(civ.status,'') = 'v'
							THEN 
							 'i'
						ELSE 'a'
						END
					  END
				AND gmv.clm8_value = civ.invoice_line_item_id AND civv.netting_calc_id  IS NULL
			) a
		INNER JOIN contract_group cg ON cg.contract_id = a.contract_id
			AND ISNULL(cg.self_billing, 'n') = CASE 
				WHEN gmv.clm2_value = 's' 
					THEN 'y'
				ELSE 'n'
				END
		INNER JOIN source_counterparty sc ON sc.source_counterparty_id = a.counterparty_id AND sc.int_ext_flag = gmv.clm3_value
		INNER JOIN counterparty_contacts cc ON cc.counterparty_id = sc.source_counterparty_id
			AND is_primary = 'y'
			AND CAST(cc.country as VARCHAR(250)) = gmv.clm4_value
		--INNER JOIN contract_group_detail cgd ON cgd.contract_id = cg.contract_id AND cgd.invoice_line_item_id  = gmv.clm6_value AND cgd.alias = gmv.clm5_value
		LEFT  JOIN contract_group_detail cgd ON cgd.contract_id = cg.contract_id AND cgd.invoice_line_item_id  = gmv.clm8_value AND cgd.alias = gmv.clm7_value-- AND cctd.contract_charge_type_id is not null
		LEFT JOIN contract_charge_type cct ON cct.contract_charge_type_id = cg.contract_charge_type_id
		LEFT JOIN contract_charge_type_detail cctd ON cctd.contract_charge_type_id = cct.contract_charge_type_id AND  cctd.invoice_line_item_id  = gmv.clm8_value AND cctd.alias = gmv.clm7_value  
		INNER JOIN generic_mapping_values gmv1 ON gmv1.clm1_value = gmv.clm1_value
			AND gmv1.clm2_value = gmv.clm2_value
			AND gmv1.clm3_value = gmv.clm3_value
			AND gmv1.clm3_value = sc.int_ext_flag
		INNER JOIN generic_mapping_header gmh1 ON gmh1.mapping_table_id = gmv1.mapping_table_id
			AND gmh1.mapping_name = 'Non EFET SAP Doc Type'
		LEFT JOIN generic_mapping_values gmv2 ON gmv2.clm1_value = gmv.clm7_value
			AND cc.region = gmv2.clm2_value
			AND gmv2.clm8_value = gmv1.clm5_value
		LEFT JOIN generic_mapping_header gmh2 ON gmh2.mapping_table_id = gmv2.mapping_table_id
			AND gmh1.mapping_name = 'Non EFET VAT Rule Mapping'
		OUTER APPLY (
			SELECT counterparty_id
				,external_type_id
				,external_value
			FROM counterparty_epa_account cea
			INNER JOIN static_data_value sdv_cea ON sdv_cea.value_id = cea.external_type_id
			INNER JOIN static_data_type sdt_cea ON sdt_cea.type_id = sdv_cea.type_id
				AND sdt_cea.type_name = 'Counterparty External ID'
			WHERE cea.counterparty_id =  sc.source_counterparty_id
				AND cea.external_type_id = sdv_cea.value_id
				AND sdv_cea.code = 'Double Booking'
				AND ISNULL(cea.external_value,'No') = CASE WHEN gmv1.clm4_value = 'y' THEN 'Yes' ELSE 'No' END
			) b
		CROSS APPLY(
			SELECT sc1.source_counterparty_id
				,sc1.counterparty_id
				,cea.external_type_id
				,cea.external_value FROM source_counterparty sc1 
			INNER JOIN counterparty_epa_account cea ON cea.counterparty_id = sc1.source_counterparty_id
			INNER JOIN static_data_value sdv_cea ON cea.external_type_id = sdv_cea.value_id
			INNER JOIN static_data_type sdt_cea ON sdt_cea.type_id = sdv_cea.type_id
						AND sdt_cea.type_name = 'Counterparty External ID'
			WHERE sc1.source_counterparty_id =cea.counterparty_id
			AND cea.counterparty_id =  sc1.source_counterparty_id
						AND cea.external_type_id = sdv_cea.value_id
						AND sdv_cea.code = 'entity code'
						AND sc1.source_counterparty_id = gmv.clm5_value
		)c 
			OUTER APPLY(
			SELECT sc1.source_counterparty_id
				,sc1.counterparty_id
				,cea.external_type_id
				,cea.external_value FROM source_counterparty sc1 
			INNER JOIN counterparty_epa_account cea ON cea.counterparty_id = sc1.source_counterparty_id
			INNER JOIN static_data_value sdv_cea ON cea.external_type_id = sdv_cea.value_id
			INNER JOIN static_data_type sdt_cea ON sdt_cea.type_id = sdv_cea.type_id
						AND sdt_cea.type_name = 'Counterparty External ID'
			WHERE sc1.source_counterparty_id =cea.counterparty_id
			AND cea.counterparty_id =  sc.source_counterparty_id
						AND cea.external_type_id = sdv_cea.value_id
						AND sdv_cea.code = 'entity code'
		)d
		LEFT JOIN static_data_value sdv_b ON sdv_b.value_id = gmv.clm7_value
		LEFT JOIN static_data_type sdt_b ON sdt_b.type_id = sdv_b.type_id
			AND sdt_b.type_name = 'Contract Charge Type Group'

		LEFT JOIN static_data_value sdv_p ON sdv_p.value_id = gmv.clm4_value
		LEFT JOIN static_data_type sdt_p ON sdt_p.type_id = sdv_p.type_id
			AND sdt_p.type_name = 'Country'
		LEFT JOIN static_data_value sdv_r ON sdv_r.value_id = gmv.clm8_value
		LEFT JOIN static_data_type sdt_r ON sdt_r.type_id = sdv_r.type_id
			AND sdt_r.type_name = 'Contract Components'

		LEFT JOIN static_data_value sdv_s ON sdv_s.value_id = gmv.clm9_value
		LEFT JOIN static_data_type sdt_s ON sdt_s.type_id = sdv_s.type_id
			AND sdt_s.type_name = 'GL Account'
		LEFT JOIN static_data_value sdv_t ON sdv_t.value_id = gmv.clm10_value
		LEFT JOIN static_data_type sdt_t ON sdt_t.type_id = sdv_t.type_id
			AND sdt_t.type_name = 'Cost Encoding'
		LEFT JOIN static_data_value sdv_u ON sdv_u.value_id = gmv.clm11_value
		LEFT JOIN static_data_type sdt_u ON sdt_u.type_id = sdv_u.type_id
			AND sdt_u.type_name = 'Profit Center'
		LEFT JOIN static_data_value sdv_v ON sdv_v.value_id = gmv.clm13_value
		LEFT JOIN static_data_type sdt_v ON sdt_u.type_id = sdv_v.type_id
			AND sdt_v.type_name = 'Profit Center'
		LEFT JOIN static_data_value sdv_w ON sdv_w.value_id = gmv.clm14_value
		LEFT JOIN static_data_type sdt_w ON sdt_w.type_id = sdv_w.type_id
			AND sdt_w.type_name = 'Cost Encoding'
		LEFT JOIN static_data_value sdv_x ON sdv_x.value_id = gmv.clm15_value
		LEFT JOIN static_data_type sdt_x ON sdt_x.type_id = sdv_x.type_id
			AND sdt_x.type_name = 'Profit Center'
		LEFT JOIN static_data_value sdv_y ON sdv_y.value_id = gmv2.clm2_value
		LEFT JOIN static_data_type sdt_y ON sdt_y.type_id = sdv_y.type_id
			AND sdt_y.type_name = 'Region'
		LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = gmv2.clm5_value
		LEFT JOIN static_data_value sdv_z ON sdv_z.value_id = gmv2.clm6_value
		LEFT JOIN static_data_type sdt_z ON sdt_z.type_id = sdv_z.type_id
			AND sdt_z.type_name = 'VAT Code'
		LEFT JOIN static_data_value sdv_a ON sdv_a.value_id = gmv2.clm7_value
		LEFT JOIN static_data_type sdt_a ON sdt_a.type_id = sdv_a.type_id
			AND sdt_a.type_name = 'GL Account'
		--LEFT JOIN static_data_value sdv_c ON sdv_c.value_id = gmv2.clm8_value
		--LEFT JOIN static_data_type sdt_c ON sdt_c.type_id = sdv_c.type_id
		--	AND sdt_c.type_name = 'VAT Code'
		--LEFT JOIN static_data_value sdv_d ON sdv_d.value_id = gmv2.clm7_value
		--LEFT JOIN static_data_type sdt_d ON sdt_d.type_id = sdv_d.type_id
		--	AND sdt_d.type_name = 'GL Account'
	
		LEFT JOIN static_data_value sdv_g ON sdv_g.value_id = ISNULL(gmv.clm6_value,'')
			LEFT JOIN static_data_type sdt_g On sdt_g.type_id = sdv_g.type_id AND sdt_g.type_name = 'GSP group'
		--	CROSS APPLY (SELECT * FROM #gsp_group_info  ggi WHERE ggi.value_id = sdv_g.value_id  OR gmv.clm6_value IS NULL)z
		LEFT JOIN static_data_value sdv_cbal   ON sdv_cbal.value_id = gmv.clm12_value 
		LEFT JOIN static_data_type sdt_cbal ON sdt_cbal.type_id = sdv_cbal.value_id  and sdt_cbal.type_name = 'GL Account Balance For Estimate'
		LEFT JOIN static_data_value sdv_lbal   ON sdv_lbal.value_id = gmv.clm12_value 
		LEFT JOIN static_data_type sdt_lbal ON sdt_lbal.type_id = sdv_lbal.value_id  and sdt_cbal.type_name = 'GL Account Balance For Estimate'
	WHERE ISNULL(cctd.contract_charge_type_id,0) =  CASE WHEN @template_id IS  NULL THEN    0 ELSE cctd.contract_charge_type_id END
		AND gmv1.clm4_value =ISNULL(@double_booking,'n') --CASE WHEN ISNULL(b.external_value,'')='' THEN 'n' ELSE CASE WHEN b.external_value = 'No' THEN 'n' ELSE 'y' END END 
 AND (CAST(gmv.clm6_value as VARCHAR(200)) IN (SELECT CAST(VALUE_ID as VARCHAR(200)) FROM  #gsp_group_info) OR gmv.clm6_value IS NULL) AND gmv2.clm3_value = ISNULL(@entrepot_number,'n')
 AND gmv2.clm4_value = ISNULL(@ic_with_fiscal,'n')


 
SELECT counterparty_Id as item into #counterparty_primary 
 FROM #calc_id
UNION ALL 
SELECT @primary_counterparty

CREATE TABLE #sap_gl_mapping_invoicing (
	mapping_table_id INT
	,mapping_name VARCHAR(2000) COLLATE DATABASE_DEFAULT
	,clm1_value VARCHAR(2000) COLLATE DATABASE_DEFAULT
	,clm2_value VARCHAR(2000) COLLATE DATABASE_DEFAULT
	,clm3_value VARCHAR(2000) COLLATE DATABASE_DEFAULT
	,clm4_value VARCHAR(2000) COLLATE DATABASE_DEFAULT
	,clm5_value VARCHAR(2000) COLLATE DATABASE_DEFAULT
	,clm6_value VARCHAR(2000) COLLATE DATABASE_DEFAULT
	,clm7_value VARCHAR(2000) COLLATE DATABASE_DEFAULT
	,clm8_value VARCHAR(2000) COLLATE DATABASE_DEFAULT
	,clm9_value VARCHAR(2000) COLLATE DATABASE_DEFAULT
	,clm10_value VARCHAR(2000) COLLATE DATABASE_DEFAULT
	,clm11_value VARCHAR(2000) COLLATE DATABASE_DEFAULT
	,clm12_value VARCHAR(2000) COLLATE DATABASE_DEFAULT
	,clm13_value VARCHAR(2000) COLLATE DATABASE_DEFAULT
	,clm14_value VARCHAR(2000) COLLATE DATABASE_DEFAULT
	,clm15_value VARCHAR(2000) COLLATE DATABASE_DEFAULT
	,clm16_value VARCHAR(2000) COLLATE DATABASE_DEFAULT
	,process VARCHAR(2000) COLLATE DATABASE_DEFAULT
	,subprocess VARCHAR(2000) COLLATE DATABASE_DEFAULT
	,country VARCHAR(2000) COLLATE DATABASE_DEFAULT
	,Entity VARCHAR(2000) COLLATE DATABASE_DEFAULT
	,product_group VARCHAR(2000) COLLATE DATABASE_DEFAULT 
	,products VARCHAR(2000) COLLATE DATABASE_DEFAULT
	,Current_Year_General_Ledger VARCHAR(2000) COLLATE DATABASE_DEFAULT
	,current_year_cost_center VARCHAR(2000) COLLATE DATABASE_DEFAULT
	,Current_Year_Profit_Center VARCHAR(2000) COLLATE DATABASE_DEFAULT
	,Last_Year_General_Ledger VARCHAR(2000) COLLATE DATABASE_DEFAULT
	,Last_Year_Cost_Center VARCHAR(2000) COLLATE DATABASE_DEFAULT
	,Last_Year_Profit_Center VARCHAR(2000) COLLATE DATABASE_DEFAULT
	,IC_EXT VARCHAR(2000) COLLATE DATABASE_DEFAULT
	,SAP VARCHAR(2000) COLLATE DATABASE_DEFAULT
	,doc_type VARCHAR(2000) COLLATE DATABASE_DEFAULT
	,region VARCHAR(2000) COLLATE DATABASE_DEFAULT
	,[Entrepot-number] VARCHAR(2000) COLLATE DATABASE_DEFAULT
	,IC VARCHAR(2000) COLLATE DATABASE_DEFAULT
	,Curve VARCHAR(2000) COLLATE DATABASE_DEFAULT
	,Curve_id INT
	,VAT_Code VARCHAR(2000) COLLATE DATABASE_DEFAULT
	,VAT_GL_Account VARCHAR(2000) COLLATE DATABASE_DEFAULT
	,source_counterparty_id INT
	,counterparty_id NVARCHAR(2000) COLLATE DATABASE_DEFAULT
	,contract_id INT
	,contract_name VARCHAR(2000) COLLATE DATABASE_DEFAULT
	,as_of_date DATETIME
	,Double_booking VARCHAR(2000) COLLATE DATABASE_DEFAULT
	,region_id VARCHAR(2000) COLLATE DATABASE_DEFAULT
	,invoice_line_item_id INT
	,invoice_line_item INT
	,entity_code VARCHAR(2000) COLLATE DATABASE_DEFAULT
	,entity_code_cpty VARCHAR(2000) COLLATE DATABASE_DEFAULT
	,non_efet_IC_Ext VARCHAR(2000) COLLATE DATABASE_DEFAULT
	,GSP_group VARCHAR(2000) COLLATE DATABASE_DEFAULT
	,current_year_balance_center VARCHAR(2000) COLLATE DATABASE_DEFAULT
	,last_year_balance_center VARCHAR(2000) COLLATE DATABASE_DEFAULT
	,ic_with_fiscal CHAR COLLATE DATABASE_DEFAULT
	,self_billing CHAR COLLATE DATABASE_DEFAULT
	)
INSERT INTO #sap_gl_mapping_invoicing
SELECT * FROM #sap_gl_mapping_invoicing1  a 
	 WHERE clm5_value IN (SELECT item FROM #counterparty_primary)
	  

SET @sql = 'INSERT INTO #sap_tax_mapping (
	generic_mapping_values_id
	,invoice_line_item_id
	,alias
	,clm1_value
	,clm2_value
	,clm3_value
	,clm4_value
	,clm5_value
	,clm6_value
	,clm7_value
	,clm8_value
	,clm9_value
	,product_group
	,region
	,VAT_Code
	,VAT_GL_Account
	,curve,calc_id,entity
	)
SELECT Distinct generic_mapping_values_id,'+CASE WHEN @template_id IS NULL THEN 'cgd' ELSE 'cctd' END+'.invoice_line_item_id,'+CASE WHEN @template_id IS NULL THEN 'cgd' ELSE 'cctd' END+'.alias,gmv.clm1_value,gmv.clm2_value,gmv.clm3_value,gmv.clm4_value,gmv.clm5_value,gmv.clm6_value,gmv.clm7_value,gmv.clm8_value,gmv.clm9_value,sdv1.code product_group
,sdv2.code region
,sdv3.code VAT_Code,sdv6.code VAT_GL_Account,spcd.curve_id curve,calc_id,entity

FROM generic_mapping_header gmh 
		INNER JOIN generic_mapping_values gmv 
		ON  gmh.mapping_table_id = gmv.mapping_table_id
		AND gmh.mapping_name = ''Non EFET VAT Rule Mapping'' 
		CROSS APPLY (
			SELECT civv.calc_id
				,civv.as_of_date
				,civv.counterparty_id
				,civv.contract_id
				,civv.prod_date
				,civv.finalized
				,civ.invoice_line_item_id
				,sdv_civ.code
				,cg.contract_charge_type_id
			FROM calc_invoice_volume_variance civv 
				INNER JOIN #calc_id ci ON ci.calc_id = civv.calc_id
				INNER JOIN calc_invoice_volume civ ON civ.calc_id = civv.calc_id
				INNER JOIN static_data_value sdv_civ ON sdv_civ.value_id = civ.invoice_line_item_id 
				INNER JOIN static_data_type sdt_civ ON sdt_civ.type_id = sdv_civ.type_id AND sdt_civ.type_name = ''Contract Components''
				INNER JOIN contract_group cg  ON cg.contract_id = civv.contract_id
				INNER JOIN source_counterparty sc ON sc.source_counterparty_id = civv.counterparty_id 
				INNER JOIN counterparty_contacts cc ON cc.counterparty_id = sc.source_counterparty_id
			AND is_primary = ''y''
				
			WHERE code LIKE ''%VAT%''    AND civv.netting_calc_id  IS NULL
				
			) a ' + CASE WHEN @template_id IS NULL THEN  
		  ' LEFT  JOIN contract_group_detail cgd   ON CAST(cgd.alias  AS VARCHAR(250))= CAST(gmv.clm1_value  as VARCHAR(250)) AND a.invoice_line_item_id = cgd.invoice_line_item_id AND cgd.contract_id = a.contract_id ' ELSE 
		'LEFT JOIN contract_charge_type_detail cctd ON cctd.contract_charge_type_id =  a.contract_charge_type_id AND  cctd.invoice_line_item_id  = a.invoice_line_item_id AND cctd.alias = gmv.clm1_value ' END +  
		 ' LEFT JOIN #sap_gl_mapping_invoicing sg ON sg.contract_id = a.contract_id  AND CAST(gmv.clm3_value as VARCHAR(250)) = CASE WHEN  sg.[Entrepot-number] = ''Yes'' THEN ''y'' ELSE ''n'' END 
		AND gmv.clm4_value = CASE WHEN sg.ic = ''Yes'' THEN ''y'' ELSE ''n'' END AND sg.region_id = gmv.clm2_value
		INNER JOIN static_data_value sdv1 ON CAST(sdv1.value_id AS VARCHAR(25))=  CAST(gmv.clm1_value AS VARCHAR(25))
		INNER JOIN static_data_type sdt1 ON sdt1.type_id = sdv1.type_id AND sdt1.type_name = ''Contract Charge Type Group''
		INNER JOIN static_data_value sdv2 ON sdv2.value_id =  CAST(gmv.clm2_value AS VARCHAR(250))
		INNER JOIN static_data_type sdt2 ON sdt2.type_id = sdv2.type_id AND sdt2.type_name = ''Region''    
		INNER JOIN static_data_value sdv3 ON sdv3.value_id =  CAST(gmv.clm6_value AS VARCHAR(250))
		INNER JOIN static_data_type sdt3 ON sdt3.type_id = sdv3.type_id  AND sdt3.type_name = ''VAT Code''                                                                                                           
         INNER JOIN static_data_value sdv4 ON sdv4.value_id =  CAST(gmv.clm7_value AS VARCHAR(250))
		INNER JOIN static_data_type sdt4 ON sdt4.type_id = sdv4.type_id  --AND sdt4.type_name = ''GL Account''                                                                                                           
              INNER JOIN static_data_value sdv6 ON sdv6.value_id =  CAST(gmv.clm7_value AS VARCHAR(250))
		INNER JOIN static_data_type sdt6 ON sdt6.type_id = sdv6.type_id  --AND sdt6.type_name = ''GL Account''
	 --    INNER JOIN static_data_value sdv5 ON sdv5.value_id =  CAST(gmv.clm9_value AS VARCHAR(250))
		--INNER JOIN static_data_type sdt5 ON sdt5.type_id = sdv5.type_id   AND sdt5.type_name = ''GL Account''                                                                                  
		INNER JOIN source_price_curve_def spcd ON  CAST(spcd.source_curve_def_id AS VARCHAR(250)) =  CAST(gmv.clm5_value AS VARCHAR(250)) 
		WHERE CAST(' +CASE WHEN @template_id IS NULL THEN 'cgd' ELSE 'cctd' END +'.invoice_line_item_id AS VARCHAR(100)) IS NOT NULL  ' + 'AND sg.mapping_table_id is NOT NULL AND '+
		CASE WHEN @template_id IS NULL THEN 'cgd' ELSE 'cctd' END + '.invoice_line_item_id NOT IN (SELECT DISTINCT invoice_line_item_id  FROM #sap_gl_mapping_invoicing ) '

EXEC(@sql)
 



/* 
 SELECT Distinct generic_mapping_values_id,cgd.invoice_line_item_id,cgd.alias,gmv.clm1_value,gmv.clm2_value,gmv.clm3_value,gmv.clm4_value,gmv.clm5_value,gmv.clm6_value,gmv.clm7_value,gmv.clm8_value,gmv.clm9_value,sdv1.code product_group
,sdv2.code region
,sdv3.code VAT_Code,sdv6.code VAT_GL_Account,spcd.curve_id curve,calc_id,entity
SELECT * 
FROM generic_mapping_header gmh 
		INNER JOIN generic_mapping_values gmv 
		ON  gmh.mapping_table_id = gmv.mapping_table_id
		AND gmh.mapping_name = 'Non EFET VAT Rule Mapping' 
		CROSS APPLY (
			SELECT civv.calc_id
				,civv.as_of_date
				,civv.counterparty_id
				,civv.contract_id
				,civv.prod_date
				,civv.finalized
				,civ.invoice_line_item_id
				,sdv_civ.code
				,cg.contract_charge_type_id
			FROM calc_invoice_volume_variance civv 
				INNER JOIN #calc_id ci ON ci.calc_id = civv.calc_id
				INNER JOIN calc_invoice_volume civ ON civ.calc_id = civv.calc_id
				INNER JOIN static_data_value sdv_civ ON sdv_civ.value_id = civ.invoice_line_item_id 
				INNER JOIN static_data_type sdt_civ ON sdt_civ.type_id = sdv_civ.type_id AND sdt_civ.type_name = 'Contract Components'
				INNER JOIN contract_group cg  ON cg.contract_id = civv.contract_id
				INNER JOIN source_counterparty sc ON Sc.source_counterparty_id = civv.counterparty_id 
				
			WHERE code LIKE '%VAT%'    AND civv.netting_calc_id  IS NULL
				
			) a
			INNER JOIN generic_mapping_values gmv1 ON gmv1.
			
			
			
			
			
			  LEFT  JOIN contract_group_detail cgd   ON CAST(cgd.alias  AS VARCHAR(250))= CAST(gmv.clm1_value  as VARCHAR(250)) AND a.invoice_line_item_id = cgd.invoice_line_item_id AND cgd.contract_id = a.contract_id  LEFT JOIN #sap_gl_mapping_invoicing sg ON sg.contract_id = a.contract_id  AND CAST(gmv.clm3_value as VARCHAR(250)) = CASE WHEN  sg.[Entrepot-number] = 'Yes' THEN 'y' ELSE 'n' END 
		AND gmv.clm4_value = CASE WHEN sg.ic = 'Yes' THEN 'y' ELSE 'n' END AND sg.region_id = gmv.clm2_value
		INNER JOIN static_data_value sdv1 ON CAST(sdv1.value_id AS VARCHAR(25))=  CAST(gmv.clm1_value AS VARCHAR(25))
		INNER JOIN static_data_type sdt1 ON sdt1.type_id = sdv1.type_id AND sdt1.type_name = 'Contract Charge Type Group'
		INNER JOIN static_data_value sdv2 ON sdv2.value_id =  CAST(gmv.clm2_value AS VARCHAR(250))
		INNER JOIN static_data_type sdt2 ON sdt2.type_id = sdv2.type_id AND sdt2.type_name = 'Region'    
		INNER JOIN static_data_value sdv3 ON sdv3.value_id =  CAST(gmv.clm6_value AS VARCHAR(250))
		INNER JOIN static_data_type sdt3 ON sdt3.type_id = sdv3.type_id  AND sdt3.type_name = 'VAT Code'                                                                                                           
         INNER JOIN static_data_value sdv4 ON sdv4.value_id =  CAST(gmv.clm7_value AS VARCHAR(250))
		INNER JOIN static_data_type sdt4 ON sdt4.type_id = sdv4.type_id  --AND sdt4.type_name = 'GL Account'                                                                                                           
              INNER JOIN static_data_value sdv6 ON sdv6.value_id =  CAST(gmv.clm7_value AS VARCHAR(250))
		INNER JOIN static_data_type sdt6 ON sdt6.type_id = sdv6.type_id  --AND sdt6.type_name = 'GL Account'
	 --    INNER JOIN static_data_value sdv5 ON sdv5.value_id =  CAST(gmv.clm9_value AS VARCHAR(250))
		--INNER JOIN static_data_type sdt5 ON sdt5.type_id = sdv5.type_id   AND sdt5.type_name = 'GL Account'                                                                                  
		INNER JOIN source_price_curve_def spcd ON  CAST(spcd.source_curve_def_id AS VARCHAR(250)) =  CAST(gmv.clm5_value AS VARCHAR(250)) 
		WHERE cgd.invoice_line_item_id IS NOT NULL  AND sg.mapping_table_id is NOT NULL AND cgd.invoice_line_item_id NOT IN (SELECT DISTINCT invoice_line_item_id  FROM #sap_gl_mapping_invoicing ) 

 
 
 RETURN
 */
 

DECLARE @invoice_num INT 

SELECT @invoice_num = count(entity)
FROM #sap_tax_mapping
WHERE entity = 'retail'
GROUP BY invoice_line_item_id
 
IF EXISTS (
		SELECT 1
		FROM #sap_gl_mapping_invoicing
		WHERE double_booking = 'yes'
			AND @invoice_num = 0
		)
 BEGIN 
	 INSERT INTO #sap_tax_mapping
		SELECT generic_mapping_values_id
		,invoice_line_item_id
		,alias
		,clm1_value
		,clm2_value
		,clm3_value
		,clm4_value
		,clm5_value
		,clm6_value
		,clm7_value
		,clm8_value
		,clm9_value
		,product_group
		,region
		,VAT_Code
		,VAT_GL_Account
		,curve
		,calc_id
		,'Retail'
	FROM #sap_tax_mapping
	WHERE entity = 'EET'
END


 SELECT DISTINCT stm.* INTO #sap_tax_mapping1 
 FROM #sap_tax_mapping stm inner join #sap_gl_mapping_invoicing s ON s.doc_type = stm.clm8_value AnD s.product_group = stm.product_group

INSERT INTO #sap_export_data
	SELECT sc2.source_counterparty_id
		,MAX(sgma.entity_code)
		,MAX(sgma.doc_type)
		,civv.settlement_date
		,YEAR(GETDATE()) [Year]
		,sc.currency_id
		,CASE WHEN MAX(civv.invoice_type) = 'i' THEN 'Sell ' ELSE 'Buy ' END [Buy/sell-h]-- + CAST(MONTH(CAST(civv.prod_date AS VARCHAR(100))) AS VARCHAR(200)) + '-' + CAST(YEAR(CAST(civv.prod_date AS VARCHAR(100))) AS VARCHAR(200)) 
		,civv.invoice_number
		,''
		,''
		,MAX(ISNULL(su1.uom_desc,su1.uom_name))
		,cast(YEAR(civ.prod_date) AS VARCHAR) + RIGHT('0' + CAST(month(civ.prod_date) AS VARCHAR), 2) delivery_period
		,
		--detail
		/*sequence number grouped by Buy/Sell*/
		/*sequence group by BSCHL,SHKZG,BURKS,FILLER,HKONT,KOSTL*/
		CASE 
			WHEN sum(cfv.value) > 0
				THEN 50
			ELSE 40
			END [Buy/sell-d]
		,''
		,2120
		,''
		,cea.external_value
		,cea2.external_value AS payable_id
		,gsm.gl_account_number [Gl account vat]
		,gsm2.gl_account_number [Gl account]
		,CASE 
			WHEN DATEDIFF(yy, civv.settlement_date, civ.prod_date) < 0
				THEN MAX(sgma.Last_Year_Cost_Center)
			ELSE MAX(sgma.current_year_cost_center)
			END [Cost encoding]
		,''
		,''
		,''
		,ROUND(sum(civ.value), 2) [Value-D]
		,COALESCE(civ.invoice_line_item_id, sgma.invoice_line_item_id, stm.invoice_line_item_id)
		,sdv_clm6_value.code [VAT code]
		,''
		,''
		,
		-- sc2.counterparty_name + ' ' + sb_3.source_book_name 
		cea.external_value [counterparty/country]
		,sc2.counterparty_name + ' ' + ISNULL(sgma.products,'')[PNL/BUYSELL]--+  ' ' + CAST(MONTH(CAST(civv.prod_date AS VARCHAR(100))) AS VARCHAR(200))  -- + '-' + CAST(YEAR(CAST(civv.prod_date AS VARCHAR(100))) AS VARCHAR(200)) [PNL/BUYSELL] --+ gmv2.clm7_value + ' ' + cg.contract_name +
		,sc2.counterparty_name 
		+ ' ' + 
		ISNULL(products,'')
		+ ' ' + 
		CAST(MONTH(CAST(civ.prod_date AS VARCHAR(100))) AS VARCHAR(200))  
		+ '-' + 
		CAST(YEAR(CAST(civ.prod_date AS VARCHAR(100))) AS VARCHAR(200)) [counterparty_pnl_buysell]
		,sdv_clm12_value.[description]
		,CASE 
			WHEN sgma.invoice_line_item_id = 293317
				THEN 0
			ELSE ROUND(sum(civ.Volume), 3)
			END AS Volume
		,
		-- summary
		/*sequence number grouped by Buy/Sell*/
		max(cbi.reference) [bank_id]
		,max(cbi1.reference) [partner_bank_id]
		,0
		
		,CONVERT(DATETIME,ISNULL(dbo.FNADateFormat(civv.payment_date), dbo.FNADateFormat(dbo.FNAInvoiceDueDate( CASE WHEN cg.invoice_due_date = '20023'  OR cg.invoice_due_date = '20024' THEN civv.finalized_date ELSE civv.prod_date END, cg.invoice_due_date, cg.holiday_calendar_id, cg.payment_days))),120) [invoice_date]
		,civv.as_of_date
		,cg.contract_id
		,CASE 
			WHEN DATEDIFF(yy, civv.settlement_date, civ.prod_date) < 0
				THEN MAX(sgma.Last_Year_General_Ledger)
			ELSE MAX(sgma.current_year_general_ledger)
			END Current_Year_General_Ledger
		,CASE 
			WHEN DATEDIFF(yy, civv.settlement_date, civ.prod_date) < 0
				THEN sgma.Last_Year_Cost_Center
			ELSE sgma.current_year_cost_center
			END current_year_cost_center
		,MAX(sgma.region)
		,MAX(sgma.contract_name)
		,MAX(iSNULL(sgma.VAT_Code,stm.VAT_gl_Account)) TaxCode
		,CASE 
			WHEN DATEDIFF(yy, civv.settlement_date, civ.prod_date) < 0
				THEN sgma.Last_Year_Profit_Center
			ELSE sgma.Current_Year_Profit_Center
			END Current_Year_Profit_Center
		,
	
		pat.PartnerID [PartnerID]
		,Last_Year_General_Ledger
		,--ISNULL(sgma.entity,'EET')
		Coalesce(sgma.entity, stm.entity, 'EET') entity
		,ISNULL(sgma.product_group, stm.product_group)
		,stm.VAT_gl_Account Tax_buy
		,ISNULL(stm.VAT_code, sgma.[VAT_Code]) tax_code_buy
		,stm.VAT_GL_Account Tax_sale
		, 
			--CASE 
			--	WHEN sgma.clm5_value = sgma.source_counterparty_id
			--		THEN ISNULL(sgma.VAT_Code,stm.VAT_CODE)
			--	ELSE   ISNULL(sgma.VAT_Code,stm.vat_code)
			--	END 
				ISNULL(sgma.VAT_Code,stm.vat_code) tax_code_sale
		,civv.calc_id
		,ISNULL(MAX(sgma.double_booking), 'Yes')
		,sc2.int_ext_flag
		,ic_with_fiscal
		,ISNULL(cg.self_billing, 'n') self_billing	

 FROM   calc_invoice_volume_variance civv 
		INNER JOIN #counterparty c
						 ON c.item  = civv.counterparty_id
				INNER JOIN #contract c1 ON c1.item = civv.contract_id
				--AND civv.calc_id = @calc_id
				INNER JOIN #calc_id ci ON ci.calc_id = civv.calc_id
       INNER JOIN #civv1 civv1
            ON  civv.as_of_date = civv1.as_of_date
            AND civv.prod_date = civv1.prod_date
            AND civv.settlement_date = civv1.settlement_date
            AND civv.counterparty_id = civv1.counterparty_id
            AND civv.contract_id = civv1.contract_id
       INNER JOIN calc_invoice_volume civ
            ON  civv.calc_id = civ.calc_id
		LEFT JOIN calc_formula_value cfv
            ON  cfv.calc_id = civv.calc_id
            AND cfv.invoice_line_item_id = civ.invoice_line_item_id
			And Source_deal_header_id IS NOT NULL
       LEFT JOIN source_deal_detail sdd
            ON  sdd.source_deal_detail_id = cfv.deal_id
       LEFT JOIN source_deal_header sdh
            ON  sdh.source_deal_header_id = ISNULL(sdd.source_deal_header_id, cfv.source_deal_header_id)	
       OUTER APPLY(
		SELECT MAX(fixed_price_currency_id) fixed_price_currency_id
		FROM   source_deal_detail
		WHERE  source_deal_header_id = sdh.source_deal_header_id
	) sdd1 	 
	LEFT JOIN source_system_book_map ssbm
            ON  ssbm.source_system_book_id1 = sdh.source_system_book_id1
            AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
            AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
            AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
       LEFT JOIN source_book sb
            ON  sb.source_book_id = ssbm.fas_book_id
	   LEFT JOIN contract_group cg
            ON  CAST(c1.item AS VARCHAR(100)) = cg.contract_id	
       LEFT JOIN source_currency sc
            ON  ISNULL(cg.currency, sdd1.fixed_price_currency_id) = 
                sc.source_currency_id

       LEFT JOIN source_commodity sc1
            ON  CAST(sdh.commodity_id AS VARCHAR(100)) = sc1.source_commodity_id
      
	
       INNER JOIN source_counterparty sc2
            ON  c.item = sc2.source_counterparty_id
			
       LEFT  JOIN counterparty_epa_account cea
            ON  sc2.source_counterparty_id = cea.counterparty_id
            AND cea.external_type_id = @external_type_id2
       LEFT JOIN static_data_value country_sdv
            ON  sc2.country = country_sdv .value_id
       LEFT JOIN generic_mapping_header gmh
            ON  gmh.mapping_name = 'Non EFET VAT Rule Mapping'
       LEFT JOIN generic_mapping_header gmh2
            ON  gmh2.mapping_name = 'Non EFET SAP GL Mapping'
       LEFT JOIN generic_mapping_definition gmd
            ON  gmd.mapping_table_id = gmh.mapping_table_id
       LEFT JOIN generic_mapping_definition gmd2
            ON  gmd2.mapping_table_id = gmh2.mapping_table_id
       LEFT  JOIN counterparty_epa_account cea1
            ON  sc2.source_counterparty_id = cea1.counterparty_id
            AND cea1.external_type_id = @external_type_id1
	  LEFT JOIN fas_subsidiaries fs ON fs.fas_subsidiary_id = cg.sub_id		
	   LEFT JOIN counterparty_epa_account cea2 ON sc2.source_counterparty_id = cea2.counterparty_id
           AND cea2.external_type_id = @external_type_id
       LEFT JOIN generic_mapping_values gmv
            ON  gmv.mapping_table_id = gmh.mapping_table_id
            AND gmv.clm1_value = CAST(ssbm.source_system_book_id2 AS VARCHAR(100))
            AND gmv.clm2_value = CAST(ssbm.source_system_book_id3 AS VARCHAR(100))
            AND gmv.clm3_value = CAST(sc2.region AS VARCHAR(100))
            AND gmv.clm4_value = CASE  WHEN cea1.external_value IS NULL THEN 'n' ELSE 'y' END
       LEFT JOIN generic_mapping_values gmv2
            ON  gmv2.mapping_table_id = gmh2.mapping_table_id
            AND gmv2.clm1_value = CAST(ssbm.source_system_book_id1 AS VARCHAR(100))
            AND gmv2.clm2_value = CAST(ssbm.source_system_book_id2 AS VARCHAR(100))
            AND gmv2.clm3_value = CAST(ssbm.source_system_book_id3 AS VARCHAR(100))
            AND gmv2.clm4_value = CAST(sdh.contract_id AS VARCHAR(100))
            AND gmv2.clm5_value = CAST(sc.source_currency_id AS VARCHAR(100))
            AND gmv2.clm6_value =  's'--(CASE WHEN cfv.value > 0 THEN 's' ELSE 'b' END)
		--
       LEFT JOIN gl_system_mapping gsm2
            ON  CAST(gsm2.gl_number_id AS VARCHAR(100)) = gmv2.clm9_value
       LEFT JOIN gl_system_mapping gsm
            ON  CAST(gsm.gl_number_id AS VARCHAR(100)) = gmv.clm7_value
       LEFT JOIN static_data_value sdv_clm11_value
            ON  CAST(sdv_clm11_value.value_id AS VARCHAR(100)) = gmv2.clm11_value
       LEFT JOIN static_data_value sdv_clm6_value
            ON  CAST(sdv_clm6_value.value_id AS VARCHAR(100)) = gmv.clm6_value
       LEFT JOIN static_data_value sdv_clm12_value
            ON  CAST(sdv_clm12_value.value_id AS VARCHAR(100)) = gmv2.clm12_value
       LEFT JOIN source_book sb_3
            ON  sb_3.source_book_id = sdh.source_system_book_id3
	   LEFT JOIN source_book sb_2
            ON  sb_2.source_book_id = sdh.source_system_book_id2
	  LEFT JOIN counterparty_bank_info cbi ON cbi.counterparty_id =fs.counterparty_id
			 AND    cbi.currency = cg.currency
	-- LEFT JOIN  fas_subsidiaries fs  ON fs.fas_subsidiary_id = cg.sub_id
	LEFT JOIN source_counterparty sc3 ON sc2.source_counterparty_id = sc3.source_counterparty_id 
		
	 LEFT JOIN counterparty_bank_info cbi1  ON sc3.source_counterparty_id = cbi1.counterparty_id
		AND    cbi1.currency = cg.currency
	LEFT JOIN source_uom su1 on su1.source_uom_id = ISNULL(civ.uom_id,cg.volume_uom)
	 left JOIN #sap_gl_mapping_invoicing sgma ON sgma.source_counterparty_id = c.item AND sgma.contract_id = c1.item   AND civ.invoice_line_item_id = sgma.invoice_line_item_id
	 LEFT JOIN #sap_tax_mapping1 stm ON stm.invoice_line_item_id =  civ.invoice_line_item_id --AND sgma.doc_type = stm.clm8_value
	 CROSS APPLY (SELECT CASE WHEN sc2.int_ext_flag  = 'i' AND ISNULL(@double_booking,'n') = 'y' THEN  MAX(entity_code) ELSE MAX(entity_code_cpty) END  as PartnerID FROM #sap_gl_mapping_invoicing a WHERE   a.ENTITY = CASE WHEN sc2.int_ext_flag  = 'i' AND ISNULL(@double_booking,'n') = 'y' THEN CASE WHEN  sgma.ENTITY = 'EET' THEN 'RETAIL' ELSE 'EET' END ELSE a.ENTITY END-- WHERE ENTITY <>  ISNULL(sgma.ENTITY,stm.entity) 
	 ) pat
	WHERE civv.invoice_type = 'i' --AND cfv.is_final_result = 'y'
		AND (
			ISNULL(civv.finalized, 'n') = CASE 
				WHEN @flag = 's' 
					THEN 'y'
				ELSE 'n'
				END
			OR ISNULL(civ.STATUS, 'n') = CASE 
				WHEN @flag = 's'
					THEN 'v'
				ELSE 'n'
				END
			)
		AND civv.settlement_date = @invoice_date
		AND civv.as_of_date = @as_of_date
		AND ISNULL(sgma.Entity, 'EET') IN (
			'EET'
			,CASE 
				WHEN Double_booking = 'YES'
					THEN 'Retail'
				ELSE ''
				END
			)
		AND civv.netting_calc_id IS NULL
		AND civ.invoice_line_item_id  NOT IN (SELECT  value_id FROM #VAT1)	
	GROUP BY civv.prod_date
		,civ.prod_date
		,stm.invoice_line_item_id
		,civv.calc_id
		,sc.currency_id
		,Last_Year_General_Ledger
		,civv.invoice_type
		,--sgma.product_group,
		sc2.counterparty_name
		,country_sdv.code
		,cg.contract_name
		,gmv2.clm7_value
		,sdv_clm11_value.code
		,gsm.gl_account_number
		,sdv_clm12_value.[description]
		,sb_3.source_book_name
		,civv.settlement_date
		,civv.invoice_number
		,sdv_clm6_value.code
		,cea.external_value
		,gmv2.clm7_value
		,sgma.[VAT_Code]
		,gsm2.gl_account_number
		,sgma.invoice_line_item_id
		,sb_2.source_book_name
		,stm.product_group
		,cea2.external_value
		,sgma.product_group
		,[current_year_cost_center]
		,sc2.source_counterparty_id
		,civv.as_of_date
		,cg.contract_id
		,sgma.entity
		,civv.finalized_date
		,stm.VAT_GL_Account
		,stm.VAT_code
		,civ.invoice_line_item_id
		,stm.entity
		,sgma.Last_Year_Cost_Center
		,sgma.current_year_cost_center
		,sgma.Last_Year_Profit_Center
		,sgma.Current_Year_Profit_Center
		,civv.payment_date
		,cg.invoice_due_date
		,cg.holiday_calendar_id
		,cg.payment_days	
		 ,products
		,sgma.clm5_value ,sgma.source_counterparty_id,sgma.VAT_Code,cg.self_billing,ic_with_fiscal,sc2.int_ext_flag,pat.PartnerID
		
		
		
DECLARE @payable_id VARCHAR(250)

SELECT @payable_id = external_value
FROM fas_subsidiaries fs
INNER JOIN counterparty_epa_account cea ON fs.counterparty_id = cea.counterparty_id
WHERE fas_subsidiary_id = - 1
	AND cea.external_type_id = @external_type_id
	
	


INSERT INTO #temp_sap_detail (
	[column_1]
	,[column_2]
	,[column_3]
	,[column_4]
	,[column_5]
	,[column_6]
	,[column_7]
	,[column_8]
	,[column_9]
	,[column_10]
	,[column_11]
	,[column_12]
	,[column_13]
	,[column_14]
	,[column_15]
	,[Order_detail]
	,[Buy_sell_d]
	,invoice_number
	,line_item
	,Gl_account_vat
	,[Buy_sell_h]
	,row_type
	,source_counterparty_id
	,contract_id
	,PartnerID
	,[ProfitCenter]
	,[grouping]
	,entity_gas
	,product_group
	,calc_id
	,self_billing
	)
SELECT [column_1]
	,[column_2]
	,[column_3]
	,[column_4]
	,[column_5]
	,[column_6]
	,[column_7]
	,[column_8]
	,[column_9]
	,[column_10]
	,[column_11]
	,LEFT([column_12],50)
	,CAST([column_13] AS numeric(38,20))
	,[column_14]
	,[column_15]
	,[Order_detail]
	,[Buy_sell_d]
	,invoice_number
	,line_item
	,Gl_account_vat
	,[Buy_sell_h]
	,row_type
	,source_counterparty_id
	,contract_id
	,PartnerID
	,[ProfitCenter]
	,[grouping]
	,entity_gas
	,product_group
	,calc_id
	,self_billing
FROM
	(
	
	 SELECT 'I' [column_1]
		,'' [column_2]
		, CASE WHEN @double_booking = 'y' THEN 
			CASE WHEN entity_gas = 'EET'  AND self_billing  = 'n'
				THEN  MAX(counterparty_country)
				ELSE MAX(sed.[BLank])
			END
			ELSE  
				CASE WHEN self_billing  = 'n'
					THEN  MAX(counterparty_country)
				ELSE MAX(sed.[BLank]) END
			END 
			 [column_3]
		,
		CASE WHEN @double_booking = 'y' THEN 
				CASE 
				WHEN entity_gas = 'Retail'  AND self_billing  = 'n'  
					THEN  @payable_id
				ELSE MAX(sed.[BLank])
				END
			ELSE  
				CASE WHEN self_billing  = 'y'
					THEN MAX(payable_id)
				ELSE MAX(sed.[BLank]) END
			END 
		 [column_4]
		,MAX(replace(CONVERT(VARCHAR(10), sed.invoice_date, 102), '.', '-')) [column_5]
		,'' [column_6]
		,CAST(CASE 
				WHEN ISNULL(ENTITY_gas, 'EET') = 'EET'
					THEN 1
				ELSE - 1
				END * SUM(CAST(sed.[Value-D] AS NUMERIC(38, 2))) AS VARCHAR(200)) [column_7]
		,
		-- CAST(SUM(CAST(sed.[Value-D] AS NUMERIC(38, 2))) AS VARCHAR(200)) [column_7],
		'' [column_8]
		,'' [column_9]
		,MAX(sed.[bank_id]) [column_10]
		,--bank id
		MAX(sed.partner_bank_id) [column_11]
		,--partner
		--max(sed.[counterparty_pnl_buysell])
		max(Buy_sell_h) [column_12]
		,SUM(round(sed.Volume, 3)) [column_13]
		,MAX(sed.UOM) [column_14]
		,'' [column_15]--sed.delivery_period 
		,2 [Order_detail]
		,MAX(sed.[Buy_sell_d]) [Buy_sell_d]
		,MAX(sed.invoice_number) invoice_number
		,MAX(sed.line_item) line_item
		,MAX(sed.Gl_account_vat) Gl_account_vat
		,MAX(sed.[Buy_sell_h]) [Buy_sell_h]
		,'a' AS row_type
		,source_counterparty_id
		,contract_ID
		,CASE WHEN counterparty_type  = 'i' THEN MAX(PartnerID)   ELSE ''  END PartnerID
		,'' [ProfitCenter]
		,'commodity' [grouping]
		,ISNULL(entity_gas, 'EET') entity_gas
		,MAX(ISNULL(product_group, 'Commodity')) product_group
		,calc_id
		, self_billing
	FROM #sap_export_data sed
	GROUP BY sed.invoice_number
		,source_counterparty_id
		,contract_ID
		--,sed.delivery_period
		,calc_id
		,entity_gas,self_billing,ic_with_fiscal,counterparty_type,double_Booking
	UNION ALL
		SELECT 'I' [column_1]
		,--CAST(sed.current_year_general_ledger AS VARCHAR(100))
		CASE 
		WHEN CAST(LEFT(delivery_period, 4) AS INT) < YEAR(prod_date)
		THEN CASE 
				WHEN sed.line_item IN (
						SELECT value_id
						FROM #vat
						)
					THEN ISNULL(sed.last_year_general_ledger, tax)
				ELSE ISNULL(sed.last_year_general_ledger, tax)
				END
		ELSE CASE 
			WHEN sed.line_item IN (
					SELECT value_id
					FROM #vat
					)
				THEN ISNULL(sed.current_year_general_ledger, tax)
			ELSE ISNULL(sed.current_year_general_ledger, tax)
			END
		END [column_2]
		,sed.[Blank_3] [column_3]
		,sed.[Blank_4] [column_4]
		,sed.[Blank_5] [column_5]
		,CASE 
		WHEN line_item NOT IN (
			SELECT value_id
			FROM #vat
			)
		THEN sed.Cost_encoding
		ELSE ''
		END [column_6]
		,CAST(CASE 
		WHEN ISNULL(ENTITY_gas, 'EET') = 'EET'
			THEN 1
		ELSE - 1
		END * (CAST(sed.[Value-D] * - 1 AS NUMERIC(38, 2))) AS VARCHAR(200)) [column_7]
		,
		--CASE 
		--WHEN sed.line_item IN (
		--	SELECT value_id
		--	FROM #vat
		--	)
		--THEN sed.tax_code_sale
		--ELSE sed.tax_code_buy END
 CASE WHEN ISNULL(ic_with_fiscal,'y') = 'y' AND counterparty_type  = 'i' ANd double_Booking = 'yes' AND entity_gas = (CASE WHEN self_billing = 'y' THEN 'EET' ELSE  'Retail' END) THEN 'VV' ELSE sed.tax_code_sale END [column_8],
		sed.payable_id [column_9]
		,sed.Blank_6 [column_10]
		,sed.Blank_8 [column_11]
		,sed.[PNL_BUYSELL] [column_12]
		,ROUND(sed.Volume, 3) [column_13]
		,sed.UOM [column_14]
		,sed.delivery_period [column_15]
		,2 [Order_detail]
		,sed.[Buy_sell_d]
		,sed.invoice_number
		,sed.line_item line_item
		,sed.Gl_account_vat
		,sed.[Buy_sell_h]
		,'b' AS row_type
		,source_counterparty_id
		,contract_ID
		,CASE WHEN counterparty_type  = 'i' THEN sed.PartnerID  ELSE ''  END
		,current_year_profit_center [ProfitCenter]
		,CASE 
		WHEN line_item NOT IN (
			SELECT value_id
			FROM #vat
			)
		THEN 'withoutvat'
		ELSE 'withvat'
		END [grouping]
		,ISNULL(entity_gas, 'EET') entity_gas
		,ISNULL(product_group, 'Commodity') product_group
		,calc_id
		 ,self_billing
 	FROM #sap_export_data sed
       ) a
ORDER BY
       a.[Order_detail],
       a.invoice_number,calc_id,
       a.line_item DESC



	   

	INSERT INTO #header (
	[column_1]
	,[column_2]
	,[column_3]
	,[column_4]
	,[column_5]
	,[column_6]
	,[column_7]
	,[column_8]
	,[column_9]
	,[column_10]
	,[column_11]
	,[column_12]
	,[column_13]
	,[column_14]
	,[column_15]
	,[ORDER]
	,[distinct_value]
	,[invoice_number]
	,[row_type]
	,source_counterparty_id
	,contract_ID
	,PartnerID
	,[ProfitCenter]
	,entity_gas
	,calc_id
	)
	SELECT 'H' [column_1],
       CAST(MAX(sed.[2120_hardcode]) AS VARCHAR(50)) [column_2],
       MAX(CAST(sed.TA_hardcode AS VARCHAR(50))) [column_3],
       replace(CONVERT(VARCHAR(10), sed.prod_date, 102),'.', '-') [column_4],
       CAST(sed.[Year] AS VARCHAR(100)) [column_5],
      replace(CONVERT(VARCHAR(10), GETDATE(), 102),'.', '-') [column_6],
       CAST(MAX(sed.currency_id) AS VARCHAR(50)) [column_7],
      MAX(sed.[Buy_sell_h]) [column_8],
       sed.[invoice_number] [column_9],
       '' [column_10],
       '' [column_11],
       '' [column_12],
       NULL [column_13],
	   '' [column_14],
	   '' [column_15],
       1 [Order]
      , ROW_NUMBER() OVER(ORDER BY MAX(sed.[Buy_sell_h])) [distinct_value],
      sed.[invoice_number],
	  '' row_type,source_counterparty_id,
			  contract_ID,
			'' PartnerID,
			'' [ProfitCenter],
			ISNULL(entity_gas,'EET'),
		
	 calc_id
FROM   #sap_export_data sed WHERE ISNULL(line_item,'') NOT IN (SELECT value_id FROM #vat) AND  line_item NOT IN (SELECT value_Id FROM #delta)
--<> @vat  
GROUP BY
      sed.[invoice_number],
      -- --sed.TA_hardcode,
       sed.prod_date,
      
       sed.[Year],
    
	  source_counterparty_id,
				  contract_ID,
				 	  calc_id,ISNULL(entity_gas,'EET')
ORDER BY
       sed.[invoice_number] 
	 
	 
	 
INSERT INTO #detail (
	[column_1]
	,[column_2]
	,[column_3]
	,[column_4]
	,[column_5]
	,[column_6]
	,[column_7]
	,[column_8]
	,[column_9]
	,[column_10]
	,[column_11]
	,[column_12]
	,[column_13]
	,[column_14]
	,[column_15]
	,[ORDER]
	,[distinct_value]
	,[invoice_number]
	,[row_type]
	,source_counterparty_id
	,contract_ID
	,PartnerID
	,ProfitCenter
	,grouping
	,entity_gas
	,product_group
	,calc_id
	,self_billing
	)
 
SELECT 'I' [column_1],
   sap_union.[column_2],
  MAX(sap_union.[column_3]),
   sap_union.[column_4],
   sap_union.[column_5],
   sap_union.[column_6],
  CAST(SUM(CAST(sap_union.[column_7] AS numeric(38,2))) AS VARCHAR(200))[column_7],
   CASE WHEN sap_union.grouping ='withvat' THEN '' ELSE  sap_union.[column_8] END,
   sap_union.[column_9],
   CASE WHEN @contract_type = 'Standard' THEN sap_union.[column_10]ELSE '' END [column_10] ,
   sap_union.[column_11],
  sap_union.[column_12],
   SUM(CAST(CAST(sap_union.[column_13] as float) AS numeric(38,3))) [column_13],
   sap_union.[column_14],
   sap_union.[column_15],
   2 [Order]
   , h.[distinct_value], 
   sap_union.[invoice_number] ,
   sap_union.[row_type],h.source_counterparty_id,
				  h.contract_ID,sap_union.PartnerID,
			sap_union. [ProfitCenter],sap_union.[grouping],MAX(sap_union.entity_gas)entity_gas,MAX(sap_union.product_group)product_group,sap_union.calc_id,self_billing
 --INTO #detail
 --SELECT h.product_group,sap_union.product_group,* 
 FROM   #temp_sap_detail sap_union
  INNER JOIN  #header h ON h.[column_9]= sap_union.[invoice_number]
  AND h.source_counterparty_id = sap_union.source_counterparty_id
				AND h.contract_id = sap_union.contract_id
				AND h.entity_gas = sap_union.entity_gas 
				--AND h.product_group = sap_union.product_group
				AND sap_union.calc_id = h.calc_id
				
  GROUP BY 
	sap_union.[column_2],
	--sap_union.[column_3],
	sap_union.[column_4],
	sap_union.[column_5],
	sap_union.[column_6],
	sap_union.[column_8],
	sap_union.[column_9],
	sap_union.[column_10],
	sap_union.[column_11],
	sap_union.[column_12],
	sap_union.[column_14],
	sap_union.[column_15],	h.[distinct_value], 
	sap_union.[invoice_number] ,
	sap_union.[row_type],h.source_counterparty_id,
	h.contract_ID,sap_union.PartnerID,
	sap_union.ProfitCenter,sap_union.calc_id,
	sap_union.[grouping],self_billing--,sap_union.entity_gas,sap_union.product_group
	ORder by row_type
	 
	 
	 

	END
	ELSE 
	BEGIN
		PRINT 'Contract type not defined'
	END
END



	   
IF @flag = 'a'
BEGIN 
		--DECLARE @sql nvarchar(4000)
		SET @sql = 'SELECT  ' + char(10)
				+ '[column_1] [DOCUMENT_HEADER/KeyField], ' + char(10)
				+ '        [column_2] [COMP_CODE /AccountID], ' + char(10)
				+ '        [column_3] [DOC_TYPE/CustomerID], ' + char(10)
				+ '        [column_4] [DOC_DATE/VendorID], ' + char(10)
				+ '        [column_5] [FISC_YEAR/BaseLineDate], ' + char(10)
				+ '        [column_6] [PSTNG_DATE/CostCenter], ' + char(10)
				+ '        [column_7] [CURRENCY/Amount], ' + char(10)
				+ '        [column_8] [HEADER_TXT/TaxCode], ' + char(10)
				+ '        [column_9] [REF_DOC_NO/Allocation], ' + char(10)
				+ '        [column_10] [REASON_REV/BankID], ' + char(10)
				+ '        [column_11] [EXTENSION1-FIELD1/PartnerBankType], ' + char(10)
				+ '        [column_12] [Text], ' + char(10)
				+ '       [column_13] [Quantity], ' + char(10)
				+ '        CASE WHEN LEN([column_14]) > 3 THEN '''' ELSE [column_14] END [Base Unit of Measure], ' + CHAR(10)    
				+ '        [column_15] [SettlementPeriod]' + char(10)        
				+ @str_batch_table + char(10)
				+ 'FROM ( ' + char(10)
				+ '   SELECT  * FROM #header  ' + char(10)
				+ '   UNION ALL  ' + char(10)
				+ '   SELECT * FROM #detail ' + char(10)
				+ ') a ' + char(10)
				+ 'ORDER BY a.[distinct_value], [column_1]'

	EXEC(@sql)
END 	
ELSE IF @flag = 's' OR @flag = 'z'
BEGIN 

	SET @sql = 'SELECT  ' + char(10)
			 + '[column_1] [DOCUMENT_HEADER/KeyField], ' + char(10)
			 + '        [column_2] [COMP_CODE /AccountID], ' + char(10)
			 + '        [column_3] [DOC_TYPE/CustomerID], ' + char(10)
			 + '        [column_4] [DOC_DATE/VendorID], ' + char(10)
			 + '        [column_5] [FISC_YEAR/BaseLineDate], ' + char(10)
			 + '        [column_6] [PSTNG_DATE/CostCenter], ' + char(10)
			 + '        [column_7] [CURRENCY/Amount], ' + char(10)
			 + '        [column_8] [HEADER_TXT/TaxCode], ' + char(10)
			 + '        [column_9] [REF_DOC_NO/Allocation], ' + char(10)
			 + '        [column_10] [REASON_REV/BankID], ' + char(10)
			 + '        [column_11] [EXTENSION1-FIELD1/PartnerBankType], ' + char(10)
			 + '        [column_12] [Text], ' + char(10)
			 + '        ABS([column_13]) [Quantity], ' + char(10)
			 + '        CASE WHEN LEN([column_14]) > 3 THEN '''' ELSE [column_14] END [Base Unit of Measure], ' + CHAR(10)    
			 + '        [column_15] [SettlementPeriod],' + char(10)        
			 + '        [row_type] [row_type],[process_id],a.[distinct_value],source_counterparty_id,
				  contract_ID ,PartnerID,[ProfitCenter],calc_id,grouping,entity_gas,self_billing'
				  --+ CAST(ISNULL(@calc_id,0) AS VARCHAR(10)) +
				  --'calc_id '
				  + char(10)        
			 + @str_batch_table + char(10)
			 + ' INTO '+char(10)+@process_table +char(10)+'FROM ( ' + char(10)
			 + '   SELECT  [column_1], 
							[column_2], 
							[column_3], 
							[column_4], 
							[column_5], 
							[column_6], 
							[column_7], 
							[column_8], 
							[column_9], 
							[column_10], 
							[column_11], 
							[column_12], 
							CAST([column_13] as numeric(38,3)) [column_13], 
							[column_14], 
							[column_15], '+''''+@process_id+''''+'[process_id],[distinct_value],row_type,source_counterparty_id,
											  contract_ID,' +  CASE WHEN @contract_type = 'Non-Standard' THEN  'PartnerID,[ProfitCenter] ' ELSE '''''PartnerID,''''[ProfitCenter] ' END 
				  + ',calc_id,''''grouping,entity_gas,'''' self_billing FROM #header  ' + char(10)
										 + '   UNION ALL  ' + char(10)
										 + '   SELECT  [column_1], 
							[column_2], 
							[column_3], 
							[column_4], 
							[column_5], 
							[column_6], 
							[column_7], 
							[column_8], 
							[column_9], 
							[column_10], 
							[column_11], 
							[column_12], 
							CAST(CAST([column_13] as float) as numeric(38,3)) [column_13], 
							[column_14], 
							[column_15],'+''''+@process_id+''''+'[process_id],[distinct_value],row_type,source_counterparty_id,
											  contract_ID,'+  CASE WHEN @contract_type = 'Non-Standard' THEN  'PartnerID,[ProfitCenter] ' ELSE '''''PartnerID,''''[ProfitCenter] ' END 
				  +  ',calc_id,grouping,entity_gas,self_billing FROM #detail ' + char(10)
										 + ') a ' + char(10)
										 + 'ORDER BY a.[distinct_value], [column_1]'
							--PRINT(@sql)
							EXEC(@sql)
							
			IF @flag = 's' --OR @flag ='z'
					BEGIN	
						EXEC('SELECT [DOCUMENT_HEADER/KeyField],
									[COMP_CODE /AccountID], 
									[DOC_TYPE/CustomerID], 
									[DOC_DATE/VendorID], 
									[FISC_YEAR/BaseLineDate], 
									[PSTNG_DATE/CostCenter], 
									[CURRENCY/Amount], 
									[HEADER_TXT/TaxCode], 
									[REF_DOC_NO/Allocation], 
									[REASON_REV/BankID], 
									[EXTENSION1-FIELD1/PartnerBankType], 
									[Text], 
									CAST([Quantity] as Float), 
									[Base Unit of Measure], 
									[SettlementPeriod],
									[row_type],
									[Process_id],partnerID,profitCenter,source_counterparty_id,
								  contract_ID
									 FROM '+@process_table +
									 ' Order by distinct_value,[DOCUMENT_HEADER/KeyField] '
									 )
					END
					
END
ELSE IF @flag = 'p'
BEGIN 
	CREATE TABLE #validate (message VARCHAR(100) COLLATE DATABASE_DEFAULT)
	EXEC('IF EXISTS(SELECT 1 FROM ' + @process_table + ' where row_type = ''a'' AND [DOC_TYPE/CustomerID] IS NULL )  --OR [REASON_REV/BankID] IS NULL OR [EXTENSION1-FIELD1/PartnerBankType] IS NULL
			OR  EXISTS(SELECT 1 FROM ' + @process_table + ' where row_type = ''b'' AND [COMP_CODE /AccountID] IS NULL OR [PSTNG_Date/CostCenter] IS NULL OR [Header_Txt/TaxCode] IS NULL 
				OR [REF_DOC_NO/Allocation] IS NULL OR [Text] IS NULL AND grouping <> ''Commodity''
)
				BEGIN
				INSERT #validate(message)
				SELECT ''Required fields are not filled. Please check exception report for more details.'' as message
				END
				ELSE 
				BEGIN
				INSERT #validate(message)
				SELECT ''true'' as message
				END
				')


	
			SELECT @validate = message FROM #validate 
			IF @validate = 'true'
			BEGIN
				SET @query = ''
				SET @query = '
					
						INSERT INTO settlement_export(counterparty_id, contract_id, as_of_date, invoice_date, type,document_header , comp_code,doc_type,doc_date,fisc_year,pstng_date,currency,header_txt,ref_doc_no,reason_rev,extension_field,text,quantity,base_unit_of_measure,settlement_period,distinct_value,row_type)
						SELECT   c.item,c1.item,'
								 +''''+cast(ISNULL(@as_of_date,GETDATE()) AS VARCHAR)+''''+','
								 +''''+cast(ISNULL(@invoice_date,GETDATE())  AS VARCHAR)+''''+',
								 ''f'',
								[DOCUMENT_HEADER/KeyField],
								[COMP_CODE /AccountID], 
								[DOC_TYPE/CustomerID], 
								[DOC_DATE/VendorID], 
								[FISC_YEAR/BaseLineDate], 
								[PSTNG_DATE/CostCenter], 
								[CURRENCY/Amount], 
								[HEADER_TXT/TaxCode], 
								[REF_DOC_NO/Allocation], 
								[REASON_REV/BankID], 
								[EXTENSION1-FIELD1/PartnerBankType], 
								[Text], 
								[Quantity], 
								[Base Unit of Measure], 
								[SettlementPeriod],
								distinct_value,row_type
						FROM   '+ @process_table  + ' a INNER JOIN #counterparty c ON c.item = a.source_counterparty_id INNER JOIN #contract c1 on c1.item = a.contract_id 
					
			'
			--Select * FROM settlement_export

			EXEC(@query)

	END
		SELECT @validate as Message
END 
ELSE IF @flag = 'b' 
BEGIN
	 EXEC('	SELECT  
			[DOCUMENT_HEADER/KeyField], 
			[COMP_CODE /AccountID], 
			[DOC_TYPE/CustomerID], 
			[DOC_DATE/VendorID], 
			[FISC_YEAR/BaseLineDate], 
			[PSTNG_DATE/CostCenter], 
			[CURRENCY/Amount], 
			[HEADER_TXT/TaxCode], 
			[REF_DOC_NO/Allocation], 
			 [REASON_REV/BankID], 
			 [EXTENSION1-FIELD1/PartnerBankType], 
			 [Text], 
			CAST(CAST(ABS([Quantity])  AS NUMERIC(38, 3)) AS VARCHAR(200))[Quantity],
			[Base Unit of Measure], 
			[SettlementPeriod],PartnerID,profitCenter  '+ @str_batch_table + ' FROM ' + @process_table + ' ORDER BY distinct_value,row_type')
			
	EXEC spa_register_event 20605, 20526, @process_table, 0, @process_id
END


 IF @flag = 'i' OR @flag = 'z'
	BEGIN
	 DECLARE @ct VARCHAR(300)

--	 DROP TABLE #contract_type
 CREATE TABLE #contract_type(contract_type VARCHAR(40) COLLATE DATABASE_DEFAULT)

 EXEC('INSERT INTO #contract_type(contract_type) 
 SELECT 
CASE WHEN MAX(ISNULL(standard_contract,''y'')) = ''y'' THEN ISNULL(sdv.code,''Standard'') ELSE ISNULL(sdv.code,''Non-Standard'') END  

FROM contract_group cg  
INNER JOIN Calc_invoice_Volume_variance civv ON civv.contract_id = cg.contract_id --AND civv.calc_id = @calc_id
INNER JOIN '+@process_table+' ci ON ci.calc_id = civv.calc_id
LEFT JOIN static_data_value sdv ON cg.contract_type_def_id = sdv.value_id
LEFT JOIN static_data_type sdt ON sdt.type_id = sdv.type_id  AND sdt.type_name = ''Contract Type''
GROUP BY sdv.code')

DECLARE @sql_code VARCHAR(MAX) 
 SELECT @ct = contract_type from #contract_type

 IF @ct = '_Standard' 
 BEGIN 
	EXEC('INSERT INTO #sap_export_exception_data (column_name,counter_party,contract_name,recomendation)
SELECT ''[DOC_TYPE/CustomerID]'',a.source_counterparty_id,a.contract_id,''Please setup missing data. Setup Counterparty >> External ID >> SAP Receivable ID'' FROM '+@process_table + ' a INNER JOIN #counterparty c ON c.item = a.source_counterparty_id INNER JOIN #contract c1 on c1.item = a.contract_id  WHERE [DOCUMENT_HEADER/KeyField]  = ''I'' AND row_type = ''a'' AND NULLIF([DOC_TYPE/CustomerID],'''') IS NULL 
UNION ALL
SELECT ''[REASON_REV/BankID]'',a.source_counterparty_id,a.contract_id,''Please setup missing data. Setup Counterparty >> Payment Info >> Counterparty Bank Info >> Reference'' FROM '+@process_table + ' a INNER JOIN #counterparty c ON c.item = a.source_counterparty_id INNER JOIN #contract c1 on c1.item = a.contract_id  WHERE [DOCUMENT_HEADER/KeyField]  = ''I'' AND row_type = ''a'' AND NULLIF([REASON_REV/BankID],'''') IS NULL 
UNION ALL
SELECT ''[EXTENSION1-FIELD1/PartnerBankType]'',a.source_counterparty_id,a.contract_id,''Please setup missing data. Setup Counterparty >> Payment Info >> Counterparty Bank Info >> Reference'' FROM '+@process_table + ' a INNER JOIN #counterparty c ON c.item = a.source_counterparty_id INNER JOIN #contract c1 on c1.item = a.contract_id  WHERE [DOCUMENT_HEADER/KeyField]  = ''I'' AND row_type = ''a'' AND NULLIF([EXTENSION1-FIELD1/PartnerBankType],'''') IS NULL 
UNION ALL
SELECT ''[COMP_CODE /AccountID]'',a.source_counterparty_id,a.contract_id,''Please setup missing data. Generic Mapping >>SAP GL Code Mapping >> GL Account'' FROM '+@process_table + ' a INNER JOIN #counterparty c ON c.item = a.source_counterparty_id INNER JOIN #contract c1 on c1.item = a.contract_id  WHERE [DOCUMENT_HEADER/KeyField]  = ''I'' AND row_type = ''b'' AND NULLIF([COMP_CODE /AccountID],'''') IS NULL 
UNION ALL
SELECT ''[PSTNG_Date/CostCenter]'',a.source_counterparty_id,a.contract_id,''Please setup missing data. Generic Mapping >>SAP GL Code Mapping >> Cost Encoding'' FROM '+@process_table + ' a INNER JOIN #counterparty c ON c.item = a.source_counterparty_id INNER JOIN #contract c1 on c1.item = a.contract_id  WHERE [DOCUMENT_HEADER/KeyField]  = ''I'' AND row_type = ''b'' AND NULLIF([PSTNG_Date/CostCenter],'''') IS NULL AND grouping <> ''withvat''
UNION ALL
SELECT ''[Header_Txt/TaxCode]'',a.source_counterparty_id,a.contract_id,''Please setup missing data. Generic Mapping >> VAT Rules Mapping >> VAT Code Sale'' FROM '+@process_table + ' a INNER JOIN #counterparty c ON c.item = a.source_counterparty_id INNER JOIN #contract c1 on c1.item = a.contract_id  WHERE [DOCUMENT_HEADER/KeyField]  = ''I'' AND row_type = ''b'' AND NULLIF([Header_Txt/TaxCode],'''')IS NULL 
UNION ALL
SELECT ''[REF_DOC_NO/Allocation]'',a.source_counterparty_id,a.contract_id,''Please setup missing data. Setup Counterparty >> External ID >> SAP Payable ID'' FROM '+@process_table + ' a INNER JOIN #counterparty c ON c.item = a.source_counterparty_id INNER JOIN #contract c1 on c1.item = a.contract_id  WHERE [DOCUMENT_HEADER/KeyField]  = ''I'' AND row_type = ''b'' AND NULLIF([REF_DOC_NO/Allocation],'''') IS NULL 
UNION ALL
SELECT ''[Text]'',a.source_counterparty_id,a.contract_id,''Please setup missing data. Generic Mapping >>SAP GL Code Mapping >> PNL'' FROM '+@process_table + ' a INNER JOIN #counterparty c ON c.item = a.source_counterparty_id INNER JOIN #contract c1 on c1.item = a.contract_id  WHERE [DOCUMENT_HEADER/KeyField]  = ''I'' AND row_type = ''b'' AND [Text] IS NULL
UNION ALL 
SELECT ''[Currency/Amount]'',a.source_counterparty_id,a.contract_id,''Total debit is not equal to total credit. Please review the entries.'' FROM '+@process_table + ' a 
 INNER JOIN #counterparty c ON c.item = a.source_counterparty_id INNER JOIN #contract c1 on c1.item = a.contract_id 
 WHERE [DOCUMENT_HEADER/KeyField] = ''I''  GROUP BY  a.source_counterparty_id,a.contract_id HAVING SUM(CAST([CURRENCY/Amount] AS Numeric(38,20)))  <> 0

')

END
ELSE
BEGIN
	EXEC('INSERT INTO #sap_export_exception_data (column_name,counter_party,contract_name,recomendation)
SELECT ''[DOC_TYPE/CustomerID]'',a.source_counterparty_id,a.contract_id,''Please setup missing data. Setup Counterparty >> External ID >> SAP Receivable ID'' FROM '+@process_table + ' a INNER JOIN #counterparty c ON c.item = a.source_counterparty_id INNER JOIN #contract c1 on c1.item = a.contract_id  WHERE [DOCUMENT_HEADER/KeyField]  = ''I'' AND row_type = ''a'' AND NULLIF([DOC_TYPE/CustomerID],'''') IS NULL  AND entity_gas = ''EET'' AND self_billing = ''n''
UNION ALL
SELECT ''[DOC_DATE/VendorID]'',a.source_counterparty_id,a.contract_id,''Please setup missing data. Setup Counterparty >> External ID >> SAP Payable ID'' FROM '+@process_table + ' a INNER JOIN #counterparty c ON c.item = a.source_counterparty_id INNER JOIN #contract c1 on c1.item = a.contract_id  WHERE [DOCUMENT_HEADER/KeyField]  = ''I'' AND row_type = ''a'' AND NULLIF([DOC_DATE/VendorID],'''') IS NULL  AND entity_gas = ''EET'' AND self_billing = ''y''
UNION ALL
SELECT ''[COMP_CODE /AccountID]'',a.source_counterparty_id,a.contract_id,''Please setup missing data. Generic Mapping >> Non EFET SAP GL Mapping >> Current/Last Year General Ledger'' FROM '+@process_table + ' a INNER JOIN #counterparty c ON c.item = a.source_counterparty_id INNER JOIN #contract c1 on c1.item = a.contract_id  WHERE [DOCUMENT_HEADER/KeyField]  = ''I'' AND NULLIF([COMP_CODE /AccountID],'''') IS NULL  AND row_type = ''b''
UNION ALL
SELECT ''[PSTNG_Date/CostCenter]'',a.source_counterparty_id,a.contract_id,''Please setup missing data. Generic Mapping >> Non EFET SAP GL Mapping >> Current/Last Year Cost Center'' FROM '+@process_table + ' a INNER JOIN #counterparty c ON c.item = a.source_counterparty_id INNER JOIN #contract c1 on c1.item = a.contract_id  WHERE [DOCUMENT_HEADER/KeyField]  = ''I'' AND row_type = ''b'' AND NULLIF([PSTNG_Date/CostCenter],'''') IS NULL AND grouping <> ''withvat''
UNION ALL
SELECT ''[Header_Txt/TaxCode]'',a.source_counterparty_id,a.contract_id,''Please setup missing data. Generic Mapping >> Non EFET VAT Rule Mapping >> VAT Code Sale/Buy'' FROM '+@process_table + ' a INNER JOIN #counterparty c ON c.item = a.source_counterparty_id INNER JOIN #contract c1 on c1.item = a.contract_id  WHERE [DOCUMENT_HEADER/KeyField]  = ''I'' AND row_type = ''b'' AND NULLIF([Header_Txt/TaxCode],'''')IS NULL  AND grouping <> ''withvat'' 
UNION ALL
SELECT ''[REF_DOC_NO/Allocation]'',a.source_counterparty_id,a.contract_id,''Please setup missing data. Setup Counterparty >> External ID >> SAP Payable ID'' FROM '+@process_table + ' a INNER JOIN #counterparty c ON c.item = a.source_counterparty_id INNER JOIN #contract c1 on c1.item = a.contract_id  WHERE [DOCUMENT_HEADER/KeyField]  = ''I'' AND row_type = ''b'' AND NULLIF([REF_DOC_NO/Allocation],'''') IS NULL 
--UNION ALL
----SELECT ''[Profit Center]''a.s,ource_counterparty_id,a.contract_id,''Please setup missing data. Generic Mapping >> Non EFET SAP GL Mapping >> Current/Last Year Profit Center'' FROM '+@process_table + ' a INNER JOIN #counterparty c ON c.item = a.source_counterparty_id INNER JOIN #contract c1 on c1.item = a.contract_id  WHERE [DOCUMENT_HEADER/KeyField]  = ''I'' AND row_type = ''b'' AND  NULLIF([ProfitCenter],'''') IS NULL
UNION ALL 
SELECT ''[Currency/Amount]'',a.source_counterparty_id,a.contract_id,''Total debit is not equal to total credit. Please review the entries.'' FROM '+@process_table + ' a 
 INNER JOIN #counterparty c ON c.item = a.source_counterparty_id INNER JOIN #contract c1 on c1.item = a.contract_id 
 WHERE [DOCUMENT_HEADER/KeyField] = ''I''  GROUP BY  a.source_counterparty_id,a.contract_id HAVING SUM(CAST([CURRENCY/Amount] AS Numeric(38,20)))  <> 0

')


	--SELECT ''[REASON_REV/BankID]'',a.source_counterparty_id,a.contract_id,''Please setup missing data. Setup Counterparty >> Payment Info >> Counterparty Bank Info >> Reference'' FROM '+@process_table + ' a INNER JOIN #counterparty c ON c.item = a.source_counterparty_id INNER JOIN #contract c1 on c1.item = a.contract_id  WHERE [DOCUMENT_HEADER/KeyField]  = ''I'' AND row_type = ''a'' AND NULLIF([REASON_REV/BankID],'''') IS NULL 
--UNION ALL
--SELECT ''[EXTENSION1-FIELD1/PartnerBankType]'',a.source_counterparty_id,a.contract_id,''Please setup missing data. Setup Counterparty >> Payment Info >> Counterparty Bank Info >> Reference'' FROM '+@process_table + ' a INNER JOIN #counterparty c ON c.item = a.source_counterparty_id INNER JOIN #contract c1 on c1.item = a.contract_id  WHERE [DOCUMENT_HEADER/KeyField]  = ''I'' AND row_type = ''a'' AND NULLIF([EXTENSION1-FIELD1/PartnerBankType],'''') IS NULL 
--UNION ALL
END	

	IF @flag = 'z'
	BEGIN
		SELECT TOP 1 '','','',' <a href="#" onclick="alert_hyperlink(''SAP Exceptions'',''EXEC spa_SettlementExport_final \''i\'','+ CAST(@counterparty_id AS VARCHAR(10)) + ',' + CAST(@contract_id AS VARCHAR(10)) + ',\''' + CONVERT(VARCHAR(10),@as_of_date, 21) + '\'',\''' + CONVERT(VARCHAR(10),@invoice_date,21) + '\'', NULL,\''' + CAST(@process_id AS VARCHAR(250)) +'\'''',500,700)">Report</a>'
		FROM #sap_export_exception_data sed INNER JOIN source_counterparty sc ON sc.source_counterparty_id = sed.counter_party 
			INNER JOIN contract_group cg on cg.contract_id = sed.contract_name
	END
	ELSE
	BEGIN
		SELECT DISTINCT column_name [Missing Column],sc.counterparty_name [Counterparty],cg.contract_name [Contract],recomendation [Recommendation] FROM #sap_export_exception_data sed INNER JOIN source_counterparty sc ON sc.source_counterparty_id = sed.counter_party 
			INNER JOIN contract_group cg on cg.contract_id = sed.contract_name
	END
END


-- ***************** FOR BATCH PROCESSING **********************************    
 
IF  @batch_process_id IS NOT NULL        
 
BEGIN        
	SELECT @str_batch_table = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL)
 
	EXEC(@str_batch_table)     
 
	DECLARE @report_name VARCHAR(100)
 
	SET @report_name = 'SAP Export Final'        
 
	SELECT @str_batch_table = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, GETDATE(),
				 'spa_SettlementExport_final', @report_name) 
 
 PRINT @str_batch_table
	EXEC(@str_batch_table)     
 
END        
-- ********************************************************************








