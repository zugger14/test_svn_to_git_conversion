IF NOT EXISTS (
	SELECT 1
	FROM regression_module_header
	WHERE module_name = 'MTM'
)
BEGIN
	INSERT INTO regression_module_header (module_name, description, process_exec_order)
	SELECT 'MTM', 'Run regression testing to validate MTM calculation and reporting logic.', 10
END
ELSE
BEGIN
	UPDATE regression_module_header
	SET [description] = 'Run regression testing to validate MTM calculation and reporting logic.',
		process_exec_order = 10
	WHERE module_name = 'MTM'
END


IF NOT EXISTS (
	SELECT 1
	FROM regression_module_header
	WHERE module_name = 'Position'
)
BEGIN
	INSERT INTO regression_module_header (module_name, description, process_exec_order)
	SELECT 'Position', 'Run regression testing to validate Position calculation and reporting logic.', 20
END
ELSE
BEGIN
	UPDATE regression_module_header
	SET [description] = 'Run regression testing to validate Position calculation and reporting logic.',
		process_exec_order = 20
	WHERE module_name = 'Position'
END


IF NOT EXISTS (
	SELECT 1
	FROM regression_module_header
	WHERE module_name = 'Deal Settlement'
)
BEGIN
	INSERT INTO regression_module_header (module_name, description, process_exec_order)
	SELECT 'Deal Settlement', 'Deal Settlement Configuration for Regression.', 0
END
ELSE
BEGIN
	UPDATE regression_module_header
	SET [description] = 'Deal Settlement Configuration for Regression.',
		process_exec_order = 0
	WHERE module_name = 'Deal Settlement'
END


/************************************************* MTM *******************************************************/
DELETE rmd
-- SELECT rmd.*
FROM regression_module_header rmh
INNER JOIN regression_module_detail rmd ON rmd.regression_module_header_id = rmh.regression_module_header_id
WHERE module_name = 'MTM'


INSERT INTO regression_module_detail (regression_module_header_id, table_name, unique_columns, compare_columns, display_columns, data_order, regg_rpt_paramset_hash, regg_type, process_exec_order)
SELECT regression_module_header_id, 'source_deal_pnl_detail', '[source_deal_header_id],[term_start],[term_end],[Leg],[pnl_as_of_date],[pnl_source_value_id]', 
	'[und_pnl],[und_intrinsic_pnl],[und_extrinsic_pnl],[dis_pnl],[dis_intrinsic_pnl],[dis_extrinisic_pnl],[pnl_conversion_factor],[pnl_adjustment_value],[deal_volume],[accrued_interest],[price],[discount_rate],[discount_factor],[curve_uom_conv_factor],[curve_fx_conv_factor],[price_fx_conv_factor],[curve_value],[fixed_cost],[fixed_price],[formula_value],[price_adder],[price_multiplier],[strike_price],[und_pnl_set],[fixed_cost_fx_conv_factor],[formula_fx_conv_factor],[price_adder1_fx_conv_factor],[price_adder2_fx_conv_factor],[volume_multiplier],[volume_multiplier2],[price_adder2],[market_value],[contract_value],[dis_market_value],[dis_contract_value],[must_run_volume],[dispatch_volume],[must_run_market_value],[must_run_contract_value],[dispatch_market_value],[dispatch_contract_value],[und_pnl_deal],[und_pnl_inv]', '[buy_sell_flag]', '1,2,3,4',
	'616DA761_A5FD_476F_A8BC_A8D88FE3E566', 109702, 10
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_detail (regression_module_header_id, table_name, unique_columns, compare_columns, display_columns, data_order, regg_rpt_paramset_hash, regg_type, process_exec_order)
SELECT regression_module_header_id, 'source_deal_pnl', '[source_deal_header_id],[term_start],[term_end],[Leg],[pnl_as_of_date],[pnl_source_value_id]', 
	'[und_pnl],[und_intrinsic_pnl],[und_extrinsic_pnl],[dis_pnl],[dis_intrinsic_pnl],[dis_extrinisic_pnl],[pnl_conversion_factor],[pnl_adjustment_value],[deal_volume],[und_pnl_set],[market_value],[contract_value],[dis_market_value],[dis_contract_value],[must_run_volume],[dispatch_volume],[must_run_market_value],[must_run_contract_value],[dispatch_market_value],[dispatch_contract_value],[und_pnl_deal],[und_pnl_inv]', '[deal_cur_id],[inv_cur_id]', '1,2,3',
	'616DA761_A5FD_476F_A8BC_A8D88FE3E566', 109702, 10
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_detail (regression_module_header_id, table_name, unique_columns, compare_columns, display_columns, data_order, regg_rpt_paramset_hash, regg_type, process_exec_order)
SELECT regression_module_header_id, 'index_fees_breakdown', '[as_of_date],[contract_mkt_flag],[field_id],[leg],[source_deal_header_id],[term_end],[term_start]', 
	'[price],[total_price],[volume],[value],[contract_value],[value_deal],[value_inv]', '[deal_cur_id],[inv_cur_id]', '1,2,3',
	'616DA761_A5FD_476F_A8BC_A8D88FE3E566', 109702, 10
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_detail (regression_module_header_id, table_name, unique_columns, compare_columns, display_columns, data_order, regg_rpt_paramset_hash, regg_type, process_exec_order)
SELECT regression_module_header_id, 'source_deal_pnl_breakdown', '[as_of_date],[term_date],[hours],[is_dst],[period],[curve_as_of_date],[source_deal_detail_id]', 
	'[leg_mtm],[leg_set],[extrinsic_value],[accrued_interest],[volume],[price],[discount_rate],[discount_factor],[curve_uom_conv_factor],[curve_fx_conv_factor],[price_fx_conv_factor],[curve_value],[fixed_cost],[fixed_price],[formula_value],[price_adder],[price_multiplier],[strike_price],[fixed_cost_fx_conv_factor],[formula_fx_conv_factor],[price_adder1_fx_conv_factor],[price_adder2_fx_conv_factor],[volume_multiplier],[volume_multiplier2],[price_adder2],[market_value],[contract_value],[formula_rounding],[formula_conv_factor],[allocation_volume],[contract_price],[market_price],[deal_volume],[simple_formula_curve_value],[must_run_volume],[dispatch_volume],[must_run_market_value],[must_run_contract_value],[dispatch_market_value],[dispatch_contract_value],[leg_mtm_deal],[leg_mtm_inv],[leg_set_deal],[leg_set_inv],[extrinsic_value_deal],[price_deal],[curve_fx_conv_factor_deal],[price_fx_conv_factor_deal],[curve_value_deal],[fixed_cost_deal],[fixed_price_deal],[formula_value_deal],[price_adder_deal],[fixed_cost_fx_conv_factor_deal],[formula_fx_conv_factor_deal],[price_adder1_fx_conv_factor_deal],[price_adder2_fx_conv_factor_deal],[price_adder2_deal],[market_value_deal],[market_value_inv],[contract_value_deal],[contract_value_inv],[simple_formula_curve_value_deal],[simple_formula_curve_value_inv],[formula_conv_factor_deal],[formula_conv_factor_inv],[contract_price_deal],[market_price_deal],[price_inv],[extrinsic_value_inv],[contract_price_inv],[market_price_inv],[price_adder2_fx_conv_factor_inv],[price_adder1_fx_conv_factor_inv],[formula_fx_conv_factor_inv],[fixed_cost_fx_conv_factor_inv],[curve_fx_conv_factor_inv],[price_fx_conv_factor_inv],[formula_value_inv],[price_adder_inv],[price_adder2_inv],[fixed_cost_inv],[fixed_price_inv],[curve_value_inv]', '[source_deal_header_id],[leg]', '',
	'616DA761_A5FD_476F_A8BC_A8D88FE3E566', 109702, 10
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_detail (regression_module_header_id, table_name, unique_columns, compare_columns, display_columns, data_order, regg_rpt_paramset_hash, regg_type, process_exec_order)
SELECT regression_module_header_id, 'MTM Extract Regression Report', '[As of Date],[Deal ID],[Term Start],[Index]', 
	'[Deal Volume],[Forward Position],[Fixed Price],[Indexed On Price],[Price Adder],[Price Multiplier],[Deal Price],[Market Price],[Net Price],[Fixed Cost],[Contract Value],[Market Value],[MTM],[Discount Factor],[Discounted Contract Value],[Discounted Market Value],[Discounted Amount],[PV MTM]', '[Subsidiary],[Strategy],[Book],[Sub Book],[Report Group 1],[Report Group 2],[Report Group 3],[Report Group 4],[Trader],[Parent Counterparty],[Counterparty],[Internal Counterparty],[Contract],[Counterparty2],[Broker],[Commodity],[Buy/Sell],[Physical/Financial],[Deal Type],[FV Level],[Volume UOM],[Position UOM],[Indexed On],[Currency]', '',
	'3EC7A11A_FDAC_43F3_B00B_786110C00F27', 109701, 20
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_detail (regression_module_header_id, table_name, unique_columns, compare_columns, display_columns, data_order, regg_rpt_paramset_hash, regg_type, process_exec_order)
SELECT regression_module_header_id, 'MTM Fees Extract Regression Report', '[As of Date],[Deal ID],[Charge Type],[Term],[Index]', 
	'[Deal Volume],[Volume Multiplier],[Forward Position],[Price Adder],[Price Multiplier],[Deal Price],[Market Price],[Net Price],[Contract Value],[Market Value],[Fair Value],[MTM],[Discount Factor],[Discounted Contract Value],[Discounted Market Value],[Discounted Fair Value],[Discounted Amount],[PV MTM]', '[Trader],[Parent Counterparty],[Counterparty],[Internal Counterparty],[Contract],[Counterparty 2],[Broker],[Commodity],[Buy/Sell],[Physical/Financial],[Formula],[Indexed On],[Volume UOM],[Position UOM],[Indexed On Price],[Currency]', '',
	'8C22186F_8FC6_45B3_9937_18FADC28724B', 109701, 20
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_detail (regression_module_header_id, table_name, unique_columns, compare_columns, display_columns, data_order, regg_rpt_paramset_hash, regg_type, process_exec_order)
SELECT regression_module_header_id, 'PNL Attribution Regression Report', '[As of Date From],[As of Date To],[Deal ID],[Location],[Index],[Term Start]', 
	'[Begin MTM],[New MTM],[Price Changed MTM],[Delivered MTM],[Deleted MTM],[Modify MTM],[Total Change MTM],[End MTM]', '[Subsidiary],[Strategy],[Book],[Sub Book],[Book Identifier1],[Book Identifier2],[Book Identifier3],[Book Identifier4],[Trader],[Counterparty],[Contract],[Deal Type],[Commodity],[Currency]', '',
	'377492F8_E8EF_49AD_831B_7969E858C8F9', 109701, 20
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_detail (regression_module_header_id, table_name, unique_columns, compare_columns, display_columns, data_order, regg_rpt_paramset_hash, regg_type, process_exec_order)
SELECT regression_module_header_id, 'Options Greeks Regression Report', '[Deal ID],[Term],[Hour],[DST]', 
	'[Volume],[Options Premium],[Strike],[Expiry In Year],[Annual Int Rate],[Annual Vol],[Annual Imp Vol],[Current Price],[Premium],[Delta],[Delta2],[Gamma],[Gamma2],[Vega],[Vega2],[Theta],[Theta2],[Rho],[Rho2]', '[Subsidiary],[Strategy],[Book],[Expiration Status],[Counterparty],[Trader],[Curve Source],[Option Type],[Excercise Type],[Underlying Index],[UOM],[Currency],[Option Status]', '',
	'55440E24_1683_4CA1_AE08_455B2D2A12BD', 109701, 20
FROM regression_module_header
WHERE module_name = 'MTM'
/************************************************* MTM *******************************************************/


/************************************************* Position *******************************************************/
DELETE rmd
-- SELECT rmd.*
FROM regression_module_header rmh
INNER JOIN regression_module_detail rmd ON rmd.regression_module_header_id = rmh.regression_module_header_id
WHERE module_name = 'Position'


INSERT INTO regression_module_detail (regression_module_header_id, table_name, unique_columns, compare_columns, display_columns, data_order, regg_rpt_paramset_hash, regg_type, process_exec_order)
SELECT regression_module_header_id, 'report_hourly_position_profile', '[source_deal_header_id],[curve_id],[location_id],[term_start],[period]', 
	'[hr1],[hr2],[hr3],[hr4],[hr5],[hr6],[hr7],[hr8],[hr9],[hr10],[hr11],[hr12],[hr13],[hr14],[hr15],[hr16],[hr17],[hr18],[hr19],[hr20],[hr21],[hr22],[hr23],[hr24],[hr25]', '', '1,2,3,4',
	'9840CF17_F263_400E_9E35_E045FD0C4BD4', 109702, 10
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_detail (regression_module_header_id, table_name, unique_columns, compare_columns, display_columns, data_order, regg_rpt_paramset_hash, regg_type, process_exec_order)
SELECT regression_module_header_id, 'report_hourly_position_deal', '[source_deal_header_id],[curve_id],[location_id],[term_start],[period]', 
	'[hr1],[hr2],[hr3],[hr4],[hr5],[hr6],[hr7],[hr8],[hr9],[hr10],[hr11],[hr12],[hr13],[hr14],[hr15],[hr16],[hr17],[hr18],[hr19],[hr20],[hr21],[hr22],[hr23],[hr24],[hr25]', '', '1,2,3',
	'9840CF17_F263_400E_9E35_E045FD0C4BD4', 109702, 10
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_detail (regression_module_header_id, table_name, unique_columns, compare_columns, display_columns, data_order, regg_rpt_paramset_hash, regg_type, process_exec_order)
SELECT regression_module_header_id, 'report_hourly_position_breakdown', '[source_deal_header_id],[curve_id],[location_id],[term_start],[deal_date]', 
	'[calc_volume]', '', '1,2,3',
	'9840CF17_F263_400E_9E35_E045FD0C4BD4', 109702, 10
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_detail (regression_module_header_id, table_name, unique_columns, compare_columns, display_columns, data_order, regg_rpt_paramset_hash, regg_type, process_exec_order)
SELECT regression_module_header_id, 'deal_position_break_down', '[source_deal_detail_id],[curve_id],[del_term_start],[fin_term_start],[fin_term_end]', 
	'[strip_from],[lag],[strip_to],[multiplier],[del_vol_multiplier],[formula],[simple_for_adder],[simple_for_multiplier]', '', '',
	'9840CF17_F263_400E_9E35_E045FD0C4BD4', 109702, 10
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_detail (regression_module_header_id, table_name, unique_columns, compare_columns, display_columns, data_order, regg_rpt_paramset_hash, regg_type, process_exec_order)
SELECT regression_module_header_id, 'report_hourly_position_financial', '[source_deal_header_id],[curve_id],[location_id],[term_start],[period]', 
	'[hr1],[hr2],[hr3],[hr4],[hr5],[hr6],[hr7],[hr8],[hr9],[hr10],[hr11],[hr12],[hr13],[hr14],[hr15],[hr16],[hr17],[hr18],[hr19],[hr20],[hr21],[hr22],[hr23],[hr24],[hr25]', '', '',
	'9840CF17_F263_400E_9E35_E045FD0C4BD4', 109702, 10
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_detail (regression_module_header_id, table_name, unique_columns, compare_columns, display_columns, data_order, regg_rpt_paramset_hash, regg_type, process_exec_order)
SELECT regression_module_header_id, 'Hourly Position Extract Regression Report', '[Deal ID],[Location],[Index],[Term Year Month],[Term Day],[Hour],[DST]', 
	'[Deal Volume]', '', '',
	'9A590408_EDC0_4435_A017_E42B86C10584', 109701, 20
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_detail (regression_module_header_id, table_name, unique_columns, compare_columns, display_columns, data_order, regg_rpt_paramset_hash, regg_type, process_exec_order)
SELECT regression_module_header_id, 'Daily Position Extract Regression Report', '[Deal ID],[Index],[Physical/Financial],[Term Day],[Term Year Month],[Location/Index]', 
	'[Deal Volume]', '', '',
	'09D2DB34_79A9_461B_B1EF_BA6E8F928005', 109701, 20
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_detail (regression_module_header_id, table_name, unique_columns, compare_columns, display_columns, data_order, regg_rpt_paramset_hash, regg_type, process_exec_order)
SELECT regression_module_header_id, 'Monthly Position Extract Regression Report', '[Deal ID],[Index],[Location],[Term Year Month]', 
	'[Deal Volume]', '', '',
	'F1342454_B2DF_40B1_8FD6_CF881A417EE9', 109701, 20
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_detail (regression_module_header_id, table_name, unique_columns, compare_columns, display_columns, data_order, regg_rpt_paramset_hash, regg_type, process_exec_order)
SELECT regression_module_header_id, ' Power ToU Position Regression Report', '[As of Date],[Block Name],[Location],[Term Year Month],[Position UOM]', 
	'[Position]', '', '',
	'79D490B2_1DC2_412E_891C_A6676A15C613', 109701, 20
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_detail (regression_module_header_id, table_name, unique_columns, compare_columns, display_columns, data_order, regg_rpt_paramset_hash, regg_type, process_exec_order)
SELECT regression_module_header_id, 'Delta Position Report by Deal Regression Report', '[As of Date],[Deal ID],[Index],[Location],[Term Year Month]', 
	'[Delta],[Position]', '', '',
	'07FA8963_F161_44C4_B745_6E3FAA7953C3', 109701, 20
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_detail (regression_module_header_id, table_name, unique_columns, compare_columns, display_columns, data_order, regg_rpt_paramset_hash, regg_type, process_exec_order)
SELECT regression_module_header_id, 'Position Attribution Regression Report', '[Deal ID],[Index],[Location],[Term Start],[As of Date From],[As of Date To]', 
	'[Begin Vol],[New Vol],[Delivered Vol],[Deleted Vol],[Modify Vol],[Total Change Vol],[End Vol]', '', '',
	'F27076BE_0F80_4DBF_A2AF_C684B1DADE1F', 109701, 20
FROM regression_module_header
WHERE module_name = 'Position'
/************************************************* Position *******************************************************/


/************************************************* Deal Settlement *******************************************************/
DELETE rmd
-- SELECT rmd.*
FROM regression_module_header rmh
INNER JOIN regression_module_detail rmd ON rmd.regression_module_header_id = rmh.regression_module_header_id
WHERE module_name = 'Deal Settlement'


INSERT INTO regression_module_detail (regression_module_header_id, table_name, unique_columns, compare_columns, display_columns, data_order, regg_rpt_paramset_hash, regg_type, process_exec_order)
SELECT regression_module_header_id, 'source_deal_settlement', '[as_of_date],[source_deal_header_id],[term_start],[leg]', 
	'[Volume],[net_price],[settlement_amount],[float_price],[Deal_price],[settlement_amount_deal],[settlement_amount_inv],[fin_volume]', '', '',
	'976B23C2_2163_4649_AB9B_46F4B579119C', 109702, 10
FROM regression_module_header
WHERE module_name = 'Deal Settlement'

INSERT INTO regression_module_detail (regression_module_header_id, table_name, unique_columns, compare_columns, display_columns, data_order, regg_rpt_paramset_hash, regg_type, process_exec_order)
SELECT regression_module_header_id, 'source_deal_settlement_breakdown', '[as_of_date],[term_date],[hours],[is_dst],[period],[curve_as_of_date],[source_deal_detail_id]', 
	'[leg_mtm],[leg_set],[extrinsic_value],[accrued_interest],[volume],[price],[discount_factor],[curve_uom_conv_factor],[curve_fx_conv_factor],[price_fx_conv_factor],[curve_value],[fixed_cost],[fixed_price],[formula_value],[price_adder],[price_multiplier],[strike_price],[fixed_cost_fx_conv_factor],[formula_fx_conv_factor],[price_adder1_fx_conv_factor],[price_adder2_fx_conv_factor],[volume_multiplier],[volume_multiplier2],[price_adder2],[market_value],[contract_value],[formula_rounding],[formula_conv_factor],[allocation_volume],[contract_price],[market_price],[deal_volume],[simple_formula_curve_value]', '[source_deal_header_id],[leg]', '',
	'976B23C2_2163_4649_AB9B_46F4B579119C', 109702, 10
FROM regression_module_header
WHERE module_name = 'Deal Settlement'

INSERT INTO regression_module_detail (regression_module_header_id, table_name, unique_columns, compare_columns, display_columns, data_order, regg_rpt_paramset_hash, regg_type, process_exec_order)
SELECT regression_module_header_id, 'Deal Settlement Extract Regression Report', '[Charge Type],[Deal ID],[Term Start],[Leg]', 
	'[Amount],[Deal Price],[Deal Volume],[Fixed Price],[Float Price],[Market Price],[Market Value],[Net Price],[Price Adder],[Total Volume],[Contract Value]', '[Commodity],[Contract],[Counterparty],[Currency],[Deal Type],[Physical/Financial],[Volume UOM]', '',
	'74D4A34C_5EE5_41D8_9323_A47128F0DA70', 109701, 20
FROM regression_module_header
WHERE module_name = 'Deal Settlement'

INSERT INTO regression_module_detail (regression_module_header_id, table_name, unique_columns, compare_columns, display_columns, data_order, regg_rpt_paramset_hash, regg_type, process_exec_order)
SELECT regression_module_header_id, ' Realized Unrealized Detail Regression Report', '[As of Date],[Deal ID],[Actual/Forward],[Term Start],[Location],[Index],[Charge Type]', 
	'[Amount],[Contract Value],[Deal Price],[Deal Volume],[Fixed Cost],[Fixed Price],[Formula Price],[Market Price],[Market Value],[Net Price],[Price Adder],[Price Multiplier],[Total Volume]', '[Currency],[Position UoM],[Volume UOM]', '',
	'9266AB50_BD94_492B_A9A7_14F25B891E41', 109701, 20
FROM regression_module_header
WHERE module_name = 'Deal Settlement'

INSERT INTO regression_module_detail (regression_module_header_id, table_name, unique_columns, compare_columns, display_columns, data_order, regg_rpt_paramset_hash, regg_type, process_exec_order)
SELECT regression_module_header_id, 'index_fees_breakdown_settlement', '[as_of_date],[source_deal_header_id],[leg],[term_start],[field_id],[set_type],[contract_mkt_flag],[shipment_id],[ticket_detail_id]', 
	'[price],[total_price],[volume],[value],[contract_value],[value_deal],[value_inv]', '', '',
	'976B23C2_2163_4649_AB9B_46F4B579119C', 109702, 10
FROM regression_module_header
WHERE module_name = 'Deal Settlement'
/************************************************* Deal Settlement *******************************************************/



/************************************************* Module Dependencies *******************************************************/
-- Clean First
DELETE FROM regression_module_dependencies

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'curve_correlation'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'curve_volatility'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'deal_detail_formula_udf'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'deal_detail_formula_udf'
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'deal_position_break_down'
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'deal_price_custom_event'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'deal_price_deemed'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'deal_price_deemed'
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'deal_price_std_event'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'deal_price_type dpt'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'deal_price_type'
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'delta_report_hourly_position'
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'delta_report_hourly_position_breakdown'
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'delta_report_hourly_position_financial'
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'FNAAverageCurveValue'
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'FNAAverageMonthlyCurveValue'
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'FNAAvg'
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'FNABatchProcess'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'FNACalcOptionsPrem'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'FNAConvertTimezone'
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'FNACurve'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'FNACurve'
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'FNACurve15'
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'FNACurveD'
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'FNACurveH'
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'FNACurveIDOfSimpleFormula'
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'FNACurveM'
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'FNACurveQ'
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'FNACurveY'
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'FNADateFormat'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'FNADateTimeFormat'
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'FNADBUser'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'FNADBUser'
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'FNAFindDateDifference'
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'FNAFNACurveNames'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'FNAGetBLPricingTerm'
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'FNAGetBusinessDay'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'FNAGetContractMonth'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'FNAGetContractMonth'
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'FNAGetGenericDate'
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'FNAGetLOCALTime'
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'FNAGetNewID'
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'FNAGetProcessTableName'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'FNAGetSplitPart'
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'FNAGetSQLStandardDate'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'FNAGetSQLStandardDate'
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'FNAGetTermEndDate'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'FNAGetTermEndDate'
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'FNAGetTermStartDate'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'FNAGetTermStartDate'
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'FNAGetUOMConvertValue'
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'FNAGetUOMConvertValueWithFactor'
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'FNAHyperLink'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'FNAHyperLinkText'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'FNAHyperLinkText'
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'FNAInvoiceDueDate'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'FNALagcurve'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'FNALagCurve'
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'FNAMax'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'FNAMin'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'FNAPartialAvgCurve'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'FNAPmt'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'FNAProcessTableName'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'FNAProcessTableName'
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'FNARCLagcurve'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'FNARelativeExpirationDate'
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'FNARFieldValue'
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'FNARUDFValue'
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'FNASplit'
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'FNAStripAnchor'
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'FNATermBreakdown'
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'FNATrmHyperlink'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'FNAUDFValue'
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'FNAUOMConv'

FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'FNAUserDateTimeFormat'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'FNAWACOGPrice'
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'formula_function_mapping'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'holiday_block'
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'holiday_group'
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'hourly_block'
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'index_fees_breakdown'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'index_fees_breakdown_settlement'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'location_price_index'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'location_price_index'
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'match_group_detail'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'match_group_header'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'meter_data'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'meter_id'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'mv90_data'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'mv90_data_hour'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'mv90_data_mins'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'pnl_component_price_detail'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'process_generation_unit_cost'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'recorder_properties'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'Report_hourly_position_breakdown'
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'Report_hourly_position_deal'
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'Report_hourly_position_financial'
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'Report_hourly_position_fixed'
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'Report_hourly_position_profile'
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'source_deal_delta_value'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'Source_deal_detail'
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'Source_deal_detail_hour'
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'Source_deal_header'
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'Source_deal_header_template'
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'source_deal_pnl'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'source_deal_pnl_breakdown'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'Source_deal_pnl_detail'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'source_deal_pnl_detail_options'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'source_deal_pnl_detail_options_WhatIf'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'source_deal_pnl_rec'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'source_deal_pnl_tou'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'Source_deal_settlement'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'source_deal_settlement_breakdown'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'Source_deal_settlement_tou'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'source_minor_location'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'source_option_greeks_detail'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'source_price_curve'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'source_price_curve_def'
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'spa_calc_deal_uom_conversion'
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'spa_Calc_Discount_Factor'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'spa_calc_mtm_job'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'spa_calc_options_prem_detail'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'spa_calculate_formula'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'spa_calculate_formula'
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'spa_create_fx_exposure_report'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'spa_create_xml_document'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'spa_deal_position_breakdown'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'spa_deal_position_breakdown'
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'spa_derive_curve_value'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'spa_ErrorHandler'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'spa_ErrorHandler'
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'spa_get_mtm_test_run_log'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'spa_maintain_transaction_job'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'spa_maintain_transaction_job'
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'spa_message_board'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'spa_message_board'
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'spa_parse_function'
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'spa_register_event'
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'spa_run_sp_as_job'
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'spa_update_deal_total_volume'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'spa_update_deal_total_volume'
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'ticket_detail'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'ticket_match'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'transportation_rate_schedule'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'user_defined_deal_detail_fields'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'user_defined_deal_fields'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'user_defined_deal_fields_template'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'user_defined_fields_template'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'variable_charge'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'vwDealTimezone'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'vwDealTimezone'
FROM regression_module_header
WHERE module_name = 'Position'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'vwDealTimezoneContract'
FROM regression_module_header
WHERE module_name = 'MTM'

INSERT INTO regression_module_dependencies (regression_module_header_id, [object_name])
SELECT regression_module_header_id, 'vwDealTimezoneContract'
FROM regression_module_header
WHERE module_name = 'Position'
/************************************************* Module Dependencies *******************************************************/

GO