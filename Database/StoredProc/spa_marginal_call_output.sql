IF OBJECT_ID(N'[dbo].[spa_marginal_call_output]', N'P') IS NOT NULL    
	DROP PROCEDURE [dbo].[spa_marginal_call_output]

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_marginal_call_output]
	@flag CHAR = 'i',
	@counterparty_id INT NULL,
	@as_of_date VARCHAR (50),
	@internal_counterparty_id INT NULL,
	@contract_id INT NULL
	
AS
SET NOCOUNT ON 
BEGIN

	--EXEC spa_drop_all_temp_table 
	SELECT CONVERT(VARCHAR(12),ces.as_of_date,107) as_of_date,
            CONVERT(VARCHAR(12),EOMONTH(ces.as_of_date),107) end_date, 
			ces.curve_source_value_id,
			ces.Source_Counterparty_ID,
			sc.counterparty_name,
			ces.internal_counterparty_id,
			scIn.counterparty_name AS internal_counterparty_name,
			ces.contract_id,
			cg.contract_name,
			cbi.bank_name,
			cbi.ach_aba AS aba, 
			cbi.reference,
			cbi.account_no,
			REPLACE(CONVERT(VARCHAR,CAST(dbo.FNARemoveTrailingZeroes(ROUND(ces.limit_provided,2))  AS MONEY),1), '.00','') limit_provided,
			dbo.FNARemoveTrailingZeroes(ROUND(ces.limit_received,2)) limit_received,
			dbo.FNARemoveTrailingZeroes(ROUND((ces.limit_provided+ces.limit_received),2)) AS total_Limit,
			REPLACE(CONVERT(VARCHAR,CAST(dbo.FNARemoveTrailingZeroes(ROUND(ces.net_exposure_to_us,2)) AS MONEY),1), '.00','')  net_exposure_to_us,
			dbo.FNARemoveTrailingZeroes(ROUND(Abs(ces.net_exposure_to_them),2)) as net_exposure_to_them,
			dbo.FNARemoveTrailingZeroes(ROUND((ces.net_exposure_to_us+ces.net_exposure_to_them),2)) AS total_exposure,
			dbo.FNARemoveTrailingZeroes(ROUND(ces.cash_collateral_provided,2)) cash_collateral_provided,
			REPLACE(CONVERT(VARCHAR,CAST(dbo.FNARemoveTrailingZeroes(ROUND(ces.collateral_received,2))  AS MONEY),1), '.00','') collateral_received,
			dbo.FNARemoveTrailingZeroes(ROUND(ces.collateral_provided,2)) collateral_provided,
			REPLACE(CONVERT(VARCHAR,CAST(dbo.FNARemoveTrailingZeroes(ROUND(ces.cash_collateral_received,2))  AS MONEY),1), '.00','') cash_collateral_received,
			REPLACE(CONVERT(VARCHAR,CAST(dbo.FNARemoveTrailingZeroes(ROUND((ces.cash_collateral_received + ces.collateral_received ),2))  AS MONEY),1), '.00','') AS total_Collateral,
			REPLACE(CONVERT(VARCHAR,CAST(dbo.FNARemoveTrailingZeroes(ROUND((ces.net_exposure_to_us - ces.cash_collateral_received - ces.collateral_received - ces.limit_provided),2))  AS MONEY),1), '.00','') AS margin_excess,
			dbo.FNARemoveTrailingZeroes(ROUND((ces.net_exposure_to_us - ces.limit_provided),2)) AS collateral_required,
			REPLACE(CONVERT(VARCHAR,CAST(sdv.code  AS MONEY),1), '.00','') AS rounding,   
			REPLACE(CONVERT(VARCHAR,CAST(dbo.FNARemoveTrailingZeroes(ROUND(ROUND(ces.net_exposure_to_us - ces.cash_collateral_received - ces.collateral_received - ces.limit_provided,0,1) / CAST(sdv.code as INT),0,1) * CAST(sdv.code as INT))  AS MONEY),1), '.00','') rounding_margin_excess,
			rnd.threshold_provided,
			rnd.threshold_received,
			rnd.min_transfer_amount,
			cc.name [contact_name],
			scu.currency_name,
			sc.phone_no As payment_contact_phone,
			cc.telephone [contact_telephone],
			cc.fax [contact_fax],
			ccii.telephone[internal_phone],
			ccii.fax[internal_fax],
			ccii.city[internal_city],
			sdv_cci_state.code[internal_state],
			sdv_cci_country.code[internal_country],
			ccii.zip[internal_zip],
			cc.city[counterparty_city],
			sdv_cc_state.code[counterparty_state],
			sdv_cc_country.code[counterparty_country],
			cc.zip[counterparty_zip],
			cc.address1 [counterparty_address1],
			cc.address2 [counterparty_address2],
			ccii.address1 [internal_address1],
			ccii.address2 [internal_address2]
		FROM source_counterparty sc  
		INNER JOIN credit_exposure_summary ces ON ces.source_counterparty_id = sc.source_counterparty_id
		LEFT JOIN counterparty_credit_info cci ON cci.counterparty_id = sc.source_counterparty_id
		LEFT JOIN source_currency scu ON scu.source_currency_id = cci.curreny_code 
		LEFT JOIN source_counterparty scIn ON scIn.source_counterparty_id = ces.internal_counterparty_id
		LEFT JOIN contract_group cg ON cg.contract_id = ces.contract_id
		OUTER APPLY (SELECT bank_name, ach_aba, reference, account_no
					FROM counterparty_bank_info cbi
					WHERE bank_id = (SELECT MAX(bank_id)
					FROM counterparty_bank_info cbi
					WHERE counterparty_id = scIn.source_counterparty_id)) cbi
		OUTER APPLY(SELECT cca.rounding, cca.margin_provision, cca.threshold_provided, cca.threshold_received, cca.min_transfer_amount
					FROM counterparty_contract_address cca
					WHERE cca.counterparty_id = sc.source_counterparty_id
					AND cca.contract_id = ces.contract_id
					AND ISNULL(cca.internal_counterparty_id,ces.internal_counterparty_id) =ces.internal_counterparty_id) rnd
		LEFT JOIN static_data_value sdv ON sdv.value_id = rnd.rounding
		LEFT JOIN counterparty_contacts cc 
			ON cc.counterparty_id = sc.source_counterparty_id AND cc.contact_type = -10000262
		LEFT JOIN counterparty_contacts ccii 
			ON ccii.counterparty_id = scIn.source_counterparty_id AND ccii.contact_type = -10000262
		LEFT JOIN static_data_value sdv1
			ON sdv1.code = 'Credit' AND sdv1.type_id = 32200 AND sdv1.value_id = cc.contact_type
		LEFT JOIN static_data_value sdv_cci_state
			ON sdv_cci_state.value_id = ccii.[state]
		LEFT JOIN static_data_value sdv_cci_country
			ON sdv_cci_country.value_id = ccii.country
		LEFT JOIN static_data_value sdv_cc_state
			ON sdv_cc_state.value_id = cc.[state]
		LEFT JOIN static_data_value sdv_cc_country
			ON sdv_cc_country.value_id = cc.country
		WHERE 1 = 1 AND 
		rnd.margin_provision IS NOT NULL 
		AND	ces.source_counterparty_id = @counterparty_id 
		AND ces.as_of_date = @as_of_date
		AND ces.internal_counterparty_id = @internal_counterparty_id
		AND ces.contract_id = @contract_id	
END

