IF OBJECT_ID(N'dbo.[spa_dump_csv]', N'P') IS NOT NULL
    DROP PROC dbo.[spa_dump_csv]
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON 
GO

/**
	Generates a flat file (CSV, XML) from a given query or a process table.

	Parameters 
	@data_table_name : Table name where data exists.
	@full_file_path : Full file path to generate the file.
	@compress_file : Whether to compress the file. Deaults to 'n'.
	@delim : Delimeter to use in CSV file. 
	@is_header : Whether to include column headers or not in the csv file.
	@xml_format : Custom format to use to generate XML file.
	@report_name : Report name to include in XML file.
	@data_sp : Query to generate data.
	@process_id : Process ID.
*/

--Note:
--All data are converted into VARCHAR while exporting.
--Max precision (full length including decimal) supported by float is 15. 
--So while converting float to varchar we have used STR, with length 16 (including .) and decimal to 8. 
--So float within the range (precision, scale) of (15, 8) will be accurately converted by STR (float, 16, 8). 
--Since float has been used in only smaller range of values,this shouldn't be a problem

CREATE PROC [dbo].[spa_dump_csv]
	@data_table_name	VARCHAR(MAX) = NULL,
	@full_file_path			VARCHAR(MAX) = NULL,
	@compress_file		CHAR(1) = 'n',
	@delim				VARCHAR(200)	= NULL,
    @is_header			VARCHAR(200)	= NULL,
	@xml_format			INT = NULL,
	@report_name		VARCHAR(200)	= NULL,
	@data_sp			VARCHAR(MAX)	= NULL,		--SP execution call to generate data
	@process_id			VARCHAR(50)	= NULL
	
AS
DECLARE @table_or_sp VARCHAR(MAX) = @data_table_name
IF OBJECT_ID(@data_table_name) IS NULL
	SET @table_or_sp = @data_sp

IF @report_name IS NULL
	SET @report_name = ''

IF @table_or_sp IS NOT NULL AND @full_file_path IS NOT NULL
BEGIN
	DECLARE @result		NVARCHAR(4000)
	DECLARE @sql        VARCHAR(MAX)
	DECLARE @col_list   VARCHAR(MAX)	
          
	IF RIGHT(RTRIM(@full_file_path), 4) = '.xml'
	BEGIN		
		DECLARE @base_xml_format INT
		DECLARE @xslt_path VARCHAR(5000)
		DECLARE @eff_file_path VARCHAR(8000)
		DECLARE @is_custom_xml_format BIT
		DECLARE @inner_result NVARCHAR(4000)
		DECLARE @summary_description VARCHAR(4000)
		DECLARE @detail_description VARCHAR(4000)
		DECLARE @url VARCHAR(8000)
		DECLARE @user_name VARCHAR(100) = dbo.FNADBUser(), @compress_custom_xml_file CHAR(1) = 'n'

		SET @is_custom_xml_format = CASE WHEN @xml_format NOT IN (-100000, -100001) THEN 1 ELSE 0 END

		IF @is_custom_xml_format = 1
		BEGIN
			--set @base_xml_format as node based format for XSLT transformation
			SET @base_xml_format = -100000
			--retain original file name for final output by creating _tmp file for base xml file (input) for transformation
			SET @eff_file_path = REPLACE(@full_file_path, '.xml', '_tmp.xml')
			SELECT @xslt_path = CONCAT(cs.document_path, '\xml_docs\', sdv_xml_format.code, '.xsl')
			FROM connection_string cs
			INNER JOIN static_data_value sdv_xml_format ON sdv_xml_format.value_id = @xml_format

			IF @compress_file = 'y'
				SET @compress_custom_xml_file = 'y'

			SET @compress_file = 'n'
		END
		ELSE
		BEGIN
			SET @base_xml_format = @xml_format
			SET @eff_file_path = @full_file_path
		END
		EXEC spa_create_xml_document @table_or_sp, 'https://pioneersolutionsglobal.com/xml/ns', @report_name,@base_xml_format,@eff_file_path, @compress_file, @result OUTPUT	

		--error handling for standard xml export
		IF @is_custom_xml_format = 1 AND @result = N'true'
		BEGIN
			--continue generating custom xml applying XSLT
			EXEC spa_transform_xml @eff_file_path, @xslt_path, @full_file_path, @compress_custom_xml_file, 'y', @inner_result OUTPUT
			
			IF @inner_result IS NOT NULL AND @inner_result != N'true'
			BEGIN
				DECLARE @new_process_id VARCHAR(75) = dbo.FNAGetNewID()
				SET @summary_description = CONCAT('XML validation failed for report <strong>', @report_name, '</strong>.')
				SET @detail_description = CONCAT(@summary_description, ' Error: ' + @inner_result)
				
				SELECT @url = './dev/spa_html.php?spa=exec spa_get_import_process_status ''' + @new_process_id + ''','''+@user_name+''''
				SELECT @url = '<a target="_blank" href="' + @url + '">' + @summary_description + '</a>.'

				--reuse import status table for detail error reporting	
				EXEC spa_source_system_data_import_status @flag='i', @process_id=@new_process_id, @code='Failed'
					, @module='XML Validation', @source=@report_name, @type='Error', @description=@detail_description

				EXEC spa_message_board 
					@flag='i'
					, @user_login_id= @user_name
					, @source = @report_name
					, @description=@url
					, @url_desc=''
					, @url=''
					, @type='s'	--TODO: check meaning of different type
					, @process_id = @new_process_id
			END
		END
	END
	ELSE IF RIGHT(RTRIM(@full_file_path), 4) = '.csv' OR RIGHT(RTRIM(@full_file_path), 4) = '.txt'
	BEGIN
		/*Process for .txt and .csv is same. Only extension is different.*/
		EXEC spa_export_to_csv @table_or_sp, @full_file_path, @is_header, @delim, @compress_file,'n','y','y',@result OUTPUT
	END

	IF @compress_file = 'y'  
	BEGIN
		Declare @output_msg nvarchar(1024)
		EXEC spa_delete_file @full_file_path, @output_msg OUTPUT 	
	END
	
	--Raise error to mark the job as failure in case of error, so that job next step will write failure message in message board
	IF (@result <> N'true' AND  @result <> '1') OR (@inner_result <> N'true' AND @is_custom_xml_format = 1 AND @inner_result IS NOT NULL)
	BEGIN

		RAISERROR
			(N'Error generating file from spa_dump_csv.',
			10, -- Severity.
			1 -- State.
			);
	END	
END
