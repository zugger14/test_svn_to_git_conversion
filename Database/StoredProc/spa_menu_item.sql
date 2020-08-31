IF OBJECT_ID(N'spa_menu_item', N'P') IS NOT NULL
DROP PROCEDURE spa_menu_item
 GO 

-- spa_menu_item 's',NULL,1
CREATE proc [dbo].[spa_menu_item]
@flag char(1),
@menu_item_id int=NULL,
@menu_group_id int=null,
@function_id int=null,
@menu_label varchar(255)=NULL,
@sequence_order int=null,
@tool_tips varchar(1000)=null,
@after_seq int=null,
@pm_file_name varchar(100)=null,
@file_name varchar(100)=null

as

declare @sql_stmt varchar(5000)
declare @scope_id int
declare @process_map_id int

if @flag='s' 
begin
	
	select sequence_order,menu_label
	from menu_item mi 
	where menu_group_id=@menu_group_id and menu_item_id not in (@menu_item_id) order by sequence_order
	
	
end
else if @flag='a' 
	select menu_item_id,menu_group_id,mi.function_id,cast(f.function_id as varchar) +') '+ f.function_name function_name,
	menu_label,sequence_order,tool_tips,(select top 1  sequence_order from menu_item 
where menu_group_id=(select menu_group_id from menu_item where menu_item_id=@menu_item_id ) and sequence_order< (select sequence_order from menu_item where
menu_group_id=(select menu_group_id from menu_item where menu_item_id=@menu_item_id ) and
 menu_item_id=@menu_item_id)
order by sequence_order desc
) Prev, pm.[file_name], pm.[pm_file_name], pm.[id]
	from menu_item mi 
join application_functions f on f.function_id=mi.function_id 
left join process_map_table pm on pm.id=mi.process_map_id
	where menu_item_id=@menu_item_id

else if @flag='i' 
begin
	if @file_name is not null or @pm_file_name is not null
	begin
		insert into process_map_table ([name], discription, [file_name], pm_file_name)
		values (@menu_label, @tool_tips, @file_name, @pm_file_name)
		set @scope_id=scope_identity()
	end
	else
		set @scope_id=null

	select @sequence_order=isNUll(max(sequence_order),0)+1 from menu_item where menu_group_id=@menu_group_id
	insert menu_item(
	menu_group_id,
	function_id,
	menu_label,
	sequence_order,
	tool_tips,
	process_map_id)
	values(
	@menu_group_id,
	@function_id,
	@menu_label,
	@sequence_order,
	@tool_tips,
	@scope_id)

	If @@ERROR <> 0
			Exec spa_ErrorHandler 1, "Menu Group", 
					"spa_menu_group", "DB Error", 
					"Error in Insert.", ''
		else
			Exec spa_ErrorHandler 0, "Menu Group", 
					"spa_menu_group", "Status", 
					"Successfully saved menu group.","Recommendation"

	
	
	--update application_functions set process_map_id=@scope_id where function_id=@function_id
	

end
else if @flag='u' 
begin
	
---------------------------------
-- declare @new_seq int,@update_id int
-- 	if not exists (select sequence_order  from formula_nested where formula_group_id=@formula_group_id and [ID]=@nested_id)
-- 	begin
-- 		select @sequence_order=isNUll(max(sequence_order),0)+1 from formula_nested where formula_group_id=@formula_group_id 
-- 		set @after_seq=null
-- 	end
-- 	select @sequence_order=sequence_order from formula_nested where [ID]=@nested_id
-- 	
-- 	if @after_seq is null
-- 	begin
-- 		set @new_seq=1
-- 		select @update_id=[ID] from formula_nested where sequence_order=@new_seq 
-- 		and formula_group_id=@formula_group_id 
-- 	end
-- 	if @after_seq is not null
-- 	begin
-- 		if(select max(sequence_order) from formula_nested where formula_group_id=@formula_group_id )=@after_seq
-- 			set @new_seq=@after_seq
-- 		else
-- 			set @new_seq=@after_seq+1
-- 		select @update_id=[ID] from formula_nested where sequence_order=@new_seq and formula_group_id=@formula_group_id
-- 	end
-- 
-- 	if @update_id is not null
-- 		update formula_nested 
-- 			set sequence_order=@sequence_order 
-- 			where [ID]=@update_id
--------------------------------

if not exists (select sequence_order  from menu_item where menu_group_id=@menu_group_id and menu_item_id=@menu_item_id)
	begin
		select @sequence_order=isNUll(max(sequence_order),0)+1 from menu_item where menu_group_id=@menu_group_id
		set @after_seq=null
	end
	select @sequence_order=sequence_order from menu_item where menu_item_id=@menu_item_id

	declare @new_seq int,@update_id int

	if @after_seq is null
	begin
		set @new_seq=1
		select @update_id=menu_item_id from menu_item where sequence_order=@new_seq 
		and  menu_group_id=@menu_group_id
	end
	if @after_seq is not null
	begin
		if(select max(sequence_order) from menu_item where menu_group_id=@menu_group_id)=@after_seq
			set @new_seq=@after_seq
		else
			set @new_seq=@after_seq+1
		select @update_id=menu_item_id from menu_item where sequence_order=@new_seq and menu_group_id=@menu_group_id
	end

	if @update_id is not null
		update menu_item 
			set sequence_order=@sequence_order 
			where menu_item_id=@update_id

-- 
-- 	if @after_seq is not null
-- 	begin
-- 		if(select max(sequence_order) from menu_item where menu_group_id=@menu_group_id)=@after_seq
-- 			set @new_seq=@after_seq
-- 		else
-- 			set @new_seq=@after_seq+1
-- 		select @update_id=menu_item_id from menu_item where sequence_order=@new_seq and menu_group_id=@menu_group_id
-- 				
-- 		update menu_item 
-- 			set 
-- 			sequence_order=@sequence_order 
-- 			where menu_item_id=@update_id
-- 	end
-- 	else
-- 		set @new_seq=@sequence_order

	
	select @process_map_id=process_map_id from  menu_item where menu_item_id=@menu_item_id

if @process_map_id is null and (@file_name is not null or @pm_file_name is not null)
	begin
		insert into process_map_table ([name], discription, [file_name], pm_file_name)
		values (@menu_label, @tool_tips, @file_name, @pm_file_name)
		set @scope_id=scope_identity()

		update menu_item 
		set menu_group_id=@menu_group_id ,
		function_id=@function_id ,
		menu_label=@menu_label,
		sequence_order=@new_seq ,
		tool_tips=@tool_tips,
		process_map_id=@scope_id
		where menu_item_id=@menu_item_id
		
		If @@ERROR <> 0
				Exec spa_ErrorHandler 1, "Menu Group", 
						"spa_menu_group", "DB Error", 
						"Error in Update.", ''
			else
				Exec spa_ErrorHandler 0, "Menu Group", 
						"spa_menu_group", "Status",
						"Successfully saved menu group.","Recommendation"
	end
else if @file_name is null and  @pm_file_name is null and @process_map_id is not null
	begin
		delete process_map_table where id=@process_map_id

		update menu_item 
			set menu_group_id=@menu_group_id ,
			function_id=@function_id ,
			menu_label=@menu_label,
			sequence_order=@new_seq ,
			tool_tips=@tool_tips,
			process_map_id=null 
		where menu_item_id=@menu_item_id
		If @@ERROR <> 0
				Exec spa_ErrorHandler 1, "Menu Group", 
						"spa_menu_group", "DB Error", 
						"Error in Update.", ''
			else
				Exec spa_ErrorHandler 0, "Menu Group", 
						"spa_menu_group", "Status",
						"Successfully saved menu group.","Recommendation"
	
	end
else
	begin
		update menu_item 
		set menu_group_id=@menu_group_id ,
		function_id=@function_id ,
		menu_label=@menu_label,
		sequence_order=@new_seq ,
		tool_tips=@tool_tips 
		where menu_item_id=@menu_item_id
		
		If @@ERROR <> 0
				Exec spa_ErrorHandler 1, "Menu Group", 
						"spa_menu_group", "DB Error", 
						"Error in Update.", ''
			else
				Exec spa_ErrorHandler 0, "Menu Group", 
						"spa_menu_group", "Status",
						"Successfully saved menu group.","Recommendation"

		update a
			set [name]=@menu_label, discription=@tool_tips, [file_name]=@file_name, pm_file_name= @pm_file_name
		from process_map_table a, menu_item b
		where a.id=b.process_map_id and b.menu_item_id=@menu_item_id
	end
--select @process_map_id=process_map_id from  menu_item where menu_item_id=@menu_item_id
--update process_map_table set [name]=@menu_label, discription=@tool_tips, [file_name]=@file_name, pm_file_name= @pm_file_name 
--where id=@process_map_id
	
	

end
else if @flag='d' 
begin
	--select @process_map_id=process_map_id from  menu_item where menu_item_id=@menu_item_id
	--update application_functions set process_map_id=null where function_id=@function_id
	if (select process_map_id from  menu_item where menu_item_id=@menu_item_id) is not null
		delete process_map_table where id=(select process_map_id from  menu_item where menu_item_id=@menu_item_id)

	delete menu_item
	where menu_item_id=@menu_item_id
	
	If @@ERROR <> 0
			Exec spa_ErrorHandler 1, "Menu Group", 
					"spa_menu_group", "DB Error", 
					"Error in Delete.", ''
		else
			Exec spa_ErrorHandler 0, "Menu Group", 
					"spa_menu_group","Status",
					"Successfully deleted menu group.","Recommendation"


end












