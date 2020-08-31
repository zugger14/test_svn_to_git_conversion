IF OBJECT_ID(N'[dbo].[spa_emsStaticDataValue]', N'P') IS NOT NULL
   DROP PROCEDURE [dbo].[spa_emsStaticDataValue]
GO



CREATE PROCEDURE [dbo].[spa_emsStaticDataValue]	@flag as char(1),
					@type_id as int=null,
					@value_id as int=null,
					@code as varchar(100)=NULL,
					@description as varchar(250)=NULL,
					@subsequent_value_id int=null,
					@exclude_type_id int=null,
					@ems_source_input_id int=null						

AS

SET NOCOUNT ON

DECLARE @errorCode Int

If @flag = 's' 
Begin

	if (select static_data_type from ems_static_data_type where type_id=@type_id) is null
	begin

		if @exclude_type_id is null
			select v.value_id ValueID,v.code Code,case when t.code is null then '' else t.code +'.' end + v.description as Description
			-- entity_id,sdc.category_id,sdc.category_name 
			 from ems_static_data_value  v 
			left outer join ems_static_data_value t on v.subsequent_value_id=t.value_id
			left outer join static_data_value sd on sd.type_id=v.value_id
			--left outer join static_data_category sdc on sdc.category_id=sd.category_id

			where v.type_id=@type_id  order by Description,v.code
		else
			select v.value_id ValueID,t.code +'.'+v.code Code,v.description as Description from ems_static_data_value v 
			join ems_static_data_type t on v.type_id=t.type_id
			where v.type_id not in (@exclude_type_id)
			order by v.type_id,v.code
	end
	else
	begin

		select v.value_id ValueID,v.code Code,v.description as Description
		--,entity_id
		from static_data_value  v 
		--left outer join static_data_category sdc on sdc.category_id=v.category_id

		where v.type_id=(select static_data_type from ems_static_data_type where type_id=@type_id)  order by Description,v.code
	end
		
End
If @flag = 't' --used in ems_conversion_iu_main for filtering depedent items
Begin
	
	if exists(select value_id from ems_static_data_value where subsequent_value_id=@value_id)
	begin
		if @exclude_type_id is null
			select v.value_id ValueID,v.code Code,case when v.code is null then '' else v.code +'.' end + v.description as Description,v.type_id
			from ems_static_data_value v inner join ems_input_characteristics ic on v.type_id=ic.type_id
			where v.subsequent_value_id=@value_id and ems_source_input_id=@ems_source_input_id
			 order by v.type_id,v.code
		else
			select v.value_id ValueID,v.code +'.'+v.code Code,v.description as Description,v.type_id
			from ems_static_data_value v inner join ems_input_characteristics ic on v.type_id=ic.type_id
			where v.type_id not in (@exclude_type_id) and v.subsequent_value_id=@value_id  and ems_source_input_id=@ems_source_input_id
			order by v.type_id,v.code
	end	
	else
		begin
			
			if @exclude_type_id is null
				select v.value_id ValueID,v.code Code,case when v.code is null then '' else v.code +'.' end + v.description as Description,v.type_id
				from ems_static_data_value v inner join ems_input_characteristics ic on v.type_id=ic.type_id
				where ems_source_input_id=@ems_source_input_id 
				and v.type_id in (select distinct type_id from ems_static_data_value v 
inner join (select value_id from ems_static_data_value where type_id=@type_id) s on v.subsequent_value_id=s.value_id)
				order by v.type_id,v.code
			else
				select v.value_id ValueID,v.code +'.'+v.code Code,v.description as Description,v.type_id
				from ems_static_data_value v inner join ems_input_characteristics ic on v.type_id=ic.type_id
				where v.type_id not in (@exclude_type_id) and ems_source_input_id=@ems_source_input_id 
				and v.type_id in (select distinct type_id from ems_static_data_value v inner join (select value_id from ems_static_data_value where type_id=@type_id) s on v.subsequent_value_id=s.value_id)
				order by v.type_id,v.code
		end

	--end
End
If @flag = 'v' --used in ems_conversion_iu_main for filtering depedent items
Begin
	select @subsequent_value_id=subsequent_value_id from ems_static_data_value where type_id=@type_id and value_id=@value_id
	if @subsequent_value_id is null
	begin
		if @exclude_type_id is null
			select v.value_id ValueID,v.code Code,case when t.code is null then '' else t.code +'.' end + v.description as Description from ems_static_data_value  v 
			left outer join ems_static_data_value t on v.subsequent_value_id=t.value_id
			where v.type_id=@type_id  order by Description,v.code
		else
			select v.value_id ValueID,t.code +'.'+v.code Code,v.description as Description from ems_static_data_value v 
			join ems_static_data_type t on v.type_id=t.type_id
			where v.type_id not in (@exclude_type_id)
			order by v.type_id,v.code
	end
	else
	begin
		if @exclude_type_id is null
			select v.value_id ValueID,v.code Code,case when v.code is null then '' else v.code +'.' end + v.description as Description,v.type_id
			from ems_static_data_value v inner join ems_input_characteristics ic on v.type_id=ic.type_id
			where v.subsequent_value_id=@subsequent_value_id and ems_source_input_id=@ems_source_input_id
			 order by v.type_id,v.code
		else
			select v.value_id ValueID,v.code +'.'+v.code Code,v.description as Description,v.type_id
			from ems_static_data_value v inner join ems_input_characteristics ic on v.type_id=ic.type_id
			where v.type_id not in (@exclude_type_id) and v.subsequent_value_id=@subsequent_value_id  and ems_source_input_id=@ems_source_input_id
			order by v.type_id,v.code
	end	
	
End
else If @flag = 'a' 
Begin
	select value_id,code,description,type_id,subsequent_value_id from ems_static_data_value
	where value_id=@value_id
	
End
Else If @flag='i'
Begin
	if EXISTS (select  code from ems_static_data_value where code=@code)
	BEGIN
		Exec spa_ErrorHandler 1, 'Duplicate code cannot be inserted.', 
						'spa_StaticDataValue', 'DB Error', 
						'Failed to insert static data value.', ''
	END
	Else
	BEGIN
			Insert into ems_static_data_value
			(code,description,type_id,subsequent_value_id)
			values (@code,@description,@type_id,@subsequent_value_id)


			Set @errorCode = @@ERROR
			If @errorCode <> 0
				Exec spa_ErrorHandler @errorCode, 'StaticDataMgmt', 
						'spa_StaticDataValue', 'DB Error', 
						'Failed to insert static data value.', ''
			Else
				Exec spa_ErrorHandler 0, 'StaticDataMgmt', 
						'spa_StaticDataValue', 'Success', 
						'Static data value inserted.', ''
			End
		END

Else If @flag = 'u'
Begin
	if EXISTS (select  code from ems_static_data_value where code=@code and value_id <> @value_id)
	BEGIN
		Exec spa_ErrorHandler 1, 'Duplicate code cannot be inserted.', 
						'spa_StaticDataValue', 'DB Error', 
						'Failed to insert static data value.', ''
	END
	Else
		BEGIN
			Update ems_static_data_value
			set code = @code, description = @description,
			subsequent_value_id=@subsequent_value_id
			where value_id = @value_id

			Set @errorCode = @@ERROR
			If @errorCode <> 0
			BEGIN
				
				Exec spa_ErrorHandler @errorCode, 'StaticDataMgmt', 
						'spa_StaticDataValue', 'DB Error', 
						'Failed to update static data value.', ''
				Return
			END
			Else
			BEGIN
				
				Exec spa_ErrorHandler 0, 'StaticDataMgmt', 
						'spa_StaticDataValue', 'Success', 
						'Static data value updated.', ''
				Return
			END
	End
END

Else If @flag='d'
Begin

	Delete ems_static_data_value where value_id = @value_id

	Set @errorCode = @@ERROR
	If @errorCode <> 0
	BEGIN
		Exec spa_ErrorHandler @errorCode, 'StaticDataMgmt', 
				'spa_StaticDataValue', 'DB Error', 
				'Failed to delete static data value.', ''
		Return
	END
	Else
	BEGIN
		Exec spa_ErrorHandler 0, 'StaticDataMgmt', 
				'spa_StaticDataValue', 'Success', 
				'Static data value deleted.', ''
		Return
	END

End











