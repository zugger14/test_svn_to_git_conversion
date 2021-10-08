IF OBJECT_ID(N'[dbo].[spa_rfx_rdl_maker]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_rfx_rdl_maker]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

/**
	Required data extraction operations for making RDL file.
	Parameters
	@flag				:	Selection variation flag
	@report_id			:	Report Id
	@page_id			:	Page Id
	@page_chart_id		:	Chart Item Id
	@page_tablix_id		:	Tablix Item Id
	@page_gauge_id		:	Gauge Item Id
	@gauge_column_id	:	Gauge Column Id

	Note: Report Page Width and Height are set to 8.5 and 11 as standard body properties of ssrs is A4 size. Greater than either of attributes will result page breakdown.
*/
CREATE PROCEDURE [dbo].[spa_rfx_rdl_maker]
    @flag CHAR(1),
    @report_id INT = NULL,
    @page_id INT   = NULL,
    @page_chart_id INT = NULL,
    @page_tablix_id INT = NULL,
    @page_gauge_id INT = NULL,
    @gauge_column_id INT = NULL	
AS

DECLARE @user_name                       VARCHAR(50),
        @sql                             VARCHAR(MAX),
        @report_name_separator			 VARCHAR(2)

SET @user_name = dbo.FNADBUser()
SET @report_name_separator = '_'

IF @flag = 's'
BEGIN
	IF @report_id IS NOT NULL
		SELECT rp.report_page_id, rp.[name] FROM report_page rp WHERE rp.report_id = @report_id
	ELSE
		EXEC spa_ErrorHandler 0, 'Reporting FX', 'spa_rfx_rdl_maker', 'Failed', 'Data selection failed.', '0'
END

IF @flag = 'a'
BEGIN
	IF @page_id IS NOT NULL
		SELECT r.report_id,
               r.[name] + @report_name_separator + rp.[name] [name],       
               r.report_hash,
               --rp.width,
			   '8.5' AS width,
               --rp.height
			   '11' AS height
        FROM   report r
        INNER JOIN report_page rp ON  rp.report_id = r.report_id
        WHERE rp.report_page_id = @page_id
	ELSE
		EXEC spa_ErrorHandler 0, 'Reporting FX', 'spa_rfx_rdl_maker', 'Failed', 'Data selection failed.', '0'
END

IF @flag = 'i'
BEGIN
	IF @page_id IS NOT NULL
		SELECT rpt.root_dataset_id [root_dataset_id],
               REPLACE(rpt.name, ' ','') [alias],
               NULL [report_dataset_paramset_id],
               't' [display_type],
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
        FROM   report_page_tablix rpt
        WHERE  rpt.page_id = @page_id
        
        UNION 
        
        SELECT rpt.root_dataset_id [root_dataset_id],
               REPLACE(rpt.name, ' ','') [alias],
               NULL [report_dataset_paramset_id],
               'c' [display_type],
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
        FROM   report_page_chart rpt
        WHERE  rpt.page_id = @page_id
	ELSE
		EXEC spa_ErrorHandler 0, 'Reporting FX', 'spa_rfx_rdl_maker', 'Failed', 'Data selection failed.', '0'
END

IF @flag = 'p'
BEGIN
	IF @page_id IS NOT NULL                        
        SELECT rpt.root_dataset_id [root_dataset_id],
               REPLACE(rpt.name, ' ','') [alias],
               NULL [report_dataset_paramset_id],
               'c' [display_type],
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
        FROM   report_page_chart rpt
        WHERE  rpt.page_id = @page_id
	ELSE
		EXEC spa_ErrorHandler 0, 'Reporting FX', 'spa_rfx_rdl_maker', 'Failed', 'Data selection failed.', '0'
END

IF @flag = 'm'
BEGIN
	IF @page_id IS NOT NULL
		SELECT rpt.root_dataset_id [root_dataset_id],
               REPLACE(rpt.name, ' ','') [alias],
               NULL [report_dataset_paramset_id],
               't' [display_type],
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
        FROM   report_page_tablix rpt
        WHERE  rpt.page_id = @page_id
	ELSE
		EXEC spa_ErrorHandler 0, 'Reporting FX', 'spa_rfx_rdl_maker', 'Failed', 'Data selection failed.', '0'
END

IF @flag = 't'
BEGIN
	IF @page_id IS NOT NULL AND @page_tablix_id IS NOT NULL
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
					   dsc2.sorting_column AS sorting_column,dsc2.sorting_datatype_id,
                       rtc.default_sort_direction,
                       rtc.background,
                       rth.background AS h_background,
                       rtc.dataset_id,
                       rtc.custom_field,
                       't' as [display_type],
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
                FROM   report_page_tablix rpt
                INNER JOIN report_tablix_column rtc ON  rtc.tablix_id = rpt.report_page_tablix_id
                LEFT JOIN data_source_column dsc ON  dsc.data_source_column_id = rtc.column_id
                LEFT JOIN report_tablix_header rth ON  rth.tablix_id = rtc.tablix_id
					AND rth.report_tablix_column_id = rtc.report_tablix_column_id
				OUTER APPLY (
					SELECT ISNULL(dsc3.alias, dsc3.[name]) AS sorting_column, dsc3.datatype_id AS sorting_datatype_id
					FROM data_source_column dsc3 
					left join report_tablix_column rtc3 on rtc3.column_id = CAST(rtc.sorting_column AS INT)
					WHERE dsc3.data_source_column_id = CAST(rtc.sorting_column AS INT)
				) dsc2
                WHERE rpt.page_id = @page_id
                    AND rpt.report_page_tablix_id =  @page_tablix_id
                ORDER BY rtc.placement DESC,rtc.column_order ASC
	ELSE
		EXEC spa_ErrorHandler 0, 'Reporting FX', 'spa_rfx_rdl_maker', 'Failed', 'Data selection failed.', '0'
END

IF @flag = 'c'
BEGIN
	IF @page_id IS NOT NULL AND @page_chart_id IS NOT NULL
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
					   dsc2.sorting_column AS sorting_column,dsc2.sorting_datatype_id,
                       NULL as [default_sort_direction],
                       NULL as [background],
                       NULL as [dataset_id],
                       rcc.[custom_field],
                       'c' as [display_type],
                       dsc.datatype_id,
                       [page_break],
                       rcc.render_as_line
                FROM   report_page_chart rpc
                INNER JOIN report_chart_column rcc ON  rcc.chart_id = rpc.report_page_chart_id
                LEFT JOIN data_source_column dsc ON  dsc.data_source_column_id = rcc.column_id
				OUTER APPLY (
					SELECT ISNULL(dsc3.alias, dsc3.[name]) AS sorting_column, dsc3.datatype_id AS sorting_datatype_id
					FROM data_source_column dsc3 
					left join report_chart_column rcc3 on rcc3.column_id = CAST(rcc.sorting_column AS INT)
					WHERE dsc3.data_source_column_id = CAST(rcc.sorting_column AS INT)
				) dsc2
                WHERE  rpc.page_id = @page_id
                    AND rpc.report_page_chart_id =  @page_chart_id
                ORDER BY rcc.placement,rcc.column_order ASC
	ELSE
		EXEC spa_ErrorHandler 0, 'Reporting FX', 'spa_rfx_rdl_maker', 'Failed', 'Data selection failed.', '0'
END

IF @flag = 'b'
BEGIN
	IF @page_id IS NOT NULL
		SELECT  rpt.report_page_textbox_id,
                rpt.content,
                rpt.font,
                rpt.font_size,
                rpt.font_style,
                rpt.width,
                rpt.height,
                rpt.[top],
                rpt.[left] 
        FROM   report_page_textbox rpt
        WHERE  rpt.page_id = @page_id
	ELSE
		EXEC spa_ErrorHandler 0, 'Reporting FX', 'spa_rfx_rdl_maker', 'Failed', 'Data selection failed.', '0'
END

IF @flag = 'l'
BEGIN
	IF @page_id IS NOT NULL
		SELECT  rpt.report_page_line_id,
                rpt.color,
                rpt.size,
                rpt.style,
                rpt.width,
                rpt.height,
                rpt.[top],
                rpt.[left] 
        FROM   report_page_line rpt
        WHERE  rpt.page_id = @page_id
	ELSE
		EXEC spa_ErrorHandler 0, 'Reporting FX', 'spa_rfx_rdl_maker', 'Failed', 'Data selection failed.', '0'
END

IF @flag = 'j'
BEGIN
	IF @page_id IS NOT NULL
		SELECT  rpt.report_page_image_id,
                rpt.name,
                rpt.width,
                rpt.height,
                rpt.[top],
                rpt.[left] 
        FROM   report_page_image rpt
        WHERE  rpt.page_id = @page_id
	ELSE
		EXEC spa_ErrorHandler 0, 'Reporting FX', 'spa_rfx_rdl_maker', 'Failed', 'Data selection failed.', '0'
END


IF @flag = 'g' --gauges
BEGIN
	IF @page_id IS NOT NULL                        
		SELECT rpg.root_dataset_id [root_dataset_id],
			   'g' [display_type],
			   rpg.report_page_gauge_id [report_component_id],
			   rpg.page_id,
			   rpg.[type_id] [type],
			   rpg.[top],
			   rpg.[left],
			   rpg.[width],
			   rpg.[height],
			   rpg.[name],
			   REPLACE(rpg.name, ' ','') [alias],			   
			   dsc.[name] [gauge_label]			   
		FROM   report_page_gauge rpg
		LEFT JOIN data_source_column dsc ON dsc.data_source_column_id = rpg.gauge_label_column_id
		WHERE  rpg.page_id = @page_id
	ELSE
		EXEC spa_ErrorHandler 0, 'Reporting FX', 'spa_rfx_rdl_maker', 'Failed', 'Data selection failed.', '0'
END


IF @flag = 'h' -- gauge_column
BEGIN
	IF @page_id IS NOT NULL AND @page_gauge_id IS NOT NULL
		SELECT DISTINCT rgc.column_order,
				dsc.[name] [column_name],
				rgc.report_gauge_column_id as [report_gauge_column_id],
				'g' as [display_type],
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
		FROM   report_page_gauge rpg
		INNER JOIN report_gauge_column rgc ON  rgc.gauge_id = rpg.report_page_gauge_id
		INNER JOIN data_source_column dsc ON  dsc.data_source_column_id = rgc.column_id
		WHERE  rpg.page_id = @page_id
			AND rpg.report_page_gauge_id =  @page_gauge_id
		
		UNION
		
		SELECT 100 column_order,
			   dsc.[name] [column_name],
			   rgc.report_gauge_column_id as [report_gauge_column_id],
			   'g' as [display_type],
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
		FROM   report_page_gauge rpg
		INNER JOIN report_gauge_column rgc ON  rgc.gauge_id = rpg.report_page_gauge_id
		INNER JOIN data_source_column dsc ON  dsc.data_source_column_id = rpg.gauge_label_column_id
		WHERE  rpg.page_id = @page_id
			AND rpg.report_page_gauge_id =  @page_gauge_id		
		
		ORDER BY rgc.column_order ASC
	ELSE
		EXEC spa_ErrorHandler 0, 'Reporting FX', 'spa_rfx_rdl_maker', 'Failed', 'Data selection failed.', '0'
END

IF @flag = 'r' -- gauge_scale_range
BEGIN
	IF @page_id IS NOT NULL AND @page_gauge_id IS NOT NULL
		SELECT rgc.column_id,
				CAST(ROW_NUMBER() OVER (ORDER BY dsc.[name]) AS VARCHAR) + '_' + dsc.[name] [name],
		       rgcs.scale_start,
		       rgcs.scale_end,
		       rgcs.scale_range_color
		FROM   report_gauge_column rgc
		INNER JOIN report_gauge_column_scale rgcs ON  rgcs.report_gauge_column_id = rgc.report_gauge_column_id
		LEFT JOIN data_source_column dsc ON  dsc.data_source_column_id = rgc.column_id
		WHERE rgc.gauge_id = @page_gauge_id	
			AND rgcs.report_gauge_column_id = @gauge_column_id
		ORDER BY rgcs.scale_start
	ELSE
		EXEC spa_ErrorHandler 0, 'Reporting FX', 'spa_rfx_rdl_maker', 'Failed', 'Data selection failed.', '0'
END