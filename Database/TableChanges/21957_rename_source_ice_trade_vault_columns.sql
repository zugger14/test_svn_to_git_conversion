--Rename all the columns in order to follow the column naming conventions.

IF COL_LENGTH(N'source_ice_trade_vault', N'source_deal_header_id') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[source_deal_header_id]', 'source_deal_header_id', 'COLUMN'
END

IF COL_LENGTH(N'source_ice_trade_vault', N'SenderTradeRefId') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[SenderTradeRefId]', 'sender_trade_ref_id', 'COLUMN'
END

IF COL_LENGTH(N'source_ice_trade_vault', N'TradeDate') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[TradeDate]', 'trade_date', 'COLUMN'
END

IF COL_LENGTH(N'source_ice_trade_vault', N'Commodity') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[Commodity]', 'commodity', 'COLUMN'
END

IF COL_LENGTH(N'source_ice_trade_vault', N'Position') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[Position]', 'position', 'COLUMN'
END

IF COL_LENGTH(N'source_ice_trade_vault', N'Buyer') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[Buyer]', 'buyer', 'COLUMN'
END

IF COL_LENGTH(N'source_ice_trade_vault', N'Index') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[Index]', 'index', 'COLUMN'
END

IF COL_LENGTH(N'source_ice_trade_vault', N'Price') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[Price]', 'price', 'COLUMN'
END

IF COL_LENGTH(N'source_ice_trade_vault', N'Quantity') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[Quantity]', 'quantity', 'COLUMN'
END

IF COL_LENGTH(N'source_ice_trade_vault', N'StartDate') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[StartDate]', 'start_date', 'COLUMN'
END

IF COL_LENGTH(N'source_ice_trade_vault', N'EndDate') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[EndDate]', 'end_date', 'COLUMN'
END

IF COL_LENGTH(N'source_ice_trade_vault', N'Accounting Treatment') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[Accounting Treatment]', 'accounting_treatment', 'COLUMN'
END

IF COL_LENGTH(N'source_ice_trade_vault', N'TotalQuantity') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[TotalQuantity]', 'total_quantity', 'COLUMN'
END

IF COL_LENGTH(N'source_ice_trade_vault', N'Seller') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[Seller]', 'seller', 'COLUMN'
END

IF COL_LENGTH(N'source_ice_trade_vault', N'Broker') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[Broker]', 'broker', 'COLUMN'
END

IF COL_LENGTH(N'source_ice_trade_vault', N'PaymentCalendar') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[PaymentCalendar]', 'payment_calendar', 'COLUMN'
END

IF COL_LENGTH(N'source_ice_trade_vault', N'PaymentFrom') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[PaymentFrom]', 'payment_from', 'COLUMN'
END

IF COL_LENGTH(N'source_ice_trade_vault', N'PriceCurrency') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[PriceCurrency]', 'price_currency', 'COLUMN'
END

IF COL_LENGTH(N'source_ice_trade_vault', N'SettlementCurrency') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[SettlementCurrency]', 'settlement_currency', 'COLUMN'
END

IF COL_LENGTH(N'source_ice_trade_vault', N'SellerPayIndex') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[SellerPayIndex]', 'seller_pay_index', 'COLUMN'
END

IF COL_LENGTH(N'source_ice_trade_vault', N'HoursFromThru') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[HoursFromThru]', 'hours_from_thru', 'COLUMN'
END

IF COL_LENGTH(N'source_ice_trade_vault', N'HoursFromThruTimezone') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[HoursFromThruTimezone]', 'hours_from_thru_timezone', 'COLUMN'
END

IF COL_LENGTH(N'source_ice_trade_vault', N'LoadType') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[LoadType]', 'load_type', 'COLUMN'
END

IF COL_LENGTH(N'source_ice_trade_vault', N'DaysOfWeek') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[DaysOfWeek]', 'days_of_week', 'COLUMN'
END

IF COL_LENGTH(N'source_ice_trade_vault', N'MasterAgreementType') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[MasterAgreementType]', 'master_agreement_type', 'COLUMN'
END

IF COL_LENGTH(N'source_ice_trade_vault', N'ContractDate') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[ContractDate]', 'contract_date', 'COLUMN'
END

IF COL_LENGTH(N'source_ice_trade_vault', N'MasterAgreementVersion') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[MasterAgreementVersion]', 'master_agreement_version', 'COLUMN'
END

IF COL_LENGTH(N'source_ice_trade_vault', N'MarketType') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[MarketType]', 'market_type', 'COLUMN'
END

IF COL_LENGTH(N'source_ice_trade_vault', N'TradeType') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[TradeType]', 'trade_type', 'COLUMN'
END

IF COL_LENGTH(N'source_ice_trade_vault', N'ProductId') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[ProductId]', 'product_id', 'COLUMN'
END

IF COL_LENGTH(N'source_ice_trade_vault', N'ProductName') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[ProductName]', 'product_name', 'COLUMN'
END

IF COL_LENGTH(N'source_ice_trade_vault', N'ReportableProduct') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[ReportableProduct]', 'reportable_product', 'COLUMN'
END

IF COL_LENGTH(N'source_ice_trade_vault', N'ContractType') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[ContractType]', 'contract_type', 'COLUMN'
END

IF COL_LENGTH(N'source_ice_trade_vault', N'SwapPurpose') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[SwapPurpose]', 'swap_purpose', 'COLUMN'
END

IF COL_LENGTH(N'source_ice_trade_vault', N'SettlementMethod') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[SettlementMethod]', 'settlement_method', 'COLUMN'
END

IF COL_LENGTH(N'source_ice_trade_vault', N'PriceUnit') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[PriceUnit]', 'price_unit', 'COLUMN'
END

IF COL_LENGTH(N'source_ice_trade_vault', N'QuantityUnit') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[QuantityUnit]', 'quantity_unit', 'COLUMN'
END

IF COL_LENGTH(N'source_ice_trade_vault', N'QuantityFrequency') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[QuantityFrequency]', 'quantity_frequency', 'COLUMN'
END

IF COL_LENGTH(N'source_ice_trade_vault', N'SettlementFrequency') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[SettlementFrequency]', 'settlement_frequency', 'COLUMN'
END

IF COL_LENGTH(N'source_ice_trade_vault', N'SellerIndexPricingCalendar') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[SellerIndexPricingCalendar]', 'seller_index_pricing_calendar', 'COLUMN'
END

IF COL_LENGTH(N'source_ice_trade_vault', N'PaymentDays') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[PaymentDays]', 'payment_days', 'COLUMN'
END

IF COL_LENGTH(N'source_ice_trade_vault', N'PaymentTerms') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[PaymentTerms]', 'payment_terms', 'COLUMN'
END

IF COL_LENGTH(N'source_ice_trade_vault', N'CurrencyConversion') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[CurrencyConversion]', 'currency_conversion', 'COLUMN'
END

IF COL_LENGTH(N'source_ice_trade_vault', N'CurrencyConversionSource') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[CurrencyConversionSource]', 'currency_conversion_source', 'COLUMN'
END

IF COL_LENGTH(N'source_ice_trade_vault', N'ExecutionVenue') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[ExecutionVenue]', 'execution_venue', 'COLUMN'
END

IF COL_LENGTH(N'source_ice_trade_vault', N'Compression') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[Compression]', 'compression', 'COLUMN'
END

IF COL_LENGTH(N'source_ice_trade_vault', N'Cleared') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[Cleared]', 'cleared', 'COLUMN'
END

IF COL_LENGTH(N'source_ice_trade_vault', N'USSDRReportableTrade') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[USSDRReportableTrade]', 'ussdr_reportable_trade', 'COLUMN'
END

IF COL_LENGTH(N'source_ice_trade_vault', N'ExtraLegalLanguage') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[ExtraLegalLanguage]', 'extra_legal_language', 'COLUMN'
END

IF COL_LENGTH(N'source_ice_trade_vault', N'AllocationTrade') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[AllocationTrade]', 'allocation_trade', 'COLUMN'
END

IF COL_LENGTH(N'source_ice_trade_vault', N'InterAffiliateClearingExemptionElection') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[InterAffiliateClearingExemptionElection]', 'inter_affiliate_clearing_exemption_election', 'COLUMN'
END

IF COL_LENGTH(N'source_ice_trade_vault', N'EMIRReportableTrade') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[EMIRReportableTrade]', 'emir_reportable_trade', 'COLUMN'
END

IF COL_LENGTH(N'source_ice_trade_vault', N'ExecutionTime') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[ExecutionTime]', 'execution_time', 'COLUMN'
END

IF COL_LENGTH(N'source_ice_trade_vault', N'CollateralizationType') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[CollateralizationType]', 'collateralization_type', 'COLUMN'
END

IF COL_LENGTH(N'source_ice_trade_vault', N'ExecutionTimeCreator') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[ExecutionTimeCreator]', 'execution_time_creator', 'COLUMN'
END

IF COL_LENGTH(N'source_ice_trade_vault', N'UTICreator') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[UTICreator]', 'uti_creator', 'COLUMN'
END

IF COL_LENGTH(N'source_ice_trade_vault', N'BuyerCADTR') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[BuyerCADTR]', 'buyer_cadtr', 'COLUMN'
END

IF COL_LENGTH(N'source_ice_trade_vault', N'CADClearingExemption') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[CADClearingExemption]', 'cad_clearing_exemption', 'COLUMN'
END

IF COL_LENGTH(N'source_ice_trade_vault', N'CADReportingEntity') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[CADReportingEntity]', 'cad_reporting_entity', 'COLUMN'
END

IF COL_LENGTH(N'source_ice_trade_vault', N'SellerCADTR') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[SellerCADTR]', 'seller_cadtr', 'COLUMN'
END

IF COL_LENGTH(N'source_ice_trade_vault', N'CADHistoricSwap') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[CADHistoricSwap]', 'cad_historic_swap', 'COLUMN'
END

IF COL_LENGTH(N'source_ice_trade_vault', N'CSAReportableTrade') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[CSAReportableTrade]', 'csa_reportable_trade', 'COLUMN'
END

IF COL_LENGTH(N'source_ice_trade_vault', N'Create Date From') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[Create Date From]', 'create_date_from', 'COLUMN'
END

IF COL_LENGTH(N'source_ice_trade_vault', N'Create Date To') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[Create Date To]', 'create_date_to', 'COLUMN'
END

IF COL_LENGTH(N'source_ice_trade_vault', N'ICE Vault Submission Status') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[ICE Vault Submission Status]', 'acer_submission_status', 'COLUMN'
END

IF COL_LENGTH(N'source_ice_trade_vault', N'Process ID') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[Process ID]', 'process_id', 'COLUMN'
END

IF COL_LENGTH(N'source_ice_trade_vault', N'report_type_id') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[report_type_id]', 'report_type', 'COLUMN'
END

IF COL_LENGTH(N'source_ice_trade_vault', N'create_user') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[create_user]', 'create_user', 'COLUMN'
END

IF COL_LENGTH(N'source_ice_trade_vault', N'create_ts') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[create_ts]', 'create_ts', 'COLUMN'
END

IF COL_LENGTH(N'source_ice_trade_vault', N'update_user') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[update_user]', 'update_user', 'COLUMN'
END

IF COL_LENGTH(N'source_ice_trade_vault', N'update_ts') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[update_ts]', 'update_ts', 'COLUMN'
END

IF COL_LENGTH(N'source_ice_trade_vault', N'file_name') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_ice_trade_vault.[file_name]', 'file_name', 'COLUMN'
END
GO