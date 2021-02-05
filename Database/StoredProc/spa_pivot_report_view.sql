IF OBJECT_ID(N'[dbo].[spa_pivot_report_view]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_pivot_report_view]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===============================================================================================================
-- Author: rajiv@pioneersolutionsglobal.com
-- Create date: 2008-09-09
-- Description: Description of the functionality in brief.
 
-- Params:
-- @flag CHAR(1)        - Description of param2
-- @param1 VARCHAR(100) - Description of param3
-- ===============================================================================================================
/**
	
	Parameters
	@flag				: 's' get pivot report view header informations for matched view id
						  't' get pivot report view columns innformation for matched view id
						  'i' insert/update pivot report view 
						  'd' delete pivot report view
						  'p' copy pivot report view
	@view_id			: View Id
	@view_name			: View Name
	@paramset_hash		: Paramset Hash
	@row_fields			: Row Fields comma separated
	@column_fields		: Column Fields comma separated
	@detail_fields		: Detail Fields comma separated
	@renderer			: Renderer (table, crosstab table, charts)
	@xml_string			: Xml String
	@grid_xml			: Pivot report view columns information in XML format. (extracted from grid UI)
	@pin_it				: Pin It flag
	@report_filter		: Report Filter string
	@report_id			: Report Id
	@user_report_name	: User Report Name
	@xaxis_label		: Xaxis Label
	@yaxis_label		: Yaxis Label
	@group_id			: Group Id
	@group_name			: Group Name
	@dashboard_id		: Dashboard Id
	@replace_params		: Process table name for Replace Parameter information
	@is_public			: Is Public flag
	@report_type		: Report Type
	@report_paramset_id	: Report Paramset ID
	@pivot_file_sql		: Query to generate pivot file
	@paramset_id	: report_paramset_id from view report to process for pivot.
	@component_id	: component_id (item_id i.e. tablix_id,chart_id,gauge_id,etc) of the report item.
*/
CREATE PROCEDURE [dbo].[spa_pivot_report_view]
    @flag CHAR(1),
    @view_id INT = NULL,
    @view_name VARCHAR(500) = NULL,
    @paramset_hash VARCHAR(500) = NULL,
    @row_fields	VARCHAR(MAX) = NULL,
    @column_fields VARCHAR(MAX) = NULL,
    @detail_fields	VARCHAR(MAX) = NULL,
    @renderer VARCHAR(50) = NULL,
	@xml_string XML = NULL,
	@grid_xml XML = NULL,
	@pin_it BIT = NULL,
	@report_filter VARCHAR(MAX) = NULL,
	@report_id INT = NULL,
	@user_report_name VARCHAR(1000) = NULL,
	@xaxis_label VARCHAR(1000) = NULL,
    @yaxis_label VARCHAR(1000) = NULL,
    @group_id INT = NULL,
    @group_name VARCHAR(200) = NULL,
    @dashboard_id INT = NULL,
    @replace_params XML = NULL,
	@is_public BIT = NULL,
	@report_type INT = NULL,
	@report_paramset_id INT = NULL,
	@pivot_file_sql NVARCHAR(MAX) = NULL,
	@paramset_id			INT = NULL,
	@component_id			 VARCHAR(500) = NULL
    
AS
SET NOCOUNT ON 
DECLARE @sql VARCHAR(MAX)
DECLARE @DESC VARCHAR(500)
DECLARE @err_no INT
DECLARE @new_id INT

DECLARE @user_name VARCHAR(100) = dbo.FNADBUser()
DECLARE @process_id VARCHAR(100) = dbo.FNAGetNewId()
DECLARE @is_admin INT = dbo.FNAIsUserOnAdminGroup(@user_name, 1)
 
IF @flag IN ('s','1')
BEGIN
	DECLARE @pivot_cols_formatting_info NVARCHAR(MAX)
	IF @flag = '1'
	BEGIN
		EXEC(@pivot_file_sql)
		 
			IF EXISTS(SELECT 1 FROM pivot_report_view_columns WHERE pivot_report_view_id = @view_id)
			BEGIN
			SET @pivot_cols_formatting_info = (
			SELECT '' [id],
				prvc.columns_name,
				prvc.label,
					COALESCE(prvc.render_as,tbl.render_as) render_as,
				prvc.date_format,
				prvc.currency,
					COALESCE(prvc.thou_sep, tbl.thousand_seperation) thou_sep,
					CASE WHEN COALESCE(prvc.rounding, tbl.rounding) = '-1' AND COALESCE(prvc.render_as,tbl.render_as) IN ('a', 'v', 'n', 'r') 
						 THEN CASE COALESCE(prvc.render_as,tbl.render_as) WHEN 'a' THEN tbl_rounding.amount_rounding
																		  WHEN 'v' THEN tbl_rounding.volume_rounding
																		  WHEN 'n' THEN tbl_rounding.number_rounding
																		  WHEN 'r' THEN tbl_rounding.price_rounding
						 ELSE COALESCE(prvc.rounding, tbl.rounding) END
					ELSE COALESCE(prvc.rounding, tbl.rounding) END rounding,
				prvc.neg_as_red
			FROM pivot_report_view_columns prvc
				OUTER APPLY (
					SELECT CASE rtc.render_as  WHEN 0 THEN 't'
											   WHEN 1 THEN 't'
											   WHEN 2 THEN 'n'
											   WHEN 3 THEN 'a'
											   WHEN 4 THEN 'd'
											   WHEN 5 THEN 'p'
											   WHEN 6 THEN 't'
											   WHEN 13 THEN 'r'
											   WHEN 14 THEN 'v'
							ELSE '' END render_as 
						, CASE rtc.thousand_seperation WHEN 0 THEN '-1'
													   WHEN 1 THEN 'y'
													   WHEN 2 THEN 'n'
						  END thousand_seperation
						, rtc.rounding
					FROM report_paramset rp
					INNER JOIN report_page_tablix rpt ON  rpt.page_id = rp.page_id 
					INNER JOIN report_tablix_column rtc
						ON rtc.tablix_id = rpt.report_page_tablix_id
					INNER JOIN data_source_column dsc
						ON dsc.data_source_column_id = rtc.column_id
					WHERE report_paramset_id = @paramset_id
						AND rpt.report_page_tablix_id = @component_id
						AND rtc.[alias] = prvc.columns_name
				) tbl
				OUTER APPLY( SELECT price_rounding,volume_rounding,amount_rounding,number_rounding
							 FROM company_info
				) tbl_rounding
			WHERE prvc.pivot_report_view_id = @view_id
			FOR JSON PATH
			,INCLUDE_NULL_VALUES
			)
		END
			ELSE
			BEGIN		
				SET @pivot_cols_formatting_info = ( 
				SELECT '' [id],
					tbl_column.columns_name,
					tbl_column.columns_name [label],
					tbl.render_as,
					CASE WHEN tbl.rounding = '-1' AND tbl.render_as IN ('a', 'v', 'n', 'r') 
						 THEN CASE tbl.render_as WHEN 'a' THEN tbl_rounding.amount_rounding
																		  WHEN 'v' THEN tbl_rounding.volume_rounding
																		  WHEN 'n' THEN tbl_rounding.number_rounding
																		  WHEN 'r' THEN tbl_rounding.price_rounding
						 ELSE tbl.rounding END
					ELSE tbl.rounding END rounding,
					tbl.thousand_seperation thou_sep
				FROM   pivot_report_view prv
				CROSS APPLY(
					SELECT item columns_name
					FROM dbo.FNASplit(prv.row_fields,',')
					UNION SELECT item columns_name
					FROM dbo.FNASplit(prv.columns_fields,',')
					UNION SELECT IIF(CHARINDEX('|',REPLACE(item,'||||','|')) = 0, REPLACE(item,'||||','|'),SUBSTRING(REPLACE(item,'||||','|'), CHARINDEX('|',REPLACE(item,'||||','|')) + 1 , LEN(REPLACE(item,'||||','|')))) columns_name
					FROM dbo.FNASplit(prv.detail_fields,',')
				) tbl_column
				OUTER APPLY (
					SELECT CASE rtc.render_as  WHEN 0 THEN 't'
											   WHEN 1 THEN 't'
											   WHEN 2 THEN 'n'
											   WHEN 3 THEN 'a'
											   WHEN 4 THEN 'd'
											   WHEN 5 THEN 'p'
											   WHEN 6 THEN 't'
											   WHEN 13 THEN 'r'
											   WHEN 14 THEN 'v'
							ELSE '' END render_as 
						, CASE rtc.thousand_seperation WHEN 0 THEN '-1'
													   WHEN 1 THEN 'y'
													   WHEN 2 THEN 'n'
						  END thousand_seperation
						, rtc.rounding
					FROM report_paramset rp
					INNER JOIN report_page_tablix rpt ON  rpt.page_id = rp.page_id 
					INNER JOIN report_tablix_column rtc
						ON rtc.tablix_id = rpt.report_page_tablix_id
					INNER JOIN data_source_column dsc
						ON dsc.data_source_column_id = rtc.column_id
					WHERE report_paramset_id = @paramset_id
						AND rpt.report_page_tablix_id = @component_id
						AND rtc.[alias] = tbl_column.columns_name
				) tbl
				OUTER APPLY( SELECT price_rounding,volume_rounding,amount_rounding,number_rounding
							 FROM company_info
				) tbl_rounding
				WHERE prv.pivot_report_view_id = @view_id
				FOR JSON PATH
				,INCLUDE_NULL_VALUES
				)
			END
	   END
		
    SELECT prv.row_fields,
           prv.columns_fields,
           prv.detail_fields,
           prv.renderer,
           ISNULL(prv.pin_it, 0) pin_it,
           prv.user_report_name,
           prv.xaxis_label,
           prv.yaxis_label,
           prv.report_group_id,
		   ISNULL(prv.is_public, 0) is_public,
		   @pivot_cols_formatting_info [pivot_cols_formatting_info]
    FROM   pivot_report_view prv
    WHERE prv.pivot_report_view_id = @view_id
END

IF @flag = 't'
BEGIN
	IF EXISTS(SELECT 1 FROM pivot_report_view_columns WHERE pivot_report_view_id = @view_id)
	BEGIN
		SELECT '' [id],
				prvc.columns_name,
				prvc.label,
					COALESCE(prvc.render_as,tbl.render_as) render_as,
				prvc.date_format,
				prvc.currency,
					COALESCE(prvc.thou_sep, tbl.thousand_seperation) thou_sep,
					CASE WHEN COALESCE(prvc.rounding, tbl.rounding) = '-1' AND COALESCE(prvc.render_as,tbl.render_as) IN ('a', 'v', 'n', 'r') 
						 THEN CASE COALESCE(prvc.render_as,tbl.render_as) WHEN 'a' THEN tbl_rounding.amount_rounding
																		  WHEN 'v' THEN tbl_rounding.volume_rounding
																		  WHEN 'n' THEN tbl_rounding.number_rounding
																		  WHEN 'r' THEN tbl_rounding.price_rounding
						 ELSE COALESCE(prvc.rounding, tbl.rounding) END
					ELSE COALESCE(prvc.rounding, tbl.rounding) END rounding,
				prvc.neg_as_red
			FROM pivot_report_view_columns prvc
				OUTER APPLY (
					SELECT CASE rtc.render_as  WHEN 0 THEN 't'
											   WHEN 1 THEN 't'
											   WHEN 2 THEN 'n'
											   WHEN 3 THEN 'a'
											   WHEN 4 THEN 'd'
											   WHEN 5 THEN 'p'
											   WHEN 6 THEN 't'
											   WHEN 13 THEN 'r'
											   WHEN 14 THEN 'v'
							ELSE '' END render_as 
						, CASE rtc.thousand_seperation WHEN 0 THEN '-1'
													   WHEN 1 THEN 'y'
													   WHEN 2 THEN 'n'
						  END thousand_seperation
						, rtc.rounding
					FROM report_paramset rp
					INNER JOIN report_page_tablix rpt ON  rpt.page_id = rp.page_id 
					INNER JOIN report_tablix_column rtc
						ON rtc.tablix_id = rpt.report_page_tablix_id
					INNER JOIN data_source_column dsc
						ON dsc.data_source_column_id = rtc.column_id
					WHERE report_paramset_id = @paramset_id
						AND rpt.report_page_tablix_id = @component_id
						AND rtc.[alias] = prvc.columns_name
				) tbl
				OUTER APPLY( SELECT price_rounding,volume_rounding,amount_rounding,number_rounding
							 FROM company_info
				) tbl_rounding
			WHERE prvc.pivot_report_view_id = @view_id
	END
	ELSE
	BEGIN
		SELECT '' [id],
					tbl_column.columns_name,
					tbl_column.columns_name [label],
					tbl.render_as,
					CASE WHEN tbl.rounding = '-1' AND tbl.render_as IN ('a', 'v', 'n', 'r') 
						 THEN CASE tbl.render_as WHEN 'a' THEN tbl_rounding.amount_rounding
																		  WHEN 'v' THEN tbl_rounding.volume_rounding
																		  WHEN 'n' THEN tbl_rounding.number_rounding
																		  WHEN 'r' THEN tbl_rounding.price_rounding
						 ELSE tbl.rounding END
					ELSE tbl.rounding END rounding,
					tbl.thousand_seperation thou_sep
				FROM   pivot_report_view prv
				CROSS APPLY(
					SELECT item columns_name
					FROM dbo.FNASplit(prv.row_fields,',')
					UNION SELECT item columns_name
					FROM dbo.FNASplit(prv.columns_fields,',')
					UNION SELECT IIF(CHARINDEX('|',REPLACE(item,'||||','|')) = 0, REPLACE(item,'||||','|'),SUBSTRING(REPLACE(item,'||||','|'), CHARINDEX('|',REPLACE(item,'||||','|')) + 1 , LEN(REPLACE(item,'||||','|')))) columns_name
					FROM dbo.FNASplit(prv.detail_fields,',')
				) tbl_column
				OUTER APPLY (
					SELECT CASE rtc.render_as  WHEN 0 THEN 't'
											   WHEN 1 THEN 't'
											   WHEN 2 THEN 'n'
											   WHEN 3 THEN 'a'
											   WHEN 4 THEN 'd'
											   WHEN 5 THEN 'p'
											   WHEN 6 THEN 't'
											   WHEN 13 THEN 'r'
											   WHEN 14 THEN 'v'
							ELSE '' END render_as 
						, CASE rtc.thousand_seperation WHEN 0 THEN '-1'
													   WHEN 1 THEN 'y'
													   WHEN 2 THEN 'n'
						  END thousand_seperation
						, rtc.rounding
					FROM report_paramset rp
					INNER JOIN report_page_tablix rpt ON  rpt.page_id = rp.page_id 
					INNER JOIN report_tablix_column rtc
						ON rtc.tablix_id = rpt.report_page_tablix_id
					INNER JOIN data_source_column dsc
						ON dsc.data_source_column_id = rtc.column_id
					WHERE report_paramset_id = @paramset_id
						AND rpt.report_page_tablix_id = @component_id
						AND rtc.[alias] = tbl_column.columns_name
				) tbl
				OUTER APPLY( SELECT price_rounding,volume_rounding,amount_rounding,number_rounding
							 FROM company_info
				) tbl_rounding
				WHERE prv.pivot_report_view_id = @view_id
	END
END

IF @flag = 'k' OR @flag = 'v'
BEGIN
	IF @report_paramset_id IS NOT NULL
	BEGIN
		SELECT @paramset_hash = paramset_hash FROM report_paramset WHERE report_paramset_id = @report_paramset_id
	END

	IF @flag = 'k'
	BEGIN
		SET @sql = '
		SELECT DISTINCT prv.pivot_report_view_id, prv.pivot_report_view_name
		FROM   pivot_report_view prv
		'
	END
	ELSE
	BEGIN
		SET @sql = '
		SELECT DISTINCT 
			 prv.pivot_report_view_id, 
			 prv.pivot_report_view_name + ''['' + rp.name + '']'' [name]
		FROM pivot_report_view prv
		'
	END

	IF @is_admin = 0
	BEGIN
		IF @report_type = 1
		BEGIN
			SET @sql += '
				LEFT JOIN report_paramset rp ON rp.paramset_hash = prv.paramset_hash
				LEFT JOIN report_page rp2 ON rp.page_id = rp2.report_page_id
				LEFT JOIN report_privilege rp3 
					ON rp2.report_hash = rp3.report_hash
					AND (rp3.[user_id] = ''' + @user_name + ''' OR rp3.role_id IN (SELECT fur.role_id FROM dbo.FNAGetUserRole(''' + @user_name + ''') fur))'
		END

		SET @sql += ' WHERE 1 = 1 AND (prv.create_user = ''' + @user_name + ''''
		
		IF @report_type = 1
		BEGIN
			SET @sql += ' 
					OR (rp.paramset_hash IS NULL AND prv.is_public = 1)					--for Std report
					OR (prv.is_public = 1 AND rp3.report_privilege_id IS NOT NULL)		--for RM reports	
			'
		END
		SET @sql += ')'
	END	
	ELSE
	BEGIN
		IF @report_type = 1
		BEGIN
			SET @sql += ' INNER JOIN report_paramset rp ON rp.paramset_hash = prv.paramset_hash'
		END
		SET @sql += ' WHERE 1 = 1 '
	END

	IF @flag = 'k'
	BEGIN
		SET @sql += ' AND prv.paramset_hash = ''' + @paramset_hash + ''''
		SET @sql += ' ORDER BY  prv.pivot_report_view_name 	'
	END
	ELSE
	BEGIN
		SET @sql += ' ORDER BY  prv.pivot_report_view_name + ''['' + rp.name + '']'''
	END	
	
	--PRINT(@sql)
	EXEC(@sql)
END

--EXEC spa_pivot_report_view  @flag='i',@view_id=NULL,@view_name='swswswsw',@paramset_hash='FF08EF80_36E8_4F11_800B_7F5125680DD2',@renderer='Table',@row_fields='',@column_fields=''
IF @flag = 'i'
BEGIN
BEGIN TRY
	BEGIN TRANSACTION
	
	IF EXISTS( 
		SELECT 1
		FROM pivot_report_view prv
		WHERE prv.pivot_report_view_name = @view_name 
		AND prv.paramset_hash = @paramset_hash
		AND prv.pivot_report_view_id <> ISNULL(@view_id, -1)
	) 
	BEGIN
		EXEC spa_ErrorHandler 0
				, 'pinned_reports'
				, 'spa_pivot_report_view'
				, 'Error' 
				, 'View Name already exists.'
				, ''
				
		RETURN
	END
	
	IF @group_id IS NULL AND @group_name IS NOT NULL AND ISNULL(NULLIF(@pin_it, ''), 0) = 1
	BEGIN
		INSERT INTO pinned_report_group (group_name)
		SELECT @group_name
		
		SET @group_id = SCOPE_IDENTITY()
	END
	
	IF @view_id IS NOT NULL
	BEGIN
		UPDATE pivot_report_view
		SET
			pivot_report_view_name = @view_name,
			paramset_hash = @paramset_hash,
			row_fields = NULLIF(@row_fields, ''),
			columns_fields = NULLIF(@column_fields, ''),
			detail_fields = NULLIF(@detail_fields, ''),
			renderer = @renderer,
			pin_it = ISNULL(NULLIF(@pin_it, ''), 0),
			standard_report_id = @report_id,
			user_report_name = @user_report_name,
			xaxis_label = @xaxis_label,
			yaxis_label = @yaxis_label,
			report_group_id = CASE WHEN ISNULL(NULLIF(@pin_it, ''), 0) = 0 THEN NULL ELSE @group_id END,
			is_public = ISNULL(NULLIF(@is_public, ''), 0)
		WHERE pivot_report_view_id = @view_id	
	END
	ELSE
	BEGIN
		INSERT INTO pivot_report_view (
			-- pivot_report_view_id -- this column value is auto-generated
			pivot_report_view_name,
			paramset_hash,
			renderer,
			row_fields,
			columns_fields,
			detail_fields,
			pin_it,
			standard_report_id,
			user_report_name, xaxis_label, yaxis_label, report_group_id,
			is_public			
		)
		VALUES (
			@view_name,
			@paramset_hash,
			@renderer,
			NULLIF(@row_fields, ''),
			NULLIF(@column_fields, ''),
			NULLIF(@detail_fields, ''),
			ISNULL(NULLIF(@pin_it, ''), 0),
			@report_id,
			NULLIF(@user_report_name, ''),
			NULLIF(@xaxis_label, ''),
			NULLIF(@yaxis_label, ''),
			CASE WHEN ISNULL(NULLIF(@pin_it, ''), 0) = 0 THEN NULL ELSE @group_id END,
			ISNULL(NULLIF(@is_public, ''), 0)
		)
		
		SET @new_id = SCOPE_IDENTITY()
	END	
	
	DECLARE @up_view_id INT = ISNULL(@view_id, @new_id)
	
	IF @grid_xml IS NOT NULL
	BEGIN
		DECLARE @grid_xml_table VARCHAR(200) 	
			
 		SET @grid_xml_table = dbo.FNAProcessTableName('grid_xml_table', @user_name, @process_id)	
 			
 		EXEC spa_parse_xml_file 'b', NULL, @grid_xml, @grid_xml_table
 			
 		SET @sql = 'UPDATE prvc
 					SET [label] = NULLIF(temp.[label], ''''),
 						[columns_position] = NULLIF(temp.[col_pos], ''''),
 						[render_as] = NULLIF(temp.[render_as], ''''),
 						[date_format] = NULLIF(temp.[date_format], ''''),
 						[currency] = NULLIF(temp.[currency], ''''),
 						[thou_sep] = NULLIF(temp.[thou_sep], ''''),
 						[rounding] = NULLIF(temp.[rounding], ''''),
 						[neg_as_red] = NULLIF(temp.[neg_as_red], '''')
 			        FROM pivot_report_view_columns prvc
 			        INNER JOIN ' + @grid_xml_table + ' temp ON temp.[name] = prvc.columns_name AND prvc.pivot_report_view_id = ' + CAST(@up_view_id AS VARCHAR(20)) + '
 					
 		'
 		--PRINT(@sql)
 		EXEC(@sql)
 		
 		SET @sql = 'INSERT INTO pivot_report_view_columns (pivot_report_view_id, columns_name, label, columns_position, render_as, date_format, currency, thou_sep, rounding, neg_as_red)
 					SELECT ' + CAST(@up_view_id AS VARCHAR(20)) + ',
 							temp.[name],
 							NULLIF(temp.[label], ''''),
 							NULLIF(temp.[col_pos], ''''),
							NULLIF(temp.[render_as], ''''),
							NULLIF(temp.[date_format], ''''),
							NULLIF(temp.[currency], ''''),
							NULLIF(temp.[thou_sep], ''''),
							NULLIF(temp.[rounding], ''''),
							NULLIF(temp.[neg_as_red], '''')
 					FROM ' + @grid_xml_table + ' temp
 					LEFT JOIN pivot_report_view_columns prvc ON temp.[name] = prvc.columns_name AND prvc.pivot_report_view_id = ' + CAST(@up_view_id AS VARCHAR(20)) + '
 					WHERE prvc.pivot_report_view_columns_id IS NULL AND NULLIF(temp.[name], '''') IS NOT NULL
 		'
 		--PRINT(@sql)
 		EXEC(@sql)
	END
	
	IF NULLIF(@report_filter, '') IS NOT NULL
	BEGIN
		IF OBJECT_ID('tempdb..#temp_report_filters') IS NOT NULL
			DROP TABLE #temp_report_filters
			
		CREATE TABLE #temp_report_filters (
			column_name VARCHAR(200) COLLATE DATABASE_DEFAULT,
			column_value VARCHAR(MAX) COLLATE DATABASE_DEFAULT
		)

		IF EXISTS ( SELECT 1 
					FROM pivot_report_view prv
					INNER JOIN application_ui_template aut ON aut.application_function_id = prv.standard_report_id
					WHERE paramset_hash = @paramset_hash AND pivot_report_view_name = @view_name 
				  )
		BEGIN
			UPDATE pivot_report_view
			SET standard_exec_sql = @report_filter
			WHERE paramset_hash = @paramset_hash AND pivot_report_view_name = @view_name
		END		
		ELSE
		BEGIN
			INSERT INTO #temp_report_filters (column_name, column_value)
			SELECT SUBSTRING(item, 0, CHARINDEX('=', item)), 
				   CASE WHEN LEN(item) - 1 - LEN(SUBSTRING(item, 0, CHARINDEX('=', item))) > 0 THEN NULLIF(RIGHT(item, LEN(item) - 1 - LEN(SUBSTRING(item, 0, CHARINDEX('=', item)))), 'NULL') ELSE NULL END
			FROM dbo.SplitCommaSeperatedValues(@report_filter)
			WHERE CHARINDEX('=', item) <> 0

			UPDATE pvp
			SET column_value = temp.column_value
			FROM pivot_view_params pvp
			INNER JOIN data_source_column dsc ON dsc.data_source_column_id = pvp.column_id
			INNER JOIN #temp_report_filters temp ON temp.column_name = dsc.name
			WHERE pvp.view_id = @up_view_id
		
			INSERT INTO pivot_view_params (
				view_id,
				column_id,
				column_name,
				column_value
			)
			SELECT @up_view_id, dsc.data_source_column_id, dsc.name, trf.column_value
			FROM report_paramset rp
			INNER JOIN report_dataset_paramset rdp ON rdp.paramset_id = rp.report_paramset_id
			INNER JOIN report_param rp2 ON rp2.dataset_paramset_id = rdp.report_dataset_paramset_id
			INNER JOIN data_source_column dsc ON dsc.data_source_column_id = rp2.column_id
			INNER JOIN #temp_report_filters trf ON dsc.name = trf.column_name
			LEFT JOIN pivot_view_params pvp ON pvp.column_id = dsc.data_source_column_id AND pvp.view_id = @up_view_id
			WHERE rp.paramset_hash = @paramset_hash AND pvp.pivot_view_params_id IS NULL
		END
	END
	
	COMMIT
	
	EXEC spa_ErrorHandler 0
		, 'pivot_report_view'
		, 'spa_pivot_report_view'
		, 'Success' 
		, 'Changes are saved successfully.'
		, @new_id
END TRY
BEGIN CATCH 
	IF @@TRANCOUNT > 0
	   ROLLBACK
 
	SET @DESC = 'Fail to insert Data ( Errr Description:' + ERROR_MESSAGE() + ').'
 
	SELECT @err_no = ERROR_NUMBER()
 
	EXEC spa_ErrorHandler @err_no
	   , 'pivot_report_view'
	   , 'spa_pivot_report_view'
	   , 'Error'
	   , @DESC
	   , ''
END CATCH
END

IF @flag = 'd'
BEGIN
	BEGIN TRY
		IF EXISTS(SELECT 1 FROM pivot_report_dashboard_detail WHERE view_id = @view_id)
		BEGIN
			DECLARE @db_name_string VARCHAR(1000)
			SELECT @db_name_string = COALESCE(@db_name_string + ',', '') + prd.dashboard_name 
			FROM pivot_report_dashboard_detail prdv
			INNER JOIN pivot_report_dashboard prd ON prdv.dashboard_id = prd.pivot_report_dashboard_id
			WHERE prdv.view_id = @view_id

			SET @desc = 'Fail to delete view. ( View is used in dashboard: <b><i>[' + @db_name_string + ']</i></b>).'

			EXEC spa_ErrorHandler -1
				, 'pivot_report_view'
				, 'spa_pivot_report_view'
				, 'Error' 
				, @desc
				, ''
			RETURN
		END 

		DELETE FROM pivot_view_params WHERE view_id = @view_id	
		DELETE FROM pivot_report_view_columns WHERE pivot_report_view_id = @view_id	
		DELETE FROM pivot_report_view WHERE pivot_report_view_id = @view_id	
	
		EXEC spa_ErrorHandler 0
			, 'pivot_report_view'
			, 'spa_pivot_report_view'
			, 'Success' 
			, 'Changes are saved successfully.'
			, @view_id
	END TRY
	BEGIN CATCH 
		IF @@TRANCOUNT > 0
		   ROLLBACK
 
		SET @DESC = 'Fail to delete Data ( Errr Description:' + ERROR_MESSAGE() + ').'
 
		SELECT @err_no = ERROR_NUMBER()
 
		EXEC spa_ErrorHandler @err_no
		   , 'pivot_report_view'
		   , 'spa_pivot_report_view'
		   , 'Error'
		   , @DESC
		   , ''
	END CATCH
END

IF @flag = 'p'
BEGIN
	BEGIN TRY
		DECLARE @copy_view_name VARCHAR(200) 
		
		INSERT INTO pivot_report_view (
					pivot_report_view_name,
					paramset_hash,
					renderer,
					row_fields,
					columns_fields,
					detail_fields
		)
		SELECT	'COPY_' + pivot_report_view_name,
				paramset_hash,
				renderer,
				row_fields,
				columns_fields,
				detail_fields
		FROM pivot_report_view 
		WHERE pivot_report_view_id = @view_id

		SET @new_id = SCOPE_IDENTITY()

		UPDATE pivot_report_view
		SET pivot_report_view_name = pivot_report_view_name + '_' + CAST(@new_id AS VARCHAR(20))
		WHERE pivot_report_view_id = @new_id

		SELECT @copy_view_name = pivot_report_view_name
		FROM pivot_report_view
		WHERE pivot_report_view_id = @new_id

		SET @copy_view_name = CAST(@new_id AS VARCHAR(20)) + ':::' + @copy_view_name


		IF EXISTS(SELECT 1 FROM pivot_report_view_columns WHERE pivot_report_view_id = @view_id) 
		BEGIN
			INSERT INTO pivot_report_view_columns (
			    pivot_report_view_id, columns_name, columns_position, label, render_as, [date_format], currency, thou_sep, rounding, neg_as_red
			)
			SELECT @new_id, columns_name, columns_position, label, render_as, [date_format], currency, thou_sep, rounding, neg_as_red
			FROM pivot_report_view_columns WHERE pivot_report_view_id = @view_id
		END

		IF EXISTS(SELECT 1 FROM pivot_view_params WHERE view_id = @view_id)
		BEGIN
			INSERT INTO pivot_view_params (view_id, column_id, column_name, column_value)
			SELECT @new_id, column_id, column_name, column_value
			FROM pivot_view_params WHERE view_id = @view_id
		END

		EXEC spa_ErrorHandler 0,
            'Copy View.',
            'spa_pivot_report_view',
            'Success',
            'View copied sucessfully.',
            @copy_view_name
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK

		SET @desc = 'Fail to copy view. ( Errr Description:' + ERROR_MESSAGE() + ').'
	 
		SELECT @err_no = ERROR_NUMBER()
	 
		EXEC spa_ErrorHandler @err_no
		   , 'Copy View.'
		   , 'spa_pivot_report_view'
		   , 'Error'
		   , @desc
		   , ''
	END CATCH
END
ELSE IF @flag = 'x' OR @flag = 'o'
BEGIN
	IF OBJECT_ID('tempdb..#temp_pinned_report_list') IS NOT NULL
		DROP TABLE #temp_pinned_report_list
	
	CREATE TABLE #temp_pinned_report_list (
		id INT IDENTITY(1,1),
		group_id INT,
		group_name VARCHAR(1000) COLLATE DATABASE_DEFAULT,
		view_id INT,
		name VARCHAR(1000) COLLATE DATABASE_DEFAULT
	)
	
	INSERT INTO #temp_pinned_report_list (group_id, group_name, view_id, name)
	SELECT prv.report_group_id,
	       NULL,
	       prv.pivot_report_view_id [id],
	       prv.pivot_report_view_name + ' [' + CASE WHEN rp.name IS NOT NULL THEN rp.name ELSE prv.paramset_hash END + ']' [name]
	FROM   pivot_report_view prv
	LEFT JOIN report_paramset rp ON  rp.paramset_hash = prv.paramset_hash
	WHERE prv.pin_it = 1
	AND prv.report_group_id = -1
	AND   prv.create_user = dbo.FNADBUser()
	ORDER BY rp.name, prv.pivot_report_view_name
	
	INSERT INTO #temp_pinned_report_list (group_id, group_name, view_id, name)
	SELECT prv.report_group_id,
	       prg.group_name,
	       prv.pivot_report_view_id [id],
	       prv.pivot_report_view_name + ' [' + CASE WHEN rp.name IS NOT NULL THEN rp.name ELSE prv.paramset_hash END + ']' [name]
	FROM   pivot_report_view prv
	LEFT JOIN report_paramset rp ON  rp.paramset_hash = prv.paramset_hash
	INNER JOIN pinned_report_group prg ON  prg.pinned_report_group_id = prv.report_group_id
	WHERE prv.pin_it = 1
	AND prv.report_group_id <> -1
	AND  prv.create_user = dbo.FNADBUser()
	ORDER BY prg.group_name, rp.name, prv.pivot_report_view_name
	
	IF @flag = 'o'
	BEGIN
		IF NOT EXISTS(SELECT 1 FROM #temp_pinned_report_list WHERE group_id = -1) 
		BEGIN
			SET IDENTITY_INSERT #temp_pinned_report_list ON
			INSERT INTO #temp_pinned_report_list (id, group_id, group_name)
			SELECT -1, -1, '...'
			SET IDENTITY_INSERT #temp_pinned_report_list OFF
		END
		
		SELECT group_id, group_name, view_id, name
		FROM (
			SELECT 'g_' + CAST(group_id AS varchar(20)) group_id,
				ISNULL(group_name, '...') group_name,
				'm_' + CAST(view_id AS VARCHAR(20)) view_id,
				name,
				id
			FROM #temp_pinned_report_list
			UNION ALL
			SELECT 'g_' + CAST(prg.pinned_report_group_id AS VARCHAR(10)) group_id, 
			prg.group_name,
			NULL view_id,
			NULL name,
			1000 id
		FROM pinned_report_group prg
		LEFT JOIN #temp_pinned_report_list temp ON prg.pinned_report_group_id = temp.group_id
		WHERE prg.create_user = dbo.FNADBUser()
		AND temp.group_id IS NULL
		) a
		ORDER BY id
		
		RETURN
	END	
	
	IF OBJECT_ID('tempdb..#temp_pinned_json') IS NOT NULL
		DROP TABLE #temp_pinned_json
	CREATE TABLE #temp_pinned_json (id INT IDENTITY(1,1), group_id INT, group_name VARCHAR(500) COLLATE DATABASE_DEFAULT, json VARCHAR(MAX) COLLATE DATABASE_DEFAULT, seq_no INT)
	
	
	DECLARE @pinned_json VARCHAR(MAX), @seq INT
	DECLARE pinned_group_cursor CURSOR FORWARD_ONLY READ_ONLY 
	FOR
		SELECT group_id, group_name, MIN(id) id
		FROM #temp_pinned_report_list
		GROUP BY group_id, group_name
		ORDER by id
	OPEN pinned_group_cursor
	FETCH NEXT FROM pinned_group_cursor INTO @group_id, @group_name, @seq
	WHILE @@FETCH_STATUS = 0
	BEGIN		
		DECLARE @nsql NVARCHAR(MAX) = NULL
		DECLARE @param NVARCHAR(100) = NULL
		DECLARE @xml XML = NULL
		
		SET @param = N'@xml XML OUTPUT';
	
		SET @nsql = ' SET @xml = (
							   SELECT 
							   view_id [id],
							   name [name]							
						FROM #temp_pinned_report_list vw
						WHERE vw.group_id = ' + CAST(@group_id AS VARCHAR(20)) + '
						ORDER by id
						FOR xml RAW(''menu''), ROOT(''root''), ELEMENTS)'
		EXECUTE sp_executesql @nsql, @param, @xml = @xml OUTPUT;
				
		SET @pinned_json = dbo.FNAFlattenedJSON(@xml)
		IF SUBSTRING(@pinned_json, 1, 1) <> '['
		BEGIN
			SET @pinned_json = '[' + @pinned_json + ']'
		END
		
		INSERT INTO #temp_pinned_json(group_id, group_name, json)
		SELECT @group_id, @group_name, @pinned_json
		
		FETCH NEXT FROM pinned_group_cursor INTO @group_id, @group_name, @seq
	END
	CLOSE pinned_group_cursor
	DEALLOCATE pinned_group_cursor
	
	SELECT group_id, group_name, json
	FROM (
		SELECT group_id, group_name, json, id
		FROM #temp_pinned_json temp
		UNION ALL
		SELECT prg.pinned_report_group_id, prg.group_name, NULL json, 1000 id
		FROM pinned_report_group prg
		LEFT JOIN #temp_pinned_json temp ON prg.pinned_report_group_id = temp.group_id
		WHERE prg.create_user = dbo.FNADBUser() AND temp.group_id IS NULL
	) a
	ORDER by id
	
END
ELSE IF @flag = 'y'
BEGIN
	DECLARE @report_param_string VARCHAR(MAX)
	DECLARE @report_name VARCHAR(500)
	DECLARE @has_view_permission CHAR(1) = 'n'
	DECLARE @public CHAR(1)
	DECLARE @is_owner CHAR(1)
	DECLARE @excel_sheet_id INT
	
	IF OBJECT_ID('tempdb..#temp_dashboard_params') IS NOT NULL
		DROP TABLE #temp_dashboard_params
	CREATE TABLE #temp_dashboard_params (column_name VARCHAR(200) COLLATE DATABASE_DEFAULT, column_value VARCHAR(MAX) COLLATE DATABASE_DEFAULT, param_type INT)
	
	IF @dashboard_id IS NOT NULL
	BEGIN
		INSERT INTO #temp_dashboard_params (column_name, column_value, param_type)
		SELECT dp.param_name,
		       REPLACE(NULLIF(MAX(dp.param_value), ''), ',', '!'),
		       MAX(dp.param_type)
		FROM   dashboard_params dp
		WHERE dp.dashboard_id = @dashboard_id AND dp.param_name NOT LIKE 'LOGICAL____%'
		GROUP BY dp.param_name
		
		UPDATE temp
		SET column_value = dbo.FNAResolveBusinessDate(dp.param_value)
		FROM #temp_dashboard_params temp
		INNER JOIN dashboard_params dp ON 'LOGICAL____' + temp.column_name = dp.param_name
		WHERE dp.dashboard_id = @dashboard_id AND NULLIF(dp.param_value, '') IS NOT NULL
		
		IF @replace_params IS NOT NULL
		BEGIN
			DECLARE @replace_params_table VARCHAR(200)
			SET @replace_params_table = dbo.FNAProcessTableName('replace_params_table', @user_name, @process_id) 	
				
 			EXEC spa_parse_xml_file 'b', NULL, @replace_params, @replace_params_table
 			
 			SET @sql = 'UPDATE dp
						SET column_value = NULLIF(NULLIF(replace(prt.[param_value],'','',''!''), ''''), ''null'')
						FROM #temp_dashboard_params dp
						INNER JOIN ' + @replace_params_table + ' prt ON  prt.[param_name] = dp.column_name  AND prt.param_name NOT LIKE ''LOGICAL____%'''
			EXEC(@sql) 
			
			SET @sql = 'UPDATE dp
						SET column_value = dbo.FNAResolveBusinessDate(prt.[param_value])
						FROM #temp_dashboard_params dp
						INNER JOIN ' + @replace_params_table + ' prt ON  prt.[param_name] = ''LOGICAL____'' + dp.column_name
			            WHERE NULLIF(NULLIF(prt.[param_value], ''''), ''null'') IS NOT NULL'
			EXEC(@sql) 
		END
	END	
	
	SELECT @view_name = prv.pivot_report_view_name, @paramset_hash = prv.paramset_hash, @excel_sheet_id = prv.excel_sheet_id
	FROM pivot_report_view prv
	WHERE prv.pivot_report_view_id = @view_id

	IF NULLIF(@excel_sheet_id,'') IS NULL
	BEGIN
		SELECT @report_param_string = COALESCE(@report_param_string + ',', '') + pvp.column_name + '=' + COALESCE(dp.column_value, pvp.column_value, 'NULL')
		FROM pivot_view_params pvp
		LEFT JOIN #temp_dashboard_params dp ON dp.column_name = pvp.column_name
		WHERE pvp.view_id = @view_id
	END
	ELSE
	BEGIN
		SELECT @report_param_string = COALESCE(@report_param_string + ',', '') + dp.column_name + '=' + COALESCE(dp.column_value, 'NULL')
		FROM #temp_dashboard_params dp
	END
	
	SELECT @report_name = rp.name, @paramset_id = rp.report_paramset_id, @report_id =rp2.report_id, @public = CASE WHEN rp.report_status_id = 2 THEN 'y' ELSE 'n' END
	FROM report_paramset rp
	INNER JOIN report_page rp2 ON rp2.report_page_id = rp.page_id 
	WHERE rp.paramset_hash = @paramset_hash

	SELECT @is_owner = CASE WHEN r.[owner] = @user_name THEN 'y' ELSE 'n' END
	FROM report r 
	WHERE r.report_id = @report_id
	
	-- for standard reports
	DECLARE @std_rpt_id INT
	IF (@report_param_string IS NULL OR @report_name IS NULL OR @report_id IS NULL)
	BEGIN
		SELECT @report_param_string = standard_exec_sql
			 , @report_id = standard_report_id
		FROM pivot_report_view 
		WHERE pivot_report_view_id = @view_id 
	
		SELECT @report_name = template_name
		FROM application_ui_template 
		WHERE application_function_id = @report_id
	END


	IF @public = 'y' OR @is_owner = 'y' OR @is_admin = 1
	BEGIN		
		SET @has_view_permission = 'y'
	END
	ELSE IF EXISTS(
		SELECT 1
		FROM report r
		INNER JOIN report_privilege rp
			ON r.report_hash = rp.report_hash
			AND (rp.[user_id] = @user_name OR rp.role_id IN (SELECT fur.role_id FROM dbo.FNAGetUserRole(@user_name) fur))
		WHERE r.report_id = @report_id
	)
	BEGIN
		SET @has_view_permission = 'y'		
	END	
	
	SELECT @component_id = rpt.report_page_tablix_id
	FROM report_paramset rp
	INNER JOIN report_page rp2 ON rp2.report_page_id = rp.page_id
	INNER JOIN report_page_tablix rpt ON rpt.page_id = rp2.report_page_id
	WHERE rp.paramset_hash = @paramset_hash
	
	IF @component_id IS NULL
	BEGIN
		SELECT @component_id = rpt.report_page_chart_id
		FROM report_paramset rp
		INNER JOIN report_page rp2 ON rp2.report_page_id = rp.page_id
		INNER JOIN report_page_chart rpt ON rpt.page_id = rp2.report_page_id
		WHERE rp.paramset_hash = @paramset_hash
		
		IF @component_id IS NULL
		BEGIN
			SELECT @component_id = rpt.report_page_gauge_id
			FROM report_paramset rp
			INNER JOIN report_page rp2 ON rp2.report_page_id = rp.page_id
			INNER JOIN report_page_gauge rpt ON rpt.page_id = rp2.report_page_id
			WHERE rp.paramset_hash = @paramset_hash
		END
	END
	
	SELECT @report_param_string [params],
	       @view_name + ' [' + @report_name + ']' [name],
	       @view_id [view_id],
	       @paramset_hash [paramset_hash],
	       @component_id [component_id],
	       @report_name [report_name],
	       @paramset_id [paramset_id],
	       @report_id [report_id],
		   @has_view_permission [has_permission],
		   @excel_sheet_id [excel_sheet_id]
END
ELSE IF @flag = 'z'
BEGIN
	IF OBJECT_ID('tempdb..#temp_report_group') IS NOT NULL 
		DROP TABLE #temp_report_group
	
	CREATE TABLE #temp_report_group (id INT IDENTITY(1,1), group_id INT, group_name VARCHAR(2000) COLLATE DATABASE_DEFAULT)
	
	INSERT INTO #temp_report_group (group_id, group_name)
	SELECT -1 pinned_report_group_id, 'General' group_name
	
	INSERT INTO #temp_report_group (group_id, group_name)
	SELECT prg.pinned_report_group_id, prg.group_name
	FROM pinned_report_group prg
	WHERE prg.create_user = dbo.FNADBUser()
	ORDER BY prg.group_name
	
	SELECT group_id, group_name
	FROM #temp_report_group
	ORDER BY id
END

ELSE IF @flag = 'q'
BEGIN
	UPDATE pivot_report_view
	SET pin_it = 0,
		report_group_id = NULL
	WHERE pivot_report_view_id = @view_id
END

ELSE IF @flag = 'u'
BEGIN
	BEGIN TRY
		DECLARE @idoc  INT
		
		--Create an internal representation of the XML document.
		EXEC sp_xml_preparedocument @idoc OUTPUT, @grid_xml

		-- Create temp table to store xml data
		IF OBJECT_ID('tempdb..#temp_pinned_update') IS NOT NULL
			DROP TABLE #temp_pinned_update
	
		-- Execute a SELECT statement that uses the OPENXML rowset provider.
		SELECT group_id        group_id,
		       group_name      group_name,
		       view_id         view_id,
		       view_name       view_name
		INTO #temp_pinned_update
		FROM OPENXML(@idoc, '/Root/TNode', 1)
		WITH (
		    group_id VARCHAR(20),
		    group_name VARCHAR(100),
		    view_id VARCHAR(20),
		    view_name VARCHAR(1000)
		)
		
		IF OBJECT_ID('tempdb..#temp_pinned_groups_update') IS NOT NULL
			DROP TABLE #temp_pinned_groups_update
		
		IF OBJECT_ID('tempdb..#temp_view_update') IS NOT NULL
			DROP TABLE #temp_view_update
			
		SELECT REPLACE(group_id, 'g_', '') group_id,
		       group_name
		INTO #temp_pinned_groups_update
		FROM #temp_pinned_update
		GROUP BY group_id, group_name
		
		SELECT REPLACE(group_id, 'g_', '') group_id,
		       REPLACE(view_id, 'm_', '') view_id,
		       view_name
		INTO #temp_view_update
		FROM #temp_pinned_update
		
		UPDATE prv
		SET prv.pin_it = 0, prv.report_group_id = NULL
		FROM pivot_report_view prv 
		LEFT JOIN #temp_view_update temp ON prv.pivot_report_view_id = temp.view_id
		WHERE prv.create_user = dbo.FNADBUser() AND temp.view_id IS NULL
		
		DELETE prg
		FROM pinned_report_group prg
		LEFT JOIN #temp_pinned_groups_update temp ON prg.pinned_report_group_id = temp.group_id
		WHERE prg.create_user = dbo.FNADBUser() AND temp.group_id IS NULL
		
		UPDATE prv
		SET prv.report_group_id = temp.group_id
		FROM pivot_report_view prv 
		INNER JOIN #temp_view_update temp ON prv.pivot_report_view_id = temp.view_id
		WHERE prv.create_user = dbo.FNADBUser() 
		
		IF EXISTS (SELECT 1 FROM #temp_pinned_groups_update WHERE group_name = '')
		BEGIN
			EXEC spa_ErrorHandler -1
			   , 'pinned_reports'
			   , 'spa_pivot_report_view'
			   , 'Error'
			   , 'Please insert the group name.'
			   , ''
		END
		ELSE 
		BEGIN
			UPDATE prg
			SET prg.group_name = temp.group_name
			FROM pinned_report_group prg
			INNER JOIN #temp_pinned_groups_update temp ON prg.pinned_report_group_id = temp.group_id
		
			EXEC spa_ErrorHandler 0
				, 'pinned_reports'
				, 'spa_pivot_report_view'
				, 'Success' 
				, 'Changes have been saved successfully.'
				, ''
		END
		
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
	 
		SET @desc = 'Fail to save data ( Errr Description:' + ERROR_MESSAGE() + ').'
	 
		SELECT @err_no = ERROR_NUMBER()
	 
		EXEC spa_ErrorHandler @err_no
		   , 'pinned_reports'
		   , 'spa_pivot_report_view'
		   , 'Error'
		   , @desc
		   , ''
	END CATCH
END