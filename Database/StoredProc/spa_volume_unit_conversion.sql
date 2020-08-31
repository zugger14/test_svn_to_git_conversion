IF OBJECT_ID(N'spa_volume_unit_conversion', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_volume_unit_conversion]
GO 

CREATE PROC [dbo].[spa_volume_unit_conversion]	
	@flag AS CHAR(1),					
	@from_source_uom_id INT = NULL,				
	@to_source_uom_id INT = NULL,
	@conversion_factor FLOAT = NULL,
	@user_name VARCHAR(50) = NULL

AS 
DECLARE @Sql_Select VARCHAR(5000)

IF @flag = 'i'
BEGIN
INSERT INTO volume_unit_conversion
		(	
		from_source_uom_id,	
		to_source_uom_id,
		conversion_factor,
		create_user,
		create_ts,
		update_user,
		update_ts
		)
	values
		(	
		@from_source_uom_id,					
		@to_source_uom_id,
		@conversion_factor,
		@user_name,
		getdate(),
		@user_name,
		getdate()
		)

		if @@Error <> 0
		Exec spa_ErrorHandler @@Error, 'MaintainDefination', 
				'spa_volume_unit_conversion', 'DB Error', 
				'Failed to insert defination value.', ''
		Else
		Exec spa_ErrorHandler 0, 'MaintainDefination', 
				'spa_volume_unit_conversion', 'Success', 
				'Defination data value inserted.', ''
end

else if @flag='a' 
begin
	select from_source_uom_id, to_source_uom_id, conversion_factor from volume_unit_conversion 
	where from_source_uom_id=@from_source_uom_id and to_source_uom_id=@to_source_uom_id
	

	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, 'volume_unit_conversion table', 
				'spa_volume_unit_conversion', 'DB Error', 
				'Failed to select maintain defiantion detail record of Item type.', ''
	Else
		Exec spa_ErrorHandler 0, 'volume_unit_conversion table', 
				'spa_volume_unit_conversion', 'Success', 
				'Source_Traders detail record of Item Type successfully selected.', ''
end

else if @flag='s' 
begin
	--set @Sql_Select='select from_source_uom_id, to_source_uom_id, conversion_factor from volume_unit_conversion'
	--exec(@SQL_select)
	set @Sql_Select='
	select from_source_uom_id,u1.uom_name [From UOM], u2.uom_name [To UOM], conversion_factor[Conv Factor],to_source_uom_id from 
	volume_unit_conversion c join source_uom u1 on c.from_source_uom_id=u1.source_uom_id
	join source_uom u2 on c.to_source_uom_id=u2.source_uom_id where 1=1 '
	if @from_source_uom_id is not null
		set @Sql_Select=@Sql_Select +' and c.from_source_uom_id='+cast(@from_source_uom_id as varchar)
	if @to_source_uom_id is not null
		set @Sql_Select=@Sql_Select +' and c.to_source_uom_id='+cast(@to_source_uom_id as varchar)
	exec(@Sql_Select)

	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, "MaintainDefination", 
				"spa_volume_unit_conversion", "DB Error", 
				"Failed to select Maintain Defination Data.", ''

	Else
		Exec spa_ErrorHandler 0, 'MaintainDefination', 
				'spa_volume_unit_conversion', 'Success', 
				'Maintain Defination Data sucessfully selected', ''
end

Else if @flag = 'u'
begin
	
	update volume_unit_conversion set to_source_uom_id = @to_source_uom_id, conversion_factor=@conversion_factor,
	update_user=@user_name, update_ts=getdate()
	where from_source_uom_id=@from_source_uom_id and to_source_uom_id=@to_source_uom_id 

	if @@Error <> 0
		Exec spa_ErrorHandler @@Error, 'MaintainDefination', 
				'spa_volume_unit_conversion', 'DB Error', 
				'Failed to update defination value.', ''
		Else
		Exec spa_ErrorHandler 0, 'MaintainDefination', 
				'spa_volume_unit_conversion', 'Success', 
				'Defination data value updated.', ''
end

Else if @flag = 'd'
begin
	delete from volume_unit_conversion
	Where 	to_source_uom_id=@to_source_uom_id and from_source_uom_id=@from_source_uom_id 

	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, "MaintainDefination", 
				"spa_volume_unit_conversion", "DB Error", 
				"Delete of Maintain Defination Data failed.", ''
	Else
		Exec spa_ErrorHandler 0, 'MaintainDefination', 
				'spa_volume_unit_conversion', 'Success', 
				'Maintain Defination Data sucessfully deleted', ''
end





