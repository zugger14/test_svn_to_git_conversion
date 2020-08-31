IF EXISTS (
       SELECT *
       FROM   sys.objects
       WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[spa_excel_addin_push]')
              AND TYPE IN (N'P', N'PC')
   )
    DROP PROCEDURE [dbo].[spa_excel_addin_push]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/***********************************************************
* Description: Push data from excel addin 
* Date:   2016-04-14 
* Author: spneupane@pioneersolutionsglobal.com
*
* Changes
* Date		Modified By			Comments
************************************************************
*2016-04-14	spneupane			Initial Version.			
								
************************************************************/

CREATE PROCEDURE [dbo].[spa_excel_addin_push]
	@report_name VARCHAR(255), @process_id VARCHAR(255)
AS
BEGIN
	DECLARE @table_name VARCHAR(1024)
	DECLARE @sql VARCHAR(MAX)
	SET @table_name = 'adiha_process.dbo.ex_add_in_' + LOWER(REPLACE(@report_name,' ','_')) + @process_id
	
	IF @report_name = 'Price Curve Report'
	BEGIN
		--	Update any modificaation in curve value
	    SET @sql =' UPDATE spc
	    SET    spc.curve_value = s.curve_value FROM ' + @table_name + ' 
	           s
	           INNER JOIN source_price_curve_def spcd ON s.curve_code = spcd.curve_id
	           INNER JOIN source_price_curve spc ON spcd.source_curve_def_id = 
	           spc.source_curve_def_id
	    WHERE  s.as_of_date = spc.as_of_date
	           AND s.maturity_date = spc.maturity_date
	           AND s.curve_value <> spc.curve_value'
	    EXEC(@sql) 
	    
	    SET @sql = '           
		INSERT INTO source_price_curve
		(
			source_curve_def_id,
			as_of_date,
			Assessment_curve_type_value_id,
			curve_source_value_id,
			maturity_date,
			curve_value,
			is_dst
		)
               
	     SELECT spcd.source_curve_def_id, s.as_of_date, curve.Assessment_curve_type_value_id, curve.curve_source_value_id, s.maturity_date, s.curve_value, 0 is_dst
	     FROM   ' + @table_name + '  s
	            INNER JOIN source_price_curve_def spcd
	                 ON  s.curve_code = spcd.curve_id
	            LEFT JOIN source_price_curve spc
	                 ON  spcd.source_curve_def_id = spc.source_curve_def_id
	                 AND s.as_of_date = spc.as_of_date
	                 AND s.maturity_date = spc.maturity_date
	            CROSS APPLY (
	                            SELECT MAX(spc1.Assessment_curve_type_value_id) Assessment_curve_type_value_id,
	                                   MAX(spc1.curve_source_value_id) curve_source_value_id
	                            FROM   source_price_curve spc1
	                            WHERE  spc1.source_curve_def_id = spcd.source_curve_def_id
	                        ) curve
	     WHERE  spc.source_curve_def_id IS NULL '
	     EXEC(@sql)
	END
END

