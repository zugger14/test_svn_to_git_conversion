IF OBJECT_ID(N'spa_portfolio_hierarchy_rootnode', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_portfolio_hierarchy_rootnode]
GO
 
CREATE PROCEDURE [dbo].[spa_portfolio_hierarchy_rootnode] 
AS
	SELECT entity_id, entity_name, hierarchy_level,parent_entity_id
	FROM portfolio_hierarchy
	WHERE (entity_id = parent_entity_id)
	AND hierarchy_level = (select max(hierarchy_level) from portfolio_hierarchy)

	

	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, "Highest Level Portfolio hierarchy", 
				"spa_portfolio_hierarchy", "DB Error", 
				"select of highest level of portfolio hierarchy failed.", ''
	else
		Exec spa_ErrorHandler 0, 'Portofolio Root note level', 
				'spa_portfolio_hierarchy', 'Success', 
				'Root Node successfully selected.', ''