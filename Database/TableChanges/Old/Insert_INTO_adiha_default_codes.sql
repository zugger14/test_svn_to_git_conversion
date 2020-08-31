delete adiha_default_codes_values where default_code_id = 40
delete adiha_default_codes_values_possible where default_code_id = 40
delete adiha_default_codes_params where default_code_id = 40
delete adiha_default_codes where default_code_id = 40
insert into adiha_default_codes values(40, 'mtm_hourly_prices', 'For MTM whether to calculate wght avg of hourly prices. ', 'Wght Avg of hourly prices in MTM.', 1)
insert into adiha_default_codes_params values(1, 40, 'mtm_hourly_prices', 3, NULL, 'h')
insert into adiha_default_codes_values_possible values(40, 0, 'Monthly Wght Avg prices already provide for hourly prices.')
insert into adiha_default_codes_values_possible values(40, 1, 'Calculate Wght Avg prices in MTM process for hourly prices.')
insert into adiha_default_codes_values values(1, 40, 1, 1, NULL)  

delete adiha_default_codes_values where default_code_id = 41
delete adiha_default_codes_values_possible where default_code_id = 41
delete adiha_default_codes_params where default_code_id = 41
delete adiha_default_codes where default_code_id = 41
insert into adiha_default_codes values(41, 'calc_mtm_from_deal', 'Calculate MTM When Deal is inserted or updated', 'caclulate MTM from Deal', 1)
insert into adiha_default_codes_params values(1, 41, 'calc_mtm_from_deal', 3, NULL, 'h')
insert into adiha_default_codes_values_possible values(41, 0, 'Do not Caclulate MTM on deal insert/update')
insert into adiha_default_codes_values_possible values(41, 1, 'Caclulate MTM on deal insert/update')
insert into adiha_default_codes_values values(1, 41, 1, 1, NULL)  
