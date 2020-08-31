
IF NOT EXISTS(SELECT 1 FROM ixp_tables where ixp_tables_name = 'ixp_hedge_relationship_type')
BEGIN
		INSERT INTO ixp_tables(ixp_tables_name,ixp_tables_description,import_export_flag)
		VALUES('ixp_hedge_relationship_type','ixp_hedge_relationship_type', 'i')
END
ELSE 
	PRINT 'ixp tables already exists'

DECLARE  @ixp_table_id INT 
SELECT @ixp_table_id  = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_hedge_relationship_type'
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'subsidiary')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype,is_major)
	SELECT @ixp_table_id,'subsidiary','VARCHAR(600)',0
END
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'strategy')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype,is_major)
	SELECT @ixp_table_id,'strategy','VARCHAR(600)',0
END
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'book')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype,is_major)
	SELECT @ixp_table_id,'book','VARCHAR(600)',0
END
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'eff_test_name')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype,is_major)
	SELECT @ixp_table_id,'eff_test_name','VARCHAR(600)',0
END
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'eff_test_profile_id')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype,is_major)
	SELECT @ixp_table_id,'eff_test_profile_id','VARCHAR(600)',0
END
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'eff_test_description')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype,is_major)
	SELECT @ixp_table_id,'eff_test_description','VARCHAR(600)',0
END
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'effective_start_date')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype,is_major)
	SELECT @ixp_table_id,'effective_start_date','VARCHAR(600)',0
END
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'effective_end_date')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype,is_major)
	SELECT @ixp_table_id,'effective_end_date','VARCHAR(600)',0
END
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'profile_approved_by')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype,is_major)
	SELECT @ixp_table_id,'profile_approved_by','VARCHAR(600)',0
END
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'matching_type')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype,is_major)
	SELECT @ixp_table_id,'matching_type','VARCHAR(600)',0
END
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'hedge_doc_temp')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype,is_major)
	SELECT @ixp_table_id,'hedge_doc_temp','VARCHAR(600)',0
END
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'profile_approved')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype,is_major)
	SELECT @ixp_table_id,'profile_approved','VARCHAR(600)',0
END
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'profile_active')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype,is_major)
	SELECT @ixp_table_id,'profile_active','VARCHAR(600)',0
END
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'externalization')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype,is_major)
	SELECT @ixp_table_id,'externalization','VARCHAR(600)',0
END
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'init_eff_test_approach_value_id')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype,is_major)
	SELECT @ixp_table_id,'init_eff_test_approach_value_id','VARCHAR(600)',0
END
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'init_assmt_curve_type_value_id')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype,is_major)
	SELECT @ixp_table_id,'init_assmt_curve_type_value_id','VARCHAR(600)',0
END
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'init_curve_source_value_id')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype,is_major)
	SELECT @ixp_table_id,'init_curve_source_value_id','VARCHAR(600)',0
END
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'init_number_of_curve_points')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype,is_major)
	SELECT @ixp_table_id,'init_number_of_curve_points','VARCHAR(600)',0
END
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'on_eff_test_approach_value_id')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype,is_major)
	SELECT @ixp_table_id,'on_eff_test_approach_value_id','VARCHAR(600)',0
END
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'on_assmt_curve_type_value_id')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype,is_major)
	SELECT @ixp_table_id,'on_assmt_curve_type_value_id','VARCHAR(600)',0
END
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'on_curve_source_value_id')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype,is_major)
	SELECT @ixp_table_id,'on_curve_source_value_id','VARCHAR(600)',0
END
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'on_number_of_curve_points')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype,is_major)
	SELECT @ixp_table_id,'on_number_of_curve_points','VARCHAR(600)',0
END
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'mstm_eff_test_type_id')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype,is_major)
	SELECT @ixp_table_id,'mstm_eff_test_type_id','VARCHAR(600)',0
END
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'convert_currency_value_id')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype,is_major)
	SELECT @ixp_table_id,'convert_currency_value_id','VARCHAR(600)',0
END
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'convert_uom_value_id')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype,is_major)
	SELECT @ixp_table_id,'convert_uom_value_id','VARCHAR(600)',0
END
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'hedge_test_price_option_value_id')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype,is_major)
	SELECT @ixp_table_id,'hedge_test_price_option_value_id','VARCHAR(600)',0
END
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'item_test_price_option_value_id')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype,is_major)
	SELECT @ixp_table_id,'item_test_price_option_value_id','VARCHAR(600)',0
END
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'inherit_assmt_eff_test_profile_id')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype,is_major)
	SELECT @ixp_table_id,'inherit_assmt_eff_test_profile_id','VARCHAR(600)',0
END
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'force_intercept_zero')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype,is_major)
	SELECT @ixp_table_id,'force_intercept_zero','VARCHAR(600)',0
END
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'use_hedge_as_depend_var')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype,is_major)
	SELECT @ixp_table_id,'use_hedge_as_depend_var','VARCHAR(600)',0
END
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'individual_link_calc')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype,is_major)
	SELECT @ixp_table_id,'individual_link_calc','VARCHAR(600)',0
END
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'ineffectiveness_in_hedge')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype,is_major)
	SELECT @ixp_table_id,'ineffectiveness_in_hedge','VARCHAR(600)',0
END
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'hedge_fixed_price_value_id')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype,is_major)
	SELECT @ixp_table_id,'hedge_fixed_price_value_id','VARCHAR(600)',0
END
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'hedge_to_item_conv_factor')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype,is_major)
	SELECT @ixp_table_id,'hedge_to_item_conv_factor','VARCHAR(600)',0
END
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'item_pricing_value_id')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype,is_major)
	SELECT @ixp_table_id,'item_pricing_value_id','VARCHAR(600)',0
END
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'item_counterparty_id')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype,is_major)
	SELECT @ixp_table_id,'item_counterparty_id','VARCHAR(600)',0
END
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'item_trader_id')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype,is_major)
	SELECT @ixp_table_id,'item_trader_id','VARCHAR(600)',0
END
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'gen_curve_source_value_id')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype,is_major)
	SELECT @ixp_table_id,'gen_curve_source_value_id','VARCHAR(600)',0
END
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'documentation_requirement')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype,is_major)
	SELECT @ixp_table_id,'documentation_requirement','VARCHAR(600)',0
END
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'profile_for_value_id')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype,is_major)
	SELECT @ixp_table_id,'profile_for_value_id','VARCHAR(600)',0
END
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'risk_mgmt_strategy')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype,is_major)
	SELECT @ixp_table_id,'risk_mgmt_strategy','VARCHAR(600)',0
END
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'risk_mgmt_policy')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype,is_major)
	SELECT @ixp_table_id,'risk_mgmt_policy','VARCHAR(600)',0
END
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'formal_documentation')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype,is_major)
	SELECT @ixp_table_id,'formal_documentation','VARCHAR(600)',0
END
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'profile_approved_date')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype,is_major)
	SELECT @ixp_table_id,'profile_approved_date','VARCHAR(600)',0
END
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'effectiveness_testing_not_required')
BEGIN
	INSERT INTO ixp_columns(ixp_table_id,ixp_columns_name,column_datatype,is_major)
	SELECT @ixp_table_id,'effectiveness_testing_not_required','VARCHAR(600)',0
END