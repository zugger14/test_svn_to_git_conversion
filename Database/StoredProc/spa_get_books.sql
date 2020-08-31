
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_get_books]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_get_books]
GO

CREATE PROCEDURE [dbo].[spa_get_books]
	@flag CHAR(1)

AS

IF @flag = 's'
BEGIN
	SELECT entity_id , entity_name FROM dbo.portfolio_hierarchy WHERE entity_type_value_id=527
	
END