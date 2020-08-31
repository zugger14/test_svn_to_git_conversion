/****** Object:  StoredProcedure [dbo].[spa_process_risk_controls_email]  Script Date: 10/19/2008 11:49:38 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_process_risk_controls_email]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_process_risk_controls_email]

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go



--exec spa_process_risk_controls_email 's', '', 905
CREATE  PROCEDURE [dbo].[spa_process_risk_controls_email]
@flag char(1),
@risk_control_email_id int =NULL,
@risk_control_id int =NULL,
@control_status int =NULL,
@inform_role int =NULL,
@communication_type int=NULL,
@no_of_days  int=NULL,
@inform_user VARCHAR(50) = NULL
as
if @flag='s' 
begin
	select risk_control_email_id ID,risk_control_id,control_status,s1.code [Control Status],inform_role,communication_type,
    s.code [Communication Type],r.role_name [Inform Role],no_of_days [No. of Reminder Days], e.inform_user [Inform User]
	from process_risk_controls_email e 
		left outer join static_data_value s on e.communication_type=s.value_id
		left outer join static_data_value s1 on e.control_status=s1.value_id
		left outer join application_security_role r on e.inform_role=r.role_id
	where risk_control_id=@risk_control_id

END
if @flag='a' 
begin
	select risk_control_email_id ID,risk_control_id,control_status [Control Status],inform_role [Inform Role]
	, communication_type [Communication Type],no_of_days [No of Days], inform_user [Inform User]
	from process_risk_controls_email
	where risk_control_email_id=@risk_control_email_id

END
if @flag='i'
begin

INSERT  process_risk_controls_email(
				risk_control_id,
				control_status,
				inform_role,
				communication_type,
                no_of_days,
                inform_user 
			)
VALUES 		(
			@risk_control_id,
			@control_status,
			@inform_role,
			@communication_type,
			@no_of_days,
			@inform_user 
		)
		If @@ERROR <> 0
				Exec spa_ErrorHandler @@ERROR, "Process Risk Control Email", 
					"spa_process_risk_controls_email_status", "DB Error", 
					"Error on Inserting Risk Control Email.", ''
			else
				Exec spa_ErrorHandler 0, 'Process Risk Control Email', 
						'spa_process_risk_controls_email_status', 'Success', 
						'Risk Control Email successfully inserted.', ''
END
if @flag='u'
begin

	UPDATE	process_risk_controls_email
		set risk_control_id=@risk_control_id ,
			control_status=@control_status,
			inform_role=@inform_role,
			communication_type=@communication_type,
            no_of_days =@no_of_days, 
            inform_user = @inform_user
		where risk_control_email_id=@risk_control_email_id
	
	If @@ERROR <> 0
				Exec spa_ErrorHandler @@ERROR, "Process Risk Control Email", 
					"spa_process_risk_controls_email", "DB Error", 
					"Error on updating Risk Control Email.", ''
	else
				Exec spa_ErrorHandler 0, 'Process Risk Control Email', 
						'spa_process_risk_controls_email', 'Success', 
						'Risk Control Email successfully updated.',''
END
if @flag='d'
begin
	delete process_risk_controls_email
	where risk_control_email_id=@risk_control_email_id
	If @@ERROR <> 0
				Exec spa_ErrorHandler @@ERROR, "Process Risk Control Email", 
						"spa_process_risk_controls_email", "DB Error", 
					"Error on deleteing Risk Control Email.", ''
	else
				Exec spa_ErrorHandler 0, 'Process Risk Control Email', 
						'spa_process_risk_controls_email', 'Success', 
						'Risk Control Emailsuccessfully deleted.',''
end



