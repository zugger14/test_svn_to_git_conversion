IF OBJECT_ID(N'[dbo].[spa_create_rec_compliance_report_paging]', N'P') IS NOT NULL
DROP PROC [dbo].[spa_create_rec_compliance_report_paging]
GO
CREATE PROCEDURE [dbo].[spa_create_rec_compliance_report_paging]
		@sub_entity_id varchar(100), 
		@strategy_entity_id varchar(100) = NULL, 
		@book_entity_id varchar(100) = NULL, 
		@compliance_state int,
		@compliance_year int,
		@assignment_type_value_id int = 5146,
		@convert_uom_id int, 
		@report_format int=1, 
		@show_bonus int=1, -- 1 - with bonus 2- without bonus 3- only bonus       
		@month int=NULL,         
		@drill_down_level int = 0,          
		@drill_value varchar(100) = null,  
		@drill_value1 varchar(100) = null,  	
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
	set @tempTable=dbo.FNAProcessTableName('paging_temp_create_rec_compliance_report', @user_login_id,@process_id)
	declare @sqlStmt varchar(5000)

if @flag='i'
begin
	set @sqlStmt='create table '+ @tempTable+'( 
	sno int  identity(1,1),
	Resource varchar(500),
	ID varchar(500),
	[Cert# From] varchar(250),
	[Cert# To] varchar(250),
	RefID varchar(500),
	[Assignedstate] varchar(500),
	AssignedType varchar(500),	
	Obligation varchar(500),
	[Year] varchar(500),
	GenDate varchar(500),
	[Buy/Sell] varchar(500),
	[Expiration] varchar(500),
	[Date] varchar(500),
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
	exec  spa_create_rec_compliance_report '+ dbo.FNASingleQuote(@sub_entity_id) +','+ 
	dbo.FNASingleQuote(@strategy_entity_id) +',' +
	dbo.FNASingleQuote(@book_entity_id) +',' +
	dbo.FNASingleQuote(@compliance_state) +',' +
	dbo.FNASingleQuote(@compliance_year) +',' +
	dbo.FNASingleQuote(@assignment_type_value_id) +',' +
	dbo.FNASingleQuote(@convert_uom_id) +',1,' +
	dbo.FNASingleQuote(@show_bonus)+','+
	dbo.FNASingleQuote(@month)+','+
	dbo.FNASingleQuote(@drill_down_level) +',' +
	dbo.FNASingleQuote(@drill_value) +',' +
	dbo.FNASingleQuote(@drill_value1)


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

set @sqlStmt='select Resource, ID, [Cert# From],[Cert# To], RefID, Assignedstate [Assigned Jurisdiction], AssignedType,
			Obligation [Env Product], [Year], GenDate Vintage, [Buy/Sell],
			[Expiration], Date [Date], [HE], [Counterparty],
			[Volume], [Bonus], [Total Volume MWh (+Long/-Short)]  [Total Volume (+Long/-Short)], [Settlement $]
		from '+ @tempTable  +' where sno between '+ cast(@row_from as varchar) +' and '+ cast(@row_to as varchar) + ' order by sno asc'
	exec(@sqlStmt)
end







