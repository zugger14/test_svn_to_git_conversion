
IF OBJECT_ID(N'[dbo].[spa_rfx_report_page]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_rfx_report_page]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
/**
	Report page related general operations.
	Parameters
	@flag				: 'i' Insert report page
						  'u' Update report page
						  's' Select all report page information
						  'a' Select report page information for matched report page id
						  'd' Delete report page
						  'g' * Get page and column informations. probably rejected enhancement logic flag since data source column does not have height and width defined. might be unused flag.
						  'r' Get report items information for matched page id
						  'c' Query to validate when page is saved without saving paramset with required parameters
						  'p' Called from [spa_rfx_deploy_rdl_as_job]; 0 = not deployed
						  'q' Called from [spa_rfx_deploy_rdl_as_job]; 1 = deployed
						  'x' Get list of report ids with help of report hash, called from page 'report.manager.dhx.bulk.rdl.maker.open.php'
		
	@process_id			: Operation ID
	@report_page_id		: Report Page ID
	@report_id			: Report ID
	@name				: Report Page Name
	@layout INT			: Predefined layout types					
	@report_hash		: Report Unique HASH Key
	@width				: Width
	@height				: Height	
	@xml				: Report page position information in XML format
	@job_user_name		: Job User Name
	@job_proc_desc  	: Job Process Description
	@job_desc			: Job Description
*/
CREATE PROCEDURE [dbo].[spa_rfx_report_page]
	@flag				CHAR(1),                             
	@process_id			VARCHAR(100) = NULL,                 
	@report_page_id		INT = NULL,		   
	@report_id			INT = NULL,	
	@layout				INT = NULL,				  
	@name				VARCHAR(200) = NULL,	  
	@report_hash		VARCHAR(MAX) = NULL,		   
	@width				VARCHAR(45) = NULL,						   
	@height				VARCHAR(45) = NULL,		
	@xml				TEXT = NULL,
	@job_user_name			VARCHAR(100) = NULL,
	@job_proc_desc  		VARCHAR(5000) = NULL,
	@job_desc				VARCHAR(5000) = NULL
AS
SET NOCOUNT ON
IF @process_id IS NULL
	SET @process_id = dbo.FNAGetNewID()

DECLARE @user_name                      VARCHAR(50)   
DECLARE @sql                            VARCHAR(MAX)
DECLARE @rfx_report                     VARCHAR(200)
DECLARE @rfx_report_page                VARCHAR(200)
DECLARE @rfx_report_paramset            VARCHAR(200)
DECLARE @rfx_report_param               VARCHAR(200)
DECLARE @rfx_report_page_chart          VARCHAR(200)
DECLARE @rfx_report_page_tablix         VARCHAR(200)
DECLARE @rfx_report_page_textbox        VARCHAR(200)
DECLARE @rfx_report_page_image          VARCHAR(200)
DECLARE @rfx_report_chart_column        VARCHAR(200)
DECLARE @rfx_report_tablix_column       VARCHAR(200) 
DECLARE @rfx_report_dataset_paramset    VARCHAR(200)
DECLARE @rfx_report_page_gauge          VARCHAR(200)
DECLARE @rfx_report_gauge_column        VARCHAR(200)
DECLARE @rfx_report_gauge_column_scale  VARCHAR(200)
DECLARE @rfx_data_source_column			VARCHAR(200)
DECLARE @rfx_report_dataset				VARCHAR(200)
DECLARE @rfx_report_page_line			VARCHAR(200)


SET @user_name = dbo.FNADBUser()
--Resolve Process Table Name
SET @rfx_report                  = dbo.FNAProcessTableName('report', @user_name, @process_id)
SET @rfx_report_page             = dbo.FNAProcessTableName('report_page', @user_name, @process_id)
SET @rfx_report_paramset         = dbo.FNAProcessTableName('report_paramset', @user_name, @process_id)
SET @rfx_report_param            = dbo.FNAProcessTableName('report_param', @user_name, @process_id)
SET @rfx_report_page_chart       = dbo.FNAProcessTableName('report_page_chart', @user_name, @process_id)
SET @rfx_report_page_tablix      = dbo.FNAProcessTableName('report_page_tablix', @user_name, @process_id)
SET @rfx_report_page_textbox     = dbo.FNAProcessTableName('report_page_textbox', @user_name, @process_id)
SET @rfx_report_page_image       = dbo.FNAProcessTableName('report_page_image', @user_name, @process_id)
SET @rfx_report_chart_column     = dbo.FNAProcessTableName('report_chart_column', @user_name, @process_id)
SET @rfx_report_tablix_column    = dbo.FNAProcessTableName('report_tablix_column', @user_name, @process_id)
SET @rfx_report_dataset_paramset = dbo.FNAProcessTableName('report_dataset_paramset', @user_name, @process_id)

SET @rfx_report_page_gauge           = dbo.FNAProcessTableName('report_page_gauge', @user_name, @process_id)
SET @rfx_report_gauge_column         = dbo.FNAProcessTableName('report_gauge_column', @user_name, @process_id)
SET @rfx_report_gauge_column_scale   = dbo.FNAProcessTableName('report_gauge_column_scale', @user_name, @process_id)
SET @rfx_report_page_line           = dbo.FNAProcessTableName('report_page_line', @user_name, @process_id)

SET @rfx_data_source_column			= dbo.FNAProcessTableName('data_source_column', @user_name, @process_id)
SET @rfx_report_dataset				= dbo.FNAProcessTableName('report_dataset', @user_name, @process_id)

-- Add Report Page
IF @flag = 'i'
BEGIN
	SET @report_hash = dbo.FNAGetNewID();
	---checking page name---
	IF @name IS NOT NULL
	BEGIN
		CREATE TABLE #rfx_report_name (name_exists TINYINT)
		SET @sql = 'INSERT INTO #rfx_report_name ([name_exists]) SELECT TOP(1) 1 FROM ' + @rfx_report_page + ' WHERE report_id = ' + CAST(@report_id AS VARCHAR(10)) + ' AND name = ''' + @name + ''''
		EXEC spa_print @sql
		EXEC (@sql)
		
		IF EXISTS(SELECT 1 FROM #rfx_report_name) 
		BEGIN
			EXEC spa_ErrorHandler -1, 'New Reporting FX', 'spa_rfx_report_page', 'DB Error', 'Page name already used.', ''
			 RETURN
		END
	END
	
    SET @sql = 'INSERT INTO ' + @rfx_report_page + '
                  (
                    report_id,
                    [name],
                    report_hash,
                    width,
                    height
                  )
                VALUES
                  (
					' + CAST(@report_id AS VARCHAR(10)) + ',
					''' + @name + ''',
					''' + CAST(@report_hash AS VARCHAR(100)) + ''',
					' + @width + ',
					' + @height + '
                  )'
    EXEC (@sql)
    
    
	IF @@ERROR <> 0
	    EXEC spa_ErrorHandler @@ERROR, 'Reporting FX', 'spa_rfx_report_page', 'DB Error', 'Fail to insert data.', ''
	ELSE
		DECLARE @report_page_id_tmp INT
		SET @report_page_id_tmp = IDENT_CURRENT(@rfx_report_page);
		SET @sql = 'INSERT INTO '+@rfx_report_paramset+' ([page_id],[name],paramset_hash, report_status_id) VALUES ('+CAST(@report_page_id_tmp AS VARCHAR(10))+',''Default'', '''+ dbo.FNAGetNewID() +''', 1)'
		
		exec spa_print @sql
		EXEC(@sql)
	    
	    EXEC spa_ErrorHandler 0, 'Reporting FX', 'spa_rfx_report_page', 'Success', 'Data successfully inserted.', @report_page_id_tmp
END

-- Edit Report Page
IF @flag = 'u'
BEGIN
	IF @name IS NOT NULL
	BEGIN
		CREATE TABLE #rfx_report_name_u (name_exists TINYINT)
		SET @sql = 'INSERT INTO #rfx_report_name_u ([name_exists]) SELECT TOP(1) 1 FROM ' + @rfx_report_page + ' WHERE report_page_id <> ' + CAST(@report_page_id AS VARCHAR(10)) + ' AND name = ''' + @name + ''''
		EXEC spa_print @sql
		EXEC (@sql)
		
		IF EXISTS(SELECT 1 FROM #rfx_report_name_u) 
		BEGIN
			EXEC spa_ErrorHandler -1, 'New Reporting FX', 'spa_rfx_report_page', 'DB Error', 'Page name already used.', ''
			RETURN
		END
	END
	SET @sql = 'UPDATE ' + @rfx_report_page + '
				SET report_id = ' + CAST(@report_id AS VARCHAR(10)) + ',
					[name] = ''' + CAST(@name AS VARCHAR(200)) + ''',
					width = ' + CAST(@width AS VARCHAR(10)) + ',
					height = ' + CAST(@height AS VARCHAR(10)) + '
				WHERE report_page_id = ' + CAST(@report_page_id AS VARCHAR(10))
	--PRINT @sql				
    EXEC (@sql)
    --if available update coordinates of report items (this is done only in update mode)
    DECLARE @idoc  INT
	--Create an internal representation of the XML document.
	EXEC sp_xml_preparedocument @idoc OUTPUT,@xml

	-- Create temp table to store the report_name and report_hash
	IF OBJECT_ID('tempdb..#rfx_page_element') IS NOT NULL
		DROP TABLE #rfx_page_element

	-- Execute a SELECT statement that uses the OPENXML rowset provider.
	SELECT ItemID [item_id],
		   ItemType [item_type],
		   TopCR [top_coordinate],
		   LeftCR [left_coordinate],
		   Width [item_width],
		   Height [item_height]
	INTO #rfx_page_element
	FROM   OPENXML(@idoc, '/Root/PSRecordset', 1)
	WITH (
	   ItemID		VARCHAR(20),
	   ItemType		VARCHAR(10),
	   TopCR		VARCHAR(45),
	   LeftCR		VARCHAR(45),
	   Width		VARCHAR(45),
	   Height		VARCHAR(45)
	)

    SET @sql = 'UPDATE rpc
				SET rpc.[top] = s.top_coordinate, rpc.[left] = s.left_coordinate, rpc.[width] = s.item_width, rpc.[height] = s.item_height 
				FROM '+ @rfx_report_page_chart +' rpc
			    INNER JOIN #rfx_page_element s ON rpc.report_page_chart_id = s.item_id AND s.item_type = ''1'''
    EXEC (@sql)
    SET @sql = 'UPDATE rpt
				SET rpt.[top] = s.top_coordinate, rpt.[left] = s.left_coordinate, rpt.[width] = s.item_width, rpt.[height] = s.item_height 
				FROM '+ @rfx_report_page_tablix +' rpt
			    INNER JOIN #rfx_page_element s ON rpt.report_page_tablix_id = s.item_id AND s.item_type = ''2'''
    EXEC (@sql)
    SET @sql = 'UPDATE rptbx
				SET rptbx.[top] = s.top_coordinate, rptbx.[left] = s.left_coordinate, rptbx.[width] = s.item_width, rptbx.[height] = s.item_height 
				FROM '+ @rfx_report_page_textbox +' rptbx
			    INNER JOIN #rfx_page_element s ON rptbx.report_page_textbox_id = s.item_id AND s.item_type = ''3'''
    EXEC (@sql)
    SET @sql = 'UPDATE rpi
				SET rpi.[top] = s.top_coordinate, rpi.[left] = s.left_coordinate, rpi.[width] = s.item_width, rpi.[height] = s.item_height 
				FROM '+ @rfx_report_page_image +' rpi
			    INNER JOIN #rfx_page_element s ON rpi.report_page_image_id = s.item_id AND s.item_type = ''4'''
    EXEC (@sql)
    
    SET @sql = 'UPDATE rpi
				SET rpi.[top] = s.top_coordinate, rpi.[left] = s.left_coordinate, rpi.[width] = s.item_width, rpi.[height] = s.item_height 
				FROM '+ @rfx_report_page_gauge +' rpi
			    INNER JOIN #rfx_page_element s ON rpi.report_page_gauge_id = s.item_id AND s.item_type = ''5'''
    EXEC (@sql)
    
    SET @sql = 'UPDATE rpi
				SET rpi.[top] = s.top_coordinate, rpi.[left] = s.left_coordinate, rpi.[width] = s.item_width, rpi.[height] = s.item_height 
				FROM '+ @rfx_report_page_line +' rpi
			    INNER JOIN #rfx_page_element s ON rpi.report_page_line_id = s.item_id AND s.item_type = ''6'''
    EXEC (@sql)
    
	IF @@ERROR <> 0
	    EXEC spa_ErrorHandler @@ERROR, 'Reporting FX', 'spa_rfx_report_page', 'DB Error', 'Fail to update data.', ''
	ELSE
	    EXEC spa_ErrorHandler 0, 'Reporting FX', 'spa_rfx_report_page', 'Success', 'Data successfully updated.', @process_id    
END

-- Get Report Page
IF @flag = 's'
BEGIN                				
	SET @sql = 'SELECT rp.report_page_id,
					   rp.[name] Name,
					   ''<ul class=ul-inside-grid>''+((
							SELECT ''<li class=grid-list-item-clean>'' + rps2.[name]
							FROM   ' + @rfx_report_paramset + ' rps2
							WHERE  rps2.page_id = rps1.page_id
							ORDER BY rps2.report_paramset_id
							FOR XML PATH(''''), TYPE).value(''.[1]'', ''VARCHAR(5000)''))+''</ul>'' AS Paramsets
				FROM ' + @rfx_report_paramset + ' rps1
				JOIN ' + @rfx_report_page + ' rp ON  (rp.report_page_id = rps1.page_id)
	            GROUP BY rps1.page_id, rp.report_page_id, rp.[name]'
			
	--PRINT @sql 				
    EXEC (@sql)  
END

-- Get Report Page
IF @flag = 'a'
BEGIN
    SET @sql = 'SELECT rp.report_page_id [Report Page ID],
                       r.[name] [Report Name],
                       --rp.report_id,
                       rp.[name] [Page Name],
                       rp.report_hash,
                       rp.width,
                       rp.height
                FROM   ' + @rfx_report_page + ' rp
                INNER JOIN ' + @rfx_report + ' r ON  r.report_id = rp.report_id
                WHERE  rp.report_page_id = ' + CAST(@report_page_id AS VARCHAR(10))
	--PRINT @sql				
    EXEC (@sql)
END

-- Get Report Pages
IF @flag = 'g'
BEGIN
	--DECLARE @rfx_data_source_column VARCHAR(200)
	--SET @rfx_data_source_column = dbo.FNAProcessTableName('data_source_column', @user_name, @process_id)
	SET @sql = 'SELECT rp.report_page_id [report_page_id],
					   rp.name [name],
					   rp.width [report_width],
					   rp.height [report_height],
					   --dsc.placement [column_placement],
					   --dsc.column_order [column_order],
					   dsc.width [column_width],
					   dsc.height [column_height],
					   dsc.alias [column_alias]
				FROM ' + @rfx_data_source_column + ' dsc
				JOIN ' + @rfx_report_page + ' rp ON rp.report_page_id = rdc.Page_id
				JOIN data_source_columns dsc ON dsc.data_source_columns_id = rdc.column_id 
	'
	--PRINT @sql				
    EXEC (@sql)  
END
IF @flag = 'd'
BEGIN
	BEGIN TRY 
		BEGIN TRAN
		SET @sql = 'DELETE rcc
                    FROM ' + @rfx_report_chart_column + ' rcc
                    INNER JOIN ' + @rfx_report_page_chart + ' rpc ON rpc.report_page_chart_id = rcc.chart_id
                    INNER JOIN ' + @rfx_report_page + ' rp ON rp.report_page_id = rpc.page_id
                    WHERE rp.report_page_id = ' + CAST(@report_page_id AS VARCHAR(50)) 
					
		--PRINT @sql
		EXEC(@sql)
		
		SET @sql = 'DELETE FROM ' + @rfx_report_page_chart + ' WHERE page_id = ' + CAST(@report_page_id AS VARCHAR)
		--PRINT @sql
		EXEC(@sql)
		
		SET @sql = 'DELETE rtc
                    FROM ' + @rfx_report_tablix_column + ' rtc
                    INNER JOIN ' + @rfx_report_page_tablix + ' rpt ON rpt.report_page_tablix_id = rtc.tablix_id
                    INNER JOIN ' + @rfx_report_page + ' rp ON rp.report_page_id = rpt.page_id
                    WHERE rp.report_page_id = ' + CAST(@report_page_id AS VARCHAR(50)) 
					
	--	EXEC spa_print @sql
		EXEC(@sql)
		
		SET @sql = 'DELETE FROM ' + @rfx_report_page_tablix + ' WHERE page_id = ' + CAST(@report_page_id AS VARCHAR)
	--	EXEC spa_print @sql
		EXEC(@sql)
		
		SET @sql = 'DELETE rp
					FROM ' + @rfx_report_param + ' rp
					INNER JOIN ' + @rfx_report_dataset_paramset + ' rdp ON rdp.report_dataset_paramset_id = rp.dataset_paramset_id
					INNER JOIN ' + @rfx_report_paramset + ' rp1 ON rp1.report_paramset_id = rdp.paramset_id
					INNER JOIN ' + @rfx_report_page + ' rp2 ON rp2.report_page_id = rp1.page_id
					WHERE rp2.report_page_id = ' + CAST(@report_page_id AS VARCHAR(50))
	--	EXEC spa_print @sql
		EXEC (@sql)
		
		SET @sql = 'DELETE rdp
					FROM ' + @rfx_report_dataset_paramset + ' rdp
					INNER JOIN ' + @rfx_report_paramset + ' rp1 ON rp1.report_paramset_id = rdp.paramset_id
					INNER JOIN ' + @rfx_report_page + ' rp2 ON rp2.report_page_id = rp1.page_id
					WHERE rp2.report_page_id = ' + CAST(@report_page_id AS VARCHAR(50))
	--	EXEC spa_print @sql
		EXEC (@sql)
		
		SET @sql = 'DELETE FROM ' + @rfx_report_paramset + '
					WHERE page_id = ' + CAST(@report_page_id AS VARCHAR(50))
		--PRINT @sql
		EXEC (@sql)			
		
		SET @sql = 'DELETE FROM ' + @rfx_report_page + '
					WHERE report_page_id = ' + CAST(@report_page_id AS VARCHAR(200))
	--	EXEC spa_print @sql
		EXEC (@sql)
		
		EXEC spa_ErrorHandler 0, 'Reporting FX', 'spa_rfx_report_page', 'Success', 'Data succesfully deleted.', @process_id
		
		COMMIT
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		DECLARE @edit_error_desc VARCHAR(1000)
		DECLARE @edit_error_no INT
		SET @edit_error_no = ERROR_NUMBER()		
		SET @edit_error_desc = ERROR_MESSAGE()
		
		EXEC spa_print 'Error:', @edit_error_desc
		
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN
			
		EXEC spa_ErrorHandler @edit_error_no, 'Reporting FX', 'spa_rfx_report_page', @edit_error_desc, 'Fail to delete data.', ''
	END CATCH
END
IF @flag = 'r'
BEGIN
    SET @sql = 'SELECT report_page_chart_id [id],1 [type],rpc.name [common_name], rpc.[top],rpc.[left], rpc.width, rpc.height, NULL,NULL,NULL
				FROM   ' + @rfx_report_page_chart + ' rpc
				WHERE page_id = ' +CAST(@report_page_id AS VARCHAR(10)) + '
				UNION ALL
				SELECT report_page_tablix_id [id],2 [type],rpt.name [common_name], rpt.[top],rpt.[left], rpt.width, rpt.height,NULL,NULL,NULL
				FROM   ' + @rfx_report_page_tablix + ' rpt
				WHERE page_id = '+CAST(@report_page_id AS VARCHAR(10)) + '
				UNION ALL
				SELECT report_page_textbox_id [id],3 [type],rptx.content [common_name],rptx.[top],rptx.[left], rptx.width, rptx.height, rptx.font,rptx.font_size,rptx.font_style
				FROM   ' + @rfx_report_page_textbox + ' rptx
				WHERE page_id = '+CAST(@report_page_id AS VARCHAR(10)) + '
				UNION ALL
				SELECT report_page_image_id [id],4 [type],rpi.name [common_name],rpi.[top],rpi.[left], rpi.width, rpi.height, NULL,NULL,NULL
				FROM   ' + @rfx_report_page_image + ' rpi
				WHERE page_id = '+CAST(@report_page_id AS VARCHAR(10)) + '
				UNION ALL
				SELECT report_page_gauge_id [id], 5 [type], rpg.name [common_name], rpg.[top], rpg.[left], rpg.width, rpg.height, NULL, NULL, NULL
				FROM   ' + @rfx_report_page_gauge + ' rpg
				WHERE  page_id = '+CAST(@report_page_id AS VARCHAR(10)) + ' 
                                UNION ALL
				SELECT report_page_line_id [id],  6 [type], rpg.color [common_name], rpg.[top], rpg.[left], rpg.width, rpg.height, rpg.size, rpg.style, NULL
				FROM   ' + @rfx_report_page_line + ' rpg
				WHERE  page_id = '+CAST(@report_page_id AS VARCHAR(10)) 
	--PRINT @sql				
    EXEC (@sql)  
END
IF @flag = 'c' --Query to validate when page is saved without saving paramset with required parameters
BEGIN	
	DECLARE @paramset_sql VARCHAR(8000)
	
	CREATE TABLE #temp_paramset (
		paramset_exists VARCHAR(20) COLLATE DATABASE_DEFAULT
	)
	
	SET  @paramset_sql = '	INSERT INTO #temp_paramset	([paramset_exists])		
						SELECT 1 
						FROM (
						select Count(rp.column_id) [Column ID Count],MAX(rpp.page_id) [Page ID] 
						FROM ' + @rfx_report_paramset + ' rpp 
						INNER JOIN ' + @rfx_report_dataset_paramset + ' rdp
							ON  rdp.paramset_id = rpp.report_paramset_id
						INNER JOIN ' + @rfx_report_param + ' rp
							ON  rp.dataset_paramset_id = rdp.report_dataset_paramset_id
						INNER JOIN data_source_column  dsc
							ON dsc.data_source_column_id = rp.column_id
							AND dsc.reqd_param = 1 						
						WHERE rpp.page_id = ' + CAST(@report_page_id AS VARCHAR(20)) + ' 
						) paramset_count
						INNER JOIN (
							SELECT
								Count(dc.data_source_column_id) [Column ID Count],								
								MAX(dc.report_page_id) [Page ID] 
							FROM (							
								SELECT distinct dsc.data_source_column_id, rp.report_page_id 
								FROM ' +  @rfx_report_page + ' rp
								LEFT JOIN ' + @rfx_report_page_tablix + ' rpt
								ON  rpt.page_id = rp.report_page_id
								LEFT JOIN ' + @rfx_report_page_chart + ' rpc
								ON  rpc.page_id = rp.report_page_id
								LEFT JOIN ' + @rfx_report_page_gauge + ' rpg
									ON  rpg.page_id = rp.report_page_id
								INNER JOIN ' + @rfx_report_dataset + ' rd
									ON  rd.report_dataset_id = rpg.root_dataset_id
									OR rd.report_dataset_id = rpc.root_dataset_id
									OR rd.report_dataset_id = rpt.root_dataset_id
								INNER JOIN data_source_column  dsc
								ON dsc.source_id = rd.source_id
								AND dsc.reqd_param = 1 
								WHERE rp.report_page_id = ' + CAST(@report_page_id AS VARCHAR(20)) + '
							) dc 
						) dataset_count
						ON  paramset_count.[Column ID Count] = dataset_count.[Column ID Count]	'				
						
						
		--PRINT (@paramset_sql)
	    EXEC (@paramset_sql)	    	   

    IF NOT EXISTS(SELECT 1 FROM #temp_paramset)  
		EXEC spa_ErrorHandler 0, 'New Reporting FX', 'spa_rfx_report_page', 'DB Error', 'Please save Paramset to continue.', ''
	ELSE
		EXEC spa_ErrorHandler 0, 'New Reporting FX', 'spa_rfx_report_page', 'Success', 'Paramset already saved', ''
		
END

/* Called from [spa_rfx_deploy_rdl_as_job]; 0 = not deployed*/
IF @flag = 'p' 
BEGIN
	
	UPDATE rp	 
	SET is_deployed = 0
	FROM report_page rp
	WHERE rp.report_page_id = @report_page_id
	
	/* sheduler failed message*/
	SET @sql = 'EXEC dbo.spa_message_board ''i'', ''' + @job_user_name + ''', NULL, ''' + @job_proc_desc  + ''', ''' + @job_desc + ''', '''', '''', ''e'', NULL'
	EXEC(@sql)

END

/* Called from [spa_rfx_deploy_rdl_as_job]; 1 = deployed*/
IF @flag = 'q' 
BEGIN
	
	UPDATE rp	 
	SET is_deployed = 1
	FROM report_page rp
	WHERE rp.report_page_id = @report_page_id

END

IF @flag = 'x' -- Get list of report ids with help of report hash, called from page 'report.manager.dhx.bulk.rdl.maker.open.php'
BEGIN
	SELECT STUFF((
				SELECT ',' + CAST(r.report_id AS VARCHAR(10))
				FROM report r
				INNER JOIN dbo.SplitCommaSeperatedValues(@report_hash) scsv 
					ON scsv.item = r.report_hash
				FOR XML path('')
				), 1, 1, '') [report_ids]
END


