/****** Object:  StoredProcedure [dbo].[spa_cash_flow_model_type_detail]******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_cash_flow_model_type_detail]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_cash_flow_model_type_detail]
GO
/****** Object:  StoredProcedure [dbo].[spa_cash_flow_model_type_detail]******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[spa_cash_flow_model_type_detail]
@flag			CHAR(1)				  ,
@model_type_id	INT				= NULL,
@model_type		INT				= NULL,
@description	VARCHAR(100)	= NULL,
@formula_id		INT				= NULL,
@model_id		INT				= NULL,
@model_name		VARCHAR(100)	= NULL,
@model_duration	VARCHAR(100)	= NULL,
@at_risks		CHAR(1)			= NULL,
@type			CHAR(1)			= NULL 

AS

DECLARE @sql_stmt VARCHAR(8000)

IF @flag = 's'
BEGIN 
	SELECT @sql_stmt = '
		SELECT cfmtd.model_type_id As [Model Type ID], cfmtd.model_name [Model Name], sdv.code AS [Model Type], 
				cfmtd.description [Description],CASE WHEN cfmtd.type = ''a'' THEN ''Actual'' 
				WHEN cfmtd.type = ''f'' THEN ''Forecast'' ELSE '''' END [Type], cfmtd.model_id [Model ID]
			FROM cash_flow_model_type_detail cfmtd
			INNER JOIN static_data_value sdv ON sdv.value_id = cfmtd.model_type
			LEFT JOIN formula_editor fe ON fe.formula_id = cfmtd.formula_id
			WHERE 1=1 '
			
			IF @model_id IS NOT NULL
				SET @sql_stmt = @sql_stmt + ' AND cfmtd.model_id='+ CAST(@model_id AS VARCHAR)
		
	exec spa_print @sql_stmt
	EXEC(@sql_stmt)	
END 

ELSE IF @flag = 'a'
BEGIN
	SELECT cfmtd.model_type, cfmtd.description, cfmtd.formula_id, cfmtd.model_id ,cfmtd.model_name
	,cfmtd.model_duration,cfmtd.at_risks
			FROM cash_flow_model_type_detail  cfmtd
		WHERE cfmtd.model_type_id = @model_type_id 
END 

ELSE IF @flag = 'i'
BEGIN 
	IF NOT EXISTS (SELECT 'X' from cash_flow_model_type_detail where model_type = @model_type AND model_id=@model_id)
	BEGIN
		INSERT INTO cash_flow_model_type_detail(model_name, model_type, model_duration, [description], formula_id, model_id, at_risks, type)
				VALUES (@model_name, @model_type, @model_duration, @description, @formula_id, @model_id, @at_risks, @type)
	END	
	ELSE	
	BEGIN
		EXEC spa_ErrorHandler -1, 'Insert Model Type Detail.', 
				'spa_cash_flow_model_type_detail', 'DB Error', 
				'Model type already exists.', ''
		RETURN
	END

	IF @@ERROR <> 0
	BEGIN 
		EXEC spa_ErrorHandler @@ERROR, 'Insert Model Type Detail.', 
				'spa_cash_flow_model_type_detail', 'DB Error', 
				'Model type detail insert failed.', ''
		RETURN
	END
	ELSE EXEC spa_ErrorHandler 0, 'Insert Model Type Detail.', 
				'spa_cash_flow_model_type_detail', 'Success', 
				'Successfully inserted model type detail.',''
END 

ELSE IF @flag = 'u'
BEGIN 
	BEGIN TRY
		IF NOT EXISTS (SELECT 'X' from cash_flow_model_type_detail where model_type=@model_type AND model_type_id<>@model_type_id AND model_id=@model_id)
		BEGIN
			UPDATE cash_flow_model_type_detail 
				SET model_type	  = @model_type,
					model_name	  = @model_name,
					model_duration = @model_duration,
					[description] = @description,
					formula_id	  = @formula_id,
					model_id	  = @model_id,
					at_risks	  = @at_risks,
					type		  =	@type
				WHERE model_type_id	  = @model_type_id 
			
			EXEC spa_ErrorHandler 0, 'Update Model Type Detail.', 
					'spa_cash_flow_model_type_detail', 'Success', 
					'Successfully updated model type detail.',''		
		END	
		ELSE
		BEGIN 
			EXEC spa_ErrorHandler -1, 'Update Model Type Detail.', 
					'spa_cash_flow_model_type_detail', 'DB Error', 
					'Model type already exists.', ''
			RETURN
		END

	END TRY
	BEGIN CATCH
		BEGIN
				Exec spa_ErrorHandler -1, 'Update Model Type Detail.', 
					'spa_cash_flow_model_type_detail', 'DB Error', 
					'Update model type detail failed.', ''
		END
	END CATCH
END 

ELSE IF @flag = 'd'
BEGIN 
	DELETE FROM cash_flow_model_type_detail WHERE model_type_id = @model_type_id
	
	If @@ERROR <> 0
	BEGIN 
		Exec spa_ErrorHandler @@ERROR, 'Delete Model Type Detail.', 
				'spa_cash_flow_model_type_detail', 'DB Error', 
				'Delete model type detail failed.', ''
		RETURN
	END
	ELSE Exec spa_ErrorHandler 0, 'Delete Model Type Detail.', 
				'spa_cash_flow_model_type_detail', 'Success', 
				'Successfully deleted model type detail.',''				
END 

ELSE IF @flag = 'e'
BEGIN 
	SELECT sdv.value_id, sdv.code
	  FROM static_data_value sdv 
		WHERE sdv.[type_id] = 17100			
END 























