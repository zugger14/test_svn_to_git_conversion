IF OBJECT_ID(N'[dbo].[spa_get_assmt_rel_type_header]', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_get_assmt_rel_type_header]
GO 

-- EXEC spa_get_assmt_rel_type_header 3, 163, -1
-- EXEC spa_get_assmt_rel_type_header 2, -1, -229
-- EXEC spa_get_assmt_rel_type_header 3, 1, -1


--EXEC spa_get_assmt_rel_type_header 2, 5, 3

-- @calc_level (1 reltype, 2 link, 3 adhoc reltype, 4 adhoc link
-- @link_id is  used for 2 and 4
-- @eff_test_profile_id is used for 1 and 3
CREATE PROCEDURE [dbo].[spa_get_assmt_rel_type_header] 	
	@calc_level int,
	@eff_test_profile_id int,
	@link_id int
						
AS

----UNCOMMENT THE FOLLOWING TO TEST
-- DECLARE @calc_level int
-- DECLARE @link_id int
-- DECLARE @eff_test_profile_id int
-- SET @calc_level = 2
-- SET @eff_test_profile_id = 4
-- SET @link_id = 3
----UNCOMMENT THE ABOVE TO TEST

IF @calc_level = 1 
BEGIN
	SELECT 	eff_test_profile_id, 
		fas_book_id, 
		eff_test_name, 
		eff_test_description, 
		inherit_assmt_eff_test_profile_id, 
		init_eff_test_approach_value_id, 
	        init_assmt_curve_type_value_id, 
		init_curve_source_value_id, 
		init_number_of_curve_points, 
		on_eff_test_approach_value_id, 
	        on_assmt_curve_type_value_id, 
		on_curve_source_value_id, 
		on_number_of_curve_points, 
		force_intercept_zero, 
		profile_for_value_id, 
	        convert_currency_value_id, 
		convert_uom_value_id, 
		effective_start_date, 
		effective_end_date, 
		risk_mgmt_strategy, 
		risk_mgmt_policy, 
	        formal_documentation, 
		profile_approved, 
		profile_active, 
		profile_approved_by, 
		profile_approved_date, 
		hedge_to_item_conv_factor, 
	        item_pricing_value_id, 
		hedge_test_price_option_value_id, 
		item_test_price_option_value_id, 
		hedge_fixed_price_value_id, 
		use_hedge_as_depend_var,	
		item_counterparty_id, 
		item_trader_id, 
		gen_curve_source_value_id, 
		individual_link_calc,
		reType.create_user,
		reType.create_ts,
		reType.update_user,
		reType.update_ts, 
		cur.currency_name AS currency_name,
		uom.uom_name AS uom_name 
	FROM 	fas_eff_hedge_rel_type reType LEFT OUTER JOIN 
		source_currency cur ON reType.convert_currency_value_id = cur.source_currency_id LEFT OUTER JOIN 
		source_uom uom ON reType.convert_uom_value_id = uom.source_uom_id 
	WHERE   eff_test_profile_id = @eff_test_profile_id

END
ELSE IF @calc_level = 3
BEGIN
	SELECT 	eff_test_profile_id, 
		fas_book_id, 
		eff_test_name, 
		eff_test_description, 
		NULL inherit_assmt_eff_test_profile_id, 
		on_eff_test_approach_value_id AS init_eff_test_approach_value_id, 
	        on_assmt_curve_type_value_id AS init_assmt_curve_type_value_id, 
		on_curve_source_value_id AS init_curve_source_value_id, 
		on_number_of_curve_points AS init_number_of_curve_points, 
		on_eff_test_approach_value_id, 
	        on_assmt_curve_type_value_id, 
		on_curve_source_value_id, 
		on_number_of_curve_points, 
		force_intercept_zero, 		
		CASE WHEN (rel_type = 'l' and rel_id is not null) then rel_id else -1 end  profile_for_value_id, 
	        convert_currency_value_id, 
		convert_uom_value_id, 
		'1990-01-01' effective_start_date, 
		'1990-01-01'effective_end_date, 
		'y' risk_mgmt_strategy, 
		'y' risk_mgmt_policy, 
	        'y' formal_documentation, 
		'y' profile_approved, 
		'y' profile_active, 
		'dbo' profile_approved_by, 
		'1990-01-01' profile_approved_date, 
		1 hedge_to_item_conv_factor, 
	        425 item_pricing_value_id, 
		hedge_test_price_option_value_id, 
		item_test_price_option_value_id, 
		425 hedge_fixed_price_value_id, 
		use_hedge_as_depend_var,	
		NULL item_counterparty_id, 
		NULL item_trader_id, 
		NULL gen_curve_source_value_id, 
		'y' individual_link_calc,
		reType.create_user,
		reType.create_ts,
		reType.update_user,
		reType.update_ts, 
		cur.currency_name AS currency_name,
		uom.uom_name AS uom_name 
	FROM 	fas_eff_hedge_rel_type_whatif reType LEFT OUTER JOIN 
		source_currency cur ON reType.convert_currency_value_id = cur.source_currency_id LEFT OUTER JOIN 
		source_uom uom ON reType.convert_uom_value_id = uom.source_uom_id 
	WHERE   eff_test_profile_id = @eff_test_profile_id

END
ELSE IF @calc_level = 2
BEGIN
	SELECT 	reType.eff_test_profile_id, 
		flh.fas_book_id, 
		eff_test_name, 
		eff_test_description, 
		inherit_assmt_eff_test_profile_id, 
		init_eff_test_approach_value_id, 
	    init_assmt_curve_type_value_id, 
		init_curve_source_value_id, 
		init_number_of_curve_points, 
		on_eff_test_approach_value_id, 
	    on_assmt_curve_type_value_id, 
		on_curve_source_value_id, 
		on_number_of_curve_points, 
		force_intercept_zero, 
		profile_for_value_id, 
	    convert_currency_value_id, 
		convert_uom_value_id, 
		effective_start_date, 
		effective_end_date, 
		risk_mgmt_strategy, 
		risk_mgmt_policy, 
	    formal_documentation, 
		profile_approved, 
		profile_active, 
		profile_approved_by, 
		profile_approved_date, 
		hedge_to_item_conv_factor, 
	        item_pricing_value_id, 
		hedge_test_price_option_value_id, 
		item_test_price_option_value_id, 
		hedge_fixed_price_value_id, 
		use_hedge_as_depend_var,	
		item_counterparty_id, 
		item_trader_id, 
		gen_curve_source_value_id, 
		individual_link_calc,
		reType.create_user,
		reType.create_ts,
		reType.update_user,
		reType.update_ts, 
		cur.currency_name AS currency_name,
		uom.uom_name AS uom_name 
	FROM 
(
select link_id, fas_book_id, eff_test_profile_id from fas_link_header where link_id = @link_id
--UNION
--select -1 * fs.fas_strategy_id,fs.no_links_fas_eff_test_profile_id
--from portfolio_hierarchy book INNER JOIN
--portfolio_hierarchy strat ON strat.entity_id = book.parent_entity_id  INNER JOIN 
--portfolio_hierarchy sub ON sub.entity_id = strat.parent_entity_id  INNER JOIN 
--fas_strategy fs ON fs.fas_strategy_id = strat.entity_id INNER JOIN
--fas_eff_hedge_rel_type rtype ON rtype.eff_test_profile_id = fs.no_links_fas_eff_test_profile_id
--where -1 * fs.fas_strategy_id = @link_id
union
select -1 * fb.fas_book_id, fb.fas_book_id, coalesce(fs.no_links_fas_eff_test_profile_id, fb.no_links_fas_eff_test_profile_id) no_links_fas_eff_test_profile_id
from portfolio_hierarchy book INNER JOIN
portfolio_hierarchy strat ON strat.entity_id = book.parent_entity_id  INNER JOIN 
portfolio_hierarchy sub ON sub.entity_id = strat.parent_entity_id  INNER JOIN 
fas_strategy fs ON fs.fas_strategy_id = strat.entity_id INNER JOIN
fas_books fb ON fb.fas_book_id = book.entity_id  INNER JOIN
fas_eff_hedge_rel_type rtype ON rtype.eff_test_profile_id = coalesce(fs.no_links_fas_eff_test_profile_id, fb.no_links_fas_eff_test_profile_id)
where -1 * fb.fas_book_id = @link_id
)
 flh INNER JOIN
		fas_eff_hedge_rel_type reType ON flh.eff_test_profile_id = reType.eff_test_profile_id LEFT OUTER JOIN 
		source_currency cur ON reType.convert_currency_value_id = cur.source_currency_id LEFT OUTER JOIN 
		source_uom uom ON reType.convert_uom_value_id = uom.source_uom_id 
	WHERE   flh.link_id = @link_id
END





