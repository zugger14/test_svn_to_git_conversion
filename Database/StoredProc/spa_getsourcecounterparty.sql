
/****** Object:  StoredProcedure [dbo].[spa_getsourcecounterparty]    Script Date: 02/26/2009 16:59:22 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_getsourcecounterparty]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_getsourcecounterparty]
GO
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[spa_getsourcecounterparty] 
	 @flag CHAR(1)
	, @eff_test_profile_id INT = NULL
	, @counterparty_type VARCHAR(5) = 'e'	
	, @source_system_id INT = NULL
	, @int_ext_flag CHAR(1) = NULL
	, @counterparty_id VARCHAR(8000) = NULL
	, @filter_value VARCHAR(1000) = NULL
AS 
SET NOCOUNT ON;

DECLARE @sql_stmt VARCHAR(5000)

IF @counterparty_type IS NULL
	SET @counterparty_type = 'e'

SELECT @filter_value = NULLIF(NULLIF(@filter_value, '<FILTER_VALUE>'), '')

IF @flag='c' -- Bring only those Counterparty which have Contract
BEGIN
	SET @sql_stmt = ' SELECT DISTINCT 
						   d.source_counterparty_id,
						   d.source_counterparty_id counterparty_id,
						   d.counterparty_name + ''.'' + CASE WHEN ssd.source_system_id = 2 THEN '''' ELSE '''' END AS counterparty_name
					  FROM   portfolio_hierarchy b
					  INNER JOIN fas_strategy c ON  b.parent_entity_id = c.fas_strategy_id
					  INNER JOIN source_system_description ssd ON  ssd.source_system_id = c.source_system_id
					  INNER JOIN source_counterparty d ON  d.source_system_id = ssd.source_system_id
					  LEFT JOIN rec_generator rg ON  d.source_counterparty_id = rg.ppa_counterparty_id
					  WHERE  1 = 1'
					  + CASE WHEN @eff_test_profile_id IS NOT NULL THEN ' AND b.entity_id =  '+CAST(@eff_test_profile_id AS VARCHAR) ELSE '' END  +'
					  AND d.int_ext_flag IN ('''+@counterparty_type+''')
					  ORDER BY counterparty_name '
END


ELSE IF @flag='d'
BEGIN
	SET @sql_stmt='
	SELECT DISTINCT 
	       d.source_counterparty_id,
	       d.counterparty_name + CASE WHEN ssd.source_system_id = 2 THEN '''' ELSE ''.'' + ssd.source_system_name END AS counterparty_name
	FROM   portfolio_hierarchy b
	INNER JOIN fas_strategy c ON  b.parent_entity_id = c.fas_strategy_id
	INNER JOIN source_system_description ssd ON  ssd.source_system_id = c.source_system_id
	INNER JOIN source_counterparty d ON  d.source_system_id = ssd.source_system_id
	WHERE  1 = 1 '
	+ CASE WHEN @eff_test_profile_id IS NOT NULL THEN ' AND b.entity_id =  '+CAST(@eff_test_profile_id AS VARCHAR) ELSE '' END 
	+' AND d.int_ext_flag IN ('''+@counterparty_type+''')  AND d.is_active = ''y''
	ORDER BY counterparty_name '
END

ELSE IF @flag='o' -- internal counterparty according to counterparty
BEGIN
	SET @sql_stmt = 'SELECT DISTINCT 
					             sc2.source_counterparty_id,
					             sc2.counterparty_name + CASE 
						                                  WHEN ssd.source_system_id = 2 THEN ''''
						                                  ELSE ''.'' + ssd.source_system_name
						                             END AS NAME
					FROM   counterparty_contract_address cca
					       INNER JOIN contract_group cg
					            ON  cca.contract_id = cg.contract_id
					       LEFT JOIN static_data_value sdv
					            ON  sdv.value_id = cca.contract_status
					       LEFT JOIN static_data_value sdv1
					            ON  sdv1.value_id = cca.rounding
					       LEFT JOIN source_counterparty sc2
					            ON  sc2.source_counterparty_id = cca.internal_counterparty_id
					       LEFT JOIN source_system_description ssd
					            ON  ssd.source_system_id = cg.source_system_id
					       INNER JOIN source_counterparty  AS sc
					            ON  sc.source_counterparty_id = cca.counterparty_id
					WHERE  1 = 1'

IF @counterparty_id IS NOT NULL
BEGIN
	SET @sql_stmt = @sql_stmt + ' AND cca.counterparty_id = ' + @counterparty_id 
END

SET @sql_stmt = @sql_stmt + ' AND sc2.int_ext_flag IN ('''+@counterparty_type+''')  AND sc2.is_active = ''y''
	ORDER BY NAME '

END

ELSE IF @flag='b' -- update mode in editable mode.
BEGIN
	--Modified to add privilege
	CREATE TABLE #final_privilege_list(value_id INT, is_enable VARCHAR(20) COLLATE DATABASE_DEFAULT )
	EXEC spa_static_data_privilege @flag = 'p', @source_object = 'counterparty'

	SET @sql_stmt='
		SELECT DISTINCT 
			d.source_counterparty_id,		
			d.counterparty_name  + CASE WHEN ssd.source_system_id=2 THEN '''' ELSE  ''.'' + ssd.source_system_name  END AS counterparty_name,
			MIN(cp.is_enable) [status]
		FROM #final_privilege_list cp 
		' + CASE WHEN dbo.FNAIsUserOnAdminGroup(dbo.FNADBUser(), 0) = 0 THEN 'INNER JOIN ' ELSE 'LEFT JOIN ' END + '
			source_counterparty d ON d.source_counterparty_id = cp.value_id
			INNER JOIN source_system_description ssd ON ssd.source_system_id = d.source_system_id
			INNER JOIN fas_strategy c ON ssd.source_system_id = c.source_system_id 
			INNER JOIN portfolio_hierarchy b ON b.parent_entity_id = c.fas_strategy_id
		WHERE 1=1 '
			+ CASE WHEN @eff_test_profile_id IS NOT NULL THEN ' AND b.entity_id ='+CAST(@eff_test_profile_id AS VARCHAR) ELSE '' END 
			+' AND d.int_ext_flag IN('''+@counterparty_type+''')
		GROUP BY d.source_counterparty_id, d.counterparty_name, ssd.source_system_id, ssd.source_system_name
		ORDER BY counterparty_name '
END
ELSE IF @flag='e'	-- Update and Copy dEal : Do not show Locked Counterparty in insert mode.
	SET @sql_stmt='
		select DISTINCT 
			d.source_counterparty_id,
			d.source_counterparty_id counterparty_id, 
			d.counterparty_name  + case when ssd.source_system_id=2 then '''' else  ''.'' + ssd.source_system_name  end as counterparty_name
		from 
			portfolio_hierarchy b inner join 
			fas_strategy c on b.parent_entity_id = c.fas_strategy_id inner join 
			source_system_description ssd on ssd.source_system_id = c.source_system_id inner join
			source_counterparty d on d.source_system_id = ssd.source_system_id 
			LEFT JOIN counterparty_credit_info cci ON d.source_counterparty_id = cci.Counterparty_id 
		where 1=1 '
			+ CASE WHEN @eff_test_profile_id IS NOT NULL THEN ' AND b.entity_id ='+CAST(@eff_test_profile_id AS VARCHAR) ELSE '' END 
			+' and d.int_ext_flag IN('''+@counterparty_type+''')
			AND ISNULL(cci.account_status,10592)<>10591
		order by counterparty_name '

ELSE IF @flag='q'	-- Insert and Copy dEal : Do not show Locked Counterparty, shows only active counterparty.
	SET @sql_stmt='
		select DISTINCT 
			d.source_counterparty_id,
			d.source_counterparty_id counterparty_id, 
			d.counterparty_name  + case when ssd.source_system_id=2 then '''' else  ''.'' + ssd.source_system_name  end as counterparty_name
		from 
			portfolio_hierarchy b inner join 
			fas_strategy c on b.parent_entity_id = c.fas_strategy_id inner join 
			source_system_description ssd on ssd.source_system_id = c.source_system_id inner join
			source_counterparty d on d.source_system_id = ssd.source_system_id 
			LEFT JOIN counterparty_credit_info cci ON d.source_counterparty_id = cci.Counterparty_id 
		where 1=1 '
			+ CASE WHEN @eff_test_profile_id IS NOT NULL THEN ' AND b.entity_id ='+CAST(@eff_test_profile_id AS VARCHAR) ELSE '' END 
			+' and d.int_ext_flag IN('''+@counterparty_type+''') 
			AND d.is_active = ''y''
			AND ISNULL(cci.account_status,10592)<>10591
		order by counterparty_name '
		
ELSE IF @flag = 'p'
BEGIN
	SELECT DISTINCT child.parent_counterparty_id, parent.counterparty_id FROM source_counterparty child 
	INNER JOIN source_counterparty parent ON child.parent_counterparty_id = parent.source_counterparty_id
	WHERE child.parent_counterparty_id IS NOT NULL
END
		
ELSE IF @flag = 'f'
BEGIN
	SET @sql_stmt='
		SELECT DISTINCT 
			sc.source_counterparty_id
			,sc.source_counterparty_id [Counterparty ID] 
			,sc.counterparty_name + CASE WHEN ssd.source_system_id=2 THEN '''' ELSE ''.'' + ssd.source_system_name  END AS [Pipeline Name]		
		FROM portfolio_hierarchy ph 
			INNER JOIN fas_strategy fs ON ph.parent_entity_id = fs.fas_strategy_id 
			INNER JOIN source_system_description ssd on ssd.source_system_id = fs.source_system_id 
			INNER JOIN source_counterparty sc on sc.source_system_id = ssd.source_system_id
			INNER JOIN delivery_path dp ON sc.source_counterparty_id = dp.counterParty
			LEFT JOIN delivery_path_detail dpd ON dp.path_id = dpd.path_id
			OR dp.path_id = dpd.path_name
		WHERE 1=1 '
			+ CASE WHEN @eff_test_profile_id IS NOT NULL THEN ' AND ph.entity_id ='+CAST(@eff_test_profile_id AS VARCHAR) ELSE '' END 
			+ CASE WHEN @source_system_id IS NOT NULL THEN ' AND ssd.source_system_id = ' + CAST(@source_system_id AS VARCHAR) ELSE '' END
			+ ' AND sc.is_active = ''y'' AND sc.int_ext_flag IN('''+@counterparty_type+''')'
	
			
	SET @sql_stmt = @sql_stmt + ' ORDER BY [Pipeline Name]'
END
ELSE IF @flag = 'n'
BEGIN
	SET @sql_stmt='
		SELECT DISTINCT 
			sc.source_counterparty_id [Counterparty ID] 
			,sc.counterparty_name + CASE WHEN ssd.source_system_id=2 THEN '''' ELSE ''.'' + ssd.source_system_name  END AS [Pipeline Name]		
		FROM portfolio_hierarchy ph 
			INNER JOIN fas_strategy fs ON ph.parent_entity_id = fs.fas_strategy_id 
			INNER JOIN source_system_description ssd on ssd.source_system_id = fs.source_system_id 
			INNER JOIN source_counterparty sc on sc.source_system_id = ssd.source_system_id
			INNER JOIN delivery_path dp ON sc.source_counterparty_id = dp.counterParty
			LEFT JOIN delivery_path_detail dpd ON dp.path_id = dpd.path_id
			OR dp.path_id = dpd.path_name
		WHERE 1=1 '
			+ CASE WHEN @eff_test_profile_id IS NOT NULL THEN ' AND ph.entity_id ='+CAST(@eff_test_profile_id AS VARCHAR) ELSE '' END 
			+ CASE WHEN @source_system_id IS NOT NULL THEN ' AND ssd.source_system_id = ' + CAST(@source_system_id AS VARCHAR) ELSE '' END
			+ ' AND sc.is_active = ''y'' AND sc.int_ext_flag IN('''+@counterparty_type+''')'

			
	SET @sql_stmt = @sql_stmt + ' ORDER BY [Pipeline Name]'
END
ELSE IF @flag = 's'
BEGIN
	SET @sql_stmt = 'SELECT '
	IF @filter_value IS NOT NULL AND @filter_value = '-1'
	BEGIN
		SET @sql_stmt += ' TOP 1 '
	END
	SET @sql_stmt += 'sc.source_counterparty_id,  
						CASE  
								WHEN sc.source_system_id = 2 THEN '''' + CASE WHEN sc.counterparty_id = sc.counterparty_name THEN sc.counterparty_id  ELSE sc.counterparty_id + '' - '' + sc.counterparty_name END 
								ELSE ssd.source_system_name + ''.'' + CASE WHEN sc.counterparty_id = sc.counterparty_name THEN sc.counterparty_id  ELSE sc.counterparty_id + '' - '' + sc.counterparty_name END 
						END [counterparty] 
					FROM   source_counterparty sc 
					INNER JOIN source_system_description ssd ON  ssd.source_system_id = sc.source_system_id'
	
	IF @filter_value IS NOT NULL AND @filter_value <> '-1'
	BEGIN
		SET @sql_stmt += ' INNER JOIN dbo.SplitCommaSeperatedValues(''' + @filter_value + ''') s ON s.item = sc.source_counterparty_id'
	END

	SET @sql_stmt += ' WHERE 1 = 1 '
	
	IF @int_ext_flag IS NOT NULL
		SET @sql_stmt = @sql_stmt + ' AND sc.int_ext_flag=''' + @int_ext_flag + ''''
	ELSE 
		SET @sql_stmt = @sql_stmt + ' AND sc.int_ext_flag <> ''b'''

	SET @sql_stmt = @sql_stmt + '
					 AND is_active = ''y'' ORDER BY CASE  
								WHEN sc.source_system_id = 2 THEN '''' + CASE WHEN sc.counterparty_id = sc.counterparty_name THEN sc.counterparty_id  ELSE sc.counterparty_id + '' - '' + sc.counterparty_name END 
								ELSE ssd.source_system_name + ''.'' + CASE WHEN sc.counterparty_id = sc.counterparty_name THEN sc.counterparty_id  ELSE sc.counterparty_id + '' - '' + sc.counterparty_name END 
						END '

END
ELSE IF @flag = 'r' -- shows only active counterparty.
BEGIN
	SET @sql_stmt='
		SELECT DISTINCT 
			sc.source_counterparty_id [Counterparty ID] 
			,sc.counterparty_name + CASE WHEN ssd.source_system_id=2 THEN '''' ELSE ''.'' + ssd.source_system_name  END AS [Counterparty Name]		
		FROM portfolio_hierarchy ph 
			INNER JOIN fas_strategy fs ON ph.parent_entity_id = fs.fas_strategy_id 
			INNER JOIN source_system_description ssd on ssd.source_system_id = fs.source_system_id 
			INNER JOIN source_counterparty sc on sc.source_system_id = ssd.source_system_id 		
		WHERE 1=1 '
			+ CASE WHEN @eff_test_profile_id IS NOT NULL THEN ' AND ph.entity_id ='+CAST(@eff_test_profile_id AS VARCHAR) ELSE '' END 
			+ CASE WHEN @source_system_id IS NOT NULL THEN ' AND ssd.source_system_id = ' + CAST(@source_system_id AS VARCHAR) ELSE '' END
			+ ' AND sc.int_ext_flag IN('''+@counterparty_type+''') 
			AND sc.is_active = ''y''				
		ORDER BY [Counterparty Name]'
END

ELSE IF @flag = 'm' -- shows counterparty in MeterID.
BEGIN
	SET @sql_stmt='
		SELECT DISTINCT 
		sc.source_counterparty_id,		
		sc.counterparty_name  + CASE WHEN ssd.source_system_id=2 THEN '''' ELSE  ''.'' + ssd.source_system_name  END AS counterparty_name
		FROM
		source_counterparty sc 
		INNER JOIN source_system_description ssd ON sc.source_system_id = ssd.source_system_id  
		INNER JOIN meter_counterparty m ON sc.source_counterparty_id = m.counterparty_id
		ORDER BY counterparty_name'
END

ELSE IF @flag = 'x' --show top 1 counterparty to populate on the apply cash module
BEGIN
	SELECT TOP(1) sc.source_counterparty_id
			,sc.source_counterparty_id [Counterparty ID] 
			,sc.counterparty_name + CASE WHEN ssd.source_system_id=2 THEN '' ELSE '.' + ssd.source_system_name  END AS [Counterparty Name]		
		FROM portfolio_hierarchy ph 
			INNER JOIN fas_strategy fs ON ph.parent_entity_id = fs.fas_strategy_id 
			INNER JOIN source_system_description ssd on ssd.source_system_id = fs.source_system_id 
			INNER JOIN source_counterparty sc on sc.source_system_id = ssd.source_system_id 		
		AND sc.int_ext_flag IN('i','e')				
		ORDER BY 3
END

ELSE IF @flag = 'a' --show counterparty of paticular source_deal_header_id

SET @sql_stmt='
	SELECT sc.source_counterparty_id, sc.counterparty_id 
	FROM source_deal_detail sdd 
		INNER JOIN source_deal_header sdh 
			ON sdh.source_deal_header_id = sdd.source_deal_header_id
		INNER JOIN source_counterparty sc 
			ON sc.source_counterparty_id = sdh.counterparty_id
	WHERE  sdd.source_deal_detail_id = 
	' + CAST(@source_system_id AS VARCHAR(10))
---PRINT @sql_stmt
EXEC(@sql_stmt)

IF @@ERROR <> 0 
		EXEC spa_ErrorHandler @@ERROR, 'source Counterparty', 
				'spa_getsourcecounterparty', 'DB Error', 
				'Failed to select source counterparties.', ''
