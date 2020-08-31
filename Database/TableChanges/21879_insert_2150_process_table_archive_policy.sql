
UPDATE process_table_archive_policy 
SET archieve_type_id=2151  
WHERE tbl_name='ems_calc_detail_value'

DELETE dbo.process_table_archive_policy  
WHERE tbl_name IN ('calcprocess_deals','calcprocess_aoci_release','report_measurement_values','report_netted_gl_entry','source_deal_pnl')

INSERT INTO dbo.process_table_archive_policy   
(tbl_name, prefix_location_table, dbase_name, upto, fieldlist, wherefield, frequency_type, archieve_type_id)
VALUES 
('calcprocess_deals', NULL,		NULL, 0, '*', 'as_of_date',	'm', 2150),
('calcprocess_deals', '_arch1',	NULL, 12,'*', 'as_of_date',	'm', 2150),
('calcprocess_deals', '_arch2',	NULL, 0, '*', 'as_of_date',	'm', 2150),
('calcprocess_aoci_release', NULL,	   NULL, 0, '*', 'as_of_date',	'm', 2150),
('calcprocess_aoci_release', '_arch1', NULL, 12,'*', 'as_of_date',	'm', 2150),
('calcprocess_aoci_release', '_arch2', NULL, 0, '*', 'as_of_date',	'm', 2150),
('report_measurement_values', NULL,		NULL, 0, '*', 'as_of_date', 'm', 2150),
('report_measurement_values', '_arch1',	NULL, 12,'*', 'as_of_date', 'm', 2150),
('report_measurement_values', '_arch2',	NULL, 0, '*', 'as_of_date', 'm', 2150),
('report_netted_gl_entry', NULL,	 NULL, 0, '[netted_gl_entry_id],[as_of_date],[netting_parent_group_id],[netting_parent_group_name],[netting_group_name],[gl_number],[gl_account_name],[debit_amount],[credit_amount],[discount_option],[create_user],[create_ts]', 'as_of_date', 'm', 2150),
('report_netted_gl_entry', '_arch1', NULL, 12,'[netted_gl_entry_id],[as_of_date],[netting_parent_group_id],[netting_parent_group_name],[netting_group_name],[gl_number],[gl_account_name],[debit_amount],[credit_amount],[discount_option],[create_user],[create_ts]', 'as_of_date', 'm', 2150),
('report_netted_gl_entry', '_arch2', NULL, 0, '[netted_gl_entry_id],[as_of_date],[netting_parent_group_id],[netting_parent_group_name],[netting_group_name],[gl_number],[gl_account_name],[debit_amount],[credit_amount],[discount_option],[create_user],[create_ts]', 'as_of_date', 'm', 2150),
('source_deal_pnl', NULL,	  NULL,	0, '[source_deal_pnl_id],[source_deal_header_id],[term_start],[term_end],[Leg],[pnl_as_of_date],[und_pnl],[und_intrinsic_pnl],[und_extrinsic_pnl],[dis_pnl],[dis_intrinsic_pnl],[dis_extrinisic_pnl],[pnl_source_value_id],[pnl_currency_id],[pnl_conversion_factor],[pnl_adjustment_value],[deal_volume],[create_user],[create_ts],[update_user],[update_ts],und_pnl_set, market_value,contract_value', 'pnl_as_of_date', 'm', 2150),
('source_deal_pnl',	'_arch1', NULL,	0,'[source_deal_pnl_id],[source_deal_header_id],[term_start],[term_end],[Leg],[pnl_as_of_date],[und_pnl],[und_intrinsic_pnl],[und_extrinsic_pnl],[dis_pnl],[dis_intrinsic_pnl],[dis_extrinisic_pnl],[pnl_source_value_id],[pnl_currency_id],[pnl_conversion_factor],[pnl_adjustment_value],[deal_volume],[create_user],[create_ts],[update_user],[update_ts],und_pnl_set, market_value,contract_value', 'pnl_as_of_date', 'm', 2150),
('source_deal_pnl',	'_arch2', NULL,	0, '[source_deal_pnl_id],[source_deal_header_id],[term_start],[term_end],[Leg],[pnl_as_of_date],[und_pnl],[und_intrinsic_pnl],[und_extrinsic_pnl],[dis_pnl],[dis_intrinsic_pnl],[dis_extrinisic_pnl],[pnl_source_value_id],[pnl_currency_id],[pnl_conversion_factor],[pnl_adjustment_value],[deal_volume],[create_user],[create_ts],[update_user],[update_ts],und_pnl_set, market_value,contract_value', 'pnl_as_of_date', 'm', 2150)