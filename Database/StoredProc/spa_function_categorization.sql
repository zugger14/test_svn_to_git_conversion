IF OBJECT_ID(N'[dbo].[spa_function_categorization]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_function_categorization]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: msingh@pioneersolutionsglobal.com
-- Create date: 2014-07-08
 
-- Params:
-- @flag CHAR(1) - Operation flag
-- 's' List all function defined.
-- @flag = 'c' --List categorized functions only
/*
	Usages
	@flag = 's' --List all functions with bullet categogy list.
	@flag = 'f' --List unmap functions only
	@flag = 'c' --List categorized functions only
	@flag = 'i' --Categorized function/operators.
	@flag = 'u' --Mapped if selected function doesnot exists or Uncategorized function which are not selected.
	@flag = 'd' --Uncategorized functions.
*/

-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_function_categorization]
    @flag CHAR(1)
    , @product_id  VARCHAR(4000) = NULL
    , @category_id VARCHAR(4000) = NULL
    , @function_id VARCHAR(4000) = NULL
AS
 
DECLARE @sql VARCHAR(MAX)
 
IF @flag = 's'
BEGIN
   SELECT mfc.map_function_category_id [Function ID]  
		, dbo.FNAToolTipText(mfc.function_name, mfc.function_name) [Functions/Operators]
		, '<ul class=ul-inside-grid>' + ((  
			SELECT '<li class=grid-list-item-clean>' + mfc_inner.function_name 
						FROM map_function_category mfc_inner
      						WHERE mfc_inner.function_name  = mfc.function_name       	       
						ORDER BY mfc_inner.map_function_category_id
						FOR XML PATH (''), TYPE).value('.[1]', 'VARCHAR(5000)')) 
		+ '</u>' Category
		, '<ul class=ul-inside-grid>' + ((  
			SELECT '<li class=grid-list-item-clean>' + af_inner.function_name 
				FROM map_function_product mfp_inner
				inner join application_functions af_inner ON af_inner.function_id = mfp_inner.product_id
      				WHERE mfp_inner.function_name  = mfc.function_name       	       
				ORDER BY af_inner.function_name
				FOR XML PATH (''), TYPE).value('.[1]', 'VARCHAR(5000)')) 
		+ '</u>' Product
		, STUFF(((  
			SELECT ',' + CAST(sdv_inner.value_id AS VARCHAR(10))
						FROM map_function_category mfc_inner
						inner join static_data_value sdv_inner ON sdv_inner.value_id = mfc_inner.category_id 
      						WHERE mfc_inner.function_name  = mfc.function_name  
						ORDER BY sdv_inner.value_id
						FOR XML PATH (''), TYPE).value('.[1]', 'VARCHAR(5000)'))
			, 1,1,'') category_ids
		  
		, STUFF(((  
			SELECT ',' + CAST(af_inner.function_id AS VARCHAR(10) )
				FROM map_function_product mfp_inner
				inner join application_functions af_inner ON af_inner.function_id = mfp_inner.product_id
      				WHERE mfp_inner.function_name  = mfc.function_name   	       
				ORDER BY af_inner.function_name
				FOR XML PATH (''), TYPE).value('.[1]', 'VARCHAR(5000)')) 
		, 1,1,'') product_ids
	FROM map_function_category mfc 
	LEFT JOIN static_data_value sdv_cat ON sdv_cat.value_id = mfc.category_id 
	LEFT JOIN map_function_product mfp ON mfp.function_name = mfc.function_name
	LEFT JOIN application_functions af ON mfp.product_id = af.function_id AND af.func_ref_id IS NULL
	GROUP BY  mfc.map_function_category_id, mfc.function_name
   ORDER BY mfc.function_name
 
END
ELSE IF @flag = 'a'
BEGIN
	SET @sql = '
				SELECT mfc.map_function_category_id  [Function ID] 
					, mfc.function_name  [Function] 
					, ''<ul class=ul-inside-grid>'' + ((  
						SELECT ''<li class=grid-list-item-clean>'' + sdv_inner.code + ''</li>''
									FROM map_function_category mfc_inner
									inner join static_data_value sdv_inner ON sdv_inner.value_id = mfc_inner.category_id 
      									WHERE mfc_inner.function_name  = mfc.function_name   	       
									ORDER BY mfc_inner.map_function_category_id
									FOR XML PATH (''''), TYPE).value(''.[1]'', ''VARCHAR(5000)'')) 
					+ ''</u>'' Category
					, ''<ul>'' + ((  
						SELECT ''<li class=grid-list-item-clean>'' + af_inner.function_name + ''</li>''
							FROM map_function_product mfp_inner
							inner join application_functions af_inner ON af_inner.function_id = mfp_inner.product_id
      							WHERE mfp_inner.function_name  = mfc.function_name          	       
							ORDER BY af_inner.function_name
							FOR XML PATH (''''), TYPE).value(''.[1]'', ''VARCHAR(5000)'')) 
					+ ''</ul>'' Product	
					
			FROM map_function_category mfc 
			LEFT JOIN static_data_value sdv_cat ON sdv_cat.value_id = mfc.category_id 
			LEFT JOIN map_function_product mfp ON mfp.function_name = mfc.function_name
			LEFT JOIN application_functions af ON mfp.product_id = af.function_id AND af.func_ref_id IS NULL
			WHERE 1 = 1 '
			+
			CASE WHEN @product_id IS NOT NULL THEN ' AND mfp.product_id IN (' + @product_id + ') ' ELSE '' END
			+
			CASE WHEN @category_id IS NOT NULL THEN ' AND mfc.category_id IN (' + @category_id + ') ' ELSE '' END
			+ ' GROUP BY mfc.map_function_category_id, mfc.function_name   ORDER BY mfc.function_name ASC'
			
			EXEC spa_print @sql
			EXEC(@sql)
END
ELSE IF @flag = 'f' --List unmap functions only
BEGIN				
	
    SET @sql = '
			SELECT  sdv.type_id, 
					sdv.value_id,
					dbo.FNAToolTipText(sdv.code, sdv.description) AS [Functions/Operators]  
			FROM static_data_value sdv
			LEFT JOIN map_function_product mfp ON mfp.function_id = sdv.value_id
			LEFT JOIN application_functions af ON mfp.product_id = af.function_id AND func_ref_id IS NULL
			LEFT JOIN map_function_category mfc ON mfc.function_id = sdv.value_id
			LEFT JOIN static_data_value sdv_cat ON sdv_cat.value_id = mfc.category_id    
			WHERE sdv.TYPE_ID = 800 AND (mfc.category_id IS  NULL AND mfp.product_id IS  NULL) 
			ORDER BY sdv.code ASC'
			
			EXEC spa_print @sql
			EXEC(@sql)
END
ELSE IF @flag = 'c' --List categorized functions only
BEGIN
    SET @sql = '
			SELECT  sdv.type_id, 
					sdv.value_id,
					dbo.FNAToolTipText(sdv.code, sdv.description) AS [Functions/Operators]  
			FROM static_data_value sdv
			LEFT JOIN map_function_product mfp ON mfp.function_id = sdv.value_id
			LEFT JOIN application_functions af ON mfp.product_id = af.function_id AND func_ref_id IS NULL
			LEFT JOIN map_function_category mfc ON mfc.function_id = sdv.value_id
			LEFT JOIN static_data_value sdv_cat ON sdv_cat.value_id = mfc.category_id    
			WHERE sdv.TYPE_ID = 800 '
			+ CASE WHEN NULLIF(@product_id, '') IS NOT NULL THEN ' AND mfp.product_id = ' + @product_id ELSE '' END +
			+ CASE WHEN NULLIF(@category_id, '') IS NOT NULL THEN ' AND mfc.category_id = ' + @category_id ELSE '' END +
			' ORDER BY sdv.code ASC'
			
			EXEC spa_print @sql
			EXEC(@sql)
END
--ELSE IF @flag = 't' --test purpose only
--BEGIN
--	SELECT sdv.value_id   
--		, STUFF(((  
--			SELECT ',' + CAST(sdv_inner.value_id AS VARCHAR(10))
--						FROM map_function_category mfc_inner
--						inner join static_data_value sdv_inner ON sdv_inner.value_id = mfc_inner.category_id 
--      						WHERE mfc_inner.function_id  = sdv.value_id       	       
--						ORDER BY sdv_inner.value_id
--						FOR XML PATH (''), TYPE).value('.[1]', 'VARCHAR(5000)')), 1,1,'')
		  
--		, STUFF(((  
--			SELECT ',' + CAST(af_inner.function_id AS VARCHAR(10) )
--				FROM map_function_product mfp_inner
--				inner join application_functions af_inner ON af_inner.function_id = mfp_inner.product_id
--      				WHERE mfp_inner.function_id  = sdv.value_id       	       
--				ORDER BY af_inner.function_name
--				FOR XML PATH (''), TYPE).value('.[1]', 'VARCHAR(5000)')) , 1,1,'')
			
--	FROM static_data_value sdv
--	LEFT JOIN map_function_category mfc ON mfc.function_id = sdv.value_id
--	LEFT JOIN static_data_value sdv_cat ON sdv_cat.value_id = mfc.category_id 
--	LEFT JOIN map_function_product mfp ON mfp.function_id = sdv.value_id
--	LEFT JOIN application_functions af ON mfp.product_id = af.function_id AND af.func_ref_id IS NULL
--	WHERE sdv.TYPE_ID = 800  AND mfc.category_id IN (27400,27401,27402)   
--	GROUP BY sdv.value_id  
--END
ELSE IF @flag = 'i'
BEGIN
	BEGIN TRY
		--Product wise function distribution
		INSERT INTO map_function_product(product_id, function_name)
		SELECT p.item product, f.item 
		FROM dbo.FNASplit(@function_id, ',') f
		CROSS JOIN dbo.FNASplit(@product_id, ',') p 
		LEFT JOIN map_function_product mfp ON mfp.function_name = f.item AND p.item = mfp.product_id
		WHERE mfp.product_id IS NULL
	
		--Category wise function distribution
		INSERT INTO map_function_category(category_id, function_name)
		SELECT c.item, f.item  
		FROM dbo.FNASplit(@function_id, ',') f
		CROSS JOIN dbo.FNASplit(@category_id, ',') c
		LEFT JOIN map_function_category mfc ON mfc.category_id = c.item AND mfc.function_name = f.item
		WHERE mfc.category_id IS NULL	
		
		EXEC spa_ErrorHandler
			@error = 0,
			@msgType1 = 'map_function_category',
			@msgType2 = 'spa_function_categorization',
			@msgType3 = 'Success',
			@msg = 'Successfully saved data.',
			@recommendation = null,
			@logFlag = null
	END TRY
	BEGIN CATCH
		EXEC spa_ErrorHandler
			@error = 1,
			@msgType1 = 'map_function_category',
			@msgType2 = 'spa_function_categorization',
			@msgType3 = 'Error',
			@msg = 'Failed to save data.',
			@recommendation = null,
			@logFlag = null
	END CATCH
END 
ELSE IF @flag = 'u'
BEGIN
	BEGIN TRY
		MERGE map_function_product AS rs  
		USING (SELECT p.item product, f.item function_name 
				FROM dbo.FNASplit(@function_id, ',') f
				CROSS JOIN dbo.FNASplit(@product_id, ',') p 
		) AS  source 
		ON (rs.product_id = source.product) AND (rs.function_name = source.function_name)	
		WHEN NOT MATCHED BY target THEN
			INSERT (product_id, function_name)
			VALUES(source.product, source.function_name)	
		WHEN NOT MATCHED BY source  AND rs.function_name = @function_id THEN
			DELETE ;
		--OUTPUT $action,  INSERTED.product_id,DELETED.product_id;
	
		MERGE map_function_category AS rs  
		USING (SELECT p.item category_id, f.item function_name 
				FROM dbo.FNASplit(@function_id, ',') f
				CROSS JOIN dbo.FNASplit(@category_id, ',') p 
		) AS  source 
		ON (rs.category_id = source.category_id) AND (rs.function_name = source.function_name)	
		WHEN NOT MATCHED BY target THEN
			INSERT (category_id, function_name)
			VALUES(source.category_id, source.function_name)	
		WHEN NOT MATCHED BY source  AND rs.function_name = @function_id THEN
			DELETE ;
	EXEC spa_ErrorHandler
			@error = 0,
			@msgType1 = 'map_function_category',
			@msgType2 = 'spa_function_categorization',
			@msgType3 = 'Success',
			@msg = 'Successfully saved data.',
			@recommendation = null,
			@logFlag = null
	END TRY
	BEGIN CATCH
		EXEC spa_ErrorHandler
			@error = 1,
			@msgType1 = 'map_function_category',
			@msgType2 = 'spa_function_categorization',
			@msgType3 = 'Error',
			@msg = 'Failed to save data.',
			@recommendation = null,
			@logFlag = null
	END CATCH	
   
END
ELSE IF @flag = 'd'
BEGIN
	BEGIN TRY
		DELETE mfc
		FROM  map_function_category mfc
		INNER JOIN dbo.FNASplit(@function_id, ',') f ON f.item = mfc.function_name
   
		DELETE mfp
		FROM  map_function_product mfp
		INNER JOIN dbo.FNASplit(@function_id, ',') f ON f.item = mfp.function_name
		
	EXEC spa_ErrorHandler
			@error = 0,
			@msgType1 = 'map_function_category',
			@msgType2 = 'spa_function_categorization',
			@msgType3 = 'Success',
			@msg = 'Function unmapped successfully.',
			@recommendation = null,
			@logFlag = null
	END TRY
	BEGIN CATCH
		EXEC spa_ErrorHandler
			@error = 1,
			@msgType1 = 'map_function_category',
			@msgType2 = 'spa_function_categorization',
			@msgType3 = 'Error',
			@msg = 'Failed to unmap function.',
			@recommendation = null,
			@logFlag = null
	END CATCH	
	
END