IF OBJECT_ID(N'spa_getdocumentpath', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_getdocumentpath]
GO 

CREATE PROCEDURE [dbo].[spa_getdocumentpath](@func_id INT)
AS
SELECT document_path
FROM   application_functions
WHERE  function_id = @func_id