IF OBJECT_ID(N'[dbo].[spa_process_requirements_main]', N'P') IS NOT NULL
drop procedure [dbo].[spa_process_requirements_main]
set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go




create  procedure [dbo].[spa_process_requirements_main]
@flag char(1),
@requirements_id int=NULL,
@standard_id int=NULL,
@requirements_name varchar(50)=NULL,
@requirements_group_id int=NULL,
@standard_revision_id int=NULL
AS
declare @sql_stmt varchar(5000)
if @flag='s'
begin
		
	set @sql_stmt = 'Select  prm.requirements_id [Requirements ID], prm.requirements_name [Requirements Name],
			rg.requirements_group_name [Group Name], 
           standard_description [Revision Description]
			From process_requirements_main prm
			LEFT JOIN requirements_group rg on prm.requirements_group_id = rg.requirements_group_id 
            INNER JOIN process_standard_revisions psr on psr.standard_revision_id=prm.standard_revision_id
           where 1=1';
--	if @standard_id is not null
	--	set @sql_stmt=@sql_stmt + ' and prm.standard_id= '+ cast(@standard_id as varchar)
    if @standard_revision_id is not null
		set @sql_stmt=@sql_stmt + ' and prm.standard_revision_id= '+ cast(@standard_revision_id as varchar)
	if @requirements_group_id is not null
		set @sql_stmt = @sql_stmt + ' and prm.requirements_group_id ='+ cast(@requirements_group_id as varchar)
exec spa_print @sql_stmt
exec(@sql_stmt)

end

if @flag='a'
	begin
		Select  requirements_id, 
			standard_revision_id,
			requirements_name,requirements_group_id
		From process_requirements_main
		where requirements_id=@requirements_id
	end

Else if @flag='i'
	begin
		Insert Into process_requirements_main(
			standard_revision_id,
			requirements_name,requirements_group_id)
		Values(
			@standard_revision_id,
			@requirements_name,@requirements_group_id)

		If @@ERROR <> 0
			Exec spa_ErrorHandler @@ERROR, "process_requirements_main", 
					"spa_process_requirements_main", "DB Error", 
					"Insert of process requirements main Failed.", ''
		else
			Exec spa_ErrorHandler 0, 'process_requirements_main', 
					'spa_process_requirements_main', 'Success', 
					'process requirements main successfully Inserted', ''
	end

Else if @flag='u'
	begin
		Update process_requirements_main
		set 	
			standard_revision_id=@standard_revision_id,
			requirements_name=@requirements_name,
			requirements_group_id=@requirements_group_id
		where 
			requirements_id=@requirements_id

		If @@ERROR <> 0
			Exec spa_ErrorHandler @@ERROR, "process_requirements_main", 
					"spa_process_requirements_main", "DB Error", 
					"Update of process requirements main failed.", ''
		else
			Exec spa_ErrorHandler 0, 'process_requirements_main', 
					'spa_process_requirements_main', 'Success', 
					'process requirements main successfully updated.', ''
	end

Else if @flag='d'
	begin
		delete process_requirements_main
		where 
			requirements_id=@requirements_id

		If @@ERROR <> 0
			Exec spa_ErrorHandler @@ERROR, "process_requirements_main", 
					"spa_process_requirements_main", "DB Error", 
					"Update of process requirements main failed.", ''
		else
			Exec spa_ErrorHandler 0, 'process_requirements_main', 
					'spa_process_requirements_main', 'Success', 
					'process requirements main successfully updated.', ''
	end




