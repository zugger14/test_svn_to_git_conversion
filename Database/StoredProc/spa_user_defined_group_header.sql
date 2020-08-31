IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_user_defined_group_header]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_user_defined_group_header]
GO 

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/**
	Generic stored procedure for UDF group header

	Parameters 
	@flag : 
		-i - Inserts user defined group header
		-u - Updates user defined group header
		-s - Returns user defined group header data according to different filters
		-d - Deletes  user defined group header
	@user_defined_group_id : User Defined Group Id
	@user_defined_group_name : User Defined Group Name
	@user_name : User Name



*/

CREATE proc [dbo].[spa_user_defined_group_header]
				 	@flag as NCHAR(1),
					@user_defined_group_id  int=NULL,
					@user_defined_group_name  NVARCHAR(500)=NULL,
                    @user_name NVARCHAR(50)=NULL
					

AS
if @user_name is null
	set @user_name=dbo.fnadbuser()

if @flag='i'
BEGIN
INSERT INTO user_defined_group_header(
        user_defined_group_name
		)
	values
		(
        @user_defined_group_name
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




ELSE IF @flag='u'
BEGIN

	update	 
		user_defined_group_header
	set
        
        
		user_defined_group_name=@user_defined_group_name
		
		
	where
		user_defined_group_id= @user_defined_group_id


		If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, 'SetupUserDefinedSourceGroup', 
		'spa_user_defined_group_header', 'DB Error', 
		"Error Updating Setup User Defined Group.", ''
	else
		Exec spa_ErrorHandler 0, 'SetupUserDefinedSourceGroup', 
		'spa_user_defined_group_header', 'Success', 
		'User Defined Grouped Header successfully Updated.',''

END

ELSE IF @flag='s'
BEGIN
declare @sqlstr NVARCHAR(MAX)
Set @sqlstr ='select user_defined_group_id,
           user_defined_group_name [Group]
          
   from
          user_defined_group_header         

   where  1=1'
+case when @user_name is not null then ' And update_user='''+@user_name+'''' else '' end
If @user_defined_group_id IS NOT NULL
		 SET @sqlstr = @sqlstr + ' AND user_defined_group_id = ' + CAST(@user_defined_group_id AS NVARCHAR)
		
exec(@sqlstr)

END

ELSE IF @flag='d'
BEGIN
  declare @sql NVARCHAR(MAX)
 SET @sql ='DELETE FROM user_defined_group_header WHERE 1=1'
            
 SET @sql = @sql + ' AND user_defined_group_id = ' + CAST(@user_defined_group_id AS NVARCHAR)
exec(@sql)

If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, "Ems Source Model Program", 
		"spa_ems_source_model_program", "DB Error", 
		"Error Updating Ems Source Model Program Information.", ''
	else
		Exec spa_ErrorHandler 0, 'Ems Source Model Program', 
		'spa_meter', 'Success', 
		'Ems Source Model Program Information successfully Deleted.',''
   
END








