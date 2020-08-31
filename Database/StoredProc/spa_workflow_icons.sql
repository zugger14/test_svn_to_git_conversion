IF OBJECT_ID(N'[dbo].[spa_workflow_icons]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].spa_workflow_icons
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: rtuladhar@pioneersolutionsglobal.com
-- Create date: 2011-06-06
-- Description: CRUD operations for table time_zone
 
-- Params:
-- @flag CHAR(1) - Operation flag
-- ===========================================================================================================
CREATE PROCEDURE [dbo].spa_workflow_icons
    @flag CHAR(1), 
	@workflow_menu_id INT = NULL,
	@image_id INT = NULL
AS

SET NOCOUNT ON
 
  
DECLARE @SQL VARCHAR(MAX)
 
IF @flag = 's' -- select icons that is not used
BEGIN
    SELECT value_id id, LOWER(code) + '.png' name
	FROM static_data_value sdv
	LEFT JOIN  workflow_icons wi ON wi.image_id = sdv.value_id
	WHERE sdv.type_id = 44600
END
ELSE IF @flag = 'i'
BEGIN 
	BEGIN TRY
		BEGIN TRAN 
		MERGE workflow_icons AS stm
		USING (SELECT @workflow_menu_id workflow_menu_id, @image_id image_id) AS sd
		ON stm.workflow_menu_id = sd.workflow_menu_id
		WHEN MATCHED THEN UPDATE SET stm.image_id = sd.image_id, workflow_user = dbo.FNADBUser()
		WHEN NOT MATCHED THEN
		INSERT(workflow_menu_id, image_id, workflow_user)
		VALUES(sd.workflow_menu_id, sd.image_id, dbo.FNADBUser());
		
		COMMIT TRAN 
		EXEC spa_ErrorHandler 0,
			'Select Icon',
			'spa_workflow_icons',
			'Success',
			'Changes has been saved successfully.',
			''

	END TRY 
	BEGIN CATCH
		ROLLBACK TRAN
		EXEC spa_ErrorHandler -1,
				'Select Icon',
				'spa_workflow_icons',
				'DB Error',
				'Icon change failed.',
				''

	END CATCH
END
ELSE IF @flag = 'a'
BEGIN
	SELECT   workflow_icons_id
		, workflow_menu_id
		, sdv.code image_name
		, sdv.value_id
	FROM workflow_icons wi
	INNER JOIN static_data_value sdv ON sdv.value_id = wi.image_id
	WHERE workflow_menu_id = @workflow_menu_id	 
END 
 
ELSE IF @flag = 't'-- get_image_name
BEGIN
	SELECT   
		 sdv.code image_name
		, sdv.value_id
	FROM  static_data_value sdv  
	WHERE value_id = @image_id	 


END 

 
GO 