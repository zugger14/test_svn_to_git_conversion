IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_UpdateBookStrategyXml]') AND TYPE IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_UpdateBookStrategyXml]

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_UpdateBookStrategyXml]
	@flag CHAR(1),
	@xml TEXT 

AS

SET NOCOUNT ON
--DECLARE @fas_strategy_id INT 

BEGIN TRY
	DECLARE @id INT 
	DECLARE @idoc INT
	DECLARE @doc VARCHAR(1000)

	EXEC sp_xml_preparedocument @idoc OUTPUT, @xml
	
	SELECT * INTO #ztbl_xmlvalue
	
	FROM OPENXML (@idoc, '/Root/FormXML', 2)
		 WITH (	ID INT '@ID', 
		 		fas_strategy_id  INT  '@fas_strategy_id',
				 source_system_id  INT '@source_system_id',
				 [entity_name] VARCHAR(100) '@entity_name',
				 --parent_entity_id INT '@parent_entity_id',
				 fun_cur_value_id INT '@fun_cur_value_id',
				 hedge_type_value_id INT '@hedge_type_value_id',
				 no_links_fas_eff_test_profile_id  INT '@no_links_fas_eff_test_profile_id',
				 label_no_links_fas_eff_test_profile_id INT '@no_links_fas_eff_test_profile_id',
				 mes_gran_value_id INT '@mes_gran_value_id',
				 mismatch_tenor_value_id INT '@mismatch_tenor_value_id',
				 gl_grouping_value_id INT '@gl_grouping_value_id',
				 rollout_per_type INT '@rollout_per_type',
				 mes_cfv_value_id INT '@mes_cfv_value_id',
				 strip_trans_value_id INT '@strip_trans_value_id',
				 mes_cfv_values_value_id INT '@mes_cfv_values_value_id',
				 oci_rollout_approach_value_id INT '@oci_rollout_approach_value_id',
				 test_range_from FLOAT '@test_range_from',
				 additional_test_range_from FLOAT '@additional_test_range_from',
				 test_range_to FLOAT '@test_range_to',
				 additional_test_range_to FLOAT '@additional_test_range_to',
				 test_range_from2 FLOAT '@test_range_from2',
				 test_range_to2 FLOAT '@test_range_to2',
				 first_day_pnl_threshold INT '@first_day_pnl_threshold',
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
				 subentity_name VARCHAR(250) '@subentity_name',
				 subentity_desc VARCHAR(1000) '@subentity_desc',
				 relationship_to_entity VARCHAR(1000) '@relationship_to_entity',
				 distinct_estimation_method INT '@distinct_estimation_method',
				 distinct_output_metrics INT '@distinct_output_metrics',
				 distinct_foreign_country INT '@distinct_foreign_country',
				 primary_naics_code_id INT '@primary_naics_code_id',
				 secondary_naics_code_id INT '@secondary_naics_code_id',
				 organization_boundary_id INT '@organization_boundary_id',
				 asset_liab_calc_value_id INT 'asset_liab_calc_value_id',
				 sub_entity CHAR(1)  '@sub_entity' )

				 --SELECT * FROM #ztbl_xmlvalue

	 
	

	--DECLARE @idoc2 INT
	--DECLARE @doc2 VARCHAR(1000)

	--EXEC sp_xml_preparedocument @idoc2 OUTPUT, @xmlValue2

	-------------------------------------------------------------------
	--SELECT * INTO #ztbl_xmlvalue2
	--FROM OPENXML (@idoc2, '/Root/PSRecordset', 2)
	--	WITH (entity_name  VARCHAR(100) '@fas_strategy_name')
	--	SELECT * FROM #ztbl_xmlvalue2		
	
	
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
				 hedge_type_value_id
				 --no_links_fas_eff_test_profile_id,
				 ----label_no_links_fas_eff_test_profile_id,
				 --mes_gran_value_id ,
				 --mismatch_tenor_value_id ,
				 --gl_grouping_value_id ,
				 --rollout_per_type ,
				 --mes_cfv_value_id ,
				 --strip_trans_value_id ,
				 --mes_cfv_values_value_id ,
				 --oci_rollout_approach_value_id ,
				 --test_range_from,
				 --additional_test_range_from ,
				 --test_range_to ,
				 --additional_test_range_to ,
				 --test_range_from2 ,
				 --test_range_to2 ,
				 --first_day_pnl_threshold ,
				 --gl_tenor_option ,
				 --fx_hedge_flag ,
				 --include_unlinked_hedges ,
				 --no_links ,
				 --include_unlinked_items ,
				 --gl_number_id_st_asset ,
				 --gl_number_id_lt_asset ,
				 --gl_number_id_st_liab ,
				 --gl_number_id_lt_liab ,
				 --gl_id_st_tax_asset ,
				 --gl_id_lt_tax_asset ,
				 --gl_id_st_tax_liab ,
				 --gl_id_lt_tax_liab ,
				 --gl_id_tax_reserve ,
				 --gl_number_id_aoci ,
				 --gl_number_id_inventory ,
				 --gl_number_id_pnl,
				 --gl_number_id_set ,
				 --gl_number_id_cash ,
				 --gl_number_id_gross_set ,
				 --subentity_name ,
				 --subentity_desc ,
				 --relationship_to_entity,
				 --distinct_estimation_method ,
				 --distinct_output_metrics ,
				 --distinct_foreign_country ,
				 --primary_naics_code_id ,
				 --secondary_naics_code_id ,
				 --organization_boundary_id,
				 --asset_liab_calc_value_id,
				 --sub_entity  
			FROM #ztbl_xmlvalue) zxv ON fs.fas_strategy_id = zxv.fas_strategy_id
			
			WHEN NOT MATCHED BY TARGET THEN
				INSERT (
				fas_strategy_id,
				 source_system_id  ,
				 fun_cur_value_id ,
				 hedge_type_value_id
				-- no_links_fas_eff_test_profile_id,
				----label_no_links_fas_eff_test_profile_id ,
				-- mes_gran_value_id ,
				-- mismatch_tenor_value_id ,
				-- gl_grouping_value_id ,
				-- rollout_per_type ,
				-- mes_cfv_value_id ,
				-- strip_trans_value_id ,
				-- mes_cfv_values_value_id ,
				-- oci_rollout_approach_value_id ,
				-- test_range_from,
				-- additional_test_range_from ,
				-- test_range_to ,
				-- additional_test_range_to ,
				-- additional_test_range_from2 ,
				-- additional_test_range_to2,
				-- first_day_pnl_threshold ,
				-- gl_tenor_option ,
				-- fx_hedge_flag ,
				-- include_unlinked_hedges ,
				-- no_links ,
				-- include_unlinked_items ,
				-- gl_number_id_st_asset ,
				-- gl_number_id_lt_asset ,
				-- gl_number_id_st_liab ,
				-- gl_number_id_lt_liab ,
				-- gl_id_st_tax_asset ,
				-- gl_id_lt_tax_asset ,
				-- gl_id_st_tax_liab ,
				-- gl_id_lt_tax_liab ,
				-- gl_id_tax_reserve ,
				-- gl_number_id_aoci ,
				-- gl_number_id_inventory ,
				-- gl_number_id_pnl,
				-- gl_number_id_set ,
				-- gl_number_id_cash ,
				-- gl_number_id_gross_set ,
				-- subentity_name ,
				-- subentity_desc ,
				-- relationship_to_entity,
				-- distinct_estimation_method ,
				-- distinct_output_metrics ,
				-- distinct_foreign_country ,
				-- primary_naics_code_id ,
				-- secondary_naics_code_id ,
				-- organization_boundary_id ,
				-- asset_liab_calc_value_id,
				-- sub_entity 
				)
				VALUES (
					@id,
				 zxv.source_system_id,
				 zxv.fun_cur_value_id,
				 zxv.hedge_type_value_id
				--2 ,
				-- --zxv.label_no_links_fas_eff_test_profile_id ,
				-- zxv.mes_gran_value_id ,
				-- zxv.mismatch_tenor_value_id ,
				-- zxv.gl_grouping_value_id ,
				-- zxv.rollout_per_type ,
				-- zxv. mes_cfv_value_id,
				-- zxv.strip_trans_value_id ,
				-- zxv.mes_cfv_values_value_id ,
				-- zxv.oci_rollout_approach_value_id ,
				-- zxv.test_range_from,
				-- zxv.additional_test_range_from ,
				-- zxv.test_range_to ,
				--zxv.additional_test_range_to ,
				-- zxv.test_range_from2 ,
				-- zxv.test_range_to2 ,
				--zxv.first_day_pnl_threshold ,
				--zxv.gl_tenor_option ,
				-- 'n' ,
				-- zxv.include_unlinked_hedges ,
				-- zxv.no_links ,
				-- zxv.include_unlinked_items ,
				-- zxv.gl_number_id_st_asset ,
				-- zxv.gl_number_id_lt_asset ,
				-- zxv.gl_number_id_st_liab ,
				-- zxv.gl_number_id_lt_liab ,
				-- zxv.gl_id_st_tax_asset ,
				-- zxv.gl_id_lt_tax_asset ,
				-- zxv.gl_id_st_tax_liab ,
				-- zxv.gl_id_lt_tax_liab ,
				-- zxv.gl_id_tax_reserve ,
				-- zxv.gl_number_id_aoci ,
				-- zxv.gl_number_id_inventory ,
				-- zxv.gl_number_id_pnl,
				-- zxv.gl_number_id_set ,
				-- zxv.gl_number_id_cash ,
				-- zxv.gl_number_id_gross_set ,
				-- zxv.subentity_name ,
				-- zxv.subentity_desc ,
				-- zxv.relationship_to_entity,
				-- zxv.distinct_estimation_method ,
				-- zxv.distinct_output_metrics ,
				-- zxv.distinct_foreign_country ,
				-- zxv.primary_naics_code_id ,
				-- zxv.secondary_naics_code_id ,
				-- zxv.organization_boundary_id ,
				-- 277,
				-- zxv.sub_entity 
				)
			WHEN MATCHED THEN
				UPDATE SET
				 fun_cur_value_id = zxv.fun_cur_value_id ,
				 hedge_type_value_id = zxv.hedge_type_value_id
				 --no_links_fas_eff_test_profile_id = 2,
				 ----label_no_links_fas_eff_test_profile_id = label_no_links_fas_eff_test_profile_id,
				 --mes_gran_value_id = zxv.mes_gran_value_id,
				 --mismatch_tenor_value_id = zxv.mismatch_tenor_value_id ,
				 --gl_grouping_value_id = zxv.gl_grouping_value_id,
				 --rollout_per_type = zxv.rollout_per_type,
				 --mes_cfv_value_id =  zxv. mes_cfv_value_id,
				 --strip_trans_value_id = zxv.strip_trans_value_id,
				 --mes_cfv_values_value_id = zxv.mes_cfv_values_value_id,
				 --oci_rollout_approach_value_id = zxv.oci_rollout_approach_value_id,
				 --test_range_from = zxv.test_range_from,
				 --additional_test_range_from = zxv.additional_test_range_from,
				 --test_range_to = zxv.test_range_to,
				 --additional_test_range_to = zxv.additional_test_range_to,
				 --additional_test_range_from2 = zxv.test_range_from2,
				 --additional_test_range_to2 = zxv.test_range_to2,
				 --first_day_pnl_threshold = zxv.first_day_pnl_threshold,
				 --gl_tenor_option = zxv.gl_tenor_option,
				 --fx_hedge_flag = 'n',
				 --include_unlinked_hedges = zxv.include_unlinked_hedges,
				 --no_links = zxv.no_links ,
				 --include_unlinked_items = zxv.include_unlinked_items,
				 --gl_number_id_st_asset = zxv.gl_number_id_st_asset,
				 --gl_number_id_lt_asset = zxv.gl_number_id_lt_asset,
				 --gl_number_id_st_liab = zxv.gl_number_id_st_liab,
				 --gl_number_id_lt_liab = zxv.gl_number_id_lt_liab,
				 --gl_id_st_tax_asset = zxv.gl_id_st_tax_asset,
				 --gl_id_lt_tax_asset = zxv.gl_id_lt_tax_asset,
				 --gl_id_st_tax_liab = zxv.gl_id_st_tax_liab,
				 --gl_id_lt_tax_liab = zxv.gl_id_lt_tax_liab,
				 --gl_id_tax_reserve = zxv.gl_id_tax_reserve,
				 --gl_number_id_aoci = zxv.gl_number_id_aoci,
				 --gl_number_id_inventory = zxv.gl_number_id_inventory,
				 --gl_number_id_pnl = zxv.gl_number_id_pnl,
				 --gl_number_id_set = zxv.gl_number_id_set,
				 --gl_number_id_cash = zxv.gl_number_id_cash,
				 --gl_number_id_gross_set = zxv.gl_number_id_gross_set,
				 --subentity_name = zxv.subentity_name,
				 --subentity_desc = zxv.subentity_desc,
				 --relationship_to_entity = zxv.relationship_to_entity,
				 --distinct_estimation_method = zxv.distinct_estimation_method,
				 --distinct_output_metrics = zxv.distinct_output_metrics,
				 --distinct_foreign_country = zxv.distinct_foreign_country,
				 --primary_naics_code_id = zxv.primary_naics_code_id,
				 --secondary_naics_code_id = zxv.secondary_naics_code_id,
				 --organization_boundary_id = zxv.organization_boundary_id,
				 --asset_liab_calc_value_id = 277,
				 --sub_entity = zxv.sub_entity
				 ;
				
		
	  --SELECT @fas_strategy_id = fas_strategy_id FROM #ztbl_xmlvalue
		--SELECT * FROM portfolio_hierarchy AS ph
		--SELECT * FROM fas_strategy AS fs
		
		
	--	EXEC dbo.spa_generate_hour_block_term 300501@block_value_id, NULL, NULL
		
		EXEC spa_ErrorHandler 0
			, 'Source Deal Detail'
			, 'spa_getXml'
			, 'Success'
			, 'Changes have been saved successfully.'
			, ''				

		COMMIT
	END
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK
		
	DECLARE @msg VARCHAR(5000)
	SELECT @msg = 'Failed Inserting record (' + ERROR_MESSAGE() + ').'
	
	EXEC spa_ErrorHandler @@ERROR
		, 'Source Deal Detail'
		, 'spa_UpdateBookStrategyXml'
		, 'DB Error'
		, @msg
		, 'Failed Inserting Record'
END CATCH



