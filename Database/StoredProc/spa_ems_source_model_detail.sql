
/****** Object:  StoredProcedure [dbo].[spa_ems_source_model_detail]    Script Date: 03/25/2009 17:21:46 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_ems_source_model_detail]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_ems_source_model_detail]
/****** Object:  StoredProcedure [dbo].[spa_ems_source_model_detail]    Script Date: 03/25/2009 17:21:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec spa_ems_source_model_detail 's',30

--spa_ems_source_model_detail 's',1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,13
CREATE procedure [dbo].[spa_ems_source_model_detail]
@flag char(1),
@ems_source_model_id int=NULL,
@ems_source_model_detail_id int=NULL,
@curve_id int=null,
@uom_id int=null,
@estimation_type_value_id int=null,
@rating_value_id int=null,
@formula_reporting_period int=NULL,
@formula_forcast_reporting int=null,
@use_as_reporting_period char(1)=NULL,
@input_id int=null,
@program_scope_value_id int=null,
@credit_env_product int=null,
@credit_product_uom_id int=null
AS
BEGIN
DECLARE @sql varchar(8000)
DECLARE @new_id INT
IF @flag='s'	
BEGIN
set @sql='
	select ems_source_model_id [Model ID],ems_source_model_detail_id [ID],
	spcd.curve_name [Emission Type],su.uom_name UOM,sd.code [Estimation Type],sd1.code [Rating],
	case when f.formula_type=''n'' then ''Nested Formula'' else dbo.FNAFormulaFormat(f.formula, ''r'') end as  Formula, 
	case when f1.formula_type=''n'' then ''Nested Formula'' else dbo.FNAFormulaFormat(f1.formula,''r'') end as  [FCT Formula],use_as_reporting_period as [Reporting Period],
	ems.curve_id as [Curve ID]	
	from
		ems_source_model_detail ems inner join source_price_curve_def spcd on
		spcd.source_curve_def_id=ems.curve_id 
		left join source_uom su on su.source_uom_id=ems.uom_id
		left join static_data_value sd on sd.value_id=ems.estimation_type_value_id
		left join static_data_value sd1 on sd1.value_id=ems.rating_value_id
		left join formula_editor f on f.formula_id=formula_reporting_period
		left join static_data_value ps on ps.value_id=ems.program_scope_value_id
		left join formula_editor f1 on f1.formula_id=formula_forcast_reporting '
	if @input_id is not null
		set @sql=@sql+ ' left join ems_input_map eim on ems.ems_source_model_detail_id=eim.source_model_detail_id'
	set @sql=@sql+ ' where 1=1
		and ems_source_model_id='+cast(@ems_source_model_id as varchar) 

	if @input_id is not null
		set @sql=@sql+ '  
		and eim.input_id='+cast(@input_id as varchar) 
	set @sql=@sql+' order by spcd.curve_name'
EXEC spa_print @sql
exec (@sql)
END


ELSE IF @flag='a'
BEGIN
	select ems_source_model_detail_id,curve_id,uom_id,estimation_type_value_id,rating_value_id,
	formula_reporting_period,
	case when f.formula_type='n' and f.formula is null then 'Nested Formula' else 
	dbo.FNAFormulaFormat(f.formula,'r') end  Formula, formula_forcast_reporting ,  
	case when f1.formula_type='n' and f1.formula is null then 'Nested Formula' else 
	dbo.FNAFormulaFormat(f1.formula,'r') end  FCTFormula,use_as_reporting_period,ems_source_model_name,
	program_scope_value_id,credit_env_product,credit_product_uom_id
	
	from 	
		ems_source_model_detail ems left join formula_editor f on f.formula_id=formula_reporting_period
		left join formula_editor f1 on f1.formula_id=formula_forcast_reporting
		left join ems_source_model sm on sm.ems_source_model_id=ems.ems_source_model_id
	where 
		ems_source_model_detail_id=@ems_source_model_detail_id
END

ELSE IF @flag='i'
BEGIN
	Insert into ems_source_model_detail(
		ems_source_model_id,
		curve_id,
		uom_id,
		estimation_type_value_id,
		rating_value_id,
		formula_reporting_period,
		formula_forcast_reporting,
		use_as_reporting_period,
		program_scope_value_id,
		credit_env_product,
		credit_product_uom_id
	)
	
	select 
		@ems_source_model_id,
		@curve_id,
		@uom_id,
		@estimation_type_value_id,
		@rating_value_id,
		@formula_reporting_period,
		@formula_forcast_reporting,
		@use_as_reporting_period,
		@program_scope_value_id,
		@credit_env_product,
		@credit_product_uom_id
		

	select @new_id=SCOPE_IDENTITY()

	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, "Ems Source Model", 
		"spa_ems_source_model", "DB Error", 
		"Error Inserting Ems Source Model Information.", ''
	else
		Exec spa_ErrorHandler 0, 'Ems Source Model', 
		'spa_meter', 'Success', 
		'Ems Source Model Information successfully inserted.',@new_id
		

END

ELSE IF @flag='u'
BEGIN

	update	 
		ems_source_model_detail
	set	
		curve_id=@curve_id,
		uom_id=@uom_id,
		estimation_type_value_id=@estimation_type_value_id,
		rating_value_id=@rating_value_id,
		formula_reporting_period=@formula_reporting_period,
		formula_forcast_reporting=@formula_forcast_reporting,
		use_as_reporting_period=@use_as_reporting_period,
		program_scope_value_id=@program_scope_value_id,
		credit_env_product=@credit_env_product,
		credit_product_uom_id=@credit_product_uom_id

	where
		ems_source_model_detail_id=@ems_source_model_detail_id


		If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, "Ems Source Model", 
		"spa_ems_source_model", "DB Error", 
		"Error Updating Ems Source Model Information.", ''
	else
		Exec spa_ErrorHandler 0, 'Ems Source Model', 
		'spa_meter', 'Success', 
		'Ems Source Model Information successfully Updated.',''

END
ELSE IF @flag='d'
BEGIN


	delete from ems_source_model_detail 
		where ems_source_model_detail_id=@ems_source_model_detail_id

	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, "Ems Source Model", 
		"spa_ems_source_model", "DB Error", 
		"Error Deleting Ems Source Model Information.", ''
	else
		Exec spa_ErrorHandler 0, 'Ems Source Model', 
		'spa_meter', 'Success', 
		'Ems Source Model Information successfully Deleted.',''
END

END



















