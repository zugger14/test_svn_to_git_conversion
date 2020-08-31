

IF OBJECT_ID('[dbo].[spa_Get_Risk_Control_Activities_Reminder]','p') IS NOT NULL
DROP PROCEDURE [dbo].[spa_Get_Risk_Control_Activities_Reminder]
GO
-- EXEC spa_Get_Risk_Control_Activities_Reminder NULL, @as_of_date, NULL, NULL, NULL, NULL, 'S', 1

CREATE PROC [dbo].[spa_Get_Risk_Control_Activities_Reminder]
    @user_login_id						AS VARCHAR(50),
    @as_of_date							AS VARCHAR(20),
    @sub_id								AS VARCHAR(250),
    @run_frequency						AS VARCHAR(20),
    @risk_priority						AS VARCHAR(20),
    @role_id							AS VARCHAR(20),
    @reminder_flag						AS CHAR(2),
    @call_type							AS INT, /*1 : At the time of login*/
    @get_counts							AS INT = 0,/*NULL : At the time of login*/
    @process_number						   VARCHAR(50) = NULL,
    @risk_description_id				   INT = NULL,
    @activity_category_id				   INT = NULL,
    @who_for							   INT = NULL,
    @where								   INT = NULL,
    @why								   INT = NULL,
    @activity_area						   INT = NULL,
    @activity_sub_area                     INT = NULL,
    @activity_action                       INT = NULL,
    @activity_desc                         VARCHAR(250) = NULL,
    @control_type                          INT = NULL,
    @montetory_value_defined               VARCHAR(1) = 'n',
    @process_owner                         VARCHAR(50) = NULL,
    @risk_owner                            VARCHAR(50) = NULL,
    @risk_control_id                       INT = NULL,
    @strategy_id                           VARCHAR(250) = NULL,
    @book_id                               VARCHAR(250) = NULL,
    @process_table                         VARCHAR(100) = NULL,
    @process_table_insert_or_create        VARCHAR(100) = 'c', --'c' creates the table and 'i' just inserts in the same table (table alredy created)
    @as_of_date_to						AS VARCHAR(20) = NULL
AS 
    SET NOCOUNT ON

-- Delete the commented portion under the name 'vk' whenever its required. As no use of the block of code was seen, it was commented.
    DECLARE @where_stmt				AS VARCHAR(20)		,
			@and_stmt				AS VARCHAR(20)		,
			@sql_stmt				AS VARCHAR(MAX)		,
			@sql_stmt0				AS VARCHAR(MAX)		,
			@sql_stmt2				AS VARCHAR(MAX)		,
			@as_of_date_sql_stmt	AS VARCHAR(8000)	,
			@sql_stmt_top			AS VARCHAR(100)		,
			@penalty_stmt			AS VARCHAR(5000)	,
			@function_id			AS INT

    SELECT @sql_stmt0 ='', 
		   @sql_stmt ='' , 
		   @sql_stmt2='',
		   @as_of_date_sql_stmt='',
		   @penalty_stmt = '',
		   @and_stmt='',
		   @where_stmt=''

    IF @get_counts IS NULL 
        SET @get_counts = 0

    IF @as_of_date_to IS NULL
        OR @reminder_flag IN ( 'R', 'S' ) 
        SET @as_of_date_to = @as_of_date

    CREATE TABLE #h_users
        (
          user_login_id VARCHAR(50) COLLATE DATABASE_DEFAULT,
          reports_to_user_login_id VARCHAR(50) COLLATE DATABASE_DEFAULT NULL
        )

    IF @user_login_id IS NOT NULL
        AND @call_type IN ( 3 ) 
        INSERT  #h_users
                EXEC spa_get_hierarchy_users @user_login_id
    ELSE 
        IF @user_login_id IS NULL
            AND @call_type IN ( 3 ) 
            INSERT  INTO #h_users
                    SELECT  user_login_id,
                            NULL
                    FROM    application_users

    SET @and_stmt = ''
    SET @where_stmt = ' '

    CREATE TABLE #tempControls
        (
          [subsidiary_id] [varchar](50) COLLATE DATABASE_DEFAULT NOT NULL	,[Subsidiary] [varchar](100) COLLATE DATABASE_DEFAULT NOT NULL		,[perform_role_id] [int] NOT NULL			 ,
          [PerformRole] [varchar](50) COLLATE DATABASE_DEFAULT NOT NULL		,[approve_role_id] [int] NULL				,[ApproveRole] [varchar](50) COLLATE DATABASE_DEFAULT NULL			 ,
		  [run_frequency_id] [int] NULL				,[run_frequency] [varchar](50) COLLATE DATABASE_DEFAULT NULL			,[risk_priority_id] [int] NOT NULL			 ,
          [risk_priority] [varchar](50) COLLATE DATABASE_DEFAULT NOT NULL	,[control_type] [varchar](50) COLLATE DATABASE_DEFAULT NOT NULL		,[risk_description] [varchar](250) COLLATE DATABASE_DEFAULT NULL		 ,
          [risk_control_id] [int] NOT NULL			,[control_activity] [varchar](250) COLLATE DATABASE_DEFAULT NULL		,[as_of_date] [datetime] NULL				 ,
          [process_number] [varchar](50) COLLATE DATABASE_DEFAULT NOT NULL	,[requires_proof] [varchar](50) COLLATE DATABASE_DEFAULT NOT NULL	,[threshold_days] [int] NOT NULL			 ,
          [exception_date] [datetime] NULL			,[requires_approval] [char] NULL			,[monetary_value] FLOAT NULL				 ,
		  [monetary_value_frequency_id] INT NULL	,[monetary_value_changes] VARCHAR(1) COLLATE DATABASE_DEFAULT NULL	,[requires_approval_for_late] VARCHAR(1) COLLATE DATABASE_DEFAULT NULL,
          [mitigation_plan_required] VARCHAR(1) COLLATE DATABASE_DEFAULT NULL,[requirements_revision_id] INT NULL		,[sub_name] [varchar](100) COLLATE DATABASE_DEFAULT NOT NULL			 ,
          [stra_name] [varchar](100) COLLATE DATABASE_DEFAULT NOT NULL		,[book_name] [varchar](100) COLLATE DATABASE_DEFAULT NOT NULL		
        )

	-- Insert the details of all the Activities into #tempControls. 
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

	--SET @as_of_date_sql_stmt = 'prc.run_date'
	SET @as_of_date_sql_stmt = 'dbo.FNANextInstanceCreationDate(risk_control_id)'
    SET @sql_stmt0 = @sql_stmt0 + @as_of_date_sql_stmt + '  AS as_of_date,  '

    SET @sql_stmt = ' 	pch.process_number As process_number, prc.requires_proof as requires_proof, prc.threshold_days AS threshold_days, 

	dbo.FNAGetSQLStandardDate(DATEADD(dd, prc.threshold_days, '
        + @as_of_date_sql_stmt
        + '	)) AS exception_date, 

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
	     static_data_value ct ON ct.value_id = prc.control_type LEFT JOIN
             static_data_value rf ON prc.run_frequency = rf.value_id INNER JOIN
             application_security_role asrP ON prc.perform_role = asrP.role_id 
             JOIN application_role_user aru ON aru.role_id = asrP.role_id AND aru.user_login_id = dbo.FNADBUser() 
             LEFT OUTER JOIN
             application_security_role asrA ON prc.approve_role = asrA.role_id INNER JOIN
             process_risk_description prd ON prc.risk_description_id = prd.risk_description_id INNER JOIN
	     static_data_value rp ON rp.value_id = prd.risk_priority INNER JOIN
             process_control_header pch ON prd.process_id = pch.process_id LEFT OUTER JOIN
	     static_data_value area on area.value_id = prc.activity_area_id LEFT OUTER JOIN
	     static_data_value sarea on sarea.value_id = prc.activity_sub_area_id LEFT OUTER JOIN
	     static_data_value action on action.value_id = prc.activity_action_id LEFT OUTER JOIN
	     process_requirements_revisions prr on prr.requirements_revision_id = prc.requirements_revision_id  		
'
              
SET @sql_stmt = @sql_stmt + ' WHERE 1=1 '
									/*******************************************************
																FILTERS
									*******************************************************/

-- filters by the user_login_id
    IF @user_login_id IS NOT NULL AND @call_type IN ( 1 ) 
	BEGIN
        SET @sql_stmt = @sql_stmt
            + ' AND prc.perform_role in ( SELECT DISTINCT asr.role_id FROM APPLICATION_SECURITY_ROLE asr, APPLICATION_ROLE_USER aru
			WHERE role_type_value_id = 4 AND
			aru.role_id = asr.role_id AND 
			aru.user_login_id = ''' + @user_login_id + ''')'
	END

    IF @user_login_id IS NOT NULL AND @call_type IN ( 3, 4 ) 
    BEGIN
        SET @sql_stmt = @sql_stmt
            + ' AND prc.perform_role in ( SELECT DISTINCT asr.role_id FROM APPLICATION_SECURITY_ROLE asr, APPLICATION_ROLE_USER aru
			WHERE role_type_value_id = 4 AND
			aru.role_id = asr.role_id AND 
			aru.user_login_id IN (select user_login_id from #h_users))'
    END

    IF @user_login_id IS NOT NULL AND @call_type = 2 
	BEGIN
       SET @sql_stmt = @sql_stmt
            + ' AND prc.approve_role in ( SELECT asr.role_id FROM APPLICATION_SECURITY_ROLE asr, APPLICATION_ROLE_USER aru
			WHERE role_type_value_id = 4 AND
			aru.role_id = asr.role_id AND 
			aru.user_login_id = ''' + @user_login_id + ''')'
	END

    IF @risk_description_id IS NOT NULL 
        BEGIN
            SET @sql_stmt = @sql_stmt + ' AND prd.risk_description_id = '
                + CAST(@risk_description_id AS VARCHAR)
        END

    IF @run_frequency IS NOT NULL 
        BEGIN
            SET @sql_stmt = @sql_stmt + ' AND prc.run_frequency = '
                + @run_frequency
        END

    IF @risk_priority IS NOT NULL 
        BEGIN
            SET @sql_stmt = @sql_stmt + ' AND prd.risk_priority = '
                + @risk_priority
        END

    IF @sub_id IS NOT NULL 
        SET @sql_stmt = @sql_stmt + ' AND sub.entity_id IN (' + @sub_id + ')'

    IF @strategy_id IS NOT NULL 
        SET @sql_stmt = @sql_stmt + ' AND stra.entity_id IN (' + @strategy_id
            + ')'

    IF @book_id IS NOT NULL 
        SET @sql_stmt = @sql_stmt + ' AND book.entity_id IN (' + @book_id
            + ')'

    IF @role_id IS NOT NULL AND @call_type = 1         
         SET @sql_stmt = @sql_stmt + ' AND prc.perform_role = ' + @role_id
        
    IF @role_id IS NOT NULL AND @call_type = 2         
         SET @sql_stmt = @sql_stmt + ' AND prc.approve_role = ' + @role_id
        
    IF @call_type = 2         
         SET @sql_stmt2 = ' AND CASE when (dbo.FNAGetSQLStandardDate(DATEADD(dd, prc.threshold_days, '
                + @as_of_date_sql_stmt
                + ')) < getdate() 
		       AND isnull(prc.requires_approval_for_late, ''n'') = ''y'') then ''y'' else prc.requires_approval end = ''y'''
        
    IF @process_number IS NOT NULL         
            SET @sql_stmt = @sql_stmt + +' AND pch.process_id = '''
                + @process_number + ''''        

    IF @activity_category_id IS NOT NULL 
        SET @sql_stmt = @sql_stmt + +' AND prc.activity_category_id = '''
            + CAST(@activity_category_id AS VARCHAR) + ''''

    IF @who_for IS NOT NULL 
        SET @sql_stmt = @sql_stmt + +' AND prc.activity_who_for_id = '''
            + CAST(@who_for AS VARCHAR) + ''''

    IF @where IS NOT NULL 
        SET @sql_stmt = @sql_stmt + +' AND prc.where_id = '''
            + CAST(@where AS VARCHAR) + ''''

    IF @why IS NOT NULL 
        SET @sql_stmt = @sql_stmt + +' AND prc.control_objective = '''
            + CAST(@why AS VARCHAR) + ''''

    IF @activity_area IS NOT NULL 
        SET @sql_stmt = @sql_stmt + +' AND prc.activity_area_id = '''
            + CAST(@activity_area AS VARCHAR) + ''''

    IF @activity_sub_area IS NOT NULL 
        SET @sql_stmt = @sql_stmt + +' AND prc.activity_sub_area_id = '''
            + CAST(@activity_sub_area AS VARCHAR) + ''''

    IF @activity_action IS NOT NULL 
        SET @sql_stmt = @sql_stmt + +' AND prc.activity_action_id = '''
            + CAST(@activity_action AS VARCHAR) + ''''

    IF @activity_desc IS NOT NULL 
        SET @sql_stmt = @sql_stmt
            + +' AND (isnull(area.code + '' > '', '''') + isnull(sarea.code + '' > '', '''')  + 
						isnull(action.code + '' > '', '''') +
						isnull(prc.risk_control_description, '''')) LIKE ''%'
            + @activity_desc + '%'''

    IF @control_type IS NOT NULL 
        SET @sql_stmt = @sql_stmt + +' AND prc.control_type = '''
            + CAST(@control_type AS VARCHAR) + ''''

    IF ISNULL(@montetory_value_defined, 'n') = 'y' 
        SET @sql_stmt = @sql_stmt + +' AND prc.monetary_value IS NOT NULL '

    IF @process_owner IS NOT NULL 
        SET @sql_stmt = @sql_stmt + +' AND pch.process_owner = '''
            + @process_owner + ''''

    IF @risk_owner IS NOT NULL 
        SET @sql_stmt = @sql_stmt + +' AND prd.risk_owner = ''' + @risk_owner
            + ''''

    IF @risk_control_id IS NOT NULL 
        SET @sql_stmt = @sql_stmt + +' AND prc.risk_control_id = '
            + CAST(@risk_control_id AS VARCHAR) 
             


/*
 EXEC spa_print @sql_stmt0
 EXEC spa_print @sql_stmt
 EXEC spa_print @sql_stmt2
*/
--select * from #tempControls



    EXEC (@sql_stmt0 + @sql_stmt + @sql_stmt2)

--select * from #tempControls

    SELECT  a.risk_control_id,
            MAX(DATEADD(dd, -r.no_of_days, a.as_of_date)) Remind,
            r.risk_control_email_id,
            k.as_of_date,
            r.control_status,
			 dbo.FNADateFormat(@as_of_date) 'remiderDate'	--+ '-'+ cast(a.risk_control_id as varchar) 'remiderDate'						
		--dbo.FNADateFormat(@as_of_date) 'remiderDate'
    INTO    #reminder1
    FROM    #tempControls a
            INNER JOIN -- process_risk_controls_reminders r on r.risk_control_id = a.risk_control_id
            process_risk_controls_email r ON r.risk_control_id = a.risk_control_id
            LEFT OUTER JOIN process_risk_controls_reminders_acknowledge k ON  k.risk_control_reminder_id = r.risk_control_email_id
                                                                              AND k.as_of_date = a.as_of_date
			--INNER JOIN application_role_user u ON r.inform_role = u.role_id
    WHERE   k.as_of_date IS NULL -- dont show the ones which has already been acknowledged
			AND control_status = -5  --  controls status for reminder is -5
			-- Discard the reminder which has already been entered in the message_board table.
			--AND NOT EXISTS(SELECT risk_control_email_id FROM message_board m WHERE r.risk_control_email_id = m.risk_control_email_id)
			--AND NOT EXISTS(SELECT reminderDate FROM message_board m WHERE dbo.FNADateFormat(@as_of_date)+'-'+cast(a.risk_control_id as varchar)= m.reminderDate)
			AND dbo.FNADateFormat(DATEADD(dd, -r.no_of_days, a.as_of_date)) = dbo.FNADateFormat(@as_of_date)
    GROUP BY a.risk_control_id,
            r.risk_control_email_id,
            k.as_of_date,
            r.control_status
    HAVING  MAX(DATEADD(dd, -r.no_of_days, a.as_of_date)) <= @as_of_date

--select * from #reminder1
--	select * from #reminder1

--select * from #reminder1 --vk
-- 1. Calc monetary penalty values
-- 2. Input monetary values from front end
-- 3. add filters and sort orders

    SELECT  r1.risk_control_id,
			r1.risk_control_email_id,
            r1.remiderDate,
            r1.Remind,
            r1.control_status
    INTO    #reminder
    FROM    ( SELECT    risk_control_id,
                        MAX(Remind) remind_date
              FROM      #reminder1
              GROUP BY  risk_control_id
            ) r
            INNER JOIN #reminder1 r1 ON r1.risk_control_id = r.risk_control_id
                                        AND r1.Remind = r.remind_date
 	--select * from #reminder1

    SET @penalty_stmt = ' cast(case when (isnull(prca.monetary_value, #tempControls.monetary_value) is not null and (#tempControls.as_of_date < case when (isnull(prca.control_status, 525) IN (728, 729)) then prca.update_ts else getdate() end) and monetary_value_frequency_id is not null) then
				case monetary_value_frequency_id when 700 then datediff(dd,#tempControls.as_of_date, case when (isnull(prca.control_status, 525) IN (728, 729)) then prca.update_ts else getdate() end)
						 		 when 701 then datediff(ww,#tempControls.as_of_date, case when (isnull(prca.control_status, 525) IN (728, 729)) then prca.update_ts else getdate() end) + 1
						 		 when 703 then datediff(mm,#tempControls.as_of_date, case when (isnull(prca.control_status, 525) IN (728, 729)) then prca.update_ts else getdate() end) + 1
						 		 when 704 then datediff(qq,#tempControls.as_of_date, case when (isnull(prca.control_status, 525) IN (728, 729)) then prca.update_ts else getdate() end) + 1
						 		 when 705 then (datediff(yy,#tempControls.as_of_date, case when (isnull(prca.control_status, 525) IN (728, 729)) then prca.update_ts else getdate() end)/2) + 1
					  	 		 when 706 then datediff(yy,#tempControls.as_of_date, case when (isnull(prca.control_status, 525) IN (728, 729)) then prca.update_ts else getdate() end) + 1
				else 1 end * coalesce(prca.monetary_value, #tempControls.monetary_value, 0)			
		       else coalesce(prca.monetary_value, #tempControls.monetary_value, 0) end as float)'
   
    IF UPPER(@reminder_flag) = 'N' 
        SET @sql_stmt_top = ' TOP 1 '
    ELSE 
        SET @sql_stmt_top = ''

    SET @sql_stmt = 'SELECT ' + @sql_stmt_top + '	
	#reminder.remiderDate,
	#tempControls.subsidiary_id,
	#tempControls.Subsidiary,
	#tempControls.perform_role_id,
	#tempControls.PerformRole,
	case when (''' + @reminder_flag
        + ''' = ''R'' AND #reminder.risk_control_id is not null) then 
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
	case when (''' + @reminder_flag
        + ''' = ''R'' AND #reminder.risk_control_id is not null) then ''n'' 
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
	case when (''' + @reminder_flag
        + ''' = ''R'' AND #reminder.risk_control_id is not null) then ''Reminder'' else ast.code end activity_status_desc, 
	(dbo.FNADateFormat(isnull(prca.as_of_date, #tempControls.as_of_date)) + '' <I>(By: '' + dbo.FNADateFormat(isnull(prca.exception_date, #tempControls.exception_date)) + '')</I>'') as as_of_date_display,
	dbo.FNAGetSQLStandardDate(#tempControls.as_of_date) as as_of_date_argument,
	CASE when (prca.exception_date < getdate()) then 1 else 0 end time_exception,
	isnull(isnull(prca.monetary_value, #tempControls.monetary_value), 0) monetary_value,
	
		' + @penalty_stmt
        + ' monetary_penalty,		
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
	#reminder.control_status control_status,
	prca.source,
	prca.status,
	prca.comments
	
from    #tempControls LEFT OUTER JOIN
	process_risk_controls_activities prca ON prca.risk_control_id = #tempControls.risk_control_id '
        + CASE WHEN UPPER(@reminder_flag) = 'R'
               THEN ' AND prca.as_of_date = #tempControls.as_of_date '
               ELSE ''
          END
        + '	LEFT OUTER JOIN application_users pUser ON prca.create_user = pUser.user_login_id LEFT OUTER JOIN
        application_users aUser ON prca.approved_by = aUser.user_login_id INNER JOIN
	static_data_value ast ON ast.value_id = isnull(prca.control_status, 725) LEFT OUTER JOIN
	#reminder ON #reminder.risk_control_id = #tempControls.risk_control_id ' 


    SET @sql_stmt = @sql_stmt + ' WHERE 1=1 ' 

    IF @reminder_flag IS NOT NULL 
        BEGIN
            IF UPPER(@reminder_flag) = 'R' 
                SET @sql_stmt = @sql_stmt + ' AND 
				(CONVERT(DATETIME,''' + @as_of_date
                    + ''', 102) < CONVERT(DATETIME, #tempControls.as_of_date, 102) AND 
								((prca.control_status IS NULL OR prca.control_status in (725, 726)) AND 
							 #reminder.risk_control_id is not null and #reminder.control_status = -5)) '
/*
-- vk
            IF @call_type = 4
                AND UPPER(@reminder_flag) = 'A' 
                SET @sql_stmt = @sql_stmt + ' AND ' + @penalty_stmt + ' <> 0 '
            ELSE 
                IF @call_type = 4
                    AND UPPER(@reminder_flag) <> 'A' 
                    SET @sql_stmt = @sql_stmt + ' AND ' + @penalty_stmt
                        + ' <> 0 '
*/
        END
   /* ELSE -- vk
        IF @call_type = 4 
            SET @sql_stmt = @sql_stmt + ' WHERE  ' + @penalty_stmt + ' <> 0 '*/


    IF @get_counts = 0 
        BEGIN
            IF @call_type = 1 
                SET @sql_stmt = @sql_stmt
                    + ' ORDER BY #tempControls.subsidiary_id, #tempControls.perform_role_id, #tempControls.run_frequency_id, #tempControls.risk_priority, #tempControls.risk_control_id'
/*    -- vk        IF @call_type = 2 
                SET @sql_stmt = @sql_stmt
                    + ' ORDER BY #tempControls.subsidiary_id, #tempControls.approve_role_id, #tempControls.run_frequency_id, #tempControls.risk_priority, #tempControls.risk_control_id'
            IF @call_type = 3 
                SET @sql_stmt = @sql_stmt
                    + ' ORDER BY #tempControls.subsidiary_id, #tempControls.run_frequency_id, #tempControls.risk_control_id'*/
        END

/*-- vk
    IF @get_counts IN ( 1, 2 ) 
        IF @process_table_insert_or_create = 'c' 
            SET @sql_stmt = 'select sub_name, stra_name, book_name, process_number, as_of_date as Date, '
                + CASE WHEN ( @get_counts = 1 )
                       THEN ' count(*) as total_rows '
                       ELSE ' sum(cast(monetary_penalty as float)) as total_values  '
                  END
                + ',activity_status,sum(exception_days) as exception_days'
                + CASE WHEN @process_table IS NOT NULL
                       THEN ' into ' + @process_table
                       ELSE ''
                  END + '  from (' + @sql_stmt
                + ') xx
		group by sub_name, stra_name, book_name, process_number, as_of_date,activity_status'
        ELSE 
            SET @sql_stmt = CASE WHEN @process_table IS NOT NULL
                                 THEN 'INSERT INTO ' + @process_table
                                 ELSE ''
                            END
                + ' select sub_name, stra_name, book_name, process_number, as_of_date as Date, '
                + CASE WHEN ( @get_counts = 1 )
                       THEN ' count(*) as total_rows '
                       ELSE ' sum(cast(monetary_penalty as float)) as total_values'
                  END
                + ',activity_status,sum(exception_days) as exception_days, control_status  from ('
                + @sql_stmt
                + ') xx
		group by sub_name, stra_name, book_name, process_number, prca.as_of_date,activity_status'
*/
--select * into tempControls  from #tempControls
--select * into reminder from #reminder
--select * from #tempControls
exec spa_print @sql_stmt
    EXEC (@sql_stmt)































