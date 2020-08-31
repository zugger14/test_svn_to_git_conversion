IF OBJECT_ID(N'[dbo].[spa_get_uom_description]', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_get_uom_description]
GO 



create procedure [dbo].[spa_get_uom_description]
	@uom_id varchar(50)
as


select uom_name from source_uom where source_uom_id = @uom_id





