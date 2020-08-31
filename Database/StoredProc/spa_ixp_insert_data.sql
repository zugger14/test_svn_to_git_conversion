IF OBJECT_ID(N'[dbo].[spa_ixp_insert_data]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_ixp_insert_data]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===============================================================================================================
-- Author: rajiv@pioneersolutionsglobal.com
-- Create date: 2008-09-09
-- Description: Description of the functionality in brief.
 
-- Params:
-- @flag CHAR(1)        - Description of param2
-- @param1 VARCHAR(100) - Description of param3
-- ===============================================================================================================
-- 
CREATE PROCEDURE [dbo].[spa_ixp_insert_data]
    @temp_process_table VARCHAR(2000),
    @file_path VARCHAR(2000),
    @delimiter CHAR(1),
    @header CHAR(1),
	@file_name VARCHAR(1000)
    
AS
 
DECLARE @file_type VARCHAR(10)
DECLARE @server_name VARCHAR(200)

SELECT  @server_name = CONVERT(VARCHAR(200),ServerProperty('ServerName'))

IF @header = 'y' 
	SET @file_type = '-F1'
ELSE 
	SET @file_type = '-F2'

DECLARE insert_cursor CURSOR FOR
SELECT DISTINCT item FROM dbo.SplitCommaSeperatedValues(@file_name)

DECLARE @file AS VARCHAR(100)
OPEN insert_cursor
	FETCH NEXT FROM insert_cursor
	INTO @file
	WHILE @@FETCH_STATUS = 0
	BEGIN
		DECLARE @full_file_path VARCHAR(2000)
		--SET @full_file_path = 'D:\FARRMS_APPLICATIONS\Products\TRMTracker_New_Framework\FARRMS\trm\adiha.php.scripts\dev\shared_docs\temp_Note' + '\' + @file
		SET @full_file_path = @file_path + '\' + @file
		
		DECLARE @import_status NVARCHAR(MAX)
		SET @header = CASE WHEN @header = 'y' THEN 'n' ELSE 'y' END 
		EXEC spa_import_from_csv
			@csv_file_path = @full_file_path,
			@process_table_name = @temp_process_table,
			@delimeter = @delimiter,
			@row_terminator = '\n',
			@has_column_headers = @header,
			@has_fields_enclosed_in_quotes = 'n',
			@include_filename = 'n',
			@result = @import_status OUTPUT
		FETCH NEXT FROM insert_cursor
		INTO @file
	END
	CLOSE insert_cursor
DEALLOCATE insert_cursor