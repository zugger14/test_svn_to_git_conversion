	BEGIN TRY
		BEGIN TRAN
	
	declare @new_ds_alias varchar(10) = 'ENSCV'
	/** IF DATA SOURCE ALIAS ALREADY EXISTS ON DESTINATION, RAISE ERROR **/
	if exists(select top 1 1 from data_source where alias = 'ENSCV' and name <> 'Enercity Settlement Checkout View')
	begin
		select top 1 @new_ds_alias = 'ENSCV' + cast(s.n as varchar(5))
		from seq s
		left join data_source ds on ds.alias = 'ENSCV' + cast(s.n as varchar(5))
		where ds.data_source_id is null
			and s.n < 10

		--RAISERROR ('Datasource alias already exists on system.', 16, 1);
	end

	DECLARE @report_id_data_source_dest INT 
	
	SELECT @report_id_data_source_dest = report_id
	FROM report r
	WHERE r.[name] = NULL
	IF NOT EXISTS (SELECT 1 
	           FROM data_source 
	           WHERE [name] = 'Enercity Settlement Checkout View'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	AND NOT EXISTS (SELECT 1 FROM map_function_category WHERE [function_name] = 'Enercity Settlement Checkout View' AND '106500' = '106501') 
	BEGIN
		INSERT INTO data_source([type_id], [name], [alias], [description], [tsql], report_id, system_defined,category)
		SELECT TOP 1 1 AS [type_id], 'Enercity Settlement Checkout View' AS [name], @new_ds_alias AS ALIAS, 'Enercity Settlement Checkout View' AS [description],null AS [tsql], @report_id_data_source_dest AS report_id,'0' AS [system_defined]
			,'106500' AS [category]
	END

	UPDATE data_source
	SET alias = @new_ds_alias, description = 'Enercity Settlement Checkout View'
	, [tsql] = CAST('' AS VARCHAR(MAX)) + 'DECLARE @_sql AS VARCHAR(MAX)

DECLARE @_sql1 AS VARCHAR(MAX)

DECLARE @_sql2 AS VARCHAR(MAX)

DECLARE @_sql3 AS VARCHAR(MAX)

DECLARE @_sql4 AS VARCHAR(MAX)

DECLARE @_sql5 AS VARCHAR(MAX)

DECLARE @_sql6 AS VARCHAR(MAX)

DECLARE @_sql7 AS VARCHAR(MAX)

DECLARE @_sql8 AS VARCHAR(MAX)

DECLARE @_sql11 AS VARCHAR(MAX)

DECLARE @_prod_date_from AS VARCHAR(10)

DECLARE @_prod_date_to AS VARCHAR(10)

DECLARE @_to_as_of_date VARCHAR(10) 

DECLARE @_as_of_date AS VARCHAR(10)

DECLARE @_counterparty_id AS VARCHAR(5000)

DECLARE @_contract_id AS VARCHAR(5000)

DECLARE @_charge_type_id VARCHAR(5000)

DECLARE @_create_ts_from VARCHAR(10)

DECLARE @_create_ts_to VARCHAR(10)

DECLARE @_update_ts_from VARCHAR(10)

DECLARE @_update_ts_to VARCHAR(10)

DECLARE @_source_deal_header_id VARCHAR(8000) --= 518 

DEClARE @_accounting_status VARCHAR(8000)

DECLARE @_invoice_type VARCHAR(8000)

DECLARE @_invoice_status VARCHAR(50)

DECLARE @_payment_date_from AS VARCHAR(100)

DECLARE @_payment_date_to AS VARCHAR(100)

DECLARE @_period_from VARCHAR(100)  --- not used

DECLARE @_period_to VARCHAR(100) --- not used

DECLARE @_stmt_invoice_id  VARCHAR(100) 

DECLARE @_accrual_or_final  VARCHAR(100)

DECLARE @_accounting_month VARCHAR(10) --=''2019-01-01''

SET NOCOUNT ON

IF ''@period_from'' <> ''NULL''

	SET @_period_from = ''@period_from''

IF ''@period_to'' <> ''NULL''

	SET @_period_to = ''@period_to''	

IF ''@payment_date_from'' <> ''NULL''

	SET @_payment_date_from = ''@payment_date_from''

IF ''@payment_date_to'' <> ''NULL''

	SET @_payment_date_to = ''@payment_date_to''	

IF ''@prod_date_from'' <> ''NULL''

	SET @_prod_date_from = ''@prod_date_from''	

IF ''@prod_date_to'' <> ''NULL''

	SET @_prod_date_to = ''@prod_date_to''	

IF ''@as_of_date'' <> ''NULL''  

      SET @_as_of_date = ''@as_of_date'' 

IF ''@to_as_of_date'' <> ''NULL''  

      SET @_to_as_of_date = ''@to_as_of_date''  

IF ''@counterparty_id'' <> ''NULL''

	SET @_counterparty_id = ''@counterparty_id''

IF ''@contract_id'' <> ''NULL''

  SET @_contract_id = ''@contract_id''		

IF ''@charge_type_id'' <> ''NULL''  

      SET @_charge_type_id = ''@charge_type_id''  	

IF ''@source_deal_header_id'' <> ''NULL''

	SET @_source_deal_header_id = ''@source_deal_header_id''

IF ''@accounting_status'' <> ''NULL''

	SET @_accounting_status = ''@accounting_status''

IF ''@invoice_type'' <> ''NULL''

	SET @_invoice_type = ''@invoice_type''

IF ''@invoice_status'' <> ''NULL''

	SET @_invoice_status = ''@invoice_status''

IF ''@create_ts_from'' <> ''NULL''

    SET @_create_ts_from = ''@create_ts_from''

IF ''@create_ts_to'' <> ''NULL''

    SET @_create_ts_to = ''@create_ts_to''

IF ''@update_ts_from'' <> ''NULL''

    SET @_update_ts_from = ''@update_ts_from''

IF ''@update_ts_to'' <> ''NULL''

    SET @_update_ts_to = ''@update_ts_to''

IF ''@stmt_invoice_id'' <> ''NULL''

	SET @_stmt_invoice_id = ''@stmt_invoice_id''

IF ''@accrual_or_final'' <> ''NULL''

	SET @_accrual_or_final = ''@accrual_or_final''

IF ''@accounting_month'' <> ''NULL''

	SET @_accounting_month = ''@accounting_month''

--SET @_source_deal_header_id = ''48396''

--SET @_prod_date_from = ''2019-01-01''

--SET @_prod_date_to = ''2019-01-31''

--SET @_accounting_month = ''2019-04-01''

IF OBJECT_ID(''tempdb..#stmt_void_data'') IS NOT NULL

BEGIN

	DROP TABLE #stmt_void_data

END

IF OBJECT_ID(''tempdb..#stmt_cross_invoice'') IS NOT NULL

BEGIN

	DROP TABLE #stmt_cross_invoice

END

IF OBJECT_ID(''tempdb..#checkout_void'') IS NOT NULL

BEGIN

	DROP TABLE #checkout_void

END

DECLARE @_stmt_orignal_invoice_id VARCHAR(100)

SET @_stmt_orignal_invoice_id = (select ISNULL(original_id_for_void,stmt_invoice_id)  from stmt_invoice where stmt_invoice_id = @_stmt_invoice_id)

create table #stmt_void_data

(stmt_invoice_orignal_void_id Nvarchar(500), stmt_invoice_id Nvarchar(500),  multiplier int, void_status Nvarchar(500), as_of_date date)

INSERT INTO #stmt_void_data

SELECT ISNULL(original_id_for_void,stmt_invoice_id)stmt_invoice_orignal_void_id , stmt_invoice_id, case when original_id_for_void is not null then -1 else 1 end,

CASE WHEN  original_id_for_void is not nULL then ''Voided'' else NULL end

, si.as_of_date

FROM  stmt_invoice  si where si.stmt_invoice_id = @_stmt_invoice_id

Create table #checkout_void

(stmt_checkout_id int , stmt_invoice_id int)

Insert into #checkout_void

SELECT a.stmt_checkout_id , stid.stmt_invoice_id FROM stmt_invoice si

        INNER JOIN stmt_invoice_detail stid ON si.stmt_invoice_id = stid.stmt_invoice_id

        OUTER APPLY( SELECT itm.item [stmt_checkout_id] FROM dbo.SplitCommaSeperatedValues(stid.description1) itm) a

		LEFT JOIN stmt_checkout stck ON stck.stmt_checkout_id = a.[stmt_checkout_id]

		LEFT JOIN  source_deal_detail sdd on sdd.source_deal_detail_id = stck.source_deal_detail_id		

        WHERE  si.stmt_invoice_id = @_stmt_invoice_id

		

Create table #stmt_cross_invoice

(stmt_invoice_id int, stmt_checkout_id int, source_deal_header_id int)

INSERT INTO #stmt_cross_invoice

--INNER JOIN dbo.FNASplit(@_source_deal_header_id, '','') a ON a.item = sdh.source_deal_header_id

SELECT si_b.stmt_invoice_id , a.[stmt_checkout_id], sdd.source_deal_header_id FROM stmt_invoice si

        INNER JOIN stmt_invoice_detail stid ON si.stmt_invoice_id = stid.stmt_invoice_id

		OUTER APPLY( SELECT itm.item [stmt_checkout_id] FROM dbo.SplitCommaSeperatedValues(stid.description1) itm) a

		LEFT JOIN stmt_checkout stck ON stck.stmt_checkout_id = a.[stmt_checkout_id]

		LEFT JOIN #checkout_void cv ON cv.stmt_checkout_id = a.stmt_checkout_id

		LEFT JOIN  source_deal_detail sdd on sdd.source_deal_detail_id = stck.source_deal_detail_id

		INNER JOIN stmt_invoice si_b ON si_b.stmt_invoice_id = cv.stmt_invoice_id AND ISNULL(si_b.is_voided,''n'') = ISNULL(si.is_voided,''n'')

        WHERE ISNULL(si_b.is_backing_sheet,''n'') = ''y'' and si.stmt_invoice_id = @_stmt_invoice_id

IF NOT EXISTS(select 1 from #stmt_cross_invoice)

BEGIN

SET @_sql = ''

SELECT 

	svd_m.stmt_invoice_id stmt_invoice_id,

	MAX(sco.as_of_date) [as_of_date],

	MAX(sco.as_of_date) [to_as_of_date],

	MAX(si.prod_date_from) [prod_date_from],

	MAX(si.prod_date_to) [prod_date_to],

	si.invoice_date [settlement_date],

	MAX(sc.counterparty_name) [counterparty_name],

	MAX(sc_si.accounting_code) [counterparty_accounting_code],

	MAX(sco.counterparty_id) [counterparty_id],

	cg.contract_name [contract_name],

	MAX(sco.contract_id) [contract_id],

	MAX(charge_type.description) AS [charge_type],

	sid.invoice_line_item_id [charge_type_id],

	CAST(dbo.FNARemoveTrailingZeroes(ROUND(AVG(ISNULL(sco.settlement_volume, 0)), 2)) AS DECIMAL(10,2)) * max(svd_m.multiplier)  [volume],

	MAX(su.uom_name) [uom],

	AVG(sdd.deal_volume) * max(svd_m.multiplier) [deal_volume],

	AVG(sco.settlement_amount) * max(svd_m.multiplier) [settlement_amount],

	ABS(AVG(sco.settlement_amount)) * max(svd_m.multiplier) [amount],

	MAX(cur.currency_name) [currency],

    SUM(sco.settlement_amount) / NULLIF(SUM(sco.settlement_volume),0) [price],

	svd_m.stmt_invoice_id [invoice_number],

	CASE si.invoice_type WHEN ''''i'''' THEN ''''Invoice'''' WHEN ''''r'''' THEN ''''Remittance'''' ELSE '''''''' END [invoice_type],

	MAX(sdv_is.code) [invoice_status],

	MAX(si.invoice_note) [invoice_notes],

	MAX(DATENAME(m,si.prod_date_from) +'''' ''''+ CAST(YEAR(si.prod_date_from) AS VARCHAR)) [invoice_subject],	

	CAST(dbo.FNARemoveTrailingZeroes(ROUND(SUM(sac.cash_received), 2)) AS DECIMAL(10,2))  [cash_received], 

	CAST(dbo.FNARemoveTrailingZeroes(ROUND(SUM(sac.variance_amount), 2)) AS DECIMAL(10,2))  [cash_receive_variance_amount], 

	MAX(sac.received_date) [cash_received_date],

	MAX(sco.debit_gl_number) [debit_gl_no.],

	MAX(sco.credit_gl_number) [credit_gl_no.],

	MAX(sdv_cta.code) [charge_type_alias],

	CASE si.invoice_type WHEN ''''r'''' THEN ''''Pay'''' ELSE ''''Receive'''' END [receive_pay],

	MAX(CASE WHEN sco.accrual_or_final= ''''a'''' THEN ''''a'''' ELSE ''''f'''' END) [accounting_status],

	CASE WHEN svd_m.void_status = ''''Voided'''' THEN svd_m.as_of_date ELSE si.invoice_date END [invoice_date],

	MAX(si.payment_date) [invoice_payment_date],

	MAX(si.create_ts) [create_ts],

	MAX(si.create_user) [create_user],

	MAX(si.update_ts) [update_ts],

	MAX(si.update_user) [update_user],

	MAX(crt.template_name) [invoice_template],

	MAX(CASE WHEN si.is_locked =''''y'''' THEN ''''Yes'''' ELSE ''''No'''' END) lock_status,

	''''@create_ts_from'''' [create_ts_from],

	''''@create_ts_to'''' [create_ts_to],

	''''@update_ts_from'''' [update_ts_from],

	''''@update_ts_to'''' [update_ts_to],

	sco.source_deal_detail_id [source_deal_detail_id],

	sdh.source_deal_header_id [source_deal_header_id],

	MIN(si.payment_date) [payment_date_from],

	MAX(si.payment_date) [payment_date_to],

	MAX(sdv_pli.code) [pnl_line_item],

	MAX(sdh.deal_id) [deal_reference],

	MAX(sdd.Leg) [Leg],

	CASE WHEN MAX(sdd.buy_sell_flag) = ''''b'''' THEN ''''Buy''''

		 WHEN MAX(sdd.buy_sell_flag) = ''''s'''' THEN ''''Sell'''' 

		 ELSE NULL 

	END [buy_sell],

	MAX(sdv3.code) [invoicing_charge_type],

	CASE WHEN MAX(sco.settlement_amount) > 0 THEN MAX(gsm_d.gl_account_number) ELSE MAX(gsm_d_minus.gl_account_number) END [Payment_Dr_GL_Code],  

	CASE WHEN MAX(sco.settlement_amount) > 0 THEN MAX(gsm_c.gl_account_number) ELSE MAX(gsm_c_minus.gl_account_number) END [Payment_Cr_GL_Code], 

	CASE WHEN MAX(sco.settlement_amount) > 0 THEN MAX(gsm_d.gl_account_name) ELSE MAX(gsm_d_minus.gl_account_name) END [Payment_Dr_GL_Name],  

	CASE WHEN MAX(sco.settlement_amount) > 0 THEN MAX(gsm_c.gl_account_name) ELSE MAX(gsm_c_minus.gl_account_name) END [Payment_Cr_GL_Name], 

	MAX(gsm.gl_account_number) [Debit_GL_Number],

	MAX(gsm1.gl_account_number) [Credit_GL_Number],

	MAX(gsm.gl_account_name) [Debit_account_name],

	MAX(gsm1.gl_account_name) [Credit_account_name],

	CASE WHEN MAX(sacd.settle_status) IS NULL AND MAX(sac1.settle_status) = ''''Partially Paid'''' THEN ''''Not Paid'''' WHEN MAX(sac1.settle_status) = ''''Fully Paid'''' THEN ''''Fully Paid'''' ELSE MAX(COALESCE(sacd.settle_status, sac.settle_status, ''''Not Paid'''')) END [payment_status],

	MAX(book.entity_name) book, 

	MAX(stra.entity_name) strategy, 

	MAX(subs.entity_name) subsidary, 

	MAX(ssbm.logical_name) sub_book,

	MAX(fassu.accounting_code) subsidiary_accounting_code,

	MAX(fasst.accounting_code) strategy_accounting_code,

	MAX(fasbo.accounting_code) book_accounting_code,

	MAX(ssbm.accounting_code) sub_book_accounting_code,

	MAX(sml.Location_Name) location_name,

	MAX(sml.accounting_code) location_accounting_code,

	MAX(smjl.Location_Name) location_group,

	MAX(sc1.commodity_id) commodity,

	MAX(sc1.accounting_code) commodity_accounting_code,

	MAX(ISNULL(sc1.commodity_desc, sc1.commodity_name)) commodity_description,

	MAX(cea_debtor.external_value) [accounting_receivable_id],

	MAX(cea_creditor.external_value) [accounting_payable_id],

	MAX(spcd.curve_name) [index],

	MAX(sdht.template_name) [template_name],

	--MAX(sdh.deal_id) [deal_id],

	MAX(sdt.source_deal_type_name) [deal_type_name],

	MAX(st.trader_name) trader,

	MAX(sdv_cnty.description) [country],

	MAX(sdv_region.code) [region],

	MAX(sdd.term_start) [term_start],   

	MAX(sdd.term_end) [term_end],

	MAX(CAST(YEAR(sdd.term_start) AS VARCHAR(5)) + ''''-'''' + RIGHT(''''0''''+ CAST(MONTH(sdd.term_start) AS VARCHAR(2)), 2))   [term_start_year_month],

	''''a'''' [actual_forward],

	MAX(ag_t.agg_term) [term_quarter],

	MAX(COALESCE(dbo.FNAInvoiceDueDate(sdd.term_start, cg.pnl_date, cg.holiday_calendar_id,10),sdd.term_end)) [pnl_date],

	CASE WHEN MAX(sdd.physical_financial_flag) = ''''p'''' THEN ''''Physical'''' ELSE ''''Financial''''   END [physical_financial_flag],

	si.invoice_number [invoice_id],

	''''Complete'''' [Pricing_Status],

	'''''''' [debit_credit],

	MAX(sdvgl1.code) [glcode1], 

	MAX(sdvgl2.code) [glcode2], 

	MAX(sdvgl3.code) [glcode3], 

	MAX(sdvgl4.code) [glcode4], 

	MAX(sdvgl5.code) [glcode5], 

	MAX(sdvgl6.code) [glcode6], 

	MAX(sdvgl7.code) [glcode7], 

	MAX(sdvgl8.code) [glcode8], 

	MAX(sdvgl9.code) [glcode9], 

	MAX(sdvgl10.code) [glcode10],

	MAX(sc.counterparty_desc) [counterparty_description],

	MAX(ISNULL(cc_receivables.name, cc.cc_name)) [counterparty_contact],

	MAX(ISNULL(cc_receivables.address1, cc.cc_address1)) [counterparty_address1],

	MAX(ISNULL(cc_receivables.address2, cc.cc_address2)) [counterparty_address2],

	MAX(ISNULL(cc_receivables.city, cc.cc_city)) counterparty_city,

	MAX(sdv_state.description) counterparty_state,

	MAX(ISNULL(cc_receivables.zip, cc.cc_zip)) counterparty_zip,

	

	 MAX(ISNULL(cc_receivables.telephone, cc.cc_phone))  counterparty_phone,

	MAX(ISNULL(cc_receivables.email, cc.cc_email)) counterparty_email,

	 MAX(ISNULL(cc_receivables.fax, cc.cc_fax)) counterparty_fax,

	

	MAX(fs_counterparty.counterparty_name) primary_counterparty,

	MAX(fs_counterparty.counterparty_desc) primary_counterparty_description,

	MAX(ccs.name) primary_counterparty_contact_name,

	MAX(ccs.address1) primary_counterparty_address1,

	MAX(ccs.address2) primary_counterparty_address2,

	MAX(ccs.city) primary_counterparty_city,

	MAX(sdv_p_state.code) primary_counterparty_state,

	MAX(COALESCE(ccs.zip, cc_receivables.zip)) primary_counterparty_zip,

	MAX(ccs.telephone) primary_counterparty_contact_telephone,

	MAX(ccs.email) primary_counterparty_email_address,

	MAX(ccs.fax) primary_counterparty_fax,

	MAX(cbi1.bank_name) AS primary_bank_name,

	MAX(cbi1.accountname) AS primary_account_name,

	MAX(cbi1.Account_no) AS primary_account_no,

	MAX(cbi1.wire_ABA) AS primary_iban,

	MAX(cbi1.ACH_ABA) AS primary_swift_no,

	MAX(cbi1.reference) AS primary_reference,

	MAX(sdh.internal_deal_subtype_value_id) internal_deal_subtype_value_id,

''

SET @_sql1 = ''

	MAX(sdh.deal_date) deal_date,

	MAX(cbi1.Address1) AS primary_counterparty_bank_address1,

	MAX(cbi1.Address2) AS primary_counterparty_bank_address2,

	MAX(sco.accounting_month) AS accounting_month,

	sco.accrual_or_final,

	sco.Deal_Charge_Type_ID,

	sdvgl11.code [Deal_Charge_Type],

	MAX(sco.type) [Calc_Type],

	MAX(sco.reversal_stmt_checkout_id) [reversal_stmt_checkout_id],

	MAX(sco.accounting_month) AS show_accounting_month,

	MAX(ISNULL(sdv_cc_c.description, cc.cc_country_name)) counterparty_country_name,

	MAX(ISNULL(sdv_cc_r.description, cc.cc_region_name)) counterparty_region_name,

	MAX(sec_sc.source_counterparty_id) secondary_counterparty_id,

	MAX(sec_sc.counterparty_name) secondary_counterparty_name,

	MAX(d_sc.source_commodity_id) source_commodity_id,

	MAX(d_sc.commodity_name) commodity_name,

	null vat_percentage,

	max(vt.vat_remarks) vat_remarks,

	max(vt.price_description) price_description,

	MAX(epa.external_value) counterparty_external_value,

	MAX(sec_cc.secondary_cc_address1) secondary_cc_address1, 

	MAX(sec_cc.secondary_cc_address2) secondary_cc_address2, 

	MAX(sec_cc.secondary_cc_city) secondary_cc_city

	, MAX(sdvc_css.description) primary_counterparty_country

, max(cbi1.primary_counterparty_bank_currency_id) [primary_counterparty_bank_currency_id]

, max(cbi1.primary_counterparty_bank_currency) [primary_counterparty_bank_currency]

, max(cbi1.primary_counterparty_bank_currency_name) primary_counterparty_bank_currency_name

, max(svd_m.void_status) void_status

, null [vat_rate]

INTO #temp_all_entries 

FROM stmt_checkout sco

INNER JOIN source_counterparty sc_si ON sc_si.source_counterparty_id = sco.counterparty_id

OUTER APPLY (SELECT MAX(create_ts) mx_create_ts FROM stmt_checkout sco1 

				WHERE sco.source_deal_detail_id = sco1.source_deal_detail_id

					AND sco.deal_charge_type_id = sco1.deal_charge_type_id

					AND sco.term_start = sco1.term_start

					AND sco.accounting_month = sco1.accounting_month

					AND sco.accrual_or_final = sco1.accrual_or_final

			) sco1

LEFT JOIN stmt_invoice_detail sid ON sco.stmt_invoice_detail_id = sid.stmt_invoice_detail_id

LEFT JOIN stmt_invoice si ON sid.stmt_invoice_id = si.stmt_invoice_id 

LEFT JOIN static_data_value charge_type ON charge_type.value_id = sid.invoice_line_item_id

LEFT JOIN source_currency cur ON cur.source_currency_id = sco.currency_id

LEFT JOIN static_data_value sdv_is ON sdv_is.value_id = si.invoice_status

LEFT JOIN stmt_apply_cash sac ON sac.stmt_invoice_detail_id = sid.stmt_invoice_detail_id

LEFT JOIN static_data_value sdv_cta on sdv_cta.value_id = sco.charge_type_alias

LEFT JOIN contract_report_template crt ON crt.template_id = si.invoice_template_id

LEFT JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = sco.source_deal_detail_id

LEFT JOIN static_data_value sdv_pli on sdv_pli.value_id = sco.pnl_line_item_id

LEFT JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id

LEFT JOIN match_group_detail mgd ON mgd.source_deal_detail_id = sdd.source_deal_detail_id  AND sco.accrual_or_final = ''''f''''

LEFT JOIN match_group_header mgh ON mgh.match_group_header_id = mgd.match_group_header_id

LEFT JOIN static_data_value sdv3 ON sdv3.value_id = sco.invoicing_charge_type_id 

OUTER APPLY (

	SELECT MAX(netting_contract_id) [contract] FROM stmt_invoice_netting

		WHERE contract_id = sco.contract_id AND stmt_invoice_id = si.stmt_invoice_id

) netting_contract

LEFT JOIN contract_group cg ON cg.contract_id = ISNULL(netting_contract.contract, sco.contract_id)

LEFT JOIN source_uom su ON su.source_uom_id = isnull(cg.volume_uom, sco.uom_id)

LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = sco.Counterparty_ID

LEFT JOIN source_minor_location sml ON sml.source_minor_location_id = sdd.location_id

OUTER APPLY(SELECT MAX(stmt_account_code_mapping_id) stmt_account_code_mapping_id FROM  stmt_account_code_mapping acm WHERE ISNULL(acm.buy_sell_flag,sdd.buy_sell_flag) = sdd.buy_sell_flag

		AND ISNULL(acm.source_deal_type_id,sdh.source_deal_type_id) = sdh.source_deal_type_id

		AND COALESCE(acm.source_deal_sub_type_id,sdh.deal_sub_type_type_id,-1) = ISNULL(sdh.deal_sub_type_type_id,-1)

		AND COALESCE(acm.commodity_id,sdh.commodity_id,-1) = ISNULL(sdh.commodity_id,-1)

		AND COALESCE(acm.location_id,sdd.location_id,-1) = ISNULL(sdd.location_id,-1)

		AND COALESCE(acm.location_group_id,sml.source_major_location_ID,-1) = ISNULL(sml.source_major_location_ID,-1)

		AND ISNULL(acm.template_id,sdh.template_id) = sdh.template_id

		AND COALESCE(acm.currency_id,cur.source_currency_id,-1) = ISNULL(cur.source_currency_id,-1)

		AND COALESCE(acm.counterparty_group,sc.type_of_entity,-1) = ISNULL(sc.type_of_entity,-1)

		AND COALESCE(acm.region,sc.region,-1) = ISNULL(sc.region,-1)

		AND COALESCE(acm.contract_id,ISNULL(netting_contract.contract, sco.contract_id),-1) = ISNULL(ISNULL(netting_contract.contract, sco.contract_id),-1)

		AND COALESCE(acm.counterparty_type,sc.int_ext_flag,''''-1'''') = ISNULL(sc.int_ext_flag,''''-1''''))acm1

LEFT JOIN stmt_account_code_chargetype acc ON acc.stmt_account_code_mapping_id = acm1.stmt_account_code_mapping_id

		AND (acc.deal_charge_type_id = sco.Deal_Charge_Type_ID OR acc.contract_charge_type_id = sco.Contract_Charge_Type_ID)

	OUTER APPLY(SELECT MAX(ISNULL(effective_date,''''9999-12-31'''')) effective_date 

		FROM stmt_account_code_gl WHERE stmt_account_code_chargetype_id = acc.stmt_account_code_chargetype_id AND effective_date <= sdd.term_start

	) acg1

LEFT JOIN stmt_account_code_gl acg ON acg.stmt_account_code_chargetype_id = acc.stmt_account_code_chargetype_id AND ISNULL(acg.effective_date,''''9999-12-31'''') = ISNULL(acg1.effective_date,''''9999-12-31'''')

LEFT JOIN adjustment_default_gl_codes adgc2 ON adgc2.default_gl_id  = acg.payment_gl_group

LEFT JOIN gl_system_mapping gsm_c ON gsm_c.gl_number_id = adgc2.credit_gl_number

LEFT JOIN gl_system_mapping gsm_c_minus ON gsm_c_minus.gl_number_id = adgc2.credit_gl_number_minus

LEFT JOIN gl_system_mapping gsm_d ON gsm_d.gl_number_id = adgc2.debit_gl_number

LEFT JOIN gl_system_mapping gsm_d_minus ON gsm_d_minus.gl_number_id = adgc2.debit_gl_number_minus

LEFT JOIN #stmt_void_data svd_m ON svd_m.stmt_invoice_orignal_void_id = sid.stmt_invoice_id

LEFT JOIN stmt_invoice_netting sin ON sin.stmt_invoice_id = si.stmt_invoice_id

	and sin.contract_id = cg.contract_id

--INNER JOIN index_fees_breakdown_settlement ifbs ON sdd.source_deal_header_id = ifbs.source_deal_header_id AND sdd.leg = ifbs.leg AND sdd.term_start = ifbs.term_start AND sdd.term_end = ifbs.term_end AND ifbs.field_id > 0

LEFT JOIN adjustment_default_gl_codes adgc ON adgc.default_gl_id = CASE WHEN ISNULL(sco.accrual_or_final,''''f'''') IN(''''a'''', ''''r'''') THEN acg.estimate_gl ELSE acg.final_gl END

''

SET @_sql11 =  ''

LEFT JOIN gl_system_mapping gsm ON gsm.gl_number_id = 

	CASE 

		WHEN sco.settlement_amount * -1 >= 0 AND sco.accrual_or_final IN (''''r'''',''''d'''') 

			THEN adgc.credit_gl_number 

		WHEN sco.settlement_amount * -1 < 0 AND sco.accrual_or_final IN (''''r'''',''''d'''') 

			THEN adgc.credit_gl_number_minus 

		WHEN sco.settlement_amount >= 0 

			THEN adgc.debit_gl_number 

		ELSE adgc.debit_gl_number_minus 

	END 

LEFT JOIN gl_system_mapping gsm1 ON gsm1.gl_number_id = 

	CASE 

		WHEN sco.settlement_amount * -1 >= 0 AND sco.accrual_or_final IN (''''r'''',''''d'''') THEN adgc.debit_gl_number 

		WHEN sco.settlement_amount * -1 < 0 AND sco.accrual_or_final IN (''''r'''',''''d'''') THEN  adgc.debit_gl_number_minus

		WHEN sco.settlement_amount >= 0 THEN adgc.credit_gl_number ELSE adgc.credit_gl_number_minus 	

	END 

INNER JOIN source_system_book_map ssbm

	ON ssbm.source_system_book_id1 = sdh.source_system_book_id1

	AND ssbm.source_system_book_id2 = sdh.source_system_book_id2

	AND ssbm.source_system_book_id3 = sdh.source_system_book_id3

	AND ssbm.source_system_book_id4 = sdh.source_system_book_id4

INNER JOIN portfolio_hierarchy book (NOLOCK) ON book.entity_id = ssbm.fas_book_id

INNER JOIN portfolio_hierarchy stra (NOLOCK) ON stra.entity_id = book.parent_entity_id

INNER JOIN portfolio_hierarchy subs (NOLOCK) ON subs.entity_id = stra.parent_entity_id

LEFT JOIN fas_books fasbo ON fasbo.fas_book_id = book.entity_id

LEFT JOIN fas_strategy fasst ON fasst.fas_strategy_id = stra.entity_id

LEFT JOIN fas_subsidiaries fassu ON fassu.fas_subsidiary_id = subs.entity_id

LEFT JOIN source_major_location smjl ON smjl.source_major_location_ID = sdd.location_id

LEFT JOIN source_minor_location sml1 ON smjl.source_major_location_ID = sml1.source_major_location_ID

LEFT JOIN source_commodity sc1 ON sc1.source_commodity_id = ISNULL(sdd.detail_commodity_id, sdh.commodity_id)

LEFT JOIN counterparty_epa_account cea_debtor ON cea_debtor.counterparty_id = sc.source_counterparty_id AND cea_debtor.external_type_id = 2202

LEFT JOIN counterparty_epa_account cea_creditor ON cea_creditor.counterparty_id = sc.source_counterparty_id AND cea_creditor.external_type_id = 2203

LEFT JOIN source_price_curve_def AS spcd ON  spcd.source_curve_def_id = sdd.curve_id

LEFT JOIN source_deal_header_template sdht ON  sdh.template_id = sdht.template_id

LEFT JOIN source_deal_type AS sdt ON  sdt.source_deal_type_id = sdh.source_deal_type_id 

LEFT JOIN source_traders st ON  st.source_trader_id = sdh.trader_id

LEFT JOIN static_data_value sdv_cnty ON  sdv_cnty.value_id = sml.country

LEFT JOIN static_data_value sdv_region ON  sdv_region.value_id = sml.region ''

SET @_sql2 =''

OUTER APPLY(

	SELECT TOP 1 

		CASE 

			WHEN MONTH(sdd.term_start)< MONTH(

                sco.as_of_date

                ) 

				AND YEAR(sdd.term_start)<= YEAR(sco.as_of_date) 

				THEN '''' '''' + CAST(YEAR(sdd.term_start) AS VARCHAR) + ''''-YTD'''' 

			WHEN MONTH(sdd.term_start)=MONTH(sco.as_of_date) 

				AND YEAR(sdd.term_start)=YEAR(sco.as_of_date) 

				THEN  CAST(YEAR(sdd.term_start) AS VARCHAR) + '''' - Current'''' 

			WHEN DATEPART(q,sco.as_of_date) =  DATEPART(q,sdd.term_start) 

				AND YEAR(sco.as_of_date) =  YEAR(sdd.term_start) 

				THEN  convert(varchar(4),sdd.term_start,120) +''''-''''+ ''''M'''' + CAST(DATEDIFF(m,sco.as_of_date,sdd.term_start) AS VARCHAR) +'''' ''''+ ''''('''' + UPPER(LEFT(DATENAME(MONTH,dateadd(MONTH, MONTH(sdd.term_start),-1)),3)) + '''')'''' 

			WHEN YEAR(sco.as_of_date) =  YEAR(sdd.term_start) 

				THEN  convert(varchar(4),sdd.term_start,120) + ''''-''''+ ''''Q'''' + CAST(DATEPART(q,sdd.term_start) AS VARCHAR) 

			ELSE CAST(YEAR(sdd.term_start) AS VARCHAR) END agg_term 

	FROM portfolio_mapping_tenor

) ag_t 

LEFT JOIN static_data_value sdvgl1 ON sdvgl1.value_id= ISNULL(gsm_d.gl_code_1,gsm_c.gl_code_1) 

LEFT JOIN static_data_value sdvgl2 ON sdvgl2.value_id= ISNULL(gsm_d.gl_code_2,gsm_c.gl_code_2) 

LEFT JOIN static_data_value sdvgl3 ON sdvgl3.value_id= ISNULL(gsm_d.gl_code_3,gsm_c.gl_code_3) 

LEFT JOIN static_data_value sdvgl4 ON sdvgl4.value_id= ISNULL(gsm_d.gl_code_4,gsm_c.gl_code_4) 

LEFT JOIN static_data_value sdvgl5 ON sdvgl5.value_id= ISNULL(gsm_d.gl_code_5,gsm_c.gl_code_5) 

LEFT JOIN static_data_value sdvgl6 ON sdvgl6.value_id= ISNULL(gsm_d.gl_code_6,gsm_c.gl_code_6) 

LEFT JOIN static_data_value sdvgl7 ON sdvgl7.value_id= ISNULL(gsm_d.gl_code_7,gsm_c.gl_code_7) 

LEFT JOIN static_data_value sdvgl8 ON sdvgl8.value_id= ISNULL(gsm_d.gl_code_8,gsm_c.gl_code_8) 

LEFT JOIN static_data_value sdvgl9 ON sdvgl9.value_id= ISNULL(gsm_d.gl_code_9,gsm_c.gl_code_9) 

LEFT JOIN static_data_value sdvgl10 ON sdvgl10.value_id= ISNULL(gsm_d.gl_code_10,gsm_c.gl_code_10) 

LEFT JOIN static_data_value sdvgl11 ON sdvgl11.value_id= sco.deal_charge_type_id

LEFT JOIN source_counterparty cii ON cii.source_counterparty_id = sco.counterparty_id

LEFT JOIN source_counterparty sc_parent ON sc_parent.source_counterparty_id = cii.netting_parent_counterparty_id

LEFT JOIN counterparty_contract_address cca ON cca.counterparty_id = sco.counterparty_id AND cca.contract_id = sco.contract_id

outer apply ( select *  FROM  source_counterparty sec_sc where  sec_sc.source_counterparty_id = cca.secondary_counterparty ) sec_sc

LEFT JOIN counterparty_contacts cc_payable ON cc_payable.counterparty_contact_id = ISNULL(cca.payables, sc_parent.payables)

LEFT JOIN counterparty_contacts cc_receivables ON cc_receivables.counterparty_contact_id = ISNULL(cca.receivables, sc_parent.receivables)

LEFT JOIN static_data_value sdv_cc_c ON sdv_cc_c.value_id = cc_receivables.country

LEFT JOIN static_data_value sdv_cc_r ON sdv_cc_r.value_id = cc_receivables.region

OUTER APPLY (

	SELECT address1 [cc_address1]

		, address2 [cc_address2]

		, zip [cc_zip]

		, city [cc_city]

		, state [cc_state]

		, [name] [cc_name]

		, cc.telephone [cc_phone]

		, fax [cc_fax]

		, cc.email [cc_email]

		, cc.country [cc_country]

		, cc.region [cc_region]

		, sdv_country.description [cc_country_name]

		, sdv_region.code [cc_region_name]

	FROM counterparty_contacts cc

	LEFT JOIN static_data_value sdv_country ON sdv_country.value_id =  cc.country and sdv_country.type_id = 14000

	LEFT JOIN static_data_value sdv_region ON sdv_region.value_id =  cc.region and sdv_region.type_id = 11150

	WHERE cc.counterparty_id = sco.counterparty_id AND cc.is_primary = ''''y'''' AND cc.is_active = ''''y''''

) cc

OUTER APPLY (

	SELECT address1 [secondary_cc_address1], address2 [secondary_cc_address2], city [secondary_cc_city]

	FROM counterparty_contacts cc

	WHERE cc.counterparty_id = sec_sc.source_counterparty_id AND cc.is_primary = ''''y'''' AND cc.is_active = ''''y''''

) sec_cc

LEFT JOIN fas_subsidiaries fs ON ISNULL(cg.sub_id, -1) = fs.fas_subsidiary_id

LEFT JOIN source_counterparty fs_counterparty ON fs.counterparty_id = fs_counterparty.source_counterparty_id

LEFT JOIN counterparty_contacts AS ccs ON CCS.counterparty_id = fs_counterparty.source_counterparty_id AND ccs.is_primary = ''''y''''

LEFT JOIN static_data_value sdvc_css ON sdvc_css.value_id =  ccs.country  and  sdvc_css.type_id = 14000

LEFT JOIN source_currency scu ON scu.source_currency_id = ISNULL(cg.currency, sdd.fixed_price_currency_id)

OUTER APPLY (

	SELECT TOP 1 cbi01.wire_ABA

		, cbi01.ACH_ABA

		, cbi01.bank_name

		, cbi01.Account_no

		, cbi01.accountname

		, cbi01.reference

		, cbi01.Address1

		, cbi01.Address2

		, sc.source_currency_id [primary_counterparty_bank_currency_id]

	    , sc.currency_id [primary_counterparty_bank_currency]

		, sc.currency_name [primary_counterparty_bank_currency_name]

	FROM counterparty_bank_info cbi01

	LEFT JOIN source_currency sc On  sc.source_currency_id = cbi01.currency

	WHERE cbi01.counterparty_id = fs_counterparty.source_counterparty_id

	ORDER BY cbi01.primary_account DESC

) cbi1

OUTER APPLY (SELECT sac1.stmt_invoice_detail_id, 

					CASE WHEN MIN(sac1.settle_status) = ''''s'''' THEN ''''Fully Paid'''' ELSE ''''Partially Paid'''' END [settle_status], 

					SUM(sac1.variance_amount) [variance_amount]

			FROM stmt_apply_cash sac1

			WHERE sac1.stmt_invoice_detail_id = sid.stmt_invoice_detail_id

			GROUP BY sac1.stmt_invoice_detail_id ) sac1

OUTER APPLY (SELECT 

					CASE WHEN sacd.settle_status = ''''s'''' THEN ''''Fully Paid'''' ELSE ''''Partially Paid'''' END  [settle_status] 

			FROM stmt_apply_cash_detail sacd

			WHERE sacd.stmt_invoice_detail_id = sac1.stmt_invoice_detail_id AND (sac1.settle_status = ''''Partially Paid'''' OR sac1.variance_amount <> 0) AND sacd.stmt_checkout_id = sco.stmt_checkout_id

			) sacd

LEFT JOIN static_data_value sdv_state ON sdv_state.value_id= ISNULL(cc_receivables.state, cc.cc_state) 

LEFT JOIN static_data_value sdv_p_state ON sdv_p_state.value_id= ccs.state

LEFT JOIN source_commodity d_sc ON d_sc.source_commodity_id = sdh.commodity_id

OUTER APPLY(

	SELECT gmv.clm13_value [vat_remarks], 

	case when gmv.clm8_value = ''''p'''' then ''''Positive'''' when  gmv.clm8_value = ''''n'''' then ''''Negative''''  when  gmv.clm8_value = ''''b'''' then''''Both'''' else NULL end [price_description]

	FROM generic_mapping_values gmv

	INNER JOIN generic_mapping_definition gmd ON gmv.mapping_table_id = gmd.mapping_table_id

	INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id

	LEFT JOIN static_data_value r_sdv ON r_sdv.value_id =  gmv.clm2_value

	LEFT JOIN source_commodity scm On scm.source_commodity_id = gmv.clm4_value

	WHERE 1=1 AND gmh.mapping_name = ''''Tax Rules'''' AND  gmv.clm10_value = ''''v'''' AND (ISNULL(gmv.clm3_value,-1) = ISNULL(sc.int_ext_flag, -1) AND ISNULL(gmv.clm2_value,-1) = ISNULL(cc.cc_region, -1)

	AND ISNULL(gmv.clm4_value, -1) = ISNULL(sdh.commodity_id,-1) AND  ISNULL(gmv.clm1_value, -1) <= ISNULL(sdd.term_start,-1))

	) vt

OUTER APPLY (

	SELECT TOP 1 cea.external_value 

	FROM counterparty_epa_account cea 

	WHERE cea.counterparty_id = sc.source_counterparty_id AND cea.external_type_id = 2200

) epa

WHERE 1 = 1 AND sco.create_ts = sco1.mx_create_ts AND ISNULL(sco.is_ignore, -1) <> 1

AND si.stmt_invoice_id = svd_m.stmt_invoice_orignal_void_id 

AND charge_type.description not like ''''%Tax%''''

AND charge_type.description not like ''''%VAT%'''' 

'' 

END

ELSE 

BEGIN

	SET @_sql = ''

SELECT 

	svd_m.stmt_invoice_id stmt_invoice_id,

	MAX(sco.as_of_date) [as_of_date],

	MAX(sco.as_of_date) [to_as_of_date],

	MAX(si.prod_date_from) [prod_date_from],

	MAX(si.prod_date_to) [prod_date_to],

	si.invoice_date [settlement_date],

	MAX(sc.counterparty_name) [counterparty_name],

	MAX(sc_si.accounting_code) [counterparty_accounting_code],

	MAX(sco.counterparty_id) [counterparty_id],

	cg.contract_name [contract_name],

	MAX(sco.contract_id) [contract_id],

	MAX(charge_type.description) AS [charge_type],

	sid.invoice_line_item_id [charge_type_id],

	CAST(dbo.FNARemoveTrailingZeroes(ROUND(AVG(ISNULL(sco.settlement_volume, 0)), 2)) AS DECIMAL(10,2)) * max(svd_m.multiplier)  [volume],

	MAX(su.uom_name) [uom],

	AVG(sdd.deal_volume) * max(svd_m.multiplier) [deal_volume],

	AVG(sco.settlement_amount) * max(svd_m.multiplier) [settlement_amount],

	ABS(AVG(sco.settlement_amount)) * max(svd_m.multiplier) [amount],

	MAX(cur.currency_name) [currency],

	SUM(sco.settlement_amount) / NULLIF(SUM(sco.settlement_volume),0) [Price],

	svd_m.stmt_invoice_id [invoice_number],

	CASE si.invoice_type WHEN ''''i'''' THEN ''''Invoice'''' WHEN ''''r'''' THEN ''''Remittance'''' ELSE '''''''' END [invoice_type],

	MAX(sdv_is.code) [invoice_status],

	MAX(si.invoice_note) [invoice_notes],

	MAX(DATENAME(m,si.prod_date_from) +'''' ''''+ CAST(YEAR(si.prod_date_from) AS VARCHAR)) [invoice_subject],	

	CAST(dbo.FNARemoveTrailingZeroes(ROUND(SUM(sac.cash_received), 2)) AS DECIMAL(10,2))  [cash_received], 

	CAST(dbo.FNARemoveTrailingZeroes(ROUND(SUM(sac.variance_amount), 2)) AS DECIMAL(10,2))  [cash_receive_variance_amount], 

	MAX(sac.received_date) [cash_received_date],

	MAX(sco.debit_gl_number) [debit_gl_no.],

	MAX(sco.credit_gl_number) [credit_gl_no.],

	MAX(sdv_cta.code) [charge_type_alias],

	CASE si.invoice_type WHEN ''''r'''' THEN ''''Pay'''' ELSE ''''Receive'''' END [receive_pay],

	MAX(CASE WHEN sco.accrual_or_final= ''''a'''' THEN ''''a'''' ELSE ''''f'''' END) [accounting_status],

	CASE WHEN svd_m.void_status = ''''Voided'''' THEN svd_m.as_of_date ELSE si.invoice_date END [invoice_date],

	MAX(si.payment_date) [invoice_payment_date],

	MAX(si.create_ts) [create_ts],

	MAX(si.create_user) [create_user],

	MAX(si.update_ts) [update_ts],

	MAX(si.update_user) [update_user],

	MAX(crt.template_name) [invoice_template],

	MAX(CASE WHEN si.is_locked =''''y'''' THEN ''''Yes'''' ELSE ''''No'''' END) lock_status,

	''''@create_ts_from'''' [create_ts_from],

	''''@create_ts_to'''' [create_ts_to],

	''''@update_ts_from'''' [update_ts_from],

	''''@update_ts_to'''' [update_ts_to],

	sco.source_deal_detail_id [source_deal_detail_id],

	sdh.source_deal_header_id [source_deal_header_id],

	MIN(si.payment_date) [payment_date_from],

	MAX(si.payment_date) [payment_date_to],

	MAX(sdv_pli.code) [pnl_line_item],

	MAX(sdh.deal_id) [deal_reference],

	MAX(sdd.Leg) [Leg],

	CASE WHEN MAX(sdd.buy_sell_flag) = ''''b'''' THEN ''''Buy''''

		 WHEN MAX(sdd.buy_sell_flag) = ''''s'''' THEN ''''Sell'''' 

		 ELSE NULL 

	END [buy_sell],

	MAX(sdv3.code) [invoicing_charge_type],

	CASE WHEN MAX(sco.settlement_amount) > 0 THEN MAX(gsm_d.gl_account_number) ELSE MAX(gsm_d_minus.gl_account_number) END [Payment_Dr_GL_Code],  

	CASE WHEN MAX(sco.settlement_amount) > 0 THEN MAX(gsm_c.gl_account_number) ELSE MAX(gsm_c_minus.gl_account_number) END [Payment_Cr_GL_Code], 

	CASE WHEN MAX(sco.settlement_amount) > 0 THEN MAX(gsm_d.gl_account_name) ELSE MAX(gsm_d_minus.gl_account_name) END [Payment_Dr_GL_Name],  

	CASE WHEN MAX(sco.settlement_amount) > 0 THEN MAX(gsm_c.gl_account_name) ELSE MAX(gsm_c_minus.gl_account_name) END [Payment_Cr_GL_Name], 

	MAX(gsm.gl_account_number) [Debit_GL_Number],

	MAX(gsm1.gl_account_number) [Credit_GL_Number],

	MAX(gsm.gl_account_name) [Debit_account_name],

	MAX(gsm1.gl_account_name) [Credit_account_name],

	CASE WHEN MAX(sacd.settle_status) IS NULL AND MAX(sac1.settle_status) = ''''Partially Paid'''' THEN ''''Not Paid'''' WHEN MAX(sac1.settle_status) = ''''Fully Paid'''' THEN ''''Fully Paid'''' ELSE MAX(COALESCE(sacd.settle_status, sac.settle_status, ''''Not Paid'''')) END [payment_status],

	MAX(book.entity_name) book, 

	MAX(stra.entity_name) strategy, 

	MAX(subs.entity_name) subsidary, 

	MAX(ssbm.logical_name) sub_book,

	MAX(fassu.accounting_code) subsidiary_accounting_code,

	MAX(fasst.accounting_code) strategy_accounting_code,

	MAX(fasbo.accounting_code) book_accounting_code,

	MAX(ssbm.accounting_code) sub_book_accounting_code,

	MAX(sml.Location_Name) location_name,

	MAX(sml.accounting_code) location_accounting_code,

	MAX(smjl.Location_Name) location_group,

	MAX(sc1.commodity_id) commodity,

	MAX(sc1.accounting_code) commodity_accounting_code,

	MAX(ISNULL(sc1.commodity_desc, sc1.commodity_name)) commodity_description,

	MAX(cea_debtor.external_value) [accounting_receivable_id],

	MAX(cea_creditor.external_value) [accounting_payable_id],

	MAX(spcd.curve_name) [index],

	MAX(sdht.template_name) [template_name],

	--MAX(sdh.deal_id) [deal_id],

	MAX(sdt.source_deal_type_name) [deal_type_name],

	MAX(st.trader_name) trader,

	MAX(sdv_cnty.description) [country],

	MAX(sdv_region.code) [region],

	MAX(sdd_d.term_start) [term_start],   

	MAX(sdd_d.term_end) [term_end],

	MAX(CAST(YEAR(sdd.term_start) AS VARCHAR(5)) + ''''-'''' + RIGHT(''''0''''+ CAST(MONTH(sdd.term_start) AS VARCHAR(2)), 2))   [term_start_year_month],

	''''a'''' [actual_forward],

	MAX(ag_t.agg_term) [term_quarter],

	MAX(COALESCE(dbo.FNAInvoiceDueDate(sdd.term_start, cg.pnl_date, cg.holiday_calendar_id,10),sdd.term_end)) [pnl_date],

	CASE WHEN MAX(sdd.physical_financial_flag) = ''''p'''' THEN ''''Physical'''' ELSE ''''Financial''''   END [physical_financial_flag],

	si.invoice_number [invoice_id],

	''''Complete'''' [Pricing_Status],

	'''''''' [debit_credit],

	MAX(sdvgl1.code) [glcode1], 

	MAX(sdvgl2.code) [glcode2], 

	MAX(sdvgl3.code) [glcode3], 

	MAX(sdvgl4.code) [glcode4], 

	MAX(sdvgl5.code) [glcode5], 

	MAX(sdvgl6.code) [glcode6], 

	MAX(sdvgl7.code) [glcode7], 

	MAX(sdvgl8.code) [glcode8], 

	MAX(sdvgl9.code) [glcode9], 

	MAX(sdvgl10.code) [glcode10],

	MAX(sc.counterparty_desc) [counterparty_description],

	MAX(ISNULL(cc_receivables.name, cc.cc_name)) [counterparty_contact],

	MAX(ISNULL(cc_receivables.address1, cc.cc_address1)) [counterparty_address1],

	MAX(ISNULL(cc_receivables.address2, cc.cc_address2)) [counterparty_address2],

	MAX(ISNULL(cc_receivables.city, cc.cc_city)) counterparty_city,

	MAX(sdv_state.description) counterparty_state,

	MAX(ISNULL(cc_receivables.zip, cc.cc_zip)) counterparty_zip,

	MAX(ISNULL(cc_receivables.telephone, cc.cc_phone))  counterparty_phone,

	MAX(ISNULL(cc_receivables.email, cc.cc_email)) counterparty_email,

	 MAX(ISNULL(cc_receivables.fax, cc.cc_fax)) counterparty_fax,

	MAX(fs_counterparty.counterparty_name) primary_counterparty,

	MAX(fs_counterparty.counterparty_desc) primary_counterparty_description,

	MAX(ccs.name) primary_counterparty_contact_name,

	MAX(ccs.address1) primary_counterparty_address1,

	MAX(ccs.address2) primary_counterparty_address2,

	MAX(ccs.city) primary_counterparty_city,

	MAX(sdv_p_state.code) primary_counterparty_state,

	MAX(COALESCE(ccs.zip, cc_receivables.zip)) primary_counterparty_zip,

	MAX(ccs.telephone) primary_counterparty_contact_telephone,

	MAX(ccs.email) primary_counterparty_email_address,

	MAX(ccs.fax) primary_counterparty_fax,

	MAX(cbi1.bank_name) AS primary_bank_name,

	MAX(cbi1.accountname) AS primary_account_name,

	MAX(cbi1.Account_no) AS primary_account_no,

	MAX(cbi1.wire_ABA) AS primary_iban,

	MAX(cbi1.ACH_ABA) AS primary_swift_no,

	MAX(cbi1.reference) AS primary_reference,

	MAX(sdh.internal_deal_subtype_value_id) internal_deal_subtype_value_id,

''

SET @_sql1 = ''

	MAX(sdh.deal_date) deal_date,

	MAX(cbi1.Address1) AS primary_counterparty_bank_address1,

	MAX(cbi1.Address2) AS primary_counterparty_bank_address2,

	MAX(sco.accounting_month) AS accounting_month,

	sco.accrual_or_final,

	sco.Deal_Charge_Type_ID,

	sdvgl11.code [Deal_Charge_Type],

	MAX(sco.type) [Calc_Type],

	MAX(sco.reversal_stmt_checkout_id) [reversal_stmt_checkout_id],

	MAX(sco.accounting_month) AS show_accounting_month,

	MAX(ISNULL(sdv_cc_c.description, cc.cc_country_name)) counterparty_country_name,

	ISNULL(MAX(sdv_cc_r.description), MAX(cc.cc_region_name)) counterparty_region_name,

	MAX(sec_sc.source_counterparty_id) secondary_counterparty_id,

	MAX(sec_sc.counterparty_name) secondary_counterparty_name,

	MAX(d_sc.source_commodity_id) source_commodity_id,

	MAX(d_sc.commodity_name) commodity_name,

	NULL vat_percentage,

	MAX(vt.vat_remarks)  vat_remarks,

	MAX(vt.price_description) price_description,

	MAX(epa.external_value) counterparty_external_value,

	MAX(sec_cc.secondary_cc_address1) secondary_cc_address1, 

	MAX(sec_cc.secondary_cc_address2) secondary_cc_address2, 

	MAX(sec_cc.secondary_cc_city) secondary_cc_city

	, MAX(sdvc_css.description) primary_counterparty_country

, max(cbi1.primary_counterparty_bank_currency_id) [primary_counterparty_bank_currency_id]

, max(cbi1.primary_counterparty_bank_currency) [primary_counterparty_bank_currency]

, max(cbi1.primary_counterparty_bank_currency_name) primary_counterparty_bank_currency_name

, max(svd_m.void_status) void_status

, null vat_rate

INTO #temp_all_entries 

FROM stmt_invoice si 

LEFT JOIN stmt_invoice_detail sid ON sid.stmt_invoice_id = si.stmt_invoice_id 

LEFT JOIN #stmt_cross_invoice scin ON scin.stmt_invoice_id = si.stmt_invoice_id

LEFT JOIN stmt_checkout sco ON sco.stmt_checkout_id = scin.stmt_checkout_id

INNER JOIN source_counterparty sc_si ON sco.counterparty_id = sc_si.source_counterparty_id

OUTER APPLY (SELECT MAX(create_ts) mx_create_ts FROM stmt_checkout sco1 

				WHERE sco.source_deal_detail_id = sco1.source_deal_detail_id

					AND sco.deal_charge_type_id = sco1.deal_charge_type_id

					AND sco.term_start = sco1.term_start

					AND sco.accounting_month = sco1.accounting_month

					AND sco.accrual_or_final = sco1.accrual_or_final

			) sco1

LEFT JOIN static_data_value charge_type ON charge_type.value_id = sid.invoice_line_item_id

LEFT JOIN source_currency cur ON cur.source_currency_id = sco.currency_id

LEFT JOIN static_data_value sdv_is ON sdv_is.value_id = si.invoice_status

LEFT JOIN stmt_apply_cash sac ON sac.stmt_invoice_detail_id = sid.stmt_invoice_detail_id

LEFT JOIN static_data_value sdv_cta on sdv_cta.value_id = sco.charge_type_alias

LEFT JOIN contract_report_template crt ON crt.template_id = si.invoice_template_id

LEFT JOIN source_deal_header sdh ON sdh.source_deal_header_id = scin.source_deal_header_id

LEFT JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id

LEFT JOIN source_deal_detail sdd_d ON sdd_d.source_deal_header_id = sdh.source_deal_header_id

		AND sdd_d.term_start = si.prod_date_from

		AND sdd_d.term_end = si.prod_date_to

LEFT JOIN static_data_value sdv_pli on sdv_pli.value_id = sco.pnl_line_item_id

LEFT JOIN match_group_detail mgd ON mgd.source_deal_detail_id = sdd.source_deal_detail_id  AND sco.accrual_or_final = ''''f''''

LEFT JOIN match_group_header mgh ON mgh.match_group_header_id = mgd.match_group_header_id

LEFT JOIN static_data_value sdv3 ON sdv3.value_id = sco.invoicing_charge_type_id 

OUTER APPLY (

	SELECT MAX(netting_contract_id) [contract] FROM stmt_invoice_netting

		WHERE contract_id = sco.contract_id AND stmt_invoice_id = si.stmt_invoice_id

) netting_contract

LEFT JOIN contract_group cg ON cg.contract_id = ISNULL(netting_contract.contract, sco.contract_id)

LEFT JOIN source_uom su ON su.source_uom_id = isnull(cg.volume_uom, sco.uom_id)

LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = sco.Counterparty_ID

LEFT JOIN source_minor_location sml ON sml.source_minor_location_id = sdd.location_id

OUTER APPLY(SELECT MAX(stmt_account_code_mapping_id) stmt_account_code_mapping_id FROM  stmt_account_code_mapping acm WHERE ISNULL(acm.buy_sell_flag,sdd.buy_sell_flag) = sdd.buy_sell_flag

		AND ISNULL(acm.source_deal_type_id,sdh.source_deal_type_id) = sdh.source_deal_type_id

		AND COALESCE(acm.source_deal_sub_type_id,sdh.deal_sub_type_type_id,-1) = ISNULL(sdh.deal_sub_type_type_id,-1)

		AND COALESCE(acm.commodity_id,sdh.commodity_id,-1) = ISNULL(sdh.commodity_id,-1)

		AND COALESCE(acm.location_id,sdd.location_id,-1) = ISNULL(sdd.location_id,-1)

		AND COALESCE(acm.location_group_id,sml.source_major_location_ID,-1) = ISNULL(sml.source_major_location_ID,-1)

		AND ISNULL(acm.template_id,sdh.template_id) = sdh.template_id

		AND COALESCE(acm.currency_id,cur.source_currency_id,-1) = ISNULL(cur.source_currency_id,-1)

		AND COALESCE(acm.counterparty_group,sc.type_of_entity,-1) = ISNULL(sc.type_of_entity,-1)

		AND COALESCE(acm.region,sc.region,-1) = ISNULL(sc.region,-1)

		AND COALESCE(acm.contract_id,ISNULL(netting_contract.contract, sco.contract_id),-1) = ISNULL(ISNULL(netting_contract.contract, sco.contract_id),-1)

		AND COALESCE(acm.counterparty_type,sc.int_ext_flag,''''-1'''') = ISNULL(sc.int_ext_flag,''''-1''''))acm1

LEFT JOIN stmt_account_code_chargetype acc ON acc.stmt_account_code_mapping_id = acm1.stmt_account_code_mapping_id

		AND (acc.deal_charge_type_id = sco.Deal_Charge_Type_ID OR acc.contract_charge_type_id = sco.Contract_Charge_Type_ID)

	OUTER APPLY(SELECT MAX(ISNULL(effective_date,''''9999-12-31'''')) effective_date 

		FROM stmt_account_code_gl WHERE stmt_account_code_chargetype_id = acc.stmt_account_code_chargetype_id AND effective_date <= sdd.term_start

	) acg1

LEFT JOIN stmt_account_code_gl acg ON acg.stmt_account_code_chargetype_id = acc.stmt_account_code_chargetype_id AND ISNULL(acg.effective_date,''''9999-12-31'''') = ISNULL(acg1.effective_date,''''9999-12-31'''')

LEFT JOIN adjustment_default_gl_codes adgc2 ON adgc2.default_gl_id  = acg.payment_gl_group

LEFT JOIN gl_system_mapping gsm_c ON gsm_c.gl_number_id = adgc2.credit_gl_number

LEFT JOIN gl_system_mapping gsm_c_minus ON gsm_c_minus.gl_number_id = adgc2.credit_gl_number_minus

LEFT JOIN gl_system_mapping gsm_d ON gsm_d.gl_number_id = adgc2.debit_gl_number

LEFT JOIN gl_system_mapping gsm_d_minus ON gsm_d_minus.gl_number_id = adgc2.debit_gl_number_minus

LEFT JOIN #stmt_void_data svd_m ON svd_m.stmt_invoice_orignal_void_id = sid.stmt_invoice_id

LEFT JOIN stmt_invoice_netting sin ON sin.stmt_invoice_id = si.stmt_invoice_id

	and sin.contract_id = cg.contract_id ''

SET @_sql11 = ''

LEFT JOIN adjustment_default_gl_codes adgc ON adgc.default_gl_id = CASE WHEN ISNULL(sco.accrual_or_final,''''f'''') IN(''''a'''', ''''r'''') THEN acg.estimate_gl ELSE acg.final_gl END

LEFT JOIN gl_system_mapping gsm ON gsm.gl_number_id = 

	CASE 

		WHEN sco.settlement_amount * -1 >= 0 AND sco.accrual_or_final IN (''''r'''',''''d'''') 

			THEN adgc.credit_gl_number 

		WHEN sco.settlement_amount * -1 < 0 AND sco.accrual_or_final IN (''''r'''',''''d'''') 

			THEN adgc.credit_gl_number_minus 

		WHEN sco.settlement_amount >= 0 

			THEN adgc.debit_gl_number 

		ELSE adgc.debit_gl_number_minus 

	END 

LEFT JOIN gl_system_mapping gsm1 ON gsm1.gl_number_id = 

	CASE 

		WHEN sco.settlement_amount * -1 >= 0 AND sco.accrual_or_final IN (''''r'''',''''d'''') THEN adgc.debit_gl_number 

		WHEN sco.settlement_amount * -1 < 0 AND sco.accrual_or_final IN (''''r'''',''''d'''') THEN  adgc.debit_gl_number_minus

		WHEN sco.settlement_amount >= 0 THEN adgc.credit_gl_number ELSE adgc.credit_gl_number_minus 	

	END 

INNER JOIN source_system_book_map ssbm

	ON ssbm.source_system_book_id1 = sdh.source_system_book_id1

	AND ssbm.source_system_book_id2 = sdh.source_system_book_id2

	AND ssbm.source_system_book_id3 = sdh.source_system_book_id3

	AND ssbm.source_system_book_id4 = sdh.source_system_book_id4

INNER JOIN portfolio_hierarchy book (NOLOCK) ON book.entity_id = ssbm.fas_book_id

INNER JOIN portfolio_hierarchy stra (NOLOCK) ON stra.entity_id = book.parent_entity_id

INNER JOIN portfolio_hierarchy subs (NOLOCK) ON subs.entity_id = stra.parent_entity_id

LEFT JOIN fas_books fasbo ON fasbo.fas_book_id = book.entity_id

LEFT JOIN fas_strategy fasst ON fasst.fas_strategy_id = stra.entity_id

LEFT JOIN fas_subsidiaries fassu ON fassu.fas_subsidiary_id = subs.entity_id

LEFT JOIN source_major_location smjl ON smjl.source_major_location_ID = sdd.location_id

LEFT JOIN source_minor_location sml1 ON smjl.source_major_location_ID = sml1.source_major_location_ID

LEFT JOIN source_commodity sc1 ON sc1.source_commodity_id = ISNULL(sdd.detail_commodity_id, sdh.commodity_id)

LEFT JOIN counterparty_epa_account cea_debtor ON cea_debtor.counterparty_id = sc.source_counterparty_id AND cea_debtor.external_type_id = 2202

LEFT JOIN counterparty_epa_account cea_creditor ON cea_creditor.counterparty_id = sc.source_counterparty_id AND cea_creditor.external_type_id = 2203

LEFT JOIN source_price_curve_def AS spcd ON  spcd.source_curve_def_id = sdd.curve_id

LEFT JOIN source_deal_header_template sdht ON  sdh.template_id = sdht.template_id

LEFT JOIN source_deal_type AS sdt ON  sdt.source_deal_type_id = sdh.source_deal_type_id 

LEFT JOIN source_traders st ON  st.source_trader_id = sdh.trader_id

LEFT JOIN static_data_value sdv_cnty ON  sdv_cnty.value_id = sml.country

LEFT JOIN static_data_value sdv_region ON  sdv_region.value_id = sml.region ''

SET @_sql2 =''

OUTER APPLY(

	SELECT TOP 1 

		CASE 

			WHEN MONTH(sdd.term_start)< MONTH(

                sco.as_of_date

                ) 

				AND YEAR(sdd.term_start)<= YEAR(sco.as_of_date) 

				THEN '''' '''' + CAST(YEAR(sdd.term_start) AS VARCHAR) + ''''-YTD'''' 

			WHEN MONTH(sdd.term_start)=MONTH(sco.as_of_date) 

				AND YEAR(sdd.term_start)=YEAR(sco.as_of_date) 

				THEN  CAST(YEAR(sdd.term_start) AS VARCHAR) + '''' - Current'''' 

			WHEN DATEPART(q,sco.as_of_date) =  DATEPART(q,sdd.term_start) 

				AND YEAR(sco.as_of_date) =  YEAR(sdd.term_start) 

				THEN  convert(varchar(4),sdd.term_start,120) +''''-''''+ ''''M'''' + CAST(DATEDIFF(m,sco.as_of_date,sdd.term_start) AS VARCHAR) +'''' ''''+ ''''('''' + UPPER(LEFT(DATENAME(MONTH,dateadd(MONTH, MONTH(sdd.term_start),-1)),3)) + '''')'''' 

			WHEN YEAR(sco.as_of_date) =  YEAR(sdd.term_start) 

				THEN  convert(varchar(4),sdd.term_start,120) + ''''-''''+ ''''Q'''' + CAST(DATEPART(q,sdd.term_start) AS VARCHAR) 

			ELSE CAST(YEAR(sdd.term_start) AS VARCHAR) END agg_term 

	FROM portfolio_mapping_tenor

) ag_t 

LEFT JOIN static_data_value sdvgl1 ON sdvgl1.value_id= ISNULL(gsm_d.gl_code_1,gsm_c.gl_code_1) 

LEFT JOIN static_data_value sdvgl2 ON sdvgl2.value_id= ISNULL(gsm_d.gl_code_2,gsm_c.gl_code_2) 

LEFT JOIN static_data_value sdvgl3 ON sdvgl3.value_id= ISNULL(gsm_d.gl_code_3,gsm_c.gl_code_3) 

LEFT JOIN static_data_value sdvgl4 ON sdvgl4.value_id= ISNULL(gsm_d.gl_code_4,gsm_c.gl_code_4) 

LEFT JOIN static_data_value sdvgl5 ON sdvgl5.value_id= ISNULL(gsm_d.gl_code_5,gsm_c.gl_code_5) 

LEFT JOIN static_data_value sdvgl6 ON sdvgl6.value_id= ISNULL(gsm_d.gl_code_6,gsm_c.gl_code_6) 

LEFT JOIN static_data_value sdvgl7 ON sdvgl7.value_id= ISNULL(gsm_d.gl_code_7,gsm_c.gl_code_7) 

LEFT JOIN static_data_value sdvgl8 ON sdvgl8.value_id= ISNULL(gsm_d.gl_code_8,gsm_c.gl_code_8) 

LEFT JOIN static_data_value sdvgl9 ON sdvgl9.value_id= ISNULL(gsm_d.gl_code_9,gsm_c.gl_code_9) 

LEFT JOIN static_data_value sdvgl10 ON sdvgl10.value_id= ISNULL(gsm_d.gl_code_10,gsm_c.gl_code_10) 

LEFT JOIN static_data_value sdvgl11 ON sdvgl11.value_id= sco.deal_charge_type_id

LEFT JOIN source_counterparty cii ON cii.source_counterparty_id = sco.counterparty_id

LEFT JOIN source_counterparty sc_parent ON sc_parent.source_counterparty_id = cii.netting_parent_counterparty_id

LEFT JOIN counterparty_contract_address cca ON cca.counterparty_id = sco.counterparty_id AND cca.contract_id = sco.contract_id

outer apply ( select *  FROM  source_counterparty sec_sc where  sec_sc.source_counterparty_id = cca.secondary_counterparty ) sec_sc

LEFT JOIN counterparty_contacts cc_payable ON cc_payable.counterparty_contact_id = ISNULL(cca.payables, sc_parent.payables)

LEFT JOIN counterparty_contacts cc_receivables ON cc_receivables.counterparty_contact_id = ISNULL(cca.receivables, sc_parent.receivables)

LEFT JOIN static_data_value sdv_cc_c ON sdv_cc_c.value_id = cc_receivables.country

LEFT JOIN static_data_value sdv_cc_r ON sdv_cc_r.value_id = cc_receivables.region

OUTER APPLY (

	SELECT address1 [cc_address1]

		, address2 [cc_address2]

		, zip [cc_zip]

		, city [cc_city]

		, state [cc_state]

		, [name] [cc_name]

		, cc.telephone [cc_phone]

		, fax [cc_fax]

		, cc.email [cc_email]

		, cc.country [cc_country]

		, cc.region [cc_region]

		, sdv_country.description [cc_country_name]

		, sdv_region.code [cc_region_name]

	FROM counterparty_contacts cc

	LEFT JOIN static_data_value sdv_country ON sdv_country.value_id =  cc.country and sdv_country.type_id = 14000

	LEFT JOIN static_data_value sdv_region ON sdv_region.value_id =  cc.region and sdv_region.type_id = 11150

	WHERE cc.counterparty_id = sco.counterparty_id AND cc.is_primary = ''''y'''' AND cc.is_active = ''''y''''

) cc

OUTER APPLY (

	SELECT address1 [secondary_cc_address1], address2 [secondary_cc_address2], city [secondary_cc_city]

	FROM counterparty_contacts cc

	WHERE cc.counterparty_id = sec_sc.source_counterparty_id AND cc.is_primary = ''''y'''' AND cc.is_active = ''''y''''

) sec_cc

LEFT JOIN fas_subsidiaries fs ON ISNULL(cg.sub_id, -1) = fs.fas_subsidiary_id

LEFT JOIN source_counterparty fs_counterparty ON fs.counterparty_id = fs_counterparty.source_counterparty_id

LEFT JOIN counterparty_contacts AS ccs ON CCS.counterparty_id = fs_counterparty.source_counterparty_id AND ccs.is_primary = ''''y''''

LEFT JOIN static_data_value sdvc_css ON sdvc_css.value_id =  ccs.country  and  sdvc_css.type_id = 14000

LEFT JOIN source_currency scu ON scu.source_currency_id = ISNULL(cg.currency, sdd.fixed_price_currency_id)

OUTER APPLY (

	SELECT TOP 1 cbi01.wire_ABA

		, cbi01.ACH_ABA

		, cbi01.bank_name

		, cbi01.Account_no

		, cbi01.accountname

		, cbi01.reference

		, cbi01.Address1

		, cbi01.Address2

		, sc.source_currency_id [primary_counterparty_bank_currency_id]

	    , sc.currency_id [primary_counterparty_bank_currency]

		, sc.currency_name [primary_counterparty_bank_currency_name]

	FROM counterparty_bank_info cbi01

	LEFT JOIN source_currency sc On  sc.source_currency_id = cbi01.currency

	WHERE cbi01.counterparty_id = fs_counterparty.source_counterparty_id

	ORDER BY cbi01.primary_account DESC

) cbi1

OUTER APPLY (SELECT sac1.stmt_invoice_detail_id, 

					CASE WHEN MIN(sac1.settle_status) = ''''s'''' THEN ''''Fully Paid'''' ELSE ''''Partially Paid'''' END [settle_status], 

					SUM(sac1.variance_amount) [variance_amount]

			FROM stmt_apply_cash sac1

			WHERE sac1.stmt_invoice_detail_id = sid.stmt_invoice_detail_id

			GROUP BY sac1.stmt_invoice_detail_id ) sac1

OUTER APPLY (SELECT 

					CASE WHEN sacd.settle_status = ''''s'''' THEN ''''Fully Paid'''' ELSE ''''Partially Paid'''' END  [settle_status] 

			FROM stmt_apply_cash_detail sacd

			WHERE sacd.stmt_invoice_detail_id = sac1.stmt_invoice_detail_id AND (sac1.settle_status = ''''Partially Paid'''' OR sac1.variance_amount <> 0) AND sacd.stmt_checkout_id = sco.stmt_checkout_id

			) sacd

LEFT JOIN static_data_value sdv_state ON sdv_state.value_id= ISNULL(cc_receivables.state, cc.cc_state) 

LEFT JOIN static_data_value sdv_p_state ON sdv_p_state.value_id= ccs.state

LEFT JOIN source_commodity d_sc ON d_sc.source_commodity_id = sdh.commodity_id

OUTER APPLY(

	SELECT  gmv.clm13_value [vat_remarks], 

	case when gmv.clm8_value = ''''p'''' then ''''Positive'''' when  gmv.clm8_value = ''''n'''' then ''''Negative'''' when gmv.clm8_value = ''''b'''' then ''''Both'''' else NULL end [price_description]

	FROM generic_mapping_values gmv

	INNER JOIN generic_mapping_definition gmd ON gmv.mapping_table_id = gmd.mapping_table_id

	INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id AND gmh.mapping_name = ''''Tax Rules''''

	LEFT JOIN static_data_value r_sdv ON r_sdv.value_id =  gmv.clm2_value

	LEFT JOIN source_commodity scm On scm.source_commodity_id = gmv.clm4_value

	WHERE 1=1 AND  gmv.clm10_value = ''''v'''' AND (ISNULL(gmv.clm3_value,-1) = ISNULL(sc.int_ext_flag, -1) AND ISNULL(gmv.clm2_value,-1) = ISNULL(cc.cc_region, -1)

	AND ISNULL(gmv.clm4_value, -1) = ISNULL(sdh.commodity_id,-1) AND  ISNULL(gmv.clm1_value, -1) <= ISNULL(sdd.term_start,-1))

	) vt

OUTER APPLY (

	SELECT TOP 1 cea.external_value 

	FROM counterparty_epa_account cea 

	WHERE cea.counterparty_id = sc.source_counterparty_id AND cea.external_type_id = 2200

) epa

WHERE 1 = 1 and svd_m.stmt_invoice_id  = svd_m.stmt_invoice_orignal_void_id

AND charge_type.description not like ''''%Tax%''''

AND charge_type.description not like ''''%VAT%'''' 

'' 

END 

SET @_sql3 = '''' +

CASE WHEN @_counterparty_id IS NOT NULL THEN '' AND sco.counterparty_id IN('' + @_counterparty_id + '')'' ELSE '''' END +

CASE WHEN @_contract_id IS NOT NULL THEN '' AND isnull(sin.contract_id, sco.contract_id) IN('' + @_contract_id + '')'' ELSE '''' END +

CASE WHEN @_prod_date_from IS NOT NULL THEN '' AND sco.term_start >= '''''' + @_prod_date_from + '''''''' ELSE '''' END +

CASE WHEN @_prod_date_to IS NOT NULL THEN '' AND sco.term_end <= '''''' + @_prod_date_to + '''''''' ELSE '''' END +

CASE WHEN @_create_ts_from IS NOT NULL THEN ''  AND ISNULL(sco.create_ts,si.create_ts) >= '''''' + @_create_ts_from + '''''''' ELSE '''' END +

CASE WHEN @_create_ts_to IS NOT NULL THEN '' AND  ISNULL(sco.create_ts,si.create_ts) <= '''''' + @_create_ts_to + '''''''' ELSE '''' END +

CASE WHEN @_update_ts_from IS NOT NULL THEN ''  AND ISNULL(sco.update_ts,si.update_ts) >= '''''' + @_update_ts_from + '''''''' ELSE '''' END +

CASE WHEN @_update_ts_to IS NOT NULL THEN ''  AND ISNULL(sco.update_ts,si.update_ts) <= '''''' + @_update_ts_to + '''''''' ELSE '''' END +

CASE WHEN @_payment_date_from IS NOT NULL THEN '' AND si.payment_date >= '''''' + @_payment_date_from + '''''''' ELSE '''' END +

CASE WHEN @_payment_date_to IS NOT NULL THEN '' AND si.payment_date <= '''''' + @_payment_date_to + '''''''' ELSE '''' END + 

CASE WHEN @_as_of_date IS NOT NULL THEN '' AND sco.as_of_date >= '''''' + @_as_of_date + '''''''' ELSE '''' END +

CASE WHEN @_to_as_of_date IS NOT NULL THEN '' AND sco.as_of_date <= '''''' + @_to_as_of_date + '''''''' ELSE '''' END +

CASE WHEN @_charge_type_id IS NULL THEN '''' ELSE '' AND sid.invoice_line_item_id IN('' + @_charge_type_id + '') '' END +

--CASE WHEN @_stmt_invoice_id IS NULL THEN '''' ELSE '' AND si.stmt_invoice_id IN('' + @_stmt_invoice_id + '') '' END +

+ CASE WHEN @_accounting_status IS NULL THEN '''' ELSE '' AND CASE 

									WHEN si.is_voided = ''''v'''' THEN 

										''''v'''' 

									WHEN si.is_finalized = ''''f'''' THEN 

										''''f'''' 

									ELSE 

										si.is_finalized

									END = '''''' + @_accounting_status + '''''''' END +

CASE WHEN @_invoice_type IS NULL THEN '''' ELSE '' AND si.invoice_type = '''''' + @_invoice_type + '''''''' END + 

CASE WHEN @_invoice_status IS NULL THEN '''' ELSE '' AND si.invoice_status = '''''' + @_invoice_status + '''''''' END + 

CASE WHEN @_source_deal_header_id IS NULL THEN '''' ELSE '' AND sdd.source_deal_header_id IN('' + @_source_deal_header_id + '') '' END

+ '' GROUP BY si.stmt_invoice_id, svd_m.stmt_invoice_id,

			si.as_of_date, 

			si.prod_date_from, 

			si.invoice_date, 

			sid.invoice_line_item_id, 

			si.invoice_number, 

			sdh.source_deal_header_id,

			sco.source_deal_detail_id,

			si.invoice_type,sdd.Leg, 

			cg.contract_name,

			sco.accrual_or_final,

			sco.Deal_Charge_Type_ID,

			sdvgl11.code, 

			sco.as_of_date, 

			--sco.ticket_id,

			--sco.shipment_id,

			sco.accounting_month,

			svd_m.stmt_invoice_id

			,svd_m.void_status

			, svd_m.as_of_date						

			''

SET @_sql4 = ''

SELECT * 

INTO #temp_all_final

FROM #temp_all_entries tmp1 WHERE 1=1

AND CASE 

	WHEN tmp1.accrual_or_final = ''''d'''' THEN NULL 

	WHEN tmp1.accrual_or_final = ''''r'''' THEN ISNULL(tmp1.stmt_invoice_id,CASE WHEN tmp1.reversal_stmt_checkout_id = -1 THEN -1 ELSE NULL END) 

	WHEN tmp1.accrual_or_final = ''''f'''' AND internal_deal_subtype_value_id = 17 THEN -1

	WHEN tmp1.accrual_or_final = ''''f'''' THEN tmp1.stmt_invoice_id

	ELSE -1 

END IS NOT NULL''

+ CASE WHEN @_accounting_month IS NULL THEN '''' ELSE '' AND tmp1.accounting_month = '''''' + CAST(@_accounting_month AS VARCHAR(10)) + '''''''' END

+ '' ORDER BY  tmp1.accounting_month''

SET @_sql5 = ''

INSERT INTO #temp_all_final

SELECT tmp1.* 

FROM #temp_all_entries tmp1 

INNER JOIN (SELECT DISTINCT source_deal_detail_id FROM #temp_all_final) fnl ON fnl.source_deal_detail_id = tmp1.source_deal_detail_id 

WHERE 1=1 AND tmp1.accrual_or_final <> ''''a'''' AND tmp1.accrual_or_final <> ''''r''''

AND (( tmp1.accrual_or_final = ''''f'''' AND tmp1.stmt_invoice_id IS NOT NULL) OR tmp1.accrual_or_final = ''''d'''')''

+ CASE WHEN @_accounting_month IS NULL THEN '''' ELSE '' AND CASE WHEN tmp1.accrual_or_final = ''''d'''' THEN DATEADD(m, -1, tmp1.accounting_month) ELSE tmp1.accounting_month END < '''''' + CAST(@_accounting_month AS VARCHAR(10)) + '''''''' END

+ '' ORDER BY  tmp1.accounting_month''

SET @_sql6 = ''

UPDATE #temp_all_final

SET show_accounting_month = '' + CASE WHEN @_accounting_month IS NULL THEN '' accounting_month '' ELSE '''''''' + CAST(@_accounting_month AS VARCHAR(10)) + '''''''' END + ''

SELECT MAX(taf.stmt_invoice_id) stmt_invoice_id

	,MAX(taf.as_of_date) as_of_date

	,MAX(taf.to_as_of_date) to_as_of_date

	,MAX(taf.prod_date_from) prod_date_from

	,MAX(taf.prod_date_to) prod_date_to

	,MAX(taf.settlement_date) settlement_date

	,MAX(taf.counterparty_name) counterparty_name

	,MAX(taf.counterparty_accounting_code) counterparty_accounting_code

	,MAX(taf.counterparty_id) counterparty_id

	,MAX(taf.contract_name) contract_name

	,MAX(taf.contract_id) contract_id

	,MAX(taf.charge_type) charge_type

	,MAX(taf.charge_type_id) charge_type_id

	, CASE WHEN MIN(taf.volume) < 0 THEN  CAST(MIN(taf.volume) as Numeric(28, 10))

	ELSE  CAST(MAX(taf.volume) as Numeric(28, 10))

	END

	volume

	,MAX(taf.uom) uom

	,Cast(SUM(taf.deal_volume) as Numeric(28, 10)) deal_volume

	,Cast(MAX(taf.settlement_amount) as Numeric(28, 10)) settlement_amount

	,Cast(MAX(taf.amount) as Numeric(28, 10)) amount

	,MAX(taf.currency) currency

	,MAX(taf.price) price

	,MAX(taf.invoice_number) invoice_number

	,MAX(taf.invoice_type) invoice_type

	,MAX(taf.invoice_status) invoice_status

	,MAX(taf.invoice_notes) invoice_notes

	,MAX(taf.invoice_subject) invoice_subject

	,MAX(taf.cash_received) cash_received

	,MAX(taf.cash_receive_variance_amount) cash_receive_variance_amount

	,MAX(taf.cash_received_date) cash_received_date

	,MAX(taf.charge_type_alias) charge_type_alias

	,MAX(taf.receive_pay) receive_pay

	,MAX(taf.accounting_status) accounting_status

	,MAX(taf.invoice_date) invoice_date

	,MAX(taf.invoice_payment_date) invoice_payment_date

	,MAX(taf.invoice_template) invoice_template

	,MAX(taf.lock_status) lock_status

	, taf.source_deal_header_id source_deal_header_id

	,MAX(taf.payment_date_from) payment_date_from

	,MAX(taf.payment_date_to) payment_date_to

	,MAX(taf.pnl_line_item) pnl_line_item

	,MAX(taf.deal_reference) deal_reference

	,MAX(taf.Leg) Leg

	,MAX(taf.buy_sell) buy_sell

	,MAX(taf.invoicing_charge_type) invoicing_charge_type

	,MAX(taf.Payment_Dr_GL_Code) Payment_Dr_GL_Code

	,MAX(taf.Payment_Cr_GL_Code) Payment_Cr_GL_Code

	,MAX(taf.Payment_Dr_GL_Name) Payment_Dr_GL_Name

	,MAX(taf.Payment_Cr_GL_Name) Payment_Cr_GL_Name

	,MAX(taf.Debit_GL_Number) Debit_GL_Number

	,MAX(taf.Credit_GL_Number) Credit_GL_Number

	,MAX(taf.Debit_account_name) Debit_account_name

	,MAX(taf.Credit_account_name) Credit_account_name

	,MAX(taf.payment_status) payment_status

	,MAX(taf.book) book

	,MAX(taf.strategy) strategy

	,MAX(taf.subsidary) subsidary

	,MAX(taf.sub_book) sub_book

	,MAX(taf.subsidiary_accounting_code) subsidiary_accounting_code

	,MAX(taf.strategy_accounting_code) strategy_accounting_code

	,MAX(taf.book_accounting_code) book_accounting_code

	,MAX(taf.sub_book_accounting_code) sub_book_accounting_code

	,MAX(taf.location_name) location_name

	,MAX(taf.location_accounting_code) location_accounting_code

	,MAX(location_group) location_group

	,MAX(taf.commodity) commodity

	,MAX(taf.commodity_accounting_code) commodity_accounting_code

	,MAX(taf.commodity_description) commodity_description

	,MAX(taf.accounting_receivable_id) accounting_receivable_id

	,MAX(taf.accounting_payable_id) accounting_payable_id

	,MAX(taf.[index]) [index]

	,MAX(taf.template_name) template_name

	,MAX(taf.deal_type_name) deal_type_name

	,MAX(taf.trader) trader

	,MAX(taf.country) country

	,MAX(taf.region) region

	,MAX(taf.term_start) term_start

	,MAX(taf.term_end) term_end

	,MAX(taf.term_start_year_month) term_start_year_month

	,MAX(taf.actual_forward) actual_forward

	,MAX(taf.term_quarter) term_quarter

	,MAX(taf.pnl_date) pnl_date

	,MAX(taf.physical_financial_flag) physical_financial_flag

	,MAX(taf.invoice_id) invoice_id

	,MAX(taf.counterparty_description) counterparty_description

	,MAX(taf.counterparty_contact) counterparty_contact

	,MAX(taf.counterparty_address1) counterparty_address1

	,MAX(taf.counterparty_address2) counterparty_address2

	,MAX(taf.counterparty_city) counterparty_city

	,MAX(taf.counterparty_state) counterparty_state

	,MAX(taf.counterparty_zip) counterparty_zip

	,MAX(taf.counterparty_phone) counterparty_phone

	,MAX(taf.counterparty_email) counterparty_email

	,MAX(taf.counterparty_fax) counterparty_fax

	,MAX(taf.primary_counterparty) primary_counterparty

	,MAX(taf.primary_counterparty_description) primary_counterparty_description

	,MAX(taf.primary_counterparty_contact_name) primary_counterparty_contact_name

	,MAX(taf.primary_counterparty_address1) primary_counterparty_address1

	,MAX(taf.primary_counterparty_address2) primary_counterparty_address2

	,MAX(taf.primary_counterparty_city) primary_counterparty_city

	,MAX(taf.primary_counterparty_state) primary_counterparty_state

	,MAX(taf.primary_counterparty_zip) primary_counterparty_zip

	,MAX(taf.primary_counterparty_contact_telephone) primary_counterparty_contact_telephone

	,MAX(taf.primary_counterparty_email_address) primary_counterparty_email_address

	,MAX(taf.primary_counterparty_fax) primary_counterparty_fax

	,MAX(taf.primary_bank_name) primary_bank_name

	,MAX(taf.primary_account_name) primary_account_name

	,MAX(taf.primary_account_no) primary_account_no

	,MAX(taf.primary_iban) primary_iban

	,MAX(taf.primary_swift_no) primary_swift_no

	,MAX(taf.primary_reference) primary_reference

	,MAX(taf.internal_deal_subtype_value_id) internal_deal_subtype_value_id

	,MAX(taf.deal_date) deal_date

	,MAX(taf.primary_counterparty_bank_address1) primary_counterparty_bank_address1

	,MAX(taf.primary_counterparty_bank_address2) primary_counterparty_bank_address2

	,MAX(taf.accounting_month) accounting_month

	,MAX(taf.accrual_or_final) accrual_or_final

	,MAX(taf.Deal_Charge_Type_ID) Deal_Charge_Type_ID

	,MAX(taf.Deal_Charge_Type) Deal_Charge_Type

	,MAX(taf.Calc_Type) Calc_Type

	,MAX(taf.reversal_stmt_checkout_id) reversal_stmt_checkout_id

	,MAX(taf.show_accounting_month) show_accounting_month

	,MAX(taf.counterparty_country_name) counterparty_country_name

	,MAX(taf.counterparty_region_name) counterparty_region_name

	,MAX(taf.secondary_counterparty_id) secondary_counterparty_id

	,MAX(taf.secondary_counterparty_name) secondary_counterparty_name

	,MAX(taf.source_commodity_id) source_commodity_id

	,MAX(taf.commodity_name) commodity_name

	, CASE WHEN MAX(ppcv.positive_commodity_vat_value) IS NOT NULL THEN 

	(MAX(ppcv.positive_commodity_vat_value) / (MAX(cet.commodity_energy_tax_value) + max(taf.settlement_amount)))

	ELSE (MAX(npcv.negative_commodity_vat_value) / (MAX(cet.commodity_energy_tax_value) + max(taf.settlement_amount))) END vat_percentage

	,MAX(taf.vat_remarks) vat_remarks

	,MAX(taf.price_description)price_description

	,MAX(taf.counterparty_external_value) counterparty_external_value

	,MAX(taf.secondary_cc_address1) secondary_cc_address1

	,MAX(taf.secondary_cc_address2) secondary_cc_address2

	,MAX(taf.secondary_cc_city) secondary_cc_city

	, NULL [Accrual_Final_Reversal]

	,MAX(taf.update_ts_from) update_ts_from

	,MAX(taf.update_ts_to) update_ts_to

	,MAX(taf.create_ts_from) create_ts_from

	,MAX(taf.create_ts_to) create_ts_to

	, MAX(taf.primary_counterparty_country)  primary_counterparty_country

	, max(taf.primary_counterparty_bank_currency_id) [primary_counterparty_bank_currency_id]

	, max(taf.primary_counterparty_bank_currency) [primary_counterparty_bank_currency]

	, max(taf.primary_counterparty_bank_currency_name) primary_counterparty_bank_currency_name

	, CONCAT(CAST(CAST(MAX(ABS(taf.volume)) as Numeric(28, 10)) AS VARCHAR(250)) + '''' '''', MAX(taf.uom)) total_volume

	, CONCAT(CAST(CAST(MAX(taf.amount) As Numeric(28, 10)) AS VARCHAR(250)) + '''' '''', MAX(taf.currency)) net_total

	, CASE WHEN MAX(ppcv.positive_commodity_vat_value) IS NOT NULL THEN  (max(ppcv.positive_commodity_vat_value)) ELSE  (max(npcv.negative_commodity_vat_value)) END vat 

	, CASE WHEN NULLIF(MAX(vat_percentage),'''''''') IS NOT NULL THEN CAST(MAX(settlement_amount) + MAX(settlement_amount) * MAX(vat_percentage) as Numeric(28, 10)) ELSE CAST(MAX(settlement_amount)as Numeric(28, 10)) END [gross_total]

	''

SET @_sql7 = ''

, MAX (taf.void_status) void_status

, cet.commodity_energy_tax_value commodity_energy_tax_value 

, ppcv.positive_commodity_vat_value pcv_positive_commodity_vat_value

, ppcv.source_deal_header_id pcv_source_deal_header_id

, npcv.source_deal_header_id npcv_source_deal_header_id

, npcv.negative_commodity_vat_value  npcv_negative_commodity_vat_value

INTO #tempt_last_finals

FROM #temp_all_final taf 

  OUTER APPLY (

	SELECT pvt.[Commodity Energy Tax] [commodity_energy_tax_value],source_deal_header_id,term_start,term_end,as_of_date,index_fees_id

	FROM (

		SELECT ifbs.field_name

			, ifbs.[value] 

			, ifbs.source_deal_header_id

			, ifbs.term_start

			, ifbs.term_end

			, ifbs.as_of_date

			, ifbs.index_fees_id

			, ifbs.internal_type

		FROM index_fees_breakdown_settlement ifbs

		INNER JOIN #temp_all_final taf ON ifbs.source_deal_header_id = taf.source_deal_header_id

			AND ifbs.term_start = taf.term_start

			AND ifbs.term_end = taf.term_end

			AND ifbs.as_of_date = taf.as_of_date

		WHERE field_name = ''''Commodity Energy Tax''''

		) x

	PIVOT(MAX(x.[value]) FOR x.field_name IN ([Commodity Energy Tax])) pvt

	) cet

OUTER APPLY (

	SELECT pvt.[Negative Price Commodity VAT][negative_commodity_vat_value],source_deal_header_id,term_start,term_end,as_of_date,index_fees_id

	FROM (

		SELECT ifbs.field_name

			, ifbs.[value] 

			,ifbs.source_deal_header_id

			,ifbs.term_start

			,ifbs.term_end

			,ifbs.as_of_date

			,ifbs.index_fees_id

			,ifbs.internal_type

		FROM index_fees_breakdown_settlement ifbs

		INNER JOIN #temp_all_final taf ON ifbs.source_deal_header_id = taf.source_deal_header_id

			AND ifbs.term_start = taf.term_start

			AND ifbs.term_end = taf.term_end

			AND ifbs.as_of_date = taf.as_of_date

		WHERE field_name IN (''''Negative Price Commodity VAT'''')

			AND NULLIF(abs(ifbs.[value]), 0) > 0

		) x

	PIVOT(MAX(x.[value]) FOR x.field_name IN ([Negative Price Commodity VAT])) pvt

	) npcv

OUTER APPLY (

		SELECT pvt.[Positive Price Commodity VAT][Positive_commodity_vat_value],source_deal_header_id,term_start,term_end,as_of_date,index_fees_id

	FROM (

		SELECT ifbs.field_name

			,ifbs.[value] 

			,ifbs.source_deal_header_id

			,ifbs.term_start

			,ifbs.term_end

			,ifbs.as_of_date

			,ifbs.index_fees_id

			,ifbs.internal_type

		FROM index_fees_breakdown_settlement ifbs

		INNER JOIN #temp_all_final taf ON ifbs.source_deal_header_id = taf.source_deal_header_id

			AND ifbs.term_start = taf.term_start

			AND ifbs.term_end = taf.term_end

			AND ifbs.as_of_date = taf.as_of_date

		WHERE field_name IN (''''Positive Price Commodity VAT'''')

			AND NULLIF(abs(ifbs.[value]), 0) > 0

		) x

	PIVOT(MAX(x.[value]) FOR x.field_name IN ([Positive Price Commodity VAT])) pvt

	) ppcv

where 

		taf.source_deal_header_id = COALESCE(ppcv.source_deal_header_id,npcv.source_deal_header_id, taf.source_deal_header_id) 

		and	taf.source_deal_header_id = COALESCE(cet.source_deal_header_id,taf.source_deal_header_id)

GROUP BY taf.source_deal_header_id,ppcv.positive_commodity_vat_value,ppcv.source_deal_header_id,cet.commodity_energy_tax_value,npcv.negative_commodity_vat_value,npcv.source_deal_header_id

select stmt_invoice_id,	as_of_date,	to_as_of_date,	prod_date_from,	prod_date_to,	settlement_date,	counterparty_name,	counterparty_accounting_code,	counterparty_id,	contract_name,	contract_id,	charge_type,	charge_type_id,	volume,	uom,	deal_volume,	settlement_amount,	amount,	currency,	price,	invoice_number,	invoice_type,	invoice_status,	invoice_notes,	invoice_subject,	cash_received,	cash_receive_variance_amount,	cash_received_date,	charge_type_alias,	receive_pay,	accounting_status,	invoice_date,	invoice_payment_date,	invoice_template,	lock_status,	source_deal_header_id,	payment_date_from,	payment_date_to,	pnl_line_item,	deal_reference,	Leg	buy_sell,	invoicing_charge_type,	Payment_Dr_GL_Code,	Payment_Cr_GL_Code,	Payment_Dr_GL_Name,	Payment_Cr_GL_Name,	Debit_GL_Number,	Credit_GL_Number,	Debit_account_name,	Credit_account_name,	payment_status,	book,	strategy,	subsidary,	sub_book,	subsidiary_accounting_code,	strategy_accounting_code,	book_accounting_code,	sub_book_accounting_code,	location_name,	location_accounting_code,	location_group,	commodity,	commodity_accounting_code,	commodity_description,	accounting_receivable_id,	accounting_payable_id,	[index],	template_name,	deal_type_name,	trader,	country,	region,	term_start,	term_end,	term_start_year_month,	actual_forward, term_quarter,	pnl_date,	physical_financial_flag,	invoice_id,	counterparty_description,	counterparty_contact,	counterparty_address1,	counterparty_address2,	counterparty_city,	counterparty_state,	counterparty_zip,	counterparty_phone,	counterparty_email,	counterparty_fax,	primary_counterparty,	primary_counterparty_description,	primary_counterparty_contact_name,	primary_counterparty_address1,	primary_counterparty_address2,	primary_counterparty_city,	primary_counterparty_state,	primary_counterparty_zip,	primary_counterparty_contact_telephone,	primary_counterparty_email_address,	primary_counterparty_fax,	primary_bank_name,	primary_account_name,	primary_account_no,	primary_iban,	primary_swift_no,	primary_reference,	internal_deal_subtype_value_id	,deal_date,	primary_counterparty_bank_address1,	primary_counterparty_bank_address2,	accounting_month,	accrual_or_final,	Deal_Charge_Type_ID	Deal_Charge_Type,	Calc_Type,	reversal_stmt_checkout_id,	show_accounting_month,	counterparty_country_name,	counterparty_region_name,	secondary_counterparty_id,	secondary_counterparty_name,	source_commodity_id,	commodity_name,	abs(vat_percentage) vat_percentage,

case when vat is null  and replace(charge_type,''''Price Commodity'''', '''''''') =  price_description then vat_remarks

when vat is null and price_description = ''''Both'''' then vat_remarks

else NULL end vat_remarks,

counterparty_external_value,	secondary_cc_address1,	secondary_cc_address2,	secondary_cc_city,	Accrual_Final_Reversal,	update_ts_from,	update_ts_to,	create_ts_from,	create_ts_to,	primary_counterparty_country,	primary_counterparty_bank_currency_id,	primary_counterparty_bank_currency,	primary_counterparty_bank_currency_name,	total_volume,	net_total, (Vat) as vat, case when settlement_amount <0 THEN -1* (ISNULL(ABS(vat),0) +ABS(settlement_amount) + ISNULL(ABS(commodity_energy_tax_value), 0)) else 1 * (ISNULL(ABS(vat),0) +ABS(settlement_amount) + ISNULL(ABS(commodity_energy_tax_value), 0)) end gross_total,	void_status,	abs(commodity_energy_tax_value) commodity_energy_tax_value

--[__batch_report__]   

FROM  #tempt_last_finals''


EXEC (@_sql + @_sql1 + @_sql11 + @_sql2 + @_sql3 + @_sql4 + @_sql5 + @_sql6 + @_sql7)', report_id = @report_id_data_source_dest,
	system_defined = '0'
	,category = '106500' 
	WHERE [name] = 'Enercity Settlement Checkout View'
		AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1)
		
	
	IF OBJECT_ID('tempdb..#data_source_column', 'U') IS NOT NULL
		DROP TABLE #data_source_column	
	CREATE TABLE #data_source_column(column_id INT)	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'accounting_status'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Accounting Status'
			   , reqd_param = NULL, widget_id = 2, datatype_id = 5, param_data_source = 'SELECT ''e'' AS value, ''Estimate'' AS label, ''enable'' AS status ' + CHAR(10) + 'UNION ALL' + CHAR(10) + 'SELECT ''f'', ''Final'', ''enable''' + CHAR(10) + 'UNION ALL' + CHAR(10) + 'SELECT ''v'', ''Voided'', ''enable''', param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'accounting_status'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'accounting_status' AS [name], 'Accounting Status' AS ALIAS, NULL AS reqd_param, 2 AS widget_id, 5 AS datatype_id, 'SELECT ''e'' AS value, ''Estimate'' AS label, ''enable'' AS status ' + CHAR(10) + 'UNION ALL' + CHAR(10) + 'SELECT ''f'', ''Final'', ''enable''' + CHAR(10) + 'UNION ALL' + CHAR(10) + 'SELECT ''v'', ''Voided'', ''enable''' AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'amount'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Amount'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'amount'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'amount' AS [name], 'Amount' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'cash_receive_variance_amount'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Cash Receive Variance Amount'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'cash_receive_variance_amount'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'cash_receive_variance_amount' AS [name], 'Cash Receive Variance Amount' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'cash_received'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Cash Received'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'cash_received'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'cash_received' AS [name], 'Cash Received' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'cash_received_date'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Cash Received Date'
			   , reqd_param = NULL, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 4, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'cash_received_date'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'cash_received_date' AS [name], 'Cash Received Date' AS ALIAS, NULL AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'charge_type'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Charge Type'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'charge_type'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'charge_type' AS [name], 'Charge Type' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'charge_type_alias'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Charge Type Alias'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'charge_type_alias'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'charge_type_alias' AS [name], 'Charge Type Alias' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'charge_type_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Charge Type Id'
			   , reqd_param = NULL, widget_id = 2, datatype_id = 4, param_data_source = 'select value_id,code from  static_data_value where type_id=10019', param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'charge_type_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'charge_type_id' AS [name], 'Charge Type Id' AS ALIAS, NULL AS reqd_param, 2 AS widget_id, 4 AS datatype_id, 'select value_id,code from  static_data_value where type_id=10019' AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'contract_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Contract ID'
			   , reqd_param = NULL, widget_id = 7, datatype_id = 4, param_data_source = 'browse_contract_counterparty', param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'contract_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'contract_id' AS [name], 'Contract ID' AS ALIAS, NULL AS reqd_param, 7 AS widget_id, 4 AS datatype_id, 'browse_contract_counterparty' AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'contract_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Contract Name'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'contract_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'contract_name' AS [name], 'Contract Name' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'counterparty_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Counterparty ID'
			   , reqd_param = NULL, widget_id = 7, datatype_id = 4, param_data_source = 'browse_counterparty', param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'counterparty_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'counterparty_id' AS [name], 'Counterparty ID' AS ALIAS, NULL AS reqd_param, 7 AS widget_id, 4 AS datatype_id, 'browse_counterparty' AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'counterparty_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Counterparty'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'counterparty_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'counterparty_name' AS [name], 'Counterparty' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'create_ts_from'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Create Ts From'
			   , reqd_param = NULL, widget_id = 6, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'create_ts_from'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'create_ts_from' AS [name], 'Create Ts From' AS ALIAS, NULL AS reqd_param, 6 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'create_ts_to'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Create Ts To'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'create_ts_to'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'create_ts_to' AS [name], 'Create Ts To' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'Credit_GL_Number'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Credit Gl Number'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'Credit_GL_Number'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Credit_GL_Number' AS [name], 'Credit Gl Number' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'currency'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Currency'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'currency'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'currency' AS [name], 'Currency' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'Debit_GL_Number'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Debit Gl Number'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'Debit_GL_Number'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Debit_GL_Number' AS [name], 'Debit Gl Number' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'invoice_date'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Invoice Date'
			   , reqd_param = NULL, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 4, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'invoice_date'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'invoice_date' AS [name], 'Invoice Date' AS ALIAS, NULL AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'invoice_notes'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Invoice Notes'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'invoice_notes'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'invoice_notes' AS [name], 'Invoice Notes' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'invoice_number'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Invoice Number'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'invoice_number'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'invoice_number' AS [name], 'Invoice Number' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'invoice_payment_date'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Invoice Payment Date'
			   , reqd_param = NULL, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 4, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'invoice_payment_date'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'invoice_payment_date' AS [name], 'Invoice Payment Date' AS ALIAS, NULL AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'invoice_status'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Invoice Status'
			   , reqd_param = NULL, widget_id = 2, datatype_id = 5, param_data_source = 'select value_id,code from  static_data_value where type_id=20700', param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'invoice_status'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'invoice_status' AS [name], 'Invoice Status' AS ALIAS, NULL AS reqd_param, 2 AS widget_id, 5 AS datatype_id, 'select value_id,code from  static_data_value where type_id=20700' AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'invoice_subject'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Invoice Subject'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'invoice_subject'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'invoice_subject' AS [name], 'Invoice Subject' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'invoice_template'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Invoice Template'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'invoice_template'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'invoice_template' AS [name], 'Invoice Template' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'invoice_type'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Invoice Type'
			   , reqd_param = NULL, widget_id = 2, datatype_id = 5, param_data_source = 'SELECT ''i'' AS value, ''Invoice'' AS label, ''enable'' AS status ' + CHAR(10) + 'UNION ALL' + CHAR(10) + 'SELECT ''r'', ''Remittance'', ''enable''', param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'invoice_type'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'invoice_type' AS [name], 'Invoice Type' AS ALIAS, NULL AS reqd_param, 2 AS widget_id, 5 AS datatype_id, 'SELECT ''i'' AS value, ''Invoice'' AS label, ''enable'' AS status ' + CHAR(10) + 'UNION ALL' + CHAR(10) + 'SELECT ''r'', ''Remittance'', ''enable''' AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'lock_status'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Lock Status'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'lock_status'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'lock_status' AS [name], 'Lock Status' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'payment_date_from'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Payment Date From'
			   , reqd_param = NULL, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 4, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'payment_date_from'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'payment_date_from' AS [name], 'Payment Date From' AS ALIAS, NULL AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'payment_date_to'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Payment Date To'
			   , reqd_param = NULL, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 4, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'payment_date_to'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'payment_date_to' AS [name], 'Payment Date To' AS ALIAS, NULL AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'pnl_line_item'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Pnl Line Item'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'pnl_line_item'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'pnl_line_item' AS [name], 'Pnl Line Item' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'price'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Price'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'price'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'price' AS [name], 'Price' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'prod_date_from'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Prod Date From'
			   , reqd_param = NULL, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 4, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'prod_date_from'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'prod_date_from' AS [name], 'Prod Date From' AS ALIAS, NULL AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'prod_date_to'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Prod Date To'
			   , reqd_param = NULL, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 4, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'prod_date_to'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'prod_date_to' AS [name], 'Prod Date To' AS ALIAS, NULL AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'receive_pay'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Receive Pay'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'receive_pay'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'receive_pay' AS [name], 'Receive Pay' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'settlement_date'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Settlement Date'
			   , reqd_param = NULL, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 4, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'settlement_date'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'settlement_date' AS [name], 'Settlement Date' AS ALIAS, NULL AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'source_deal_header_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal ID'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'source_deal_header_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'source_deal_header_id' AS [name], 'Deal ID' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'stmt_invoice_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Stmt Invoice Id'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'stmt_invoice_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'stmt_invoice_id' AS [name], 'Stmt Invoice Id' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'to_as_of_date'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'As of Date To'
			   , reqd_param = NULL, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 4, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'to_as_of_date'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'to_as_of_date' AS [name], 'As of Date To' AS ALIAS, NULL AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'uom'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Uom'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'uom'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'uom' AS [name], 'Uom' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'update_ts_from'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Update Ts From'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'update_ts_from'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'update_ts_from' AS [name], 'Update Ts From' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'update_ts_to'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Update Ts To'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'update_ts_to'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'update_ts_to' AS [name], 'Update Ts To' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'volume'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Volume'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'volume'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'volume' AS [name], 'Volume' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'buy_sell'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Buy Sell'
			   , reqd_param = NULL, widget_id = 2, datatype_id = 4, param_data_source = 'SELECT ''b'' AS value, ''Buy'' AS code union ' + CHAR(10) + 'SELECT ''s'', ''Sell''', param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'buy_sell'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'buy_sell' AS [name], 'Buy Sell' AS ALIAS, NULL AS reqd_param, 2 AS widget_id, 4 AS datatype_id, 'SELECT ''b'' AS value, ''Buy'' AS code union ' + CHAR(10) + 'SELECT ''s'', ''Sell''' AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'deal_reference'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal Reference'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'deal_reference'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'deal_reference' AS [name], 'Deal Reference' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'invoicing_charge_type'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Invoicing Charge Type'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'invoicing_charge_type'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'invoicing_charge_type' AS [name], 'Invoicing Charge Type' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'Payment_Cr_GL_Code'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Payment Cr Gl Code'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'Payment_Cr_GL_Code'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Payment_Cr_GL_Code' AS [name], 'Payment Cr Gl Code' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'Payment_Dr_GL_Code'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Payment Dr Gl Code'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'Payment_Dr_GL_Code'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Payment_Dr_GL_Code' AS [name], 'Payment Dr Gl Code' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'payment_status'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Payment Status'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'payment_status'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'payment_status' AS [name], 'Payment Status' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'as_of_date'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'As of Date'
			   , reqd_param = NULL, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 4, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'as_of_date'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'as_of_date' AS [name], 'As of Date' AS ALIAS, NULL AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'accounting_payable_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Accounting Payable Id'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'accounting_payable_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'accounting_payable_id' AS [name], 'Accounting Payable Id' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'accounting_receivable_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Accounting Receivable Id'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'accounting_receivable_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'accounting_receivable_id' AS [name], 'Accounting Receivable Id' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'actual_forward'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Actual Forward'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'actual_forward'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'actual_forward' AS [name], 'Actual Forward' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'book'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Book'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'book'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'book' AS [name], 'Book' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'commodity'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Commodity'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'commodity'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'commodity' AS [name], 'Commodity' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'country'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Country'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'country'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'country' AS [name], 'Country' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'deal_type_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal Type Name'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'deal_type_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'deal_type_name' AS [name], 'Deal Type Name' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'index'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Index'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'index'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'index' AS [name], 'Index' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'invoice_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Invoice Id'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'invoice_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'invoice_id' AS [name], 'Invoice Id' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'location_group'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Location Group'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'location_group'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'location_group' AS [name], 'Location Group' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'location_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Location Name'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'location_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'location_name' AS [name], 'Location Name' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'physical_financial_flag'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Physical Financial'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'physical_financial_flag'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'physical_financial_flag' AS [name], 'Physical Financial' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'pnl_date'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Pnl Date'
			   , reqd_param = NULL, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 4, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'pnl_date'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'pnl_date' AS [name], 'Pnl Date' AS ALIAS, NULL AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'region'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Region'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'region'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'region' AS [name], 'Region' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'strategy'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Strategy'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'strategy'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'strategy' AS [name], 'Strategy' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'sub_book'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Sub Book'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'sub_book'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'sub_book' AS [name], 'Sub Book' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'subsidary'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Subsidary'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'subsidary'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'subsidary' AS [name], 'Subsidary' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'template_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Template Name'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'template_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'template_name' AS [name], 'Template Name' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'term_end'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Term End'
			   , reqd_param = NULL, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 4, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'term_end'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'term_end' AS [name], 'Term End' AS ALIAS, NULL AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'term_quarter'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Term Quarter'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'term_quarter'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'term_quarter' AS [name], 'Term Quarter' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'term_start'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Term Start'
			   , reqd_param = NULL, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 4, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'term_start'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'term_start' AS [name], 'Term Start' AS ALIAS, NULL AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'term_start_year_month'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Term Start Year Month'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'term_start_year_month'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'term_start_year_month' AS [name], 'Term Start Year Month' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'trader'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Trader'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'trader'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'trader' AS [name], 'Trader' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'Payment_Cr_GL_Name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Payment Cr Gl Name'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'Payment_Cr_GL_Name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Payment_Cr_GL_Name' AS [name], 'Payment Cr Gl Name' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'Payment_Dr_GL_Name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Payment Dr Gl Name'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'Payment_Dr_GL_Name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Payment_Dr_GL_Name' AS [name], 'Payment Dr Gl Name' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'Credit_account_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Credit Account Name'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'Credit_account_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Credit_account_name' AS [name], 'Credit Account Name' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'Debit_account_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Debit Account Name'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'Debit_account_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Debit_account_name' AS [name], 'Debit Account Name' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'counterparty_address1'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Counterparty Address1'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'counterparty_address1'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'counterparty_address1' AS [name], 'Counterparty Address1' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'counterparty_address2'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Counterparty Address2'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'counterparty_address2'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'counterparty_address2' AS [name], 'Counterparty Address2' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'counterparty_city'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Counterparty City'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'counterparty_city'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'counterparty_city' AS [name], 'Counterparty City' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'counterparty_contact'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Counterparty Contact'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'counterparty_contact'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'counterparty_contact' AS [name], 'Counterparty Contact' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'counterparty_description'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Counterparty Description'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'counterparty_description'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'counterparty_description' AS [name], 'Counterparty Description' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'counterparty_email'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Counterparty Email'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'counterparty_email'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'counterparty_email' AS [name], 'Counterparty Email' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'counterparty_fax'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Counterparty Fax'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'counterparty_fax'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'counterparty_fax' AS [name], 'Counterparty Fax' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'counterparty_phone'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Counterparty Phone'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'counterparty_phone'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'counterparty_phone' AS [name], 'Counterparty Phone' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'counterparty_zip'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Counterparty Zip'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'counterparty_zip'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'counterparty_zip' AS [name], 'Counterparty Zip' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'primary_account_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Primary Account Name'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'primary_account_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'primary_account_name' AS [name], 'Primary Account Name' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'primary_account_no'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Primary Account No'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'primary_account_no'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'primary_account_no' AS [name], 'Primary Account No' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'primary_bank_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Primary Bank Name'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'primary_bank_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'primary_bank_name' AS [name], 'Primary Bank Name' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'primary_counterparty'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Primary Counterparty'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'primary_counterparty'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'primary_counterparty' AS [name], 'Primary Counterparty' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'primary_counterparty_city'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Primary Counterparty City'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'primary_counterparty_city'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'primary_counterparty_city' AS [name], 'Primary Counterparty City' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'primary_counterparty_contact_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Primary Counterparty Contact Name'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'primary_counterparty_contact_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'primary_counterparty_contact_name' AS [name], 'Primary Counterparty Contact Name' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'primary_counterparty_contact_telephone'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Primary Counterparty Contact Telephone'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'primary_counterparty_contact_telephone'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'primary_counterparty_contact_telephone' AS [name], 'Primary Counterparty Contact Telephone' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'primary_counterparty_description'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Primary Counterparty Description'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'primary_counterparty_description'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'primary_counterparty_description' AS [name], 'Primary Counterparty Description' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'primary_iban'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Primary Iban'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'primary_iban'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'primary_iban' AS [name], 'Primary Iban' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'primary_swift_no'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Primary Swift No'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'primary_swift_no'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'primary_swift_no' AS [name], 'Primary Swift No' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'deal_date'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal Date'
			   , reqd_param = NULL, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 4, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'deal_date'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'deal_date' AS [name], 'Deal Date' AS ALIAS, NULL AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'primary_counterparty_address1'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Primary Counterparty Address1'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'primary_counterparty_address1'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'primary_counterparty_address1' AS [name], 'Primary Counterparty Address1' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'primary_counterparty_address2'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Primary Counterparty Address2'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'primary_counterparty_address2'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'primary_counterparty_address2' AS [name], 'Primary Counterparty Address2' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'primary_counterparty_email_address'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Primary Counterparty Email Address'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'primary_counterparty_email_address'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'primary_counterparty_email_address' AS [name], 'Primary Counterparty Email Address' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'primary_counterparty_fax'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Primary Counterparty Fax'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'primary_counterparty_fax'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'primary_counterparty_fax' AS [name], 'Primary Counterparty Fax' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'primary_counterparty_zip'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Primary Counterparty Zip'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'primary_counterparty_zip'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'primary_counterparty_zip' AS [name], 'Primary Counterparty Zip' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'commodity_description'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Commodity Description'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'commodity_description'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'commodity_description' AS [name], 'Commodity Description' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'primary_reference'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Primary Reference'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'primary_reference'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'primary_reference' AS [name], 'Primary Reference' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'primary_counterparty_bank_address1'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Primary Counterparty Bank Address1'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'primary_counterparty_bank_address1'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'primary_counterparty_bank_address1' AS [name], 'Primary Counterparty Bank Address1' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'primary_counterparty_bank_address2'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Primary Counterparty Bank Address2'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'primary_counterparty_bank_address2'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'primary_counterparty_bank_address2' AS [name], 'Primary Counterparty Bank Address2' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'accounting_month'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Accounting Month'
			   , reqd_param = NULL, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 4, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'accounting_month'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'accounting_month' AS [name], 'Accounting Month' AS ALIAS, NULL AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'accrual_or_final'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Accrual Or Final'
			   , reqd_param = NULL, widget_id = 2, datatype_id = 1, param_data_source = 'SELECT ''a'' AS value, ''Accrual'' AS label, ''enable'' AS status ' + CHAR(10) + 'UNION ALL ' + CHAR(10) + 'SELECT ''f'' AS value, ''Final'' AS label, ''enable'' AS status ' + CHAR(10) + 'UNION ALL ' + CHAR(10) + 'SELECT ''r'' AS value, ''Reversal'' AS label, ''enable'' AS status', param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'accrual_or_final'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'accrual_or_final' AS [name], 'Accrual Or Final' AS ALIAS, NULL AS reqd_param, 2 AS widget_id, 1 AS datatype_id, 'SELECT ''a'' AS value, ''Accrual'' AS label, ''enable'' AS status ' + CHAR(10) + 'UNION ALL ' + CHAR(10) + 'SELECT ''f'' AS value, ''Final'' AS label, ''enable'' AS status ' + CHAR(10) + 'UNION ALL ' + CHAR(10) + 'SELECT ''r'' AS value, ''Reversal'' AS label, ''enable'' AS status' AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'Calc_Type'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Calc Type'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'Calc_Type'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Calc_Type' AS [name], 'Calc Type' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'counterparty_state'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Counterparty State'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'counterparty_state'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'counterparty_state' AS [name], 'Counterparty State' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'Deal_Charge_Type'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal Charge Type'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'Deal_Charge_Type'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Deal_Charge_Type' AS [name], 'Deal Charge Type' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'deal_volume'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal Volume'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'deal_volume'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'deal_volume' AS [name], 'Deal Volume' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'primary_counterparty_state'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Primary Counterparty State'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'primary_counterparty_state'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'primary_counterparty_state' AS [name], 'Primary Counterparty State' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'reversal_stmt_checkout_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Reversal Stmt Checkout Id'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'reversal_stmt_checkout_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'reversal_stmt_checkout_id' AS [name], 'Reversal Stmt Checkout Id' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'Accrual_Final_Reversal'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Accrual Final Reversal'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'Accrual_Final_Reversal'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Accrual_Final_Reversal' AS [name], 'Accrual Final Reversal' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'show_accounting_month'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Show Accounting Month'
			   , reqd_param = NULL, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 4, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'show_accounting_month'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'show_accounting_month' AS [name], 'Show Accounting Month' AS ALIAS, NULL AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'settlement_amount'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Settlement Amount'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'settlement_amount'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'settlement_amount' AS [name], 'Settlement Amount' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'internal_deal_subtype_value_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Internal Deal Subtype Value Id'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'internal_deal_subtype_value_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'internal_deal_subtype_value_id' AS [name], 'Internal Deal Subtype Value Id' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'book_accounting_code'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Book Accounting Code'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'book_accounting_code'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'book_accounting_code' AS [name], 'Book Accounting Code' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'commodity_accounting_code'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Commodity Accounting Code'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'commodity_accounting_code'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'commodity_accounting_code' AS [name], 'Commodity Accounting Code' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'counterparty_accounting_code'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Counterparty Accounting Code'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'counterparty_accounting_code'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'counterparty_accounting_code' AS [name], 'Counterparty Accounting Code' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'location_accounting_code'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Location Accounting Code'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'location_accounting_code'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'location_accounting_code' AS [name], 'Location Accounting Code' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'strategy_accounting_code'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Strategy Accounting Code'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'strategy_accounting_code'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'strategy_accounting_code' AS [name], 'Strategy Accounting Code' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'sub_book_accounting_code'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Sub Book Accounting Code'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'sub_book_accounting_code'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'sub_book_accounting_code' AS [name], 'Sub Book Accounting Code' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'subsidiary_accounting_code'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Subsidiary Accounting Code'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'subsidiary_accounting_code'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'subsidiary_accounting_code' AS [name], 'Subsidiary Accounting Code' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'commodity_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Commodity Name'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'commodity_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'commodity_name' AS [name], 'Commodity Name' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'counterparty_country_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Counterparty Country Name'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'counterparty_country_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'counterparty_country_name' AS [name], 'Counterparty Country Name' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'counterparty_region_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Counterparty Region Name'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'counterparty_region_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'counterparty_region_name' AS [name], 'Counterparty Region Name' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'secondary_counterparty_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Secondary Counterparty Id'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'secondary_counterparty_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'secondary_counterparty_id' AS [name], 'Secondary Counterparty Id' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'secondary_counterparty_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Secondary Counterparty Name'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'secondary_counterparty_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'secondary_counterparty_name' AS [name], 'Secondary Counterparty Name' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'source_commodity_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Source Commodity Id'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'source_commodity_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'source_commodity_id' AS [name], 'Source Commodity Id' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'vat_percentage'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Vat Percentage'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'vat_percentage'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'vat_percentage' AS [name], 'Vat Percentage' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'vat_remarks'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Vat Remarks'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'vat_remarks'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'vat_remarks' AS [name], 'Vat Remarks' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'counterparty_external_value'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Counterparty External Value'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'counterparty_external_value'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'counterparty_external_value' AS [name], 'Counterparty External Value' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'secondary_cc_address1'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Secondary Cc Address1'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'secondary_cc_address1'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'secondary_cc_address1' AS [name], 'Secondary Cc Address1' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'secondary_cc_address2'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Secondary Cc Address2'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'secondary_cc_address2'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'secondary_cc_address2' AS [name], 'Secondary Cc Address2' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'secondary_cc_city'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Secondary Cc City'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'secondary_cc_city'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'secondary_cc_city' AS [name], 'Secondary Cc City' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'primary_counterparty_country'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Primary Counterparty Country'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'primary_counterparty_country'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'primary_counterparty_country' AS [name], 'Primary Counterparty Country' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'primary_counterparty_bank_currency'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Primary Counterparty Bank Currency'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'primary_counterparty_bank_currency'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'primary_counterparty_bank_currency' AS [name], 'Primary Counterparty Bank Currency' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'primary_counterparty_bank_currency_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Primary Counterparty Bank Currency Id'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'primary_counterparty_bank_currency_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'primary_counterparty_bank_currency_id' AS [name], 'Primary Counterparty Bank Currency Id' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'primary_counterparty_bank_currency_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Primary Counterparty Bank Currency Name'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'primary_counterparty_bank_currency_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'primary_counterparty_bank_currency_name' AS [name], 'Primary Counterparty Bank Currency Name' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'net_total'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Net Total'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'net_total'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'net_total' AS [name], 'Net Total' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'total_volume'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Total Volume'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'total_volume'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'total_volume' AS [name], 'Total Volume' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'vat'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Vat'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'vat'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'vat' AS [name], 'Vat' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'gross_total'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Gross Total'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'gross_total'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'gross_total' AS [name], 'Gross Total' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'void_status'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Void Status'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'void_status'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'void_status' AS [name], 'Void Status' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Enercity Settlement Checkout View'
	            AND dsc.name =  'commodity_energy_tax_value'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Commodity Energy Tax Value'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Enercity Settlement Checkout View'
			AND dsc.name =  'commodity_energy_tax_value'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'commodity_energy_tax_value' AS [name], 'Commodity Energy Tax Value' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Enercity Settlement Checkout View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	DELETE dsc
	FROM data_source_column dsc 
	INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		AND ds.[name] = 'Enercity Settlement Checkout View'
		AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1)
	LEFT JOIN #data_source_column tdsc ON tdsc.column_id = dsc.data_source_column_id
	WHERE tdsc.column_id IS NULL
	COMMIT TRAN

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN;
		
			DECLARE @error_msg VARCHAR(1000)
             	SET @error_msg = ERROR_MESSAGE()
             	RAISERROR (@error_msg, 16, 1);
	END CATCH
	
	IF OBJECT_ID('tempdb..#data_source_column', 'U') IS NOT NULL
		DROP TABLE #data_source_column	