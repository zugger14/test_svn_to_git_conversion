IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_user_defined_group_detail]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_user_defined_group_detail]
GO 


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/**
	Generic stored procedure for UDF group

	Parameters 
	@flag : 
			- i - Inserts user defined group detail
			- u - Updates user defined group detail
			- s - Returns user defined group detail data according to different filters
			- d - Deletes user defined group detail

	@user_defined_group_detail_id : User Defined Group Detail Id
	@user_defined_group_id : User Defined Group Id
	@rec_generator_id : Rec Generator Id
	@user_name : User Name

*/

create proc [dbo].[spa_user_defined_group_detail]	@flag as NCHAR(1),
                        @user_defined_group_detail_id NVARCHAR(MAX),	
						@user_defined_group_id int ,									
						@rec_generator_id NVARCHAR(MAX)=null,				
						@user_name NVARCHAR(50) = null
AS 


select @user_name= dbo.fnadbuser()
if @flag='i'
BEGIN
declare @sql1 as NVARCHAR(MAX)

		set @sql1='INSERT INTO user_defined_group_detail
							(
							user_defined_group_id,
							rec_generator_id
							)
							select 
						'+cast(@user_defined_group_id as NVARCHAR)+', rg.generator_id
							from rec_generator rg
							left join user_defined_group_detail usdf on 
							usdf.rec_generator_id=rg.generator_id
							and usdf.user_defined_group_id='+cast(@user_defined_group_id as NVARCHAR)+'
							and usdf.create_user='''+@user_name+'''
							where generator_id in ('+@rec_generator_id+') and usdf.user_defined_group_detail_id is null'

		  exec(@sql1)
		If @@Error <> 0
				Exec spa_ErrorHandler @@Error, 'EmissionSourceModel', 
						'spa_ems_source_model_program', 'DB Error', 
						'Failed to insert defination value.', ''
			Else
				Exec spa_ErrorHandler 0, 'EmissionSourceModel', 
						'spa_ems_source_model_program', 'Success', 
						'Defination data value inserted.', ''
	--END
END
ELSE IF @flag='u'
BEGIN

	update	 
		user_defined_group_detail
	set
        
        user_defined_group_id = @user_defined_group_id,	
		rec_generator_id=@rec_generator_id
	
	where
		user_defined_group_detail_id= @user_defined_group_detail_id


		If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, "Ems Source Model Program", 
		"spa_ems_source_model_program", "DB Error", 
		"Error Updating Ems Source Model Program Information.", ''
	else
		Exec spa_ErrorHandler 0, 'Ems Source Model Program', 
		'spa_meter', 'Success', 
		'Ems Source Model Program Information successfully Updated.',''

END
ELSE IF @flag='s'
BEGIN

Set @sql1 ='select ud.user_defined_group_detail_id[Group Detail ID],
           ud.user_defined_group_id [Group ID],
           uh.user_defined_group_name [Group Name], 
           ud.rec_generator_id [Rec Generator ID],
		   rg.name [Source/Sink Name]                  
   from
          user_defined_group_detail ud inner join user_defined_group_header uh on ud.user_defined_group_id=uh.user_defined_group_id
										inner join rec_generator rg on ud.rec_generator_id=rg.generator_id
			

   where  ud.user_defined_group_id=uh.user_defined_group_id'
   	
If @user_defined_group_detail_id IS NOT NULL
		SET @sql1 = @sql1 + ' AND ud.user_defined_group_detail_id = ' + CAST(@user_defined_group_detail_id AS NVARCHAR)

If @user_defined_group_id IS NOT NULL
		SET @sql1 = @sql1 + ' AND ud.user_defined_group_id = ' + CAST(@user_defined_group_id AS NVARCHAR)
 
		SET @sql1 = @sql1 + ' order by rg.name '		
--print(@sql)
exec(@sql1)
END

ELSE IF @flag='d'
BEGIN
  
 SET @sql1 ='DELETE FROM user_defined_group_detail WHERE 1=1'
            
 SET @sql1 = @sql1 + ' AND user_defined_group_detail_id in(' + @user_defined_group_detail_id+')'
 EXEC spa_print @sql1
 exec(@sql1)

If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, "Ems Source Model Program", 
		"spa_ems_source_model_program", "DB Error", 
		"Error Updating Ems Source Model Program Information.", ''
	else
		Exec spa_ErrorHandler 0, 'Ems Source Model Program', 
		'spa_meter', 'Success', 
		'Ems Source Model Program Information successfully Deleted.',''
   
END



















