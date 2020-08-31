DELETE FROM master_view_counterparty_contract_address
INSERT INTO dbo.master_view_counterparty_contract_address (
	[counterparty_contract_address_id], [address1], [address2], [address3], [address4], [contract_id], [email], [fax], [telephone], [counterparty_id], [counterparty_full_name], [cc_mail], [bcc_mail], [remittance_to], [cc_remittance], [bcc_remittance], [internal_counterparty_id], [counterparty_trigger], [company_trigger], [margin_provision], [counterparty_name]
)
SELECT [cc].[counterparty_contract_address_id], [cc].[address1], [cc].[address2], [cc].[address3], [cc].[address4], [cg].[contract_name], [cc].[email], [cc].[fax], [cc].[telephone], [cc].[counterparty_id], [cc].[counterparty_full_name], [cc].[cc_mail], [cc].[bcc_mail], [cc].[remittance_to], [cc].[cc_remittance], [cc].[bcc_remittance], [sc2].[counterparty_name], sdv.code, sdv1.code, sdv2.code, [sc].[counterparty_name]
FROM counterparty_contract_address AS cc
LEFT JOIN contract_group AS cg ON cg.contract_id = cc.contract_id
LEFT JOIN source_counterparty AS sc ON sc.source_counterparty_id = cc.counterparty_id
LEFT JOIN source_counterparty AS sc2 ON sc2.source_counterparty_id = cc.internal_counterparty_id
LEFT JOIN static_data_value sdv ON sdv.value_id = cc.counterparty_trigger
LEFT JOIN static_data_value sdv1 ON sdv1.value_id = cc.company_trigger
LEFT JOIN static_data_value sdv2 ON sdv2.value_id = cc.margin_provision


DELETE FROM master_view_counterparty_credit_info
INSERT INTO dbo.master_view_counterparty_credit_info (
	counterparty_credit_info_id, Counterparty_id, account_status, limit_expiration, curreny_code, Industry_type1, Industry_type2, SIC_Code, Duns_No, Risk_rating, Debt_rating, Ticker_symbol, Date_established, Next_review_date, Last_review_date, Customer_since, Approved_by, Settlement_contact_name, Settlement_contact_address, Settlement_contact_address2, Settlement_contact_phone, Settlement_contact_email, payment_contact_name, payment_contact_address, contactfax, payment_contact_phone, payment_contact_email, Debt_Rating2, Debt_Rating3, Debt_Rating4, Debt_Rating5, payment_contact_address2, analyst, rating_outlook
)
SELECT cc.counterparty_credit_info_id, sc.counterparty_name, sdv.code, cc.limit_expiration, sc2.currency_name, sdv2.code, sdv3.code, sdv4.code, cc.Duns_No, sdv5.code, sdv6.code, cc.Ticker_symbol, CONVERT(VARCHAR(10), cc.Date_established, 120), CONVERT(VARCHAR(10), cc.Next_review_date, 120), CONVERT(VARCHAR(10), cc.Last_review_date, 120), CONVERT(VARCHAR(10), cc.Customer_since, 120), cc.Approved_by, cc.Settlement_contact_name, cc.Settlement_contact_address, cc.Settlement_contact_address2, cc.Settlement_contact_phone, cc.Settlement_contact_email, cc.payment_contact_name, cc.payment_contact_address, cc.contactfax, cc.payment_contact_phone, cc.payment_contact_email, sdv7.code, sdv8.code, sdv9.code, sdv10.code, cc.payment_contact_address2, cc.analyst, sdv11.code
FROM counterparty_credit_info AS cc
LEFT JOIN [source_counterparty] [sc] ON [sc].[source_counterparty_id] = [cc].[counterparty_id]
LEFT JOIN source_currency sc2 ON sc2.source_currency_id = cc.curreny_code
LEFT JOIN static_data_value sdv ON sdv.value_id = cc.account_status
LEFT JOIN static_data_value sdv2 ON sdv2.value_id = cc.Industry_type1
LEFT JOIN static_data_value sdv3 ON sdv3.value_id = cc.Industry_type2
LEFT JOIN static_data_value sdv4 ON sdv4.value_id = cc.SIC_Code
LEFT JOIN static_data_value sdv5 ON sdv5.value_id = cc.Risk_rating
LEFT JOIN static_data_value sdv6 ON sdv6.value_id = cc.Debt_rating
LEFT JOIN static_data_value sdv7 ON sdv7.value_id = cc.Debt_rating2
LEFT JOIN static_data_value sdv8 ON sdv8.value_id = cc.Debt_rating3
LEFT JOIN static_data_value sdv9 ON sdv9.value_id = cc.Debt_rating4
LEFT JOIN static_data_value sdv10 ON sdv10.value_id = cc.Debt_rating5
LEFT JOIN static_data_value sdv11 ON sdv11.value_id = cc.rating_outlook


DELETE FROM master_view_counterparty_credit_enhancements
INSERT INTO dbo.master_view_counterparty_credit_enhancements (
	counterparty_credit_enhancement_id, counterparty_credit_info_id, enhance_type, guarantee_counterparty, comment, currency_code, eff_date, approved_by, expiration_date, contract_id, internal_counterparty
)
SELECT cc.counterparty_credit_enhancement_id, cc.counterparty_credit_info_id, sdv.code, sc.counterparty_name, cc.comment, sc2.currency_name, CONVERT(VARCHAR(10), cc.eff_date, 120), cc.approved_by, CONVERT(VARCHAR(10), cc.expiration_date, 120), cg.[contract_name], sc3.counterparty_name --, sdv1.code
FROM counterparty_credit_enhancements AS cc
LEFT JOIN [source_counterparty] [sc] ON [sc].[source_counterparty_id] = [cc].[guarantee_counterparty]
LEFT JOIN source_currency sc2 ON sc2.source_currency_id = cc.currency_code
LEFT JOIN contract_group cg ON cg.contract_id = cc.contract_id
LEFT JOIN [source_counterparty] [sc3] ON [sc3].[source_counterparty_id] = [cc].internal_counterparty
LEFT JOIN static_data_value sdv ON sdv.value_id = cc.enhance_type
--LEFT JOIN static_data_value sdv1 ON sdv1.value_id = cc.collateral_status

DELETE FROM master_view_counterparty_credit_limits
INSERT INTO dbo.master_view_counterparty_credit_limits (
	counterparty_credit_limit_id, counterparty_id, contract_id, internal_counterparty_id, limit_status, counterparty_credit_info_id
)
SELECT cc.counterparty_credit_limit_id, sc.counterparty_name, cg.[contract_name], sc2.counterparty_name, sdv.code, cci.counterparty_credit_info_id
FROM counterparty_credit_limits AS cc
INNER JOIN counterparty_credit_info cci ON cci.Counterparty_id = [cc].counterparty_id
LEFT JOIN [source_counterparty] [sc] ON [sc].[source_counterparty_id] = [cc].counterparty_id
LEFT JOIN contract_group cg ON cg.contract_id = cc.contract_id
LEFT JOIN [source_counterparty] [sc2] ON [sc2].[source_counterparty_id] = [cc].internal_counterparty_id
LEFT JOIN static_data_value sdv ON sdv.value_id = cc.limit_status

DELETE FROM master_view_counterparty_epa_account
INSERT INTO dbo.master_view_counterparty_epa_account (
	counterparty_epa_account_id, counterparty_id, external_type_id, external_value, counterparty_name
)
SELECT cc.counterparty_epa_account_id, [cc].counterparty_id, sdv.code, cc.external_value, sc.counterparty_name
FROM counterparty_epa_account AS cc
INNER JOIN counterparty_credit_info cci ON cci.Counterparty_id = [cc].counterparty_id
LEFT JOIN [source_counterparty] [sc] ON [sc].[source_counterparty_id] = [cc].counterparty_id
LEFT JOIN static_data_value sdv ON sdv.value_id = cc.external_type_id

DELETE FROM master_view_counterparty_credit_migration
INSERT INTO dbo.master_view_counterparty_credit_migration (
	counterparty_credit_migration_id, counterparty_credit_info_id, counterparty, [contract], internal_counterparty, rating, effective_date
)
SELECT cc.counterparty_credit_migration_id, cc.counterparty_credit_info_id, sc.counterparty_name, cg.[contract_name], sc2.counterparty_name, sdv.code, CONVERT(VARCHAR(10), cc.effective_date, 120)
FROM counterparty_credit_migration AS cc
LEFT JOIN [source_counterparty] [sc] ON [sc].[source_counterparty_id] = [cc].counterparty
LEFT JOIN contract_group cg ON cg.contract_id = cc.[contract]
LEFT JOIN [source_counterparty] [sc2] ON [sc2].[source_counterparty_id] = [cc].internal_counterparty
LEFT JOIN static_data_value sdv ON sdv.value_id = cc.rating

DELETE FROM master_view_incident_log
INSERT INTO dbo.master_view_incident_log (
	[incident_log_id], [incident_type], [incident_description], [incident_status], [buyer_from], [seller_to], [location], [date_initiated], [date_closed], [trader], [logistics], [corrective_action], [preventive_action]
)
SELECT [cc].[incident_log_id], [sdv].[code], [cc].[incident_description], [sdv1].[code], [sc].[counterparty_name], [sc2].[counterparty_name], [sml].[Location_Name], CONVERT(VARCHAR(10), [cc].[date_initiated], 120), CONVERT(VARCHAR(10), [cc].[date_closed], 120), [st].[trader_name], [sdv2].[code], [cc].[corrective_action], [cc].[preventive_action]
FROM incident_log AS cc
LEFT JOIN [source_counterparty] AS [sc] ON [sc].[source_counterparty_id] = [cc].buyer_from
LEFT JOIN [source_counterparty] AS [sc2] ON [sc2].[source_counterparty_id] = [cc].seller_to
LEFT JOIN source_minor_location AS sml ON sml.source_minor_location_id = cc.[location]
LEFT JOIN source_traders AS st ON st.source_trader_id = cc.[trader]
--LEFT JOIN contract_group AS cg ON cg.contract_id = cc.[contract]
LEFT JOIN static_data_value AS sdv ON sdv.value_id = cc.incident_type
LEFT JOIN static_data_value AS sdv1 ON sdv1.value_id = cc.incident_status
LEFT JOIN static_data_value AS sdv2 ON sdv2.value_id = cc.logistics
--LEFT JOIN [source_counterparty] [sc3] ON [sc].[source_counterparty_id] = [cc].[counterparty]
--LEFT JOIN [source_counterparty] [sc4] ON [sc2].[source_counterparty_id] = [cc].[internal_counterparty]

DELETE FROM master_view_incident_log_detail
INSERT INTO dbo.master_view_incident_log_detail (
	incident_log_detail_id, incident_log_id, incident_status, comments
)
SELECT cc.incident_log_detail_id, cc.incident_log_id, sdv.code, cc.comments
FROM incident_log_detail AS cc
LEFT JOIN static_data_value sdv ON sdv.value_id = cc.incident_status