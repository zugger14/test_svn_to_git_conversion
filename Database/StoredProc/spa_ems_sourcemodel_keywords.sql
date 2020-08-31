IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_ems_sourcemodel_keywords]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_ems_sourcemodel_keywords]
GO 
CREATE PROC [dbo].spa_ems_sourcemodel_keywords 
	@keyword_type INT

AS

BEGIN

	DECLARE @sql_stmt VARCHAR(500)
	
	SET @sql_stmt='
				select 	distinct keyword'+cast(@keyword_type as VARCHAR)+
				' from ems_source_model where ISNULL(keyword'+cast(@keyword_type as VARCHAR)+ ','''')<>'''''
	
	EXEC (@sql_stmt)
	


END
