IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_get_portfolio_recursive]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_get_portfolio_recursive]
GO 


CREATE proc [dbo].[spa_get_portfolio_recursive]
                     	@entity_id int=NULL
                   
AS 
BEGIN
declare @sql varchar(5000)
Set @sql ='SELECT  parent_entity_id
                            
             FROM
                  portfolio_hierarchy  
			

            WHERE  1=1'
If @entity_id IS NOT NULL
		SET @sql = @sql + ' AND entity_id = ' + CAST(@entity_id AS Varchar)



exec spa_print @sql
exec(@sql)
END



















