IF OBJECT_ID(N'spa_regulatory_submission_error', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_regulatory_submission_error]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[spa_regulatory_submission_error]
	@submission_type VARCHAR(100),
	@process_id VARCHAR(100) = NULL,
	@batch_process_id VARCHAR(100) = '',
	@batch_report_param VARCHAR(500) = NULL
AS

/************Debug Code*************
DECLARE @submission_type VARCHAR(100),
		@process_id VARCHAR(100) = NULL,
		@batch_process_id VARCHAR(100) = '',
		@batch_report_param VARCHAR(500) = NULL

SELECT @submission_type = 'EMIR Collateral', @process_id = '7ed5e02a_1f62_4114_9916_4119c974280a',@batch_process_id='514BC04D_DAF6_45FC_8F60_C2BB259F1DBB_5errMifid86a1',@batch_report_param='spa_regulatory_submission_error @submission_type = ''EMIR Collateral'', @process_id = ''7ed5e02a_1f62_4114_9916_4119c974280a'''
--***********************************/

SET NOCOUNT ON

IF @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL
BEGIN
	DECLARE @str_batch_table VARCHAR(MAX) = '', @temp_table_name VARCHAR(200) = ''

	IF (@batch_process_id IS NULL)
		SET @batch_process_id = REPLACE(NEWID(), '-', '_')
	
	SET @temp_table_name = dbo.FNAProcessTableName('batch_report', dbo.FNADBUser(), @batch_process_id)

	SET @str_batch_table = ' INTO ' + @temp_table_name
END

DECLARE @sql_query VARCHAR(MAX), @regulatory_table VARCHAR(100)

SET @regulatory_table = CASE WHEN @submission_type = 'MiFID Transaction' THEN 'source_mifid '
							 WHEN @submission_type = 'MiFID Trade' THEN 'source_mifid_trade ' 
							 WHEN @submission_type IN ('EMIR MTM', 'EMIR Trade') THEN 'source_emir '
							 WHEN @submission_type = 'EMIR Collateral' THEN 'source_emir_collateral ' 
						END

IF @submission_type = 'MiFID Transaction'
BEGIN
	SET @sql_query = '
	SELECT sm.source_mifid_id AS [MiFID ID],
		   sm.source_deal_header_id AS [Deal ID],
		   ''"'' + sm.deal_id + ''"''AS [Reference ID],
		   ssbm.logical_name AS sub_book_id,
		   sm.[report_status] AS [Report Status],
		   sm.[trans_ref_no] AS [Transaction Reference Number],
		   sm.[trading_trans_id] AS [Trading Venue Transaction ID Code],
		   sm.[exec_entity_id] AS [Executing Entity ID Code],
		   sm.[covered_by_dir] AS [Investment Firm Covered by Directive 2014/65/EU],
		   sm.[submitting_entity_id_code] AS [Submitting Entity ID Code],
		   sm.[buyer_id] AS [Buyer ID Code],
		   sm.[buyer_country] AS [Buyer - Country of the Branch ],
		   sm.[buyer_fname] AS [Buyer - First Name(s)],
		   sm.[buyer_sname] AS [Buyer - Surname(s)],
		   sm.[buyer_dob] AS [Buyer - Date of Birth],
		   sm.[buyer_decision_maker_code] AS [Buyer Decision Maker Code],
		   sm.[buyer_decision_maker_fname] AS [Buyer Decision Maker - First Name(s)],
		   sm.[buyer_decision_maker_sname] AS [Buyer Decision Maker - Surname(s)],
		   CONVERT(VARCHAR(10), sm.[buyer_decision_maker_dob], 120) AS [Buyer Decision Maker - Date of Birth],
		   sm.[seller_id] AS [Seller ID Code],
		   sm.[seller_country] AS [Seller - Country of the Branch],
		   sm.[seller_fname] AS [Seller - First Name(s)],
		   sm.[seller_sname] AS [Seller - Surname(s)],
		   sm.[seller_dob] AS [Seller - Date of Birth],
		   sm.[seller_decision_maker_code] AS [Seller Decision Maker Code],
		   sm.[seller_decision_maker_fname] AS [Seller Decision Maker - First Name(s)],
		   sm.[seller_decision_maker_sname] AS [Seller Decision Maker - Surname(s)],
		   CONVERT(VARCHAR(10), sm.[seller_decision_maker_dob], 120) AS [Seller Decision Maker - Date of Birth],
		   sm.[order_trans_indicator] AS [Transmission of Order Indicator],
		   sm.[buyer_trans_firm_id] AS [Buyer - Transmitting Firm ID Code],
		   sm.[seller_trans_firm_id] AS [Seller - Transmitting Firm ID Code],
		   sm.[trading_date_time] AS [Trading Date Time],
		   sm.[trading_capacity] AS [Trading Capacity],
		   sm.[quantity] AS [Quantity],
		   sm.[quantity_currency] AS [Quantity Currency],
		   sm.[der_notional_incr_decr] AS [Derivative Notional Increase/Decrease],
		   sm.[price] AS [Price],
		   sm.[price_currency] AS [Price Currency],
		   sm.[net_amount] AS [Net Amount],
		   sm.[venue] AS [Venue],
		   sm.[branch_membership_country] AS [Country of the Branch Membership],
		   sm.[upfront_payment] AS [Upfront Payment],
		   sm.[upfront_payment_currency] AS [Upfront Payment Currency],
		   sm.[complex_trade_component_id] AS [Complex Trade Component ID],
		   sm.[instrument_id_code] AS [Instrument ID Code],
		   sm.[instrument_name] AS [Instrument Full Name],
		   sm.[instrument_classification] AS [Instrument Classification],
		   sm.[notional_currency_1] AS [Notional Currency 1],
		   sm.[notional_currency_2] AS [Notional Currency 2],
		   sm.[price_multiplier] AS [Price Multiplier],
		   sm.[underlying_instrument_code] AS [Underlying Instrument Code],
		   sm.[underlying_index_name] AS [Underlying Index Name],
		   sm.[underlying_index_term] AS [Term of the Underlying Index],
		   sm.[option_type] AS [Option Type],
		   sm.[strike_price] AS [Strike Price],
		   sm.[strike_price_currency] AS [Strike Price Currency],
		   sm.[option_exercise_style] AS [Option Exercise Style],
		   NULLIF(sm.[maturity_date], '''') AS [Maturity Date],
		   sm.[expiry_date] AS [Expiry Date],
		   sm.[delivery_type] AS [Delivery Type],
		   sm.[firm_invest_decision] AS [Investment Decision within Firm],
		   sm.[decision_maker_country] AS [Decision Maker - Country of the Branch],
		   sm.[firm_execution] AS [Execution within Firm],
		   sm.[supervising_execution_country] AS [Supervising Execution - Country of the Branch],
		   sm.[waiver_indicator] AS [Waiver Indicator],
		   sm.[short_selling_indicator] AS [Short Selling Indicator],
		   sm.[otc_post_trade_indicator] AS [OTC Post-Trade Indicator],
		   sm.[commodity_derivative_indicator] AS [Commodity Derivative Indicator],
		   sm.[securities_financing_transaction_indicator] AS [Securities Financing Transaction Indicator],
		   sm.report_type AS [Report type],
		   sm.create_date_from AS [Create Date From],
		   sm.create_date_to AS [Create Date To],
		   sdv.code AS [Submission Status],
		   sm.submission_date AS [Submission Date],
		   sm.confirmation_date AS [Confirmation Date],
		   sm.process_id AS [Process ID],
		   sm.error_validation_message AS [Error Validations],
		   sm.file_export_name AS [Export File Name],
		   sm.hash_of_concatenated_values AS [Hash Of Concatenated Values],
		   sm.create_user AS [Create User],
		   sm.create_ts AS [Create Timestamp],
		   sm.update_user AS [Update User],
		   sm.update_ts AS [Update Timestamp]
	' + @str_batch_table + '
	FROM source_mifid sm
	INNER JOIN source_deal_header sdh
		ON sdh.source_deal_header_id = sm.source_deal_header_id
	INNER JOIN source_system_book_map ssbm
		ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
			AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
			AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
			AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
	INNER JOIN static_data_value sdv
		ON sdv.value_id = sm.submission_status
		AND sdv.type_id = 39500
	WHERE process_id = ''' + @process_id + '''
		AND error_validation_message IS NOT NULL'

	EXEC(@sql_query)
END
ELSE IF @submission_type = 'MiFID Trade'
BEGIN
	SET @sql_query = '
		SELECT smt.source_deal_header_id [Deal ID],
		   smt.deal_id [Reference ID],
		   ssbm.logical_name [Sub Book],
		   trading_date_and_time [Trading Date and Time],
		   instrument_identification_code_type [Instrument Identification Code Type],
		   instrument_identification_code [Instrument Identification Code],
		   dbo.FNARemoveTrailingZeroes(ROUND(price, 4)) [Price],
		   venue_of_execution [Venue of Execution],
		   price_notation [Price Notation],
		   price_currency [Price Currency],
		   notation_quantity_measurement_unit [Notation of the Quantity in Measurement Unit],
		   dbo.FNARemoveTrailingZeroes(ROUND(quantity_measurement_unit, 4)) [Quantity in Measurement Unit],
		   dbo.FNARemoveTrailingZeroes(ROUND(quantity, 4)) [Quantity],
		   dbo.FNARemoveTrailingZeroes(ROUND(notional_amount, 4)) [Notional Amount],
		   notional_currency [Notional Currency],
		   type [Type],
		   publication_date_and_time [Publication Date and Time],
		   --venue_of_publication [Venue of Publication],
		   transaction_identification_code [Transaction Identification Code],
		   transaction_to_be_cleared [Transaction to be Cleared],
		   flags [Flags],
		   supplimentary_deferral_flags [Supplimentary Defferal Flags],
		   trade_report_id [Trade Report ID],
		   trade_version [Trade Version],
		   trade_report_type [Trade Report Type],
		   trade_report_reject_reason [Trade Report Reject Reason],
		   CASE WHEN trade_report_trans_type = 0 THEN ''New'' WHEN trade_report_trans_type = 1 THEN ''Cancel'' WHEN trade_report_trans_type = 2 THEN ''Modified'' END [Trade Report Trans Type],
		   package_id [Package ID],
		   trade_number [Trade Number],
		   total_num_trade_reports [Total Num Trade Reports],
		   security_id [Security ID],
		   security_id_source [Security ID Source],
		   unit_of_measure [Unit Of Measure],
		   contract_multiplier [Contract Multiplier],
		   reporting_party_lei [Reporting Party LEI],
		   submitting_party_lei [Submitting Party LEI],
		   submitting_party_si_status [Submitting Party SI Status],
		   asset_class [Asset Class],
		   contract_type [Contract Type],
		   asset_sub_class [AssetSubClass],
		   maturity_date [MaturityDate],
		   freight_size [FreightSize],
		   specific_route_or_time_charter_average [SpecificRouteOrTimeCharterAverage],
		   settlement_location [SettlementLocation],
		   reference_rate [ReferenceRate],
		   ir_term_of_contract [IRTermOfContract],
		   parameter [Parameter],
		   notional_currency2 [NotionalCurrency2],
		   series [Series],
		   version [Version],
		   roll_months [RollMonths],
		   next_roll_date [NextRollDate],
		   CASE WHEN smt.option_type = 1 THEN ''Call'' WHEN smt.option_type = 2 THEN ''Put'' END [OptionType],
		   strike_price [StrikePrice],
		   strike_currency [StrikeCurrency],
		   exercise_style [ExerciseStyle],
		   delivery_type [DeliveryType],
		   transaction_type [TransactionType],
		   final_price_type [FinalPriceType ],
		   floating_rate_of_leg2 [FloatingRateOfLeg2],
		   ir_term_of_contract_leg2 [IRTermOfContractLeg2 ],
		   issue_date [IssueDate ],
		   settl_currency [SettlCurrency ],
		   notional_schedule [NotionalSchedule ],
		   valuation_method_trigger [ValuationMethodTrigger ],
		   return_or_payout_trigger [ReturnorPayoutTrigger ],
		   debt_seniority [DebtSeniority ],
		   dsb_use_case [DSBUseCase ],
		   no_underlyings [NoUnderlyings ],
		   underlying_symbol [UnderlyingSymbol ],
		   underlying_security_type [UnderlyingSecurityType ],
		   underlying_issuer [UnderlyingIssuer ],
		   underlying_maturity_date [UnderlyingMaturityDate],
		   underlying_issue_date [UnderlyingIssueDate ],
		   underlying_security_id [UnderlyingSecurityID],
		   underlying_security_id_source [UnderlyingSecurityIDSource],
		   underlying_index_name [UnderlyingIndexName ],
		   underlying_issuer_type [UnderlyingIssuerType ],
		   underlying_index_term [UnderlyingIndexTerm ],
		   underlying_further_sub_product [UnderlyingFurtherSubProduct],
		   underlying_other_security_type [UnderlyingOtherSecurityType],
		   underlying_other_further_sub_product [UnderlyingOtherFurtherSubProduct],
		   error_validation_message [Error Validations]
	' + @str_batch_table + '
	FROM source_mifid_trade smt
	INNER JOIN source_deal_header sdh
		ON sdh.source_deal_header_id = smt.source_deal_header_id
	INNER JOIN source_system_book_map ssbm
		ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
			AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
			AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
			AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
	INNER JOIN static_data_value sdv
	  ON sdv.value_id = smt.submission_status
	  AND sdv.type_id = 39500
	WHERE error_validation_message IS NOT NULL 
		AND smt.process_id = ''' + @process_id + ''''

	EXEC(@sql_query)
END
ELSE IF @submission_type = 'EMIR Trade'
BEGIN
	SET @sql_query = '
		SELECT
			source_emir_id [EMIR ID],
			sdh.source_deal_header_id [Deal ID],
			se.deal_id [Deal Ref ID],
			ssbm.logical_name [Sub Book],
			se.reporting_timestamp [Reporting timestamp],
			''Trade'' AS [Trade/Allege],
			ISNULL(trade_id, '''') AS [Trade ID],
			'''' AS [Trade Party Transaction ID],
			ISNULL(report_tracking_no, '''') AS [Report tracking number],
			ISNULL(complex_trade_component_id, '''') AS [Complex trade component ID],
			'''' AS [Trade Party 1 - Event ID],
			ISNULL(se.counterparty_id, '''') AS [Reporting Counterparty ID],
			ISNULL(other_counterparty_id, '''') AS [Type of ID of the other Counterparty],
			ISNULL(counterparty_name, '''') AS [ID of the other Counterparty],
			'''' AS [Trade Party 1 - Execution Agent ID],
			'''' AS [Trade Party 2 - Execution Agent ID],
			CASE
				WHEN se.action_type = ''N'' THEN ''New''
				WHEN se.action_type = ''M'' THEN ''Modify''
				WHEN se.action_type = ''E'' THEN ''Error''
				WHEN se.action_type = ''C'' THEN ''Early Termination''
				WHEN se.action_type = ''R'' THEN ''Correction''
				WHEN se.action_type = ''V'' THEN ''Valuation update''
				WHEN se.action_type = ''P'' THEN ''Position component''
			END [Action type],
			CASE
				WHEN se.[level] = ''P'' THEN ''Position''
				WHEN se.[level] = ''T'' THEN ''Trade''
			END [Level],
			--ISNULL(reporting_timestamp, '''') AS [Reporting timestamp],
			ISNULL(reporting_entity_id, '''') AS [Report submitting entity ID],
			'''' AS [Submitted For Party],
			''New'' AS [Action],
			'''' AS [Message Version],
			''Position'' AS [Message Type],
			''ESMA'' AS [Trade Party 1 - Reporting Destination],
			''ETD'' AS [Exchange Traded Indicator],
			'''' AS [Trade Party 1 - Third Party Viewer ID Type],
			'''' AS [Trade Party 1 - Third Party Viewer ID],
			'''' AS [Message ID],
			'''' AS [Name of the counterparty],
			'''' AS [Domicile of the counterparty],
			'''' AS [Contract with non-EEA counterparty],
			ISNULL(counterparty_country, '''') AS [Country of the other Counterparty],
			ISNULL(corporate_sector, '''') AS [Corporate sector of the reporting counterparty],
			'''' AS [Financial or non-financial nature of the counterparty ],
			ISNULL(nature_of_reporting_cpty, '''') AS [Nature of the reporting counterparty],
			ISNULL(se.broker_id, '''') AS [Broker ID],
			ISNULL(clearing_member_id, '''') AS [Clearing member ID],
			ISNULL(beneficiary_type_id, '''') AS [Type of ID of the Beneficiary],
			ISNULL(beneficiary_id, '''') AS [Beneficiary ID],
			ISNULL(trading_capacity, '''') AS [Trading capacity],
			ISNULL(counterparty_side, '''') AS [Counterparty side],
			ISNULL(commercial_or_treasury, '''') AS [Directly linked to commercial activity or treasury financing],
			ISNULL(clearing_threshold, '''') AS [Clearing threshold],
			'''' AS [Taxonomy used],
			'''' AS [Product ID 1],
			'''' AS [Product ID 2],
			ISNULL(contract_type, '''') AS [Contract type],
			ISNULL(asset_class, '''') AS [Asset class],
			ISNULL(product_classification_type, '''') AS [Product classification type],
			ISNULL(se.product_classification, '''') AS [Product classification],
			ISNULL(product_identification_type, '''') AS [Product identification type],
			ISNULL(product_identification, '''') AS [Product identification],
			ISNULL(underlying, '''') AS [Underlying identification type],
			ISNULL(underlying_identification, '''') AS [Underlying identification],
			ISNULL(derivable_currency, '''') AS [Deliverable currency],
			ISNULL(se.option_type, '''') AS [Option type],
			ISNULL(option_style, '''') AS [Option exercise style],
			ISNULL(strike_price, '''') AS [Strike price (cap/floor rate)],
			ISNULL(strike_price_notation, '''') AS [Strike price notation],
			ISNULL(underlying_maturity_date, '''') AS [Maturity date of the underlying],
			ISNULL(exec_venue, '''') AS [Venue of execution],
			ISNULL(compression, '''') AS [Compression],
			ISNULL(dbo.FNARemoveTrailingZeroes(ROUND(price_rate, 4)), '''') AS [Price / rate],
			ISNULL(price_notation, '''') AS [Price notation],
			ISNULL(price_currency, '''') AS [Currency of price],
			ISNULL(dbo.FNARemoveTrailingZeroes(ROUND(notional_amount, 4)), '''') AS [Notional],
			ISNULL(notional_currency_1, '''') AS [Notional currency 1],
			ISNULL(notional_currency_2, '''') AS [Notional currency 2],
			ISNULL(price_multiplier, '''') AS [Price multiplier],
			ISNULL(quantity, '''') AS [Quantity],
			ISNULL(up_front_payment, '''') AS [Up-front payment],
			ISNULL(delivery_type, '''') AS [Delivery type],
			ISNULL(execution_timestamp, '''') AS [Execution timestamp],
			ISNULL(effective_date, '''') AS [Effective date],
			ISNULL(maturity_date, '''') AS [Maturity date],
			ISNULL(termination_date, '''') AS [Termination date],
			ISNULL(settlement_date, '''') AS [Settlement date],
			ISNULL(aggreement_type, '''') AS [Master Agreement type],
			ISNULL(aggreement_version, '''') AS [Master Agreement version],
			ISNULL(confirm_ts, '''') AS [Confirmation timestamp],
			ISNULL(confirm_means, '''') AS [Confirmation means],
			ISNULL(clearing_obligation, '''') AS [Clearing obligation],
			ISNULL(cleared, '''') AS [Cleared],
			ISNULL(clearing_ts, '''') AS [Clearing timestamp],
			ISNULL(ccp, '''') AS [CCP],
			ISNULL(intra_group, '''') AS [Intragroup],
			ISNULL(fixed_rate_leg_1, '''') AS [Fixed rate of leg 1],
			ISNULL(fixed_rate_leg_2, '''') AS [Fixed rate of leg 2],
			'''' AS [Fixed rate day count],
			ISNULL(fixed_rate_day_count_leg_1, '''') AS [Fixed rate day count leg 1],
			ISNULL(fixed_rate_day_count_leg_2, '''') AS [Fixed rate day count leg 2],
			'''' AS [Fixed leg payment frequency],--
			ISNULL(fixed_rate_payment_feq_time_leg_1, '''') AS [Fixed rate payment frequency leg 1 - Time Period],
			ISNULL(fixed_rate_payment_feq_mult_leg_1, '''') AS [Fixed rate payment frequency leg 1 - Multiplier],
			ISNULL(fixed_rate_payment_feq_time_leg_2, '''') AS [Fixed rate payment frequency leg 2 - Time Period],
			ISNULL(fixed_rate_payment_feq_mult_leg_2, '''') AS [Fixed rate payment frequency leg 2 - Multiplier],
			'''' AS [Floating rate payment frequency],
			ISNULL(float_rate_payment_feq_time_leg_1, '''') AS [Floating rate payment frequency leg 1 - Time Period],
			ISNULL(float_rate_payment_feq_mult_leg_1, '''') AS [Floating rate payment frequency leg 1 - Multiplier],
			ISNULL(float_rate_payment_feq_time_leg_2, '''') AS [Floating rate payment frequency leg 2 - Time Period],
			ISNULL(float_rate_payment_feq_mult_leg_2, '''') AS [Floating rate payment frequency leg 2 - Multiplier],
			'''' AS [Floating rate reset frequency],
			ISNULL(float_rate_reset_freq_leg_1_time, '''') AS [Floating rate reset frequency leg 1 - Time Period],
			ISNULL(float_rate_reset_freq_leg_1_mult, '''') AS [Floating rate reset frequency leg 1 - Multiplier],
			ISNULL(float_rate_reset_freq_leg_2_time, '''') AS [Floating rate reset frequency leg 2- Time Period],
			ISNULL(float_rate_reset_freq_leg_2_mult, '''') AS [Floating rate reset frequency leg 2 - Multiplier],
			ISNULL(float_rate_leg_1, '''') AS [Floating rate of leg 1],
			ISNULL(float_rate_ref_period_leg_1_time, '''') AS [Floating rate reference period leg 1 - Time Period],
			float_rate_ref_period_leg_1_mult AS [Floating rate reference period leg 1 - Multiplier],
			ISNULL(float_rate_leg_2, '''') AS [Floating rate of leg 2],
			ISNULL(float_rate_ref_period_leg_2_time, '''') AS [Floating rate reference period leg 2 - Time Period],
			ISNULL(float_rate_ref_period_leg_2_mult, '''') AS [Floating rate reference period leg 2 - Multiplier],
			ISNULL(delivery_currency_2, '''') AS [Delivery currency 2],
			ISNULL(exchange_rate_1, '''') AS [Exchange rate 1],
			ISNULL(forward_exchange_rate, '''') AS [Forward exchange rate],
			ISNULL(exchange_rate_basis, '''') AS [Exchange rate basis],
			ISNULL(commodity_base, '''') AS [Commodity base],
			ISNULL(commodity_details, '''') AS [Commodity details],
			ISNULL(delivery_point, '''') AS [Delivery point or zone],
			ISNULL(interconnection_point, '''') AS [Interconnection Point],
			ISNULL(load_type, '''') AS [Load type],
			ISNULL(load_delivery_interval, '''') AS [Load delivery intervals],
			ISNULL(delivery_start_date, '''') AS [Delivery start date and time],
			ISNULL(delivery_end_date, '''') AS [Delivery end date and time],
			ISNULL(duration, '''') AS [Duration],
			ISNULL(days_of_the_week, '''') AS [Days of the week],
			'''' AS [Contract capacity],
			ISNULL(delivery_capacity, '''') AS [Delivery capacity],
			ISNULL(quantity_unit, '''') AS [Quantity Unit],
			ISNULL(price_time_interval_quantity, '''') AS [Price/time interval quantities],
			ISNULL(seniority, '''') AS [Seniority],
			ISNULL(reference_entity, '''') AS [Reference entity],
			ISNULL(frequency_of_payment, '''') AS [Frequency of payment],
			ISNULL(calculation_basis, '''') AS [The calculation basis],
			ISNULL(series, '''') AS [Series],
			ISNULL(version, '''') AS [Version],
			ISNULL(dbo.FNARemoveTrailingZeroes(ROUND(index_factor, 4)), '''') AS [Index factor],
			ISNULL(tranche, '''') AS [Tranche],
			ISNULL(attachment_point, '''') AS [Attachment point],
			ISNULL(detachment_point, '''') AS [Detachment point],
			ISNULL(dbo.FNARemoveTrailingZeroes(ROUND(contarct_mtm_value, 4)), '''') AS [Value of contract],
			ISNULL(contarct_mtm_currency, '''') AS [Currency of the value],
			ISNULL(valuation_ts, '''') AS [Valuation timestamp],
			ISNULL(valuation_type, '''') AS [Valuation type],
			'''' AS [Reserved - Participant Use 1],
			'''' AS [Reserved - Participant Use 2],
			'''' AS [Reserved - Participant Use 3],
			'''' AS [Reserved - Participant Use 4],
			'''' AS [Reserved - Participant Use 5],
			se.create_date_from [Create Date From],
			se.create_date_to [Create Date To],
			sdv.code [Submission Status],
			se.submission_date [Submission Date],
			se.confirmation_date [Confirmation Date],
			se.process_id [Process ID],
			se.error_validation_message [Error Validation],
			se.file_export_name [Export File Name],
			se.create_user [Create User],
			se.create_ts [Create TS],
			se.update_user [Update User],
			se.update_ts [Update TS]
		' + @str_batch_table + '
		FROM source_emir se
		INNER JOIN source_deal_header sdh
			ON sdh.source_deal_header_id = se.source_deal_header_id
		INNER JOIN source_system_book_map ssbm
			ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
				AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
				AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
				AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
		INNER JOIN static_data_value sdv
			ON sdv.value_id = se.submission_status
				AND sdv.type_id = 39500
		WHERE se.process_id = ''' + @process_id + '''
			AND error_validation_message IS NOT NULL'

	EXEC(@sql_query)
END
ELSE IF  @submission_type = 'EMIR MTM'
BEGIN
	SET @sql_query = '
		SELECT 
			source_emir_id [EMIR ID],
			sdh.source_deal_header_id [Deal ID],
			se.deal_id [Deal Ref ID],
			ssbm.logical_name [Sub Book],
			se.reporting_timestamp [Reporting timestamp],
			'''' [*Comment],
			action_type [Action],
			''EULITE1.0'' [Message Version],
			''Valuation'' [Message Type],
			ISNULL(reporting_entity_id, '''') [Report submitting entity ID],
			ISNULL(se.counterparty_id, '''') [Submitted For Party],
			ISNULL(other_counterparty_id, '''') [Trade Party 1 - ID Type],
			ISNULL(se.counterparty_id, '''') [Trade Party 1 - ID],
			ISNULL(other_counterparty_id, '''') [Trade Party 2 - ID Type],
			ISNULL(se.counterparty_name, '''') [Trade Party 2 - ID],
			''ESMA'' [Trade Party 1 - Reporting Destination],
			'''' [Trade Party 2 - Reporting Destination],
			'''' [Trade Party 1 - Execution Agent ID],
			'''' [Trade Party 2 - Execution Agent ID],
			'''' [Trade Party 1 - Third Party Viewer ID Type],
			'''' [Trade Party 1 - Third Party Viewer ID],
			''OTC'' [Exchange Traded Indicator],
			CAST(reporting_timestamp AS VARCHAR(10)) [Data Submitter Message ID],
			'''' [Trade Party 1 - Event ID],
			'''' [Trade Party 2 - Event ID],
			contarct_mtm_value [Value of contract - Trade Party 1],
			contarct_mtm_currency [Valuation Currency - Trade Party 1],
			valuation_ts [Valuation Datetime - Trade Party 1],
			''M'' [Valuation Type - Trade Party 1],
			'''' [Value of contract - Trade Party 2],
			'''' [Valuation Currency - Trade Party 2],
			'''' [Valuation Datetime - Trade Party 2],
			'''' [Valuation Type - Trade Party 2],
			ISNULL(trade_id, '''') [Trade ID],
			ISNULL(cleared, '''') [Cleared],
			''V'' [Trade Party 1 - Action Type],
			'''' [Trade Party 2 - Action Type],
			'''' [Reserved - Participant Use 1],
			'''' [Reserved - Participant Use 2],
			'''' [Reserved - Participant Use 3],
			'''' [Reserved - Participant Use 4],
			'''' [Reserved - Participant Use 5],
			ISNULL(asset_class, '''') [Asset Class],
			''M'' [Level],
			'''' [Trade Party 1 - Transaction ID],
			'''' [Trade Party 2 - Transaction ID],
			'''' [Trade Party 2 - Third Party Viewer ID Type],
			'''' [Trade Party 2 - Third Party Viewer ID],
			error_validation_message [Error Validations]
	' + @str_batch_table + '
	FROM source_emir se
	INNER JOIN source_deal_header sdh
		ON sdh.source_deal_header_id = se.source_deal_header_id
	INNER JOIN source_system_book_map ssbm
		ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
			AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
			AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
			AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
	INNER JOIN static_data_value sdv
		ON sdv.value_id = se.submission_status
			AND sdv.type_id = 39500
	WHERE [level] = ''M''
		AND se.process_id = ''' + @process_id + '''
		AND error_validation_message IS NOT NULL'

	EXEC(@sql_query)
END
ELSE IF @submission_type = 'EMIR Collateral'
BEGIN
	SET @sql_query = '
		SELECT sdh.source_deal_header_id [Deal ID],
			   se.deal_id + '' '' [Deal Ref ID],
			   ssbm.logical_name [Sub Book],
			   ''CollateralizedPortfolioLevel'' [*Comment],
			   ''Coll1.0'' [Version],
			   message_type [Message Type],
			   data_submitter_message_id [Data Submitter Message ID],
			   [action] [Action],
			   data_submitter_prefix [Data Submitter prefix],
			   data_submitter_value [Data Submitter value],
			   trade_party_prefix [Trade Party Prefix],
			   trade_party_value [Trade Party Value],
			   execution_agent_party_prefix [Execution Agent Party Prefix],
			   execution_agent_party_value [Execution Agent Party Value],
			   collateral_portfolio_code [Collateral Portfolio Code],
			   collateral_portfolio [Collateral Portfolio],
			   value_of_the_collateral [Value of the collateral],
			   currency_of_the_collateral [Currency of the collateral],
			   collateral_valuation_date_time [Collateral Valuation Date Time],
			   collateral_reporting_date [Collateral Reporting Date],
			   send_to [sendTo],
			   execution_agent_masking_indicator [Execution Agent Masking Indicator],
			   trade_party_reporting_obligation [Trade Party Reporting Obligation],
			   other_party_id_type [Other Party ID Type],
			   other_party_id [Other Party ID],
			   collateralized [Collateralized],
			   initial_margin_posted [Initial Margin Posted],
			   initial_margin_posted_currency [Currency of the initial margin posted],
			   initial_margin_received [Initial Margin Received  ],
			   initial_margin_received_currency [Currency of the initial margin received],
			   variation_margin_posted [Variation Margin Posted],
			   variation_margin_posted_currency [Currency of the Variation Margin Posted],
			   variation_margin_received [Variation Margin Received  ],
			   variation_margin_received_currency [Currency of the variation margin received],
			   excess_collateral_posted [Excess Collateral Posted],
			   excess_collateral_posted_currency [Currency of the Excess Collateral Posted],
			   excess_collateral_received [Excess Collateral Received],
			   excess_collateral_received_currency [Currency of the Excess Collateral received],
			   third_party_viewer [Third Party Viewer],
			   reserved_participant_use_1 [Reserved - Participant Use 1],
			   reserved_participant_use_2 [Reserved - Participant Use 2],
			   reserved_participant_use_3 [Reserved - Participant Use 3],
			   reserved_participant_use_4 [Reserved - Participant Use 4],
			   reserved_participant_use_5 [Reserved - Participant Use 5],
			   action_type_party_1 [Action Type Party 1],
			   third_party_viewer_id_type [Third Party Viewer ID Type],
			   [level] [Level],
			   error_validation_message [Error]
		' + @str_batch_table + ' 
		FROM source_emir_collateral se
		INNER JOIN source_deal_header sdh
			ON sdh.source_deal_header_id = se.source_deal_header_id
		INNER JOIN source_system_book_map ssbm
			ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
				AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
				AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
				AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
		INNER JOIN static_data_value sdv
			ON sdv.value_id = se.submission_status
				AND sdv.type_id = 39500
		WHERE se.process_id = ''' + @process_id + '''
			AND se.error_validation_message IS NOT NULL'

		EXEC(@sql_query)
		
END

IF @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL
BEGIN
	DECLARE @user_name VARCHAR(100) = dbo.FNADBUser(), @job_name VARCHAR(100) = 'report_batch_' + @batch_process_id
	
	IF OBJECT_ID('tempdb..#temp_regulatory_table') IS NOT NULL
		DROP TABLE #temp_regulatory_table

	CREATE TABLE #temp_regulatory_table (
		process_id VARCHAR(200),
		error_validation_message VARCHAR(MAX)
	)

	EXEC('
		INSERT INTO #temp_regulatory_table
		SELECT process_id, error_validation_message
		FROM ' + @regulatory_table + ' 
		WHERE process_id = ''' + @process_id + '''
	')

	IF EXISTS(SELECT 1 FROM #temp_regulatory_table WHERE process_id = @process_id AND error_validation_message IS NOT NULL)
	BEGIN
		SELECT @str_batch_table = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL)	
		EXEC (@str_batch_table)
		
		DECLARE @file_name VARCHAR(1000), @title VARCHAR(100)

		SET @file_name = CASE 
							WHEN @submission_type = 'MiFID Transaction' THEN 'MiFID_Transaction_Error_Report_' + REPLACE(CONVERT(VARCHAR(10), GETDATE(), 120), '-', '') + '_' + REPLACE(CAST(CAST(GETDATE() AS TIME) AS VARCHAR(8)), ':', '')
							WHEN @submission_type = 'MiFID Trade' THEN 'MiFID_Trade_Error_Report_' + REPLACE(CONVERT(VARCHAR(10), GETDATE(), 120), '-', '') + '_' + REPLACE(CAST(CAST(GETDATE() AS TIME) AS VARCHAR(8)), ':', '')
							WHEN @submission_type LIKE '%EMIR%' THEN 'EMIR_Error_Report_' + REPLACE(CONVERT(VARCHAR(10), GETDATE(), 120), '-', '') + '_' + REPLACE(CAST(CAST(GETDATE() AS TIME) AS VARCHAR(8)), ':', '')
						 END
		SET @title = CASE 
						WHEN @submission_type = 'MiFID Transaction' THEN 'MiFID Transaction Error Report'
						WHEN @submission_type = 'MiFID Trade' THEN 'MiFID Trade Error Report'
						WHEN @submission_type LIKE '%EMIR%' THEN 'EMIR Error Report'
					 END
	
		SELECT @str_batch_table = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, DEFAULT, @file_name, @title)
		EXEC (@str_batch_table)
	END
	ELSE 
	BEGIN
		DELETE mb
		FROM application_role_user afu 
		INNER JOIN application_security_role asr 
			ON asr.role_id = afu.role_id
		LEFT JOIN message_board mb
			ON mb.user_login_id = afu.user_login_id
				OR mb.user_login_id = dbo.FNADBUser()
		INNER JOIN static_data_value sdv
			ON sdv.value_id = asr.role_type_value_id
				AND sdv.code = 'Regulatory Submission'
				AND sdv.[type_id] = 1
		WHERE mb.process_id = @batch_process_id
			
	END

	SET @sql_query = 'DELETE FROM ' + @regulatory_table + 
					 ' WHERE process_id = ''' + @process_id + ''' 
						AND error_validation_message IS NOT NULL'
	
	EXEC(@sql_query)
END
