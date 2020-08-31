--lists module_types
--spa_module_types  's'
IF OBJECT_ID(N'spa_module_types', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_module_types]
GO 
CREATE PROCEDURE [dbo].[spa_module_types]
	@flag as Char(1)
						
AS 
Declare @Sql_Select varchar(1000)


if @flag='s' 
begin
	set @Sql_Select='select value_id [module_type],code from static_data_value where type_id=15500'
	exec(@Sql_Select)
end


