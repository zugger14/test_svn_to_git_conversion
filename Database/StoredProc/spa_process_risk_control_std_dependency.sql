/****** Object:  StoredProcedure [dbo].[spa_process_risk_control_std_dependency]  Script Date: 10/19/2008 11:49:38 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_process_risk_control_std_dependency]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_process_risk_control_std_dependency]

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

--exec spa_process_risk_control_std_dependency 'i',227,NULL,225,NULL, NULL,'farrms_admin'




CREATE PROCEDURE [dbo].[spa_process_risk_control_std_dependency] 
	@flag varchar(1),
    @requirements_revision_id int =NULL,
	@risk_control_id_dependent int =NULL,
    @requirements_revision_id_depend_on int =NULL,
    @requirement_revision_hierarchy_level int =NULL,
    @requirements_revision_dependency_id int =NULL,
    @user_name varchar(200)=null  
	
AS
declare @tmp_hierarchy_level int
--set @tmp_hierarchy_level =0	

 if(@flag = 'i')
 BEGIN



            SELECT @tmp_hierarchy_level=requirement_revision_hierarchy_level FROM process_risk_control_std_dependency
	        WHERE requirements_revision_dependency_id= @requirements_revision_id_depend_on
	 
	--print @tmp_hierarchy_level
		
	set @tmp_hierarchy_level=@tmp_hierarchy_level+1
	--print @tmp_hierarchy_level

             INSERT into process_risk_control_std_dependency
                     (requirements_revision_id,requirements_revision_id_depend_on,requirement_revision_hierarchy_level
                    ) 
                     VALUES(@requirements_revision_id,@requirements_revision_id_depend_on,@tmp_hierarchy_level)
			

  


         If @@Error <> 0
		Exec spa_ErrorHandler @@Error, 'EmissionSourceModel', 
				'spa_ems_source_model_program', 'DB Error', 
				'Failed to insert defination value.', ''
	Else
		Exec spa_ErrorHandler 0, 'EmissionSourceModel', 
				'spa_ems_source_model_program', 'Success', 
				'Defination data value inserted.', ''

 END

ELSE IF(@flag = 's')
 BEGIN

 select * from process_risk_control_std_dependency 
 where requirements_revision_id =  cast(@requirements_revision_id as varchar) 




 END



ELSE IF(@flag = 'd')
 BEGIN
			declare @tmp_cnt int
						
						
				
				select @tmp_cnt=count(requirements_revision_dependency_id)
						from process_risk_control_std_dependency 
						where requirements_revision_id_depend_on=@requirements_revision_dependency_id
				
				if @tmp_cnt>0
					BEGIN
						Exec spa_ErrorHandler -1, "Failed to Detele Dependency found .", 
							"spa_process_risk_control_std_dependency", "DB Error", 
							"Dependency Found.",''
					END
				ELSE
					BEGIN
						 DELETE FROM process_risk_control_std_dependency 
						 where requirements_revision_dependency_id = @requirements_revision_dependency_id



								 If @@Error <> 0
								Exec spa_ErrorHandler @@Error, 'Compliance Requirement', 
										'spa_process_risk_control_std_dependency', 'DB Error', 
										'Failed to Delete the value.', ''
							Else
								Exec spa_ErrorHandler 0, 'Compliance Requirement', 
										'spa_process_risk_control_std_dependency', 'Success', 
										'Data inserted Successfully.', ''
					END


 END



