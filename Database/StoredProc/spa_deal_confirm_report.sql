
IF OBJECT_ID(N'[dbo].[spa_deal_confirm_report]', N'P') IS NOT NULL
  DROP PROCEDURE [dbo].spa_deal_confirm_report
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**
	Used to return the data according to source_deal_header_id for confirmation report

	Parameters
	@flag : Operational flag
	@source_deal_header_id : Deal id
	@param_term_start : Term start
	@filter_id : id call from workflow and others.
*/

CREATE  PROC [dbo].[spa_deal_confirm_report]  
	@source_deal_header_id VARCHAR(MAX), 
	@flag CHAR(1) = NULL,
	@param_term_start DATE = NULL,
	@filter_id VARCHAR(MAX) = NULL

AS
/*
DECLARE 
@source_deal_header_id VARCHAR(MAX) ='55564', 
	@flag CHAR(1) = 'v',
	@param_term_start DATE = NULL

	exec spa_drop_all_temp_table
--*/
DECLARE @counterparty_id INT, @pricing VARCHAR(500), @company VARCHAR(500), @pricing_1 VARCHAR(500),  @deal_vol VARCHAR(500)
Declare @avg_value int


SELECT @company = [entity_name] FROM portfolio_hierarchy WHERE [entity_id] = -1
SELECT @counterparty_id = fs2.counterparty_id FROM fas_subsidiaries fs2 WHERE fs2.fas_subsidiary_id = -1	

SELECT	@pricing = 
COALESCE(CONVERT(VARCHAR(6),CAST(AVG(sdd.fixed_price) AS VARCHAR)),MAX(spcd1.curve_name),NULLIF(MAX(fe.formula_name),''),dbo.FNAFormulaFormat(MAX(fe.formula), 'r')) + 
						CASE WHEN AVG(sdd.price_adder) IS NOT NULL THEN 
						CASE WHEN AVG(sdd.price_adder) > 0 THEN ' +' ELSE ' ' END +  CONVERT(VARCHAR(6),CONVERT(VARCHAR,AVG(sdd.price_adder))) 
						ELSE ' ' END
						
	from source_deal_detail sdd
	 LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = sdd.curve_id
	 LEFT JOIN source_price_curve_def spcd1 ON spcd1.source_curve_def_id = sdd.formula_curve_id
	 LEFT JOIN formula_editor fe On fe.formula_id = sdd.formula_id
	where sdd.source_deal_header_id = @source_deal_header_id
	and leg= 1

	SELECT @pricing_1 = SUM(sdd.deal_volume * sdd.fixed_price) / ISNULL(NULLIF(SUM(sdd.deal_volume), 0), 1)
	FROM source_deal_detail sdd 
		INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
	WHERE sdd.source_deal_header_id = @source_deal_header_id

	SELECT @deal_vol =  SUM(sdd.deal_volume)
	FROM source_deal_detail sdd 
		INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
	WHERE sdd.source_deal_header_id = @source_deal_header_id

	DECLARE @user_signature_name VARCHAR(MAX)
	SELECT @user_signature_name = attachment_file_name FROM application_notes an
		INNER JOIN application_users au on au.application_users_id = an.notes_object_id
	WHERE an.internal_type_value_id = 10000132 AND an.user_category = -43000 
	AND au.user_login_id = (SELECT TOP 1 create_user FROM confirm_status WHERE source_deal_header_id = @source_deal_header_id AND type = 17202 ORDER BY 1 DESC)

	DECLARE @file_path VARCHAR(MAX)
	SELECT @file_path= SUBSTRING(file_attachment_path, 0, CHARINDEX('adiha_pm_html', file_attachment_path)) FROM connection_string

IF @flag = 'f'	-- For Counterparty contract
BEGIN
	SELECT cg.contract_name [contract_name],
		dbo.FNADateFormat(cca.contract_date) [contract_date],
		sc.counterparty_name [counterparty_name],
		musddv.static_data_udf_values [eic],
		cc.title [cc_title],
		cc.name [cc_name],
		'' [act_on_the_basic_of],
		dbo.FNADateFormat(cca.contract_start_date) [contract_start_date],
		dbo.FNADateFormat(cca.contract_end_date) [contract_end_date],
		contract_limit.[value] [contract_limit],
		contract_limit_words.[value] [contract_limit_words],
		'«' + CAST(DATEPART(day, cca.contract_start_date) AS NVARCHAR) + '»' 
		+ CASE DATEPART(month, cca.contract_start_date) 
			WHEN 1 THEN N' січня' 
			WHEN 2 THEN N' лютого'
			WHEN 3 THEN N' марш'
			WHEN 4 THEN N' квітня'
			WHEN 5 THEN N' може'
			WHEN 6 THEN N' червня'
			WHEN 7 THEN N' липня'
			WHEN 8 THEN N' серпень'
			WHEN 9 THEN N' Вересень'
			WHEN 10 THEN N' жовтня'
			WHEN 11 THEN N' Листопад'
			WHEN 12 THEN N' Грудень'
		END + ' ' + CAST(DATEPART(year, cca.contract_start_date) AS NVARCHAR) + N' року' [end_date_ukrainian],
		cc.address1 + IIF(cc.address1 = '', '', ', ') + cc.address2 [cc_address],
		cbi.bank_name [cbi_bank_name],
		cbi.aba_number [cbi_aba_number],
		cbi.address [cbi_address],
		sc.tax_id [tax_id],
		cc.telephone [cc_telephone],
		cc.email [cc_email]
	FROM counterparty_contract_address cca 
	LEFT JOIN contract_group cg 
		ON cg.contract_id = cca.contract_id
	LEFT JOIN source_counterparty sc 
		ON sc.source_counterparty_id = cca.counterparty_id
	LEFT JOIN counterparty_contacts cc 
		ON cc.counterparty_contact_id = cca.confirmation AND cc.counterparty_id = cca.counterparty_id
	LEFT JOIN maintain_udf_static_data_detail_values musddv 
		ON musddv.primary_field_object_id = cca.counterparty_id
	LEFT JOIN application_ui_template_fields autf
		ON musddv.application_field_id = autf.application_field_id
	LEFT JOIN user_defined_fields_template udft  
		ON udft.udf_template_id = autf.udf_template_id
	LEFT JOIN application_ui_template_definition autd
		ON autf.application_ui_field_id = autd.application_ui_field_id 
	OUTER APPLY (
		SELECT musddv.static_data_udf_values [value]
			FROM application_ui_template_definition autd 
		INNER JOIN application_ui_template_fields autf
			ON autf.application_ui_field_id = autd.application_ui_field_id
		INNER JOIN user_defined_fields_template udft 
			ON udft.udf_template_id = autf.udf_template_id 
		INNER JOIN maintain_udf_static_data_detail_values musddv 
			ON musddv.application_field_id = autf.application_field_id
		WHERE application_function_id = 10105830 
			AND udft.Field_label = 'Contract Limit' AND musddv.primary_field_object_id = cca.counterparty_contract_address_id
	) contract_limit
	OUTER APPLY (
		SELECT musddv.static_data_udf_values [value]
			FROM application_ui_template_definition autd 
		INNER JOIN application_ui_template_fields autf
			ON autf.application_ui_field_id = autd.application_ui_field_id
		INNER JOIN user_defined_fields_template udft 
			ON udft.udf_template_id = autf.udf_template_id 
		INNER JOIN maintain_udf_static_data_detail_values musddv 
			ON musddv.application_field_id = autf.application_field_id
		WHERE application_function_id = 10105830 
			AND udft.Field_label = 'Contract Limit in Words' AND musddv.primary_field_object_id = cca.counterparty_contract_address_id
	) contract_limit_words
	OUTER APPLY (
		SELECT
			TOP 1
			cbi.bank_name,
			cbi.ACH_ABA [aba_number],
			cbi.Address1 + IIF(cbi.Address1 = '','', ', ') + cbi.Address2 [address]
		FROM counterparty_bank_info cbi
		WHERE  cbi.counterparty_id = cca.counterparty_id
		ORDER BY cbi.primary_account DESC  -- cbi.primary_account= 'y'           		
	) cbi 
	WHERE 1 =1 AND autd.application_function_id = 10105800  AND udft.field_name = -5692  
	AND counterparty_contract_address_id = @filter_id -- @counterparty_contract_address_id
	RETURN
END
	
IF @flag = 'a'	
BEGIN

	CREATE TABLE #deal_confirmation_tbl2(source_deal_header_id INT, confirm_replace_flag CHAR(1) COLLATE DATABASE_DEFAULT , term INT,	wtavgCost NUMERIC(30,18), hourlyQty NUMERIC(30,18))

	
	DECLARE @term_start DATETIME, @term_end DATETIME, 
		@fixed_price NUMERIC(30,18), @deal_volume NUMERIC(30,18),  
		@leg INT, @location_id int, @currency_id int, @volume_uom_id int,@location_name VARCHAR(5000),@capacity NUMERIC(30,18), @syv NUMERIC(30,18)


	select @term_start =MIN(term_start),  
			@term_end =max(term_end),
			@fixed_price = max(fixed_price),
			@leg = 1,
			@location_id  = max(sdd.location_id),
			@currency_id = max(fixed_price_currency_id),
			@volume_uom_id = max(deal_volume_uom_id),
			@deal_volume = max(deal_volume),
			@capacity = MAX(sdd.capacity),
			@syv = MIN(sdd.standard_yearly_volume)
	from source_deal_detail sdd
	 LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = sdd.curve_id
	 LEFT JOIN source_price_curve_def spcd1 ON spcd1.source_curve_def_id = sdd.formula_curve_id
	 LEFT JOIN formula_editor fe On fe.formula_id = sdd.formula_id
	where sdd.source_deal_header_id = @source_deal_header_id
	and leg= 1

	INSERT INTO #deal_confirmation_tbl2(source_deal_header_id, confirm_replace_flag, term,	wtavgCost, hourlyQty)
	SELECT  sdh.source_deal_header_id
			, MAX(CASE WHEN scs.confirm_id IS NULL THEN 'c' ELSE 'r' END) confirm_replace_flag
			, COUNT(*) term
			--, CASE WHEN ISNULL(@fixed_price, 0) = 0 THEN MAX(ISNULL(sds.net_price, 0)) ELSE ISNULL(@fixed_price, 0) END 
			, @fixed_price
			, @deal_volume
	FROM source_deal_header sdh
	INNER JOIN dbo.FNASplit(@source_deal_header_id, ',') a ON a.item = sdh.source_deal_header_id
	--INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
	--	AND sdd.Leg = 1
	LEFT JOIN deal_confirmation_rule dcr ON dcr.counterparty_id = sdh.counterparty_id
		AND ISNULL(dcr.buy_sell_flag,sdh.header_buy_sell_flag) = sdh.header_buy_sell_flag
		AND ISNULL(dcr.commodity_id, 0) = (CASE WHEN dcr.commodity_id IS NULL THEN 0 ELSE ISNULL(sdh.commodity_id, 0) END)
		AND ISNULL(dcr.contract_id, 0) = (CASE WHEN dcr.contract_id IS NULL THEN 0 ELSE ISNULL(sdh.contract_id, 0) END)
		AND ISNULL(dcr.deal_type_id, 0) = (CASE WHEN dcr.deal_type_id IS NULL THEN 0 ELSE ISNULL(sdh.source_deal_type_id, 0) END) 
	LEFT JOIN deal_report_template drt1 ON dcr.confirm_template_id = drt1.template_id
	LEFT JOIN deal_report_template drt2 ON dcr.revision_confirm_template_id = drt2.template_id
	LEFT JOIN save_confirm_status scs ON scs.source_deal_header_id = sdh.source_deal_header_id
		AND  scs.[status] = 'v'
	--LEFT JOIN source_deal_settlement sds ON sds.source_deal_header_id = sdh.source_deal_header_id AND sds.term_start = @term_start AND sds.leg = @leg
	GROUP BY sdh.source_deal_header_id

	SELECT @location_name = 
	Location_Name FROM (
		SELECT 
			stuff((
				SELECT DISTINCT ',' + sml.Location_Name
				from source_minor_location sml
					 INNER JOIN source_deal_detail sdd ON sml.source_minor_location_id = sdd.location_id
				where sdd.source_deal_header_id = @source_deal_header_id
				order by ',' + sml.Location_Name
				for xml path('')
			),1,1,'') as Location_Name
	) a

CREATE TABLE #deal_transport(counterparty_name varchar(100) COLLATE DATABASE_DEFAULT , contract_id int, source_deal_header_id INT)
Insert into #deal_transport (counterparty_name, contract_id, source_deal_header_id)
(SELECT DISTINCT sc.counterparty_name, sdh.contract_id, sdh.source_deal_header_id FROM user_defined_deal_fields_template uddft
				INNER JOIN user_defined_deal_fields uddf ON uddf.udf_template_id = uddft.udf_template_id
				INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = uddf.source_deal_header_id
				INNER JOIN source_counterparty sc ON cast(sc.source_counterparty_id AS VARCHAR(100)) = cast (uddf.udf_value AS VARCHAR(100))
				WHERE field_label LIKE '%Pipeline%') 

CREATE TABLE #deal_contract(contract_name varchar(100) COLLATE DATABASE_DEFAULT , contract_id int, source_deal_header_id INT)
Insert into #deal_contract (contract_name, contract_id, source_deal_header_id)
(SELECT DISTINCT cg1.contract_name, cg1.contract_id, sdh.source_deal_header_id FROM user_defined_deal_fields_template uddft
				INNER JOIN user_defined_deal_fields uddf ON uddf.udf_template_id = uddft.udf_template_id
				INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = uddf.source_deal_header_id
				INNER JOIN contract_group cg1 ON cast(cg1.contract_id AS VARCHAR (100)) = cast (uddf.udf_value AS VARCHAR(100))
				WHERE field_label LIKE '%Pipeline%')


CREATE TABLE #deal_description(udf_value varchar(2500) COLLATE DATABASE_DEFAULT ,  source_deal_header_id INT)
Insert into #deal_description (udf_value, source_deal_header_id)
SELECT distinct udf_value, sdh.source_deal_header_id FROM user_defined_deal_fields_template uddft
				INNER JOIN user_defined_deal_fields uddf ON uddf.udf_template_id = uddft.udf_template_id
				INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = uddf.source_deal_header_id
				WHERE sdh.source_deal_header_id = @source_deal_header_id AND uddft.field_type = 't' And uddft.Field_label = 'Description'

	SELECT DISTINCT 
	CASE 
		WHEN sdh.header_buy_sell_flag = 'b'
			THEN COALESCE(MAX(sc.counterparty_name), MAX(cc5.NAME), MAX(cc1.NAME))
		WHEN sdh.header_buy_sell_flag = 's'
			THEN COALESCE(MAX(sc_internal.counterparty_name), MAX(sc_sub.counterparty_name), MAX(primary_sc1.counterparty_name))
		END counterparty_name
	,CASE 
		WHEN sdh.header_buy_sell_flag = 's'
			THEN COALESCE(MAX(sc.counterparty_name), MAX(cc5.NAME), MAX(cc1.NAME))
		WHEN sdh.header_buy_sell_flag = 'b'
			THEN COALESCE(MAX(sc_internal.counterparty_name), MAX(sc_sub.counterparty_name), MAX(primary_sc1.counterparty_name))
		END counterparty_name_buy
	,REPLACE(CASE 
		WHEN sdh.header_buy_sell_flag = 'b'
			THEN COALESCE(MAX(cc5.telephone), MAX(cc1.telephone), MAX(sc.phone_no),MAX(sc_sub.phone_no))
		WHEN sdh.header_buy_sell_flag = 's'
			THEN COALESCE(MAX(cc_internal.telephone), MAX(primary_cc1.telephone),MAX(sc_sub.phone_no))
		END,'-','') counterparty_phone
	,REPLACE(CASE 
		WHEN sdh.header_buy_sell_flag = 's'
			THEN COALESCE(MAX(cc5.telephone), MAX(sc.phone_no))
		WHEN sdh.header_buy_sell_flag = 'b'
			THEN COALESCE(MAX(cc_internal.telephone), MAX(primary_cc1.telephone), MAX(sc_sub.phone_no))
		END,'-','') counterparty_phone_buy
	,REPLACE(CASE 
		WHEN sdh.header_buy_sell_flag = 'b'
			THEN COALESCE(MAX(cc5.fax), MAX(cc1.fax), MAX(sc.fax))
		WHEN sdh.header_buy_sell_flag = 's'
			THEN COALESCE(MAX(cc_internal.fax), MAX(primary_cc1.fax), MAX(sc_sub.fax))
		END,'-','') counterparty_fax
	,REPLACE(CASE 
		WHEN sdh.header_buy_sell_flag = 's'
			THEN COALESCE(MAX(cc5.fax), MAX(cc1.fax), MAX(sc.fax))
		WHEN sdh.header_buy_sell_flag = 'b'
			THEN COALESCE(MAX(cc_internal.fax), MAX(sc_internal.fax), MAX(primary_cc1.fax), MAX(sc_sub.fax))
		END,'-','') counterparty_fax_buy
	,CASE 
		WHEN sdh.header_buy_sell_flag = 'b'
			THEN COALESCE(MAX(cc5.email), MAX(cc1.email), MAX(sc.email))
		WHEN sdh.header_buy_sell_flag = 's'
			THEN COALESCE(MAX(sc_internal.email), MAX(primary_cc1.email), MAX(sc_sub.email))
		END counterparty_email
	,CASE 
		WHEN sdh.header_buy_sell_flag = 's'
			THEN COALESCE(MAX(cc5.email), MAX(cc1.email), MAX(sc.email))
		WHEN sdh.header_buy_sell_flag = 'b'
			THEN COALESCE(MAX(sc_internal.email), MAX(primary_cc1.email), MAX(sc_sub.email))
		END counterparty_email_buy
	,ISNULL(MAX(cg.contract_name), '') contract_name
	,ISNULL(MAX(cg2.contract_name), MAX(sc.contact_name)) contract_name_buy
	,MAX(dbo.FNADateFormat(cca.contract_start_date)) [effective_date]
	,dbo.FNADateFormat(GETDATE()) [Date]
	,MAX(sdh.deal_id) [deal_reference_id]
	,MAX(CASE uddf5.udf_value
			WHEN '1'
				THEN 'Short Term'
			WHEN '2'
				THEN 'Long Term'
			ELSE ''
			END) [transaction_type]
	,MAX(dbo.FNADateFormat(sdh.deal_date)) [deal_date]
	,@location_name Location_Name 
	,CASE
		WHEN MAX(uddf.udf_value) = '1' THEN 'Firm' 
		WHEN MAX(uddf.udf_value) = '2' THEN 'Spot' 
		WHEN MAX(uddf.udf_value) = '3' THEN 'Peaking' 
		WHEN MAX(uddf.udf_value) = '4' THEN 'Others' 
		ELSE ''
	END [Service_level]
	,ISNULL(MAX(CAST(uddf1.udf_value AS FLOAT)), 0) [max_daily_quantity]
	,ISNULL(MAX(CAST(uddf2.udf_value AS FLOAT)), 0) [min_daily_quantity]
	,ISNULL(MAX(CAST(uddf3.udf_value AS FLOAT)), 0) [demand_charges]
	,DATENAME(mm, min(sdd.term_start)) + ' ' + DATENAME(dd,min(sdd.term_start)) + ', ' + DATENAME(YEAR,min(sdd.term_start))  term_start
	,DATENAME(mm, max(sdd.term_end)) + ' ' + DATENAME(dd,max(sdd.term_end)) + ', ' + DATENAME(YEAR,max(sdd.term_end))  end_date
	,@pricing [Fixed_Price]
	,MAX(dct2.confirm_replace_flag) confirm_replace_flag
	,MAX(scu.currency_name) + ' / '+ MAX(su.uom_name) fixed_price_curr_uom
	,MAX(sdh.source_deal_header_id) source_deal_header_id
	,MAX(uddf6.udf_value) description4
	,MAX(uddf4.udf_value) nom_time_stamp
	,CASE 
		WHEN sdh.header_buy_sell_flag = 's'
			THEN 'Sell'
		ELSE 'Buy'
		END [header_buy_sell_flag]
	,CASE 
		WHEN sdh.header_buy_sell_flag = 'b'
			THEN ISNULL(MAX(sdv.code), '')
		WHEN sdh.header_buy_sell_flag = 's'
			THEN COALESCE(MAX(primary1_sdv.code), MAX(sdv_internal.code), MAX(sdv_primary_cc1.code), primary_sdv.code)
		END STATE
	, CASE 
		WHEN sdh.header_buy_sell_flag = 's'
			THEN ISNULL(MAX(sdv.code), '')
		WHEN sdh.header_buy_sell_flag = 'b'
			THEN COALESCE(MAX(sdv_internal.code), MAX(sdv_primary_cc1.code), primary_sdv.code)
		END state_buy
	,CASE 
		WHEN sdh.header_buy_sell_flag = 'b'
			THEN ISNULL(MAX(cc1.city), '')
		WHEN sdh.header_buy_sell_flag = 's'
			THEN COALESCE(MAX(cc_internal.city), MAX(sc_sub.city), primary_cc1.[city])
		END city
	,CASE 
		WHEN sdh.header_buy_sell_flag = 's'
			THEN ISNULL(MAX(cc1.city), '')
		WHEN sdh.header_buy_sell_flag = 'b'
			THEN COALESCE(MAX(cc_internal.city), MAX(sc_sub.city), primary_cc1.[city])
		END city_buy
	,CASE 
		WHEN sdh.header_buy_sell_flag = 'b'
			THEN ISNULL(MAX(cc1.zip), '')
		WHEN sdh.header_buy_sell_flag = 's'
			THEN COALESCE(MAX(cc_internal.[zip]), MAX(sc_sub.[zip]), primary_cc1.[zip])
		END zip
	,CASE 
		WHEN sdh.header_buy_sell_flag = 's'
			THEN ISNULL(MAX(cc1.zip), '')
		WHEN sdh.header_buy_sell_flag = 'b'
			THEN COALESCE(MAX(cc_internal.[zip]), MAX(sc_sub.[zip]), primary_cc1.[zip])
		END zip_buy
	,ISNULL(MAX(sc.counterparty_id),'') counterparty_id
	,CASE 
		WHEN sdh.header_buy_sell_flag = 'b'
			THEN ISNULL(MAX(cc1.NAME), '')
		WHEN sdh.header_buy_sell_flag = 's'
			THEN COALESCE(MAX(cc_internal.NAME), MAX(sc_sub.NAME), MAX(primary_cc1.NAME))
		END counterparty_contact_name
	,CASE 
		WHEN sdh.header_buy_sell_flag = 's'
			THEN ISNULL(MAX(cc1.NAME), '')
		WHEN sdh.header_buy_sell_flag = 'b'
			THEN COALESCE(MAX(cc_internal.NAME), MAX(sc_sub.NAME), MAX(primary_cc1.NAME))
		END counterparty_contact_name_buy
	,ISNULL(MAX(cg.contract_id), '') contract_id
	,sdh.contract_id [base_contract]
	,sdd.deal_volume
	,dd.udf_value [description]
	,dt.counterparty_name [transporter]
	,ISNULL(CASE WHEN CAST(ROUND(MAX(ABS(sdd.price_adder)),4) AS NUMERIC(20,4)) <> 0 THEN 
		CASE WHEN sdd.fixed_price IS NOT NULL THEN (scu.currency_name + ' ' + Cast(CAST(ROUND(MAX(sdd.fixed_price),4) AS NUMERIC(20,4)) As Varchar(30)))
			 WHEN sdd.fixed_price IS NULL THEN ((SELECT spcd.curve_name FROM source_price_curve_def spcd WHERE spcd.source_curve_def_id = sdd.formula_curve_id) + 
			 CASE 
			 WHEN MAX(sdd.price_adder) < 0 THEN ' less '
			 WHEN MAX(sdd.price_adder) = 0 THEN ' '
			 WHEN MAX(sdd.price_adder) IS null THEN ' '
			 ELSE ' plus ' 
			 END +
			 CAST(CAST(ROUND(MAX(ABS(sdd.price_adder)),4) AS NUMERIC(20,4)) AS VARCHAR(30)) ) 
		END
		ELSE CASE WHEN sdd.fixed_price IS NOT NULL THEN (scu.currency_name + ' ' + CAST(CAST(ROUND(MAX(sdd.fixed_price),4) AS NUMERIC(20,4)) AS VARCHAR(30)))
			 WHEN sdd.fixed_price IS NULL THEN @pricing END END ,0)
			 [contract_price],
		dc.contract_name transporter_id,
	CASE 
		WHEN sdh.header_buy_sell_flag = 'b'
			THEN ISNULL(MAX(cc1.[address1])+' '+ MAX(cc1.[address2]), MAX(sc.[address]))
		WHEN sdh.header_buy_sell_flag = 's'
			THEN COALESCE(MAX(cc_internal.address1) + ' ' + MAX(cc_internal.address2), MAX(sc_sub.[address1]), MAX(primary_cc1.[address1])+ ' '+ MAX(primary_cc1.[address2]))
		END counterparty_address
	,CASE 
		WHEN sdh.header_buy_sell_flag = 's'
			THEN ISNULL(MAX(cc1.[address1])+' '+ MAX(cc1.[address2]), MAX(sc.[address]))
		WHEN sdh.header_buy_sell_flag = 'b'
			THEN  COALESCE(MAX(cc_internal.address1) + ' ' + MAX(cc_internal.address2), MAX(sc_sub.[address1]), MAX(primary_cc1.[address1])+ ' '+ MAX(primary_cc1.[address2]))
			
		END counterparty_address_buy
	,CASE 
		WHEN sdh.header_buy_sell_flag = 'b'
			THEN ISNULL(MAX(cc1.[name]), MAX(sc.contact_name))
		WHEN sdh.header_buy_sell_flag = 's'
			THEN COALESCE(MAX(cc_internal.NAME), MAX(sc_sub.NAME), MAX(primary_cc1.[name]))
		END buyer_name
	,CASE 
		WHEN sdh.header_buy_sell_flag = 's'
			THEN ISNULL(MAX(cc1.[name]), MAX(sc.contact_name))
		WHEN sdh.header_buy_sell_flag = 'b'
			THEN COALESCE(MAX(cc_internal.NAME), MAX(sc_sub.NAME), MAX(primary_cc1.[name]))
		END buyer_name_buy
	,CASE 
		WHEN sdh.header_buy_sell_flag = 'b'
			THEN ISNULL(MAX(cc1.title), MAX(sc.contact_title))
		WHEN sdh.header_buy_sell_flag = 's'
			THEN COALESCE(MAX(cc_internal.title), MAX(sc_sub.title), MAX(primary_cc1.title))
		END buyer_title
	,CASE 
		WHEN sdh.header_buy_sell_flag = 's'
			THEN ISNULL(MAX(cc1.title), MAX(sc.contact_title))
		WHEN sdh.header_buy_sell_flag = 'b'
			THEN COALESCE(MAX(cc_internal.title), MAX(sc_sub.title), MAX(primary_cc1.title))
		END buyer_title_buy
	,
		MAX(sdh.confirm_status_type) confirm_status_type,
		MAX(uddf7.udf_value) special_condition,

		CASE WHEN MAX(sdh.confirm_status_type) = '17202'
			THEN @file_path + '/dev/shared_docs/attach_docs/setup user/' + @user_signature_name 
		ELSE ''
		END [user_signature]

		INTO #temp_table
	FROM source_deal_header sdh
	INNER JOIN #deal_confirmation_tbl2 dct2 on dct2.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN source_deal_type sdt ON sdh.source_deal_type_id = sdt.source_deal_type_id
	LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = sdh.counterparty_id
	LEFT JOIN contract_group cg ON cg.contract_id = sdh.contract_id
	LEFT JOIN contract_group cg2 ON cg2.contract_id = sdh.contract_id 
	LEFT JOIN counterparty_contract_address cca ON cca.contract_id = cg.contract_id AND cca.counterparty_id = sc.source_counterparty_id
	LEFT JOIN user_defined_deal_fields_template uddft ON uddft.Field_label = 'Service level' AND uddft.template_id = sdh.template_id
	LEFT JOIN user_defined_deal_fields uddf ON uddf.source_deal_header_id = sdh.source_deal_header_id  AND uddft.udf_template_id = uddf.udf_template_id	
	LEFT JOIN user_defined_deal_fields_template uddft1 ON uddft1.Field_label = 'Maximum Daily Quantity' AND uddft1.template_id = sdh.template_id
	LEFT JOIN user_defined_deal_fields uddf1 ON uddf1.source_deal_header_id = sdh.source_deal_header_id AND uddft1.udf_template_id = uddf1.udf_template_id	
	LEFT JOIN user_defined_deal_fields_template uddft2 ON uddft2.Field_label = 'Minimum Daily Quantity' AND uddft2.template_id = sdh.template_id
	LEFT JOIN user_defined_deal_fields uddf2 ON uddf2.source_deal_header_id = sdh.source_deal_header_id AND uddft2.udf_template_id = uddf2.udf_template_id	
	LEFT JOIN user_defined_deal_fields_template uddft3 ON uddft3.Field_label = 'Demand Charges' AND uddft3.template_id = sdh.template_id
	LEFT JOIN user_defined_deal_fields uddf3 ON uddf3.source_deal_header_id = sdh.source_deal_header_id AND uddft3.udf_template_id = uddf3.udf_template_id
	LEFT JOIN user_defined_deal_fields_template uddft4 ON uddft4.Field_id = -5696 AND uddft4.template_id = sdh.template_id
	LEFT JOIN user_defined_deal_fields uddf4 ON uddf4.source_deal_header_id = sdh.source_deal_header_id AND uddft4.udf_template_id = uddf4.udf_template_id
	LEFT JOIN user_defined_deal_fields_template uddft5 ON uddft5.Field_label = 'Contract Type' AND uddft5.template_id = sdh.template_id
	LEFT JOIN user_defined_deal_fields uddf5 ON uddf5.source_deal_header_id = sdh.source_deal_header_id AND uddft5.udf_template_id = uddf5.udf_template_id
	LEFT JOIN user_defined_deal_fields_template uddft6 ON uddft6.Field_id = -5697 AND uddft6.template_id = sdh.template_id
	LEFT JOIN user_defined_deal_fields uddf6 ON uddf6.source_deal_header_id = sdh.source_deal_header_id AND uddft6.udf_template_id = uddf6.udf_template_id
	LEFT JOIN user_defined_deal_fields_template uddft7 ON uddft7.field_label = 'Special Condition' AND uddft7.template_id = sdh.template_id
	LEFT JOIN user_defined_deal_fields uddf7 ON uddf7.source_deal_header_id = sdh.source_deal_header_id AND uddf7.udf_template_id = uddf7.udf_template_id
	LEFT JOIN source_deal_header_template sdht ON sdht.template_id = uddft.template_id
	LEFT JOIN source_currency scu ON scu.source_currency_id = @currency_id
	LEFT JOIN dbo.source_uom su ON su.source_uom_id = @volume_uom_id
	LEFT JOIN #deal_transport dt on dt.source_deal_header_id = sdh.source_deal_header_id
	LEFT JOIN #deal_contract dc on dc.source_deal_header_id = sdh.source_deal_header_id
	LEFT JOIN #deal_description dd on dd.source_deal_header_id = sdh.source_deal_header_id
	LEFT JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
	LEFT JOIN source_counterparty sc3 on sc3.source_counterparty_id = sc.source_counterparty_id	
	LEFT JOIN source_counterparty sc2 ON sc2.source_counterparty_id = cg.pipeline AND cg.transportation_contract = 't'
	LEFT JOIN counterparty_contacts cc1 on cc1.counterparty_id = sdh.counterparty_id
	LEFT JOIN static_data_value sdv ON sdv.value_id = cc1.state
	LEFT JOIN source_counterparty primary_sc1 ON primary_sc1.source_counterparty_id = @counterparty_id
	LEFT JOIN counterparty_contacts primary_cc1 on primary_cc1.counterparty_id = primary_sc1.source_counterparty_id AND primary_cc1.is_active = 'y' AND primary_cc1.counterparty_contact_id = primary_sc1.confirmation
	LEFT JOIN static_data_value primary_sdv ON primary_sdv.value_id = primary_cc1.contact_type AND primary_sdv.type_id = 32200 AND primary_sdv.code = 'Confirmation'
	LEFT JOIN counterparty_contacts cc5 ON cc5.counterparty_contact_id = ISNULL(cca.confirmation,sc.confirmation)
	LEFT JOIN static_data_value cc5_sdv ON  cc5_sdv.value_id =cc5.state 
	LEFT JOIN static_data_value primary1_sdv ON  primary1_sdv.value_id =primary_cc1.state
	LEFT JOIN source_counterparty sc_internal ON sc_internal.source_counterparty_id= sdh.internal_counterparty
	LEFT JOIN counterparty_contacts cc_internal ON cc_internal.counterparty_id = sc_internal.source_counterparty_id
	LEFT JOIN static_data_value sdv_internal ON cc_internal.state = sdv_internal.value_id
	LEFT JOIN static_data_value sdv_primary_cc1 ON primary_cc1.state =sdv_primary_cc1.value_id
	--WHERE sdd.term_start = CASE WHEN @param_term_start IS NULL THEN sdd.term_start ELSE @param_term_start END
		--AND sdd.term_end = CASE WHEN @param_term_end IS NULL THEN sdd.term_end ELSE @param_term_end END 
	OUTER APPLY(	SELECT sc.counterparty_name,cc.telephone phone_no,sc.email,cc.fax,ISNULL(cc.address1,'')+' '+ISNULL(cc.address2,'') address1,cc.city,cc.zip,cc.name,cc.title
		FROM portfolio_hierarchy book(NOLOCK)
		INNER JOIN Portfolio_hierarchy stra(NOLOCK) ON book.parent_entity_id = stra.entity_id
		INNER JOIN source_system_book_map sbm ON sbm.fas_book_id = book.entity_id
		INNER JOIN fas_subsidiaries fs ON fs.fas_subsidiary_id = stra.parent_entity_id
		INNER JOIN source_deal_header sdh1 on sdh1.source_system_book_id1=sbm.source_system_book_id1
				 AND sdh1.source_system_book_id2=sbm.source_system_book_id2
				 AND sdh1.source_system_book_id3=sbm.source_system_book_id3
				 AND sdh1.source_system_book_id4=sbm.source_system_book_id4
		LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = fs.counterparty_id
		LEFT JOIN counterparty_contacts cc ON cc.counterparty_id = sc.source_counterparty_id
				 WHERE source_deal_header_id =  sdh.source_deal_header_id
	) sc_sub
	GROUP BY sdh.header_buy_sell_flag, sc.city, sc.state, sc.zip, sdh.contract_id, sdd.deal_volume, sdd.fixed_price, sdd.curve_id, sdd.price_adder, scu.currency_name,sc3.counterparty_name,sc.address, sc.contact_address, cg.contract_name, sc.counterparty_contact_name,sdv.code, dt.counterparty_name, dc.contract_name, sdd.formula_curve_id, dd.udf_value,sdh.source_deal_header_id
	,primary_sdv.code, primary_cc1.city, primary_cc1.zip,primary_cc1.name,cc1.name

	SELECT * FROM #temp_table sdd WHERE sdd.term_start = CASE WHEN @param_term_start IS NULL THEN sdd.term_start ELSE @param_term_start END

DROP TABLE #deal_transport
DROP TABLE #deal_contract
DROP TABLe #deal_description
	DROP TABLE #deal_confirmation_tbl2
	DROP TABLE #temp_table
END
ELSE IF @flag <> 'a'
BEGIN
	
DECLARE @vol_frequency_table   VARCHAR(128)
DECLARE @process_id            VARCHAR(50)
DECLARE @user_login_id         VARCHAR(50)
DECLARE @sql_Select            VARCHAR(MAX)
DECLARE @sql_Select2            VARCHAR(MAX)
DECLARE @wtavgCost             NUMERIC(36, 12)
DECLARE @hourlyQty             VARCHAR(100)
DECLARE @term                  VARCHAR(100)
DECLARE @filename1             VARCHAR(100)
DECLARE @filename2             VARCHAR(100)
DECLARE @confirm_replace_flag  CHAR(1)

---## GET the volume by frequency	
SET @user_login_id = dbo.FNADBUser()
SET @process_id = REPLACE(NEWID(), '-', '_')

SET @vol_frequency_table = dbo.FNAProcessTableName('deal_volume_frequency_mult', @user_login_id, @process_id)

SET @sql_Select = 'SELECT DISTINCT 
                          sdd.term_start,
                          sdd.term_end,
                          sdd.deal_volume_frequency AS deal_volume_frequency,
                          ISNULL(spcd1.block_type, sdh.block_type) block_type,
                          ISNULL(spcd1.block_define_id, sdh.block_define_id) 
                          block_definition_id
                          INTO ' + @vol_frequency_table + '
                   FROM   source_deal_header sdh
					INNER JOIN dbo.SplitCommaSeperatedValues(''' + @source_deal_header_id + ''') a ON  a.item = sdh.source_deal_header_id
					INNER JOIN source_deal_detail sdd ON  sdd.source_deal_header_id = sdh.source_deal_header_id
					LEFT JOIN source_deal_detail sdd1 ON  sdh.source_deal_header_id = sdd1.source_deal_header_id
						AND sdd.term_start = sdd1.term_start
						AND sdd1.leg = 1
					LEFT JOIN source_price_curve_def spcd1 ON  sdd1.curve_id = spcd1.source_curve_def_id'

		
EXEC (@sql_Select)

EXEC spa_get_dealvolume_mult_byfrequency @vol_frequency_table
EXEC spa_print @vol_frequency_table
	
CREATE TABLE #deal_confirmation_tbl(source_deal_header_id INT, confirm_replace_flag CHAR(1) COLLATE DATABASE_DEFAULT , [filename] VARCHAR(1000) COLLATE DATABASE_DEFAULT , [filename1] VARCHAR(1000) COLLATE DATABASE_DEFAULT , term INT,	wtavgCost NUMERIC(30,18), hourlyQty NUMERIC(30,18))

INSERT INTO #deal_confirmation_tbl(source_deal_header_id, confirm_replace_flag, [filename], [filename1], term,	wtavgCost, hourlyQty)
SELECT  sdh.source_deal_header_id
		, MAX(CASE WHEN scs.confirm_id IS NULL THEN 'c' ELSE 'r' END) confirm_replace_flag
		, MAX(ISNULL(drt1.[filename], 'confirm_template.php')) [filename]
		, MAX(ISNULL(drt2.[filename], 'confirm_template_replacement.php')) [filename1]
		, COUNT(*) term
		, CASE WHEN SUM(deal_volume) = 0 THEN 0 ELSE SUM(deal_volume * (ISNULL(sdd.fixed_price, 0) + ISNULL(sdd.price_adder, 0))) / SUM(deal_volume) END
		, AVG(deal_volume) 
FROM source_deal_header sdh
INNER JOIN dbo.FNASplit(@source_deal_header_id, ',') a ON a.item = sdh.source_deal_header_id
INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
	AND sdd.Leg = 1
LEFT JOIN deal_confirmation_rule dcr ON dcr.counterparty_id = sdh.counterparty_id
	AND ISNULL(dcr.buy_sell_flag,sdh.header_buy_sell_flag) = sdh.header_buy_sell_flag
	AND ISNULL(dcr.commodity_id, 0) = (CASE WHEN dcr.commodity_id IS NULL THEN 0 ELSE ISNULL(sdh.commodity_id, 0) END)
	AND ISNULL(dcr.contract_id, 0) = (CASE WHEN dcr.contract_id IS NULL THEN 0 ELSE ISNULL(sdh.contract_id, 0) END)
	AND ISNULL(dcr.deal_type_id, 0) = (CASE WHEN dcr.deal_type_id IS NULL THEN 0 ELSE ISNULL(sdh.source_deal_type_id, 0) END) 
LEFT JOIN deal_report_template drt1 ON dcr.confirm_template_id = drt1.template_id
LEFT JOIN deal_report_template drt2 ON dcr.revision_confirm_template_id = drt2.template_id
LEFT JOIN save_confirm_status scs ON scs.source_deal_header_id = sdh.source_deal_header_id
	AND  scs.[status] = 'v'
GROUP BY sdh.source_deal_header_id

IF @flag = 'v'	
BEGIN
		SELECT 
		 ddh.Hr1
		, CASE WHEN mdst.hour = 2 THEN iif(mdst.id IS NOT NULL, ddh.Hr2 - ISNULL(ddh.Hr25,0), ddh.Hr2)  ELSE Hr2 END Hr2
		, CASE WHEN mdst.hour = 3 THEN iif(mdst.id IS NOT NULL, ddh.Hr3 - ISNULL(ddh.Hr25,0), ddh.Hr3)  ELSE Hr3 END hr3
		, ddh.Hr4
		, ddh.Hr5
		, ddh.Hr6
		, ddh.Hr7
		, ddh.Hr8
		, ddh.Hr9
		, ddh.Hr10
		, ddh.Hr11
		, ddh.Hr12
		, ddh.Hr13
		, ddh.Hr14
		, ddh.Hr15
		, ddh.Hr16
		, ddh.Hr17
		, ddh.Hr18
		, ddh.Hr19
		, ddh.Hr20
		, ddh.Hr21
		, ddh.Hr22
		, ddh.Hr23
		, ddh.Hr24	
		, ddh.Hr25
	INTO #deal_data
	FROM forecast_profile fp 
	INNER JOIN deal_detail_hour ddh ON ddh.profile_id = fp.profile_id 
	LEFT JOIN mv90_dst mdst on mdst.date = ddh.term_date
	INNER JOIN source_deal_detail sdd on sdd.profile_id = ddh.profile_id
	INNER JOIN source_deal_header sdh on sdh.source_deal_header_id = sdd.source_deal_header_id 
	WHERE 1 = 1	and sdh.source_deal_header_id = @source_deal_header_id 	

		SELECT
		CAST(REPLACE(hour, 'Hr','') AS varchar) [hour]	
		, value		
		INTO #deal_detail_hour
		FROM #deal_data 
		UNPIVOT
				   (value FOR [Hour] IN 
				   ([Hr1],[Hr2],[Hr3],[Hr4],[Hr5],[Hr6],[Hr7],[Hr8],[Hr9],[Hr10],[Hr11],[Hr12],[Hr13],[Hr14],[Hr15],[Hr16],[Hr17],[Hr18],[Hr19],[Hr20],[Hr21],[Hr22],[Hr23],[Hr24],[Hr25])
				)AS unpvt
		WHERE 1 = 1 

    set @avg_value = (select avg(value) from #deal_detail_hour)
	
	SET @sql_Select = '
		 SELECT DISTINCT dbo.FNAConvertTZAwareDateFormat(GETDATE(),1) [Date], ''' + @company +''' company_name,
		 CASE 
			WHEN sdh.header_buy_sell_flag = ''b''
				THEN COALESCE(MAX(scp.counterparty_name), MAX(cc5.NAME), MAX(cc1.NAME))
			WHEN sdh.header_buy_sell_flag = ''s''
				THEN COALESCE(MAX(sc_internal.counterparty_name), MAX(sc_sub.counterparty_name), MAX(primary_sc1.counterparty_name))
			END counterparty_name
		,CASE 
			WHEN sdh.header_buy_sell_flag = ''s''
				THEN COALESCE(MAX(scp.counterparty_name), MAX(cc5.NAME), MAX(cc1.NAME))
			WHEN sdh.header_buy_sell_flag = ''b''
				THEN COALESCE(MAX(sc_internal.counterparty_name), MAX(sc_sub.counterparty_name), MAX(primary_sc1.counterparty_name))
			END counterparty_name_buy,
			CASE 
		WHEN sdh.header_buy_sell_flag = ''b''
			THEN COALESCE(MAX(cc1.title), MAX(cc01.title),MAX(scp.contact_title))
		WHEN sdh.header_buy_sell_flag = ''s''
			THEN COALESCE(MAX(cc_internal.title),MAX(cc_internal1.title), MAX(sc_sub.title), MAX(primary_cc1.title))
		END buyer_title
	,CASE 
		WHEN sdh.header_buy_sell_flag = ''s''
			THEN COALESCE(MAX(cc1.title), MAX(cc01.title),MAX(scp.contact_title))
		WHEN sdh.header_buy_sell_flag = ''b''
			THEN COALESCE(MAX(cc_internal.title),MAX(cc_internal1.title), MAX(sc_sub.title), MAX(primary_cc1.title))
		END buyer_title_buy,
				st.trader_name Trader,CAST(sdh.deal_date AS DATE) [Trade Date],
				sdt.source_deal_type_name [Trade Type],
				CASE WHEN sdh.header_buy_sell_flag=''b'' THEN ''Buy'' ELSE ''Sell'' end AS [Type],
				MAX(sc.commodity_name) [Commodity], 
				MIN(sdd.term_start) [Start Date], MAX(sdd.term_end) [End Date],
				CASE 
					WHEN MAX(sdd.deal_volume_frequency) =''t'' 
						THEN CAST(dbo.FNARemoveTrailingZeroes(ISNULL(AVG(CASE WHEN ISNULL(sddh.volume, 0.0) = 0.0 THEN NULL ELSE ISNULL(sddh.volume, 0.0) END), 0.0)) as VARCHAR) + '' '' +  MAX(su.uom_name) + '' per term'' 
					ELSE 
						CASE 
							WHEN CAST(MAX(hourlyQty) AS decimal(10,2))
							 IS NULL THEN 
							 ''' + CAST(ISNULL(@avg_value,0) AS VARCHAR(10)) +'''								
								 + '' ''
							  + MAX(su.uom_name) 
							 + '' per '' + dbo.FNAGetFrequencyText(MAX(sdd.deal_volume_frequency), ''v'') 
							ELSE CAST(dbo.FNARemoveTrailingZeroes(CAST(MAX(hourlyQty) AS decimal(10,2))) AS VARCHAR(1000)) + '' '' + MAX(su.uom_name) + '' per '' + dbo.FNAGetFrequencyText(MAX(sdd.deal_volume_frequency),''v'') 
						END 
				END [Quantity] ,
				CASE WHEN MAX(sdd.deal_volume_frequency) =''t'' THEN CAST(dbo.FNARemoveTrailingZeroes(SUM(isnull(sddh.volume,0))) AS VARCHAR) ELSE CAST(dbo.FNARemoveTrailingZeroes(CAST(SUM(sdd.total_volume) AS NUMERIC(36,10))) AS VARCHAR) END + '' '' + ISNULL(MAX(su1.uom_name), '''')  [Total Quantity],			
				ISNULL(MAX(spcd.curve_name), MAX(risk_spcd.curve_name)) AS [Price Index],
				''1st day of the month'' [Pricing Date]
				,NULLIF(CAST(''' + ISNULL(@pricing_1, '') + ''' AS flOAT),0) [Fixed Price],
				''firm'' [Service Type]
				,dbo.FNAGetFrequencyText(MAX(sdht.term_frequency_type),''a'') [Payment Frequency],
				CASE WHEN sdh.source_deal_type_id=3 THEN ''T+2'' ELSE ''T+5'' END [Settle Rules],
				ISNULL(MAX(sdv1.code),MAX(sdv.code)) [Holiday Calendar],
				MAX(sdh.deal_id) [External Trade ID],
				MAX(ph.entity_name) [Book],
				MAX(sdd.deal_detail_description) [Comments],
				ISNULL(MAX(scp.counterparty_name),'''') counterparty_name,
				ISNULL(MAX(scp.address),'''')  counterparty_address,
				ISNULL(MAX(scp.phone_no),'''') counterparty_phone_no,
				ISNULL(MAX(scp.mailing_address),'''') counterparty_mailing_address,
				ISNULL(MAX(scp.contact_fax),'''') + '' / '' + ISNULL(MAX(scp.contact_email),'''')  counterparty_fax_email,
				isnull(MAX(sdv2.code),''New'') [Trade Confirmation Status],	
				max(a.comment1)	[Trade Confirmation comment],
				''0'' [nearby month],
				''last day'' [Roll Convention],
				MAX(au.user_off_tel) [TraderPhone],
				MAX(au.user_fax_tel) [TraderFax],
				MAX(au.user_emal_add) [TraderEmail],
				''day 20 of month following delivery'' as [PaymentDates],
					MAX(sdh.source_deal_header_id) [System Trade ID],
				MAX(sdh.create_user) [Input By],
				MAX(sdh.option_settlement_date) [Premium Settlement Date],
				CAST(ROUND(MAX(sdd.option_strike_price),2) AS NUMERIC(20,2))[Strike Price],
				CAST(CAST(ROUND(AVG((( isnull(sdd.fixed_price, 0) + isnull(sdd.price_adder, 0)) * isnull(sdd.price_multiplier, 1))),2)AS NUMERIC(20,2)) AS VARCHAR) + '' ''  [Premium],
				CAST(dbo.FNARemoveTrailingZeroes(ROUND(SUM(((isnull(sdd.fixed_price, 0) +  isnull(sdd.price_adder, 0)) * isnull(sdd.price_multiplier, 1))* ISNULL(vft.Volume_Mult,1)*sdd.deal_volume),2)) AS VARCHAR(100)) + '' '' + MAX(scu.currency_name) [TotalPremium],
				dbo.FNAConvertTZAwareDateFormat(MAX(sdh.create_ts),1) [Input Date],
				au2.user_l_name + '', '' + au2.user_f_name + '' '' + ISNULL(au2.user_m_name,'''') [Verified By Name],
				sdh.verified_date [Verified Date],
				st.user_login_id,
				ISNULL(sml.Location_Name, '''') [Location Name],
				ISNULL(scp1.counterparty_name, '''') [Counterparty Name],
				max(dct.confirm_replace_flag) [confirm_replace_flag]
				,max(dct.filename) [filename]
				,max(dct.filename1) [filename1]
				,dbo.FNAGetFrequencyText(MAX(sdd.deal_volume_frequency), ''a'') [deal_volume_frequency]				
				,MAX(ISNULL(spcd.curve_definition,spcd.curve_id)) [curve]	
				,sdh.source_deal_header_id	
				,MAX(sdh.confirm_status_type) confirm_status_type
				,COALESCE(ISNULL(MAX(cc_internal.telephone),MAX(cc_internal1.telephone)), MAX(sc_sub.phone_no), MAX(primary_cc1.telephone))telephone
				,COALESCE(ISNULL(MAX(cc_internal.fax),MAX(cc_internal1.fax)), MAX(sc_sub.fax), MAX(primary_cc1.fax)) fax_no,
				CASE 
					WHEN sdh.header_buy_sell_flag = ''b''
						THEN ISNULL(MAX(cc1.NAME), MAX(cc01.NAME))
					WHEN sdh.header_buy_sell_flag = ''s''
						THEN COALESCE(MAX(cc_internal.NAME),MAX(cc_internal1.NAME), MAX(sc_sub.NAME), MAX(primary_cc1.NAME))
					END counterparty_contact_name
				,CASE 
					WHEN sdh.header_buy_sell_flag = ''s''
						THEN ISNULL(MAX(cc1.NAME), MAX(cc01.NAME))
					WHEN sdh.header_buy_sell_flag = ''b''
						THEN COALESCE(MAX(cc_internal.NAME),MAX(cc_internal1.NAME), MAX(sc_sub.NAME), MAX(primary_cc1.NAME))
					END counterparty_contact_name_buy, 
				CASE 
					WHEN MAX(sdh.confirm_status_type) = ''17202''
							THEN ''' + @file_path + '/dev/shared_docs/attach_docs/setup user/' + isnull(@user_signature_name, '') +'''
						ELSE ''''
				END user_signature,
				GETDATE() [current_date] ,
				CASE
					WHEN sdh.header_buy_sell_flag = ''s''
						THEN COALESCE(ISNULL(MAX(cc_internal.address1),MAX(cc_internal1.address1)), MAX(sc_sub.address01), MAX(primary_cc1.address1))
					WHEN sdh.header_buy_sell_flag = ''b''
						THEN ISNULL(MAX(cc1.address1), MAX(cc01.address1))
					END address1_counterparty
				,CASE
					WHEN sdh.header_buy_sell_flag = ''s''
						THEN MAX(cc_internal.id) 
					WHEN sdh.header_buy_sell_flag = ''b''
						THEN MAX(cc1.id) 
					END contract_id
				,CASE 
					WHEN sdh.header_buy_sell_flag = ''s''
						THEN ISNULL(MAX(cc1.address1), MAX(cc01.address1))
					WHEN sdh.header_buy_sell_flag = ''b''
						THEN COALESCE(ISNULL(MAX(cc_internal.address1),MAX(cc_internal1.address1)), MAX(sc_sub.address01), MAX(primary_cc1.address1))
					END address1_counterparty_buy
				,CASE 
					WHEN sdh.header_buy_sell_flag = ''s''
						THEN COALESCE(ISNULL(MAX(cc_internal.address2),MAX(cc_internal1.address2)), MAX(sc_sub.address02), MAX(primary_cc1.address2))
					WHEN sdh.header_buy_sell_flag = ''b''
						THEN ISNULL(MAX(cc1.address2), MAX(cc01.address2))
					END address2_counterparty
				,CASE
					WHEN sdh.header_buy_sell_flag = ''s''
						THEN MAX(cc1.id) 
					WHEN sdh.header_buy_sell_flag = ''b''
						THEN MAX(cc_internal.id) 
					END contract_id1
				,CASE 
					WHEN sdh.header_buy_sell_flag = ''s''
						THEN ISNULL(MAX(cc1.address2), MAX(cc01.address2))
					WHEN sdh.header_buy_sell_flag = ''b''
						THEN COALESCE(ISNULL(MAX(cc_internal.address2),MAX(cc_internal1.address2)), MAX(sc_sub.address02), MAX(primary_cc1.address2))
					END address2_counterparty_buy
				,CASE 
					WHEN sdh.header_buy_sell_flag = ''b''
						THEN ISNULL(MAX(cc1.fax),MAX(cc01.fax))	
					WHEN sdh.header_buy_sell_flag = ''s''
						THEN COALESCE(ISNULL(MAX(cc_internal.fax),MAX(cc_internal1.fax)), MAX(sc_sub.fax), MAX(primary_cc1.fax))
					END counterparty_fax
				,CASE 
					WHEN sdh.header_buy_sell_flag = ''s''
						THEN ISNULL(MAX(cc1.fax),MAX(cc01.fax))	
					WHEN sdh.header_buy_sell_flag = ''b''
						THEN COALESCE(ISNULL(MAX(cc_internal.fax),MAX(cc_internal1.fax)), MAX(sc_sub.fax), MAX(primary_cc1.fax))
					END counterparty_fax_buy
				,CASE 
					WHEN sdh.header_buy_sell_flag = ''b''
						THEN ISNULL(MAX(cc1.email),MAX(cc01.email))
					WHEN sdh.header_buy_sell_flag = ''s''
						THEN COALESCE(ISNULL(MAX(cc_internal.email),MAX(cc_internal1.email)), MAX(sc_sub.email), MAX(primary_cc1.email)) 
					END counterparty_email
				,CASE 
					WHEN sdh.header_buy_sell_flag = ''s''
						THEN ISNULL(MAX(cc1.email),MAX(cc01.email))
					WHEN sdh.header_buy_sell_flag = ''b''
						THEN COALESCE(ISNULL(MAX(cc_internal.email),MAX(cc_internal1.email)), MAX(sc_sub.email), MAX(primary_cc1.email)) 
					END counterparty_email_buy
				,CASE 
					WHEN sdh.header_buy_sell_flag = ''b''
						THEN ISNULL(MAX(cc1.cell_no),MAX(cc01.cell_no)) 
					WHEN sdh.header_buy_sell_flag = ''s''
						THEN COALESCE(ISNULL(MAX(cc_internal.cell_no),MAX(cc_internal1.cell_no)), MAX(sc_sub.cell_no), MAX(primary_cc1.cell_no)) 
					END counterparty_cell_no
				,CASE 
					WHEN sdh.header_buy_sell_flag = ''s''
						THEN ISNULL(MAX(cc1.cell_no),MAX(cc01.cell_no)) 
					WHEN sdh.header_buy_sell_flag = ''b''
						THEN COALESCE(ISNULL(MAX(cc_internal.cell_no),MAX(cc_internal1.cell_no)), MAX(sc_sub.cell_no), MAX(primary_cc1.cell_no)) 
					END cell_no
				,CASE 
					WHEN sdh.header_buy_sell_flag = ''b''
						THEN ISNULL(MAX(cc1.telephone),MAX(cc01.telephone))
					WHEN sdh.header_buy_sell_flag = ''s''
						THEN COALESCE(ISNULL(MAX(cc_internal.telephone),MAX(cc_internal1.telephone)), MAX(sc_sub.phone_no), MAX(primary_cc1.telephone))
					END  counterparty_telephone
				,CASE 
					WHEN sdh.header_buy_sell_flag = ''s''
						THEN ISNULL(MAX(cc1.telephone),MAX(cc01.telephone))
					WHEN sdh.header_buy_sell_flag = ''b''
						THEN COALESCE(ISNULL(MAX(cc_internal.telephone),MAX(cc_internal1.telephone)), MAX(sc_sub.phone_no), MAX(primary_cc1.telephone))
					END counterparty_telephone_buy
				, cg.contract_name [contract_name]
				, sdh.entire_term_start [term_start]
				, max(souo.uom_name) position_uom,
				COALESCE(MAX(sc_internal.counterparty_name), MAX(sc_sub.counterparty_name), MAX(primary_sc1.counterparty_name)) internal_coutnerparty,
				MAX(sdh.deal_id) deal_id,
				MAX(sdv_v.code) vintage,
				MAX(dbo.FNADateFormat(sdd.delivery_date))  delivery_date,
				MAX(sdv_s.code) settlement_date,
				NULLIF(CAST(''' + ISNULL(@deal_vol, '') + ''' AS flOAT),0) [deal_volume],
				CASE WHEN MAX(sdh.generator_id) IS NOT NULL THEN ''Yes'' ELSE ''No'' END [project_specific],
				MAX(sdv_p1.code) + '' '' + MAX(sdv_p2.code) [product],
				CASE WHEN MAX(sdh.match_type) = ''y'' THEN ''Compliance Year'' ELSE ''Calendar Year'' END vintage_type,
				MAX(firm_uc.value) firm_uc,
				MAX(su_sdd.uom_name) deal_volume_uom,
				sdv_j.code jurisdiction,
				sdv_t.code tier,
				sdv_ce.code certification_entity,
				sdh.description1 applicable_standards,
				rc.id facuilty
				,CASE 
					WHEN MAX(firm_uc.value) = 1
						THEN ''Unit Contingent'' 
					WHEN MAX(firm_uc.value) = 2
						THEN ''Firm'' 
					WHEN MAX(firm_uc.value) = 3
						THEN ''Forward Transfer''
					WHEN MAX(firm_uc.value) = 4
						THEN ''Auto Transfer''
					WHEN MAX(firm_uc.value) = 5
						THEN ''Externally Managed''
					ELSE NULL END delivery_obligation,
				FORMAT (contract_date.contract_date, ''MMMM dd yyyy'') contract_date,
				FORMAT (sdh.deal_date, ''MMMM dd yyyy'') contract_date_other,
				MAX(cbi.bank_name) bank_name,
				MAX(cbi.accountname) account_name,
				MAX(cbi.ACH_ABA) aba,
				MAX(cbi.Account_no) account_no

				'
			SET @sql_Select2 = ' FROM source_deal_header sdh 
			INNER JOIN #deal_confirmation_tbl dct on dct.source_deal_header_id = sdh.source_deal_header_id
			INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id=sdd.source_deal_header_id 
			INNER JOIN source_system_book_map ssbm ON 	ssbm.source_system_book_id1 = sdh.source_system_book_id1 
				AND ssbm.source_system_book_id2 = sdh.source_system_book_id2 
				AND ssbm.source_system_book_id3 = sdh.source_system_book_id3 
				AND ssbm.source_system_book_id4 = sdh.source_system_book_id4 
			INNER JOIN dbo.portfolio_hierarchy ph ON ph.entity_id=ssbm.fas_book_id
			LEFT JOIN contract_group cg ON cg.contract_id = sdh.contract_id
			LEFT JOIN source_deal_detail_hour sddh ON sddh.source_deal_detail_id = sdd.source_deal_detail_id
			LEFT JOIN source_price_curve_def spcd ON sdd.curve_id=spcd.source_curve_def_id 			
			LEFT JOIN source_price_curve_def risk_spcd ON risk_spcd.source_curve_def_id=spcd.risk_bucket_id 
			LEFT JOIN dbo.source_counterparty  scp ON sdh.counterparty_id = scp.source_counterparty_id 
			LEFT JOIN dbo.source_counterparty  scp1 ON scp1.source_counterparty_id=sdh.broker_id
			LEFT JOIN dbo.source_traders st ON st.source_trader_id=sdh.trader_id
			LEFT JOIN dbo.source_deal_type sdt ON sdt.source_deal_type_id=sdh.source_deal_type_id
			LEFT JOIN source_commodity sc ON sc.source_commodity_id=ISNULL(spcd.commodity_id,risk_spcd.commodity_id)
			LEFT JOIN source_deal_header_template sdht ON sdh.template_id=sdht.template_id
			LEFT JOIN source_currency scu ON scu.source_currency_id=sdd.fixed_price_currency_id
			LEFT JOIN dbo.source_uom su ON su.source_uom_id=sdd.deal_volume_uom_id
			LEFT JOIN dbo.static_data_value sdv ON sdv.value_id=sdh.block_define_id
			LEFT JOIN (select distinct block_value_id,holiday_value_id from dbo.hourly_block) hb ON hb.block_value_id =sdh.block_define_id
			LEFT JOIN dbo.static_data_value sdv1 ON sdv1.value_id =hb.holiday_value_id
			LEFT JOIN (select source_deal_header_id, MAX(confirm_status_id) confirm_status_id, MAX(type) type, MAX(is_confirm) is_confirm, MAX(comment1) comment1 from confirm_status_recent group by source_deal_header_id) a ON a.source_deal_header_id = sdd.source_deal_header_id
			LEFT JOIN static_data_value sdv2 ON sdv2.value_id = a.type 
			LEFT JOIN application_users au ON au.user_f_name + '' '' + au.user_l_name=st.trader_name
			LEFT JOIN application_users au2 ON au2.user_login_id = sdh.verified_by
			LEFT JOIN source_minor_location sml ON sdd.location_id = sml.source_minor_location_id AND sdd.Leg=1
			LEFT JOIN source_deal_detail sdd1 on sdh.source_deal_header_id=sdd1.source_deal_header_id
				AND sdd.term_start=sdd1.term_start and sdd1.leg=1
			LEFT JOIN source_price_curve_def spcd1 ON sdd1.curve_id = spcd1.source_curve_def_id
			LEFT JOIN ' + @vol_frequency_table + '  vft ON vft.term_start=sdd.term_start
				AND vft.term_end=sdd.term_end
				AND ISNULL(vft.block_definition_id,-1)=COALESCE(spcd1.block_define_id,sdh.block_define_id,-1)
				AND ISNULL(vft.block_type,-1)=COALESCE(spcd1.block_type,sdh.block_type,-1)
			LEFT JOIN source_uom su1 ON su1.source_uom_id = spcd.display_uom_id	
			LEFT JOIN source_price_curve_def spcdef ON spcdef.source_curve_def_id = sdd.formula_curve_id
			OUTER APPLY( SELECT CAST(cca.contract_date AS DATE) contract_date FROM source_deal_header sdh 
						INNER JOIN counterparty_contract_address cca ON  sdh.contract_id = cca.contract_id AND sdh.counterparty_id = cca.counterparty_id
							WHERE sdh.source_deal_header_id = '+ @source_deal_header_id +'
			) contract_date
			LEFT JOIN counterparty_bank_info cbi ON cbi.counterparty_id = CASE WHEN sdh.header_buy_sell_flag = ''s'' THEN sdh.internal_counterparty WHEN sdh.header_buy_sell_flag = ''b'' THEN sdh.counterparty_id END
			LEFT JOIN source_counterparty sc_internal ON sc_internal.source_counterparty_id= sdh.internal_counterparty
			LEFT JOIN counterparty_contacts cc_internal ON cc_internal.counterparty_id = sc_internal.source_counterparty_id AND cc_internal.contact_type = -32204
			LEFT JOIN counterparty_contacts cc_internal1 ON cc_internal1.counterparty_id = sc_internal.source_counterparty_id AND cc_internal1.is_primary = ''y''
			LEFT JOIN static_data_value sdv_internal ON cc_internal.state = sdv_internal.value_id
			LEFT JOIN counterparty_contract_address cca ON cca.contract_id = cg.contract_id AND cca.counterparty_id = scp.source_counterparty_id
			LEFT JOIN counterparty_contacts cc1 on cc1.counterparty_id = sdh.counterparty_id AND cc1.contact_type = -32204
			LEFT JOIN counterparty_contacts cc01 on cc01.counterparty_id = sdh.counterparty_id AND cc01.is_primary = ''y''	
			LEFT JOIN source_counterparty primary_sc1 ON primary_sc1.source_counterparty_id = '+ISNULL(CAST(@counterparty_id as VARCHAR),'0')
			+' LEFT JOIN counterparty_contacts cc5 ON cc5.counterparty_contact_id = ISNULL(cca.confirmation,scp.confirmation)
			LEFT JOIN static_data_value cc5_sdv ON  cc5_sdv.value_id =cc5.state 
			LEFT JOIN counterparty_contacts primary_cc1 on primary_cc1.counterparty_id = primary_sc1.source_counterparty_id AND primary_cc1.is_active = ''y'' AND primary_cc1.counterparty_contact_id = primary_sc1.confirmation
			LEFT JOIN source_uom souo ON souo.source_uom_id = sdd.position_uom
			LEFT JOIN static_data_value sdv_j ON sdv_j.value_id = sdh.state_value_id
			LEFT JOIN static_data_value sdv_t ON sdv_t.value_id = sdh.tier_value_id
			LEFT JOIN Gis_Certificate gc ON gc.source_deal_header_id = sdh.source_deal_header_id
			LEFT JOIN static_data_value sdv_ce ON sdv_ce.value_id = gc.certification_entity
			OUTER APPLY(	SELECT sc.counterparty_name,cc.telephone phone_no,ISNULL(cc.email,cc1.email) email,ISNULL(cc.fax,cc1.fax) fax,ISNULL(cc.address1,'''')+'' ''+ISNULL(cc.address2,'''') address1,cc.city,cc.zip,ISNULL(cc.name,cc1.name) name,ISNULL(cc.title,cc1.title) title, ISNULL(cc.address1,cc1.address1) address01, ISNULL(cc.address2,cc1.address2) address02,ISNULL(cc.cell_no,cc1.cell_no) cell_no
						FROM portfolio_hierarchy book(NOLOCK)
						INNER JOIN Portfolio_hierarchy stra(NOLOCK) ON book.parent_entity_id = stra.entity_id
						INNER JOIN source_system_book_map sbm ON sbm.fas_book_id = book.entity_id
						INNER JOIN fas_subsidiaries fs ON fs.fas_subsidiary_id = stra.parent_entity_id
						INNER JOIN source_deal_header sdh1 on sdh1.source_system_book_id1=sbm.source_system_book_id1
								 AND sdh1.source_system_book_id2=sbm.source_system_book_id2
								 AND sdh1.source_system_book_id3=sbm.source_system_book_id3
								 AND sdh1.source_system_book_id4=sbm.source_system_book_id4
						LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = fs.counterparty_id
						LEFT JOIN counterparty_contacts cc ON cc.counterparty_id = sc.source_counterparty_id AND cc.contact_type = -32204
						LEFT JOIN counterparty_contacts cc1 ON cc1.counterparty_id = sc.source_counterparty_id AND cc1.is_primary = ''y''
								 WHERE source_deal_header_id =  sdh.source_deal_header_id
					) sc_sub
				LEFT JOIN static_data_value sdv_p1 ON sdv_p1.value_id = sdh.state_value_id
				LEFT JOIN static_data_value sdv_p2 ON sdv_p2.value_id = sdh.tier_value_id	
				LEFT JOIN state_properties sp ON sp.state_value_id = sdh.state_value_id 
				LEFT JOIN static_data_value sdv_v ON sdv_v.value_id = sdd.vintage AND sdv_v.type_id = 10092 
				LEFT JOIN 	static_data_value sdv_s ON sdv_s.value_id = cg.settlement_date AND sdv_s.type_id = 20000 
				LEFT JOIN rec_generator rc ON rc.generator_id = sdh.generator_id
				OUTER APPLY (
					SELECT MAX(uddf.udf_value) value FROM user_defined_deal_fields uddf 
					INNER JOIN  user_defined_deal_fields_template uddft ON uddf.udf_template_id = uddft.udf_template_id AND uddft.field_label = ''Service Type''
					WHERE uddf.source_deal_header_id = sdh.source_deal_header_id
				) firm_uc
				LEFT JOIN source_uom su_sdd ON su_sdd.source_uom_id = sdd.deal_volume_uom_id	
			WHERE  sdd.Leg = 1
			GROUP BY st.trader_name ,sdh.deal_date,sdt.source_deal_type_name,
				sdh.header_buy_sell_flag,sdh.source_deal_type_id,sdh.option_type,sdh.verified_by,sdh.verified_date,
				au2.user_f_name, au2.user_m_name, au2.user_l_name,st.user_login_id,sml.Location_Name,scp1.counterparty_name
				,a.is_confirm, sdh.source_deal_header_id,sdd.price_multiplier,cg.contract_name,sdh.entire_term_start,sdv_j.code,sdv_t.code,sdv_ce.code
				,sdh.description1,rc.id,contract_date.contract_date,cbi.bank_name	'

	DROP TABLE #deal_data
	DROP TABLE #deal_detail_hour
END
ELSE 
BEGIN 
	SET @sql_Select = '
	SELECT  dbo.FNADateFormat(dbo.FNAConvertTZAwareDateFormat(GETDATE(),1)) [Date]
			,st.trader_name Trader,dbo.FNADateFormat(sdh.deal_date) [Trade Date],
			sdt.source_deal_type_name [Trade Type],
			CASE WHEN sdh.header_buy_sell_flag=''b'' THEN ''Buy'' ELSE ''Sell'' end AS [Type],
			MAX(sc.commodity_name) [Commodity], 
			dbo.FNADateFormat(MIN(sdd.term_start)) [Start Date], dbo.FNADateFormat(MAX(sdd.term_end)) [End Date],			
			CAST(dbo.FNARemoveTrailingZeroes((MAX(ISNULL(dct.hourlyQty, 0)))) AS VARCHAR(1000)) + '' '' + MAX(su.uom_name) + '' per '' + 
			dbo.FNAGetFrequencyText(MAX(sdd.deal_volume_frequency),''v'') [Quantity],			
			CAST(dbo.FNARemoveTrailingZeroes(CAST(SUM(sdd.deal_volume*ISNULL(vft.Volume_Mult,1)) AS NUMERIC(36,10))) AS VARCHAR) + '' ''+ MAX(su.uom_name) [Total Quantity],			
			ISNULL(MAX(spcd.curve_name),MAX(risk_spcd.curve_name)) AS [Price Index],
			''1st day of the month'' [Pricing Date],
			CAST(dbo.FNARemoveTrailingZeroes(MAX(dct.wtavgCost)) AS VARCHAR(1000)) + '' ''+ MAX(scu.currency_name) + '' / ''+ MAX(su.uom_name) 
			 [Fixed Price],
			''firm'' [Service Type]
			,dbo.FNAGetFrequencyText(MAX(sdht.term_frequency_type),''a'')	
			[Payment Frequency],
			CASE WHEN sdh.source_deal_type_id=3 THEN ''T+2'' ELSE ''T+5'' END [Settle Rules],
			ISNULL(MAX(sdv1.code),MAX(sdv.code)) [Holiday Calendar],
			MAX(sdh.deal_id) [External Trade ID],
			MAX(ph.entity_name) [Book],
			MAX(sdd.deal_detail_description) [Comments],
			ISNULL(MAX(scp.counterparty_name),'''') counterparty_name,
			ISNULL(MAX(scp.address),'''')  counterparty_address,
			ISNULL(MAX(scp.phone_no),'''') counterparty_phone_no,
			ISNULL(MAX(scp.mailing_address),'''') counterparty_mailing_address,
			ISNULL(MAX(scp.contact_fax),'''')+'' / ''+ISNULL(MAX(scp.contact_email),'''')  counterparty_fax_email,
			isnull(MAX(sdv2.code),''New'') [Trade Confirmation Status],	
			max(csr.comment1)	[Trade Confirmation comment],
			''0'' [nearby month],
			''last day'' [Roll Convemtion],
			MAX(au.user_off_tel) [TraderPhone],
			MAX(au.user_fax_tel) [TraderFax],
			MAX(au.user_emal_add) [TraderEmail],
			''day 20 of month following delivery'' as [PaymentDates],
			MAX(sdh.source_deal_header_id) [System Trade ID],
			MAX(sdh.create_user) [Input By],
			dbo.FNADateFormat(MAX(sdh.option_settlement_date)) [Premium Settlement Date],
			CAST(ROUND(MAX(sdd.option_strike_price),2) AS NUMERIC(20,2))[Strike Price],
			CAST(CAST(ROUND(AVG((( isnull(sdd.fixed_price, 0) + isnull(sdd.price_adder, 0)) * isnull(sdd.price_multiplier, 1))),2)AS NUMERIC(20,2)) AS VARCHAR)+'' '' [Premium],
			CAST(dbo.FNARemoveTrailingZeroes(ROUND(SUM(((isnull(sdd.fixed_price, 0) +  isnull(sdd.price_adder, 0)) * isnull(sdd.price_multiplier, 1))* ISNULL(vft.Volume_Mult,1)*sdd.deal_volume),2)) AS VARCHAR(100))+'' ''+MAX(scu.currency_name) [TotalPremium],
			dbo.FNADateFormat(MAX(sdh.create_ts)) [Input Date],
			au2.user_l_name + '', '' + au2.user_f_name + '' '' + ISNULL(au2.user_m_name,'''')   [Verified By Name],
			dbo.FNADateFormat(sdh.verified_date) [Verified Date],
			st.user_login_id,
			ISNULL(sml.Location_Name, '''') [Location Name],
			ISNULL(scp1.counterparty_name, '''') [Counterparty Name]
			,max(dct.confirm_replace_flag) [confirm_replace_flag]
			,max(dct.filename) [filename]
			,max(dct.filename1) [filename1]
			,dbo.FNAGetFrequencyText(MAX(sdd.deal_volume_frequency),''a'') [deal_volume_frequency]				
			,ISNULL(spcd.curve_definition,spcd.curve_id) [curve]		
			,MAX(sdh.confirm_status_type) confirm_status_type	
			FROM source_deal_header sdh 
			INNER JOIN #deal_confirmation_tbl dct on dct.source_deal_header_id = sdh.source_deal_header_id
			INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id=sdd.source_deal_header_id 
			INNER JOIN source_system_book_map ssbm ON 	ssbm.source_system_book_id1 = sdh.source_system_book_id1 
				AND ssbm.source_system_book_id2 = sdh.source_system_book_id2 
				AND ssbm.source_system_book_id3 = sdh.source_system_book_id3 
				AND ssbm.source_system_book_id4 = sdh.source_system_book_id4 
			INNER JOIN dbo.portfolio_hierarchy ph ON ph.entity_id=ssbm.fas_book_id
			LEFT JOIN source_price_curve_def spcd ON sdd.curve_id=spcd.source_curve_def_id 			
			LEFT JOIN source_price_curve_def risk_spcd ON risk_spcd.source_curve_def_id=spcd.risk_bucket_id 
			LEFT JOIN dbo.source_counterparty  scp ON sdh.counterparty_id = scp.source_counterparty_id 
			LEFT JOIN dbo.source_counterparty  scp1 ON scp1.source_counterparty_id=sdh.broker_id
			LEFT JOIN dbo.source_traders st ON st.source_trader_id=sdh.trader_id
			LEFT JOIN dbo.source_deal_type sdt ON sdt.source_deal_type_id=sdh.source_deal_type_id
			LEFT JOIN source_commodity sc ON sc.source_commodity_id=ISNULL(spcd.commodity_id,risk_spcd.commodity_id)
			LEFT JOIN source_deal_header_template sdht ON sdh.template_id=sdht.template_id
			LEFT JOIN source_currency scu ON scu.source_currency_id=sdd.fixed_price_currency_id
			LEFT JOIN dbo.source_uom su ON su.source_uom_id=sdd.deal_volume_uom_id
			LEFT JOIN dbo.static_data_value sdv ON sdv.value_id=sdh.block_define_id
			LEFT JOIN (select distinct block_value_id,holiday_value_id from dbo.hourly_block) hb ON hb.block_value_id =sdh.block_define_id
			LEFT JOIN dbo.static_data_value sdv1 ON sdv1.value_id =hb.holiday_value_id
			LEFT JOIN confirm_status_recent csr on csr.source_deal_header_id=sdh.source_deal_header_id
			LEFT JOIN static_data_value sdv2 ON sdv2.value_id = csr.type 
			LEFT JOIN application_users au ON au.user_f_name + '' '' + au.user_l_name=st.trader_name
			LEFT JOIN application_users au2 ON au2.user_login_id = sdh.verified_by
			LEFT JOIN source_minor_location sml ON sdd.location_id = sml.source_minor_location_id AND sdd.Leg=1
			LEFT JOIN source_deal_detail sdd1 on sdh.source_deal_header_id=sdd1.source_deal_header_id
				AND sdd.term_start=sdd1.term_start and sdd1.leg=1
			LEFT JOIN source_price_curve_def spcd1 ON sdd1.curve_id = spcd1.source_curve_def_id
			LEFT JOIN ' + @vol_frequency_table + ' vft ON vft.term_start=sdd.term_start
				AND vft.term_end=sdd.term_end
				AND ISNULL(vft.block_definition_id,-1)=COALESCE(spcd1.block_define_id,sdh.block_define_id,-1)
				AND ISNULL(vft.block_type,-1)=COALESCE(spcd1.block_type,sdh.block_type,-1)	
									
			WHERE sdd.Leg = 1			
			GROUP BY st.trader_name, sdh.deal_date, sdt.source_deal_type_name, sdh.header_buy_sell_flag, sdh.source_deal_type_id,
					 sdh.option_type, sdh.verified_by, sdh.verified_date, au2.user_f_name, au2.user_m_name, au2.user_l_name, 
					 st.user_login_id, sml.Location_Name, scp1.counterparty_name, csr.is_confirm,
					 spcd.curve_definition, spcd.curve_id, sdh.source_deal_header_id'
END 			
--Exec spa_PRINT @sql_select
EXEC spa_print @sql_Select2
EXEC spa_print @sql_select
EXEC(@sql_select+@sql_Select2)
DROP TABLE #deal_confirmation_tbl
END

  

  	 