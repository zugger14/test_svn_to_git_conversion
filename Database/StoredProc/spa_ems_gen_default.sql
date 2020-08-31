IF OBJECT_ID(N'[dbo].[spa_ems_gen_default]', N'P') IS NOT NULL
   DROP PROCEDURE [dbo].[spa_ems_gen_default]
GO


--spa_ems_gen_default 's',272
CREATE PROCEDURE [dbo].[spa_ems_gen_default]	@flag as char(1),
					@generator_id as int=null,
					@input_type_id int=NULL,
					@ems_source_model_id INT =NULL
AS

SET NOCOUNT ON

If @flag = 's' 
Begin
	declare @sql varchar(5000)
	set @sql=' select input_type_id,char1,char2,char3,char4,
	char5,char6,char7,char8,char9,char10,rg.technology,rg.fuel_value_id	
 	from ems_gen_default egd 
	left join rec_generator rg on egd.generator_id=rg.generator_id
	where egd.generator_id='+ cast(@generator_id as varchar)
	if @input_type_id is not null
	set @sql=@sql+' and input_type_id='+cast(@input_type_id as varchar)
	exec(@sql)	

end
ELSE IF @flag='f'	/* for filter in combo box*/
	BEGIN
	SET @sql='
		select distinct esm.ems_source_model_id ,esm.ems_source_model_name
		from ems_source_model_effective esme
		INNER JOIN 	ems_source_model esm on esm.ems_source_model_id=esme.ems_source_model_id
		INNER JOIN 	 rec_generator g on g.generator_id=esme.generator_id				 
		where 1=1 '
		+CASE WHEN @generator_id IS NOT NULL THEN ' and g.generator_id='+CAST(@generator_id AS VARCHAR) ELSE '' END
		
	EXEC (@sql)
	EXEC spa_print @sql
END
ELSE IF @flag='r'	/* for filter in combo box*/
	BEGIN
	SET @sql='
		select distinct esm.ems_source_model_id ,esm.ems_source_model_name,
		esm.input_frequency,esm.forecast_input_frequency,
		sdv.code,sdv2.code
		from ems_source_model_effective esme
		INNER JOIN 	ems_source_model esm on esm.ems_source_model_id=esme.ems_source_model_id
		INNER JOIN 	 rec_generator g on g.generator_id=esme.generator_id
		INNER JOIN static_data_value sdv ON sdv.value_id = esm.input_frequency
		INNER JOIN static_data_value sdv2 ON sdv2.value_id = esm.forecast_input_frequency		 
		where 1=1 '
		+CASE WHEN @generator_id IS NOT NULL THEN ' and g.generator_id='+CAST(@generator_id AS VARCHAR)+'' ELSE '' END
		+CASE WHEN @ems_source_model_id IS NOT NULL THEN ' and esm.ems_source_model_id='+CAST(@ems_source_model_id AS VARCHAR) ELSE '' END
		
	EXEC (@sql)
	EXEC spa_print @sql
END




















