IF OBJECT_ID(N'[dbo].[spa_rfx_init]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_rfx_init]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: mshrestha@pioneersolutionsglobal.com
-- Create date: 2012-08-14
-- Description: Init Logic saves all the temporary information of the report to respective temporary tables named
-- adhiha_process.dbo.<table_name>_<username>_<process_id>.
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
-- @process_id CHAR(1) - Operation ID
-- @report_id CHAR(1) - Report ID 

-- Sample Use
-- 1. Adding New Report		:: EXEC [spa_rfx_init] 'c'
-- 2. Updating New report	:: EXEC [spa_rfx_init] 'e', NULL,4
-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_rfx_init]
	@flag CHAR(1),
	@process_id VARCHAR(100) = NULL,
	@report_id VARCHAR(100) = NULL
AS
	IF @process_id IS NULL
	    SET @process_id = dbo.FNAGetNewID()
	
	DECLARE @user_name                        VARCHAR(50) = dbo.FNADBUser()  
	DECLARE @sql                              VARCHAR(8000)
	DECLARE @sql_1                            VARCHAR(8000)
	DECLARE @sql_1_1						  VARCHAR(8000)
	DECLARE @sql_2                            VARCHAR(8000)
	DECLARE @sql_3                            VARCHAR(8000)
	DECLARE @sql_4                            VARCHAR(8000)
	DECLARE @rfx_report                       VARCHAR(200)
	DECLARE @rfx_report_page                  VARCHAR(200)
	DECLARE @rfx_report_page_chart            VARCHAR(200)
	DECLARE @rfx_report_chart_column          VARCHAR(200)
	DECLARE @rfx_report_page_tablix           VARCHAR(200)
	DECLARE @rfx_report_tablix_column         VARCHAR(200)
	DECLARE @rfx_report_tablix_header         VARCHAR(200)
	DECLARE @rfx_report_column_link           VARCHAR(200)
	DECLARE @rfx_report_paramset              VARCHAR(200)
	DECLARE @rfx_report_dataset_paramset      VARCHAR(200)
	DECLARE @rfx_report_param                 VARCHAR(200)
	DECLARE @rfx_report_dataset               VARCHAR(200)
	DECLARE @rfx_report_dataset_relationship  VARCHAR(200)
	DECLARE @rfx_report_page_textbox          VARCHAR(200)
	DECLARE @rfx_report_page_image            VARCHAR(200)
	DECLARE @rfx_report_page_line             VARCHAR(200)
	
	DECLARE @rfx_report_page_gauge            VARCHAR(200)
	DECLARE @rfx_report_gauge_column          VARCHAR(200)
	DECLARE @rfx_report_gauge_column_scale    VARCHAR(200)
	DECLARE @rfx_report_dataset_deleted       VARCHAR(200) -- table to store deleted dataset id
	
	
	-- set names at first as eveery process seems to utilise the adiha_process table names
	SET @rfx_report                      = dbo.FNAProcessTableName('report', @user_name, @process_id)
	SET @rfx_report_dataset              = dbo.FNAProcessTableName('report_dataset', @user_name, @process_id)
    SET @rfx_report_dataset_relationship = dbo.FNAProcessTableName('report_dataset_relationship', @user_name, @process_id)
    SET @rfx_report_page                 = dbo.FNAProcessTableName('report_page', @user_name, @process_id)
    
    SET @rfx_report_page_tablix          = dbo.FNAProcessTableName('report_page_tablix', @user_name, @process_id)
    SET @rfx_report_tablix_column        = dbo.FNAProcessTableName('report_tablix_column', @user_name, @process_id)
    SET @rfx_report_tablix_header        = dbo.FNAProcessTableName('report_tablix_header', @user_name, @process_id)
    SET @rfx_report_column_link          = dbo.FNAProcessTableName('report_column_link', @user_name, @process_id)
    
    SET @rfx_report_page_chart           = dbo.FNAProcessTableName('report_page_chart', @user_name, @process_id)
    SET @rfx_report_chart_column         = dbo.FNAProcessTableName('report_chart_column', @user_name, @process_id)
    
    SET @rfx_report_paramset             = dbo.FNAProcessTableName('report_paramset', @user_name, @process_id)
    SET @rfx_report_dataset_paramset     = dbo.FNAProcessTableName('report_dataset_paramset', @user_name, @process_id)
    SET @rfx_report_param                = dbo.FNAProcessTableName('report_param', @user_name, @process_id)
    
    SET @rfx_report_page_textbox         = dbo.FNAProcessTableName('report_page_textbox', @user_name, @process_id)
    SET @rfx_report_page_image           = dbo.FNAProcessTableName('report_page_image', @user_name, @process_id)
    SET @rfx_report_page_line           = dbo.FNAProcessTableName('report_page_line', @user_name, @process_id)
    
    SET @rfx_report_page_gauge           = dbo.FNAProcessTableName('report_page_gauge', @user_name, @process_id)
    SET @rfx_report_gauge_column         = dbo.FNAProcessTableName('report_gauge_column', @user_name, @process_id)
    SET @rfx_report_gauge_column_scale   = dbo.FNAProcessTableName('report_gauge_column_scale', @user_name, @process_id)
    SET @rfx_report_dataset_deleted      = dbo.FNAProcessTableName('rfx_report_dataset_deleted', @user_name, @process_id)
	
	-- Clone Reporting schemas to Process DB :: Call This on Creating New Report
	IF @flag = 'c'
	BEGIN
	    SET @sql = 'SELECT * INTO ' + @rfx_report + ' FROM report WHERE 1 = 2
					SELECT * INTO ' + @rfx_report_dataset + ' FROM report_dataset WHERE 1 = 2
					SELECT * INTO ' + @rfx_report_dataset_relationship + ' FROM report_dataset_relationship WHERE 1 = 2
					SELECT * INTO ' + @rfx_report_page + ' FROM report_page WHERE 1 = 2
					SELECT * INTO ' + @rfx_report_page_tablix + ' FROM report_page_tablix WHERE 1 = 2
					SELECT * INTO ' + @rfx_report_tablix_column + ' FROM report_tablix_column WHERE 1 = 2
					SELECT * INTO ' + @rfx_report_tablix_header + ' FROM report_tablix_header WHERE 1 = 2
					SELECT * INTO ' + @rfx_report_column_link + ' FROM report_column_link WHERE 1 = 2
					SELECT * INTO ' + @rfx_report_page_chart + ' FROM report_page_chart WHERE 1 = 2
					SELECT * INTO ' + @rfx_report_chart_column + ' FROM report_chart_column WHERE 1 = 2
					SELECT * INTO ' + @rfx_report_paramset + ' FROM report_paramset WHERE 1 = 2
					SELECT * INTO ' + @rfx_report_dataset_paramset + ' FROM report_dataset_paramset WHERE 1 = 2					
					SELECT * INTO ' + @rfx_report_param + ' FROM report_param WHERE 1 = 2
					SELECT * INTO ' + @rfx_report_page_textbox + ' FROM report_page_textbox WHERE 1 = 2
					SELECT * INTO ' + @rfx_report_page_image + ' FROM report_page_image WHERE 1 = 2
					SELECT * INTO ' + @rfx_report_page_line + ' FROM report_page_line WHERE 1 = 2
					
					SELECT * INTO ' + @rfx_report_page_gauge + ' FROM report_page_gauge WHERE 1 = 2
					SELECT * INTO ' + @rfx_report_gauge_column + ' FROM report_gauge_column WHERE 1 = 2
					SELECT * INTO ' + @rfx_report_gauge_column_scale + ' FROM report_gauge_column_scale WHERE 1 = 2
					CREATE table ' + @rfx_report_dataset_deleted + '(source_id int)
					'
                
	    EXEC spa_print 'Clone Reporting schemas to Process DB :: ', @sql
	    EXEC (@sql)
	    
	    IF @@ERROR <> 0
	        EXEC spa_ErrorHandler @@ERROR, 'Reporting FX', 'spa_rfx_init', 'DB Error', 'Cloned Reporting schemas to Process DB.', ''
	    ELSE
	        EXEC spa_ErrorHandler 0, 'Reporting FX', 'spa_rfx_init', 'Success', 'Cloned Reporting schemas to Process DB.', @process_id
	END
	
	-- Clone Reporting schemas and data to Process DB :: Call This on Editing Existing Report
	IF @flag = 'e'
	BEGIN try
	    SET @sql = '----------------------------------------------------------------------------------
					SELECT * INTO ' + @rfx_report + ' FROM report WHERE report_id = ' + @report_id + '
					----------------------------------------------------------------------------------
					
					
					----------------------------------------------------------------------------------
					SELECT * INTO ' + @rfx_report_page + ' FROM report_page WHERE report_id = ' + @report_id + '
					----------------------------------------------------------------------------------
					

					----------------------------------------------------------------------------------
					SELECT rpc.* INTO ' + @rfx_report_page_chart + ' FROM report_page_chart rpc WHERE 1 = 2
					SET IDENTITY_INSERT ' + @rfx_report_page_chart + ' ON
					
					INSERT INTO ' + @rfx_report_page_chart + '(report_page_chart_id, page_id, root_dataset_id, [name], [TYPE_ID], width, height, create_user, create_ts, update_user, update_ts, [top], [left], y_axis_caption, x_axis_caption, page_break, chart_properties) 
					SELECT rpc.report_page_chart_id, rpc.page_id, rpc.root_dataset_id, rpc.[name], rpc.[type_id], rpc.width, rpc.height, rpc.create_user, rpc.create_ts, rpc.update_user, rpc.update_ts, rpc.[top], rpc.[left], rpc.y_axis_caption, rpc.x_axis_caption, rpc.page_break, rpc.chart_properties 
					FROM report_page_chart rpc 
					INNER JOIN ' + @rfx_report_page + ' rp ON rp.report_page_id = rpc.page_id
					
					SET IDENTITY_INSERT ' + @rfx_report_page_chart + ' OFF
					----------------------------------------------------------------------------------
					
					
					----------------------------------------------------------------------------------
					SELECT rcc.* INTO ' + @rfx_report_chart_column + ' FROM report_chart_column rcc WHERE 1 = 2
					SET IDENTITY_INSERT ' + @rfx_report_chart_column + ' ON
					
					INSERT INTO ' + @rfx_report_chart_column + '(report_chart_column_id, chart_id, column_id, placement, column_order, alias, create_user, create_ts, update_user, update_ts, dataset_id, functions, aggregation, default_sort_order, default_sort_direction, custom_field, render_as_line) 
					SELECT rcc.report_chart_column_id, rcc.chart_id, rcc.column_id, rcc.placement, rcc.column_order, rcc.alias, rcc.create_user, rcc.create_ts, rcc.update_user, rcc.update_ts, rcc.dataset_id, rcc.functions, rcc.aggregation, rcc.default_sort_order, rcc.default_sort_direction, rcc.custom_field, rcc.render_as_line
					FROM report_chart_column rcc 
					INNER JOIN ' + @rfx_report_page_chart + ' rpc ON rpc.report_page_chart_id = rcc.chart_id
					
					SET IDENTITY_INSERT ' + @rfx_report_chart_column + ' OFF
					----------------------------------------------------------------------------------
					
					
					----------------------------------------------------------------------------------
					SELECT rpt.* INTO ' + @rfx_report_page_tablix + ' FROM report_page_tablix rpt WHERE 1 = 2
					SET IDENTITY_INSERT ' + @rfx_report_page_tablix + ' ON
					
					INSERT INTO ' + @rfx_report_page_tablix + '(report_page_tablix_id, page_id, root_dataset_id, [name], width, height, create_user, create_ts, update_user, update_ts, [top], [left], group_mode, border_style, page_break, type_id, cross_summary, no_header, export_table_name, is_global) 
					SELECT rpt.report_page_tablix_id, rpt.page_id, rpt.root_dataset_id, rpt.[name], rpt.width, rpt.height, rpt.create_user, rpt.create_ts, rpt.update_user, rpt.update_ts, rpt.[top],rpt.[left], rpt.group_mode, rpt.border_style, rpt.page_break, rpt.type_id, rpt.cross_summary, rpt.no_header, rpt.export_table_name, rpt.is_global
					FROM report_page_tablix rpt 
					INNER JOIN ' + @rfx_report_page + ' rp ON rp.report_page_id = rpt.page_id
					
					SET IDENTITY_INSERT ' + @rfx_report_page_tablix + ' OFF
					----------------------------------------------------------------------------------'
					
					
		SET @sql_1 = '
					-------------------------@sql_1---------------------------------------------------------
					SELECT rtc.* INTO ' + @rfx_report_tablix_column + ' FROM report_tablix_column rtc WHERE 1 = 2
					SET IDENTITY_INSERT ' + @rfx_report_tablix_column + ' ON
					
					INSERT INTO ' + @rfx_report_tablix_column + ' (report_tablix_column_id, tablix_id, column_id, placement, column_order, aggregation, functions, alias, sortable, rounding, thousand_seperation, font, font_size, font_style, text_align, text_color, default_sort_order, default_sort_direction, background, create_user, create_ts, update_user, update_ts, dataset_id, render_as, custom_field, column_template, negative_mark, currency, date_format, cross_summary_aggregation, mark_for_total, sql_aggregation, subtotal)
					SELECT rtc.report_tablix_column_id, rtc.tablix_id, rtc.column_id, rtc.placement, rtc.column_order, rtc.aggregation, rtc.functions, rtc.alias, rtc.sortable, rtc.rounding, rtc.thousand_seperation, rtc.font, rtc.font_size, rtc.font_style, rtc.text_align, rtc.text_color, rtc.default_sort_order, rtc.default_sort_direction, rtc.background, rtc.create_user, rtc.create_ts, rtc.update_user, rtc.update_ts, rtc.dataset_id, rtc.render_as, rtc.custom_field, rtc.column_template, rtc.negative_mark, rtc.currency, rtc.date_format, rtc.cross_summary_aggregation, rtc.mark_for_total, rtc.sql_aggregation, rtc.subtotal
					FROM report_tablix_column rtc 
					INNER JOIN ' + @rfx_report_page_tablix + ' rpt ON rpt.report_page_tablix_id = rtc.tablix_id
					
					SET IDENTITY_INSERT ' + @rfx_report_tablix_column + ' OFF
					----------------------------------------------------------------------------------
					
					
					----------------------------------------------------------------------------------
					SELECT rth.* INTO ' + @rfx_report_tablix_header + ' FROM report_tablix_header rth WHERE 1 = 2
					SET IDENTITY_INSERT ' + @rfx_report_tablix_header + ' ON
					
					INSERT INTO ' + @rfx_report_tablix_header + ' (report_tablix_header_id, tablix_id, column_id, font, font_size, font_style, text_align, text_color, background, create_user, create_ts, update_user, update_ts, report_tablix_column_id)
					SELECT rth.report_tablix_header_id, rth.tablix_id, rth.column_id, rth.font, rth.font_size, rth.font_style, rth.text_align, rth.text_color, rth.background, rth.create_user, rth.create_ts, rth.update_user, rth.update_ts, rth.report_tablix_column_id
					FROM   report_tablix_header rth 
					INNER JOIN ' + @rfx_report_page_tablix + ' rpt ON rpt.report_page_tablix_id = rth.tablix_id
					
					SET IDENTITY_INSERT ' + @rfx_report_tablix_header + ' OFF
					----------------------------------------------------------------------------------
					
					
					
					----------------------------------------------------------------------------------
					SELECT rcl.* INTO ' + @rfx_report_column_link + ' FROM report_column_link rcl WHERE 1= 2
					SET IDENTITY_INSERT ' + @rfx_report_column_link + ' ON
					
					INSERT INTO ' + @rfx_report_column_link + ' (report_column_link_id, tablix_column_id, page_id, paramset_id, parameter_pair, create_user, create_ts, update_user, update_ts)
					SELECT rcl.report_column_link_id, rcl.tablix_column_id, rcl.page_id, rcl.paramset_id, rcl.parameter_pair, rcl.create_user, rcl.create_ts, rcl.update_user, rcl.update_ts 
					FROM report_column_link rcl  
					INNER JOIN ' + @rfx_report_tablix_column + ' rtc ON rtc.report_tablix_column_id = rcl.tablix_column_id
					
					SET IDENTITY_INSERT ' + @rfx_report_column_link + ' OFF
					----------------------------------------------------------------------------------'
					
		SET @sql_1_1 = 			
					'----------------------------------------------------------------------------------
					SELECT rp.* INTO ' + @rfx_report_paramset + ' FROM report_paramset rp WHERE 1 = 2
					SET IDENTITY_INSERT ' + @rfx_report_paramset + ' ON
					
					INSERT INTO ' + @rfx_report_paramset + ' (report_paramset_id , page_id, [name], paramset_hash, create_user, create_ts, update_user, update_ts, report_status_id )
					SELECT rp.report_paramset_id, rp.page_id, rp.[name], rp.paramset_hash, rp.create_user, rp.create_ts, rp.update_user, rp.update_ts, rp.report_status_id 
					FROM report_paramset rp 
					INNER JOIN ' + @rfx_report_page + ' rps ON rps.report_page_id = rp.page_id
					
					SET IDENTITY_INSERT ' + @rfx_report_paramset + ' OFF
					----------------------------------------------------------------------------------
					
					
					----------------------------------------------------------------------------------
					SELECT rp.* INTO ' + @rfx_report_dataset_paramset + ' FROM report_dataset_paramset rp WHERE 1 = 2
					SET IDENTITY_INSERT ' + @rfx_report_dataset_paramset + ' ON
					
					INSERT INTO ' + @rfx_report_dataset_paramset + ' (report_dataset_paramset_id,paramset_id, root_dataset_id, where_part, advance_mode)
					SELECT rp.report_dataset_paramset_id, rp.paramset_id, rp.root_dataset_id, rp.where_part, rp.advance_mode  
					FROM report_dataset_paramset rp 
					INNER JOIN ' + @rfx_report_paramset + ' rps ON rps.report_paramset_id = rp.paramset_id
					
					SET IDENTITY_INSERT ' + @rfx_report_dataset_paramset + ' OFF
					----------------------------------------------------------------------------------
					
					
					----------------------------------------------------------------------------------
					SELECT rps.* INTO ' + @rfx_report_param + ' FROM report_param rps WHERE 1 = 2
					SET IDENTITY_INSERT ' + @rfx_report_param + ' ON
					
					INSERT INTO ' + @rfx_report_param + ' (report_param_id, dataset_paramset_id, dataset_id, column_id, operator, initial_value, initial_value2, optional, create_user, create_ts, update_user, update_ts, hidden, logical_operator, param_order, param_depth, label)
					SELECT rps.report_param_id, rps.dataset_paramset_id, rps.dataset_id, rps.column_id, rps.operator, rps.initial_value, rps.initial_value2, rps.optional, rps.create_user, rps.create_ts, rps.update_user, rps.update_ts, rps.hidden, rps.logical_operator, rps.param_order, rps.param_depth, rps.label
					FROM report_param rps
					INNER JOIN ' + @rfx_report_dataset_paramset + ' rdp ON rdp.report_dataset_paramset_id = rps.dataset_paramset_id					
					
					SET IDENTITY_INSERT ' + @rfx_report_param + ' OFF
					----------------------------------------------------------------------------------'
					
					
	 SET @sql_2 = '
					----------@sql_2------------------------------------------------------------------------
					SELECT rd.* INTO ' + @rfx_report_dataset + ' FROM report_dataset rd WHERE 1 = 2
					SET IDENTITY_INSERT ' + @rfx_report_dataset + ' ON
					
					INSERT INTO ' + @rfx_report_dataset + ' (report_dataset_id, source_id, report_id, alias, create_user, create_ts, update_user, update_ts, root_dataset_id, is_free_from, relationship_sql)
					SELECT rd.report_dataset_id, rd.source_id, rd.report_id, rd.alias, rd.create_user, rd.create_ts, rd.update_user, rd.update_ts, rd.root_dataset_id, rd.is_free_from, rd.relationship_sql
					FROM report_dataset rd 
					INNER JOIN ' + @rfx_report + ' r ON r.report_id = rd.report_id
					
					SET IDENTITY_INSERT ' + @rfx_report_dataset + ' OFF 
					----------------------------------------------------------------------------------
					
					
					----------------------------------------------------------------------------------
					SELECT rdr.* INTO ' + @rfx_report_dataset_relationship + ' FROM report_dataset_relationship rdr WHERE 1 = 2
					SET IDENTITY_INSERT ' + @rfx_report_dataset_relationship + ' ON 
					
					INSERT INTO ' + @rfx_report_dataset_relationship + ' (report_dataset_relationship_id, create_user, create_ts, update_user, update_ts, from_dataset_id, to_dataset_id, dataset_id, from_column_id, to_column_id, join_type)
					SELECT rdr.report_dataset_relationship_id, rdr.create_user, rdr.create_ts, rdr.update_user, rdr.update_ts, rdr.from_dataset_id, rdr.to_dataset_id, rdr.dataset_id, rdr.from_column_id, rdr.to_column_id, rdr.join_type
					FROM report_dataset_relationship rdr 
					INNER JOIN ' + @rfx_report_dataset + ' rd ON rd.report_dataset_id = rdr.dataset_id
					
					SET IDENTITY_INSERT ' + @rfx_report_dataset_relationship + ' OFF 
					----------------------------------------------------------------------------------
					
					----------------------------------------------------------------------------------
					SELECT rptb.* INTO ' + @rfx_report_page_textbox + ' FROM report_page_textbox rptb WHERE 1 = 2
					SET IDENTITY_INSERT ' + @rfx_report_page_textbox + ' ON 
					
					INSERT INTO ' + @rfx_report_page_textbox + ' (report_page_textbox_id,page_id, content, font, font_size, font_style , width, height, [top], [left], hash, create_user, create_ts, update_user, update_ts)
					SELECT rptb.report_page_textbox_id, rptb.page_id, rptb.content, rptb.font, rptb.font_size, rptb.font_style , rptb.width, rptb.height, rptb.[top], rptb.[left], rptb.hash, rptb.create_user, rptb. create_ts, rptb.update_user, rptb.update_ts   
					FROM report_page_textbox rptb 
					INNER JOIN ' + @rfx_report_page + ' rp ON rp.report_page_id = rptb.page_id
					
					SET IDENTITY_INSERT ' + @rfx_report_page_textbox + ' OFF 
					----------------------------------------------------------------------------------
					
					----------------------------------------------------------------------------------
					SELECT rpi.* INTO ' + @rfx_report_page_image + ' FROM report_page_image rpi WHERE 1 = 2
					SET IDENTITY_INSERT ' + @rfx_report_page_image + ' ON 
					
					INSERT INTO ' + @rfx_report_page_image + ' (report_page_image_id, page_id, name , filename, width, height, [top], [left] , hash, create_user, create_ts, update_user, update_ts)
					SELECT rpi.report_page_image_id, rpi.page_id, rpi.name , rpi.filename, rpi.width, rpi.height, rpi.[top], rpi.[left] , rpi.hash, rpi.create_user, rpi.create_ts, rpi.update_user, rpi.update_ts      
					FROM report_page_image rpi 
					INNER JOIN ' + @rfx_report_page + ' rp ON rp.report_page_id = rpi.page_id
					
					SET IDENTITY_INSERT ' + @rfx_report_page_image + ' OFF 
					----------------------------------------------------------------------------------
					
					----------------------------------------------------------------------------------
					SELECT rpl.* INTO ' + @rfx_report_page_line + ' FROM report_page_line rpl WHERE 1 = 2
					SET IDENTITY_INSERT ' + @rfx_report_page_line + ' ON 
					
					INSERT INTO ' + @rfx_report_page_line + ' (report_page_line_id, page_id, color, size, style, width, height, [top], [left], hash, create_user, create_ts, update_user, update_ts)
					SELECT rpl.report_page_line_id, rpl.page_id, rpl.color, rpl.size, rpl.style, rpl.width, rpl.height, rpl.[top], rpl.[left], rpl.hash, rpl.create_user, rpl.create_ts, rpl.update_user, rpl.update_ts      
					FROM report_page_line rpl 
					INNER JOIN ' + @rfx_report_page + ' rp ON rp.report_page_id = rpl.page_id
					
					SET IDENTITY_INSERT ' + @rfx_report_page_line + ' OFF 
					----------------------------------------------------------------------------------
					'
		
		SET @sql_3 = '
					----------------------------------------------------------------------------------
					SELECT rpc.* INTO ' + @rfx_report_page_gauge + ' FROM   report_page_gauge rpc WHERE  1 = 2
					SET IDENTITY_INSERT ' + @rfx_report_page_gauge + ' ON

					INSERT INTO ' + @rfx_report_page_gauge + ' (report_page_gauge_id, page_id, root_dataset_id, [name], [type_id], width, height, [top], [left], create_user, create_ts, update_user, update_ts, gauge_label_column_id )
					SELECT rpc.report_page_gauge_id, rpc.page_id, rpc.root_dataset_id, rpc.[name], rpc.[type_id], rpc.width, rpc.height, rpc.[top], rpc.[left], rpc.create_user, rpc.create_ts, rpc.update_user, rpc.update_ts, rpc.gauge_label_column_id
					FROM   report_page_gauge rpc
					INNER JOIN ' + @rfx_report_page + ' rp ON  rp.report_page_id = rpc.page_id

					SET IDENTITY_INSERT ' + @rfx_report_page_gauge + ' OFF
					----------------------------------------------------------------------------------

					----------------------------------------------------------------------------------
					SELECT rcc.* INTO ' + @rfx_report_gauge_column + ' FROM   report_gauge_column rcc WHERE  1 = 2
					SET IDENTITY_INSERT ' + @rfx_report_gauge_column + ' ON

					INSERT INTO ' + @rfx_report_gauge_column + ' (report_gauge_column_id, gauge_id, column_id, column_order, dataset_id, create_user, create_ts, update_user, update_ts, scale_minimum, scale_maximum, scale_interval, alias, functions, aggregation, font, font_size, font_style, text_color, custom_field, render_as, column_template, currency, rounding, thousand_seperation)
					SELECT rcc.report_gauge_column_id, rcc.gauge_id, rcc.column_id, rcc.column_order, rcc.dataset_id, rcc.create_user, rcc.create_ts, rcc.update_user, rcc.update_ts, rcc.scale_minimum, rcc.scale_maximum, rcc.scale_interval, rcc.alias, rcc.functions, rcc.aggregation, rcc.font, rcc.font_size, rcc.font_style, rcc.text_color, rcc.custom_field, rcc.render_as, rcc.column_template, rcc.currency, rcc.rounding, rcc.thousand_seperation
					FROM   report_gauge_column rcc
					INNER JOIN ' + @rfx_report_page_gauge + ' rpc ON  rpc.report_page_gauge_id = rcc.gauge_id

					SET IDENTITY_INSERT ' + @rfx_report_gauge_column + ' OFF
					----------------------------------------------------------------------------------

					----------------------------------------------------------------------------------
					SELECT rcc.* INTO ' + @rfx_report_gauge_column_scale + ' FROM report_gauge_column_scale rcc WHERE  1 = 2
					SET IDENTITY_INSERT ' + @rfx_report_gauge_column_scale + ' ON

					INSERT INTO ' + @rfx_report_gauge_column_scale + ' (report_gauge_column_scale_id, report_gauge_column_id, scale_start, scale_end, create_user, create_ts, update_user, update_ts, scale_range_color, column_id, placement)
					SELECT rcc.[report_gauge_column_scale_id], rcc.[report_gauge_column_id], rcc.scale_start,rcc.scale_end, rcc.create_user, rcc.create_ts, rcc.update_user, rcc.update_ts, rcc.scale_range_color, rcc.column_id, rcc.placement
					FROM   report_gauge_column_scale rcc
					INNER JOIN ' + @rfx_report_gauge_column + ' rpc ON  rpc.[report_gauge_column_id] = rcc.[report_gauge_column_id]

					SET IDENTITY_INSERT ' + @rfx_report_gauge_column_scale + ' OFF
					----------------------------------------------------------------------------------					
					'			
		set @sql_4 = 'CREATE table ' + @rfx_report_dataset_deleted + '(source_id int)'
							
        
	    EXEC spa_print 'Clone Reporting schemas to Process DB :: ' 
	    EXEC spa_print @sql 
	    EXEC spa_print @sql_1
	    EXEC spa_print @sql_1_1
	    EXEC spa_print @sql_2
	    EXEC spa_print @sql_3
		EXEC spa_print @sql_4
	    EXEC (@sql + @sql_1 + @sql_1_1 + @sql_2 + @sql_3 + @sql_4)
	    
	    EXEC spa_ErrorHandler 0, 'Reporting FX', 'spa_rfx_init', 'Success', 'Cloned Existing Report schemas and data to Process DB.', @process_id
	END TRY
	BEGIN CATCH
		DECLARE @catch_err_msg VARCHAR(100)
		SET @catch_err_msg = ERROR_MESSAGE()
		EXEC spa_ErrorHandler 1, 'Reporting FX', 'spa_rfx_init', 'DB Error', 'Cloned Existing Report schemas and data to Process DB.', @catch_err_msg
	END CATCH
	
	-- Delete Cloned schemas from Process DB 
	IF @flag = 'd'
	BEGIN
		--delete SQL datasource and its columns map with the unsaved report,
		--but make sure it is still unused
	    SET @sql = '
					DELETE data_source_column
					FROM data_source_column dsc
					INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id
					INNER JOIN ' + @rfx_report_dataset + ' dm ON dm.source_id = ds.data_source_id
					LEFT JOIN report_dataset rd ON rd.source_id = ds.data_source_id
					WHERE ds.type_id = 2 AND rd.report_dataset_id IS NULL
										
					DELETE data_source
					FROM data_source ds
					INNER JOIN ' + @rfx_report_dataset + ' dm ON dm.source_id = ds.data_source_id
					LEFT JOIN report_dataset rd ON rd.source_id = ds.data_source_id
					WHERE ds.type_id = 2 AND rd.report_dataset_id IS NULL
	
					DROP TABLE  ' + @rfx_report + '
					DROP TABLE  ' + @rfx_report_page + '
					DROP TABLE  ' + @rfx_report_page_chart + '
					DROP TABLE  ' + @rfx_report_chart_column + '
					DROP TABLE  ' + @rfx_report_page_tablix + '
					DROP TABLE  ' + @rfx_report_tablix_column + '
					DROP TABLE  ' + @rfx_report_tablix_header + '
					DROP TABLE  ' + @rfx_report_column_link + '
					DROP TABLE  ' + @rfx_report_paramset + '
					DROP TABLE  ' + @rfx_report_dataset_paramset + '
					DROP TABLE  ' + @rfx_report_param + '
					DROP TABLE  ' + @rfx_report_dataset + '
					DROP TABLE  ' + @rfx_report_dataset_relationship +'
					DROP TABLE  ' + @rfx_report_page_textbox + '
					DROP TABLE  ' + @rfx_report_page_image +'		
					DROP TABLE  ' + @rfx_report_page_line +'					
					DROP TABLE  ' + @rfx_report_gauge_column_scale +'
					DROP TABLE  ' + @rfx_report_gauge_column + '
					DROP TABLE  ' + @rfx_report_page_gauge +'
					DROP TABLE  ' + @rfx_report_dataset_deleted +'					
					'
      
	    EXEC spa_print 'Deleted Scehmas From Process DB :: ', @sql
	    EXEC (@sql)
	    
	    IF @@ERROR <> 0
	        EXEC spa_ErrorHandler @@ERROR, 'Reporting FX', 'spa_rfx_init', 'DB Error', 'Error in Delete Schemas From Process DB.', ''
	    ELSE
	        EXEC spa_ErrorHandler 0, 'Reporting FX', 'spa_rfx_init', 'Success', 'Deleted schemas from Process DB.', @process_id
	END
GO
