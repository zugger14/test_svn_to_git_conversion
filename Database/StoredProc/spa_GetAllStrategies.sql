IF OBJECT_ID(N'spa_GetAllStrategies', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_GetAllStrategies]
GO 

--===========================================================================================
--This Procedure returns all strategies for a given sub
--Input Parameters:
-- sub_id:

-- DROP PROC spa_GetAllStrategies 

--===========================================================================================

CREATE PROCEDURE [dbo].[spa_GetAllStrategies]
	@sub_id INT  	
AS

SET NOCOUNT ON

IF @sub_id IS NOT NULL
    SELECT entity_id,
           entity_name
    FROM   portfolio_hierarchy
    WHERE  entity_type_value_id = 526
           AND parent_entity_id = @sub_id
    ORDER BY entity_name
ELSE
    SELECT entity_id,
           entity_name
    FROM   portfolio_hierarchy
    WHERE  entity_type_value_id = 526
    ORDER BY entity_name