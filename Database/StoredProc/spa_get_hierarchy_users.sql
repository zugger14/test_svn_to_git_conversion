
IF OBJECT_ID(N'[dbo].[spa_get_hierarchy_users]', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_get_hierarchy_users]
GO 

-- exec spa_get_hierarchy_users 'urbaral'

CREATE PROC [dbo].[spa_get_hierarchy_users] 
	@user_login_id varchar(50)
AS


-- drop table #users

CREATE TABLE #users
(user_login_id varchar(50) COLLATE DATABASE_DEFAULT,
 reports_to_user_login_id varchar(50) COLLATE DATABASE_DEFAULT null,
 hlevel int)


insert into #users
select user_login_id, NULL, 1 
from application_users where user_login_id = @user_login_id

insert into #users
select user_login_id, reports_to_user_login_id, 2 
from application_users where reports_to_user_login_id in (select user_login_id from #users where hlevel=1) 

insert into #users
select user_login_id, reports_to_user_login_id, 3 
from application_users where reports_to_user_login_id in (select user_login_id from #users where hlevel=2) 

insert into #users
select user_login_id, reports_to_user_login_id, 4 
from application_users where reports_to_user_login_id in (select user_login_id from #users where hlevel=3) 

insert into #users
select user_login_id, reports_to_user_login_id, 5 
from application_users where reports_to_user_login_id in (select user_login_id from #users where hlevel=4) 

insert into #users
select user_login_id, reports_to_user_login_id, 6 
from application_users where reports_to_user_login_id in (select user_login_id from #users where hlevel=5) 

insert into #users
select user_login_id, reports_to_user_login_id, 7 
from application_users where reports_to_user_login_id in (select user_login_id from #users where hlevel=6) 

insert into #users
select user_login_id, reports_to_user_login_id, 8 
from application_users where reports_to_user_login_id in (select user_login_id from #users where hlevel=7) 

insert into #users
select user_login_id, reports_to_user_login_id, 9 
from application_users where reports_to_user_login_id in (select user_login_id from #users where hlevel=8) 

insert into #users
select user_login_id, reports_to_user_login_id, 10 
from application_users where reports_to_user_login_id in (select user_login_id from #users where hlevel=9)

insert into #users
select user_login_id, reports_to_user_login_id, 11 
from application_users where reports_to_user_login_id in (select user_login_id from #users where hlevel=10)  

select user_login_id, reports_to_user_login_id from #users order by hlevel


