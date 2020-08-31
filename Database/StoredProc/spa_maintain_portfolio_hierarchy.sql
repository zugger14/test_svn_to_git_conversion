IF OBJECT_ID(N'spa_maintain_portfolio_hierarchy', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_maintain_portfolio_hierarchy]
GO 

CREATE PROCEDURE [dbo].[spa_maintain_portfolio_hierarchy]
	@flag CHAR(1),
	@entity_id INTEGER = NULL,
	@entity_name VARCHAR(100) = NULL,
	@entity_type_value_id INTEGER = NULL,
	@hierarchy_level INTEGER = NULL,
	@parent_entity_id INTEGER = NULL,
	@level INT = NULL 
AS

IF @flag = 's'
BEGIN
	SELECT ph.entity_id, ph.entity_name, ph.entity_type_value_id,
	       ph.hierarchy_level, ph.parent_entity_id
	FROM portfolio_hierarchy ph
	WHERE ph.entity_id = @entity_id
END
ELSE IF @flag = 'i'
BEGIN
	INSERT INTO portfolio_hierarchy 
		(entity_name,entity_type_value_id,hierarchy_level, parent_entity_id)
	VALUES 
		(@entity_name,@entity_type_value_id,@hierarchy_level, @parent_entity_id)

	IF @@ERROR <> 0
		EXEC spa_ErrorHandler @@ERROR, "Maintain Portfolio Hierarchy", 
				"spa_maintain_portfolio_hierarchy", "DB ERROR", 
				"INSERT OF portfolio hierarchy DATA failed.", ''
	ELSE
		EXEC spa_ErrorHandler 0, 'Maintain Portofolio hierarchy', 
				'spa_maintain_portfolio_hierarchy', 'Success', 
				'Portforlio hierarchy data successfully inserted.', ''
END	
ELSE IF @flag = 'u'
BEGIN
	UPDATE portfolio_hierarchy 
	SET	entity_name=@entity_name,
		entity_type_value_id=@entity_type_value_id,
		hierarchy_level=@hierarchy_level,
		parent_entity_id=@parent_entity_id
	WHERE entity_id=@entity_id

	IF @@ERROR <> 0
		EXEC spa_ErrorHandler @@ERROR, "Maintain Portfolio Hierarchy", 
				"spa_maintain_portfolio_hierarchy", "DB ERROR", 
				"UPDATE OF portfolio hierarchy DATA failed.", ''
	ELSE
		EXEC spa_ErrorHandler 0, 'Maintain Portofolio hierarchy', 
				'spa_maintain_portfolio_hierarchy', 'Success', 
				'Portforlio hierarchy data successfully updated.', ''

END	
ELSE IF @flag = 'd'
BEGIN
	DELETE FROM portfolio_hierarchy 
	WHERE 	entity_id=@entity_id		
		
	IF @@ERROR <> 0
		EXEC spa_ErrorHandler @@ERROR, "Maintain Portfolio Hierarchy", 
				"spa_maintain_portfolio_hierarchy", "DB ERROR", 
				"DELETE OF portfolio hierarchy DATA failed.", ''
	ELSE
		EXEC spa_ErrorHandler 0, 'Maintain Portofolio hierarchy', 
				'spa_maintain_portfolio_hierarchy', 'Success', 
				'Portforlio hierarchy data successfully deleted', ''
END
ELSE IF @flag = 'l' --SELECT  according to level
BEGIN
	SELECT	ph.entity_id, ph.entity_name
	FROM	portfolio_hierarchy ph
	WHERE	ph.hierarchy_level = @level
		AND ph.entity_id <> -1
END





