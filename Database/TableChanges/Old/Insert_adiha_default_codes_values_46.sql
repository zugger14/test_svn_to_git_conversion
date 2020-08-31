--select * from adiha_default_codes_values order by default_code_id
delete adiha_default_codes_values where default_code_id = 46
delete adiha_default_codes_values_possible where default_code_id = 46
delete adiha_default_codes_params where default_code_id = 46
delete adiha_default_codes where default_code_id = 46
insert into adiha_default_codes values(46, 'credit_exposure_calc', 'Credit Expousre Calculations Defined no of terms', 'Credit Expousre Calculations Defined no of terms', 1)
insert into adiha_default_codes_params values(1, 46, 'credit_physical_buy_mth no of terms', 3, NULL, 'h')
insert into adiha_default_codes_params values(2, 46, 'credit_physical_sell_mth no of terms', 3, NULL, 'h')
insert into adiha_default_codes_values_possible values(46, 0, '1st Term')
insert into adiha_default_codes_values_possible values(46, 1, '2nd Term')
insert into adiha_default_codes_values values(1, 46, 1, 3, 'credit_physical_buy_mth')  
insert into adiha_default_codes_values values(1, 46, 2, 3, 'credit_physical_sell_mth')  



