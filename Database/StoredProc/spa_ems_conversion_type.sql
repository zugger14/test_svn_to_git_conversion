IF OBJECT_ID(N'[dbo].[spa_ems_conversion_type]', N'P') IS NOT NULL
   DROP PROCEDURE [dbo].[spa_ems_conversion_type]
GO


CREATE PROCEDURE [dbo].[spa_ems_conversion_type]
@flag char(1),
@ems_conversion_type_id int=NULL,
@ems_conversion_type_value_id int=null,
@ems_source_input_id int=null,
@type_char_id int=NULL

AS
BEGIN
DECLARE @sql varchar(8000)


IF @flag='s' 
BEGIN
	select ems_conversion_type_id [ID], ems_conversion_type_value_id, ems_source_input_id, type_char_id,code [Conversion Type]
	from ems_conversion_type inner join static_data_value on ems_conversion_type_value_id=value_id
	where type_char_id=@type_char_id
	
END

ELSE IF @flag='e' -- Select all ems cov type
BEGIN
	select  value_id,code,description from static_data_value
	where type_id=5006 and value_id not in (select ems_conversion_type_value_id from ems_conversion_type where type_char_id=@type_char_id)
END
ELSE IF @flag='a' -- Select all input type by Conv_type
BEGIN
	
select x.* from( 
select d.type_id,isNull(ems_conversion_type_value_id,-1) ems_conversion_type_value_id from (
select  type_id from ems_input_characteristics 
where  ems_source_input_id=@ems_source_input_id) d left outer join (
select  type_id,ems_conversion_type_value_id from 
ems_conversion_type c join ems_input_characteristics i
on c.type_char_id=i.type_char_id
where  i.ems_source_input_id=@ems_source_input_id and 
ems_conversion_type_value_id=@ems_conversion_type_value_id
) c on d.type_id=c.type_id) x
join ems_input_characteristics esi on x.type_id=esi.type_id and ems_source_input_id=@ems_source_input_id
order by type_char_id
	
END
ELSE IF @flag='i'
BEGIN
	Insert into ems_conversion_type(
		ems_conversion_type_value_id,
		ems_source_input_id,
		type_char_id

	)
	
	select 
		@ems_conversion_type_value_id,
		@ems_source_input_id,
		@type_char_id


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
		ems_conversion_type
	set	
		 ems_conversion_type_value_id=@ems_conversion_type_value_id,
		 ems_source_input_id=@ems_source_input_id,
		 type_char_id=@type_char_id
		

	where
		ems_conversion_type_id=@ems_conversion_type_id


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


	delete from ems_conversion_type 
		where ems_conversion_type_id=@ems_conversion_type_id

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










