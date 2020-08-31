if object_id('[dbo].[spa_process_risk_controls_email_status]','p') is not null
DROP PROCEDURE [dbo].[spa_process_risk_controls_email_status]
go

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

--exec spa_process_risk_controls_email_status 'a'
Create PROCEDURE [dbo].[spa_process_risk_controls_email_status]
@flag char(1),
@risk_control_email_status_id int =NULL,
@risk_control_id int =NULL,
@as_of_date datetime =NULL,
@control_status int =NULL,
@email_message varchar(255) =NULL,
@email_ref varchar(255)=NULL,
@inform_role int =NULL,
@email_status char(1)=NULL

as
if @flag='s' 
begin
	select risk_control_email_status_id ID,risk_control_id,as_of_date [As of Date],control_status [Control Status],email_message [Message],email_ref [Refrence],inform_role [Inform Role],email_status [Email Status]
	from process_risk_controls_email_status
	where risk_control_id=@risk_control_id

END
if @flag='a' 
begin
	select risk_control_email_status_id ID, risk_control_id,as_of_date [As of Date],control_status [Control Status],email_message [Message],email_ref [Refrence],inform_role [Inform Role],email_status [Email Status]
	from process_risk_controls_email_status
	where risk_control_email_status_id=@risk_control_email_status_id

END
if @flag='i'
begin

INSERT  process_risk_controls_email_status(
			risk_control_id,
			as_of_date,
			control_status,
			email_message,
			email_ref,
			inform_role,
			email_status
		)
VALUES 	(
			@risk_control_id,
			@as_of_date,
			@control_status,
			@email_message,
			@email_ref,
			@inform_role,
			@email_status
		)
		If @@ERROR <> 0
				Exec spa_ErrorHandler @@ERROR, "Process Risk Control Email Status", 
					"spa_process_risk_controls_email_status", "DB Error", 
					"Error on Inserting Risk Control Email Status.", ''
			else
				Exec spa_ErrorHandler 0, 'Process Risk Control Email Status', 
						'spa_process_risk_controls_email_status', 'Success', 
						'Risk Control Email Status successfully inserted.', ''
END
if @flag='u'
begin

	UPDATE	process_risk_controls_email_status
		set risk_control_id=@risk_control_id ,
			as_of_date=@as_of_date,
			control_status=@control_status,
			email_message=@email_message,
			email_ref=@email_ref,
			inform_role=@inform_role,
			email_status=@email_status
		where risk_control_email_status_id=@risk_control_email_status_id
	
	If @@ERROR <> 0
				Exec spa_ErrorHandler @@ERROR, "Process Risk Control Email Status", 
					"spa_process_risk_controls_email_status", "DB Error", 
					"Error on updating Risk Control Email Status.", ''
	else
				Exec spa_ErrorHandler 0, 'Process Risk Control Email Status', 
						'spa_process_risk_controls_email_status', 'Success', 
						'Risk Control Email Status successfully updated.',''
END
if @flag='d'
begin
	delete process_risk_controls_email_status
	where risk_control_email_status_id=@risk_control_email_status_id
	If @@ERROR <> 0
				Exec spa_ErrorHandler @@ERROR, "Process Risk Control Email Status", 
						"spa_process_risk_controls_email_status", "DB Error", 
					"Error on deleteing Risk Control Email Status.", ''
	else
				Exec spa_ErrorHandler 0, 'Process Risk Control Email Status', 
						'spa_process_risk_controls_email_status', 'Success', 
						'Risk Control Email Status successfully deleted.',''
end

