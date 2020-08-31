SET NOCOUNT OFF

IF OBJECT_ID('tempdb..#temp_def_code') IS NOT NULL
	DROP TABLE #temp_def_code

SELECT default_code_id, default_code, code_def, instances
INTO #temp_def_code
FROM adiha_default_codes WHERE code_def IN ('Allow to edit locked links by default',
	'AOCI/PNL allocation approach for match tenor case',
	'Assessment Beyond Quarter Exceptions',
	'Asset/Liabilities calculation',
	'Asset/Liabilities logic for AOCI',
	'Calculate MTM from deal',
	'Check of Hedging Relationship Type For Generation',
	'Currency Conversion  Factors',
	'Discount Factor Exceptions',
	'Discount Values Definition',
	'Effective PNL Exceptions',
	'Finalization of Automated Forecasted Transactions',
	'First Day PNL Rule',
	'Handling of PNL ineffectiveness if assessment failed',
	'Hedge PNL For Roll-forward Hedges Logic',
	' Hedged Items Settlement Entry Rule',
	'Location of Automated Forecasted Transactions',
	'Measurement Runs Count For Trend Graph',
	'Over Hedge Capacity Exception  Rule During Generation',
	'PNL Detail Save Options.',
	'PNL Exceptions',
	'PNL explain',
	'Prior AOCI Discounted Values',
	'Same PNL Sign Rule',
	'Save measurement results in FASTracker in a std as of date - end of month',
	'Source of Discounted MTM Values',
	'Test Hedge Eligibility Rules',
	'Use Balance of the Month Logic in MTM Report',
	'Outstanding Control Activities'
)

BEGIN TRY
BEGIN TRANSACTION
--SELECT *
DELETE adcv
FROM adiha_default_codes_values adcv
INNER JOIN #temp_def_code tdc ON tdc.default_code_id = adcv.default_code_id

--Allow to edit locked links by default
INSERT INTO adiha_default_codes_values (instance_no, default_code_id, seq_no, var_value, description)
SELECT 1, adc.default_code_id, 1, 0, 'Do not allow to edit locked links by default.' FROM adiha_default_codes adc
LEFT JOIN adiha_default_codes_values adcv ON adcv.default_code_id = adc.default_code_id AND adcv.description = 'Do not allow to edit locked links by default.'
WHERE adc.code_def = 'Allow to edit locked links by default' AND adcv.default_code_id IS NULL

--AOCI/PNL allocation approach for match tenor case
INSERT INTO adiha_default_codes_values (instance_no, default_code_id, seq_no, var_value, description)
SELECT 1, adc.default_code_id, 1, 0, 'AOCI/PNL will be allocated to each month based on total I/H%' FROM adiha_default_codes adc
LEFT JOIN adiha_default_codes_values adcv ON adcv.default_code_id = adc.default_code_id AND adcv.description = 'AOCI/PNL will be allocated to each month based on total I/H%'
WHERE adc.code_def = 'AOCI/PNL allocation approach for match tenor case' AND adcv.default_code_id IS NULL

--Assessment Beyond Quarter Exceptions
INSERT INTO adiha_default_codes_values (instance_no, default_code_id, seq_no, var_value, description)
SELECT 1, adc.default_code_id, 1, 2, 'If assessment is run beyond a quarter, use the most recent value and proceed without warning.' FROM adiha_default_codes adc
LEFT JOIN adiha_default_codes_values adcv ON adcv.default_code_id = adc.default_code_id AND adcv.description = 'If assessment is run beyond a quarter, use the most recent value and proceed without warning.'
WHERE adc.code_def = 'Assessment Beyond Quarter Exceptions' AND adcv.default_code_id IS NULL

--Asset/Liabilities calculation
INSERT INTO adiha_default_codes_values (instance_no, default_code_id, seq_no, var_value, description)
SELECT 1, adc.default_code_id, 1, 1, 'Assets/Liabilities calculation at Deal level.' FROM adiha_default_codes adc
LEFT JOIN adiha_default_codes_values adcv ON adcv.default_code_id = adc.default_code_id AND adcv.description = 'Assets/Liabilities calculation at Deal level.'
WHERE adc.code_def = 'Asset/Liabilities calculation' AND adcv.default_code_id IS NULL

--Asset/Liabilities logic for AOCI
--PNL Detail Save Options.
INSERT INTO adiha_default_codes_values (instance_no, default_code_id, seq_no, var_value, description)
SELECT 1, adc.default_code_id, 1, 1, 'Save PNL and Settlement but not Detail PNL.' FROM adiha_default_codes adc
LEFT JOIN adiha_default_codes_values adcv ON adcv.default_code_id = adc.default_code_id AND adcv.description = 'Save PNL and Settlement but not Detail PNL.'
WHERE adc.code_def = 'PNL Detail Save Options.' AND adcv.default_code_id IS NULL

--Calculate MTM from deal
INSERT INTO adiha_default_codes_values (instance_no, default_code_id, seq_no, var_value, description)
SELECT 1, adc.default_code_id, 1, 0, 'Do not calculate MTM on deal insert/update.' FROM adiha_default_codes adc
LEFT JOIN adiha_default_codes_values adcv ON adcv.default_code_id = adc.default_code_id AND adcv.description = 'Do not calculate MTM on deal insert/update.'
WHERE adc.code_def = 'Calculate MTM from deal' AND adcv.default_code_id IS NULL

--Check of Hedging Relationship Type For Generation
INSERT INTO adiha_default_codes_values (instance_no, default_code_id, seq_no, var_value, description)
SELECT 1, adc.default_code_id, 1, 1, 'For automation of forecasted transactions, even though hedging relationship type is passed, perform test to ensure that the hedges match the hedging relationship type.' FROM adiha_default_codes adc
LEFT JOIN adiha_default_codes_values adcv ON adcv.default_code_id = adc.default_code_id AND adcv.description = 'For automation of forecasted transactions, even though hedging relationship type is passed, perform test to ensure that the hedges match the hedging relationship type.'
WHERE adc.code_def = 'Check of Hedging Relationship Type For Generation' AND adcv.default_code_id IS NULL

--Currency Conversion Factors
INSERT INTO adiha_default_codes_values (instance_no, default_code_id, seq_no, var_value, description)
SELECT 1, adc.default_code_id, 1, 1, 'If currency conversion factors not found, use value of 1.0 and continue the measurement process with warning' FROM adiha_default_codes adc
LEFT JOIN adiha_default_codes_values adcv ON adcv.default_code_id = adc.default_code_id AND adcv.description = 'If currency conversion factors not found, use value of 1.0 and continue the measurement process with warning'
WHERE adc.code_def = 'Currency Conversion  Factors' AND adcv.default_code_id IS NULL

--Discount Factor Exceptions
INSERT INTO adiha_default_codes_values (instance_no, default_code_id, seq_no, var_value, description)
SELECT 1, adc.default_code_id, 1, 1, 'If discount factor not found, continue with warnings with default value of 1.0' FROM adiha_default_codes adc
LEFT JOIN adiha_default_codes_values adcv ON adcv.default_code_id = adc.default_code_id AND adcv.description = 'If discount factor not found, continue with warnings with default value of 1.0'
WHERE adc.code_def = 'Discount Factor Exceptions' AND adcv.default_code_id IS NULL

--Discount Values Definition
INSERT INTO adiha_default_codes_values (instance_no, default_code_id, seq_no, var_value, description)
SELECT 1, adc.default_code_id, 1, 2, 'Discount curve from source is already discount factor at deal level (no need to calculate discount factors - use as it is).' FROM adiha_default_codes adc
LEFT JOIN adiha_default_codes_values adcv ON adcv.default_code_id = adc.default_code_id AND adcv.description = 'Discount curve from source is already discount factor at deal level (no need to calculate discount factors - use as it is).'
WHERE adc.code_def = 'Discount Values Definition' AND adcv.default_code_id IS NULL

--Effective PNL Exceptions
INSERT INTO adiha_default_codes_values (instance_no, default_code_id, seq_no, var_value, description)
SELECT 1, adc.default_code_id, 1, 3, 'De-designation' FROM adiha_default_codes adc
LEFT JOIN adiha_default_codes_values adcv ON adcv.default_code_id = adc.default_code_id AND adcv.description = 'If Effective date PNL not found as of effective date, use the PNL as of max (as_of_date) or 0 prior to hedge effective date with warning.'
WHERE adc.code_def = 'Effective PNL Exceptions' AND adcv.default_code_id IS NULL
UNION ALL
SELECT 2, adc.default_code_id, 2, 1, 'Measurement' FROM adiha_default_codes adc
LEFT JOIN adiha_default_codes_values adcv ON adcv.default_code_id = adc.default_code_id AND adcv.description = 'If Effective date PNL not found as of effective date, continue with warnings with default value of 0.'
WHERE adc.code_def = 'Effective PNL Exceptions' AND adcv.default_code_id IS NULL

--Finalization of Automated Forecasted Transactions
INSERT INTO adiha_default_codes_values (instance_no, default_code_id, seq_no, var_value, description)
SELECT 1, adc.default_code_id, 1, 0, 'Requires approval of automated forecasted transactions from the user prior to the hedging relationship being finalized.' FROM adiha_default_codes adc
LEFT JOIN adiha_default_codes_values adcv ON adcv.default_code_id = adc.default_code_id AND adcv.description = 'Requires approval of automated forecasted transactions from the user prior to the hedging relationship being finalized.'
WHERE adc.code_def = 'Finalization of Automated Forecasted Transactions' AND adcv.default_code_id IS NULL

--First Day PNL Rule
INSERT INTO adiha_default_codes_values (instance_no, default_code_id, seq_no, var_value, description)
SELECT 1, adc.default_code_id, 1, 6, 'Same as option 5 except only strip out Item MTM if the item deal date not same as hedge deal date.' FROM adiha_default_codes adc
LEFT JOIN adiha_default_codes_values adcv ON adcv.default_code_id = adc.default_code_id AND adcv.description = 'Same as option 5 except only strip out Item MTM if the item deal date not same as hedge deal date.'
WHERE adc.code_def = 'First Day PNL Rule' AND adcv.default_code_id IS NULL

--Handling of PNL ineffectiveness if assessment failed
INSERT INTO adiha_default_codes_values (instance_no, default_code_id, seq_no, var_value, description)
SELECT 1, adc.default_code_id, 1, 0, 'Allow recapturing period MTM into AOCI in the period assessment fails.' FROM adiha_default_codes adc
LEFT JOIN adiha_default_codes_values adcv ON adcv.default_code_id = adc.default_code_id AND adcv.description = 'Allow recapturing period MTM into AOCI in the period assessment fails.'
WHERE adc.code_def = 'Handling of PNL ineffectiveness if assessment failed' AND adcv.default_code_id IS NULL

--Hedge PNL For Roll-forward Hedges Logic
INSERT INTO adiha_default_codes_values (instance_no, default_code_id, seq_no, var_value, description)
SELECT 1, adc.default_code_id, 1, 3, 'For roll forward hedges upon hedge settlement, re-measurement will not take place.' FROM adiha_default_codes adc
LEFT JOIN adiha_default_codes_values adcv ON adcv.default_code_id = adc.default_code_id AND adcv.description = 'For roll forward hedges upon hedge settlement, re-measurement will not take place.'
WHERE adc.code_def = 'Hedge PNL For Roll-forward Hedges Logic' AND adcv.default_code_id IS NULL

--Hedged Items Settlement Entry Rule
INSERT INTO adiha_default_codes_values (instance_no, default_code_id, seq_no, var_value, description)
SELECT 1, adc.default_code_id, 1, 0, 'Cash-flow Hedges' FROM adiha_default_codes adc
LEFT JOIN adiha_default_codes_values adcv ON adcv.default_code_id = adc.default_code_id AND adcv.description = 'Do not generate any settlement entry for hedged items.'
WHERE adc.code_def = ' Hedged Items Settlement Entry Rule' AND adcv.default_code_id IS NULL
UNION ALL
SELECT 2, adc.default_code_id, 2, 0, 'Fair-value Hedges' FROM adiha_default_codes adc
LEFT JOIN adiha_default_codes_values adcv ON adcv.default_code_id = adc.default_code_id AND adcv.description = 'Do not generate any settlement entry for hedged items.'
WHERE adc.code_def = ' Hedged Items Settlement Entry Rule' AND adcv.default_code_id IS NULL

--Location of Automated Forecasted Transactions
INSERT INTO adiha_default_codes_values (instance_no, default_code_id, seq_no, var_value, description)
SELECT 1, adc.default_code_id, 1, 0, 'Automated forecasted transactions (hedged items) are kept in FARRMS database.' FROM adiha_default_codes adc
LEFT JOIN adiha_default_codes_values adcv ON adcv.default_code_id = adc.default_code_id AND adcv.description = 'Automated forecasted transactions (hedged items) are kept in FARRMS database.'
WHERE adc.code_def = 'Location of Automated Forecasted Transactions' AND adcv.default_code_id IS NULL

--Measurement Runs Count For Trend Graph
INSERT INTO adiha_default_codes_values (instance_no, default_code_id, seq_no, var_value, description)
SELECT 1, adc.default_code_id, 1, 6, 'For measurement trend graph in dashboard, use past 6 measurement run.' FROM adiha_default_codes adc
LEFT JOIN adiha_default_codes_values adcv ON adcv.default_code_id = adc.default_code_id AND adcv.description = 'For measurement trend graph in dashboard, use past 6 measurement run.'
WHERE adc.code_def = 'Measurement Runs Count For Trend Graph' AND adcv.default_code_id IS NULL

--Over Hedge Capacity Exception Rule During Generation
INSERT INTO adiha_default_codes_values (instance_no, default_code_id, seq_no, var_value, description)
SELECT 1, adc.default_code_id, 1, 1, 'Check for over-hedged capacity exception during automation of forecasted transactions and continue with warnings.' FROM adiha_default_codes adc
LEFT JOIN adiha_default_codes_values adcv ON adcv.default_code_id = adc.default_code_id AND adcv.description = 'Check for over-hedged capacity exception during automation of forecasted transactions and continue with warnings.'
WHERE adc.code_def = 'Over Hedge Capacity Exception  Rule During Generation' AND adcv.default_code_id IS NULL


--PNL Detail Save Options. (Wrong One) should be Outstanding Control Activities
INSERT INTO adiha_default_codes_values (instance_no, default_code_id, seq_no, var_value, description)
SELECT 1, adc.default_code_id, 1, 1, 'Include previous 1 day.' FROM adiha_default_codes adc
LEFT JOIN adiha_default_codes_values adcv ON adcv.default_code_id = adc.default_code_id AND adcv.description = 'Include previous 1 day.'
WHERE adc.code_def = 'Outstanding Control Activities' AND adcv.default_code_id IS NULL
UNION ALL
SELECT 1, adc.default_code_id, 2, 2, 'Include previous 2 days.' FROM adiha_default_codes adc
LEFT JOIN adiha_default_codes_values adcv ON adcv.default_code_id = adc.default_code_id AND adcv.description = 'Include previous 2 days.'
WHERE adc.code_def = 'Outstanding Control Activities' AND adcv.default_code_id IS NULL
UNION ALL
SELECT 1, adc.default_code_id, 3, 3, 'Include previous 3 days.' FROM adiha_default_codes adc
LEFT JOIN adiha_default_codes_values adcv ON adcv.default_code_id = adc.default_code_id AND adcv.description = 'Include previous 3 days.'
WHERE adc.code_def = 'Outstanding Control Activities' AND adcv.default_code_id IS NULL
UNION ALL
SELECT 1, adc.default_code_id, 4, 4, 'Include previous 4 days.' FROM adiha_default_codes adc
LEFT JOIN adiha_default_codes_values adcv ON adcv.default_code_id = adc.default_code_id AND adcv.description = 'Include previous 4 days.'
WHERE adc.code_def = 'Outstanding Control Activities' AND adcv.default_code_id IS NULL
UNION ALL
SELECT 1, adc.default_code_id, 5, 5, 'Include previous 5 days.' FROM adiha_default_codes adc
LEFT JOIN adiha_default_codes_values adcv ON adcv.default_code_id = adc.default_code_id AND adcv.description = 'Include previous 5 days.'
WHERE adc.code_def = 'Outstanding Control Activities' AND adcv.default_code_id IS NULL
UNION ALL
SELECT 1, adc.default_code_id, 6, 6, 'Include previous 6 days.' FROM adiha_default_codes adc
LEFT JOIN adiha_default_codes_values adcv ON adcv.default_code_id = adc.default_code_id AND adcv.description = 'Include previous 6 days.'
WHERE adc.code_def = 'Outstanding Control Activities' AND adcv.default_code_id IS NULL
UNION ALL
SELECT 1, adc.default_code_id, 7, 7, 'Include previous 7 days.' FROM adiha_default_codes adc
LEFT JOIN adiha_default_codes_values adcv ON adcv.default_code_id = adc.default_code_id AND adcv.description = 'Include previous 7 days.'
WHERE adc.code_def = 'Outstanding Control Activities' AND adcv.default_code_id IS NULL

--PNL Exceptions
INSERT INTO adiha_default_codes_values (instance_no, default_code_id, seq_no, var_value, description)
SELECT 1, adc.default_code_id, 1, 1, 'If PNL not found, continue with warnings with default value of 0.' FROM adiha_default_codes adc
LEFT JOIN adiha_default_codes_values adcv ON adcv.default_code_id = adc.default_code_id AND adcv.description = 'If PNL not found, continue with warnings with default value of 0.'
WHERE adc.code_def = 'PNL Exceptions' AND adcv.default_code_id IS NULL

--PNL explain
INSERT INTO adiha_default_codes_values (instance_no, default_code_id, seq_no, var_value, description)
SELECT 1, adc.default_code_id, 1, 2, 'Both' FROM adiha_default_codes adc
LEFT JOIN adiha_default_codes_values adcv ON adcv.default_code_id = adc.default_code_id AND adcv.description = 'Both'
WHERE adc.code_def = 'PNL explain' AND adcv.default_code_id IS NULL

--Prior AOCI Discounted Values
INSERT INTO adiha_default_codes_values (instance_no, default_code_id, seq_no, var_value, description)
SELECT 1, adc.default_code_id, 1, 0, 'Use prior undiscounted AOCI and discount by current factor.' FROM adiha_default_codes adc
LEFT JOIN adiha_default_codes_values adcv ON adcv.default_code_id = adc.default_code_id AND adcv.description = 'Use prior undiscounted AOCI and discount by current factor.'
WHERE adc.code_def = 'Prior AOCI Discounted Values' AND adcv.default_code_id IS NULL

--Same PNL Sign Rule
INSERT INTO adiha_default_codes_values (instance_no, default_code_id, seq_no, var_value, description)
SELECT 1, adc.default_code_id, 1, 1, 'Take the entire hedges cumulative fair value to Earnings (AOCI will become 0)' FROM adiha_default_codes adc
LEFT JOIN adiha_default_codes_values adcv ON adcv.default_code_id = adc.default_code_id AND adcv.description = 'Take the entire hedges cumulative fair value to Earnings (AOCI will become 0)'
WHERE adc.code_def = 'Same PNL Sign Rule' AND adcv.default_code_id IS NULL

--Save measurement results in FASTracker in a std as of date - end of month
INSERT INTO adiha_default_codes_values (instance_no, default_code_id, seq_no, var_value, description)
SELECT 1, adc.default_code_id, 1, 0, 'Use actual valuation date as the as of date.' FROM adiha_default_codes adc
LEFT JOIN adiha_default_codes_values adcv ON adcv.default_code_id = adc.default_code_id AND adcv.description = 'Use actual valuation date as the as of date.'
WHERE adc.code_def = 'Save measurement results in FASTracker in a std as of date - end of month' AND adcv.default_code_id IS NULL

--Source of Discounted MTM Values
INSERT INTO adiha_default_codes_values (instance_no, default_code_id, seq_no, var_value, description)
SELECT 1, adc.default_code_id, 1, 0, 'MTM table contains discounted MTM.' FROM adiha_default_codes adc
LEFT JOIN adiha_default_codes_values adcv ON adcv.default_code_id = adc.default_code_id AND adcv.description = 'MTM table contains discounted MTM.'
WHERE adc.code_def = 'Source of Discounted MTM Values' AND adcv.default_code_id IS NULL

--Test Hedge Eligibility Rules
INSERT INTO adiha_default_codes_values (instance_no, default_code_id, seq_no, var_value, description)
SELECT 1, adc.default_code_id, 1, 1, 'For test hedge eligibility wizard, if rules are not found for given sub then use generic rules (sub id is used as -1)' FROM adiha_default_codes adc
LEFT JOIN adiha_default_codes_values adcv ON adcv.default_code_id = adc.default_code_id AND adcv.description = 'For test hedge eligibility wizard, if rules are not found for given sub then use generic rules (sub id is used as -1)'
WHERE adc.code_def = 'Test Hedge Eligibility Rules' AND adcv.default_code_id IS NULL

--Use Balance of the Month Logic in MTM Report
INSERT INTO adiha_default_codes_values (instance_no, default_code_id, seq_no, var_value, description)
SELECT 1, adc.default_code_id, 1, 0, 'Use balance of the month logic in MTM report.' FROM adiha_default_codes adc
LEFT JOIN adiha_default_codes_values adcv ON adcv.default_code_id = adc.default_code_id AND adcv.description = 'Use balance of the month logic in MTM report.'
WHERE adc.code_def = 'Use Balance of the Month Logic in MTM Report' AND adcv.default_code_id IS NULL

COMMIT TRANSACTION
END TRY
BEGIN CATCH
	PRINT 'ROLLINg BACK EVERy CHANGES.'
	DECLARE @err_msg VARCHAR(MAX) = ERROR_MESSAGE()
	ROLLBACK TRANSACTION
	RAISERROR (@err_msg, 17, -1);
END CATCH

GO