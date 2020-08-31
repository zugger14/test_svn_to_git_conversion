IF OBJECT_ID(N'spa_menu_group', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_menu_group]
GO 
 
CREATE PROCEDURE [dbo].[spa_menu_group]
	@flag CHAR(1),
	@menu_group_id INT = NULL,
	@group_name VARCHAR(255),
	@role_id INT = NULL,
	@user_name VARCHAR(50) = NULL,
	@sequence_order INT = NULL,
	@tool_tips VARCHAR(1000) = NULL
AS
if @flag='s' and @role_id is not null
	select menu_group_id GroupID,group_name GroupName,sequence_order OrderBy
	from menu_group where [role_id]=@role_id order by sequence_order
else if @flag='s' and @user_name is not null
	select menu_group_id GroupID,group_name GroupName,sequence_order OrderBy
	from menu_group where [user_id]=@user_name order by sequence_order
else if @flag='a' 
	select menu_group_id GroupID,group_name GroupName,sequence_order OrderBy,tool_tips
	from menu_group where menu_group_id=@menu_group_id
else if @flag='i' 
begin
	if @role_id is not null
		select @sequence_order =isNUll(max(sequence_order),0)+1 from menu_group 
		where role_id=@role_id
	else
		select @sequence_order =isNUll(max(sequence_order),0)+1 from menu_group 
		where [user_id]=@user_name
	
	insert menu_group(
	group_name,
	role_id,
	[user_id],
	sequence_order,
	tool_tips)
	values(
	@group_name,
	@role_id,
	@user_name,
	@sequence_order,
	@tool_tips)

	If @@ERROR <> 0
			Exec spa_ErrorHandler 1, "Menu Group", 
					"spa_menu_group", "DB Error", 
					"Error in Insert.", ''
		else
			Exec spa_ErrorHandler 0, "Menu Group", 
					"spa_menu_group", "Status", 
					"Successfully saved menu group.","Recommendation"

end
else if @flag='u' 
begin
	update menu_group
	set group_name=@group_name,
	-- sequence_order=@sequence_order,
	tool_tips=@tool_tips
	where menu_group_id=@menu_group_id
	
	If @@ERROR <> 0
			Exec spa_ErrorHandler 1, "Menu Group", 
					"spa_menu_group", "DB Error", 
					"Error in Update.", ''
		else
			Exec spa_ErrorHandler 0, "Menu Group", 
					"spa_menu_group", "Status",
					"Successfully saved menu group.","Recommendation"

end
else if @flag='c'
begin
begin tran
	delete menu_group where [user_id]=@user_name
	insert menu_group(group_name,[user_id],sequence_order,tool_tips,temp_group_id )
	select group_name,@user_name,sequence_order,tool_tips,menu_group_id from menu_group
	where role_id=@role_id order by role_id,sequence_order
	
	insert menu_item(menu_group_id,function_id,menu_label,sequence_order,tool_tips )
	select mg.menu_group_id,function_id,menu_label,mi.sequence_order,mi.tool_tips  from menu_item mi
	join menu_group mg on mi.menu_group_id=mg.temp_group_id 
	join menu_group mgfr on mgfr.menu_group_id=mg.temp_group_id
	where mgfr.role_id=@role_id order by mi.sequence_order

	update menu_group set temp_group_id=null where temp_group_id is not null
	
	If @@ERROR <> 0
	begin	
			rollback tran
			Exec spa_ErrorHandler 1, "Menu Group", 
					"spa_menu_group", "DB Error", 
					"Error in Update.", ''
	end	
	else
	begin
			commit tran
			Exec spa_ErrorHandler 0, "Menu Group", 
					"spa_menu_group", "Status",
					"Successfully copied menu group.","Recommendation"
	end
end
else if @flag='d' 
begin
	delete menu_group
	where menu_group_id=@menu_group_id
	
	If @@ERROR <> 0
			Exec spa_ErrorHandler 1, "Menu Group", 
					"spa_menu_group", "DB Error", 
					"Error in Delete.", ''
		else
			Exec spa_ErrorHandler 0, "Menu Group", 
					"spa_menu_group","Status",
					"Successfully deleted menu group.","Recommendation"
end



