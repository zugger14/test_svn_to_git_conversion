IF EXISTS (
       SELECT *
       FROM   sys.objects
       WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[spa_strategy]')
              AND TYPE IN (N'P', N'PC')
)
DROP PROCEDURE [dbo].[spa_strategy]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

--SELECT * FROM fas_strategy
-- EXEC spa_strategy 's', 3


-- DROP PROC spa_strategy

--This proc will be used to perform select, insert, update and delete record
--from the fas_strategy table
--The fisrt parameter or flag to pass: select = 's', for Insert='i'. Update='u' and Delete='d'
--For insert and update, pass all the parameters defined for this stored procedure
--For delete, pass the flad and the fas_subsidiary_od parameter
CREATE PROC [dbo].[spa_strategy] 
@flag CHAR(1),
@fas_strategy_id INT = NULL,
@source_system_id INT = NULL,
@hedge_type_value_id INT = NULL,
@fx_hedge_flag CHAR(1) = NULL,
@mes_gran_value_id INT = NULL,
@gl_grouping_value_id INT = NULL,
@no_links CHAR(1) = NULL,
@no_links_fas_eff_test_profile_id INT = NULL,
@mes_cfv_value_id INT = NULL,
@mes_cfv_values_value_id INT = NULL,
@mismatch_tenor_value_id INT = NULL,
@strip_trans_value_id INT = NULL,
@asset_liab_calc_value_id INT = NULL,
@test_range_from FLOAT = NULL,
@test_range_to FLOAT = NULL,
@include_unlinked_hedges CHAR(1) = NULL,
@include_unlinked_items CHAR(1) = NULL,
@gl_entries_value_id INT = NULL,
@gl_number_id_st_asset INT = NULL,
@gl_number_id_st_liab INT = NULL,
@gl_number_id_lt_asset INT = NULL,
@gl_number_id_lt_liab INT = NULL,
@gl_number_id_item_st_asset INT = NULL,
@gl_number_id_item_st_liab INT = NULL,
@gl_number_id_item_lt_asset INT = NULL,
@gl_number_id_item_lt_liab INT = NULL,
@gl_number_id_aoci INT = NULL,
@gl_number_id_pnl INT = NULL,
@gl_number_id_set INT = NULL,
@gl_number_id_cash INT = NULL,
@oci_rollout_approach_value_id INT = NULL,
@fas_subsidiary_id INT = NULL,
@fas_strategy_name VARCHAR(100) = NULL,
@test_range_from2 FLOAT = NULL,
@test_range_to2 FLOAT = NULL,
@additional_test_range_from FLOAT = NULL,
@additional_test_range_to FLOAT = NULL,
@gl_number_id_inventory INT = NULL,
@options_premium_approach INT = NULL,
@gl_number_id_amortization INT = NULL,
@gl_number_id_interest INT = NULL,
@gl_number_id_expense INT = NULL,
@gl_number_id_gross_set INT = NULL,
@subentity_name VARCHAR(250) = NULL,
@subentity_desc VARCHAR(1000) = NULL,
@relationship_to_entity VARCHAR(1000) = NULL,
@distinct_estimation_method INT = NULL,
@distinct_output_metrics INT = NULL,
@distinct_foreign_country INT = NULL,
@primary_naics_code_id INT = NULL,
@secondary_naics_code_id INT = NULL,
@organization_boundary_id INT = NULL,
@sub_entity CHAR(1) = NULL,
@rollout_per_type INT = NULL,

@gl_id_st_tax_asset INT = NULL,
@gl_id_st_tax_liab INT = NULL,
@gl_id_lt_tax_asset INT = NULL,
@gl_id_lt_tax_liab INT = NULL,
@gl_id_tax_reserve INT = NULL,
@first_day_pnl_threshold FLOAT = NULL,
@gl_tenor_option CHAR(1) = NULL,
-- Added 
@fun_cur_value_id INT = NULL,
@gl_number_unhedged_der_st_asset INT = NULL,
@gl_number_unhedged_der_lt_asset INT = NULL,
@gl_number_unhedged_der_st_liab INT = NULL,
@gl_number_unhedged_der_lt_liab INT = NULL

 AS
 
 SET NOCOUNT ON

DECLARE  @tmp_subsidiary  varchar(200)

DECLARE @total_book INT
IF @flag = 's'
BEGIN
    -- 	SELECT a.*, b.entity_name
    -- 	FROM fas_strategy a, portfolio_hierarchy b,
    -- 		gl_system_mapping gl1,
    -- 	WHERE a.fas_strategy_id = @fas_strategy_id
    -- 	AND a.fas_strategy_id = b.entity_id
    
    SELECT @total_book = COUNT(*)
    FROM   portfolio_hierarchy
    WHERE  parent_entity_id = @fas_strategy_id
--SELECT	fas_strategy.fas_strategy_id,
--		fas_strategy.source_system_id,
--		fas_strategy.hedge_type_value_id,
--		fas_strategy.fx_hedge_flag,
--		fas_strategy.mes_gran_value_id,
--		fas_strategy.gl_grouping_value_id,
--		fas_strategy.no_links,
--		fas_strategy.no_links_fas_eff_test_profile_id,
--		fas_strategy.mes_cfv_value_id,
--		fas_strategy.mes_cfv_values_value_id,
--		fas_strategy.mismatch_tenor_value_id,
--		fas_strategy.strip_trans_value_id,
--		fas_strategy.asset_liab_calc_value_id,
--		CAST(ROUND(test_range_from, 2) AS VARCHAR) AS test_range_from,
--		CAST(ROUND(test_range_to, 2) AS VARCHAR) AS test_range_to,
--		CAST(ROUND(additional_test_range_from, 2) AS VARCHAR) AS 
--		additional_test_range_from,
--		CAST(ROUND(additional_test_range_to, 2) AS VARCHAR) AS 
--		additional_test_range_to,
--		fas_strategy.include_unlinked_hedges,
--		fas_strategy.include_unlinked_items,
--		fas_strategy.gl_number_id_st_asset,
--		fas_strategy.gl_number_id_st_liab,
--		fas_strategy.gl_number_id_lt_asset,
--		fas_strategy.gl_number_id_lt_liab,
--		fas_strategy.gl_number_id_item_st_asset,
--		fas_strategy.gl_number_id_item_st_liab,
--		fas_strategy.gl_number_id_item_lt_asset,
--		fas_strategy.gl_number_id_item_lt_liab,
--		fas_strategy.gl_number_id_aoci,
--		fas_strategy.gl_number_id_pnl,
--		fas_strategy.gl_number_id_set,
--		fas_strategy.gl_number_id_cash,
--		fas_strategy.oci_rollout_approach_value_id,
--		fas_strategy.create_user,
--		fas_strategy.create_ts,
--		fas_strategy.update_user,
--		fas_strategy.update_ts,
--		portfolio_hierarchy.entity_name AS entity_name,
--		gl1.gl_account_number + ' (' + gl1.gl_account_name + ')' AS gl_number_id_st_asset_display,
--		gl2.gl_account_number + ' (' + gl2.gl_account_name + ')' AS gl_number_id_st_liab_display,
--		gl3.gl_account_number + ' (' + gl3.gl_account_name + ')' AS gl_number_id_lt_asset_display,
--		gl4.gl_account_number + ' (' + gl4.gl_account_name + ')' AS gl_number_id_lt_liab_display,
--		gl5.gl_account_number + ' (' + gl5.gl_account_name + ')' AS gl_number_id_item_st_asset_display,
--		gl6.gl_account_number + ' (' + gl6.gl_account_name + ')' AS gl_number_id_item_st_liab_display,
--		gl7.gl_account_number + ' (' + gl7.gl_account_name + ')' AS gl_number_id_item_lt_asset_display,
--		gl8.gl_account_number + ' (' + gl8.gl_account_name + ')' AS gl_number_id_item_lt_liab_display,
--		gl9.gl_account_number + ' (' + gl9.gl_account_name + ')' AS gl_number_id_aoci_display,
--		gl10.gl_account_number + ' (' + gl10.gl_account_name + ')' AS gl_number_id_pnl_display,
--		gl11.gl_account_number + ' (' + gl11.gl_account_name + ')' AS gl_number_id_set_display,
--		gl12.gl_account_number + ' (' + gl12.gl_account_name + ')' AS gl_number_id_cash_display,
--		fas_eff_hedge_rel_type.eff_test_name AS no_links_fas_eff_test_profile_id_name,
--		CAST(ROUND(additional_test_range_from2, 2)AS VARCHAR) AS test_range_from2,
--		CAST(ROUND(additional_test_range_to2, 2)AS VARCHAR) AS test_range_to2,
--		fas_strategy.gl_number_id_inventory,
--		gl13.gl_account_number + ' (' + gl13.gl_account_name + ')' AS gl_number_id_inventory_display, 
--		fas_strategy.options_premium_approach,
--		fas_strategy.gl_id_amortization,
--		gl14.gl_account_number + ' (' + gl14.gl_account_name + ')' AS gl_number_id_Amortize_display,
--		fas_strategy.gl_id_interest,
--		gl15.gl_account_number + ' (' + gl15.gl_account_name + ')' AS gl_number_id_Intrest_display,
--		fas_strategy.gl_number_id_expense,
--		gl16.gl_account_number + ' (' + gl16.gl_account_name + ')' AS gl_number_id_Expense_display,
--		fas_strategy.gl_number_id_gross_set,
--		gl17.gl_account_number + ' (' + gl17.gl_account_name + ')' AS gl_number_id_Gross_display,
--		subentity_name,
--		subentity_desc,
--		relationship_to_entity,
--		distinct_estimation_method,
--		distinct_output_metrics,
--		distinct_foreign_country,
--		primary_naics_code_id,
--		secondary_naics_code_id,
--		organization_boundary_id,
--		sub_entity,fas_strategy.rollout_per_type,
--		fas_strategy.gl_id_st_tax_asset,
--		gl18.gl_account_number + ' (' + gl18.gl_account_name + ')' AS gl_id_st_tax_asset_display,
--		fas_strategy.gl_id_st_tax_liab,
--		gl19.gl_account_number + ' (' + gl19.gl_account_name + ')' AS gl_id_st_tax_liab_display,
--		fas_strategy.gl_id_lt_tax_asset,
--		gl20.gl_account_number + ' (' + gl20.gl_account_name + ')' AS gl_id_lt_tax_asset_display,
--		fas_strategy.gl_id_lt_tax_liab,
--		gl21.gl_account_number + ' (' + gl21.gl_account_name + ')' AS gl_id_lt_tax_liab_display,
--		fas_strategy.gl_id_tax_reserve,
--		gl22.gl_account_number + ' (' + gl22.gl_account_name + ')' AS gl_id_tax_reserve_display,
--		@total_book total_book,
--		first_day_pnl_threshold,
--		gl_tenor_option,
--		fun_cur_value_id,
--		fas_strategy.gl_number_unhedged_der_st_asset,
--		gl23.gl_account_number + ' (' + gl23.gl_account_name +')' as gl_number_unhedged_der_st_asset_display,
--		fas_strategy.gl_number_unhedged_der_lt_asset,
--		gl24.gl_account_number + ' (' + gl24.gl_account_name +')' as gl_number_unhedged_der_lt_asset_display,
--		fas_strategy.gl_number_unhedged_der_st_liab,
--		gl25.gl_account_number + ' (' + gl25.gl_account_name +')' as gl_number_unhedged_der_st_liab_display,
--		fas_strategy.gl_number_unhedged_der_lt_liab,
--		gl26.gl_account_number + ' (' + gl26.gl_account_name +')' as gl_number_unhedged_der_lt_liab_display
--	FROM fas_strategy 
--	INNER JOIN portfolio_hierarchy ON fas_strategy.fas_strategy_id = portfolio_hierarchy.entity_id 
--	LEFT OUTER JOIN gl_system_mapping gl1 ON fas_strategy.gl_number_id_st_asset = gl1.gl_number_id 
--	LEFT OUTER JOIN gl_system_mapping gl2 ON fas_strategy.gl_number_id_st_liab = gl2.gl_number_id  
--	LEFT OUTER JOIN gl_system_mapping gl3 ON fas_strategy.gl_number_id_lt_asset = gl3.gl_number_id 
--	LEFT OUTER JOIN gl_system_mapping gl4 ON fas_strategy.gl_number_id_lt_liab = gl4.gl_number_id 
--	LEFT OUTER JOIN gl_system_mapping gl5 ON fas_strategy.gl_number_id_item_st_asset = gl5.gl_number_id  
--	LEFT OUTER JOIN gl_system_mapping gl6 ON fas_strategy.gl_number_id_item_st_liab = gl6.gl_number_id  
--	LEFT OUTER JOIN gl_system_mapping gl7 ON fas_strategy.gl_number_id_item_lt_asset = gl7.gl_number_id  
--	LEFT OUTER JOIN gl_system_mapping gl8 ON fas_strategy.gl_number_id_item_lt_liab = gl8.gl_number_id  
--	LEFT OUTER JOIN gl_system_mapping gl9 ON fas_strategy.gl_number_id_aoci = gl9.gl_number_id   
--	LEFT OUTER JOIN gl_system_mapping gl10 ON fas_strategy.gl_number_id_pnl = gl10.gl_number_id  
--	LEFT OUTER JOIN gl_system_mapping gl11 ON fas_strategy.gl_number_id_set = gl11.gl_number_id 
--	LEFT OUTER JOIN gl_system_mapping gl12 ON fas_strategy.gl_number_id_cash = gl12.gl_number_id 
--	LEFT OUTER JOIN gl_system_mapping gl13 ON fas_strategy.gl_number_id_inventory = gl13.gl_number_id
--	LEFT OUTER JOIN gl_system_mapping gl14 ON fas_strategy.gl_id_amortization = gl14.gl_number_id
--	LEFT OUTER JOIN gl_system_mapping gl15 ON fas_strategy.gl_id_interest = gl15.gl_number_id
--	LEFT OUTER JOIN gl_system_mapping gl16 ON fas_strategy.gl_number_id_expense = gl16.gl_number_id 
--	LEFT OUTER JOIN gl_system_mapping gl17 ON fas_strategy.gl_number_id_gross_set = gl17.gl_number_id
--	LEFT OUTER JOIN gl_system_mapping gl18 ON fas_strategy.gl_id_st_tax_asset = gl18.gl_number_id 
--	LEFT OUTER JOIN gl_system_mapping gl19 ON fas_strategy.gl_id_st_tax_liab = gl19.gl_number_id
--	LEFT OUTER JOIN gl_system_mapping gl20 ON fas_strategy.gl_id_lt_tax_asset = gl20.gl_number_id
--	LEFT OUTER JOIN gl_system_mapping gl21 ON fas_strategy.gl_id_lt_tax_liab = gl21.gl_number_id
--	LEFT OUTER JOIN gl_system_mapping gl22 ON fas_strategy.gl_id_tax_reserve = gl22.gl_number_id
--	LEFT OUTER JOIN gl_system_mapping gl23 ON   fas_strategy.gl_number_unhedged_der_st_asset = gl23.gl_number_id 
--	LEFT OUTER JOIN	gl_system_mapping gl24 ON   fas_strategy.gl_number_unhedged_der_lt_asset = gl24.gl_number_id 
--	LEFT OUTER JOIN	gl_system_mapping gl25 ON   fas_strategy.gl_number_unhedged_der_st_liab = gl25.gl_number_id 
--	LEFT OUTER JOIN	gl_system_mapping gl26 ON   fas_strategy.gl_number_unhedged_der_lt_liab = gl26.gl_number_id 
--	LEFT OUTER JOIN fas_eff_hedge_rel_type ON fas_strategy.no_links_fas_eff_test_profile_id = fas_eff_hedge_rel_type.eff_test_profile_id
--WHERE fas_strategy.fas_strategy_id = @fas_strategy_id 

SELECT * FROM vwStrategy WHERE fas_strategy_id = @fas_strategy_id   
--	If @@ERROR <> 0
--		Exec spa_ErrorHandler @@ERROR, "Strategy", 
--				"spa_strategy", "DB Error", 
--				"Failed to select Strategy Property Data.", ''
--
--	Else
--		Exec spa_ErrorHandler 0, 'Strategy', 
--				'spa_strategy', 'Success', 
--				'Strategy properties sucessfully selected', ''

END
ELSE IF @flag = 'i'
BEGIN
     DECLARE @smt VARCHAR(500)
     IF EXISTS (
            SELECT 1
            FROM   portfolio_hierarchy
            WHERE  entity_name = @fas_strategy_name
                   AND hierarchy_level = 1
                   AND parent_entity_id = @fas_subsidiary_id
        )
     BEGIN
         --select @tmp_strategy=entity_name from portfolio_hierarchy where hierarchy_level =1  and  
         SELECT @tmp_subsidiary = entity_name
         FROM   portfolio_hierarchy
         WHERE  entity_id = @fas_subsidiary_id
         
         SET @smt = 'The strategy ''' + @fas_strategy_name + ''' already exists under subsidiary ''' + @tmp_subsidiary + '''.'
         
         EXEC spa_ErrorHandler -1,
              @smt,
              'spa_strategy',
              'DB Error',
              @smt,
              ''
         
         RETURN
     END
     
     INSERT INTO portfolio_hierarchy
     VALUES
       (
         @fas_strategy_name,
         526,
         1,
         @fas_subsidiary_id,
         NULL,
         NULL,
         NULL,
         NULL
       )	
     
     SET @fas_strategy_id = SCOPE_IDENTITY() 
     IF @@ERROR = 0
     BEGIN
         INSERT INTO fas_strategy
           (
             fas_strategy_id,
             source_system_id,
             hedge_type_value_id,
             fx_hedge_flag,
             mes_gran_value_id,
             gl_grouping_value_id,
             no_links,
             no_links_fas_eff_test_profile_id,
             mes_cfv_value_id,
             mes_cfv_values_value_id,
             mismatch_tenor_value_id,
             strip_trans_value_id,
             asset_liab_calc_value_id,
             test_range_from,
             test_range_to,
             include_unlinked_hedges,
             include_unlinked_items,
             gl_number_id_st_asset,
             gl_number_id_st_liab,
             gl_number_id_lt_asset,
             gl_number_id_lt_liab,
             gl_number_id_item_st_asset,
             gl_number_id_item_st_liab,
             gl_number_id_item_lt_asset,
             gl_number_id_item_lt_liab,
             gl_number_id_aoci,
             gl_number_id_pnl,
             gl_number_id_set,
             gl_number_id_cash,
             oci_rollout_approach_value_id,
             additional_test_range_from2,
             additional_test_range_to2,
             additional_test_range_from,
             additional_test_range_to,
             gl_number_id_inventory,
             options_premium_approach,
             gl_id_amortization,
             gl_id_interest,
             gl_number_id_expense,
             gl_number_id_gross_set,
             subentity_name,
             subentity_desc,
             relationship_to_entity,
             distinct_estimation_method,
             distinct_output_metrics,
             distinct_foreign_country,
             primary_naics_code_id,
             secondary_naics_code_id,
             organization_boundary_id,
             sub_entity,
             rollout_per_type,
             gl_id_st_tax_asset,
             gl_id_st_tax_liab,
             gl_id_lt_tax_asset,
             gl_id_lt_tax_liab,
             gl_id_tax_reserve,
             first_day_pnl_threshold,
             gl_tenor_option,
             fun_cur_value_id,
             gl_number_unhedged_der_st_asset,
			 gl_number_unhedged_der_lt_asset,
			 gl_number_unhedged_der_st_liab,
			 gl_number_unhedged_der_lt_liab
           )
         VALUES
           (
             @fas_strategy_id,
             @source_system_id,
             @hedge_type_value_id,
             @fx_hedge_flag,
             @mes_gran_value_id,
             @gl_grouping_value_id,
             @no_links,
             @no_links_fas_eff_test_profile_id,
             @mes_cfv_value_id,
             @mes_cfv_values_value_id,
             @mismatch_tenor_value_id,
             @strip_trans_value_id,
             ISNULL(@asset_liab_calc_value_id, 277),
             @test_range_from,
             @test_range_to,
             @include_unlinked_hedges,
             @include_unlinked_items,
             @gl_number_id_st_asset,
             @gl_number_id_st_liab,
             @gl_number_id_lt_asset,
             @gl_number_id_lt_liab,
             @gl_number_id_item_st_asset,
             @gl_number_id_item_st_liab,
             @gl_number_id_item_lt_asset,
             @gl_number_id_item_lt_liab,
             @gl_number_id_aoci,
             @gl_number_id_pnl,
             @gl_number_id_set,
             @gl_number_id_cash,
             @oci_rollout_approach_value_id,
             @test_range_from2,
             @test_range_to2,
             @additional_test_range_from,
             @additional_test_range_to,
             @gl_number_id_inventory,
             @options_premium_approach,
             @gl_number_id_amortization,
             @gl_number_id_interest,
             @gl_number_id_expense,
             @gl_number_id_gross_set,
             @subentity_name,
             @subentity_desc,
             @relationship_to_entity,
             @distinct_estimation_method,
             @distinct_output_metrics,
             @distinct_foreign_country,
             @primary_naics_code_id,
             @secondary_naics_code_id,
             @organization_boundary_id,
             @sub_entity,
             @rollout_per_type,
             @gl_id_st_tax_asset,
             @gl_id_st_tax_liab,
             @gl_id_lt_tax_asset,
             @gl_id_lt_tax_liab,
             @gl_id_tax_reserve,
             @first_day_pnl_threshold,
             @gl_tenor_option,
             @fun_cur_value_id,
             @gl_number_unhedged_der_st_asset,
			 @gl_number_unhedged_der_lt_asset,
			 @gl_number_unhedged_der_st_liab,
			 @gl_number_unhedged_der_lt_liab
           )
     END
     IF @@ERROR <> 0
         EXEC spa_ErrorHandler @@ERROR,
              "Strategy",
              "spa_role_strategy",
              "DB Error",
              "Failed to Insert Strategy Property Data.",
              ''
     ELSE
         EXEC spa_ErrorHandler 0,
              'Strategy',
              'spa_strategy',
              'Success',
              'Strategy properties sucessfully inserted',
              @fas_strategy_id
END
ELSE IF @flag = 'u'
BEGIN
	DECLARE @stmt VARCHAR(500)

	--don't allow to update any strategy to have existing name under same subsidiary

	IF EXISTS (
		SELECT 1
		FROM   portfolio_hierarchy strategy
			   INNER JOIN (
						SELECT parent_entity_id entity_id
						FROM   portfolio_hierarchy
						WHERE  entity_id = @fas_strategy_id
					) stra
					ON  strategy.parent_entity_id = stra.entity_id
		WHERE  strategy.entity_name = @fas_strategy_name
			   AND strategy.entity_id <> @fas_strategy_id
	)
	BEGIN
		--select @tmp_strategy=entity_name from portfolio_hierarchy where hierarchy_level =1  and  
		SELECT @tmp_subsidiary = stra.entity_name
		FROM   portfolio_hierarchy strategy
			INNER JOIN portfolio_hierarchy stra
				 ON  stra.entity_id = strategy.parent_entity_id
		WHERE  strategy.entity_id = @fas_strategy_id

		SET @stmt = 'The strategy ''' + @fas_strategy_name + ''' already exists under subsidiary ''' + @tmp_subsidiary + '''.'

		EXEC spa_ErrorHandler -1,
		     @stmt,
		     'spa_strategy',
		     'DB Error',
		     @stmt,
		     ''

		RETURN
	END
	
	SELECT @total_book = COUNT(*)
	FROM   portfolio_hierarchy
	WHERE  parent_entity_id = @fas_strategy_id 
--	if @total_book>1 and ((@mes_gran_value_id=178 and @hedge_type_value_id=150)
--		or  @hedge_type_value_id=151 or @no_links='y')
--	begin
--		Exec spa_ErrorHandler -1, 'Strategy', 
--				'spa_strategy', 'Error', 
--				'For Cash Flow Hedges using measurement granularity at Strategy level, only one book is allowed.',
--			'For Cash Flow Hedges using measurement granularity at Strategy level, only one book is allowed.'
--			return
--	end 


	SELECT 'p' AS TYPE,
	       portfolio_hierarchy.entity_name AS [entity_name],
	       fas_strategy_id,
	       source_system_id,
	       hedge_type_value_id,
	       fx_hedge_flag,
	       mes_gran_value_id,
	       no_links,
	       gl_grouping_value_id,
	       no_links_fas_eff_test_profile_id,
	       mes_cfv_value_id,
	       mes_cfv_values_value_id,
	       mismatch_tenor_value_id,
	       strip_trans_value_id,
	       asset_liab_calc_value_id,
	       test_range_from,
	       test_range_to,
	       additional_test_range_from,
	       additional_test_range_to,
	       include_unlinked_hedges,
	       include_unlinked_items,
	       gl_number_id_st_asset,
	       gl_number_id_st_liab,
	       gl_number_id_lt_asset,
	       gl_number_id_lt_liab,
	       gl_number_id_item_st_asset,
	       gl_number_id_item_st_liab,
	       gl_number_id_item_lt_asset,
	       gl_number_id_item_lt_liab,
	       gl_number_id_aoci,
	       gl_number_id_pnl,
	       gl_number_id_set,
	       gl_number_id_cash,
	       oci_rollout_approach_value_id,
	       additional_test_range_from2,
	       additional_test_range_to2,
	       gl_number_id_inventory,
	       options_premium_approach,
	       gl_id_amortization,
	       gl_id_interest
	       
	       INTO #temp_fas_strategy
	FROM   fas_strategy
	       INNER JOIN portfolio_hierarchy
	            ON  portfolio_hierarchy.entity_id = fas_strategy.fas_strategy_id
	WHERE  fas_strategy_id = @fas_strategy_id

	
	UPDATE portfolio_hierarchy
	SET    entity_name = @fas_strategy_name
	WHERE  entity_id = @fas_strategy_id
	
	UPDATE fas_strategy
	SET    source_system_id = @source_system_id,
	       hedge_type_value_id = @hedge_type_value_id,
	       fx_hedge_flag = @fx_hedge_flag,
	       mes_gran_value_id = @mes_gran_value_id,
	       gl_grouping_value_id = @gl_grouping_value_id,
	       no_links = @no_links,
	       no_links_fas_eff_test_profile_id = @no_links_fas_eff_test_profile_id,
	       mes_cfv_value_id = @mes_cfv_value_id,
	       mes_cfv_values_value_id = @mes_cfv_values_value_id,
	       mismatch_tenor_value_id = @mismatch_tenor_value_id,
	       strip_trans_value_id = @strip_trans_value_id,
	       asset_liab_calc_value_id = ISNULL(@asset_liab_calc_value_id, 277),
	       test_range_from = @test_range_from,
	       test_range_to = @test_range_to,
	       include_unlinked_hedges = @include_unlinked_hedges,
	       include_unlinked_items = @include_unlinked_items,
	       gl_number_id_st_asset = @gl_number_id_st_asset,
	       gl_number_id_st_liab = @gl_number_id_st_liab,
	       gl_number_id_lt_asset = @gl_number_id_lt_asset,
	       gl_number_id_lt_liab = @gl_number_id_lt_liab,
	       gl_number_id_item_st_asset = @gl_number_id_item_st_asset,
	       gl_number_id_item_st_liab = @gl_number_id_item_st_liab,
	       gl_number_id_item_lt_asset = @gl_number_id_item_lt_asset,
	       gl_number_id_item_lt_liab = @gl_number_id_item_lt_liab,
	       gl_number_id_aoci = @gl_number_id_aoci,
	       gl_number_id_pnl = @gl_number_id_pnl,
	       gl_number_id_set = @gl_number_id_set,
	       gl_number_id_cash = @gl_number_id_cash,
	       oci_rollout_approach_value_id = @oci_rollout_approach_value_id,
	       additional_test_range_from2 = @test_range_from2,
	       additional_test_range_to2 = @test_range_to2,
	       additional_test_range_from = @additional_test_range_from,
	       additional_test_range_to = @additional_test_range_to,
	       gl_number_id_inventory = @gl_number_id_inventory,
	       options_premium_approach = @options_premium_approach,
	       gl_id_amortization = @gl_number_id_amortization,
	       gl_id_interest = @gl_number_id_interest,
	       gl_number_id_expense = @gl_number_id_expense,
	       gl_number_id_gross_set = @gl_number_id_gross_set,
	       subentity_name = @subentity_name,
	       subentity_desc = @subentity_desc,
	       relationship_to_entity = @relationship_to_entity,
	       distinct_estimation_method = @distinct_estimation_method,
	       distinct_output_metrics = @distinct_output_metrics,
	       distinct_foreign_country = @distinct_foreign_country,
	       primary_naics_code_id = @primary_naics_code_id,
	       secondary_naics_code_id = @secondary_naics_code_id,
	       organization_boundary_id = @organization_boundary_id,
	       sub_entity = @sub_entity,
	       rollout_per_type = @rollout_per_type,
	       gl_id_st_tax_asset = @gl_id_st_tax_asset,
	       gl_id_st_tax_liab = @gl_id_st_tax_liab,
	       gl_id_lt_tax_asset = @gl_id_lt_tax_asset,
	       gl_id_lt_tax_liab = @gl_id_lt_tax_liab,
	       gl_id_tax_reserve = @gl_id_tax_reserve,
	       first_day_pnl_threshold = @first_day_pnl_threshold,
	       gl_tenor_option = @gl_tenor_option,
	       fun_cur_value_id = @fun_cur_value_id,
	       gl_number_unhedged_der_st_asset=@gl_number_unhedged_der_st_asset,
			gl_number_unhedged_der_lt_asset=@gl_number_unhedged_der_lt_asset,
			gl_number_unhedged_der_st_liab=@gl_number_unhedged_der_st_liab,
			gl_number_unhedged_der_lt_liab=@gl_number_unhedged_der_lt_liab
	WHERE  fas_strategy_id = @fas_strategy_id

	IF @@ERROR <> 0
	    EXEC spa_ErrorHandler @@ERROR,
	         "Strategy",
	         "spa_strategy",
	         "DB Error",
	         "Update of Strategy Property Data failed.",
	         ''
	ELSE
	    EXEC spa_ErrorHandler 0,
	         'Strategy',
	         'spa_strategy',
	         'Success',
	         'Strategy properties sucessfully Updated',
	         ''

	INSERT INTO #temp_fas_strategy
	SELECT 'c' AS TYPE,
	       portfolio_hierarchy.entity_name AS [entity_name],
	       fas_strategy_id,
	       source_system_id,
	       hedge_type_value_id,
	       fx_hedge_flag,
	       mes_gran_value_id,
	       no_links,
	       gl_grouping_value_id,
	       no_links_fas_eff_test_profile_id,
	       mes_cfv_value_id,
	       mes_cfv_values_value_id,
	       mismatch_tenor_value_id,
	       strip_trans_value_id,
	       asset_liab_calc_value_id,
	       test_range_from,
	       test_range_to,
	       additional_test_range_from,
	       additional_test_range_to,
	       include_unlinked_hedges,
	       include_unlinked_items,
	       gl_number_id_st_asset,
	       gl_number_id_st_liab,
	       gl_number_id_lt_asset,
	       gl_number_id_lt_liab,
	       gl_number_id_item_st_asset,
	       gl_number_id_item_st_liab,
	       gl_number_id_item_lt_asset,
	       gl_number_id_item_lt_liab,
	       gl_number_id_aoci,
	       gl_number_id_pnl,
	       gl_number_id_set,
	       gl_number_id_cash,
	       oci_rollout_approach_value_id,
	       additional_test_range_from2,
	       additional_test_range_to2,
	       gl_number_id_inventory,
	       options_premium_approach,
	       gl_id_amortization,
	       gl_id_interest
	FROM   fas_strategy
	       INNER JOIN portfolio_hierarchy
	            ON  portfolio_hierarchy.entity_id = fas_strategy.fas_strategy_id
	WHERE  fas_strategy_id = @fas_strategy_id
	
	-- exec spa_audit_trail '#temp_fas_strategy',@fas_strategy_id
END	
ELSE IF @flag = 'd'
 --BEGIN
 --    DELETE 
 --    FROM   fas_strategy
 --    WHERE  fas_strategy_id = @fas_strategy_id
     
 --    IF @@ERROR = 0
 --    BEGIN
 --        DELETE 
 --        FROM   portfolio_hierarchy
 --        WHERE  entity_id = @fas_strategy_id
 --    END
     
 --    IF @@ERROR <> 0
 --        EXEC spa_ErrorHandler @@ERROR,
 --             'Strategy',
 --             'spa_strategy',
 --             'DB Error',
 --             'Delete of Strategy Property Data failed.',
 --             ''
 --    ELSE
 --        EXEC spa_ErrorHandler 0,
 --             'Strategy',
 --             'spa_strategy',
 --             'Success',
 --             'Strategy properties sucessfully deleted',
 --             ''
 --END
BEGIN
	IF EXISTS(SELECT 1 FROM portfolio_hierarchy WHERE parent_entity_id = @fas_strategy_id)
    BEGIN
        EXEC spa_ErrorHandler 1,
             'Strategy Properties Properties',
             'spa_strategy',
             'DB Error',
             'Please delete all books for the selected Strategy first.',
             ''
        
        RETURN
    END
      
    BEGIN TRANSACTION
		DELETE an FROM application_notes an 
			INNER JOIN fas_strategy fs  ON fs.fas_strategy_id = ISNULL(an.parent_object_id, an.notes_object_id)
		WHERE an.internal_type_value_id = 26
			AND fs.fas_strategy_id = @fas_strategy_id

		UPDATE en SET notes_object_id = NULL 			
		FROM email_notes en
			INNER JOIN fas_strategy fs  ON CAST(fs.fas_strategy_id AS VARCHAR(50)) = en.notes_object_id
		WHERE en.internal_type_value_id = 26
			AND fs.fas_strategy_id = @fas_strategy_id

		DELETE 
		FROM   fas_strategy
		WHERE  fas_strategy_id = @fas_strategy_id
       
		IF @@ERROR <> 0
		BEGIN
			EXEC spa_ErrorHandler @@ERROR,
			'Strategy',
			'spa_strategy',
			'DB Error',
			'Delete of Strategy Property Data failed.',
			''
        
			ROLLBACK TRANSACTION
		END
		ELSE
		BEGIN
			DELETE 
			FROM   portfolio_hierarchy
			WHERE  entity_id = @fas_strategy_id		
        
			IF @@ERROR <> 0
			BEGIN
				EXEC spa_ErrorHandler @@ERROR,
                'Book Properties',
                'spa_books',
                'DB Error',
                'Failed to delete book properties.',
                ''
           
				ROLLBACK TRANSACTION
			END
			ELSE
			BEGIN
				EXEC spa_ErrorHandler 0,
				'Strategy',
				'spa_strategy',
				'DB Error',
				'Changes have been saved successfully.',
				''
           
				COMMIT TRANSACTION
			END
		END
END













