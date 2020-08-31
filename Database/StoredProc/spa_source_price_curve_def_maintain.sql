IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_source_price_curve_def_maintain]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_source_price_curve_def_maintain]

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**
	Stored procedure for Price curve Definition

	Parameters
	@flag: Operation flag
	@source_curve_def_id: Price curve definition id
	@source_system_id: Source system id
	@curve_id: Price curve id
	@curve_name: Price curve name
	@curve_des:  Price curve description
	@commodity_id: Commodity id
	@market_value_id: Market Value id
	@market_value_desc:  Market value Description
	@source_currency_id:  Currency id
	@source_currency_to_id:  Currency to id
	@source_curve_type_value_id:  Price curve type value id
	@uom_id: UOM id
	@proxy_source_curve_def_id:  Proxy curve definition id
	@user_name: User name
	@formula_id: Formula id
	@obligation: Obligation
	@fair_value: Fair value
	@granularity: Granularity
	@risk_bucket_id: Risk bucket id
	@exp_calENDar_id: Expiry calendar id
	@reference_curve_id: Reference curve id
	@monthly_index:  Monthly Index
	@program_scope: Program scope
	@block_type: Block type
	@block_define_id: Block define id
	@curve_definition: Price curve definition
	@index_group: Index group
	@display_uom_id: Display UOM id
	@derived_flag:  Derived flag
	@proxy_curve_id: Proxy curve id
	@settlement_curve_id:  Settlement curve id
	@hourly_volume_allocation:  Hourly volume allocation
	@time_zone: Time zone
	@udf_block_group_id:  UDF block group id
	@is_active: Active flag
	@ratioOption: Ratio option
	@timeOfUse: Time of use
	@proxyCurve3: Proxy Curve 3
	@useAODInCurrentMonth: User AOD in current month
	@monte_carlo_model_id: Monte carlo model id
	@strategy_id: Strategy id
	@show_hyperlink: Flag to show hyperlink
	@show_only_monte_carlo_model: Flag to show only monte carlo model
	@filter_value: FIlter Value
*/
CREATE proc [dbo].[spa_source_price_curve_def_maintain]	
	@flag                 		CHAR(20),	
	@source_curve_def_id        INT = NULL,				
	@source_system_id           INT = NULL,
	@curve_id          			VARCHAR(50) = NULL,
	@curve_name        			VARCHAR(100) = NULL,
	@curve_des        			VARCHAR(50) = NULL,
	@commodity_id               INT = NULL,
	@market_value_id   			VARCHAR(50) = NULL,
	@market_value_desc 			VARCHAR(50) = NULL,
	@source_currency_id         INT = NULL,
	@source_currency_to_id      INT = NULL,
	@source_curve_type_value_id VARCHAR(100) = NULL,
	@uom_id                     INT = NULL,
	@proxy_source_curve_def_id  INT = NULL,					
	@user_name         			VARCHAR(50) = NULL,
	@formula_id                 INT = NULL,
	@obligation           		CHAR(1) = NULL,
	@fair_value                 INT = NULL,
	@granularity                INT = NULL,
	@risk_bucket_id             INT = NULL,
	@exp_calENDar_id            INT = NULL,
	@reference_curve_id         INT = NULL, 
	@monthly_index              INT = NULL, 		
	@program_scope              INT = NULL,
	@block_type                 INT = NULL,
	@block_define_id            INT = NULL,
	@curve_definition  			VARCHAR(MAX) = NULL,
	@index_group                INT = NULL,
	@display_uom_id             INT = NULL,
	@derived_flag         		CHAR(1) = NULL,
	@proxy_curve_id             INT = NULL,
	@settlement_curve_id        INT = NULL,
	@hourly_volume_allocation   INT = NULL,
	@time_zone                  INT = NULL,
	@udf_block_group_id         INT = NULL,
	@is_active         			VARCHAR(1) = NULL,
	@ratioOption                INT = NULL,
	@timeOfUse                  INT = NULL,
	@proxyCurve3                INT = NULL,
	@useAODInCurrentMonth 		CHAR(1) = NULL,
	@monte_carlo_model_id       INT = NULL,
	@strategy_id INT = NULL,
	@show_hyperlink CHAR(1) = 'y',
	@show_only_monte_carlo_model CHAR(1) = 'n' ,
	@filter_value				VARCHAR(MAX) = NULL

AS 

DECLARE @sql_select VARCHAR(5000)
DECLARE @curve_id_new int
SET NOCOUNT ON

SELECT @filter_value = NULLIF(NULLIF(@filter_value, '<FILTER_VALUE>'), '')

IF @flag IN('l', 't', 'm', 'n', 'q','b','j')
BEGIN
	CREATE TABLE #final_privilege_list(value_id INT, is_enable VARCHAR(20) COLLATE DATABASE_DEFAULT)
	EXEC spa_static_data_privilege @flag = 'p', @source_object = 'pricecurve'
END

IF OBJECT_ID('tempdb..#deal_to_calc') IS NOT NULL	
		DROP TABLE #deal_to_calc
CREATE TABLE #deal_to_calc(source_deal_header_id INT)

IF @flag = 'i'
BEGIN
	DECLARE @curve_count VARCHAR(100)
	SELECT @curve_count = COUNT(*) FROM source_price_curve_def WHERE curve_id = @curve_id AND source_system_id = @source_system_id
	
	IF EXISTS(SELECT 1 FROM source_price_curve_def WHERE curve_name = @curve_name)
	BEGIN
		EXEC spa_ErrorHandler -1,
		     'MaintainDefinition',
		     'spa_source_price_curve_def_maintain',
		     'DB Error',
		     'Curve Name already exists.',
		     ''
		RETURN
	END
	
	IF (@curve_count > 0)
	BEGIN
		SELECT 'Error',
		       'Can not insert duplicate ID :' + @curve_id,
		       'spa_application_security_role',
		       'DB Error',
		       'Can not insert duplicate ID :' + @curve_id,
		       ''
		RETURN
	END
	
	INSERT INTO source_price_curve_def
	(
		source_system_id,
		curve_id,
		curve_name,
		curve_des,
		commodity_id,
		market_value_id,
		market_value_desc,
		source_currency_id,
		source_currency_to_id,
		source_curve_type_value_id,
		uom_id,
		proxy_source_curve_def_id,
		formula_id,
		obligation,
		fv_level,
        granularity,
		risk_bucket_id,
		exp_calENDar_id,
		reference_curve_id, 
		monthly_index,  
		program_scope_value_id,
		block_type,
		block_define_id,
		curve_definition,
		index_group,
		display_uom_id,
		proxy_curve_id,
		settlement_curve_id,
		hourly_volume_allocation,
		time_zone,
		udf_block_group_id,
		is_active,
		ratio_option,
		curve_tou,
		proxy_curve_id3,
		asofdate_current_month
	)
	VALUES
	(				
		@source_system_id,
		@curve_id,
		@curve_name,
		@curve_des,
		@commodity_id,
		@market_value_id,
		@market_value_desc,
		@source_currency_id,
		@source_currency_to_id,
		@source_curve_type_value_id,
		@uom_id,
		@proxy_source_curve_def_id,
		@formula_id,
		@obligation,
		@fair_value,
		@granularity,
		@risk_bucket_id,
		@exp_calENDar_id,
		@reference_curve_id,
		@monthly_index,  
		@program_scope,
		@block_type,
		@block_define_id,
		@curve_definition,
		@index_group,
		@display_uom_id,
		@proxy_curve_id,
		@settlement_curve_id,
		@hourly_volume_allocation,
		@time_zone,
		@udf_block_group_id,
		@is_active,
		@ratioOption,
		@timeOfUse,
		@proxyCurve3,
		@useAODInCurrentMonth
	)
	
	SET @curve_id_new = SCOPE_IDENTITY()
	
	IF @@ERROR <> 0
		EXEC spa_ErrorHandler @@ERROR,
		     'MaintainDefinition',
		     'spa_source_price_curve_def_maintain',
		     'DB Error',
		     'Failed to insert definition value.',
		     ''
	ELSE
		EXEC spa_ErrorHandler 0,
			 'MaintainDefinition',
			 'spa_source_price_curve_def_maintain',
			 'Success',
			 'Successfully Inserted Values',
			 @curve_id_new

	-- Insertion of the reference ID in the CurveReferenceHierachy Table.
	EXEC CurveReferenceHierarchySP @curve_id_new, @reference_curve_id 
END

ELSE IF @flag = 'a'
BEGIN
	SELECT source_price_curve_def.source_curve_def_id,
	       source_system_description.source_system_name,
	       source_price_curve_def.curve_id,
	       source_price_curve_def.curve_name,
	       source_price_curve_def.curve_des,
	       source_price_curve_def.commodity_id,
	       source_price_curve_def.market_value_id,
	       source_price_curve_def.market_value_desc,
	       source_price_curve_def.source_currency_id,
	       source_price_curve_def.source_currency_to_id,
	       source_price_curve_def.source_curve_type_value_id,
	       source_price_curve_def.uom_id,
	       source_price_curve_def.proxy_source_curve_def_id,
	       source_price_curve_def.formula_id,
	       dbo.FNAFormulaFormat(f.formula, 'r') formula_text,
	       source_price_curve_def.obligation,
	       source_price_curve_def.fv_level,
	       source_price_curve_def.granularity,
	       source_price_curve_def.risk_bucket_id,
	       source_price_curve_def.exp_calENDar_id,
	       source_price_curve_def.reference_curve_id,
	       spcd2.curve_name reference_curve_name,
	       source_price_curve_def.monthly_index,
	       source_price_curve_def.program_scope_value_id,
	       source_price_curve_def.block_type,
	       source_price_curve_def.block_define_id,
	       CASE source_price_curve_def.index_group WHEN NULL THEN '' ELSE source_price_curve_def.index_group END AS [grp],
	       source_price_curve_def.display_uom_id,
	       source_price_curve_def.proxy_curve_id,
	       source_price_curve_def.curve_definition,
	       source_price_curve_def.settlement_curve_id,
	       source_price_curve_def.hourly_volume_allocation,
	       source_price_curve_def.time_zone,
	       source_price_curve_def.udf_block_group_id,
	       source_price_curve_def.is_active,
	       source_price_curve_def.ratio_option,
	       source_price_curve_def.curve_tou,
	       source_price_curve_def.proxy_curve_id3,
	       source_price_curve_def.asofdate_current_month,
	       source_price_curve_def.monte_carlo_model_parameter_id
	FROM   source_price_curve_def
	       INNER JOIN source_system_description ON  source_system_description.source_system_id = source_price_curve_def.source_system_id
	       LEFT OUTER JOIN formula_editor f ON source_price_curve_def.formula_id = f.formula_id
	       LEFT JOIN source_price_curve_def spcd2 ON  spcd2.source_curve_def_id = source_price_curve_def.reference_curve_id
	WHERE  source_price_curve_def.source_curve_def_id = @source_curve_def_id

RETURN
END

ELSE IF @flag = 's' 
BEGIN
	SET @sql_select = 'SELECT 
						spcd.source_curve_def_id [ID]
						, ssd.source_system_name [System]
						, spcd.curve_id AS [Curve ID]						
						, spcd.curve_name + CASE  WHEN ssd.source_system_id = 2 THEN '''' ELSE  ''.''  + ssd.source_system_name END AS Name
						, spcd.curve_des AS Description						
						, sc.commodity_name AS [Commodity]
						, spcd.market_value_id AS [Market Value ID]
						, spcd.market_value_desc AS [Market Value Description]
						, sc2.currency_name AS [Source Currency ID]
						, sc3.currency_name AS [Source Currency To ID]
						, sdv.[description] AS [Source Curve Type Value ID]
						, su.uom_name AS [UOM]
						, spcd1.curve_name AS [Proxy Curve]
						, spcd.formula_id AS [Formula ID]
						, spcd.obligation AS [Obligation]
						, spcd.sort_order AS [Sort Order]
						, sdv_fl.[description] AS [FV Level]						
						, dbo.FNADateTimeFormat(spcd.create_ts,1) [Created Date]
						, spcd.create_user [Created User]
						, spcd.update_user [Updated User]
						, dbo.FNADateTimeFormat(spcd.update_ts,1) [Updated Date]
						, sdv1.[description] AS [Granularity]
						, sdv2.[description] AS [Expiration Calendar]
						, spcd2.curve_name AS [Risk Bucket]
						, spcd3.curve_name AS [Reference Curve]
						, spcd4.curve_name AS [Proxy Curve 2]
						, sdv3.[description] AS [Program Scope]
						, spcd.curve_definition AS [Curve Definition]
						, sdv4.[description] AS [Block Type]
						, sdv5.[description] AS [Block Definition]
						, sdv6.[description] AS [Index Group]
						, su1.uom_name AS [Display UOM]
						, spcd5.curve_name AS [Proxy Curve Name]
						, sdv7.[description] AS [Hourly Break Down]
						, spcd6.curve_name AS [Settlement Curve]
						, tz.TIMEZONE_NAME AS [Time Zone]
						, sdv_udf_block.[description] As [User Defined Block]
						, spcd.is_active AS [Is Active]
						, sdv_ratio_opt.[description] AS [Ratio Option]
						, sdv_curve_tou.[description] AS [Time of Use]
						, spcd_proxy_curve_id3.curve_name AS [Proxy Curve 3]
						, spcd.asofdate_current_month AS [As of Date Current Month]
						, mcmp.monte_carlo_model_parameter_name AS [Simulation Model]
					FROM source_price_curve_def spcd
					INNER JOIN source_system_description ssd on ssd.source_system_id = spcd.source_system_id
					LEFT JOIN  source_commodity sc ON spcd.commodity_id = sc.source_commodity_id
					LEFT JOIN source_currency sc2 ON spcd.source_currency_id = sc2.source_currency_id 
					LEFT JOIN source_currency sc3 ON spcd.source_currency_to_id = sc3.source_currency_id
					LEFT JOIN static_data_value sdv ON spcd.source_curve_type_value_id = sdv.value_id
					LEFT JOIN source_uom su ON spcd.uom_id = su.source_uom_id
					LEFT JOIN source_price_curve_def spcd1 ON spcd.proxy_source_curve_def_id = spcd1.source_curve_def_id 					
					LEFT JOIN static_data_value sdv1 ON spcd.Granularity =  sdv1.value_id
					LEFT JOIN static_data_value sdv_fl ON spcd.fv_level = sdv_fl.value_id
					LEFT JOIN static_data_value sdv2 ON spcd.exp_calendar_id =  sdv2.value_id
					LEFT JOIN source_price_curve_def spcd2 ON spcd.risk_bucket_id = spcd2.source_curve_def_id
					LEFT JOIN source_price_curve_def spcd3 ON spcd.reference_curve_id = spcd3.source_curve_def_id
					LEFT JOIN source_price_curve_def spcd4 ON spcd.monthly_index = spcd4.source_curve_def_id
					LEFT JOIN static_data_value sdv3 ON spcd.program_scope_value_id = sdv3.value_id
					LEFT JOIN static_data_value sdv4 ON spcd.block_type = sdv4.value_id
					LEFT JOIN static_data_value sdv5 ON spcd.block_define_id = sdv5.value_id
					LEFT JOIN static_data_value sdv6 ON spcd.index_group = sdv6.value_id
					LEFT JOIN source_uom su1 ON spcd.display_uom_id = su1.source_uom_id
					LEFT JOIN source_price_curve_def spcd5 ON spcd.proxy_curve_id = spcd5.source_curve_def_id
					LEFT JOIN static_data_value sdv7 ON spcd.hourly_volume_allocation = sdv7.value_id
					LEFT JOIN source_price_curve_def spcd6 ON spcd.settlement_curve_id = spcd6.source_curve_def_id
					LEFT JOIN time_zones tz ON spcd.time_zone =  tz.TIMEZONE_ID
					LEFT JOIN static_data_value sdv_udf_block ON spcd.udf_block_group_id = sdv_udf_block.value_id
					LEFT JOIN static_data_value sdv_ratio_opt ON spcd.ratio_option = sdv_ratio_opt.value_id
					LEFT JOIN static_data_value sdv_curve_tou ON spcd.curve_tou = sdv_curve_tou.value_id
					LEFT JOIN source_price_curve_def spcd_proxy_curve_id3 ON spcd.proxy_curve_id3 = spcd_proxy_curve_id3.source_curve_def_id
					LEFT JOIN monte_carlo_model_parameter mcmp ON mcmp.monte_carlo_model_parameter_id = spcd.monte_carlo_model_parameter_id
	                WHERE 1=1
					'
	
	IF @is_active = 'y'
	BEGIN
		SET @sql_select = @sql_select + 'AND spcd.is_active = ''y'''
	END
	ELSE IF @is_active = 'n'
	BEGIN
		SET @sql_select = @sql_select + 'AND spcd.is_active = ''n'' OR spcd.is_active IS NULL'	
	END
	
	IF @source_curve_type_value_id IS NOT NULL and @source_system_id IS NULL
		SET @sql_select=@sql_select +  ' AND spcd.source_curve_type_value_id='+CONVERT(VARCHAR(20),@source_curve_type_value_id)+''
	ELSE IF @source_system_id IS NOT NULL and @source_curve_type_value_id IS NULL
		SET @sql_select=@sql_select +  ' AND spcd.source_system_id='+ CONVERT(VARCHAR(20), @source_system_id) + ''
	ELSE IF @source_system_id IS NOT NULL and @source_curve_type_value_id IS NOT NULL
		SET @sql_select=@sql_select +  ' AND spcd.source_system_id='+ CONVERT(VARCHAR(20), @source_system_id) + 'AND spcd.source_curve_type_value_id='+ CONVERT(VARCHAR(20), @source_curve_type_value_id) + ''

	IF @Commodity_id IS NOT NULL 
		SET @sql_select = @sql_select + ' AND spcd.commodity_id=' + CONVERT(VARCHAR(20), @Commodity_id)

	IF @curve_name IS NOT NULL 
		SET @sql_select = @sql_select + ' AND spcd.curve_name LIKE ''' + CONVERT(VARCHAR(50), @curve_name)	+ ''''
		
	IF @granularity IS NOT NULL  
		SET @sql_select = @sql_select + ' AND spcd.granularity=' + CONVERT(VARCHAR(20), @granularity)
	
	IF @uom_id IS NOT NULL 
		SET @sql_select = @sql_select + ' AND spcd.uom_id=' + CONVERT(VARCHAR(20), @uom_id)
		
	IF @source_curve_type_value_id IS NOT NULL 
		SET @sql_select = @sql_select + ' AND spcd.source_curve_type_value_id=' + CONVERT(VARCHAR(20), @source_curve_type_value_id)
	
	IF @source_currency_id IS NOT NULL 
		SET @sql_select = @sql_select + ' AND spcd.source_currency_id=' + CONVERT(VARCHAR(20), @source_currency_id)
	
	IF @block_type IS NOT NULL 
		SET @sql_select = @sql_select + ' AND spcd.block_type=' + CONVERT(VARCHAR(20), @block_type)
		
	IF @block_define_id IS NOT NULL 
		SET @sql_select = @sql_select + ' AND spcd.block_define_id=' + CONVERT(VARCHAR(20), @block_define_id)	
		
	IF @index_group IS NOT NULL 
		SET @sql_select = @sql_select + ' AND spcd.index_group=' + CONVERT(VARCHAR(20), @index_group)	
					
	IF @fair_value IS NOT NULL 
		SET @sql_select = @sql_select + ' AND spcd.fv_level=' + CONVERT(VARCHAR(20), @fair_value)
		
	IF @derived_flag IS NOT NULL 
	BEGIN
		IF @derived_flag = 'y'
			SET @sql_select = @sql_select + ' AND spcd.formula_id IS NOT NULL'
		IF @derived_flag = 'n' 
			SET @sql_select = @sql_select + ' AND spcd.formula_id IS NULL'
	END
				
	SET @sql_select=@sql_select +  ' order by spcd.curve_name,spcd.curve_des'
	
	exec spa_print @sql_select
	EXEC(@sql_select)
	
END

ELSE IF @flag = 'b'
BEGIN
	SET @sql_select = ' SELECT	spcd.source_curve_def_id,
								spcd.curve_name,
								spcd.curve_des,
								MIN(fpl.is_enable) [status]
						FROM #final_privilege_list fpl
						' 											
	SET @sql_select += CASE WHEN dbo.FNAIsUserOnAdminGroup(dbo.FNADBUser(), 0) = 0 THEN ' INNER JOIN ' ELSE ' LEFT JOIN ' END + '
						source_price_curve_def spcd ON spcd.source_curve_def_id = fpl.value_id '
	IF @filter_value IS NOT NULL AND @filter_value <> '-1' 
	BEGIN
		SET @sql_select += ' INNER JOIN dbo.SplitCommaSeperatedValues(''' + @filter_value + ''') s ON s.item = spcd.source_curve_def_id '
	END					
	SET @sql_select +=  ' GROUP BY spcd.source_curve_def_id, spcd.curve_name, spcd.curve_des
						ORDER BY spcd.curve_name asc'
	EXEC(@sql_select)
END
ELSE IF @flag = 'l'
BEGIN
	SET @sql_select = '
		SELECT DISTINCT d.source_curve_def_id,
				d.curve_name AS curve_name,
				MIN(fpl.is_enable) [status]
		FROM #final_privilege_list fpl
		' + CASE WHEN dbo.FNAIsUserOnAdminGroup(dbo.FNADBUser(), 0) = 0 THEN 'INNER JOIN ' ELSE 'LEFT JOIN ' END + '
		 source_price_curve_def d ON d.source_curve_def_id = fpl.value_id
		INNER JOIN source_system_description ssd ON  ssd.source_system_id = d.source_system_id
		WHERE 1=1'
	
	IF @source_curve_type_value_id IS NOT NULL
		SET @sql_select += ' AND source_curve_type_value_id IN (' + @source_curve_type_value_id + ')'
	
	IF @obligation IS NOT NULL
		SET @sql_select += ' AND obligation = ''' + @obligation + ''''

	IF @source_system_id IS NOT NULL
		SET @sql_select += ' AND '''+ + CAST(@source_system_id AS VARCHAR(100))+'''= ssd.source_system_id'

	IF @commodity_id IS NOT NULL
		SET @sql_select += ' AND (commodity_id = ISNULL(''' + CAST(@commodity_id AS VARCHAR(10))+''', commodity_id))'
		
    IF @is_active IS NOT NULL 
		SET @sql_select += ' AND is_active = ''' + @is_active + ''''

	IF ISNULL(@show_only_monte_carlo_model,'n') = 'y'
		SET @sql_select += ' AND monte_carlo_model_parameter_id IS NOT NULL'
		
	SET @sql_select += ' GROUP BY d.source_curve_def_id, d.curve_name, ssd.source_system_id, ssd.source_system_name
		ORDER BY curve_name
		'
	EXEC(@sql_select)
END
ELSE IF  @flag = 'm'
BEGIN
	SET @sql_select = '
		SELECT DISTINCT d.source_curve_def_id AS [Curve ID], 
			d.curve_name + CASE WHEN e.source_system_id = 2 THEN '''' ELSE ''.'' + e.source_system_name END AS [Index],
			MIN(fpl.is_enable) [status]
		FROM #final_privilege_list fpl
		' + CASE WHEN dbo.FNAIsUserOnAdminGroup(dbo.FNADBUser(), 0) = 0 THEN 'INNER JOIN ' ELSE 'LEFT JOIN ' END + '
		 source_price_curve_def d ON d.source_curve_def_id = fpl.value_id
		INNER JOIN source_system_description e ON e.source_system_id = d.source_system_id 
		INNER JOIN fas_strategy fs ON d.source_system_id = fs.source_system_id
		'
	IF @filter_value IS NOT NULL AND @filter_value <> '-1'
	BEGIN
		SET @sql_select += ' INNER JOIN dbo.SplitCommaSeperatedValues(''' + @filter_value + ''') s ON s.item = d.source_curve_def_id '
	END
	SET @sql_select +=  ' WHERE 1 = 1 
			AND (d.source_curve_type_value_id = ISNULL(NULL, d.source_curve_type_value_id))
			AND (d.commodity_id = ISNULL(NULL, d.commodity_id))
		'
	IF @strategy_id IS NOT NULL
		BEGIN
			DECLARE @stra_id INT --get from book id
			SELECT @stra_id  = stra.entity_id 
			FROM portfolio_hierarchy book
			INNER JOIN portfolio_hierarchy stra ON stra.entity_id= book.parent_entity_id
			INNER JOIN portfolio_hierarchy sub ON stra.parent_entity_id= sub.entity_id
			AND book.entity_id = @strategy_id
			SET @sql_select = @sql_select + 'AND fs.fas_strategy_id = ' + CAST (@stra_id AS VARCHAR(10))		
		END
	SET @sql_select = @sql_select + ' GROUP BY d.source_curve_def_id, d.curve_name, d.curve_name, e.source_system_id, e.source_system_name
										ORDER BY [Index]'
	EXEC(@sql_select)
END
ELSE IF @flag = 'n'
BEGIN
	SET @sql_select = ' SELECT	spcd.source_curve_def_id,
								spcd.curve_name,
								MIN(fpl.is_enable) [status]
						FROM #final_privilege_list fpl
						' + CASE WHEN dbo.FNAIsUserOnAdminGroup(dbo.FNADBUser(), 0) = 0 THEN 'INNER JOIN ' ELSE 'LEFT JOIN ' END + '
						 source_price_curve_def spcd ON spcd.source_curve_def_id = fpl.value_id
						INNER JOIN (SELECT DISTINCT curve_id FROM source_deal_detail WHERE curve_id IS NOT NULL) sdd
							ON sdd.curve_id = spcd.source_curve_def_id
						GROUP BY spcd.source_curve_def_id, spcd.curve_name
						ORDER BY spcd.curve_name'
	EXEC(@sql_select)
END
ELSE IF @flag = 'q'
BEGIN
	SET @sql_select = ' SELECT	spcd.source_curve_def_id,
								spcd.curve_name,
								MIN(fpl.is_enable) [status]
						FROM #final_privilege_list fpl
						' + CASE WHEN dbo.FNAIsUserOnAdminGroup(dbo.FNADBUser(), 0) = 0 THEN 'INNER JOIN ' ELSE 'LEFT JOIN ' END + '
						 source_price_curve_def spcd ON spcd.source_curve_def_id = fpl.value_id
						INNER JOIN (SELECT DISTINCT formula_curve_id FROM source_deal_detail WHERE formula_curve_id IS NOT NULL) sdd
							ON sdd.formula_curve_id = spcd.source_curve_def_id
						GROUP BY spcd.source_curve_def_id, spcd.curve_name
						ORDER BY spcd.curve_name'
	EXEC(@sql_select)
END
ELSE IF @flag = 'u'
BEGIN
	
	DECLARE @curve_counter VARCHAR(100)
	
	SELECT @curve_counter = count(*) FROM source_price_curve_def 
	WHERE curve_id = @curve_id  AND source_curve_def_id <> @source_curve_def_id
		AND source_system_id = @source_system_id
	
	IF (@curve_counter > 0)
	BEGIN
		SELECT 'Error',
		       'Can not update duplicate ID :' + @curve_id,
		       'spa_application_security_role',
		       'DB Error',
		       'Can not update duplicate ID :' + @curve_id,
		       ''
		RETURN
	END
	
	IF EXISTS(SELECT 1 FROM source_price_curve_def WHERE curve_name = @curve_name AND source_curve_def_id <> @source_curve_def_id)
	BEGIN
		EXEC spa_ErrorHandler -1,
		     'MaintainDefinition',
		     'spa_source_price_curve_def_maintain',
		     'DB Error',
		     'Curve Name already exists.',
		     ''
		RETURN
	END
	

	DECLARE @report_position_process_id  VARCHAR(100)
	DECLARE @user_login_id               VARCHAR(100)
	DECLARE @job_name                    VARCHAR(100)
	
	DECLARE @report_position_deals       VARCHAR(300)
	DECLARE @sql                         VARCHAR(8000)
	DECLARE @run_position                CHAR(1)
	
	SET @run_position = 'n'
	SET @user_login_id = dbo.FNADBUser()
	SET @report_position_process_id = REPLACE(NEWID(), '-', '_')

	IF NOT EXISTS (
		SELECT 1
		FROM   source_price_curve_def
		WHERE  source_curve_def_id = @source_curve_def_id
	       AND ISNULL(block_type, -1) = ISNULL(@block_type, -1)
	       AND ISNULL(block_define_id, -1) = ISNULL(@block_define_id, -1)
	       AND commodity_id = @commodity_id
	       AND ISNULL(exp_calENDar_id, -1) = ISNULL(@exp_calENDar_id, -1)
	       AND ISNULL(hourly_volume_allocation, -1) = ISNULL(@hourly_volume_allocation, -1)
	       AND ISNULL(uom_id, -1) = ISNULL(@uom_id, -1)
	       AND ISNULL(display_uom_id, -1) = ISNULL(@display_uom_id, -1)
		   AND ISNULL(time_zone, -1) = ISNULL(@time_zone, -1)
	)
	BEGIN
		

		INSERT INTO dbo.process_deal_position_breakdown (source_deal_header_id,create_user,create_ts,process_status,insert_type,deal_type,commodity_id,fixation,internal_deal_type_value_id)
		OUTPUT INSERTED.source_deal_header_id INTO #deal_to_calc(source_deal_header_id)
		SELECT  sdh.source_deal_header_id, MAX(sdh.create_user), GETDATE(), 9 process_status, 0 deal_type, MAX(ISNULL(sdh.internal_desk_id, 17300)) deal_type , 
		MAX(ISNULL(spcd.commodity_id, -1)) commodity_id, MAX(ISNULL(sdh.product_id, 4101)) fixation, MAX(ISNULL(sdh.internal_deal_type_value_id, -999999))
		FROM source_deal_header sdh
		INNER JOIN source_deal_detail sdd on sdh.source_deal_header_id=sdd.source_deal_header_id
		LEFT JOIN source_price_curve_def spcd on sdd.curve_id=spcd.source_curve_def_id and sdd.curve_id is not null
		WHERE spcd.source_curve_def_id = @source_curve_def_id
		GROUP BY sdh.source_deal_header_id

		IF EXISTS(SELECT 1 FROM #deal_to_calc)
			SET @run_position = 'y'
	END

	UPDATE source_price_curve_def
	SET    source_system_id = @source_system_id,
	       curve_id = @curve_id,
	       curve_name = @curve_name,
	       curve_des = @curve_des,
	       commodity_id = @commodity_id,
	       market_value_id = @market_value_id,
	       market_value_desc = @market_value_desc,
	       source_currency_id = @source_currency_id,
	       source_currency_to_id = @source_currency_to_id,
	       source_curve_type_value_id = @source_curve_type_value_id,
	       uom_id = @uom_id,
	       proxy_source_curve_def_id = @proxy_source_curve_def_id,
	       formula_id = @formula_id,
	       obligation = @obligation,
	       fv_level = @fair_value,
	       granularity = @granularity,
	       risk_bucket_id = @risk_bucket_id,
	       exp_calENDar_id = @exp_calENDar_id,
	       reference_curve_id = @reference_curve_id,
	       monthly_index = @monthly_index,
	       program_scope_value_id = @program_scope,
	       block_type = @block_type,
	       block_define_id = @block_define_id,
	       curve_definition = @curve_definition,
	       index_group = @index_group,
	       display_uom_id = @display_uom_id,
	       proxy_curve_id = @proxy_curve_id,
	       settlement_curve_id = @settlement_curve_id,
	       hourly_volume_allocation = @hourly_volume_allocation,
	       time_zone = @time_zone,
	       udf_block_group_id = @udf_block_group_id,
	       is_active = @is_active,
	       ratio_option = @ratioOption,
	       curve_tou = @timeOfUse,
	       proxy_curve_id3 = @proxyCurve3,
	       asofdate_current_month = @useAODInCurrentMonth,
	       monte_carlo_model_parameter_id = @monte_carlo_model_id
	WHERE  source_curve_def_id = @source_curve_def_id

	IF @run_position ='y'
	BEGIN
		
	    EXEC dbo.spa_calc_pending_deal_position @call_from = 1
	END
	
	IF @@Error <> 0
		EXEC spa_ErrorHandler @@Error,
		     'MaintainDefinition',
		     'spa_source_price_curve_def_maintain',
		     'DB Error',
		     'Failed to update definition value.',
		     ''
	ELSE
		EXEC spa_ErrorHandler 0,
		     'MaintainDefinition',
		     'spa_source_price_curve_def_maintain',
		     'Success',
		     'Definition data value updated.',
		     ''
		
	EXEC CurveReferenceHierarchySP @source_curve_def_id, @reference_curve_id 
END

ELSE IF @flag = 'post_insert'
BEGIN

		INSERT INTO dbo.process_deal_position_breakdown (source_deal_header_id,create_user,create_ts,process_status,insert_type,deal_type,commodity_id,fixation,internal_deal_type_value_id)
		OUTPUT INSERTED.source_deal_header_id INTO #deal_to_calc(source_deal_header_id)
		SELECT  sdh.source_deal_header_id, MAX(sdh.create_user), GETDATE(), 9 process_status, 0 deal_type, MAX(ISNULL(sdh.internal_desk_id, 17300)) deal_type , 
		MAX(ISNULL(spcd.commodity_id, -1)) commodity_id, MAX(ISNULL(sdh.product_id, 4101)) fixation, MAX(ISNULL(sdh.internal_deal_type_value_id, -999999))
		FROM source_deal_header sdh
		INNER JOIN source_deal_detail sdd on sdh.source_deal_header_id=sdd.source_deal_header_id
		LEFT JOIN source_price_curve_def spcd on sdd.curve_id=spcd.source_curve_def_id and sdd.curve_id is not null
		WHERE spcd.source_curve_def_id = @source_curve_def_id
		GROUP BY sdh.source_deal_header_id

		IF EXISTS(SELECT 1 FROM #deal_to_calc)
			EXEC dbo.spa_calc_pending_deal_position @call_from = 1	
END

ELSE IF @flag = 'd'
BEGIN
	-- Added for validating values used in Rec Assignment Priority
	IF EXISTS (SELECT 1
	           FROM   rec_assignment_priority_order rapo
	           INNER JOIN rec_assignment_priority_detail rapd ON  rapo.rec_assignment_priority_detail_id = rapd.rec_assignment_priority_detail_id
	           WHERE  rapo.priority_type_value_id = @source_curve_def_id
	) 
	BEGIN
		EXEC spa_ErrorHandler -1,
		     'StaticDataMgmt',
		     'spa_StaticDataValue',
		     'DB Error',
		     'Selected data is in use in Rec Priority order and cannot be deleted.',
		     ''
		RETURN
	END
	
	DECLARE @tmp_id INT
	SELECT @tmp_id = reference_curve_id
	FROM   source_price_curve_def
	WHERE  source_curve_def_id = @source_curve_def_id
	
	EXEC spa_maintain_udf_header 'd', NULL, @source_curve_def_id			

	IF (@tmp_id IS NULL)
	BEGIN
		BEGIN TRY
			BEGIN TRAN
				
				DELETE 
				FROM   source_price_curve_def
				WHERE  source_curve_def_id = @source_curve_def_id
				
				EXEC spa_ErrorHandler 0,
				     'MaintainDefinition',
				     'spa_source_price_curve_def_maintain',
				     'Success',
				     'Maintain Definition Data sucessfully deleted',
				     ''
				COMMIT
		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT <> 0
			    ROLLBACK
			
			DECLARE @error_no INT
			SET @error_no = ERROR_NUMBER()
			
			EXEC spa_ErrorHandler -1,
			     'MaintainDefinition',
			     'spa_source_price_curve_def_maintain',
			     'DB Error,Foreign key constrains',
			     'Price Curve cannot be deleted when used in deal(s).',
			     'Foreign key constrains'
		END CATCH
	END		 
END

-- BEGIN : VK06TRM
ELSE IF @flag = 'r'
BEGIN
	CREATE TABLE #CRH_TMP(Curveid INT)
	INSERT INTO #CRH_TMP SELECT curveId  FROM CurveReferenceHierarchy
	INSERT INTO #CRH_TMP SELECT RefID_1  FROM CurveReferenceHierarchy
	INSERT INTO #CRH_TMP SELECT RefID_2  FROM CurveReferenceHierarchy
	INSERT INTO #CRH_TMP SELECT RefID_3  FROM CurveReferenceHierarchy
	INSERT INTO #CRH_TMP SELECT RefID_4  FROM CurveReferenceHierarchy	
	INSERT INTO #CRH_TMP SELECT RefID_5  FROM CurveReferenceHierarchy
	INSERT INTO #CRH_TMP SELECT RefID_6  FROM CurveReferenceHierarchy
	INSERT INTO #CRH_TMP SELECT RefID_7  FROM CurveReferenceHierarchy
	INSERT INTO #CRH_TMP SELECT RefID_8  FROM CurveReferenceHierarchy
	INSERT INTO #CRH_TMP SELECT RefID_9  FROM CurveReferenceHierarchy
	INSERT INTO #CRH_TMP SELECT RefID_10 FROM CurveReferenceHierarchy
	
	DELETE FROM #CRH_TMP WHERE curveID IS NULL
	
	-- The deleted CurveId will be populated for reference after left outer join in @sql_select.	
	 SELECT CurveId INTO #CurveWithNoReferenceHierarchy
		FROM CurveReferenceHierarchy 
		WHERE  RefID_1 IS NULL AND RefID_2 IS NULL AND RefID_3 IS NULL AND RefID_4 IS NULL AND RefID_5  IS NULL AND 
			   RefID_6 IS NULL AND RefID_7 IS NULL AND RefID_8 IS NULL AND RefID_9 IS NULL AND RefID_10 IS NULL AND
			   curveId IS NOT NULL	
	
	DELETE FROM #CRH_TMP WHERE curveID IN (SELECT CurveId FROM #CurveWithNoReferenceHierarchy) 

	-- The curve Id passed in the SP should not appear to reference itself. After insertion in #CRH_TMP,it will be omitted in left outer join of @sql_select. 
	INSERT INTO #CRH_TMP (curveID) VALUES (@source_curve_def_id)

	-- BEGIN : Curve Reference should not be circular. i.e IF I HAVE 1-2-3. Now 1 should not be allowed to refer to 3.
	DECLARE @nodisplay VARCHAR(1000)
	
	SELECT @nodisplay = ISNULL(CONVERT(VARCHAR, RefID_1), '') + ',' +
	       ISNULL(CONVERT(VARCHAR, RefID_2), '') + ',' +
	       ISNULL(CONVERT(VARCHAR, RefID_3), '') + ',' +
	       ISNULL(CONVERT(VARCHAR, RefID_4), '') + ',' +
	       ISNULL(CONVERT(VARCHAR, RefID_5), '') + ',' +
	       ISNULL(CONVERT(VARCHAR, RefID_6), '') + ',' +
	       ISNULL(CONVERT(VARCHAR, RefID_7), '') + ',' +
	       ISNULL(CONVERT(VARCHAR, RefID_8), '') + ',' +
	       ISNULL(CONVERT(VARCHAR, RefID_9), '') + ',' +
	       ISNULL(CONVERT(VARCHAR, RefID_10), '')
	FROM   curvereferencehierarchy
	WHERE  curveId = @source_curve_def_id

	INSERT INTO #CRH_TMP (curveID) SELECT item FROM dbo.splitcommaseperatedvalues(@nodisplay)
	-- END : Curve Reference should not be circular.
	
	SELECT DISTINCT curveId INTO #CRH FROM #CRH_TMP

	-- Circular Reference to be avoided.
	SELECT @sql_select = ''

	SELECT @sql_select = 'SELECT spcd.source_curve_def_id,
	                             curve_name AS [Name],
	                             spcd.curve_des AS [Description],
	                             ssd.source_system_name AS [System],
	                             spcd.create_ts [Created Date],
	                             spcd.create_user [Created User],
	                             spcd.update_user [Updated Date],
	                             spcd.update_ts [Updated User]
	                      FROM   source_price_curve_def spcd
						  LEFT OUTER JOIN #CRH ON source_curve_def_id = CurveID 
						  inner join source_system_description ssd on ssd.source_system_id = spcd.source_system_id 
	                      WHERE CurveID IS NULL '	

	IF @source_curve_type_value_id IS NOT NULL and @source_system_id is null
		SELECT  @sql_select=@sql_select +  ' and spcd.source_curve_type_value_id='+convert(VARCHAR(20),@source_curve_type_value_id)+''
	ELSE IF @source_system_id IS NOT NULL and @source_curve_type_value_id is null
		SELECT  @sql_select=@sql_select +  ' and spcd.source_system_id='+convert(VARCHAR(20),@source_system_id)+''
	ELSE IF @source_system_id IS NOT NULL and @source_curve_type_value_id IS NOT NULL
		SELECT  @sql_select=@sql_select +  ' and spcd.source_system_id='+convert(VARCHAR(20),@source_system_id)+'and spcd.source_curve_type_value_id='+convert(VARCHAR(20),@source_curve_type_value_id)+''

	IF @granularity IS NOT NULL
		set @sql_select = @sql_select + ' and spcd.Granularity = ''' + cast(@granularity AS VARCHAR) + ''''

	SELECT @sql_select=@sql_select +  ' order by curve_name,spcd.curve_des'
	
	exec spa_print @sql_select
	EXEC(@sql_select)
	
END
-- END : VK06TRM

ELSE IF @flag = 'c'
BEGIN
	 SET @sql_select = 'SELECT spcd.source_curve_def_id,
	                           curve_name AS [Name],
	                           spcd.curve_des AS [Description],
	                           ssd.source_system_name AS [System],
	                           spcd.create_ts [Created Date],
	                           spcd.create_user [Created User],
	                           spcd.update_user [Updated Date],
	                           spcd.update_ts [Updated User],
	                           CASE WHEN spcd.formula_id IS NULL THEN ''n'' ELSE ''y'' END HasFormula
	                    FROM   source_price_curve_def spcd
	                    INNER JOIN source_system_description ssd ON  ssd.source_system_id = spcd.source_system_id
	                    WHERE  1 = 1'
	 
	 IF @source_curve_type_value_id IS NOT NULL AND @source_system_id IS NULL
		 SET @sql_select = @sql_select + ' AND spcd.source_curve_type_value_id=' + CONVERT(VARCHAR(20), @source_curve_type_value_id) + ''
	 
	 ELSE IF @source_system_id IS NOT NULL AND @source_curve_type_value_id IS NULL
		 SET @sql_select = @sql_select + ' AND spcd.source_system_id=' + CONVERT(VARCHAR(20), @source_system_id) + ''
	 
	 ELSE IF @source_system_id IS NOT NULL AND @source_curve_type_value_id IS NOT NULL
		 SET @sql_select = @sql_select + ' AND spcd.source_system_id=' + CONVERT(VARCHAR(20), @source_system_id) 
							+ 'and spcd.source_curve_type_value_id=' + CONVERT(VARCHAR(20), @source_curve_type_value_id) + ''
	 
	 IF @source_curve_def_id IS NOT NULL
		 SET @sql_select = @sql_select + 'AND  spcd.source_curve_def_id <> ' + CAST(@source_curve_def_id AS VARCHAR)
	 
	 SET @sql_select = @sql_select + ' order by curve_name,spcd.curve_des'
	 
	 exec spa_print @sql_select
	 EXEC (@sql_select)
END


ELSE IF @flag = 'o'
BEGIN
	SELECT spcd.uom_id, uom.uom_name
	FROM   source_price_curve_def spcd
	INNER JOIN source_uom uom ON  spcd.uom_id = uom.source_uom_id
	WHERE  source_curve_def_id = @source_curve_def_id
END

ELSE IF @flag = 'p'
BEGIN
	SET @sql_select = 'SELECT spcd.source_curve_def_id,
	                          curve_name AS NAME,
	                          spcd.curve_des AS DESCRIPTION,
	                          ssd.source_system_name AS SYSTEM,
	                          spcd.create_ts [Created Date],
	                          spcd.create_user [Created User],
	                          spcd.update_user [Updated Date],
	                          spcd.update_ts [Updated User]
	                   FROM   source_price_curve_def spcd
	                   INNER JOIN source_system_description ssd ON ssde.source_system_id = spcd.source_system_id'

	IF @source_curve_type_value_id IS NOT NULL AND @source_system_id IS NULL
		SET @sql_select = @sql_select + ' WHERE spcd.source_curve_type_value_id=' + CONVERT(VARCHAR(20), @source_curve_type_value_id) + ''
	
	ELSE IF @source_system_id IS NOT NULL AND @source_curve_type_value_id IS NULL
		SET @sql_select = @sql_select + ' WHERE spcd.source_system_id=' + CONVERT(VARCHAR(20), @source_system_id) + ''
	
	ELSE IF @source_system_id IS NOT NULL AND @source_curve_type_value_id IS NOT NULL
		SET @sql_select = @sql_select + ' WHERE spcd.source_system_id=' + CONVERT(VARCHAR(20), @source_system_id) 
						+ 'and spcd.source_curve_type_value_id=' + CONVERT(VARCHAR(20), @source_curve_type_value_id) + ''
	
	ELSE IF @obligation IS NOT NULL
		SET @sql_select = @sql_select + ' WHERE obligation=''' + CAST(@obligation AS VARCHAR) + ''''

	SET @sql_select = @sql_select + ' order by curve_name,spcd.curve_des'

	EXEC spa_print @sql_select
	EXEC (@sql_select)
END

ELSE IF @flag = 't'
BEGIN
	SET @sql_select = 'SELECT DISTINCT
							sdv.[description] AS s_curve_type,
							CASE WHEN ''' + @show_hyperlink+ ''' = ''n'' THEN spcd.curve_name ELSE dbo.FNATRMWinHyperlink(''a'', 10102600, spcd.curve_name, ABS(spcd.source_curve_def_id),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0) END curve_name, 
							spcd.source_curve_def_id, 
							spcd.curve_id,
							spcd.curve_des,
							
							sdv1.[description] AS s_granularity,
							sc2.currency_name AS source_currency_id,
							su.uom_name,
							sc.commodity_name, 
							sdv4.code [market_value_desc],
							
							CASE WHEN spcd.Forward_settle = ''s'' THEN ''Settlement'' 
									WHEN spcd.Forward_settle = ''f'' THEN ''Forward''
								ELSE NULL END AS Forward_settle,
							CASE WHEN spcd.formula_id IS NOT NULL THEN ''Yes'' ELSE ''No'' END formula_id,
							sdv2.code as index_group,
							CASE WHEN spcd.is_active = ''y'' THEN ''Yes'' ELSE ''No'' END AS is_active,
							4008 type_id,
							ISNULL(sdad.is_active, 0) is_privilege_active,
							
							spcd.effective_date,
							spcd.Granularity,
							spcd.market_value_id
					   FROM #final_privilege_list fpl
					   ' + CASE WHEN dbo.FNAIsUserOnAdminGroup(dbo.FNADBUser(), 0) = 0 THEN 'INNER JOIN ' ELSE 'LEFT JOIN ' END + '
							source_price_curve_def spcd ON spcd.source_curve_def_id = fpl.value_id'
							
	IF @granularity = '30' -- filtering monthly granuality
	BEGIN
		-- Adding tou monthly granularity - 10000289
		SET @sql_select += '
					
					INNER JOIN static_data_value sdv3 on sdv3.value_id = spcd.Granularity and spcd.Granularity in (980,991,992,993,10000289)'
	END
	
	SET @sql_select += '
				LEFT JOIN source_commodity sc ON spcd.commodity_id = sc.source_commodity_id
				LEFT JOIN source_currency sc2 ON spcd.source_currency_id = sc2.source_currency_id
				LEFT JOIN static_data_value sdv ON spcd.source_curve_type_value_id = sdv.value_id
				LEFT JOIN source_uom su ON spcd.uom_id = su.source_uom_id 					
				LEFT JOIN static_data_value sdv1 ON spcd.Granularity =  sdv1.value_id
				LEFT JOIN static_data_value sdv2 ON spcd.index_group = sdv2.value_id
				LEFT JOIN static_data_active_deactive sdad ON sdad.type_id = 4008 --  type id :4000	
				LEFT JOIN static_data_value sdv4 ON sdv4.value_id = spcd.market_value_desc						
				WHERE 1 = 1'
	
	IF @is_active IS NOT NULL 
		SET @sql_select += ' AND spcd.is_active = ''' + @is_active + ''''
	
	SET @sql_select += ' ORDER BY sdv.[description], curve_name'
	--print(@sql_select)
	EXEC(@sql_select)
END 

ELSE IF @flag = 'v'
BEGIN
	DECLARE @app_admin_role_check INT, @is_user_on_admin_group INT
	SET @app_admin_role_check =   dbo.FNAAppAdminRoleCheck(dbo.FNADBUser())

	SET @is_user_on_admin_group = dbo.FNAIsUserOnAdminGroup(dbo.FNADBUser(), 0)

	SET @sql_select = 'SELECT DISTINCT
							sdv.[description] AS s_curve_type,
							dbo.FNATRMWinHyperlink(''a'', 10102600, spcd.curve_name, ABS(spcd.source_curve_def_id),null,null,null,null,null,null,null,null,null,null,null,0) curve_name,
							spcd.source_curve_def_id, 
							spcd.curve_id,
							spcd.curve_des,
							sdv1.[description] AS s_granularity,
							sc2.currency_name AS source_currency_id,
							su.uom_name,
							sc.commodity_name, 
							spcd.market_value_id,
							CASE WHEN spcd.Forward_settle = ''s'' THEN ''Settlement'' 
									WHEN spcd.Forward_settle = ''f'' THEN ''Forward''
								ELSE NULL END AS Forward_settle,
							CASE WHEN spcd.formula_id IS NOT NULL THEN ''Yes'' ELSE ''No'' END formula_id,
							sdv2.code as index_group,
							CASE WHEN spcd.is_active = ''y'' THEN ''Yes'' ELSE ''No'' END AS is_active
					   FROM source_price_curve_def spcd
					   LEFT JOIN source_commodity sc ON spcd.commodity_id = sc.source_commodity_id
					   LEFT JOIN source_currency sc2 ON spcd.source_currency_id = sc2.source_currency_id
					   LEFT JOIN static_data_value sdv ON spcd.source_curve_type_value_id = sdv.value_id
					   LEFT JOIN source_uom su ON spcd.uom_id = su.source_uom_id 					
					   LEFT JOIN static_data_value sdv1 ON spcd.Granularity =  sdv1.value_id
					   LEFT JOIN static_data_value sdv2 ON spcd.index_group = sdv2.value_id '

	IF (@app_admin_role_check = 0) and (@is_user_on_admin_group = 0)
	BEGIN
		SET @sql_select = @sql_select + ' LEFT JOIN source_price_curve_def_privilege spcdp ON spcd.source_curve_def_id = spcdp.source_curve_def_id 
										  LEFT JOIN application_role_user aru ON spcdp.role_id = aru.role_id AND spcdp.role_id IS NOT NULL
										  WHERE 1 = 1 AND (aru.user_login_id = ''' + dbo.FNADBUser() +''' OR (spcdp.id IS NOT NULL AND spcdp.role_id IS NULL))'
	END
	ELSE 
	BEGIN
		SET @sql_select = @sql_select + ' WHERE 1 = 1 '
	END
	SET @sql_select = @sql_select + ' AND spcd.is_active = ''y'' ORDER BY sdv.[description], curve_name'

	EXEC(@sql_select)
END
ELSE IF @flag = 'z'
BEGIN 
	IF EXISTS(SELECT TOP 1 is_active is_active FROM static_data_active_deactive WHERE is_active = 1 
		AND type_id =  4008)
	BEGIN 
		SELECT 1 is_active
	END
	ELSE
	BEGIN 
		SELECT 0 is_active
	END 
END 


ELSE IF @flag = 'j'
BEGIN
	SET @sql_select = ' SELECT	spcd.source_curve_def_id,
								spcd.curve_name,
								MIN(fpl.is_enable) [status]
						FROM #final_privilege_list fpl
						' + CASE WHEN dbo.FNAIsUserOnAdminGroup(dbo.FNADBUser(), 0) = 0 THEN 'INNER JOIN ' ELSE 'LEFT JOIN ' END + '
						 source_price_curve_def spcd ON spcd.source_curve_def_id = fpl.value_id						
	WHERE obligation = ''y'' GROUP BY spcd.source_curve_def_id, spcd.curve_name
						ORDER BY spcd.curve_name asc'
	EXEC(@sql_select)
END

 