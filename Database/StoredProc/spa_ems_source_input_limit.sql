IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_ems_source_input_limit]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_ems_source_input_limit]


set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go


-- ================================================================================
-- Author:		<Sudeep Lamsal>
-- Create date: <18th March, 2010>
-- Update date: <>
-- Description:	<>
-- =================================================================================


CREATE PROCEDURE [dbo].[spa_ems_source_input_limit]
	@flag char(1)
	, @limit_type_id INT = NULL
	, @ems_type_id INT = NULL
	, @max_value FLOAT = NULL
	, @min_value FLOAT = NULL
	, @input_limit_id INT = NULL
	, @series_type_id INT = NULL
	, @uom INT = NULL
	, @source_id INT = NULL
	, @source CHAR(1) = NULL
	, @fas_book_id VARCHAR(500)=NULL
AS
DECLARE @sql VARCHAR(MAX)
BEGIN

	IF @flag='s' --List data in a grid on the basis of ems_source_input_id
	BEGIN
		/*
		SELECT     
				ems_source_input_limit.input_limit_id
				,ems_source_input_limit.criteria_id
				,static_data_value.code AS [Source Input Limit Name]
				,static_data_value.description AS [Limit Type]
				,ems_source_input_limit.curve_id
				,source_price_curve_def.curve_des AS [Emmission Type]
				,ems_source_input_limit.lower_limit_value AS [Lower Limit]
				,ems_source_input_limit.upper_limit_value AS [upper Limit]
				,source_price_curve_def.source_curve_def_id
				,ems_source_input_limit.ems_source_input_id
				,source_price_curve_def.uom_id AS [UOM]
				
		FROM dbo.static_data_value 
		INNER JOIN dbo.ems_source_input_limit
		ON dbo.static_data_value.value_id = dbo.ems_source_input_limit.criteria_id 
		INNER JOIN source_price_curve_def 
		ON dbo.ems_source_input_limit.curve_id = dbo.source_price_curve_def.source_curve_def_id
		WHERE  1=1 
		--(ems_source_input_limit.ems_source_input_id = @ems_source_input_id)
		*/
		
		SET @sql = 'SELECT     
						esil.input_limit_id as [Input Limit ID]
						, spcd.curve_id [Emmission Type]
						, ltv.code AS [Limit Type]
						, stv.code AS [Series Type]
						, rg.name + ''('' + rg.id + '')''  AS Source
						, ISNULL(esil.lower_limit_value, 0) AS [Lower Limit]
						, ISNULL(esil.upper_limit_value, 0) AS [Upper Limit]
						, su.uom_name AS [UOM]
					FROM dbo.ems_source_input_limit esil
					INNER JOIN dbo.source_price_curve_def spcd ON spcd.source_curve_def_id = esil.curve_id
					INNER JOIN dbo.static_data_value stv ON esil.series_value_id = stv.value_id
					INNER JOIN dbo.static_data_value ltv ON esil.criteria_id = ltv.value_id
					LEFT JOIN rec_generator rg ON rg.generator_id = esil.source_generator_id
					LEFT JOIN dbo.source_uom su ON su.source_uom_id = esil.uom_id
					WHERE  1=1'
					
					+ CASE WHEN @ems_type_id IS NOT NULL THEN ' AND esil.curve_id = ' + CAST(@ems_type_id AS VARCHAR) ELSE '' END
					+ CASE WHEN @limit_type_id IS NOT NULL THEN ' AND esil.criteria_id = ' + CAST(@limit_type_id AS VARCHAR) ELSE '' END
					+ CASE WHEN @source = 'y' OR @source = 'Y' THEN ' AND esil.source_generator_id IS NOT NULL' ELSE '' END
					+ CASE WHEN @fas_book_id IS NOT NULL THEN ' AND rg.fas_book_id IN ('+@fas_book_id+')' ELSE '' END
		
		EXEC spa_print @sql
		--RETURN
		EXEC(@sql)

	END

	ELSE IF @flag='a' -- LOADS data in windows after hitting update button in Grid of previous page.
	BEGIN
		/*
		SELECT dbo.ems_source_input_limit.criteria_id
				,source_price_curve_def.source_curve_def_id
				,ems_source_input_limit.lower_limit_value
				,ems_source_input_limit.upper_limit_value
				,ems_source_input_limit.ems_source_input_id
				,source_price_curve_def.source_curve_def_id
		FROM static_data_value INNER JOIN ems_source_input_limit 
		ON static_data_value.value_id = ems_source_input_limit.criteria_id 
		INNER JOIN source_price_curve_def 
		ON ems_source_input_limit.curve_id = source_price_curve_def.source_curve_def_id
		WHERE (ems_source_input_limit.input_limit_id = @input_limit_id)
		*/
		
		SELECT   
			input_limit_id
			, source_generator_id
			, criteria_id
			, curve_id
			, uom_id
			, series_value_id
			, lower_limit_value
			, upper_limit_value
		FROM dbo.ems_source_input_limit esil
		WHERE esil.input_limit_id = @input_limit_id
	END

	ELSE IF @flag='i'
	BEGIN
		BEGIN TRY
			INSERT INTO ems_source_input_limit
				(criteria_id
				, curve_id
				, lower_limit_value
				, upper_limit_value 
				, series_value_id 
				, uom_id
				, source_generator_id)
			VALUES(@limit_type_id, @ems_type_id, @min_value, @max_value, @series_type_id, @uom, @source_id)
			
			Exec spa_ErrorHandler 0, 'Successfully insert values', 
					'spa_ems_source_input_limit', 'Success', 
					'Successfully insert values.',''
		END TRY
		BEGIN CATCH
			EXEC spa_ErrorHandler @@ERROR, 'Failed to insert values', 
					'spa_ems_source_input_limit', 'DB Error', 
					'Failed to insert values.', ''
		END CATCH
		
	END
	ELSE IF @flag='u'
	BEGIN
		BEGIN TRY
			UPDATE ems_source_input_limit
			SET criteria_id = @limit_type_id
				, curve_id = @ems_type_id
				, lower_limit_value = @min_value
				, upper_limit_value = @max_value
				, series_value_id = @series_type_id
				, uom_id = @uom
				, source_generator_id = @source_id
			WHERE input_limit_id = @input_limit_id
			
			Exec spa_ErrorHandler 0, 'Successfully insert values.', 
			'spa_ems_source_input_limit', 'Success', 
			'Successfully insert values.',''
		END TRY
		BEGIN CATCH
			Exec spa_ErrorHandler @@ERROR, 'Failed to insert values.', 
			'spa_ems_source_input_limit', 'DB Error', 
			'Error Updating Ems Source Model Inputs.', ''
		END CATCH
	END

	ELSE IF @flag='d'
	BEGIN
		BEGIN TRY
			DELETE FROM ems_source_input_limit 
			WHERE input_limit_id=@input_limit_id
			
			Exec spa_ErrorHandler 0, 'Successfully delete values.', 
			'spa_ems_source_input_limit', 'Success', 
			'Successfully delete values.',''
		END TRY
		BEGIN CATCH
			Exec spa_ErrorHandler @@ERROR, 'Failed to delete values.', 
			'spa_ems_source_input_limit', 'DB Error', 
			'Error Deleting Ems Source Model Inputs.', ''
		END CATCH
	END	
	
END



