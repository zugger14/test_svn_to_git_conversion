IF OBJECT_ID(N'spa_Create_Inventory_Journal_Entry_Report_paging', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_Create_Inventory_Journal_Entry_Report_paging]
 GO 






--EXEC spa_Create_Inventory_Journal_Entry_Report '2004-01-01', null, '95', null, null, 'd', 'j', null, null, 'y', 'n', '01/31/2004', '01/01/2004','Sempra'

--EXEC spa_Create_Inventory_Journal_Entry_Report_paging '2004-01-01', null, '95', null, null, 'd', 'j', null, null, 'y', 'n', '01/31/2004', '01/01/2004','Sempra'



CREATE PROCEDURE [dbo].[spa_Create_Inventory_Journal_Entry_Report_paging]
		@as_of_date varchar(50), 
		@as_of_date_to varchar(50), 
		@sub_entity_id varchar(100), 
		@strategy_entity_id varchar(100) = NULL, 
		@book_entity_id varchar(100) = NULL, 
		@summary_option char(1) = 'e',
		@report_type char(1)= 'j', 
		@link_id varchar(500) = null,
		@counterparty_id int = null,	
	    	@final_prior_months varchar(1) = 'y',
	    	@reverse_prior_months varchar(1) = 'n',
		@state_value_id int = null,
		@as_of_date_drill varchar(50) = null,
		@production_month_drill varchar(50) = null,
		@Counterparty varchar(100) = NULL,
		@gl_number varchar(250) = NULL,
		@process_id varchar(200)=NULL, 
		@page_size int =NULL,
		@page_no int=NULL 
AS

SET NOCOUNT ON 

declare @user_login_id varchar(50),@tempTable varchar(300) ,@flag char(1)

	set @user_login_id=dbo.FNADBUser()

	if @process_id is NULL
	Begin
		set @flag='i'
		set @process_id=REPLACE(newid(),'-','_')
	End
	set @tempTable=dbo.FNAProcessTableName('paging_Create_Inventory_Journal_Entry_Report', @user_login_id,@process_id)
	declare @sqlStmt varchar(5000)

if @flag='i'
begin

	set @sqlStmt='create table '+ @tempTable+'( 
	sno int  identity(1,1),
	AsOfDate varchar(200),
	ProductionMonth varchar(200),
	ID	varchar(500),
	RefID varchar(50),
	Type varchar(10),
	Counterparty varchar(200),
	[Settlement Rec(+)/Pay(-)] varchar(200),
	[REC Value Long(-)/Short(+)] varchar(200), 
	[AR Db(+)/Cr(-)] varchar(200),
	[Liability Db(+)/Cr(-)] varchar(200),
	[Inventory  Db(+)/Cr(-)] varchar(200),
	[Expenses Db(+)/Cr(-)] varchar(200),
	[Adjustments Db] varchar(200),
	[Adjustments Cr] varchar(200)
	)'

	exec(@sqlStmt)
	
	set @sqlStmt=' insert  '+@tempTable+'
	exec  spa_Create_Inventory_Journal_Entry_Report '+ dbo.FNASingleQuote(@as_of_date) +','+ 
	dbo.FNASingleQuote(@as_of_date_to) +',' +
	dbo.FNASingleQuote(@sub_entity_id) +',' +
	dbo.FNASingleQuote(@strategy_entity_id) +',' +
	dbo.FNASingleQuote(@book_entity_id) +',' +
	dbo.FNASingleQuote(@summary_option) +',' +
	dbo.FNASingleQuote(@report_type)+',' +
	dbo.FNASingleQuote(@link_id)+',' +
	case when(@counterparty_id IS NULL) then 'NULL' else cast(@counterparty_id as varchar) end + ',' +	
	dbo.FNASingleQuote(@final_prior_months)+',' +
	dbo.FNASingleQuote(@reverse_prior_months)+',' +
	case when(@state_value_id IS NULL) then 'NULL' else cast(@state_value_id as varchar) end + ',' +	
	dbo.FNASingleQuote(@as_of_date_drill)+',' +
	dbo.FNASingleQuote(@production_month_drill)+',' +
	dbo.FNASingleQuote(@Counterparty)+',' +
	dbo.FNASingleQuote(@gl_number)

	--print @sqlStmt
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

set @sqlStmt='select  AsOfDate,ProductionMonth, 	
			ID as [ID (Cert #)], RefID, Type, Counterparty,
		[Settlement Rec(+)/Pay(-)],[REC Value Long(-)/Short(+)], [AR Db(+)/Cr(-)],
		[Liability Db(+)/Cr(-)],
		[Inventory  Db(+)/Cr(-)],[Expenses Db(+)/Cr(-)],[Adjustments Db], [Adjustments Cr]
		from '+ @tempTable  +' where sno between '+ cast(@row_from as varchar) +' and '+ cast(@row_to as varchar) + ' order by sno asc'
	exec(@sqlStmt)
end













