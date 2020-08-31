IF OBJECT_ID('dbo.spa_commodity_attribute_form') IS NOT NULL
	DROP PROCEDURE dbo.spa_commodity_attribute_form
GO

CREATE PROCEDURE dbo.spa_commodity_attribute_form 
	@flag CHAR(1), 
	@commodity_attribute_id VARCHAR(1000) = NULL,
	@column_name VARCHAR(1000) = NULL,
	@xml VARCHAR(MAX) = NULL,
	@call_from VARCHAR(100) = NULL
AS

/************************************
DECLARE @flag CHAR(1), @commodity_attribute_id VARCHAR(1000)

SET @flag = 'd'
SET @commodity_attribute_id = '7'

--***********************************/

SET NOCOUNT ON

DECLARE @sql VARCHAR(MAX)

IF @flag = 's'
BEGIN
	SELECT commodity_attribute_form_id, 
		commodity_attribute_id,
		commodity_attribute_value
	FROM commodity_attribute_form caf
	INNER JOIN dbo.FNASplit(@commodity_attribute_id, ',') it ON it.item = caf.commodity_attribute_id
END
ELSE IF @flag = 'd'
BEGIN
	BEGIN TRY
	BEGIN TRAN
		IF @call_from = 'setup_static_data'
		BEGIN
			DECLARE @idoc INT
			EXEC sp_xml_preparedocument @idoc OUTPUT, @xml
			
			IF OBJECT_ID('tempdb..#delete_static_data') IS NOT NULL 
				DROP TABLE #delete_static_data
      
			SELECT grid_id
			INTO #delete_static_data
			FROM   OPENXML(@idoc, '/Root/GridGroup/GridDelete', 1) 
			WITH (
				grid_id INT
			)
		
			DELETE caf5
			FROM commodity_form_attribute5 caf5
			INNER JOIN #delete_static_data dsd ON dsd.grid_id = caf5.commodity_attribute_id
		
			DELETE caf4
			FROM commodity_form_attribute4 caf4
			INNER JOIN #delete_static_data dsd ON dsd.grid_id = caf4.commodity_attribute_id
		
			DELETE caf3
			FROM commodity_form_attribute5 caf3
			INNER JOIN #delete_static_data dsd ON dsd.grid_id = caf3.commodity_attribute_id
		
			DELETE caf2
			FROM commodity_form_attribute5 caf2
			INNER JOIN #delete_static_data dsd ON dsd.grid_id = caf2.commodity_attribute_id
		
			DELETE caf1
			FROM commodity_form_attribute5 caf1
			INNER JOIN #delete_static_data dsd ON dsd.grid_id = caf1.commodity_attribute_id
		
			DELETE caf 
			FROM commodity_attribute_form caf 
			INNER JOIN #delete_static_data dsd ON dsd.grid_id = caf.commodity_attribute_id
		
			DELETE ca
			FROM commodity_attribute ca 
			INNER JOIN #delete_static_data dsd ON dsd.grid_id = ca.commodity_attribute_id
		END
		ELSE
		BEGIN
			DELETE caf
			FROM commodity_attribute_form caf
			INNER JOIN dbo.FNASplit(@commodity_attribute_id, ',') it ON it.item = caf.commodity_attribute_id

			DELETE ca
			FROM commodity_attribute ca
			INNER JOIN dbo.FNASplit(@commodity_attribute_id, ',') it ON it.item = ca.commodity_attribute_id
		END

	COMMIT TRAN
	EXEC spa_ErrorHandler 0
			, 'Commodity Attribute'
			, 'spa_commodity_attribute_form'
			, 'Success'
			, 'Changes have been saved Succesfully..'
			, @commodity_attribute_id
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN

		DECLARE @err_msg VARCHAR(MAX) = ERROR_MESSAGE()

		EXEC spa_ErrorHandler -1
			, 'Commodity Attribute'
			, 'spa_commodity_attribute_form'
			, 'Error'
			, @err_msg
			, ''
	END CATCH
END
ELSE IF @flag = 'c'--- select for combos
BEGIN 
	IF OBJECT_ID('tempdb..#commodity_attribute_form_detail') IS NOT NULL
		DROP TABLE commodity_attribute_form_detail
	 
	SELECT ca.commodity_attribute_id
			, ca.commodity_name
			, caf.commodity_attribute_form_id
			, caf.commodity_form_name
		INTO #commodity_attribute_form_detail
	FROM commodity_attribute ca
	INNER JOIN commodity_attribute_form caf ON caf.commodity_attribute_id = ca.commodity_attribute_id
	
	SET @sql = ' SELECT DISTINCT ' + CASE WHEN @column_name = 'origin' THEN 'value_id, commodity_origin_id '
								WHEN @column_name = 'form' THEN 'commodity_type_form_id, commodity_form_description'
								WHEN @column_name = 'attribute1' THEN 'commodity_attribute_id1, commodity_form_attribute1'
								WHEN @column_name = 'attribute2' THEN 'commodity_attribute_id2, commodity_form_attribute2 '
								WHEN @column_name = 'attribute3' THEN 'commodity_attribute_id3, commodity_form_attribute3 '
								WHEN @column_name = 'attribute4' THEN 'commodity_attribute_id4, commodity_form_attribute4 '							 
								ELSE 'commodity_attribute_id5 , commodity_form_attribute5' END + ' 
				FROM (
					SELECT
						commodity_origin_id.code commodity_origin_id
						, commodity_origin_id.value_id
						, commodity_form_id.commodity_form_description commodity_form_description
						, commodity_form_id.commodity_type_form_id commodity_type_form_id
						, cafd1.commodity_form_name commodity_form_attribute1
						, cafd1.commodity_attribute_id commodity_attribute_id1
						, cafd2.commodity_form_name commodity_form_attribute2
						, cafd2.commodity_attribute_id commodity_attribute_id2
						, cafd3.commodity_form_name commodity_form_attribute3
						, cafd3.commodity_attribute_id commodity_attribute_id3
						, cafd4.commodity_form_name  commodity_form_attribute4
						, cafd4.commodity_attribute_id commodity_attribute_id4
						, cafd5.commodity_form_name  commodity_form_attribute5
						, cafd5.commodity_attribute_id commodity_attribute_id5				 
					FROM source_deal_detail sdd
					LEFT JOIN commodity_origin co ON co.commodity_origin_id = sdd.origin
					LEFT JOIN static_data_value commodity_origin_id ON commodity_origin_id.value_id = co.origin
						AND type_id = 14000
					
					LEFT JOIN commodity_form cf ON cf.commodity_form_id = sdd.form
					LEFT JOIN commodity_type_form commodity_form_id ON commodity_form_id.commodity_type_form_id = cf.form
				
					LEFT JOIN commodity_form_attribute1 cfa1 ON cfa1.commodity_form_attribute1_id = sdd.attribute1
					LEFT JOIN #commodity_attribute_form_detail cafd1 ON cafd1.commodity_attribute_id = cfa1.attribute_id
						AND cafd1.commodity_attribute_form_id = cfa1.attribute_form_id

					LEFT JOIN commodity_form_attribute2 cfa2 ON cfa2.commodity_form_attribute2_id = sdd.attribute2
					LEFT JOIN #commodity_attribute_form_detail cafd2 ON cafd2.commodity_attribute_id = cfa2.attribute_id
						AND cafd2.commodity_attribute_form_id = cfa2.attribute_form_id
	
					LEFT JOIN commodity_form_attribute3 cfa3 ON cfa3.commodity_form_attribute3_id = sdd.attribute3
					LEFT JOIN #commodity_attribute_form_detail cafd3 ON cafd3.commodity_attribute_id = cfa3.attribute_id
						AND cafd3.commodity_attribute_form_id = cfa3.attribute_form_id

					LEFT JOIN commodity_form_attribute4 cfa4 ON cfa4.commodity_form_attribute4_id = sdd.attribute4
					LEFT JOIN #commodity_attribute_form_detail cafd4 ON cafd4.commodity_attribute_id = cfa4.attribute_id
						AND cafd4.commodity_attribute_form_id = cfa4.attribute_form_id

					LEFT JOIN commodity_form_attribute5 cfa5 ON cfa5.commodity_form_attribute5_id = sdd.attribute5
					LEFT JOIN #commodity_attribute_form_detail cafd5 ON cafd5.commodity_attribute_id = cfa5.attribute_id
						AND cafd5.commodity_attribute_form_id = cfa5.attribute_form_id
					WHERE sdd.origin		IS NOT NULL 
						OR sdd.form			IS NOT NULL 
						OR sdd.attribute1	IS NOT NULL 
						OR sdd.attribute2	IS NOT NULL 
						OR sdd.attribute3	IS NOT NULL 
						OR sdd.attribute4	IS NOT NULL 
						OR sdd.attribute5	IS NOT NULL ) a
				WHERE  1 = 1 
					AND ' + CASE WHEN @column_name = 'origin' THEN 'value_id IS NOT NULL '
								WHEN @column_name = 'form' THEN 'commodity_type_form_id IS NOT NULL'
								WHEN @column_name = 'attribute1' THEN 'commodity_attribute_id1 IS NOT NULL'
								WHEN @column_name = 'attribute2' THEN 'commodity_attribute_id2 IS NOT NULL'
								WHEN @column_name = 'attribute3' THEN 'commodity_attribute_id3 IS NOT NULL'
								WHEN @column_name = 'attribute4' THEN 'commodity_attribute_id4 IS NOT NULL'							 
								ELSE 'commodity_attribute_id5 IS NOT NULL' END 
	--PRINT @sql
	EXEC(@sql)

END
GO