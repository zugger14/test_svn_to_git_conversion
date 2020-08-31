IF OBJECT_ID(N'spa_create_rec_settlement_report_paging', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_create_rec_settlement_report_paging]
 GO 





--EXEC spa_create_rec_settlement_report '95', null, null, null, null, '2004-01-01', '2006-02-05', null, 'd', 'e', NULL, 'john'
--EXEC spa_create_rec_settlement_report_paging '95', null, null, null, null, '2004-01-01', '2006-02-05', null, 'd', 'e', NULL, 'john'

CREATE PROCEDURE [dbo].[spa_create_rec_settlement_report_paging]
		@sub_entity_id varchar(100)=null, 
		@strategy_entity_id varchar(100) = NULL, 
		@book_entity_id varchar(100) = NULL, 
		@book_deal_type_map_id varchar(5000) = null,
		@source_deal_header_id varchar(5000)  = null,
		@deal_date_from varchar(20),
		@deal_date_to varchar(20),
		@counterparty_id int,
		@summary_option varchar(1), --s summary, d detail
		@int_ext_flag varchar(1),  -- i internal, e external, b both
		@type varchar(1) =  null, --'c' means current, 'a' means adjustment, and null means both
		@feeder_deal_id varchar(50)= NULL,	
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
	set @tempTable=dbo.FNAProcessTableName('paging_rec_settlement_report', @user_login_id,@process_id)
	--print @tempTable
	declare @sqlStmt varchar(5000)

if @flag='i'
begin

	if @summary_option='s'
	set @sqlStmt='create table '+ @tempTable+'( 
	sno int  identity(1,1),
	CounterParty varchar(500),
	[Settlement (+Rec, -Pay)] varchar(500)
	)'
	else
	set @sqlStmt='create table '+ @tempTable+'( 
	sno int  identity(1,1),
	CounterParty varchar(500),
	DealID varchar(500),
	RefDealID varchar(50),
	DealDate varchar(500),
	ProductionMonth varchar(500),
	Type varchar(500),
	Price varchar(500),
	Volume varchar(500),
	Unit varchar(500),
	BuySell varchar(500),
	Obligation varchar(500),
	[Settlement (+Rec, -Pay)] varchar(500)
	)'
	

	
	exec(@sqlStmt)
	
	set @sqlStmt=' insert  '+@tempTable+'
	exec spa_create_rec_settlement_report  '+ dbo.FNASingleQuote(@sub_entity_id ) +','+ 
	dbo.FNASingleQuote(@strategy_entity_id ) +',' +
	dbo.FNASingleQuote(@book_entity_id)+',' +
	dbo.FNASingleQuote(@book_deal_type_map_id )+',' +
	dbo.FNASingleQuote(@source_deal_header_id )+',' +
	dbo.FNASingleQuote(@deal_date_from )+',' +
	dbo.FNASingleQuote(@deal_date_to )+',' +
	dbo.FNASingleQuote(@counterparty_id  )+',' +
	dbo.FNASingleQuote(@summary_option  )+',' +
	dbo.FNASingleQuote(@int_ext_flag  )+',' +
	dbo.FNASingleQuote(@type)+',' +
	dbo.FNASingleQuote(@feeder_deal_id  )
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
if @summary_option='s'
set @sqlStmt='select 	CounterParty, [Settlement (+Rec, -Pay)]
		from '+ @tempTable  +' where sno between '+ cast(@row_from as varchar) +' and '+ cast(@row_to as varchar) + ' order by sno asc'
else
set @sqlStmt='select 	CounterParty,	DealID,	RefDealID,	DealDate,	ProductionMonth,	Type,	Price,	Volume,
	Unit, 	BuySell,	Obligation [Env Product],	[Settlement (+Rec, -Pay)]
		from '+ @tempTable  +' where sno between '+ cast(@row_from as varchar) +' and '+ cast(@row_to as varchar) + ' order by sno asc'
--print @sqlStmt
exec(@sqlStmt)
end







