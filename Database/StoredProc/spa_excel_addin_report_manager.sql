
IF OBJECT_ID('spa_excel_addin_report_manager') IS NOT NULL
    DROP PROC spa_excel_addin_report_manager
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************
 ** Author: bbhandari@pioneersolutionsglobal.com
 * 
 * @flag =  s - selects the sheet data to be displayed in the grid of general tab.
 *			g - selects the grid data for the left hand side main grid.
 *			t - selects the data for privilege window grid.
 *			p - selects the data for the grid in Paramsets tab.
 *			d - for deleting the excel file.
 *			z - checks if the file to be deleted has snapshot in view report.
 *			c - selects file name according to excel_file_id.
 *			y - saves the user and role selected in the privilege window.
 *			i - saves the data after a new excel file is uploaded and saved.
 *			u - saves the data when the existing excel file is updated. 
 *			
 * @mode =  i - insert mode. triggers when a new file is uploaded.
 *			u - updat mode. triggers when an existing excel file is double clicked.			
 *******************************************/
CREATE PROC [dbo].[spa_excel_addin_report_manager]
	@flag CHAR(1),
	@xml VARCHAR(MAX) = NULL,
	@filename NVARCHAR(1024) = NULL, 
	@object_id INT = NULL,
	@mode CHAR(1) = NULL,
	@excel_file_id INT = NULL,
	@excel_sheet_id INT = NULL,
	@excel_sheet_parameter_id INT = NULL,
	@type_id VARCHAR(MAX) = NULL,
	@value_id INT = NULL,
	@call_from VARCHAR(20) = NULL,
	@xml_data VARCHAR(MAX) = NULL,
	@del_ids VARCHAR(MAX) = NULL
       
AS

/*----------DEBUG--------------------
DECLARE @flag CHAR(1),
	@xml VARCHAR(MAX) = NULL,
	@filename NVARCHAR(1024) = NULL, 
	@object_id INT = NULL,
	@mode CHAR(1) = NULL,
	@excel_file_id INT = NULL,
	@excel_sheet_id INT = NULL,
	@excel_sheet_parameter_id INT = NULL,
	@type_id VARCHAR(MAX) = NULL,
	@value_id INT = NULL,
	@call_from VARCHAR(20) = NULL,
	@xml_data VARCHAR(MAX) = NULL,
	@del_ids VARCHAR(MAX) = NULL

SELECT @flag='s',@filename='By_Cpty.xlsx',@mode='u'
------------------------------------*/

SET NOCOUNT ON	
DECLARE @output_result NVARCHAR(MAX),
        @temp_note_path VARCHAR(1024),
        @excel_report_path VARCHAR(1024),
        @full_file_path VARCHAR(1024),
		@old_filename VARCHAR(1024),
        @desc VARCHAR(5000) = NULL,
        @function_id INT = NULL,
        @idoc INT,
        @sql_id SMALLINT,
		@sheet_name VARCHAR(100) = NULL,
		@snapshot VARCHAR(100) = NULL,
		@publish_mobile VARCHAR(100) = NULL,
		@sheet_type VARCHAR(100) = NULL,
		@category_id INT = NULL,
		@parameter_sheet_name VARCHAR(100) = NULL,
		@alias VARCHAR(100) = NULL,
		@description VARCHAR(2048) = NULL,
		@maintain_history VARCHAR(100) = '1',
		@parameter_name VARCHAR(100) = NULL,
		@parameter_label VARCHAR(100) = NULL,
		@values VARCHAR(100) = NULL,
		@data_type VARCHAR(100) = NULL,
		@optional VARCHAR(100) = NULL,
		@override_type VARCHAR(100) = NULL,
		@no_days VARCHAR(100) = NULL,
		@file_exists INT,
		@exists INT = NULL,
		@sql VARCHAR(MAX) = NULL
		
DECLARE @user_login_id VARCHAR(20) = dbo.FNADBUser();
DECLARE @check_report_admin_role INT = ISNULL(dbo.FNAReportAdminRoleCheck(@user_login_id), 0)
DECLARE @is_admin INT = dbo.FNAIsUserOnAdminGroup(@user_login_id, 1)
			  
SELECT @temp_note_path = cs.document_path + '\temp_Note\', @excel_report_path = cs.document_path + '\Excel_Reports\'
FROM   connection_string cs

SET @full_file_path = @temp_note_path + @filename

IF (@flag IN ('i', 'u') OR (@flag = 'p' AND @mode = 'i'))
BEGIN
	IF OBJECT_ID('tempdb..#aggregate_excel_parameters') IS NOT NULL
		DROP TABLE tempdb..#aggregate_excel_parameters

	CREATE TABLE #aggregate_excel_parameters(
		id int IDENTITY(1, 1)
		, parameter_name NVARCHAR(512) COLLATE DATABASE_DEFAULT 
		, parameter_label NVARCHAR(512) COLLATE DATABASE_DEFAULT 
		, data_type INT
		, [values] NVARCHAR(1024) COLLATE DATABASE_DEFAULT 
		, [optional] BIT)
			
	INSERT INTO #aggregate_excel_parameters
	EXEC spa_excel_addin_parameters @filename= @full_file_path, @list_all='n', @output_result = NULL
	
	UPDATE aep2 SET parameter_label = aep.parameter_label + ' [To]'
	FROM #aggregate_excel_parameters aep
	INNER JOIN  #aggregate_excel_parameters aep2 ON aep2.parameter_name = '2_'+ aep.parameter_name  

	UPDATE aep SET parameter_label = aep.parameter_label + ' [From]'
	FROM #aggregate_excel_parameters aep
	INNER JOIN  #aggregate_excel_parameters aep2 ON aep2.parameter_name = '2_'+ aep.parameter_name  		
END

					
IF @flag = 's'
BEGIN
    IF @mode='u'
		BEGIN
			SELECT 
				es.sheet_name,
				es.alias,
				es.[description],
				es.[snapshot] publish,
				es.publish_mobile,
				es.category_id report_category,
				CASE WHEN es.sheet_type = 0 THEN 'e'
					WHEN es.sheet_type > 2 THEN 'd'
					ELSE 'h' END AS show_type,
				es.sheet_type,
				@maintain_history maintain_history,
				es.excel_sheet_id,
				ef.excel_file_id,
				es.paramset_hash,
				ISNULL(es.document_type, sdv.value_id) document_type,
				ISNULL(es.show_data_tabs, '0') show_data_tabs
			FROM
			excel_sheet es
			INNER JOIN excel_file ef 
			ON ef.excel_file_id = es.excel_file_id
			LEFT JOIN static_data_value AS sdv 
			ON ISNULL(es.document_type, 106700) = sdv.value_id AND sdv.[type_id] = 106700
			WHERE ef.[file_name] = @filename			
		END
    ELSE 
    BEGIN
    	IF OBJECT_ID('tempdb..#excel_sheets') IS NOT NULL
			DROP TABLE #excel_sheets
    
		CREATE TABLE #excel_sheets
		(
    		sheet_name           NVARCHAR(255) COLLATE DATABASE_DEFAULT,
    		report_name          NVARCHAR(255) COLLATE DATABASE_DEFAULT,
    		spa_rfx_query        NVARCHAR(MAX) COLLATE DATABASE_DEFAULT,
    		parameter_sheet      NVARCHAR(255) COLLATE DATABASE_DEFAULT,
    		sheet_type           NVARCHAR (255) COLLATE DATABASE_DEFAULT,
			paramset_hash		 VARCHAR(1000) COLLATE DATABASE_DEFAULT,
			document_type		 INT
		)
    
		INSERT INTO #excel_sheets
		EXEC spa_excel_addin_worksheets 
			@full_file_path,
			@output_result OUTPUT
        
		SELECT DISTINCT
			tes.sheet_name,
			tes.report_name,
			COALESCE(es.[description], CAST(NULL AS VARCHAR(2048))) as [description],
			COALESCE(es.[snapshot], CAST(NULL AS CHAR(1))) as [publish],
			COALESCE(es.publish_mobile, CAST(NULL AS CHAR(1))) as publish_mobile,
			COALESCE(es.category_id, CAST(NULL AS INT)) AS report_category,
			CASE WHEN tes.sheet_type = 0 THEN 'e'
				WHEN tes.sheet_type > 2 THEN 'd'
				ELSE 'h' END AS show_type,
			tes.sheet_type,
			@maintain_history maintain_history,
			@excel_sheet_id excel_sheet_id,
			@excel_file_id excel_file_id,
			tes.paramset_hash,
			tes.document_type,
		    es.show_data_tabs
		FROM #excel_sheets tes
		LEFT JOIN excel_sheet es
		ON es.sheet_name = tes.sheet_name
		AND es.document_type = tes.document_type
		AND es.sheet_type = tes.sheet_type
		LEFT JOIN excel_file ef 
		ON ef.excel_file_id = es.excel_file_id
		AND ef.[file_name] = @filename
    END
END

ELSE IF @flag = 'g'
BEGIN
	SET @sql = '
			SELECT DISTINCT
			   ef.[file_name],
			   ef.excel_file_id,
			   es.sheet_name,
			   es.excel_sheet_id,
			   es.[snapshot] [publish],
			   es.publish_mobile,
			   dbo.FNADateTimeFormat(l.snapshot_refreshed_on, 1) [refreshed_on],
			   sdv.code,
			   es.sheet_type,
			   es.paramset_hash,
			   es.show_data_tabs
			FROM   excel_file AS ef 
			'	
	SET @sql += '
			   INNER JOIN excel_sheet  AS es
					ON  ef.excel_file_id = es.excel_file_id AND es.sheet_type = 0 --IN (0, 3) include excel addin rport / user defined sheet tab
			   LEFT JOIN static_data_value sdv
					ON sdv.value_id = es.document_type
			   OUTER APPLY (
					SELECT TOP 1 ess.excel_sheet_snapshot_id AS latest_snapshot_id, ess.snapshot_refreshed_on
					FROM   excel_sheet_snapshot AS ess
					WHERE  es.excel_sheet_id = ess.excel_sheet_id
					ORDER BY latest_snapshot_id DESC
				)  l 
		' 
	IF @is_admin <> 1 AND @check_report_admin_role <> 1
	BEGIN
		SET @sql += ' 
				LEFT JOIN excel_report_privilege erp ON erp.type_id = ef.excel_file_id
					--TODO: Refactor - Current storage system in excel_report_privilege saves both excel_file_id and excel_sheet_id if privilege is
					--given to sheet only, which should ideally be NULL for excel_file_id. So extra check is required to exclude such rows.
					AND NULLIF(erp.value_id, 0) IS NULL
					AND (erp.[user_id] = ''' + @user_login_id + ''' OR erp.role_id IN (SELECT fur.role_id FROM dbo.FNAGetUserRole(''' + @user_login_id + ''') fur)) 
				WHERE 1=1 AND (ef.create_user = ''' + @user_login_id + ''' OR erp.excel_report_privilege_id IS NOT NULL)
			 '	
	END
	EXEC spa_print @sql 
	EXEC(@sql)
END

ELSE IF @flag = 't'
BEGIN
	IF @call_from = 'File'
	BEGIN
		SELECT 
		   ef.[file_name],
		   '' sheet_name,
		   '' [type],
		   '' excel_sheet_id,
		   ef.excel_file_id,
		   left(NULLIF(user_ids,''), LEN(user_ids) - 1) [user_id],
		   left(NULLIF(role_ids,''), LEN(role_ids) - 1) [role_id]
		FROM   excel_file AS ef
		OUTER APPLY
			(
				SELECT CAST([user_id] AS VARCHAR(MAX)) + ','	
				FROM excel_report_privilege 
				WHERE nullif(value_id,0) IS NULL
					AND [type_id] = @type_id
				FOR XML PATH('')
				) m (user_ids)
		OUTER APPLY
			(
				SELECT CAST(role_name AS VARCHAR(MAX)) + ','	
				FROM application_security_role asp
					LEFT JOIN excel_report_privilege erp
				ON asp.role_id = erp.role_id
				WHERE nullif(value_id,0) IS NULL 
					AND [type_id] = @type_id
				FOR XML PATH('')
			) n (role_ids)	
		WHERE  ef.[file_name] = @filename
	END
	ELSE
	BEGIN
		SELECT 
		   ef.[file_name],
		   es.sheet_name,
		   '' [type],
		   ef.excel_file_id,
		   es.excel_sheet_id,
		   left(user_ids, LEN(NULLIF(user_ids,'')) - 1) [user_id],
		   left(role_ids, LEN(NULLIF(role_ids,'')) - 1) [role_id]
		FROM   excel_file AS ef
		INNER JOIN excel_sheet  AS es
		ON  ef.excel_file_id = es.excel_file_id
		OUTER APPLY
			(
				SELECT CAST([user_id] AS VARCHAR(MAX)) + ','	
				FROM excel_report_privilege 
				WHERE value_id =  es.excel_sheet_id
					AND [type_id] = @type_id
				FOR XML PATH('')
				) m (user_ids)
		OUTER APPLY
			(
				SELECT CAST(role_name AS VARCHAR(MAX)) + ','	
				FROM application_security_role asp
					LEFT JOIN excel_report_privilege erp
				ON asp.role_id = erp.role_id
				WHERE value_id =  es.excel_sheet_id
					AND [type_id] = @type_id
				FOR XML PATH('')
			) n (role_ids)	
		WHERE  ef.[file_name] = @filename
		AND  es.sheet_type = 0 --IN (0, 3) include excel addin rport / user defined sheet tab
	END
END

ELSE IF @flag = 'p'
BEGIN
	IF @mode='u'
		BEGIN
			--TODO: Refactor using OVER clause of SQL SERVER 2012 feature
			SELECT MAX(rs_aep.name) parameter_name, rs_aep.label, MAX(rs_aep.data_type) data_type
			 , MAX(rs_aep.[values]) [values], CAST(MAX(CAST(rs_aep.optional AS TINYINT)) AS BIT) optional, MAX(rs_aep.override_type) override_type, MAX(rs_aep.no_days) no_days
			 , MAX(rs_aep.excel_sheet_parameter_id) excel_sheet_parameter_id, MAX(min_seq2.id) seq
			FROM excel_file ef
			CROSS APPLY 
			(
				SELECT aep.name, MAX(aep.label) label, MAX(aep.data_type) data_type, MAX(aep.[values]) [values]
				, CAST(MAX(CAST(aep.optional AS TINYINT)) AS BIT) optional, MAX(aep.override_type) override_type, MAX(aep.no_days) no_days
				, MAX(aep.excel_sheet_parameter_id) excel_sheet_parameter_id, MAX(aep.excel_file_id) excel_file_id, MAX(min_seq.id) id
				FROM excel_sheet_parameter aep 
				OUTER APPLY(SELECT TOP 1 excel_sheet_parameter_id id 
								FROM excel_sheet_parameter a 
								WHERE a.excel_file_id = aep.excel_file_id
									AND (a.name = aep.name OR LTRIM(RTRIM(a.label)) = LTRIM(RTRIM(aep.label)))
								ORDER BY a.excel_sheet_parameter_id ASC
					) min_seq 
				WHERE aep.excel_file_id = ef.excel_file_id
				GROUP BY aep.name
			) rs_aep-- ON ef.excel_file_id = rs_aep.excel_file_id
			OUTER APPLY(SELECT TOP 1 excel_sheet_parameter_id id 
								FROM excel_sheet_parameter a 
								WHERE a.excel_file_id = rs_aep.excel_file_id
									AND (a.name = rs_aep.name OR LTRIM(RTRIM(a.label)) = LTRIM(RTRIM(rs_aep.label))) 
								ORDER BY a.excel_sheet_parameter_id ASC
					) min_seq2 
			WHERE ef.[file_name] = @filename --'Book1.xlsx'		
			GROUP BY rs_aep.label
			ORDER BY seq
		END
    ELSE 
    BEGIN
			--TODO: Refactor using OVER clause of SQL SERVER 2012 feature
			SELECT MAX(rs_aep.parameter_name) parameter_name, rs_aep.parameter_label, MAX(rs_aep.data_type) data_type, NULL [values], 0 [optional], NULL [override_type], NULL [no_days], NULL [excel_sheet_parameter_id], MAX(min_seq2.id) seq
			FROM (
				SELECT aep.parameter_name, MAX(aep.parameter_label) parameter_label, MAX(aep.data_type) data_type, MAX(min_seq.id) id
				  FROM #aggregate_excel_parameters aep
				OUTER APPLY(SELECT TOP 1 id 
								FROM #aggregate_excel_parameters a 
								WHERE a.parameter_name = aep.parameter_name OR LTRIM(RTRIM(a.parameter_label)) = LTRIM(RTRIM(aep.parameter_label)) 
								ORDER BY a.id ASC
					) min_seq 
				GROUP BY aep.parameter_name
			) rs_aep
			OUTER APPLY(SELECT TOP 1 id 
								FROM #aggregate_excel_parameters a 
								WHERE a.parameter_name = rs_aep.parameter_name OR LTRIM(RTRIM(a.parameter_label)) = LTRIM(RTRIM(rs_aep.parameter_label)) 
								ORDER BY a.id ASC
					) min_seq2 
			
			GROUP BY rs_aep.parameter_label
			ORDER BY seq						
		END
END

ELSE IF @flag = 'z'
BEGIN
			
IF EXISTS(SELECT 1 FROM dbo.FNASplit(@del_ids,',') id INNER JOIN excel_sheet es ON es.excel_file_id = id.item INNER JOIN excel_sheet_snapshot exs ON exs.excel_sheet_id = es.excel_sheet_id)
	BEGIN	
			EXEC spa_ErrorHandler -1, 'Excel File', 
				'spa_excel_addin_report_manager', 
				'Error', 
				'Snapshot Exists.',
				 @object_id			
			
		END
ELSE
			BEGIN
				EXEC spa_ErrorHandler 0, 
							'Excel File', 
				'spa_excel_addin_report_manager',
				'Success', 
				'snapshot doesnot exist.',
				 @object_id
			END
END

ELSE IF @flag = 'd'
BEGIN
	BEGIN TRY
		
		DECLARE @id INT = 1
		DECLARE @count INT = NULL
		DECLARE @deleted_ids VARCHAR(MAX) = NULL
		
		IF OBJECT_ID(N'tempdb..#del_lists1') IS NOT NULL 
			DROP TABLE #del_lists1
			
		IF OBJECT_ID(N'tempdb..#del_lists2') IS NOT NULL 
			DROP TABLE #del_lists2
		
		IF OBJECT_ID(N'tempdb..#final_lists') IS NOT NULL 
			DROP TABLE #final_lists
		
		CREATE TABLE #del_lists1
		(
			id INT IDENTITY (1,1),
			[object_id] INT
		)
		
		CREATE TABLE #del_lists2
		(
			id INT IDENTITY (1,1),
			[filename] VARCHAR(MAX)
		)
		
		CREATE TABLE #final_lists
		(
			id INT,
			[object_id] INT,
			[filename] VARCHAR(MAX)
		)
			
		INSERT INTO #del_lists1
		(
			[object_id]
		)
		SELECT *
		FROM dbo.FNASplit(@del_ids,',') a		
		
		INSERT INTO #del_lists2
		(
			[filename]
		)
		SELECT *
		FROM dbo.FNASplit(@filename,',') b
				
		INSERT INTO #final_lists
		SELECT del1.id,
			   del1.[object_id],
			   del2.[filename]
		FROM #del_lists1 del1
		INNER JOIN #del_lists2 del2
		ON del1.id = del2.id
		
		SELECT @count = COUNT(1) 
		FROM #final_lists
		
		WHILE @count >= @id
		BEGIN
			SELECT @object_id = [object_id]
				 , @filename = [filename]
			FROM #final_lists
			WHERE id = @id
			
			SET @full_file_path = @excel_report_path + @filename
		
			IF EXISTS(SELECT 1 FROM excel_sheet es INNER JOIN excel_sheet_snapshot AS ess ON ess.excel_sheet_id = es.excel_sheet_id WHERE es.excel_file_id = @object_id)
			BEGIN
				DELETE ess
				FROM excel_sheet_snapshot ess
				INNER JOIN excel_sheet es 
				ON ess.excel_sheet_id = es.excel_sheet_id
				WHERE es.excel_file_id = @object_id	
			END
		
			DELETE esp
			FROM excel_sheet_parameter esp
			INNER JOIN excel_file ef
			ON esp.excel_file_id = ef.excel_file_id
			WHERE ef.excel_file_id = @object_id
		
			DELETE erp
			FROM excel_report_privilege AS erp
			INNER JOIN excel_file ef
			ON erp.[type_id] = ef.excel_file_id
			WHERE ef.excel_file_id = @object_id
		
			DELETE es
			FROM excel_sheet es
			INNER JOIN excel_file ef
			ON es.excel_file_id = ef.excel_file_id
			WHERE ef.excel_file_id = @object_id
		
			DELETE FROM excel_file 
			WHERE excel_file_id = @object_id
		
			EXEC [spa_delete_file] @full_file_path, @output_result OUTPUT
		
			--While terminating condition
			SET @id += 1
		END
		
		IF @id > 1
		EXEC spa_ErrorHandler 0, 
					'Excel File', 
					'spa_excel_addin_report_manager', 
					'Success', 
					'Delete success.', 
					 @del_ids
	END TRY 
		BEGIN CATCH
		EXEC spa_ErrorHandler -1, 
				'Excel File', 
				'spa_excel_addin_report_manager', 
				'Error', 
				'Delete failed.', 
				 @del_ids
		END CATCH
END

ELSE IF @flag = 'c'
BEGIN
	SELECT [file_name] FROM excel_file WHERE excel_file_id = @object_id
END

ELSE IF @flag = 'y'
BEGIN	
	EXEC sp_xml_preparedocument @idoc OUTPUT, @xml_data

	SELECT value_id		
		, [type_id]			
		, CASE WHEN [user] = 'None' OR [user] = '' THEN NULL ELSE [user] END [user]
		, CASE WHEN [role] = 'None' THEN NULL ELSE [role] END [role]
		, '' active_state
		INTO #temp_excel_privilege			
	FROM   OPENXML (@idoc, '/gridXml/GridRow', 1)
			WITH ( 
				value_id		VARCHAR(5000)	'@value_id',						
				[type_id]		VARCHAR(5000)	'@type_id', 
				[user]			VARCHAR(5000)	'@user',
				[role]			VARCHAR(5000)	'@role' 
				)
	EXEC sp_xml_removedocument @idoc
 
	CREATE TABLE #privilege_row (value_id	INT	
								, type_id	INT		
								, [user]	VARCHAR(1000) COLLATE DATABASE_DEFAULT 		
								, [role] VARCHAR(1000) COLLATE DATABASE_DEFAULT 
								) 
	SELECT [type_id]
		INTO #active_type_id
	FROM #temp_excel_privilege
	WHERE RTRIM(LTRIM([user])) <> 'All' OR [role] <>  'All'
	UNION ALL
	SELECT DISTINCT  type_id
	FROM excel_report_privilege

	--select * 
	UPDATE  tep 
	SET active_state = 1
	FROM #active_type_id ati
	INNER JOIN #temp_excel_privilege tep ON tep.[type_id] = ati.[type_id]

	DECLARE @active_state INT, 
			@user_id VARCHAR(MAX) = NULL,
			@role_id VARCHAR(MAX) = NULL

	DECLARE db_cursor CURSOR FOR  
	SELECT value_id		
			, [type_id]			
			, [user]			
			, [role]
			, active_state			
	FROM #temp_excel_privilege
	OPEN db_cursor   
	FETCH NEXT FROM db_cursor INTO  @value_id		
			, @type_id			
			, @user_id 			
			, @role_id 	
			, @active_state
	WHILE @@FETCH_STATUS = 0   
	BEGIN   
		IF @user_id = 'All'
		BEGIN 
			
			INSERT INTO #privilege_row( value_id		
								, [type_id]			
								, [user])
			SELECT @value_id, @type_id, user_login_id FROM application_users
		END 
		ELSE 
		BEGIN 
			INSERT INTO #privilege_row( value_id		
										, [type_id]			
										, [user])
			SELECT @value_id, @type_id, item FROM dbo.FNASplit(@user_id, ',') 
		END 

		IF @role_id = 'All'
		BEGIN				  
			INSERT INTO #privilege_row( value_id		
									, [type_id]			
									, [role])
			SELECT @value_id, @type_id, asr.role_id  FROM application_security_role asr 		 			 
		END 
		ELSE 
		BEGIN 
			INSERT INTO #privilege_row( value_id		
										, [type_id]			
										, [role])
			SELECT @value_id, @type_id, asr.role_id FROM dbo.FNASplit(@role_id, ',') i
			INNER JOIN application_security_role asr ON asr.role_name = i.item
		END 
		FETCH NEXT FROM db_cursor INTO @value_id		
			, @type_id			
			, @user_id 			
			, @role_id 	
			, @active_state
	END   
	CLOSE db_cursor   
	DEALLOCATE db_cursor
  
 	IF EXISTS(SELECT  1
			FROM #temp_excel_privilege WHERE [user] IS NULL OR [role] IS NULL)
	BEGIN
		--select *   
		DELETE erp
		FROM #temp_excel_privilege tep
		INNER JOIN excel_report_privilege erp ON erp.[type_id] = tep.[type_id]
			AND erp.value_id = tep.value_id
		WHERE tep.[user] IS NULL AND tep.[role] IS NOT NULL
			AND erp.[user_id] IS NOT NULL AND erp.[role_id] IS NULL

		--select *   
		DELETE erp
		FROM #temp_excel_privilege tep
		INNER JOIN excel_report_privilege erp ON erp.[type_id] = tep.[type_id]
			AND erp.value_id = tep.value_id
		WHERE tep.[user] IS NOT NULL AND tep.[role] IS NULL
			AND erp.[user_id] IS  NULL AND erp.[role_id] IS NOT NULL

		--select *   
		DELETE erp
		FROM #temp_excel_privilege tep
		INNER JOIN excel_report_privilege erp ON erp.[type_id] = tep.[type_id]
			AND erp.value_id = tep.value_id
		WHERE tep.[user] IS NULL AND tep.[role] IS NULL
	END  
 
	DELETE erp
	FROM #privilege_row tep
	INNER JOIN excel_report_privilege erp ON erp.[type_id] = tep.[type_id]
			AND erp.value_id = tep.value_id 
	WHERE erp.role_id IS NULL AND erp.[user_id] IS NULL

	--SELECT *
	DELETE erp
	FROM #privilege_row tep
	INNER JOIN excel_report_privilege erp ON erp.[type_id] = tep.[type_id]
			AND erp.value_id = tep.value_id
			AND erp.[user_id] <> tep.[user]
	WHERE 1=1
		--AND tep.[user] IS NULL
		AND erp.role_id IS NULL 
  
	DELETE erp
	FROM #privilege_row tep
	INNER JOIN excel_report_privilege erp ON erp.[type_id] = tep.[type_id]
			AND erp.value_id = tep.value_id
			AND erp.role_id <> tep.[role]
	WHERE 1=1
		--AND erp.[role] IS NULL
		AND erp.[user_id] IS NULL
 
	BEGIN TRY
		BEGIN TRAN
		--for user

		MERGE excel_report_privilege AS target
		USING (SELECT type_id, value_id,  [user] FROM #privilege_row WHERE [user] IS NOT NULL) AS source  
		ON (target.type_id = source.type_id
				AND target.value_id = source.value_id
				AND target.user_id = source.[user])
		WHEN NOT MATCHED BY TARGET THEN
		INSERT (type_id
				, value_id
				, user_id) VALUES (source.type_id
									, source.value_id
									 , source.[user]);
		 
		--for role
		MERGE excel_report_privilege AS target
		USING (SELECT type_id, value_id, [role] FROM #privilege_row WHERE [role] IS NOT NULL) AS source  
		ON (target.type_id = source.type_id
				AND target.value_id = source.value_id
				AND target.role_id = source.[role])
		WHEN NOT MATCHED BY TARGET THEN
		INSERT (type_id
				, value_id
				, role_id) VALUES (source.type_id
									, source.value_id
									 , source.[role]);

	
		COMMIT TRAN

		--Report Manager report privilege changed so release view report left grid data key.		
		IF  EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_manage_memcache]') AND TYPE IN (N'P', N'PC'))
		BEGIN			
			EXEC [spa_manage_memcache] @flag = 'd', @other_key_source='ReportManagerPrivilege', @source_object = 'spa_excel_addin_report_manager @flag=y'
		END

		EXEC spa_ErrorHandler 0
		   , 'excel_report_privilege'
		   , 'spa_excel_report_privilege'
		   , 'Success'
		   , 'Privilege assigned successfully.'
		   , ''
 
   	     
	 END TRY 
	 BEGIN CATCH 
		 IF @@TRANCOUNT > 0 ROLLBACK TRAN
 
	      EXEC spa_ErrorHandler -1
	           , 'excel_report_privilege'
			   , 'spa_excel_report_privilege'
			   , 'DB ERROR'
			   , 'Error while assigning privilege.'
			   , ''
	 END CATCH	
END

ELSE IF @flag IN ('i', 'u')
BEGIN	
	SELECT @file_exists = dbo.FNAFileExists(cs.document_path + '\Excel_Reports\' + @filename) FROM connection_string cs
		
	EXEC sp_xml_preparedocument @idoc OUTPUT, @xml

	IF OBJECT_ID('tempdb..#temp_excel_sheet') IS NOT NULL
		DROP TABLE #temp_excel_sheet
		
	SELECT
		excel_file_id,
		excel_sheet_id,
		sheet_name,
		[snapshot],
		publish_mobile,
		sheet_type,
		category_id,
		parameter_sheet_name,
		NULLIF(alias, '') alias,
		NULLIF([description], '') [description],
		maintain_history,
		NULLIF(paramset_hash, '') paramset_hash,
		document_type,
		show_data_tabs
	INTO #temp_excel_sheet
	FROM   OPENXML (@idoc, '/Root/GridGroup/SheetGrid/GridRow', 2)
	WITH (
		excel_file_id INT '@sql_id',
		excel_sheet_id INT'@excel_sheet_id',
		sheet_name VARCHAR(100) '@sheet_name',
		[snapshot] VARCHAR (100) '@snapshot',
		publish_mobile VARCHAR (100) '@publish_mobile',
		sheet_type VARCHAR (100) '@sheet_type',
		category_id INT '@category_id',
		parameter_sheet_name VARCHAR (100) '@parameter_sheet_name',
		alias VARCHAR (100) '@alias',
		[description] VARCHAR(250) '@description',
		maintain_history VARCHAR (100) '@maintain_history',
		paramset_hash VARCHAR(1000) '@paramset_hash',
		document_type INT '@document_type',
		show_data_tabs VARCHAR(100) '@show_data_tabs'
	)

	IF @flag = 'i'
	BEGIN
		IF @file_exists = 1
		BEGIN
			EXEC spa_ErrorHandler -1, 'Excel File/Excel Sheet', 
						'spa_excel_addin_report_manager', 'Error', 
						'File with same name already exists.', ''
		END
		ELSE
		BEGIN
			BEGIN TRY					
				BEGIN TRAN		
				INSERT INTO excel_file
				(
					[file_name]
				)
				SELECT 
					@filename
				
				SET @sql_id = SCOPE_IDENTITY()
				INSERT INTO excel_sheet
				(
					excel_file_id,
					sheet_name,
					[snapshot],
					publish_mobile,
					sheet_type,
					category_id,
					parameter_sheet_name,
					alias,
					[description],
					maintain_history,
					paramset_hash,
					document_type,
					show_data_tabs
				)
				SELECT 
					@sql_id,
					sheet_name,
					[snapshot],
					publish_mobile,
					sheet_type,
					NULLIF(category_id, ''),
					parameter_sheet_name,
					NULLIF (alias, ''),
					[description],
					maintain_history,
					paramset_hash,
					document_type,
					show_data_tabs
				FROM #temp_excel_sheet
				
				COMMIT

				--Report Manager report privilege changed so release view report left grid data key.		
				IF  EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_manage_memcache]') AND TYPE IN (N'P', N'PC'))
				BEGIN			
					EXEC [spa_manage_memcache] @flag = 'd', @other_key_source='ReportManagerPrivilege', @source_object = 'spa_excel_addin_report_manager @flag=i'
				END

				EXEC spa_ErrorHandler 0,
					'Excel File/Excel Sheet',
					'spa_excel_addin_report_manager',
					'Success',
					'Excel file has been saved.',
					@sql_id
			
			END TRY	
			BEGIN CATCH
				IF @@TRANCOUNT > 0
					ROLLBACK			
				SET @desc = dbo.FNAHandleDBError(@function_id)
	
				EXEC spa_ErrorHandler -1, 'Excel File/Excel Sheet', 
					'spa_excel_addin_report_manager', 'Error', 
					@desc, ''
			END CATCH	
		END	
	END
	ELSE IF @flag = 'u'
	BEGIN
		IF @file_exists = 0
		BEGIN
			BEGIN TRY					
				BEGIN TRAN
				SELECT @old_filename = [file_name] FROM excel_file WHERE excel_file_id = @object_id
				SET @old_filename = @excel_report_path + @old_filename
				EXEC [spa_delete_file] @old_filename, @output_result OUTPUT

				UPDATE ef
				SET
					ef.[file_name] = @filename
				FROM excel_file ef
				WHERE ef.excel_file_id = @object_id

				MERGE excel_sheet AS T
				USING #temp_excel_sheet AS S
				ON (T.excel_file_id = @object_id AND T.sheet_name = S.sheet_name)
				WHEN NOT MATCHED BY TARGET
					THEN INSERT(
							excel_file_id,
							sheet_name,
							[snapshot],
							publish_mobile,
							sheet_type,
							category_id,
							parameter_sheet_name,
							alias,
							[description],
							maintain_history,
							paramset_hash,
							document_type, 
							show_data_tabs ) 	
						VALUES(
							@object_id,
							S.sheet_name,
							S.[snapshot],
							S.publish_mobile,
							S.sheet_type,
							NULLIF (S.category_id, ''),
							S.parameter_sheet_name,
							NULLIF (S.alias, ''), 
							S.[description], 
							S.maintain_history,
							S.paramset_hash,
							S.document_type, 
							S.show_data_tabs)
				WHEN MATCHED 
					THEN UPDATE SET T.sheet_name = S.sheet_name,
									T.[snapshot] = S.[snapshot],
									T.publish_mobile = S.publish_mobile,
									T.sheet_type = S.sheet_type,
									T.category_id = NULLIF (S.category_id, ''),
									T.parameter_sheet_name = S.parameter_sheet_name,
									T.alias = NULLIF (S.alias, ''),
									T.[description] = S.[description],
									T.maintain_history = S.maintain_history,
									T.paramset_hash = S.paramset_hash,
									T.document_type = S.document_type,
									T.show_data_tabs = s.show_data_tabs;
				DELEte es 
				FROM excel_sheet es
				LEFT JOIN #temp_excel_sheet tes
				ON es.excel_file_id = @object_id AND es.sheet_name = tes.sheet_name
				WHERE tes.sheet_name IS NULL AND es.excel_file_id = @object_id
				
				COMMIT

				--Report Manager report privilege changed so release view report left grid data key.		
				IF  EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_manage_memcache]') AND TYPE IN (N'P', N'PC'))
				BEGIN			
					EXEC [spa_manage_memcache] @flag = 'd', @other_key_source='ReportManagerPrivilege', @source_object = 'spa_excel_addin_report_manager @flag=u'
				END


				EXEC spa_ErrorHandler 0,
					'Excel File/Excel Sheet',
					'spa_excel_addin_report_manager',
					'Success',
					'Excel file has been updated.',
					@filename
			
			END TRY	
			BEGIN CATCH
				IF @@TRANCOUNT > 0
					ROLLBACK			
				SET @desc = dbo.FNAHandleDBError(@function_id)
	
				EXEC spa_ErrorHandler -1, 'Excel File/Excel Sheet', 
					'spa_excel_addin_report_manager', 'Error', 
					@desc, ''
			END CATCH	
		END
		ELSE
		BEGIN
			BEGIN TRY
				BEGIN TRAN
				--SET @full_file_path = @temp_note_path + @filename
				UPDATE es
				SET
					es.sheet_name = tes.sheet_name,
					es.[snapshot] = tes.[snapshot],
					es.publish_mobile = tes.publish_mobile,
					es.sheet_type = tes.sheet_type,
					es.category_id = NULLIF(tes.category_id,''),
					es.parameter_sheet_name = tes.parameter_sheet_name,
					es.alias = NULLIF(tes.alias, ''),
					es.[description] = tes.[description],
					es.maintain_history = tes.maintain_history,
					es.paramset_hash = tes.paramset_hash,
					es.document_type = tes.document_type,
					es.excel_file_id = @object_id,
					es.show_data_tabs = tes.show_data_tabs
				FROM excel_sheet es 
				INNER JOIN #temp_excel_sheet tes
				ON es.excel_sheet_id = tes.excel_sheet_id
				
				COMMIT
				
				EXEC spa_ErrorHandler 0,
					'Excel File/Excel Sheet',
					'spa_excel_addin_report_manager',
					'Success',
					'Changes have been updated successfully.',
					@filename
			END TRY
			BEGIN CATCH
				IF @@TRANCOUNT > 0
					ROLLBACK			
				SET @desc = dbo.FNAHandleDBError(@function_id)
	
				EXEC spa_ErrorHandler -1, 'Excel File/Excel Sheet', 
					'spa_excel_addin_report_manager', 'Error', 
					@desc, ''
			END CATCH
		END	
	END
END
ELSE IF @flag = 'k'
BEGIN
	SELECT template_id, template_name 
	FROM Contract_report_template AS crt 
	WHERE crt.document_type = 'e'
END
