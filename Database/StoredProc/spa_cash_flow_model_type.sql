/****** Object:  StoredProcedure [dbo].[spa_cash_flow_model_type]******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_cash_flow_model_type]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_cash_flow_model_type]
GO
/****** Object:  StoredProcedure [dbo].[spa_cash_flow_model_type]******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[spa_cash_flow_model_type]
@flag CHAR(1)			,
@model_id INT			=NULL,
@model_name VARCHAR(50)	=NULL,
@model_desc VARCHAR(100) = NULL

AS

DECLARE @sql_stmt VARCHAR(8000)

IF @flag = 's'
BEGIN 
	SELECT @sql_stmt = '
		SELECT cfmt.model_id As [Model ID], cfmt.model_name AS [Model Group Name], 
			cfmt.model_desc [Model Description]
			FROM cash_flow_model_type cfmt
			WHERE 1=1 '
	IF @model_id IS NOT NULL
	SET	@sql_stmt = @sql_stmt + 'AND cfmt.model_id= '+ cast(@model_id AS VARCHAR)
		
	exec spa_print @sql_stmt
	
	EXEC(@sql_stmt)
	
	
END 

ELSE IF @flag = 'a'
BEGIN
	SELECT cfmt.model_name,cfmt.model_desc
		FROM cash_flow_model_type cfmt 
		WHERE cfmt.model_id = @model_id 
END 

ELSE IF @flag = 'i'
BEGIN 
	IF NOT EXISTS (SELECT 'X' from cash_flow_model_type where model_id = @model_id)
	BEGIN
		INSERT INTO cash_flow_model_type (model_name,model_desc) 
			VALUES (@model_name,@model_desc)
	END	
	ELSE	
	BEGIN
		EXEC spa_ErrorHandler -1, 'Insert Model Name.', 
				'spa_cash_flow_model_type', 'DB Error', 
				'Model Name Already Exists.', ''
		RETURN
	END

	IF @@ERROR <> 0
	BEGIN 
		Exec spa_ErrorHandler @@ERROR, 'Insert Model Name.', 
				'spa_cash_flow_model_type', 'DB Error', 
				'Model Name Insert Failed.', ''
		RETURN
	END
	ELSE EXEC spa_ErrorHandler 0, 'Insert Model Name.', 
				'spa_cash_flow_model_type', 'Success', 
				'Successfully Inserted Model Name.',''
END 

ELSE IF @flag = 'u'
BEGIN 
	BEGIN TRY
		UPDATE cash_flow_model_type 
			SET model_name = @model_name,
			model_desc = @model_desc
		WHERE model_id = @model_id

		Exec spa_ErrorHandler 0, 'Update Model Name.', 
					'spa_cash_flow_model_type', 'Success', 
					'Successfully Updated Model Name.',''
	END TRY
	BEGIN CATCH
		If @@ERROR =2601
		BEGIN 
			Exec spa_ErrorHandler -1, 'Update Model Name.', 
					'spa_cash_flow_model_type', 'DB Error', 
					'Model Name Already Exists.', ''
			RETURN
		END
		ELSE Exec spa_ErrorHandler -1, 'Update Model Name.', 
					'spa_cash_flow_model_type', 'DB Error', 
					'Update Model Name Failed.', ''
	END CATCH
END 

ELSE IF @flag = 'd'
BEGIN TRY
	BEGIN TRAN
		DELETE FROM cash_flow_model_type WHERE model_id = @model_id
	COMMIT
	EXEC spa_ErrorHandler 0, 'Delete Model Name.', 
				'spa_cash_flow_model_type', 'Success', 
				'Successfully Deleted Model Name.', ''
END TRY
BEGIN CATCH
	ROLLBACK
	EXEC spa_ErrorHandler -1, 'Delete Model Name.', 
				'spa_cash_flow_model_type', 'DB Error', 
				'Delete Model Name Failed.', ''
	
END CATCH

ELSE IF @flag = 'e'
BEGIN 
	SELECT cfmt.model_id,cfmt.model_name,model_desc FROM cash_flow_model_type cfmt
END 





















