IF OBJECT_ID(N'[dbo].[spa_ssis_configurations]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_ssis_configurations]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ===========================================================================================================
--	Author: smanandhar@pioneersolutionsglobal.com
--	Create date: 2011-06-14
--	Description: CRUD operations  for table ssis_configurations

--	Params:
--		@flag CHAR(1) - Operation flag
--		@configuration_filter NVARCHAR(255) - Configuration filter 
--		@configured_value NVARCHAR(255) - Configured value
--		@package_path NVARCHAR(255) - Package path
--		@configured_value_type NVARCHAR(20) - Configured value type  
--		@xmlValue NVARCHAR(MAX) - XML Value
--		@save CHAR(1) = 'y',	-- 'y' = save data for editable grid 
--		@batch_process_id VARCHAR(50) - Process id
--		@batch_report_param VARCHAR(1000) - Batch report parameter
--		@enable_paging INT = 0,  --	'1' = enable, '0' = disable
--		@page_size INT - Page size for paging
--		@page_no INT - Page no for  paging
-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_ssis_configurations]
    @flag CHAR(1) = NULL,
    @configuration_filter NVARCHAR(255) = NULL,
    @package_path NVARCHAR(255) = NULL,
    @configured_value NVARCHAR(255) = NULL,
    @configured_value_type NVARCHAR(20) = NULL,
    @xmlValue NVARCHAR(MAX) = NULL,
    @save CHAR(1) = 'y',
    @batch_process_id VARCHAR(50) = NULL,
	@batch_report_param VARCHAR(1000) = NULL,
    @enable_paging INT = 0,  --	'1' = enable, '0' = disable
	@page_size INT = NULL,
	@page_no INT = NULL
AS

SET NOCOUNT ON;
DECLARE @sql VARCHAR(8000)
DECLARE @err_no INT
DECLARE @idoc INT

/*******************************************1st Paging Batch START**********************************************/

DECLARE @str_batch_table VARCHAR(8000)
DECLARE @process_table_name VARCHAR(150)
DECLARE @is_batch BIT
DECLARE @sql_paging VARCHAR(8000)
DECLARE @user_login_id VARCHAR(50)

SET @str_batch_table = ''
SET @user_login_id = dbo.FNADBUser() 
SET @is_batch = CASE WHEN @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL THEN 1 ELSE 0 END 
SET @process_table_name = dbo.FNAProcessTableName('batch_report', @user_login_id, @batch_process_id)

IF @is_batch = 1
   SET @str_batch_table = ' INTO ' + @process_table_name 

IF @enable_paging = 1 --paging processing
BEGIN
	IF @batch_process_id IS NULL
		SET @batch_process_id = dbo.FNAGetNewID()
	
	SET @str_batch_table = dbo.FNAPagingProcess('p', @batch_process_id, @page_size, @page_no)
	
	--retrieve data from paging table instead of main table
	IF @page_no IS NOT NULL  
	BEGIN
		DECLARE @row_to INT, @row_from INT  
		SET @row_to = @page_no * @page_size  
						 
		IF @page_no > 1
		   SET @row_from = ((@page_no -1) * @page_size) + 1
		ELSE
		   SET @row_from = @page_no			   
	   
	   SELECT @sql_paging = '[Configuration Filter],
							REPLACE([Package Path], ''\'', ''\\'') AS [Package Path],
							REPLACE([Configured Value], ''\'', ''\\'') AS [Configured Value],
							[Configured Value Type] AS [Configured Value Type],
							[Configuration Filter Hidden] AS [Configuration Filter Hidden],
							REPLACE([Package Path Hidden], ''\'', ''\\'') AS [Package Path Hidden]'
		
	   SET @sql_paging = 'SELECT ' + @sql_paging + '  
						  FROM ' + @process_table_name + '   
						  WHERE row_id BETWEEN ' + CAST(@row_from AS VARCHAR(10)) + ' AND ' + CAST(@row_to AS VARCHAR(10))
		EXEC (@sql_paging)  
		RETURN  
	END
END

/*******************************************1st Paging Batch END**********************************************/

IF @flag = 's'
BEGIN
	SET @sql = ' SELECT ConfigurationFilter AS [Configuration Filter],
						PackagePath AS [Package Path],
						ConfiguredValue AS [Configured Value],
						ConfiguredValueType AS [Configured Value Type],
						ConfigurationFilter AS [Configuration Filter Hidden],
						PackagePath AS [Package Path Hidden]' + @str_batch_table +
				' FROM   ssis_configurations sc
				WHERE  1 = 1 '
	IF @configuration_filter IS NOT NULL
		SET @sql = @sql + ' AND sc.ConfigurationFilter LIKE ''%' + @configuration_filter + '%'''
	IF @configured_value IS NOT NULL
		SET @sql = @sql + ' AND sc.ConfiguredValue LIKE ''%' + @configured_value + '%'''
	IF @package_path IS NOT NULL
		SET @sql = @sql + ' AND sc.PackagePath LIKE ''%' + @package_path + '%'''
	EXEC (@sql)			
END
ELSE IF @flag = 'i'
BEGIN
	BEGIN TRY
		IF EXISTS(SELECT 1 FROM ssis_configurations WHERE ConfigurationFilter = @configuration_filter AND PackagePath = @package_path)
		BEGIN
			EXEC spa_ErrorHandler -1,
	    			 'ssis_configurations table',
	    			 'spa_ssis_configurations',
	    			 'Failed',
	    			 'Data already exists.Value for Package Path should be defined only once for each Configuration Filter.',
	    			 ''
		END
		ELSE
		BEGIN
			INSERT INTO ssis_configurations
			  (
				ConfigurationFilter,
				ConfiguredValue,
				PackagePath,
				ConfiguredValueType
			  )
			VALUES
			  (
				@configuration_filter,
				@configured_value,
				@package_path,
				@configured_value_type
			  )
			EXEC spa_ErrorHandler 0,
	    			 'ssis_configurations table',
	    			 'spa_ssis_configurations',
	    			 'Success',
	    			 'Data successfully inserted.',
	    			 ''
		END	
	END TRY
	BEGIN CATCH
    	SET @err_no = ERROR_NUMBER()
    	EXEC spa_ErrorHandler @err_no,
    	     'ssis_configurations table',
    	     'spa_ssis_configurations',
    	     'DB Error',
    	     'Failed inserting data.',
    	     ''
	END CATCH
END
ELSE IF @flag = 'u'
BEGIN
	BEGIN TRY
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlValue
		
		SELECT ConfigurationFilter,
		       PackagePath,
		       ConfiguredValue,
		       ConfiguredValueType,
		       oldConfigurationFilter,
		       oldPackagePath 
		       INTO 
		       #tbl_xmlSSIS
		FROM   OPENXML(@idoc, '/Root/PSRecordset', 2) 
		       WITH (
		           ConfigurationFilter NVARCHAR(255) '@editGrid1',
		           PackagePath NVARCHAR(255) '@editGrid2',
		           ConfiguredValue NVARCHAR(255) '@editGrid3',
		           ConfiguredValueType NVARCHAR(255) '@editGrid4',
		           oldConfigurationFilter NVARCHAR(255) '@editGrid5',
		           oldPackagePath NVARCHAR(255) '@editGrid6'  
		       )
		-- To check the existing data  for  update. 		       
		IF EXISTS(
			SELECT ISNULL(t.ConfigurationFilter, sc.ConfigurationFilter) final_filter, ISNULL(t.PackagePath, sc.PackagePath) final_path, COUNT(*) cnt
			FROM ssis_configurations sc
			LEFT JOIN #tbl_xmlSSIS t ON sc.ConfigurationFilter = t.oldConfigurationFilter
				AND sc.PackagePath = t.oldPackagePath
			GROUP BY ISNULL(t.ConfigurationFilter, sc.ConfigurationFilter), ISNULL(t.PackagePath, sc.PackagePath)
			HAVING COUNT(*) > 1)
			
		BEGIN
			EXEC spa_ErrorHandler -1,
				 'ssis_configurations table',
				 'spa_ssis_configurations',
				 'Failed',
				 'Data already exists.Value for Package Path should be defined only once for each Configuration Filter.',
				 ''
		END
		ELSE
		-- puts all the data in the paging table
		BEGIN
			SET @sql = '
			UPDATE sc
				SET [Configuration Filter] = t.ConfigurationFilter,
					[Package Path] = t.PackagePath,
					[Configured Value] = dbo.FNAURLDecode(t.ConfiguredValue),
					[Configured Value Type] = t.ConfiguredValueType
				FROM   #tbl_xmlSSIS t
					INNER JOIN ' + @process_table_name + ' sc
						 ON  sc.[Configuration Filter] = t.oldConfigurationFilter
						 AND sc.[Package Path] = t.oldPackagePath'
			EXEC (@sql)
			--	if save = 'y', the data is updated from paging table 
			IF @save = 'y'
			BEGIN
				 SET @sql = '
				 UPDATE sc
					SET ConfigurationFilter = t.[Configuration Filter],
						PackagePath = t.[Package Path],
						ConfiguredValue = dbo.FNAURLDecode(t.[Configured Value]),
						ConfiguredValueType = t.[Configured Value Type]
				 	FROM ' + @process_table_name + ' t
					INNER JOIN ssis_configurations sc
						ON  sc.ConfigurationFilter = t.[Configuration Filter Hidden]
						AND sc.PackagePath = t.[Package Path Hidden]'
				EXEC (@sql)
				EXEC spa_ErrorHandler 0,
				  'ssis_configurations table',
				  'spa_ssis_configurations',
				  'Success',
				  'Data successfully updated.',
				  ''		
			END
			ELSE
			BEGIN 
				RETURN
			END  
		END
	END TRY
	BEGIN CATCH
    	SET @err_no = ERROR_NUMBER()
    	EXEC spa_ErrorHandler @err_no,
    	     'ssis_configurations table',
    	     'spa_ssis_configurations',
    	     'DB Error',
    	     'Failed updating data.',
    	     ''
	END CATCH
END
ELSE IF @flag = 'd'
BEGIN
	BEGIN TRY
		DELETE FROM ssis_configurations
		WHERE  ConfigurationFilter = @configuration_filter
		       AND PackagePath = @package_path 
		EXEC spa_ErrorHandler 0,
	    	     'ssis_configurations table',
	    	     'spa_ssis_configurations',
	    	     'Success',
	    	     'Data successfully deleted.',
	    	     ''
	END TRY
	BEGIN CATCH
    	SET @err_no = ERROR_NUMBER()
    	EXEC spa_ErrorHandler @err_no,
    	     'ssis_configurations table',
    	     'spa_ssis_configurations',
    	     'DB Error',
    	     'Failed deleting data.',
    	     ''
	END CATCH
END
--	@flag = 'e' is used for exporting report  
ELSE IF @flag = 'e'
BEGIN
	SET @sql = ' SELECT ConfigurationFilter AS [Configuration Filter],
						REPLACE(PackagePath, ''\'', ''\\'') AS [Package Path],
						REPLACE(ConfiguredValue, ''\'', ''\\'') AS [Configured Value],
						ConfiguredValueType AS [Configured Value Type]' + @str_batch_table +
				' FROM   ssis_configurations sc
				WHERE  1 = 1 '
	IF @configuration_filter IS NOT NULL
		SET @sql = @sql + ' AND sc.ConfigurationFilter LIKE ''%' + @configuration_filter + '%'''
	IF @configured_value IS NOT NULL
		SET @sql = @sql + ' AND sc.ConfiguredValue LIKE ''%' + @configured_value + '%'''
	IF @package_path IS NOT NULL
		SET @sql = @sql + ' AND sc.PackagePath LIKE ''%' + @package_path + '%'''
	EXEC (@sql)			
END

/*******************************************2nd Paging Batch START**********************************************/

--update time spent and batch completion message in message board
IF @is_batch = 1
BEGIN
   SELECT @str_batch_table = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL) 
   EXEC(@str_batch_table)

   SELECT @str_batch_table = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, GETDATE(), 'spa_ssis_configurations', '') --TODO: modify sp and report name
   EXEC(@str_batch_table)
   RETURN
END

--if it is first call from paging, return total no. of rows and process id instead of actual data
IF @enable_paging = 1 AND @page_no IS NULL
BEGIN
   SET @sql_paging = dbo.FNAPagingProcess('t', @batch_process_id, @page_size, @page_no)
   EXEC(@sql_paging)
END
/*******************************************2nd Paging Batch END**********************************************/
GO
