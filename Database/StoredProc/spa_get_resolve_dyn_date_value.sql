IF OBJECT_ID(N'[dbo].[spa_get_resolve_dyn_date_value]', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_get_resolve_dyn_date_value]

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**
	Returns the resolved dynamic date parameters

	Parameters 
	@flag : 's' - Replaces the dynamic date parameters
	@applied_filters : Applied Filter Text
*/
CREATE PROC [dbo].[spa_get_resolve_dyn_date_value]
	@flag CHAR(1),
	@applied_filters NVARCHAR(MAX)
AS 

SET NOCOUNT ON

IF @flag ='s'
BEGIN
	SELECT dbo.FNAReplaceDYNDateParam(@applied_filters) as result
END