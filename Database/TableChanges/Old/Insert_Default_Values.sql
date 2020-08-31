
IF NOT EXISTS(SELECT 1 FROM adiha_default_codes_values_possible WHERE default_code_id = 16 AND var_value = 7)
	insert into adiha_default_codes_values_possible values(16, 7, 'Strip out MTM of first day for both hedge and item if deal date is same as hedge effective date (does not apply to portfolio logic).')

update adiha_default_codes_values  set var_value=7 where default_code_id=16

