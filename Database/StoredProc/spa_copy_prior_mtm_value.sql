IF OBJECT_ID(N'spa_copy_prior_mtm_value', N'P') IS NOT NULL
	DROP PROCEDURE spa_copy_prior_mtm_value;
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[spa_copy_prior_mtm_value]
@flag char(1),
@from_date AS VARCHAR(20),
@to_date AS VARCHAR(20)
AS

SET NOCOUNT ON

DECLARE @sql AS varchar(MAX)
DECLARE @proc_from_date AS DATETIME
DECLARE @proc_to_date AS DATETIME

SET @proc_from_date = dbo.FNAGetSQLStandardDate(@from_date)
SET @proc_to_date = dbo.FNAGetSQLStandardDate(@to_date)

if @flag = 's'
BEGIN
	SET @sql = 'SELECT
			dbo.FNAdateformat(pnl_as_of_date)[Prior As Of Date], 
			count(sdp.source_deal_header_id)[Records] 
		FROM 
			source_deal_pnl AS sdp
		INNER JOIN 
			source_deal_header AS sdh ON sdp.source_deal_header_id = sdh.source_deal_header_id
		WHERE 
			sdh.deal_id LIKE ''MA[_]%''' 
			
	IF @from_date IS NOT NULL AND @to_date IS NOT NULL
		SET @sql = @sql + 'AND pnl_as_of_date BETWEEN ''' + CAST(@proc_from_date AS VARCHAR) +  ''' AND ''' + CAST(@proc_to_date AS VARCHAR) + ''''
		
	SET @sql = @sql + 'GROUP BY pnl_as_of_date'	

	EXEC (@sql)
END