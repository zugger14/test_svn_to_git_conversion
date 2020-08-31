IF OBJECT_ID('spa_delete_ProcessTable') IS NOT NULL
DROP PROCEDURE [dbo].[spa_delete_ProcessTable]
 GO 

/*
exec  spa_get_Script_ProcessTableFunc 'max','as_of_date','report_measurement_values','as_of_date<=''2005-01-15'''
exec('
select * from process_table_location;select * from process_table_location
')

*/
create proc [dbo].[spa_delete_ProcessTable] 
@table_name varchar(50),@where_expression varchar(1000)=null
as

--declare @aggregative_func varchar(30),@field_name varchar(50),@table_name varchar(50),@where_expression varchar(50)
--set @aggregative_func='min'
--set @field_name='as_of_date'
--set @table_name='report_measurement_values'
--set @where_expression='as_of_date<=''2005-01-15'''


declare @st1 varchar(8000)
set @st1=''
select @st1= @st1+case when isnull(@st1,'')='' then '' else ' ; ' end + 'delete '+@table_name+isnull(prefix_location_table,'')+ case when isnull(@where_expression,'')='' then '' else ' where ('+  @where_expression +')' end from process_table_location where tbl_name=@table_name group by prefix_location_table
--print @st1
exec(@st1)





