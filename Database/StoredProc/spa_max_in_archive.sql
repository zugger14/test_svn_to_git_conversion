IF OBJECT_ID(N'spa_max_in_archive', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_max_in_archive]
 GO 

CREATE PROCEDURE [dbo].[spa_max_in_archive]
	@field_name VARCHAR(50),
	@table_name VARCHAR(50),
	@where_expression VARCHAR(50)
AS
DECLARE @st   VARCHAR(8000)
DECLARE @st1  VARCHAR(8000)
SET  @st1=''
SELECT  @st1= @st1+CASE  WHEN ISNULL(@st1,'')='' THEN '' ELSE ' union all ' END + 'select max('+@field_name+') '+@field_name+' from  '+@table_name+ISNULL(prefix_location_table,'')+ CASE WHEN ISNULL(@where_expression,'')='' THEN '' ELSE ' where ('+  @where_expression +')' END FROM process_table_location WHERE tbl_name='report_measurement_values' group by prefix_location_table
EXEC spa_print @st1