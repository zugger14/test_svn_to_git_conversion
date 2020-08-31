
IF OBJECT_ID(N'[dbo].[spa_view_report]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_view_report]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**
	Purpose					: View report related operations like listing of reports (report manager,excel addin), returning filter criteria as json, my reports pin operations
							  , excel addin report operations, custom report filter json listing, custom report filter json listing for mobile, listing reports and filters from web		services,etc.
	Created By				: braryal@pioneersolutionsglobal.com
	Created Date			: 2015-01-27
	Modified By				: sligal@pioneersolutionsglobal.com

	Parameters 					
	@flag					: Operation flag for various tasks and logic.
							  s => Returns the data to be loaded in the Accordion Grid in View Report.
							  z => Returns Excel report with parameters.
							  n => 
							  o => Generate excel addin snapshot and return file name.
							  b => For batch of excel add in reports.
							  c => Returns the JSON to create the parameter criteria for Custom Report.
							  p => To PIN report to My Report
							  d => To UNPIN report from My Report
							  m => 
							  k => Returns the JSON to create the parameter criteria for Custom Report in mobile.
							  f => Returns the JSON for Apply Filters.
							  a => Returns report_id,paramset_id from report_name (caller: view.link.php,buysell.match.php,deal.match.php).
							  x => Get Report manager reports for excel addin.
							  g => Load the list of report for web services.
							  l => Load the list the parameters of report for web services.
							  q => To run the report from the web services.
							  w => To check the privilege of report from web services.
							  j => Returns json items of paramset_id, name according to defined category in paramsets of report.

	@report_name			: Name of report.
	@report_id				: Report ID of report.
	@report_type			: Type of report (1=report manager,2=standard[spa_html],3=dashboard,4=excel addin,5=power BI).
	@report_param_id		: Report Paramset ID
	@product_category		: Product Category like trm,rec,set,fas,ems
	@runtime_user			: Run time user used to set context_info.
	@template_type			: Template Type like FORM.
	@view_report_filter_xml	: XML Format report filters from view report.
	@call_from				: Call from value.
	@view_id				: Pivot View ID saved on view report pivot.
    @batch_process_id		: Batch Unique ID for batch process
	@batch_report_param		: Batch params required for batch process.
	@export_format			: Export file format for excel addin reports.
	@filter_string			: Report filter string used for excel addin reports.
	@paramset_hash			: Paramset Hash string used for api filter.
	@paraset_category_id    : Paramset Category used in paramset of report.
	@param_filter_xml		: XML Format filter used in different FORM.
	@dashboard_id			: Dashboard ID to show the default saved parameter's value.

*/
CREATE PROCEDURE [dbo].[spa_view_report]
	@flag CHAR(1) = NULL,
	@report_name VARCHAR(200) = NULL,
	@report_id INT = NULL,
	@report_type INT = NULL,
	@report_param_id varchar(2000) = NULL,
	@product_category INT = 10000000,
	@runtime_user VARCHAR(100)  = NULL,
	@template_type VARCHAR(8) = 'FORM',
	@view_report_filter_xml TEXT = NULL,
	@call_from VARCHAR(500) = NULL,
	@view_id INT = NULL,
    @batch_process_id varchar(100) = NULL,
	@batch_report_param varchar(max) = NULL,
	@export_format VARCHAR(25) = 'PNG',
	@filter_string VARCHAR(MAX) = NULL,
	@paramset_hash  VARCHAR(250) = NULL,
	@paraset_category_id INT = NULL,
	@param_filter_xml NVARCHAR(MAX) = NULL,
	@dashboard_id INT = NULL
AS
IF ISNULL(@runtime_user, '') <> '' AND @runtime_user <> dbo.FNADBUser()   
BEGIN
	--EXECUTE AS USER = @runtime_user;
	DECLARE @contextinfo VARBINARY(128)
	SELECT @contextinfo = CONVERT(VARBINARY(128), @runtime_user)
	SET CONTEXT_INFO @contextinfo
END

/*********************DEBUG*******************

--PRINT @call_from
DECLARE 
	@flag CHAR(1) = NULL,
	@report_name VARCHAR(200) = NULL,
	@report_id INT = NULL,
	@report_type INT = NULL,
	@report_param_id varchar(2000) = NULL,
	@product_category INT = 10000000,
	@runtime_user VARCHAR(100)  = NULL,
	@template_type VARCHAR(8) = 'FORM',
	@view_report_filter_xml VARCHAR(MAX) = NULL,
	@call_from VARCHAR(500) = NULL,
	@view_id INT = NULL,
    @batch_process_id varchar(100) = NULL,
	@batch_report_param varchar(max) = NULL,
	@export_format VARCHAR(25) = 'PNG',
	@filter_string VARCHAR(MAX) = NULL,
	@paramset_hash  VARCHAR(250) = NULL,
	@paraset_category_id INT = NULL,
	@param_filter_xml NVARCHAR(MAX) = NULL

--SELECT @flag='c',@report_param_id='42901,42910',@call_from='pinned_report'
SELECT @flag = 'q', @paramset_hash = '4081CCA5_B7FE_47B8_8564_1E2561A672EC', @view_report_filter_xml='[{"buy_sell":"","contract_id":"","counterparty_id":"","prod_date":"2018-04-01","invoice_type":""}]'
--************************************/

SET NOCOUNT ON
DECLARE @sql VARCHAR(MAX)
DECLARE @is_admin INT
DECLARE @user_name VARCHAR(100) = dbo.FNADBUser()
DECLARE @tab_process_table VARCHAR(300)
DECLARE @report_process_table VARCHAR(7000)
DECLARE @report_grid_name_process_table VARCHAR(300)
DECLARE @process_id VARCHAR(300) = REPLACE(newid(),'-','_')
DECLARE @process_id2 VARCHAR(300) = REPLACE(newid(),'-','_')
DECLARE @process_id3 VARCHAR(300) = REPLACE(newid(),'-','_')
DECLARE @application_group_id INT
--DECLARE @report_param_id INT
DECLARE @max_id INT
DECLARE @items_combined VARCHAR(250)
DECLARE @column_id VARCHAR(25)
DECLARE @operator VARCHAR(25)
DECLARE @id INT = 1
DECLARE @row_count INT = 0
DECLARE @report_path VARCHAR(250)

SELECT @is_admin = dbo.FNAIsUserOnAdminGroup(@user_name, 1)
DECLARE @check_report_admin_role INT = ISNULL(dbo.FNAReportAdminRoleCheck(@user_name), 0)

declare @document_path VARCHAR(500)
SELECT @document_path = cs.document_path FROM connection_string cs

--set @report_id with help of @report_param_id
if nullif(@report_param_id, '') is not null and @flag in ('k','c') --only for k and c flag, since other flag comes with report_id with value and web services flag will have paramset_hash on report_param_id.
begin
	select @report_id = max(r.report_id)
	from report_paramset rpm
	inner join report_page rpg on rpg.report_page_id = rpm.page_id
	inner join report r on r.report_id = rpg.report_id
	inner join dbo.SplitCommaSeperatedValues(@report_param_id) scsv on scsv.item = rpm.report_paramset_id
end
--decodeing xml values
--set @view_report_filter_xml = dbo.FNAURLDecode(@view_report_filter_xml)

IF OBJECT_ID('tempdb..#accordion_report_grid') IS NOT NULL
	DROP TABLE #accordion_report_grid

CREATE TABLE #accordion_report_grid(
	accordion_id VARCHAR(200) COLLATE DATABASE_DEFAULT,
	accordion_name VARCHAR(200) COLLATE DATABASE_DEFAULT,
	height VARCHAR(25) COLLATE DATABASE_DEFAULT DEFAULT ('*')
)
 
INSERT INTO #accordion_report_grid
(accordion_id, accordion_name)
	SELECT DISTINCT ISNULL(cat.code, 'General') AS accordion_id,ISNULL(cat.code, 'General') AS accordion_name
	FROM report_paramset rp
	inner JOIN report_page rpg on rpg.report_page_id = rp.page_id
	inner join report r on r.report_hash = rpg.report_hash
	left join static_data_value cat on cat.value_id = r.category_id
	left join report_privilege rpv on rpv.report_hash = r.report_hash 
	left join report_paramset_privilege rpp on rpp.paramset_hash = rp.paramset_hash
	WHERE 1 = 1 
		and rpg.is_deployed = 1
		AND 
		(
			@is_admin = 1
			or
			(
				r.[owner] = @user_name
				OR
				(rp.report_status_id = 2 OR rp.report_status_id = 3 
					AND
					(	
						rpv.user_id = @user_name
						OR rpv.role_id IN (SELECT role_id FROM dbo.FNAGetUserRole(@user_name)) 
						OR rpp.[user_id] = @user_name
						OR rpp.role_id IN (SELECT role_id FROM dbo.FNAGetUserRole(@user_name))
					) 
					OR rp.report_status_id IN (1,4) AND rp.create_user = @user_name
				)
			)
		)
	UNION ALL
	SELECT 'My Reports' AS report, 'My Reports' AS category
	UNION ALL 
	SELECT 'Standard Reports' AS report, 'Standard Reports' AS category
	UNION ALL
	SELECT 'Dashboard Reports' AS report, 'Dashboard Reports' AS category
	UNION ALL
	SELECT 
		sdv11.code [accordion_id],
		sdv11.code	[accordion_name]	
		FROM excel_sheet es
		-- Modified this logic because, there may not always be excel sheet snapshot for excel sheet
		LEFT JOIN excel_sheet_snapshot ess ON ess.excel_sheet_id = es.excel_sheet_id AND es.[snapshot] = 1
		INNER JOIN static_data_value sdv11 ON sdv11.value_id = es.category_id
		GROUP BY es.category_id, sdv11.code
	UNION ALL
	SELECT 'Power BI Reports' AS report, 'Power BI Reports' AS category


-- Returns the data to be loaded in the Accordion Grid in View Report
IF @flag = 's'
BEGIN
	CREATE TABLE #grid_data (
		report_category NVARCHAR(200) COLLATE DATABASE_DEFAULT
	  , report_name NVARCHAR(200) COLLATE DATABASE_DEFAULT
	  , report_id NVARCHAR(200) COLLATE DATABASE_DEFAULT
	  , report_type NVARCHAR(200) COLLATE DATABASE_DEFAULT
	  , paramset_id NVARCHAR(200) COLLATE DATABASE_DEFAULT
	  , report_unique_identifier NVARCHAR(200) COLLATE DATABASE_DEFAULT
	  , system_defined NVARCHAR(200) COLLATE DATABASE_DEFAULT
	  , excel_doc_type NVARCHAR(200) COLLATE DATABASE_DEFAULT
	)

	IF @call_from IN ('document_generation', 'calculation_engine')
	BEGIN
		DECLARE @excel_doc_type VARCHAR(25)
		SELECT @excel_doc_type = value_id 
		FROM static_data_value AS sdv
		WHERE sdv.[description] = @call_from
		
		INSERT INTO #grid_data
		SELECT DISTINCT arg.accordion_id [report_category], all_reports.report_name, all_reports.report_id, report_type, paramset_id, '' report_unique_identifier, system_defined, excel_doc_type FROM (
			SELECT MAX(ISNULL(sdv11.code, 'General')) AS accordion_name,
				es.excel_sheet_id AS report_id,
				MAX(COALESCE(nullif(es.alias,''), es.sheet_name)) AS report_name,
				'4' AS report_type,
				p.paramset_ids  AS paramset_id,
				'3' AS accordion_order,
				0 AS system_defined,
				CAST(es.excel_sheet_id AS VARCHAR(20)) report_unique_identifier,
				MAX(es.document_type) AS excel_doc_type
			FROM excel_sheet es
			LEFT JOIN excel_sheet_snapshot ess ON ess.excel_sheet_id = es.excel_sheet_id
			LEFT JOIN static_data_value sdv11 ON sdv11.value_id = es.category_id
			LEFT JOIN excel_report_privilege erp ON (erp.[value_id] = es.excel_sheet_id OR (erp.type_id = es.excel_file_id AND NULLIF(erp.value_id, 0) IS NULL))
			OUTER APPLY (
					--get only one role for which privilege is provided
					SELECT TOP 1 aru.role_id
					FROM application_role_user AS aru
					WHERE aru.role_id = erp.role_id AND aru.user_login_id = @user_name
			) rs_role
			OUTER APPLY (					
				SELECT STUFF((SELECT ',' + CAST(rp.report_paramset_id AS VARCHAR(10)) [text()]
							   FROM   excel_sheet AS es
									  INNER JOIN report_paramset AS rp
										-- Updated to support backward compatibility (excel addin reports created by previous version doesnt have paramset hash) 
											ON ISNULL(es.paramset_hash,es.alias) = CASE WHEN es.paramset_hash IS NOT NULL THEN rp.paramset_hash ELSE rp.[name] END 
							   WHERE  excel_file_id = es1.excel_file_id
									  FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'),1,1,'') paramset_ids               
				FROM   excel_sheet  AS es1
					   CROSS APPLY(
					SELECT es2.excel_file_id
					FROM   excel_sheet AS es2
					WHERE  es2.excel_sheet_id = es.excel_sheet_id
				)                      b
				WHERE  es1.excel_file_id = b.excel_file_id
				GROUP BY
					   es1.excel_file_id
			) p
			WHERE es.[snapshot] = 1 
					AND 
					(	
						@is_admin = 1							--if user is super user
						OR @check_report_admin_role = 1			--if user is Reporting Admin
						OR es.[create_user] = @user_name		--if the user is the report creator
						OR (erp.[user_id] = @user_name OR rs_role.role_id IS NOT NULL)	--user or role is explicitly assigned privilege
					)
					AND ( es.document_type = @excel_doc_type )
			GROUP BY es.excel_sheet_id, p.paramset_ids
		) AS all_reports
		LEFT JOIN #accordion_report_grid arg ON all_reports.accordion_name = arg.accordion_name
		Order by report_category, all_reports.report_name
	END
	ELSE IF @call_from = 'run_process'
	BEGIN
		INSERT INTO #grid_data
		SELECT DISTINCT arg.accordion_id [report_category], all_reports.report_name, all_reports.report_id, report_type, paramset_id, report_unique_identifier, system_defined, excel_doc_type FROM (
		-- Report Manager Report
		--Same code block is also used in flag = x for Excel AddIn
		SELECT MAX(ISNULL(sdv.code, 'General')) AS accordion_name, 
			r.report_id AS report_id, MAX(r.name) report_name, max(rps.name) [report_package_name], '1' AS report_type, cast(rps.report_paramset_id as varchar(100)) AS paramset_id, '3' AS accordion_order, MAX(CONVERT(int,r.is_system))  [system_defined]
			, MAX(rps.paramset_hash) report_unique_identifier
			, NULL AS excel_doc_type
			FROM report r 
			INNER JOIN report_page rp ON rp.report_id = r.report_id
			INNER JOIN report_paramset rps ON  rps.page_id = rp.report_page_id
			LEFT JOIN report_dataset_paramset rdp ON rdp.paramset_id = rps.report_paramset_id
			LEFT JOIN report_param rpm ON rdp.report_dataset_paramset_id = rpm.dataset_paramset_id 
			LEFT JOIN report_privilege rpv ON r.report_hash = rpv.report_hash
			--AND (rpv.[user_id] = @user_name OR rpv.role_id IN (SELECT fur.role_id FROM dbo.FNAGetUserRole(@user_name) fur))
			LEFT JOIN report_paramset_privilege rpp ON rpp.paramset_hash = rps.paramset_hash
			LEFT JOIN static_data_value sdv ON sdv.value_id = r.category_id			
			WHERE rp.is_deployed = 1	--Show deployed reports only as they are the ones that can be run.
				AND 
				(	
					@is_admin = 1						--Superuser (farrms_admin, WinAuth Admin or Application Admin Group) and Reporting Admin Group can see all reports.
					OR r.[owner] = @user_name			--Package owner can see all paramsets (even Draft or Hidden created by others in same package)
					OR rps.create_user = @user_name		--Paramset owner should see her report regardless of its status
					OR rps.report_status_id = 2			--Public reports should be visible to all
					OR (rps.report_status_id = 3		--Private report and
						AND (@user_name IN (rpv.user_id, rpp.[user_id])	--got directly assigned privilege
								OR EXISTS(SELECT role_id FROM dbo.FNAGetUserRole(@user_name) WHERE role_id IN (rpv.role_id, rpp.role_id))	--got privilege via role
							)
					)
				)
				AND r.category_id = -10008	--Show reports for report category type 'Processes' only
			GROUP BY   rps.report_paramset_id , rp.report_page_id, r.report_id
		) AS all_reports
		LEFT JOIN #accordion_report_grid arg ON all_reports.accordion_name = arg.accordion_name
		ORDER BY report_category, all_reports.report_name
	END
	ELSE IF @call_from = 'data_export'
	BEGIN
		INSERT INTO #grid_data
		SELECT DISTINCT arg.accordion_id [report_category], all_reports.report_name, all_reports.report_id, report_type, paramset_id, report_unique_identifier, system_defined, excel_doc_type FROM (
		-- Report Manager Report
		--Same code block is also used in flag = x for Excel AddIn
		SELECT MAX(ISNULL(sdv.code, 'General')) AS accordion_name, 
			r.report_id AS report_id, MAX(r.name) report_name, max(rps.name) [report_package_name], '1' AS report_type, cast(rps.report_paramset_id as varchar(100)) AS paramset_id, '3' AS accordion_order, MAX(CONVERT(int,r.is_system))  [system_defined]
			, MAX(rps.paramset_hash) report_unique_identifier
			, NULL AS excel_doc_type
			FROM report r 
			INNER JOIN report_page rp ON rp.report_id = r.report_id
			INNER JOIN report_paramset rps ON  rps.page_id = rp.report_page_id
			LEFT JOIN report_dataset_paramset rdp ON rdp.paramset_id = rps.report_paramset_id
			LEFT JOIN report_param rpm ON rdp.report_dataset_paramset_id = rpm.dataset_paramset_id 
			LEFT JOIN report_privilege rpv ON r.report_hash = rpv.report_hash
			--AND (rpv.[user_id] = @user_name OR rpv.role_id IN (SELECT fur.role_id FROM dbo.FNAGetUserRole(@user_name) fur))
			LEFT JOIN report_paramset_privilege rpp ON rpp.paramset_hash = rps.paramset_hash
			LEFT JOIN static_data_value sdv ON sdv.value_id = r.category_id			
			WHERE rp.is_deployed = 1	--Show deployed reports only as they are the ones that can be run.
				AND 
				(	
					@is_admin = 1						--Superuser (farrms_admin, WinAuth Admin or Application Admin Group) and Reporting Admin Group can see all reports.
					OR r.[owner] = @user_name			--Package owner can see all paramsets (even Draft or Hidden created by others in same package)
					OR rps.create_user = @user_name		--Paramset owner should see her report regardless of its status
					OR rps.report_status_id = 2			--Public reports should be visible to all
					OR (rps.report_status_id = 3		--Private report and
						AND (@user_name IN (rpv.user_id, rpp.[user_id])	--got directly assigned privilege
								OR EXISTS(SELECT role_id FROM dbo.FNAGetUserRole(@user_name) WHERE role_id IN (rpv.role_id, rpp.role_id))	--got privilege via role
							)
					)
				)
				AND r.category_id = -10010	--Show reports for report category type 'Export' only
			GROUP BY   rps.report_paramset_id , rp.report_page_id, r.report_id
		) AS all_reports
		LEFT JOIN #accordion_report_grid arg ON all_reports.accordion_name = arg.accordion_name
		ORDER BY report_category, all_reports.report_name
	END
	ELSE
	BEGIN
		INSERT INTO #grid_data
		SELECT DISTINCT arg.accordion_id [report_category], all_reports.report_name, all_reports.report_id, report_type, paramset_id, '' report_unique_identifier, system_defined, excel_doc_type FROM (
		-- Report Manager Report
		--Same code block is also used in flag = x for Excel AddIn
		SELECT MAX(ISNULL(sdv.code, 'General')) AS accordion_name, 
			r.report_id AS report_id, MAX(rps.name) report_name, max(r.name) [report_package_name], '1' AS report_type, cast(rps.report_paramset_id as varchar(100)) AS paramset_id, '3' AS accordion_order, MAX(CONVERT(int,r.is_system))  [system_defined]
			, MAX(rps.paramset_hash) report_unique_identifier
			, NULL AS excel_doc_type
			FROM report r 
			INNER JOIN report_page rp ON rp.report_id = r.report_id
			INNER JOIN report_paramset rps ON  rps.page_id = rp.report_page_id
			LEFT JOIN report_dataset_paramset rdp ON rdp.paramset_id = rps.report_paramset_id
			LEFT JOIN report_param rpm ON rdp.report_dataset_paramset_id = rpm.dataset_paramset_id 
			LEFT JOIN report_privilege rpv ON r.report_hash = rpv.report_hash
			--AND (rpv.[user_id] = @user_name OR rpv.role_id IN (SELECT fur.role_id FROM dbo.FNAGetUserRole(@user_name) fur))
			LEFT JOIN report_paramset_privilege rpp ON rpp.paramset_hash = rps.paramset_hash
			LEFT JOIN static_data_value sdv ON sdv.value_id = r.category_id			
			WHERE rp.is_deployed = 1	--Show deployed reports only as they are the ones that can be run.
				AND 
				(	
					@is_admin = 1						--Superuser (farrms_admin, WinAuth Admin or Application Admin Group) and Reporting Admin Group can see all reports.
					OR r.[owner] = @user_name			--Package owner can see all paramsets (even Draft or Hidden created by others in same package)
					OR rps.create_user = @user_name		--Paramset owner should see her report regardless of its status
					OR rps.report_status_id = 2			--Public reports should be visible to all
					OR (rps.report_status_id = 3		--Private report and
						AND (@user_name IN (rpv.user_id, rpp.[user_id])	--got directly assigned privilege
								OR EXISTS(SELECT role_id FROM dbo.FNAGetUserRole(@user_name) WHERE role_id IN (rpv.role_id, rpp.role_id))	--got privilege via role
							)
					)
				)		
				--AND ISNULL(r.category_id, 2) > 1 -- Does not show reports of report category containg negative value id for eg: Processes, Regresion Testing
				AND isnull(r.category_id,-1) <> -10008
			GROUP BY   rps.report_paramset_id , rp.report_page_id, r.report_id
		UNION
		-- Custom Reports in the My Report
		SELECT 
			CASE 
				WHEN dashboard_report_flag IN ('r', 's') THEN 'My Reports' 
				WHEN dashboard_report_flag = 'd' THEN 'Dashboard Reports' 
			END as accordin_name, r.report_id, r.name, NULL, 
			CASE 
				WHEN dashboard_report_flag IN ('r', 'd') THEN '1' 
				WHEN dashboard_report_flag = 's' THEN '2' 
			END AS report_type,
			cast(CASE 
				WHEN dashboard_report_flag IN ('r', 's') THEN rps.report_paramset_id 
				WHEN dashboard_report_flag = 'd' THEN rps.report_paramset_id 
			END as varchar(200)) as paramset_id,
			CASE 
				WHEN dashboard_report_flag IN ('r', 's') THEN '1' 
				WHEN dashboard_report_flag = 'd' THEN '2' 
			END AS accordion_order,
			0 AS system_defined
			, r.report_hash report_unique_identifier
			, NULL AS excel_doc_type
		FROM my_report mr
		INNER JOIN report_paramset rps ON rps.paramset_hash = mr.paramset_hash
		LEFT JOIN report_page rp ON rps.page_id = rp.report_page_id
		INNER JOIN report r ON rp.report_id = r.report_id
		AND ISNULL(mr.my_report_owner, @user_name) = @user_name
		UNION
		-- Dashboard Reports in the My Report
		SELECT 
			'My Reports' as accordin_name, rtn.report_template_name_id, rtn.report_name, NULL,
			'3' AS report_type,
			cast(rps.report_paramset_id as varchar(200))  AS paramset_id,
			'1' AS accordion_order,
			0 AS system_defined
			, '' report_unique_identifier
			, NULL AS excel_doc_type
		FROM my_report mr
		INNER JOIN report_template_name rtn ON mr.dashboard_id = rtn.report_template_name_id
		LEFT JOIN report_paramset rps ON rps.paramset_hash = mr.paramset_hash
		AND ISNULL(mr.my_report_owner, @user_name) = @user_name
		UNION
		-- Standard Reports in the My Report
		SELECT 
			CASE 
				WHEN dashboard_report_flag IN ('r', 's') THEN 'My Reports' 
				WHEN dashboard_report_flag = 'd' THEN 'Dashboard Reports' 
			END as accordin_name, af.function_id, mr.my_report_name, NULL,
			CASE 
				WHEN dashboard_report_flag IN ('r', 'd') THEN '1' 
				WHEN dashboard_report_flag = 's' THEN '2' 
			END AS report_type,
			''  AS paramset_id,
			CASE 
				WHEN dashboard_report_flag IN ('r', 's') THEN '1' 
				WHEN dashboard_report_flag = 'd' THEN '2' 
			END AS accordion_order,
			0 AS system_defined
			, CASE dashboard_report_flag 
				WHEN 'r' THEN paramset_hash 
				WHEN 's' THEN CAST(af.function_id AS VARCHAR(10)) 
				ELSE '' 
			END report_unique_identifier
			, NULL AS excel_doc_type
		FROM my_report mr
		INNER JOIN application_functions af ON mr.application_function_id = af.function_id
		WHERE mr.my_report_owner = @user_name
		UNION
		-- Standard Reports
		SELECT DISTINCT 'Standard Reports' AS accordin_name, aut.application_function_id, aut.template_name, NULL, '2' AS report_type ,''  AS paramset_id, '4' AS accordion_order , 0 AS system_defined, CAST(aut.application_function_id AS VARCHAR(10)) report_unique_identifier, NULL AS excel_doc_type
		FROM application_ui_template aut
		INNER JOIN setup_menu sm 
			ON sm.function_id = aut.application_function_id
		LEFT JOIN application_functional_users afu 
			ON afu.function_id = aut.application_function_id 
			AND (COALESCE(afu.login_id, '-1') = @user_name OR EXISTS(
					SELECT role_id 
					FROM dbo.FNAGetUserRole(@user_name)
					WHERE role_id = afu.role_id
				) 
			)			
		WHERE aut.is_report = 'y' AND aut.active_flag = 'y' AND sm.product_category = @product_category
			AND (afu.functional_users_id IS NOT NULL	--Got privilege for the report
				OR @is_admin = 1						--Superuser
				OR (aut.application_function_id IN (10201900, 10202100, 10201500) 		--Data Import/Export Audit, Message Board Log, Static Data Audit Report
					AND dbo.FNAImportAdminRoleCheck(@user_name) = 1)					--Show above reports to Import Data Integration Group 		
				)									
		UNION
		--Dashboard Reports
		SELECT 
			'Dashboard Reports' as accordin_name, rtn.report_template_name_id, rtn.report_name, NULL, 
			'3' AS report_type,
			''  AS paramset_id,
			'2' AS accordion_order,
			0 AS system_defined,
			'' report_unique_identifier,
			NULL AS excel_doc_type
		FROM report_template_name rtn
		WHERE @is_admin = 1 OR (rtn.user_login_id=dbo.FNAdbUser() OR ISNULL(rtn.ispublic,'n')='y')
		UNION
		--Excel Reports
		SELECT MAX(ISNULL(sdv11.code, 'General')) AS accordion_name,
			es.excel_sheet_id AS report_id,
			MAX(COALESCE(nullif(es.alias,''), es.sheet_name)) AS report_name,
			NULL,
			'4' AS report_type,
			p.paramset_ids  AS paramset_id,
			'3' AS accordion_order,
			0 AS system_defined,
			CAST(es.excel_sheet_id AS VARCHAR(20)) report_unique_identifier,
			MAX(es.document_type) AS excel_doc_type
		FROM excel_sheet es
		LEFT JOIN excel_sheet_snapshot ess ON ess.excel_sheet_id = es.excel_sheet_id
		LEFT JOIN static_data_value sdv11 ON sdv11.value_id = es.category_id
		LEFT JOIN excel_report_privilege erp ON (erp.[value_id] = es.excel_sheet_id OR (erp.type_id = es.excel_file_id AND NULLIF(erp.value_id, 0) IS NULL))
		OUTER APPLY (
				--get only one role for which privilege is provided
				SELECT TOP 1 aru.role_id
				FROM application_role_user AS aru
				WHERE aru.role_id = erp.role_id AND aru.user_login_id = @user_name
		) rs_role
		OUTER APPLY (					
			SELECT STUFF((SELECT ',' + CAST(rp.report_paramset_id AS VARCHAR(10)) [text()]
						   FROM   excel_sheet AS es
								  INNER JOIN report_paramset AS rp
									-- Updated to support backward compatibility (excel addin reports created by previous version doesnt have paramset hash) 
										ON ISNULL(es.paramset_hash,es.alias) = CASE WHEN es.paramset_hash IS NOT NULL THEN rp.paramset_hash ELSE rp.[name] END 
						   WHERE  excel_file_id = es1.excel_file_id
								  FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'),1,1,'') paramset_ids               
			FROM   excel_sheet  AS es1
				   CROSS APPLY(
				SELECT es2.excel_file_id
				FROM   excel_sheet AS es2
				WHERE  es2.excel_sheet_id = es.excel_sheet_id
			)                      b
			WHERE  es1.excel_file_id = b.excel_file_id
			GROUP BY
				   es1.excel_file_id
		) p
		WHERE es.[snapshot] = 1 
				AND 
				(	
					@is_admin = 1							--if user is super user
					OR @check_report_admin_role = 1			--if user is Reporting Admin
					OR es.[create_user] = @user_name		--if the user is the report creator
					OR (erp.[user_id] = @user_name OR rs_role.role_id IS NOT NULL)	--user or role is explicitly assigned privilege
				)
				AND ( es.document_type NOT IN ( SELECT value_id FROM static_data_value WHERE [type_id] = 106700 AND value_id <> 106700 ) OR es.document_type IS NULL )
		GROUP BY es.excel_sheet_id, p.paramset_ids
		UNION
		SELECT 
			'Power BI Reports' as accordin_name, 
			pbr.power_bi_report_id report_id, 
			rps01.[name]  + ' - BI' report_name, 
			rps01.[name] AS report_package_name, 
			'5' AS report_type,
			CAST(rps01.report_paramset_id AS VARCHAR)  AS paramset_id,
			'3' AS accordion_order,
			0 AS system_defined,
			pbr.powerbi_report_id report_unique_identifier,
			NULL AS excel_doc_type
			FROM power_bi_report AS [pbr]
				left JOIN report_paramset rps01 ON  rps01.paramset_hash = pbr.[source_report]
				left join  report_page rp01 on rp01.report_page_id = rps01.page_id
				left join report r on r.report_id = rp01.report_id
			where pbr.is_published = 1 AND r.is_powerbi = 1 and pbr.powerbi_report_id <> '' AND  pbr.powerbi_report_id is not null
			and rp01.is_deployed = 1
		) AS all_reports
		LEFT JOIN #accordion_report_grid arg ON all_reports.accordion_name = arg.accordion_name
		Order by report_category, all_reports.report_name
	END

	SELECT report_category
		 , report_name
		 , report_id
		 , report_type
		 , paramset_id
		 , '' report_unique_identifier -- Note: bypass UI data caching by setting report_unique_identifier to ''.
		 , system_defined
		 , excel_doc_type
	FROM #grid_data
END 
	
-- Returns Excel report with parameters
ELSE IF @flag = 'z'
BEGIN
	SELECT 
		ess.excel_sheet_snapshot_id,
		ess.snapshot_applied_filter,
		dbo.FNADateTimeFormat(ess.snapshot_refreshed_on, 0) snapshot_refreshed_on,
		ess.snapshot_filename AS [snapshot_filename],
		COALESCE(es.alias, es.sheet_name) AS report_name,
		' | ' + es.[description] AS [description]
		
   
		FROM excel_sheet es
		INNER JOIN excel_sheet_snapshot ess ON ess.excel_sheet_id = es.excel_sheet_id
		LEFT JOIN static_data_value sdv11 ON sdv11.value_id = es.category_id  
		CROSS APPLY (
		SELECT MAX(excel_sheet_snapshot_id)     lastest_snapshot_id
		FROM   excel_sheet_snapshot e
		WHERE  e.excel_sheet_id = @report_id
		)
		rs_lates
		WHERE  es.[snapshot] = 1
			AND es.excel_sheet_id = @report_id
			AND rs_lates.lastest_snapshot_id = ess.excel_sheet_snapshot_id	
END

ELSE IF @flag = 'n'
BEGIN
	
	DECLARE @excel_sheet_snapshot_id INT
	DECLARE @snapshot_applied_filter VARCHAR(500)
	DECLARE @snapshot_refreshed_on VARCHAR(500)
	DECLARE @snapshot_filename VARCHAR(500)
	DECLARE @report_title VARCHAR(500)
	DECLARE @report_desc VARCHAR(500)
	DECLARE @filepath VARCHAR(500)
	DECLARE @file_exists INT
	
	SELECT 
		@excel_sheet_snapshot_id = ess.excel_sheet_snapshot_id,
		@snapshot_applied_filter = ess.snapshot_applied_filter,
		@snapshot_refreshed_on = ess.snapshot_refreshed_on,
		@snapshot_filename = ess.snapshot_filename,-- AS [snapshot_filename],
		@report_title = COALESCE(nullif(es.alias,''), es.sheet_name),-- AS report_name
		@report_desc = es.[description]
   
		FROM excel_sheet es
		INNER JOIN excel_sheet_snapshot ess ON ess.excel_sheet_id = es.excel_sheet_id
		LEFT JOIN static_data_value sdv11 ON sdv11.value_id = es.category_id  
		CROSS APPLY (
		SELECT MAX(excel_sheet_snapshot_id)     lastest_snapshot_id
		FROM   excel_sheet_snapshot e
		WHERE  e.excel_sheet_id = @report_id AND e.snapshot_filename LIKE '%.PNG'
		)
		rs_lates
		WHERE  es.[snapshot] = 1
			AND es.excel_sheet_id = @report_id
			AND rs_lates.lastest_snapshot_id = ess.excel_sheet_snapshot_id
			AND ess.snapshot_filename LIKE '%.PNG'
	
	
	SELECT @file_exists = dbo.FNAFileExists(cs.document_path + '\temp_note\' + @snapshot_filename) FROM connection_string cs	
	
	IF @file_exists = 1
	BEGIN
		SELECT 
		@excel_sheet_snapshot_id  excel_sheet_snapshot_id,
		@snapshot_applied_filter snapshot_applied_filter,
		dbo.FNADateTimeFormat(@snapshot_refreshed_on, 0) snapshot_refreshed_on,
		@snapshot_filename AS [snapshot_filename],
		@report_title AS report_name,
		' | ' + @report_desc AS [description]
		
		-- Insert data to pivot view for dashboard report
		DECLARE @view_name VARCHAR(255) = NULL
		DECLARE @new_id INT = NULL

		SELECT @view_name = sheet_name + ' - Excel' FROM excel_sheet WHERE excel_sheet_id = @report_id

		SELECT @paramset_hash = MAX(es.paramset_hash)
		FROM excel_sheet es
		LEFT JOIN excel_file ef ON es.excel_file_id = ef.excel_file_id
		CROSS APPLY (SELECT excel_file_id FROM excel_sheet WHERE excel_sheet_id = @report_id) a
		WHERE ef.excel_file_id = a.excel_file_id
			
		SELECT @new_id = pivot_report_view_id
		FROM pivot_report_view prv
		WHERE prv.pivot_report_view_name = @view_name 
		AND prv.paramset_hash = @paramset_hash
		AND prv.excel_sheet_id = @report_id
				
		IF OBJECT_ID('tempdb..#temp_report_filters') IS NOT NULL
			DROP TABLE #temp_report_filters
			
		CREATE TABLE #temp_report_filters (
			column_name VARCHAR(200) COLLATE DATABASE_DEFAULT,
			column_value VARCHAR(MAX) COLLATE DATABASE_DEFAULT
		)

		IF NULLIF(@new_id, '') IS NULL
		BEGIN
				
			INSERT INTO pivot_report_view(pivot_report_view_name, renderer, is_public, excel_sheet_id, pin_it, paramset_hash)
			SELECT @view_name, '', 1, @report_id, 0, @paramset_hash

			SET @new_id = SCOPE_IDENTITY()				
		END

		INSERT INTO #temp_report_filters (column_name, column_value)
		SELECT SUBSTRING(item, 0, CHARINDEX('=', item)), 
				CASE WHEN LEN(item) - 1 - LEN(SUBSTRING(item, 0, CHARINDEX('=', item))) > 0 THEN NULLIF(RIGHT(item, LEN(item) - 1 - LEN(SUBSTRING(item, 0, CHARINDEX('=', item)))), 'NULL') ELSE NULL END
		FROM dbo.SplitCommaSeperatedValues(@filter_string)
		WHERE CHARINDEX('=', item) <> 0

		UPDATE pvp
		SET column_value = temp.column_value
		FROM pivot_view_params pvp
		INNER JOIN data_source_column dsc ON dsc.data_source_column_id = pvp.column_id
		INNER JOIN #temp_report_filters temp ON temp.column_name = dsc.name
		WHERE pvp.view_id = @new_id
				
		INSERT INTO pivot_view_params (
			view_id,
			column_id,
			column_name,
			column_value
		)
		SELECT @new_id, dsc.data_source_column_id, dsc.name, trf.column_value
		FROM report_paramset rp
		INNER JOIN report_dataset_paramset rdp ON rdp.paramset_id = rp.report_paramset_id
		INNER JOIN report_param rp2 ON rp2.dataset_paramset_id = rdp.report_dataset_paramset_id
		INNER JOIN data_source_column dsc ON dsc.data_source_column_id = rp2.column_id
		INNER JOIN #temp_report_filters trf ON dsc.name = trf.column_name
		LEFT JOIN pivot_view_params pvp ON pvp.column_id = dsc.data_source_column_id AND pvp.view_id = @new_id
		WHERE rp.paramset_hash = @paramset_hash AND pvp.pivot_view_params_id IS NULL
	END
	
END

--Generate excel addin snapshot and return file name.
ELSE IF @flag = 'o'
BEGIN
		EXEC spa_synchronize_excel_reports @excel_sheet_id=@report_id, @synchronize_report='y', @image_snapshot='y',@view_report_filter_xml=@view_report_filter_xml, @process_id=@process_id, @export_format = @export_format, @suppress_result = 'y'
		
		IF (@export_format = 'excel')
		BEGIN
			SELECT 
				ess.excel_sheet_snapshot_id excel_sheet_snapshot_id,
				ess.snapshot_applied_filter snapshot_applied_filter,
				ess.snapshot_refreshed_on snapshot_refreshed_on,
				@process_id + '.xlsx' [snapshot_filename],
				'' report_name,
				'' [description] 
			FROM excel_sheet_snapshot AS ess WHERE ess.process_id = @process_id
			RETURN
		END

		IF EXISTS (SELECT 1 FROM excel_sheet_snapshot AS ess WHERE ess.process_id = @process_id)
		BEGIN
			IF @export_format = 'PNG' -- Needed for Dashboard excel report view
			BEGIN
				EXEC spa_view_report 'n', @report_id = @report_id, @filter_string = @filter_string
			END
			ELSE
			BEGIN
				EXEC spa_view_report 'z', @report_id = @report_id
			END
		END
		ELSE
			SELECT 
			 '' excel_sheet_snapshot_id,
			'' snapshot_applied_filter,
			'' snapshot_refreshed_on,
			'' [snapshot_filename],
			'' report_name,
			'Error: Failed to synchronize.' [description]
END

ELSE IF @flag = 'b' --for batch of excel add in reports.
BEGIN
		DECLARE @output_filename VARCHAR(5000)
		DECLARE @proc_desc VARCHAR(MAX) = 'BatchReport (Excel Addin)'
		DECLARE @url VARCHAR(2000)
		DECLARE @desc_success VARCHAR(MAX)
		DECLARE @email_description varchar(4000)

		IF @export_format = 'PDF'
		BEGIN
			DECLARE @excel_filename VARCHAR(100)
			SELECT @process_id = REPLACE(NEWID(),'-','_')

			EXEC spa_synchronize_excel_reports @excel_sheet_id=@report_id, @synchronize_report='y', @image_snapshot='y',@view_report_filter_xml=@view_report_filter_xml, @process_id=@process_id, @export_format = @export_format, @suppress_result = 'y'

			SELECT @excel_filename = snapshot_filename FROM excel_sheet_snapshot WHERE process_id = @process_id
			SELECT @report_name = COALESCE(NULLIF(es.alias,''), es.sheet_name)
			FROM excel_sheet es
			WHERE es.excel_sheet_id = @report_id

			SET @output_filename = @document_path + '\temp_note\' + @excel_filename
			SET @url = '../../adiha.php.scripts/force_download.php?path=dev/shared_docs/temp_note/'
			SET @desc_success = 'Batch process completed for <b>' + @report_name + '</b>. Report has been saved. Please <a target="_blank" href="'+  @url + @excel_filename + '"><b> Click Here</b></a> to download.'
			
		END
		ELSE
		BEGIN
			EXEC spa_synchronize_excel_reports @excel_sheet_id=@report_id, @synchronize_report='y', @image_snapshot='y',@view_report_filter_xml=@view_report_filter_xml, @process_id=@process_id, @export_format = 'PNG', @suppress_result = 'y'

			SELECT @report_name = COALESCE(NULLIF(es.alias,''), es.sheet_name)
			FROM excel_sheet es
			WHERE es.excel_sheet_id = @report_id

			SET @output_filename = @document_path + '\temp_Note\' + @process_id + '.xlsx'
			SET @url = '../../adiha.php.scripts/force_download.php?path=dev/shared_docs/temp_Note/'
			SET @desc_success = 'Batch process completed for <b>' + @report_name + '</b>. Report has been saved. Please <a target="_blank" href="'+  @url + @process_id + '.xlsx"><b> Click Here</b></a> to download.'
		END
		--declare @nvar nvarchar(100)
		--exec spa_create_file @filename=@output_filename, @result=@nvar output
		
		IF EXISTS (SELECT 1 FROM excel_sheet_snapshot AS ess WHERE ess.process_id = @process_id)
		BEGIN	
			SET @email_description = 'Batch process completed for <b>' + @report_name + '</b>.'
			
		END
		ELSE
		BEGIN
			SET @desc_success = 'Batch process error for <b>' + @report_name + '</b>.'
		END

		EXEC spa_message_board @flag = 'u', @user_login_id = @user_name, @source = @proc_desc , @description = @desc_success , @url_desc = '', @url = '',@type = 's', @process_id = @batch_process_id,@email_enable = 'y', @email_description = @email_description,@file_name = @output_filename, @email_subject = 'TRM Tracker Notifications', @is_aggregate = 0
			
END

-- Returns the JSON to create the parameter criteria for Custom Report.
IF @flag = 'c'
BEGIN	
	-- Default size
	DECLARE @default_field_size			INT
		, @default_column_num_per_row	INT
		, @default_offsetleft			INT
		, @default_fieldset_offsettop	INT
		, @default_filter_field_size	INT
		, @default_fieldset_width		INT =1000
	
	-- Set Default Values
	SELECT @default_field_size =  var_value 
	FROM adiha_default_codes_values 
	WHERE default_code_id = 86 AND instance_no = 1
		AND seq_no = CASE WHEN @template_type = 'FORM' THEN   1  ELSE  7 END  

	SELECT @default_column_num_per_row =  var_value FROM adiha_default_codes_values WHERE default_code_id = 86 AND seq_no = 4 AND instance_no = 1
	SELECT @default_offsetleft =  var_value FROM adiha_default_codes_values WHERE default_code_id = 86 AND seq_no = 3 AND instance_no = 1
	SELECT @default_fieldset_offsettop =  var_value FROM adiha_default_codes_values WHERE default_code_id = 86 AND seq_no = 5 AND instance_no = 1
	SELECT @default_fieldset_width =  var_value FROM adiha_default_codes_values WHERE default_code_id = 86 AND seq_no = 8 AND instance_no = 1

	SET @tab_process_table = dbo.FNAProcessTableName('tab_process_table', @user_name, @process_id2)
	SET @report_process_table = dbo.FNAProcessTableName('report_process_table', @user_name, @process_id)
	SET @report_grid_name_process_table = dbo.FNAProcessTableName('report_grid_name_process_table', @user_name, @process_id3)
	
	SET @sql = '
			SELECT 
				application_group_id,ISNULL(field_layout,''1C'') field_layout,application_grid_id,ISNULL(sequence,1)  sequence, ''n'' is_udf_tab, REPLACE(ag.group_name, ''"'', ''\"'') group_name, ag.default_flag, ''n'' is_new_tab
			INTO '+@tab_process_table+'
			FROM	application_ui_template_group ag 
					INNER JOIN application_ui_template at on at.application_ui_template_id = ag.application_ui_template_id
			WHERE 
				application_function_id = 10202200 AND at.template_name = ''report template''
			ORDER BY ag.sequence asc '
	EXEC(@sql)
	
	SELECT @application_group_id = application_group_id
	FROM application_ui_template_group ag 
	INNER JOIN application_ui_template at on at.application_ui_template_id = ag.application_ui_template_id
	WHERE application_function_id = 10202200 AND at.template_name = 'report template'
	
	--SELECT @report_param_id = rps.report_paramset_id
	--FROM report r 
	--INNER JOIN report_page rp ON  rp.report_id = r.report_id
	--INNER JOIN report_paramset rps ON  rps.page_id = rp.report_page_id
	--WHERE r.report_id = @report_id
	
	SELECT @items_combined = dbo.FNARFXGenerateReportItemsCombined(MAX(rp.report_page_id))
	FROM report r 
	INNER JOIN report_page rp ON rp.report_id = r.report_id
	WHERE r.report_id = @report_id
	
	SELECT @report_name =  r.[name] + '_' + rp.[name]
	FROM report r
	INNER JOIN report_page rp ON  rp.report_id = r.report_id
	WHERE r.report_id = @report_id

	SELECT @paramset_hash = rps.paramset_hash
	FROM report r 
	INNER JOIN report_page rp ON  rp.report_id = r.report_id
	INNER JOIN report_paramset rps ON  rps.page_id = rp.report_page_id
	inner join dbo.SplitCommaSeperatedValues(@report_param_id) scsv on scsv.item = rps.report_paramset_id
	--WHERE r.report_id = @report_param_id

	SELECT @report_path = r.name + '_' + rp.name
	FROM report r 
	INNER JOIN report_page rp ON  rp.report_id = r.report_id
	INNER JOIN report_paramset rps ON  rps.page_id = rp.report_page_id
	WHERE r.report_id = @report_id

	IF OBJECT_ID('tempdb..#report_criteria') IS NOT NULL
		DROP TABLE #report_criteria
	IF OBJECT_ID('tempdb..#report_criteria_process_table_columns') IS NOT NULL
		DROP TABLE #report_criteria_process_table_columns
	
	CREATE TABLE #report_criteria_process_table_columns
	(
		application_field_id varchar(200) COLLATE DATABASE_DEFAULT,
		id INT,
		[type] varchar(200) COLLATE DATABASE_DEFAULT,
		name varchar(200) COLLATE DATABASE_DEFAULT,
		label varchar(200) COLLATE DATABASE_DEFAULT,
		[validate] varchar(200) COLLATE DATABASE_DEFAULT,
		[value] VARCHAR(max) COLLATE DATABASE_DEFAULT,
		default_format varchar(200) COLLATE DATABASE_DEFAULT,
		is_hidden varchar(200) COLLATE DATABASE_DEFAULT,
		field_size varchar(200) COLLATE DATABASE_DEFAULT,
		field_id varchar(200) COLLATE DATABASE_DEFAULT,
		header_detail varchar(200) COLLATE DATABASE_DEFAULT,
		system_required varchar(200) COLLATE DATABASE_DEFAULT,
		[disabled] varchar(200) COLLATE DATABASE_DEFAULT,
		has_round_option varchar(200) COLLATE DATABASE_DEFAULT DEFAULT 'n',
		update_required varchar(200) COLLATE DATABASE_DEFAULT DEFAULT 'n',
		data_flag varchar(200) COLLATE DATABASE_DEFAULT,
		insert_required varchar(200) COLLATE DATABASE_DEFAULT DEFAULT 'n',
		tab_name varchar(200) COLLATE DATABASE_DEFAULT,
		tab_description varchar(200) COLLATE DATABASE_DEFAULT,
		tab_active_flag varchar(200) COLLATE DATABASE_DEFAULT,
		tab_sequence varchar(200) COLLATE DATABASE_DEFAULT,
		sql_string varchar(max) COLLATE DATABASE_DEFAULT,
		fieldset_name varchar(200) COLLATE DATABASE_DEFAULT,
		className varchar(200) COLLATE DATABASE_DEFAULT,
		fieldset_is_disable varchar(200) COLLATE DATABASE_DEFAULT,
		fieldset_is_hidden varchar(200) COLLATE DATABASE_DEFAULT,
		inputLeft varchar(200) COLLATE DATABASE_DEFAULT DEFAULT 0,
		inputTop varchar(200) COLLATE DATABASE_DEFAULT DEFAULT 0,
		fieldset_label varchar(200) COLLATE DATABASE_DEFAULT,
		offsetLeft varchar(200) COLLATE DATABASE_DEFAULT DEFAULT 0,
		offsetTop varchar(200) COLLATE DATABASE_DEFAULT DEFAULT 0,
		fieldset_position varchar(200) COLLATE DATABASE_DEFAULT,
		fieldset_width varchar(200) COLLATE DATABASE_DEFAULT,
		fieldset_id varchar(200) COLLATE DATABASE_DEFAULT,
		fieldset_seq varchar(200) COLLATE DATABASE_DEFAULT,
		blank_option varchar(200) COLLATE DATABASE_DEFAULT DEFAULT 'y',
		inputHeight varchar(200) COLLATE DATABASE_DEFAULT DEFAULT 200,
		group_name varchar(200) COLLATE DATABASE_DEFAULT,
		group_id varchar(200) COLLATE DATABASE_DEFAULT,
		application_function_id varchar(200) COLLATE DATABASE_DEFAULT DEFAULT 10202200,
		template_name varchar(200) COLLATE DATABASE_DEFAULT DEFAULT 'report criteria',
		position varchar(200) COLLATE DATABASE_DEFAULT,
		num_column varchar(200) COLLATE DATABASE_DEFAULT DEFAULT 3,
		field_hidden varchar(200) COLLATE DATABASE_DEFAULT,
		field_seq VARCHAR(200) COLLATE DATABASE_DEFAULT,
		text_row_num INT, 
		validation_message VARCHAR(200) COLLATE DATABASE_DEFAULT, 
		hyperlink_function VARCHAR(200) COLLATE DATABASE_DEFAULT,
		char_length INT,
		udf_template_id VARCHAR(10) COLLATE DATABASE_DEFAULT,
		dependent_field varchar(200) COLLATE DATABASE_DEFAULT,
		dependent_query varchar(200) COLLATE DATABASE_DEFAULT,
		[sequence]		int,
		original_label VARCHAR(128) COLLATE DATABASE_DEFAULT,
		open_ui_function_id INT
	)

	CREATE TABLE #report_criteria
	(
		report_param_id INT,
		column_id INT,
		column_name VARCHAR(200) COLLATE DATABASE_DEFAULT,
		column_alias VARCHAR(200) COLLATE DATABASE_DEFAULT,
		operator VARCHAR(200) COLLATE DATABASE_DEFAULT,
		initial_value VARCHAR(max) COLLATE DATABASE_DEFAULT NULL,
		initial_value2 VARCHAR(max) COLLATE DATABASE_DEFAULT NULL,
		param_data_source VARCHAR(2000) COLLATE DATABASE_DEFAULT NULL,
		param_default_value VARCHAR(2000) COLLATE DATABASE_DEFAULT NULL,
		optional VARCHAR(2000) COLLATE DATABASE_DEFAULT,
		widget_id INT,
		datatype_id INT,
		source_id INT,
		datatype_name VARCHAR(25) COLLATE DATABASE_DEFAULT,
		report_paramset_id INT,
		widget_type VARCHAR(25) COLLATE DATABASE_DEFAULT,
		label VARCHAR(200) COLLATE DATABASE_DEFAULT NULL,	
		param_order INT,
		data_source_type INT,
		is_hidden VARCHAR(25) COLLATE DATABASE_DEFAULT DEFAULT 'n',
		field_size VARCHAR(25) COLLATE DATABASE_DEFAULT DEFAULT '150',
		header_detail VARCHAR(25) COLLATE DATABASE_DEFAULT DEFAULT 'h',
		system_required VARCHAR(25) COLLATE DATABASE_DEFAULT DEFAULT 'n',
		[disabled] VARCHAR(25) COLLATE DATABASE_DEFAULT DEFAULT 'n',
		data_flag VARCHAR(25) COLLATE DATABASE_DEFAULT DEFAULT 'n',
		tab_name VARCHAR(25) COLLATE DATABASE_DEFAULT DEFAULT 'Report Criteria',
		tab_active_flag VARCHAR(25) COLLATE DATABASE_DEFAULT DEFAULT 'y',
		tab_sequence VARCHAR(25) COLLATE DATABASE_DEFAULT DEFAULT '1',
		fieldset_label VARCHAR(25) COLLATE DATABASE_DEFAULT DEFAULT 'fieldset',
		fieldset_position VARCHAR(25) COLLATE DATABASE_DEFAULT,
		group_name VARCHAR(25) COLLATE DATABASE_DEFAULT DEFAULT 'General',
		group_id VARCHAR(25) COLLATE DATABASE_DEFAULT,
		position VARCHAR(25) COLLATE DATABASE_DEFAULT DEFAULT 'label-top',
		field_hidden VARCHAR(25) COLLATE DATABASE_DEFAULT DEFAULT 'n',
		field_seq VARCHAR(25) COLLATE DATABASE_DEFAULT DEFAULT 0
	)

	--dump all cols giving rank with partition of alias and name
	if object_id('tempdb..#tmp_ranked_cols') is not null
		drop table #tmp_ranked_cols

	select * 
	into #tmp_ranked_cols 
	from (
		select 
			row_number() over(partition by COALESCE(rpm.label, dsc.alias, dsc.name)
					order by 
					case dsc.widget_id 
						when 7 then 1 
						when 2 then 2 
						when 6 then 3 
					else 4 end, rpm.param_order asc) drank_ref_alias
			, row_number() over(partition by dsc.name
				order by 
				case dsc.widget_id 
					when 7 then 1 
					when 2 then 2 
					when 6 then 3 
				else 4 end, rpm.param_order asc) drank_ref_name
			, rpm.report_param_id
			, rpm.column_id
			, dsc.name column_name
			, COALESCE(rpm.label, dsc.alias, dsc.name) column_alias
			, rpm.operator
			, rpm.initial_value
			, rpm.initial_value2
			, dsc.param_data_source
			, dsc.param_default_value
			, iif(dsc.required_filter=1,0,rpm.optional) [optional]
			, dsc.widget_id
			, dsc.datatype_id
			, dsc.source_id
			, rdt.name datatype_name
			, rps.report_paramset_id
			, rwt.[name] widget_type
			, rpm.label
			, rpm.param_order
			, ds.type_id data_source_type

		from report_param rpm
		inner join report_dataset_paramset rdp on rdp.report_dataset_paramset_id = rpm.dataset_paramset_id
		inner join report_paramset rps on rps.report_paramset_id = rdp.paramset_id
		inner join data_source_column dsc on dsc.data_source_column_id = rpm.column_id
		inner join report_datatype rdt ON rdt.report_datatype_id = dsc.datatype_id
		inner join report_widget rwt ON rwt.report_widget_id = dsc.widget_id
		inner JOIN data_source ds on ds.data_source_id = dsc.source_id
		inner join dbo.SplitCommaSeperatedValues(@report_param_id) scsv on scsv.item = rps.report_paramset_id
		where 1=1 --rps.report_paramset_id = @report_param_id
			and rpm.hidden <> 1
		--order by column_alias asc
	) a

	

	--dump only secondary cols that are excluded being duplicate cols
	if object_id('tempdb..#tmp_secondary_cols') is not null
		drop table #tmp_secondary_cols
	select trc.column_name [col_name]
		, trc.column_alias
		, ca_org_col.column_name [filter_col]
		, null [filter_value]
	into #tmp_secondary_cols
	from #tmp_ranked_cols trc
	cross apply (
		select trc1.column_name
		from #tmp_ranked_cols trc1
		where trc1.column_alias = trc.column_alias and trc1.column_name <> trc.column_name
	) ca_org_col
	where trc.drank_ref_alias > 1 and trc.drank_ref_name = 1
	
	DECLARE @rfx_secondary_filters_info VARCHAR(500) = dbo.FNAProcessTableName('rfx_secondary_filters_info', @user_name , @process_id)
	
	set @sql = '
	if object_id(''' + @rfx_secondary_filters_info + ''') is not null
		drop table ' + @rfx_secondary_filters_info + '

	select * into ' + @rfx_secondary_filters_info + ' 
	from #tmp_secondary_cols
	'
	exec(@sql)

	IF OBJECT_ID('tempdb..#between_operator') IS NOT NULL
		DROP TABLE #between_operator

	CREATE TABLE #between_operator(field_id VARCHAR(50) COLLATE DATABASE_DEFAULT)

	INSERT INTO #report_criteria
	(
		report_param_id,
		column_id,
		column_name,
		column_alias,
		operator,
		initial_value,
		initial_value2,
		param_data_source,
		param_default_value,
		optional,
		widget_id,
		datatype_id,
		source_id,
		datatype_name,
		report_paramset_id,
		widget_type,
		label,
		param_order,
		data_source_type
	)	
	select trc.report_param_id
			, trc.column_id
			, trc.column_name
			, trc.column_alias
			, trc.operator
			, trc.initial_value
			, trc.initial_value2
			, trc.param_data_source
			, trc.param_default_value
			, isnull(ca_ins_req.optional, trc.optional) optional
			, trc.widget_id
			, trc.datatype_id
			, trc.source_id
			, trc.datatype_name
			, trc.report_paramset_id
			, trc.widget_type
			, trc.label
			, trc.param_order
			, trc.data_source_type
	from #tmp_ranked_cols trc
	outer apply (
		select top 1 trc1.optional
		from #tmp_ranked_cols trc1
		where trc1.label = trc.label 
			and trc1.optional = 0
	) ca_ins_req
	where trc.drank_ref_alias = 1 and trc.drank_ref_name = 1
	
	/** 
	INSERT UNSAVED VIEW FILTER COLUMNS TO BUILD FILTER STRING,TO AVOID REPORT ABORTED ERROR DUE TO UNSATISFIED REPORT FILTER STRING BUILD.
	ISSUE DESCRIPTION: WHEN VIEW IS MODIFIED WITH ADDED COLUMN FILTERS AND REPORT IS UNCHANGED, REPORT WILL BREAK DUE TO ABSENCE OF ADDED FILTER COLUMNS ON REPORT FILTER STRING. 
	FIX: ADDED VIEW FILTER COLUMNS NOT AVAILABLE OF REPORT PARAM TABLE SO THAT THEY CAN PARTICIPATE ON REPORT FILTER
	**/
	union all
	select -1 [report_param_id] --set not null value as this will be checked while drawing browse column on view report critria
			, dsc.data_source_column_id [column_id]
			, dsc.name [column_name]
			, dsc.alias [column_alias]
			, 1 [operator]
			, null [initial_value]
			, null [initial_value2]
			, dsc.param_data_source
			, dsc.param_default_value
			, iif(dsc.required_filter=1,0,1) [optional]
			, dsc.widget_id
			, dsc.datatype_id
			, dsc.source_id
			, rdt.name [datatype_name]
			, rdp.paramset_id [report_paramset_id]
			, rwt.[name] [widget_type]
			, dsc.alias [label]
			, 9999 param_order
			, ds.type_id [data_source_type]
		
	from report_dataset_paramset rdp 
	inner join report_dataset rd on rd.report_dataset_id = rdp.root_dataset_id
	inner join data_source_column dsc on dsc.source_id = rd.source_id
	inner join dbo.SplitCommaSeperatedValues(@report_param_id) scsv on scsv.item = rdp.paramset_id 
	inner join report_datatype rdt ON rdt.report_datatype_id = dsc.datatype_id
	inner join report_widget rwt ON rwt.report_widget_id = dsc.widget_id
	inner JOIN data_source ds on ds.data_source_id = dsc.source_id
	left join report_param rp on rp.column_id = dsc.data_source_column_id and rp.dataset_paramset_id = rdp.report_dataset_paramset_id
	where dsc.required_filter is not null --valid value for required filter are null,0,1 [null=normal column,0=filter column optional,1=filter column mandatory]
		and rp.column_id is null

	--select * from #tmp_ranked_cols order by column_alias
	--select * from #tmp_secondary_cols order by column_alias
	--select * from #report_criteria
	--return
	
	IF @call_from = 'excel_addin'
	BEGIN
		EXEC ('SELECT column_name [Name],
					operator [OperatorId],
					column_alias [Label],
					column_alias [Alias],
					optional [Optional],
					widget_id [WidgetId],
					datatype_id [DatatypeId],
					ISNULL(param_data_source,'''') [DataSource],
					ISNULL(NULLIF(initial_value,''''), ''NULL'') [DefaultValue],
					ISNULL(NULLIF(initial_value2,''''), ''NULL'') [DefaultValue2],
					widget_type [WidgetName],
					param_order [Order] FROM #report_criteria  
				ORDER BY param_order')

		RETURN
	END

	IF @call_from = 'pinned_pivot' AND @view_id IS NOT NULL
	BEGIN
		UPDATE rc
		SET initial_value = df.column_value
		FROM #report_criteria rc
		OUTER APPLY (
			SELECT pvp.column_value
			FROM pivot_view_params pvp
			inner join dbo.SplitCommaSeperatedValues(@view_id) scsv on scsv.item = pvp.view_id
				AND pvp.column_id = rc.column_id
		) df
	END

	IF @call_from = 'dashboard_config'
	BEGIN
		UPDATE rc
		SET initial_value = dp.param_value 
		FROM #report_criteria rc
		INNER JOIN dashboard_params dp ON dp.dashboard_id = @dashboard_id AND dp.param_name = rc.column_name
	END

	DECLARE @subbook_id VARCHAR(max)
	SELECT @subbook_id = initial_value FROM #report_criteria 
	WHERE widget_type = 'BSTREE-SubBook'

	UPDATE #report_criteria
	SET initial_value = @subbook_id
	WHERE widget_type = 'BSTREE-Subsidiary'

	DECLARE db_cursor CURSOR FOR  
	SELECT column_id, operator
	FROM #report_criteria
	ORDER BY param_order ASC
	--WHERE operator = '8'
	--select * from #report_criteria
	OPEN db_cursor  
	FETCH NEXT FROM db_cursor INTO @column_id, @operator

	WHILE @@FETCH_STATUS = 0  
	BEGIN
		SET @row_count = @row_count + 1
		INSERT INTO #report_criteria_process_table_columns
		(
			application_field_id,
			id,
			field_id,
			[name],
			label,
			default_format,
			[value],
			sql_string,
			validate,
			--application_function_id,
			[type],
			is_hidden,
			field_size,
			header_detail,
			insert_required,
			[disabled],
			data_flag,
			tab_name,
			tab_active_flag,
			tab_sequence,
			fieldset_label,
			fieldset_position,
			group_name,
			group_id,
			position,
			field_hidden,
			validation_message,
			field_seq,
			udf_template_id,
			dependent_field,
			dependent_query,
			[sequence],
			original_label
		)
		SELECT
			report_param_id,
				@row_count,
			CASE
				WHEN widget_type = 'BSTREE-Subsidiary' THEN 'book_structure' ELSE column_name
			END 
			column_name,
			CASE
				WHEN widget_type = 'BSTREE-Subsidiary' THEN 'book_structure' ELSE column_name
			END 
			column_name,
			REPLACE(CASE
				WHEN widget_type = 'BSTREE-Subsidiary' THEN 'Book Structure' ELSE isnull(nullif(column_alias,''),replace(column_name,'_',' '))
			END, '"', '\"')
			column_alias,
			-- Added to make every combo as muiticheckbox combo.
			CASE
				WHEN widget_type = 'Multiselect Dropdown' THEN 'm'
				ELSE NULL
			END default_format,
			REPLACE(ISNULL(NULLIF(initial_value,''), initial_value2), '"', '\"'),
			param_data_source,
			CASE
				WHEN widget_type = 'DATETIME' AND (@call_from = 'report_manager_dhx_excel' OR @call_from = 'report_manager_dhx') THEN 'ValidDynamicDate'
				WHEN optional = '0' THEN 'NotEmpty'
				WHEN optional = '1' THEN ''
			END
			optional,
			--report_paramset_id,
			CASE
				--integrate new dynamic date component only for excel addin reports
				WHEN widget_type = 'DATETIME' THEN iif((@call_from = 'report_manager_dhx_excel' OR @call_from = 'report_manager_dhx' OR @call_from = 'pinned_report'), 'dyn_calendar', 'calendar')
				--WHEN widget_type = 'DATETIME' THEN 'dyn_calendar'
				WHEN widget_type = 'DROPDOWN' THEN 'combo'
				WHEN widget_type = 'Multiselect Dropdown' THEN 'combo'
				WHEN widget_type = 'TEXTBOX' THEN 'input'
				WHEN widget_type = 'DataBrowser' THEN 'browser'
				WHEN widget_type = 'BSTREE-Subsidiary' THEN 'browser'
			END 
			widget_type,
			is_hidden,
			field_size,
			header_detail,
			CASE
				WHEN optional = '0' THEN 'y'
				WHEN optional = '1' THEN 'n'
			END insert_required,
			[disabled],
			data_flag,
			tab_name,
			tab_active_flag,
			tab_sequence,
			fieldset_label,
			fieldset_position,
			group_name,
			ISNULL(group_id, @application_group_id),
			position,
			field_hidden,
			CASE
				WHEN widget_type = 'DATETIME' AND (@call_from = 'report_manager_dhx_excel' OR  @call_from = 'report_manager_dhx') THEN 'Invalid Selection'
				WHEN optional = '0' THEN CASE WHEN widget_type IN ('DROPDOWN', 'Multiselect Dropdown') THEN 'Invalid Selection' ELSE 'Required Field' END
				WHEN optional = '1' THEN 'Invalid Selection'
			END,
			param_order,
			'',
			null,
			null,
			null,
			NULL
		FROM #report_criteria
		WHERE column_id = @column_id
		
		IF (@operator = '8')
		BEGIN
			INSERT INTO #report_criteria_process_table_columns
			(
				application_field_id,
				id,
				field_id,
				[name],
				label,
				[value],
				default_format,
				sql_string,
				validate,
				--application_function_id,
				[type],
				is_hidden,
				field_size,
				header_detail,
				system_required,
				[disabled],
				data_flag,
				tab_name,
				tab_active_flag,
				tab_sequence,
				fieldset_label,
				fieldset_position,
				group_name,
				group_id,
				position,
				field_hidden,
				validation_message,
				field_seq,
				udf_template_id,
				dependent_field,
				dependent_query,
				[sequence],
				original_label
			)
			OUTPUT INSERTED.[field_id] INTO #between_operator 
			SELECT
				rcp.application_field_id,
				rcp.id + 1,
				rcp.field_id,
				'2_' + rcp.[name],
				REPLACE(rcp.label + ' [To]', '"', '\"'),
				REPLACE(ISNULL(NULLIF(rc.initial_value2,''), rc.initial_value), '"', '\"'),
				CASE
					WHEN widget_type = 'Multiselect Dropdown' THEN 'm'
					ELSE NULL
				END default_format,
				rcp.sql_string,
				rcp.validate,
				--application_function_id,
				rcp.[type],
				rcp.is_hidden,
				rcp.field_size,
				rcp.header_detail,
				rcp.system_required,
				rcp.[disabled],
				rcp.data_flag,
				rcp.tab_name,
				rcp.tab_active_flag,
				rcp.tab_sequence,
				rcp.fieldset_label,
				rcp.fieldset_position,
				rcp.group_name,
				rcp.group_id,
				rcp.position,
				rcp.field_hidden,
				rcp.validation_message,
				param_order,
				'',
				null,
				null,
				null,
				NULL
			FROM #report_criteria_process_table_columns rcp
				CROSS JOIN #report_criteria rc
			WHERE rcp.id = @row_count AND rc.column_id = @column_id
			
			SET @row_count = @row_count + 1
			
		END
		SET @id = @id + 1
		FETCH NEXT FROM db_cursor INTO @column_id, @operator
	END

	CLOSE db_cursor  
	DEALLOCATE db_cursor
		
	UPDATE rcp SET label = label + ' [From]' 
	FROM #report_criteria_process_table_columns  rcp
	INNER JOIN #between_operator bo ON bo.field_id = rcp.[field_id] 
	WHERE rcp.[name] =  REPLACE(rcp.[name], '2_', '' )

	--SELECT * FROM #report_criteria_process_table_columns order by label
	--RETURN

	SELECT @max_id = MAX(CAST(id AS INT))
	FROM #report_criteria_process_table_columns
	
	SET @max_id = ISNULL(@max_id, 0)

	--set disabled to 'r' and hidden 'y' for config columns so that it can be avoided on applyfilter logic
	INSERT INTO #report_criteria_process_table_columns
	VALUES (NULL,@max_id+1,'input','report_name','Report Name',NULL,@report_name,NULL,'n',250,'report_name',NULL,null,'r','n','n','n','n','Report Criteria',NULL,'n',2,NULL,NULL,NULL,NULL,NULL,0,0,'fieldset',0,0,NULL,NULL,NULL,NULL,'y',200,'General',@application_group_id,10202200,'report template','label-top',3,'y',0, NULL, NULL, NULL, NULL, '', null, null, null, NULL, NULL)

	INSERT INTO #report_criteria_process_table_columns
	VALUES (NULL,@max_id+2,'input','report_paramset_id','Report Paramset ID',NULL,@report_param_id,NULL,'n',250,'report_paramset_id',NULL,null,'r','n','n','n','n','Report Criteria',NULL,'n',2,NULL,NULL,NULL,NULL,NULL,0,0,'fieldset',0,0,NULL,NULL,NULL,NULL,'y',200,'General',@application_group_id,10202200,'report template','label-top',3,'y',0, NULL, NULL, NULL, NULL, '', null, null, null, NULL, NULL)

	INSERT INTO #report_criteria_process_table_columns
	VALUES (NULL,@max_id+3,'input','items_combined','Items Combined',NULL,@items_combined,NULL,'n',250,'items_combined',NULL,null,'r','n','n','n','n','Report Criteria',NULL,'n',2,NULL,NULL,NULL,NULL,NULL,0,0,'fieldset',0,0,NULL,NULL,NULL,NULL,'y',200,'General',@application_group_id,10202200,'report template','label-top',3,'y',0, NULL, NULL, NULL, NULL, '', null, null, null, NULL, NULL)

	INSERT INTO #report_criteria_process_table_columns
	VALUES (NULL,@max_id+4,'settings',NULL,NULL,NULL,NULL,NULL,'n',250,NULL,NULL,NULL,'n','n','n','n','n','Report Criteria',NULL,'n',2,NULL,NULL,NULL,NULL,NULL,0,0,'fieldset',0,0,NULL,NULL,NULL,NULL,'y',200,'General',@application_group_id,10202200,'report template','label-top',3,'n',0, NULL, NULL, NULL, NULL, '', null, null, null, NULL, NULL)

	INSERT INTO #report_criteria_process_table_columns
	VALUES (NULL,@max_id+5,'input','paramset_hash','Paramset Hash',NULL,@paramset_hash,NULL,'n',250,'paramset_hash',NULL,null,'r','n','n','n','n','Report Criteria',NULL,'n',2,NULL,NULL,NULL,NULL,NULL,0,0,'fieldset',0,0,NULL,NULL,NULL,NULL,'y',200,'General',@application_group_id,10202200,'report template','label-top',3,'y',0, NULL, NULL, NULL, NULL, '', null, null, null, NULL, NULL)

	INSERT INTO #report_criteria_process_table_columns
	VALUES (NULL,@max_id+6,'input','report_path','Report Path',NULL,@report_path,NULL,'n',250,'report_path',NULL,null,'r','n','n','n','n','Report Criteria',NULL,'n',2,NULL,NULL,NULL,NULL,NULL,0,0,'fieldset',0,0,NULL,NULL,NULL,NULL,'y',200,'General',@application_group_id,10202200,'report template','label-top',3,'y',0, NULL, NULL, NULL, NULL, '', null, null, null, NULL, NULL)

	
	
	UPDATE #report_criteria_process_table_columns
	SET field_size = @default_field_size,
		offsetLeft = @default_offsetleft,
		offsetTop = @default_fieldset_offsettop,
		fieldset_width = @default_fieldset_width,
		num_column = @default_column_num_per_row

	EXEC ('select * into ' + @report_process_table + ' FROM #report_criteria_process_table_columns')

	--Resolved reporting items. 
	IF @paraset_category_id IS NOT NULL
	BEGIN
		DECLARE @idoc int
		EXEC sp_xml_preparedocument @idoc OUTPUT,  @param_filter_xml
		IF OBJECT_ID('tempdb..#temp_report_params') IS NOT NULL
		DROP TABLE #temp_report_params

		SELECT  param_name
			,  param_value
		INTO #temp_report_params
		FROM OPENXML(@idoc, '/Root/FormXML', 1) 
		WITH (
			param_name NVARCHAR(100)
			,param_value NVARCHAR(MAX)
		)

		SET @sql = '
			UPDATE rpt 
				SET rpt.value = ISNULL(REPLACE(trp.[param_value],'','',''!''), rpt.value)
			FROM '+@report_process_table+' rpt 
			INNER JOIN #temp_report_params trp 
				ON rpt.name = trp.param_name 
			WHERE trp.param_value IS NOT NULL
		'
		EXEC (@sql)
	
		SET  @sql = 'SELECT RTRIM(LTRIM(scf.[sec_filters_info])) sec_filters_info
						,RTRIM(LTRIM(itm.[items_combined])) items_combined
						,'''+@process_id+''' process_id
						,RTRIM(LTRIM(rp.report_paramset_id)) report_paramset_id
						, RTRIM(LTRIM(rn.report_name)) report_name
					 FROM (
						SELECT STUFF((
									SELECT '', '' + name + ''='' + ISNULL(NULLIF(value, ''''), ''null'')
									FROM '+@report_process_table+'
									WHERE application_field_id IS NOT NULL and name != ''book_structure''
									GROUP BY name
										,value
									ORDER BY name ASC
									FOR XML PATH('''')
										,TYPE
									).value(''.'', ''NVARCHAR(MAX)''), 1, 1, '''') AS [sec_filters_info]
						) scf
					 CROSS APPLY (
						SELECT ic.items_combined
						FROM (
							SELECT STUFF((
										SELECT '', '' + ISNULL(NULLIF(value, ''''), ''null'')
										FROM '+@report_process_table+'
										WHERE QUOTENAME(name) = ''[items_combined]''
										GROUP BY name
											,value
										ORDER BY name ASC
										FOR XML PATH('''')
											,TYPE
										).value(''.'', ''NVARCHAR(MAX)''), 1, 1, '''') AS [items_combined]
							) ic
						) itm
					 CROSS APPLY (
						SELECT rpi.report_paramset_id
						FROM (
							SELECT STUFF((
										SELECT '', '' + ISNULL(NULLIF(value, ''''), ''null'')
										FROM '+@report_process_table+'
										WHERE QUOTENAME(name) = ''[report_paramset_id]''
										GROUP BY name
											,value
										ORDER BY name ASC
										FOR XML PATH('''')
											,TYPE
										).value(''.'', ''NVARCHAR(MAX)''), 1, 1, '''') AS [report_paramset_id]
							) rpi
						) rp
					CROSS APPLY (
						SELECT rni.report_name
						FROM (
							SELECT STUFF((
										SELECT '', '' + ISNULL(NULLIF(value, ''''), ''null'')
										FROM '+@report_process_table+'
										WHERE QUOTENAME(name) = ''[report_name]''
										GROUP BY name
											,value
										ORDER BY name ASC
										FOR XML PATH('''')
											,TYPE
										).value(''.'', ''NVARCHAR(MAX)''), 1, 1, '''') AS [report_name]
							) rni
						) rn

					' 
		 EXEC(@sql)
		 RETURN 
	END

	IF OBJECT_ID('tempdb..#tmp_browser') IS NOT NULL
		DROP TABLE #tmp_browser

	CREATE TABLE #tmp_browser
	(
		farrms_field_id VARCHAR(100) COLLATE DATABASE_DEFAULT,
		grid_name VARCHAR(100) COLLATE DATABASE_DEFAULT
	)

	INSERT INTO #tmp_browser (farrms_field_id, grid_name)
	SELECT CASE WHEN dsc.widget_id = 5 THEN 'book_structure' ELSE rc.column_name END column_name, dsc.param_data_source
	FROM data_source_column dsc
	INNER JOIN #report_criteria rc ON dsc.data_source_column_id = rc.column_id
	WHERE NULLIF(dsc.param_data_source, '') IS NOT NULL AND dsc.widget_id IN (5,7)
	
	EXEC ('SELECT * INTO ' + @report_grid_name_process_table + ' FROM #tmp_browser')
 
	IF ((SELECT COUNT(*) FROM #tmp_browser) = 0) 
		SET @report_grid_name_process_table = NULL

	--DROP TABLE #report_criteria_process_table_columns
	--DROP TABLE #report_criteria
	--exec('select * from ' + @report_process_table)
	--select @tab_process_table, @report_process_table, @report_grid_name_process_table
	--return
	IF @call_from IN ('regression_testing', 'regression_testing_load_default_filter')
	BEGIN
		--reset filter values in update mode as it will be set by breaking down combined filter value
		IF @call_from = 'regression_testing'
		BEGIN
			EXEC ('UPDATE ' + @report_process_table + ' SET [value] = NULL')
		END

		EXEC spa_convert_to_form_json @tab_process_table, @report_process_table, NULL, @report_grid_name_process_table, NUll,'regression_testing','y',@batch_process_id
	END
	ELSE 
	BEGIN
		EXEC spa_convert_to_form_json @tab_process_table, @report_process_table, NULL, @report_grid_name_process_table, NUll, @is_report = 'y'
	END

END

--To PIN report to My Report
ELSE IF @flag = 'p'
BEGIN
	BEGIN TRY
		IF @report_type = 1
		BEGIN
			
			IF EXISTS(
			SELECT 1
			FROM report_paramset rp
			WHERE rp.report_paramset_id = @report_param_id and rp.report_status_id = 1 AND dbo.FNAIsUserOnAdminGroup(@user_name, 1) <> 1 AND ISNULL(dbo.FNAReportAdminRoleCheck(@user_name), 0) <> 1
			)
			BEGIN
				EXEC spa_ErrorHandler -1,
				 'my_report',
				 'spa_view_report',
				 'Error',
				 'Report with Draft status can be pinned to My Reports, only by admin users.',
				 ''
				 
				RETURN
			
			END
		
			IF EXISTS (SELECT * FROM my_report mr
				INNER JOIN report_paramset rps ON rps.paramset_hash = mr.paramset_hash
				LEFT JOIN report_page rp ON rps.page_id = rp.report_page_id
				INNER JOIN report r ON rp.report_id = r.report_id
				WHERE r.report_id = @report_id AND rps.report_paramset_id = @report_param_id AND my_report_owner = @user_name
			)
			BEGIN
				EXEC spa_ErrorHandler -1,
				 'my_report',
				 'spa_view_report',
				 'Error',
				 'Report already exists in My Report.',
				 ''

				RETURN
			END

			INSERT INTO my_report (my_report_name, dashboard_report_flag, paramset_hash, tooltip, my_report_owner)
			SELECT r.name, 'r' as dashboard_report_flag, rps.paramset_hash, r.name, @user_name from report r
			INNER JOIN report_page rp ON r.report_id = rp.report_id 
			INNER JOIN report_paramset rps ON rp.report_page_id = rps.page_id 
			WHERE r.report_id = @report_id AND rps.report_paramset_id = @report_param_id
		END
		ELSE IF @report_type = 3
		BEGIN
			IF EXISTS (SELECT * FROM my_report mr
				LEFT JOIN report_template_name rtn ON mr.dashboard_id = rtn.report_template_name_id
				WHERE mr.dashboard_id = @report_id AND my_report_owner = @user_name
			)
			BEGIN
				EXEC spa_ErrorHandler -1,
				 'my_report',
				 'spa_view_report',
				 'Error',
				 'Report already exists in My Report.',
				 ''

				RETURN
			END

			INSERT INTO my_report (my_report_name, dashboard_report_flag, paramset_hash, tooltip, my_report_owner, dashboard_id)
			SELECT r.report_name, 'd' as dashboard_report_flag, NULL, r.report_name, @user_name, @report_id from report_template_name r
			WHERE r.report_template_name_id = @report_id
		END
		ELSE
		BEGIN
			IF EXISTS (SELECT 	* FROM my_report mr
				WHERE mr.application_function_id = @report_id AND my_report_owner = @user_name
			)
			BEGIN
				EXEC spa_ErrorHandler -1,
				 'my_report',
				 'spa_view_report',
				 'Error',
				 'Report already exists in My Report.',
				 ''

				RETURN
			END

			INSERT INTO my_report (my_report_name, dashboard_report_flag, tooltip, application_function_id, my_report_owner)
			SELECT af.function_name, 's' AS [dashboard_report_flag], af.function_name, af.function_id, @user_name FROM application_functions af
			WHERE af.function_id = @report_id
		END

		--Report Manager report privilege changed so release view report left grid data key.		
		IF  EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_manage_memcache]') AND TYPE IN (N'P', N'PC'))
		BEGIN			
			EXEC [spa_manage_memcache] @flag = 'd', @other_key_source='ReportManagerPrivilege', @source_object = 'spa_view_report @flag=p'
		END

		EXEC spa_ErrorHandler 0,
		 'my_report',
		 'spa_view_report',
		 'Success',
		 'Report successfully pinned to My Report.',
		 ''

	 END TRY
	 BEGIN CATCH
		  IF @@TRANCOUNT > 0
			 ROLLBACK

		  EXEC spa_ErrorHandler -1
		   , 'my_report'
		   , 'spa_view_report'
		   , 'Error'
		   , 'Report pin to My Report Failed.'
		   ,''
	 END CATCH
END

--To UNPIN report from My Report
ELSE IF @flag = 'd'
BEGIN
	BEGIN TRY
		IF @report_type = 1
		BEGIN
			DELETE mr from my_report mr
			INNER JOIN report_paramset rps ON mr.paramset_hash = rps.paramset_hash
			INNER JOIN report_page rp ON rps.page_id = rp.report_page_id
			WHERE rp.report_id = @report_id AND rps.report_paramset_id = @report_param_id AND mr.my_report_owner = @user_name
		END
		IF @report_type = 3
		BEGIN
			DELETE mr from my_report mr
			WHERE mr.dashboard_id = @report_id  AND mr.my_report_owner = @user_name
		END
		ELSE
		BEGIN
			DELETE mr from my_report mr
			WHERE mr.application_function_id = @report_id  AND mr.my_report_owner = @user_name
		END

		--Report Manager report privilege changed so release view report left grid data key.		
		IF  EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_manage_memcache]') AND TYPE IN (N'P', N'PC'))
		BEGIN			
			EXEC [spa_manage_memcache] @flag = 'd', @other_key_source='ReportManagerPrivilege', @source_object = 'spa_view_report @flag=d'
		END

		EXEC spa_ErrorHandler 0,
			 'my_report',
			 'spa_view_report',
			 'Success',
			 'Report successfully unpinned from My Report',
			 ''

	 END TRY
	 BEGIN CATCH
		  IF @@TRANCOUNT > 0
			 ROLLBACK

		  EXEC spa_ErrorHandler -1
		   , 'my_report'
		   , 'spa_view_report'
		   , 'Error'
		   , 'Report unpin from My Report Failed'
		   ,''
	 END CATCH
END

--To UNPIN report from My Report
IF @flag = 'm'
BEGIN
	
	--SELECT 
	--	r.report_id [report_id],
	--	r.[name] [report_name],
	--	rp2.report_paramset_id [report_param_id]
	--FROM report AS r
	--INNER JOIN report_page AS rp ON rp.report_id = r.report_id
	--INNER JOIN report_paramset AS rp2 ON rp2.page_id = rp.report_page_id
	--WHERE r.is_mobile = 1 AND r.report_id = ISNULL(@report_id,r.report_id)
	--ORDER BY r.[name]
	
	SELECT  arg.accordion_id [report_category], all_reports.report_name, all_reports.[report_package_name], all_reports.report_id, report_type, paramset_id FROM (
		-- Report Manager Report
		SELECT MAX(ISNULL(sdv.code, 'General')) AS accordion_name, 
			r.report_id AS report_id, MAX(rps.name) report_name, max(r.name) [report_package_name], '1' AS report_type, rps.report_paramset_id AS paramset_id, '3' AS accordion_order
			FROM report r 
			INNER JOIN report_page rp ON rp.report_id = r.report_id
			INNER JOIN report_paramset rps ON  rps.page_id = rp.report_page_id
			LEFT JOIN report_dataset_paramset rdp ON rdp.paramset_id = rps.report_paramset_id
			LEFT JOIN report_param rpm ON rdp.report_dataset_paramset_id = rpm.dataset_paramset_id 
			LEFT JOIN report_privilege rpv ON r.report_hash = rpv.report_hash
			--AND (rpv.[user_id] = @user_name OR rpv.role_id IN (SELECT fur.role_id FROM dbo.FNAGetUserRole(@user_name) fur))
			LEFT JOIN report_paramset_privilege rpp ON rpp.paramset_hash = rps.paramset_hash
			LEFT JOIN static_data_value sdv ON sdv.value_id = r.category_id			
			WHERE 1 = 1 
				AND r.is_mobile = 1
				AND r.is_powerbi <> 1
				AND rp.is_deployed = 1
				AND 
				(	
					@is_admin = 1
					or
					(
							r.[owner] = @user_name
							OR
						(rps.report_status_id = 2 OR rps.report_status_id = 3 
							AND
							(	
								rpv.user_id = @user_name
								OR rpv.role_id IN (SELECT role_id FROM dbo.FNAGetUserRole(@user_name)) 
								OR rpp.[user_id] = @user_name
								OR rpp.role_id IN (SELECT role_id FROM dbo.FNAGetUserRole(@user_name))
							) 
							OR rps.report_status_id IN (1,4) AND rps.create_user = @user_name
						)
					)
				)
			
				GROUP BY   rps.report_paramset_id , rp.report_page_id, r.report_id
			UNION
			--Excel Reports
			SELECT MAX(ISNULL(sdv11.code, 'General')) AS accordion_name,
				es.excel_sheet_id AS report_id,
				MAX(COALESCE(nullif(es.alias,''), es.sheet_name)) AS report_name,
				MAX(COALESCE(nullif(es.alias,''), es.sheet_name)) AS [report_package_name],
				'4' AS report_type,
				''  AS paramset_id,
				'3' AS accordion_order
			
			FROM excel_sheet es
			INNER JOIN excel_sheet_snapshot ess ON ess.excel_sheet_id = ess.excel_sheet_id
			LEFT JOIN static_data_value sdv11 ON sdv11.value_id = es.category_id
			LEFT JOIN excel_report_privilege erp ON (erp.[value_id] = es.excel_sheet_id OR (erp.type_id = es.excel_file_id AND NULLIF(erp.value_id, 0) IS NULL))
			OUTER APPLY (
					--get only one role for which privilege is provided
					SELECT TOP 1 aru.role_id
					FROM application_role_user AS aru
					WHERE aru.role_id = erp.role_id AND aru.user_login_id = @user_name
			) rs_role
			WHERE es.publish_mobile =1  AND es.[snapshot] = 1 
					AND 
					(	
						@is_admin = 1							--if user is super user
						OR @check_report_admin_role = 1			--if user is Reporting Admin
						OR es.[create_user] = @user_name		--if the user is the report creator
						OR (erp.[user_id] = @user_name OR rs_role.role_id IS NOT NULL)	--user or role is explicitly assigned privilege
					)
			GROUP BY es.excel_sheet_id
			-- Power BI Report
			UNION
			SELECT 
				'Power BI Reports' as accordin_name, 
				pbr.power_bi_report_id report_id, 
				rps01.[name]  + ' - BI' report_name, 
				NULL [report_package_name], 
				'5' AS report_type,
				CAST(rps01.report_paramset_id AS VARCHAR)  AS paramset_id,
				'3' AS accordion_order
			FROM power_bi_report AS [pbr]
			LEFT JOIN report_paramset rps01 ON  rps01.paramset_hash = pbr.[source_report]
			LEFT JOIN  report_page rp01 ON rp01.report_page_id = rps01.page_id
			LEFT JOIN report r ON r.report_id = rp01.report_id
			WHERE pbr.is_published = 1 AND r.is_powerbi = 1 AND pbr.powerbi_report_id <> '' AND  pbr.powerbi_report_id IS NOT NULL
				and rp01.is_deployed = 1 and r.is_mobile = 1 
	)
	 AS all_reports
		LEFT JOIN #accordion_report_grid arg ON all_reports.accordion_name = arg.accordion_name
		ORDER BY report_category,report_name
		
END

-- Returns the JSON to create the parameter criteria for Custom Report in mobile.
IF @flag = 'k'
BEGIN
	
	SET @tab_process_table = dbo.FNAProcessTableName('tab_process_table', @user_name, @process_id2)
	SET @report_process_table = dbo.FNAProcessTableName('report_process_table', @user_name, @process_id)
	SET @report_grid_name_process_table = dbo.FNAProcessTableName('report_grid_name_process_table', @user_name, @process_id3)
	
	SET @sql = '
			SELECT 
				application_group_id,ISNULL(field_layout,''1C'') field_layout,application_grid_id,ISNULL(sequence,1)  sequence, ''n'' is_udf_tab, ag.group_name, ag.default_flag, ''n'' is_new_tab
			INTO '+@tab_process_table+'
			FROM	application_ui_template_group ag 
					INNER JOIN application_ui_template at on at.application_ui_template_id = ag.application_ui_template_id
			WHERE 
				application_function_id = 10202200 AND at.template_name = ''report template''
			ORDER BY ag.sequence asc '
	EXEC(@sql)
	
	SELECT @application_group_id = application_group_id
	FROM application_ui_template_group ag 
	INNER JOIN application_ui_template at on at.application_ui_template_id = ag.application_ui_template_id
	WHERE application_function_id = 10202200 AND at.template_name = 'report template'
		
	SELECT @items_combined = dbo.FNARFXGenerateReportItemsCombined(MAX(rp.report_page_id))
	FROM report r 
	INNER JOIN report_page rp ON rp.report_id = r.report_id
	WHERE r.report_id = @report_id
	
	SELECT @report_name =  r.[name] + '_' + rp.[name]
	FROM report r
	INNER JOIN report_page rp ON  rp.report_id = r.report_id
	WHERE r.report_id = @report_id

	SELECT @paramset_hash = rps.paramset_hash
	FROM report r 
	INNER JOIN report_page rp ON  rp.report_id = r.report_id
	INNER JOIN report_paramset rps ON  rps.page_id = rp.report_page_id
	WHERE r.report_id = @report_id

	SELECT @report_path = r.name + '_' + rp.name
	FROM report r 
	INNER JOIN report_page rp ON  rp.report_id = r.report_id
	INNER JOIN report_paramset rps ON  rps.page_id = rp.report_page_id
	WHERE r.report_id = @report_id

	IF OBJECT_ID('tempdb..#report_ct') IS NOT NULL
		DROP TABLE #report_ct
	IF OBJECT_ID('tempdb..#report_criteria_process_table_columns1') IS NOT NULL
		DROP TABLE #report_criteria_process_table_columns1
	
	CREATE TABLE #report_criteria_process_table_columns1
	(
		application_field_id varchar(200) COLLATE DATABASE_DEFAULT,
		id INT,
		[type] varchar(200) COLLATE DATABASE_DEFAULT,
		name varchar(200) COLLATE DATABASE_DEFAULT,
		label varchar(200) COLLATE DATABASE_DEFAULT,
		[validate] varchar(200) COLLATE DATABASE_DEFAULT,
		[value] VARCHAR(200) COLLATE DATABASE_DEFAULT,
		default_format varchar(200) COLLATE DATABASE_DEFAULT,
		is_hidden varchar(200) COLLATE DATABASE_DEFAULT,
		field_size varchar(200) COLLATE DATABASE_DEFAULT,
		field_id varchar(200) COLLATE DATABASE_DEFAULT,
		header_detail varchar(200) COLLATE DATABASE_DEFAULT,
		system_required varchar(200) COLLATE DATABASE_DEFAULT,
		[disabled] varchar(200) COLLATE DATABASE_DEFAULT,
		has_round_option varchar(200) COLLATE DATABASE_DEFAULT DEFAULT 'n',
		update_required varchar(200) COLLATE DATABASE_DEFAULT DEFAULT 'n',
		data_flag varchar(200) COLLATE DATABASE_DEFAULT,
		insert_required varchar(200) COLLATE DATABASE_DEFAULT DEFAULT 'n',
		tab_name varchar(200) COLLATE DATABASE_DEFAULT,
		tab_description varchar(200) COLLATE DATABASE_DEFAULT,
		tab_active_flag varchar(200) COLLATE DATABASE_DEFAULT,
		tab_sequence varchar(200) COLLATE DATABASE_DEFAULT,
		sql_string varchar(max) COLLATE DATABASE_DEFAULT,
		fieldset_name varchar(200) COLLATE DATABASE_DEFAULT,
		className varchar(200) COLLATE DATABASE_DEFAULT,
		fieldset_is_disable varchar(200) COLLATE DATABASE_DEFAULT,
		fieldset_is_hidden varchar(200) COLLATE DATABASE_DEFAULT,
		inputLeft varchar(200) COLLATE DATABASE_DEFAULT DEFAULT 0,
		inputTop varchar(200) COLLATE DATABASE_DEFAULT DEFAULT 0,
		fieldset_label varchar(200) COLLATE DATABASE_DEFAULT,
		offsetLeft varchar(200) COLLATE DATABASE_DEFAULT DEFAULT 0,
		offsetTop varchar(200) COLLATE DATABASE_DEFAULT DEFAULT 0,
		fieldset_position varchar(200) COLLATE DATABASE_DEFAULT,
		fieldset_width varchar(200) COLLATE DATABASE_DEFAULT,
		fieldset_id varchar(200) COLLATE DATABASE_DEFAULT,
		fieldset_seq varchar(200) COLLATE DATABASE_DEFAULT,
		blank_option varchar(200) COLLATE DATABASE_DEFAULT DEFAULT 'y',
		inputHeight varchar(200) COLLATE DATABASE_DEFAULT DEFAULT 200,
		group_name varchar(200) COLLATE DATABASE_DEFAULT,
		group_id varchar(200) COLLATE DATABASE_DEFAULT,
		application_function_id varchar(200) COLLATE DATABASE_DEFAULT DEFAULT 10202200,
		template_name varchar(200) COLLATE DATABASE_DEFAULT DEFAULT 'report criteria',
		position varchar(200) COLLATE DATABASE_DEFAULT,
		num_column varchar(200) COLLATE DATABASE_DEFAULT DEFAULT 3,
		field_hidden varchar(200) COLLATE DATABASE_DEFAULT,
		field_seq VARCHAR(200) COLLATE DATABASE_DEFAULT,
		text_row_num INT, 
		validation_message VARCHAR(200) COLLATE DATABASE_DEFAULT, 
		hyperlink_function VARCHAR(200) COLLATE DATABASE_DEFAULT,
		char_length INT,
		udf_template_id VARCHAR(10) COLLATE DATABASE_DEFAULT,
		dependent_field VARCHAR(200) COLLATE DATABASE_DEFAULT,
		dependent_query VARCHAR(200) COLLATE DATABASE_DEFAULT,
		[sequence] INT,
		original_label VARCHAR(128) COLLATE DATABASE_DEFAULT,
		open_ui_function_id INT
	)

	CREATE TABLE #report_ct
	(
		report_param_id INT,
		column_id INT,
		column_name VARCHAR(200) COLLATE DATABASE_DEFAULT,
		column_alias VARCHAR(200) COLLATE DATABASE_DEFAULT,
		operator VARCHAR(200) COLLATE DATABASE_DEFAULT,
		initial_value VARCHAR(200) COLLATE DATABASE_DEFAULT NULL,
		initial_value2 VARCHAR(200) COLLATE DATABASE_DEFAULT NULL,
		param_data_source VARCHAR(2000) COLLATE DATABASE_DEFAULT NULL,
		param_default_value VARCHAR(2000) COLLATE DATABASE_DEFAULT NULL,
		optional VARCHAR(2000) COLLATE DATABASE_DEFAULT,
		widget_id INT,
		datatype_id INT,
		source_id INT,
		datatype_name VARCHAR(25) COLLATE DATABASE_DEFAULT,
		report_paramset_id INT,
		widget_type VARCHAR(25) COLLATE DATABASE_DEFAULT,
		label VARCHAR(200) COLLATE DATABASE_DEFAULT NULL,	
		param_order INT,
		data_source_type INT,
		is_hidden VARCHAR(25) COLLATE DATABASE_DEFAULT DEFAULT 'n',
		field_size VARCHAR(25) COLLATE DATABASE_DEFAULT DEFAULT '150',
		header_detail VARCHAR(25) COLLATE DATABASE_DEFAULT DEFAULT 'h',
		system_required VARCHAR(25) COLLATE DATABASE_DEFAULT DEFAULT 'n',
		[disabled] VARCHAR(25) COLLATE DATABASE_DEFAULT DEFAULT 'n',
		data_flag VARCHAR(25) COLLATE DATABASE_DEFAULT DEFAULT 'n',
		tab_name VARCHAR(25) COLLATE DATABASE_DEFAULT DEFAULT 'Report Criteria',
		tab_active_flag VARCHAR(25) COLLATE DATABASE_DEFAULT DEFAULT 'y',
		tab_sequence VARCHAR(25) COLLATE DATABASE_DEFAULT DEFAULT '1',
		fieldset_label VARCHAR(25) COLLATE DATABASE_DEFAULT DEFAULT 'fieldset',
		fieldset_position VARCHAR(25) COLLATE DATABASE_DEFAULT,
		group_name VARCHAR(25) COLLATE DATABASE_DEFAULT DEFAULT 'General',
		group_id VARCHAR(25) COLLATE DATABASE_DEFAULT,
		position VARCHAR(25) COLLATE DATABASE_DEFAULT DEFAULT 'label-top',
		field_hidden VARCHAR(25) COLLATE DATABASE_DEFAULT DEFAULT 'n',
		field_seq VARCHAR(25) COLLATE DATABASE_DEFAULT DEFAULT 0
	)

	

	INSERT INTO #report_ct
	(
		report_param_id,
		column_id,
		column_name,
		column_alias,
		operator,
		initial_value,
		initial_value2,
		param_data_source,
		param_default_value,
		optional,
		widget_id,
		datatype_id,
		source_id,
		datatype_name,
		report_paramset_id,
		widget_type,
		label,
		param_order,
		data_source_type
	)	
	EXEC spa_rfx_report_record 'a', @report_param_id, NULL, NULL, NULL, NULL
	
	DECLARE @subbook_id1 VARCHAR(100)
	SELECT @subbook_id1 = initial_value FROM #report_ct 
	WHERE widget_type = 'BSTREE-SubBook'

	UPDATE #report_ct
	SET initial_value = @subbook_id1
	WHERE widget_type = 'BSTREE-Subsidiary'

	DECLARE db_cursor1 CURSOR FOR  
	SELECT column_id, operator
	FROM #report_ct
	--WHERE operator = '8'

	OPEN db_cursor1  
	FETCH NEXT FROM db_cursor1 INTO @column_id, @operator

	WHILE @@FETCH_STATUS = 0  
	BEGIN
		SET @row_count = @row_count + 1
		INSERT INTO #report_criteria_process_table_columns1
		(
			application_field_id,
			id,
			field_id,
			[name],
			label,
			VALUE,
			sql_string,
			validate,
			--application_function_id,
			[type],
			is_hidden,
			field_size,
			header_detail,
			system_required,
			[disabled],
			data_flag,
			tab_name,
			tab_active_flag,
			tab_sequence,
			fieldset_label,
			fieldset_position,
			group_name,
			group_id,
			position,
			field_hidden,
			validation_message
		)
		SELECT
			report_param_id,
				param_order + @id,
			CASE
				WHEN widget_type = 'BSTREE-Subsidiary' THEN 'book_structure' ELSE column_name
			END 
			column_name,
			CASE
				WHEN widget_type = 'BSTREE-Subsidiary' THEN 'book_structure' ELSE column_name
			END 
			column_name,
			CASE
				WHEN widget_type = 'BSTREE-Subsidiary' THEN 'Book Structure' ELSE isnull(nullif(column_alias,''),replace(column_name,'_',' '))
			END 
			column_alias,
			ISNULL(NULLIF(initial_value2,''), initial_value),
			param_data_source,
			CASE
				WHEN optional = '0' THEN 'NotEmpty'
				WHEN optional = '1' THEN ''
			END
			optional,
			--report_paramset_id,
			CASE
				WHEN widget_type = 'DATETIME' THEN 'calendar'
				WHEN widget_type = 'DROPDOWN' THEN 'combo'
				WHEN widget_type = 'Multiselect Dropdown' THEN 'combo'
				WHEN widget_type = 'TEXTBOX' THEN 'input'
				WHEN widget_type = 'DataBrowser' THEN 'browser'
				WHEN widget_type = 'BSTREE-Subsidiary' THEN 'browser'
			END 
			widget_type,
			is_hidden,
			field_size,
			header_detail,
			system_required,
			[disabled],
			data_flag,
			tab_name,
			tab_active_flag,
			tab_sequence,
			fieldset_label,
			fieldset_position,
			group_name,
			ISNULL(group_id, @application_group_id),
			position,
			field_hidden,
			CASE
				WHEN optional = '0' THEN
					CASE
						WHEN widget_type IN ('DROPDOWN', 'Multiselect Dropdown') THEN 'Invalid Selection'
						ELSE 'Required Field'
					END
				WHEN optional = '1' THEN ''
			END
		FROM #report_ct
		WHERE column_id = @column_id
		
		IF (@operator = '8')
		BEGIN
			INSERT INTO #report_criteria_process_table_columns1
			(
				application_field_id,
				id,
				field_id,
				[name],
				label,
				VALUE,
				sql_string,
				validate,
				--application_function_id,
				[type],
				is_hidden,
				field_size,
				header_detail,
				system_required,
				[disabled],
				data_flag,
				tab_name,
				tab_active_flag,
				tab_sequence,
				fieldset_label,
				fieldset_position,
				group_name,
				group_id,
				position,
				field_hidden,
				validation_message
			)
			SELECT
				application_field_id,
				id + 1,
				field_id,
				'2_' + [name],
				'and',
				VALUE,
				sql_string,
				validate,
				--application_function_id,
				[type],
				is_hidden,
				field_size,
				header_detail,
				system_required,
				[disabled],
				data_flag,
				tab_name,
				tab_active_flag,
				tab_sequence,
				fieldset_label,
				fieldset_position,
				group_name,
				group_id,
				position,
				field_hidden,
				validation_message
			FROM #report_criteria_process_table_columns1
			WHERE id = @row_count

			SET @id = @id + 1
			SET @row_count = @row_count + 1
			
		END
		FETCH NEXT FROM db_cursor1 INTO @column_id, @operator
	END

	CLOSE db_cursor1
	DEALLOCATE db_cursor1
	
	SELECT @max_id = MAX(CAST(id AS INT))
	FROM #report_criteria_process_table_columns1
	
	SET @max_id = ISNULL(@max_id, 0)

	INSERT INTO #report_criteria_process_table_columns1
	VALUES (NULL,@max_id+1,'input','report_name','Report Name',NULL,@report_name,NULL,'n',250,'report_name',NULL,NULL,'n','n','n','n','n','Report Criteria',NULL,'n',2,NULL,NULL,NULL,NULL,NULL,0,0,'fieldset',0,0,NULL,NULL,NULL,NULL,'y',200,'General',@application_group_id,10202200,'report template','label-top',3,'y',0, NULL, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL, NULL)

	INSERT INTO #report_criteria_process_table_columns1
	VALUES (NULL,@max_id+2,'input','report_paramset_id','Report Paramset ID',NULL,@report_param_id,NULL,'n',250,'report_paramset_id',NULL,NULL,'n','n','n','n','n','Report Criteria',NULL,'n',2,NULL,NULL,NULL,NULL,NULL,0,0,'fieldset',0,0,NULL,NULL,NULL,NULL,'y',200,'General',@application_group_id,10202200,'report template','label-top',3,'y',0, NULL, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL, NULL)

	INSERT INTO #report_criteria_process_table_columns1
	VALUES (NULL,@max_id+3,'input','items_combined','Items Combined',NULL,@items_combined,NULL,'n',250,'items_combined',NULL,NULL,'n','n','n','n','n','Report Criteria',NULL,'n',2,NULL,NULL,NULL,NULL,NULL,0,0,'fieldset',0,0,NULL,NULL,NULL,NULL,'y',200,'General',@application_group_id,10202200,'report template','label-top',3,'y',0, NULL, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL, NULL)

	INSERT INTO #report_criteria_process_table_columns1
	VALUES (NULL,@max_id+4,'settings',NULL,NULL,NULL,NULL,NULL,'n',250,NULL,NULL,NULL,'n','n','n','n','n','Report Criteria',NULL,'n',2,NULL,NULL,NULL,NULL,NULL,0,0,'fieldset',0,0,NULL,NULL,NULL,NULL,'y',200,'General',@application_group_id,10202200,'report template','label-top',3,'n',0, NULL, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL, NULL)

	--INSERT INTO #report_criteria_process_table_columns1
	--VALUES (NULL,@max_id+5,'input','paramset_hash','Paramset Hash',NULL,@paramset_hash,NULL,'n',250,'paramset_hash',NULL,NULL,'n','n','n','n','n','Report Criteria',NULL,'n',2,NULL,NULL,NULL,NULL,NULL,0,0,'fieldset',0,0,NULL,NULL,NULL,NULL,'y',200,'General',@application_group_id,10202200,'report template','label-top',3,'y',0, NULL, NULL, NULL, NULL)

	--INSERT INTO #report_criteria_process_table_columns1
	--VALUES (NULL,@max_id+6,'input','report_path','Report Path',NULL,@report_path,NULL,'n',250,'report_path',NULL,NULL,'n','n','n','n','n','Report Criteria',NULL,'n',2,NULL,NULL,NULL,NULL,NULL,0,0,'fieldset',0,0,NULL,NULL,NULL,NULL,'y',200,'General',@application_group_id,10202200,'report template','label-top',3,'y',0, NULL, NULL, NULL, NULL)

	--SELECT * FROM #report_criteria_process_table_columns1
	--RETURN
	
	EXEC ('SELECT * INTO ' + @report_process_table + ' FROM #report_criteria_process_table_columns1')
	--EXEC ('select 
	--			[type]
	--			,[name]
	--			,[label]
	--			,[validate]
	--			,[is_hidden]
	--			,[value]
	--			,[application_field_id]
	--			,[default_format]
	--			,[is_dependent]
	--			,[validation_message]
	--			,[tooltip]
	--			,[required]
	--			,[dateFormat]
	--			,[serverDateFormat]
	--			,[calendarPosition] 
	--      FROM #report_criteria_process_table_columns1')

	--SET @report_grid_name_process_table = NULL
	
	IF OBJECT_ID('tempdb..#tmp_browser0') IS NOT NULL
		DROP TABLE #tmp_browser0

	CREATE TABLE #tmp_browser0
	(
		farrms_field_id VARCHAR(100) COLLATE DATABASE_DEFAULT,
		grid_name VARCHAR(100) COLLATE DATABASE_DEFAULT
	)

	INSERT INTO #tmp_browser0 (farrms_field_id, grid_name)
	SELECT CASE WHEN dsc.widget_id = 5 THEN 'book_structure' ELSE rc.column_name END column_name, dsc.param_data_source
	FROM data_source_column dsc
	INNER JOIN #report_ct rc ON dsc.data_source_column_id = rc.column_id
	WHERE NULLIF(dsc.param_data_source, '') IS NOT NULL AND dsc.widget_id IN (5,7)
	
	EXEC ('SELECT * INTO ' + @report_grid_name_process_table + ' FROM #tmp_browser0')

	IF ((SELECT COUNT(*) FROM #tmp_browser0) = 0) 
		SET @report_grid_name_process_table = NULL
	
	
	DROP TABLE #report_criteria_process_table_columns1
	DROP TABLE #report_ct
	
	--EXEC spa_convert_to_form_json NULL, @report_process_table, NULL, NULL
	EXEC spa_convert_to_form_json @tab_process_table, @report_process_table, NULL, @report_grid_name_process_table, @call_from = 'mobile', @is_report = 'y'
	
END

-- Returns the JSON for Apply Filters
IF @flag = 'f'
BEGIN
	DECLARE @filter_json VARCHAR(MAX) = ''
	DECLARE @filter_name1 VARCHAR(50) = ''
	DECLARE @filter_name VARCHAR(50) = ''
	DECLARE @name VARCHAR(50) = ''
	DECLARE @data_label VARCHAR(MAX) = ''
	DECLARE @data_value VARCHAR(MAX) = ''
	DECLARE @row_count2 INT = 0
	
	IF OBJECT_ID('tempdb..#tmp_browser1') IS NOT NULL
		DROP TABLE #tmp_browser1

	CREATE TABLE #tmp_browser1 (filter_name VARCHAR(1024) COLLATE DATABASE_DEFAULT, name VARCHAR(1024) COLLATE DATABASE_DEFAULT, data_label VARCHAR(1024) COLLATE DATABASE_DEFAULT, data_value VARCHAR(1024) COLLATE DATABASE_DEFAULT)
	
	IF @report_id IS NOT NULL AND @report_id <> '' -- For Power BI Reports
	BEGIN
		INSERT INTO #tmp_browser1 
		SELECT DISTINCT
			auf.application_ui_filter_name [filter_name],
			CASE  
				WHEN dsc.name = 'sub_id' THEN 'subsidiary_id'
				WHEN dsc.name = 'stra_id' THEN 'strategy_id'
				WHEN aufd.report_column_id < 0 THEN CASE WHEN dsc.name = 'sub_book_id' THEN 'book_structure' ELSE 'browse_' + dsc.name END
				WHEN dsc.name = 'sub_book_id' THEN 'subbook_id'
				ELSE dsc.name
			END AS [name],
			CASE  
			WHEN dsc.name IN ('sub_id','stra_id','book_id', 'sub_book_id') THEN REPLACE(aufd.field_value, ',', '!')
			ELSE
				aufd.field_value 
			END [data_label],
			CASE  
			WHEN dsc.name IN ('sub_id','stra_id','book_id', 'sub_book_id') THEN REPLACE(aufd.field_value, ',', '!')
			ELSE
				aufd.field_value 
			END  [data_value]  
		FROM application_ui_filter AS auf
		INNER JOIN application_ui_filter_details aufd
			ON auf.application_ui_filter_id = aufd.application_ui_filter_id
		INNER JOIN data_source_column dsc
			ON dsc.data_source_column_id = CASE WHEN aufd.report_column_id < 0 THEN aufd.report_column_id * -1 ELSE aufd.report_column_id END
		INNER JOIN report_dataset_paramset rdp ON rdp.paramset_id IN (SELECT scsv.item FROM dbo.SplitCommaSeperatedValues(@report_param_id) scsv)
		INNER JOIN report_param rp ON rp.dataset_paramset_id = rdp.report_dataset_paramset_id and rp.column_id = dsc.data_source_column_id
		WHERE auf.report_id = @report_id AND auf.user_login_id = @user_name AND auf.application_function_id = 10202700
	END
	ELSE
	BEGIN
		INSERT INTO #tmp_browser1 
	SELECT
	DISTINCT
	auf.application_ui_filter_name [filter_name],
	
         case  
    when dsc.name = 'sub_id' then 'subsidiary_id'
    when dsc.name = 'stra_id' then 'strategy_id'
    when aufd.report_column_id < 0 then CASE WHEN dsc.name = 'sub_book_id' THEN 'book_structure' ELSE 'browse_' + dsc.name END
    when dsc.name = 'sub_book_id' then 'subbook_id'
    else dsc.name
   end AS [name],
    case  
    when dsc.name IN ('sub_id','stra_id','book_id', 'sub_book_id') then REPLACE(aufd.field_value, ',', '!')
    ELSE
		aufd.field_value 
	END [data_label]
		,case  
    when dsc.name IN ('sub_id','stra_id','book_id', 'sub_book_id') then REPLACE(aufd.field_value, ',', '!')
    ELSE
		aufd.field_value 
	END  [data_value]
		--into #tmp_browser1     
       FROM application_ui_filter AS auf
       INNER JOIN application_ui_filter_details aufd
         ON auf.application_ui_filter_id = aufd.application_ui_filter_id
       INNER JOIN report_paramset rps
         ON rps.report_paramset_id = auf.report_id
       INNER JOIN data_source_column dsc
         ON dsc.data_source_column_id = CASE WHEN aufd.report_column_id < 0 THEN aufd.report_column_id * -1 ELSE aufd.report_column_id END
		WHERE auf.report_id = @report_param_id
       AND auf.user_login_id = @user_name
    END
    
     UPDATE t1
		SET t1.data_value = REPLACE(t2.data_value, ',', '!')
		--SELECT 
		--*
       FROM #tmp_browser1 t1
       INNER JOIN #tmp_browser1 t2 ON t1.filter_name = t2.filter_name AND t1.name = 'browse_' + t2.name
       
     DELETE t2
       FROM #tmp_browser1 t1
       INNER JOIN #tmp_browser1 t2 ON t1.filter_name = t2.filter_name AND t1.name = 'browse_' + t2.name   
	
	DECLARE db_cursor2 CURSOR FOR  
	SELECT filter_name, name, data_label, data_value
	FROM #tmp_browser1
	--WHERE operator = '8'

	OPEN db_cursor2  
	FETCH NEXT FROM db_cursor2 INTO @filter_name, @name, @data_label, @data_value

	WHILE @@FETCH_STATUS = 0  
	BEGIN
		IF @filter_name <> @filter_name1
		BEGIN
			IF @row_count2 > 0
			BEGIN
				SET @filter_json = @filter_json + ']},'
			END
			SET @filter_json = @filter_json + '{ "name": "' + @filter_name + '",'
			SET @filter_json = @filter_json + ' "fields": ['
			SET @filter_json = @filter_json + '{ "name": "' + @name + '", "data_label" : "' + @data_label+ '",  "data_value" : "' + @data_value+ '"}'
		END 
		ELSE
		BEGIN
			SET @filter_json = @filter_json + ', { "name": "' + @name + '", "data_label" : "' + @data_label+ '",  "data_value" : "' + @data_value+ '"}'
		END
		SET @filter_name1 = @filter_name
		SET @row_count2 = @row_count2 + 1
			
		
		FETCH NEXT FROM db_cursor2 INTO @filter_name, @name, @data_label, @data_value
	END
		SET @filter_json = @filter_json + ']}'
	CLOSE db_cursor2
	DEALLOCATE db_cursor2
	
	SET @filter_json = '{"filter_presets": [' + @filter_json + ']}'
	
	SELECT @filter_json [filter_json]
	
END	

--Returns report_id,paramset_id from report_name (caller: view.link.php,buysell.match.php,deal.match.php).
ELSE IF @flag = 'a' 
BEGIN
	SELECT r.report_id, rps.report_paramset_id FROM report r
				LEFT JOIN report_page rp ON rp.report_id = r.report_id
				INNER JOIN report_paramset rps ON rps.page_id = rp.report_page_id
				WHERE 
				r.name =  @report_name 	
END

--Get Report manager reports for excel addin
ELSE IF @flag = 'x'
BEGIN
	-- Report Manager Report for excel add-in, Please do not change column selection here , it will break excel add-in
		SELECT MAX(ISNULL(sdv.code, 'General')) AS accordion_name, MAX(rps.name) report_name,
			r.report_id AS report_id, '1' AS report_type, cast(rps.report_paramset_id as varchar(100)) AS paramset_id
			FROM report r 
			INNER JOIN report_page rp ON rp.report_id = r.report_id
			INNER JOIN report_paramset rps ON  rps.page_id = rp.report_page_id
			LEFT JOIN report_dataset_paramset rdp ON rdp.paramset_id = rps.report_paramset_id
			LEFT JOIN report_param rpm ON rdp.report_dataset_paramset_id = rpm.dataset_paramset_id 
			LEFT JOIN report_privilege rpv ON r.report_hash = rpv.report_hash
			--AND (rpv.[user_id] = @user_name OR rpv.role_id IN (SELECT fur.role_id FROM dbo.FNAGetUserRole(@user_name) fur))
			LEFT JOIN report_paramset_privilege rpp ON rpp.paramset_hash = rps.paramset_hash
			LEFT JOIN static_data_value sdv ON sdv.value_id = r.category_id			
			WHERE rp.is_deployed = 1	--Show deployed reports only as they are the ones that can be run.
				AND 
				(	
					@is_admin = 1						--Superuser (farrms_admin, WinAuth Admin or Application Admin Group) and Reporting Admin Group can see all reports.
					OR r.[owner] = @user_name			--Package owner can see all paramsets (even Draft or Hidden created by others in same package)
					OR rps.create_user = @user_name		--Paramset owner should see her report regardless of its status
					OR rps.report_status_id = 2			--Public reports should be visible to all
					OR (rps.report_status_id = 3		--Private report and
						AND (@user_name IN (rpv.user_id, rpp.[user_id])	--got directly assigned privilege
								OR EXISTS(SELECT role_id FROM dbo.FNAGetUserRole(@user_name) WHERE role_id IN (rpv.role_id, rpp.role_id))	--got privilege via role
							)
					)
				)		
			GROUP BY   rps.report_paramset_id , rp.report_page_id, r.report_id
END

/*
 * [Load the list of report for web services]
 */
ELSE IF @flag = 'g'
BEGIN
	IF OBJECT_ID('tempdb..#listreports') IS NOT NULL
		DROP TABLE #listreports 
	
	CREATE TABLE #listreports (
		report_category VARCHAR(100) COLLATE DATABASE_DEFAULT
		, report_name VARCHAR(100) COLLATE DATABASE_DEFAULT
		, report_id INT
		, report_type INT
		, paramset_id VARCHAR(100) COLLATE DATABASE_DEFAULT
		, report_unique_identifier VARCHAR(250) COLLATE DATABASE_DEFAULT
		, system_defined INT
		, excel_doc_type INT
		)

	INSERT INTO #listreports
	EXEC spa_view_report @flag = 's'

	SELECT	r.report_name		[report_name],
			rp.paramset_hash	[report_hash] 
	FROM #listreports r
	INNER JOIN report_paramset rp ON rp.report_paramset_id = r.paramset_id
	WHERE r.report_type = 1 --pick only report manager paramsets
	ORDER BY r.report_name
END


/*
 * [Load the list the parameters of report for web services]
 */
ELSE IF @flag = 'l'
BEGIN
	SELECT	dsc.name [parameter],
			rdt.name [data_type],
			CASE WHEN rpm.optional = 1 THEN 'y' ELSE 'n' END [optional]
	FROM 
	report_paramset rps 
	INNER JOIN report_dataset_paramset rdp ON rdp.paramset_id = rps.report_paramset_id
	INNER JOIN report_param rpm ON rdp.report_dataset_paramset_id = rpm.dataset_paramset_id 
	LEFT JOIN data_source_column dsc ON dsc.data_source_column_id = rpm.column_id
	LEFT JOIN report_datatype rdt ON rdt.report_datatype_id = dsc.datatype_id
	WHERE rps.name = @report_name AND rps.paramset_hash = @paramset_hash 
	AND rpm.hidden <> 1
	UNION ALL
	SELECT  dsc.name [column_name],
			rdt.name [data_type],
			CASE WHEN dsc.required_filter = 0 THEN 'y' ELSE 'n' END [optional]
	FROM report_dataset_paramset rdp 
	INNER JOIN report_dataset rd on rd.report_dataset_id = rdp.root_dataset_id
	INNER JOIN data_source_column dsc on dsc.source_id = rd.source_id
	INNER JOIN report_paramset rps ON rps.report_paramset_id = rdp.paramset_id
	INNER JOIN report_datatype rdt ON rdt.report_datatype_id = dsc.datatype_id
	INNER JOIN report_widget rwt ON rwt.report_widget_id = dsc.widget_id
	INNER JOIN data_source ds on ds.data_source_id = dsc.source_id
	LEFT JOIN report_param rp on rp.column_id = dsc.data_source_column_id and rp.dataset_paramset_id = rdp.report_dataset_paramset_id
	WHERE rps.paramset_hash = @paramset_hash
		AND dsc.required_filter IS NOT NULL
		AND rp.column_id IS NULL

END

/*
 * [To run the report from the web services]
 */
ELSE IF @flag = 'q'
BEGIN
	DECLARE @param_table NVARCHAR(MAX)
	DEClARE @paramset_id INT
	DEClARE @component_id INT
	DECLARE @required_cols NVARCHAR(MAX)

	IF OBJECT_ID('tempdb..#temp_table') IS NOT NULL
	BEGIN
		DROP TABLE #temp_table 
	END

	CREATE TABLE #temp_table ([param_table] NVARCHAR(200) COLLATE DATABASE_DEFAULT)
	
	-- If no parameters passed
	IF CAST(@view_report_filter_xml AS VARCHAR(10)) = '[{}]' OR CAST(@view_report_filter_xml AS VARCHAR(10)) = '[]'
		SET @view_report_filter_xml = NULL
	
	IF @view_report_filter_xml IS NOT NULL
	BEGIN
		INSERT INTO #temp_table
		EXEC spa_parse_json @flag = 'parse', @json_string = @view_report_filter_xml
	END
	
	SELECT @param_table =  REPLACE([param_table], 'adiha_process.dbo.', '') FROM #temp_table
	
	IF OBJECT_ID('tempdb..#transpose_tbl_val') IS NOT NULL
	BEGIN
		DROP TABLE #transpose_tbl_val
	END

	CREATE TABLE #transpose_tbl_val(
		col NVARCHAR(MAX) COLLATE DATABASE_DEFAULT ,
		Colval NVARCHAR(MAX) COLLATE DATABASE_DEFAULT
	)
	
	IF @param_table IS NOT NULL
	BEGIN
		INSERT INTO #transpose_tbl_val
		EXEC spa_Transpose @TableName = @param_table, @where = NULL, @is_adiha_table = '1'
	END
	
	SELECT @paramset_id = CAST(report_paramset_id AS NVARCHAR) FROM report_paramset WHERE paramset_hash = @paramset_hash
	
	DROP TABLE IF EXISTS #temp_parameter_col_lists
	CREATE TABLE #temp_parameter_col_lists(col_id NVARCHAR(MAX) COLLATE DATABASE_DEFAULT, optional BIT)

	INSERT INTO #temp_parameter_col_lists(col_id, optional)
	SELECT dsc.name [col_id], r.optional [optional]
	FROM report_paramset rp
	INNER JOIN report_dataset_paramset rpd
		ON rp.report_paramset_id = rpd.paramset_id AND rp.report_paramset_id = @paramset_id
	INNER JOIN report_param r
		ON r.dataset_paramset_id = rpd.report_dataset_paramset_id
	INNER JOIN data_source_column dsc
		ON r.column_id = dsc.data_source_column_id
	
	SELECT @required_cols = COALESCE(@required_cols + ',', '') + tpcl.col_id
	FROM #temp_parameter_col_lists tpcl
	LEFT JOIN #transpose_tbl_val ttv
		ON ttv.col = tpcl.col_id AND NULLIF(ttv.colval,'NULL') IS NOT NULL
	WHERE ttv.col IS NULL AND tpcl.optional = 0
	
	IF @required_cols IS NULL
	BEGIN
		DECLARE @cols NVARCHAR(MAX), @table_cols NVARCHAR(MAX)
		
		SELECT @cols = COALESCE(@cols + ', ', '') + CAST(tpcl.col_id AS NVARCHAR(MAX)) + ' = ' + CAST(ISNULL(NULLIF(ttv.Colval, ''), 'NULL') AS NVARCHAR(MAX))
		FROM #temp_parameter_col_lists tpcl
		LEFT JOIN #transpose_tbl_val ttv ON ttv.col = tpcl.col_id
		
		SELECT @component_id = CAST(report_page_tablix_id AS NVARCHAR)
		FROM report_page_tablix rpt
		INNER JOIN report_paramset rp ON rp.page_id = rpt.page_id
		WHERE rp.paramset_hash=@paramset_hash			
		
		EXEC spa_rfx_run_sql @paramset_id, @component_id, @cols, NULL,'t'
	END
	ELSE
	BEGIN
		DECLARE @error_msg NVARCHAR(2000)
		SET @error_msg = 'Required value missing for parameter: ' + @required_cols

		EXEC spa_ErrorHandler -1
		   , 'my_report'
		   , 'spa_view_report'
		   , 'Error'
		   ,  @error_msg
		   ,''
	END
END

/*
 * [To check the privilege of report from web services]
 */
ELSE IF @flag = 'w'
BEGIN
	IF NOT EXISTS(
		SELECT 1 FROM report r
		INNER JOIN report_page rp ON rp.report_id = r.report_id
		INNER JOIN report_paramset rps ON  rps.page_id = rp.report_page_id
		WHERE rps.paramset_hash = @paramset_hash
	)
	BEGIN
		-- Invalid Hash
		SELECT 2 [PrivilegeStatus]
	END
	ELSE IF NOT EXISTS(
		SELECT 1 FROM report r
		INNER JOIN report_page rp ON rp.report_id = r.report_id
		INNER JOIN report_paramset rps ON  rps.page_id = rp.report_page_id 
		LEFT JOIN report_privilege rpv ON r.report_hash = rpv.report_hash
		LEFT JOIN report_paramset_privilege rpp ON rpp.paramset_hash = rps.paramset_hash			
		WHERE 1 = 1 AND 
					(	
						@is_admin = 1						--Superuser (farrms_admin, WinAuth Admin or Application Admin Group) and Reporting Admin Group can see all reports.
						OR r.[owner] = @user_name			--Package owner can see all paramsets (even Draft or Hidden created by others in same package)
						OR rps.create_user = @user_name		--Paramset owner should see her report regardless of its status
						OR rps.report_status_id = 2			--Public reports should be visible to all
						OR (rps.report_status_id = 3		--Private report and
							AND (@user_name IN (rpv.user_id, rpp.[user_id])	--got directly assigned privilege
									OR EXISTS(SELECT role_id FROM dbo.FNAGetUserRole(@user_name) WHERE role_id IN (rpv.role_id, rpp.role_id))	--got privilege via role
								)
						)
					)
		AND rps.paramset_hash = @paramset_hash
	)
	BEGIN
		SELECT 0 [PrivilegeStatus]
	END
	ELSE
	BEGIN
		SELECT 1 [PrivilegeStatus]
	END
END

/*
 * [Returns json items of paramset_id, name according to defined category in paramsets of report.]
 */
IF @flag = 'j'
BEGIN
	SELECT + '[' + ji.[json_item] + ']' json_item
	FROM (
	SELECT STUFF((
				SELECT ',' + '[' + (cast(rps.report_paramset_id AS VARCHAR) + ',' + '"'+MAX(rps.name)) + '"' + ']'
				FROM report r
				INNER JOIN report_page rp ON rp.report_id = r.report_id
				INNER JOIN report_paramset rps ON rps.page_id = rp.report_page_id
				LEFT JOIN report_dataset_paramset rdp ON rdp.paramset_id = rps.report_paramset_id
				LEFT JOIN report_param rpm ON rdp.report_dataset_paramset_id = rpm.dataset_paramset_id
				LEFT JOIN report_privilege rpv ON r.report_hash = rpv.report_hash
				LEFT JOIN report_paramset_privilege rpp ON rpp.paramset_hash = rps.paramset_hash
				LEFT JOIN static_data_value sdv ON sdv.value_id = r.category_id
				WHERE rp.is_deployed = 1
					AND rps.category_id = @paraset_category_id -- 104701 
				GROUP BY rps.report_paramset_id
					,rp.report_page_id
					,r.report_id
				FOR XML PATH('')
					,TYPE
				).value('.', 'NVARCHAR(MAX)'), 1, 1, '') AS [json_item]
	) ji

END

-- Clean up Process Tables Used after the scope is completed when Debug Mode is Off. This process table is used to build filters.
DECLARE @debug_mode VARCHAR(128) = REPLACE(CONVERT(VARCHAR(128), CONTEXT_INFO()), 0x0, '')

IF ISNULL(@debug_mode, '') <> 'DEBUG_MODE_ON'
BEGIN
	EXEC dbo.spa_clear_all_temp_table NULL, @process_id3
END

