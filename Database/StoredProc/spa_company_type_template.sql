IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_company_type_template]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_company_type_template]
GO 

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go



CREATE proc [dbo].[spa_company_type_template]
@flag varchar(1),
@company_type_template_id int=null,
@company_type_id int =null,
@section varchar(100)=null,
@parent_company_type_template_id int =null
as

declare @sql_stmt varchar(1000)

if @flag='f'
Begin

set @sql_stmt = 'select company_type_template_id  from company_type_template'

if @company_type_template_id is not null 
begin 
	set @sql_stmt = @sql_stmt + ' company_type_template_id=' + cast(@company_type_template_id as int)
end

EXEC spa_print @sql_stmt
exec(@sql_stmt)
END

Else if @flag ='s'
Begin

--set @sql_stmt = 'select company_type_template_id [CompanyTypeID] ,company_type_id [CompanyType],section [Section],parent_company_type_template_id [ParentCompanyTemplateID]
--from company_type_template '

select ctt.company_type_template_id [Company Type Template ID],ctt.company_type_id [Company Type ID],stv.code [Company Type],ctt.section [Section],ctt.parent_company_type_template_id [Parent Company Template ID]
from company_type_template ctt 
join static_data_value stv  on ctt.company_type_id=stv.value_id


EXEC spa_print @sql_stmt
exec(@sql_stmt)

END
Else if @flag ='a'
Begin

set @sql_stmt = 'select company_type_template_id ,company_type_id ,section ,parent_company_type_template_id 
from company_type_template where company_type_template_id='+ cast(@company_type_template_id as varchar)

EXEC spa_print @sql_stmt
exec(@sql_stmt)

END

Else if @flag='i'

Begin
	insert into company_type_template(company_type_id,section,parent_company_type_template_id)
	values(@company_type_id,@section,@parent_company_type_template_id)

If @@ERROR <> 0
	begin
		Exec spa_ErrorHandler @@ERROR, "Emissions Wizard Setup", 
				"spa_company_type_template", "DB Error", 
				"Insert of spa_company_type_template  failed.", ''
		return
	end

		else Exec spa_ErrorHandler 0, 'Emissions Wizard Setup', 
				'spa_company_type_template', 'Success', 
				'spa_company_type_template  successfully inserted.', ''

End
Else if @flag='u'

Begin

update company_type_template set 
											--company_type_template_id=@company_type_template_id,
											company_type_id=@company_type_id,
											section=@section,
											parent_company_type_template_id=@parent_company_type_template_id

where company_type_template_id=@company_type_template_id

If @@ERROR <> 0
	begin
		Exec spa_ErrorHandler @@ERROR, "Emissions Wizard Setup", 
				"spa_company_type_template", "DB Error", 
				"Update of spa_company_type_template  failed.", ''
		return
	end

		else Exec spa_ErrorHandler 0, 'Emissions Wizard Setup', 
				'spa_company_type_template', 'Success', 
				'spa_company_type_template  successfully updated.', ''


End
Else if @flag='d'
Begin
		delete from company_type_template where company_type_template_id=@company_type_template_id
		
If @@ERROR <> 0
	begin
		Exec spa_ErrorHandler @@ERROR, "Emissions Wizard Setup", 
				"spa_company_type_template", "DB Error", 
				"Delete of spa_company_type_template  failed.", ''
		return
	end

		else Exec spa_ErrorHandler 0, 'Emissions Wizard Setup', 
				'spa_company_type_template', 'Success', 
				'spa_company_type_template  successfully deleted.', ''


End









