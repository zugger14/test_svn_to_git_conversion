
IF OBJECT_ID(N'spa_count_assessment_exceptions', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_count_assessment_exceptions]
 GO 




--EXEC spa_count_assessment_exceptions  '1,2,20'
--Returns the number of assessment values that are either missing or done beyond the quarter
create procedure [dbo].[spa_count_assessment_exceptions] @sub_entity_id varchar(100)
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
c11 varchar (1000) COLLATE DATABASE_DEFAULT
)

declare @threshold_date varchar(20)
declare @exception_count int 

set @threshold_date = dbo.FNAGetSQLStandardDate(getdate())


insert #temp EXEC spa_Create_Missing_Assessment_Values_Exception_Report  @sub_entity_id, null, null, null, @threshold_date, 'o', 'a'
select @exception_count = count(c11) from #temp where c11 = 'yes'

--'./dev/spa_html.php?spa=exec spa_Create_Missing_Assessment_Values_Exception_Report ''' + @sub_entity_id + ''',NULL,NULL,NULL,''' + @threshold_date + ''',''o'',''a''&__user_name__=' + dbo.FNADBUser()

if @exception_count IS NOT NULL AND @exception_count > 0
	Select 'Assessment exception(s) found (missing or run beyond a quarter)' as [desc], @exception_count  as [exception_count]
Else
	Select 'No assessment exceptions found' [desc], 0 as exception_count






