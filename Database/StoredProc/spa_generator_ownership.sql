IF OBJECT_ID(N'[dbo].[spa_generator_ownership]', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_generator_ownership]
GO
CREATE PROCEDURE [dbo].[spa_generator_ownership]
@flag char(1),
@generator_ownership_id int=null,
@generator_id int=null,
@counterparty_id varchar(1000)=null,
@organization_boundary_id int=null,
@per_ownership float=null,
@relationship varchar(250)=null
as
if @flag='s' 
begin
	select generator_ownership_id ID,Relationship,counterparty_id Partners,
	Cast((isnull(per_ownership, 1) * 100) as varchar) +'%' [% Held by Partners],
	s.code [Organization Boundary], per_ownership
	from generator_ownership o left outer join static_data_value s on o.organization_boundary_id=s.value_id
	where generator_id=@generator_id

END
if @flag='a' 
begin
	select generator_ownership_id,o.generator_id,counterparty_id,organization_boundary_id,per_ownership,
	rg.name,relationship	
	from generator_ownership o inner join rec_generator rg on o.generator_id=rg.generator_id
	where generator_ownership_id=@generator_ownership_id

END
-- If @flag = 'm'  --This is called from generator ownership for organization boundary combo box
-- begin
-- 	select type_id,value_id, code Code, description Description from static_data_value where type_id=1100 and value_id not in (select organization_boundary_id from generator_ownership where  generator_id=@generator_id)
-- end
if @flag='i' or @flag='u'
BEGIN
	 if (select sum(per_ownership)+@per_ownership from generator_ownership where generator_id=@generator_id)>1
		begin
				Exec spa_ErrorHandler 1, "Source/Sink", 
							"spa_generator_ownership", "DB Error", 
						"Ownership percentage should not exceed 1.", ''
				return
		end

	if @flag='i'
	begin


	INSERT  generator_ownership(
			generator_id,
			counterparty_id,
			organization_boundary_id,
			per_ownership,
			relationship
	)
	VALUES 	(
			@generator_id,
			@counterparty_id,
			@organization_boundary_id,
			@per_ownership,
			@relationship

	)
			If @@ERROR <> 0
					Exec spa_ErrorHandler @@ERROR, "Rec Generator", 
							"spa_rec_generator", "DB Error", 
						"Error on Inserting Rec generator.", ''
				else
					Exec spa_ErrorHandler 0, 'Rec Generator', 
							'spa_rec_generatpr', 'Success', 
							'Rec Generator successfully inserted.', ''
	END
	if @flag='u'
	begin

		UPDATE	generator_ownership
			set counterparty_id=@counterparty_id ,
			organization_boundary_id=@organization_boundary_id,
			per_ownership=@per_ownership,
			relationship=@relationship
			where generator_ownership_id=@generator_ownership_id
		
		If @@ERROR <> 0
					Exec spa_ErrorHandler @@ERROR, "Rec Generator", 
							"spa_rec_generator", "DB Error", 
						"Error on updating Rec generator.", ''
		else
					Exec spa_ErrorHandler 0, 'Rec Generator', 
							'spa_rec_generatpr', 'Success', 
							'Rec Generator successfully updated.',''
	END
END

if @flag='d'
begin
	delete generator_ownership
	where generator_ownership_id=@generator_ownership_id
	If @@ERROR <> 0
				Exec spa_ErrorHandler @@ERROR, "Rec Generator", 
						"spa_rec_generator", "DB Error", 
					"Error on deleting Rec generator.", ''
	else
				Exec spa_ErrorHandler 0, 'Rec Generator', 
						'spa_rec_generatpr', 'Success', 
						'Rec Generator deleted updated.',''
end





