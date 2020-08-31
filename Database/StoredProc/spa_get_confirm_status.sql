IF OBJECT_ID('[dbo].[spa_get_confirm_status]','p') IS NOT NULL
DROP PROCEDURE [dbo].[spa_get_confirm_status]
GO 
--exec spa_get_confirm_status
CREATE proc [dbo].[spa_get_confirm_status]
AS
SELECT [value_id], code AS [Code] FROM static_data_value WHERE [type_id] = 17200

