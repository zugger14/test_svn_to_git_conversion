IF OBJECT_ID(N'spa_requirements_group', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_requirements_group]
GO
 
CREATE PROCEDURE [dbo].[spa_requirements_group]
	@flag CHAR(1),
	@requirements_group_id INT = NULL,
	@requirements_group_name VARCHAR(250) = NULL
AS

if @flag='s'
Begin
	Select requirements_group_id [ID],requirements_group_name [Group Name]
	From requirements_group
End

else if @flag='a'
Begin
	Select requirements_group_id,requirements_group_name 
	From requirements_group
	Where requirements_group_id = @requirements_group_id
End

else if @flag='i'
Begin
	Insert Into requirements_group(
		requirements_group_name)		
	Values(
		@requirements_group_name)

	If @@ERROR <> 0
			Exec spa_ErrorHandler @@ERROR, "requirements_group", 
					"spa_requirements_group", "DB Error", 
					"Insert of requirements group Failed.", ''
		else
			Exec spa_ErrorHandler 0, 'requirements_group', 
					'spa_requirements_group', 'Success', 
					'requirements group successfully Inserted', ''
End

else if @flag='u'
Begin
	Update requirements_group
	Set requirements_group_name=@requirements_group_name
	Where requirements_group_id = @requirements_group_id

	If @@ERROR <> 0
			Exec spa_ErrorHandler @@ERROR, "requirements_group", 
					"spa_requirements_group", "DB Error", 
					"Update of requirements group failed.", ''
		else
			Exec spa_ErrorHandler 0, 'requirements_group', 
					'spa_requirements_group', 'Success', 
					'requirements group successfully updated.', ''
End

else if @flag='d'
Begin
	Delete requirements_group
	Where requirements_group_id = @requirements_group_id

	If @@ERROR <> 0
			Exec spa_ErrorHandler @@ERROR, "requirements_group", 
					"spa_requirements_group", "DB Error", 
					"Update of requirements group failed.", ''
		else
			Exec spa_ErrorHandler 0, 'requirements_group', 
					'spa_requirements_group', 'Success', 
					'requirements group successfully updated.', ''
End

