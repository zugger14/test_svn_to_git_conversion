IF OBJECT_ID(N'[dbo].[spa_get_subsidiary_from_book]', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_get_subsidiary_from_book]
 GO 

create PROCEDURE [dbo].[spa_get_subsidiary_from_book]
	@fas_book_id int

 AS

Declare @starategy_id int
Begin
	set @starategy_id=(Select parent_entity_id from portfolio_hierarchy where entity_id=@fas_book_id)
	select parent_entity_id as [Subsidiary Id] from portfolio_hierarchy where entity_id=@starategy_id

End





