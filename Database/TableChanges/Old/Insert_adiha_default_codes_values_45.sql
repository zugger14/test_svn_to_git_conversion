--select * from adiha_default_codes_values order by default_code_id
delete adiha_default_codes_values where default_code_id = 45
delete adiha_default_codes_values_possible where default_code_id = 45
delete adiha_default_codes_params where default_code_id = 45
delete adiha_default_codes where default_code_id = 45
insert into adiha_default_codes values(45, 'credit_exposure_calc', 'Include Contract settlement in Credit Exposure', 'Include Contract settlement in Credit Exposure', 1)
insert into adiha_default_codes_params values(1, 45, 'credit_exposure_calc', 3, NULL, 'h')
insert into adiha_default_codes_values_possible values(45, 0, 'Include Contract settlement in Credit Exposure')
insert into adiha_default_codes_values_possible values(45, 1, 'Do Not Include Contract settlement in Credit Exposure')
insert into adiha_default_codes_values values(1, 45, 1, 1, 'Do Not Include Contract settlement in Credit Exposure')  