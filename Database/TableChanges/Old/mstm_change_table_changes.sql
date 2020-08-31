insert into adiha_default_codes values(38, 'use_std_as_of_date', 'Save measurement results in FASTracker in a std as of date - end of month', 'Save measurement results in FASTracker in a std as of date - end of month', 1)
insert into adiha_default_codes_params values(1, 38, 'use_std_as_of_date', 3, NULL, 'h')
insert into adiha_default_codes_values_possible values(38, 0, 'Use actual valulation date as the as of date.')
insert into adiha_default_codes_values_possible values(38, 1, 'Use standard as of date for all valulation dates - end day of each month.')
insert into adiha_default_codes_values values(1, 38, 1, 0, NULL)  


alter table calcprocess_deals add valuation_date datetime null
alter table calcprocess_deals_arch1 add valuation_date datetime null
alter table calcprocess_deals_arch2 add valuation_date datetime null
alter table calcprocess_deals_expired add valuation_date datetime null
alter table report_measurement_values add valuation_date datetime null, d_aoci_released float null
alter table report_measurement_values_arch1 add valuation_date datetime null, d_aoci_released float null
alter table report_measurement_values_arch2 add valuation_date datetime null, d_aoci_released float null
alter table report_measurement_values_expired add valuation_date datetime null, d_aoci_released float null
