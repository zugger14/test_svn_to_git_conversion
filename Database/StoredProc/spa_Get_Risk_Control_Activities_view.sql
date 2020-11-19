
IF OBJECT_ID('[dbo].[spa_Get_Risk_Control_Activities_view]','p') IS NOT NULL
DROP PROC [dbo].[spa_Get_Risk_Control_Activities_view]
/*
Author		:	Sishir Maharjan
Date		:	07/08/2009
Description	:	View Status of Compliance Activities
*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[spa_Get_Risk_Control_Activities_view]
	@user_login_id AS VARCHAR(50),
	@as_of_date AS VARCHAR(20),
	@sub_id AS VARCHAR(250),
	@run_frequency AS VARCHAR(20),
	@risk_priority AS VARCHAR(20),
	@role_id AS VARCHAR(20),
	@activityStatus AS INT ,
	@call_type AS INT,
	@get_counts INT = 0,
	@process_number VARCHAR(50) = NULL,
    @risk_description_id INT = NULL,
	@activity_category_id INT=NULL,
	@who_for INT=NULL,
	@where INT=NULL,
	@why INT=NULL,
	@activity_area INT=NULL,
	@activity_sub_area INT=NULL,
	@activity_action INT=NULL,
	@activity_desc VARCHAR(250)=NULL,
	@control_type INT=NULL,
	@montetory_value_defined VARCHAR(1)='n',
	@process_owner VARCHAR(50)=NULL,
	@risk_owner VARCHAR(50)=NULL,
	@risk_control_id INT = NULL,
	@strategy_id VARCHAR(250)=NULL,
	@book_id VARCHAR(250)=NULL,
	@process_table VARCHAR(100)=NULL,
	@process_table_insert_or_create VARCHAR(100)='c', --'c' creates the table and 'i' just inserts in the same table (table alredy created)
	@as_of_date_to AS VARCHAR(20)=NULL,
	@is_dependent_act AS INT=NULL,
	@mitigateActivity AS INT = NULL,
	@activity_mode AS VARCHAR(20)=NULL,
	@flag AS CHAR(1) = NULL,
	@risk_control_activity_id VARCHAR(MAX) = NULL,
	@source_column VARCHAR(200) = NULL,
	@source_id INT = NULL,
	@source VARCHAR(1000) = NULL
		
AS

SET NOCOUNT ON
--select @as_of_date_to '@as_of_date_to'
DECLARE @stmt VARCHAR(MAX),
		@control_activity_stmt varchar(500),
		@penalty_stmt VARCHAR(MAX),
		@risk_control_activity_ids VARCHAR(MAX)

EXEC spa_print @risk_control_activity_id

IF @as_of_date is NULL
  SELECT @as_of_date ='1900-01-01'
  
SELECT @as_of_date_to = ISNULL(@as_of_date_to , GETDATE()) 
  

SELECT @control_activity_stmt = 
			'	
			isnull(area.code + '' > '', '''') + isnull(sarea.code + '' > '', '''')  + 
			isnull(action.code , '''') +
			isnull('' > '' + prc.risk_control_description, '''')'
			
set @penalty_stmt = '0.0'
--			' 
--			cast(case when (isnull(prca.monetary_value, prc.monetary_value) is not null and (prca.as_of_date < case when (isnull(prca.control_status, 525) IN (728, 729)) then prca.update_ts else getdate() end) and prc.monetary_value_frequency_id is not null) then
--			case prc.monetary_value_frequency_id when 700 then datediff(dd,prca.as_of_date, case when (isnull(prca.control_status, 525) IN (728, 729)) then prca.update_ts else getdate() end)
--			when 701 then datediff(ww,prca.as_of_date, case when (isnull(prca.control_status, 525) IN (728, 729)) then prca.update_ts else getdate() end) + 1
--			when 703 then datediff(mm,prca.as_of_date, case when (isnull(prca.control_status, 525) IN (728, 729)) then prca.update_ts else getdate() end) + 1
--			when 704 then datediff(qq,prca.as_of_date, case when (isnull(prca.control_status, 525) IN (728, 729)) then prca.update_ts else getdate() end) + 1
--			when 705 then (datediff(yy,prca.as_of_date, case when (isnull(prca.control_status, 525) IN (728, 729)) then prca.update_ts else getdate() end)/2) + 1
--			when 706 then datediff(yy,prca.as_of_date, case when (isnull(prca.control_status, 525) IN (728, 729)) then prca.update_ts else getdate() end) + 1
--			else 1 end * coalesce(prca.monetary_value, prc.monetary_value, 0)			
--			else coalesce(prca.monetary_value, prc.monetary_value, 0) end as float)
--			'			
DECLARE @alert_table VARCHAR(500)
DECLARE @workflow_action_id INT
DECLARE @sql_stmt VARCHAR(MAX)
DECLARE @process_id VARCHAR(MAX)

SELECT @workflow_action_id  = CASE 
                                  WHEN ISNULL(prcas.nextAction, 11001) = 11001 THEN prc.action_type_on_complete
                                  WHEN prcas.nextAction = 11000 THEN prc.action_type_on_approve
                             END
FROM process_risk_controls_activities prca
INNER JOIN process_risk_controls prc ON  prc.risk_control_id = prca.risk_control_id
LEFT JOIN process_risk_controls_activities_status prcas ON prcas.activityStatus = prca.control_status 
AND UPPER(prc.requires_approval) = UPPER(prcas.requiresApproval) AND UPPER(prc.requires_approval_for_late) = UPPER(prcas.requiresApprovalLate) 
AND UPPER(prc.requires_proof) = UPPER(prcas.requiresProof) AND UPPER(prc.mitigation_plan_required) = UPPER(prcas.mitigationRequired)
LEFT JOIN dbo.static_data_value sdv ON sdv.value_id = ISNULL(prcas.nextAction,11001)
WHERE  risk_control_activity_id = @risk_control_activity_id

IF OBJECT_ID('tempdb..#temp_alert_workflow') IS NOT NULL
    DROP TABLE #temp_alert_workflow

CREATE TABLE #temp_alert_workflow (
	list         VARCHAR(2000) COLLATE DATABASE_DEFAULT,
	risk_control_activity_id  INT
)

IF @workflow_action_id = 20801
BEGIN
	SELECT @alert_table = 'adiha_process.dbo.nested_alert_' + ISNULL(prca.process_id, '') + '_na', @process_id = prca.process_id
	FROM   process_risk_controls_activities prca
	WHERE  prca.risk_control_activity_id = @risk_control_activity_id
	
	IF EXISTS (SELECT 1 FROM adiha_process.sys.tables WITH(NOLOCK) WHERE [name] = 'nested_alert_' + ISNULL(@process_id, '') + '_na')
	BEGIN
	SET @sql_stmt = 'DECLARE @list VARCHAR(2000)
	                 SELECT @list = (COALESCE(@list + '', '', '''')) + counterparty_name
	                 FROM   ' + @alert_table + ' temp
	                 INNER JOIN source_counterparty sc ON temp.id = sc.source_counterparty_id
	                 
	                 INSERT INTO #temp_alert_workflow
	                 SELECT ''Disabled Counterparty - '' + @list, ' + CAST(@risk_control_activity_id AS VARCHAR(20)) + ''
	                 	
	END
	EXEC(@sql_stmt)
	exec spa_print @sql_stmt
	--SELECT * FROM #temp_alert_workflow
END
ELSE IF @workflow_action_id = 20803
BEGIN
	SELECT @alert_table = 'adiha_process.dbo.deal_validation_' + ISNULL(prca.process_id, '') + '_dv', @process_id = prca.process_id
	FROM   process_risk_controls_activities prca
	WHERE  prca.risk_control_activity_id = @risk_control_activity_id
	
	
	IF EXISTS (SELECT 1 FROM adiha_process.sys.tables WITH(NOLOCK) WHERE [name] = 'deal_validation_' + ISNULL(@process_id, '') + '_dv')
	BEGIN
	SET @sql_stmt = 'DECLARE @list VARCHAR(2000)
	                 SELECT @list = (COALESCE(@list + '', '', '''')) + dbo.FNAHyperLinkText(10131010, temp.source_deal_header_id, temp.source_deal_header_id)
	                 FROM   ' + @alert_table + ' temp
	                
	                 
	                 INSERT INTO #temp_alert_workflow
	                 SELECT ''New Deals - '' + @list, ' + CAST(@risk_control_activity_id AS VARCHAR(20)) + ''
	                 	
	END
	EXEC(@sql_stmt)
	exec spa_print @sql_stmt
END
ELSE IF @workflow_action_id IN (20802, 20804, 20805) OR @workflow_action_id IS NULL
BEGIN
	SELECT @alert_table = 'adiha_process.dbo.workflow_table_' + ISNULL(prca.process_id, ''), @process_id = prca.process_id
	FROM   process_risk_controls_activities prca
	WHERE  prca.risk_control_activity_id = @risk_control_activity_id
	
	
	IF EXISTS (SELECT 1 FROM adiha_process.sys.tables WITH(NOLOCK) WHERE [name] = 'workflow_table_' + ISNULL(@process_id, ''))
	BEGIN
	SET @sql_stmt = 'DECLARE @list VARCHAR(5000)
	                 SELECT @list = (COALESCE(@list + '', '', '''')) + dbo.FNAHyperLinkText(10211010, cg.contract_name, temp.id) + 
						            CASE WHEN prc.document_template IS NOT NULL THEN ISNULL('' - ''+''<a href=../load_document_template.php?contract_id=''+CAST(cg.contract_id AS VARCHAR)+''&__user_name__=' + @user_login_id + '>Prepare Document</a>'', '''') ELSE '''' END
	                 FROM ' + @alert_table + ' temp
	                 INNER JOIN contract_group cg ON temp.id = cg.contract_id
	                 INNER JOIN process_risk_controls_activities prca ON prca.risk_control_activity_id = ' + CAST(@risk_control_activity_id AS VARCHAR(20)) + '
	                 INNER JOIN process_risk_controls prc ON prc.risk_control_id = prca.risk_control_id
	                 
	                 INSERT INTO #temp_alert_workflow
	                 SELECT @list, ' + CAST(@risk_control_activity_id AS VARCHAR(20)) + ''
	                 	
	END
	exec spa_print @sql_stmt
	EXEC(@sql_stmt)
END

exec spa_print @workflow_action_id, '@workflow_action_id'

SELECT @stmt = '
			SELECT 
				DISTINCT prca.risk_control_activity_id,ISNULL(dbo.FNAgetSubsidiary(prc.fas_book_id, ''a''),''NOT APPLICABLE'') AS [Subsidiary],
				ISNULL (frequency.code, ''One-Time'') AS [Frequency],
				NULL AS [Source],
				dbo.FNAComplianceHyperlink(''b'',10121600,' + @control_activity_stmt + ',44, cast(prca.risk_control_id as varchar),default,default,default,default,default) + '' - '' + ISNULL(temp_alert_table.list, '''')  AS [Activity],
				prca.comments  AS [Comments],
				dbo.FNADateformat(prca.as_of_date) AS [Date],
				dbo.FNADateformat(prca.exception_date) AS [Date By],
				CASE WHEN activity_status.code<> ''Notified'' THEN  dbo.FNAComplianceHyperlink(''a'',367,activity_status.code, cast(prca.risk_control_activity_id as varchar),default,default,default,default,default,default) ELSE  activity_status.code END [Status], '
				+ @penalty_stmt + ' AS [Penalty/Fees],
				CASE WHEN pUser.user_f_name IS NOT NULL THEN ''By: '' + '' '' + ISNULL(pUser.user_l_name, '''') + '' '' + ISNULL(pUser.user_f_name, '''') + '' '' + ISNULL(pUser.user_m_name, '''') 
				+ ''(On: '' + ISNULL(dbo.FNADateFormat(prca.create_ts),'''') + '')'' ELSE '''' END AS [Performer],
				CASE WHEN aUser.user_f_name IS NOT NULL THEN ''By: '' + '' '' + ISNULL(aUser.user_l_name, '''') + '' '' + ISNULL(aUser.user_f_name, '''') + '' '' + ISNULL(aUser.user_m_name, '''') 
				+ ''(On: '' + ISNULL(dbo.FNADateFormat(prca.approved_date),'''') + '')'' ELSE '''' END AS [Approver],
				dbo.FNAComplianceHyperlink(''a'',368, ''<IMG SRC="../adiha_pm_html/process_controls/steps.jpg">'', CAST(prca.risk_control_id AS VARCHAR),default,default,default,default,default,default)  [Steps],
				dbo.FNAComplianceHyperlink(''c'',10102900,''<IMG SRC="../adiha_pm_html/process_controls/doc.jpg">'',CAST(prca.risk_control_activity_id AS VARCHAR) ,dbo.FNAGetSQLStandardDate(prca.as_of_date),''a'',default,default,default,default) AS [Proof],'+
				case when @flag = 'v' then ' dbo.FNAComplianceActivityStatus(prca.risk_control_activity_id,''n'',''' + ISNULL(cast(@as_of_date as varchar),'''') + ''', ''' + ISNULL(cast(@as_of_date_to as varchar), '''') + ''', DEFAULT, ' + ISNULL('''' + @process_table + '''', 'NULL') + ', ' + ISNULL('''' + @source_column + '''', 'NULL') + ', ' + ISNULL('''' + CAST(@source_id AS VARCHAR(10)) + '''', 'NULL') + ') AS [Action] '
				else 
				' dbo.FNAComplianceActivityStatus(prca.risk_control_activity_id,''y'',''' + ISNULL(cast(@as_of_date as varchar), '''') + ''', ''' + ISNULL(cast(@as_of_date_to as varchar), '''') + ''', DEFAULT, ' + ISNULL('''' + @process_table + '''', 'NULL') + ', ' + ISNULL('''' + @source_column + '''', 'NULL') + ', ' + ISNULL('''' + CAST(@source_id AS VARCHAR(10)) + '''', 'NULL') + ') AS [Action] ' 
				end +
			'FROM dbo.process_risk_controls prc
			INNER JOIN dbo.process_risk_controls_activities prca ON prca.risk_control_id = prc.risk_control_id
			LEFT JOIN dbo.static_data_value frequency ON frequency.value_id = prc.run_frequency
			LEFT OUTER JOIN static_data_value area on area.value_id = prc.activity_area_id 
			LEFT OUTER JOIN static_data_value sarea on sarea.value_id = prc.activity_sub_area_id 
			LEFT OUTER JOIN static_data_value action on action.value_id = prc.activity_action_id 
			INNER JOIN static_data_value activity_status ON activity_status.value_id = isnull(prca.control_status, 725)
			LEFT OUTER JOIN application_users pUser ON prca.create_user = pUser.user_login_id
			LEFT OUTER JOIN	application_users aUser ON prca.approved_by = aUser.user_login_id
			LEFT JOIN application_notes an1 ON 
			an1.notes_id = 
			(
				SELECT a.notes_id FROM 
				(
				SELECT TOP 1 an.notes_id, pnm.process_risk_control_id, an.update_ts FROM application_notes an
				JOIN process_notes_map pnm ON pnm.notes_id = an.notes_id
				WHERE pnm.process_risk_control_id = prca.risk_control_id ORDER BY an.update_ts DESC
				) a
			)
			INNER JOIN process_risk_description prd ON prc.risk_description_id = prd.risk_description_id
			INNER JOIN process_control_header pch ON prd.process_id = pch.process_id 
			LEFT OUTER JOIN portfolio_hierarchy book ON book.entity_id = prc.fas_book_id 
			LEFT OUTER JOIN process_risk_controls_email prce on prce.risk_control_id = prc.risk_control_id
			LEFT JOIN application_role_user aru ON 
			CAST(aru.role_id AS VARCHAR) LIKE '+
			CASE WHEN @flag = 'v' THEN ' ISNULL(CAST(prce.inform_role AS VARCHAR),''%'')' ELSE +
				
				' CASE WHEN prca.control_status = 728 and requires_approval = ''y'' THEN ISNULL(CAST(prc.approve_role AS VARCHAR),''%'')							
					ELSE ISNULL(CAST(prc.perform_role AS VARCHAR),''%'') END ' END +													

			' AND aru.user_login_id LIKE  '+ CASE WHEN @flag = 'v' THEN ' ISNULL(prce.inform_user,''%'')'  ELSE +
				' CASE WHEN prca.control_status = 728 and requires_approval = ''y'' THEN ISNULL(prc.approve_user,''%'')
					ELSE ISNULL(prc.perform_user,''%'') END	'  END	+ 
			' LEFT JOIN application_users au ON au.user_login_id LIKE  '+ CASE WHEN @flag = 'v' THEN ' ISNULL(prce.inform_user,''' + dbo.FNADBUser() + ''')'  ELSE +
				' CASE WHEN prca.control_status = 728 and requires_approval = ''y'' THEN ISNULL(prc.approve_user,''' + dbo.FNADBUser() + ''')
					ELSE ISNULL(prc.perform_user,''' + dbo.FNADBUser() + ''') END	'  END	+ ' 
			LEFT JOIN #temp_alert_workflow temp_alert_table ON temp_alert_table.risk_control_activity_id = prca.risk_control_activity_id
			 LEFT JOIN contract_report_template crt ON crt.template_id = prc.document_template			
			WHERE 1=1 				
					AND ISNULL(aru.user_login_id, au.user_login_id) = '''+@user_login_id+''' 
					--AND prc.notificationOnly <> ''y''

				'

IF @as_of_date IS NOT NULL 
SET @stmt = @stmt + 
			CASE @flag WHEN  'v' THEN
					' AND prca.as_of_date  = CONVERT(DATETIME,''' + @as_of_date + ''', 102)'
				ELSE
					' AND (prca.as_of_date BETWEEN CONVERT(DATETIME,''' + @as_of_date + ''', 102) AND CONVERT(DATETIME,''' + @as_of_date_to + ''', 102)) '
			END 

IF @run_frequency IS NOT NULL 
	SELECT @stmt = @stmt + ' AND prc.run_frequency = ' + CAST(@run_frequency AS VARCHAR) 
	
IF @risk_priority IS NOT NULL 
	SELECT @stmt = @stmt + ' AND prd.risk_priority = ' + CAST(@risk_priority AS VARCHAR) 
	
IF @role_id IS NOT NULL AND @call_type = 1 
	SELECT @stmt = @stmt + ' AND prc.perform_role = ' + CAST(@role_id AS VARCHAR) 
	
IF @activityStatus IS NOT NULL 
BEGIN 
	IF @activityStatus = 734
	BEGIN 
		SELECT @stmt = @stmt + ' AND prca.mitigatedActivityInstanceId IS NOT NULL AND prca.force_build = ''m'' ' 
		SELECT @mitigateActivity = 1
	END 
	ELSE 
	BEGIN 
		IF @activityStatus = 733
			SELECT @stmt = @stmt + ' AND prca.control_status in (725, 731) AND CAST(dbo.FNADateFormat(GETDATE()) AS DATETIME) > prca.exception_date ' 
		ELSE 
			SELECT @stmt = @stmt + ' AND prca.control_status = ' + CAST(@activityStatus AS VARCHAR) 
	END 
END 
	
	
IF @process_number IS NOT NULL 
	SELECT @stmt = @stmt + ' AND pch.process_id = ''' + @process_number + ''' '

IF @risk_description_id IS NOT NULL 
	SELECT @stmt = @stmt + ' AND prd.risk_description_id = ' + CAST(@risk_description_id AS VARCHAR)
	
IF @activity_category_id IS NOT NULL 
	SELECT @stmt = @stmt + ' AND prc.activity_category_id = ' + CAST(@activity_category_id AS VARCHAR)

IF @who_for IS NOT NULL 
	SELECT @stmt = @stmt + ' AND prc.activity_who_for_id = ' + CAST(@who_for  AS VARCHAR)

IF @where IS NOT NULL 
	SELECT @stmt = @stmt + ' AND prc.where_id = ' + CAST(@where  AS VARCHAR)
	
IF @why  IS NOT NULL 
	SELECT @stmt = @stmt + ' AND prc.control_objective = ' + CAST(@why  AS VARCHAR)
	
IF @activity_area  IS NOT NULL 
	SELECT @stmt = @stmt + ' AND prc.activity_area_id = ' + CAST(@activity_area  AS VARCHAR)
	
IF @activity_sub_area  IS NOT NULL 
	SELECT @stmt = @stmt + ' AND prc.activity_sub_area_id = ' + CAST(@activity_sub_area  AS VARCHAR)
	
IF @activity_action  IS NOT NULL 
	SELECT @stmt = @stmt + ' AND prc.activity_action_id = ' + CAST(@activity_action  AS VARCHAR) 
	
IF @activity_desc  IS NOT NULL 
	SELECT @stmt = @stmt + ' AND (isnull(area.code + '' > '', '''') + isnull(sarea.code + '' > '', '''')  + 
						isnull(action.code + '' > '', '''') +
						isnull(prc.risk_control_description, '''')) LIKE ''%' + CAST(@activity_desc AS VARCHAR(MAX)) + '%'''
						
IF @control_type  IS NOT NULL 
	SELECT @stmt = @stmt + ' AND prc.control_type = ' + CAST(@control_type  AS VARCHAR) 
	
IF ISNULL(@montetory_value_defined, 'n') = 'y' 
	SELECT @stmt = @stmt + ' AND prc.monetary_value IS NOT NULL '

IF @process_owner  IS NOT NULL 
	SELECT @stmt = @stmt + ' AND pch.process_owner = ''' + CAST(@process_owner AS VARCHAR) + ''''
	
IF @risk_owner IS NOT NULL 
	SELECT @stmt = @stmt + ' AND prd.risk_owner = ''' + CAST(@risk_owner AS VARCHAR) + ''''
	
IF @risk_control_id IS NOT NULL
	SELECT @stmt = @stmt + ' AND prc.risk_control_id = ' + CAST(@risk_control_id AS VARCHAR) 

IF @book_id IS NOT NULL
	SELECT @stmt = @stmt + ' AND book.entity_id IN (' + CAST(@book_id AS VARCHAR(MAX)) + ')'
	
IF @mitigateActivity IS NULL 
	SELECT @stmt = @stmt + 'AND prca.force_build in (''n'', ''y'', ''t'') '
ELSE 
	SELECT @stmt = @stmt + 'AND prca.force_build = ''m'' '

IF @risk_control_activity_id IS NOT NULL
BEGIN
	SET @risk_control_activity_ids = REPLACE(@risk_control_activity_id, '|', ',')
	SELECT @stmt = @stmt + ' AND prca.risk_control_activity_id in(' + @risk_control_activity_ids  +')'
END

IF @source_column IS NOT NULL
BEGIN
	SELECT @stmt = @stmt + ' AND prca.source_column = ''' + @source_column + ''''
END

IF @source_id IS NOT NULL
BEGIN
	SELECT @stmt = @stmt + ' AND prca.source_id = ' + CAST(@source_id AS VARCHAR(10)) + ''
END

IF @source IS NOT NULL
BEGIN
	SELECT @stmt = @stmt + ' AND prca.source = ''' + @source + ''''
END

exec spa_print @stmt
EXEC (@stmt)
