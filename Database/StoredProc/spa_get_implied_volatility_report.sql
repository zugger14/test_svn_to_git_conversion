set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_get_implied_volatility_report]') AND type in (N'P', N'PC'))
DROP PROC [dbo].[spa_get_implied_volatility_report]
go

/**********************************
* Modified By : Mukesh SIngh
* Modified On: 17-March-2009
* Added date formate in as of date,term-start,term-end
***********************************/

/**********************************
Created By : Anal Shrestha
Created On: 01/08/2009

This report is to get the impleid volatility calculations data
exec spa_get_implied_volatility_report 's','2009-01-31',null,'2008-01-01','2009-02-02'
***********************************/


CREATE PROC [dbo].[spa_get_implied_volatility_report]
		@flag CHAR(1)='s',
		@as_of_date DATETIME,
		@curve_id INT=NULL,
		@term_start DATETIME=NULL,
		@term_end DATETIME=NULL

AS
SET NOCOUNT ON 
BEGIN

DECLARE @sql_str VARCHAR(8000)

	SET @sql_str='
		SELECT 
			spcd.curve_name [Index],
			dbo.fnadateformat(cvi.term) [Term],
			SUM(cvi.[value]) [Annual Implied Volatility],
			SUM(cv.value*sqrt(252)) [Annual Historical Volatility]
		FROM
			curve_volatility_imp cvi
			LEFT JOIN curve_volatility cv ON cv.curve_id=cvi.curve_id
				 AND cv.term=cvi.term
			LEFT JOIN source_price_curve_def spcd on spcd.source_curve_def_id=cvi.curve_id
		WHERE 1=1 
			  AND 	cvi.as_of_date='''+CAST(dbo.FNADateformat(@as_of_date) AS VARCHAR)+''''
		+CASE WHEN @curve_id IS NOT NULL THEN ' AND cvi.curve_id='+CAST(@curve_id AS VARCHAR) ELSE '' END
		+CASE WHEN @term_start IS NOT NULL THEN ' AND cvi.term>='''+CAST(dbo.FNADateformat(@term_start) AS VARCHAR)+'''' ELSE '' END
		+CASE WHEN @term_end IS NOT NULL THEN ' AND cvi.term<='''+CAST(dbo.FNADateformat(@term_end) AS VARCHAR)+'''' ELSE '' END
	
		+' GROUP BY '+
			' spcd.curve_name,cvi.term '
	--PRINT @sql_str
	EXEC(@sql_str)
END


