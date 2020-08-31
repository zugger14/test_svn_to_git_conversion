

IF OBJECT_ID(N'[dbo].[spa_rfx_report]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_rfx_report]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- owner: padhikari@pioneersolutionsglobal.com
-- Create date: 2012-08-15
-- Description: Add/Update Operations for Reports
 
-- Params:
-- @flag				CHAR(1) - Operation flag
-- @process_id			VARCHAR - Operation ID
-- @report_id			INT		- Report ID 
-- @category_id			INT		- Report Category ID
-- @report_name			VARCHAR - Report Name
-- @report_owner		VARCHAR - Report owner
-- @report_desc			VARCHAR - Report Description

-- Sample Use :: EXEC spa_rfx_report 'i', 'E35252A5_992D_44C2_B240_848D3149AA68', NULL, NULL , 'First Report', 'farrms_admin','First Report'
-- Sample Use :: EXEC spa_rfx_report 'u', 'E35252A5_992D_44C2_B240_848D3149AA68', 1, NULL , 'First Report1', 'farrms_admin','First Report1'
-- Sample Use :: EXEC spa_rfx_report 'a', 'E35252A5_992D_44C2_B240_848D3149AA68', 1
-- Sample Use :: EXEC spa_rfx_report 's', 'E35252A5_992D_44C2_B240_848D3149AA68', NULL
-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_rfx_report]
	@flag CHAR(1),
	@process_id VARCHAR(100),
	@report_id VARCHAR(500) = NULL,
	@category_id INT = NULL,
	@report_name VARCHAR(300) = NULL,
	@report_owner VARCHAR(50) = NULL,
	@report_desc VARCHAR(100) = NULL,
	@system_report CHAR(1)= '0',
	@retain_privilege int = 0
AS
SET NOCOUNT ON
set @retain_privilege = isnull(@retain_privilege,0)
IF @process_id IS NULL
    SET @process_id = dbo.FNAGetNewID()

DECLARE @user_name  VARCHAR(50)   
DECLARE @sql        VARCHAR(8000)
DECLARE @rfx_report VARCHAR(200)
DECLARE @is_owner INT

SET @user_name = dbo.FNADBUser()

--Resolve Process Table Name
SET @rfx_report  = dbo.FNAProcessTableName('report', @user_name, @process_id)

-- Add New Report
IF @flag = 'i'
BEGIN
	CREATE TABLE #temp_exist ([name] TINYINT)
	SET @sql =  'INSERT INTO #temp_exist ([name]) SELECT TOP(1) 1 FROM report  WHERE name = ''' + @report_name + ''''
	--PRINT(@sql)
	EXEC(@sql)
	IF EXISTS (SELECT 1 FROM #temp_exist)
	BEGIN
		EXEC spa_ErrorHandler -1,
				 'Reporting FX',
				 'spa_rfx_report_paramset',
				 'DB Error',
				 'Report name already exists.',
				 ''
		RETURN
	END
    SET @sql = 'INSERT INTO ' + @rfx_report + '
                  (
                    [name],
                    owner,
                    category_id,
                    [description],
                    is_system
                  )
                VALUES
                  (
                    ''' + @report_name + ''',
                    ''' + ISNULL(@report_owner, @user_name) + ''',
                    ' + ISNULL(CAST(@category_id AS VARCHAR(10)), 'NULL') + ',
                    ''' + ISNULL(@report_desc, @report_name) + ''',
                     ''' + (@system_report ) + '''
                    
                  )
				'
	--PRINT @sql				
    EXEC (@sql)
    
    DECLARE @report_id_new INT
    SET @report_id_new = IDENT_CURRENT(@rfx_report)
    EXEC spa_print @report_id_new
    
	IF @@ERROR <> 0
	    EXEC spa_ErrorHandler @@ERROR,
	         'New Reporting FX',
	         'spa_rfx_report',
	         'DB Error',
	         'Fail to insert data.',
	         ''
	ELSE
	    EXEC spa_ErrorHandler 0,
	         'New Reporting FX',
	         'spa_rfx_report',
	         'Success',
	         'Data successfully inserted.',
	         @report_id_new    
END

-- Edit Existing Report
IF @flag = 'u'
BEGIN
	CREATE TABLE #temp_exist_u ([name] TINYINT)
	SET @sql =  'INSERT INTO #temp_exist_u ([name]) SELECT TOP(1) 1 FROM report WHERE report_id <>' + CAST(@report_id AS VARCHAR(10)) + ' AND name = ''' + @report_name + ''''
	exec spa_print @sql
	EXEC(@sql)
	IF EXISTS (SELECT 1 FROM #temp_exist_u)
	BEGIN
		EXEC spa_ErrorHandler -1,
				 'Reporting FX',
				 'spa_rfx_report',
				 'DB Error',
				 'Report name already exists.',
				 ''
		RETURN
	END
    SET @sql = '  UPDATE ' + @rfx_report + '
					SET [name] = ''' + @report_name + ''',
						owner = ''' + ISNULL(@report_owner, @user_name) + ''',
						category_id = ' + ISNULL(CAST(@category_id AS VARCHAR(10)), 'NULL') + ',
						[description] = ''' + ISNULL(@report_desc, @report_name) + ''',
						[is_system] = ''' + (@system_report) + '''
					WHERE report_id = ' + CAST(@report_id AS VARCHAR(10)) + '                  
				'
	--PRINT @sql				
    EXEC (@sql)
    
	IF @@ERROR <> 0
	    EXEC spa_ErrorHandler @@ERROR,
	         'New Reporting FX',
	         'spa_rfx_report',
	         'DB Error',
	         'Fail to update data.',
	         ''
	ELSE
	    EXEC spa_ErrorHandler 0,
	         'New Reporting FX',
	         'spa_rfx_report',
	         'Success',
	         'Data successfully updated.',
	         @process_id    
END

-- Get Existing Reports
IF @flag = 's' 
BEGIN
    SET @sql = '  SELECT  r.report_id [Report ID],
                         r.name [Name],
                         r.owner [Owner],
                         r.category_id [Category ID],
                         r.[description] [Description],
                         r.[is_system] [System Report]
                  FROM   ' + @rfx_report + ' r
				'
	--PRINT @sql				
    EXEC (@sql)
END

-- Get Existing Report
IF @flag = 'a'
BEGIN
    SET @sql = '  SELECT r.report_id [Report ID],
                         r.name [Name],
                         r.owner [Owner],
                         r.category_id [Category ID],
                         r.[description] [Description],
                         r.is_system [System Report]
                  FROM   ' + @rfx_report + ' r
                  WHERE  r.report_id = ' + CAST(@report_id AS VARCHAR(10)) + '
				'
	--PRINT @sql				
    EXEC (@sql)
END

IF @flag = 'd'
BEGIN
	BEGIN TRY
	--prevent parent reports of dependent report from being deleted.
		DECLARE @report_names VARCHAR(2000)
		DECLARE @validation_msg VARCHAR(2000)

		IF OBJECT_ID('tempdb..#export_table_names') IS NOT NULL
		DROP TABLE #export_table_names

		IF OBJECT_ID('tempdb..#dependent_reports') IS NOT NULL
		DROP TABLE #dependent_reports

		CREATE TABLE #export_table_names (export_table_name VARCHAR(2000) COLLATE DATABASE_DEFAULT )
		INSERT INTO #export_table_names
		SELECT  rpt.export_table_name 
		FROM report r 
		INNER JOIN report_page rpage ON rpage.report_id = r.report_id
		INNER JOIN report_page_tablix rpt ON rpt.page_id = rpage.report_page_id
		INNER JOIN dbo.SplitCommaSeperatedValues(@report_id) scsv ON scsv.item = r.report_id

		CREATE TABLE #dependent_reports (report_id INT, report_name VARCHAR(1000) COLLATE DATABASE_DEFAULT )
		INSERT INTO #dependent_reports
		SELECT  distinct rd.report_id, r.[name] FROM #export_table_names etn
		INNER JOIN data_source ds ON REPLACE(REPLACE(ds.name, '[adiha_process].[dbo].[report_export_', ''), ']', '') = etn.export_table_name
		INNER JOIN report_dataset rd ON rd.source_id = ds.data_source_id 
		INNER JOIN report r ON r.report_id = rd.report_id

		SELECT @report_names = STUFF((
								SELECT ',' + report_name FROM #dependent_reports
									FOR XML PATH(''), TYPE).value('.[1]', 'VARCHAR(5000)'), 1, 1, '')
									
		SET  @validation_msg = 'Report cannot be deleted. Report(s) dependent on it :' + @report_names 					


		IF EXISTS(SELECT  1 FROM #dependent_reports)
		BEGIN
			EXEC spa_ErrorHandler -1, 'Reporting FX', 'spa_rfx_report', 'DB Error', @validation_msg, ''
			RETURN
		END
		
	BEGIN TRAN
	
		IF OBJECT_ID('tempdb..#del_report_ids') IS NOT NULL
		DROP TABLE #del_report_ids

		SELECT item report_id INTO #del_report_ids
		FROM   dbo.SplitCommaSeperatedValues(@report_id)

		IF OBJECT_ID('tempdb..#deleted_report_page') IS NOT NULL
		DROP TABLE #deleted_report_page

		IF OBJECT_ID('tempdb..#del_report_dataset') IS NOT NULL
		DROP TABLE #del_report_dataset		

		IF OBJECT_ID('tempdb..#del_report_dataset_paramset') IS NOT NULL
		DROP TABLE #del_report_dataset_paramset		

		IF OBJECT_ID('tempdb..#del_report_tablix_column') IS NOT NULL
		DROP TABLE #del_report_tablix_column

		IF OBJECT_ID('tempdb..#del_report_page_chart') IS NOT NULL
		DROP TABLE #del_report_page_chart			

		IF OBJECT_ID('tempdb..#deleted_report_paramset') IS NOT NULL
		DROP TABLE #deleted_report_paramset
		
		/********************Delete reports from My Reports*************************/
		
		DELETE mr 
		FROM 
		#del_report_ids r
		INNER JOIN report_page rpp
			ON rpp.report_id = r.report_id
		INNER JOIN report_paramset rp 
			ON  rp.page_id = rpp.report_page_id
		INNER JOIN my_report mr 
			ON mr.paramset_hash = rp.paramset_hash
			
		/********************Delete reports from My Reports END*************************/

		SELECT rp.report_page_id,
			   rp.[name] 
		INTO #deleted_report_page
		FROM   report_page rp
		INNER JOIN #del_report_ids dri ON rp.report_id = dri.report_id 

		-- report column link deletion starts

		DELETE rcl 
		FROM report_column_link rcl 
		INNER JOIN #deleted_report_page drp ON drp.report_page_id = rcl.page_id

		-- report column link deletion ends

		-- report tablix deletion part starts

		SELECT rpt.report_page_tablix_id,
			   rpt.[name] 
		INTO #del_report_tablix_column
		FROM   report_page_tablix rpt
		INNER JOIN #deleted_report_page drp ON  drp.report_page_id = rpt.page_id

		DELETE rtc
		FROM   report_tablix_column rtc
		INNER JOIN #del_report_tablix_column drtc ON  drtc.report_page_tablix_id = rtc.tablix_id

		DELETE rpt 
		FROM report_page_tablix rpt 
		INNER JOIN #deleted_report_page drp ON drp.report_page_id = rpt.page_id

		-- report tablix deletion part ends

		-- report chart deletion part starts

		SELECT rpc.report_page_chart_id,rpc.[name] INTO #del_report_page_chart FROM report_page_chart rpc 
		INNER JOIN #deleted_report_page drp ON drp.report_page_id = rpc.page_id

		DELETE rcc 
		FROM report_chart_column rcc 
		INNER JOIN #del_report_page_chart drpc ON drpc.report_page_chart_id = rcc.chart_id

		DELETE rpc 
		FROM report_page_chart rpc	
		INNER JOIN #deleted_report_page drp ON drp.report_page_id = rpc.page_id

		-- report chart deletion part ends
		
		-- report paramset deletion part starts

		SELECT rp.report_paramset_id,rp.[name], rp.paramset_hash INTO #deleted_report_paramset
		FROM report_paramset rp 
		INNER JOIN #deleted_report_page drp ON drp.report_page_id = rp.page_id
					
		SELECT rdp.report_dataset_paramset_id INTO #del_report_dataset_paramset FROM report_dataset_paramset rdp 
		INNER JOIN #deleted_report_paramset drp ON drp.report_paramset_id = rdp.paramset_id

		DELETE rp 
		FROM report_param rp 
		INNER JOIN #del_report_dataset_paramset drdp ON drdp.report_dataset_paramset_id = rp.dataset_paramset_id

		DELETE rdp 
		FROM report_dataset_paramset rdp 
		INNER JOIN #deleted_report_paramset drp ON drp.report_paramset_id = rdp.paramset_id
				 
		DELETE rp 
		FROM report_paramset rp 
		INNER JOIN #deleted_report_page drp ON drp.report_page_id = rp.page_id	

		-- report paramset deletion part ends

		DELETE rp
		FROM   report_page rp
		INNER JOIN #del_report_ids dri ON rp.report_id = dri.report_id


		-- report dataset deletion part starts

		SELECT rd.report_dataset_id,
			   rd.alias ,
			   rd.source_id
		INTO #del_report_dataset
		FROM   report_dataset rd
		INNER JOIN #del_report_ids dri ON rd.report_id = dri.report_id

		DELETE rdr 
		FROM report_dataset_relationship rdr 
		INNER JOIN #del_report_dataset drd ON drd.report_dataset_id = rdr.dataset_id

		DELETE rd
		FROM   report_dataset rd
		INNER JOIN #del_report_ids dri ON rd.report_id = dri.report_id
		-- report dataset deletion part ends
		
		--do not delete privilege data/apply filter data when @retain_privilege=1 (thats from report export call)
		if @retain_privilege <> 1
		begin
			-- delete from report_privilege
			DELETE rp
			FROM report_privilege rp
			INNER JOIN report r ON r.report_hash = rp.report_hash
			INNER JOIN #del_report_ids dri ON dri.report_id = r.report_id
		
			-- delete from report_paramset_privilege
			DELETE rpp
			FROM report_paramset_privilege rpp
			INNER JOIN #deleted_report_paramset drp ON drp.paramset_hash = rpp.paramset_hash	
			
			/**
			Delete from application_ui_filter and details
			**/
			delete d
			from application_ui_filter_details d 
			inner join application_ui_filter h on h.application_ui_filter_id = d.application_ui_filter_id
			INNER JOIN #deleted_report_paramset drp ON drp.report_paramset_id = h.report_id
			where h.application_function_id is null
		
			delete a 
			from application_ui_filter a 
			INNER JOIN #deleted_report_paramset drp ON drp.report_paramset_id = a.report_id
			where a.application_function_id is null
		end
		
		

		DELETE r
		FROM   report r
		INNER JOIN #del_report_ids dri ON r.report_id = dri.report_id
		
		DELETE dsc
		FROM data_source_column dsc 
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id
		INNER JOIN #del_report_dataset drd ON drd.source_id = ds.data_source_id
		WHERE ds.[type_id] = 2
		
		DELETE ds
		FROM data_source ds
		INNER JOIN #del_report_dataset drd ON drd.source_id = ds.data_source_id
		WHERE ds.[type_id] = 2
		
		declare @deleted_paramset_ids varchar(500)
		SELECT @deleted_paramset_ids = COALESCE(@deleted_paramset_ids + ',', '') + cast(drp.report_paramset_id AS VARCHAR) + '|' + drp.paramset_hash FROM #deleted_report_paramset drp
		
		--drop conflicted temp tables with report export script
		IF OBJECT_ID('tempdb..#deleted_report_page') IS NOT NULL
		DROP TABLE #deleted_report_page
		IF OBJECT_ID('tempdb..#deleted_report_paramset') IS NOT NULL
		DROP TABLE #deleted_report_paramset
	 
		COMMIT TRAN
	
	 
		EXEC spa_ErrorHandler 0
			, 'report'
			, 'spa_rfx_report'
			, 'Success'
			, 'Data successfully deleted.'
			, @deleted_paramset_ids
	END TRY
	BEGIN CATCH
		DECLARE @DESC VARCHAR(500)
		DECLARE @err_no INT
	 
		IF @@TRANCOUNT > 0
		   ROLLBACK
	 
		IF ERROR_MESSAGE() = 'CatchError'
		   SET @DESC = '(Error Description:' + @DESC + ').'
		ELSE
		   SET @DESC = '(Error Description:' + ERROR_MESSAGE() + ').'

		SET @DESC = 'Report deletion failed ' + @DESC
		SELECT @err_no = ERROR_NUMBER()
		
		IF @retain_privilege = 1 --call from export
		BEGIN
			RAISERROR(@DESC,16,1)
		END
		ELSE
		BEGIN
			EXEC spa_ErrorHandler @err_no
		   , 'report'
		   , 'spa_rfx_report'
		   , 'Error'
		   , @DESC
		   , ''
		END
		
	END CATCH
END
