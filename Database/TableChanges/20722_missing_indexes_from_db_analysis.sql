
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[assignment_audit]') AND name = N'indx_assignment_audit_tm')
BEGIN 
	CREATE NONCLUSTERED INDEX indx_assignment_audit_tm ON [dbo].[assignment_audit](source_deal_header_id)
END 
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[calcprocess_aoci_release]') AND name = N'indx_calcprocess_aoci_release_tm')
BEGIN 
	CREATE NONCLUSTERED INDEX indx_calcprocess_aoci_release_tm ON [dbo].[calcprocess_aoci_release](link_id)
END 
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[calcprocess_deals]') AND name = N'indx_calcprocess_deals_tm')
BEGIN 
	CREATE NONCLUSTERED INDEX indx_calcprocess_deals_tm ON [dbo].[calcprocess_deals](link_id)
END 
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[calcprocess_deals]') AND name = N'ixp_cd')
BEGIN 
	CREATE NONCLUSTERED INDEX ixp_cd ON [dbo].[calcprocess_deals](link_id,link_type,as_of_date)
END 
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[calcprocess_deals_expired]') AND name = N'indx_calcprocess_deals_expired_tm')
BEGIN 
	CREATE NONCLUSTERED INDEX indx_calcprocess_deals_expired_tm ON [dbo].[calcprocess_deals_expired](link_id)
END 
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[calcprocess_deals_expired]') AND name = N'ixp_cde')
BEGIN 
	CREATE NONCLUSTERED INDEX ixp_cde ON [dbo].[calcprocess_deals_expired](link_id,link_type,as_of_date)
END 
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[confirm_status]') AND name = N'indx_confirm_status_tm')
BEGIN 
	CREATE NONCLUSTERED INDEX indx_confirm_status_tm ON [dbo].[confirm_status](source_deal_header_id)
END 
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[deal_exercise_detail]') AND name = N'indx_deal_exercise_detail_tm')
BEGIN 
	CREATE NONCLUSTERED INDEX indx_deal_exercise_detail_tm ON [dbo].[deal_exercise_detail](source_deal_detail_id)
END 
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[deal_tagging_audit]') AND name = N'indx_deal_tagging_audit_tm')
BEGIN 
	CREATE NONCLUSTERED INDEX indx_deal_tagging_audit_tm ON [dbo].[deal_tagging_audit](source_deal_header_id)
END 
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[deal_voided_in_external]') AND name = N'indx_deal_voided_in_external_tm')
BEGIN 
	CREATE NONCLUSTERED INDEX indx_deal_voided_in_external_tm ON [dbo].[deal_voided_in_external](source_deal_header_id)
END 
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[fas_dedesignated_link_detail]') AND name = N'indx_fas_dedesignated_link_detail_tm')
BEGIN 
	CREATE NONCLUSTERED INDEX indx_fas_dedesignated_link_detail_tm ON [dbo].[fas_dedesignated_link_detail](dedesignated_link_id) ON [PRIMARY ]
END 
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[fas_dedesignated_link_header]') AND name = N'indx_fas_dedesignated_link_header_tm') 
BEGIN 
	CREATE NONCLUSTERED INDEX indx_fas_dedesignated_link_header_tm ON [dbo].[fas_dedesignated_link_header](original_link_id)
END 
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[fas_eff_ass_test_results]') AND name = N'indx_fas_eff_ass_test_results_tm')
BEGIN 
	CREATE NONCLUSTERED INDEX indx_fas_eff_ass_test_results_tm ON [dbo].[fas_eff_ass_test_results](eff_test_profile_id)
END 
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[fas_eff_ass_test_results]') AND name = N'indx_fas_eff_ass_test_results_tm1')
BEGIN 
	CREATE NONCLUSTERED INDEX indx_fas_eff_ass_test_results_tm1 ON [dbo].[fas_eff_ass_test_results](calc_level)
END 
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[fas_eff_ass_test_results]') AND name = N'indx_fas_eff_ass_test_results_tm2')
BEGIN 
	CREATE NONCLUSTERED INDEX indx_fas_eff_ass_test_results_tm2 ON [dbo].[fas_eff_ass_test_results](link_id)
END 
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[fas_eff_ass_test_results]') AND name = N'indx_fas_eff_ass_test_results_tm3')
	BEGIN CREATE NONCLUSTERED INDEX indx_fas_eff_ass_test_results_tm3 ON [dbo].[fas_eff_ass_test_results](eff_test_result_id) ON [PRIMARY ]
END 
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[fas_eff_ass_test_results]') AND name = N'indx_fas_eff_ass_test_results1_tm') 
BEGIN 
	CREATE NONCLUSTERED INDEX indx_fas_eff_ass_test_results1_tm ON [dbo].[fas_eff_ass_test_results](calc_level)
END 
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[fas_eff_ass_test_results_process_detail]') AND name = N'indx_fas_eff_ass_test_results_process_detail_tm')
BEGIN 
	CREATE NONCLUSTERED INDEX indx_fas_eff_ass_test_results_process_detail_tm ON [dbo].[fas_eff_ass_test_results_process_detail](eff_test_result_id)
END 
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[fas_eff_ass_test_results_process_header]') AND name = N'indx_fas_eff_ass_test_results_process_header_tm')
BEGIN 
	CREATE NONCLUSTERED INDEX indx_fas_eff_ass_test_results_process_header_tm ON [dbo].[fas_eff_ass_test_results_process_header](eff_test_result_id)
END 
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[fas_eff_ass_test_results_profile]') AND name = N'indx_fas_eff_ass_test_results_profile_tm')
BEGIN 
	CREATE NONCLUSTERED INDEX indx_fas_eff_ass_test_results_profile_tm ON [dbo].[fas_eff_ass_test_results_profile](eff_test_result_id)
END 
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[fas_eff_hedge_rel_type_whatif]') AND name = N'indx_fas_eff_hedge_rel_type_whatif_tm')
BEGIN 
	CREATE NONCLUSTERED INDEX indx_fas_eff_hedge_rel_type_whatif_tm ON [dbo].[fas_eff_hedge_rel_type_whatif](eff_test_profile_id)
END 
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[fas_eff_hedge_rel_type_whatif]') AND name = N'indx_fas_eff_hedge_rel_type_whatif_tm1')
BEGIN 
	CREATE NONCLUSTERED INDEX indx_fas_eff_hedge_rel_type_whatif_tm1 ON [dbo].[fas_eff_hedge_rel_type_whatif](rel_id)
END 
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[fas_eff_hedge_rel_type_whatif_detail]') AND name = N'indx_fas_eff_hedge_rel_type_whatif_detail_tm')
BEGIN 
	CREATE NONCLUSTERED INDEX indx_fas_eff_hedge_rel_type_whatif_detail_tm ON [dbo].[fas_eff_hedge_rel_type_whatif_detail](eff_test_profile_id)
END 
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[fas_link_detail]') AND name = N'indx_fas_link_detail_tm')
BEGIN 
	CREATE NONCLUSTERED INDEX indx_fas_link_detail_tm ON [dbo].[fas_link_detail](link_id)
END 
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[fas_link_detail_dicing]') AND name = N'indx_fas_link_detail_dicing_tm')
BEGIN 
	CREATE NONCLUSTERED INDEX indx_fas_link_detail_dicing_tm ON [dbo].[fas_link_detail_dicing](link_id)
END 
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[fas_link_header]') AND name = N'indx_fas_link_header_tm')
BEGIN 
	CREATE NONCLUSTERED INDEX indx_fas_link_header_tm ON [dbo].[fas_link_header](link_id)
END 
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[first_day_gain_loss_decision]') AND name = N'indx_first_day_gain_loss_decision_tm')
BEGIN 
	CREATE NONCLUSTERED INDEX indx_first_day_gain_loss_decision_tm ON [dbo].[first_day_gain_loss_decision](source_deal_header_id) ON [PRIMARY ]
END 
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[Gis_Certificate]') AND name = N'indx_gis_certificate_tm') 
BEGIN 
	CREATE NONCLUSTERED INDEX indx_gis_certificate_tm ON [dbo].[Gis_Certificate](source_deal_header_id)
END 
GO


IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[inventory_reclassify_aoci]') AND name = N'indx_inventory_reclassify_aoci_tm')
BEGIN 
	CREATE NONCLUSTERED INDEX indx_inventory_reclassify_aoci_tm ON [dbo].[inventory_reclassify_aoci](link_id)
END 
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[reclassify_aoci]') AND name = N'indx_reclassify_aoci_tm')
BEGIN 
	CREATE NONCLUSTERED INDEX indx_reclassify_aoci_tm ON [dbo].[reclassify_aoci](link_id)
END 
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[report_measurement_values]') AND name = N'indx_report_measurement_values_tm')
BEGIN 
	CREATE NONCLUSTERED INDEX indx_report_measurement_values_tm ON [dbo].[report_measurement_values](link_id)
END 
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[report_measurement_values]') AND name = N'ixp_rmv')
BEGIN 
	CREATE NONCLUSTERED INDEX ixp_rmv ON [dbo].[report_measurement_values](link_id,link_deal_flag,as_of_date)
END 
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[report_measurement_values_expired]') AND name = N'indx_report_measurement_values_expired_tm')
BEGIN 
	CREATE NONCLUSTERED INDEX indx_report_measurement_values_expired_tm ON [dbo].[report_measurement_values_expired](link_id)
END 
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[report_measurement_values_expired]') AND name = N'ixp_rmve')
BEGIN 
	CREATE NONCLUSTERED INDEX ixp_rmve ON [dbo].[report_measurement_values_expired](link_id,link_deal_flag,as_of_date) ON [PRIMARY ] 
END 
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[source_book]') AND name = N'indx_source_book_name_tm') 
BEGIN 
	CREATE NONCLUSTERED INDEX indx_source_book_name_tm ON [dbo].[source_book](source_book_name)
END 
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[source_counterparty]') AND name = N'indx_counterparty_name_tm')
BEGIN 
	CREATE NONCLUSTERED INDEX indx_counterparty_name_tm ON [dbo].[source_counterparty](counterparty_name)
END 
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[source_deal_detail]') AND name = N'indx_source_deal_detail_tm')
BEGIN 
	CREATE NONCLUSTERED INDEX indx_source_deal_detail_tm ON [dbo].[source_deal_detail](source_deal_header_id)
END 
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[source_deal_detail]') AND name = N'IX_curve_leg')
BEGIN 
	CREATE NONCLUSTERED INDEX IX_curve_leg ON [dbo].[source_deal_detail](curve_id,Leg)
END 
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[source_deal_detail]') AND name = N'IX_deal_id_curve')
BEGIN 
	CREATE NONCLUSTERED INDEX IX_deal_id_curve ON [dbo].[source_deal_detail](source_deal_header_id,curve_id) ON [PRIMARY ]
END 
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[source_deal_header]') AND name = N'indx_entire_term_end_tm') 
BEGIN 
	CREATE NONCLUSTERED INDEX indx_entire_term_end_tm ON [dbo].[source_deal_header](entire_term_end)
END 
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[source_deal_header]') AND name = N'indx_source_deal_header_tm1')
BEGIN 
	CREATE NONCLUSTERED INDEX indx_source_deal_header_tm1 ON [dbo].[source_deal_header](source_system_book_id1) ON [PRIMARY ]
END 
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[source_deal_header]') AND name = N'indx_source_deal_header_tm2') 
BEGIN 
	CREATE NONCLUSTERED INDEX indx_source_deal_header_tm2 ON [dbo].[source_deal_header](source_system_book_id2)
END 
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[source_deal_header]') AND name = N'indx_source_deal_header_tm3')
BEGIN 
	CREATE NONCLUSTERED INDEX indx_source_deal_header_tm3 ON [dbo].[source_deal_header](source_system_book_id3)
END 
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[source_deal_header]') AND name = N'indx_source_deal_header_tm4')
BEGIN 
	CREATE NONCLUSTERED INDEX indx_source_deal_header_tm4 ON [dbo].[source_deal_header](source_system_book_id4)
END 
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[source_deal_pnl]') AND name = N'indx_source_deal_pnl_tm')
BEGIN 
	CREATE NONCLUSTERED INDEX indx_source_deal_pnl_tm ON [dbo].[source_deal_pnl](pnl_as_of_date)
END 
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[source_deal_pnl]') AND name = N'indx_source_deal_pnl_tm1')
BEGIN 
	CREATE NONCLUSTERED INDEX indx_source_deal_pnl_tm1 ON [dbo].[source_deal_pnl](source_deal_header_id) ON [PRIMARY ]
END 
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[source_deal_pnl_arch1]') AND name = N'indx_source_deal_pnl_arch1_tm') 
BEGIN 
	CREATE NONCLUSTERED INDEX indx_source_deal_pnl_arch1_tm ON [dbo].[source_deal_pnl_arch1](pnl_as_of_date)
END 
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[source_deal_pnl_arch1]') AND name = N'indx_source_deal_pnl_arch1_tm1')
BEGIN
	 CREATE NONCLUSTERED INDEX indx_source_deal_pnl_arch1_tm1 ON [dbo].[source_deal_pnl_arch1](source_deal_header_id) ON [PRIMARY ] 
END 
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[source_deal_pnl_arch2]') AND name = N'indx_source_deal_pnl_arch2_tm')
BEGIN 
	CREATE NONCLUSTERED INDEX indx_source_deal_pnl_arch2_tm ON [dbo].[source_deal_pnl_arch2](pnl_as_of_date)
END 
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[source_deal_pnl_arch2]') AND name = N'indx_source_deal_pnl_arch2_tm1')
BEGIN 
	CREATE NONCLUSTERED INDEX indx_source_deal_pnl_arch2_tm1 ON [dbo].[source_deal_pnl_arch2](source_deal_header_id)
END 
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[source_deal_pnl_arch3]') AND name = N'indx_source_deal_pnl_arch3_tm')
	AND OBJECT_ID(N'[dbo].[source_deal_pnl_arch3]') IS NOT NULL
BEGIN 
	CREATE NONCLUSTERED INDEX indx_source_deal_pnl_arch3_tm ON [dbo].[source_deal_pnl_arch3](pnl_as_of_date)
END 
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[source_deal_pnl_arch3]') AND name = N'indx_source_deal_pnl_arch3_tm1')
	AND OBJECT_ID(N'[dbo].[source_deal_pnl_arch3]') IS NOT NULL
BEGIN 
	CREATE NONCLUSTERED INDEX indx_source_deal_pnl_arch3_tm1 ON [dbo].[source_deal_pnl_arch3](source_deal_header_id)
END 
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[source_deal_pnl_eff]') AND name = N'indx_source_deal_pnl_eff_tm')
BEGIN 
	CREATE NONCLUSTERED INDEX indx_source_deal_pnl_eff_tm ON [dbo].[source_deal_pnl_eff](source_deal_header_id)
END 
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[source_deal_pnl_settlement]') AND name = N'indx_source_deal_pnl_settlement_tm')
BEGIN 
	CREATE NONCLUSTERED INDEX indx_source_deal_pnl_settlement_tm ON [dbo].[source_deal_pnl_settlement](source_deal_header_id) ON [PRIMARY ]
END 
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[user_defined_deal_fields]') AND name = N'indx_user_defined_deal_fields_tm') 
BEGIN 
	CREATE NONCLUSTERED INDEX indx_user_defined_deal_fields_tm ON [dbo].[user_defined_deal_fields](source_deal_header_id)
END 
GO

------------------------

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[report_measurement_values_expired]') AND name = N'ix_report_measurement_values_expired1')
BEGIN 
	CREATE NONCLUSTERED INDEX ix_report_measurement_values_expired1 ON [dbo].[report_measurement_values_expired](link_id)
END 
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[report_measurement_values_expired]') AND name = N'ix_report_measurement_values_expired2')
BEGIN 
	CREATE NONCLUSTERED INDEX ix_report_measurement_values_expired2 ON [dbo].[report_measurement_values_expired](link_deal_flag) ON [PRIMARY ]
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[report_measurement_values]') AND name = N'ix_report_measurement_values1') 
BEGIN 
	CREATE NONCLUSTERED INDEX ix_report_measurement_values1 ON [dbo].[report_measurement_values](link_id)
END 
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[report_measurement_values]') AND name = N'ix_report_measurement_values2')
BEGIN 
	CREATE NONCLUSTERED INDEX ix_report_measurement_values2 ON [dbo].[report_measurement_values](link_deal_flag)
END 
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[calcprocess_deals_expired]') AND name = N'ix_calcprocess_deals_expired1')
BEGIN 
	CREATE NONCLUSTERED INDEX ix_calcprocess_deals_expired1 ON [dbo].[calcprocess_deals_expired](link_id)
END 
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[calcprocess_deals_expired]') AND name = N'ix_calcprocess_deals_expired2')
BEGIN 
	CREATE NONCLUSTERED INDEX ix_calcprocess_deals_expired2 ON [dbo].[calcprocess_deals_expired](link_type)
END 
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[calcprocess_aoci_release]') AND name = N'ix_calcprocess_aoci_release1')
BEGIN 
	CREATE NONCLUSTERED INDEX ix_calcprocess_aoci_release1 ON [dbo].[calcprocess_aoci_release](link_id)
END 
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[calcprocess_aoci_release]') AND name = N'ix_calcprocess_aoci_release2')
BEGIN 
	CREATE NONCLUSTERED INDEX ix_calcprocess_aoci_release2 ON [dbo].[calcprocess_aoci_release](link_type)
END 
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[calcprocess_deals]') AND name = N'ix_calprocess_deals1')
BEGIN 
	CREATE NONCLUSTERED INDEX ix_calprocess_deals1 ON [dbo].[calcprocess_deals](link_id)
END 
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[calcprocess_deals]') AND name = N'ix_calprocess_deals2')
BEGIN 
	CREATE NONCLUSTERED INDEX ix_calprocess_deals2 ON [dbo].[calcprocess_deals](link_type)
END 
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[fas_link_detail]') AND name = N'ix_fas_link_detail1')
BEGIN 
	CREATE NONCLUSTERED INDEX ix_fas_link_detail1 ON [dbo].[fas_link_detail](link_id)
END 
GO

