
IF OBJECT_ID(N'spa_count_failed_assessment_exceptions', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_count_failed_assessment_exceptions]
 GO 




--EXEC spa_count_failed_assessment_exceptions  '1,2,20'
--Returns the number of assessment values that are either missing or done beyond the quarter
create procedure [dbo].[spa_count_failed_assessment_exceptions] @sub_entity_id varchar(100)
as
--drop table #temp
create table #temp
(
c1 varchar (1000) COLLATE DATABASE_DEFAULT,
c2 varchar (1000) COLLATE DATABASE_DEFAULT,
c3 varchar (1000) COLLATE DATABASE_DEFAULT,
c4 varchar (1000) COLLATE DATABASE_DEFAULT,
c5 varchar (1000) COLLATE DATABASE_DEFAULT,
c6 varchar (1000) COLLATE DATABASE_DEFAULT,
c7 varchar (1000) COLLATE DATABASE_DEFAULT,
c8 varchar (1000) COLLATE DATABASE_DEFAULT,
c9 varchar (1000) COLLATE DATABASE_DEFAULT,
c10 varchar (1000) COLLATE DATABASE_DEFAULT,
c11 varchar (1000) COLLATE DATABASE_DEFAULT,
c12 varchar (1000) COLLATE DATABASE_DEFAULT,
c13 varchar (1000) COLLATE DATABASE_DEFAULT,
c14 varchar (1000) COLLATE DATABASE_DEFAULT,
c15 varchar (1000) COLLATE DATABASE_DEFAULT,
c16 varchar (1000) COLLATE DATABASE_DEFAULT
)

declare @exception_count int 

--EXEC spa_create_failed_assessment_reports '1,2,20', NULL, NULL, NULL, 'e'

insert #temp EXEC spa_create_failed_assessment_reports @sub_entity_id, NULL, NULL, NULL, 'e'
select @exception_count = count(*) from #temp 


if @exception_count IS NOT NULL AND @exception_count > 0
	Select 'Failed Assessment exception(s) found' as [desc], @exception_count  as [exception_count]
Else
	Select 'No failed assessment exceptions found' [desc], 0 as exception_count







