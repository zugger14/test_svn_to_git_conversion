
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_GetAllPriceCurveDefinitions]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_GetAllPriceCurveDefinitions]

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
GO
--EXEC spa_GetAllPriceCurveDefinitions NULL,NULL,NULL,'d'
--exec spa_GetAllPriceCurveDefinitions 'a'
--EXEC [spa_GetAllPriceCurveDefinitions] 'a',

CREATE  PROCEDURE [dbo].[spa_GetAllPriceCurveDefinitions]  
	@flag VARCHAR(1) = NULL,
	@sub_id VARCHAR(100) = NULL ,
	@curve_type INT = NULL,
	@commodity_id INT = NULL,
	--@flag VARCHAR(1) = NULL,
	@strategy_id INT = NULL,
	@index_group INT = NULL,
	@granularity INT = NULL,
	@source_price_curve_def_id INT = NULL,
	@contract_id INT = NULL,
	@is_active CHAR(1) = NULL
AS


/*
	@flag								Function

	'l'	(alternative for flag 'v')		Returns data for exporting(HTML,XML,etc)
	'k'	(alternative for flag 'v')		Skips @strategy_id in condition if it is null

*/

SET NOCOUNT ON
--SET @strategy_id = 58
DECLARE @sql VARCHAR(8000)

CREATE TABLE #temp(
					CurveId INT
					, Name VARCHAR(100) COLLATE DATABASE_DEFAULT
					, Description VARCHAR(200) COLLATE DATABASE_DEFAULT
					, formula_id INT
					, granularity INT
				)
IF @flag IS NULL 
  SET @flag='s'

--SELECT @flag
--PRINT @flag
IF @flag IN ('e', 's')
BEGIN
	--flag 'e' is used for dropdown list
	IF @sub_id IS NOT NULL
	BEGIN
		--SELECT IF the passed id is strategy id	
		SET @sql='
		INSERT INTO #temp

			SELECT spcd.source_curve_def_id AS CurveId, spcd.curve_name AS Name, spcd.curve_des AS Description, spcd.formula_id AS formula_id, spcd.granularity 
			FROM  source_price_curve_def spcd 
			INNER JOIN  source_price_curve_def_privilege spcdf
			ON  spcd.source_curve_def_id = spcdf.source_curve_def_id AND spcdf.sub_entity_id IS NULL AND spcdf.role_id IS NULL
		WHERE 
			
			(source_curve_type_value_id = ISNULL('+CAST(@curve_type AS VARCHAR)+', source_curve_type_value_id))
			AND (commodity_id=ISNULL('+CASE WHEN @commodity_id IS NULL THEN 'NULL' ELSE CAST(@commodity_id AS VARCHAR) END+', commodity_id))
			UNION 

		  SELECT spcd.source_curve_def_id AS CurveId, spcd.curve_name AS Name, spcd.curve_des AS Description, spcd.formula_id AS formula_id, spcd.granularity as granularity 
			FROM  source_price_curve_def spcd 
			INNER JOIN source_price_curve_def_privilege spcdf
			ON  spcd.source_curve_def_id = spcdf.source_curve_def_id 
			AND spcdf.sub_entity_id in('+@sub_id+') 
			LEFT JOIN application_role_user ar ON ar.role_id=spcdf.role_id
			AND ar.user_login_id=dbo.FNADBUser()
			WHERE 
 			(source_curve_type_value_id = ISNULL('+CAST(@curve_type AS VARCHAR)+', source_curve_type_value_id))
 			AND (commodity_id=ISNULL('+CASE WHEN @commodity_id IS NULL THEN 'NULL' ELSE CAST(@commodity_id AS VARCHAR) END+', commodity_id)) 

			UNION 

			SELECT spcd.source_curve_def_id AS CurveId, spcd.curve_name AS Name, spcd.curve_des AS Description, spcd.formula_id AS formula_id, spcd.granularity as granularity 
			FROM  source_price_curve_def spcd 
			INNER JOIN source_price_curve_def_privilege spcdf
			ON  spcd.source_curve_def_id = spcdf.source_curve_def_id 
			AND spcdf.sub_entity_id IS NULL
			LEFT JOIN application_role_user ar ON ar.role_id=spcdf.role_id
			AND ar.user_login_id=dbo.FNADBUser()
			WHERE 
			(source_curve_type_value_id = ISNULL('+CAST(@curve_type AS VARCHAR)+', source_curve_type_value_id))
			AND (commodity_id=ISNULL('+CASE WHEN @commodity_id IS NULL THEN 'NULL' ELSE CAST(@commodity_id  AS VARCHAR) END+', commodity_id))

			UNION

			SELECT spcd.source_curve_def_id AS CurveId, spcd.curve_name AS Name, spcd.curve_des AS Description, spcd.formula_id AS formula_id, spcd.granularity as granularity
			FROM  source_price_curve_def spcd 
			INNER JOIN source_price_curve_def_privilege spcdf
			ON  spcd.source_curve_def_id = spcdf.source_curve_def_id 
			AND spcdf.sub_entity_id in('+@sub_id+') AND spcdf.role_id IS NULL
			WHERE 
			(source_curve_type_value_id = ISNULL('+CAST(@curve_type AS VARCHAR)+', source_curve_type_value_id))
			AND (commodity_id=ISNULL('+CASE WHEN @commodity_id IS NULL THEN 'NULL' ELSE CAST(@commodity_id  AS VARCHAR) END+', commodity_id))'
			 

		--PRINT @sql
		EXEC (@sql) 
		SELECT CurveId,
		       dbo.FNAHyperLinkText(10102610, [Name], curveId),
		       dbo.FNAHyperLinkText(10102610, [Description], curveId),
		       [Description],
		       CASE 
		            WHEN formula_id IS NULL THEN 'n'
		            ELSE 'y'
		       END HasFormula,
		       granularity
		FROM   #temp
		ORDER BY
		       NAME

	END
	ELSE
	BEGIN
		--SELECT IF the passed id is book id
		--PRINT 'chk1'
		
		DECLARE @stra_id INT --get from book id
		
		SELECT @stra_id  = stra.entity_id 
		FROM portfolio_hierarchy book
		INNER JOIN portfolio_hierarchy stra ON stra.entity_id= book.parent_entity_id
		INNER JOIN portfolio_hierarchy sub ON stra.parent_entity_id= sub.entity_id
		AND book.entity_id = @strategy_id
		
		
		SET @sql = '
					SELECT 
						DISTINCT d.source_curve_def_id AS [Curve ID]
						, d.curve_name + CASE WHEN e.source_system_id = 2 THEN '''' ELSE ''.'' + e.source_system_name END AS [Index]
						'
						+
						--CASE WHEN @flag = 'e' THEN '' ELSE ', d.curve_des AS Description' END
						
						+
						'						
					FROM 
						source_price_curve_def d 
						INNER JOIN source_system_description e ON e.source_system_id = d.source_system_id 
						INNER JOIN fas_strategy fs ON d.source_system_id = fs.source_system_id
					WHERE 1 = 1 
						AND (d.source_curve_type_value_id = ISNULL(' + ISNULL(CAST(@curve_type AS VARCHAR), 'NULL') + ', d.source_curve_type_value_id))
						AND (d.commodity_id = ISNULL(' + ISNULL(CAST(@commodity_id AS VARCHAR), 'NULL') + ', d.commodity_id))
						
					'
		
		IF @strategy_id IS NOT NULL
			SET @sql = @sql + 'AND fs.fas_strategy_id = ' + CAST (@stra_id AS VARCHAR)
		IF @granularity IS NOT NULL 
			SET @sql = @sql + 'AND d.granularity = ' + CAST(@granularity AS VARCHAR)
		SET @sql = @sql + '						
						--AND d.source_system_id = 2
					ORDER BY d.curve_name + CASE WHEN e.source_system_id = 2 THEN '''' ELSE ''.'' + e.source_system_name END
					'
		--PRINT @sql
		EXEC (@sql)
					
	END
END
ELSE IF @flag = 'f' 
BEGIN
		SELECT DISTINCT d.source_curve_def_id AS ID, 
			d.curve_name + CASE WHEN e.source_system_id=2 THEN '' ELSE '.' + e.source_system_name END AS [Curve], 
			d.curve_des AS Description
			FROM source_price_curve_def d INNER JOIN
			source_system_description e ON  e.source_system_id = d.source_system_id
			WHERE 
			(d.source_curve_type_value_id = ISNULL(@curve_type, d.source_curve_type_value_id))
			AND (d.commodity_id=ISNULL(@commodity_id, d.commodity_id))
			AND ((d.contract_id IS NOT NULL AND contract_id = @contract_id) OR d.contract_id IS NULL) 
			ORDER BY d.curve_name + CASE WHEN e.source_system_id=2 THEN '' ELSE '.' + e.source_system_name END 

END
ELSE IF @flag = 'a' 
BEGIN
	-- Removed old logic because, privileges defined for "Price Curve" are now handled with static_data_privilege instead of source_price_curve_def_privilege.
	CREATE TABLE #final_privilege_list(value_id INT, is_enable NVARCHAR(20) COLLATE DATABASE_DEFAULT)
	EXEC dbo.spa_static_data_privilege @flag = 'p', @source_object = 'pricecurve'

	SET @sql = '
		SELECT DISTINCT d.source_curve_def_id,
				d.curve_name AS curve_name,
				MIN(fpl.is_enable) [status]
		FROM #final_privilege_list fpl' +
		CASE WHEN dbo.FNAIsUserOnAdminGroup(dbo.FNADBUser(), 0) = 0 THEN '
			INNER JOIN '
			ELSE '
			LEFT JOIN ' END + '
			source_price_curve_def d ON d.source_curve_def_id = fpl.value_id
		INNER JOIN source_system_description ssd ON ssd.source_system_id = d.source_system_id
		GROUP BY d.source_curve_def_id, d.curve_name, ssd.source_system_id, ssd.source_system_name
		ORDER BY curve_name
	'
	EXEC(@sql)
END

ELSE IF @flag='g'
BEGIN
	SELECT spcd.curve_name ,su.uom_name UOM ,sdv.code Granularity FROM source_price_curve_def spcd 
	LEFT JOIN source_uom su ON su.source_uom_id=spcd.uom_id
	LEFT JOIN static_data_value sdv ON sdv.value_id=spcd.granularity
	WHERE spcd.source_curve_def_id=@curve_type

END

ELSE IF @flag='d'
BEGIN
--SELECT * FROM source_price_curve_def WHERE source_curve_type_value_id=577

 SELECT source_curve_def_id AS CurveId, CASE WHEN curve_id <> curve_name THEN  curve_id + ' - ' + curve_name ELSE curve_name END AS Name
	FROM  source_price_curve_def WHERE source_curve_type_value_id=577
END

/***************  To get the value curve for environmental product ******************************************Added by Bikash Subba*********/

ELSE IF @flag='o'
BEGIN

 SELECT source_curve_def_id AS CurveId,curve_name AS Name,curve_des AS Description 
	FROM  source_price_curve_def WHERE obligation='y'
END

ELSE IF @flag  in('v','l','k')
BEGIN
	
	SET @sql='
	insert into #temp
		SELECT DISTINCT spcd.source_curve_def_id AS CurveId, spcd.curve_name AS Name, spcd.curve_des AS Description, spcd.formula_id AS formula_id, spcd.granularity as granularity 
		FROM  source_price_curve_def spcd '

-- OLD Logic
--	IF @sub_id IS NOT NULL
--	BEGIN
--		SET @sql = @sql + '
--		INNER JOIN source_price_curve_def_privilege spcdf
--		ON  spcd.source_curve_def_id = spcdf.source_curve_def_id 
--		AND spcdf.sub_entity_id= '+ CAST(@sub_id  AS VARCHAR)
--	END
-- Changes made by Sudeep Lamsal


	IF @strategy_id  IS NULL AND @flag = 'v'
	BEGIN
		DECLARE @app_admin_role_check INT
		SET @app_admin_role_check = dbo.FNAAppAdminRoleCheck(dbo.FNADBUser())
				
		If @app_admin_role_check = 1
			SET @sql = @sql + '
			LEFT JOIN source_price_curve_def_privilege spcdf
			ON  spcd.source_curve_def_id = spcdf.source_curve_def_id 
			AND spcdf.sub_entity_id IS NULL'
		ELSE
			SET @sql = @sql + '
			INNER JOIN source_price_curve_def_privilege spcdf
			ON  spcd.source_curve_def_id = spcdf.source_curve_def_id 
			AND spcdf.sub_entity_id IS NULL'
	END
	ELSE 
	IF @strategy_id  IS NULL AND @flag IN('k','l')
	
	BEGIN 
		SET @app_admin_role_check = dbo.FNAAppAdminRoleCheck(dbo.FNADBUser())
		
		If @app_admin_role_check = 1
		BEGIN
			SET @sql = @sql + '
			LEFT JOIN source_price_curve_def_privilege spcdf
			ON  spcd.source_curve_def_id = spcdf.source_curve_def_id 
			--AND spcdf.sub_entity_id IS NULL'
		END	
		ELSE
		SET @sql = @sql + '
		INNER JOIN source_price_curve_def_privilege spcdf
		ON  spcd.source_curve_def_id = spcdf.source_curve_def_id 
		--AND spcdf.sub_entity_id IS NULL'	
	END
	ELSE
	BEGIN
		SET @sql = @sql + '
		INNER JOIN source_price_curve_def_privilege spcdf
		ON  spcd.source_curve_def_id = spcdf.source_curve_def_id 
		AND spcdf.sub_entity_id= '+ CAST(@strategy_id  AS VARCHAR)
	END
	
	SET @sql = @sql + '
		LEFT JOIN application_role_user ar ON ar.role_id=spcdf.role_id
		AND ar.user_login_id=dbo.FNADBUser()
		WHERE 1=1 '

	IF @curve_type is not null
		SET @sql = @sql + ' AND source_curve_type_value_id = ' + CAST(@curve_type AS VARCHAR)
		
	IF @index_group IS NOT NULL
	set @sql=@sql+ ' AND spcd.index_group='+cast(@index_group as varchar)


	IF @commodity_id is not null
		SET @sql = @sql + ' AND commodity_id=' + CAST(@commodity_id  AS VARCHAR)


	--PRINT @sql


	IF @sub_id IS NOT NULL
		BEGIN


			--SELECT IF the passed id is strategy id	
		SET @sql= @sql + '
			UNION

			SELECT spcd.source_curve_def_id AS CurveId, spcd.curve_name AS Name, spcd.curve_des AS Description, spcd.formula_id AS formula_id, spcd.granularity 
			FROM  source_price_curve_def spcd 
			INNER JOIN  source_price_curve_def_privilege spcdf
			ON  spcd.source_curve_def_id = spcdf.source_curve_def_id AND spcdf.sub_entity_id IS NULL AND spcdf.role_id IS NULL
		WHERE 
			
			(source_curve_type_value_id = ISNULL('+CAST(@curve_type AS VARCHAR)+', source_curve_type_value_id))
			AND (commodity_id=ISNULL('+CASE WHEN @commodity_id IS NULL THEN 'NULL' ELSE CAST(@commodity_id AS VARCHAR) END+', commodity_id))

			UNION 

		  SELECT spcd.source_curve_def_id AS CurveId, spcd.curve_name AS Name, spcd.curve_des AS Description, spcd.formula_id AS formula_id, spcd.granularity as granularity 
			FROM  source_price_curve_def spcd 
			INNER JOIN source_price_curve_def_privilege spcdf
			ON  spcd.source_curve_def_id = spcdf.source_curve_def_id 
			AND spcdf.sub_entity_id in('+@sub_id+') 
			LEFT JOIN application_role_user ar ON ar.role_id=spcdf.role_id
			AND ar.user_login_id=dbo.FNADBUser()
			WHERE 
 			(source_curve_type_value_id = ISNULL('+CAST(@curve_type AS VARCHAR)+', source_curve_type_value_id))
 			AND (commodity_id=ISNULL('+CASE WHEN @commodity_id IS NULL THEN 'NULL' ELSE CAST(@commodity_id AS VARCHAR) END+', commodity_id)) 

			UNION 

			SELECT spcd.source_curve_def_id AS CurveId, spcd.curve_name AS Name, spcd.curve_des AS Description, spcd.formula_id AS formula_id, spcd.granularity as granularity 
			FROM  source_price_curve_def spcd 
			INNER JOIN source_price_curve_def_privilege spcdf
			ON  spcd.source_curve_def_id = spcdf.source_curve_def_id 
			AND spcdf.sub_entity_id IS NULL
			LEFT JOIN application_role_user ar ON ar.role_id=spcdf.role_id
			AND ar.user_login_id=dbo.FNADBUser()
			WHERE 
			(source_curve_type_value_id = ISNULL('+CAST(@curve_type AS VARCHAR)+', source_curve_type_value_id))
			AND (commodity_id=ISNULL('+CASE WHEN @commodity_id IS NULL THEN 'NULL' ELSE CAST(@commodity_id  AS VARCHAR) END+', commodity_id))

			UNION

			SELECT spcd.source_curve_def_id AS CurveId, spcd.curve_name AS Name, spcd.curve_des AS Description, spcd.formula_id AS formula_id, spcd.granularity as granularity
			FROM  source_price_curve_def spcd 
			INNER JOIN source_price_curve_def_privilege spcdf
			ON  spcd.source_curve_def_id = spcdf.source_curve_def_id 
			AND spcdf.sub_entity_id in('+@sub_id+') AND spcdf.role_id IS NULL
			WHERE 
			(source_curve_type_value_id = ISNULL('+CAST(@curve_type AS VARCHAR)+', source_curve_type_value_id))
			AND (commodity_id=ISNULL('+CASE WHEN @commodity_id IS NULL THEN 'NULL' ELSE CAST(@commodity_id  AS VARCHAR) END+', commodity_id))
		'

		

--		EXEC spa_print @sql
--		EXEC (@sql) 
--		SELECT CurveId,dbo.FNAHyperLinkText(10102610,[Name],curveId),dbo.FNAHyperLinkText(10102610,[Description],curveId),[Description], 
--		CASE WHEN formula_id IS NULL THEN 'n' ELSE 'y' END HasFormula, granularity 
--		FROM #temp ORDER BY name

		END
		
	
	--PRINT @sql 
	EXEC (@sql) 
	
--OLD Logic 
--	SELECT CurveId,dbo.FNAHyperLinkText(10102610,[Name],curveId),
--		/*dbo.FNAHyperLinkText(10102610,[Description],curveId),[Description] 250 */dbo.FNAHyperLinkText(10102610,[Name],curveId),[Name], 
--	CASE WHEN formula_id IS NULL THEN 'n' ELSE 'y' END HasFormula, granularity 
--	FROM #temp ORDER BY name

-- Changes made by Sudeep Lamsal

--SELECT * FROM #temp
--RETURN

	IF (@flag IN('v','k')) 
	BEGIN
		SELECT tmp.CurveId,
				dbo.FNAHyperLinkText(10102610,(tmp.[Name]+'.'+ssd.source_system_name),tmp.curveId),
				dbo.FNAHyperLinkText(10102610,(tmp.[Name]),tmp.curveId),
				[Name],
				CASE WHEN tmp.formula_id IS NULL THEN 'n' ELSE 'y' END HasFormula, 
				tmp.granularity 
		FROM #temp tmp 
		INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id=tmp.CurveId
		INNER JOIN source_system_description ssd ON ssd.source_system_id = spcd.source_system_id
		ORDER BY [Name]
	END
	ELSE IF(@flag = 'l') 
	BEGIN
		SELECT tmp.CurveId,tmp.[Name]+CASE WHEN ssd.source_system_id=2 THEN '' ELSE '.'+ssd.source_system_name END as [Name],tmp.Description
		FROM #temp tmp 
			INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id=tmp.CurveId
			INNER JOIN source_system_description ssd ON ssd.source_system_id = spcd.source_system_id
		ORDER BY [Name]
	END
END
IF @flag = 'z' -- to get all source_price_curve_ids
BEGIN
	SELECT 
		DISTINCT d.source_curve_def_id AS [Curve ID]
		, CASE WHEN d.curve_id <> d.curve_name THEN d.curve_id + ' - ' + d.curve_name ELSE d.curve_name END  + CASE WHEN e.source_system_id = 2 THEN '' ELSE '.' + e.source_system_name END AS [Index]
	FROM 
		source_price_curve_def d 
		INNER JOIN source_system_description e ON e.source_system_id = d.source_system_id 
		INNER JOIN fas_strategy fs ON d.source_system_id = fs.source_system_id
	WHERE 1 = 1 
		AND (d.source_curve_type_value_id = ISNULL(NULL, d.source_curve_type_value_id))
		AND (d.commodity_id = ISNULL(NULL, d.commodity_id))
	ORDER BY CASE WHEN d.curve_id <> d.curve_name THEN d.curve_id + ' - ' + d.curve_name ELSE d.curve_name END  + CASE WHEN e.source_system_id = 2 THEN '' ELSE '.' + e.source_system_name END 
END
ELSE IF @flag = 'p' --for view price previlage
BEGIN
	DECLARE @user_pre_role_id VARCHAR(MAX)

	SELECT  @user_pre_role_id = STUFF(( SELECT DISTINCT ',' +  CAST(spcdf.role_id AS VARCHAR(10)) FROM source_price_curve_def spcd
	INNER JOIN source_price_curve_def_privilege spcdf ON  spcd.source_curve_def_id = spcdf.source_curve_def_id 
	INNER JOIN application_role_user ar ON  ar.role_id = spcdf.role_id
		AND ar.user_login_id = dbo.FNADBUser() 
	FOR XML PATH('')
			), 1, 1, '')
	
	--PRINT @user_pre_role_id
	
	SELECT DISTINCT spcd.source_curve_def_id 
			, spcd.curve_name 
			, spcd.curve_des 
			, spcd.formula_id
			, spcd.granularity 
			, spcdf.role_id
			, spcdf.sub_entity_id
			, spcd.source_curve_type_value_id
		INTO #user_pre_curve_ids
	FROM  source_price_curve_def spcd  
	INNER JOIN source_price_curve_def_privilege spcdf ON spcd.source_curve_def_id = spcdf.source_curve_def_id  
	INNER JOIN dbo.FNASplit(@user_pre_role_id, ',') user_pre_role_id ON user_pre_role_id.item = spcdf.role_id
		AND spcd.source_curve_type_value_id = @curve_type
	
	
	--SELECT  * FROM #user_pre_curve_ids
	SET @sql = 'INSERT INTO #temp
				SELECT DISTINCT spcd.source_curve_def_id AS CurveId
						, spcd.curve_name AS Name
						, spcd.curve_des AS Description
						, spcd.formula_id AS formula_id
						, spcd.granularity as granularity 
				FROM  source_price_curve_def spcd  
				INNER JOIN source_price_curve_def_privilege spcdf ON spcd.source_curve_def_id = spcdf.source_curve_def_id'
	
	IF @curve_type IS NOT NULL
		SET @sql = @sql + ' AND spcd.source_curve_type_value_id = ' + CAST(@curve_type AS VARCHAR(20))
	
	IF @index_group IS NOT NULL
		SET @sql = @sql + ' AND spcd.index_group=' + CAST(@index_group AS VARCHAR)
	
		
	IF @strategy_id IS NOT NULL 
		SET @sql = @sql + ' WHERE spcdf.sub_entity_id = ' + CAST(@strategy_id  AS VARCHAR(500)) + ' AND spcdf.role_id IS NULL 
							UNION 
							SELECT source_curve_def_id AS CurveId
									, curve_name AS Name
									, curve_des AS Description
									, formula_id AS formula_id
									, granularity as granularity 
							FROM   #user_pre_curve_ids where sub_entity_id = ' + CAST(@strategy_id  AS VARCHAR(500))
	
	
	IF @strategy_id IS NULL 
	BEGIN
		SET @sql = @sql + ' AND spcdf.sub_entity_id IS NULL 
								AND spcdf.role_id IS NULL 
							UNION 
							SELECT source_curve_def_id AS CurveId
									, curve_name AS Name
									, curve_des AS Description
									, formula_id AS formula_id
									, granularity as granularity 
							FROM   #user_pre_curve_ids'
	END

	--PRINT(isnull(@sql, 'sql is null'))
	EXEC(@sql)	
	
	SET @sql = 'SELECT	tmp.CurveId,dbo.FNAHyperLinkText(10102610, (tmp.[Name] + CASE WHEN ssd.source_system_id = 2 THEN '''' ELSE ''.'' + ssd.source_system_name END), tmp.curveId)
			, dbo.FNAHyperLinkText(10102610, (tmp.[Name] + CASE WHEN ssd.source_system_id = 2 THEN '''' ELSE ''.'' + ssd.source_system_name END), tmp.curveId)
			, [Name]
			, CASE WHEN tmp.formula_id IS NULL THEN ''n'' ELSE ''y'' END HasFormula, tmp.granularity 
	FROM #temp tmp 
	INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id=tmp.CurveId
	INNER JOIN source_system_description ssd ON ssd.source_system_id = spcd.source_system_id 
	WHERE 1=1 '
	
	IF @source_price_curve_def_id IS NOT NULL
	BEGIN
		SET @sql = @sql + ' AND spcd.source_curve_def_id = ' + CAST(@source_price_curve_def_id AS VARCHAR) 
	END
	SET @sql = @sql + ' ORDER BY [Name]'
	EXEC(@sql)
	--PRINT(@sql)
END
