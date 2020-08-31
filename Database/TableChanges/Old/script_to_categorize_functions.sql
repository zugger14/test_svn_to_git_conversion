DECLARE @product_ids VARCHAR(200)
	, @function_ids VARCHAR(4000)
	, @category_ids VARCHAR(500)

IF OBJECT_ID(N'tempdb..#collect_function_category_detail') IS NOT NULL DROP TABLE #collect_function_category_detail
IF OBJECT_ID(N'tempdb..#collect_product_detail') IS NOT NULL DROP TABLE #collect_product_detail

CREATE TABLE #collect_function_category_detail (
	sno					INT IDENTITY(1,1)
	, function_ids		VARCHAR(4000)
	, product_ids		VARCHAR(200)
	, category_ids		VARCHAR(500)
)

CREATE TABLE #collect_product_detail (
	product_id		INT,
	product_name	VARCHAR(50)
)

INSERT INTO #collect_product_detail(product_id, product_name)
EXEC spa_farrms_product 'p'

SELECT @product_ids = COALESCE(@product_ids + ',', '') + CAST(product_id AS VARCHAR(8)) FROM #collect_product_detail

--Collect
INSERT INTO #collect_function_category_detail(function_ids, product_ids, category_ids)
SELECT '-856,-841,-807,-801,822,823,853,874,886', @product_ids, 27405			--Date Time
UNION
SELECT '-863,-865,857,860,862,868,869,834,-900,-888', @product_ids, 27401			--Deal
UNION
SELECT '-902,816,838,873', @product_ids, 27402			--Logical
UNION
SELECT '828,821,810,809,808,807,806,-813,-908', @product_ids, 27400			--Math
UNION
SELECT '801,804,805,802,803,800,-802,-803,-804,-805,-806', @product_ids, 27406			--Operators
UNION
SELECT '890,835', @product_ids, 27407			--Others
UNION
SELECT '891,859,858,-909,877', @product_ids, 27404			--PNL
UNION
SELECT '896,894,889,-818,-819,-820,-821,-826,-838,-844,-851,-852,-853,-855,-873,-874,-897,-899,298005,-872,-914,-916', @product_ids, 27403			--Price
UNION
SELECT '-811,861,820,813,-854,-866,-871,-901, -912', @product_ids, 27409			--Reference
UNION
SELECT '-847,899,898,897,850,846,845,844,818,815,812,811,-816,-817,-824,-848,-849,-862,-864,-896,-898', @product_ids, 27408			--Volume

--SELECT * FROM #collect_function_category_detail ORDER BY sno ASC
--RETURN
	
	DECLARE cur_function_category CURSOR LOCAL FOR

	SELECT function_ids, product_ids, category_ids
	FROM #collect_function_category_detail
	ORDER BY sno ASC
	OPEN cur_function_category
		FETCH NEXT FROM cur_function_category INTO @function_ids, @product_ids, @category_ids
		WHILE @@FETCH_STATUS = 0   
		BEGIN 							
			--SELECT  @product_ids, @category_ids, @function_ids
			
			--Product wise function distribution
			INSERT INTO map_function_product(product_id, function_id)
			SELECT p.item product, f.item 
			FROM static_data_value sdv
			INNER JOIN dbo.FNASplit(@function_ids, ',') f ON f.item = sdv.value_id
			CROSS JOIN dbo.FNASplit(@product_ids, ',') p 
			LEFT JOIN map_function_product mfp ON mfp.function_id = f.item AND p.item = mfp.product_id
			WHERE TYPE_ID = 800 AND mfp.map_function_product_id IS NULL
	
			--Category wise function distribution
			INSERT INTO map_function_category(category_id, function_id)
			SELECT c.item, f.item  
			FROM static_data_value sdv
			INNER JOIN dbo.FNASplit(@function_ids, ',') f ON f.item = sdv.value_id
			CROSS JOIN dbo.FNASplit(@category_ids, ',') c
			LEFT JOIN map_function_category mfc ON mfc.category_id = c.item AND mfc.function_id = sdv.value_id
			WHERE TYPE_ID = 800 AND mfc.map_function_category_id IS NULL	
						
			FETCH NEXT FROM cur_function_category INTO @function_ids, @product_ids, @category_ids
		END
	CLOSE cur_function_category
	DEALLOCATE  cur_function_category
	PRINT 'cur_function_category cursor ends'					
	
EXEC spa_ErrorHandler 0, 'Function Categorization', 
			'Function Categorization', 'Success',
			'Function Categorization completed.', ''

			
