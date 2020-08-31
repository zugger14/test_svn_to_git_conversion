IF OBJECT_ID(N'[dbo].[spa_get_rec_assign_log_paging]', N'P') IS NOT NULL
   DROP PROCEDURE [dbo].[spa_get_rec_assign_log_paging]
GO


CREATE PROCEDURE [dbo].[spa_get_rec_assign_log_paging]
		@process_id_prev varchar(200),
		@process_id varchar(200)=NULL, 
		@page_size int =NULL,
		@page_no int=NULL 

AS

declare @user_login_id varchar(50),@tempTable varchar(300) ,@flag char(1)

	set @user_login_id=dbo.FNADBUser()

	if @process_id is NULL
	Begin
		set @flag='i'
		set @process_id=REPLACE(newid(),'-','_')
	End
	set @tempTable=dbo.FNAProcessTableName('paging_get_rec_assign_log', @user_login_id,@process_id)
	declare @sqlStmt varchar(5000)

if @flag='i'
begin
	set @sqlStmt='create table '+ @tempTable+'( 
	sno int  identity(1,1),
	Code varchar(500),
	Module varchar(500),
	[Action] varchar(500),
	ID varchar(500),
	[Sale From] varchar(500),
	CreatedBy varchar(500),
	CreatedTS varchar(500)
	)'

	exec(@sqlStmt)


-- 	set @sqlStmt='exec spa_get_rec_assign_log    ' + dbo.FNASingleQuote(@process_id_prev)
-- 	exec(@sqlStmt)
-- 	

	set @sqlStmt=' insert  '+@tempTable+'
	exec spa_get_rec_assign_log  '+ dbo.FNASingleQuote(@process_id_prev)

--	EXEC spa_print @sqlStmt
	exec(@sqlStmt)	

	set @sqlStmt='select count(*) TotalRow,'''+@process_id +''' process_id  from '+ @tempTable
	--print @sqlStmt
	exec(@sqlStmt)
end
else
begin
declare @row_to int,@row_from int
set @row_to=@page_no * @page_size
if @page_no > 1 
set @row_from =((@page_no-1) * @page_size)+1
else
set @row_from =@page_no

set @sqlStmt='select Code,Module,[Action],ID,[Sale From] [Assigned From],CreatedBy,CreatedTS  from '+ @tempTable  +' where sno between '+ cast(@row_from as varchar) +' and '+ 
	cast(@row_to as varchar) + ' order by sno asc'
	exec(@sqlStmt)
end








