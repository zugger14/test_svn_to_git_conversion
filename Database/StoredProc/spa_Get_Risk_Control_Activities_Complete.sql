

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_Get_Risk_Control_Activities_Complete]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_Get_Risk_Control_Activities_Complete]

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go
 




-- EXEC spa_Get_Risk_Control_Activities NULL, '2008-09-14', NULL, NULL, NULL, NULL, 'R', 1, NULL, 0

CREATE PROC [dbo].[spa_Get_Risk_Control_Activities_Complete]
	@user_login_id As varchar(50),
	@as_of_date As varchar(20) = NULL,
	@sub_id As varchar(250),
	@run_frequency As varchar(20),
	@risk_priority As varchar(20),
	@role_id As varchar(20),
	@activityStatus As INT,
	@call_type As Int,
	@get_counts int = 0,
	@process_number varchar(50) = NULL,
--	@process_id int = null,
    @risk_description_id int = null,
	@activity_category_id int=null,
	@who_for int=null,
	@where int=null,
	@why int=null,
	@activity_area int=null,
	@activity_sub_area int=null,
	@activity_action int=null,
	@activity_desc varchar(250)=null,
	@control_type int=null,
	@montetory_value_defined varchar(1)='n',
	@process_owner varchar(50)=NULL,
	@risk_owner varchar(50)=NULL,
	@risk_control_id int = NULL,
	@strategy_id varchar(250)=NULL,
	@book_id varchar(1000)=NULL,
	@process_table varchar(100)=null,
	@process_table_insert_or_create varchar(100)='c', --'c' creates the table and 'i' just inserts in the same table (table alredy created)
    @as_of_date_to  varchar(200)=null,
    @next_action  INT =null,
	@img_path varchar(5000) = null,
	@force_build as char(1)='n'						-- 'y' when forcefully created and 'n' to perform activity at Perform compliance activities
   
    
	
As

SET NOCOUNT ON



DECLARE @sql_stmt As varchar(8000)
DECLARE @run char(1)

DECLARE @control_activity_stmt varchar(500)
DECLARE @penalty_stmt varchar(5000)

If @get_counts IS NULL
	set @get_counts = 0

--If @pre_runs  is null then exception are desired ... check previous runs dates
DECLARE @pre_runs varchar 
SET @pre_runs = '0'

if @as_of_date_to is null 
	set @as_of_date_to = @as_of_date

IF @force_build = 'y'
BEGIN 

SET @control_activity_stmt = 
			'isnull(''('' + prr.requirement_no + '') '', '''') + 	
			isnull(area.code + '' > '', '''') + isnull(sarea.code + '' > '', '''')  + 
			isnull(action.code , '''') +
			isnull('' > '' + prc.risk_control_description, '''')'
			
	SET @sql_stmt = '
		select DISTINCT 
		[risk_control_id] ''Risk Control ID'',	
		isnull(sub.entity_name + ''/'' + stra.entity_name + ''/'' + book.entity_name, '''') [Subsidiary] ,
		asrP.role_name AS [Performer Role],	
		asrA.role_name AS [Approver Role],	
		ISNULL(rf.code, ''One time activity'') AS ''Run Frequency'',	
		rp.code AS  ''Risk Priority'',
		ct.code AS ''Control Type'',
		pch.process_number + '' ('' + CAST(prd.risk_description_id AS varchar) + '' - '' + prd.risk_description + '')'' AS ''Risk Description'', '
		+ @control_activity_stmt + ' AS ''Control Activity'',
		dbo.FNADateFormat(dbo.FNANextInstanceCreationDate(prc.risk_control_id)) ''As Of Date'',
		pch.process_number As ''Process Number'',
		Case prc.requires_proof When ''n'' then ''No'' when ''y'' then ''Yes'' End   ''Requires Proof?'',
		prc.threshold_days AS ''Threshold Days'',
		dbo.FNADateFormat(dbo.FNAGetSQLStandardDate(DATEADD(dd, prc.threshold_days, dbo.FNANextInstanceCreationDate(prc.risk_control_id)))) AS ''Perform By Date'',
		isnull(prc.requires_approval, ''n'') AS ''Requires Approval?''	
		FROM         
		process_risk_controls prc 
		LEFT OUTER JOIN portfolio_hierarchy book ON book.entity_id = prc.fas_book_id 
		LEFT OUTER JOIN portfolio_hierarchy stra ON stra.entity_id = book.parent_entity_id 
		LEFT OUTER JOIN portfolio_hierarchy sub ON sub.entity_id = stra.parent_entity_id 
		LEFT OUTER JOIN static_data_value ct ON ct.value_id = prc.control_type 		
		LEFT OUTER JOIN static_data_value rf ON prc.run_frequency = rf.value_id 
		LEFT OUTER JOIN application_security_role asrP ON prc.perform_role = asrP.role_id 
		LEFT OUTER JOIN application_security_role asrA ON prc.approve_role = asrA.role_id 
		INNER JOIN process_risk_description prd ON prc.risk_description_id = prd.risk_description_id 
		INNER JOIN static_data_value rp ON rp.value_id = prd.risk_priority 
		INNER JOIN process_control_header pch ON prd.process_id = pch.process_id 
		LEFT OUTER JOIN static_data_value area on area.value_id = prc.activity_area_id 
		LEFT OUTER JOIN static_data_value sarea on sarea.value_id = prc.activity_sub_area_id 
		LEFT OUTER JOIN static_data_value action on action.value_id = prc.activity_action_id 
		LEFT OUTER JOIN process_requirements_revisions prr on prr.requirements_revision_id = prc.requirements_revision_id 
		LEFT OUTER JOIN application_role_user aru ON 
				CAST(aru.role_id AS VARCHAR) LIKE ISNULL(CAST(prc.perform_role AS VARCHAR),''%'')
								AND aru.user_login_id LIKE ISNULL(prc.perform_user,''%'')
		WHERE 1=1 
		AND ISNULL(prc.perform_user,aru.user_login_id) = '''+@user_login_id+'''
		AND prc.notificationOnly<>''y''	
		'
	
--	IF @user_login_id IS NOT NULL AND @call_type IN (1)
--	BEGIN
--	  SET @sql_stmt = @sql_stmt + ' AND prc.perform_role in ( SELECT DISTINCT asr.role_id FROM APPLICATION_SECURITY_ROLE asr, APPLICATION_ROLE_USER aru
--					WHERE role_type_value_id = 4 AND
--					aru.role_id = asr.role_id AND 
--					aru.user_login_id = ''' + @user_login_id + ''')'
--	END
	
	/* Uncomment Below lines for @call type 2,3,4*/
	/*
	IF @user_login_id IS NOT NULL AND @call_type IN (3, 4)
	BEGIN
	  SET @sql_stmt = @sql_stmt + ' AND prc.perform_role in ( SELECT DISTINCT asr.role_id FROM APPLICATION_SECURITY_ROLE asr, APPLICATION_ROLE_USER aru
					WHERE role_type_value_id = 4 AND
					aru.role_id = asr.role_id AND 
					aru.user_login_id IN (select user_login_id from #h_users))'
	-- 				aru.user_login_id IN (''urbaral''))'
	END
	If @user_login_id IS NOT NULL AND @call_type = 2
	BEGIN
	  SET @sql_stmt = @sql_stmt + ' AND prc.approve_role in ( SELECT asr.role_id FROM APPLICATION_SECURITY_ROLE asr, APPLICATION_ROLE_USER aru
		WHERE role_type_value_id = 4 AND
		aru.role_id = asr.role_id AND 
		aru.user_login_id = ''' + @user_login_id  + ''')'
	END
	*/
	
	IF @risk_description_id IS NOT NULL
	BEGIN
		SET @sql_stmt = @sql_stmt + ' AND prd.risk_description_id = ' + cast(@risk_description_id as varchar)
	END

	IF @run_frequency IS NOT NULL
	BEGIN
		SET @sql_stmt = @sql_stmt + ' AND prc.run_frequency = ' + @run_frequency
	END

	IF @risk_priority IS NOT NULL
	BEGIN
		SET   @sql_stmt = @sql_stmt + ' AND prd.risk_priority = ' + @risk_priority
	END


	IF @sub_id IS NOT NULL
		SET   @sql_stmt = @sql_stmt + ' AND sub.entity_id IN (' + @sub_id + ')'
	IF @strategy_id IS NOT NULL
		SET   @sql_stmt = @sql_stmt + ' AND stra.entity_id IN (' + @strategy_id + ')'
	IF @book_id IS NOT NULL
		SET   @sql_stmt = @sql_stmt + ' AND book.entity_id IN (' + @book_id + ')'

	-- ROLES
	IF @role_id IS NOT NULL AND @call_type = 1 
	BEGIN
	SET   @sql_stmt = @sql_stmt + ' AND prc.perform_role = ' + @role_id
	END
	
	If @process_number IS NOT NULL 
	BEGIN
	SET   @sql_stmt = @sql_stmt + + ' AND pch.process_id = ''' + @process_number + ''''
	END

	If @activity_category_id IS NOT NULL 
		SET   @sql_stmt = @sql_stmt + + ' AND prc.activity_category_id = ''' + cast(@activity_category_id as varchar) + ''''
	If @who_for  IS NOT NULL 
		SET   @sql_stmt = @sql_stmt + + ' AND prc.activity_who_for_id = ''' + cast(@who_for  as varchar) + ''''
	If @where  IS NOT NULL 
		SET   @sql_stmt = @sql_stmt + + ' AND prc.where_id = ''' + cast(@where  as varchar) + ''''
	If @why  IS NOT NULL 
		SET   @sql_stmt = @sql_stmt + + ' AND prc.control_objective = ''' + cast(@why  as varchar) + ''''
	If @activity_area  IS NOT NULL 
		SET   @sql_stmt = @sql_stmt + + ' AND prc.activity_area_id = ''' + cast(@activity_area  as varchar) + ''''
	If @activity_sub_area  IS NOT NULL 
		SET   @sql_stmt = @sql_stmt + + ' AND prc.activity_sub_area_id = ''' + cast(@activity_sub_area  as varchar) + ''''
	If @activity_action  IS NOT NULL 
		SET   @sql_stmt = @sql_stmt + + ' AND prc.activity_action_id = ''' + cast(@activity_action  as varchar) + ''''
	If @activity_desc  IS NOT NULL 
		SET   @sql_stmt = @sql_stmt + + ' AND (isnull(area.code + '' > '', '''') + isnull(sarea.code + '' > '', '''')  + 
							isnull(action.code + '' > '', '''') +
							isnull(prc.risk_control_description, '''')) LIKE ''%' + @activity_desc + '%'''
	If @control_type  IS NOT NULL 
		SET   @sql_stmt = @sql_stmt + + ' AND prc.control_type = ''' + cast(@control_type  as varchar) + ''''
	If isnull(@montetory_value_defined, 'n') = 'y' 
		SET   @sql_stmt = @sql_stmt + + ' AND prc.monetary_value IS NOT NULL '

	If @process_owner  IS NOT NULL 
		SET   @sql_stmt = @sql_stmt + + ' AND pch.process_owner = ''' + @process_owner + ''''
	If @risk_owner  IS NOT NULL 
		SET   @sql_stmt = @sql_stmt + + ' AND prd.risk_owner = ''' + @risk_owner + ''''
	if @risk_control_id IS NOT NULL
		SET   @sql_stmt = @sql_stmt + + ' AND prc.risk_control_id = ' + cast(@risk_control_id as varchar) 
	
	SET @sql_stmt = @sql_stmt + ' AND (dbo.FNANextInstanceCreationDate(prc.risk_control_id) 
				BETWEEN CONVERT(DATETIME,''' + ISNULL(@as_of_date, '1900-01-01') + ''', 102) AND CONVERT(DATETIME,''' + @as_of_date_to + ''', 102)) '

	exec spa_print @sql_stmt
	
	EXEC (@sql_stmt)
	
END 				
ELSE IF @force_build = 'n'
BEGIN 

set @run = 'r'

 
set @penalty_stmt = 
			' 
			cast(case when (isnull(prca.monetary_value, prc.monetary_value) is not null and (prca.as_of_date < case when (isnull(prca.control_status, 525) IN (728, 729)) then prca.update_ts else getdate() end) and prc.monetary_value_frequency_id is not null) then
			case prc.monetary_value_frequency_id when 700 then datediff(dd,prca.as_of_date, case when (isnull(prca.control_status, 525) IN (728, 729)) then prca.update_ts else getdate() end)
			when 701 then datediff(ww,prca.as_of_date, case when (isnull(prca.control_status, 525) IN (728, 729)) then prca.update_ts else getdate() end) + 1
			when 703 then datediff(mm,prca.as_of_date, case when (isnull(prca.control_status, 525) IN (728, 729)) then prca.update_ts else getdate() end) + 1
			when 704 then datediff(qq,prca.as_of_date, case when (isnull(prca.control_status, 525) IN (728, 729)) then prca.update_ts else getdate() end) + 1
			when 705 then (datediff(yy,prca.as_of_date, case when (isnull(prca.control_status, 525) IN (728, 729)) then prca.update_ts else getdate() end)/2) + 1
			when 706 then datediff(yy,prca.as_of_date, case when (isnull(prca.control_status, 525) IN (728, 729)) then prca.update_ts else getdate() end) + 1
			else 1 end * coalesce(prca.monetary_value, prc.monetary_value, 0)			
			else coalesce(prca.monetary_value, prc.monetary_value, 0) end as float)
			'

SET @control_activity_stmt = 
			'isnull(''('' + prr.requirement_no + '') '', '''') + 	
			isnull(area.code + '' > '', '''') + isnull(sarea.code + '' > '', '''')  + 
			isnull(action.code , '''') +
			isnull('' > '' + prc.risk_control_description, '''')'

SET @sql_stmt = 
	'
	SELECT  DISTINCT 
	prca.risk_control_activity_id [Risk Control Activity ID], 
	prca.risk_control_id [ID],
	isnull(sub.entity_name + ''/'' + stra.entity_name + ''/'' + book.entity_name, '''') as [Subsidiary],
	dbo.FNAComplianceHyperlink(''a'',10111100,asrP.role_name, cast(prc.perform_role as varchar),default,default,default,default,default,default) [Role],
	ISNULL(rf.code, ''One time activity'') [Frequency],
	/*
	rp.code  [Priority],
	*/
	prc.requires_proof  [Proof],
	case when (cast(isnull(prca.control_status, 725) as varchar) <> 729 and CASE when (prca.exception_date < getdate()) then 1 else 0 END > 0) then
		''<IMG SRC=' + @img_path + '/adiha_pm_html/process_controls/flag.jpg>'' + '' '' + 
		dbo.FNAComplianceHyperlink(''b'',10101125,' + @control_activity_stmt + ',''44'',cast(prca.risk_control_id as varchar),default,default,default,default,default) 
			else
		dbo.FNAComplianceHyperlink(''b'',10101125,' + @control_activity_stmt + ',''44'',cast(prca.risk_control_id as varchar),default,default,default,default,default) end  [Activity],
	dbo.FNAComplianceHyperlink(''b'',367,ast.code, cast(prca.risk_control_id as varchar),''''+dbo.FNAGetSQLStandardDate(prca.as_of_date)+'''',default,default,default,default,default)  [Status], '
	+  @penalty_stmt + ' [Penalty/Fees],
	(dbo.FNADateFormat(prca.as_of_date) + '' <I>(By: '' + dbo.FNADateFormat(prca.exception_date) + '')</I>'') as  [Date],
	dbo.FNAComplianceHyperlink(''a'',368, ''<IMG SRC=' + @img_path + '/adiha_pm_html/process_controls/steps.jpg>'', cast(prca.risk_control_id as varchar),default,default,default,default,default,default)  [Steps],
	CASE 
		WHEN (prc.requires_proof=''y'') 
			THEN
				(dbo.FNAComplianceHyperlink(''c'',10101125,''<IMG SRC=' + @img_path + '/adiha_pm_html/process_controls/doc.jpg>'',cast(an1.notes_id as varchar),''''+dbo.FNAGetSQLStandardDate(prca.as_of_date)+'''','''+@run+''',default,default,default,default))
			 
			ELSE
					'' ''
	END [Proof],
	CASE WHEN
		(
		SELECT COUNT(prcd.risk_control_id) 
		FROM process_risk_controls_dependency prcd 
			JOIN process_risk_controls_dependency prcd1 on prcd1.risk_control_id_depend_on = prcd.risk_control_dependency_id
			WHERE prcd.risk_control_id = prca.risk_control_id
		) > 0 then ''Yes'' else ''No'' end as ''Has Dependency'' 
	
	FROM 
	process_risk_controls prc 
	JOIN process_risk_controls_activities prca ON prca.risk_control_id = prc.risk_control_id
	JOIN process_risk_controls_dependency prcd on prca.risk_control_id=prcd.risk_control_id
	INNER JOIN static_data_value ast ON ast.value_id = isnull(prca.control_status, 725)
	LEFT OUTER JOIN portfolio_hierarchy book ON book.entity_id = prc.fas_book_id 
	LEFT OUTER JOIN portfolio_hierarchy stra ON stra.entity_id = book.parent_entity_id 
	LEFT OUTER JOIN portfolio_hierarchy sub ON sub.entity_id = stra.parent_entity_id 
	LEFT OUTER  JOIN static_data_value ct ON ct.value_id = prc.control_type 
	LEFT OUTER JOIN static_data_value rf ON prc.run_frequency = rf.value_id 
	LEFT OUTER JOIN application_security_role asrP ON prc.perform_role = asrP.role_id 
	LEFT OUTER JOIN application_security_role asrA ON prc.approve_role = asrA.role_id 
	INNER JOIN process_risk_description prd ON prc.risk_description_id = prd.risk_description_id 
	INNER JOIN static_data_value rp ON rp.value_id = prd.risk_priority 
	INNER JOIN process_control_header pch ON prd.process_id = pch.process_id 
	LEFT OUTER JOIN static_data_value area on area.value_id = prc.activity_area_id 
	LEFT OUTER JOIN static_data_value sarea on sarea.value_id = prc.activity_sub_area_id 
	LEFT OUTER JOIN static_data_value action on action.value_id = prc.activity_action_id 
	LEFT OUTER JOIN process_requirements_revisions prr on prr.requirements_revision_id = prc.requirements_revision_id
	left join application_notes an1 on 
	an1.notes_id = (
					select a.notes_id from 
						(
						select top 1 an.notes_id, pnm.process_risk_control_id, an.update_ts from application_notes an
						join process_notes_map pnm on pnm.notes_id = an.notes_id
						where pnm.process_risk_control_id = prca.risk_control_id order by an.update_ts desc
						) a
					)
	LEFT OUTER JOIN application_role_user aru ON 
				CAST(aru.role_id AS VARCHAR) LIKE ISNULL(CAST(prc.perform_role AS VARCHAR),''%'')
								AND aru.user_login_id LIKE ISNULL(prc.perform_user,''%'')
	WHERE prcd.risk_control_id NOT IN (SELECT risk_control_id 
										FROM process_risk_controls_dependency 
										WHERE risk_control_id_depend_on IS NOT NULL ) 

	AND ISNULL(prc.perform_user,aru.user_login_id) = '''+@user_login_id+'''	
	AND prc.notificationOnly<>''y''									
	'
	
	SET @sql_stmt = @sql_stmt + 
				' AND (prca.as_of_date BETWEEN CONVERT(DATETIME,''' + ISNULL(@as_of_date , '1900-01-01') + ''', 102) AND CONVERT(DATETIME,''' + @as_of_date_to + ''', 102)) '
	
	-- filters by the user_login_id
--	IF @user_login_id IS NOT NULL AND @call_type IN (1)
--	BEGIN
--	  SET @sql_stmt = @sql_stmt + ' AND prc.perform_role in ( SELECT DISTINCT asr.role_id FROM APPLICATION_SECURITY_ROLE asr, APPLICATION_ROLE_USER aru
--					WHERE role_type_value_id = 4 AND
--					aru.role_id = asr.role_id AND 
--					aru.user_login_id = ''' + @user_login_id + ''')'
--	END
	/* Uncomment Below lines for @call type 2,3,4*/
	/*
	IF @user_login_id IS NOT NULL AND @call_type IN (3, 4)
	BEGIN
	  SET @sql_stmt = @sql_stmt + ' AND prc.perform_role in ( SELECT DISTINCT asr.role_id FROM APPLICATION_SECURITY_ROLE asr, APPLICATION_ROLE_USER aru
					WHERE role_type_value_id = 4 AND
					aru.role_id = asr.role_id AND 
					aru.user_login_id IN (select user_login_id from #h_users))'
	-- 				aru.user_login_id IN (''urbaral''))'
	END
	If @user_login_id IS NOT NULL AND @call_type = 2
	BEGIN
	  SET @sql_stmt = @sql_stmt + ' AND prc.approve_role in ( SELECT asr.role_id FROM APPLICATION_SECURITY_ROLE asr, APPLICATION_ROLE_USER aru
		WHERE role_type_value_id = 4 AND
		aru.role_id = asr.role_id AND 
		aru.user_login_id = ''' + @user_login_id  + ''')'
	END
	*/
	--select @sql_stmt
	IF @risk_description_id IS NOT NULL
	BEGIN
		SET @sql_stmt = @sql_stmt + ' AND prd.risk_description_id = ' + cast(@risk_description_id as varchar)
	END

	-- IF @process_id IS NOT NULL
	-- BEGIN
	-- 	SET @sql_stmt = @sql_stmt + ' AND pch.process_id = ' + cast(@process_id as varchar)
	-- END



	IF @run_frequency IS NOT NULL
	BEGIN
		SET @sql_stmt = @sql_stmt + ' AND prc.run_frequency = ' + @run_frequency
	END

	IF @risk_priority IS NOT NULL
	BEGIN
		SET   @sql_stmt = @sql_stmt + ' AND prd.risk_priority = ' + @risk_priority
	END


	IF @sub_id IS NOT NULL
		SET   @sql_stmt = @sql_stmt + ' AND sub.entity_id IN (' + @sub_id + ')'
	IF @strategy_id IS NOT NULL
		SET   @sql_stmt = @sql_stmt + ' AND stra.entity_id IN (' + @strategy_id + ')'
	IF @book_id IS NOT NULL
		SET   @sql_stmt = @sql_stmt + ' AND book.entity_id IN (' + @book_id + ')'

	-- ROLES
	IF @role_id IS NOT NULL AND @call_type = 1 
	BEGIN
	SET   @sql_stmt = @sql_stmt + ' AND prc.perform_role = ' + @role_id
	END

	If @process_number IS NOT NULL 
	BEGIN
	SET   @sql_stmt = @sql_stmt + + ' AND pch.process_id = ''' + @process_number + ''''
	END

	If @activity_category_id IS NOT NULL 
		SET   @sql_stmt = @sql_stmt + + ' AND prc.activity_category_id = ''' + cast(@activity_category_id as varchar) + ''''
	If @who_for  IS NOT NULL 
		SET   @sql_stmt = @sql_stmt + + ' AND prc.activity_who_for_id = ''' + cast(@who_for  as varchar) + ''''
	If @where  IS NOT NULL 
		SET   @sql_stmt = @sql_stmt + + ' AND prc.where_id = ''' + cast(@where  as varchar) + ''''
	If @why  IS NOT NULL 
		SET   @sql_stmt = @sql_stmt + + ' AND prc.control_objective = ''' + cast(@why  as varchar) + ''''
	If @activity_area  IS NOT NULL 
		SET   @sql_stmt = @sql_stmt + + ' AND prc.activity_area_id = ''' + cast(@activity_area  as varchar) + ''''
	If @activity_sub_area  IS NOT NULL 
		SET   @sql_stmt = @sql_stmt + + ' AND prc.activity_sub_area_id = ''' + cast(@activity_sub_area  as varchar) + ''''
	If @activity_action  IS NOT NULL 
		SET   @sql_stmt = @sql_stmt + + ' AND prc.activity_action_id = ''' + cast(@activity_action  as varchar) + ''''
	If @activity_desc  IS NOT NULL 
		SET   @sql_stmt = @sql_stmt + + ' AND (isnull(area.code + '' > '', '''') + isnull(sarea.code + '' > '', '''')  + 
							isnull(action.code + '' > '', '''') +
							isnull(prc.risk_control_description, '''')) LIKE ''%' + @activity_desc + '%'''
	If @control_type  IS NOT NULL 
		SET   @sql_stmt = @sql_stmt + + ' AND prc.control_type = ''' + cast(@control_type  as varchar) + ''''
	If isnull(@montetory_value_defined, 'n') = 'y' 
		SET   @sql_stmt = @sql_stmt + + ' AND prc.monetary_value IS NOT NULL '

	If @process_owner  IS NOT NULL 
		SET   @sql_stmt = @sql_stmt + + ' AND pch.process_owner = ''' + @process_owner + ''''
	If @risk_owner  IS NOT NULL 
		SET   @sql_stmt = @sql_stmt + + ' AND prd.risk_owner = ''' + @risk_owner + ''''
	if @risk_control_id IS NOT NULL
		SET   @sql_stmt = @sql_stmt + + ' AND prc.risk_control_id = ' + cast(@risk_control_id as varchar) 
	
	--Not completed		
--	If upper(@activityStatus) = 'N'
--		SET @sql_stmt = @sql_stmt + ' AND prca.control_status in (725, 726, 727) '
	If @activityStatus IS NULL 
		SET @sql_stmt = @sql_stmt + ' AND prca.control_status in (725,726,728,729,730,731,733) '
	ELSE 
	BEGIN 
		IF @activityStatus = 734
			SELECT @sql_stmt = @sql_stmt + ' AND prca.mitigatedActivityInstanceId IS NOT NULL AND prca.force_build = ''m'' ' 
		ELSE 
		BEGIN 
			IF @activityStatus = 733
				SELECT @sql_stmt = @sql_stmt + ' AND prca.control_status in (725, 731) AND CAST(dbo.FNADateFormat(GETDATE()) AS DATETIME) > prca.exception_date ' 
			ELSE 
				SELECT @sql_stmt = @sql_stmt + ' AND prca.control_status = ' + CAST(@activityStatus AS VARCHAR) 
		END 
	END 
		
		
		
	IF @next_action = 11001 -- Complete 
	BEGIN 
		set @sql_stmt = @sql_stmt + ' AND   prca.control_status in (725, 726) '
		set @sql_stmt = @sql_stmt + ' AND   prc.requires_proof = ''n'' ' 
--		set @sql_stmt = @sql_stmt + ' AND   prc.mitigation_plan_required = ''n'' '  
	END 
	ELSE IF @next_action = 11002	-- Mitigate
	BEGIN 
		set @sql_stmt = @sql_stmt + ' AND   prc.mitigation_plan_required = ''y'' ' 
		set @sql_stmt = @sql_stmt + ' AND   prca.control_status = 731 '
	END 
	ELSE IF @next_action = 11004	-- Re-process
	BEGIN 
		set @sql_stmt = @sql_stmt + ' AND  prca.control_status in (728, 729) '
	END 
	ELSE IF @next_action = 11005	-- Submit Proof
	BEGIN 
		set @sql_stmt = @sql_stmt + ' AND  (prca.control_status = 725 AND  prc.requires_proof = ''y'')'
		set @sql_stmt = @sql_stmt + ' OR (prca.control_status in (725, 726) AND prc.requires_proof = ''y'' AND prc.requires_approval = ''y'') ' 
--		set @sql_stmt = @sql_stmt + ' OR   CASE when (prca.exception_date < getdate() AND isnull(prc.requires_approval_for_late, ''n'') = ''y'') then ''y'' else ''n'' end  = ''y'') ' 
		 
	END 
	
	exec spa_print @sql_stmt
	
	EXEC (@sql_stmt)

END 			
	