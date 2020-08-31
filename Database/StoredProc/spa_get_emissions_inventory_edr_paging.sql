IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_get_emissions_inventory_edr_paging]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_get_emissions_inventory_edr_paging]
GO 
CREATE PROCEDURE [dbo].[spa_get_emissions_inventory_edr_paging]
	@flag char(1)='s', -- 's' summary,'d' detail
	@sub_entity_id varchar(100)=null,
	@strategy_entity_id varchar(100)=null,
	@fas_book_id varchar(100)=null,
	@generator_id varchar(1000)=NULL,
	@term_start datetime=null,
	@term_end datetime=null,
	@curve_id int=null,
	@frequency int=null,
	@view_hourly char(1)='n',
	@process_id varchar(100)=NULL, 
	@page_size int =NULL,
	@page_no int=NULL 
AS
BEGIN

declare @user_login_id varchar(50),@tempTable varchar(300) 

	set @user_login_id=dbo.FNADBUser()

	if @process_id is NULL
	Begin
		set @flag='i'
		set @process_id=REPLACE(newid(),'-','_')
	End
	set @tempTable=dbo.FNAProcessTableName('paging_temp_edr_dat_report', @user_login_id,@process_id)
	declare @sqlStmt varchar(5000)


if @flag='i'
begin

	set @sqlStmt=' 
	exec  spa_get_emissions_inventory_edr s, '+ 
	dbo.FNASingleQuote(@sub_entity_id) +','+ 
	dbo.FNASingleQuote(@strategy_entity_id) +','+ 
	dbo.FNASingleQuote(@fas_book_id) +','+ 
	dbo.FNASingleQuote(@generator_id) +','+ 
	dbo.FNASingleQuote(@term_start) +',' +
	dbo.FNASingleQuote(@term_end) +',' +
	dbo.FNASingleQuote(@curve_id) +',' +
	dbo.FNASingleQuote(@frequency)+',' +
	dbo.FNASingleQuote(@view_hourly)  + ',' +
	dbo.FNASingleQuote(@tempTable) + ',' +
	dbo.FNASingleQuote(@process_id)


exec(@sqlStmt)	
exec('Alter table '+@tempTable+' add SNO int identity(1,1)')

end
else
begin
	declare @row_to int,@row_from int
	set @row_to=@page_no * @page_size
	if @page_no > 1 
	set @row_from =((@page_no-1) * @page_size)+1
	else
	set @row_from =@page_no



DECLARE @col_names varchar(100)
DECLARE @all_col_names varchar(1000)
set @all_col_names=''
declare cur_col cursor for
SELECT     c.name AS Expr1
FROM         adiha_process.dbo.sysobjects o INNER JOIN
                      adiha_process.dbo.syscolumns c ON o.id = c.id AND o.xtype = 'U'
WHERE     (o.name like '%'+@process_id+'%')
open cur_col
fetch next from cur_col into @col_names

while @@fetch_status=0
begin
	if @all_col_names=''
		set @all_col_names='['+@col_names+']'
	else
		set @all_col_names=@all_col_names+','+'['+@col_names+']'
fetch next from cur_col into @col_names
end
close cur_col
deallocate cur_col

set @all_col_names=REVERSE(substring(REVERSE(@all_col_names),charindex(',',REVERSE(@all_col_names))+1,len(@all_col_names)))


		set @sqlStmt='select '+@all_col_names+' from '+ @tempTable  +' where sno between '+ cast(@row_from as varchar) 
						+' and '+ cast(@row_to as varchar)+ ' order by sno asc'
EXEC spa_print @sqlStmt
		exec(@sqlStmt)

end

end


