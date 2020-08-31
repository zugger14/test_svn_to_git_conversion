IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_company_type_source_model]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_company_type_source_model]
GO
/****** Object:  StoredProcedure [dbo].[spa_company_type_source_model]    Script Date: 06/10/2010 11:56:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[spa_company_type_source_model]
@flag varchar(1),
@company_type_id int =null,
@source_model_id varchar(250)=null,
@company_type_source_model_id varchar(500) = null,
@keyword1 varchar(100)= null,
@keyword2 varchar(100)= null,
@keyword3 varchar(100)= null,
@keyword4 varchar(100)= null
As
	declare @sql_stmt varchar(1000)
if @flag='s'

Begin

	set @sql_stmt='
	select ctsm.company_type_source_model_id,esm.ems_source_model_id as [Ems Model ID],
	esm.ems_source_model_name as [Source Model Name],
	sd.code as [Company Type]
	from company_type_source_model ctsm 
	join ems_source_model esm on ems_source_model_id=ctsm.source_model_id
	LEFT JOIN static_data_value sd on sd.value_id=ctsm.company_type_id
	where 1=1'
	+case when @company_type_id is not null then ' and company_type_id=' + cast(@company_type_id as varchar) else '' end
	+case when @keyword1 is not null then ' and esm.keyword1 like ''%'+cast(@keyword1 as varchar)+'%''' else '' end
	+case when @keyword2 is not null then ' and esm.keyword2 like ''%'+cast(@keyword2 as varchar)+'%''' else '' end
	+case when @keyword3 is not null then ' and esm.keyword3 like ''%'+cast(@keyword3 as varchar)+'%''' else '' end
	+case when @keyword4 is not null then ' and esm.keyword4 like ''%'+cast(@keyword4 as varchar)+'%''' else '' end
EXEC spa_print @sql_stmt
exec(@sql_stmt)

	

End

ELSE if @flag = 'i'
begin
		
	set @sql_stmt=' insert into company_type_source_model(company_type_id,source_model_id)
					select '+cast(@company_type_id as varchar)+',ems_source_model_id from 
					ems_source_model a where ems_source_model_id in('+@source_model_id+') 
					and not exists (select source_model_id from company_type_source_model b WHERE b.source_model_id = a.ems_source_model_id AND b.company_type_id='+cast(@company_type_id as varchar)+')'
		exec(@sql_stmt)
EXEC spa_print '@sql_stmt'

		If @@ERROR <> 0
					begin
						EXEC spa_ErrorHandler @@ERROR, "Emissions Vendor Setup", 
								"spa_company_type_source_model", "DB Error", 
								"Source model Data Insert  failed.", ''
						return
					end
		else
		begin
		EXEC spa_ErrorHandler 0, 'Emissions Vendor Setup', 
								'spa_company_type_source_model', 'Success', 
								'Source model Data Successfully Inserted', ''
		end
END

ELSE if @flag = 'd'
begin
	set @sql_stmt='delete from company_type_source_model where company_type_source_model_id in('+@company_type_source_model_id+')'
--print @sql_stmt
exec(@sql_stmt)

		If @@ERROR <> 0
					begin
						EXEC spa_ErrorHandler @@ERROR, "Emissions Vendor Setup", 
								"spa_company_type_source_model", "DB Error", 
								"Source model Data Insert  failed.", ''
						return
					end
		else
		begin
		EXEC spa_ErrorHandler 0, 'Emissions Vendor Setup', 
								'spa_company_type_source_model', 'Success', 
								'Source model Data Successfully Deleted', ''
		end


END
	












