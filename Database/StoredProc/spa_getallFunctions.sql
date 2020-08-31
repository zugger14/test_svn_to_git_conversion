IF OBJECT_ID(N'spa_getallFunctions', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_getallFunctions]
GO 

CREATE PROCEDURE [dbo].[spa_getallFunctions]
AS
	SELECT function_id,
	       function_name,
	       function_desc,
	       func_ref_id
	FROM   application_functions
	GROUP BY function_id, Function_name, function_desc, func_ref_id
	

IF @@ERROR <> 0
    EXEC spa_ErrorHandler @@ERROR,
         'Functions',
         'spa_getallfunctios',
         'DB Error',
         'Failed to select all functions.',
         ''
ELSE
    EXEC spa_ErrorHandler 0,
         'Functions',
         'spa_getallfunctions',
         'Success',
         'Functions successfully selected.',
         ''