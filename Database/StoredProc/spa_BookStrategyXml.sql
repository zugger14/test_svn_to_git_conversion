
IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_BookStrategyXml]') AND TYPE IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_BookStrategyXml]
	
/**
 Stored Procedure to Insert/Update data in fas_strategy. 
 Parameters
	@flag : Operation flag optional
			i - insert data in fas_strategy.  
			u - update data in fas_strategy.			
	@xml : xml data.
*/
 
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_BookStrategyXml]
	@flag CHAR(1),
	@xml NVARCHAR(MAX) 

AS

SET NOCOUNT ON
--DECLARE @fas_strategy_id INT 

BEGIN TRY 
	DECLARE @id INT 
	DECLARE @idoc INT
	DECLARE @doc NVARCHAR(1000)
	
	EXEC sp_xml_preparedocument @idoc OUTPUT, @xml
	
	SELECT 
		NULLIF(ID, '') ID
		, NULLIF(fas_strategy_id,'') fas_strategy_id
		, NULLIF(source_system_id,'') source_system_id
		, NULLIF([entity_name],'') [entity_name]
		, NULLIF(fun_cur_value_id,'') fun_cur_value_id
		, NULLIF(hedge_type_value_id ,'') hedge_type_value_id
		, NULLIF(no_links_fas_eff_test_profile_id,'') no_links_fas_eff_test_profile_id
		, NULLIF(label_no_links_fas_eff_test_profile_id,'') label_no_links_fas_eff_test_profile_id
		, NULLIF(mes_gran_value_id ,'') mes_gran_value_id
		, NULLIF(mismatch_tenor_value_id,'') mismatch_tenor_value_id
		, NULLIF(gl_grouping_value_id,'') gl_grouping_value_id
		, NULLIF(rollout_per_type,'') rollout_per_type
		, NULLIF(mes_cfv_value_id,'') mes_cfv_value_id
		, NULLIF(strip_trans_value_id,'') strip_trans_value_id
		, NULLIF(mes_cfv_values_value_id ,'') mes_cfv_values_value_id
		, NULLIF(oci_rollout_approach_value_id,'') oci_rollout_approach_value_id
		, NULLIF(test_range_from,'') test_range_from
		, NULLIF(additional_test_range_from,'') additional_test_range_from
		, NULLIF(test_range_to,'') test_range_to
		, NULLIF(additional_test_range_to,'') additional_test_range_to
		, NULLIF(test_range_from2,'') test_range_from2
		, NULLIF(test_range_to2 ,'') test_range_to2
		, NULLIF(first_day_pnl_threshold ,'') first_day_pnl_threshold
		, NULLIF(gl_tenor_option,'') gl_tenor_option
		, NULLIF(fx_hedge_flag,'') fx_hedge_flag
		, NULLIF(include_unlinked_hedges ,'') include_unlinked_hedges
		, NULLIF(no_links ,'') no_links
		, NULLIF(include_unlinked_items,'') include_unlinked_items
		, NULLIF(gl_number_id_st_asset,'') gl_number_id_st_asset
		, NULLIF(gl_number_id_lt_asset ,'') gl_number_id_lt_asset
		, NULLIF(gl_number_id_st_liab,'') gl_number_id_st_liab
		, NULLIF(gl_number_id_lt_liab,'') gl_number_id_lt_liab
		, NULLIF(gl_id_st_tax_asset,'') gl_id_st_tax_asset
		, NULLIF(gl_id_lt_tax_asset,'') gl_id_lt_tax_asset
		, NULLIF(gl_id_st_tax_liab ,'') gl_id_st_tax_liab
		, NULLIF(gl_id_lt_tax_liab ,'') gl_id_lt_tax_liab
		, NULLIF(gl_id_tax_reserve ,'') gl_id_tax_reserve
		, NULLIF(gl_number_id_aoci ,'') gl_number_id_aoci
		, NULLIF(gl_number_id_inventory,'') gl_number_id_inventory
		, NULLIF(gl_number_id_pnl,'') gl_number_id_pnl 
		, NULLIF(gl_number_id_set,'') gl_number_id_set
		, NULLIF(gl_number_id_cash ,'') gl_number_id_cash 
		, NULLIF(gl_number_id_gross_set,'') gl_number_id_gross_set
		, NULLIF(subentity_name ,'') subentity_name
		, NULLIF(subentity_desc ,'') subentity_desc
		, NULLIF(relationship_to_entity,'') relationship_to_entity
		, NULLIF(distinct_estimation_method,'') distinct_estimation_method
		, NULLIF(distinct_output_metrics ,'') distinct_output_metrics
		, NULLIF(distinct_foreign_country,'') distinct_foreign_country
		, NULLIF(primary_naics_code_id ,'') primary_naics_code_id
		, NULLIF(secondary_naics_code_id ,'') secondary_naics_code_id
		, NULLIF(organization_boundary_id,'') organization_boundary_id
		, NULLIF(asset_liab_calc_value_id,'') asset_liab_calc_value_id
		, NULLIF(sub_entity ,'') sub_entity
		, NULLIF(gl_number_id_item_st_asset, '') gl_number_id_item_st_asset
		, NULLIF(gl_number_id_item_st_liab, '') gl_number_id_item_st_liab
		, NULLIF(gl_number_id_item_lt_asset, '') gl_number_id_item_lt_asset
		, NULLIF(gl_number_id_item_lt_liab, '')  gl_number_id_item_lt_liab
		, NULLIF(gl_number_unhedged_der_st_asset, '') gl_number_unhedged_der_st_asset
		, NULLIF(gl_number_unhedged_der_lt_asset, '') gl_number_unhedged_der_lt_asset
		, NULLIF(gl_number_unhedged_der_st_liab, '') gl_number_unhedged_der_st_liab
		, NULLIF(gl_number_unhedged_der_lt_liab, '') gl_number_unhedged_der_lt_liab
		, NULLIF(gl_id_amortization, '') gl_id_amortization
		, NULLIF(gl_id_interest, '') gl_id_interest
		, NULLIF(gl_number_id_expense, '') gl_number_id_expense
		, NULLIF (primary_counterparty_id, '') primary_counterparty_id
		, NULLIF (accounting_code, '') accounting_code
	INTO #ztbl_xmlvalue
	
	FROM OPENXML (@idoc, '/Root/FormXML', 2)
		 WITH (	ID INT '@ID', 
		 		fas_strategy_id  INT  '@fas_strategy_id',
				 source_system_id  INT '@source_system_id',
				 [entity_name] NVARCHAR(100) '@entity_name',
				 --parent_entity_id INT '@parent_entity_id',
				 fun_cur_value_id INT '@fun_cur_value_id',
				 hedge_type_value_id INT '@hedge_type_value_id',
				 no_links_fas_eff_test_profile_id  NVARCHAR(50) '@no_links_fas_eff_test_profile_id',
				 label_no_links_fas_eff_test_profile_id INT '@no_links_fas_eff_test_profile_id',
				 mes_gran_value_id INT '@mes_gran_value_id',
				 mismatch_tenor_value_id INT '@mismatch_tenor_value_id',
				 gl_grouping_value_id INT '@gl_grouping_value_id',
				 rollout_per_type INT '@rollout_per_type',
				 mes_cfv_value_id INT '@mes_cfv_value_id',
				 strip_trans_value_id INT '@strip_trans_value_id',
				 mes_cfv_values_value_id INT '@mes_cfv_values_value_id',
				 oci_rollout_approach_value_id INT '@oci_rollout_approach_value_id',
				 test_range_from NVARCHAR(20) '@test_range_from',
				 additional_test_range_from NVARCHAR(20) '@additional_test_range_from',
				 test_range_to NVARCHAR(20) '@test_range_to',
				 additional_test_range_to NVARCHAR(20) '@additional_test_range_to',
				 test_range_from2 NVARCHAR(20) '@test_range_from2',
				 test_range_to2 NVARCHAR(20) '@test_range_to2',
				 first_day_pnl_threshold NVARCHAR(20) '@first_day_pnl_threshold',
				 gl_tenor_option CHAR(1) '@gl_tenor_option',
				 fx_hedge_flag CHAR(1) '@fx_hedge_flag',
				 include_unlinked_hedges CHAR(1) '@include_unlinked_hedges',
				 no_links CHAR(1) '@no_links',
				 include_unlinked_items CHAR(1) '@include_unlinked_items',
				 gl_number_id_st_asset INT '@gl_number_id_st_asset',
				 gl_number_id_lt_asset INT '@gl_number_id_lt_asset',
				 gl_number_id_st_liab INT '@gl_number_id_st_liab',
				 gl_number_id_lt_liab INT '@gl_number_id_lt_liab',
				 gl_id_st_tax_asset INT '@gl_id_st_tax_asset',
				 gl_id_lt_tax_asset INT '@gl_id_lt_tax_asset',
				 gl_id_st_tax_liab INT '@gl_id_st_tax_liab',
				 gl_id_lt_tax_liab INT '@gl_id_lt_tax_liab',
				 gl_id_tax_reserve INT '@gl_id_tax_reserve',
				 gl_number_id_aoci INT '@gl_number_id_aoci',
				 gl_number_id_inventory INT '@gl_number_id_inventory',
				 gl_number_id_pnl INT '@gl_number_id_pnl',
				 gl_number_id_set INT '@gl_number_id_set',
				 gl_number_id_cash INT '@gl_number_id_cash',
				 gl_number_id_gross_set INT '@gl_number_id_gross_set',
				 subentity_name NVARCHAR(250) '@subentity_name',
				 subentity_desc NVARCHAR(1000) '@subentity_desc',
				 relationship_to_entity NVARCHAR(1000) '@relationship_to_entity',
				 distinct_estimation_method INT '@distinct_estimation_method',
				 distinct_output_metrics INT '@distinct_output_metrics',
				 distinct_foreign_country INT '@distinct_foreign_country',
				 primary_naics_code_id INT '@primary_naics_code_id',
				 secondary_naics_code_id INT '@secondary_naics_code_id',
				 organization_boundary_id INT '@organization_boundary_id',
				 asset_liab_calc_value_id INT '@asset_liab_calc_value_id',
				 sub_entity CHAR(1) '@sub_entity',
		         gl_number_id_item_st_asset INT '@gl_number_id_item_st_asset', 
		         gl_number_id_item_st_liab INT '@gl_number_id_item_st_liab',
		         gl_number_id_item_lt_asset INT '@gl_number_id_item_lt_asset',
		         gl_number_id_item_lt_liab INT '@gl_number_id_item_lt_liab',
		         gl_number_unhedged_der_st_asset INT '@gl_number_unhedged_der_st_asset',
		         gl_number_unhedged_der_lt_asset INT '@gl_number_unhedged_der_lt_asset',
		         gl_number_unhedged_der_st_liab INT '@gl_number_unhedged_der_st_liab',
		         gl_number_unhedged_der_lt_liab INT '@gl_number_unhedged_der_lt_liab',
		         gl_id_amortization INT '@gl_id_amortization',
		         gl_id_interest INT '@gl_id_interest',
		         gl_number_id_expense INT '@gl_number_id_expense',
				 primary_counterparty_id INT '@primary_counterparty_id',
				 accounting_code VARCHAR(500) '@accounting_code'
				 )
	
	IF @flag IN ('i', 'u')
	BEGIN
		--PRINT 'Merge'
		BEGIN TRAN
		
		MERGE portfolio_hierarchy ph
		USING (SELECT [entity_name],ID,fas_strategy_id
		FROM #ztbl_xmlvalue) zxv ON ph.[entity_id] = zxv.fas_strategy_id
				
	
		WHEN NOT MATCHED BY TARGET THEN
		INSERT ([entity_name],hierarchy_level,entity_type_value_id,parent_entity_id)
		VALUES ( zxv.[entity_name],1,526,zxv.ID )
		WHEN MATCHED THEN
		UPDATE SET	 ph.[entity_name] = zxv.[entity_name];
		set @id = SCOPE_IDENTITY()
			

		MERGE fas_strategy AS fs
		USING (
			SELECT fas_strategy_id,
				 source_system_id,
				 fun_cur_value_id,
				 hedge_type_value_id,				 
				 asset_liab_calc_value_id,
				 no_links_fas_eff_test_profile_id,
				 mes_gran_value_id,
				 mismatch_tenor_value_id,
				 gl_grouping_value_id,
				 rollout_per_type,
				 mes_cfv_value_id,
				 strip_trans_value_id,
				 mes_cfv_values_value_id,
				 oci_rollout_approach_value_id,
				 test_range_from,
				 additional_test_range_from,
				 test_range_to,
				 additional_test_range_to,
				 test_range_from2,
				 test_range_to2,
				 first_day_pnl_threshold,
				 gl_tenor_option,
				 fx_hedge_flag,
				 include_unlinked_hedges,
				 no_links,
				 include_unlinked_items,
				 gl_number_id_st_asset,
				 gl_number_id_lt_asset,
				 gl_number_id_st_liab,
				 gl_number_id_lt_liab,
				 gl_id_st_tax_asset,
				 gl_id_lt_tax_asset,
				 gl_id_st_tax_liab,
				 gl_id_lt_tax_liab,
				 gl_id_tax_reserve,
				 gl_number_id_aoci,
				 gl_number_id_inventory,
				 gl_number_id_pnl,
				 gl_number_id_set,
				 gl_number_id_cash,
				 gl_number_id_gross_set,
				 gl_number_id_item_st_asset, 
		         gl_number_id_item_st_liab,
		         gl_number_id_item_lt_asset,
		         gl_number_id_item_lt_liab,
		         gl_number_unhedged_der_st_asset,
		         gl_number_unhedged_der_lt_asset,
		         gl_number_unhedged_der_st_liab,
		         gl_number_unhedged_der_lt_liab,
		         gl_id_amortization,
		         gl_id_interest,
		         gl_number_id_expense, 
				 primary_counterparty_id,
				 accounting_code
			FROM #ztbl_xmlvalue) zxv ON fs.fas_strategy_id = zxv.fas_strategy_id
			
			WHEN NOT MATCHED BY TARGET THEN
				INSERT (
				fas_strategy_id,
				 source_system_id  ,
				 fun_cur_value_id ,
				 hedge_type_value_id,
				 asset_liab_calc_value_id,
				 no_links_fas_eff_test_profile_id,
				 mes_gran_value_id,
				 mismatch_tenor_value_id,
				 gl_grouping_value_id,
				 rollout_per_type,
				 mes_cfv_value_id,
				 strip_trans_value_id,
				 mes_cfv_values_value_id,
				 oci_rollout_approach_value_id,
				 test_range_from,
				 additional_test_range_from,
				 test_range_to,
				 additional_test_range_to,
				 additional_test_range_from2,
				 additional_test_range_to2,
				 first_day_pnl_threshold,
				 gl_tenor_option,
				 fx_hedge_flag,
				 include_unlinked_hedges,
				 no_links,
				 include_unlinked_items,
				 gl_number_id_st_asset,
				 gl_number_id_lt_asset,
				 gl_number_id_st_liab,
				 gl_number_id_lt_liab,
				 gl_id_st_tax_asset,
				 gl_id_lt_tax_asset,
				 gl_id_st_tax_liab,
				 gl_id_lt_tax_liab,
				 gl_id_tax_reserve,
				 gl_number_id_aoci,
				 gl_number_id_inventory,
				 gl_number_id_pnl,
				 gl_number_id_set,
				 gl_number_id_cash,
				 gl_number_id_gross_set,
				 gl_number_id_item_st_asset, 
		         gl_number_id_item_st_liab,
		         gl_number_id_item_lt_asset,
		         gl_number_id_item_lt_liab,
		         gl_number_unhedged_der_st_asset,
		         gl_number_unhedged_der_lt_asset,
		         gl_number_unhedged_der_st_liab,
		         gl_number_unhedged_der_lt_liab,
		         gl_id_amortization,
		         gl_id_interest,
		         gl_number_id_expense,
				 primary_counterparty_id,
				 accounting_code
				)
				VALUES (
					@id,
				 zxv.source_system_id,
				 zxv.fun_cur_value_id,
				 zxv.hedge_type_value_id,
				 277,
				 zxv.no_links_fas_eff_test_profile_id,
				 zxv.mes_gran_value_id,
				 zxv.mismatch_tenor_value_id,
				 zxv.gl_grouping_value_id,
				 zxv.rollout_per_type,
				 zxv.mes_cfv_value_id,
				 zxv.strip_trans_value_id,
				 zxv.mes_cfv_values_value_id,
				 zxv.oci_rollout_approach_value_id,
				 zxv.test_range_from,
				 zxv.additional_test_range_from,
				 zxv.test_range_to,
				 zxv.additional_test_range_to,
				 zxv.test_range_from2,
				 zxv.test_range_to2,
				 zxv.first_day_pnl_threshold,
				 zxv.gl_tenor_option,
				 zxv.fx_hedge_flag,
				 zxv.include_unlinked_hedges,
				 zxv.no_links,
				 zxv.include_unlinked_items,
				 zxv.gl_number_id_st_asset,
				 zxv.gl_number_id_lt_asset,
				 zxv.gl_number_id_st_liab,
				 zxv.gl_number_id_lt_liab,
				 zxv.gl_id_st_tax_asset,
				 zxv.gl_id_lt_tax_asset,
				 zxv.gl_id_st_tax_liab,
				 zxv.gl_id_lt_tax_liab,
				 zxv.gl_id_tax_reserve,
				 zxv.gl_number_id_aoci,
				 zxv.gl_number_id_inventory,
				 zxv.gl_number_id_pnl,
				 zxv.gl_number_id_set,
				 zxv.gl_number_id_cash,
				 zxv.gl_number_id_gross_set,
				 zxv.gl_number_id_item_st_asset, 
		         zxv.gl_number_id_item_st_liab,
		         zxv.gl_number_id_item_lt_asset,
		         zxv.gl_number_id_item_lt_liab,
		         zxv.gl_number_unhedged_der_st_asset,
		         zxv.gl_number_unhedged_der_lt_asset,
		         zxv.gl_number_unhedged_der_st_liab,
		         zxv.gl_number_unhedged_der_lt_liab,
		         zxv.gl_id_amortization,
		         zxv.gl_id_interest,
		         zxv.gl_number_id_expense,
				 zxv.primary_counterparty_id,
				 zxv.accounting_code
				)
			WHEN MATCHED THEN
				UPDATE SET
				 fun_cur_value_id = zxv.fun_cur_value_id ,
				 hedge_type_value_id = zxv.hedge_type_value_id,
				 asset_liab_calc_value_id = 277,
				 no_links_fas_eff_test_profile_id = zxv.no_links_fas_eff_test_profile_id,
				 mes_gran_value_id = zxv.mes_gran_value_id,
				 mismatch_tenor_value_id = zxv.mismatch_tenor_value_id,
				 gl_grouping_value_id =  zxv.gl_grouping_value_id,
				 rollout_per_type = zxv.rollout_per_type,
				 mes_cfv_value_id = zxv.mes_cfv_value_id,
				 strip_trans_value_id = zxv.strip_trans_value_id,
				 mes_cfv_values_value_id = zxv.mes_cfv_values_value_id,
				 oci_rollout_approach_value_id = zxv.oci_rollout_approach_value_id,
				 test_range_from = zxv.test_range_from,
				 additional_test_range_from = zxv.additional_test_range_from,
				 test_range_to = zxv.test_range_to,
				 additional_test_range_to =  zxv.additional_test_range_to,
				 additional_test_range_from2 = zxv.test_range_from2,
				 additional_test_range_to2 = zxv.test_range_to2,
				 first_day_pnl_threshold = zxv.first_day_pnl_threshold,
				 gl_tenor_option = zxv.gl_tenor_option,
				 fx_hedge_flag = zxv.fx_hedge_flag,
				 include_unlinked_hedges = zxv.include_unlinked_hedges,
				 no_links = zxv.no_links,
				 include_unlinked_items = zxv.include_unlinked_items,

				 gl_number_id_st_asset = zxv.gl_number_id_st_asset,
				 gl_number_id_lt_asset = zxv.gl_number_id_lt_asset,
				 gl_number_id_st_liab = zxv.gl_number_id_st_liab,
				 gl_number_id_lt_liab = zxv.gl_number_id_lt_liab,
				 gl_id_st_tax_asset = zxv.gl_id_st_tax_asset,
				 gl_id_lt_tax_asset = zxv.gl_id_lt_tax_asset,
				 gl_id_st_tax_liab = zxv.gl_id_st_tax_liab,
				 gl_id_lt_tax_liab = zxv.gl_id_lt_tax_liab,
				 gl_id_tax_reserve = zxv.gl_id_tax_reserve,
				 gl_number_id_aoci =  zxv.gl_number_id_aoci,
				 gl_number_id_inventory = zxv.gl_number_id_inventory,
				 gl_number_id_pnl = zxv.gl_number_id_pnl,
				 gl_number_id_set = zxv.gl_number_id_set,
				 gl_number_id_cash = zxv.gl_number_id_cash,
				 gl_number_id_gross_set = zxv.gl_number_id_gross_set,

				 gl_number_id_item_st_asset = zxv.gl_number_id_item_st_asset, 
		         gl_number_id_item_st_liab = zxv.gl_number_id_item_st_liab,
		         gl_number_id_item_lt_asset = zxv.gl_number_id_item_lt_asset,
		         gl_number_id_item_lt_liab = zxv.gl_number_id_item_lt_liab,
		         gl_number_unhedged_der_st_asset = zxv.gl_number_unhedged_der_st_asset,
		         gl_number_unhedged_der_lt_asset = zxv.gl_number_unhedged_der_lt_asset,
		         gl_number_unhedged_der_st_liab = zxv.gl_number_unhedged_der_st_liab,
		         gl_number_unhedged_der_lt_liab = zxv.gl_number_unhedged_der_lt_liab,
		         gl_id_amortization = zxv.gl_id_amortization,
		         gl_id_interest = zxv.gl_id_interest,
		         gl_number_id_expense = zxv.gl_number_id_expense,
				 primary_counterparty_id = zxv.primary_counterparty_id,
				 accounting_code = zxv.accounting_code;
				 ;		
	  --SELECT @fas_strategy_id = fas_strategy_id FROM #ztbl_xmlvalue
		--SELECT * FROM portfolio_hierarchy AS ph
		--SELECT * FROM fas_strategy AS fs
		
		
	--	EXEC dbo.spa_generate_hour_block_term 300501@block_value_id, NULL, NULL
		IF @id IS NULL
			SELECT @id = fas_strategy_id FROM #ztbl_xmlvalue

		--Release Bookstructure cache key.
		IF  EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_manage_memcache]') AND TYPE IN (N'P', N'PC'))
		BEGIN
			EXEC [spa_manage_memcache] @flag = 'd', @other_key_source='BookStructure', @source_object = 'spa_BookStrategyXml @flag=iu'
		END

		EXEC spa_ErrorHandler 0
			, 'Source Deal Detail'
			, 'spa_getXml'
			, 'Success'
			, 'Changes have been saved successfully.'
			, @id				

		COMMIT
		
		--Logic to move the GL Code mapping corresponding to the Hierarchy levels
		DECLARE @gl_grouping_value_id INT,
				@fas_strategy_id INT,
				@process_table NVARCHAR(500)
		
		SET @process_table = dbo.FNAProcessTableName('map_gl_codes', dbo.FNADbUser(), REPLACE(NEWID(), '-', '_'))
		
		EXEC(
			'SELECT first_day_pnl_threshold AS gl_first_day_pnl,
					gl_number_id_item_st_asset,
					gl_number_id_item_st_liab,
					gl_number_id_item_lt_asset,
					gl_number_id_item_lt_liab,
					gl_number_unhedged_der_st_asset,
					gl_number_unhedged_der_lt_asset,
					gl_number_unhedged_der_st_liab,
					gl_number_unhedged_der_lt_liab,
					gl_id_amortization,
					gl_id_interest,
					gl_number_id_expense,
					gl_number_id_st_asset,
					gl_number_id_lt_asset,
					gl_number_id_st_liab,
					gl_number_id_lt_liab,
					gl_id_st_tax_asset,
					gl_id_lt_tax_asset,
					gl_id_st_tax_liab,
					gl_id_lt_tax_liab,
					gl_id_tax_reserve,
					gl_number_id_aoci,
					gl_number_id_inventory,
					gl_number_id_pnl,
					gl_number_id_set,
					gl_number_id_cash,
					gl_number_id_gross_set,
					gl_tenor_option			    
			INTO ' + @process_table + '
			FROM #ztbl_xmlvalue'
		)
		SELECT @gl_grouping_value_id = gl_grouping_value_id,
			   @fas_strategy_id = fas_strategy_id
		FROM #ztbl_xmlvalue
	
		EXEC [dbo].[spa_shift_map_gl_codes] @fas_strategy_id, @gl_grouping_value_id, @process_table
	END
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK
		
	DECLARE @msg NVARCHAR(4000)
	--SELECT @msg = 'Strategy name must be unique.'--'Failed Inserting record (' + ERROR_MESSAGE() + ').'
	--SELECT @msg = 'Invalid Number below Test Range to 1 text box field.'--'Failed Inserting record (' + ERROR_MESSAGE() + ').'
	SELECT @msg = 'Duplicate value in (<b>Strategy</b>).'

	EXEC spa_ErrorHandler -1
		, 'Source Deal Detail'
		, 'spa_UpdateBookStrategyXml'
		, 'DB Error'
		, @msg
		, 'Failed Inserting Record'
END CATCH