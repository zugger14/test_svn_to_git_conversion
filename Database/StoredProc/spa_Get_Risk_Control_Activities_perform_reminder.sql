IF OBJECT_ID('[dbo].[spa_Get_Risk_Control_Activities_perform_reminder]','p') IS NOT NULL
DROP PROC [dbo].[spa_Get_Risk_Control_Activities_perform_reminder]
GO
/*Author : Vishwas Khanal
  Desc	 : Compliance Renovation. This SP will fetch all the reminders on the given date for the asigned User/Role.
  Dated	 : 10.July.2009
*/

CREATE PROC [dbo].[spa_Get_Risk_Control_Activities_perform_reminder]
	@user_login_id As varchar(50),
	@as_of_date As varchar(20),
	@sub_id As varchar(250),
	@run_frequency As varchar(20),
	@risk_priority As varchar(20),
	@role_id As varchar(20),
	@unapporved_flag As char,
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
	@as_of_date_to As varchar(20)=NULL,
	@message_id INT = NULL 
As

SET NOCOUNT ON

SELECT DISTINCT 
ISNULL(dbo.FNAGetSubsidiary(prc.fas_book_id,'a'),'NOT APPLICABLE') [Subsdiary],
dbo.FNAComplianceHyperlink('a',366,ISNULL(asr.role_name,''), CAST(prce.inform_role AS VARCHAR),DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT) [Role],
prc.run_frequency  [Frequency],
sdv.code  [Priority],
dbo.FNAComplianceHyperlink('b',10101125,dbo.FNAGetActivityHierarchy(prc.risk_control_id),'''44''',CAST(prc.risk_control_id as varchar),default,default,default,default,default)   [Activity],	
'0.0'  [Penalty/Fees],
dbo.FNADateFormat(dbo.FNANextInstanceCreationDate(prc.risk_control_id))+'(By:'+dbo.FNADateFormat(DATEADD(dd,prc.threshold_days,dbo.FNANextInstanceCreationDate(prc.risk_control_id)))+')'  [Date],            
dbo.FNAComplianceHyperlink('a',368, '<IMG SRC=''./adiha_pm_html/process_controls/steps.jpg''>', CAST(prc.risk_control_id as varchar),default,default,default,default,default,default)  [Steps],
dbo.FNAComplianceHyperlink('g',801,'Acknowledge',CAST(prce.risk_control_email_id AS VARCHAR),''+dbo.FNADateFormat(@as_of_date)+'','1',CAST(@message_id AS VARCHAR) , @user_login_id ,default,default) 
 [Action]
--prce.inform_role [roleId],isnull(prce.inform_user,aru.user_login_id) [user]
FROM 
process_risk_controls prc
INNER JOIN process_risk_controls_email prce ON prc.risk_control_id=prce.risk_control_id
INNER JOIN application_role_user aru 
ON CAST(aru.role_id AS VARCHAR) LIKE ISNULL(CAST(prce.inform_role AS VARCHAR),'%')
								AND aru.user_login_id LIKE ISNULL(prce.inform_user,'%')
LEFT OUTER JOIN application_security_role asr ON 
							asr.role_id = prce.inform_role 
INNER JOIN process_risk_description prd ON prd.risk_description_id = prc.risk_description_id
INNER JOIN static_data_value sdv ON sdv.value_id = prd.risk_priority
WHERE 
--DATEADD(dd,-prce.no_of_days,dbo.FNADateFormat(dbo.FNANextInstanceCreationDate(prce.risk_control_id)))=@as_of_date
dbo.FNANextInstanceCreationDate(prce.risk_control_id) = @as_of_date
AND prce.control_status = -5
AND prce.communication_type IN (751,752)
AND NOT EXISTS (
SELECT risk_control_reminder_id FROM process_risk_controls_reminders_acknowledge ack WHERE ack.risk_control_reminder_id = prce.risk_control_email_id)
and ISNULL(prce.inform_user,aru.user_login_id) = @user_login_id



