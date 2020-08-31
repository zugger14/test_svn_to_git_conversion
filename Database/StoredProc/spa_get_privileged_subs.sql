
IF OBJECT_ID(N'[dbo].[spa_get_privileged_subs]', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_get_privileged_subs]
GO 

CREATE PROC [dbo].[spa_get_privileged_subs] 
	@function_id int
	
AS

CREATE TABLE [#temp] (
	[sub_entity_id] [int] NOT NULL ,
	[sub_entity_name] [varchar] (100) COLLATE DATABASE_DEFAULT NOT NULL
) 

declare @entity_id varchar(100)
declare @all_entity_ids varchar (1000)

set @all_entity_ids =  ''

--insert into #temp exec get_subsidiaries_for_rights 84 @function_id

insert into #temp
select distinct ph.entity_id, ph.entity_name from portfolio_hierarchy ph right outer join
	(
		SELECT  distinct application_functional_users.entity_id AS entity_id 
		FROM       application_users INNER JOIN
		           application_functional_users ON application_users.user_login_id = application_functional_users.login_id
		WHERE      application_functional_users.function_id = @function_id AND 	   
			   application_functional_users.role_user_flag = 'u' AND 
			   application_users.user_login_id = dbo.FNADBUser() 
		UNION 
		
		SELECT     distinct  application_functional_users.entity_id AS entity_id
		FROM       application_users INNER JOIN
		           application_role_user ON application_users.user_login_id = application_role_user.user_login_id INNER JOIN
		           application_functional_users ON application_role_user.role_id = application_functional_users.role_id
		WHERE      application_functional_users.role_user_flag = 'r'
		 AND 	   application_users.user_login_id = dbo.FNADBUser() 
		 AND        application_functional_users.function_id  = @function_id
	) er
	on isnull(er.entity_id, ph.entity_id) = ph.entity_id
where ph.entity_type_value_id  = 525

DECLARE a_cursor CURSOR FOR
	select sub_entity_id
	from #temp
	order by sub_entity_id
	
	OPEN a_cursor
	
	FETCH NEXT FROM a_cursor
	INTO @entity_id

	WHILE @@FETCH_STATUS = 0   -- book
	BEGIN 

		If @all_entity_ids <> '' set @all_entity_ids = @all_entity_ids + ','
		set @all_entity_ids = @all_entity_ids + @entity_id

		FETCH NEXT FROM a_cursor
		INTO @entity_id

	END -- end book
	CLOSE a_cursor
	DEALLOCATE  a_cursor

select @all_entity_ids as ids


