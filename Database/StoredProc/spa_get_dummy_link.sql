IF OBJECT_ID(N'[dbo].[spa_get_dummy_link]', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_get_dummy_link]
GO 

CREATE procedure [dbo].[spa_get_dummy_link]

as

create table #temp_link(
grp int,
link_id int,
percentage float)

insert into #temp_link select 1,50,0.4
insert into #temp_link select 1,51,0.6
insert into #temp_link select 1,52,0.3
insert into #temp_link select 2,59,0.2
insert into #temp_link select 2,60,0.5
insert into #temp_link select 2,61,0.1
insert into #temp_link select 3,61,0.1
insert into #temp_link select 3,61,0.1

select grp,link_id,cast(round(percentage, 2) as varchar) as percentage  from #temp_link




