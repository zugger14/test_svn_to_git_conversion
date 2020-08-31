
IF OBJECT_ID(N'[dbo].[spa_rfx_data_source]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_rfx_data_source]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: rgiri@pioneersolutionsglobal.com
-- Create date: 2012-08-17
-- Description: Add/Update Operations for Report Resultsetss
-- IMPORTANT NOTE: THIS STORED PROCEDURE MUST NOT CONTAIN print() statement as this SP is called by SQLSRV library (in the application) which creates issues when it encounters print()               
-- Params:
-- @flag					CHAR	- Operation flag
-- @source_id

-- Sample Use:
-- 1. EXEC [spa_rfx_data_source] 's'
-- 2. EXEC [spa_rfx_data_source] 'a', NULL, 3
-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_rfx_data_source]
	@flag				CHAR(1),
	@report_id			INT = NULL,
	@name				VARCHAR(100)= NULL,
	@sql_query			VARCHAR(MAX) = NULL,
	@type_id			INT = NULL,
	@alias				VARCHAR(100) = NULL,
	@source_id			INT = NULL,
	@description		VARCHAR(1000) = NULL,
	@criteria			VARCHAR(5000) = NULL,
	@tsql_column_xml	VARCHAR(MAX) = NULL
AS
DECLARE @sql			NVARCHAR(MAX)  
DECLARE @user_name		VARCHAR(50) = dbo.FNADBUser() 

--Resolve Process Table Name
IF @flag = 's'
BEGIN
    SELECT ds.[type_id],
           ds.[data_source_id],
           	CASE WHEN CHARINDEX('[adiha_process].[dbo].[batch_export_', ds.[name], 1) > 0 THEN dbo.[FNAGetUserTableName](ds.[name], '[batch_export_') 
				 WHEN CHARINDEX('[adiha_process].[dbo].[report_export_', ds.[name], 1) > 0 THEN dbo.[FNAGetUserTableName](ds.[name], '[report_export_')
				ELSE ds.[name]
			END AS [Name],
          -- ds.[name],
           ds.[alias],
           ds.[description],
           ds.[tsql],
           ds.[report_id]
    FROM   data_source ds
    WHERE (CASE WHEN ds.[type_id] = 2 THEN ds.report_id ELSE @report_id END)  = @report_id 
END

IF @flag = 'i'
BEGIN
	
	CREATE TABLE #temp_errorhandler_result 
	(
		ErrorCode       VARCHAR(50) COLLATE DATABASE_DEFAULT,
    		Module          VARCHAR(100) COLLATE DATABASE_DEFAULT,
		Area            VARCHAR(100) COLLATE DATABASE_DEFAULT,
		[Status]        VARCHAR(100) COLLATE DATABASE_DEFAULT,
    		[Message]       VARCHAR(500) COLLATE DATABASE_DEFAULT,
		Recommendation  VARCHAR(500) COLLATE DATABASE_DEFAULT
	)	
	BEGIN TRY
		IF NOT EXISTS (SELECT 1 FROM data_source WHERE [name] = @name )
		BEGIN
			BEGIN TRAN
			CREATE TABLE #temp_exist ([alias] TINYINT)
			SET @sql =  'INSERT INTO #temp_exist ([alias]) SELECT TOP(1) 1 FROM data_source WHERE alias = ''' + @alias + ''''
			EXEC(@sql)
			
			IF EXISTS (SELECT 1 FROM #temp_exist)
			BEGIN
				EXEC spa_ErrorHandler -1, 'Reporting FX', 'spa_rfx_report_paramset', 'DB Error', 'Alias already exists.', ''
				RETURN
			END

			DECLARE @data_source_id INT
			DECLARE @Params NVARCHAR(500);
			SET @Params = N'@data_source_id INT OUTPUT';
			
			SET @sql = 'INSERT INTO data_source([type_id],[name],report_id,alias,[tsql],[description])
						SELECT	' + CAST (@type_id AS VARCHAR(20)) + '
								,''' + @name + '''
								,' + ISNULL(CAST(@report_id AS VARCHAR(20)), 'NULL') + '
								,''' + ISNULL(@alias, '') + '''
								,''' + ISNULL(REPLACE(@sql_query, '''', ''''''), '') + '''
								,''' + ISNULL(@description, '') + '''
								
						SET @data_source_id = SCOPE_IDENTITY() '

			--EXEC (@sql)
			EXEC sp_executesql @sql, @Params, @data_source_id = @data_source_id OUTPUT;
								
			CREATE TABLE #sql_columns_message_i
			(
				ErrorCode       VARCHAR(50) COLLATE DATABASE_DEFAULT,
					Module          VARCHAR(100) COLLATE DATABASE_DEFAULT,
				Area            VARCHAR(100) COLLATE DATABASE_DEFAULT,
				[Status]        VARCHAR(100) COLLATE DATABASE_DEFAULT,
					[Message]       VARCHAR(500) COLLATE DATABASE_DEFAULT,
				Recommendation  VARCHAR(500) COLLATE DATABASE_DEFAULT
			)
				
			IF @tsql_column_xml IS NOT NULL
			BEGIN
				INSERT INTO #sql_columns_message_i
				EXEC spa_rfx_save_data_source_column 'u', NULL, @data_source_id, @tsql_column_xml	
			END			
				
			DECLARE @state_check_i VARCHAR(200)
			SELECT @state_check_i = ErrorCode FROM #sql_columns_message_i
			IF @state_check_i = 'Error'
			BEGIN
				DECLARE @col_error_msg_i VARCHAR(8000)
				SELECT @col_error_msg_i = [Message] FROM #sql_columns_message_i
				RAISERROR (@col_error_msg_i, 16, 1 )
			END 
			
			EXEC spa_ErrorHandler 0, 'Reporting FX', 'spa_rfx_data_source', 'Success', 'Datasource successfully inserted.', @data_source_id
			COMMIT
		END
		ELSE
			EXEC spa_ErrorHandler -1, 'Reporting FX', 'spa_rfx_data_source', 'DB Error', 'Name already exists.', ''
	END TRY	
	BEGIN CATCH
		ROLLBACK TRAN
		EXEC spa_ErrorHandler 1, 'Reporting FX', 'spa_rfx_data_source', 'DB Error', 'Fail to insert datasource.', @source_id
	END CATCH
END

IF @flag = 'u'
BEGIN
	BEGIN TRY
		IF NOT EXISTS (SELECT 1 FROM data_source WHERE [name] = @name AND data_source_id <> @source_id AND [type_id] IN (1, 3))
		BEGIN
			BEGIN TRAN
			CREATE TABLE #temp_exist_u ([alias] TINYINT)
			SET @sql =  'INSERT INTO #temp_exist_u ([alias]) 
							SELECT TOP(1) 1 FROM data_source 
							WHERE alias = ''' + @alias + ''' AND data_source_id <> '+ CAST(@source_id AS VARCHAR) + '
							AND [type_id] IN (1, 3)'
							
			EXEC(@sql)
			
			IF EXISTS (SELECT 1 FROM #temp_exist_u)
			BEGIN
				EXEC spa_ErrorHandler -1, 'Reporting FX', 'spa_rfx_report_paramset', 'DB Error', 'Alias already exists.', ''
				RETURN
			END
		
			SET @sql = 'UPDATE data_source
						SET [type_id] = ' + CAST (@type_id AS VARCHAR(20)) + '
							, [name] = ''' + @name + '''
							, alias = ''' + ISNULL(@alias, '') + '''
							, [description] = ''' + ISNULL(@description, '')  + '''
							, [tsql] = ''' + ISNULL(REPLACE(@sql_query, '''', ''''''), '') + '''
							, report_id = ' + ISNULL(CAST(@report_id AS VARCHAR(20)), 'NULL') + '
						WHERE data_source_id = ' + CAST (@source_id AS VARCHAR(20))
			EXEC (@sql)
			
			CREATE TABLE #sql_columns_message_u
			(
				ErrorCode       VARCHAR(50) COLLATE DATABASE_DEFAULT,
				Module          VARCHAR(100) COLLATE DATABASE_DEFAULT,
				Area            VARCHAR(100) COLLATE DATABASE_DEFAULT,
				[Status]        VARCHAR(100) COLLATE DATABASE_DEFAULT,
				[Message]       VARCHAR(500) COLLATE DATABASE_DEFAULT,
				Recommendation  VARCHAR(500) COLLATE DATABASE_DEFAULT
			)
			
			IF @tsql_column_xml IS NOT NULL
			BEGIN
				--SELECT @process_id, @source_id
				INSERT INTO #sql_columns_message_u
				EXEC spa_rfx_save_data_source_column 'u', NULL, @source_id, @tsql_column_xml	
			END			
			
			--SELECT * FROM #sql_columns_message_u				
			
			DECLARE @state_check_u VARCHAR(200)
			SELECT @state_check_u = ErrorCode FROM #sql_columns_message_u
			
			IF @state_check_u = 'Error'
			BEGIN
				DECLARE @col_error_msg VARCHAR(8000)
					SELECT @col_error_msg = [Message] FROM #sql_columns_message_u
				RAISERROR (@col_error_msg, 16, 1 )
			END 	
			
			EXEC spa_ErrorHandler 0, 'Reporting FX', 'spa_rfx_data_source', 'Success', 'Datasource successfully updated.', @source_id
			
		COMMIT
		END
		ELSE
		BEGIN
			IF @@TRANCOUNT > 0
				ROLLBACK TRAN
			EXEC spa_ErrorHandler 1, 'Reporting FX', 'spa_rfx_data_source', 'DB Error', 'Name already exists.', ''
		END
			
	END TRY	
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN
			
			DECLARE @error_msg	VARCHAR(1000)
			DECLARE @error_no	VARCHAR(1000)
			
			SELECT @error_msg = ERROR_MESSAGE()
			SET @error_no = ERROR_NUMBER()
	
			EXEC spa_ErrorHandler @error_no, 'Reporting FX', 'spa_rfx_data_source', 'DB Error', @error_msg, ''	
			--EXEC spa_ErrorHandler 1, 'Reporting FX', 'spa_rfx_data_source', 'DB Error', 'Fail to update datasource.', @source_id
	END CATCH
END

IF @flag = 'p' -- v => View, q => SQL, t => Table
BEGIN
		--DECLARE @tid INT = 1
		
		SELECT DISTINCT ds.[type_id]
				, ds.data_source_id
				, CASE WHEN CHARINDEX('[adiha_process].[dbo].[batch_export_', ds.[name], 1) > 0 THEN dbo.[FNAGetUserTableName](ds.[name], '[batch_export_') 
						 WHEN CHARINDEX('[adiha_process].[dbo].[report_export_', ds.[name], 1) > 0 THEN dbo.[FNAGetUserTableName](ds.[name], '[report_export_')
						ELSE ds.[name]
					END AS [Name]
				, ds.alias
		FROM data_source ds
		LEFT JOIN application_role_user aru ON aru.user_login_id = dbo.FNADBUser()
		LEFT JOIN report_manager_view_users rmvu ON ds.data_source_id = rmvu.data_source_id
		WHERE  
			(dbo.FNAIsUserOnAdminGroup(dbo.FNADBUser(), 1) = 1	--if user belongs to Application Admin Group or Reporting Admin Group or AppAdminID (normally farrms_admin)
				OR (rmvu.login_id = dbo.FNADBUser() --if user is directly granted privilege for the view
				OR rmvu.role_id = aru.role_id)		--if role in which the user belongs is directly granted privilege for the view
			)		
		ORDER BY [type_id],[name]		  
END

IF @flag = 'v' -- v => View, q => SQL, t => Table
BEGIN
		DECLARE @tid INT = 1
		
		SELECT DISTINCT ds.[type_id]
				, ds.data_source_id
				, CASE WHEN CHARINDEX('[adiha_process].[dbo].[batch_export_', ds.[name], 1) > 0 THEN dbo.[FNAGetUserTableName](ds.[name], '[batch_export_') 
					   WHEN CHARINDEX('[adiha_process].[dbo].[report_export_', ds.[name], 1) > 0 THEN dbo.[FNAGetUserTableName](ds.[name], '[report_export_')
					   ELSE ds.[name]
					END AS [Name]
				, ds.alias
				, [description]
				, [tsql] 
		FROM data_source ds
		LEFT JOIN application_role_user aru ON aru.user_login_id = dbo.FNADBUser()
		LEFT JOIN report_manager_view_users rmvu ON ds.data_source_id = rmvu.data_source_id
		WHERE [type_id] = @tid 
			--AND 
			--(dbo.FNAIsUserOnAdminGroup(dbo.FNADBUser(), 1) = 1	--if user belongs to Application Admin Group or Reporting Admin Group or AppAdminID (normally farrms_admin)
			--	OR (rmvu.login_id = dbo.FNADBUser() --if user is directly granted privilege for the view
			--	OR rmvu.role_id = aru.role_id)		--if role in which the user belongs is directly granted privilege for the view
			--)			  
END
IF @flag = 'q' OR @flag = 't' -- v => View, q => SQL, t => Table
BEGIN
	SET @tid = (CASE WHEN @flag = 'q' THEN 2 ELSE 3 END)
	SELECT [type_id]
			, data_source_id, 
			CASE WHEN CHARINDEX('[adiha_process].[dbo].[batch_export_', ds.[name], 1) > 0 THEN dbo.[FNAGetUserTableName](ds.[name], '[batch_export_') 
				 WHEN CHARINDEX('[adiha_process].[dbo].[report_export_', ds.[name], 1) > 0 THEN dbo.[FNAGetUserTableName](ds.[name], '[report_export_')
				 ELSE ds.[name]
				END AS [Name]
			, ds.alias
			, [description]
			, [tsql] 
	FROM   data_source ds WHERE [type_id]= @tid	   
END
IF @flag = 'x' --for especially views stored, called from select privileges
BEGIN
	SELECT ds.data_source_id AS [ID], ds.[name] AS [View Name], ds.alias AS [Alias] FROM   data_source ds WHERE  ds.[type_id] = 1
END

IF @flag = 'w'
BEGIN
	SELECT data_source_id [Data Source ID]
			, CASE WHEN [TYPE_ID] = 1 THEN 'View' WHEN [TYPE_ID] = 3 THEN 'Table' END AS [TYPE]
			--To display only the user given table name excluding the '[adiha_process].[dbo].[batch_export_'
			, CASE WHEN CHARINDEX('[adiha_process].[dbo].[batch_export_', [name], 1) > 0 THEN dbo.[FNAGetUserTableName]([name], '[batch_export_') 
				WHEN CHARINDEX('[adiha_process].[dbo].[report_export_', [name], 1) > 0 THEN dbo.[FNAGetUserTableName]([name], '[report_export_')
					ELSE [name] 
				END AS [Name]
			, ALIAS AS [ALIAS]
			, [description] AS [Description]
	FROM data_source WHERE [TYPE_ID] <> 2
END

IF @flag = 'd'
BEGIN
	IF NOT EXISTS (SELECT 1 FROM report_dataset rd WHERE rd.source_id = @source_id)
	BEGIN
		BEGIN TRY
			BEGIN TRAN
				SET @sql = 'DELETE FROM data_source_column WHERE source_id = ' + CAST(@source_id AS VARCHAR(10))
				SET @sql = @sql + ' DELETE FROM report_manager_view_users WHERE data_source_id = ' + CAST(@source_id AS VARCHAR(10))				
				SET @sql = @sql + ' DELETE FROM data_source WHERE data_source_id = ' + CAST(@source_id AS VARCHAR(10))
				
				EXEC spa_print @sql
				EXEC(@sql)				
			COMMIT
			EXEC spa_ErrorHandler 0, 'Reporting FX', 'spa_rfx_data_source', 'Success', 'Datasource successfully deleted.', ''
		END TRY
		BEGIN CATCH
			ROLLBACK TRAN
			EXEC spa_ErrorHandler 1, 'Reporting FX', 'spa_rfx_data_source', 'DB Error', 'Fail to delete datasource.', ''
		END CATCH	
	END
	ELSE 
		EXEC spa_ErrorHandler 1, 'Reporting FX', 'spa_rfx_data_source', 'DB Error', 'Datasource being used can not be deleted.', @source_id 
	
END

IF @flag = 'a'
BEGIN
	SELECT ds.data_source_id,
	       ds.[type_id],
	       ds.[name],
	       ds.alias,
	       ds.[description],
	       ds.[tsql],
	       ds.report_id
	FROM   data_source ds
	WHERE  ds.data_source_id = @source_id 
END
	
IF @flag = 'y' --for especially views stored, called from pivot template
BEGIN
	SELECT ds.data_source_id AS [ID], ds.[name] AS [View Name] FROM   data_source ds WHERE  ds.[type_id] = 1
END
