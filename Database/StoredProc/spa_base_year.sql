IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_base_year]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_base_year]
GO 
CREATE PROC [dbo].[spa_base_year]
	@sub_id VARCHAR(100)
AS

BEGIN

DECLARE @Sql_Select VARCHAR(1000)

	CREATE TABLE #fas_id(fas_id int)

	SET @Sql_Select=
			'
			insert into #fas_id(fas_id)
			select fas_subsidiary_id from
				fas_subsidiaries WHERE fas_subsidiary_id in('+@sub_id+')'

	EXEC(@Sql_Select)


	SELECT 	min(base_year_from), max(base_year_from)
			FROM fas_subsidiaries WHERE fas_subsidiary_id in(SELECT fas_id FROM #fas_id)



END

