IF OBJECT_ID(N'[dbo].[spa_rfx_report_record_dhx]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_rfx_report_record_dhx]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
/**
	Operations for extraction of report informations. created for new report manager dhx. currently in use.
	Parameters
	@flag				: 'z' report name listing on report manager UI left treegrid
						  'y' get report owners of all report
						  's' select report,report page,paramset level informations for matched filters (user id,category,report id)
						  'y' select report param column informations for matched report paramset id
	@report_paramset_id : Report Paramset Id
	@report_owner		: Report Owner
	@is_system			: Is System
	@category_id		: Category Id
	@call_from			: Call From
	@report_id			: Report Id
	@process_id			: Process Id
*/
CREATE PROCEDURE [dbo].[spa_rfx_report_record_dhx]
	@flag CHAR(1) = NULL,
	@report_paramset_id VARCHAR(MAX) = NULL,
	@report_owner VARCHAR(200) = NULL,
	@is_system VARCHAR(2) = NULL,
	@category_id INT = NULL	,
	@call_from VARCHAR(100) = NULL,
	@report_id INT = NULL,
	@process_id VARCHAR(50) = NULL
AS

SET NOCOUNT ON

/*
declare @flag CHAR(1) = NULL,
	@report_paramset_id INT = NULL,
	@report_owner VARCHAR(200) = NULL,
	@is_system VARCHAR(2) = NULL,
	@category_id INT = NULL	,
	@call_from VARCHAR(100) = NULL,
	@report_id INT = NULL,
	@process_id VARCHAR(50) = NULL

select @flag='z'
--*/

DECLARE @sql VARCHAR(MAX), @is_admin INT, @user_id VARCHAR(100)

SET @user_id = dbo.FNADBUser()

SET @process_id = ISNULL(@process_id, dbo.FNAGetNewID())

DECLARE @rfx_report VARCHAR(300) = dbo.FNAProcessTableName('report', @user_id, @process_id)
DECLARE @rfx_report_page VARCHAR(300) = dbo.FNAProcessTableName('report_page', @user_id, @process_id)
DECLARE @rfx_report_paramset VARCHAR(300) = dbo.FNAProcessTableName('report_paramset', @user_id, @process_id) 
DECLARE @rfx_report_dataset_paramset VARCHAR(300) = dbo.FNAProcessTableName('report_dataset_paramset', @user_id, @process_id)
DECLARE @rfx_report_param VARCHAR(300) = dbo.FNAProcessTableName('report_param', @user_id, @process_id)

IF @call_from IS NULL 
	SET @call_from = 'default'

--IF @report_owner IS NULL
--	SET @report_owner = dbo.FNADBUser()

--setting @is_admin	
SELECT @is_admin = dbo.FNAIsUserOnAdminGroup(@user_id, 1)

IF @flag = 's'
BEGIN
	SET @sql = 'SELECT ' + CASE WHEN @call_from <> 'view_grid_export' THEN 'report_paramset_id [Report Paramset ID], ' ELSE ' ' END +
				'report_id [Report ID]
				,MAX([Report Name]) [Report Name]				
				,MAX([Page]) [Page]
				,MAX([Paramset]) [Paramset]
				' + CASE WHEN @call_from <> 'view_grid_export' 
						THEN ',MAX(tree_filter_required) [Tree Filter Required]
						,MAX(other_filter_required) [Other Filter Required]
						,MAX(items_combined) [Items Combines]
						,MAX(paramset_hash) [Paramset Hash]
						,MAX([Report]) [Report Package] ' ELSE ' ' 
				    END +
				
				',CASE [is_system] WHEN 1 THEN ''Yes'' ELSE ''No'' END [Is System]
				,MAX([report_owner]) [Report Owner]
				,[Report Category]
				,CASE [Report status]	WHEN 1 THEN ''Draft''
					 WHEN 2 THEN ''Public''
					 WHEN 3 THEN ''Private''
					 WHEN 4 THEN ''Hidden''
				 END [Report Status]
				,' + CASE WHEN @is_admin = 1 THEN '''admin''' ELSE 'dbo.FNADBUser()' END + ' [Effective User]
				 FROM (
					SELECT DISTINCT rps.report_paramset_id
						, r.report_id
						, sdv.code [Report Category]
						, MAX(r.name) [Report]
						, MAX(rp.[name]) [Page]
						, MAX(rps.[name]) [Paramset]			
						--treat no widget as TEXTBOX (1)
						, SUM(CASE WHEN ISNULL(rpm.hidden, -1) <> 1 AND (ISNULL(dsc.widget_id, 1) IN (3, 4, 5)) THEN 1 ELSE 0 END) tree_filter_required
						, SUM(CASE WHEN ISNULL(rpm.hidden, -1) <> 1 AND (ISNULL(dsc.widget_id, 1) NOT IN (3, 4, 5)) THEN 1 ELSE 0 END) other_filter_required
						, dbo.FNARFXGenerateReportItemsCombined(MAX(rp.report_page_id)) items_combined
						, rps.paramset_hash
						, (CASE when MAX(rps.[name]) <> ''Default'' THEN MAX(rps.[name]) ELSE MAX(r.name) + '' '' + MAX(rp.[name] ) END) [Report Name]
						, r.is_system [is_system]							
						, MAX(r.[owner]) [report_owner]	
						, MAX(rps.report_status_id) [Report Status]							
					FROM report r 
					INNER JOIN report_page rp ON rp.report_id = r.report_id
					INNER JOIN report_paramset rps ON  rps.page_id = rp.report_page_id
					LEFT JOIN report_dataset_paramset rdp ON rdp.paramset_id = rps.report_paramset_id
					LEFT JOIN report_param rpm ON rdp.report_dataset_paramset_id = rpm.dataset_paramset_id 
					LEFT JOIN data_source_column dsc ON dsc.data_source_column_id = rpm.column_id
					LEFT JOIN report_privilege rpv ON r.report_hash = rpv.report_hash	
					LEFT JOIN report_paramset_privilege rpp ON rpp.paramset_hash = rps.paramset_hash
					LEFT JOIN static_data_value sdv ON sdv.value_id = r.category_id				
					WHERE 1 = 1 		
					AND rp.is_deployed = 1			
				    AND ( ' + 
				    CASE WHEN @is_admin = 1 THEN '1 = 1' 
					ELSE 
				    '
				    r.[owner] = ''' + @user_id + '''' 
						+ CASE WHEN (@call_from = 'report_parameters' OR @call_from = 'my_report') THEN ' AND rps.report_status_id <> 1 ' 
								ELSE '' 
						 END +
				    'OR
				    (rps.report_status_id = 2 OR rps.report_status_id = 3 
						AND
						(	
							rpv.user_id = ''' + @user_id + ''' 
							OR rpv.role_id IN (SELECT role_id FROM dbo.FNAGetUserRole(''' + @user_id + ''')) 
							OR rpp.[user_id] = ''' + @user_id + '''
							OR rpp.role_id IN (SELECT role_id FROM dbo.FNAGetUserRole(''' + @user_id + '''))
						) 
						OR rps.report_status_id IN (1,4) AND rps.create_user = ''' + @user_id + '''
				    )'
				    END
				    +
					CASE WHEN (@call_from = 'report_parameters' OR @call_from = 'my_report') AND @is_admin = 0
						 THEN ' AND rps.report_status_id <> 1 '
						 ELSE ''
					END
					+
					CASE WHEN @category_id IS NOT NULL THEN ' AND sdv.value_id = ' + CAST(@category_id AS VARCHAR) 
						 ELSE ''
					END
					+
					CASE WHEN @report_id IS NOT NULL THEN ' AND r.report_id = ' + CAST(@report_id AS VARCHAR)
						ELSE ''
					END
					
				    +	
					' ) GROUP BY r.report_id, rps.report_paramset_id, rps.paramset_hash, r.is_system, sdv.code, rps.report_status_id
					
				) s
	            WHERE 1=1'
				+   
				CASE WHEN @is_system = 'Y' THEN ' AND s.is_system = 1 '
					 WHEN @is_system = 'N' THEN ' AND s.is_system = 0 '
				ELSE '' 
				END
				+
				CASE WHEN @report_owner IS NOT NULL THEN ' AND [report_owner] = ''' + @report_owner + ''''
					 ELSE ''
				END
				+				
				' GROUP BY report_paramset_id,report_id, [is_system], [Report Category], [Report Status]
				 ORDER BY MAX(s.[Report]), MAX(s.[Page]), MAX(s.[Paramset])'
			--print(@sql)
			EXEC (@sql)
END

IF @flag = 'm'  
BEGIN  
 	SET @sql = 'SELECT r.report_id [Report ID],
				   r.[name] Name, '
				   + CASE WHEN @call_from <> 'manage_grid_export' 
						  THEN '''<ul class=ul-inside-grid>''+((  
							SELECT ''<li class=grid-list-item-clean>'' + rp2.[name]  
							   FROM   report_page rp2  
							   WHERE  rp2.report_id = rp1.report_id  
							   ORDER BY  
									  rp2.report_page_id  
									  FOR XML PATH(''''), TYPE).value(''.[1]'', ''VARCHAR(5000)''  
							))+''</ul>''' 
						  ELSE ' rp1.name' 
				     END +
				   ' AS [Report Page(s)] 
					, CASE r.is_system WHEN 1 THEN ''Yes'' ELSE ''No'' END [Is System]			
					, r.owner [Owner]
					, ' + CASE WHEN @is_admin = 1 THEN '''admin''' ELSE 'dbo.FNADBUser()' END + ' [Effective User] 
					, ' + CASE WHEN @is_admin = 1 THEN '''Edit Report''' 
								ELSE 'ISNULL(CASE WHEN MAX(rp.report_privilege_type) = ''e'' THEN ''Edit Report'' ELSE (CASE WHEN r.owner = ''' + @user_id + ''' THEN ''Edit Report'' ELSE ''Add Paramset'' END) END, ''Edit Report'')' 
					      END + ' [Privilege Type]'
					 + CASE WHEN @call_from <> 'manage_grid_export' THEN ', r.report_hash [Report Hash] ' ELSE ' ' END +     
				'FROM   report r '
	
	SET @sql = @sql + CASE WHEN @is_admin = 1  THEN 
						'LEFT JOIN report_page rp1 ON  (r.report_id = rp1.report_id)  
						WHERE 1=1   
						'
						ELSE 
						'INNER JOIN report_dataset rd ON rd.report_id = r.report_id  
						LEFT JOIN report_privilege rp ON rp.report_hash = r.report_hash 
							AND (rp.[user_id] = ''' + @user_id + ''' OR rp.role_id IN (SELECT fur.role_id FROM dbo.FNAGetUserRole(''' + @user_id + ''') fur))
						LEFT JOIN report_page rp1 ON  (r.report_id = rp1.report_id)  
						WHERE 1=1 AND (r.owner = dbo.FNADBUser() OR rp.report_privilege_id IS NOT NULL)'
						END 
						+								 
						CASE WHEN @is_system = 'Y' THEN ' AND r.is_system = 1 '  
						  WHEN @is_system = 'N' THEN ' AND r.is_system = 0 '  
						  ELSE ''   
						END
						+
						CASE WHEN @category_id IS NOT NULL THEN ' AND r.category_id = ' + CAST(@category_id AS VARCHAR) 
							 ELSE ''
						END
						+
						CASE WHEN @report_owner IS NOT NULL THEN ' AND r.owner = ''' + @report_owner + ''''
							 ELSE ''
						END
						+
						' GROUP BY  
						  r.report_id,  
						  rp1.report_id,  
						  r.[name],r.is_system , r.report_hash, r.owner' 
						  + CASE WHEN @call_from = 'manage_grid_export' THEN ', rp1.name ' ELSE ' ' END +		  
						 'ORDER BY r.[name]'
     
   --print(@sql)  
   EXEC (@sql)  
END  
  
  
IF @flag = 'a'
BEGIN
	set @sql = '
	SELECT DISTINCT 
       MAX(rpm.report_param_id) report_param_id,
       MAX(rpm.column_id) column_id,
       dsc.name column_name,
       MAX(COALESCE(rpm.label, dsc.alias, dsc.name)) column_alias, 
       MAX(rpm.operator) operator, 
       MAX(rpm.initial_value) initial_value,
       MAX(rpm.initial_value2) initial_value2,
       MAX(dsc.param_data_source) param_data_source,
       MAX(dsc.param_default_value) param_default_value,
       MIN(rpm.optional + 0) optional, -- + 0 added since MIN function is not allowed for BIT data type.
       MAX(dsc.widget_id) widget_id,
       MAX(dsc.datatype_id) datatype_id,
       MAX(dsc.source_id) source_id,
	   MAX(rdt.name) datatype_name,
	   MAX(rps.report_paramset_id) report_paramset_id,
	   MAX(rwt.[name]) widget_type,
	   MAX(rpm.label) label, 
	   MIN(rpm.param_order) param_order
	   , MAX(ds.type_id) data_source_type
	FROM report r 
	INNER JOIN report_page rp ON  rp.report_id = r.report_id
	INNER JOIN report_paramset rps ON  rps.page_id = rp.report_page_id
	INNER JOIN report_dataset_paramset rdp ON rdp.paramset_id = rps.report_paramset_id
	INNER JOIN report_param rpm ON rdp.report_dataset_paramset_id = rpm.dataset_paramset_id 
	LEFT JOIN data_source_column dsc ON dsc.data_source_column_id = rpm.column_id
	LEFT JOIN report_datatype rdt ON rdt.report_datatype_id = dsc.datatype_id
	LEFT JOIN report_widget rwt ON rwt.report_widget_id = dsc.widget_id
	LEFT JOIN data_source ds on ds.data_source_id = dsc.source_id	
	WHERE rps.report_paramset_id IN (' + @report_paramset_id + ')
		AND rpm.hidden <> 1
	GROUP BY dsc.name
	ORDER BY param_order
	'
	EXEC (@sql) 
END

IF @flag = 'y' --get report owners of all report
BEGIN
	SELECT DISTINCT owner FROM report
END

else if @flag = 'z' -- report name listing on report manager UI left treegrid
begin
	set @sql ='
	select 
	''c_'' + cast(case when  r.category_id is null then -1 else r.category_id end as varchar(10)) [category_id]
	, case when sdv_cat.code is null then ''General'' else sdv_cat.code end [category_name]
	, ''r_'' + cast(r.report_id as varchar(10)) [report_id], r.name [report_name]
	, MAX(CONVERT(int,r.is_system)) [system_defined]  
	from report r
	left join static_data_value sdv_cat on sdv_cat.value_id = r.category_id
	'

	SET @sql = @sql + 
	CASE WHEN @is_admin = 1  THEN 
	'LEFT JOIN report_page rp1 ON  (r.report_id = rp1.report_id)  
	WHERE 1=1   
	'
	ELSE 
	'
	--INNER JOIN report_dataset rd ON rd.report_id = r.report_id  
	LEFT JOIN report_privilege rp ON rp.report_hash = r.report_hash 
		AND (rp.[user_id] = ''' + @user_id + ''' OR rp.role_id IN (SELECT fur.role_id FROM dbo.FNAGetUserRole(''' + @user_id + ''') fur))
	LEFT JOIN report_page rp1 ON  (r.report_id = rp1.report_id)  
	WHERE 1=1 AND (r.owner = dbo.FNADBUser() OR rp.report_privilege_id IS NOT NULL)'
	END 
						
	SET @sql = @sql + '
	GROUP BY r.category_id, sdv_cat.code, r.report_id, r.name
	order by [category_name], [report_name]
	'
	--print(@sql)
	exec(@sql) 
	
	
end
GO
