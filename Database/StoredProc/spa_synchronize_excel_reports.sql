IF OBJECT_ID('[dbo].[spa_synchronize_excel_reports]') IS NOT NULL
    DROP PROC spa_synchronize_excel_reports
GO
/*
Description : Synchronize excel add in reports / Generate snapshot of sheet to image / pdf

Parameters :
 @excel_sheet_id 	   : Identifier Excel snapshot id 
 @synchronize_report   :Synchronize excel sheets created using report manager y/n
 @image_snapshot       :generate snapshot file y/n
 @export_format			: Possible values => PNG, PDF
 Example : spa_synchronize_excel_reports 1,'n','y'
 Example 2 From Batch 
 DECLARE @data XML =
        '<ExcelSheet>
  <Parameter>
    <ParameterName>as_of_date_from</ParameterName>
    <ScheduleType>5</ScheduleType>
    <Days>20</Days>
  </Parameter>
  <Parameter>
    <ParameterName>as_of_date_to</ParameterName>
    <ScheduleType>2</ScheduleType>
    <Days>-30</Days>
  </Parameter>
</ExcelSheet>'
@view_report_filter_xml = '<Parameters>
	                                                <Parameter>
		                                                <Name>as_of_date_from</Name>
		                                                <Value>2016-10-01</Value>
	                                                </Parameter>
	                                                <Parameter>
		                                                <Name>as_of_date_to</Name>
		                                                <Value>2017-12-30</Value>
	                                                </Parameter>
                                                </Parameters>'
                                                
 spa_synchronize_excel_reports 1,'n','y', @data, @view_report_filter_xml, null 
*/
CREATE PROC [dbo].[spa_synchronize_excel_reports]
@excel_sheet_id NVARCHAR(255),
@synchronize_report CHAR(1),
@image_snapshot CHAR(1),
@batch_xml_report_param XML = NULL,
@view_report_filter_xml XML = NULL,
@process_id VARCHAR(1000) = NULL,
@export_format VARCHAR(25) = 'PNG',
@suppress_result NCHAR(1) = 'n'
AS
SET @process_id = CASE WHEN @process_id IS NULL THEN REPLACE(NEWID(),'-','_') ELSE @process_id END
-- Pass view report filter arguement as table , SSIS Pkg will resolve this values. Instead of passing of command line argument with invalid character eg. & will throw an error 
DECLARE @parameter_table_name VARCHAR(255) = 'adiha_process.dbo.excel_add_in_view_report_filter_' + @process_id

DECLARE @xml_filter NVARCHAR(MAX) = CAST(@view_report_filter_xml AS NVARCHAR(MAX))
	
DECLARE @parameter_import_status NVARCHAR(100) 	
EXEC spa_import_from_xml @xml_content = @xml_filter, @xml_filename = NULL, @table_name = @parameter_table_name, @suppress_result = 'y', @status = @parameter_import_status OUTPUT

DECLARE @db_user NVARCHAR(1024), @result_output NVARCHAR(MAX)
SELECT @db_user = dbo.FNADBUser()
	
EXEC [spa_synchronize_excel_with_spire] @excelSheetId = @excel_sheet_id , @synchronize = @synchronize_report, @imageSnapshot = @image_snapshot, @userName =@db_user, @settlementCalc ='n' , @exportFormat =@export_format , @processId = @process_id
, @outputResult = @result_output output
	
IF ISNULL(@suppress_result, 'n') = 'n'
	SELECT @result_output
