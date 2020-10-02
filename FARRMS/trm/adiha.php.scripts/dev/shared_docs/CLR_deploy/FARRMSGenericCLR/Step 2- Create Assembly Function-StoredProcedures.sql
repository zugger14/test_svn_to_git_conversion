-- Last Modified :  2019-05-03 02:18:55.580
--SELECT GETDATE()

--Create 

 /*
 * Description : Lists folder/subfolder contents
 * Param Description :
	@folder_path		: Folder path
	@file_extention		: File extenstion , for all types use *.* others eg. *.xml, *.csv
	@all_directories	: recourse directory list ,list subfolder contents y/n
	Eg					: SELECT f.[filename] FROM dbo.FNAListFiles('D:\importexport\', '*.*', 'y') f
 */
IF OBJECT_ID('FNAListFiles') IS NOT NULL
	DROP FUNCTION FNAListFiles
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO   
CREATE FUNCTION [dbo].[FNAListFiles]
(
	@folder_path NVARCHAR(MAX),
	@file_extention NVARCHAR(32),
	@all_directories NVARCHAR(1)
)
RETURNS TABLE([filename] NVARCHAR(MAX))
AS
	EXTERNAL NAME FARRMSGenericCLR.[FARRMSGenericCLR.UserDefinedFunction].ListFiles
GO
/*
 * Description : Checks if write access is available in specific folder
 * Returns : -1 - If folder path doesn't exist, 1 - Success, exception message - Error.
 * Param Description	
	@folder_path				: Folder path   		
	Eg							: SELECT dbo.FNACheckWriteAccessToFolder('\\PSLDEV10\ImportFiles')
 */ 
IF OBJECT_ID('FNACheckWriteAccessToFolder') IS NOT NULL
	DROP FUNCTION FNACheckWriteAccessToFolder
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNACheckWriteAccessToFolder]
(
	@folder_path NVARCHAR(MAX) 
)
RETURNS SMALLINT
AS
	EXTERNAL NAME FARRMSGenericCLR.[FARRMSGenericCLR.UserDefinedFunction].CheckWriteAccessToFolder
GO
/*
 * Description : Reads file contents
 * Returns : 
 * Param Description :
	@file_name		 : File name
	Eg: DECLARE @result NVARCHAR(MAX)				 
		SELECT dbo.FNAReadFileContents('D:\exported.csv')
 */ 
IF OBJECT_ID('FNAReadFileContents') IS NOT NULL
	DROP FUNCTION FNAReadFileContents
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNAReadFileContents]
(
	@file_name NVARCHAR(MAX)
)
RETURNS  NVARCHAR(MAX)
AS
	EXTERNAL NAME FARRMSGenericCLR.[FARRMSGenericCLR.UserDefinedFunction].ReadFileContents
GO


/*
 * Description : Deletes empty folder
 * Returns -1 - Directory Doesnt exists, 1 - Delete Successfull, 0 - Error occured while deleting
 * Param Description :
	@folder_path		: Folder path
	Eg: DECLARE @result NVARCHAR(MAX)
		EXEC dbo.spa_delete_folder'D:\CLR~', @result OUTPUT
		select @result
 */
IF OBJECT_ID('spa_delete_folder') IS NOT NULL
	DROP PROC spa_delete_folder
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO 
CREATE PROC [dbo].[spa_delete_folder]
(
	@folder_path NVARCHAR(MAX), @result NVARCHAR(MAX) OUTPUT 
)
AS
	EXTERNAL NAME FARRMSGenericCLR.[FARRMSGenericCLR.StoredProcedure].DeleteFolder
GO

/*
 * Description : Deletes File
 * Returns -1 - File Doesnt exists, 1 - Delete Successfull, 0 - Error occured while deleting
 * Param Description :
	@filename			: File Path
	Eg					: SELECT dbo.spa_delete_file('D:\importdata.csv')
 */ 
IF OBJECT_ID('spa_delete_file') IS NOT NULL
	DROP PROC spa_delete_file
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO 
CREATE PROC [dbo].[spa_delete_file]
(
	@filename NVARCHAR(MAX), @result NVARCHAR(MAX) OUTPUT
)
AS
	EXTERNAL NAME FARRMSGenericCLR.[FARRMSGenericCLR.StoredProcedure].DeleteFile
GO

/*
 * Description : Move folder and it contents with same folder name to destination 
 * Returns -1 - Source Folder Doesnt exists, 1 - Move Successfull, 0 - Error occured while deleting
 * Param Description :
	@source_folder			: Source folder location
	@destination_path		: Destination folder path where source folder will be moved.
	Eg						: EXEC dbo.spa_move_folder 'D:\remitxml','d:\surya'
 */
IF OBJECT_ID('spa_move_folder') IS NOT NULL
	DROP PROC spa_move_folder
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO  
CREATE PROC [dbo].[spa_move_folder]
(
	@source_folder NVARCHAR(MAX), @destination_path NVARCHAR(MAX), @result NVARCHAR(MAX) OUTPUT
)
AS
	EXTERNAL NAME FARRMSGenericCLR.[FARRMSGenericCLR.StoredProcedure].MoveFolder
GO

IF OBJECT_ID('FNAFileExists') IS NOT NULL
	DROP FUNCTION FNAFileExists
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO  
/*
 * Description : Checks file existance 
 * Returns 1 - if file exists , Otherwise 0
 * Param Description :
	@filename			: Filename 
	Eg					: SELECT dbo.FNAFileExists('D:\meterdata.csv')
 */ 
CREATE FUNCTION [dbo].[FNAFileExists]
(
	@filename NVARCHAR(MAX) 
)
RETURNS SMALLINT
AS
	EXTERNAL NAME FARRMSGenericCLR.[FARRMSGenericCLR.UserDefinedFunction].FileExists
GO

IF OBJECT_ID('spa_create_file') IS NOT NULL
	DROP PROC spa_create_file
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO  
/*
 * Description : Create New File , deletes if file exists and creates new one
 * Returns 1 - Successfull, 0- Error
 * Param Description :
	@filename			: Filename 
	Eg					: EXEC spa_create_file('D:\sample.txt', @outputvar
 */ 
CREATE PROC [dbo].[spa_create_file]
(
	@filename NVARCHAR(MAX), @result NVARCHAR(MAX) OUTPUT
)
AS
	EXTERNAL NAME FARRMSGenericCLR.[FARRMSGenericCLR.StoredProcedure].CreateFile
GO

IF OBJECT_ID('spa_write_to_file') IS NOT NULL
	DROP PROC spa_write_to_file
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO  
/*
 * Description : Write string content to file with append option
 * Returns 1 - Successfull else exception error message
 * Param Description :
	@content			: String Content
	@filename			: Filename
	@appendContent		: append content to existing file , y, n
	@result				: Output var
	 
	Eg					: EXEC spa_write_to_file 'the quick brown fox jumps over the lazy dog','y', 'D:\sample.txt', @outputvar
 */ 
CREATE PROC [dbo].[spa_write_to_file]
(
	@content NVARCHAR(MAX),@appendContent NVARCHAR(1), @filename NVARCHAR(MAX), @result NVARCHAR(MAX) OUTPUT
)
AS
	EXTERNAL NAME FARRMSGenericCLR.[FARRMSGenericCLR.StoredProcedure].WriteToFile
GO

IF OBJECT_ID('spa_move_file') IS NOT NULL
	DROP PROC spa_move_file
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO  
/*
 * Description : Moves source file specified destination  
 * Returns -1 - Source file doesnt exists, 1- Successfull, 0 - Error
 * Param Description	
	@source_file		: Source filename  
	@destination_file	: Destination filename		
	Eg					: EXEC spa_move_file 'D:\meterdata.csv','D:\processed\meterdata_processed.csv', @outputvar
 */ 
 
CREATE PROC [dbo].[spa_move_file]
(
	@source_file NVARCHAR(MAX), @destination_file NVARCHAR(MAX), @result NVARCHAR(MAX) OUTPUT
)
AS
	EXTERNAL NAME FARRMSGenericCLR.[FARRMSGenericCLR.StoredProcedure].MoveFile
GO

IF OBJECT_ID('spa_move_file_to_folder') IS NOT NULL
	DROP PROC spa_move_file_to_folder
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO 
/*
 * Description : Moves source file specified destination folder  with same filename.
 * Returns -1 - Source file doesnt exists, -2 - Destination Folder Doesnt exists, 1 - Successfull, 0 - Error
 * Param Description	
	@source_file				: Source filename  
	@destination_folder_path	: Destination folder path where source file is to be copied		
	Eg							: EXEC spa_move_file_to_folder 'D:\meterdata.csv','D:\processed\', @outputvar
 */ 

CREATE PROC [dbo].[spa_move_file_to_folder]
(
	@source_file NVARCHAR(MAX), @destination_folder_path NVARCHAR(MAX), @result NVARCHAR(MAX) OUTPUT 
)
AS
	EXTERNAL NAME FARRMSGenericCLR.[FARRMSGenericCLR.StoredProcedure].MoveFileToFolder
GO

IF OBJECT_ID('spa_create_folder') IS NOT NULL
	DROP PROC spa_create_folder
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO 
/*
 * Description : Creates New Folder 
 * Returns 1 - Successfull, 0 - Error
 * Param Description	
	@folder_path				: Folder path   		
	Eg							: EXEC spa_create_folder 'D:\Data\Error', @outputvar
 */ 
 --DROP PROC spa_create_folder
CREATE PROC [dbo].[spa_create_folder]
(
	@folder_path NVARCHAR(MAX), @result NVARCHAR(MAX) OUTPUT 
)
AS
	EXTERNAL NAME FARRMSGenericCLR.[FARRMSGenericCLR.StoredProcedure].CreateFolder
GO

IF OBJECT_ID('spa_compress_folder') IS NOT NULL
	DROP PROC spa_compress_folder
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO 
/*
 * Description : Compress Folder
 * Returns : 'success' on compression completed otherewise error message is displayed instead of success string
 * Param Description	
	@folder_path				: Folder path
	@zip_file_name NVARCHAR(MAX): Output Zip file name eg : D:compressed.zip   		
	Eg							: EXEC spa_compress_folder 'D:\ImportExport\Processed', 'D:\processedfiles.zip', @outputvar
 */ 

CREATE PROC [dbo].[spa_compress_folder]
(
	@folder_path NVARCHAR(MAX), @zip_file_name NVARCHAR(MAX), @result NVARCHAR(MAX) OUTPUT
)
AS
	EXTERNAL NAME FARRMSGenericCLR.[FARRMSGenericCLR.StoredProcedure].CompressFolder
GO

IF OBJECT_ID('spa_compress_file_v2') IS NOT NULL
	DROP PROC spa_compress_file_v2
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO 
/*
 * Description : Compress File
 * Returns : 'success' on compression completed otherewise error message is displayed instead of success string
 * Param Description	
	@folder_path				: Folder path
	@zip_file_name NVARCHAR(MAX): Output Zip file name eg : D:compressed.zip   		
	Eg							: EXEC  dbo.spa_compress_file 'D:\exported.csv', 'D:\exported.zip',@output_result
 */ 

CREATE PROC [dbo].[spa_compress_file_v2]
(
	@file_name NVARCHAR(MAX), @zip_file_name NVARCHAR(MAX), @result NVARCHAR(MAX) OUTPUT 
)
AS
	EXTERNAL NAME FARRMSGenericCLR.[FARRMSGenericCLR.StoredProcedure].CompressFile
GO

IF OBJECT_ID('spa_deploy_rdl') IS NOT NULL
	DROP PROC spa_deploy_rdl
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO 
/*
 * Description : Deploy RDL to report server using sql server reporting web services, access from [spa_deploy_rdl_using_clr]
 *				SSRS configuration are stored in connection string table.
 * Returns : 'success' if deployed successfull otherwise custom error is raised.
 * Param Description	
	@user_name				: Report server user name
	@password				: Report server password ascociated with username
	@host_name				: Domain Hostname
	@server_url				: Report server url
	@report_temp_folder		: Report document path folder
	@report_folder			: SSRS Application folder
	@data_source			: SSRS Report Data Source
	@report_name			: Report Name
	@report_description		: Report Description
	 		
	Eg						: EXEC spa_deploy_rdl 'spneupnae', 'p@ssw0rd', 'DPCS', 'http://localhost/ReportServer_INSTANCE2012', 'D:\Farrms_Application\TRMTracker_New_Framework_Branch\FARRMS\trm\adiha.php.scripts\dev\shared_docs\temp_Note', 'TRMTracker_New_Framework_Branch', 'custom_reports','Deal detail report', 'Deal detal report description', @outputvar
 */ 
CREATE PROC [dbo].[spa_deploy_rdl]
(
	@user_name				NVARCHAR(2048),
	@password				NVARCHAR(2048),
	@host_name				NVARCHAR(2048),
	@server_url				NVARCHAR(2048),
	@report_temp_folder		NVARCHAR(2048),
	@report_target_folder	NVARCHAR(2048),
	@data_source			NVARCHAR(2048),
	@report_name			NVARCHAR(2048),
	@report_description		NVARCHAR(2048),
	@debug_mode				NCHAR(1),
	@result					NVARCHAR(MAX) OUTPUT
)
AS
	EXTERNAL NAME FARRMSGenericCLR.[FARRMSGenericCLR.StoredProcedure].DeployRDL
GO

IF OBJECT_ID('spa_export_to_csv') IS NOT NULL
	DROP PROC spa_export_to_csv
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO 
/*
 * Description : Export table records in to csv file format.
 * Param Description	
		@table_name				: Table name / Process Table name
		@export_file_name		: Export CSV file name 
		@include_column_headers	: Include column headers while exporting csv 
		@delimiter				: Field delimiter 
		@compress_file			: Compress Exported csv file
		@use_date_conversion	: use generic date conversion for date fields
		@strip_html				: Strip html contents to plain text
		@enclosed_with_quotes	: Enclosed / exclude data with double quotes
	 		
	Eg						: EXEC spa_export_to_csv  @table_name = 'source_counterparty', @export_file_name ='D:\exported.csv', @include_column_headers = 'y', @delimiter = ',', @compress_file = 'y', @use_date_conversion = 'y', @strip_html = 'y', @enclosed_with_quotes='n'
 */ 
CREATE PROCEDURE [dbo].[spa_export_to_csv]
	@table_name					NVARCHAR(MAX),
	@export_file_name			NVARCHAR(2048),
	@include_column_headers		NVARCHAR(1),
	@delimiter					NVARCHAR(10),
	@compress_file				NVARCHAR(1),
	@use_date_conversion		NVARCHAR(1),
	@strip_html					NVARCHAR(1),
	@enclosed_with_quotes		NVARCHAR(1),
	@result						NVARCHAR(1024) OUTPUT
AS
	EXTERNAL NAME FARRMSGenericCLR.[FARRMSGenericCLR.StoredProcedure].ExportToCsv
GO

 
/*
* THIS FEATURE USE .NET SQL BULK COPY FEATURE BUT THIS DOESNT WORK ON CONTEXT CONNECTION 
CREATE PROCEDURE spa_import_csv_to_table
	@user_name NVARCHAR(255),
	@csv_file_path NVARCHAR(2048),
	@delimeter NVARCHAR(10),
	@has_fields_enclosed_in_quotes NVARCHAR(1),
	@has_column_headers NVARCHAR(1)
AS
	EXTERNAL NAME FARRMSGenericCLR.[FARRMSGenericCLR.StoredProcedure].ImportCsvToTable
GO
*/

IF OBJECT_ID('spa_import_from_csv') IS NOT NULL
	DROP PROC spa_import_from_csv
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 /*
	spa_import_from_csv	Import csv file contents into table, uses MSSQL BULK Insert (spa_bulk_insert).
	@csv_file_path	CSV file path
	@process_table_name	Table name to import records from csv  file this table will be dynamically created according to csv file configuration.
	@delimeter	Delimiter used.
	@row_terminator	Row terminator for new line eg:  
	@has_column_headers	If CSV file contains header information or not
	@has_fields_enclosed_in_quotes	Are Field data enclosed with double quotes.
	@include_filename	Include filename column to imported table.
	@result	Output
	@format_column_header_for_xml	Format column header for xml. Default is 'n'
*/
CREATE PROCEDURE [dbo].[spa_import_from_csv]
	@csv_file_path					NVARCHAR(2048),
	@process_table_name				NVARCHAR(2048),
	@delimeter						NVARCHAR(10),
	@row_terminator					NVARCHAR(10),
	@has_column_headers				NVARCHAR(1),
	@has_fields_enclosed_in_quotes  NVARCHAR(1),
	@include_filename				NVARCHAR(1),
	@result NVARCHAR(MAX) OUTPUT,
	@format_column_header_for_xml NCHAR(1) = 'n'
AS
	EXTERNAL NAME FARRMSGenericCLR.[FARRMSGenericCLR.StoredProcedure].ImportFromCSV
GO

IF OBJECT_ID('spa_generate_xml') IS NOT NULL
	DROP PROC spa_generate_xml
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
 * Description : Generate XML for any datatable
 * Returns : 'success' if xml generation successfull otherwise custom error is raised.
 * Param Description	
		@datatable_name		: Table Name
		@xml_path			: Xml File name to generate
		
		EG.			EXEC spa_generate_xml 'contract_group', 'D:\cg1.xml'
 */ 
 
CREATE PROCEDURE [dbo].[spa_generate_xml]
(
	@datatable_name NVARCHAR(1024),
	@sql_query NVARCHAR(MAX),
	@xml_path NVARCHAR(1024),
	@result NVARCHAR(MAX) OUTPUT 
)
AS
	EXTERNAL NAME FARRMSGenericCLR.[FARRMSGenericCLR.StoredProcedure].GenerateXML
GO

IF OBJECT_ID('IsValidDatePattern') IS NOT NULL
	DROP FUNCTION IsValidDatePattern
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[IsValidDatePattern]
(
	@text NVARCHAR(MAX)
)
RETURNS BIT
AS
	EXTERNAL NAME FARRMSGenericCLR.[FARRMSGenericCLR.UserDefinedFunction].IsValidDatePattern
GO

IF OBJECT_ID('IsValidDeliveryPoint') IS NOT NULL
	DROP FUNCTION IsValidDeliveryPoint
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[IsValidDeliveryPoint]
(
	@text NVARCHAR(MAX)
)
RETURNS BIT
AS
	EXTERNAL NAME FARRMSGenericCLR.[FARRMSGenericCLR.UserDefinedFunction].IsValidDeliveryPoint
GO

IF OBJECT_ID('BASE64SHA256') IS NOT NULL
	DROP FUNCTION BASE64SHA256
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[BASE64SHA256]
(
	@text NVARCHAR(MAX)
)
RETURNS NVARCHAR(MAX)
AS
	EXTERNAL NAME FARRMSGenericCLR.[FARRMSGenericCLR.UserDefinedFunction].BASE64SHA256
GO

IF OBJECT_ID('SpecialNumberFormat') IS NOT NULL
	DROP FUNCTION SpecialNumberFormat
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[SpecialNumberFormat]
(
	@text NVARCHAR(MAX)
)
RETURNS NVARCHAR(MAX)
AS
	EXTERNAL NAME FARRMSGenericCLR.[FARRMSGenericCLR.UserDefinedFunction].SpecialNumberFormat
GO

--	Calculate Eigen Decomposition / Singular decomposition matrix values
-- Added @decomposition_type type to calculate different decomposition values
-- Possible values @decomposition_type = e for Eigen Decomposition , s = singular , else runs eigen first if it fails runs singular
IF OBJECT_ID('spa_calculate_eigen_values') IS NOT NULL
	DROP PROC spa_calculate_eigen_values
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spa_calculate_eigen_values]
	@as_of_date NVARCHAR(10),
	@term_start NVARCHAR(10),
	@term_end NVARCHAR(10),
	@purge NVARCHAR(1),
	@dvalue_end_range FLOAT = -2, -- Default end range for dvalue
	@user_name NVARCHAR(100),
	@process_id NVARCHAR(100),
	@criteria_id INT,
	@decomposition_type NCHAR(1) = 'b'
AS
	EXTERNAL NAME FARRMSGenericCLR.[FARRMSGenericCLR.StoredProcedure].CalculateEigenValues
GO

IF OBJECT_ID('spa_generate_doc_from_rdl') IS NOT NULL
	DROP PROC spa_generate_doc_from_rdl
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[spa_generate_doc_from_rdl]
(
	@Server_url NVARCHAR(1000), 
	@userName NVARCHAR(100), 
	@password NVARCHAR(1000), 
	@domain NVARCHAR(200), 
	@report_name NVARCHAR(1000), 
	@parameters NVARCHAR(MAX),
	@OutputFileFormat NVARCHAR(25),
	@output_filename NVARCHAR(1000),
	@process_id NVARCHAR(512) = NULL,
	@result_output NVARCHAR(MAX) OUTPUT
)
AS
		EXTERNAL NAME FARRMSGenericCLR.[FARRMSGenericCLR.StoredProcedure].GenerateDocFromRDL
GO

IF OBJECT_ID('spa_generate_document_from_xml') IS NOT NULL
	DROP PROC spa_generate_document_from_xml
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[spa_generate_document_from_xml]
(
    @doc_location NVARCHAR(500),
    @temp_location NVARCHAR(500),
    @xml_location NVARCHAR(500),
    @result_output NVARCHAR(MAX) OUTPUT
)
AS
		EXTERNAL NAME FARRMSGenericCLR.[FARRMSGenericCLR.StoredProcedure].generatedocument
GO

IF OBJECT_ID('spa_copy_file') IS NOT NULL
	DROP PROC spa_copy_file
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[spa_copy_file]
(
    @source_file NVARCHAR(1024),
    @destination_file NVARCHAR(1024),
    @result NVARCHAR(1024) OUTPUT
)
AS
	EXTERNAL NAME FARRMSGenericCLR.[FARRMSGenericCLR.StoredProcedure].CopyFile
GO

IF OBJECT_ID('spa_generate_doc_using_xml') IS NOT NULL
	DROP PROC spa_generate_doc_using_xml
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[spa_generate_doc_using_xml]
(
	 @xml_file NVARCHAR(2048)
	,@xsdfile NVARCHAR(2048)
	,@template_name NVARCHAR(500)
	,@file_name NVARCHAR(500)
	,@template_id INT
)
AS
	EXTERNAL NAME FARRMSGenericCLR.[FARRMSGenericCLR.StoredProcedure].GenerateDocUsingXML
GO

IF OBJECT_ID('spa_insert_a_picture') IS NOT NULL
	DROP PROC spa_insert_a_picture
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[spa_insert_a_picture]
(
	 @document_name NVARCHAR(1028)
	,@image_name NVARCHAR(1028)
)
AS
	EXTERNAL NAME FARRMSGenericCLR.[FARRMSGenericCLR.UserDefinedFunction].InsertAPicture
GO

IF OBJECT_ID('spa_execute_ssis_package') IS NOT NULL
	DROP PROC spa_execute_ssis_package
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[spa_execute_ssis_package]
(
    @dtsx_file_name NVARCHAR(1024),
    @package_vairables_values NVARCHAR(MAX),
    @ssis_system_variables NVARCHAR(MAX),
    @sql_version NVARCHAR(25),
    @bit_version INT,
    @debug_mode NCHAR(1),
    @output_result NVARCHAR(1024) OUTPUT
)
AS
	EXTERNAL NAME FARRMSGenericCLR.[FARRMSGenericCLR.StoredProcedure].ExecuteSSISPackage
GO

-- Break down formula
IF OBJECT_ID('FNAParseFormula') IS NOT NULL
	DROP FUNCTION FNAParseFormula
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNAParseFormula]
(@formula NVARCHAR(MAX))
RETURNS NVARCHAR(MAX)
AS
 EXTERNAL NAME FARRMSGenericCLR.[FARRMSGenericCLR.UserDefinedFunction].[FNAParseFormula]
GO

/* Example execution
SELECT dbo.FNAParseFormula('LagCurve(94,  0,  6, 0,  3, NULL,0,0.0247,NULL,NULL)+LagCurve(92,0,6,0,3,null,0,0.0263,NULL,NULL)+LagCurve(97,0,0,0,1,null,0,0.25,null,null)+2.54')
*/


IF OBJECT_ID('spa_push_notification') IS NOT NULL
    DROP PROC spa_push_notification
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[spa_push_notification]
(
    @push_php_url NVARCHAR(1024),
    @push_xml NVARCHAR(MAX),
    @debug_mode NCHAR(1),
    @output_result NVARCHAR(1024) OUTPUT,
    @http_web_response NVARCHAR(1024) = NULL OUTPUT,
	@authorization_type NVARCHAR(50) = 'noAuth',
	@access_token NVARCHAR(1000) = ''
)
AS
EXTERNAL NAME FARRMSGenericCLR.[FARRMSGenericCLR.StoredProcedure].PushNotification
GO

-- Description : Retrives sheet names exist in excel file
IF OBJECT_ID('spa_excel_sheets') IS NOT NULL
    DROP PROC spa_excel_sheets
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[spa_excel_sheets]
(
    @filename NVARCHAR(1024)
)
AS
EXTERNAL NAME FARRMSGenericCLR.[FARRMSGenericCLR.StoredProcedure].ExcelSheets
GO
/**
    Read Excel Spreadsheet and dumps into process table
 
    Parameters:
    @filename : Excel filename to import.                    
    @sheetname : sheet name
    @process_table_name : Process table to dump data 
	@output_result : output prameter returns success or failure message
    @format_column_header_for_xml : possible values y/n , default n.
	@has_column_headers : possible values y/n, By default y. y=> Assumes first row as table header, n=> performs excel row scan to identify number of columns to create process table
    
 */
IF OBJECT_ID('spa_import_from_excel') IS NOT NULL
    DROP PROC spa_import_from_excel
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[spa_import_from_excel]
(
    @filename NVARCHAR(1024),
	@sheetname NVARCHAR(255),
	@process_table_name NVARCHAR(255),
	@output_result NVARCHAR(max) OUTPUT,
	@format_column_header_for_xml NCHAR(1) = 'n',
	@has_column_headers NCHAR(1) = 'y'
)
AS
EXTERNAL NAME FARRMSGenericCLR.[FARRMSGenericCLR.StoredProcedure].ImportFromExcel
GO

-- Description : Read lse file and dump in Process table
IF OBJECT_ID('spa_import_from_lse') IS NOT NULL
    DROP PROC spa_import_from_lse
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[spa_import_from_lse]
(
	@filePath NVARCHAR(255),
	@table_name NVARCHAR(255),
	@output_result NVARCHAR(255) OUTPUT
)
AS
EXTERNAL NAME FARRMSGenericCLR.[FARRMSGenericCLR.StoredProcedure].ImportFromLSE
GO


-- Description : Excel addin sheets configuration list
IF OBJECT_ID('spa_excel_addin_worksheets') IS NOT NULL
    DROP PROC spa_excel_addin_worksheets
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[spa_excel_addin_worksheets]
(
    @filename NVARCHAR(1024),
    @output_result NVARCHAR(MAX) OUTPUT
)
AS
EXTERNAL NAME FARRMSGenericCLR.[FARRMSGenericCLR.StoredProcedure].ExcelAddinSheets
GO

IF OBJECT_ID('spa_excel_addin_parameters') IS NOT NULL
    DROP PROC spa_excel_addin_parameters
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[spa_excel_addin_parameters]
(
    @filename NVARCHAR(1024),
    @list_all NCHAR(1),
    @output_result NVARCHAR(MAX) OUTPUT
)
AS
EXTERNAL NAME FARRMSGenericCLR.[FARRMSGenericCLR.StoredProcedure].ExcelAddInParameters
GO

-- XML Export of table
IF OBJECT_ID('spa_create_xml_document') IS NOT NULL
    DROP PROC spa_create_xml_document
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[spa_create_xml_document]
(
    @table_name NVARCHAR(1024),
    @xml_namespace NVARCHAR(1024),
    @report_name NVARCHAR(255),
    @xml_format NVARCHAR(8),
    @xml_filename NVARCHAR(1024),
	@compress_file NVARCHAR(1),
    @output_result NVARCHAR(MAX) OUTPUT
)
AS
EXTERNAL NAME FARRMSGenericCLR.[FARRMSGenericCLR.StoredProcedure].CreateXMLDocument
GO

IF OBJECT_ID('spa_transform_xml') IS NOT NULL
    DROP PROC spa_transform_xml
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO 
/*
 * Description : Transform XML according to the given XSLT file
 * Param Description
	@eff_file_path			: Input XML file path
	@xslt_path				: Path of XSLT file
	@file_path				: Output Filepath
	@remove_blank_options	: Remove blank option from transformed xml
	@outmsg					: Out Message
		
 */ 
CREATE PROCEDURE [dbo].spa_transform_xml
	@eff_file_path			NVARCHAR(MAX),
	@xslt_path				NVARCHAR(MAX),
	@file_path				NVARCHAR(MAX),
	@compress_file			NVARCHAR(1),
	@remove_blank_options	NVARCHAR(1),
	@outmsg					NVARCHAR(MAX) OUTPUT
AS
	EXTERNAL NAME FARRMSGenericCLR.[FARRMSGenericCLR.StoredProcedure].TransformXML
GO

-- Send remote command to ps socket server
IF OBJECT_ID('spa_send_remote_command') IS NOT NULL
    DROP PROC spa_send_remote_command
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[spa_send_remote_command]
(
    @ip_address NVARCHAR(1024),
    @port_no INT,
    @remote_cmd_parameter NVARCHAR(max),
    @output_result NVARCHAR(MAX) OUTPUT
)
AS
EXTERNAL NAME FARRMSGenericCLR.[FARRMSGenericCLR.StoredProcedure].SendRemoteCommand
GO
--Get outlook incoming mail (manage email)
IF OBJECT_ID('spa_dump_incoming_email_clr') IS NOT NULL
    DROP PROC spa_dump_incoming_email_clr
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[spa_dump_incoming_email_clr]
(
    @email_id NVARCHAR(1024),
    @email_pwd NVARCHAR(1024),
    @email_host NVARCHAR(255),
    @email_port int,
	@email_require_ssl int,
    @document_path NVARCHAR(1024),
	@message_id NVARCHAR(1024) = NULL,
	@flag NVARCHAR(1),
	@process_id NVARCHAR(100) = NULL,
    @output_result NVARCHAR(MAX) OUTPUT
)
AS
EXTERNAL NAME FARRMSGenericCLR.[FARRMSGenericCLR.StoredProcedure].DumpIncomingEmail
GO


--Build JSON from table / SQL command
IF OBJECT_ID('spa_build_json') IS NOT NULL
    DROP PROC spa_build_json
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[spa_build_json]
(
	@sql_command NVARCHAR(MAX),
	@json_field_list NVARCHAR(2500) = NULL,
	@json_content NVARCHAR(MAX) OUTPUT
)
AS
	EXTERNAL NAME FARRMSGenericCLR.[FARRMSGenericCLR.StoredProcedure].BuildJson
GO

--Dump JSON content to table
-- Return success if dumped otherwise exception message is displayed
IF OBJECT_ID('spa_import_from_json') IS NOT NULL
    DROP PROC spa_import_from_json
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[spa_import_from_json]
(
	@json_content NVARCHAR(MAX),
	@process_table_name NVARCHAR(2500) = NULL,
	@status NVARCHAR(MAX) OUTPUT
)
AS
	EXTERNAL NAME FARRMSGenericCLR.[FARRMSGenericCLR.StoredProcedure].ImportFromJSON
GO

-- Get table Raw xml , used to generate spa rfx dumped xml for excel add-in
--Build JSON from table / SQL command
IF OBJECT_ID('spa_raw_xml') IS NOT NULL
    DROP PROC spa_raw_xml
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[spa_raw_xml]
(
	@process_table_name NVARCHAR(MAX),
	@xml_content NVARCHAR(MAX) OUTPUT
)
AS
	EXTERNAL NAME FARRMSGenericCLR.[FARRMSGenericCLR.StoredProcedure].RawXml
GO
-- Export RDL TO Html
IF OBJECT_ID('spa_export_rdl_to_html') IS NOT NULL
    DROP PROC [spa_export_rdl_to_html]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spa_export_rdl_to_html]
(
	@Server_url NVARCHAR(1000), 
	@userName NVARCHAR(100), 
	@password NVARCHAR(1000), 
	@domain NVARCHAR(200), 
	@report_name NVARCHAR(1000), 
	@parameters NVARCHAR(MAX),
	@device_info NVARCHAR(MAX),
	@sorting  NVARCHAR(MAX), 
	@toggle_item  NVARCHAR(MAX), 
	@document_path  NVARCHAR(MAX),
	@execution_id  NVARCHAR(100),
	@export_type  NVARCHAR(20)
)
AS
	EXTERNAL NAME FARRMSGenericCLR.[FARRMSGenericCLR.StoredProcedure].ExportRdlToHtml
GO
/*
Update Date format in Import sample files and zip multiple files for downloading
Param Desc:
@source_file_name: Takes Single file name or multiple comma separated file name
*/
IF OBJECT_ID('spa_process_import_sample_file') IS NOT NULL
    DROP PROC spa_process_import_sample_file
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[spa_process_import_sample_file]
(
    @source_file_name NVARCHAR(MAX)
)
AS
EXTERNAL NAME FARRMSGenericCLR.[FARRMSGenericCLR.StoredProcedure].processImportSampleFile
GO


/*
	Description			: Import XML Contents to table
	Param Description
	@xml_content	    : Valid XML content
	@xml_filename		: XML full filename
	@table_name			: Process table name
	@suppress_result	: Suppress stored procedure result, added to support nested insert
	@status				: Success / Failed output status
		
 */ 
IF OBJECT_ID('spa_import_from_xml') IS NOT NULL
    DROP PROC spa_import_from_xml
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO 
CREATE PROCEDURE [dbo].spa_import_from_xml
	@xml_content NVARCHAR(MAX),
	@xml_filename NVARCHAR(1024) = NULL,
	@table_name NVARCHAR(1024) = NULL,
	@suppress_result NCHAR(1) = NULL,
	@status NVARCHAR(MAX) OUTPUT
AS
	EXTERNAL NAME FARRMSGenericCLR.[FARRMSGenericCLR.StoredProcedure].ImportFromXml
GO

IF OBJECT_ID('[dbo].[FNABuildRfxQueryFromReportParameter]') IS NOT NULL
    DROP FUNCTION [dbo].[FNABuildRfxQueryFromReportParameter]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO 

CREATE FUNCTION [dbo].[FNABuildRfxQueryFromReportParameter]
(
	@report_rfx_parameter	    NVARCHAR(MAX),
	@process_id					NVARCHAR(1024),
	@output_to_proc_table		NVARCHAR(1)
)
RETURNS NVARCHAR(MAX)
AS
	EXTERNAL NAME FARRMSGenericCLR.[FARRMSGenericCLR.UserDefinedFunction].BuildRfxQueryFromReportParameter
GO

IF OBJECT_ID('spa_generate_registr_log') IS NOT NULL
    DROP PROC spa_generate_registr_log
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO 
/*
 * Description : Read and save response xml 
 * Param Description
		@process_table			: Table to stored the content of read xml file
		@xml_file_list			: XML request needed to get file names
		@recover_xml			: XML request needed to read file content
		@request_url			: URL for SOAP request
		@host_url			    : URL for SOAP
		@soap_action			: URL for SOAP action
		@outmsg					: Success/Failed status
		@response_file_xml		: XML response from client
		@response_recover_xml	: XML response from client
 */ 
CREATE PROCEDURE [dbo].[spa_generate_registr_log]
	@process_table	    NVARCHAR(MAX),
	@xml_file_list		NVARCHAR(MAX), 
	@recover_xml		NVARCHAR(MAX), 
	@request_url		NVARCHAR(1000), 
	@host_url			NVARCHAR(1000), 
	@soap_action		NVARCHAR(1000),
	@outmsg				NVARCHAR(MAX) OUTPUT,
	@response_file_xml	NVARCHAR(MAX) OUTPUT,
	@response_recover_xml	NVARCHAR(MAX) OUTPUT

AS
	EXTERNAL NAME FARRMSGenericCLR.[FARRMSGenericCLR.StoredProcedure].RegisTRMessageLog
GO


-- Download RDL file from report server , report server configuration are defined in connection string.
IF OBJECT_ID('spa_download_rdl') IS NOT NULL
    DROP PROC [spa_download_rdl]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spa_download_rdl]
(
	@report_name NVARCHAR(2000)
)
AS
	EXTERNAL NAME FARRMSGenericCLR.[FARRMSGenericCLR.StoredProcedure].DownloadRdl
GO

-- Check if rdl exists or not in report server report target folder.
IF OBJECT_ID('FNARdlExists') IS NOT NULL
	DROP FUNCTION FNARdlExists
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO   
CREATE FUNCTION [dbo].[FNARdlExists]
(
	@report_name NVARCHAR(2000)
)
RETURNS BIT
AS
	--UserDefinedFunction.RdlExists("Assessment Results Plot Trends_Assessment Results Plot Trends");
	EXTERNAL NAME FARRMSGenericCLR.[FARRMSGenericCLR.UserDefinedFunction].RdlExists
GO
/*
	Description : Get SQl output schema information or dump data in process table
	Parameters
		@sql_query : Storedprocedure query or SQL Adhoc query
		@process_table_name : process table name
		@data_output_col_count : Return number of columns output by query
		@flag : string possible value data=> dumps data to process table, schema => dumps schema information to process table
*/
IF OBJECT_ID('spa_get_output_schema_or_data') IS NOT NULL
    DROP PROC [spa_get_output_schema_or_data]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[spa_get_output_schema_or_data]
(
	@sql_query NVARCHAR(MAX)
	,@process_table_name NVARCHAR(1024)
	,@data_output_col_count INT OUTPUT
	,@flag NVARCHAR(10)
)
AS
	EXTERNAL NAME FARRMSGenericCLR.[FARRMSGenericCLR.StoredProcedure].GetSchemaOrData
GO

IF OBJECT_ID('spa_generate_nordpool_log') IS NOT NULL
    DROP PROC spa_generate_nordpool_log
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO 
/*
 * Description : Read and save response xml 
 * Param Description
		@report_ids				: Report Ids
		@process_table			: Table to stored the content of read xml file
		@outmsg					: Success/Failed status
 */ 
CREATE PROCEDURE [dbo].[spa_generate_nordpool_log]
	@report_ids			NVARCHAR(MAX),
	@process_table	    NVARCHAR(MAX),
	@outmsg				NVARCHAR(MAX) OUTPUT
AS
	EXTERNAL NAME FARRMSGenericCLR.[FARRMSGenericCLR.StoredProcedure].NordpoolFeedbackCapture
GO

IF OBJECT_ID('spa_build_epex_data_table') IS NOT NULL
    DROP PROC spa_build_epex_data_table
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO 
/*
 * Description : Build Data table for Epex Market results 
 * Param Description
		@process_table_name	: Name of Process table
		@area				: Area of Market Results
		@raw_data			: Data to be processed
 */ 
CREATE PROCEDURE [dbo].[spa_build_epex_data_table]
	@process_table_name NVARCHAR(150),
	@area NVARCHAR(50),
	@raw_data NVARCHAR(MAX) 
AS
	EXTERNAL NAME FARRMSGenericCLR.[FARRMSGenericCLR.StoredProcedure].BuildEpexDataTable
GO

IF OBJECT_ID('FNARemoveColumnsFromUpdate') IS NOT NULL
	DROP FUNCTION FNARemoveColumnsFromUpdate
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**
	Remove specified column name from update set clause

	Parameters
	@update_query : Update statement query
	@column_name_to_exclude : Column name defined in set clause update statement
	
*/
CREATE FUNCTION [dbo].[FNARemoveColumnsFromUpdate]
(
	@udpate_query NVARCHAR(MAX),
	@column_name_to_exclude NVARCHAR(MAX)
)
RETURNS TABLE(update_query NVARCHAR(MAX), [output_status] NVARCHAR(MAX))
AS
	EXTERNAL NAME FARRMSGenericCLR.[FARRMSGenericCLR.UserDefinedFunction].RemoveColumnsFromUpdate
GO