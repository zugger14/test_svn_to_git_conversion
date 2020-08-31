
-------------------------------------------READ ME----------------------------------------------------------------------------
-----  ENSURE THAT THERE IS NO EXISTING 27, 28, 29 CODES IN adiha_default_codes which may be conflict ------------------------
------------------------------------------------------------------------------------------------------------------------------
-- select * from adiha_default_codes order by default_code_id
delete adiha_default_codes_values_possible where default_code_id = 16 and var_value=6

insert into adiha_default_codes_values_possible values(16, 6, 'Same as Option 5 except only strip out Item MTM if the item deal date not same as hedge deal date.')

delete adiha_default_codes_values_possible where default_code_id = 14 and var_value=2
insert into adiha_default_codes_values_possible values(14, 2, 'Discount curve from  source is already discount factor at deal level (no  need to  calculate discount factors - use as it is)')

delete adiha_default_codes_values where default_code_id = 27
delete adiha_default_codes_values_possible where default_code_id = 27
delete adiha_default_codes_params where default_code_id = 27
delete adiha_default_codes where default_code_id = 27
insert into adiha_default_codes values(27, 'disc_mtm_source', 'Source of Discounted MTM Values', 'Source of Discounted MTM Values', 1)
insert into adiha_default_codes_params values(1, 27, 'disc_mtm_source_val', 3, NULL, 'h')
insert into adiha_default_codes_values_possible values(27, 0, 'MTM Table contains discounted MTM')
insert into adiha_default_codes_values_possible values(27, 1, 'Calculate dynamically using Undiscounted MTM Values')
insert into adiha_default_codes_values values(1, 27, 1, 1, NULL)  

delete adiha_default_codes_values where default_code_id = 28
delete adiha_default_codes_values_possible where default_code_id = 28
delete adiha_default_codes_params where default_code_id = 28
delete adiha_default_codes where default_code_id = 28
insert into adiha_default_codes values(28, 'asset_liab_by_deal', 'Asset/Liabilities calculation', 'Asset/Liabilities calculation', 1)
insert into adiha_default_codes_params values(1, 28, 'asset_liab_deal', 3, NULL, 'h')
insert into adiha_default_codes_values_possible values(28, 0, 'Asset/Liabilities calculation at Link level')
insert into adiha_default_codes_values_possible values(28, 1, 'Asset/Liabilities calculation at Deal level')
insert into adiha_default_codes_values values(1, 28, 1, 0, NULL)  


delete adiha_default_codes_values where default_code_id = 29
delete adiha_default_codes_values_possible where default_code_id = 29
delete adiha_default_codes_params where default_code_id = 29
delete adiha_default_codes where default_code_id = 29
insert into adiha_default_codes values(29, 'prior_aoci_disc_value', 'Prior AOCI Discounted Values', 'Prior AOCI Discounted Values', 1)
insert into adiha_default_codes_params values(1, 29, 'prior_aoci_disc_value', 3, NULL, 'h')
insert into adiha_default_codes_values_possible values(29, 0, 'Use prior undiscounted AOCI and discount by current factor')
insert into adiha_default_codes_values_possible values(29, 1, 'Use prior AOCI discounted values')
insert into adiha_default_codes_values values(1, 29, 1, 0, NULL)  

delete adiha_default_codes_values where default_code_id = 31
delete adiha_default_codes_values_possible where default_code_id = 31
delete adiha_default_codes_params where default_code_id = 31
delete adiha_default_codes where default_code_id = 31
insert into adiha_default_codes values(31, 'tenor_match_per', 'AOCI/PNL allocation approach for match tenor case', 'AOCI/PNL allocation approach for match tenor case', 1)
insert into adiha_default_codes_params values(1, 31, 'tenor_match_per', 3, NULL, 'h')
insert into adiha_default_codes_values_possible values(31, 0, 'AOCI/PNL will be allocated to each month based on total I/H%')
insert into adiha_default_codes_values_possible values(31, 1, 'AOCI/PNL will be allocated to each month based on monthly I/H%')
insert into adiha_default_codes_values values(1, 31, 1, 0, NULL)  

delete adiha_default_codes_values where default_code_id = 32
delete adiha_default_codes_values_possible where default_code_id = 32
delete adiha_default_codes_params where default_code_id = 32
delete adiha_default_codes where default_code_id = 32
insert into adiha_default_codes values(32, 'deal_detail_audit_log', 'Maintain deal detail audit log while importing deals', 'Maintain deal detail audit log while importing deals', 1)
insert into adiha_default_codes_params values(1, 32, 'deal_detail_audit_log', 3, NULL, 'h')
insert into adiha_default_codes_values_possible values(32, 1, 'Do not maintain deal detail audit log while importing')
insert into adiha_default_codes_values_possible values(32, 2, 'Maintain deal deail audit log while maintaining')
insert into adiha_default_codes_values values(1, 32, 1, 1, NULL)  

delete adiha_default_codes_values where default_code_id = 33
delete adiha_default_codes_values_possible where default_code_id = 33
delete adiha_default_codes_params where default_code_id = 33
delete adiha_default_codes where default_code_id = 33
insert into adiha_default_codes values(33, 'allow_to_edit_locked_links', 'Allow to edit locked links by default', 'Allow to edit locked links by default',1)
insert into adiha_default_codes_params values(1, 33, 'allow_to_edit_locked_links', 3, NULL, 'h')
insert into adiha_default_codes_values_possible values(33, 1, 'Do not allow to edit locked links by default')
insert into adiha_default_codes_values_possible values(33, 2, 'Allow to edit locked links by default')
insert into adiha_default_codes_values values(1, 33, 1, 0, NULL)  



delete adiha_default_codes_values where default_code_id = 35
delete adiha_default_codes_values_possible where default_code_id = 35
delete adiha_default_codes_params where default_code_id = 35
delete adiha_default_codes where default_code_id = 35
insert into adiha_default_codes values(35, 'assment_failed_prior_ineff', 'Handling of PNL ineffectiveness if assessment failed', 'Handling of PNL ineffectiveness if assessment failed', 1)
insert into adiha_default_codes_params values(1, 35, 'lock_pmtm_assmt_failed', 3, NULL, 'h')
insert into adiha_default_codes_values_possible values(35, 0, 'Allow recapturing period MTM into AOCI in the period assessment fails.')
insert into adiha_default_codes_values_possible values(35, 1, 'Lock period MTM into PNL ineffetiveness in the period assessment fails.')
insert into adiha_default_codes_values values(1, 35, 1, 0, NULL)  

----
delete adiha_default_codes_values where default_code_id = 36
delete adiha_default_codes_values_possible where default_code_id = 36
delete adiha_default_codes_params where default_code_id = 36
delete adiha_default_codes where default_code_id = 36
insert into adiha_default_codes values(36, 'system_time_zone', 'Define System Time Zone', 'Define System Time Zone', 1)
insert into adiha_default_codes_params values(1, 36, 'system_time_zone', 3, NULL, 'h')
insert into adiha_default_codes_values_possible values(36, 5, 'Mountain Time')
insert into adiha_default_codes_values values(1, 36, 1, 5,'Mountain Time')  

----
delete adiha_default_codes_values where default_code_id = 37
delete adiha_default_codes_values_possible where default_code_id = 37
delete adiha_default_codes_params where default_code_id = 37
delete adiha_default_codes where default_code_id = 37
insert into adiha_default_codes values(37, 'mtm_report_bom_logic', 'Use Balance of the Month Logic in MTM Report', 'Use Balance of the Month Logic in MTM Report', 1)
insert into adiha_default_codes_params values(1, 37, 'mtm_report_bom_logic', 3, NULL, 'h')
insert into adiha_default_codes_values_possible values(37, 0, 'Use Balance of the Month Logic in MTM Report')
insert into adiha_default_codes_values_possible values(37, 1, 'Do Not Use Balance of the Month Logic in MTM Report')
insert into adiha_default_codes_values values(1, 37, 1, 0, 'Do Not Use Balance of the Month Logic in MTM Report')  




--select * from adiha_default_codes_values where default_code_id=33
GO
alter table calcprocess_deals add d_aoci float, d_pnl_ineffectiveness float, d_extrinsic_pnl float, d_pnl_mtm float, dis_pnl float
alter table calcprocess_deals_expired add d_aoci float, d_pnl_ineffectiveness float, d_extrinsic_pnl float, d_pnl_mtm float, dis_pnl float
alter table CALCPROCESS_AOCI_RELEASE add d_aoci float
alter table fas_books add hedge_item_same_sign varchar(1)

alter table calcprocess_deals_arch1 add d_aoci float, d_pnl_ineffectiveness float, d_extrinsic_pnl float, d_pnl_mtm float, dis_pnl float
alter table calcprocess_deals_arch2 add d_aoci float, d_pnl_ineffectiveness float, d_extrinsic_pnl float, d_pnl_mtm float, dis_pnl float
alter table CALCPROCESS_AOCI_RELEASE_arch1 add d_aoci float
alter table CALCPROCESS_AOCI_RELEASE_arch2 add d_aoci float

update adiha_default_codes_values set var_value=0
WHERE     (instance_no = '1') AND (default_code_id = 27) AND (seq_no = 1)


--select * from adiha_default_codes_values

