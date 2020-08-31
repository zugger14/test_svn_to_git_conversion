IF OBJECT_ID(N'spa_effhedgereltype', N'P') IS NOT NULL
	DROP PROCEDURE dbo.spa_effhedgereltype
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**
This proc will be used to select, insert, update and delete hedge relationship record
from the fas_eff_hedge_rel_type table
For insert and update, pass all the parameters defined for this stored procedure
For delete, pass the flag and the fas_book_id
Check whether approved and inactive in the GUI are filter criteria or not
Parameters: 
	@flag								: select = 's' mutliple, 'a' for select only one type, 
											'c' for copy, for Insert='i'. Update='u' and Delete='d'
	@fas_book_id						: Numeric Identifier for FAS Book.
	@approved							: Specify whether the link is approved or not.
	@inactive							: Specify whether the link is active or not.
	@eff_test_profile_id				: Numeric Identifier of Hedging Relationship Type.
	@eff_test_name						: Name of the Hedging Relationship Type.
	@eff_test_description				: Description of the Hedging Relationship Type.
	@inherit_assmt_eff_test_profile_id	: Numeric Identifier of hedging relationship type from which the assessment value is inherited.
	@init_eff_test_approach_value_id	: Numeric Identifier of assessment approach of inception assessment.
	@init_assmt_curve_type_value_id		: Numeric Identifier of curve type of inception assessment.
	@init_curve_source_value_id			: Numeric Identifier of the source of Price Curve in inception assessment.
	@init_number_of_curve_points		: The number of price points in inception assessment.
	@on_eff_test_approach_value_id		: Numeric Identifier of assessment approach of ongoing assessment.
	@on_assmt_curve_type_value_id		: Numeric Identifier of curve type of ongoing assessment.
	@on_curve_source_value_id			: Numeric Identifier of the source of Price Curve in ongoing assessment.
	@on_number_of_curve_points			: The number of price points in ongoing assessment.
	@force_intercept_zero				: Specify whether to force the interception to zero or not.
	@profile_for_value_id				: TBD.
	@convert_currency_value_id			: Numeric Identifier of the Currency to which the price is to be converted.
	@convert_uom_value_id				: Numeric Identifier of the UOM to which the uom is to be converted.
	@effective_start_date				: Specific date used as Start Date.
	@effective_end_date					: Specific date used as End Date.
	@risk_mgmt_strategy					: Specify whether the profile is consistent with risk management strategy.
	@risk_mgmt_policy					: Specify whether the profile is governed by existing risk management policies
	@formal_documentation				: Specify whether the profile is governed by frormal existing hedge documentation.
	@profile_approved					: Specify whether the profile is approved or not.
	@profile_approved_by				: Specify the name who has approved the profile.
	@profile_approved_date				: Specify the date when the profile was approved.
	@hedge_to_item_conv_factor			: Conversion Factor for Hedge to Item volume conversion.
	@item_pricing_value_id				: Numeric Identifier of the hedge item pricing type.
	@hedge_test_price_option_value_id	: Numeric Identifier of Hedge assessment pricing option.
	@item_test_price_option_value_id	: Numeric Identifier of Itemedge assessment pricing option.
	@hedge_fixed_price_value_id			: Numeric Identifier of the fixed price of Hedge Total.
	@use_hedge_as_depend_var			: Specify whether to use Hedge as dependent variable or not.
	@item_counterparty_id				: Numeric Identifier of Counterparty in Item.
	@item_trader_id						: Numeric Identifier of Trader in Item.
	@gen_curve_source_value_id			: Numeric Identifier of the source of price curve.
	@individual_link_calc				: Specify whether to calculate at relationship level or not.
	@ineffectiveness_in_hedge			: Specify whether to exclude spot forward difference or not.
	@mstm_eff_test_type_id				: Numeric Identifier of Measurement Effective Test Approach.
	@matching_type						: Specify the type of the match a (Auto Matching), h (Hypothetical Derivative), b (Both) or n (None).
	@is_externalization					: This parameter is currently not in use.
	@form_xml							: Data related to profile in form of XML.
	@subsidiary_id						: Numeric Identifier of Subsidiary.
	@strategy_id						: Numeric Identifier of Strategy.
	@book_id							: Numeric Identifier of Book.
	@effectiveness_testing_not_required	: Specify whether the Test is required or not.

*/
CREATE PROC [dbo].[spa_effhedgereltype]
	@flag								CHAR(1),
	@fas_book_id						INT = NULL,
	@approved							CHAR(1) = NULL,
	@inactive							CHAR(1) = NULL,
	@eff_test_profile_id				VARCHAR(500) = NULL, 
	@eff_test_name						VARCHAR(100) = NULL,
	@eff_test_description				VARCHAR(500) = NULL,
	@inherit_assmt_eff_test_profile_id	INT = NULL,
	@init_eff_test_approach_value_id	INT = NULL,
	@init_assmt_curve_type_value_id		INT = NULL,
	@init_curve_source_value_id			INT = NULL,
	@init_number_of_curve_points		INT = NULL,
	@on_eff_test_approach_value_id		INT = NULL,
	@on_assmt_curve_type_value_id		INT = NULL,
	@on_curve_source_value_id			INT = NULL,
	@on_number_of_curve_points			INT = NULL,
	@force_intercept_zero				CHAR(1) = NULL,
	@profile_for_value_id				INT = NULL,
	@convert_currency_value_id			INT = NULL,
	@convert_uom_value_id				INT = NULL,
	@effective_start_date				DATETIME = NULL,
	@effective_end_date					DATETIME = NULL,
	@risk_mgmt_strategy					CHAR(1) = NULL,
	@risk_mgmt_policy					CHAR(1) = NULL,
	@formal_documentation				CHAR(1) = NULL,
	@profile_approved					CHAR(1) = NULL,
	@profile_approved_by				VARCHAR(50) = NULL,
	@profile_approved_date				DATETIME = NULL,
	@hedge_to_item_conv_factor			FLOAT = NULL,
	@item_pricing_value_id				INT = NULL,
	@hedge_test_price_option_value_id	INT = NULL,
	@item_test_price_option_value_id	INT = NULL,
	@hedge_fixed_price_value_id			INT = NULL,
	@use_hedge_as_depend_var			CHAR(1) = NULL,
	@item_counterparty_id				INT = NULL,
	@item_trader_id						INT = NULL,
	@gen_curve_source_value_id			INT = NULL,
	@individual_link_calc				CHAR(1) = NULL,  
	@ineffectiveness_in_hedge			CHAR(1) = NULL,
	@mstm_eff_test_type_id				INT = NULL,
	@matching_type						CHAR(1)	= 'a',
	@is_externalization					CHAR(1) = 'n',
	@form_xml							VARCHAR(MAX) = null,
	@subsidiary_id						VARCHAR(MAX) = NULL,
	@strategy_id						VARCHAR(MAX) = NULL,
	@book_id							VARCHAR(MAX) = NULL,
	@effectiveness_testing_not_required VARCHAR(1) = NULL

AS
SET NOCOUNT ON

DECLARE @sql_stmt VARCHAR(8000)
DECLARE @copy_eff_test_profile_id INT

IF @flag IN ( 'i', 'u')
BEGIN
	DECLARE @idoc INT
		, @idoc1 INT
		, @delivery_path_id INT
		, @pipeline INT
		, @contract_id INT
		, @new_path_name VARCHAR(100)
	
	IF @form_xml IS NOT NULL
	BEGIN
		IF OBJECT_ID(N'tempdb..#collect_form_data') IS NOT NULL DROP TABLE #collect_form_data
	
		EXEC sp_xml_preparedocument @idoc OUTPUT, @form_xml		
		
		SELECT eff_test_profile_id
			, fas_book_id
			, eff_test_name
			, eff_test_description
			, NULLIF(inherit_assmt_eff_test_profile_id, '') inherit_assmt_eff_test_profile_id
			, init_eff_test_approach_value_id
			, NULLIF(init_assmt_curve_type_value_id, '') init_assmt_curve_type_value_id
			, init_curve_source_value_id
			, init_number_of_curve_points
			, on_eff_test_approach_value_id
			, on_assmt_curve_type_value_id
			, on_curve_source_value_id
			, on_number_of_curve_points
			, force_intercept_zero
			, profile_for_value_id
			, NULLIF(convert_currency_value_id, '') convert_currency_value_id
			, NULLIF(convert_uom_value_id, '') convert_uom_value_id
			, effective_start_date
			, NULLIF(effective_end_date, '') effective_end_date
			, risk_mgmt_strategy
			, risk_mgmt_policy
			, formal_documentation
			, profile_approved
			, profile_active
			, profile_approved_by
			, NULLIF(profile_approved_date, '') profile_approved_date
			, hedge_to_item_conv_factor
			, item_pricing_value_id
			, hedge_test_price_option_value_id
			, item_test_price_option_value_id
			, hedge_fixed_price_value_id
			, use_hedge_as_depend_var
			, item_counterparty_id
			, item_trader_id
			, NULLIF(gen_curve_source_value_id, '') gen_curve_source_value_id
			, individual_link_calc
			, ineffectiveness_in_hedge
			, hedge_doc_temp
			, mstm_eff_test_type_id
			, externalization
			, matching_type
			, effectiveness_testing_not_required
		INTO #collect_form_data
		FROM   OPENXML(@idoc, '/FormXML', 1)
				WITH (
					eff_test_profile_id VARCHAR(10) '@eff_test_profile_id'
					, fas_book_id	VARCHAR(100) '@fas_book_id'
					, eff_test_name	VARCHAR(100) '@eff_test_name'
					, eff_test_description VARCHAR(500) '@eff_test_description'
					, inherit_assmt_eff_test_profile_id VARCHAR(10) '@inherit_assmt_eff_test_profile_id'
					, init_eff_test_approach_value_id VARCHAR(10) '@init_eff_test_approach_value_id'
					, init_assmt_curve_type_value_id VARCHAR(10) '@init_assmt_curve_type_value_id'
					, init_curve_source_value_id VARCHAR(10) '@init_curve_source_value_id'
					, init_number_of_curve_points VARCHAR(10) '@init_number_of_curve_points'
					, on_eff_test_approach_value_id VARCHAR(10) '@on_eff_test_approach_value_id'
					, on_assmt_curve_type_value_id VARCHAR(10) '@on_assmt_curve_type_value_id'
					, on_curve_source_value_id VARCHAR(10) '@on_curve_source_value_id'
					, on_number_of_curve_points VARCHAR(10) '@on_number_of_curve_points'
					, force_intercept_zero CHAR(1) '@force_intercept_zero'
					, profile_for_value_id VARCHAR(10) '@profile_for_value_id'
					, convert_currency_value_id VARCHAR(10) '@convert_currency_value_id'
					, convert_uom_value_id VARCHAR(10) '@convert_uom_value_id'
					, effective_start_date	VARCHAR(10)  '@effective_start_date'
					, effective_end_date	VARCHAR(10)  '@effective_end_date'
					, risk_mgmt_strategy	CHAR(1) '@risk_mgmt_strategy'
					, risk_mgmt_policy		CHAR(1) '@risk_mgmt_policy'
					, formal_documentation	CHAR(1) '@formal_documentation'
					, profile_approved		CHAR(1) '@profile_approved'
					, profile_active		CHAR(1) '@profile_active'
					, profile_approved_by	VARCHAR(10) '@profile_approved_by'
					, profile_approved_date	VARCHAR(10) '@profile_approved_date'
					, hedge_to_item_conv_factor	VARCHAR(50) '@hedge_to_item_conv_factor'
					, item_pricing_value_id	VARCHAR(50) '@item_pricing_value_id'
					, hedge_test_price_option_value_id VARCHAR(50) '@hedge_test_price_option_value_id'
					, item_test_price_option_value_id VARCHAR(50) '@item_test_price_option_value_id'
					, hedge_fixed_price_value_id VARCHAR(50) '@hedge_fixed_price_value_id'
					, use_hedge_as_depend_var	CHAR(1) '@use_hedge_as_depend_var'
					, item_counterparty_id	VARCHAR(50) '@item_counterparty_id'
					, item_trader_id	VARCHAR(50) '@item_trader_id'
					, gen_curve_source_value_id	VARCHAR(50) '@gen_curve_source_value_id'
					, individual_link_calc	CHAR(1) '@individual_link_calc'
					, ineffectiveness_in_hedge	CHAR(1) '@ineffectiveness_in_hedge'
					, hedge_doc_temp	VARCHAR(250) '@hedge_doc_temp'
					, mstm_eff_test_type_id VARCHAR(50) '@mstm_eff_test_type_id'
					, externalization	CHAR(1) '@externalization'
					, matching_type	CHAR(1) '@matching_type'
					, effectiveness_testing_not_required VARCHAR(1) '@effectiveness_testing_not_required'
				)
	END
END
IF @flag = 's'
BEGIN
	SET @sql_stmt = 'SELECT a.eff_test_profile_id,
						   a.eff_test_name,
						   sub.entity_name subsidiary,
						   stra.entity_name strategy,						   
						   book.entity_name book,
						   a.eff_test_description,
						   CASE WHEN a.matching_type = ''a'' THEN ''Auto Matching''
								WHEN a.matching_type = ''h'' THEN ''Hypothetical Derivative''
								WHEN a.matching_type = ''b'' THEN ''Both''
								WHEN a.matching_type = ''n'' THEN ''None''
							END matching_type,
						   dbo.FNADateFormat(a.effective_start_date)  effective_start_date,
						   dbo.FNADateFormat(a.effective_end_date)  effective_end_date,
						   CASE WHEN a.profile_active = ''y'' THEN ''Yes'' ELSE ''No'' END profile_active,
						   CASE WHEN a.profile_approved = ''y'' THEN ''Yes'' ELSE ''No'' END profile_approved,
						   a.profile_approved_by,
						   dbo.FNADateFormat(a.profile_approved_date)  profile_approved_date,
						   a.create_user,
						   dbo.FNADateFormat(a.create_ts) create_ts,
						   a.update_user,
						   dbo.FNADateFormat(a.update_ts) update_ts,
						   sdv.code [measurement_eff_test_approach],
						   a.externalization,
						   a.fas_book_id
					FROM fas_eff_hedge_rel_type a
					LEFT JOIN static_data_value  sdv ON  a.mstm_eff_test_type_id = sdv.value_id
					INNER JOIN portfolio_hierarchy book ON book.hierarchy_level = 0 AND  a.fas_book_id = book.entity_id
					INNER JOIN portfolio_hierarchy stra ON stra.hierarchy_level = 1 AND book.parent_entity_id = stra.entity_id
					INNER JOIN portfolio_hierarchy sub ON sub.hierarchy_level = 2 AND stra.parent_entity_id = sub.entity_id
					WHERE 1 = 1 ' 
					+ CASE WHEN @subsidiary_id IS NOT NULL THEN ' AND sub.entity_id IN (' + @subsidiary_id + ')' ELSE '' END +
					+ CASE WHEN @strategy_id IS NOT NULL THEN ' AND stra.entity_id IN (' + @strategy_id + ')' ELSE '' END +
					+ CASE WHEN @book_id IS NOT NULL THEN ' AND book.entity_id IN (' + @book_id + ')' ELSE '' END +
					' ORDER BY sub.entity_name, stra.entity_name, book.entity_name, a.eff_test_name '
	--print @sql_stmt
	EXEC(@sql_stmt)
END
ELSE IF @flag = 'a' 
BEGIN
	SELECT  a.eff_test_profile_id, a.fas_book_id, a.eff_test_name, a.eff_test_description, a.inherit_assmt_eff_test_profile_id, a.init_eff_test_approach_value_id, 
            a.init_assmt_curve_type_value_id, a.init_curve_source_value_id, a.init_number_of_curve_points, a.on_eff_test_approach_value_id, 
            a.on_assmt_curve_type_value_id, a.on_curve_source_value_id, a.on_number_of_curve_points, a.force_intercept_zero, a.profile_for_value_id, 
            a.convert_currency_value_id, a.convert_uom_value_id, dbo.FNADateFormat(a.effective_start_date) as effective_start_date,
			dbo.FNADateFormat( a.effective_end_date), a.risk_mgmt_strategy, a.risk_mgmt_policy, 
            a.formal_documentation, a.profile_approved, a.profile_active, a.profile_approved_by, dbo.FNADateFormat(a.profile_approved_date) as profile_approved_date,
			a.hedge_to_item_conv_factor as hedge_to_item_conv_factor, 
			--		 cast(round(a.hedge_to_item_conv_factor, 2) as VARCHAR) as hedge_to_item_conv_factor, 
            a.item_pricing_value_id, a.hedge_test_price_option_value_id, a.item_test_price_option_value_id, a.hedge_fixed_price_value_id, 
            a.use_hedge_as_depend_var, a.item_counterparty_id, a.item_trader_id, a.gen_curve_source_value_id, a.individual_link_calc ,a.ineffectiveness_in_hedge,a.create_user, dbo.FNADateFormat(a.create_ts) as create_ts, a.update_user, 
            a.update_ts, fas_eff_hedge_rel_type_inherit_from.eff_test_name AS eff_test_name_inherit_from,a.mstm_eff_test_type_id, a.externalization isExternalization,a.matching_type
	FROM fas_eff_hedge_rel_type a 
	LEFT OUTER JOIN fas_eff_hedge_rel_type fas_eff_hedge_rel_type_inherit_from ON a.inherit_assmt_eff_test_profile_id = fas_eff_hedge_rel_type_inherit_from.eff_test_profile_id
	WHERE a.eff_test_profile_id = @eff_test_profile_id

	IF @@ERROR <> 0
		EXEC spa_ErrorHandler @@ERROR, 'Effective Hedge Relation table', 
				'spa_eff_hedge_rel_type', 'DB Error', 
				'Failed to select effective hedge relation record.', ''
	ELSE
		EXEC spa_ErrorHandler 0, 'Effective Hedge Relation table', 
				'spa_eff_hedge_rel_type', 'Success', 
				'Effective hedge relation record successfully selected.', ''
END
ELSE IF @flag = 'c' 
BEGIN
	DECLARE @splited_eff_test_profile_id INT
	DECLARE multi_eff_test_profile_id CURSOR FOR
	SELECT item FROM [dbo].[SplitCommaSeperatedValues](@eff_test_profile_id) 
	OPEN multi_eff_test_profile_id
	FETCH NEXT
	FROM multi_eff_test_profile_id INTO @splited_eff_test_profile_id
	WHILE @@FETCH_STATUS = 0
	BEGIN	
		BEGIN TRANSACTION
		INSERT INTO fas_eff_hedge_rel_type
			(
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
			ineffectiveness_in_hedge,
			mstm_eff_test_type_id,
			externalization, 
			matching_type,
			effectiveness_testing_not_required
			)
			SELECT 	fas_book_id, ('Copy of ' + eff_test_name) AS eff_test_name, 
					('Copy of ' + eff_test_name) AS eff_test_description, inherit_assmt_eff_test_profile_id, 
					init_eff_test_approach_value_id, init_assmt_curve_type_value_id, 
					init_curve_source_value_id, init_number_of_curve_points, 
					on_eff_test_approach_value_id, on_assmt_curve_type_value_id, 
					on_curve_source_value_id, on_number_of_curve_points, 
					force_intercept_zero, profile_for_value_id, convert_currency_value_id, 
					convert_uom_value_id, effective_start_date, 
					effective_end_date, 'n' AS risk_mgmt_strategy, 
					'n' AS risk_mgmt_policy, 'n' AS formal_documentation, 'n' AS profile_approved, 
					'y' AS profile_active, NULL AS profile_approved_by, NULL AS profile_approved_date, 
					hedge_to_item_conv_factor, item_pricing_value_id, 
					hedge_test_price_option_value_id, 
					item_test_price_option_value_id, hedge_fixed_price_value_id, 
					use_hedge_as_depend_var, item_counterparty_id, item_trader_id, 
					gen_curve_source_value_id, individual_link_calc, ineffectiveness_in_hedge,mstm_eff_test_type_id, 
					externalization,matching_type, effectiveness_testing_not_required
			FROM fas_eff_hedge_rel_type
			WHERE eff_test_profile_id = @splited_eff_test_profile_id
			
			SET @copy_eff_test_profile_id = SCOPE_IDENTITY() 

			IF @@ERROR <> 0
			BEGIN
				EXEC spa_ErrorHandler @@ERROR, 'Hedge Relationship Types', 
						'spa_eff_hedge_rel_type', 'DB Error', 
						'Failed to copy the selected hedging relationship type.', ''
				ROLLBACK TRANSACTION
			END
			ELSE
			BEGIN
				INSERT INTO fas_eff_hedge_rel_type_detail([eff_test_profile_id]
				   , [hedge_or_item]
				   , [book_deal_type_map_id]
				   , [source_deal_type_id]
				   , [deal_sub_type_id]
				   , [fixed_float_flag]
				   , [deal_sequence_number]
				   , [leg]
				   , [buy_sell_flag]
				   , [source_curve_def_id]
				   , [strip_month_from]
				   , [strip_month_to]
				   , [strip_year_overlap]
				   , [roll_forward_year]
				   , [volume_mix_percentage]
				   , [uom_conversion_factor]
				   , [deal_xfer_source_book_id]
				   , [create_user]
				   , [create_ts]
				   , [update_user]
				   , [update_ts]
				   , [strip_months]
				   , [price_adder]
				   , [price_multiplier]
				   , sub_id)
				SELECT 	@copy_eff_test_profile_id AS eff_test_profile_id, 
						hedge_or_item, book_deal_type_map_id, 
						source_deal_type_id, deal_sub_type_id, fixed_float_flag, 
						deal_sequence_number, leg, buy_sell_flag, 
						source_curve_def_id, strip_month_from, strip_month_to, 
						strip_year_overlap, roll_forward_year, 
						volume_mix_percentage, uom_conversion_factor, 
						deal_xfer_source_book_id, 
						NULL AS create_user, NULL AS create_ts, 
						NULL AS update_user, NULL AS update_ts,
						strip_months, price_adder, price_multiplier, sub_id
				FROM fas_eff_hedge_rel_type_detail 
				WHERE eff_test_profile_id = @splited_eff_test_profile_id

				IF @@ERROR <> 0
				BEGIN
				EXEC spa_ErrorHandler @@ERROR, 'Hedge Relationship Types', 
					'spa_eff_hedge_rel_type', 'DB Error', 
					'Failed to copy the selected hedging relationship type detail records.', ''
				ROLLBACK TRANSACTION
				END
				ELSE
				BEGIN
					SELECT @fas_book_id = fas_book_id
					FROM fas_eff_hedge_rel_type
					WHERE eff_test_profile_id = @splited_eff_test_profile_id

				SET @sql_stmt = ('Hedging relationship type copied. New ID: ' 
						+ cast(@copy_eff_test_profile_id AS VARCHAR(10)) 
					+ ' in selected Book ID: ' 
						+ CAST(@fas_book_id AS VARCHAR(10)))

				EXEC spa_ErrorHandler 0, 'Hedge Relationship Types', 
					'spa_eff_hedge_rel_type', 'Success',
					@sql_stmt, ''
				COMMIT TRANSACTION
			END
		END
		FETCH NEXT
		FROM multi_eff_test_profile_id INTO @splited_eff_test_profile_id
		END
	CLOSE multi_eff_test_profile_id
	DEALLOCATE multi_eff_test_profile_id
END
ELSE IF @flag = 'i'
BEGIN
	INSERT INTO fas_eff_hedge_rel_type
		(fas_book_id,
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
		ineffectiveness_in_hedge,
		mstm_eff_test_type_id,
		externalization,matching_type,
		hedge_doc_temp,
		effectiveness_testing_not_required)
	SELECT fas_book_id,
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
		CASE WHEN profile_approved = 'y' THEN dbo.FNADBUser() ELSE '' END,
		CASE WHEN profile_approved = 'y' THEN GETDATE() ELSE NULL END,
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
		ineffectiveness_in_hedge,
		mstm_eff_test_type_id,
		externalization,matching_type,
		hedge_doc_temp,
		effectiveness_testing_not_required
	FROM #collect_form_data

	DECLARE @new_id VARCHAR(100)

	SET @new_id = CAST(SCOPE_IDENTITY() AS VARCHAR)

	IF @@ERROR <> 0
		EXEC spa_ErrorHandler @@ERROR, 'Effective Hedge Relation table', 
				'spa_eff_hedge_rel_type', 'DB Error', 
				'Failed to insert effective hedge relation record.', ''
	ELSE
		EXEC spa_ErrorHandler 0, 'Effective Hedge Relation table', 
				'spa_eff_hedge_rel_type', 'Success', 
				'Changes have been saved successfully.', @new_id
END	
ELSE IF @flag = 'u'
BEGIN
	DECLARE @previous_profile_approved CHAR(1)
	DECLARE @previous_profile_approved_by VARCHAR(50)
	DECLARE @previous_profile_approved_date DATETIME

	---- get who approved and what date ----------
	SET @previous_profile_approved = 'n'

	SELECT 	@previous_profile_approved = ISNULL(hrt.profile_approved, 'n'),
		@previous_profile_approved_by = hrt.profile_approved_by,
		@previous_profile_approved_date = hrt.profile_approved_date
	FROM fas_eff_hedge_rel_type hrt
	INNER JOIN #collect_form_data cfd ON cfd.eff_test_profile_id = hrt.eff_test_profile_id

	IF @profile_approved = 'y' AND @previous_profile_approved = 'n'
	BEGIN
		SET @profile_approved_by = dbo.FNADBUser()
		SET @profile_approved_date = getdate()
	END
	ELSE IF @profile_approved = 'y' AND @previous_profile_approved = 'y'
	BEGIN
		SET @profile_approved_by = @previous_profile_approved_by
		SET @profile_approved_date = @previous_profile_approved_date
	END
	ELSE IF @profile_approved = 'n' 
	BEGIN
		SET @profile_approved_by = NULL
		SET @profile_approved_date = NULL
	END

	UPDATE hrt
	SET	fas_book_id = cfd.fas_book_id,
		eff_test_name=cfd.eff_test_name,
		eff_test_description=cfd.eff_test_description,
		inherit_assmt_eff_test_profile_id=cfd.inherit_assmt_eff_test_profile_id,
		init_eff_test_approach_value_id=cfd.init_eff_test_approach_value_id,
		init_assmt_curve_type_value_id=cfd.init_assmt_curve_type_value_id,
		init_curve_source_value_id=cfd.init_curve_source_value_id,
		init_number_of_curve_points=cfd.init_number_of_curve_points,
		on_eff_test_approach_value_id=cfd.on_eff_test_approach_value_id,
		on_assmt_curve_type_value_id=cfd.on_assmt_curve_type_value_id,
		on_curve_source_value_id=cfd.on_curve_source_value_id,
		on_number_of_curve_points=cfd.on_number_of_curve_points,
		force_intercept_zero=cfd.force_intercept_zero,
		profile_for_value_id=cfd.profile_for_value_id,
		convert_currency_value_id=cfd.convert_currency_value_id,
		convert_uom_value_id=cfd.convert_uom_value_id,
		effective_start_date=cfd.effective_start_date,
		effective_end_date=cfd.effective_end_date,
		risk_mgmt_strategy=cfd.risk_mgmt_strategy,
		risk_mgmt_policy=cfd.risk_mgmt_policy,
		formal_documentation=cfd.formal_documentation,
		profile_approved=cfd.profile_approved,
		profile_active = cfd.profile_active,
		profile_approved_by = @profile_approved_by,
		profile_approved_date = @profile_approved_date,
		hedge_to_item_conv_factor=cfd.hedge_to_item_conv_factor,
		item_pricing_value_id=cfd.item_pricing_value_id,
		hedge_test_price_option_value_id=cfd.hedge_test_price_option_value_id,
		item_test_price_option_value_id=cfd.item_test_price_option_value_id,
		hedge_fixed_price_value_id=cfd.hedge_fixed_price_value_id,
		use_hedge_as_depend_var=cfd.use_hedge_as_depend_var,
		item_counterparty_id=cfd.item_counterparty_id,
		item_trader_id=cfd.item_trader_id,
		gen_curve_source_value_id=cfd.gen_curve_source_value_id,
		individual_link_calc=cfd.individual_link_calc,
		ineffectiveness_in_hedge=cfd.ineffectiveness_in_hedge,
		mstm_eff_test_type_id=cfd.mstm_eff_test_type_id,
		externalization=cfd.externalization,
		matching_type = cfd.matching_type,
		hedge_doc_temp = cfd.hedge_doc_temp,
		effectiveness_testing_not_required = cfd.effectiveness_testing_not_required		
	FROM fas_eff_hedge_rel_type hrt
	INNER JOIN #collect_form_data cfd ON cfd.eff_test_profile_id = hrt.eff_test_profile_id	

	IF @@ERROR <> 0
		EXEC spa_ErrorHandler @@ERROR, 'Effective Hedge Relation table', 
				'spa_eff_hedge_rel_type', 'DB Error', 
				'Failed to update effective hedge relation record.', ''
	ELSE
		EXEC spa_ErrorHandler 0, 'Effective Hedge Relation table', 
				'spa_eff_hedge_rel_type', 'Success', 
				'Changes have been saved successfully.', ''
END	
ELSE IF @flag = 'd'
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION

			DELETE featrpd
			FROM fas_eff_ass_test_results_process_detail featrpd
			INNER JOIN fas_eff_ass_test_results featr ON featr.eff_test_result_id = featrpd.eff_test_result_id
			INNER JOIN dbo.FNASplit(@eff_test_profile_id, ',') di ON di.item = featr.eff_test_profile_id
			WHERE featr.calc_level IN (1, 2)

			DELETE featrph
			FROM fas_eff_ass_test_results_process_header featrph
			INNER JOIN fas_eff_ass_test_results featr ON featr.eff_test_result_id = featrph.eff_test_result_id
			INNER JOIN dbo.FNASplit(@eff_test_profile_id, ',') di ON di.item = featr.eff_test_profile_id
			WHERE featr.calc_level IN (1, 2)

			DELETE featr
			FROM fas_eff_ass_test_results featr
			INNER JOIN dbo.FNASplit(@eff_test_profile_id, ',') di ON di.item = featr.eff_test_profile_id
			WHERE featr.calc_level IN (1, 2)

			DELETE fehrtd
			FROM fas_eff_hedge_rel_type_detail fehrtd
			INNER JOIN dbo.FNASplit(@eff_test_profile_id, ',') di ON di.item = fehrtd.eff_test_profile_id

			DELETE fehrt
			FROM fas_eff_hedge_rel_type fehrt
			INNER JOIN dbo.FNASplit(@eff_test_profile_id, ',') di ON di.item = fehrt.eff_test_profile_id

		COMMIT TRANSACTION

		EXEC spa_ErrorHandler 0,
			'Effective Hedge Relation table',
			'spa_eff_hedge_rel_type', 'Success',
			'Changes have been saved successfully.',
			''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION

		DECLARE @err_msg VARCHAR(MAX) = dbo.FNAHandleDBError(10231900)

		EXEC spa_ErrorHandler -1,
			'Effective Hedge Relation table',
			'spa_eff_hedge_rel_type', 'DB Error',
			@err_msg,
			''
		RETURN
	END CATCH
END
ELSE IF @flag = 'z' -- get sub 
BEGIN
	SELECT sub.entity_id 
	FROM portfolio_hierarchy sub 
	INNER JOIN portfolio_hierarchy stra ON sub.entity_id = stra.parent_entity_id
	INNER JOIN portfolio_hierarchy book ON stra.entity_id = book.parent_entity_id
	WHERE book.entity_id = @fas_book_id
END
ELSE IF @flag = 'g' -- for Hedging Relationship Type dropdown
BEGIN
	SELECT eff_test_profile_id
		, eff_test_name + ': ' + sub.entity_name + '|' + stra.entity_name + '|' + book.entity_name 
	FROM fas_eff_hedge_rel_type hedge_rel
	INNER JOIN portfolio_hierarchy book ON book.entity_id = hedge_rel.fas_book_id AND book.hierarchy_level = 0
	INNER JOIN portfolio_hierarchy stra ON stra.entity_id = book.parent_entity_id AND stra.hierarchy_level = 1
	INNER JOIN portfolio_hierarchy sub ON sub.entity_id = stra.parent_entity_id AND sub.hierarchy_level = 2
END
ELSE IF @flag ='h'
BEGIN
	SELECT convert_currency_value_id, convert_uom_value_id  FROM fas_eff_hedge_rel_type WHERE eff_test_profile_id = @eff_test_profile_id
END
ELSE IF @flag ='k'-- For fas_eff_hedge_rel_type grid in adiha_grid_definition
BEGIN
	SELECT eff_test_profile_id, eff_test_name FROM fas_eff_hedge_rel_type 
END

GO