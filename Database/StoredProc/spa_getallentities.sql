IF OBJECT_ID(N'spa_getallentities', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_getallentities]
GO 

CREATE PROCEDURE [dbo].[spa_getallentities]
AS

SELECT     entity_id, entity_name
FROM  portfolio_hierarchy
WHERE hierarchy_level = 2
union
SELECT     a.entity_id, b.entity_name + '/' + a.entity_name AS Expr1
FROM         portfolio_hierarchy a INNER JOIN
                      portfolio_hierarchy b ON a.parent_entity_id = b.entity_id
WHERE     (a.hierarchy_level = 1 AND b.hierarchy_level = 2)
union                  
SELECT a.entity_id, b.entity_name + '/' + c.entity_name + '/' + a.entity_name
FROM   portfolio_hierarchy a, portfolio_hierarchy b, portfolio_hierarchy c
WHERE     a.parent_entity_id = c.entity_id 
AND c.parent_entity_id = b.entity_id 
AND (a.hierarchy_level = 0 AND 
b.hierarchy_level = 2 AND
c.hierarchy_level = 1)

IF @@ERROR <> 0
    EXEC spa_ErrorHandler @@ERROR,
         'All entities',
         'spa_getallentities',
         'DB Error',
         'Failed to select all entities.',
         ''
ELSE
    EXEC spa_ErrorHandler 0,
         'All Entities',
         'spa_getallentities',
         'Success',
         'Entities successfully selected.',
         ''