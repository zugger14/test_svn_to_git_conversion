
if object_id('[dbo].[spa_compliance_std_steps]','p') is not null
drop proc [dbo].[spa_compliance_std_steps]
go
/*
Vishwas Khanal
Dated : 09.April.2009
Compliance Integration to TRM
*/

CREATE  proc [dbo].[spa_compliance_std_steps]	@flag as Char(1),
                        @risk_control_step_id int=null,
                        @requirement_revision_id int=null,
                        @step_sequence int=null,
						@step_desc1 varchar(250)=null,
                        @step_desc2 varchar(250)=null,
						@step_reference varchar(100)=null,				
						@user_name varchar(50) = null
AS 
declare @sql varchar(5000)

if @flag='i'
BEGIN
INSERT INTO process_risk_std_steps
		(
        requirement_revision_id,
		step_sequence,
        step_desc1,
        step_desc2,
        step_reference,
		create_user,
		create_ts,
		update_user,
		update_ts	
		)
	values
		(
        @requirement_revision_id,
		@step_sequence,
        @step_desc1,
        @step_desc2,
        @step_reference,
		@user_name,
		getdate(),
		@user_name,
		getdate()		
		)
		
		If @@Error <> 0
		Exec spa_ErrorHandler @@Error, 'EmissionSourceModel', 
				'spa_ems_source_model_program', 'DB Error', 
				'Failed to insert defination value.', ''
	Else
		Exec spa_ErrorHandler 0, 'EmissionSourceModel', 
				'spa_ems_source_model_program', 'Success', 
				'Defination data value inserted.', ''
END

if @flag = 'u'
  BEGIN
   UPDATE process_risk_std_steps SET

      requirement_revision_id = @requirement_revision_id,
      step_sequence = @step_sequence,
      step_desc1 = @step_desc1,
      step_desc2 = @step_desc2,
      step_reference = @step_reference,
      create_user = @user_name,
      create_ts = getdate(),
      update_user = @user_name,
      update_ts = getdate()

    where risk_control_step_id = cast(@risk_control_step_id as varchar)
      
      If @@Error <> 0
		Exec spa_ErrorHandler @@Error, 'EmissionSourceModel', 
				'spa_ems_source_model_program', 'DB Error', 
				'Failed to insert defination value.', ''
	Else
		Exec spa_ErrorHandler 0, 'EmissionSourceModel', 
				'spa_ems_source_model_program', 'Success', 
				'Defination data value inserted.', ''
      
     
    
  END


if @flag = 's'
  BEGIN
   
set   @sql =  'select risk_control_step_id [ID],
                      requirement_revision_id [Requirement Revision ID],
                      step_sequence [Step Sequence],
                      step_desc1 [Description 1],
                      step_desc2 [Description 2],
                      step_reference [Reference] 
                                        from process_risk_std_steps where 1=1 '
if(@risk_control_step_id is not null)
set   @sql = @sql + ' AND risk_control_step_id =' + cast(@risk_control_step_id as varchar)
if(@requirement_revision_id is not null)

set   @sql = @sql + ' AND requirement_revision_id =' + cast(@requirement_revision_id as varchar)
 exec(@sql)     
     
    
  END


if @flag = 'd'
  BEGIN
   
    Delete  from process_risk_std_steps
      where risk_control_step_id = cast(@risk_control_step_id as varchar)
      
     If @@Error <> 0
		Exec spa_ErrorHandler @@Error, 'EmissionSourceModel', 
				'spa_ems_source_model_program', 'DB Error', 
				'Failed to insert defination value.', ''
	Else
		Exec spa_ErrorHandler 0, 'EmissionSourceModel', 
				'spa_ems_source_model_program', 'Success', 
				'Defination data value inserted.', ''  
    
  END

















