IF OBJECT_ID(N'[dbo].[spa_get_netting_group_name]', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_get_netting_group_name]
GO 

create procedure [dbo].[spa_get_netting_group_name] 
	@netting_group_id varchar(50)
as

SELECT netting_parent_group_name
FROM   netting_group_parent
WHERE  netting_parent_group_id = @netting_group_id





