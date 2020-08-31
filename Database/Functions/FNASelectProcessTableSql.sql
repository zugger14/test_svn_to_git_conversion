IF OBJECT_ID(N'FNASelectProcessTableSql', N'FN') IS NOT NULL 
DROP FUNCTION [dbo].[FNASelectProcessTableSql]
GO 

CREATE FUNCTION [dbo].[FNASelectProcessTableSql](@field_name VARCHAR(1000),@tbl_name VARCHAR(150),@where_expression VARCHAR(1000))
RETURNS VARCHAR(5000)
AS
BEGIN

/*
declare @field_name varchar(300),@tbl_name varchar(50),@where_expression varchar(50)
select * from process_table_location

--set @aggregative_func='min'
set @field_name='*'
set @tbl_name='source_deal_pnl'
set  @where_expression=''
--*/
declare @st1 varchar(8000)
set @st1=''
select @st1= @st1+case when isnull(@st1,'')='' then '' else ' union all ' end + 'select '+@field_name+ ' from '
			 +case when isnull(max(dbase_name),'dbo')='dbo' THEN 'dbo' ELSE max(dbase_name) + '.dbo' END + '.'+@tbl_name+isnull(prefix_location_table,'')+ case when isnull(@where_expression,'')='' then '' else ' where ('+  @where_expression +')' end 
			 from process_table_archive_policy where tbl_name=@tbl_name 
			 group by prefix_location_table
--print @st1

	RETURN(@st1)
END
				
		
