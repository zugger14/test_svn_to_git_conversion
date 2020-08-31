IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_ems_source_control_type]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_ems_source_control_type]
GO 


CREATE PROCEDURE [dbo].[spa_ems_source_control_type]
	@flag char(1), -- 'c' show counterparty report
	@source_control_id int=null,
	@generator_id int=null,
	@ems_conversion_type_value_id int=null,
	@control_type_id int=null,
	@control_type_id1 int=null,
	@control_type_id2 int=null,
	@control_type_id3 int=null,
	@control_type_id4 int=null
		
AS
BEGIN

DECLARE @sql varchar(8000)

IF @flag='s'	
BEGIN
set @sql='
	select source_control_id,generator_id,
	sd.code as [Emissions Types],sd1.code as [Control Types]
	from 	ems_source_control_type esct
	left join static_data_value sd on sd.value_id=esct.ems_conversion_type_value_id
	left join static_data_value sd1 on sd1.value_id=esct.control_type_id
	where 1=1 '+
	case when @source_control_id is not null then ' and recorderid '+cast(@source_control_id as varchar) else '' end
	+case when @generator_id is not null then ' and generator_id ='+cast(@generator_id as varchar) else '' end
	--case when @desc is not null then ' and description like '''+@desc+'%''' else '' end 
EXEC spa_print @sql
exec (@sql)
END


ELSE IF @flag='a'
BEGIN
	select source_control_id,generator_id,
			ems_conversion_type_value_id,control_type_id,
			control_type_id1,control_type_id2,
			control_type_id3,control_type_id4
	from 	ems_source_control_type where source_control_id=@source_control_id
END

ELSE IF @flag='i'
BEGIN
	Insert into ems_source_control_type(
			generator_id,
			ems_conversion_type_value_id,
			control_type_id,
			control_type_id1,
			control_type_id2,
			control_type_id3,
			control_type_id4
		)
	select 
		  @generator_id,
		  @ems_conversion_type_value_id,
		  @control_type_id,
		  @control_type_id1,
		  @control_type_id2,
		  @control_type_id3,
		  @control_type_id4

	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, "Recorder ID Detail", 
		"spa_meter", "DB Error", 
		"Error Inserting Recoder Information.", ''
	else
		Exec spa_ErrorHandler 0, 'Recorder ID', 
		'spa_meter', 'Success', 
		'Recorder Information successfully inserted.',''
		

END

ELSE IF @flag='u'
BEGIN

	update	 
		ems_source_control_type
	set	
			generator_id=@generator_id,
			ems_conversion_type_value_id=@ems_conversion_type_value_id,
			control_type_id=@control_type_id,
			control_type_id1=@control_type_id1,
			control_type_id2=@control_type_id2,
			control_type_id3=@control_type_id3,
			control_type_id4=@control_type_id4
		
	where
		source_control_id=@source_control_id


	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, "Recorder ID", 
		"spa_meter", "DB Error", 
		"Error Updating Recoder Information.", ''
	else
		Exec spa_ErrorHandler 0, 'Recorder ID', 
		'spa_meter', 'Success', 
		'Recoder Information successfully updated.',''

END
ELSE IF @flag='d'
BEGIN


	delete from 
		ems_source_control_type
	where 
		source_control_id=@source_control_id

	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, "Recorder ID", 
		"spa_meter", "DB Error", 
		"Error  Deleting Recoder Information.", ''
	else
		Exec spa_ErrorHandler 0, 'Recorder ID', 
		'spa_meter', 'Success', 
		'Recoder Information Deleted Successfully.',''

END


END











