IF OBJECT_ID(N'[dbo].[spa_get_Subsidiary_id_Measurement_Report]', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_get_Subsidiary_id_Measurement_Report]
 GO 
 
CREATE PROC [dbo].[spa_get_Subsidiary_id_Measurement_Report]
		@entity_id AS INT
		--@parent_entity_id as int
AS
SET NOCOUNT ON 

BEGIN
	select strat.parent_entity_id from portfolio_hierarchy book 
	inner join portfolio_hierarchy strat on book.parent_entity_id=strat.entity_id 
WHERE
	book.entity_id=@entity_id
END
