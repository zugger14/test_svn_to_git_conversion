IF OBJECT_ID(N'spa_portfolio_hierarchy_sublevel', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_portfolio_hierarchy_sublevel]
GO 

CREATE PROCEDURE [dbo].[spa_portfolio_hierarchy_sublevel]
	@entity_id integer,
	@hierarchy_level integer AS
	SELECT entity_id, entity_name,hierarchy_level, parent_entity_id
	FROM portfolio_hierarchy
	WHERE parent_entity_id=@entity_id
	and hierarchy_level <> @hierarchy_level
	

	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, "Portfolio sub-levels", 
				"spa_portfolio_hierarchy_sublevel", "DB Error", 
				"select of portfolio hierarchy sublevel data failed.", ''
	else
		Exec spa_ErrorHandler 0, 'Portofolio sub-level', 
				'spa_portfolio hierarchy sub-level', 'Success', 
				'Sub-nodes successfully selected.', ''