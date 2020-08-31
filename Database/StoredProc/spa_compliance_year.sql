IF EXISTS (SELECT 1 FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[spa_compliance_year]') AND [type] IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_compliance_year]


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_compliance_year]  
	@start_year DATETIME = '1995',
	@total_no_of_year INT = 31
AS
BEGIN
	SET NOCOUNT ON

	SELECT DATEPART(YEAR, @start_year) + (n - 1) [year_id], DATEPART(YEAR, @start_year) + (n - 1) [year]
	FROM seq WHERE n <= @total_no_of_year
END