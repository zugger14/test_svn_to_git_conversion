IF OBJECT_ID(N'spa_Get_Volume_UOM', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_Get_Volume_UOM]
GO 

-- EXEC spa_Get_Volume_UOM null
-- drop proc spa_Get_Volume_UOM

CREATE PROCEDURE [dbo].[spa_Get_Volume_UOM]
--	@strategy_id Int = NULL 
AS

SELECT source_uom_id,
       uom_name
FROM   source_uom uom
ORDER BY uom_name