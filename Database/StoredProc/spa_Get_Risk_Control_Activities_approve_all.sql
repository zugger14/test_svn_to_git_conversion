
/****** Object:  StoredProcedure [dbo].[spa_Get_Risk_Control_Activities_approve_all]    Script Date: 10/17/2008 10:20:42 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_Get_Risk_Control_Activities_approve_all]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_Get_Risk_Control_Activities_approve_all]


GO
/****** Object:  StoredProcedure [dbo].[spa_Get_Risk_Control_Activities_approve_all]    Script Date: 10/17/2008 10:20:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[spa_Get_Risk_Control_Activities_approve_all]
	@user_login_id As varchar(50),
	@as_of_date As varchar(20) = NULL,
	@sub_id As varchar(250) = NULL ,
	@run_frequency As varchar(20) = NULL ,
	@risk_priority As varchar(20) = NULL ,
	@role_id As varchar(20) = NULL ,
	@unapporved_flag As char = NULL ,
	@call_type As Int = NULL ,
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
	@as_of_date_to As varchar(20)=null,
    @activity_mode char(1)=null,
	@img_path varchar(5000) = null
As

SET NOCOUNT ON
DECLARE @where_stmt AS varchar(20)
DECLARE @and_stmt As varchar(20)
DECLARE @sql_stmt As varchar(8000)
DECLARE @sql_stmt0 As varchar(8000)
DECLARE @sql_stmt2 As varchar(8000)
DECLARE @as_of_date_sql_stmt As varchar(8000)
DECLARE @function_id As INT

declare @run char(1)
DECLARE @control_activity_stmt varchar(500)
DECLARE @penalty_stmt varchar(5000)


If @get_counts IS NULL
	set @get_counts = 0

--If @pre_runs  is null then exception are desired ... check previous runs dates
DECLARE @pre_runs varchar 
SET @pre_runs = '0'


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
	SELECT DISTINCT 
	prca.risk_control_activity_id [Instance ID], 
	prca.risk_control_id [ID],
	dbo.FNADateFormat(prca.as_of_date) as  [Date],
--	isnull(sub.entity_name + ''/'' + stra.entity_name + ''/'' + book.entity_name, '''') as [Subsidiary],
	dbo.FNAgetSubsidiary(prc.fas_book_id, ''a'') [Subsidiary],
	dbo.FNAComplianceHyperlink(''a'',10111100,asrP.role_name, cast(prc.perform_role as varchar),default,default,default,default,default,default) [Role],
	ISNULL(rf.code, ''One time activity'') [Frequency],
	rp.code  [Priority],
	prc.requires_proof  [Proof],
	case when (cast(isnull(prca.control_status, 725) as varchar) <> 729 and CASE when (prca.exception_date < getdate()) then 1 else 0 END > 0) then
		''<IMG SRC=' + @img_path + '/adiha_pm_html/process_controls/flag.jpg>'' + '' '' + 
		dbo.FNAComplianceHyperlink(''b'',10101125,' + @control_activity_stmt + ',''44'',cast(prca.risk_control_id as varchar),default,default,default,default,default) 
			else
		dbo.FNAComplianceHyperlink(''b'',10101125,' + @control_activity_stmt + ',''44'',cast(prca.risk_control_id as varchar),default,default,default,default,default) end  [Activity],
	dbo.FNAComplianceHyperlink(''b'',367,ast.code, cast(prca.risk_control_activity_id as varchar),''''+dbo.FNAGetSQLStandardDate(prca.as_of_date)+'''',default,default,default,default,default)  [Status], '
	+  @penalty_stmt + ' [Penalty/Fees]
	/*
	dbo.FNAComplianceHyperlink(''a'',368, ''<IMG SRC=' + @img_path + '/adiha_pm_html/process_controls/steps.jpg>'', cast(prca.risk_control_id as varchar),default,default,default,default,default,default)  [Steps],
	CASE 
		WHEN (prc.requires_proof=''y'') 
			THEN
				(dbo.FNAComplianceHyperlink(''c'',10101125,''<IMG SRC=' + @img_path + '/adiha_pm_html/process_controls/doc.jpg>'',cast(an1.notes_id as varchar),''dbo.FNAGetSQLStandardDate(prca.as_of_date)'','''+@run+''',default,default,default,default))
			 
			ELSE
					'' ''
	END [Proof]
	*/
	
	FROM 
	process_risk_controls prc 
	JOIN process_risk_controls_activities prca ON prca.risk_control_id = prc.risk_control_id
	JOIN process_risk_controls_dependency prcd on prca.risk_control_id=prcd.risk_control_id
	INNER JOIN static_data_value ast ON ast.value_id = isnull(prca.control_status, 725)
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
	left join application_notes an1 on 
	an1.notes_id = (
					select a.notes_id from 
						(
						select top 1 an.notes_id, pnm.process_risk_control_id, an.update_ts from application_notes an
						join process_notes_map pnm on pnm.notes_id = an.notes_id
						where pnm.process_risk_control_id = prca.risk_control_id order by an.update_ts desc
						) a
					)
	INNER JOIN application_role_user aru ON CAST(aru.role_id AS VARCHAR) LIKE 
				CASE WHEN control_status = 728 and prc.requires_approval = ''y'' THEN ISNULL(CAST(prc.approve_role AS VARCHAR),''%'') END													
					AND aru.user_login_id LIKE 
				CASE WHEN control_status = 728 and prc.requires_approval = ''y'' THEN ISNULL(prc.approve_user,''%'') END	
					
	WHERE prcd.risk_control_id NOT IN (SELECT risk_control_id 
										FROM process_risk_controls_dependency 
										WHERE risk_control_id_depend_on IS NOT NULL ) 
	AND prc.requires_approval = ''y'' 
	AND aru.user_login_id = '''+@user_login_id+'''
	'
	
	SET @sql_stmt = @sql_stmt + 
				' AND (prca.as_of_date BETWEEN CONVERT(DATETIME,''' + CAST(ISNULL(@as_of_date, '1900-01-01') AS VARCHAR) + ''', 102) AND CONVERT(DATETIME,''' + CAST(@as_of_date_to AS VARCHAR) + ''', 102)) '
	
	if(@activity_mode is not null and @activity_mode = 'a')
		set @sql_stmt =  @sql_stmt+ 'AND prca.control_status in (728)'
	else if(@activity_mode is not null and @activity_mode = 'u')
		set @sql_stmt =  @sql_stmt+ 'AND prca.control_status = 728'
	else
		set @sql_stmt =  @sql_stmt+ 'AND prca.control_status in (726, 728, 729)'
	
	-- filters by the user_login_id
--	IF @user_login_id IS NOT NULL AND @call_type IN (1)
--	BEGIN
--	  SET @sql_stmt = @sql_stmt + ' AND prc.perform_role in ( SELECT DISTINCT asr.role_id FROM APPLICATION_SECURITY_ROLE asr, APPLICATION_ROLE_USER aru
--					WHERE role_type_value_id = 4 AND
--					aru.role_id = asr.role_id AND 
--					aru.user_login_id = ''' + @user_login_id + ''')'
--	END
	
	
	IF @risk_description_id IS NOT NULL
	BEGIN
		SET @sql_stmt = @sql_stmt + ' AND prd.risk_description_id = ' + cast(@risk_description_id as varchar)
	END

	IF @run_frequency IS NOT NULL
	BEGIN
		SET @sql_stmt = @sql_stmt + ' AND prc.run_frequency = ' + CAST(@run_frequency AS VARCHAR)
	END

	IF @risk_priority IS NOT NULL
	BEGIN
		SET   @sql_stmt = @sql_stmt + ' AND prd.risk_priority = ' + CAST(@risk_priority AS VARCHAR)
	END


	IF @sub_id IS NOT NULL
		SET   @sql_stmt = @sql_stmt + ' AND sub.entity_id IN (' + CAST(@sub_id AS VARCHAR) + ')'
	IF @strategy_id IS NOT NULL
		SET   @sql_stmt = @sql_stmt + ' AND stra.entity_id IN (' + CAST(@strategy_id AS VARCHAR) + ')'
	IF @book_id IS NOT NULL
		SET   @sql_stmt = @sql_stmt + ' AND book.entity_id IN (' + CAST(@book_id AS VARCHAR) + ')'

	-- ROLES
	IF @role_id IS NOT NULL AND @call_type = 1 
	BEGIN
	SET   @sql_stmt = @sql_stmt + ' AND prc.perform_role = ' + CAST(@role_id AS VARCHAR) 
	END

	If @process_number IS NOT NULL 
	BEGIN
	SET   @sql_stmt = @sql_stmt + + ' AND pch.process_id = ''' + CAST(@process_number AS VARCHAR) + ''''
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
							isnull(prc.risk_control_description, '''')) LIKE ''%' + CAST(@activity_desc AS VARCHAR(MAX))+ '%'''
	If @control_type  IS NOT NULL 
		SET   @sql_stmt = @sql_stmt + + ' AND prc.control_type = ''' + cast(@control_type  as varchar) + ''''
	If isnull(@montetory_value_defined, 'n') = 'y' 
		SET   @sql_stmt = @sql_stmt + + ' AND prc.monetary_value IS NOT NULL '

	If @process_owner  IS NOT NULL 
		SET   @sql_stmt = @sql_stmt + + ' AND pch.process_owner = ''' + CAST(@process_owner AS VARCHAR) + ''''
	If @risk_owner  IS NOT NULL 
		SET   @sql_stmt = @sql_stmt + + ' AND prd.risk_owner = ''' + CAST(@risk_owner AS VARCHAR) + ''''
	if @risk_control_id IS NOT NULL
		SET   @sql_stmt = @sql_stmt + + ' AND prc.risk_control_id = ' + cast(@risk_control_id as varchar) 
	
	exec spa_print @sql_stmt
	
	EXEC (@sql_stmt)

