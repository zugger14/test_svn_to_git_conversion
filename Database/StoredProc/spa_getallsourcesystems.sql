IF OBJECT_ID(N'spa_getallsourcesystems', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_getallsourcesystems]
GO 

CREATE PROCEDURE [dbo].[spa_getallsourcesystems]
AS
BEGIN
	SELECT source_system_id,
	       source_system_name
	FROM   source_system_description
	
	IF @@ERROR <> 0
	    EXEC spa_ErrorHandler @@ERROR,
	         'Source Systems',
	         'spa_getallsourcesystems',
	         'DB Error',
	         'Failed to select the source systems.',
	         ''
	ELSE
	    EXEC spa_ErrorHandler 0,
	         'Source Systems',
	         'spa_getallsourcesystems',
	         'Success',
	         'Source systems successfully selected.',
	         ''
			 
END 