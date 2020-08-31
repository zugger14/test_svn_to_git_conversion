
IF OBJECT_ID(N'[dbo].[spa_rfx_report_starter_template]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_rfx_report_starter_template]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: mshrestha@pioneersolutionsglobal.com
-- Create date: 2012-08-14
-- Description: Used to list and operate on Report Starter Templates
-- In the insert mode the reports are always inserted to the temp table with the report_id 1. 
-- In the update mode the data of each main table is copied into the temp table for the report.  

	/*Note:
	* Any changes made while adding or removing for columns in tables must reflect on three spas namely
	* 1.spa_rfx_init
	* 2.spa_rfx_save
	* 3.spa_rfx_export_report
	* */
 
-- Params:
-- @flag CHAR(1) - Operation flag
-- @report_starter_template_id INT - Report Template ID

-- Sample Use
-- 1. Listing Report Template		:: EXEC [spa_rfx_report_starter_template] 'a'
-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_rfx_report_starter_template]
	@flag CHAR(1),
	@process_id VARCHAR(100) = NULL,
	@report_starter_template_id INT = NULL,
	@package_name VARCHAR(200) = NULL,
	@dataset_id INT = NULL,
	@dataset_alias VARCHAR(200) = NULL
AS
SET NOCOUNT ON
	DECLARE @user_name  VARCHAR(50) = dbo.FNADBUser()  
	DECLARE @sql        VARCHAR(8000)
	DECLARE @spa_name   VARCHAR(200)
	
	-- List the templates 
	IF @flag = 'a'
	BEGIN
	    SELECT rst.report_starter_template_id,
	           rst.[name]
	    FROM   report_starter_template rst
	END
	
	-- Get the template components
	IF @flag = 'c'
	BEGIN
	    IF @report_starter_template_id IS NOT NULL
	        SELECT rtc.report_template_component_id,
	               rtc.[component_type]
	        FROM   report_template_component rtc
	               JOIN report_starter_template rst
	                    ON  rst.report_starter_template_id = rtc.template_id
	        WHERE  rst.report_starter_template_id = @report_starter_template_id
	    ELSE
	        EXEC spa_ErrorHandler 0,
	             'Reporting FX',
	             'spa_rfx_report_starter_template',
	             'Failed',
	             'Data selection failed.',
	             '0'
	END
	
	-- Process report package and its items in addition as per template information
	IF @flag = 'p'
	BEGIN
	    IF @report_starter_template_id IS NOT NULL
	    BEGIN
	        --Declare temp table for grabbing returns from SPs and some vars
	        CREATE TABLE #msg_handler
	        (
	        	error_code      VARCHAR(50) COLLATE DATABASE_DEFAULT,
	        	module          VARCHAR(100) COLLATE DATABASE_DEFAULT,
	        	area            VARCHAR(100) COLLATE DATABASE_DEFAULT,
	        	[status]        VARCHAR(100) COLLATE DATABASE_DEFAULT,
	        	[message]       VARCHAR(5000) COLLATE DATABASE_DEFAULT,
	        	recommendation  VARCHAR(2000) COLLATE DATABASE_DEFAULT
	        )
	        
	        DECLARE @report_id         INT 
	        DECLARE @task_status       VARCHAR(50)
	        DECLARE @task_msg          VARCHAR(5000) 
	        DECLARE @root_dataset_id   INT
	        DECLARE @report_page_id    INT
	        DECLARE @report_page_name  VARCHAR(300) 
	        
	        --Init report processing, get process_id
	        INSERT INTO #msg_handler
	          (
	            error_code,
	            module,
	            area,
	            [status],
	            [message],
	            [recommendation]
	          )
	        EXEC spa_rfx_init 'c'
	        
	        SELECT TOP 1 @process_id = [recommendation]
	        FROM   #msg_handler
	        
	        TRUNCATE TABLE #msg_handler
	        
	        --Save report package
	        INSERT INTO #msg_handler
	          (
	            error_code,
	            module,
	            area,
	            [status],
	            [message],
	            [recommendation]
	          )
	        EXEC spa_rfx_report 'i',
	             @process_id,
	             NULL,
	             NULL,
	             @package_name,
	             NULL,
	             @package_name,
	             0
	        
	        SELECT TOP 1 @report_id = [recommendation],
	               @task_status = [status],
	               @task_msg = [message]
	        FROM   #msg_handler
	        
	        IF @task_status <> 'Success'
	        BEGIN
	            EXEC spa_ErrorHandler 0,
	                 'Reporting FX',
	                 'spa_rfx_report_starter_template',
	                 'Failed',
	                 @task_msg,
	                 @process_id
	                 
	            EXEC spa_rfx_init 'd',
	                 @process_id
	                 
	            RETURN
	        END
	        
	        TRUNCATE TABLE #msg_handler
	        
	        --Save dataset
	        INSERT INTO #msg_handler
	          (
	            error_code,
	            module,
	            area,
	            [status],
	            [message],
	            [recommendation]
	          )
	        EXEC spa_rfx_report_dataset 'i',
	             @process_id,
	             NULL,
	             @dataset_id,
	             @report_id,
	             NULL,
	             NULL,
	             NULL,
	             NULL,
	             NULL
	        
	        SELECT TOP 1 @root_dataset_id = [message],
	               @task_status = [status],
	               @task_msg = [message]
	        FROM   #msg_handler
	        
	        IF @task_status <> 'Success'
	        BEGIN
	            EXEC spa_ErrorHandler 0,
	                 'Reporting FX',
	                 'spa_rfx_report_starter_template',
	                 'Failed',
	                 @task_msg,
	                 @process_id
	            
	            EXEC spa_rfx_init 'd',
	                 @process_id
	                 
	            RETURN
	        END
	        
	        TRUNCATE TABLE #msg_handler
	        
	        
	        --Save report page
	        SET @report_page_name = @package_name + '_page1'
	        INSERT INTO #msg_handler
	          (
	            error_code,
	            module,
	            area,
	            [status],
	            [message],
	            [recommendation]
	          )
	        EXEC spa_rfx_report_page 'i',
	             @process_id,
	             NULL,
	             @report_id,
	             NULL,
	             @report_page_name,
	             NULL,
	             '12',
	             '11.69',
	             NULL
	        
	        SELECT TOP 1 @report_page_id = [recommendation],
	               @task_status = [status],
	               @task_msg = [message]
	        FROM   #msg_handler
	        
	        IF @task_status <> 'Success'
	        BEGIN
	            EXEC spa_ErrorHandler 0,
	                 'Reporting FX',
	                 'spa_rfx_report_starter_template',
	                 'Failed',
	                 @task_msg,
	                 @process_id
	            
	            EXEC spa_rfx_init 'd',
	                 @process_id
	                 
	            RETURN
	        END
	        
	        TRUNCATE TABLE #msg_handler
	        
	        --Process Report Items 
	        DECLARE @component_id INT -- wont be used much for now
	        DECLARE @component_counter INT = 0
	        DECLARE @component_top FLOAT = 1.1
	        DECLARE @component_left FLOAT = 1.3
			DECLARE @component_type INT
			DECLARE @component_name VARCHAR(300)
			
	        BEGIN TRY
				
				DECLARE cur_status CURSOR LOCAL FOR
				SELECT rtc.report_template_component_id, rtc.component_type
				FROM   report_template_component rtc
				INNER JOIN report_starter_template rst ON rst.report_starter_template_id = rtc.template_id
				WHERE rst.report_starter_template_id = @report_starter_template_id
				
				OPEN cur_status;

				FETCH NEXT FROM cur_status INTO @component_id, @component_type
				EXEC spa_print @component_id
				EXEC spa_print @@FETCH_STATUS
				WHILE @@FETCH_STATUS = 0
				BEGIN
					exec spa_print 'Now processing component_id: ', @component_id 
					IF @component_counter > 0
					BEGIN
						IF (@component_counter % 2) <> 0
							SET @component_left = 6.6
						ELSE
						BEGIN
							SET @component_left = 1.3
							SET @component_top += 3
						END	
					END
					TRUNCATE TABLE #msg_handler				
					IF @component_type = 1
					BEGIN
						SET @component_name = @report_page_name+'_tab_'+CAST(@component_counter AS VARCHAR(25))
						INSERT INTO #msg_handler(
							error_code, 
							module, 
							area, 
							[status],
							[message],
							[recommendation] 
						)
						EXEC spa_rfx_report_page_tablix 'u', 
							NULL, 
							@root_dataset_id, 
							@component_name, 
							@process_id , 
							4, 
							2.5, 
							@component_left, 
							@report_page_id, 
							@component_top,
							NULL, 
							0, 
							1, 
							NULL,
							0, 
							1
							
					END
					
					ELSE IF @component_type = 2
					BEGIN
						SET @component_name = @report_page_name+'_chart_'+CAST(@component_counter AS VARCHAR(25))
						INSERT INTO #msg_handler(
							error_code, 
							module, 
							area, 
							[status],
							[message],
							[recommendation] 
						)
						EXEC spa_rfx_chart 'i', 
							@process_id,
							@report_page_id,
							@root_dataset_id,
							@component_name,
							1, 
							@component_top,
							4,
							2.5,
							NULL,
							@component_left,
							NULL,
							'',
							'',	
							'',
							''
							
					END
					
					ELSE IF @component_type = 3
					BEGIN
						SET @component_name = @report_page_name+'_gauge_'+CAST(@component_counter AS VARCHAR(25))
						INSERT INTO #msg_handler(
							error_code, 
							module, 
							area, 
							[status],
							[message],
							[recommendation] 
						)
						EXEC spa_rfx_gauge 'i', 
							@process_id,
							@report_page_id,
							@root_dataset_id,
							@component_name,
							1, 
							@component_top,
							4,
							2.5,
							NULL,
							@component_left,
							NULL,
							''
							
					END
					--counter and some other vars updates
					SET @component_counter += 1 
					IF @component_counter = 0
						SET @component_top = 0.5
					FETCH NEXT FROM cur_status INTO @component_id, @component_type
				END;

				CLOSE cur_status;
				DEALLOCATE cur_status;	
			END TRY
			BEGIN CATCH
				IF CURSOR_STATUS('local', 'cur_status') >= 0 
				BEGIN
					CLOSE cur_status
					DEALLOCATE cur_status;
				END
				ELSE
				BEGIN
					SELECT TOP 1 @task_msg = [message]
					FROM   #msg_handler
					
					EXEC spa_ErrorHandler 0,
									 'Reporting FX',
									 'spa_rfx_report_starter_template',
									 'Failed',
									 @task_msg,
									 @process_id
					            
					EXEC spa_rfx_init 'd',
						 @process_id
				END	 
			END CATCH
	        --End of Report Items processing
	        
	        SET @sql = @process_id + '|' + CONVERT(VARCHAR(100), @report_id)
	        EXEC spa_ErrorHandler 0,
	             'Reporting FX',
	             'spa_rfx_report_starter_template',
	             'Success',
	             'Package saved.',
	             @sql
	    END
	    ELSE
	        EXEC spa_ErrorHandler 0,
	             'Reporting FX',
	             'spa_rfx_report_starter_template',
	             'Failed',
	             'Data selection failed.',
	             '0'
	END
GO
