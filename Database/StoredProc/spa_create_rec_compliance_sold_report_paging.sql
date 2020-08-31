IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_create_rec_compliance_sold_report_paging]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_create_rec_compliance_sold_report_paging]
GO 

--EXEC spa_create_rec_compliance_sold_report_paging '96', null, null, 5118, 2005, 5146,'Duke Energy'

CREATE proc [dbo].[spa_create_rec_compliance_sold_report_paging]
		@sub_entity_id varchar(100), 
		@strategy_entity_id varchar(100) = NULL, 
		@book_entity_id varchar(100) = NULL, 
		@compliance_state varchar(20),
		@compliance_year varchar(20),
		@assignment_type_value_id int = 5146,
		@convert_uom_id int, 
		@counterparty varchar(100) = NULL,
		@process_id varchar(200)=NULL, 
		@page_size int =NULL,
		@page_no int=NULL 
as

SET NOCOUNT ON 
declare @user_login_id varchar(50),@tempTable varchar(300) ,@flag char(1)

	set @user_login_id=dbo.FNADBUser()

	if @process_id is NULL
	Begin
		set @flag='i'
		set @process_id=REPLACE(newid(),'-','_')
	End
	set @tempTable=dbo.FNAProcessTableName('paging_compliance_sold_report', @user_login_id,@process_id)
	--print @tempTable
	declare @sqlStmt varchar(5000)

if @flag='i'
begin
	set @sqlStmt='create table '+ @tempTable+'( 
	sno int  identity(1,1),
	Resource varchar(500),
	ID varchar(500),
	[Cert #] varchar(250),
	RefID varchar(500),
	AssignedState varchar(500),
	AssignedType varchar(500),
	Obligation varchar(500),
	[Year] varchar(500),
	GenDate varchar(500),
	[Buy/Sell] varchar(500),
	[Expiration] varchar(500),
	[DealDate] varchar(500),
	[HE] varchar(500),
	[Counterparty] varchar(500),
	[Volume] varchar(500),
	[Bonus] varchar(500),
	[Total Volume MWh (+Long/-Short)] varchar(500),
	[Settlement $] varchar(500)
	)'
	
	--print @sqlStmt
	exec(@sqlStmt)
	
	set @sqlStmt=' insert  '+@tempTable+'
	exec spa_create_rec_compliance_sold_report '+ dbo.FNASingleQuote(@sub_entity_id ) +','+ 
	dbo.FNASingleQuote(@strategy_entity_id ) +',' +
	dbo.FNASingleQuote(@book_entity_id)+',' +
	dbo.FNASingleQuote(@compliance_state)+',' +
	dbo.FNASingleQuote(@compliance_year)+',' +
	dbo.FNASingleQuote(@assignment_type_value_id) +',' +
	dbo.FNASingleQuote(@convert_uom_id)+',' +
	dbo.FNASingleQuote(@counterparty) 


	--print @sqlStmt
	exec(@sqlStmt)	

	set @sqlStmt='select count(*) TotalRow,'''+@process_id +''' process_id  from '+ @tempTable
--	EXEC spa_print @sqlStmt
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

set @sqlStmt='select 	Resource, ID, [Cert #], RefID, AssignedState, AssignedType,
			Obligation, [Year], GenDate, [Buy/Sell],
			[Expiration], DealDate [Date], [HE], [Counterparty],
			[Volume], [Bonus], [Total Volume MWh (+Long/-Short)] [Total Volume (+Long/-Short)], [Settlement $]  
		from '+ @tempTable  +' where sno between '+ cast(@row_from as varchar) +' and '+ cast(@row_to as varchar) + ' order by sno asc'
exec(@sqlStmt)
end



