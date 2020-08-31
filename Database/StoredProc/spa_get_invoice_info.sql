IF EXISTS (
       SELECT *
       FROM   sys.objects
       WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[spa_get_invoice_info]')
              AND TYPE IN (N'P', N'PC')
   )
    DROP PROCEDURE [dbo].[spa_get_invoice_info]

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_get_invoice_info]
	@save_invoice_id INT = NULL,
	@counterparty_id INT = NULL,
	@prod_month VARCHAR(20) = NULL,
	@approver VARCHAR(100) = NULL,
	@as_of_date DATETIME = NULL,
	@contract_id INT = NULL,
	@invoice_tye CHAR(1) = NULL,
	@calc_id INT = NULL
	AS
		DECLARE @mapping_table_id INT
		
		SELECT @mapping_table_id = gmh.mapping_table_id
		FROM   generic_mapping_header gmh
		WHERE  gmh.mapping_name = 'Purchase Order'

		 
		--collect counterparty history names
		SELECT CASE WHEN sch_effective.effective_date IS NULL THEN sc.counterparty_desc ELSE  sch_effective.counterparty_desc END counterparty_desc, 
				sc.source_counterparty_id source_counterparty_id
			INTO #history_counterparty_name
		FROM dbo.FNASplit(@counterparty_id, ',') c 
		INNER JOIN source_counterparty sc ON sc.source_counterparty_id = c.item
		--LEFT JOIN source_counterparty_history sch ON c.item = sch.source_counterparty_id
		OUTER APPLY (SELECT TOP 1 sch_inner.effective_date, sch_inner.counterparty_desc 
					FROM source_counterparty_history sch_inner 
					WHERE sch_inner.source_counterparty_id = sc.source_counterparty_id AND  sch_inner.effective_date <= @prod_month  
					ORDER BY sch_inner.effective_date DESC) sch_effective
		WHERE  1 = 1 
 
		-- check if netting calc id exists or not; used for attachment
		DECLARE @contract_id_calc INT = @contract_id
		SELECT @contract_id_calc = CASE WHEN civv.netting_calc_id IS NOT NULL AND @save_invoice_id IS NOT NULL THEN civv1.contract_id ELSE @contract_id END		
		FROM
			calc_invoice_volume_variance civv
			left join calc_invoice_volume_variance civv1 
			on civv1.calc_id = civv.netting_calc_id
		WHERE civv.calc_id = @save_invoice_id
				
	    SELECT 
			MAX(cpty.counterparty_name) counterparty_name,
			MAX(civv.invoice_number) AS invoice_number,
			MAX(civv.finalized) AS calc_status,
			 --CAST(Day(MAX(civv.settlement_date)) AS VARCHAR)+ ' '+DATENAME(m,MAX(civv.settlement_date))+' '+CAST(YEAR(MAX(civv.settlement_date)) AS VARCHAR) invoice_date,
			MAX(civv.settlement_date) invoice_date,
	        MAX(dbo.FNAInvoiceDueDate((ISNULL((civv.prod_date), GETDATE())),(cg.invoice_due_date),(cg.holiday_calendar_id),(cg.payment_days))) invoice_due_date,
	        dbo.FNADateFormat(GETDATE()) AS request_date,
	                    CASE 
                WHEN cg.billing_cycle = 976 THEN CAST(dbo.FNADateFormat(@prod_month) AS VARCHAR)
                ELSE dbo.FNADateFormat(
                         CAST(DATEPART(YEAR, @prod_month) AS VARCHAR) + '-' + CAST(
                             DATEPART(MONTH, DATEADD(MONTH, -1, @prod_month)) AS VARCHAR
                         ) + '-' + CAST(cg.billing_FROM_date AS VARCHAR)
                     )
            END AS invoice_period_from,
            CASE 
                WHEN cg.billing_cycle = 976 THEN CAST(
                         dbo.FNADateFormat(DATEADD(MONTH, 1, @prod_month) -1) AS VARCHAR
                     )
                ELSE dbo.FNADateFormat(
                         CAST(DATEPART(YEAR, @prod_month) AS VARCHAR) + '-' + CAST(DATEPART(MONTH, @prod_month) AS VARCHAR) + '-' + CAST(cg.billing_to_date AS VARCHAR)
                     )
            END AS invoice_period_to,
            cg.[type],
            cg.sub_id,
			--ISNULL(sc_parent.counterparty_desc, cii.counterparty_desc) AS counterparty,	
			MAX(ISNULL(hcn.counterparty_desc, hcn1.counterparty_desc)) AS counterparty,	
			MAX(COALESCE(cc_payable.title,sc_parent.counterparty_contact_title,cii.counterparty_contact_title)) AS counterparty_contact_title,
			MAX(COALESCE(cc_payable.name,sc_parent.counterparty_contact_name,cii.counterparty_contact_name)) AS counterparty_contact_name,
			MAX(COALESCE(cc_payable.address1,sc_parent.[address],cii.[address])) AS counterparty_contact_address,
			MAX(COALESCE(cc_payable.address2,sc_parent.[mailing_address], cii.[mailing_address])) AS counterparty_contact_address2,
			MAX(COALESCE(cc_payable.zip,sc_parent.[zip], cii.[zip])) AS counterparty_contact_address3,
			MAX(COALESCE(cc_payable.city,sc_parent.[city],cii.[city])) AS counterparty_contact_address4,
			MAX(COALESCE(cc_payable.city,sc_parent.city, cii.city)) AS counterparty_contact_city,
			MAX(COALESCE(sc_parent.[state], cii.[state])) AS counterparty_contact_state,
			MAX(COALESCE(cc_payable.zip,sc_parent.zip, cii.zip)) AS counterparty_contact_zip,
			MAX(sdv_country.[description]) AS counterparty_contact_country,
			MAX(sdv_region.[description]) AS counterparty_contact_region,
			MAX(COALESCE(sc_parent.phone_no, cii.phone_no)) AS counterparty_contact_phone,
			MAX(COALESCE(sc_parent.fax, cii.fax)) AS counterparty_contact_fax,
			MAX(COALESCE(sc_parent.email, cii.email)) AS counterparty_contact_email,
			MAX(ISNULL(sc_parent.contact_title,cii.contact_title)) AS counterparty_payment_title,
			MAX(ISNULL(sc_parent.contact_name,cii.contact_name)) AS counterparty_payment_name,
			MAX(ISNULL(sc_parent.contact_address,cii.contact_address)) AS counterparty_payment_address,
			MAX(ISNULL(sc_parent.contact_address2, cii.contact_address2)) AS counterparty_payment_address2,	
			MAX(ISNULL(sc_parent.contact_phone, cii.contact_phone)) AS counterparty_payment_phone,
			MAX(ISNULL(sc_parent.contact_fax, cii.contact_fax)) AS counterparty_payment_fax,
			MAX(ISNULL(sc_parent.email, cii.email)) AS counterparty_contact_parent_email,			
			MAX(fs_counterparty.counterparty_contact_title) AS primary_counterparty_contact_title,
			MAX(fs_counterparty.counterparty_contact_name) AS primary_counterparty_contact_name,
			MAX(fs_counterparty.[address]) AS primary_counterparty_contact_address,
			MAX(fs_counterparty.[mailing_address]) AS primary_counterparty_contact_address2,
			MAX(fs_counterparty.[city]) AS primary_counterparty_contact_address3,
			MAX(fs_counterparty.[zip]) AS primary_counterparty_contact_address4,			
			MAX(fs_counterparty.city) AS primary_counterparty_contact_city,
			MAX(fs_counterparty.[state]) AS primary_counterparty_contact_state,
			MAX(fs_counterparty.zip) AS primary_counterparty_contact_zip,
			MAX(sdv_parent_country.[description]) AS counterparty_contact_parent_country,
			MAX(sdv_parent_region.[description]) AS counterparty_contact_parent_region,
			MAX(fs_counterparty.phone_no) AS primary_counterparty_contact_phone,
			MAX(fs_counterparty.fax) AS primary_counterparty_contact_fax,
			MAX(fs_counterparty.contact_title) AS primary_counterparty_payment_title,
			MAX(ISNULL(fs_counterparty.contact_name,ccs.name)) AS primary_counterparty_payment_name,
			MAX(fs_counterparty.contact_address) AS primary_counterparty_payment_address,
			MAX(fs_counterparty.contact_address2) AS primary_counterparty_payment_address2,
			MAX(fs_counterparty.contact_phone) AS primary_counterparty_payment_phone,
			MAX(fs_counterparty.contact_fax) AS primary_counterparty_payment_fax,
			MAX(fs_counterparty.email) AS primary_counterparty_contact_email,						
			MAX(ISNULL(sc_parent.instruction, cii.instruction)) counterparty_payment_instruction,
			MAX(ISNULL(sc_parent.customer_duns_number, cii.customer_duns_number)) external_reference_number,
            MAX(au.user_f_name + ' ' + au.user_l_name) settlement_account,	          
            MAX(au.user_title) AS Title,
            MAX(au.user_address3) AS empid,
            MAX(sd.code) AS business_uint,
            MAX(au.user_off_tel) AS phone,
            MAX(au1.user_f_name + ' ' + au1.user_l_name) AS contract_specialist,
            MAX(au1.user_title) AS contract_title,
            MAX(au1.user_address3) AS contract_empid,
            MAX(au1.user_off_tel) AS contract_phone,
            MAX(cii.confirm_from_text) AS confirm_from_text,
            MAX(cii.confirm_to_text) AS confirm_to_text,
            MAX(cii.confirm_instruction) AS confirm_instruction,
            fs.entity_name subsidiary,
            MAX(fs.address1) subsidiary_address1,
            MAX(fs.address2) subsidiary_ddress2,
            MAX(fs.city) subsidiary_city,
            MAX(cg.contract_name) contract_name,
            MAX(cg.[address]) AS contract_address1,
            MAX(cg.address2) AS contract_address2,
            MAX(cg_state.code) AS contract_state,
            MAX(cg.zip) AS contract_zip,
            MAX(cg.UD_Contract_id) AS contract_customer_id,
            MAX(cg.company) AS company_name,
			MAX(cbi.bank_name) AS bank_name,
			MAX(cbi.accountname) AS account_name,
			MAX(cbi.Account_no) AS account_no,
			MAX(cbi.wire_ABA) AS iban,
			MAX(cbi.ACH_ABA) AS swift_no,
            MAX(cbi.reference) AS Reference,
            MAX(civv.as_of_date) as_of_date,
            MAX(cii.contact_name) contact_name,
            MAX(cii.contact_phone) contact_phone,
            MAX(cii.contact_fax) contact_fax,
            MAX(fs.tax_payer_id) tax_payer_id,
            MAX(fs_counterparty.phone_no) company_phone,
            MAX(fs_counterparty.fax) company_fax,
            MAX(fs_counterparty.counterparty_name) primary_counterparty,
            CONVERT(VARCHAR(10), MAX(dbo.FNAInvoiceDueDate(CASE WHEN cg.invoice_due_date = '20023'  OR cg.invoice_due_date = '20024' THEN civv.finalized_date ELSE civv.prod_date END, cg.invoice_due_date, cg.holiday_calendar_id,cg.payment_days)), 110) payment_date,
            --MAX(civv.invoice_note,sc_parent.instruction, cii.instruction)) AS invoice_notes,
			MAX(civv.invoice_note) AS invoice_notes,
			MAX(cii.instruction) AS instruction,
            MAX(civv.contract_id) AS contract_id,
            MAX(sdh.deal_type_desc)+MAX(ISNULL(' - '+com.commodity_name,'')) AS invoice_description,
            MAX(sdh.deal_type_desc + ' ' + sb_subject.source_book_name + ' Supply in ' + DATENAME(m,civv.prod_date) +' '+ CAST(YEAR(civv.prod_date) AS VARCHAR)) invoice_subject,
            MAX(ISNULL(cea0.external_value, cea.external_value)) AS counterparty_external_id1,
            MAX(cea1.external_value) AS counterparty_external_id2,
            MAX(primary_cea.external_value) AS primary_counterparty_external_id1,
            MAX(mp.vat_remarks) AS vat_remarks,
            MAX(sc.currency_name) AS currency,
            CASE WHEN civv.invoice_type = 'i' THEN MAX(cea2.external_value) ELSE MAX(cea3.external_value) END AS client_number,
            ISNULL(MAX(sdh.deal_type),0) deal_type,
            ISNULL(MAX(sdh.book_id2),0) book_id2,
            ISNULL(MAX(cca.address1), MAX(ISNULL(sc_parent.[address],cii.[address]))) counterparty_contract_address1,
            ISNULL(MAX(cca.address2), MAX(ISNULL(sc_parent.[mailing_address], cii.[mailing_address]))) counterparty_contract_address2,
            ISNULL(MAX(cca.address3), MAX(ISNULL(sc_parent.[zip],cii.[zip]))) counterparty_contract_address3,
            ISNULL(MAX(cca.address4), MAX(ISNULL(sc_parent.[city],cii.[city]))) counterparty_contract_address4,
            MAX(ISNULL(cca.counterparty_full_name, cii.counterparty_contact_name)) counterparty_contact_full_name,
			MAX(vat.code) vat,
			MAX(cc_receivables.title) receivable_title,
            MAX(ISNULL(cc_receivables.address1,cc.cc_address1)) cc_address1,
            MAX(ISNULL(cc_receivables.address2,cc.cc_address2)) cc_address2,
            MAX(ISNULL(cc_receivables.zip,cc.cc_zip)) cc_zip,
            MAX(ISNULL(cc_receivables.city,cc.cc_city)) cc_city,
            MAX(ISNULL(cc_receivables.name,cc.cc_name)) cc_name,
            MAX(ISNULL(cc_receivables.zip,ccs.zip)) ccs_primary_zip,
            MAX(cc.cc_fax) cc_fax,
			MAX(civv.payment_date) civv_payment_date,
            MAX(civv.finalized_date) civv_finalized_date,       
			MAX(datepart(year, civv.prod_date)) civv_prod_year,
			MAX(datepart(month, civv.prod_date)) civv_prod_month, 		
			MAX(ccs.name) ccs_primary_counterparty_contact_name,
			MAX(ccs.address1) ccs_primary_counterparty_contact_address1,
			MAX(ccs.address2) ccs_primary_counterparty_contact_address2,
			MAX(ccs.telephone) ccs_primary_counterparty_contact_telephone,
			MAX(ccs.fax) ccs_primary_counterparty_contact_fax,
			MAX(ccs.email) ccs_primary_counterparty_contact_email,
			MAX(cbi1.bank_name) AS primary_bank_name,
			MAX(cbi1.accountname) AS primary_account_name,
			MAX(cbi1.Account_no) AS primary_account_no,
			MAX(cbi1.wire_ABA) AS primary_iban,
			MAX(cbi1.ACH_ABA) AS primary_swift_no,
			MAX(primary_cea2.external_value) chamber_commerce_no,
			MAX(primary_cea3.external_value) supplier_number,
			CONVERT(VARCHAR(10), MAX(civv.prod_date), 105) + '  -  ' + CONVERT(VARCHAR(10), MAX(civv.prod_date_to), 105) [period],
			MAX(po.[purchase_order_number]) [purchase_order_number],
			CASE WHEN MAX(civv.netting_calc_id) IS NOT NULL THEN 'ATTACHMENT  ' ELSE 'INVOICE  ' END document_type, 
			MAX(civv.netting_calc_id)  netting_calc_id,
			MAX(ic_within_fiscal_unit.code) is_ic_within_fiscal_unit,
			MAX(cii.int_ext_flag) int_ext_flag,
			MAX(ccts_region.code) AS ccts_region,
			Case when @invoice_tye = 'i' then MAX(COALESCE(cc_payable.email,cii.email,cc.cc_email)) ELSE MAX(COALESCE(cc_receivables.email,cii.email,cc.cc_email)) END as  email,
			Case when @invoice_tye = 'i' then MAX(COALESCE(cc_payable.name,cc.cc_name)) ELSE MAX(COALESCE(cc_receivables.name,sc_parent.counterparty_contact_name,cc.cc_name)) END as  display_name,
			Case when @invoice_tye = 'i' then MAX(COALESCE(cc_payable.address1,cc.cc_address1)) + ','+ MAX(COALESCE(cc_payable.city,cc.cc_city)) + ','+  MAX(COALESCE(cc_payable.zip,cc.cc_zip)) ELSE MAX(COALESCE(cc_receivables.address1,cc.cc_address1))+ ','+ MAX(COALESCE(cc_receivables.city,cc.cc_city)) + ','+  MAX(COALESCE(cc_receivables.zip,cc.cc_zip)) END as  display_address,
			Case when @invoice_tye = 'i' then MAX(COALESCE(cc_payable.telephone,cc.cc_phone)) ELSE MAX(COALESCE(cc_receivables.telephone,cc.cc_phone)) END as  phone_display,
			Case when @invoice_tye = 'i' then MAX(COALESCE(cc_payable.fax,cc.cc_fax)) ELSE MAX(COALESCE(cc_receivables.fax,cc.cc_fax)) END as  phone_fax
					
	    FROM   
	           calc_invoice_volume_variance civv
			   JOIN contract_group cg
	                ON  cg.contract_id = @contract_id_calc
	           JOIN source_counterparty cii
	                ON  cii.source_Counterparty_id = civv.counterparty_id
	           LEFT JOIN source_counterparty sc_parent
	                ON  sc_parent.source_counterparty_id = cii.netting_parent_counterparty_id
				LEFT JOIN #history_counterparty_name hcn On hcn.source_counterparty_id = sc_parent.source_counterparty_id
				LEFT JOIN #history_counterparty_name hcn1 On hcn1.source_counterparty_id = civv.counterparty_id
	           
	           LEFT JOIN application_users au
	                ON  au.user_login_id = cg.settlement_accountant
	           LEFT JOIN application_users au1
	                ON  au1.user_login_id = '' + ISNULL(@approver, '') + ''
	           LEFT JOIN static_data_value sd
	                ON  sd.value_id = au1.entity_id
	           LEFT JOIN fas_subsidiaries fs
	                ON  cg.sub_id = fs.fas_subsidiary_id
	           LEFT JOIN source_counterparty fs_counterparty
	                ON  fs.counterparty_id = fs_counterparty.source_counterparty_id
	           LEFT JOIN counterparty_contacts AS ccs 
					ON CCS.counterparty_id = fs_counterparty.source_counterparty_id
	           LEFT OUTER JOIN static_data_value cg_state
	                ON  cg_state.value_id = cg.state
	           LEFT OUTER JOIN static_data_value cii_state
	                ON  cii_state.value_id = cii.state
	           LEFT OUTER JOIN static_data_value sc_state
	                ON  sc_state.value_id = sc_parent.state
	          LEFT JOIN static_data_value sdv_country ON sdv_country.value_id =  ISNULL(sc_parent.country, cii.country)    
	           LEFT JOIN static_data_value sdv_region ON sdv_region.value_id =  ISNULL(sc_parent.region, cii.region)    
	           LEFT JOIN static_data_value sdv_parent_country ON sdv_parent_country.value_id = fs_counterparty.country   
	           LEFT JOIN static_data_value sdv_parent_region ON sdv_parent_region.value_id =  fs_counterparty.region   
	           LEFT JOIN counterparty_epa_account cea ON cea.counterparty_id = civv.counterparty_id AND cea.external_type_id = 2200 AND NULLIF(cea.contract_id,'') IS NULL
			   LEFT JOIN counterparty_epa_account cea0 ON cea0.counterparty_id = civv.counterparty_id AND cea0.external_type_id = 2200 AND cea0.contract_id = @contract_id
	           LEFT JOIN counterparty_epa_account cea1 ON cea1.counterparty_id = civv.counterparty_id AND cea1.external_type_id = 2201
	           LEFT JOIN counterparty_epa_account cea2 ON cea2.counterparty_id = civv.counterparty_id AND cea2.external_type_id = 2202
	           LEFT JOIN counterparty_epa_account cea3 ON cea3.counterparty_id = civv.counterparty_id AND cea3.external_type_id = 2203
	           LEFT JOIN counterparty_epa_account primary_cea ON primary_cea.counterparty_id =  fs.counterparty_id AND primary_cea.external_type_id = 2200
			   LEFT JOIN counterparty_epa_account primary_cea2 ON primary_cea2.counterparty_id =  fs.counterparty_id AND primary_cea2.external_type_id = 307234 --static data value: chamber of commerce number     
			   LEFT JOIN counterparty_epa_account primary_cea3 ON civv.counterparty_id = primary_cea3.counterparty_id AND primary_cea3.external_type_id = 307222
			   LEFT JOIN counterparty_contacts AS ccts 
					ON ccts.counterparty_id = @counterparty_id AND ccts.is_primary = 'y'
				LEFT JOIN static_data_value ccts_region ON ccts_region.value_id =  ccts.region 
	           OUTER APPLY (
	                           SELECT gmv.clm4_value [purchase_order_number]
	                           FROM   generic_mapping_values gmv
	                           WHERE  gmv.mapping_table_id = @mapping_table_id
	                                  AND gmv.clm1_value = @contract_id_calc
	                                  AND @prod_month BETWEEN  CAST(gmv.clm2_value AS date) AND  CAST(gmv.clm3_value AS date)
	                       ) po
	           OUTER APPLY(
					SELECT MAX(sdt.source_deal_desc) deal_type_desc,MAX(sdd.location_id)location_id,MAX(curve_id) curve_id,MAX(commodity_id)commodity_id,MAX(sdd.fixed_price_currency_id)currency_id, MAX(sdh.source_deal_type_id) deal_type, MAX(sdh.source_system_book_id2) book_id2
					FROM source_deal_header sdh 
						INNER JOIN source_deal_type sdt ON sdh.source_deal_type_id = sdt.source_deal_type_id
						INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
					WHERE ((sdh.contract_id = civv.contract_id AND sdh.counterparty_id = civv.counterparty_id AND cii.int_ext_flag<>'b')
							OR
							(sdh.broker_id = civv.counterparty_id AND cii.int_ext_flag = 'b'))
				) sdh		  	     
	            OUTER APPLY(
					SELECT MAX(clm8_value) as vat_remarks FROM	generic_mapping_header gmh 
						INNER JOIN generic_mapping_values gmv 
							ON gmv.mapping_table_id = gmh.mapping_table_id 
							AND  CAST(ccts.region AS VARCHAR(1000)) = gmv.clm3_value
							AND gmh.mapping_name = 'EFET VAT Rule Mapping'
						INNER JOIN source_deal_header sdh
							ON  sdh.counterparty_id = @counterparty_id
							AND sdh.source_system_book_id2 = gmv.clm1_value
							AND sdh.source_system_book_id3 = gmv.clm2_value
							--AND sdh.contract_id = civv.contract_id
					WHERE 
					gmv.clm4_value = CASE WHEN cea1.external_value IS NOT NULL THEN 'y' ELSE 'n' END AND 
					gmv.clm3_value = ccts.region
				) mp   				
			    LEFT JOIN source_currency sc ON sc.source_currency_id = ISNULL(cg.currency,sdh.currency_id)
			    OUTER APPLY (
	           		SELECT
	           			TOP 1
	           			cbi0.accountname,
						cbi0.wire_ABA,
						cbi0.reference,
						cca0.bank_account,
						cbi0.ACH_ABA,
						cbi0.bank_name,
						cbi0.Account_no
	           		FROM counterparty_bank_info cbi0
	           		LEFT JOIN counterparty_contract_address cca0 ON cca0.counterparty_id = civv.counterparty_id AND cca0.contract_id = @contract_id AND cbi0.bank_id = cca0.bank_account
	                WHERE  cbi0.counterparty_id = ISNULL(sc_parent.source_counterparty_id,cii.source_counterparty_id) AND cbi0.currency = sc.source_currency_id
	           		ORDER BY ISNULL(cca0.bank_account,0) DESC, cbi0.primary_account DESC  -- cbi0.primary_account= 'y'
	           		
	           ) cbi 
	           OUTER APPLY (
	           		SELECT
	           			TOP 1
	           			cbi01.wire_ABA,
						cbi01.ACH_ABA,
						cbi01.bank_name,
						cbi01.Account_no,
						cbi01.accountname
	           		FROM counterparty_bank_info cbi01
	                WHERE  cbi01.counterparty_id = fs_counterparty.source_counterparty_id AND cbi01.currency = sc.source_currency_id
	           		ORDER BY cbi01.primary_account DESC  -- cbi01.primary_account= 'y'
	           		
	           ) cbi1    
	            LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id=sdh.curve_Id
	            LEFT JOIN source_commodity com ON com.source_commodity_id = sdh.commodity_id
				OUTER APPLY (
					SELECT counterparty_name FROM dbo.source_counterparty WHERE source_counterparty_id = @counterparty_id
				) cpty
				OUTER APPLY (
	            	SELECT address1 [cc_address1],
	            	       address2 [cc_address2],
	            	       zip [cc_zip],
	            	       city [cc_city],
	            	       [name] [cc_name],
	            	       cc.telephone [cc_phone],
	            	       fax [cc_fax],
	            	       cc.email [cc_email],
	            	       cc.country [cc_country],
	            	       cc.region [cc_region]
	            	FROM   counterparty_contacts cc
	            	WHERE  cc.counterparty_id = @counterparty_id
	            	       AND cc.is_primary = 'y'
	            )cc
	            LEFT JOIN counterparty_contract_address cca ON cca.counterparty_id = civv.counterparty_id AND cca.contract_id = @contract_id_calc
				LEFT JOIN counterparty_contacts cc_payable ON cc_payable.counterparty_contact_id = ISNULL(cca.payables,sc_parent.payables)
				LEFT JOIN counterparty_contacts cc_receivables ON cc_receivables.counterparty_contact_id = ISNULL(cca.receivables,sc_parent.receivables)
				LEFT JOIN source_book sb_subject ON  sb_subject.source_book_id = sdh.book_id2
				OUTER APPLY (
	    				SELECT cea.external_value code FROM counterparty_epa_account cea WHERE cea.counterparty_id = @counterparty_id AND cea.external_type_id = 2200
					) vat
				OUTER APPLY (
	    				SELECT cea.external_value code FROM counterparty_epa_account cea WHERE cea.counterparty_id = @counterparty_id AND cea.external_type_id = 307212 -- IC within Fiscal Unit
				) ic_within_fiscal_unit
	    WHERE  cii.source_counterparty_id = @counterparty_id
	           AND civv.contract_id = @contract_id
	           AND civv.prod_date = @prod_month
	           AND civv.as_of_date = @as_of_date
	           AND civv.invoice_type = @invoice_tye
	           AND (@save_invoice_id IS NULL OR civv.calc_id = @save_invoice_id)
			   AND (@calc_id IS NULL OR civv.calc_id =@calc_id)
	    GROUP BY
	           ISNULL(sc_parent.counterparty_desc, cii.counterparty_desc),
	           dbo.FNAInvoiceDueDate(ISNULL(civv.prod_date, GETDATE()), cg.invoice_due_date, cg.holiday_calendar_id,cg.payment_days),
	           cg.name,cg.billing_cycle,cg.billing_from_date,cg.billing_to_date,cg.[type],cg.sub_id,cg.sub_id,
	           fs.entity_name,civv.invoice_type,sc_parent.counterparty_name,cii.counterparty_name