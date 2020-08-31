
IF OBJECT_ID('spa_excel_snapshots') IS NOT NULL
    DROP PROCEDURE spa_excel_snapshots
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
/**
	Excel snapshot ssis package misc. operation

	Parameters
	@flag : 
			'f' Get list of excel files under excel reports folder
			'e' Get configuration of saved excel sheet
			'c' Get document , temp note, ssis package folder path
			'p' Get saved configuration of excel file published sheet
			'h' Save history of snapshot generated
			'o' Xml parameter for report generation
			'x' Get report parameters present excl file
			'y' Get user signature image from application notes
			'z' Get paramset id / tablix id from paramset hash
	@sheet_id : Excel sheet id
	@filename : Excel file name
	@snapshot_sheet_name : Snapshot sheet name
	@snapshot_filename : Snapshot filename
	@applied_filter : Applied filter
	@refreshed_on : refreshed on date
	@batch_call_xml : batch parameters
	@process_id : process id
	@user_name : runtime username
	@paramset_hash : report paramset hash
*/
CREATE PROC [dbo].[spa_excel_snapshots]
@flag CHAR(1) = 'a'
,@sheet_id VARCHAR(1024) = NULL
,@filename VARCHAR(1024) = NULL
,@snapshot_sheet_name VARCHAR(1024) = NULL
,@snapshot_filename VARCHAR(1024) = NULL
,@applied_filter VARCHAR(MAX) = NULL
,@refreshed_on DATETIME = NULL,
@batch_call_xml XML = NULL,
@process_id VARCHAR(1000) = NULL,
@user_name NVARCHAR(255) = NULL,
@paramset_hash NVARCHAR(255) = NULL
AS
BEGIN
	DECLARE @repository_path NVARCHAR(1024)
	SELECT @repository_path = cs.document_path + '\Excel_Reports\'
	FROM   connection_string cs
	SET @process_id = CASE WHEN @process_id IS NULL THEN REPLACE(NEWID(),'-','_') ELSE @process_id END 
	
	IF @flag = 'f'
	BEGIN
	    SELECT f.[filename]
	    FROM   dbo.FNAListFiles(@repository_path, '*.xlsx', 'n') f
	    WHERE  CHARINDEX('~', f.[filename], 0) = 0
	END
	ELSE IF @flag = 'e'
	BEGIN
		SELECT DISTINCT es.excel_sheet_id [Id], @repository_path + ef.[file_name] [FileName],
			   es.sheet_name [SheetName],
			   es.[snapshot] [Publish],
			   es.maintain_history [MaintainHistory],
			   COALESCE(doc.is_template, es.document_type, 106700) [DocumentType],
			   ISNULL(es.show_data_tabs, 0) [ShowDataTabs]
		FROM   excel_file ef
			   INNER JOIN excel_sheet es
					ON  ef.excel_file_id = es.excel_file_id AND es.excel_sheet_id = @sheet_id
					--ON  es.excel_sheet_id = f.item -- Check sheet name has document template or not                 
			   OUTER APPLY (
							   SELECT TOP 1 es.document_type [is_template]
							   FROM   excel_sheet AS es2
							   WHERE  es2.sheet_name = es.sheet_name + '_template'
						   ) doc
		WHERE  dbo.FNAFileExists(@repository_path + ef.[file_name]) = 1 AND es.[snapshot] = 1 
	END
	ELSE IF @flag = 'c'
	BEGIN
		SELECT cs.document_path + '\Excel_Reports\', cs.document_path + '\temp_note\'
		, dbo.FNADecrypt(server_side_excel_key) [LicenseKey]
	FROM   connection_string cs
	END
	ELSE IF @flag = 'p'
	BEGIN
		SELECT  ef.[file_name] [FileName], es.sheet_name [SheetName], es.[snapshot] [Publish] , es.maintain_history [MaintainHistory] FROM excel_sheet es
		INNER JOIN excel_file ef ON es.excel_file_id = ef.excel_file_id
		WHERE ef.[file_name] = @filename
		AND es.[snapshot] = 1 
	END
	ELSE IF @flag = 'h'
	BEGIN
		DECLARE @snapshot_sheet_id INT 
		--	Insert new snapshot history	
		INSERT INTO excel_sheet_snapshot(excel_sheet_id, snapshot_filename, snapshot_applied_filter, snapshot_refreshed_on, process_id)
		SELECT @sheet_id, @snapshot_filename, @applied_filter, @refreshed_on, @process_id
		
	END
	-- List parameter that will be used while overriding 
	-- Part of xml is generated from view report batch
	ELSE IF @flag = 'o'
	BEGIN
	    SELECT DISTINCT COALESCE(bt.ParameterName, esp.name) [ParameterName],
			   esp.label [Label],
			   ISNULL(COALESCE(bt.OverrideType, esp.override_type), 0) [OverrideType],
			   ISNULL(COALESCE(bt.NoOfDays, esp.no_days), 0) [NoOfDays]
		FROM   excel_sheet_parameter esp
			   INNER JOIN excel_file ef
					ON  esp.excel_file_id = ef.excel_file_id
			   OUTER APPLY (
					SELECT x.Rec.query('./ParameterName').value('.', 'nvarchar(2000)') AS ParameterName,
						   x.Rec.query('./ScheduleType').value('.', 'nvarchar(2000)') AS OverrideType,
						   x.Rec.query('./Days').value('.', 'int') AS NoOfDays
					FROM   @batch_call_xml.nodes('/ExcelSheet/Parameter') AS x(Rec)
					WHERE  x.Rec.query('./ParameterName').value('.', 'nvarchar(2000)') = esp.name
		) bt
		WHERE  ef.[file_name] = @filename
	END
	ELSE IF @flag = 'x'
	BEGIN
		IF OBJECT_ID('tempdb..#excel_sheet_parameters') IS NOT NULL
			DROP TABLE tempdb..#excel_sheet_parameters
		CREATE TABLE #excel_sheet_parameters ([name] NVARCHAR(500) COLLATE DATABASE_DEFAULT,[label] NVARCHAR(500) COLLATE DATABASE_DEFAULT,data_type INT,[values] VARCHAR(1024) COLLATE DATABASE_DEFAULT,optional BIT,override_type INT,no_days INT,excel_sheet_parameter_id INT,sequence INT)
		INSERT INTO #excel_sheet_parameters	
		EXEC spa_excel_addin_report_manager @flag='p',@mode='u', @filename= @filename
		SELECT [name] [Name], label [Label] FROM #excel_sheet_parameters
	END
	-- Retrive user signature
	ELSE IF @flag = 'y'
	BEGIN
		SELECT REPLACE(an.notes_attachment, '/', '\') [user_signature_filename]
		FROM   application_notes an
			   INNER JOIN application_users au
					ON  au.application_users_id = an.notes_object_id
		WHERE  an.internal_type_value_id = 10000132
			   AND an.user_category = -43000
			   AND au.user_login_id = @user_name
	END
	-- Get paramset id / tablix id of report
	ELSE IF @flag = 'z'
	BEGIN
		SELECT 
			rp.report_paramset_id [ParamsetId],
			rpt.report_page_tablix_id [TablixId]
		FROM   report_paramset rp
			INNER JOIN report_page_tablix rpt
				ON  rpt.page_id = rp.page_id
			WHERE rp.paramset_hash= @paramset_hash
	END
END
