
IF OBJECT_ID(N'spa_count_process_exceptions', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_count_process_exceptions]
 GO 

--EXEC spa_count_process_exceptions  '1,2,20', 'd'
--Returns the number of assessment values that are either missing or done beyond the quarter
-- Report type 'c' means exceptions counts, 'd' means detail view by date
create procedure [dbo].[spa_count_process_exceptions] 
@sub_entity_id varchar(100), @report_type varchar(1) = 'c'
as

--declare @sub_entity_id varchar(100), @report_type varchar(1) 
--set @sub_entity_id='1,30,256,259,280'
--set @report_type='c'

--drop table #temp
create table #temp
(
[Date] varchar (1000) COLLATE DATABASE_DEFAULT,
exception_count int 
)
-- 
-- create table #temp_sub
-- (
-- subs varchar (50) COLLATE DATABASE_DEFAULT 
-- )

declare @aDate as datetime
declare @as_of_date varchar(20)
declare @pre_days_count int
declare @next_item int
--declare @privileged_subs varchar(50)

set @aDate = getdate()
SET @next_item = 0

select @pre_days_count = var_value from adiha_default_codes_values where instance_no = 1 and default_code_id = 8 and seq_no = 1
-- INSERT #temp_sub exec spa_get_privileged_subs 79
-- SELECT @privileged_subs = subs FROM #temp_sub
-- 
-- EXEC spa_print @privileged_subs
--get the current date
-- set @as_of_date = dbo.FNADateFormat(@aDate)
-- insert #temp EXEC spa_Get_Risk_Control_Activities NULL, @as_of_date, NULL, NULL, 675, NULL, 'e', 3, NULL, 1
-- get the previous days based on default value @pre_days_count
WHILE (@pre_days_count > 0)
BEGIN
	set @as_of_date = dbo.FNAGetSQLStandardDate(dateadd(dd, @next_item, @aDate))
--COMMENT by PRATISHARA 23 sep
--insert #temp EXEC spa_Get_Risk_Control_Activities NULL, @as_of_date, @sub_entity_id, NULL, 675, NULL, 'e', 3, NULL, 1
--	insert #temp EXEC spa_Get_Risk_Control_Activities NULL, @as_of_date, NULL, NULL, 675, NULL, 'e', 3, NULL, 1

	SET @pre_days_count =  @pre_days_count - 1
	SET @next_item = @next_item - 1
END

 

-- set @as_of_date = dbo.FNADateFormat(dateadd(dd, -2, @aDate))
-- insert #temp EXEC spa_Get_Risk_Control_Activities NULL, @as_of_date, NULL, NULL, 675, NULL, 'e', 3, NULL, 1
-- set @as_of_date = dbo.FNADateFormat(dateadd(dd, -3, @aDate))
-- insert #temp EXEC spa_Get_Risk_Control_Activities NULL, @as_of_date, NULL, NULL, 675, NULL, 'e', 3, NULL, 1
-- set @as_of_date = dbo.FNADateFormat(dateadd(dd, -4, @aDate))
-- insert #temp EXEC spa_Get_Risk_Control_Activities NULL, @as_of_date, NULL, NULL, 675, NULL, 'e', 3, NULL, 1
-- set @as_of_date = dbo.FNADateFormat(dateadd(dd, -5, @aDate))
-- insert #temp EXEC spa_Get_Risk_Control_Activities NULL, @as_of_date, NULL, NULL, 675, NULL, 'e', 3, NULL, 1
-- set @as_of_date = dbo.FNADateFormat(dateadd(dd, -6, @aDate))
-- insert #temp EXEC spa_Get_Risk_Control_Activities NULL, @as_of_date, NULL, NULL, 675, NULL, 'e', 3, NULL, 1
-- set @as_of_date = dbo.FNADateFormat(dateadd(dd, -7, @aDate))
-- insert #temp EXEC spa_Get_Risk_Control_Activities NULL, @as_of_date, NULL, NULL, 675, NULL, 'e', 3, NULL, 1
-- set @as_of_date = dbo.FNADateFormat(dateadd(dd, -7, @aDate))
-- insert #temp EXEC spa_Get_Risk_Control_Activities NULL, @as_of_date, NULL, NULL, 675, NULL, 'e', 3, NULL, 1
-- set @as_of_date = dbo.FNADateFormat(dateadd(dd, -8, @aDate))
-- insert #temp EXEC spa_Get_Risk_Control_Activities NULL, @as_of_date, NULL, NULL, 675, NULL, 'e', 3, NULL, 1
-- set @as_of_date = dbo.FNADateFormat(dateadd(dd, -9, @aDate))
-- insert #temp EXEC spa_Get_Risk_Control_Activities NULL, @as_of_date, NULL, NULL, 675, NULL, 'e', 3, NULL, 1
-- set @as_of_date = dbo.FNADateFormat(dateadd(dd, -10, @aDate))
-- insert #temp EXEC spa_Get_Risk_Control_Activities NULL, @as_of_date, NULL, NULL, 675, NULL, 'e', 3, NULL, 1
-- set @as_of_date = dbo.FNADateFormat(dateadd(dd, -11, @aDate))
-- insert #temp EXEC spa_Get_Risk_Control_Activities NULL, @as_of_date, NULL, NULL, 675, NULL, 'e', 3, NULL, 1
-- set @as_of_date = dbo.FNADateFormat(dateadd(dd, -12, @aDate))
-- insert #temp EXEC spa_Get_Risk_Control_Activities NULL, @as_of_date, NULL, NULL, 675, NULL, 'e', 3, NULL, 1
-- set @as_of_date = dbo.FNADateFormat(dateadd(dd, -13, @aDate))
-- insert #temp EXEC spa_Get_Risk_Control_Activities NULL, @as_of_date, NULL, NULL, 675, NULL, 'e', 3, NULL, 1
-- set @as_of_date = dbo.FNADateFormat(dateadd(dd, -14, @aDate))
-- insert #temp EXEC spa_Get_Risk_Control_Activities NULL, @as_of_date, NULL, NULL, 675, NULL, 'e', 3, NULL, 1
-- set @as_of_date = dbo.FNADateFormat(dateadd(dd, -15, @aDate))
-- insert #temp EXEC spa_Get_Risk_Control_Activities NULL, @as_of_date, NULL, NULL, 675, NULL, 'e', 3, NULL, 1
 
If @report_type = 'c'
BEGIN
	select 'Process exception(s) found with High priority' as [desc], sum(exception_count) as exception_count from #temp
END
Else
	select * from  #temp











