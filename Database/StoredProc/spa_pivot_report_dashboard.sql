IF OBJECT_ID(N'[dbo].[spa_pivot_report_dashboard]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_pivot_report_dashboard]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

/**
	Report dashboard related operations
	Parameters
	@flag					: 'd' delete operation for report dashboard for matched dashboard id
							  'x' select all dashboard header information for privileged users (optionally filtered by category)
							  'i' insert operation for report dashboard
							  's' get report dashboard layout and format information for matched dashboard id
							  'z' report filters population for view pivot reports used on matched dashboard id
							  'y' get report column param data source (sql string) for matched column id
							  'w' get privilege status for matched dashboard id
							  'j' Returns json items of dashboard_id, dashboard_name , [owner] according to defined category in dashboard of report
	@layout_format			: Layout Format
	@xml					: Dashboard informations in XML format
	@dashboard_id			: Dashboard Id
	@dashboard_name			: Dashboard Name
	@report_string			: Report String
	@datasource_column_id	: Datasource Column Id
	@param_xml				: Dashboard parameter informations in XML format
	@mins					: Dashboard refresh minute value
	@secs					: Dashboard refresh second value
	@category				: Dashboard category id
	@is_public				: Is Public flag
	@call_from				: Call from Dashboard config or change filter
*/
CREATE PROCEDURE [dbo].[spa_pivot_report_dashboard]
    @flag CHAR(1),
    @layout_format VARCHAR(10) = NULL,
    @xml XML = NULL,
    @dashboard_id VARCHAR(100) = NULL,
    @dashboard_name VARCHAR(500) = NULL,
    @report_string VARCHAR(MAX) = NULL,
    @datasource_column_id INT = NULL,
    @param_xml XML = NULL,
    @mins INT = NULL,
    @secs INT = NULL,
	@category INT = NULL,
	@is_public BIT = 0,
	@call_from VARCHAR(100) = NULL
AS
/*
declare @flag CHAR(1),
    @layout_format VARCHAR(10) = NULL,
    @xml XML = NULL,
    @dashboard_id VARCHAR(100) = NULL,
    @dashboard_name VARCHAR(500) = NULL,
    @report_string VARCHAR(MAX) = NULL,
    @datasource_column_id INT = NULL,
    @param_xml XML = NULL,
    @mins INT = NULL,
    @secs INT = NULL,
	@category INT = NULL,
	@is_public BIT = 0

select @flag='z', @dashboard_id=1101

declare @s varbinary(128) = cast('debug_mode_on' as varbinary(128)) set context_info @s
--*/
 
SET NOCOUNT ON
 
DECLARE @sql VARCHAR(MAX)
DECLARE @user_name VARCHAR(200) = dbo.FNADBUser()
DECLARE @process_id VARCHAR(200) = dbo.FNAGETNewID()
DECLARE @desc VARCHAR(500)
DECLARE @err_no INT, @report_count INT
DECLARE @is_admin INT = dbo.FNAIsUserOnAdminGroup(@user_name, 1)

IF @flag = 'd'
BEGIN
	BEGIN TRY	
		IF OBJECT_ID('tempdb..#temp_delete_dashboard') IS NOT NULL
			DROP TABLE #temp_delete_dashboard
		CREATE TABLE #temp_delete_dashboard (dashboard_id INT)

		INSERT INTO #temp_delete_dashboard(dashboard_id)
		SELECT scsv.item FROM dbo.SplitCommaSeperatedValues(@dashboard_id) scsv
		
		DELETE pdp
		FROM pivot_dashboard_privilege pdp
		INNER JOIN #temp_delete_dashboard td ON td.dashboard_id = pdp.dashboard_id

		DELETE dp
		FROM dashboard_params dp
		INNER JOIN #temp_delete_dashboard td ON td.dashboard_id = dp.dashboard_id

		DELETE drdd
		FROM pivot_report_dashboard_detail drdd
		INNER JOIN #temp_delete_dashboard td ON td.dashboard_id = drdd.dashboard_id

		DELETE prd
		FROM pivot_report_dashboard prd
		INNER JOIN #temp_delete_dashboard td ON td.dashboard_id = prd.pivot_report_dashboard_id
		
		EXEC spa_ErrorHandler 0
			, 'pivot_report_dashboard'
			, 'spa_pivot_report_dashboard'
			, 'Success' 
			, 'Dashboard sucessfully deleted.'
			, @dashboard_id
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
 
		SET @DESC = 'Fail to delete Data ( Errr Description:' + ERROR_MESSAGE() + ').'
 
		SELECT @err_no = ERROR_NUMBER()
 
		EXEC spa_ErrorHandler @err_no
		   , 'pivot_report_dashboard'
		   , 'spa_pivot_report_dashboard'
		   , 'Error'
		   , @DESC
		   , ''
	END CATCH
END
ELSE IF @flag = 'x'
BEGIN 	
	SET @sql = 'SELECT prd.pivot_report_dashboard_id dashboard_id, prd.dashboard_name, prd.[user_name] [owner]
				FROM pivot_report_dashboard prd '

	IF @is_admin = 0
	BEGIN
		SET @sql += '
			LEFT JOIN pivot_dashboard_privilege pdp 
				ON pdp.dashboard_id = prd.pivot_report_dashboard_id
				AND (pdp.[user_login_id] = ''' + @user_name + ''' OR pdp.role_id IN (SELECT fur.role_id FROM dbo.FNAGetUserRole(''' + @user_name + ''') fur))
			WHERE 1 = 1
			AND (prd.is_public = 1 OR prd.[user_name] = ''' + @user_name + ''' OR pdp.pivot_dashboard_privilege_id IS NOT NULL)		
		'
	END
	ELSE
	BEGIN
		SET @sql += ' WHERE 1 = 1'
	END

	IF @category IS NOT NULL
	BEGIN
		SET @sql += ' AND prd.category = ' + CAST(@category AS VARCHAR(20))
	END

	SET @sql += ' ORDER BY prd.dashboard_name'
	
	--PRINT(@sql)
	EXEC(@sql)
END
ELSE IF @flag = 'i'
BEGIN
	BEGIN TRAN
	BEGIN TRY
		IF @xml IS NOT NULL
 		BEGIN
 			DECLARE @dashboard_process_table VARCHAR(200), @is_new VARCHAR(10) = ''
 			
 			IF EXISTS(SELECT 1 FROM pivot_report_dashboard prd WHERE prd.dashboard_name = @dashboard_name AND prd.[user_name] = @user_name AND CAST(prd.pivot_report_dashboard_id AS VARCHAR(20)) <> @dashboard_id)
 			BEGIN
 				EXEC spa_ErrorHandler -1
 					, 'pivot_report_dashboard'
 					, 'spa_pivot_report_dashboard'
 					, 'Error'
 					, 'Dashboard name already exists.'
 					, ''
 				RETURN 			
 			END
 			
 			SET @dashboard_process_table = dbo.FNAProcessTableName('dashboard_process_table', @user_name, @process_id)
 		
 			EXEC spa_parse_xml_file 'b', NULL, @xml, @dashboard_process_table
 		 	
 		 	IF EXISTS(SELECT 1 FROM pivot_report_dashboard prd WHERE CAST(prd.pivot_report_dashboard_id AS VARCHAR(20)) = ISNULL(@dashboard_id, -1))
 		 	BEGIN
 		 		UPDATE pivot_report_dashboard
 				SET layout_format = @layout_format, 
 					dashboard_name = @dashboard_name,
 					mins = @mins,
 					secs = @secs,
					category = @category,
					is_public = @is_public
 				WHERE CAST(pivot_report_dashboard_id AS VARCHAR(20)) = @dashboard_id
 		 	END
 			ELSE
 			BEGIN
 				INSERT INTO pivot_report_dashboard ([user_name], layout_format, dashboard_name, mins, secs, category, is_public)
 				VALUES (@user_name, @layout_format, @dashboard_name, @mins, @secs, @category, @is_public)
 			
 				SET @dashboard_id = SCOPE_IDENTITY()
 				SET @is_new = @dashboard_id
 			END
 		
 			SET @sql = 'UPDATE pivot_report_dashboard_detail
						SET    view_id = prt.report,
								height_percentage = height,
								width_percentage = width
						FROM   pivot_report_dashboard_detail prdd
						INNER JOIN ' + @dashboard_process_table + ' prt ON  prt.cell_id = prdd.cell_id
						WHERE  prdd.dashboard_id = ' + @dashboard_id
			EXEC(@sql)

			SET @sql = '
				INSERT INTO pivot_report_dashboard_detail (dashboard_id, cell_id, view_id, height_percentage, width_percentage)
				SELECT ' + @dashboard_id + ', prt.cell_id, prt.report, prt.height, prt.width
				FROM ' + @dashboard_process_table + ' prt 
				LEFT JOIN pivot_report_dashboard_detail prdd ON prt.cell_id = prdd.cell_id AND prdd.dashboard_id = ' + @dashboard_id + '
				WHERE prdd.pivot_report_dashboard_detail_id IS NULL				
			'
			EXEC(@sql)
			
			SET @sql = '
				DELETE prdd
				FROM pivot_report_dashboard_detail prdd
				LEFT JOIN ' + @dashboard_process_table + ' prt ON prt.cell_id = prdd.cell_id 
				WHERE prdd.dashboard_id = ' + @dashboard_id + '
				AND prt.report IS NULL
			'
			EXEC(@sql)	
			
			IF @param_xml IS NOT NULL
			BEGIN
				DECLARE @dashboard_param_table VARCHAR(200)
				SET @dashboard_param_table = dbo.FNAProcessTableName('dashboard_param_table', @user_name, @process_id) 		
 				EXEC spa_parse_xml_file 'b', NULL, @param_xml, @dashboard_param_table
 				
 				SELECT @report_count = COUNT(1)
 				FROM   pivot_report_dashboard_detail
 				WHERE dashboard_id = @dashboard_id
 				
 				IF OBJECT_ID('tempdb..#temp_common_params1') IS NOT NULL
					DROP TABLE #temp_common_params1
				CREATE TABLE #temp_common_params1 (column_id INT, column_name VARCHAR(200) COLLATE DATABASE_DEFAULT)
	
				INSERT INTO #temp_common_params1 (column_id, column_name)
				SELECT MAX(column_id) column_id, column_name
				FROM pivot_report_dashboard_detail prdd
				INNER JOIN pivot_view_params pvp ON prdd.view_id = pvp.view_id
				WHERE prdd.dashboard_id = @dashboard_id
				GROUP BY column_name
				--HAVING COUNT(column_name) = @report_count
 				
 				
 				SET @sql = 'UPDATE dp
							SET param_value = prt.[param_value],
								param_type = dsc.widget_id
							FROM dashboard_params dp
							INNER JOIN ' + @dashboard_param_table + ' prt ON  prt.[param_name] = dp.param_name
							INNER JOIN #temp_common_params1 temp ON (temp.column_name = prt.[param_name] OR ''LOGICAL____'' + temp.column_name = prt.[param_name])
							INNER JOIN data_source_column dsc ON dsc.data_source_column_id = temp.column_id
							WHERE dp.dashboard_id = ' + @dashboard_id
				EXEC(@sql)
				
				SET @sql = '
					INSERT INTO dashboard_params (dashboard_id, param_name, param_value, param_type)
					SELECT ' + @dashboard_id + ', prt.param_name, prt.param_value, dsc.widget_id
					FROM ' + @dashboard_param_table + ' prt 
					INNER JOIN #temp_common_params1 temp ON (temp.column_name = prt.[param_name] OR ''LOGICAL____'' + temp.column_name = prt.[param_name])
					INNER JOIN data_source_column dsc ON dsc.data_source_column_id = temp.column_id
					LEFT JOIN dashboard_params dp ON prt.param_name = dp.param_name AND dp.dashboard_id = ' + @dashboard_id + '
					WHERE dp.dashboard_params_id IS NULL				
				'
				EXEC(@sql)
				
				SET @sql = '
					DELETE dp
					FROM dashboard_params dp
					LEFT JOIN ' + @dashboard_param_table + ' prt ON prt.param_name = dp.param_name 
					WHERE dp.dashboard_id = ' + @dashboard_id + '
					AND prt.param_name IS NULL
				'
				EXEC(@sql)			
			END
 		END
 		
 		COMMIT TRAN
 		
 		EXEC spa_ErrorHandler 0
 			, 'pivot_report_dashboard'
 			, 'spa_pivot_report_dashboard'
 			, 'Success' 
 			, 'Changes have been saved successfully.'
 			, @is_new
 		
 	END TRY
 	BEGIN CATCH  
 		IF @@TRANCOUNT > 0
 			ROLLBACK
  
 		SET @desc = 'Fail to save Data ( Errr Description:' + ERROR_MESSAGE() + ').'
  
 		SELECT @err_no = ERROR_NUMBER()
  
 		EXEC spa_ErrorHandler @err_no
 			, 'pivot_report_dashboard'
 			, 'spa_pivot_report_dashboard'
 			, 'Error'
 			, @desc
 			, ''
	END CATCH
END
ELSE IF @flag = 's'
BEGIN
	SELECT prd.layout_format,
	       prdd.cell_id,
	       prdd.view_id [report_id],
	       prdd.height_percentage [height],
	       prdd.width_percentage [width],
	       prv.pivot_report_view_name + ' [' + rp.name + ']' [report_name],
	       prd.dashboard_name,
	       prd.mins,
	       prd.secs,
		   prd.category,
		   CASE WHEN prd.is_public = 1 THEN 'true' ELSE 'false' END [is_public]
	FROM pivot_report_dashboard prd
	INNER JOIN pivot_report_dashboard_detail prdd ON prdd.dashboard_id = prd.pivot_report_dashboard_id
	INNER JOIN pivot_report_view prv ON prv.pivot_report_view_id = prdd.view_id
	INNER JOIN report_paramset rp ON rp.paramset_hash = prv.paramset_hash
	WHERE CAST(prd.pivot_report_dashboard_id AS VARCHAR(20)) = @dashboard_id
END
ELSE IF @flag = 'z' --report filters population for view pivot reports used on matched dashboard id
BEGIN	
	declare @pivot_view_id varchar(200),@report_param_id varchar(200)
	select @pivot_view_id = stuff(
		(select distinct ',' + cast(d.view_id as varchar(10))
		FROM pivot_report_dashboard_detail d
		where d.dashboard_id = @dashboard_id
		for xml path('')
	),1,1,'')
	select @report_param_id = stuff(
		(select distinct ',' + cast(rp.report_paramset_id as varchar(10))
		FROM pivot_report_dashboard_detail d
		inner join pivot_report_view p on p.pivot_report_view_id = d.view_id
		inner join report_paramset rp on rp.paramset_hash = p.paramset_hash
		where d.dashboard_id = @dashboard_id
		for xml path('')
	),1,1,'')

	IF @call_from IS NULL
		SET @call_from = 'pinned_pivot'

	exec spa_view_report @flag='c',@report_param_id=@report_param_id,@call_from=@call_from, @dashboard_id = @dashboard_id
	
END
ELSE IF @flag = 'y' --get report column param data source (sql string) for matched column id
BEGIN
	SELECT @sql = dsc.param_data_source
	FROM data_source_column dsc WHERE dsc.data_source_column_id = @datasource_column_id 
	
	EXEC(@sql)
END
ELSE IF @flag = 'w' --get privilege status for matched dashboard id
BEGIN
	IF @is_admin = 1
	BEGIN
		SELECT 1 [privilege] 
		RETURN
	END
	ELSE
	BEGIN
		IF EXISTS(
			SELECT 1
			FROM pivot_report_dashboard prv 
			INNER JOIN dbo.SplitCommaSeperatedValues(@dashboard_id) scsv ON scsv.item = prv.pivot_report_dashboard_id
			WHERE prv.[user_name] <> @user_name
		)
		BEGIN
			SELECT 0 [privilege] 
			RETURN
		END
		ELSE
		BEGIN
			SELECT 1 [privilege] 
			RETURN
		END
	END
END
ELSE IF @flag = 'j' --Returns json items of dashboard_id, dashboard_name , [owner] according to defined category in dashboard of report
BEGIN 	

    CREATE TABLE #pivot_report_dashboard (dashboard_id INT , dashboard_name NVARCHAR(100) COLLATE DATABASE_DEFAULT, [owner] NVARCHAR(50) COLLATE DATABASE_DEFAULT)
	SET @sql = 'INSERT INTO #pivot_report_dashboard(dashboard_id, dashboard_name, [owner])
				SELECT prd.pivot_report_dashboard_id dashboard_id, prd.dashboard_name, prd.[user_name] [owner]
				FROM pivot_report_dashboard prd '
	IF @is_admin = 0
	BEGIN
		SET @sql += 'LEFT JOIN pivot_dashboard_privilege pdp ON pdp.dashboard_id = prd.pivot_report_dashboard_id AND (pdp.[user_login_id] = ''' + @user_name + ''' OR pdp.role_id IN (SELECT fur.role_id FROM dbo.FNAGetUserRole(''' + @user_name + ''') fur)) WHERE 1 = 1
		  AND (prd.is_public = 1 OR prd.[user_name] = ''' + @user_name + ''' OR pdp.pivot_dashboard_privilege_id IS NOT NULL)		
		'
	END
	ELSE
	BEGIN
		SET @sql += ' WHERE 1 = 1'
	END

	IF @category IS NOT NULL
	BEGIN
		SET @sql += ' AND prd.category = ' + CAST(@category AS VARCHAR(20))
	END
	SET @sql += 'SELECT + ''['' + ji.[json_item] + '']'' json_item FROM (
			         SELECT STUFF((
						SELECT '','' + ''['' + (cast(r.dashboard_id AS VARCHAR) + '','' + ''"''+ r.dashboard_name + ''"'' + '','' + ''"''+ r.[owner]) + ''"'' + '']''
						FROM #pivot_report_dashboard r ORDER By r.dashboard_name
						FOR XML PATH('''')
							,TYPE
						).value(''.'', ''NVARCHAR(MAX)''), 1, 1, '''') AS [json_item]
			   ) ji '
	
	EXEC(@sql)
	
END
