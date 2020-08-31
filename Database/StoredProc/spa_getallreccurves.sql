IF OBJECT_ID(N'[dbo].[spa_getallreccurves]', N'P') IS NOT NULL
   DROP PROCEDURE [dbo].[spa_getallreccurves]
GO

--===========================================================================================
--This Procedure returns all  REC curves
--===========================================================================================

CREATE PROCEDURE [dbo].[spa_getallreccurves]

AS

SET NOCOUNT ON
BEGIN
	--select if the passed id is  strategy id	
	SELECT source_curve_def_id, curve_name 
	FROM  source_price_curve_def 
	WHERE obligation IS NOT NULL 
		AND obligation = 'y'
END
