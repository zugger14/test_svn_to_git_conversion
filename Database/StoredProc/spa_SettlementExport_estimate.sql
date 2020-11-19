
IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_SettlementExport_estimate]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_SettlementExport_estimate]
GO
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[spa_SettlementExport_estimate] 
		@flag CHAR  = NULL
	, @counterparty_id NVARCHAR(1000)  = NULL	
	, @contract_id VARCHAR(250) = NULL
	, @as_of_date DATETIME = NULL
	, @invoice_date DATETIME = NULL
	, @type VARCHAR(250) = NULL 
	
		,@process_id VARCHAR(250) = NULL
		,@calc_id  VARCHAR(250) = NULL
		,@display_result CHAR(1) = 'y'
	, @batch_process_id    VARCHAR(250) = NULL
	, @batch_report_param  VARCHAR(500) = NULL
AS
/*

declare @flag CHAR  = NULL
	, @counterparty_id VARCHAR(250)  = NULL	
	, @contract_id VARCHAR(250) = NULL
	, @as_of_date DATETIME = NULL
	, @invoice_date DATETIME = NULL
	, @type VARCHAR(250) = NULL 
	
		,@process_id VARCHAR(250) = NULL
		,@calc_id  VARCHAR(250) = NULL
		,@display_result CHAR(1) = 'y'
	, @batch_process_id    VARCHAR(250) = NULL
	, @batch_report_param  VARCHAR(500) = NULL

	 SELECT  @flag='s',@counterparty_id='4412',@contract_id='3926',@as_of_date='2016-10-31',@invoice_date='2016-10-01',@calc_id='11599'
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
	SET @str_batch_table = ''        
	DECLARE @user VARCHAR(100)  = dbo.FNADBUser()
	DECLARE @query VARCHAR(MAX)
	DECLARE @validate VARCHAR(200)
	DECLARE @external_type_id INT 
	DECLARE @vat INT 
	DECLARE @table_name_accural VARCHAR(200) 
	DECLARE @function_id VARCHAR(200) 
	DECLARE @gsp_group VARCHAR(40) 

SELECT @function_id = function_id  FROM application_functions WHERE function_name = 'Setup Non-Standard Contract'
SELECT @gsp_group = application_ui_field_id FROM application_ui_template_definition WHERE application_function_id = @function_id  AND field_id = 'GSP_Group'
IF OBJECT_ID('tempdb..#delta') IS NOT NULL
    DROP TABLE #delta

DECLARE @external_id INT 	
SELECT value_id INTO #delta FROM static_data_value sdv INNER JOIN static_data_type sdt ON sdt.type_id = sdv.type_id WHERE sdt.type_name = 'Contract Components' AND sdv.code LIKE '%Delta%' OR  sdv.code LIKE'%Correctie%'
SELECT @external_type_id = value_id FROM static_data_value sdv INNER JOIN static_Data_type sdt ON sdt.type_id = sdv.type_id WHERE sdt.type_name = 'Counterparty External ID' AND sdv.code = 'SAP Payable ID (Creditor)'
SELECT  @external_id = value_id
  FROM static_data_value sdv INNER JOIN static_Data_type sdt ON sdt.type_id = sdv.type_id WHERE sdt.type_name = 'Counterparty External ID' AND sdv.code = 'SAP Receivable ID (Debtor)'
SELECT @vat= value_id FROM static_Data_value sdv INNER JOIN static_data_type sdt ON sdt.type_id = sdv.type_id WHERE sdt.type_name = 'Contract Components' AND sdv.code = 'VAT'

IF OBJECT_ID('tempdb..#vat') IS NOT NULL
    DROP TABLE #VAT

Select value_id,sdv.type_id,code INTO #VAT  FROM static_data_value sdv 
			INNER JOIN static_data_type sdt ON sdt.type_id = sdv.type_id 
			WHERE sdt.type_name = 'Contract Components'  AND (code like '% VAT%' OR code like 'VAT%')

INSERT INTO #VAT 
SELECT value_id,sdv.type_id,code   FROM static_data_value  sdv INNER JOIN static_data_type sdt ON sdt.type_id = sdv.type_id 
WHERE code IN  ('Consumption at Meter level','Consumption at Grid level','Consumption Including Gridlosses')  AND type_name ='Contract Components'

IF OBJECT_ID('tempdb..#counterparty_primary') IS NOT NULL
			DROP TABLE #counterparty_primary
IF OBJECT_ID('tempdb..#sap_export_data') IS NOT NULL
    DROP TABLE #sap_export_data
IF OBJECT_ID('tempdb..#sap_export_data_a') IS NOT NULL
    DROP TABLE #sap_export_data_a
IF OBJECT_ID('tempdb..#temp_sap_detail') IS NOT NULL
    DROP TABLE #temp_sap_detail
IF OBJECT_ID('tempdb..#temp_sap_detail_with_sequence') IS NOT NULL
	DROP TABLE #temp_sap_detail_with_sequence  
IF OBJECT_ID('tempdb..#detail') IS NOT NULL
	DROP TABLE #detail   
IF OBJECT_ID('tempdb..#header') IS NOT NULL
	DROP TABLE #header 
IF OBJECT_ID('tempdb..#summary') IS NOT NULL
	DROP TABLE #summary 
IF OBJECT_ID('tempdb..#count') IS NOT NULL
	DROP TABLE #count 
IF OBJECT_ID('tempdb..#removed_lineitem') IS NOT NULL
	DROP TABLE #removed_lineitem
IF OBJECT_ID('tempdb..#double_booking') IS NOT NULL
	DROP TABLE #double_booking
IF OBJECT_ID('tempdb..#summary_with_count') IS NOT NULL
	DROP TABLE #summary_with_count 
IF OBJECT_ID('tempdb..#refresh_grid') IS NOT NULL
	DROP TABLE #refresh_grid
IF OBJECT_ID('tempdb..#counterparty') IS NOT NULL
	DROP TABLE #counterparty
IF OBJECT_ID('tempdb..#contract') IS NOT NULL
	DROP TABLE #contract
IF OBJECT_ID('tempdb..#validate') IS NOT NULL
	DROP TABLE #validate	
IF OBJECT_ID('tempdb..#contract_type') IS NOT NULL
	DROP TABLE #contract_type	
IF OBJECT_ID('tempdb..#sap_export_exception_data') IS NOT NULL
    DROP TABLE #sap_export_exception_data
IF OBJECT_ID('tempdb..#sap_gl_mapping_accural') IS NOT NULL
    DROP TABLE #sap_gl_mapping_accural

IF OBJECT_ID('tempdb..#sap_gl_mapping_trueup') IS NOT NULL
    DROP TABLE #sap_gl_mapping_trueup
	
IF OBJECT_ID('tempdb..#calc_id') IS NOT NULL
    DROP TABLE #calc_id	

IF OBJECT_ID('tempdb..#gsp_group_info') IS NOT NULL 
	DROP TABLE #gsp_group_info
 IF OBJECT_ID('tempdb..#sap_gl_mapping_accural1') IS NOT NULL 
	DROP TABLE #sap_gl_mapping_accural1 

CREATE TABLE #sap_export_exception_data
(
		row_id      NVARCHAR(MAX) COLLATE DATABASE_DEFAULT  NULL,
		column_name      NVARCHAR(MAX) COLLATE DATABASE_DEFAULT  NULL,
		counter_party      NVARCHAR(MAX) COLLATE DATABASE_DEFAULT  NULL,
		contract_name      NVARCHAR(MAX) COLLATE DATABASE_DEFAULT  NULL,
		recomendation      NVARCHAR(MAX) COLLATE DATABASE_DEFAULT  NULL
)
CREATE TABLE #calc_id(
	calc_id INT
	,counterparty_id INT
	,contract_id INT
	,as_of_date DATETIME 
	,invoice_date DATETIME
	
)


--WHERE cg.contract_id = @contract_id


--Select @contract_type

CREATE TABLE #counterparty(item INT)
CREATE TABLE #contract(item INT)

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


IF NULLIF(@calc_id, '') IS  NULL
BEGIN
	INSERT INTO #calc_id (calc_id,counterparty_id,contract_id,as_of_date,invoice_date)
	SELECT calc_id,counterparty_id,contract_id,as_of_date,settlement_date FROM Calc_invoice_Volume_variance civv 
	INNER JOIN #counterparty c On c.item = civv.counterparty_id
	INNER JOIN #contract c1 ON c1.item = civv.contract_id 
	WHERE as_of_date = @as_of_date 
		AND settlement_date = @invoice_date AND netting_calc_id IS NULL

END
ELSE
BEGIN
	INSERT INTO #calc_id (calc_id,counterparty_id,contract_id,as_of_date,invoice_date)
	SELECT @calc_id,counterparty_id,contract_id,CAST(@as_of_date as DATETIME),CAST(@invoice_date AS datetime) FROM Calc_invoice_Volume_variance WHERE calc_id =@calc_id
	
END




Select @contract_type = 
CASE WHEN MAX(ISNULL(standard_contract,'y')) = 'y' THEN ISNULL(sdv.code,'Standard') ELSE ISNULL(sdv.code,'Non-Standard') END  
FROM contract_group cg  
INNER JOIN Calc_invoice_Volume_variance civv ON civv.contract_id = cg.contract_id --AND civv.calc_id = @calc_id
INNER JOIN #calc_id ci ON ci.calc_id = civv.calc_id
LEFT JOIN static_data_value sdv ON cg.contract_type_def_id = sdv.value_id
LEFT JOIN static_data_type sdt ON sdt.type_id = sdv.type_id  AND sdt.type_name = 'Contract Type'
GROUP BY sdv.code


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

IF @process_id IS NULL 
BEGIN
	SELECT @process_id = dbo.FNAGETnewID()
END
SET @process_table = dbo.FNAProcesstablename('SAP_estimate',@user,@process_id)
SET @table_name_accural = dbo.FNAProcesstablename('sap_gl_mapping_accural',@user,@process_id)

Declare @table_name VARCHAR(300)
SELECT @table_name = 'SAP_estimate_'+@user+'_'+@process_id

IF @flag ='s' or @flag = 'z'
BEGIN
EXEC('IF EXISTS(SELECT 1 FROM adiha_process.sys.tables WITH(NOLOCK) WHERE  name =  '+''''+@table_name+''')
			DROP TABLE '+@process_table )

	CREATE TABLE #refresh_grid
		(
			counterparty_id							NVARCHAR(MAX) COLLATE DATABASE_DEFAULT  NULL,
			contract_id								NVARCHAR(MAX) COLLATE DATABASE_DEFAULT  NULL,
			as_of_date								NVARCHAR(MAX) COLLATE DATABASE_DEFAULT  NULL,
			invoice_date							NVARCHAR(MAX) COLLATE DATABASE_DEFAULT  NULL,
			document_header							NVARCHAR(MAX) COLLATE DATABASE_DEFAULT  NULL,
			comp_code								NVARCHAR(MAX) COLLATE DATABASE_DEFAULT  NULL,
			doc_type								NVARCHAR(MAX) COLLATE DATABASE_DEFAULT  NULL,
			doc_date								NVARCHAR(MAX) COLLATE DATABASE_DEFAULT  NULL,
			fisc_year								NVARCHAR(MAX) COLLATE DATABASE_DEFAULT  NULL,
			pstng_date								NVARCHAR(MAX) COLLATE DATABASE_DEFAULT  NULL,
			currency								NVARCHAR(MAX) COLLATE DATABASE_DEFAULT  NULL,
			header_txt								NVARCHAR(MAX) COLLATE DATABASE_DEFAULT  NULL,
			ref_doc_no								NVARCHAR(MAX) COLLATE DATABASE_DEFAULT  NULL,
			reason_rev								NVARCHAR(MAX) COLLATE DATABASE_DEFAULT  NULL,
			extension_field							NVARCHAR(MAX) COLLATE DATABASE_DEFAULT  NULL,
			[text]									NVARCHAR(MAX) COLLATE DATABASE_DEFAULT  NULL,
			quantity								NVARCHAR(MAX) COLLATE DATABASE_DEFAULT  NULL,
			base_unit_of_measure					NVARCHAR(MAX) COLLATE DATABASE_DEFAULT  NULL,
			settlement_period						NVARCHAR(MAX) COLLATE DATABASE_DEFAULT  NULL
		) 
		
		CREATE TABLE #sap_export_data (
			[source_counterparty_id] INT
			,[2120_hardcode] VARCHAR(100) COLLATE DATABASE_DEFAULT  NULL
			,[TA_hardcode] VARCHAR(50) COLLATE DATABASE_DEFAULT 
			,[prod_date] DATETIME NULL
			,[Year] VARCHAR(10) COLLATE DATABASE_DEFAULT  NULL
			,[currency_id] VARCHAR(50) COLLATE DATABASE_DEFAULT  NULL
			,[Buy_sell_h] VARCHAR(50) COLLATE DATABASE_DEFAULT  NULL
			,[ST_ESTIMATE_hardcode] VARCHAR(100) COLLATE DATABASE_DEFAULT  NULL
			,[5_hardcode] INT NULL
			,[Nxt Mth] DATETIME NULL
			,
			--detail
			[Buy_sell_d] VARCHAR(50) COLLATE DATABASE_DEFAULT  NULL
			,[BLank] VARCHAR(200) COLLATE DATABASE_DEFAULT  NULL
			,[2120_hardcode2] VARCHAR(100) COLLATE DATABASE_DEFAULT  NULL
			,[Blank_2] VARCHAR(10) COLLATE DATABASE_DEFAULT  NULL
			,[Gl_account] INT NULL
			,[Cost_encoding] VARCHAR(100) COLLATE DATABASE_DEFAULT  NULL
			,[Blank_3] VARCHAR(10) COLLATE DATABASE_DEFAULT  NULL
			,[Blank_4] VARCHAR(10) COLLATE DATABASE_DEFAULT  NULL
			,[Blank_5] VARCHAR(10) COLLATE DATABASE_DEFAULT  NULL
			,[Value-D] FLOAT NULL
			,[VAT_code_estimate] VARCHAR(200) COLLATE DATABASE_DEFAULT  NULL
			,[Blank_6] VARCHAR(10) COLLATE DATABASE_DEFAULT  NULL
			,[Blank_7] VARCHAR(10) COLLATE DATABASE_DEFAULT  NULL
			,[counterparty_country] VARCHAR(200) COLLATE DATABASE_DEFAULT  NULL
			,[PNL_BUYSELL] VARCHAR(200) COLLATE DATABASE_DEFAULT  NULL
			,[counterparty_pnl_buysell] VARCHAR(5000) COLLATE DATABASE_DEFAULT  NULL
			,[gl_ac_blnc_est] VARCHAR(200) COLLATE DATABASE_DEFAULT  NULL
			,
			-- summary
			[Value-S] FLOAT NULL
			,[0_hardcoded] INT NULL
			,[0_hardcoded2] INT NULL
			,[ZSTOP_Xellent_GL_harcdode] VARCHAR(200) COLLATE DATABASE_DEFAULT  NULL
			,[epa_external_value] VARCHAR(50) COLLATE DATABASE_DEFAULT  NULL
			,as_of_date DATETIME
			,contract_id INT
			,[UOM] VARCHAR(200) COLLATE DATABASE_DEFAULT  NULL
			,[delivery_period] VARCHAR(6) COLLATE DATABASE_DEFAULT  NULL
			,[Volume] FLOAT NULL
			,[counterparty_name] VARCHAR(250) COLLATE DATABASE_DEFAULT 
			,[current_year_profit_center] VARCHAR(250) COLLATE DATABASE_DEFAULT 
			,[TaxCodeBuy] VARCHAR(250) COLLATE DATABASE_DEFAULT 
			,[contract_name] VARCHAR(250) COLLATE DATABASE_DEFAULT 
			,[TaxCodesale] VARCHAR(250) COLLATE DATABASE_DEFAULT 
			,[PartnerID] VARCHAR(250) COLLATE DATABASE_DEFAULT 
			,calc_id VARCHAR(250) COLLATE DATABASE_DEFAULT 
			,products VARCHAR(250) COLLATE DATABASE_DEFAULT 
			,invoice_lineitem VARCHAR(250) COLLATE DATABASE_DEFAULT 
			,double_booking VARCHAR(250) COLLATE DATABASE_DEFAULT 
			,entity_gas VARCHAR(250) COLLATE DATABASE_DEFAULT  
			,non_efet_IC_Ext VARCHAR(50) COLLATE DATABASE_DEFAULT 
			,GSP_group VARCHAR(50) COLLATE DATABASE_DEFAULT 
			,current_year_balance_center VARCHAR(200) COLLATE DATABASE_DEFAULT 
			,last_year_balance_center VARCHAR(300) COLLATE DATABASE_DEFAULT 
			,Resultant_balance_center VARCHAR(300) COLLATE DATABASE_DEFAULT 
			,counterparty_type VARCHAR(10) COLLATE DATABASE_DEFAULT 
			,ic_with_fiscal VARCHAR(100) COLLATE DATABASE_DEFAULT 
			,self_billing VARCHAR(10) COLLATE DATABASE_DEFAULT 
			,invoice_type VARCHAR(10) COLLATE DATABASE_DEFAULT 
			,settlementdate datetime
			)
		
			CREATE TABLE #temp_sap_detail(
						[column_2] VARCHAR(250) COLLATE DATABASE_DEFAULT ,
					[column_3] VARCHAR(250) COLLATE DATABASE_DEFAULT ,
					[column_4] VARCHAR(250) COLLATE DATABASE_DEFAULT ,
					[column_5] VARCHAR(250) COLLATE DATABASE_DEFAULT ,
					[column_6] VARCHAR(250) COLLATE DATABASE_DEFAULT ,
					[column_7] VARCHAR(250) COLLATE DATABASE_DEFAULT ,
					[column_8] VARCHAR(250) COLLATE DATABASE_DEFAULT ,
					[column_9] VARCHAR(250) COLLATE DATABASE_DEFAULT ,
					[column_10] VARCHAR(250) COLLATE DATABASE_DEFAULT ,
					[column_11] VARCHAR(250) COLLATE DATABASE_DEFAULT ,
					[column_12] VARCHAR(250) COLLATE DATABASE_DEFAULT ,
					[Buy_sell_h] VARCHAR(250) COLLATE DATABASE_DEFAULT ,
					[Order_detail] VARCHAR(10) COLLATE DATABASE_DEFAULT ,
					[Buy_sell_d] VARCHAR(250) COLLATE DATABASE_DEFAULT ,
					row_type VARCHAR(10) COLLATE DATABASE_DEFAULT ,
					source_counterparty_id INT,
					contract_id INT,
				[uom] VARCHAR(250) COLLATE DATABASE_DEFAULT ,
					delivery_period INT,
					volume Numeric(38,3),
						TaxCodeBuy VARCHAR(250) COLLATE DATABASE_DEFAULT ,
					[ProfitCenter] VARCHAR(250) COLLATE DATABASE_DEFAULT ,
					PartnerID VARCHAR(250) COLLATE DATABASE_DEFAULT 
					,calc_id VARCHAR(250) COLLATE DATABASE_DEFAULT ,entity_gas VARCHAR(250) COLLATE DATABASE_DEFAULT )
		
		
		CREATE TABLE #temp_sap_detail_with_sequence(
			 [column_1]   VARCHAR(250) COLLATE DATABASE_DEFAULT 
			,[column_2]   VARCHAR(250) COLLATE DATABASE_DEFAULT 
			,[column_3]   VARCHAR(250) COLLATE DATABASE_DEFAULT 
			,[column_4]   VARCHAR(250) COLLATE DATABASE_DEFAULT 
			,[column_5]   VARCHAR(250) COLLATE DATABASE_DEFAULT 
			,[column_6]   VARCHAR(250) COLLATE DATABASE_DEFAULT 
			,[column_7]   VARCHAR(250) COLLATE DATABASE_DEFAULT 
			,[column_8]   VARCHAR(250) COLLATE DATABASE_DEFAULT 
			,[column_9]   VARCHAR(250) COLLATE DATABASE_DEFAULT 
			,[column_10]  VARCHAR(250) COLLATE DATABASE_DEFAULT 
			,[column_11]  VARCHAR(250) COLLATE DATABASE_DEFAULT 
			,[column_12]  VARCHAR(250) COLLATE DATABASE_DEFAULT 
			, [Order]     VARCHAR(10) COLLATE DATABASE_DEFAULT 
			,[Buy_sell_h] VARCHAR(250) COLLATE DATABASE_DEFAULT 
			,row_type VARCHAR(10) COLLATE DATABASE_DEFAULT 
			,source_counterparty_id INT
			,contract_id INT 
			,[uom] VARCHAR(250) COLLATE DATABASE_DEFAULT  
			,delivery_period VARCHAR(250) COLLATE DATABASE_DEFAULT 
			,volume VARCHAR(250) COLLATE DATABASE_DEFAULT 
			,TaxCodeBuy VARCHAR(250) COLLATE DATABASE_DEFAULT 
			, ProfitCenter VARCHAR(250) COLLATE DATABASE_DEFAULT 
			,PartnerID VARCHAR(250) COLLATE DATABASE_DEFAULT 
			,calc_id VARCHAR(250) COLLATE DATABASE_DEFAULT 
			,entity_gas VARCHAR(250) COLLATE DATABASE_DEFAULT )

		
IF @contract_type = '_Standard'
	BEGIN
	--nukkk
	INSERT INTO #sap_export_data(
		[source_counterparty_id],[2120_hardcode],[TA_hardcode],[prod_date],[Year],[currency_id],[Buy_sell_h] ,[ST_ESTIMATE_hardcode],[5_hardcode],[Nxt Mth],[Buy_sell_d],[BLank] ,[2120_hardcode2],[Blank_2] ,[Gl_account],[Cost_encoding],[Blank_3],[Blank_4],[Blank_5],[Value-D],[VAT_code_estimate],[Blank_6] ,[Blank_7],[counterparty_country],[PNL_BUYSELL],[counterparty_pnl_buysell],[gl_ac_blnc_est],[Value-S],[0_hardcoded],[0_hardcoded2],[ZSTOP_Xellent_GL_harcdode],[epa_external_value],as_of_date,contract_id,[UOM],[delivery_period],[Volume],counterparty_name,Calc_id)
		SELECT sc2.source_counterparty_id,
			 2120,
		   CASE WHEN  SUM(cfv.value) < 0 THEN 'ST' ELSE 'TA'END,
		   civv.settlement_date,
		   YEAR(civv.settlement_date)[Year],
		   sc.currency_id,
		   CASE 
					WHEN civv.invoice_type = 'i' THEN 'SELL ' + sc1.commodity_id + ' ' + cast(month(CAST(civv.prod_date AS VARCHAR(100))) AS VARCHAR(200)) +'-' + cast(YEAR(CAST(civv.prod_date AS VARCHAR(100))) AS VARCHAR(200))
					ELSE 'BUY ' + sc1.commodity_id + ' ' + cast(month(CAST(civv.prod_date AS VARCHAR(100))) AS VARCHAR(200))+ '-' + cast(YEAR(CAST(civv.prod_date AS VARCHAR(100))) AS VARCHAR(200))
		   END [Buy/sell-h],
			CONVERT(varchar(16), right(newid(), 16)),
		   '5',
			civv.prod_date [Nxt Mth],
		   --detail
		   /*sequence number grouped by Buy/Sell*/
		   /*sequence group by BSCHL,SHKZG,BURKS,FILLER,HKONT,KOSTL*/
		   CASE 
					WHEN SUM(cfv.value) > 0 THEN 50 ELSE 40
		   END [Buy/sell-d],
		   '',
		   2120,
		   '',
			sdv101.code [Gl account],
		   sdv_clm11_value.code [Cost encoding],
		   '',
		   '',
		   '',
		   round(SUM(cfv.value),2) [Value-D],
		   sdv_clm13_value.code[VAT code estimate],
		   '',
		   '',
		   cea.external_value  [counterparty/country],
			sc2.counterparty_name + ' ' +gmv.clm7_value+ ' ' 
			+ CASE 
									 WHEN civv.invoice_type = 'i' THEN 'SELL ' + sc1.commodity_id + ' ' + cast(month(CAST(civv.prod_date AS VARCHAR(100))) AS VARCHAR(200)) + '-' + cast(YEAR(CAST(civv.prod_date AS VARCHAR(100))) AS VARCHAR(200))
									 ELSE 'BUY ' + sc1.commodity_id + ' ' + cast(month(CAST(civv.prod_date AS VARCHAR(100))) AS VARCHAR(200)) + '-' + + cast(YEAR(CAST(civv.prod_date AS VARCHAR(100))) AS VARCHAR(200))
								END [PNL/BUYSELL],
				 CASE 
			 WHEN civv.invoice_type = 'i' THEN sc2.counterparty_name + ' SELL ' + sc1.commodity_id + ' ' + cast(month(CAST(civv.prod_date AS VARCHAR(100))) AS VARCHAR(200)) +'-' + cast(YEAR(CAST(civv.prod_date AS VARCHAR(100))) AS VARCHAR(200))
					ELSE sc2.counterparty_name + ' BUY ' + sc1.commodity_id + ' ' + cast(month(CAST(civv.prod_date AS VARCHAR(100))) AS VARCHAR(200))+ '-' + cast(YEAR(CAST(civv.prod_date AS VARCHAR(100))) AS VARCHAR(200))
			 END [counterparty_pnl_buysell],
			 sdv_clm12_value.[description],
	  
		   -- summary
		   /*sequence number grouped by Buy/Sell*/
		   round(SUM(cfv.value),2)[Value-S],
		   0,
		   0,
		   'ZSTOP Xellent GL' [ZSTOP Xellent GL-hardcode],
			 max(cea.external_value),
		   civv1.as_of_date,
		  ISNULL(cg.contract_id,civv.contract_id) contract_id,
		  MAX(ISNULL(su1.uom_desc,su1.uom_name)) uom_name,
		   cast(YEAR(civv.prod_date) AS VARCHAR) + RIGHT('0' + CAST(month(civv.prod_date) AS VARCHAR),2) delivery_period,
		   CASE WHEN  cfv.invoice_line_item_id = @vat THEN 0 ELSE  ROUND(sum(cfv.Volume),3)  END AS Volume,sc2.counterparty_name, civv.Calc_id
 FROM   calc_invoice_volume_variance civv 
		INNER JOIN #counterparty c
				 ON c.item  = civv.counterparty_id
		INNER JOIN #contract c1 ON c1.item = civv.contract_id
		INNER JOIN #calc_id ci ON ci.calc_id = civv.calc_id
			  INNER JOIN (
					 SELECT MAX(as_of_date) as_of_date,
							prod_date,
							settlement_date,
							counterparty_id,
							contract_id
					 FROM   calc_invoice_volume_variance
					 GROUP BY
							prod_date,
							settlement_date,
							counterparty_id,
							contract_id
					 ) civv1
							ON civv.as_of_date = civv1.as_of_date 
							AND civv.prod_date = civv1.prod_date
							AND civv.settlement_date = civv1.settlement_date 
							AND civv.counterparty_id = civv1.counterparty_id 
							AND civv.contract_id = civv1.contract_id   
				   INNER JOIN calc_invoice_volume civ
							ON  civv.calc_id = civ.calc_id
				   LEFT JOIN calc_formula_value cfv
							ON  cfv.calc_id = civv.calc_id
							AND cfv.invoice_line_item_id = civ.invoice_line_item_id
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
						ON  CAST(sdh.contract_id AS VARCHAR(100)) = cg.contract_id
               LEFT JOIN source_currency sc
                        ON  ISNULL(cg.currency, sdd1.fixed_price_currency_id) = 
                              sc.source_currency_id
               LEFT JOIN source_commodity sc1
                        ON  CAST(sdh.commodity_id AS VARCHAR(100)) = sc1.source_commodity_id
			 
               LEFT JOIN source_counterparty sc2
                        ON  civv.counterparty_id = sc2.source_counterparty_id
               LEFT JOIN static_data_value country_sdv
                        ON  sc2.country = country_sdv .value_id
               LEFT JOIN generic_mapping_header gmh
                        ON  gmh.mapping_name = 'SAP GL Code Mapping'
               LEFT JOIN generic_mapping_definition gmd
                        ON  gmd.mapping_table_id = gmh.mapping_table_id
               LEFT JOIN generic_mapping_values gmv
                        ON  gmv.mapping_table_id = gmh.mapping_table_id
                        AND gmv.clm1_value = CAST(ssbm.source_system_book_id1 AS VARCHAR(100))
                        AND gmv.clm2_value = CAST(ssbm.source_system_book_id2 AS VARCHAR (100))
                        AND gmv.clm3_value = CAST(ssbm.source_system_book_id3 AS VARCHAR (100))
                        AND gmv.clm4_value = CAST(sdh.contract_id AS VARCHAR (100))
                        AND gmv.clm5_value = CAST(sc.source_currency_id AS VARCHAR (100))
                        AND gmv.clm6_value = (CASE WHEN civ.value > 0 THEN 's' ELSE 'b' END)
						LEFT JOIN static_data_value sdv101 ON sdv101.value_id = gmv.clm9_value AND sdv101.type_id = 29800
                 --    LEFT JOIN gl_system_mapping gsm ON CAST(gsm.gl_number_id AS VARCHAR (100)) = gmv.clm9_value 
                        LEFT JOIN static_data_value sdv_clm11_value ON CAST(sdv_clm11_value.value_id AS VARCHAR (100)) = gmv.clm11_value
                        LEFT JOIN static_data_value sdv_clm13_value ON CAST(sdv_clm13_value.value_id AS VARCHAR (100)) = gmv.clm13_value
                        LEFT JOIN static_data_value sdv_clm12_value ON CAST(sdv_clm12_value.value_id AS VARCHAR (100)) = gmv.clm12_value
            LEFT JOIN source_book sb_3 ON  sb_3.source_book_id = sdh.source_system_book_id3
            LEFT JOIN counterparty_epa_account cea ON sc2.source_counterparty_id = cea.counterparty_id
            AND external_type_id = @external_type_id
            LEFT JOIN source_uom su1 on su1.source_uom_id = ISNULL(civ.uom_id,cg.volume_uom)
		WHERE  --civ.is_final_result = 'y' AND
				 civ.invoice_line_item_id <> @vat
				AND (civv.finalized IS NULL OR civv.finalized = 'n')
				AND  civv.settlement_date = @invoice_date --@prod_date
				AND civv.as_of_date= @as_of_date
          GROUP BY
               civv.prod_date,civv.contract_id,
               sc.currency_id,
               civv.invoice_type,
               sc2.counterparty_name,
               country_sdv.code,
               sc1.commodity_id,
               gmv.clm7_value,
               sdv_clm11_value.code,
               sdv_clm13_value.code,
                sdv101.code,
               sdv_clm12_value.[description],
               sb_3.source_book_name,
               civv.settlement_date,
			   sc2.source_counterparty_id,
			   civv1.as_of_date,
			   cg.contract_id,
			   cea.external_value,cfv.invoice_line_item_id,civv.Calc_id
			
			

INSERT INTO #temp_sap_detail([column_2],
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
		[Buy_sell_h],
		[Order_detail],
		[Buy_sell_d],
		row_type,
		source_counterparty_id,
		contract_id,
		[uom],
		delivery_period,
		volume,calc_id)
		SELECT  CAST(sed.[Gl_account] AS VARCHAR(100)) [column_2],
            sed.[BLank] [column_3],
            sed.[BLank_2] [column_4],
            sed.[Blank_5] [column_5],
            sed.Cost_encoding [column_6],
           -- CAST(CAST(sed.[Value-D]    AS NUMERIC(38, 2)) AS VARCHAR(200)) [column_7],
   --        CASE WHEN  sed.[Buy_sell_d] = '40'  THEN  
			--	CAST((CAST(sed.[Value-D] * -1  AS NUMERIC(38, 2)) ) AS VARCHAR(200))  
			--ELSE	CAST(CAST(sed.[Value-D] *-1 AS NUMERIC(38, 2)) AS VARCHAR(200)) 
			--END
			CAST(CAST(sed.[Value-D] *-1 AS NUMERIC(38, 2)) AS VARCHAR(200)) 
			 [column_7],
            sed.VAT_code_estimate [column_8],
            sed.counterparty_country [column_9],
            sed.[Blank_6] [column_10],
            sed.[Blank_7] [column_11],
            sed.PNL_BUYSELL [column_12],
            sed.[Buy_sell_h],
            1 [Order_detail],
            sed.[Buy_sell_d],
			'a' row_type,
			source_counterparty_id,
			contract_id,
			[uom],
			delivery_period,
			volume,calc_id
     FROM   #sap_export_data sed
	 UNION ALL
     SELECT MAX(sed.gl_ac_blnc_est) [column_2],
            MAX(sed.[BLank]) [column_3],
            MAX(sed.[BLank_2]) [column_4],
            MAX(sed.[Blank_5]) [column_5],
            '' [column_6],
			CAST(SUM(CAST(sed.[Value-D]   AS NUMERIC(38, 2))) AS VARCHAR(200)) [column_7],
           -- CASE WHEN sed.[Buy_sell_d] = '40' THEN  CAST(SUM(CAST(sed.[Value-D]  AS NUMERIC(38, 2) )) AS VARCHAR(200))  ELSE CAST(sum(CAST(sed.[Value-D] *-1    AS NUMERIC(38, 2))) AS VARCHAR(200)) END [column_7],
            MAX(sed.VAT_code_estimate) [column_8],
            sed.counterparty_country [column_9],
            MAX(sed.[Blank_6]) [column_10],
            MAX(sed.[Blank_7]) [column_11],
           MAX(sed.counterparty_name) + ' ' +  MAX(sed.[Buy_sell_h]) [column_12],
            sed.[Buy_sell_h],
            2 [Order_detail],
            sed.[Buy_sell_d],
			'b' as row_type,
			source_counterparty_id,
			contract_id,
			[uom],
			delivery_period,
			volume,calc_id
     FROM   #sap_export_data sed
     GROUP BY
            sed.counterparty_country, sed.[Buy_sell_d], sed.[Buy_sell_h],source_counterparty_id,
			contract_id,
			[uom],
			delivery_period,
			volume,calc_id
			
	
			
			INSERT INTO #temp_sap_detail_with_sequence(
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
			, [Order]     
			,[Buy_sell_h] 
			,row_type 
			,source_counterparty_id 
			,contract_id  
			,[uom]  
			,delivery_period
			,volume 
			,TaxCodeBuy 
			, ProfitCenter 
			,PartnerID,calc_id )
	SELECT 
		'I' [column_1]
		,sap_union.[column_2]
		,sap_union.[column_3]
		,sap_union.[column_4]
		,sap_union.[column_5]
		,sap_union.[column_6]
		,sap_union.[column_7]
		,sap_union.[column_8]
		,sap_union.[column_9]
		,sap_union.[column_10]
		,sap_union.[column_11]
		,sap_union.[column_12] [column_12]
		,2 [Order]
		,sap_union.[Buy_sell_h]
		,sap_union.row_type
		,source_counterparty_id
		,contract_id
		,[uom]
		,delivery_period
		,volume
		,
			TaxCodeBuy,
			[ProfitCenter],
			PartnerID,calc_id
	FROM #temp_sap_detail sap_union
	ORDER BY DENSE_RANK() OVER (
			ORDER BY [Order_detail]
				,sap_union.[Buy_sell_h],calc_id
			)
		,sap_union.[column_9] DESC

	END
ELSE IF @contract_type = 'Non-Standard' OR @contract_type = 'Transportation' OR @contract_type = 'Standard'
	BEGIN 
		
DECLARE @template_id INT 

SELECT @template_id = contract_charge_type_id  FROM contract_group cg
	INNER JOIN #calc_id ci ON ci.contract_id = cg.contract_id
--where contract_id = @contract_id
--select @template_id
--return

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

	SELECT 	DISTINCT
			gmv.mapping_table_id
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
			,	CASE 
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
			,sdv_z.code [VAT_Code]--CASE WHEN ISNULL(cg.self_billing, 'n') = 'n' THEN sdv_z.code ELSE sdv_c.code END  [VAT_Code]
			,sdv_a.code [VAT_GL_Account]
			--,sdv_c.code [VAT_Code_Buy]
			--,sdv_d.code [VAT_GL_Account_Buy]
			,sc.source_counterparty_id
			,sc.counterparty_id
			,cg.contract_id
			,cg.contract_name
			,@as_of_date as_of_date
			,a.calc_id
			,ISNULL(cgd.invoice_line_item_id,cctd.invoice_line_item_id) invoice_line_item_id
			,cctd.contract_charge_type_id
			,ISNULL(c.external_value,'') entity_code
			,ISNULL(b.external_value,'No') Double_booking
			,CASE WHEN gmv.clm3_value = 'b' THEN 'Broker'
			WHEN gmv.clm3_value = 'i' THEN 'Internal'
			WHEN gmv.clm3_value = 'e' THEN 'External' 
			ELSE '' END non_efet_IC_Ext
			,sdv_g.code [GSP_group]
			,sdv_cbal.code[current_year_balance_center]
			,sdv_lbal.code[last_year_balance_center]
			,cctd.is_true_up [true_up]
			,@ic_with_fiscal [ic_with_fiscal]
			,ISNULL(cg.self_billing, 'n') self_billing
			,a.invoice_type invoice_type
INTO #sap_gl_mapping_accural1
--SELECT *--gmv.clm4_value,sc.source_counterparty_id,a.counterparty_id, sc.int_ext_flag , gmv.clm3_value,cc.*,* 

		FROM generic_mapping_header ghm
			INNER JOIN generic_mapping_values gmv ON gmv.mapping_table_id = ghm.mapping_table_id
				AND mapping_name = 'Non EFET SAP GL Mapping' 
			CROSS APPLY (
				SELECT civv.calc_id
					,civv.as_of_date
					,civv.counterparty_id
					,civv.contract_id
					,civv.prod_date
					,civv.finalized,civv.invoice_type
		FROM calc_invoice_volume_variance civv INNER JOIN #calc_id ci ON 
				ci.calc_id = civv.calc_id
			INNER JOIN calc_invoice_volume civ ON civ.calc_id = civv.calc_id
				WHERE 	
					 gmv.clm1_value = CASE 
					--	WHEN ISNULL(finalized,'n') = 'y'
					WHEN ISNULL(civv.finalized,'n') ='y' OR ISNULL(civ.status,'') = 'v'
							THEN 'i'
						ELSE 'a'
						END
					AND netting_calc_id  IS NULL
				) a
			INNER JOIN contract_group cg ON cg.contract_id = a.contract_id
				AND ISNULL(cg.self_billing, 'n') = CASE 
					WHEN gmv.clm2_value = 's'
						THEN 'y'
					ELSE  'n'
					END
			INNER JOIN source_counterparty sc ON sc.source_counterparty_id = a.counterparty_id AND sc.int_ext_flag = gmv.clm3_value --AND sc.source_counterparty_id = gmv.clm5_value
			INNER JOIN counterparty_contacts cc ON cc.counterparty_id = sc.source_counterparty_id
				AND is_primary = 'y'
				AND CAST(cc.country as VARCHAR(250))= gmv.clm4_value 
			LEFT  JOIN contract_group_detail cgd ON cgd.contract_id = cg.contract_id 
					AND cgd.invoice_line_item_id  = gmv.clm8_value AND cgd.alias = gmv.clm7_value
			LEFT JOIN contract_charge_type cct ON cct.contract_charge_type_id = cg.contract_charge_type_id
			LEFT JOIN contract_charge_type_detail cctd ON cctd.contract_charge_type_id = cct.contract_charge_type_id AND  cctd.invoice_line_item_id  = gmv.clm8_value AND cctd.alias = gmv.clm7_value
			INNER JOIN generic_mapping_values gmv1 ON gmv1.clm1_value = gmv.clm1_value
				AND gmv1.clm2_value = gmv.clm2_value
				AND gmv1.clm3_value = gmv.clm3_value
				AND gmv1.clm3_value = sc.int_ext_flag	
			INNER JOIN generic_mapping_header gmh1 ON gmh1.mapping_table_id = gmv1.mapping_table_id
				AND gmh1.mapping_name = 'Non EFET SAP Doc Type'
			OUTER APPLY (
				SELECT counterparty_id
					,external_type_id
					,external_value
				FROM counterparty_epa_account cea
				INNER JOIN static_data_value sdv_cea ON sdv_cea.value_id = cea.external_type_id
				INNER JOIN static_data_type sdt_cea ON sdt_cea.type_id = sdv_cea.type_id
					AND sdt_cea.type_name = 'Counterparty External ID'
				WHERE cea.counterparty_id = sc.source_counterparty_id
				--WHERE cea.counterparty_id = 8257
					AND cea.external_type_id = sdv_cea.value_id
					AND sdv_cea.code = 'Double Booking'
				--AND ISNULL(cea.external_value,'No') = CASE WHEN 'n' = 'y' THEN 'Yes' ELSE 'No' END
				) b
				
			LEFT JOIN generic_mapping_values gmv2 ON gmv2.clm1_value = gmv.clm7_value
				AND cc.region = gmv2.clm2_value
				AND gmv2.clm8_value = gmv1.clm5_value	
			LEFT JOIN generic_mapping_header gmh2 ON gmh1.mapping_table_id = gmv1.mapping_table_id
				AND gmh1.mapping_name = 'Non EFET VAT Rule Mapping'
			OUTER APPLY(
					SELECT sc1.source_counterparty_id
					,sc1.counterparty_id
					,cea.external_type_id
					,cea.external_value 
				FROM source_counterparty sc1 
				INNER JOIN counterparty_epa_account cea ON cea.counterparty_id = sc1.source_counterparty_id
				INNER JOIN static_data_value sdv_cea ON cea.external_type_id = sdv_cea.value_id
				INNER JOIN static_data_type sdt_cea ON sdt_cea.type_id = sdv_cea.type_id
							AND sdt_cea.type_name = 'Counterparty External ID'
				WHERE sc1.source_counterparty_id =cea.counterparty_id
							AND cea.external_type_id = sdv_cea.value_id
							AND sdv_cea.code = 'entity code'
						AND sc1.source_counterparty_id = gmv.clm5_value
			)c
			LEFT JOIN static_data_value sdv_b ON sdv_b.value_id = gmv2.clm1_value
			LEFT JOIN static_data_type sdt_b ON sdt_b.type_id = sdv_b.type_id
				AND sdt_b.type_name = 'Contract Charge Type Group'
			LEFT JOIN static_data_value sdv_p ON sdv_p.value_id = gmv.clm4_value
			LEFT JOIN static_data_type sdt_p ON sdt_p.type_id = sdv_p.type_id
				AND sdt_p.type_name = 'Country'
			LEFT JOIN static_data_value sdv_r ON sdv_r.value_id = gmv.clm8_value
			LEFT JOIN static_data_type sdt_r ON sdt_r.type_id = sdv_r.type_id
				AND sdt_p.type_name = 'Contract Components'
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
			LEFT JOIN static_data_value sdv_g ON sdv_g.value_id = ISNULL(gmv.clm6_value,'')
			LEFT JOIN static_data_type sdt_g On sdt_g.type_id = sdv_g.type_id AND sdt_g.type_name = 'GSP group'
			--OUTER APPLY (SELECT * FROM #gsp_group_info  ggi WHERE ggi.value_id = sdv_g.value_id  OR gmv.clm6_value IS NULL)z
			LEFT JOIN static_data_value sdv_cbal   ON sdv_cbal.value_id = gmv.clm12_value 
			LEFT JOIN static_data_type sdt_cbal ON sdt_cbal.type_id = sdv_cbal.value_id  and sdt_cbal.type_name = 'GL Account Balance For Estimate'
			LEFT JOIN static_data_value sdv_lbal   ON sdv_lbal.value_id = gmv.clm16_value 
			LEFT JOIN static_data_type sdt_lbal ON sdt_lbal.type_id = sdv_lbal.value_id  and sdt_cbal.type_name = 'GL Account Balance For Estimate'
		WHERE ISNULL(cctd.contract_charge_type_id,0) =  CASE WHEN ISNULL(@template_id,0) =0 THEN    0 ELSE ISNULL(cctd.contract_charge_type_id,0) END
			AND (CAST(gmv.clm6_value as VARCHAR(200)) IN (SELECT CAST(VALUE_ID as VARCHAR(200)) FROM  #gsp_group_info) OR gmv.clm6_value IS NULL) 
			----AND gmv1.clm4_value = ISNULL(@double_booking,'n')
			AND ISNULL(gmv2.clm3_value,'n') = ISNULL(@entrepot_number,'n')
			AND ISNULL(gmv2.clm4_value,'n') = ISNULL(@ic_with_fiscal,'n')
			AND gmv.clm2_value = CASE WHEN gmv.clm2_value = 's' THEN 's' ELSE CASE WHEN a.invoice_type = 'r' then 'i' ELSE 'o' END END
		
		
			
Declare @primary_counterparty VARCHAR(25)
SELECT @primary_counterparty =counterparty_id FROM  fas_subsidiaries where fas_subsidiary_id = -1

 SELECT counterparty_Id as item into #counterparty_primary 
 FROM #calc_id
UNION ALL 
SELECT @primary_counterparty

SELECT * INTO #sap_gl_mapping_accural FROM #sap_gl_mapping_accural1  a WHERE clm5_value IN (SELECT item FROM #counterparty_primary)


		
	SELECT sgma.as_of_date
				,prod_date
				,invoice_number
				,citu.invoice_line_item_id
				,mapping_table_id
				,mapping_name
				,clm1_value
				,clm2_value
				,clm3_value
				,clm4_value
				,clm5_value
				,clm6_value
				,clm7_value
				,clm8_value
				,clm9_value
				,clm10_value
				,clm11_value
				,clm12_value
				,process
				,subprocess
				,country
				,Entity
				,product_group
				,products
				,Current_Year_General_Ledger
				,current_year_cost_center
				,Current_Year_Profit_Center
				,Last_Year_General_Ledger
				,Last_Year_Cost_Center
				,Last_Year_Profit_Center
				,IC_EXT
				,SAP
				,doc_type
				,region
				,[Entrepot-number]
				,IC
				,Curve
				,Curve_id
				,VAT_Code
				,VAT_GL_Account
				--,VAT_Code_Buy
				--,VAT_GL_Account_Buy
				,source_counterparty_id
				,sgma.counterparty_id
				,sgma.contract_id
				,contract_name
				,formula_ID
				,sequence_id
				,citu.calc_id
				,citu.value value
				,citu.volume Volume
				,citu.true_up_month
				,current_year_balance_center
				,last_year_balance_center
			INTO #sap_gl_mapping_trueup

 		FROM  #sap_gl_mapping_accural sgma
			INNER JOIN calc_invoice_true_up citu ON citu.contract_id = sgma.contract_id
				AND citu.counterparty_id = sgma.source_counterparty_id
				AND citu.as_of_date = @as_of_date
				AND citu.invoice_line_item_id = sgma.clm8_value
				AND is_final_result = 'y'
				--AND citu.true_up_calc_id IS NULL
				AND sgma.clm8_value IN (SELECT value_id FROM #delta) -- 300289
				--AND citu.calc_id = @calc_id
			INNER JOIN #calc_id ci on ci.calc_id = citu.calc_id
			OUTER APPLY (
				SELECT SUM(value) volume
				FROM calc_invoice_true_up ctu
				INNER JOIN formula_nested fn ON ctu.formula_id = fn.formula_group_id
					AND ctu.sequence_id = fn.sequence_order
					AND fn.show_value_id = 1200
					AND citu.true_up_month = ctu.true_up_month
				WHERE ctu.calc_id = citu.calc_id
				) citu1

				
			INSERT INTO #sap_export_data
	SELECT /*sequence number grouped by Buy/Sell*/
	
	sc2.source_counterparty_id
	,entity_code [2120_hardcode]
	,sgma.doc_type [TA_hardcode]
	,civv.settlement_date [prod_date]
	,YEAR(civv.settlement_date) [Year]
	,sc.currency_id [currency_id]
	,CASE 
		WHEN civv.invoice_type = 'i'
			THEN 'SELL ' 
			ELSE 'BUY ' 
		END [Buy/sell-h]
	,CONVERT(VARCHAR(16), right(newid(), 16)) [ST_ESTIMATE_hardcode]
	,'5' [5_hardcode]
	,civv.prod_date [Nxt Mth]
	,CASE 
		WHEN SUM(cfv.value) > 0
			THEN 50
		ELSE 40
		END [Buy/sell-d]
	,'' [BLank] -- cea1.external_value  SAP REceivable value
	,entity_code [2120_hardcode2]
	,'' [Blank_2]
	,CASE WHEN DATEDIFF ( yy , civv.settlement_date  ,civ.prod_date ) <0 THEN CAST(sgma.Last_Year_General_Ledger  AS VARCHAR(250)) ELSE CAST(sgma.Current_Year_General_Ledger AS VARCHAR(250)) END [Gl account]
	,CASE WHEN DATEDIFF ( yy , civv.settlement_date  ,civ.prod_date ) <0 THEN sgma.Last_Year_Cost_Center ELSE sgma.current_year_cost_center END [Cost encoding]
	,'' [Blank_3] 
	,'' [Blank_4]
	,'' [Blank_5]
	,round(SUM(civ.value), 2) [Value-D]
	,'' [VAT code estimate]
	,'' [Blank_6]
	,'' [Blank_7]
	,cea.external_value [counterparty_country]
	,sc2.counterparty_name + ' ' + gmv.clm7_value + ' ' + CASE 
		WHEN civv.invoice_type = 'i'
			THEN 'SELL ' + sc1.commodity_id + ' ' + cast(month(CAST(civv.prod_date AS VARCHAR(100))) AS VARCHAR(200)) + '-' + cast(YEAR(CAST(civv.prod_date AS VARCHAR(100))) AS VARCHAR(200))
		ELSE 'BUY ' + sc1.commodity_id + ' ' + cast(month(CAST(civv.prod_date AS VARCHAR(100))) AS VARCHAR(200)) + '-' + + cast(YEAR(CAST(civv.prod_date AS VARCHAR(100))) AS VARCHAR(200))
		END [PNL/BUYSELL]
	,CASE 
		WHEN civv.invoice_type = 'i'
			THEN sc2.counterparty_name + ' SELL ' + sc1.commodity_id + ' ' + cast(month(CAST(civv.prod_date AS VARCHAR(100))) AS VARCHAR(200)) + '-' + cast(YEAR(CAST(civv.prod_date AS VARCHAR(100))) AS VARCHAR(200))
		ELSE sc2.counterparty_name + ' BUY ' + sc1.commodity_id + ' ' + cast(month(CAST(civv.prod_date AS VARCHAR(100))) AS VARCHAR(200)) + '-' + cast(YEAR(CAST(civv.prod_date AS VARCHAR(100))) AS VARCHAR(200))
		END [counterparty_pnl_buysell]
	,sdv_clm12_value.[description]
	,
	-- summary
	/*sequence number grouped by Buy/Sell*/
	round(SUM(civ.value), 2) [Value-S]
	,0 [0_hardcoded]
	,0 [0_hardcoded2]
	,'ZSTOP Xellent GL' [ZSTOP Xellent GL-hardcode]
	,max(cea.external_value) [epa_external_value]
	,civv1.as_of_date
	,ISNULL(cg.contract_id,civv.contract_id) contract_id
	,MAX(ISNULL(su1.uom_desc,su1.uom_name)) uom_name
	,cast(YEAR(civv.prod_date) AS VARCHAR) + RIGHT('0' + CAST(month(civv.prod_date) AS VARCHAR), 2) delivery_period
	,CASE 
		WHEN civ.invoice_line_item_id = @vat
			THEN 0
		ELSE ROUND(sum(civ.Volume), 3)
		END AS Volume
	,sc2.counterparty_name
	,CASE WHEN DATEDIFF ( yy , civv.settlement_date  ,civ.prod_date ) <0 THEN sgma.Last_Year_Profit_Center ELSE sgma.Current_Year_Profit_Center END Current_Year_Profit_Center
	,'' VAT_Code_Buy
	,sgma.contract_name
	,sgma.VAT_Code
	--CASE WHEN sgma.clm5_value = sgma.source_counterparty_id
	--				THEN sgma.VAT_Code
	--			ELSE   sgma.VAT_Code
	--			END 
	,MAX(pat.PartnerID) [PartnerID]--CASE WHEN Double_booking = 'YES' THEN MAX(pat.PartnerID) ELSE '' END [PartnerID]
	,civv.calc_id
	,sgma.products,civ.invoice_line_item_id,MAX(double_booking),sgma.entity entity
		,non_efet_IC_Ext 
			,GSP_group 
			,current_year_balance_center 
			,last_year_balance_center
,CASE WHEN DATEDIFF ( yy , civv.settlement_date  ,civ.prod_date ) <0 THEN sgma.last_year_balance_center ELSE sgma.current_year_balance_center END Resultant_balance_center
,sc2.int_ext_flag,ic_with_fiscal,sgma.self_billing,sgma.invoice_type,civv.settlement_date

FROM   calc_invoice_volume_variance civv 
		INNER JOIN #counterparty c
			ON c.item  = civv.counterparty_id
		INNER JOIN #contract c1 ON c1.item = civv.contract_id
		INNER JOIN #calc_id ci ON ci.calc_id = civv.calc_id
		INNER JOIN (
				SELECT MAX(as_of_date) as_of_date,
					prod_date,
					settlement_date,
					counterparty_id,
					contract_id
				FROM   calc_invoice_volume_variance
				GROUP BY
					prod_date,
					settlement_date,
					counterparty_id,
					contract_id
				) civv1
					ON civv.as_of_date = civv1.as_of_date 
					AND civv.prod_date = civv1.prod_date
					AND civv.settlement_date = civv1.settlement_date 
					AND civv.counterparty_id = civv1.counterparty_id 
					AND civv.contract_id = civv1.contract_id   
			INNER JOIN calc_invoice_volume civ
					ON  civv.calc_id = civ.calc_id
					AND civ.invoice_line_item_id  NOT IN (SELECT  value_id FROM #VAT)
			LEFT JOIN #sap_gl_mapping_accural sgma ON 
				sgma.invoice_line_item_id = civ.invoice_line_item_id
			  AND 
			  sgma.source_counterparty_id = c.item AND sgma.contract_id = c1.item 		
			  AND sgma.invoice_line_item_id IS NOT NULL	
			LEFT JOIN calc_formula_value cfv
					ON  cfv.calc_id = civv.calc_id AND cfv.is_final_result = 'y' AND cfv.finalized ='s'
					AND cfv.invoice_line_item_id = civ.invoice_line_item_id
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
		
		LEFT JOIN source_commodity sc1
				ON  CAST(sdh.commodity_id AS VARCHAR(100)) = sc1.source_commodity_id
		LEFT JOIN contract_group cg
				ON  CAST(c1.item AS VARCHAR(100)) = cg.contract_id
				LEFT JOIN source_currency sc
				ON  coalesce(cg.currency,sdd.fixed_price_currency_id, sdd1.fixed_price_currency_id) = 
						sc.source_currency_id
		LEFT JOIN source_counterparty sc2
				ON  civv.counterparty_id = sc2.source_counterparty_id
		LEFT JOIN static_data_value country_sdv
				ON  sc2.country = country_sdv .value_id
		LEFT JOIN generic_mapping_header gmh
				ON  gmh.mapping_name = 'SAP GL Code Mapping'
		LEFT JOIN generic_mapping_definition gmd
				ON  gmd.mapping_table_id = gmh.mapping_table_id
		LEFT JOIN generic_mapping_values gmv
				ON  gmv.mapping_table_id = gmh.mapping_table_id
				AND gmv.clm1_value = CAST(ssbm.source_system_book_id1 AS VARCHAR(100))
				AND gmv.clm2_value = CAST(ssbm.source_system_book_id2 AS VARCHAR (100))
				AND gmv.clm3_value = CAST(ssbm.source_system_book_id3 AS VARCHAR (100))
				AND gmv.clm4_value = CAST(sdh.contract_id AS VARCHAR (100))
				AND gmv.clm5_value = CAST(sc.source_currency_id AS VARCHAR (100))
				AND gmv.clm6_value = (CASE WHEN civ.value > 0 THEN 's' ELSE 'b' END)
		LEFT JOIN gl_system_mapping gsm ON CAST(gsm.gl_number_id AS VARCHAR (100)) = gmv.clm9_value 
		LEFT JOIN static_data_value sdv_clm11_value ON CAST(sdv_clm11_value.value_id AS VARCHAR (100)) = gmv.clm11_value
		LEFT JOIN static_data_value sdv_clm13_value ON CAST(sdv_clm13_value.value_id AS VARCHAR (100)) = gmv.clm13_value
		LEFT JOIN static_data_value sdv_clm12_value ON CAST(sdv_clm12_value.value_id AS VARCHAR (100)) = gmv.clm12_value
		LEFT JOIN source_book sb_3 ON  sb_3.source_book_id = sdh.source_system_book_id3
		LEFT JOIN counterparty_epa_account cea ON sc2.source_counterparty_id = cea.counterparty_id
		AND external_type_id = @external_type_id
		LEFT JOIN counterparty_epa_account cea1 ON sc2.source_counterparty_id = cea1.counterparty_id
		AND cea1.external_type_id = @external_id
		LEFT JOIN source_uom su1 on su1.source_uom_id = ISNULL(civ.uom_id,cg.volume_uom)
		  
		CROSS APPLY (SELECT MAX(entity_code) as PartnerID FROM #sap_gl_mapping_accural WHERE ENTITY = CASE WHEN  sgma.ENTITY = 'EET' THEN 'RETAIL' ELSE 'EET' END ) pat
		
		WHERE  
		 civ.invoice_line_item_id <> @vat  AND ISNULL(sgma.Entity,'EET') IN ('EET',CASE WHEN Double_booking = 'YES' THEN 'Retail' ELSE '' END) 
		AND (civv.finalized IS NULL OR civv.finalized = 'n')
		AND  civv.settlement_date = @invoice_date --@prod_date
		AND civv.as_of_date= @as_of_date
		AND ISNULL(sgma.Entity,'EET') IN ('EET',CASE WHEN Double_booking = 'YES' THEN 'Retail' ELSE '' END)
		AND civ.value <> 0
		GROUP BY
		civv.prod_date,
		sc.currency_id,civv.contract_id,
		civv.invoice_type,
		sc2.counterparty_name,
		country_sdv.code,
		sc1.commodity_id,
		gmv.clm7_value,
		sdv_clm11_value.code,
		sdv_clm13_value.code,
		gsm.gl_account_number,
		sdv_clm12_value.[description],
		sb_3.source_book_name,
		civv.settlement_date,
		sc2.source_counterparty_id,
		civv1.as_of_date,
		cg.contract_id,
		cea.external_value,civ.invoice_line_item_id
		,sgma.current_year_general_ledger, sgma.current_year_cost_center, sgma.VAT_GL_Account,sgma.current_year_profit_center, sgma.doc_type,sgma.VAT_Code,sgma.contract_name,sgma.product_group 
		--,sgma.VAT_Code_Buy
		,sgma.VAT_Code,civv.calc_id,sgma.Last_Year_General_Ledger, sgma.Last_Year_Cost_Center,sgma.Last_Year_Profit_Center
		,sgma.entity,sgma.products,entity_code,Double_booking,non_efet_IC_Ext 
			,GSP_group 
			,current_year_balance_center 
			,last_year_balance_center,sgma.clm5_value , sgma.source_counterparty_id
	,sc2.int_ext_flag,ic_with_fiscal,sgma.self_billing,sgma.invoice_type,civ.prod_date
	


	 IF EXISTS(SELECT 1 FROM #sap_export_data WHERE double_booking = 'yes')
	 BEGIN
	 INSERT INTO #sap_export_data(source_counterparty_id,[2120_hardcode],TA_hardcode,prod_date,Year,currency_id,Buy_sell_h,ST_ESTIMATE_hardcode,[5_hardcode],[Nxt Mth],Buy_sell_d,BLank,[2120_hardcode2],Blank_2,Gl_account,Cost_encoding,Blank_3,Blank_4,Blank_5,[Value-D],VAT_code_estimate,Blank_6,Blank_7,counterparty_country,PNL_BUYSELL,counterparty_pnl_buysell,gl_ac_blnc_est,[Value-S],[0_hardcoded],[0_hardcoded2],ZSTOP_Xellent_GL_harcdode,epa_external_value,as_of_date,contract_id,UOM,delivery_period,Volume,counterparty_name,current_year_profit_center,TaxCodeBuy,contract_name,TaxCodesale,PartnerID,calc_id,products,invoice_lineitem,double_booking,entity_gas,non_efet_IC_Ext,gsp_group,current_year_balance_center,last_year_balance_center,resultant_balance_center,counterparty_type,ic_with_fiscal,self_billing)
			 Select source_counterparty_id,[2120_hardcode],TA_hardcode,prod_date,Year,currency_id,Buy_sell_h,ST_ESTIMATE_hardcode,[5_hardcode],[Nxt Mth],Buy_sell_d,BLank,[2120_hardcode2],Blank_2,Gl_account,Cost_encoding,Blank_3,Blank_4,Blank_5,[Value-D],VAT_code_estimate,Blank_6,Blank_7,counterparty_country,PNL_BUYSELL,counterparty_pnl_buysell,gl_ac_blnc_est,[Value-S],[0_hardcoded],[0_hardcoded2],ZSTOP_Xellent_GL_harcdode,epa_external_value,as_of_date,contract_id,UOM,delivery_period,Volume,counterparty_name,current_year_profit_center,TaxCodeBuy,contract_name,TaxCodesale,PartnerID,calc_id,products,invoice_lineitem,double_booking,'Retail' entity_gas,non_efet_IC_Ext,gsp_group,current_year_balance_center,last_year_balance_center,resultant_balance_center,counterparty_type,ic_with_fiscal,self_billing FROM #sap_export_data
		WHERE entity_gas IS NULL-- OR entity_gas = 'Retail'
	 END	

	 
	 
INSERT INTO #temp_sap_detail([column_2],
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
		[Buy_sell_h],
		[Order_detail],
		[Buy_sell_d],
		row_type,
		source_counterparty_id,
		contract_id,
		[uom],
		delivery_period,
		volume,
		TaxCodeBuy,
		[ProfitCenter],
		PartnerID,calc_id,entity_gas )
		SELECT		
				CAST(sed.[Gl_account] AS VARCHAR(100)) [column_2],
				MAX(sed.[BLank]) [column_3],
				MAX(sed.[BLank_2]) [column_4],
				MAX(sed.[Blank_5]) [column_5],
				sed.Cost_encoding [column_6],
				CAST(CAST(SUM(sed.[Value-D]) *CASE WHEN ISNULL(ENTITY_gas,'EET') = 'EET' THEN -1 ELSE  1 END  AS NUMERIC(38, 2)) AS VARCHAR(200)) 
					[column_7],
				
				CASE WHEN ic_with_fiscal = 'y' AND counterparty_type  = 'i' ANd double_Booking = 'yes' AND entity_gas = (CASE WHEN self_billing = 'y' THEN 'EET' ELSE  'Retail' END) THEN 'VV' ELSE sed.TaxCodeSale END [column_8],
				MAX(sed.counterparty_country) [column_9],
				MAX(sed.[Blank_6]) [column_10],
				MAX(sed.[Blank_7]) [column_11],
				--sed.PNL_BUYSELL [column_12],
				  MAX(sed.counterparty_name) + ' '+ MAX(sed.[Buy_sell_h])+ ' '+Products [column_12],--+' '+  MAX(delivery_period) 	
				MAX(sed.[Buy_sell_h]),
				1 [Order_detail],
				MAX(sed.[Buy_sell_d]),
				'a' row_type,
				source_counterparty_id,
				contract_id,
				MAX([uom]),
				MAX(delivery_period),
				SUM(CAST(volume as numeric(38,3))),
				TaxCodeBuy,
				MAX(current_year_profit_center) [ProfitCenter]
				,PartnerID,calc_id,ISNULL(entity_gas,'EET') entity_gas --NULLIF(entity_gas,'EET')
	 FROM   #sap_export_data sed
			 GROUP BY
				  --sed.[counterparty_pnl_buysell],
--				  sed.line_item,
				
				  source_counterparty_id,Products,
				  contract_ID,PartnerID,--sed.[counterparty_pnl_buysell],
					sed.delivery_period,calc_id,ISNULL(entity_gas,'EET'),sed.Cost_encoding,sed.TaxCodeSale,TaxCodeBuy,sed.[Gl_account],ic_with_fiscal,counterparty_type,double_Booking,entity_gas
					,self_billing
	UNION ALL 
		 SELECT DISTINCT
				CASE WHEN  DATEDIFF ( yy , sed.settlementdate  ,sglm.true_up_month ) <0  THEN Last_Year_General_Ledger ELSE  current_year_general_ledger END [column_2]
			,'' [column_3]
			,'' [column_4]
			,'' [column_5]
			,	CASE WHEN DATEDIFF ( yy , sed.settlementdate  ,sglm.true_up_month ) <0   THEN Last_year_cost_center ELSE sglm.current_year_cost_center  END [column_6]
			,CAST(CAST(sglm.[value] * CASE WHEN entity_gas = 'EET' THEN -1 ELSE 1 END AS NUMERIC(38, 2)) AS VARCHAR(200)) [column_7]
			,taxcodesale [column_8]
			,sed.counterparty_country [column_9]
			,'' [column_10]
			,'' [column_11]
			,sglm.counterparty_id + ' '+sed.[Buy_sell_h]+ ' '+sglm.Products [column_12]-- +' '+  delivery_period 
			,sed.[Buy_sell_h]
			,1 [Order_detail]
			,sed.[Buy_sell_d]
			,'a' row_type
			,sglm.source_counterparty_id
			,sglm.contract_id
			,[uom]
			,cast(YEAR(sglm.true_up_month) AS VARCHAR) + RIGHT('0' + CAST(month(sglm.true_up_month) AS VARCHAR), 2)  delivery_period
			,sglm.volume
			,sglm.VAT_Code
			,CASE WHEN DATEDIFF ( yy , sed.settlementdate  ,sglm.true_up_month ) <0   THEN sglm.Last_Year_Profit_Center ELSE sglm.current_year_Profit_Center  END [ProfitCenter]
			,PartnerID,sed.calc_id,NULLIF(entity_gas,'EET') entity_gas
	 FROM #sap_gl_mapping_trueup sglm
	
		INNER JOIN #sap_export_data sed ON sed.as_of_date = sglm.as_of_date
			AND sed.contract_id = sglm.contract_id
			AND sed.source_counterparty_id = sglm.source_counterparty_id
			AND sed.calc_id = sglm.calc_id
			AND taxcodesale = VAT_Code
	

     UNION ALL
			 SELECT  CAST(NULLIF(ISNULL([column_2] , ''), '')as VARCHAR),
				[column_3]
				,[column_4]
				,[column_5]
				,[column_6]
				,CAST([column_7] AS NUMERIC(38, 20))  * -1   [column_7]
				,[column_8]
				,[column_9]
				,[column_10]
				,[column_11]
				,[column_12]
				,[Buy_sell_h]
				, [Order_detail]
				,[Buy_sell_d]
				,'b' row_type
				,source_counterparty_id
				,contract_id
				,[uom]
				,delivery_period
				,volume VOLUME
				,TaxCodesale  TaxCodesale
				,[ProfitCenter][ProfitCenter]
				,[PartnerID],calc_id,entity_gas
	 	FROM
	 (
			SELECT
			CAST( sed.Resultant_balance_center as VARCHAR) [column_2],
				'' [column_3]
				,MAX(sed.[BLank_2]) [column_4]
				,MAX(sed.[Blank_5]) [column_5]
				,'' [column_6]
				,CAST(SUM(CAST(sed.[Value-D] AS NUMERIC(38, 2))) * CASE WHEN ISNULL(entity_gas,'EET') = 'EET' THEN -1 ELSE  1 END  AS VARCHAR(200)) [column_7]
				,'' [column_8]
				,sed.counterparty_country [column_9]
				,MAX(sed.[Blank_6]) [column_10]
				,MAX(sed.[Blank_7]) [column_11]
				, MAX(sed.counterparty_name) + ' '+ MAX(sed.[Buy_sell_h])+ ' '+MAX(sed.Products) [column_12]-- +' '+  MAX(delivery_period) 	
				,sed.[Buy_sell_h]
				,	2 [Order_detail]
				,sed.[Buy_sell_d]
				,'b' AS row_type
				,sed.source_counterparty_id
				,sed.contract_id
				,[uom]
				,delivery_period
				,sed.volume
				,TaxCodeSale
				,'' [ProfitCenter]
				, PartnerID,sed.calc_id,NULLIF(MAX(entity_gas),'EET') entity_gas
FROM #sap_export_data sed

			--LEFT JOIN #sap_gl_mapping_trueup sglm ON sed.as_of_date = sglm.as_of_date
			--	AND sed.contract_id = sglm.contract_id
			--	AND sed.source_counterparty_id = sglm.source_counterparty_id
			--	AND sed.calc_id = sglm.calc_id
			--	AND taxcodesale = VAT_Code
			GROUP BY sed.counterparty_country
				,sed.[Buy_sell_d]
				,sed.[Buy_sell_h]
				,sed.source_counterparty_id
				,sed.contract_id
				,[uom]
				,delivery_period
				,sed.volume
				,TaxCodeSale
				,sed.current_year_profit_center
				,sed.contract_name
				,PartnerID,sed.calc_id,
				--sglm.counterparty_id,
				entity_gas,sed.Resultant_balance_center,sed.[Gl_account],sed.Cost_encoding
	UNION ALL
	
			SELECT DISTINCT 
			CAST( CASE WHEN DATEDIFF ( yy , sed.settlementdate  ,sglm.true_up_month ) <0     THEN sglm.last_year_balance_center ELSE  sglm.current_year_balance_center END AS VARCHAR)  [column_2],
				'' [column_3]
				,'' [column_4]
				,'' [column_5]
				,'' [column_6]
				,CAST(CAST(sglm.[value] * CASE WHEN ISNULL(ENTITY_gas,'EET') = 'EET' THEN -1 ELSE  1 END  AS NUMERIC(38, 2)) AS VARCHAR(200)) [column_7]
				,'' [column_8]
				,sed.counterparty_country [column_9]
				,'' [column_10]
				,'' [column_11]
				, sed.counterparty_name + ' '+ sed.[Buy_sell_h]+ ' '+sglm.Products [column_12] -- +' '+  delivery_period 	 
				,sed.[Buy_sell_h]
				,	2 [Order_detail]
				,sed.[Buy_sell_d]
				,'a' row_type
				,sglm.source_counterparty_id
				,sglm.contract_id
				,[uom]
				,cast(YEAR(sglm.true_up_month) AS VARCHAR) + RIGHT('0' + CAST(month(sglm.true_up_month) AS VARCHAR), 2) delivery_period
				,sglm.volume
				,sglm.VAT_Code
				,'' [ProfitCenter]
				,PartnerID,sed.calc_id,NULLIF(entity_gas,'EET') entity_gas
	 FROM #sap_gl_mapping_trueup sglm
		INNER JOIN #sap_export_data sed ON sed.as_of_date = sglm.as_of_date
			AND sed.contract_id = sglm.contract_id
			AND sed.source_counterparty_id = sglm.source_counterparty_id
			AND sed.calc_id = sglm.calc_id
			AND taxcodesale = VAT_Code
	)a 
	--GROUP BY 
	--source_counterparty_id,contract_id,[uom],delivery_period,PartnerID,calc_id,entity_gas
	
	
	
	INSERT INTO #temp_sap_detail_with_sequence(
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
				, [Order]     
				,[Buy_sell_h] 
				,row_type 
				,source_counterparty_id 
				,contract_id  
				,[uom]  
				,delivery_period
				,volume 
				,TaxCodeBuy 
				, ProfitCenter 
				,PartnerID,calc_id,entity_gas  )
	SELECT 
		'I' [column_1]
		,sap_union.[column_2]
		,sap_union.[column_3]
		,sap_union.[column_4]
		,sap_union.[column_5]
		,sap_union.[column_6]
		,sap_union.[column_7]
		,sap_union.[column_8]
		,sap_union.[column_9]
		,sap_union.[column_10]
		,sap_union.[column_11]
		,sap_union.[column_12] [column_12]
		,2 [Order]
		,sap_union.[Buy_sell_h]
		,sap_union.row_type
		,source_counterparty_id
		,contract_id
		,[uom]
		,delivery_period
		,volume
		,TaxCodeBuy
		, ProfitCenter
		,PartnerID,calc_id,entity_gas
	FROM #temp_sap_detail sap_union
	ORDER BY DENSE_RANK() OVER (
			ORDER BY [Order_detail]
				,sap_union.[Buy_sell_h],calc_id
			)
		,sap_union.[column_9] DESC
	 
	END
	ELSE 
	BEGIN 
		PRINT 'Contract Type not found' 
	END
	
	

	
	SELECT 
			'H' [column_1],
			CAST(sed.[2120_hardcode] AS VARCHAR(50)) [column_2],
			CAST(sed.TA_hardcode AS VARCHAR(50)) [column_3],
			CASE WHEN invoice_type = 'i' THEN replace(CONVERT(VARCHAR(10), cast(DATEADD(m,1,sed.[Nxt Mth])-1 AS datetime),111), '/', '-') ELSE  replace(CONVERT(VARCHAR(10),cast(GETDATE() AS datetime),111), '/', '-')  END   [column_4],
			CAST(sed.[Year] AS VARCHAR(100)) [column_5],
			REPLACE(CONVERT(VARCHAR(10),cast(DATEADD(m,1,sed.[Nxt Mth])-1 AS datetime),111), '/', '-') [column_6],
			CAST(sed.currency_id AS VARCHAR(50)) [column_7],
			sed.[Buy_sell_h] [column_8],
			max(sed.[ST_ESTIMATE_hardcode]) [column_9],
			case WHEN MAX(sed.TA_hardcode) ='ST' THEN '' ELSE '05' END  [column_10],
			case WHEN MAX(sed.TA_hardcode)  ='ST' THEN '' ELSE replace(CONVERT(VARCHAR(10),CAST(DATEADD(m, 1, sed.[Nxt Mth]) AS DATETIME), 111), '/', '-') END [column_11],
			'' [column_12],
		    1 [Order],
			ROW_NUMBER() OVER(ORDER BY sed.[Buy_sell_h]) [distinct_value],
			'' row_type,
			source_counterparty_id,
			contract_id,''	[uom],
			'' delivery_period,
			'' volume,
			'' PartnerID, --MAX(PartnerID) 
			'' profitCenter,
			calc_id
			,ISNULL(entity_gas,'EET') entity_gas
		INTO #header
	 FROM   #sap_export_data sed
		 GROUP BY
		 sed.[Nxt Mth],
		 sed.[Year],
		 sed.currency_id,
			sed.[Buy_sell_h],
			sed.[2120_hardcode],sed.TA_hardcode,
			source_counterparty_id,
		   contract_id,	[uom],
			--sed.prod_date,
			--sed.[5_hardcode],
			delivery_period,
			--PartnerID,
			--current_year_profit_center,
			calc_id
			,ISNULL(entity_gas,'EET'),invoice_type


		 
			SELECT 'I' [column_1]
				,sap_union.[column_2]
				,cast(sap_union.[column_3] AS VARCHAR(200)) [column_3]
				,sap_union.[column_4]
				,sap_union.[column_5]
				,sap_union.[column_6]
				,CAST(SUM(CAST(sap_union.[column_7] AS numeric(38,2)))AS VARCHAR(250)) [column_7]
				,sap_union.[column_8]
				,sap_union.[column_9]
				, sap_union.[column_10]
				,sap_union.[column_11]
				,LEFT(sap_union.[column_12],50)[column_12]
				,2 [Order]
				,h.[distinct_value]
				,sap_union.row_type
				,h.source_counterparty_id
				,h.contract_id
				,sap_union.[uom]
				,sap_union.delivery_period
				,CAST(SUM(CAST(sap_union.volume AS numeric(38,3)))AS VARCHAR(250)) volume
				,sap_union.PartnerID
				,sap_union.ProfitCenter,sap_union.calc_id,sap_union.entity_gas
		INTO #detail
		FROM #temp_sap_detail_with_sequence sap_union
			INNER JOIN #header h ON h.[column_8] = sap_union.[Buy_sell_h]
				AND h.source_counterparty_id = sap_union.source_counterparty_id
				AND ISNULL(h.contract_id,0) = ISNULL(sap_union.contract_id,0)
				AND h.calc_id = sap_union.calc_id
				AND ISNULL(sap_union.entity_gas,'EET') = ISNULL(h.entity_gas,'EET')
			
			GROUP BY 
				sap_union.[column_2]
				,sap_union.[column_3] 
				,sap_union.[column_4]
				,sap_union.[column_5]
				,sap_union.[column_6]
				,sap_union.[column_8]
				,sap_union.[column_9]
				,sap_union.[column_10]
				,sap_union.[column_11]
				,sap_union.[column_12]
				,h.[distinct_value]
				,sap_union.row_type
				,h.source_counterparty_id
				,h.contract_id
				,sap_union.[uom]
				,sap_union.delivery_period
				,sap_union.PartnerID
				,sap_union.ProfitCenter,sap_union.calc_id,sap_union.entity_gas

				
END


IF @flag = 'a'
BEGIN 
	
	DECLARE @sql nvarchar(4000)
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
			 + '        [column_12] [Text] ' + char(10)
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
			 + '        [column_12] [Text] ,CAST(ABS(NULLIF(CAST(volume as float),CAST(0 as float))) as numeric(38,3))[Quantity], 
[uom] [Base Unit of Measure], 
delivery_period [SettlementPeriod],
			 ' + char(10)
			  + '        [row_type] [row_type],[process_id],partnerID,profitCenter,a.[distinct_value],source_counterparty_id,contract_id,calc_id,entity_gas' + char(10)    
			 + @str_batch_table + char(10)
			 + ' INTO '+char(10)+@process_table +char(10)+'FROM ( ' + char(10)
			
			 + '   SELECT  * , '+''''+@process_id+''''+'[process_id] FROM #header  ' + char(10)
			 + '   UNION ALL  ' + char(10)
			 + '   SELECT * , '+''''+@process_id+''''+'[process_id] FROM #detail where NULLIF(CAST(column_7 as float),0) IS  NOT NULL' + char(10)
			 + ') a ' + char(10)
			 + 'ORDER BY a.[distinct_value], [column_1]'

EXEC(@sql)
--return
IF @flag = 's'
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
					[Quantity], 
					[Base Unit of Measure], 
					[SettlementPeriod],
					[row_type],
					[Process_id],partnerID,profitCenter,distinct_value,source_counterparty_id,contract_id,entity_gas FROM '+@process_table + ' ORDER BY distinct_value,row_type')
 END
 END 
 
 ELSE IF @flag = 'p'
BEGIN 
DECLARE @sql_cond VARCHAR(MAX)

	CREATE TABLE #validate (message VARCHAR(100) COLLATE DATABASE_DEFAULT)
	SET @sql_cond = 'IF EXISTS(SELECT 1 FROM ' + @process_table + ' a INNER JOIN #counterparty c ON c.item = a.source_counterparty_id INNER JOIN #contract c1 on c1.item = a.contract_id where row_type = ''a'' AND [DOC_TYPE/CustomerID] IS NULL OR [REASON_REV/BankID] IS NULL OR [EXTENSION1-FIELD1/PartnerBankType] IS NULL )  
			OR  EXISTS(SELECT 1 FROM ' + @process_table + '  a INNER JOIN #counterparty c ON c.item = a.source_counterparty_id INNER JOIN #contract c1 on c1.item = a.contract_id where row_type = ''b'' AND ' + CASE WHEN @contract_type = 'standard' THEN +
			 '[COMP_CODE /AccountID] IS NULL OR ' ELSE '' END +  '  [PSTNG_Date/CostCenter] IS NULL OR [Header_Txt/TaxCode] IS NULL 
				OR [REF_DOC_NO/Allocation] IS NULL OR [Text] IS NULL)
				BEGIN
				INSERT #validate(message)
				SELECT ''Required fields are not filled. Please check exception report for more details.'' as message
				END
				ELSE 
				BEGIN
				INSERT #validate(message)
				SELECT ''true'' as message
				END
				'

				EXEC(@sql_cond)
	
			SELECT @validate = message FROM #validate 
			IF @validate = 'true'
			BEGIN
				SET @query = ''
				SET @query = '
						INSERT INTO settlement_export(counterparty_id, contract_id, as_of_date, invoice_date, type,document_header , comp_code,doc_type,doc_date,fisc_year,pstng_date,currency,header_txt,ref_doc_no,reason_rev,extension_field,text,quantity,base_unit_of_measure,settlement_period,distinct_value,row_type)
						SELECT   c.item,
								 c1.item,'
								 +''''+cast(ISNULL(@as_of_date,GETDATE()) AS VARCHAR)+''''+','
								 +''''+cast(ISNULL(@invoice_date,GETDATE())  AS VARCHAR)+''''+',
								 ''E'',
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
								[SettlementPeriod],
								[Distinct_value],[row_type]
						FROM   '+ @process_table +' a INNER JOIN #counterparty c ON c.item = a.source_counterparty_id INNER JOIN #contract c1 on c1.item = a.contract_id 
					
					
			'
			--Select * FROM settlement_export

			EXEC(@query)

	END
		SELECT @validate as Message
END 
  --'h' - display exception msg
 IF @flag= 'h' OR ( @flag = 'z' AND @display_result = 'y')
 BEGIN
 DECLARE @ct VARCHAR(300)
 CREATE TABLE #contract_type(contract_type VARCHAR(40) COLLATE DATABASE_DEFAULT)

 EXEC('INSERT INTO #contract_type(contract_type) 
 SELECT 
CASE WHEN MAX(ISNULL(standard_contract,''y'')) = ''y'' THEN ISNULL(sdv.code,''Standard'') ELSE ISNULL(sdv.code,''Non-Standard'') END  

FROM contract_group cg  
INNER JOIN Calc_invoice_Volume_variance civv ON civv.contract_id = cg.contract_id --AND civv.calc_id = @calc_id
INNER JOIN '+ @process_table +' ci ON ci.calc_id = civv.calc_id
LEFT JOIN static_data_value sdv ON cg.contract_type_def_id = sdv.value_id
LEFT JOIN static_data_type sdt ON sdt.type_id = sdv.type_id  AND sdt.type_name = ''Contract Type''
GROUP BY sdv.code')


 DECLARE @sql_code VARCHAR(MAX) 
 SELECT @ct = contract_type from #contract_type
 

 IF @ct = '_Standard' 
 BEGIN
 	SET @sql_code = 'INSERT INTO #sap_export_exception_data (column_name,counter_party,contract_name,recomendation) ' + CASE WHEN @contract_type = 'standard' THEN +
			'SELECT ''[COMP_CODE /AccountID]'',a.source_counterparty_id,a.contract_id,''Please setup missing data. Generic Mapping >> SAP GL Code Mapping >> GL Account OR
Generic Mapping >> SAP GL Code Mapping >> GL Account Balance for Estimate
'' FROM '+@process_table + ' a INNER JOIN #counterparty c ON c.item = a.source_counterparty_id INNER JOIN #contract c1 on c1.item = a.contract_id WHERE [DOCUMENT_HEADER/KeyField]  = ''I''  AND [COMP_CODE /AccountID] IS NULL 
			UNION ALL ' ELSE '' END +
			' SELECT ''[PSTNG_DATE/CostCenter]'',a.source_counterparty_id,a.contract_id,''Please setup missing data. Generic Mapping >> SAP GL Code Mapping >> Cost Encoding'' FROM '+@process_table + ' a INNER JOIN #counterparty c ON c.item = a.source_counterparty_id INNER JOIN #contract c1 on c1.item = a.contract_id  WHERE [DOCUMENT_HEADER/KeyField]  = ''I'' AND row_type = ''a'' AND [PSTNG_DATE/CostCenter] IS NULL 
			UNION ALL
			SELECT ''[Header_Txt/TaxCode]'',a.source_counterparty_id,a.contract_id,''Please setup missing data. Generic Mapping >> SAP GL Code Mapping >> VAT Code'' FROM '+@process_table + ' a INNER JOIN #counterparty c ON c.item = a.source_counterparty_id INNER JOIN #contract c1 on c1.item = a.contract_id WHERE [DOCUMENT_HEADER/KeyField]  = ''I'' AND [Header_Txt/TaxCode] IS NULL
			UNION ALL
			SELECT ''[REF_DOC_NO/Allocation]'',a.source_counterparty_id,a.contract_id,''Please setup missing data. Setup Counterparty >> External ID >> SAP Payable ID'' FROM '+@process_table + ' a INNER JOIN #counterparty c ON c.item = a.source_counterparty_id INNER JOIN #contract c1 on c1.item = a.contract_id WHERE [DOCUMENT_HEADER/KeyField]  = ''I'' AND [REF_DOC_NO/Allocation] IS NULL
			UNION ALL
			SELECT ''[Text]'',a.source_counterparty_id,a.contract_id,''Please setup missing data. Generic Mapping >> SAP GL Code Mapping >> PNL'' FROM '+@process_table + ' a INNER JOIN #counterparty c ON c.item = a.source_counterparty_id INNER JOIN #contract c1 on c1.item = a.contract_id WHERE [DOCUMENT_HEADER/KeyField]  = ''I'' AND [Text] IS NULL
			'
END
ELSE 
BEGIN
	SET @sql_code = 'INSERT INTO #sap_export_exception_data (column_name,counter_party,contract_name,recomendation) ' +-- CASE WHEN @contract_type = 'standard' THEN +
			'SELECT ''[COMP_CODE /AccountID]'',a.source_counterparty_id,a.contract_id,''Please setup missing data. Generic Mapping >> Non EFET SAP GL Mapping >> Current/Last Year General Ledger'' FROM '+@process_table + ' a INNER JOIN #counterparty c ON c.item = a.source_counterparty_id INNER JOIN #contract c1 on c1.item = a.contract_id WHERE [DOCUMENT_HEADER/KeyField]  = ''I''  AND [COMP_CODE /AccountID] IS NULL AND entity_gas = ''EET''
			UNION ALL '-- ELSE '' END 
			+
			'SELECT ''[COMP_CODE /AccountID]'',a.source_counterparty_id,a.contract_id,''Please setup missing data. Generic Mapping >> Non EFET SAP GL Mapping >> Current/Last Year Balance Ledger'' FROM '+@process_table + ' a INNER JOIN #counterparty c ON c.item = a.source_counterparty_id INNER JOIN #contract c1 on c1.item = a.contract_id WHERE [DOCUMENT_HEADER/KeyField]  = ''I''  AND [COMP_CODE /AccountID] IS NULL AND entity_gas is NULL
			UNION ALL '
			+
			' SELECT ''[PSTNG_DATE/CostCenter]'',a.source_counterparty_id,a.contract_id,''Please setup missing data. Generic Mapping >> Non EFET SAP GL Mapping >> Current/Last Year Cost Center'' FROM '+@process_table + ' a INNER JOIN #counterparty c ON c.item = a.source_counterparty_id INNER JOIN #contract c1 on c1.item = a.contract_id  WHERE [DOCUMENT_HEADER/KeyField]  = ''I'' AND row_type = ''a'' AND [PSTNG_DATE/CostCenter] IS NULL 
			UNION ALL
			SELECT ''[Header_Txt/TaxCode]'',a.source_counterparty_id,a.contract_id,''Please setup missing data. Generic Mapping >> Non EFET VAT Rule Mapping >> VAT Code Sale/Buy'' FROM '+@process_table + ' a INNER JOIN #counterparty c ON c.item = a.source_counterparty_id INNER JOIN #contract c1 on c1.item = a.contract_id WHERE [DOCUMENT_HEADER/KeyField]  = ''I'' AND [Header_Txt/TaxCode] IS NULL
			UNION ALL
			SELECT ''[REF_DOC_NO/Allocation]'',a.source_counterparty_id,a.contract_id,''Please setup missing data. Setup Counterparty >> External ID >> SAP Payable ID'' FROM '+@process_table + ' a INNER JOIN #counterparty c ON c.item = a.source_counterparty_id INNER JOIN #contract c1 on c1.item = a.contract_id WHERE [DOCUMENT_HEADER/KeyField]  = ''I'' AND [REF_DOC_NO/Allocation] IS NULL
			--UNION ALL
			--SELECT ''[Profit Center]'',a.source_counterparty_id,a.contract_id,''Please setup missing data. Generic Mapping >> Non EFET SAP GL Mapping >> Current/Last Year Profit Center'' FROM '+@process_table + ' a INNER JOIN #counterparty c ON c.item = a.source_counterparty_id INNER JOIN #contract c1 on c1.item = a.contract_id WHERE [DOCUMENT_HEADER/KeyField]  = ''I'' AND [profitCenter] IS NULL'	
END
	EXEC(@sql_code)
	IF @flag = 'z'
	BEGIN
		SELECT TOP 1 '','','',' <a href="#" onclick="alert_hyperlink(''SAP Exceptions'',''EXEC spa_SettlementExport_estimate \''h\'','+ CAST(@counterparty_id AS VARCHAR(10)) + ',' + CAST(@contract_id AS VARCHAR(10)) + ',\''' + CONVERT(VARCHAR(10),@as_of_date, 21) + '\'',\''' + CONVERT(VARCHAR(10),@invoice_date,21) + '\'', NULL,\''' + CAST(@process_id AS VARCHAR(250)) +'\'''',500,700)">Report</a>' recommendation
		FROM #sap_export_exception_data sed INNER JOIN source_counterparty sc ON sc.source_counterparty_id = sed.counter_party 
			INNER JOIN contract_group cg on cg.contract_id = sed.contract_name
	END
	ELSE
	BEGIN
		SELECT Distinct  column_name [Missing Column],sc.counterparty_name [Counterparty],cg.contract_name [Contract],recomendation [Recommendation] FROM #sap_export_exception_data sed 
		INNER JOIN source_counterparty sc ON sc.source_counterparty_id = sed.counter_party 
			INNER JOIN contract_group cg on cg.contract_id = sed.contract_name	
	END			
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
			[SettlementPeriod] '+ @str_batch_table + ' FROM ' + @process_table +' ORDER BY distinct_value')

	EXEC spa_register_event 20605, 20526, @process_table, 0, @process_id
END
 --***************** FOR BATCH PROCESSING **********************************    
 
    IF  @batch_process_id IS NOT NULL        
 
BEGIN        
	SELECT @str_batch_table = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL)
 
	EXEC(@str_batch_table)     
 
	DECLARE @report_name VARCHAR(100)
 
	SET @report_name = 'SAP Export Estimate'        
 
	SELECT @str_batch_table = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, GETDATE(),
				 'spa_SettlementExport_estimate', @report_name) 
 
	EXEC(@str_batch_table)     
 
END
 --********************************************************************
