IF OBJECT_ID(N'[dbo].[spa_Get_All_Subsidiaries]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_Get_All_Subsidiaries]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--===========================================================================================
--This Procedure returns all subsidiaries for a given function id
--Input Parameters:
--===========================================================================================

CREATE PROCEDURE [dbo].[spa_Get_All_Subsidiaries] 
	@function_id INT = NULL,
	@flag CHAR(1) = NULL	
AS
SET NOCOUNT ON
IF @flag = 's'
BEGIN
	SELECT  entity_id, entity_name FROM portfolio_hierarchy WHERE hierarchy_level = 2	
	AND entity_id <> -1
	ORDER BY entity_name
END
ELSE 
BEGIN
	SELECT entity_id, entity_name FROM portfolio_hierarchy
	WHERE entity_type_value_id = 525 
		AND entity_id <> -1 
	ORDER BY entity_name
	
END	






