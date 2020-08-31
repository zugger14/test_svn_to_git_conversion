--procedure called from Endur Import SSIS package to log errors for importing

IF OBJECT_ID(N'dbo.spa_endur_import_report_invalid_file_format', N'P') IS NOT NULL
	DROP PROCEDURE dbo.spa_endur_import_report_invalid_file_format
GO

CREATE PROCEDURE dbo.spa_endur_import_report_invalid_file_format
	  @process_id VARCHAR(100),
	  @parse_type INT, --  mtm : 6, price : 4
	  @error_msg VARCHAR(2000)
  
AS

DECLARE @error_desc VARCHAR(1000), @error_main VARCHAR(500), @import_type VARCHAR(30)
SELECT @error_desc = ISNULL(@error_msg, 'Error found in import file.')
SELECT @error_main = dbo.FNAGetSplitPart(@error_desc,':',2)

SELECT @import_type  = CASE CAST(@parse_type AS VARCHAR)
							WHEN '4' THEN 'RWE Price Curve'
							WHEN '6' THEN 'RWE MTM'
							WHEN '5' THEN 'RWE Deal'
							WHEN '7' THEN 'Deal Detail Hour'
							ELSE 'File Format Error' 
						END

INSERT INTO source_system_data_import_status_detail(process_id, [source], [type], [description], [type_error])
SELECT @process_id, @import_type, NULL, @error_desc, @error_main

INSERT INTO source_system_data_import_status(Process_id, code, module, [source], [type], [description])
SELECT DISTINCT @process_id Process_id, 'Error' code, NULL module, @import_type source, 'Import' [type], @error_main [description]

