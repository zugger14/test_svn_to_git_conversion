IF OBJECT_ID(N'[dbo].[spa_rfx_rdl_maker_preview_dhx]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_rfx_rdl_maker_preview_dhx]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: mshrestha@pioneersolutionsglobal.com
-- Create date: 2012-08-15
-- Description: Add/Update Operations for Report Page Textbox
 
-- Params:
-- @flag					CHAR	- Operation flag
-- @process_id				VARCHAR - Operation ID

-- Sample Use :: EXEC spa_rfx_rdl_maker_preview_dhx 'i', '751FAC2F_F97C_479F_BE6B_CB39EEE7B0EA', NULL, 648, 'IMG_21112012_144048.png', '216572acaa31ca543242634d38824557.png', '2.6666666666666665', '0.7733333333333333', '4.933333333333334', '2.4266666666666667'
-- Sample Use :: EXEC spa_rfx_rdl_maker_preview_dhx 'u', '751FAC2F_F97C_479F_BE6B_CB39EEE7B0EA', 123, 648, 'IMG_21112012_144048.png', '216572acaa31ca543242634d38824557.png', '2.6666666666666665', '0.7733333333333333', '4.933333333333334', '2.4266666666666667'
-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_rfx_rdl_maker_preview_dhx]
    @flag CHAR(1),
	@process_id VARCHAR(50),
    @report_id VARCHAR(50) = NULL,
    @page_id VARCHAR(50)   = NULL,
    @page_chart_id VARCHAR(50) = NULL,
    @page_tablix_id VARCHAR(50) = NULL,
    @page_gauge_id VARCHAR(50) = NULL,
    @gauge_column_id VARCHAR(50) = NULL	
AS
set nocount on
DECLARE @user_name                       VARCHAR(50),
        @sql                             VARCHAR(MAX),
        @report_name_separator			 VARCHAR(2)

SET @user_name = dbo.FNADBUser()
SET @report_name_separator = '_'

DECLARE @rfx_report                       VARCHAR(200)
DECLARE @rfx_report_page                  VARCHAR(200)
DECLARE @rfx_report_page_chart            VARCHAR(200)
DECLARE @rfx_report_chart_column          VARCHAR(200)
DECLARE @rfx_report_page_tablix           VARCHAR(200)
DECLARE @rfx_report_tablix_column         VARCHAR(200)
DECLARE @rfx_report_tablix_header         VARCHAR(200)
DECLARE @rfx_report_page_textbox          VARCHAR(200)
DECLARE @rfx_report_page_image            VARCHAR(200)
DECLARE @rfx_report_page_line             VARCHAR(200)
DECLARE @rfx_report_page_gauge            VARCHAR(200)
DECLARE @rfx_report_gauge_column          VARCHAR(200)
DECLARE @rfx_report_gauge_column_scale    VARCHAR(200)

SET @rfx_report                      = dbo.FNAProcessTableName('report', @user_name, @process_id)
SET @rfx_report_page                 = dbo.FNAProcessTableName('report_page', @user_name, @process_id)
SET @rfx_report_page_tablix          = dbo.FNAProcessTableName('report_page_tablix', @user_name, @process_id)
SET @rfx_report_tablix_column        = dbo.FNAProcessTableName('report_tablix_column', @user_name, @process_id)
SET @rfx_report_tablix_header        = dbo.FNAProcessTableName('report_tablix_header', @user_name, @process_id)
SET @rfx_report_page_chart           = dbo.FNAProcessTableName('report_page_chart', @user_name, @process_id)
SET @rfx_report_chart_column         = dbo.FNAProcessTableName('report_chart_column', @user_name, @process_id)
SET @rfx_report_page_textbox         = dbo.FNAProcessTableName('report_page_textbox', @user_name, @process_id)
SET @rfx_report_page_image           = dbo.FNAProcessTableName('report_page_image', @user_name, @process_id)
SET @rfx_report_page_line           = dbo.FNAProcessTableName('report_page_line', @user_name, @process_id)
SET @rfx_report_page_gauge           = dbo.FNAProcessTableName('report_page_gauge', @user_name, @process_id)
SET @rfx_report_gauge_column         = dbo.FNAProcessTableName('report_gauge_column', @user_name, @process_id)
SET @rfx_report_gauge_column_scale   = dbo.FNAProcessTableName('report_gauge_column_scale', @user_name, @process_id)


IF @flag = 's'
BEGIN
	IF @report_id IS NOT NULL
	BEGIN
		SET @sql = 'SELECT rp.report_page_id, rp.[name] FROM ' + @rfx_report_page + ' rp WHERE rp.report_id = ' + @report_id
		EXEC(@sql)
	END
	ELSE
		EXEC spa_ErrorHandler 0, 'Reporting FX', 'spa_rfx_rdl_maker_preview_dhx', 'Failed', 'Data selection failed.', '0'
END

IF @flag = 'a'
BEGIN
	IF @page_id IS NOT NULL
	BEGIN
		SET @sql = '
		SELECT r.report_id,
				r.[name] [name],       
				rp.report_hash,
				rp.width,
				rp.height
		FROM   ' + @rfx_report + ' r
		INNER JOIN ' + @rfx_report_page + ' rp ON  rp.report_id = r.report_id
			WHERE rp.report_page_id = ' + @page_id + '
		'
		EXEC(@sql)
	END
	
	ELSE
		EXEC spa_ErrorHandler 0, 'Reporting FX', 'spa_rfx_rdl_maker_preview_dhx', 'Failed', 'Data selection failed.', '0'
END

IF @flag = 'i'
BEGIN
	IF @page_id IS NOT NULL
	BEGIN
		SET @sql = '
		SELECT rpt.root_dataset_id [root_dataset_id],
				REPLACE(rpt.name, '' '','''') [alias],
				NULL [report_dataset_paramset_id],
				''t'' [display_type],
				rpt.report_page_tablix_id [report_component_id],
				rpt.page_id,
				NULL [type],
				rpt.[top],
				rpt.[left],
				rpt.[width],
				rpt.[height],
				rpt.[name],
				NULL [y_axis_caption],
				NULL [x_axis_caption],
				rpt.group_mode,
				rpt.border_style,
				rpt.page_break
		FROM   ' + @rfx_report_page_tablix + ' rpt
		WHERE  rpt.page_id = ' + @page_id + '
        
		UNION 
        
		SELECT rpt.root_dataset_id [root_dataset_id],
				REPLACE(rpt.name, '' '','''') [alias],
				NULL [report_dataset_paramset_id],
				''c'' [display_type],
				rpt.report_page_chart_id [report_component_id],
				rpt.page_id,
				rpt.[type_id] [type],
				rpt.[top],
				rpt.[left],
				rpt.[width],
				rpt.[height],
				rpt.[name],
				rpt.y_axis_caption,
				rpt.x_axis_caption,
				NULL as group_mode,
				NULL AS border_style,
				rpt.page_break
		FROM   ' + @rfx_report_page_chart + ' rpt
		WHERE  rpt.page_id = ' + @page_id + '
		'
		EXEC(@sql)
	END
	ELSE
		EXEC spa_ErrorHandler 0, 'Reporting FX', 'spa_rfx_rdl_maker_preview_dhx', 'Failed', 'Data selection failed.', '0'
END

IF @flag = 'p'
BEGIN
	IF @page_id IS NOT NULL    
	BEGIN
		SET @sql = '
		SELECT rpt.root_dataset_id [root_dataset_id],
               REPLACE(rpt.name, '' '','''') [alias],
               NULL [report_dataset_paramset_id],
               ''c'' [display_type],
               rpt.report_page_chart_id [report_component_id],
               rpt.page_id,
               rpt.[type_id] [type],
               rpt.[top],
               rpt.[left],
               rpt.[width],
               rpt.[height],
               rpt.[name],
               rpt.y_axis_caption,
               rpt.x_axis_caption,
               NULL as group_mode,
               NULL AS border_style,
               rpt.page_break,
               rpt.chart_properties               
        FROM   ' + @rfx_report_page_chart + ' rpt
        WHERE  rpt.page_id = ' + @page_id + '
		'
		EXEC(@sql)
	END                    
        
	ELSE
		EXEC spa_ErrorHandler 0, 'Reporting FX', 'spa_rfx_rdl_maker_preview_dhx', 'Failed', 'Data selection failed.', '0'
END

IF @flag = 'm'
BEGIN
	IF @page_id IS NOT NULL
	BEGIN
		SET @sql = '
		SELECT rpt.root_dataset_id [root_dataset_id],
               REPLACE(rpt.name, '' '','''') [alias],
               NULL [report_dataset_paramset_id],
               ''t'' [display_type],
               rpt.report_page_tablix_id [report_component_id],
               rpt.page_id,
               NULL [type],
               rpt.[top],
               rpt.[left],
               rpt.[width],
               rpt.[height],
               rpt.[name],
               NULL [y_axis_caption],
               NULL [x_axis_caption],
               rpt.group_mode,
               rpt.border_style,
               rpt.page_break,
               rpt.type_id,
               rpt.cross_summary,
               rpt.no_header
        FROM   ' + @rfx_report_page_tablix + ' rpt
        WHERE  rpt.page_id = ' + @page_id + '
		'
		EXEC(@sql)
	END
		
	ELSE
		EXEC spa_ErrorHandler 0, 'Reporting FX', 'spa_rfx_rdl_maker_preview_dhx', 'Failed', 'Data selection failed.', '0'
END

IF @flag = 't'
BEGIN
	IF @page_id IS NOT NULL AND @page_tablix_id IS NOT NULL
	BEGIN
		SET @sql = '
		SELECT DISTINCT rtc.column_order,
                dsc.[name] [column_name],
                rpt.report_page_tablix_id,
                rtc.report_tablix_column_id,
                rtc.placement,
                rtc.aggregation,
                rtc.functions,
                rtc.alias,
                rtc.sortable,
                rtc.rounding,
                rtc.thousand_seperation,
                rtc.font,
                rtc.font_size,
                rtc.font_style,
                rtc.text_align,
                rtc.text_color,
                rth.font AS h_font,
                rth.font_size AS h_font_size,
                rth.font_style AS h_font_style,
                rth.text_align AS h_text_align,
                rth.text_color AS h_text_color,
                rtc.default_sort_order,
                rtc.default_sort_direction,
                rtc.background,
                rth.background AS h_background,
                rtc.dataset_id,
                rtc.custom_field,
                ''t'' as [display_type],
                dsc.datatype_id,
                rtc.render_as,
                rpt.border_style,
                rpt.page_break,
                rtc.negative_mark,
                rtc.currency,
                rtc.date_format,
                rtc.cross_summary_aggregation,
                rtc.mark_for_total,
                rtc.sql_aggregation,
				rtc.subtotal
        FROM   ' + @rfx_report_page_tablix + ' rpt
        INNER JOIN ' + @rfx_report_tablix_column + ' rtc ON  rtc.tablix_id = rpt.report_page_tablix_id
        LEFT JOIN data_source_column dsc ON  dsc.data_source_column_id = rtc.column_id
        LEFT JOIN ' + @rfx_report_tablix_header + ' rth ON  rth.tablix_id = rtc.tablix_id
			AND rth.report_tablix_column_id = rtc.report_tablix_column_id
        WHERE rpt.page_id = ' + @page_id + '
            AND rpt.report_page_tablix_id = ' + @page_tablix_id + '
        ORDER BY rtc.placement DESC,rtc.column_order ASC
		'
		EXEC(@sql)
	END
		
	ELSE
		EXEC spa_ErrorHandler 0, 'Reporting FX', 'spa_rfx_rdl_maker_preview_dhx', 'Failed', 'Data selection failed.', '0'
END

IF @flag = 'c'
BEGIN
	IF @page_id IS NOT NULL AND @page_chart_id IS NOT NULL
	BEGIN
		SET @sql = '
		SELECT DISTINCT rcc.column_order,
                dsc.[name] [column_name],
                NULL as [report_page_tablix_id],
                NULL as [report_tablix_column_id],
                rcc.placement,
                NULL as [aggregation],
                NULL as [functions],
                rcc.alias [alias],
                NULL as [sortable],
                NULL as [rounding],
                NULL as [thousand_seperation],
                NULL as [font],
                NULL as [font_size],
                NULL as [font_style],
                NULL as [text_align],
                NULL as [text_color],
                NULL as [default_sort_order],
                NULL as [default_sort_direction],
                NULL as [background],
                NULL as [dataset_id],
                rcc.[custom_field],
                ''c'' as [display_type],
                dsc.datatype_id,
                [page_break],
                rcc.render_as_line
        FROM   ' + @rfx_report_page_chart + ' rpc
        INNER JOIN ' + @rfx_report_chart_column + ' rcc ON  rcc.chart_id = rpc.report_page_chart_id
        LEFT JOIN data_source_column dsc ON  dsc.data_source_column_id = rcc.column_id
        WHERE  rpc.page_id = ' + @page_id + '
            AND rpc.report_page_chart_id = ' + @page_chart_id + '
        ORDER BY rcc.placement,rcc.column_order ASC
		'
		EXEC(@sql)
	END
		
	ELSE
		EXEC spa_ErrorHandler 0, 'Reporting FX', 'spa_rfx_rdl_maker_preview_dhx', 'Failed', 'Data selection failed.', '0'
END

IF @flag = 'b'
BEGIN
	IF @page_id IS NOT NULL
	BEGIN
		SET @sql = '
		SELECT  rpt.report_page_textbox_id,
                rpt.content,
                rpt.font,
                rpt.font_size,
                rpt.font_style,
                rpt.width,
                rpt.height,
                rpt.[top],
                rpt.[left] 
        FROM   ' + @rfx_report_page_textbox + ' rpt
        WHERE  rpt.page_id = ' + @page_id + '
		'
		EXEC(@sql)
	END
		
	ELSE
		EXEC spa_ErrorHandler 0, 'Reporting FX', 'spa_rfx_rdl_maker_preview_dhx', 'Failed', 'Data selection failed.', '0'
END

IF @flag = 'l'
BEGIN
	IF @page_id IS NOT NULL
	BEGIN
		SET @sql = '
		SELECT  rpt.report_page_line_id,
                rpt.color,
                rpt.size,
                rpt.style,
                rpt.width,
                rpt.height,
                rpt.[top],
                rpt.[left] 
        FROM   ' + @rfx_report_page_line + ' rpt
        WHERE  rpt.page_id = ' + @page_id + '
		'
		EXEC(@sql)
	END
		
	ELSE
		EXEC spa_ErrorHandler 0, 'Reporting FX', 'spa_rfx_rdl_maker_preview_dhx', 'Failed', 'Data selection failed.', '0'
END

IF @flag = 'j'
BEGIN
	IF @page_id IS NOT NULL
	BEGIN
		SET @sql = '
		SELECT  rpt.report_page_image_id,
                rpt.name,
                rpt.width,
                rpt.height,
                rpt.[top],
                rpt.[left] 
        FROM   ' + @rfx_report_page_image + ' rpt
        WHERE  rpt.page_id = ' + @page_id + '
		'
		EXEC(@sql)
	END
		
	ELSE
		EXEC spa_ErrorHandler 0, 'Reporting FX', 'spa_rfx_rdl_maker_preview_dhx', 'Failed', 'Data selection failed.', '0'
END


IF @flag = 'g' --gauges
BEGIN
	IF @page_id IS NOT NULL   
	BEGIN
		SET @sql = '
		SELECT rpg.root_dataset_id [root_dataset_id],
			   ''g'' [display_type],
			   rpg.report_page_gauge_id [report_component_id],
			   rpg.page_id,
			   rpg.[type_id] [type],
			   rpg.[top],
			   rpg.[left],
			   rpg.[width],
			   rpg.[height],
			   rpg.[name],
			   REPLACE(rpg.name, '' '','''') [alias],			   
			   dsc.[name] [gauge_label]			   
		FROM   ' + @rfx_report_page_gauge + ' rpg
		LEFT JOIN data_source_column dsc ON dsc.data_source_column_id = rpg.gauge_label_column_id
		WHERE  rpg.page_id = ' + @page_id + '
		'
		EXEC(@sql)
	END                     
		
	ELSE
		EXEC spa_ErrorHandler 0, 'Reporting FX', 'spa_rfx_rdl_maker_preview_dhx', 'Failed', 'Data selection failed.', '0'
END


IF @flag = 'h' -- gauge_column
BEGIN
	IF @page_id IS NOT NULL AND @page_gauge_id IS NOT NULL
	BEGIN
		SET @sql = '
		SELECT DISTINCT rgc.column_order,
				dsc.[name] [column_name],
				rgc.report_gauge_column_id as [report_gauge_column_id],
				''g'' as [display_type],
				dsc.datatype_id,
				rgc.scale_minimum,
				rgc.scale_maximum,
				rgc.scale_interval,
				dsc.alias,
				rgc.aggregation,
				rgc.functions,				
				rgc.rounding,
				rgc.thousand_seperation,
				rgc.font,
				rgc.font_size,
				rgc.font_style,
				rgc.text_color,
				rgc.dataset_id,
				rgc.custom_field,
				rgc.render_as			   
		FROM   ' + @rfx_report_page_gauge + ' rpg
		INNER JOIN ' + @rfx_report_gauge_column + ' rgc ON  rgc.gauge_id = rpg.report_page_gauge_id
		INNER JOIN data_source_column dsc ON  dsc.data_source_column_id = rgc.column_id
		WHERE  rpg.page_id = ' + @page_id + '
			AND rpg.report_page_gauge_id =  ' + @page_gauge_id + '
		
		UNION
		
		SELECT 100 column_order,
			   dsc.[name] [column_name],
			   rgc.report_gauge_column_id as [report_gauge_column_id],
			   ''g'' as [display_type],
			   dsc.datatype_id,
			   NULL scale_minimum,
			   NULL scale_maximum,
			   NULL scale_interval,
			   dsc.alias,
			   rgc.aggregation,
				rgc.functions,
				rgc.rounding,
				rgc.thousand_seperation,
				rgc.font,
				rgc.font_size,
				rgc.font_style,
				rgc.text_color,
				rgc.dataset_id,
				rgc.custom_field,
				rgc.render_as			   	   
		FROM   ' + @rfx_report_page_gauge + ' rpg
		INNER JOIN ' + @rfx_report_gauge_column + ' rgc ON  rgc.gauge_id = rpg.report_page_gauge_id
		INNER JOIN data_source_column dsc ON  dsc.data_source_column_id = rpg.gauge_label_column_id
		WHERE  rpg.page_id = ' + @page_id + '
			AND rpg.report_page_gauge_id =  ' + @page_gauge_id + '
		
		ORDER BY rgc.column_order ASC
		'
		EXEC(@sql)
	END
		
	ELSE
		EXEC spa_ErrorHandler 0, 'Reporting FX', 'spa_rfx_rdl_maker_preview_dhx', 'Failed', 'Data selection failed.', '0'
END

IF @flag = 'r' -- gauge_scale_range
BEGIN
	IF @page_id IS NOT NULL AND @page_gauge_id IS NOT NULL
	BEGIN
		SET @sql = '
		SELECT rgc.column_id,
				CAST(ROW_NUMBER() OVER (ORDER BY dsc.[name]) AS VARCHAR) + ''_'' + dsc.[name] [name],
		       rgcs.scale_start,
		       rgcs.scale_end,
		       rgcs.scale_range_color
		FROM   ' + @rfx_report_gauge_column + ' rgc
		INNER JOIN ' + @rfx_report_gauge_column_scale + ' rgcs ON  rgcs.report_gauge_column_id = rgc.report_gauge_column_id
		LEFT JOIN data_source_column dsc ON  dsc.data_source_column_id = rgc.column_id
		WHERE rgc.gauge_id = ' + @page_gauge_id	+ '
			AND rgcs.report_gauge_column_id = ' + @gauge_column_id + '
		ORDER BY rgcs.scale_start
		'
		EXEC(@sql)
	END
		
	ELSE
		EXEC spa_ErrorHandler 0, 'Reporting FX', 'spa_rfx_rdl_maker_preview_dhx', 'Failed', 'Data selection failed.', '0'
END