IF OBJECT_ID(N'[dbo].[spa_run_sql_adhoc]', N'P') IS NOT NULL
DROP proc [dbo].[spa_run_sql_adhoc]
GO
/****** Object:  StoredProcedure [dbo].[spa_run_sql_adhoc]    Script Date: 10/02/2008 17:30:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc [dbo].[spa_run_sql_adhoc]
@sql_stmt varchar(max),
@batch_process_id varchar(100)=NULL,	
@batch_report_param varchar(1000)=NULL
as 

declare @str_batch_table varchar(max)
SET @str_batch_table=''        
IF @batch_process_id is not null        
	 SELECT @str_batch_table=dbo.FNABatchProcess('s',@batch_process_id,@batch_report_param,NULL,NULL,NULL)         


declare @from_i int
set @from_i = charindex('from', @sql_stmt, 0)

IF  @batch_process_id is not  null 
begin

	set @sql_stmt = substring(@sql_stmt, 0, @from_i) + @str_batch_table + ' ' +  substring(@sql_stmt, @from_i, len(@sql_stmt)) 

		     
	SELECT @str_batch_table=dbo.FNABatchProcess('u',@batch_process_id,@batch_report_param,GETDATE(),NULL,NULL)         
	EXEC(@str_batch_table)        
	declare @report_name varchar(100)        
	 set @report_name='Run Report Writer'        
    SELECT @str_batch_table=dbo.FNABatchProcess('c',@batch_process_id,@batch_report_param,GETDATE(),'spa_run_sql',@report_name)         
	EXEC(@str_batch_table)        
       

end
exec spa_print @sql_stmt

exec(@sql_stmt)






