
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_getPortfolioHierarchyEms]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_getPortfolioHierarchyEms]
GO 

CREATE Proc [dbo].[spa_getPortfolioHierarchyEms] 
@flag char(1),
@group_id int,
@entity_id int=null,
@entity_name varchar(200)=null,
@entity_type_value_id int=null,
@hierarchy_level int=null,
@parent_entity_id int=null
as 
---FOR TEST COMMENT THIS

-- DROP TABLE #sorted_return_entity
-- declare @function_id int,
--  @group_id int
-- 
-- set @function_id=1
-- set @group_id=1

----------COMMENT THE ABOVE FOR PRODUCTION VERSION

DECLARE @sql_stmt varchar(8000)
DECLARE @all_count int
SET @all_count = 0

SET NOCOUNT ON

if @flag='s'
begin
CREATE TABLE #sorted_return_entity
(next_id int identity,
entity_id int, 
parent_entity_id int,
entity_name varchar(200) COLLATE DATABASE_DEFAULT,
have_rights int,
node_type int,
first_sort_order int,
second_sort_order int,
third_sort_order int
)

declare @user_login_id varchar(100)
set @user_login_id=dbo.FNADBUser() 

------- now sort the results and return distinct nodes only

DECLARE  @have_rights int, @node_type int, @sub_entity_name varchar(100), 
	@str_entity_name varchar(100), @book_entity_name varchar(100),@first_sort_order int,@second_sort_order int,@third_sort_order int
	,@first_sort_order1 INT,@second_sort_order1 INT,@third_sort_order1 INT,@first_sort_order2 INT,@second_sort_order2 INT,@third_sort_order2 INT
DECLARE	@sub_entity_id int, @strategy_entity_id int

DECLARE sub_cursor CURSOR FOR
select entity_id, parent_entity_id, entity_name, hierarchy_level, 1 as have_rights,first_sort_order,second_sort_order,third_sort_order
from ems_portfolio_hierarchy
where hierarchy_level = 2 and emission_group_id=@group_id
group by entity_id, parent_entity_id, entity_name, hierarchy_level,first_sort_order,second_sort_order,third_sort_order
order by first_sort_order,second_sort_order,third_sort_order

OPEN sub_cursor

FETCH NEXT FROM sub_cursor
INTO @entity_id, @parent_entity_id, @entity_name, @node_type, @have_rights,@first_sort_order,@second_sort_order,@third_sort_order

WHILE @@FETCH_STATUS = 0   -- sub
BEGIN 

SET @sub_entity_name = @entity_name
SET @sub_entity_id = @entity_id
INSERT INTO #sorted_return_entity values(@entity_id, @parent_entity_id, @entity_name + '|' , @have_rights, @node_type,@first_sort_order,@second_sort_order,@third_sort_order)

	DECLARE strategy_cursor CURSOR FOR
	select entity_id, parent_entity_id, entity_name, hierarchy_level, 1 as have_rights,first_sort_order,second_sort_order,third_sort_order
	from ems_portfolio_hierarchy
	where hierarchy_level = 1 AND parent_entity_id = @sub_entity_id and emission_group_id=@group_id
	group by entity_id, parent_entity_id, entity_name, hierarchy_level,first_sort_order,second_sort_order,third_sort_order
	order by first_sort_order,second_sort_order,third_sort_order
	
	OPEN strategy_cursor
	
	FETCH NEXT FROM strategy_cursor
	INTO @entity_id, @parent_entity_id, @entity_name, @node_type, @have_rights,@first_sort_order2,@second_sort_order2,@third_sort_order2

	WHILE @@FETCH_STATUS = 0   -- strategy
	BEGIN 

		SET @str_entity_name = @entity_name
		SET @strategy_entity_id = @entity_id
		INSERT INTO #sorted_return_entity values(@entity_id, @parent_entity_id, @sub_entity_name + '|' + @entity_name + '|' , @have_rights, @node_type,@first_sort_order2,@second_sort_order2,@third_sort_order2)
	
		DECLARE book_cursor CURSOR FOR
		select entity_id, parent_entity_id, entity_name, hierarchy_level, 1 as have_rights,first_sort_order,second_sort_order,third_sort_order
		from ems_portfolio_hierarchy
		where hierarchy_level = 0 AND parent_entity_id = @strategy_entity_id and emission_group_id=@group_id
		group by entity_id, parent_entity_id, entity_name, hierarchy_level,first_sort_order,second_sort_order,third_sort_order
		order by first_sort_order,second_sort_order,third_sort_order
		
		OPEN book_cursor
		
		FETCH NEXT FROM book_cursor
		INTO @entity_id, @parent_entity_id, @entity_name, @node_type, @have_rights,@first_sort_order1,@second_sort_order1,@third_sort_order1
	
		WHILE @@FETCH_STATUS = 0   -- book
		BEGIN 
	
			SET @book_entity_name = @entity_name
			INSERT INTO #sorted_return_entity values(@entity_id, @parent_entity_id, @sub_entity_name + '|' + @str_entity_name + '|' + @entity_name, @have_rights, @node_type,@first_sort_order1,@second_sort_order1,@third_sort_order1)
	
			FETCH NEXT FROM book_cursor
			INTO @entity_id, @parent_entity_id, @entity_name, @node_type, @have_rights,@first_sort_order1,@second_sort_order1,@third_sort_order1
	
		END -- end book
		CLOSE book_cursor
		DEALLOCATE  book_cursor
	
		FETCH NEXT FROM strategy_cursor
		INTO @entity_id, @parent_entity_id, @entity_name, @node_type, @have_rights,@first_sort_order2,@second_sort_order2,@third_sort_order2
	END  -- end strategy
	CLOSE strategy_cursor
	DEALLOCATE  strategy_cursor

FETCH NEXT FROM sub_cursor
INTO @entity_id, @parent_entity_id, @entity_name, @node_type, @have_rights,@first_sort_order,@second_sort_order,@third_sort_order
END  -- end sub
CLOSE sub_cursor
DEALLOCATE  sub_cursor

--SELECT entity_id, parent_entity_id, entity_name, have_rights, node_type FROM #sorted_return_entity
SELECT entity_id, entity_name, have_rights, node_type  FROM #sorted_return_entity
order by next_id

--order by parent_entity_id +  node_type + entity_id desc
end
else if @flag='a'
begin
select entity_id,entity_name,emission_group_id from ems_portfolio_hierarchy where entity_id=@entity_id
end
else if @flag='b' -- List EMS Book by hierarchy_level
begin
select book.entity_id,start.entity_name +'.'+ book.entity_name EntityName ,book.emission_group_id from ems_portfolio_hierarchy start
join ems_portfolio_hierarchy book on start.entity_id=book.parent_entity_id 
 where book.hierarchy_level=@hierarchy_level
order by start.entity_name,book.entity_name
end
else if @flag='i'
begin
insert ems_portfolio_hierarchy(
	entity_name,
	entity_type_value_id,
	hierarchy_level,
	parent_entity_id,
	emission_group_id)
values(
	@entity_name,
	@entity_type_value_id,
	@hierarchy_level,
	@parent_entity_id,
	@group_id)
	If @@ERROR <> 0
			Exec spa_ErrorHandler  @@ERROR, 'Emission Group', 
						'ems_group', 'DB Error', 
						'Failed to insert Emission Reporting Group.', ''
	Else
			Exec spa_ErrorHandler 0, 'Emission Group', 
						'ems_group', 'Success', 
						'Emission Reporting Group successfully inserted.', ''
end
else if @flag='u'
begin
	update ems_portfolio_hierarchy
	set entity_name=@entity_name
	where entity_id=@entity_id
	If @@ERROR <> 0
			Exec spa_ErrorHandler  @@ERROR, 'Emission Group', 
						'ems_group', 'DB Error', 
						'Failed to update Emission Reporting Group.', ''
	Else
			Exec spa_ErrorHandler 0, 'Emission Group', 
						'ems_group', 'Success', 
						'Emission Reporting Group successfully update.', ''
	
end
else if @flag='d'
begin
	delete ems_portfolio_hierarchy
	where entity_id=@entity_id
		If @@ERROR <> 0
			Exec spa_ErrorHandler  @@ERROR, 'Emission Group', 
						'ems_group', 'DB Error', 
						'Failed to delete Emission Reporting Group.', ''
	Else
			Exec spa_ErrorHandler 0, 'Emission Group', 
						'ems_group', 'Success', 
						'Emission Reporting Group successfully deleted.', ''
end










