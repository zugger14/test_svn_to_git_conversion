IF OBJECT_ID(N'[dbo].[spa_alert_report_hyperlink]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_alert_report_hyperlink]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[spa_alert_report_hyperlink] 
	@alert_reports_id  INT,
	@output_table	   NVARCHAR(300),
	@report_params	   NVARCHAR(MAX) OUTPUT	
AS
SET NOCOUNT ON

BEGIN
	DECLARE @param_columns VARCHAR(3000)
	DECLARE @casted_param_columns VARCHAR(3000)
	DECLARE @unpivot_sql NVARCHAR(MAX)
	
	;WITH
	  report_params (parameter_name, parameter_value)
	AS(
		SELECT 
			arp.parameter_name, arp.parameter_value
		FROM 
			alert_report_params arp
		INNER JOIN adiha_process.information_schema.columns cols 
			ON	cols.table_Name = @output_table AND cols.column_name = arp.parameter_value
		WHERE 
			arp.alert_report_id = @alert_reports_id
	)
	SELECT @param_columns = STUFF(
									(
										SELECT 
											',' + parameter_value 
										FROM 
											report_params 
										FOR XML PATH('')
									), 1, 1, ''),
		   @casted_param_columns = STUFF(
											(
												SELECT 
													', CAST(' + parameter_value + ' AS VARCHAR(100)) ' + parameter_value 
												FROM 
													report_params 
												FOR XML PATH('')
										), 1, 1, '')
		   
	IF OBJECT_ID('tempdb..#temp_pivoted_columns') IS NOT NULL DROP TABLE #temp_pivoted_columns	
	SET @unpivot_sql = 'SELECT DISTINCT
							unpvt.attribute, 
							unpvt.value
						INTO 
							#temp_pivoted_columns 
						FROM
							(
								SELECT ' +  
									@casted_param_columns + ' 
								FROM adiha_process.dbo.' + @output_table + ' 
							) process_table 	
						UNPIVOT
						(
						  value
						  for attribute in (' + @param_columns + ')
						) unpvt;
						
						SELECT @report_params = STUFF(
										(
											SELECT 
												'','' + arp.parameter_name + ''='' + 
												COALESCE((SELECT value FROM #temp_pivoted_columns WHERE attribute = arp.parameter_value), ''NULL'') 
											FROM 
												alert_report_params arp											
											WHERE 
												arp.alert_report_id = ' + CAST(@alert_reports_id AS VARCHAR(30)) + '
											FOR XML PATH ('''')
										), 1, 1, ''''
									)'
	--PRINT @unpivot_sql
	EXEC sp_executesql @unpivot_sql, N'@report_params NVARCHAR(2000) OUTPUT', @report_params output
	
	IF NOT EXISTS (SELECT 1 FROM alert_report_params WHERE parameter_value != '') SET @report_params = NULL
END