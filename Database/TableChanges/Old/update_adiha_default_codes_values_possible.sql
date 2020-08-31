/* Assessment Beyond Quarter Exceptions */
UPDATE adiha_default_codes_values_possible
	SET DESCRIPTION = 'If assessment is run  beyond a quarter, halt the measurement process with Error'
WHERE  default_code_id = 6 AND var_value = 0

UPDATE adiha_default_codes_values_possible
	SET DESCRIPTION = 'If assessment is  run beyond a quarter, use the most recent value and proceed with Warning'
WHERE  default_code_id = 6 AND var_value = 1

UPDATE adiha_default_codes_values_possible
	SET DESCRIPTION = 'If assessment is  run beyond a quarter, use the most recent value and proceed without Warning'
WHERE  default_code_id = 6 AND var_value = 2
/* END */


/* Test Hedge Eligibility Rules */
UPDATE adiha_default_codes_values_possible 
	SET description = 'For test hedge eligibility wizard, rules should  be used for specific sub (do  not use generic rules)' 
WHERE default_code_id = 11 AND var_value = 0

UPDATE adiha_default_codes_values_possible 
	SET description = 'For test hedge eligibility wizard, if rules are not found for a given sub then use generic rules (sub id is used as -1)' 
WHERE default_code_id = 11 AND var_value = 1
/* END */


/* Maintain deal detail audit log while importing deals */
UPDATE adiha_default_codes_values_possible 
	SET description = 'Do not maintain deal detail audit log while importing' 
WHERE default_code_id = 32 AND var_value = 1

UPDATE adiha_default_codes_values_possible 
	SET description = 'Maintain deal detail audit log while importing' 
WHERE default_code_id = 32 AND var_value = 2
/* END */


/* Check of Hedging Relationship Type For Generation */
UPDATE adiha_default_codes_values_possible 
	SET description = 'For automation  of forecasted transactions, if hedging relationship type is passed do not perform test to ensure that the hedges match the hedging relationship type' 
WHERE default_code_id = 17 AND var_value = 0

UPDATE adiha_default_codes_values_possible 
	SET description = 'For automation of forecasted transactions, even though hedging relationship type is passed, perform test to ensure that the hedges match the hedging  relationship type' 
WHERE default_code_id = 17 AND var_value = 1
/* END */


/* Same PNL Sign Rule */
UPDATE adiha_default_codes_values_possible 
	SET description = 'If hedges and hedges itms PNL have same sign (both + or -) then take period PNL of hedges to Earnings (AOCI this  period will be same as prior AOCI)' 
WHERE default_code_id = 15 AND var_value = 0

UPDATE adiha_default_codes_values_possible 
	SET description = 'Take the entire hedges  cumulative fair value to Earnings (AOCI will become 0)' 
WHERE default_code_id = 15 AND var_value = 1

UPDATE adiha_default_codes_values_possible 
	SET description = 'Always use absolute value of both hedge and item for the PNL effectiveness test' 
WHERE default_code_id = 15 AND var_value = 2
/* END */


/* Finalization of Automated Forecasted Transactions */
UPDATE adiha_default_codes_values_possible 
	SET description = 'Requires approval of automated forecasted transactions from the user prior to the hedging relationship  being finalized ' 
WHERE default_code_id = 18 AND var_value = 0

UPDATE adiha_default_codes_values_possible 
	SET description = 'Does not  require approval of automated forecasted transactions from the user prior to the hedging relationship  being finalized (bypass the  approval process)' 
WHERE default_code_id = 18 AND var_value = 1
/* END */

