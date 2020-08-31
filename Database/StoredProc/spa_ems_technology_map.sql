IF OBJECT_ID(N'spa_ems_technology_map', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_ems_technology_map]
 GO 

--spa_ems_technology_map 's',29
create procedure [dbo].[spa_ems_technology_map]
@flag char(1),
@ems_book_id int=NULL,
@ems_tech_map_id int=NULL,
@technology_value_id int=null,
@ems_group_id int=null,
@ems_source_model_id int=null,
@ems_description varchar(500)=null,
@fas_subsidiary_id int=null,
@fas_book_id int=null
AS
BEGIN
declare @sql varchar(5000)
IF @flag='s' 
BEGIN
	set @sql='
	select ems_tech_map_id,sdv.Code Technology,esm.ems_source_model_name EmissionSource,ems_description Description,
	etm.technology_value_id,etm.ems_source_model_id from ems_technology_map etm 
	inner join static_data_value  sdv on etm.technology_value_id=sdv.value_id
	inner join ems_source_model  esm on esm.ems_source_model_id=etm.ems_source_model_id
	where  1=1 '
	if @fas_book_id is not null
		set @sql=@sql +' and fas_book_id='+ cast(@fas_book_id  as varchar)
	if @ems_book_id is not null
		set @sql=@sql +' and etm.ems_book_id='+ cast(@ems_book_id  as varchar)
	if @fas_subsidiary_id is not null
		set @sql=@sql +' and etm.fas_subsidiary_id='+ cast(@fas_subsidiary_id  as varchar)

	exec(@sql)


END
ELSE IF @flag='a'
BEGIN
	
	select *
	from ems_technology_map where ems_tech_map_id=@ems_tech_map_id
END

ELSE IF @flag='i'
BEGIN
	select @fas_subsidiary_id=sub.entity_id from portfolio_hierarchy book join 
	portfolio_hierarchy st on book.parent_entity_id=st.entity_id
	join portfolio_hierarchy sub on st.parent_entity_id=sub.entity_id
	where book.entity_id=@fas_book_id
	
	Insert into ems_technology_map(
		technology_value_id,
		ems_group_id,
		ems_source_model_id,
		ems_book_id,
		ems_description,
		fas_subsidiary_id,
		fas_book_id
	)
	
	select 
		@technology_value_id,
		@ems_group_id,
		@ems_source_model_id,
		@ems_book_id,
		@ems_description,
		@fas_subsidiary_id,
		@fas_book_id
		

	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, "Ems Source Inputs", 
		"spa_ems_source_model", "DB Error", 
		"Error Inserting Ems Source Model Inputs.", ''
	else
		Exec spa_ErrorHandler 0, 'Ems Source Model', 
		'spa_meter', 'Success', 
		'Ems Source Model Inputs successfully inserted.',''
		

END

ELSE IF @flag='u'
BEGIN

	update	 
		ems_technology_map
	set	
		technology_value_id=@technology_value_id,
		ems_group_id=@ems_group_id,
		ems_source_model_id=@ems_source_model_id,
		ems_book_id=@ems_book_id,
		ems_description=@ems_description
		

	where
		ems_tech_map_id=@ems_tech_map_id


		If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, "Ems Source Input", 
		"spa_ems_source_model", "DB Error", 
		"Error Updating Ems Source Model Inputs.", ''
	else
		Exec spa_ErrorHandler 0, 'Ems Source Model', 
		'spa_ems_source_model', 'Success', 
		'Ems Source Model Inputs successfully Updated.',''

END
ELSE IF @flag='d'
BEGIN


	delete from ems_technology_map 
		where ems_tech_map_id=@ems_tech_map_id

	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, "Ems Source Model", 
		"spa_ems_source_model", "DB Error", 
		"Error Deleting Ems Source Model Inputs.", ''
	else
		Exec spa_ErrorHandler 0, 'Ems Source Model', 
		'spa_meter', 'Success', 
		'Ems Source Model Inputs successfully Deleted.',''
END

END




