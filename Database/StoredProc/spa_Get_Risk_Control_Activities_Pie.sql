

/****** Object:  StoredProcedure [dbo].[spa_Get_Risk_Control_Activities_Pie]    Script Date: 11/07/2008 12:41:37 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_Get_Risk_Control_Activities_Pie]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_Get_Risk_Control_Activities_Pie]
go

-- EXEC spa_Get_Risk_Control_Activities NULL, @as_of_date, NULL, NULL, NULL, NULL, 'S', 1
create PROC [dbo].[spa_Get_Risk_Control_Activities_Pie]
	@user_login_id As varchar(50),
	@as_of_date As varchar(20),
	@sub_id As varchar(250),
	@run_frequency As varchar(20),
	@risk_priority As varchar(20),
	@role_id As varchar(20),
	@unapporved_flag As char(2),
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
	@book_id varchar(250)=NULL,
	@process_table varchar(100)=null,
	@process_table_insert_or_create varchar(100)='c', --'c' creates the table and 'i' just inserts in the same table (table alredy created)
	@as_of_date_to As varchar(20)=null
	
As

SET NOCOUNT ON

EXEC spa_print @as_of_date_to
--drop table #tempControls

--UNCOMMENT THIS TO TEST 
-- DECLARE @user_login_id As varchar(50)
-- DECLARE @as_of_date As varchar(20)
-- DECLARE @sub_id As varchar(50)
-- DECLARE @run_frequency As varchar(20)
-- DECLARE @risk_priority As varchar(20)
-- DECLARE @role_id As varchar(20)
-- DECLARE @unapporved_flag As char
-- DECLARE @call_type As Int
-- DECLARE @process_number varchar(50)
-- DECLARE @get_counts int
-- DECLARE @process_id int
-- DECLARE @risk_description_id int
-- 
-- --SET @as_of_date = '2006-01-29'
-- SET @as_of_date = '2006-01-15'
-- SET @sub_id = null
-- SET @run_frequency = NULL
-- SET @risk_priority = NULL
-- SET @user_login_id = 'urbaral' 
-- SET @role_id = NULL
-- set @unapporved_flag = 'r'
-- SET @call_type = 1
-- SET @get_counts = 0
-- set @process_number = NULL
-- DROP TABLE #tempControls
-- DROP TABLE #reminder
--UNCOMMENT ABOVE TO TEST


DECLARE @where_stmt AS varchar(20)
DECLARE @and_stmt As varchar(20)
DECLARE @sql_stmt As varchar(8000)
DECLARE @sql_stmt0 As varchar(8000)
DECLARE @sql_stmt2 As varchar(8000)
DECLARE @as_of_date_sql_stmt As varchar(8000)
DECLARE @function_id As Int


If @get_counts IS NULL
	set @get_counts = 0

--If @pre_runs  is null then exception are desired ... check previous runs dates
DECLARE @pre_runs varchar 
SET @pre_runs = '0'
--NOT NEEDED WITH NEW DESIGN/APPROACH
-- if upper(@unapporved_flag) IN ('E', 'T', 'S') 
-- 	SET @pre_runs = '1'

if @as_of_date_to is null OR @unapporved_flag IN ('R', 'S')
	set @as_of_date_to = @as_of_date

CREATE TABLE #h_users
(user_login_id varchar(50) COLLATE DATABASE_DEFAULT,
 reports_to_user_login_id varchar(50) COLLATE DATABASE_DEFAULT null)

-- insert into #users select 'urbaral', NULL
if @user_login_id is not null AND  @call_type IN (3)
	insert #h_users exec spa_get_hierarchy_users  @user_login_id
else if @user_login_id is null AND  @call_type IN (3)
	insert into #h_users select user_login_id, NULL from application_users
-- select * from #users

SET @and_stmt = ''
SET @where_stmt = ' '

CREATE TABLE #tempControls (
	[subsidiary_id] [varchar] (50) COLLATE DATABASE_DEFAULT NOT NULL ,
	[Subsidiary] [varchar] (100) COLLATE DATABASE_DEFAULT  NOT NULL ,
	[perform_role_id] [int] NOT NULL ,
	[PerformRole] [varchar] (50) COLLATE DATABASE_DEFAULT  NOT NULL ,
	[approve_role_id] [int] NOT NULL ,
	[ApproveRole] [varchar] (50) COLLATE DATABASE_DEFAULT  NOT NULL ,
	[run_frequency_id] [int] NOT NULL ,
	[run_frequency] [varchar] (50) COLLATE DATABASE_DEFAULT  NOT NULL ,
	[risk_priority_id] [int] NOT NULL ,
	[risk_priority] [varchar] (50) COLLATE DATABASE_DEFAULT  NOT NULL ,
	[control_type] [varchar] (50) COLLATE DATABASE_DEFAULT  NOT NULL ,
	[risk_description] [varchar] (250) COLLATE DATABASE_DEFAULT  NULL ,
	[risk_control_id] [int] NOT NULL ,
	[control_activity] [varchar] (250) COLLATE DATABASE_DEFAULT  NULL ,
	[as_of_date] [datetime] NULL ,
	[process_number] [varchar] (50) COLLATE DATABASE_DEFAULT  NOT NULL ,
	[requires_proof] [varchar] (50) COLLATE DATABASE_DEFAULT  NOT NULL ,
	[threshold_days] [int] NOT NULL ,
	[exception_date] [datetime]  NULL,
	[requires_approval] [char] NULL,
	[monetary_value] float NULL,
	[monetary_value_frequency_id] int null,
	[monetary_value_changes] varchar(1) COLLATE DATABASE_DEFAULT null,
	[requires_approval_for_late] varchar(1) COLLATE DATABASE_DEFAULT null,
	[mitigation_plan_required] varchar(1) COLLATE DATABASE_DEFAULT null,
	[requirements_revision_id] int null,
	[sub_name] [varchar] (100) COLLATE DATABASE_DEFAULT  NOT NULL,
	[stra_name] [varchar] (100) COLLATE DATABASE_DEFAULT  NOT NULL,
	[book_name] [varchar] (100) COLLATE DATABASE_DEFAULT  NOT NULL 
	 
)

--prc.run_frequency = 700 and prc.run_date is not null and @as_of_date = prc.run_date
--- ' + @pre_runs + ' 
SET @sql_stmt0 = 'INSERT #tempControls 
SELECT  CAST(isnull(sub.entity_id, '''') as varchar) AS subsidiary_id, 
	isnull(sub.entity_name + ''/'' + stra.entity_name + ''/'' + book.entity_name, '''') as Subsidiary,
	prc.perform_role AS perform_role_id, 
	asrP.role_name AS PerformRole, 
	prc.approve_role AS approve_role_id, 
	asrA.role_name AS ApproveRole, 
	prc.run_frequency AS run_frequency_id, 
	rf.code AS run_frequency, 
	prd.risk_priority AS risk_priority_id, 
	rp.code AS risk_priority, 
	ct.code AS control_type,
	pch.process_number + '' ('' + CAST(prd.risk_description_id AS varchar) + '' - '' + prd.risk_description + '')'' AS risk_description, 
	prc.risk_control_id, 


        isnull(''('' + prr.requirement_no + '') '', '''') + 	
		isnull(area.code + '' > '', '''') + isnull(sarea.code + '' > '', '''')  + 
		isnull(action.code , '''') +
		isnull('' > '' + prc.risk_control_description, '''') AS control_activity, '

SET @as_of_date_sql_stmt = '
	CASE prc.run_frequency
  		WHEN 700 THEN isnull(prc.run_date, dbo.FNAGetSQLStandardDate(''' + @as_of_date + '''))
		WHEN 701 THEN dbo.FNAGetSQLStandardDate(DATEADD(dd, (6 - DATEPART(dw, ''' + @as_of_date + ''')' + '), ''' + @as_of_date + '''))
		WHEN 703 THEN 
			CASE (DATEPART(mm, ''' + @as_of_date + ''') - ' + @pre_runs + ') 
			  WHEN 0 Then 
				(CAST(DATEPART(yy, ''' + @as_of_date + ''') -1 As varchar) + ''-12-'' + cast(isnull(datepart(dd, prc.run_date), 31) as varchar))
			  WHEN 1 Then 
				(CAST(DATEPART(yy, ''' + @as_of_date + ''') As varchar) + ''-1-'' + cast(isnull(datepart(dd, prc.run_date), 31) as varchar))
			  WHEN 2 Then 	
				CASE ISDATE(CAST(DATEPART(yy, ''' + @as_of_date + ''') As varchar) + ''-2-'' + cast(isnull(datepart(dd, prc.run_date), 29) as varchar))
					WHEN 1 Then (CAST(DATEPART(yy, ''' + @as_of_date + ''') As varchar) + ''-2-'' + cast(isnull(datepart(dd, prc.run_date), 29) as varchar))
					ELSE (CAST(DATEPART(yy, ''' + @as_of_date + ''') As varchar) + ''-2-'' + cast(isnull(datepart(dd, prc.run_date), 28) as varchar))
				END
			  WHEN 3 Then (CAST(DATEPART(yy, ''' + @as_of_date + ''') As varchar) + ''-3-'' + cast(isnull(datepart(dd, prc.run_date), 31) as varchar))
			  WHEN 4 Then (CAST(DATEPART(yy, ''' + @as_of_date + ''') As varchar) + ''-4-'' + cast(isnull(datepart(dd, prc.run_date), 30) as varchar))
			  WHEN 5 Then (CAST(DATEPART(yy, ''' + @as_of_date + ''') As varchar) + ''-5-'' + cast(isnull(datepart(dd, prc.run_date), 31) as varchar))
			  WHEN 6 Then (CAST(DATEPART(yy, ''' + @as_of_date + ''') As varchar) + ''-6-'' + cast(isnull(datepart(dd, prc.run_date), 30) as varchar))
			  WHEN 7 Then (CAST(DATEPART(yy, ''' + @as_of_date + ''') As varchar) + ''-7-'' + cast(isnull(datepart(dd, prc.run_date), 31) as varchar))
			  WHEN 8 Then (CAST(DATEPART(yy, ''' + @as_of_date + ''') As varchar) + ''-8-'' + cast(isnull(datepart(dd, prc.run_date), 31) as varchar))
			  WHEN 9 Then (CAST(DATEPART(yy, ''' + @as_of_date + ''') As varchar) + ''-9-'' + cast(isnull(datepart(dd, prc.run_date), 30) as varchar))
			  WHEN 10 Then (CAST(DATEPART(yy, ''' + @as_of_date + ''') As varchar) + ''-10-'' + cast(isnull(datepart(dd, prc.run_date), 31) as varchar))
			  WHEN 11 Then (CAST(DATEPART(yy, ''' + @as_of_date + ''') As varchar) + ''-11-'' + cast(isnull(datepart(dd, prc.run_date), 30) as varchar))
			  ELSE (CAST(DATEPART(yy, ''' + @as_of_date + ''') As varchar) + ''-12-'' + cast(isnull(datepart(dd, prc.run_date), 31) as varchar))
			END
		WHEN 704 THEN 
			CASE (DATEPART(qq, ''' + @as_of_date + ''') - ' + @pre_runs + ') 
			  WHEN 0 Then (CAST(DATEPART(yy, ''' + @as_of_date + ''') - 1 As varchar) + ''-12-'' + cast(isnull(datepart(dd, prc.run_date), 31) as varchar))
			  WHEN 1 Then (CAST(DATEPART(yy, ''' + @as_of_date + ''') As varchar) + ''-3-'' + cast(isnull(datepart(dd, prc.run_date), 31) as varchar))
			  WHEN 2 Then (CAST(DATEPART(yy, ''' + @as_of_date + ''') As varchar) + ''-6-'' + cast(isnull(datepart(dd, prc.run_date), 30) as varchar))
			  WHEN 3 Then (CAST(DATEPART(yy, ''' + @as_of_date + ''') As varchar) + ''-9-'' + cast(isnull(datepart(dd, prc.run_date), 30) as varchar))
			  ELSE (CAST(DATEPART(yy, ''' + @as_of_date + ''') As varchar) + ''-12-'' + cast(isnull(datepart(dd, prc.run_date), 31) as varchar))
			END
		WHEN 705 THEN 
			CASE CASE DATEPART(qq, ''' + @as_of_date + ''') WHEN 1 THEN 0 WHEN 2 THEN 0 ELSE 1 END - ' + @pre_runs + ' 
			WHEN -1 then (CAST(DATEPART(yy, ''' + @as_of_date + ''') -1 As varchar) + ''-12-'' + cast(isnull(datepart(dd, prc.run_date), 31) as varchar))
			WHEN 0 then (CAST(DATEPART(yy, ''' + @as_of_date + ''') As varchar) + ''-6-'' + cast(isnull(datepart(dd, prc.run_date), 30) as varchar))
			WHEN 1 then (CAST(DATEPART(yy, ''' + @as_of_date + ''') As varchar) + ''-12-'' + cast(isnull(datepart(dd, prc.run_date), 31) as varchar))
			END
		WHEN 706 THEN CAST(DATEPART(yy, ''' + @as_of_date + ''') - ' + @pre_runs + ' As varchar) + ''-'' + cast(isnull(datepart(mm, prc.run_date), 12) as varchar) + ''-'' + cast(isnull(datepart(dd, prc.run_date), 31) as varchar)
		ELSE ''1900-1-1''
		END
	'
 
SET @sql_stmt0 = @sql_stmt0 + @as_of_date_sql_stmt + '  AS as_of_date,  '

SET @sql_stmt = ' 	pch.process_number As process_number, prc.requires_proof as requires_proof, prc.threshold_days AS threshold_days, 

	dbo.FNAGetSQLStandardDate(DATEADD(dd, prc.threshold_days, ' + @as_of_date_sql_stmt + '	)) AS exception_date, 

	isnull(prc.requires_approval, ''n'') as requires_approval,
	prc.monetary_value,
	prc.monetary_value_frequency_id,
	prc.monetary_value_changes,
	prc.requires_approval_for_late,
	case when (isnull(prc.activity_category_id, 1213) = 1213) then ''n'' else prc.mitigation_plan_required end mitigation_plan_required,
	prc.requirements_revision_id,
	sub.entity_name as sub_name,
	stra.entity_name as stra_name,
	book.entity_name as book_name

FROM         process_risk_controls prc INNER JOIN
	     portfolio_hierarchy book ON book.entity_id = prc.fas_book_id INNER JOIN
             portfolio_hierarchy stra ON stra.entity_id = book.parent_entity_id INNER JOIN
             portfolio_hierarchy sub ON sub.entity_id = stra.parent_entity_id INNER JOIN             
	     static_data_value ct ON ct.value_id = prc.control_type INNER JOIN
             static_data_value rf ON prc.run_frequency = rf.value_id INNER JOIN
             application_security_role asrP ON prc.perform_role = asrP.role_id INNER JOIN
             application_security_role asrA ON prc.approve_role = asrA.role_id INNER JOIN
             process_risk_description prd ON prc.risk_description_id = prd.risk_description_id INNER JOIN
	     static_data_value rp ON rp.value_id = prd.risk_priority INNER JOIN
             process_control_header pch ON prd.process_id = pch.process_id LEFT OUTER JOIN
	     static_data_value area on area.value_id = prc.activity_area_id LEFT OUTER JOIN
	     static_data_value sarea on sarea.value_id = prc.activity_sub_area_id LEFT OUTER JOIN
	     static_data_value action on action.value_id = prc.activity_action_id LEFT OUTER JOIN
	     process_requirements_revisions prr on prr.requirements_revision_id = prc.requirements_revision_id
     
'

        
--Run upto run_end_date if defined..
-- SET @sql_stmt = @sql_stmt + ' WHERE (prc.run_effective_date <= CONVERT(DATETIME,''' + @as_of_date + ''', 102) AND 
-- 				(prc.run_end_date IS NULL OR prc.run_end_date >= CONVERT(DATETIME,''' + @as_of_date + ''', 102))) '
-- 
SET @sql_stmt = @sql_stmt + ' WHERE (prc.run_date between CONVERT(DATETIME,''' + @as_of_date + ''', 102) 
					and isnull(prc.run_end_date, CONVERT(DATETIME,''' + @as_of_date + ''', 102)) 
					OR
					prc.run_effective_date  between  CONVERT(DATETIME,''' + @as_of_date_to + ''', 102)
					and isnull(prc.run_end_date, CONVERT(DATETIME,''' + @as_of_date_to + ''', 102))) '

--Now put all the filters....

-- filters by the user_login_id
IF @user_login_id IS NOT NULL AND @call_type IN (1)
BEGIN
  SET @sql_stmt = @sql_stmt + ' AND prc.perform_role in ( SELECT DISTINCT asr.role_id FROM APPLICATION_SECURITY_ROLE asr, APPLICATION_ROLE_USER aru
				WHERE role_type_value_id = 4 AND
				aru.role_id = asr.role_id AND 
				aru.user_login_id = ''' + @user_login_id + ''')'
END
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

IF @role_id IS NOT NULL AND @call_type = 2
BEGIN
SET   @sql_stmt = @sql_stmt + ' AND prc.approve_role = ' + @role_id
END



IF @call_type = 2
BEGIN
SET   @sql_stmt2 = ' AND CASE when (dbo.FNAGetSQLStandardDate(DATEADD(dd, prc.threshold_days, ' + @as_of_date_sql_stmt + ')) < getdate() 
		       AND isnull(prc.requires_approval_for_late, ''n'') = ''y'') then ''y'' else prc.requires_approval end = ''y'''
END


If @process_number IS NOT NULL 
BEGIN
SET   @sql_stmt = @sql_stmt + + ' AND pch.process_id = ''' + @process_number + ''''
END

--print @sql_stmt
EXEC spa_print 'here'
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
             

-- 
 EXEC spa_print @sql_stmt0
 EXEC spa_print @sql_stmt
 EXEC spa_print @sql_stmt2

--print 'before populating temp table'

EXEC (@sql_stmt0 + @sql_stmt + @sql_stmt2)


--select '#tempControls', * from #tempControls
--return
--print 'after populating temp table'
-- select * from #tempControls

select 	a.risk_control_id, max(dateadd(dd, -r.no_of_days, a.as_of_date)) Remind,
r.risk_control_email_id, k.as_of_date, r.control_status
into #reminder1
from #tempControls a INNER JOIN
-- process_risk_controls_reminders r on r.risk_control_id = a.risk_control_id
process_risk_controls_email r on r.risk_control_id = a.risk_control_id
left outer join process_risk_controls_reminders_acknowledge k on k.risk_control_reminder_id = r.risk_control_email_id 
and k.as_of_date = a.as_of_date 
where k.as_of_date is null
group by a.risk_control_id, r.risk_control_email_id, k.as_of_date,r.control_status
having max(dateadd(dd, -r.no_of_days, a.as_of_date)) <= @as_of_date


-- select '#reminder1', * from #reminder1

-- 1. Calc monetary penalty values
-- select datediff(dd,'12/25/2006', '12/29/2006')
-- select datediff(mm,'12/25/2006', '12/29/2006')
-- select datediff(qq,'12/25/2006', '12/29/2006')
-- select datediff(yy,'12/25/2006', '12/29/2006')
-- 2. Input monetary values from front end
-- 3. add filters and sort orders


select r1.risk_control_id, r1.risk_control_email_id, r1.Remind, r1.control_status
into #reminder
from
(select risk_control_id, max(Remind) remind_date
from #reminder1
group by risk_control_id) r inner join
#reminder1 r1 on r1.risk_control_id = r.risk_control_id and
		 r1.Remind = r.remind_date

--select '#reminder' , * from #reminder

--select * from #tempControls

DECLARE @penalty_stmt varchar(5000)
 

set @penalty_stmt = ' cast(case when (isnull(prca.monetary_value, #tempControls.monetary_value) is not null and (#tempControls.as_of_date < case when (isnull(prca.control_status, 525) IN (728, 729)) then prca.update_ts else getdate() end) and monetary_value_frequency_id is not null) then
				case monetary_value_frequency_id when 700 then datediff(dd,#tempControls.as_of_date, case when (isnull(prca.control_status, 525) IN (728, 729)) then prca.update_ts else getdate() end)
						 		 when 701 then datediff(ww,#tempControls.as_of_date, case when (isnull(prca.control_status, 525) IN (728, 729)) then prca.update_ts else getdate() end) + 1
						 		 when 703 then datediff(mm,#tempControls.as_of_date, case when (isnull(prca.control_status, 525) IN (728, 729)) then prca.update_ts else getdate() end) + 1
						 		 when 704 then datediff(qq,#tempControls.as_of_date, case when (isnull(prca.control_status, 525) IN (728, 729)) then prca.update_ts else getdate() end) + 1
						 		 when 705 then (datediff(yy,#tempControls.as_of_date, case when (isnull(prca.control_status, 525) IN (728, 729)) then prca.update_ts else getdate() end)/2) + 1
					  	 		 when 706 then datediff(yy,#tempControls.as_of_date, case when (isnull(prca.control_status, 525) IN (728, 729)) then prca.update_ts else getdate() end) + 1
				else 1 end * coalesce(prca.monetary_value, #tempControls.monetary_value, 0)			
		       else coalesce(prca.monetary_value, #tempControls.monetary_value, 0) end as float)'

declare @sql_stmt_top varchar(100)

If upper(@unapporved_flag) = 'N'
	set @sql_stmt_top = ' TOP 1 '
else
	set @sql_stmt_top = ''

--select '@unapporved_flag' , @unapporved_flag

SET @sql_stmt = 'SELECT ' + @sql_stmt_top + '
	#tempControls.subsidiary_id,
	#tempControls.Subsidiary,
	#tempControls.perform_role_id,
	#tempControls.PerformRole,
	case when (''' + @unapporved_flag + ''' = ''R'' AND #reminder.risk_control_id is not null) then 
			#reminder.risk_control_email_id else #tempControls.approve_role_id end approve_role_id,
	#tempControls.ApproveRole,
	#tempControls.run_frequency_id,
	#tempControls.run_frequency  run_frequency,
	#tempControls.risk_priority_id,
	#tempControls.risk_priority,
	#tempControls.control_type,
	#tempControls.risk_description,
	#tempControls.risk_control_id,
	#tempControls.control_activity,
-- 	#tempControls.control_activity +
-- 	  case when (isnull(prca.monetary_value, #tempControls.monetary_value) is not null) then '' (Monetary Value: ''+ cast(isnull(prca.monetary_value, #tempControls.monetary_value) as varchar) + '')''else '''' end control_activity,
	dbo.FNADateFormat(isnull(prca.as_of_date, #tempControls.as_of_date)) AS as_of_date,
	#tempControls.process_number,
	case when (''' + @unapporved_flag + ''' = ''R'' AND #reminder.risk_control_id is not null) then ''n'' 
	     when (prca.exception_date < getdate() AND isnull(requires_approval_for_late, ''n'') = ''y'') then ''y'' 
	else #tempControls.requires_proof end requires_proof,
	#tempControls.threshold_days,
	dbo.FNADateFormat(isnull(prca.exception_date, #tempControls.exception_date)) AS exception_date,
	CASE when (prca.exception_date < getdate() AND isnull(requires_approval_for_late, ''n'') = ''y'') then ''y'' else #tempControls.requires_approval end requires_approval,	 
	cast(isnull(prca.control_status, 725) as varchar) As  activity_status,
	isnull((pUser.user_l_name + '', '' + pUser.user_f_name + '' '' + pUser.user_m_name), '''')  AS run_by, 
	dbo.FNADateFormat(prca.create_ts) AS run_date, 
	isnull((aUser.user_l_name + '', '' + aUser.user_f_name + '' '' + aUser.user_m_name), '''') AS approved_by,
        dbo.FNADateFormat(prca.approved_date) AS approved_date, 
	'' '' AS attach_proof,  ''Save'' As save_clm, cast('''' as varchar) As approve_checkbox, cast('''' as varchar) exception_flag, 
	case when (''' + @unapporved_flag + ''' = ''R'' AND #reminder.risk_control_id is not null) then ''Reminder'' else ast.code end activity_status_desc, 
	(dbo.FNADateFormat(isnull(prca.as_of_date, #tempControls.as_of_date)) + '' <I>(By: '' + dbo.FNADateFormat(isnull(prca.exception_date, #tempControls.exception_date)) + '')</I>'') as as_of_date_display,
	dbo.FNAGetSQLStandardDate(#tempControls.as_of_date) as as_of_date_argument,
	CASE when (prca.exception_date < getdate()) then 1 else 0 end time_exception,
	isnull(isnull(prca.monetary_value, #tempControls.monetary_value), 0) monetary_value,
	
		' + @penalty_stmt + ' monetary_penalty,		
	isnull(monetary_value_frequency_id, 0) monetary_value_frequency_id,
	isnull(monetary_value_changes, ''n'') monetary_value_changes,
	isnull(requires_approval_for_late, ''n'') requires_approval_for_late,
	CASE when (prca.exception_date < getdate() AND isnull(requires_approval_for_late, ''n'') = ''y'') then ''y'' else ''n'' end force_late_approval, 
	CASE when (prca.exception_date < getdate() AND isnull(mitigation_plan_required, ''n'') = ''y'') then ''y'' else ''n'' end mitigation_plan_required,
	requirements_revision_id,
	#tempControls.sub_name,
	#tempControls.stra_name,
	#tempControls.book_name,
	case when prca.control_status IN (728, 729) then datepart(d,prca.update_ts-prca.exception_date)
	     else datepart(d,getdate()-prca.exception_date) end as exception_days,
	#reminder.control_status
	
	

from    #tempControls LEFT OUTER JOIN
	process_risk_controls_activities prca ON prca.risk_control_id = #tempControls.risk_control_id ' + 
	case when upper(@unapporved_flag) = 'R' then
		' AND prca.as_of_date = #tempControls.as_of_date '
	else '' end +

'	LEFT OUTER JOIN application_users pUser ON prca.create_user = pUser.user_login_id LEFT OUTER JOIN
        application_users aUser ON prca.approved_by = aUser.user_login_id INNER JOIN
	static_data_value ast ON ast.value_id = isnull(prca.control_status, 725) LEFT OUTER JOIN
	#reminder ON #reminder.risk_control_id = #tempControls.risk_control_id ' 


SET @sql_stmt = @sql_stmt + ' WHERE 1=1 ' 
--	
--			else ' AND  (isnull(prca.as_of_date, #tempControls.as_of_date) BETWEEN
--					 CONVERT(DATETIME,''' + @as_of_date + ''', 102) 
--			AND CONVERT(DATETIME,''' + @as_of_date_to + ''', 102))' 
--	end
--		

-- EXEC spa_print 'after building sql stmt'
-- exec (@sql_stmt)
-- EXEC spa_print 'after RUNNING the sql stmt'
-- 
-- EXEC spa_print @sql_stmt
-- If as_of_date is null there is no acknowledgemdent. if as of date is not null then y can join and Remind is < as_of_date give message
-- declare @as_of_date datetime
-- set @as_of_date = '2006-01-28'

--select '@unapporved_flag' , @unapporved_flag

If @unapporved_flag IS NOT NULL
BEGIN
	--Reminders
	If upper(@unapporved_flag) = 'R'
		SET @sql_stmt = @sql_stmt + ' AND 
		(CONVERT(DATETIME,''' + @as_of_date + ''', 102) < CONVERT(DATETIME, #tempControls.as_of_date, 102) AND 
								((prca.control_status IS NULL OR prca.control_status in (725, 726)) AND 
							 #reminder.risk_control_id is not null and #reminder.control_status = -5)) '
	--Not completed		
	else If upper(@unapporved_flag) = 'N'
		SET @sql_stmt = @sql_stmt + ' AND prca.control_status in (725) and  
							dbo.FNADateFormat(''' + @as_of_date + ''') <= dbo.FNADateFormat(prca.exception_date)'

	--Unapproved
	else If  upper(@unapporved_flag) = 'U'
		SET @sql_stmt = @sql_stmt + ' AND prca.control_status = 726 '

	--Completed
	else If  upper(@unapporved_flag) = 'C'
	begin
		if @call_type = 2
			SET @sql_stmt = @sql_stmt + ' AND prca.control_status in (726, 727, 728) '
		else
			SET @sql_stmt = @sql_stmt + ' AND prca.control_status in (726, 727, 728, 729) '
	end

	else If  upper(@unapporved_flag) = 'P'
		SET @sql_stmt = @sql_stmt + ' AND prca.control_status in (727, 728, 729) '

	--Exceptions only (the ones that have not been completed yet
	else If  upper(@unapporved_flag) = 'E'
		SET @sql_stmt = @sql_stmt + ' AND prca.control_status <> 
				case when (#tempControls.requires_approval = ''n'') then 728 else 729 end '

	-- Completed but Exceeds threshold days 
	else If  upper(@unapporved_flag) = 'T'
		SET @sql_stmt = @sql_stmt + ' AND (prca.control_status IN (728, 729) AND 
				dbo.FNADateFormat(prca.update_ts) > dbo.FNADateFormat(prca.exception_date)) '

	-- Exceeds threshold days and still not completed - ESCALATION
	else If  upper(@unapporved_flag) = 'S'
		SET @sql_stmt = @sql_stmt + ' AND (prca.control_status NOT IN (725, 728, 729) AND 
								dbo.FNADateFormat(''' + @as_of_date + ''') > dbo.FNADateFormat(prca.exception_date)) '
--		SET @sql_stmt = @sql_stmt + ' AND (prca.control_status NOT IN (728, 729) AND CONVERT(DATETIME,''' + @as_of_date + ''', 102)  > CONVERT(DATETIME, prca.exception_date, 102)) '

	-- Fetch Completed activities for communication
	else If  upper(@unapporved_flag) = 'CO'	
		SET @sql_stmt = @sql_stmt + ' AND prca.control_status = 728'
	
	-- Fetch Approved activities for communication
	else If  upper(@unapporved_flag) = 'AP'
		SET @sql_stmt = @sql_stmt + '
						 AND  (prca.as_of_date BETWEEN prca.as_of_date 
					AND CONVERT(DATETIME,''' + @as_of_date_to + ''', 102)) 
					 AND prca.control_status = 729 AND #tempControls.requires_approval = ''y'''

	-- Fetch Mitigated activities for communication
	else If  upper(@unapporved_flag) = 'M'
		SET @sql_stmt = @sql_stmt + ' AND 
				dbo.FNADateFormat(''' + @as_of_date + ''') > dbo.FNADateFormat(prca.exception_date) AND 
				prca.control_status = 725 AND mitigation_plan_required = ''y'''

	-- Fetch Mitigated activities for communication
	else If  upper(@unapporved_flag) = 'RE'
		SET @sql_stmt = @sql_stmt + ' AND prca.control_status = 727 '
	
	else
		SET @sql_stmt = @sql_stmt + '
		 AND  (isnull(prca.as_of_date, #tempControls.as_of_date) BETWEEN
					 CONVERT(DATETIME,''' + @as_of_date + ''', 102) 
			AND CONVERT(DATETIME,''' + @as_of_date_to + ''', 102))'

	IF @call_type = 4 and upper(@unapporved_flag) = 'A'
		SET   @sql_stmt = @sql_stmt + ' AND ' + @penalty_stmt + ' <> 0 '
	ELSE IF @call_type = 4 and upper(@unapporved_flag) <> 'A'
		SET   @sql_stmt = @sql_stmt + ' AND ' + @penalty_stmt + ' <> 0 '
END
ELSE IF @call_type = 4
	SET   @sql_stmt = @sql_stmt + ' WHERE  ' + @penalty_stmt + ' <> 0 '


If @get_counts = 0
BEGIN
	If @call_type = 1
	 SET @sql_stmt = @sql_stmt + ' ORDER BY #tempControls.subsidiary_id, #tempControls.perform_role_id, #tempControls.run_frequency_id, #tempControls.risk_priority, #tempControls.risk_control_id'
	If @call_type = 2
	 SET @sql_stmt = @sql_stmt + ' ORDER BY #tempControls.subsidiary_id, #tempControls.approve_role_id, #tempControls.run_frequency_id, #tempControls.risk_priority, #tempControls.risk_control_id'
	If @call_type = 3
	 SET @sql_stmt = @sql_stmt + ' ORDER BY #tempControls.subsidiary_id, #tempControls.run_frequency_id, #tempControls.risk_control_id'
END
--print @sql_stmt;

--	exec(@sql_stmt)


If @get_counts IN (1, 2)
  if @process_table_insert_or_create = 'c'
	SET @sql_stmt = 'select sub_name, stra_name, book_name, process_number, as_of_date as Date, ' + 
			case when (@get_counts = 1) then ' count(*) as total_rows ' else ' sum(cast(monetary_penalty as float)) as total_values  ' end + 
		',activity_status,sum(exception_days) as exception_days'+
		case when @process_table is not null then ' into '+@process_table else '' end+'  from (' + @sql_stmt + ') xx
		group by sub_name, stra_name, book_name, process_number, as_of_date,activity_status'
  elsE 	
	SET @sql_stmt = case when @process_table is not null then 'INSERT INTO '+@process_table else '' end + 
		' select sub_name, stra_name, book_name, process_number, as_of_date as Date, ' + 
		case when (@get_counts = 1) then ' count(*) as total_rows ' else ' sum(cast(monetary_penalty as float)) as total_values' end + 
		',activity_status,sum(exception_days) as exception_days, control_status  from (' + @sql_stmt + ') xx
		group by sub_name, stra_name, book_name, process_number, prca.as_of_date,activity_status'
-- monetary_penalty
--PRINT @sql_stmt
EXEC (@sql_stmt)

--print @sql_stmt
--select * from #tempControls

























