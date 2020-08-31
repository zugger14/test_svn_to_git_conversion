if object_id('[dbo].[spa_get_audit_on_activity]') is not null
drop proc [dbo].[spa_get_audit_on_activity]
go

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go





create proc [dbo].[spa_get_audit_on_activity]
          @risk_control_activity_id int = null
          
         

AS
BEGIN
declare @sqlStmt varchar(2000)

			set @sqlStmt = 'SELECT  (CAST(prc.risk_control_id AS varchar) + ''- '' + DBO.FNAGetActivityName(prc.risk_control_id)) AS Activity,'

			set   @sqlStmt = @sqlStmt + 'dbo.FNADateFormat(prcau.as_of_date) As Date,'
			set    @sqlStmt = @sqlStmt +' ps.code as ''Prior Status'','
			set    @sqlStmt = @sqlStmt + 'cs.code as ''Current Status'','

			set   @sqlStmt = @sqlStmt + 'prcau.activity_desc as ''Description'','
			set   @sqlStmt = @sqlStmt + 'isnull((isnull(pUser.user_l_name,'''') + '', '' + pUser.user_f_name + '' '' + isnull(pUser.user_m_name,'''')), '''')  AS ''Run By'','
			set   @sqlStmt = @sqlStmt + 'dbo.FNADateTimeFormat(prcau.create_ts, 1) AS ''Run Date'' '

			set   @sqlStmt = @sqlStmt + 'FROM 	process_risk_controls_activities_audit prcau INNER JOIN 


			process_risk_controls prc ON prc.risk_control_id = prcau.risk_control_id INNER JOIN 

			static_data_value ps ON ps.value_id = prcau.control_prior_status INNER JOIN 
			static_data_value cs ON cs.value_id = prcau.control_new_status LEFT OUTER JOIN

			application_users pUser ON pUser.user_login_id = prcau.create_user ' 

            
set   @sqlStmt = @sqlStmt +'WHERE  prcau.risk_control_activity_id =' + cast(@risk_control_activity_id as varchar)
--set   @sqlStmt = @sqlStmt +' AND prcau.as_of_date =' + ''''+dbo.FNAGetSQLStandardDate(@asOfDate)+''''   

set   @sqlStmt = @sqlStmt +' ORDER BY prcau.risk_control_id, prcau.as_of_date, risk_control_activity_audit_id desc'
            
EXEC spa_print @sqlStmt
exec(@sqlStmt)

END



