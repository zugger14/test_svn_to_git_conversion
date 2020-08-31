IF OBJECT_ID(N'spa_getDayCode', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_getDayCode]
GO 

CREATE PROCEDURE [dbo].[spa_getDayCode]
AS
SELECT value_id,
       code
FROM   static_data_value
WHERE   type_id=925