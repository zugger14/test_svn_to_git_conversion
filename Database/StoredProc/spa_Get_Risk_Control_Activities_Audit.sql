
IF OBJECT_ID(N'[dbo].[spa_Get_Risk_Control_Activities_Audit]', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_Get_Risk_Control_Activities_Audit]
GO 

CREATE PROC [dbo].[spa_Get_Risk_Control_Activities_Audit]
	@sub_id AS VARCHAR(50),
	@user_login_id AS VARCHAR(50) = NULL,
	@as_of_date_from AS VARCHAR(20),
	@as_of_date_to AS VARCHAR(20) = NULL,
	@run_frequency AS VARCHAR(20) = NULL,
	@risk_priority AS VARCHAR(20) = NULL,
	@role_id AS VARCHAR(20) = NULL,
	@process_number VARCHAR(50) = NULL,
	@risk_description_id INT = NULL,
	@activity_category_id INT = NULL,
	@who_for INT = NULL,
	@where INT = NULL,
	@why INT = NULL,
	@activity_area INT = NULL,
	@activity_sub_area INT = NULL,
	@activity_action INT = NULL,
	@activity_desc VARCHAR(250) = NULL,
	@control_type INT = NULL,
	@montetory_value_defined VARCHAR(1) = 'n',
	@process_owner VARCHAR(50) = NULL,
	@risk_owner VARCHAR(50) = NULL,
	@memo VARCHAR(250) = NULL,
	@strategy_id VARCHAR(250) = NULL,
	@book_id VARCHAR(250) = NULL,
	@source VARCHAR(200) = NULL,
	@source_column VARCHAR(200) = NULL,
	@source_id INT = NULL	
AS

SET NOCOUNT ON

DECLARE @sql_stmt VARCHAR(8000)

CREATE TABLE #h_users (
	user_login_id     VARCHAR(50) COLLATE DATABASE_DEFAULT,
	reports_to_user_login_id  VARCHAR(50) COLLATE DATABASE_DEFAULT NULL
)

IF @user_login_id IS NOT NULL
BEGIN
	INSERT #h_users
  EXEC spa_get_hierarchy_users @user_login_id
END  
ELSE
BEGIN
	INSERT INTO #h_users
	SELECT user_login_id, NULL
	FROM application_users
END  

IF @as_of_date_to IS NULL AND @as_of_date_from IS NOT NULL
  SET @as_of_date_to = @as_of_date_from 

SET @sql_stmt = 'SELECT 
					atd.logical_table_name [Source],
					prca.source_id [ID],  
					(CAST(prc.risk_control_id AS VARCHAR(10)) + ''- '' + DBO.FNAGetActivityName(prc.risk_control_id)) AS Activity,
					prca.comments [Details], 
					dbo.FNADateformat(prca.as_of_date) As [Run Date],
					ps.code as [Prior Status], cs.code as [Current Status], 
					prcau.activity_desc as [Action], 
					CASE WHEN pUser.user_f_name IS NOT NULL THEN '' '' + ISNULL(pUser.user_l_name, '''') + '' '' + ISNULL(pUser.user_f_name, '''') + '' '' + ISNULL(pUser.user_m_name, '''') ELSE '''' END  AS [By Who], 
					dbo.FNADateTimeFormat(prcau.create_ts, 1) AS [Time Stamp]
				FROM process_risk_controls_activities_audit prcau
				INNER JOIN process_risk_controls_activities prca ON  prca.risk_control_id = prcau.risk_control_id AND prca.risk_control_activity_id = prcau.risk_control_activity_id
				INNER JOIN process_risk_controls prc ON  prc.risk_control_id = prcau.risk_control_id
				LEFT JOIN portfolio_hierarchy book ON  book.entity_id = prc.fas_book_id
				LEFT JOIN portfolio_hierarchy stra ON  stra.entity_id = book.parent_entity_id
				LEFT JOIN portfolio_hierarchy sub ON  sub.entity_id = stra.parent_entity_id
				INNER JOIN process_risk_description prd ON  prc.risk_description_id = prd.risk_description_id
				INNER JOIN process_control_header pch ON  prd.process_id = pch.process_id
				INNER JOIN static_data_value ps ON  ps.value_id = prcau.control_prior_status
				INNER JOIN static_data_value cs ON  cs.value_id = prcau.control_new_status
				LEFT JOIN application_users pUser ON  pUser.user_login_id = prcau.create_user
				LEFT JOIN static_data_value area ON  area.value_id = prc.activity_area_id
				LEFT JOIN static_data_value sarea ON  sarea.value_id = prc.activity_sub_area_id
				LEFT JOIN static_data_value [action] ON  [action].value_id = prc.activity_action_id 
				LEFT JOIN alert_table_definition atd ON atd.physical_table_name = ISNULL(prcau.source, prca.source)
				WHERE 1 =1 
                '
                
IF @as_of_date_from IS NOT NULL
	SET @sql_stmt = @sql_stmt + ' AND CONVERT(VARCHAR(10), prcau.as_of_date, 120) >= ''' + @as_of_date_from + '''' 

IF @as_of_date_to IS NOT NULL 
	SET @sql_stmt = @sql_stmt + ' AND CONVERT(VARCHAR(10), prcau.as_of_date, 120) <= ''' + @as_of_date_to + ''''
	
IF @user_login_id IS NOT NULL
	SET @sql_stmt = @sql_stmt + ' AND (prc.perform_role in ( SELECT DISTINCT asr.role_id
															FROM application_security_role asr,
																 application_role_user aru
															WHERE  role_type_value_id = 4
															AND aru.role_id = asr.role_id
															AND aru.user_login_id IN (SELECT user_login_id FROM #h_users))
								OR prc.perform_user = ''' + @user_login_id + ''')'

IF @run_frequency IS NOT NULL
BEGIN
	SET @sql_stmt = @sql_stmt + ' AND prc.run_frequency = ' + @run_frequency
END

IF @risk_priority IS NOT NULL
BEGIN
	SET @sql_stmt = @sql_stmt + ' AND prd.risk_priority = ' + @risk_priority
END

IF @sub_id IS NOT NULL
	SET @sql_stmt = @sql_stmt + ' AND sub.entity_id IN (' + @sub_id + ')'
	
IF @strategy_id IS NOT NULL
	SET @sql_stmt = @sql_stmt + ' AND stra.entity_id IN (' + @strategy_id + ')'
	
IF @book_id IS NOT NULL
	SET @sql_stmt = @sql_stmt + ' AND book.entity_id IN (' + @book_id + ')'

IF @role_id IS NOT NULL 
BEGIN
	SET @sql_stmt = @sql_stmt + ' AND prc.perform_role = ' + @role_id
END

If @process_number IS NOT NULL 
BEGIN
	SET @sql_stmt = @sql_stmt + + ' AND pch.process_number = ''' + @process_number + ''''
END

IF @risk_description_id IS NOT NULL
BEGIN
	SET @sql_stmt = @sql_stmt + ' AND prd.risk_description_id = ' + CAST(@risk_description_id AS VARCHAR(10))
END

IF @activity_category_id IS NOT NULL
  SET @sql_stmt = @sql_stmt + ' AND prc.activity_category_id = ''' + CAST(@activity_category_id AS VARCHAR(10)) + ''''

IF @who_for IS NOT NULL
  SET @sql_stmt = @sql_stmt + ' AND prc.activity_who_for_id = ''' + CAST(@who_for AS VARCHAR(10)) + ''''

IF @where IS NOT NULL
  SET @sql_stmt = @sql_stmt + ' AND prc.where_id = ''' + CAST(@where AS VARCHAR(10)) + ''''

IF @why IS NOT NULL
  SET @sql_stmt = @sql_stmt + ' AND prc.control_objective = ''' + CAST(@why AS VARCHAR(10)) + ''''

IF @activity_area IS NOT NULL
  SET @sql_stmt = @sql_stmt + ' AND prc.activity_area_id = ''' + CAST(@activity_area AS VARCHAR(10)) + ''''

IF @activity_sub_area IS NOT NULL
  SET @sql_stmt = @sql_stmt + ' AND prc.activity_sub_area_id = ''' + CAST(@activity_sub_area AS VARCHAR(10)) + ''''

IF @activity_action IS NOT NULL
  SET @sql_stmt = @sql_stmt + ' AND prc.activity_action_id = ''' + CAST(@activity_action AS VARCHAR(10)) + ''''

IF @activity_desc IS NOT NULL
  SET @sql_stmt = @sql_stmt + ' AND (isnull(area.code + '' > '', '''') + isnull(sarea.code + '' > '', '''')  + 
								ISNULL(action.code + '' > '', '''') +
								ISNULL(prc.risk_control_description, '''')) LIKE ''%' + @activity_desc + '%'''

IF @control_type IS NOT NULL
  SET @sql_stmt = @sql_stmt + ' AND prc.control_type = ''' + CAST(@control_type AS VARCHAR(10)) + ''''
	
IF ISNULL(@montetory_value_defined, 'n') = 'y' 
	SET @sql_stmt = @sql_stmt + ' AND prc.monetary_value IS NOT NULL '

IF @process_owner IS NOT NULL 
	SET @sql_stmt = @sql_stmt + ' AND pch.process_owner = ''' + @process_owner + ''''
	
IF @risk_owner IS NOT NULL 
	SET @sql_stmt = @sql_stmt + ' AND prd.risk_owner = ''' + @risk_owner + ''''

IF @memo IS NOT NULL
	SET @sql_stmt = @sql_stmt + ' AND prcau.activity_desc like  ''%' + @memo + '%'''
	
IF @source_column IS NOT NULL
BEGIN
	SELECT @sql_stmt = @sql_stmt + ' AND prcau.source_column = ''' + @source_column + ''''
END

IF @source_id IS NOT NULL
BEGIN
	SELECT @sql_stmt = @sql_stmt + ' AND prcau.source_id = ' + CAST(@source_id AS VARCHAR(10)) + ''
END

IF @source IS NOT NULL
BEGIN
	IF @source IN ('source_deal_header', 'source_deal_detail')
		SET @source = 'source_deal_header''' + ',''source_deal_detail'
		
	SELECT @sql_stmt = @sql_stmt + ' AND prcau.source IN (''' + @source + ''')'
END				

SET @sql_stmt = @sql_stmt + ' ORDER BY prcau.risk_control_id, prcau.as_of_date, risk_control_activity_audit_id desc'

EXEC spa_print @sql_stmt
EXEC (@sql_stmt)




