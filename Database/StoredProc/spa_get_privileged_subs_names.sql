
IF OBJECT_ID(N'[dbo].[spa_get_privileged_subs_names]', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_get_privileged_subs_names]
GO 

CREATE PROC [dbo].[spa_get_privileged_subs_names] 
	@function_id int
	
AS

CREATE TABLE [#temp] (
	[sub_entity_id] [int] NOT NULL ,
	[sub_entity_name] [varchar] (100) COLLATE DATABASE_DEFAULT NOT NULL
) 

declare @entity_name varchar(100)
declare @all_entity_ids varchar (1000)

set @all_entity_ids =  ''

insert into #temp exec get_subsidiaries_for_rights @function_id

DECLARE a_cursor CURSOR FOR
	select sub_entity_name + ' (' + sc.currency_name + ')' as sub_entity_name
	from #temp INNER JOIN
	fas_subsidiaries fs ON fs.fas_subsidiary_id = #temp.sub_entity_id LEFT OUTER JOIN
	source_currency sc ON fs.func_cur_value_id = sc.source_currency_id
	order by sub_entity_name
	
	OPEN a_cursor
	
	FETCH NEXT FROM a_cursor
	INTO @entity_name

	WHILE @@FETCH_STATUS = 0   -- book
	BEGIN 

		If @all_entity_ids <> '' set @all_entity_ids = @all_entity_ids + ', '
		set @all_entity_ids = @all_entity_ids + @entity_name

		FETCH NEXT FROM a_cursor
		INTO @entity_name

	END -- end book
	CLOSE a_cursor
	DEALLOCATE  a_cursor

select @all_entity_ids as ids







