IF OBJECT_ID(N'[dbo].[spa_get_selected_region]', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_get_selected_region]
GO 


CREATE PROCEDURE [dbo].[spa_get_selected_region]
	@region_id INT

AS

SELECT  region_id, REPLACE(REPLACE (region_name,'(', '--'), ')', '---')  region_name FROM region WHERE region_id = @region_id