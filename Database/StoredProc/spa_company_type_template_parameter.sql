IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_company_type_template_parameter]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_company_type_template_parameter]
GO 

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go


--select * from company_template_parameter
--exec spa_company_type_template_parameter 'c',NULL,NULL,NULL,NULL,NULL
--exec spa_company_type_template_parameter 'm',NULL,NULL,NULL,NULL,NULL

CREATE proc [dbo].[spa_company_type_template_parameter]
@flag varchar(1),
@company_type_id int=null,
@section varchar(100)=null,
@process_id varchar(2000)=null,
@company_type_template_id varchar(100)=null,
@parameter_id int =null,
@parameter_name varchar(2000)=null,
@parameter_desc varchar(2000)=null,
@parameter_type varchar(2000)=null,
@value varchar(2000)=null,
@is_entity_name int =null
AS

DECLARE @sql_stmt varchar(1000)

SET @sql_stmt = '';

IF @flag='s'
BEGIN

SET @sql_stmt = 'select ctp.parameter_id [ParameterID] ,ctp.parameter_name [ParameterName],ctp.parameter_desc [ParameterDesc],ctp.value [Value],ctp.parameter_type [ParameterType],ctt.company_type_template_id [Comp Type Temp ID],is_entity_name [Entity]
from company_template_parameter ctp
inner join company_type_template ctt on ctp.company_type_template_id=ctt.company_type_template_id
inner join static_data_value sdv on sdv.value_id=ctt.company_type_id
--inner join company_template_parameter_value_tmp ctpvt on ctpvt.parameter_id=ctp.parameter_id

where 1=1'

if @company_type_id is not null 
BEGIN 
	SET @sql_stmt = @sql_stmt + ' and ctt.company_type_id=' + cast(@company_type_id as varchar)
END

if @section is not null 
BEGIN
	SET @sql_stmt = @sql_stmt + ' and ctt.section= ''' + cast(@section as varchar) + ''''
END

EXEC spa_print @sql_stmt
exec(@sql_stmt)



END


Else if @flag='a'
Begin

set @sql_stmt = 'select ctp.parameter_id [ParameterID] ,ctp.parameter_name [ParameterName],ctp.parameter_desc [ParameterDesc],ctpvt.parameter_value [Value],ctp.parameter_type [ParameterType],is_entity_name [Entity]
from company_template_parameter ctp
inner join company_type_template ctt on ctp.company_type_template_id=ctt.company_type_template_id
inner join static_data_value sdv on sdv.value_id=ctt.company_type_id
inner join company_template_parameter_value_tmp ctpvt on ctpvt.parameter_id=ctp.parameter_id

where 1=1'

If @company_type_id is not null 
Begin 
	set @sql_stmt = @sql_stmt + ' and ctt.company_type_id=' + cast(@company_type_id as varchar)
End

If @section is not null 
Begin
	set @sql_stmt = @sql_stmt + ' and ctt.section= ''' + cast(@section as varchar) + ''''
End

If @process_id is not null 
Begin
	set @sql_stmt = @sql_stmt + ' and ctpvt.process_id= ''' + cast(@process_id as varchar(1000)) + ''''
End

EXEC spa_print @sql_stmt
exec(@sql_stmt)

End

ELSE IF @flag='i'
BEGIN

insert into company_template_parameter (company_type_template_id,parameter_name,parameter_desc,parameter_type,value,is_entity_name)
				 values(@company_type_template_id,@parameter_name,@parameter_desc,@parameter_type,@value,@is_entity_name)

IF @@ERROR <> 0
			BEGIN
				EXEC spa_ErrorHandler @@ERROR, "Emissions Vendor Setup", 
						"spa_company_type_template_parameter", "DB Error", 
						"Errors Founnd While Inserting Data ", ''

				
			END
Else
				
			BEGIN
				EXEC spa_ErrorHandler @@ERROR, "Emissions Vendor Setup", 
						"spa_company_type_template_parameter", "Success", 
						"Success", ''
				

			END

EXEC spa_print @sql_stmt
exec(@sql_stmt)	
END

ELSE IF @flag='u'
BEGIN

 update company_template_parameter 
				SET
					parameter_name = @parameter_name,
					parameter_desc = @parameter_desc,
					parameter_type = @parameter_type,
					value = @value,
					is_entity_name = @is_entity_name
				Where 
					parameter_id = @parameter_id	

IF @@ERROR <> 0
			BEGIN
				EXEC spa_ErrorHandler @@ERROR, "Emissions Vendor Setup", 
						"spa_company_type_template_parameter", "DB Error", 
						"Errors Founnd While Updating Data ", ''

				
			END
Else
				
			BEGIN
				EXEC spa_ErrorHandler @@ERROR, "Emissions Vendor Setup", 
						"spa_company_type_template_parameter", "Success", 
						"Success", ''
				

			END				

END

ELSE IF @flag='d'
BEGIN

				delete company_template_parameter 
				Where 
					parameter_id = @parameter_id



IF @@ERROR <> 0
			BEGIN
				EXEC spa_ErrorHandler @@ERROR, "Emissions Vendor Setup", 
						"spa_company_type_template_parameter", "DB Error", 
						"Errors Founnd While Inserting Data ", ''

				
			END
Else
				
			BEGIN
				EXEC spa_ErrorHandler @@ERROR, "Emissions Vendor Setup", 
						"spa_company_type_template_parameter", "Success", 
						"Success", ''
				

			END				

END

ELSE IF @flag='m'
BEGIN

SET @sql_stmt = 'select 
		ctp.parameter_id [Parameter ID],
		ctp.company_type_template_id [Company Type Temp Param ID],
		ctp.parameter_name [Parameter Name],
		ctp.parameter_desc [Parameter Desc],
		ctp.parameter_type [Parameter Type],
		ctp.value [Parameter Value],
		ctp.is_entity_name [Is Entity],
		ctt.company_type_template_id,
		ctt.company_type_id,
		ctt.section,
		ctt.parent_company_type_template_id

from company_template_parameter ctp
join company_type_template ctt on ctt.company_type_template_id=ctp.company_type_template_id
where ctp.company_type_template_id='+ cast(@company_type_template_id as varchar)
	
EXEC spa_print @sql_stmt
exec(@sql_stmt)				

END
 if @flag='c'
Begin

 select * from company_template_parameter where parameter_id=@parameter_id
End













