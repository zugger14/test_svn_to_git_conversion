IF OBJECT_ID(N'spa_system_user',N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_system_user]
GO 

CREATE PROC [dbo].[spa_system_user]	
	@flag CHAR(1),
	@system_user_id INT=NULL

AS

IF @flag = 's'
BEGIN
	SELECT	  sdv.value_id [Value ID]
			, sdv.type_id [Type ID] 
			, sdv.code [User]
			, sdv.description [Description]
			--, sdv.entity_id
			--, sdv.xref_value_id
			--, sdv.xref_value
			--, sdv.category_id
	FROM static_data_value sdv 
	WHERE type_id = @system_user_id
END
