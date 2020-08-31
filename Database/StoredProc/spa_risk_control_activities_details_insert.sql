if object_id('[dbo].[spa_risk_control_activities_details_insert]','p') is not null
drop proc [dbo].[spa_risk_control_activities_details_insert]
go
/*
Vishwas Khanal
Dated : 09.April.2009
Compliance Integration to TRM
*/


CREATE  proc [dbo].[spa_risk_control_activities_details_insert]
                     @flag char(1)= null, 
                     @riskControlId int = null,
                     @addriskControlId int=null,
                     @user_name VARCHAR(50) = null
                                       
AS

if @flag = 'i'
BEGIN




 INSERT INTO process_risk_controls_dependency(
        risk_control_id,
		risk_control_id_depend_on,
        create_user,
		create_ts,
		update_user,
		update_ts	
		)
	values
		(
        @riskControlId,
        @addriskControlId,
		@user_name,
		getdate(),
		@user_name,
		getdate()		
		)
		
		If @@Error <> 0
		Exec spa_ErrorHandler @@Error, 'SetupUserDefinedSourceGroup', 
				'spa_user_defined_group_header', 'DB Error', 
				'Failed to insert defination value.', ''
	    Else
		Exec spa_ErrorHandler 0, 'SetupUserDefinedSourceGroup', 
				'spa_user_defined_group_header', 'Success', 
				'Defination data value inserted.', ''
END

Else if @flag = 'd'
    BEGIN
       Delete from process_risk_controls_dependency where risk_control_id = cast(@riskControlId as varchar )
 
    END






