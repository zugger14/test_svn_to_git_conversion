

IF OBJECT_ID(N'[dbo].[spa_rfx_save]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_rfx_save]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: padhikari@pioneersolutionsglobal.com
-- Create date: 2012-08-16
-- Description: Save operations for New reporting Form
 
-- Params:
-- @process_id CHAR(1) - Operation ID

-- Sample Use :: EXEC [spa_rfx_save] '06205D01_C778_4D98_96A0_AF2FB281DFA4'
-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_rfx_save]
	@process_id VARCHAR(50)
AS

DECLARE @user_name                        VARCHAR(50)   
DECLARE @rfx_report                       VARCHAR(200)
DECLARE @rfx_report_page                  VARCHAR(200)
DECLARE @rfx_report_page_chart            VARCHAR(200)
DECLARE @rfx_report_chart_column          VARCHAR(200)
DECLARE @rfx_report_page_tablix           VARCHAR(200)
DECLARE @rfx_report_tablix_column         VARCHAR(200)
DECLARE @rfx_report_tablix_header         VARCHAR(200)
DECLARE @rfx_report_column_link           VARCHAR(200)
DECLARE @rfx_report_paramset              VARCHAR(200)
DECLARE @rfx_report_dataset_paramset	  VARCHAR(200)
DECLARE @rfx_report_param                 VARCHAR(200)
DECLARE @rfx_report_dataset               VARCHAR(200)
DECLARE @rfx_report_dataset_relationship  VARCHAR(200)
DECLARE @rfx_report_page_textbox		  VARCHAR(200)
DECLARE @rfx_report_page_image		      VARCHAR(200)
DECLARE @rfx_report_page_line		      VARCHAR(200)

DECLARE @rfx_report_page_gauge            VARCHAR(200)
DECLARE @rfx_report_gauge_column          VARCHAR(200)
DECLARE @rfx_report_gauge_column_scale    VARCHAR(200)

DECLARE @sql                              VARCHAR(8000)
DECLARE @report_hash                      VARCHAR(50)
DECLARE @report_name                      VARCHAR(300)
DECLARE @old_report_id                    INT
DECLARE @new_report_id                    INT
DECLARE @report_paramset_id               INT
DECLARE @edit_mode						  BIT
DECLARE @rfx_report_dataset_deleted       VARCHAR(200)

--DECLARE @report_id_report_paramset_id	  VARCHAR(20)

SET @user_name = dbo.FNADBUser()
SET @rfx_report							= dbo.FNAProcessTableName('report', @user_name, @process_id)
SET @rfx_report_dataset					= dbo.FNAProcessTableName('report_dataset', @user_name, @process_id)
SET @rfx_report_dataset_relationship	= dbo.FNAProcessTableName('report_dataset_relationship', @user_name, @process_id)
SET @rfx_report_page					= dbo.FNAProcessTableName('report_page', @user_name, @process_id)
SET @rfx_report_paramset				= dbo.FNAProcessTableName('report_paramset', @user_name, @process_id)
SET @rfx_report_dataset_paramset		= dbo.FNAProcessTableName('report_dataset_paramset', @user_name, @process_id)
SET @rfx_report_param					= dbo.FNAProcessTableName('report_param', @user_name, @process_id)
SET @rfx_report_page_tablix				= dbo.FNAProcessTableName('report_page_tablix', @user_name, @process_id)
SET @rfx_report_tablix_column			= dbo.FNAProcessTableName('report_tablix_column', @user_name, @process_id)
SET @rfx_report_tablix_header			= dbo.FNAProcessTableName('report_tablix_header', @user_name, @process_id)
SET @rfx_report_column_link				= dbo.FNAProcessTableName('report_column_link', @user_name, @process_id)
SET @rfx_report_page_chart				= dbo.FNAProcessTableName('report_page_chart', @user_name, @process_id)
SET @rfx_report_chart_column			= dbo.FNAProcessTableName('report_chart_column', @user_name, @process_id) 
SET @rfx_report_page_textbox			= dbo.FNAProcessTableName('report_page_textbox', @user_name, @process_id)
SET @rfx_report_page_image				= dbo.FNAProcessTableName('report_page_image', @user_name, @process_id)
SET @rfx_report_page_line				= dbo.FNAProcessTableName('report_page_line', @user_name, @process_id)

SET @rfx_report_page_gauge				= dbo.FNAProcessTableName('report_page_gauge', @user_name, @process_id)
SET @rfx_report_gauge_column			= dbo.FNAProcessTableName('report_gauge_column', @user_name, @process_id)
SET @rfx_report_gauge_column_scale		= dbo.FNAProcessTableName('report_gauge_column_scale', @user_name, @process_id)
SET @rfx_report_dataset_deleted      = dbo.FNAProcessTableName('rfx_report_dataset_deleted', @user_name, @process_id)

BEGIN TRY
	BEGIN TRAN
	
	/*************************************************************************
	* DB Tables Hierarchy From Root To Leaf
	1. report
	2. report_dataset
	3. report_dataset_relationship
	5. report_page
	6. report_paramset
	7. report_dataset_paramset
	8. report_param	
	9. report_page_tablix
	10. report_tablix_column
	11. report_tablix_column
	12. report_column_link
	13. report_page_chart
	14. report_chart_column			   
	*************************************************************************/
	
	
	/*************************************************************************
	* START :: Deleting Existing Report Data From Data Tables
	*************************************************************************/

	-- Create temp table to store the report_name and report_hash
	IF OBJECT_ID('tempdb..#rfx_report') IS NOT NULL
		DROP TABLE #rfx_report

	-- Start :: Get Report Name
	CREATE TABLE #rfx_report (report_name VARCHAR(200) COLLATE DATABASE_DEFAULT , report_hash VARCHAR(50) COLLATE DATABASE_DEFAULT )
	EXEC('INSERT INTO #rfx_report(report_name,report_hash)
			SELECT [name], report_hash FROM ' + @rfx_report + '')
	SELECT @report_name = report_name, @report_hash = report_hash FROM #rfx_report
	-- End

	-- Start :: Get Deletion Keys for report
	SELECT @old_report_id = report_id FROM report WHERE report_hash = @report_hash
	EXEC spa_print 'Report to delete:', @old_report_id
	-- End

	IF OBJECT_ID('tempdb..#del_report_page') IS NOT NULL
		DROP TABLE #del_report_page

	IF OBJECT_ID('tempdb..#del_report_paramset') IS NOT NULL
		DROP TABLE #del_report_paramset
		
	IF OBJECT_ID('tempdb..#create_user_hash') IS NOT NULL
		DROP TABLE #create_user_hash
	CREATE TABLE #create_user_hash ([create_user] VARCHAR(50) COLLATE DATABASE_DEFAULT , [hash_code] VARCHAR(50) COLLATE DATABASE_DEFAULT )
		
	--find out the mode (insert or update). Only newly inserted reports will be added in My Reports tab.
	IF EXISTS (SELECT 1 FROM report WHERE report_hash = @report_hash)
		SET @edit_mode = 1
	ELSE
		SET @edit_mode = 0	
		
	--grab report_page_id and report_paramset_id to delete
	SELECT rp.report_page_id, rp.[name] INTO #del_report_page FROM report_page rp WHERE rp.report_id = @old_report_id
	SELECT rp.report_paramset_id,rp.[name] INTO #del_report_paramset FROM report_paramset rp 
	INNER JOIN #del_report_page drp ON drp.report_page_id = rp.page_id
			
	DELETE rdr 
	FROM report_dataset_relationship rdr
	INNER JOIN report_dataset rd ON rd.report_dataset_id = rdr.dataset_id
	WHERE rd.report_id = @old_report_id
		
	DELETE rcl 
	FROM report_column_link rcl 
	INNER JOIN #del_report_page drp ON drp.report_page_id = rcl.page_id

	DELETE rtc 
	FROM report_tablix_column rtc
	INNER JOIN report_page_tablix rpt ON rpt.report_page_tablix_id = rtc.tablix_id
	INNER JOIN #del_report_page drp ON drp.report_page_id = rpt.page_id
	
	DELETE rth 
	FROM report_tablix_header rth
	INNER JOIN report_page_tablix rpt ON rpt.report_page_tablix_id = rth.tablix_id
	INNER JOIN #del_report_page drp ON drp.report_page_id = rpt.page_id	
		
	DELETE rpt 
	FROM report_page_tablix rpt 
	INNER JOIN #del_report_page drp ON drp.report_page_id = rpt.page_id

	DELETE rcc 
	FROM report_chart_column rcc
	INNER JOIN report_page_chart rpc ON rpc.report_page_chart_id = rcc.chart_id
	INNER JOIN #del_report_page drp ON drp.report_page_id = rpc.page_id
		
	DELETE rpc 
	FROM report_page_chart rpc	
	INNER JOIN #del_report_page drp ON drp.report_page_id = rpc.page_id

	DELETE rp 
	FROM report_param rp
	INNER JOIN report_dataset_paramset rdp ON rdp.report_dataset_paramset_id = rp.dataset_paramset_id
	INNER JOIN #del_report_paramset drp ON drp.report_paramset_id = rdp.paramset_id
		
	DELETE rdp 
	FROM report_dataset_paramset rdp 
	INNER JOIN #del_report_paramset drp ON drp.report_paramset_id = rdp.paramset_id
				 
	DELETE rp 
	OUTPUT DELETED.create_user, DELETED.paramset_hash INTO #create_user_hash
	FROM report_paramset rp 
	INNER JOIN #del_report_page drp ON drp.report_page_id = rp.page_id				

	DELETE rptb 
	FROM report_page_textbox rptb 
	INNER JOIN #del_report_page drp ON drp.report_page_id = rptb.page_id	
	
	DELETE rpi 
	FROM report_page_image rpi 
	INNER JOIN #del_report_page drp ON drp.report_page_id = rpi.page_id	
	
	DELETE rpl 
	FROM report_page_line rpl 
	INNER JOIN #del_report_page drp ON drp.report_page_id = rpl.page_id	
	
	DELETE rgcs
	FROM report_gauge_column_scale rgcs
	INNER JOIN report_gauge_column rgc ON rgc.report_gauge_column_id = rgcs.report_gauge_column_id
	INNER JOIN report_page_gauge rpg ON rpg.report_page_gauge_id = rgc.gauge_id
	INNER JOIN #del_report_page drp ON drp.report_page_id = rpg.page_id
	
	DELETE rgc 
	FROM report_gauge_column rgc
	INNER JOIN report_page_gauge rpg ON rpg.report_page_gauge_id = rgc.gauge_id
	INNER JOIN #del_report_page drp ON drp.report_page_id = rpg.page_id
		
	DELETE rpg 
	FROM report_page_gauge rpg	
	INNER JOIN #del_report_page drp ON drp.report_page_id = rpg.page_id
	--DELETE FROM my_report WHERE paramset_hash IN(SELECT [hash_code] FROM #create_user_hash) 
	DELETE FROM report_page WHERE report_id = @old_report_id
	DELETE FROM report_dataset WHERE report_id = @old_report_id

	DELETE FROM report WHERE report_id = @old_report_id		
	
	/******************************************************************/
	DECLARE @dynamic_sql NVARCHAR(500), @return_value INT

	SET @dynamic_sql = 'IF OBJECT_ID(N'''+ @rfx_report_dataset_deleted +''') is not null
						set @return_value = 1 else set @return_value = 0'

	EXEC sp_executesql @dynamic_sql, N'@return_value INT OUTPUT' ,@return_value output

	IF (@return_value = 1)
	BEGIN
		--deleting sql data_source	 
		set @sql = 'DELETE dsc 
					FROM data_source_column dsc
					INNER JOIN data_source ds on ds.data_source_id = dsc.source_id AND ds.type_id = 2
					INNER JOIN ' + @rfx_report_dataset_deleted + ' rfdd on ds.data_source_id = rfdd.source_id'
		exec spa_print @sql
		EXEC(@sql)

		set @sql = 'DELETE ds 
					FROM data_source ds
					INNER JOIN ' + @rfx_report_dataset_deleted + ' rfdd 
					on ds.data_source_id = rfdd.source_id AND ds.type_id = 2 '
		exec spa_print @sql
		EXEC(@sql)
	END
	/******************************************************************/

	/*************************************************************************
	* END :: Deleting Existing Report Data From Data Tables
	*************************************************************************/

	
	/*************************************************************************
	* START :: Inserting Report Data From Process DB To Data Tables
	*************************************************************************/

	IF @report_hash IS NULL	
		SET @report_hash = dbo.FNAGetNewID()

	SET @sql = 'UPDATE ' + @rfx_report + ' SET report_hash = ''' + @report_hash + '''
				UPDATE ' + @rfx_report_page + ' SET report_hash = ''' + @report_hash + ''''
	EXEC(@sql)
	
	IF OBJECT_ID('tempdb..#report_adiha_process') IS NOT NULL
		DROP TABLE #report_adiha_process
	IF OBJECT_ID('tempdb..#report_map') IS NOT NULL
		DROP TABLE #report_map
	IF OBJECT_ID('tempdb..#dataset_map') IS NOT NULL
		DROP TABLE #dataset_map
	IF OBJECT_ID('tempdb..#page_map') IS NOT NULL
		DROP TABLE #page_map
	IF OBJECT_ID('tempdb..#paramset_map') IS NOT NULL
		DROP TABLE #paramset_map
	/*
	* create mapping table to store the values of the adiha_process table and main table.
	* */		
	
	CREATE TABLE #report_adiha_process(report_id INT, [name] VARCHAR(100) COLLATE DATABASE_DEFAULT )
	CREATE TABLE #report_map (report_id_adiha_process INT, report_id_main INT)
	CREATE TABLE #dataset_map (dataset_id_adiha_process INT, dataset_id_main INT, source_id INT, report_id_main INT, alias VARCHAR(100) COLLATE DATABASE_DEFAULT )
	CREATE TABLE #page_map (page_id_adiha_process INT, page_id_main INT, report_id_main INT, name VARCHAR(100) COLLATE DATABASE_DEFAULT )
	CREATE TABLE #paramset_map (paramset_id_adiha_process INT, paramset_id_main INT, page_id_main INT, name VARCHAR(100) COLLATE DATABASE_DEFAULT )
	CREATE TABLE #dataset_paramset_map(dataset_paramset_id_adiha_process INT, dataset_paramset_id_main INT, paramset_id_main INT, root_dataset_id_main INT)
	CREATE TABLE #tablix_map(tablix_id_adiha_process INT, tablix_id_main INT, page_id_main INT, name VARCHAR(100) COLLATE DATABASE_DEFAULT ) 
	CREATE TABLE #chart_map(chart_id_adiha_process INT, chart_id_main INT, page_id_main INT, name VARCHAR(100) COLLATE DATABASE_DEFAULT )
	
	CREATE TABLE #gauge_map(gauge_id_adiha_process INT, gauge_id_main INT, page_id_main INT, name VARCHAR(100) COLLATE DATABASE_DEFAULT )
	CREATE TABLE #gauge_column_map(gauge_column_id_adiha_process INT, gauge_column_id_main INT, dataset_id INT, column_id INT)
	
	/* The data of the respective temp table i.e. adhiha_process.dbo.<table_name>_<username>_<process_id> is inserted to the main table.*/
	/******************************Migrating report START****************************************/
	SET @sql = 'INSERT INTO #report_adiha_process(report_id, name) SELECT report_id, [name] FROM  ' + @rfx_report + ''
	EXEC spa_print @sql
	EXEC(@sql)
	
	DECLARE @report_id_adiha_process INT
	DECLARE @data_source_hash VARCHAR
	SELECT @report_id_adiha_process = report_id FROM #report_adiha_process
	EXEC spa_print 'Old process table report_id: ', @report_id_adiha_process
	
	SET @sql = 'INSERT INTO report([name], [owner], is_system, report_hash, [description], category_id)	
				OUTPUT ' + CAST(@report_id_adiha_process AS VARCHAR(10)) + ', INSERTED.report_id INTO #report_map
				SELECT [name], [owner], is_system, [report_hash], [description], category_id
				FROM  ' + @rfx_report + ''
	EXEC spa_print @sql
	EXEC(@sql)

	SELECT @new_report_id = report_id_main FROM #report_map
	/******************************Migrating report END ******************************************/	
		
	
	/******************************Migrating report_dataset START*********************************/
	--migrate report_dataset and build map table of same table between adiha_process and main table. Resolve root_dataset_id later in main table.
	SET @sql = 'INSERT INTO report_dataset(source_id, report_id, alias)	
				OUTPUT INSERTED.report_dataset_id, INSERTED.source_id, INSERTED.report_id, INSERTED.alias 
				INTO #dataset_map (dataset_id_main, source_id, report_id_main, alias)
				SELECT source_id, ' + CAST(@new_report_id AS VARCHAR) + ', alias
				FROM  ' + @rfx_report_dataset + ''
	EXEC spa_print @sql
	EXEC(@sql)
	
	--update SQL datasource to map with the report correctly
	UPDATE data_source
	SET report_id = dm.report_id_main
	FROM data_source ds
	INNER JOIN #dataset_map dm ON dm.source_id = ds.data_source_id
	WHERE ds.type_id = 2
	
	--update dataset_id_adiha_process in mapping table
	SET @sql = 'UPDATE #dataset_map
				SET dataset_id_adiha_process = rrd.report_dataset_id
	            FROM #dataset_map dm
	            INNER JOIN #report_map rm ON rm.report_id_main = dm.report_id_main
	            INNER JOIN ' + @rfx_report_dataset + ' rrd ON rrd.source_id = dm.source_id 
					AND rrd.report_id = rm.report_id_adiha_process
					AND rrd.alias = dm.alias'
	EXEC spa_print @sql
	EXEC(@sql)

	--update root_dataset_id
	SET @sql = 'UPDATE rd
				SET rd.root_dataset_id = dm_dataset_parent.dataset_id_main
	            FROM ' + @rfx_report_dataset + ' rrd
	            INNER JOIN #dataset_map dm_dataset ON dm_dataset.dataset_id_adiha_process = rrd.report_dataset_id
	            INNER JOIN #dataset_map dm_dataset_parent ON dm_dataset_parent.dataset_id_adiha_process = rrd.root_dataset_id
	            INNER JOIN report_dataset rd ON rd.report_dataset_id = dm_dataset.dataset_id_main
	            WHERE rrd.root_dataset_id IS NOT NULL
	            ' 
	EXEC spa_print @sql
	EXEC(@sql)
	--update is_free_from and relationship_sql
	SET @sql = 'UPDATE rd
				SET rd.is_free_from = rrd.is_free_from, rd.relationship_sql = rrd.relationship_sql			
				FROM ' + @rfx_report_dataset + ' rrd
				INNER JOIN #dataset_map dm_dataset ON dm_dataset.dataset_id_adiha_process = rrd.report_dataset_id 
				INNER JOIN ' + @rfx_report_dataset + ' rds_child ON rds_child.root_dataset_id = rrd.report_dataset_id
				INNER JOIN report_dataset rd ON rd.report_dataset_id = dm_dataset.dataset_id_main'
	EXEC spa_print @sql
	EXEC(@sql)			
	/******************************Migrating report_dataset END*********************************/
		
	
	/******************************Migrating report_dataset_relationship START*********************************/
	--migrate report_dataset_relationship
	SET @sql = 'INSERT INTO report_dataset_relationship([dataset_id], [from_dataset_id], [to_dataset_id], [from_column_id], [to_column_id], join_type)			
				SELECT dm.dataset_id_main, dm_from.dataset_id_main, dm_to.dataset_id_main, rds.from_column_id, rds.to_column_id, rds.join_type  
				FROM ' + @rfx_report_dataset_relationship + ' rds
				INNER JOIN #dataset_map dm ON dm.dataset_id_adiha_process = rds.dataset_id
				INNER JOIN #dataset_map dm_from ON dm_from.dataset_id_adiha_process = rds.from_dataset_id
				INNER JOIN #dataset_map dm_to ON dm_to.dataset_id_adiha_process = rds.to_dataset_id
				'
	EXEC spa_print @sql
	EXEC(@sql)
	/******************************Migrating report_dataset_relationship END *********************************/	
		
			
	/******************************Migrating report_page START***************************************/
	--migrate report_page and build map table of same table between adiha_process and main table.				
	SET @sql = 'INSERT INTO report_page(report_id, [name], report_hash, width, height)	
				OUTPUT INSERTED.report_page_id, INSERTED.report_id, INSERTED.name 
				INTO #page_map(page_id_main, report_id_main, name)
				SELECT ' + CAST(@new_report_id AS VARCHAR) + ', [name], report_hash, width, height
				FROM  ' + @rfx_report_page + ''				
	EXEC spa_print @sql
	EXEC(@sql)
	
	--update page_id_adiha_process in mapping table
	SET @sql = 'UPDATE #page_map
				SET page_id_adiha_process = rrp.report_page_id
				FROM #page_map pm
				INNER JOIN #report_map rm ON rm.report_id_main = pm.report_id_main
				INNER JOIN ' + @rfx_report_page + ' rrp ON rrp.report_id = rm.report_id_adiha_process
					AND rrp.name = pm.name'
		
	EXEC spa_print @sql
	EXEC(@sql)
		
	--SELECT  * FROM #page_map
	/******************************Migrating report_page END ***************************************/


	/******************************Migrating report_paramset START *********************************/
	--migrate report_paramset and build map table of same table between adiha_process and main table.				
	SET @sql = 'INSERT INTO report_paramset(page_id, [name], paramset_hash, report_status_id, create_user) 
				OUTPUT INSERTED.report_paramset_id, INSERTED.page_id, INSERTED.[name]
				INTO #paramset_map(paramset_id_main, page_id_main, name)
				SELECT pm.page_id_main, rp.[name], rp.paramset_hash, rp.report_status_id, ISNULL(cuh.create_user, dbo.FNADBUser())
				FROM  ' + @rfx_report_paramset + ' rp
				INNER JOIN #page_map pm ON rp.page_id = pm.page_id_adiha_process
				LEFT JOIN #create_user_hash cuh ON cuh.hash_code = rp.paramset_hash'
		
	EXEC spa_print @sql
	EXEC(@sql)
	
	--update page_id_adiha_process in mapping table
	SET @sql = 'UPDATE #paramset_map 
				SET paramset_id_adiha_process = rps.report_paramset_id
				FROM #paramset_map psm
				INNER JOIN #page_map pm on pm.page_id_main = psm.page_id_main
				INNER JOIN ' + @rfx_report_paramset + ' rps ON rps.page_id = pm.page_id_adiha_process
					AND rps.name = psm.name'
		
	EXEC spa_print @sql
	EXEC(@sql)

	--SELECT * FROM #paramset_map
	/******************************Migrating report_paramset END *********************************/
		
	
	/******************************Migrating report_dataset_paramset START *********************************/
	--migrate report_dataset_paramset and build map table of same table between adiha_process and main table.				
	SET @sql = 'INSERT INTO report_dataset_paramset(paramset_id, root_dataset_id, where_part, advance_mode)	
				OUTPUT INSERTED.report_dataset_paramset_id, INSERTED.paramset_id, INSERTED.root_dataset_id
				INTO #dataset_paramset_map(dataset_paramset_id_main, paramset_id_main, root_dataset_id_main)
				SELECT pm.paramset_id_main, dm.dataset_id_main, rdp.where_part, rdp.advance_mode 
				FROM  '+ @rfx_report_dataset_paramset + ' rdp
				INNER JOIN #paramset_map pm ON pm.paramset_id_adiha_process = rdp.paramset_id
				INNER JOIN #dataset_map dm ON dm.dataset_id_adiha_process = rdp.root_dataset_id
				'		
	EXEC spa_print @sql
	EXEC(@sql)
	
	--update dataset_paramset_id_adiha_process in mapping table
	SET @sql = 'UPDATE #dataset_paramset_map 
				SET dataset_paramset_id_adiha_process = rrdp.report_dataset_paramset_id
				FROM #dataset_paramset_map dpm
				INNER JOIN #paramset_map pm ON pm.paramset_id_main = dpm.paramset_id_main
				INNER JOIN #dataset_map dm ON dm.dataset_id_main = dpm.root_dataset_id_main
				INNER JOIN ' + @rfx_report_dataset_paramset + ' rrdp ON rrdp.paramset_id = pm.paramset_id_adiha_process
					AND rrdp.root_dataset_id = dm.dataset_id_adiha_process'
		
	EXEC spa_print @sql
	EXEC(@sql)
	
	--SELECT  * FROM #dataset_paramset_map
	/******************************Migrating report_dataset_paramset END *********************************/
		
	
	/******************************Migrating report_param START ******************************************/
	--migrate report_param
	SET @sql = 'INSERT INTO report_param(dataset_paramset_id, dataset_id, column_id, operator, initial_value, initial_value2, optional, hidden, logical_operator, param_order, param_depth, label)
				SELECT dpm.dataset_paramset_id_main, dm.dataset_id_main, rp.column_id, rp.operator, rp.initial_value, rp.initial_value2, rp.optional, rp.hidden, rp.logical_operator, rp.param_order, rp.param_depth, rp.label
				FROM  ' + @rfx_report_param + ' rp
				INNER JOIN #dataset_map dm ON dm.dataset_id_adiha_process = rp.dataset_id
				INNER JOIN #dataset_paramset_map dpm ON dpm.dataset_paramset_id_adiha_process = rp.dataset_paramset_id
				'
	
	EXEC spa_print @sql
	EXEC(@sql)
	/******************************Migrating report_param END **********************************************/
		
	
	/******************************Migrating report_page_tablix START **************************************/
	--migrate report_page_tablix and build map table of same table between adiha_process and main table.
	--ASSUMPTION: name is unique per page
	SET @sql = 'INSERT INTO report_page_tablix(page_id, root_dataset_id, [name], width, height, [top], [left], group_mode, border_style, page_break, type_id, cross_summary, no_header, export_table_name, is_global)	
				OUTPUT INSERTED.report_page_tablix_id, INSERTED.page_id, INSERTED.name 
				INTO #tablix_map(tablix_id_main, page_id_main, name)
				SELECT pm.page_id_main, dm.dataset_id_main, rrpt.[name], rrpt.width, rrpt.height, rrpt.[top], rrpt.[left], rrpt.group_mode, rrpt.border_style, rrpt.page_break, rrpt.type_id, rrpt.cross_summary, rrpt.no_header, rrpt.export_table_name, rrpt.is_global
				FROM ' + @rfx_report_page_tablix + ' rrpt
				INNER JOIN #page_map pm ON pm.page_id_adiha_process = rrpt.page_id
				INNER JOIN #dataset_map dm ON dm.dataset_id_adiha_process = rrpt.root_dataset_id
				'
	EXEC spa_print @sql
	EXEC(@sql)
	
	--update page_tablix_id_adiha_process in mapping table
	SET @sql = 'UPDATE #tablix_map
	            SET tablix_id_adiha_process = rrpt.report_page_tablix_id
	            FROM #tablix_map tm
	            INNER JOIN #page_map pm ON pm.page_id_main = tm.page_id_main
	            INNER JOIN ' + @rfx_report_page_tablix + ' rrpt ON rrpt.page_id = pm.page_id_adiha_process
					AND rrpt.name = tm.name
				'
	EXEC spa_print @sql
	EXEC(@sql)
	/******************************Migrating report_page_tablix END ***************************************/
		
	
	/******************************Migrating report_page_tablix START **************************************/	
	----update report_tablix_column dataset_id and column_id to NULL where Zero
	SET @sql = 'UPDATE tm
	            SET    dataset_id = NULL, column_id = NULL
	            FROM   ' + @rfx_report_tablix_column + ' tm
	            WHERE  dataset_id = 0 AND column_id = 0 	            
				'
	EXEC spa_print @sql
	EXEC(@sql)
	
	--migrate report_tablix_column
	SET @sql = 'INSERT INTO report_tablix_column(tablix_id, dataset_id, column_id, 
					placement, aggregation, functions, alias, sortable, rounding, thousand_seperation, 
					font, font_size, font_style, text_align, text_color, default_sort_order, default_sort_direction, background, column_order, custom_field, render_as, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation, subtotal)
				SELECT tm.tablix_id_main, dm.dataset_id_main, rrtc.column_id, 
						rrtc.placement, rrtc.aggregation, rrtc.functions, rrtc.alias, rrtc.sortable, rrtc.rounding, rrtc.thousand_seperation,  
						rrtc.font, rrtc.font_size, rrtc.font_style, rrtc.text_align, rrtc.text_color, rrtc.default_sort_order, rrtc.default_sort_direction, rrtc.background, rrtc.column_order, rrtc.custom_field, rrtc.render_as, rrtc.column_template, rrtc.negative_mark, rrtc.currency, rrtc.date_format, rrtc.cross_summary_aggregation, rrtc.mark_for_total, rrtc.sql_aggregation, rrtc.subtotal
				FROM  ' + @rfx_report_tablix_column + ' rrtc
				INNER JOIN #tablix_map tm ON tm.tablix_id_adiha_process = rrtc.tablix_id
				LEFT JOIN #dataset_map dm ON dm.dataset_id_adiha_process = rrtc.dataset_id
				'
	EXEC spa_print @sql
	EXEC(@sql)
		
	--migrate report_tablix_header
	SET @sql = 'INSERT INTO report_tablix_header(tablix_id, column_id, font, font_size, font_style, text_align, text_color, background, report_tablix_column_id )
				SELECT rrtc.tablix_id,
					   rrth.column_id,
					   rrth.font,
					   rrth.font_size,
					   rrth.font_style,
					   rrth.text_align,
					   rrth.text_color,
					   rrth.background,
					   rrtc.report_tablix_column_id
				FROM   ' + @rfx_report_tablix_header + ' rrth
				INNER JOIN #tablix_map tm ON  tm.tablix_id_adiha_process = rrth.tablix_id
				LEFT JOIN report_tablix_column rrtc ON rrtc.tablix_id = tm.tablix_id_main
					AND rrth.column_id = rrtc.column_id
					
				UNION
				
				SELECT rrtc.tablix_id,
					   rrth.column_id,
					   rrth.font,
					   rrth.font_size,
					   rrth.font_style,
					   rrth.text_align,
					   rrth.text_color,
					   rrth.background,
					   rrtc.report_tablix_column_id
				FROM   ' + @rfx_report_tablix_header + ' rrth
				INNER JOIN #tablix_map tm ON  tm.tablix_id_adiha_process = rrth.tablix_id
				LEFT JOIN report_tablix_column rrtc ON rrtc.tablix_id = tm.tablix_id_main
					AND rrth.column_id IS NULL 
					AND rrtc.column_id IS NULL
				'
	EXEC spa_print @sql
	EXEC(@sql)
	
	SET @sql = 'UPDATE h 
				SET h.report_tablix_column_id = c.report_tablix_column_id
				FROM report_tablix_header h
				INNER JOIN ' + @rfx_report_tablix_column + ' c ON c.tablix_id = h.tablix_id
					AND h.column_id = c.column_id
				'
	EXEC(@sql)
	
	SET @sql = 'UPDATE h 
				SET h.report_tablix_column_id = c.report_tablix_column_id
				FROM report_tablix_header h
				INNER JOIN ' + @rfx_report_tablix_column + ' c ON c.tablix_id = h.tablix_id
					AND h.column_id IS NULL
					AND c.column_id IS NULL
				'
	EXEC(@sql)
	
	/******************************Migrating report_page_tablix START **************************************/

	
	--TODO: migrate report_column_link
	/******************************Migrating report_page_chart START **************************************/
	--migrate report_chart_tablix and build map table of same table between adiha_process and main table.
	--ASSUMPTION: name is unique per page
	SET @sql = 'INSERT INTO report_page_chart(page_id, root_dataset_id, [name], type_id, [top], [left], width, height, y_axis_caption, x_axis_caption, page_break, chart_properties)	
				OUTPUT INSERTED.report_page_chart_id, INSERTED.page_id, INSERTED.name 
				INTO #chart_map(chart_id_main, page_id_main, name)
				SELECT pm.page_id_main, dm.dataset_id_main, rrpc.[name], rrpc.type_id, rrpc.[top], rrpc.[left], rrpc.width, rrpc.height, rrpc.y_axis_caption, rrpc.x_axis_caption, rrpc.page_break, rrpc.chart_properties
				FROM ' + @rfx_report_page_chart + ' rrpc
				INNER JOIN #page_map pm ON pm.page_id_adiha_process = rrpc.page_id
				INNER JOIN #dataset_map dm ON dm.dataset_id_adiha_process = rrpc.root_dataset_id
				'
	EXEC spa_print @sql
	EXEC(@sql)
	
	--update page_chart_id_adiha_process in mapping table
	SET @sql = 'UPDATE #chart_map
	            SET chart_id_adiha_process = rrpc.report_page_chart_id
	            FROM #chart_map cm
	            INNER JOIN #page_map pm ON pm.page_id_main = cm.page_id_main
	            INNER JOIN ' + @rfx_report_page_chart + ' rrpc ON rrpc.page_id = pm.page_id_adiha_process
					AND rrpc.name = cm.name
				'
	EXEC spa_print @sql
	EXEC(@sql)
	/******************************Migrating report_page_chart END **************************************/
	
	
	
	/******************************Migrating report_chart_column START **************************************/
	--migrate report_chart_column
	SET @sql = 'INSERT INTO report_chart_column(chart_id, dataset_id, column_id, placement, column_order, alias, functions, aggregation, default_sort_order, default_sort_direction, custom_field, render_as_line)
				SELECT cm.chart_id_main, dm.dataset_id_main, rrpc.column_id, rrpc.placement, rrpc.column_order, rrpc.alias, rrpc.functions, rrpc.aggregation, rrpc.default_sort_order, rrpc.default_sort_direction, rrpc.custom_field, rrpc.render_as_line
				FROM  ' + @rfx_report_chart_column + ' rrpc
				INNER JOIN #chart_map cm ON cm.chart_id_adiha_process = rrpc.chart_id
				LEFT JOIN #dataset_map dm ON dm.dataset_id_adiha_process = rrpc.dataset_id
				'
	EXEC spa_print @sql
	EXEC(@sql)
	/******************************Migrating report_chart_column END **************************************/
	
	/******************************Migrating report_page_textbox START **************************************/
	SET @sql = 'INSERT INTO report_page_textbox(page_id, content, font, font_size, font_style , width, height, [top], [left], hash)	
				SELECT pm.page_id_main, rrptb.content, rrptb.font, rrptb.font_size, rrptb.font_style , rrptb.width, rrptb.height, rrptb.[top], rrptb.[left], rrptb.hash 
				FROM ' + @rfx_report_page_textbox + ' rrptb
				INNER JOIN #page_map pm ON pm.page_id_adiha_process = rrptb.page_id
				'
	EXEC spa_print @sql
	EXEC(@sql)
	/******************************Migrating report_page_textbox END **************************************/
	
	/******************************Migrating report_page_image START **************************************/
	SET @sql = 'INSERT INTO report_page_image( page_id, name , filename, width, height, [top], [left] , hash)	
				SELECT pm.page_id_main, rpi.name , rpi.filename, rpi.width, rpi.height, rpi.[top], rpi.[left] , rpi.hash 
				FROM ' + @rfx_report_page_image + ' rpi
				INNER JOIN #page_map pm ON pm.page_id_adiha_process = rpi.page_id
				'
	EXEC spa_print @sql
	EXEC(@sql)
	/******************************Migrating report_page_image END **************************************/
	
	/******************************Migrating report_page_line START **************************************/
	SET @sql = 'INSERT INTO report_page_line( page_id, color, size, style, width, height, [top], [left], hash)	
				SELECT pm.page_id_main, rpl.color, rpl.size, rpl.style, rpl.width, rpl.height, rpl.[top], rpl.[left], rpl.hash 
				FROM ' + @rfx_report_page_line + ' rpl
				INNER JOIN #page_map pm ON pm.page_id_adiha_process = rpl.page_id
				'
	EXEC spa_print @sql
	EXEC(@sql)
	/******************************Migrating report_page_line END **************************************/
	
	
	/******************************Migrating report_page_gauge START **************************************/
	--ASSUMPTION: name is unique per page
	SET @sql = 'INSERT INTO report_page_gauge(page_id, root_dataset_id, [name], type_id, [top], [left], width, height, gauge_label_column_id)	
				OUTPUT INSERTED.report_page_gauge_id, INSERTED.page_id, INSERTED.name 
				INTO #gauge_map(gauge_id_main, page_id_main, name)
				SELECT pm.page_id_main, dm.dataset_id_main, rrpg.[name], rrpg.type_id, rrpg.[top], rrpg.[left], rrpg.width, rrpg.height , rrpg.gauge_label_column_id
				FROM ' + @rfx_report_page_gauge + ' rrpg
				INNER JOIN #page_map pm ON pm.page_id_adiha_process = rrpg.page_id
				INNER JOIN #dataset_map dm ON dm.dataset_id_adiha_process = rrpg.root_dataset_id
				'
	EXEC spa_print @sql
	EXEC(@sql)
	
	--update page_gauge_id_adiha_process in mapping table
	SET @sql = 'UPDATE #gauge_map
	            SET gauge_id_adiha_process = rrpg.report_page_gauge_id
	            FROM #gauge_map gm
	            INNER JOIN #page_map pm ON pm.page_id_main = gm.page_id_main
	            INNER JOIN ' + @rfx_report_page_gauge + ' rrpg ON rrpg.page_id = pm.page_id_adiha_process
					AND rrpg.name = gm.name
				'
	EXEC spa_print @sql
	EXEC(@sql)
	/******************************Migrating report_page_gauge END **************************************/
	
	
	/******************************Migrating report_gauge_column START **************************************/
	--migrate report_gauge_column
	SET @sql = 'INSERT INTO report_gauge_column(gauge_id, dataset_id, column_id, scale_minimum, scale_maximum, scale_interval, column_order, alias, functions, aggregation, font, font_size, font_style, text_color, custom_field, render_as, column_template, currency, rounding, thousand_seperation)
				OUTPUT INSERTED.report_gauge_column_id, INSERTED.dataset_id, INSERTED.column_id 
				INTO #gauge_column_map(gauge_column_id_main, dataset_id, column_id)
				SELECT gm.gauge_id_main, dm.dataset_id_main, rrpg.column_id, rrpg.scale_minimum, rrpg.scale_maximum, rrpg.scale_interval, rrpg.column_order, rrpg.alias, rrpg.functions, rrpg.aggregation, rrpg.font, rrpg.font_size, rrpg.font_style, rrpg.text_color, rrpg.custom_field, rrpg.render_as, rrpg.column_template, rrpg.currency, rrpg.rounding, rrpg.thousand_seperation
				FROM  ' + @rfx_report_gauge_column + ' rrpg
				INNER JOIN #gauge_map gm ON gm.gauge_id_adiha_process = rrpg.gauge_id
				LEFT JOIN #dataset_map dm ON dm.dataset_id_adiha_process = rrpg.dataset_id
				
				INSERT INTO report_gauge_column_scale (report_gauge_column_id, scale_start, scale_end, column_id, scale_range_color, placement)
				SELECT DISTINCT rgc.report_gauge_column_id
					   ,rc.scale_start
					   ,rc.scale_end
					   ,rc.column_id
					   ,rc.scale_range_color							   
					   ,rc.placement							   
				FROM   ' + @rfx_report_gauge_column_scale + ' rc
				INNER JOIN ' + @rfx_report_gauge_column + ' o on o.report_gauge_column_id = rc.report_gauge_column_id
					--AND o.column_id = rc.column_id
				--INNER JOIN #gauge_column_map n ON o.column_id = n.column_id
				LEFT JOIN #gauge_map gm on gm.gauge_id_adiha_process = o.gauge_id
				LEFT JOIN report_gauge_column rgc ON rgc.column_id = o.column_id
					AND rgc.gauge_id = gm.gauge_id_main					
				ORDER BY rc.scale_start, rc.scale_end
				
				'
	EXEC spa_print @sql
	EXEC(@sql)
	
	
		

	/******************************Migrating report_gauge_column END **************************************/
	
	
	/******************************Adding report in My report START **************************************/
	IF @edit_mode = 0
	BEGIN
		DECLARE @report_group_id INT
		DECLARE @column_order INT
		IF NOT EXISTS (SELECT 1 FROM my_report_group mrg WHERE mrg.my_report_group_name = 'Auto My Reports Group' AND mrg.group_owner = dbo.FNADBUser() AND mrg.role_id = 0 AND mrg.report_dashboard_flag = 'r')
		BEGIN
			INSERT INTO my_report_group (my_report_group_name, report_dashboard_flag, role_id, group_owner, group_order)
			VALUES ('Auto My Reports Group', 'r', 0, dbo.FNADBUser(), 1)
			SET @report_group_id = SCOPE_IDENTITY()
			SET @column_order = 1
		END
		ELSE
		BEGIN
			SELECT @report_group_id = mrg.my_report_group_id FROM my_report_group mrg WHERE mrg.my_report_group_name = 'Auto My Reports Group' AND mrg.group_owner = dbo.FNADBUser() AND mrg.role_id = 0 AND mrg.report_dashboard_flag = 'r'
			SELECT @column_order = ISNULL(MAX(mr.column_order), 0) + 1 FROM my_report mr WHERE mr.role_id = 0 AND mr.group_id = @report_group_id
		END
		
		SET @sql = 'INSERT INTO my_report (my_report_name, dashboard_report_flag, paramset_hash, tooltip, my_report_owner, role_id, column_order, group_id)
					SELECT r.[name] + ''_'' + rp.[name] + ''_'' + rps.[name], ''r'', rps.paramset_hash, r.[name] + ''_'' + rp.[name], dbo.FNADBUser(), 0 , ' + CAST(@column_order AS VARCHAR(10)) + ' , ' + CAST(@report_group_id AS VARCHAR(10)) + '
					FROM report_paramset rps
					INNER JOIN report_page rp ON rp.report_page_id = rps.page_id
					INNER JOIN report r ON r.report_id = rp.report_id
					WHERE r.report_hash = ''' + @report_hash + ''''
		EXEC spa_print @sql
		EXEC(@sql)
	END				
	/******************************Adding report in My report END ***************************************/
	
	/*******************************Deleting deleted reports from My Reports*************************************/
	DELETE 
	FROM   my_report
	WHERE  paramset_hash IN (
		SELECT mr.paramset_hash
		FROM   my_report mr
		WHERE  mr.dashboard_report_flag = 'r'
		EXCEPT
		SELECT rp.paramset_hash
		FROM   report_paramset rp
	)
	/*******************************Deleting deleted reports from My Reports END*************************************/

	/**
	retain application filter details
	**/
	--select * from #paramset_map
	update f set f.report_id = pm.paramset_id_main
	--select *
	from application_ui_filter f
	inner join #paramset_map pm on pm.paramset_id_adiha_process = isnull(f.report_id, -1)
	

	delete fd
	--select *
	from application_ui_filter_details fd
	inner join application_ui_filter f on f.application_ui_filter_id = fd.application_ui_filter_id
	inner join #paramset_map pm on pm.paramset_id_main = isnull(f.report_id, -1)
	where abs(fd.report_column_id) not in (
		select distinct rp.column_id
		from report_param rp
		inner join report_dataset_paramset rdp on rdp.report_dataset_paramset_id = rp.dataset_paramset_id
		inner join report_paramset rpm on rpm.report_paramset_id = rdp.paramset_id
		where rpm.report_paramset_id = f.report_id
	)

	/** DELETE FROM REPORT_PARAMSET_PRIVILEGE FOR DELETED PARAMSET **/

	DELETE rpv
	FROM report_paramset_privilege rpv
	LEFT JOIN report_paramset rp ON rp.paramset_hash = rpv.paramset_hash
	INNER JOIN report_page rpg ON rpg.report_page_id = rp.page_id
	WHERE rpg.report_hash = @report_hash AND rp.paramset_hash IS NULL


	EXEC spa_print 'Save Report to DataTables from ProcessDB :: '	
	COMMIT TRAN
	
	EXEC spa_ErrorHandler 0, 'Reporting FX', 'spa_rfx_save', 'Success', 'Saved Report to Data Tables from Process DB.', @new_report_id	
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRAN
		
	EXEC spa_print 'ERROR:' --+ ERROR_MESSAGE()
	SET @sql = ERROR_MESSAGE()
	--EXEC spa_ErrorHandler 1, 'Reporting FX', 'spa_rfx_save', 'DB Error', 'Error on Saving Report to Data Tables from Process DB.', @new_report_id
	EXEC spa_ErrorHandler 1, 'Reporting FX', 'spa_rfx_save', 'DB Error', @sql, @new_report_id
END CATCH

