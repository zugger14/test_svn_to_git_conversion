if object_id('[dbo].[spa_update_requirement_revision]','p') is not null
DROP procedure [dbo].[spa_update_requirement_revision]
go
set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go






CREATE procedure [dbo].[spa_update_requirement_revision]
@flag char(1)=null,
@risk_control_id int=null,
@requirements_revision_id int=null

AS

If @flag = 'u' 
BEGIN
   UPDATE  process_risk_controls 
     SET   requirements_revision_id = cast(@requirements_revision_id as varchar)
    WHERE  risk_control_id = cast(@risk_control_id as varchar) 
	
If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, 'Fas Link header table', 
				'spa_update_requirement_revision', 'DB Error', 
				'Data Update Failed.', ''
	Else
		Exec spa_ErrorHandler 0, @requirements_revision_id, 
				'spa_update_requirement_revision','Success' , 
				'Data Updated successfully..', ''

END

