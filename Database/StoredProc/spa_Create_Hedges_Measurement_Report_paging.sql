IF OBJECT_ID('spa_Create_Hedges_Measurement_Report_paging') IS NOT NULL
	DROP  PROCEDURE [dbo].[spa_Create_Hedges_Measurement_Report_paging]
GO




--===========================================================================================
--This Procedure create Measuremetnt Reports
--Input Parameters
--@as_of_date - effective date
--@sub_entity_id - subsidiary Id
--@strategy_entity_id - strategy Id
--@book_entity_id - book Id
--@discount_option - takes two values 'd' or 'u', corresponding to 'discounted', 'undiscounted' 
--@settlement_option -  takes 'f','c','s','a' corrsponding to 'forward', 'current & forward', 'current & settled', 'all' transactions
--@report_type - takes 'f', 'c',  corresponding to 'fair value', 'cash flow'
--@summary_option - takes 'd', 's' corresponding to 'detail' , 'summary' report
--===========================================================================================
create PROC [dbo].[spa_Create_Hedges_Measurement_Report_paging] 
	@as_of_date varchar(50), @sub_entity_id varchar(100), 
 	@strategy_entity_id varchar(100) = NULL, 
	@book_entity_id varchar(100) = NULL, @discount_option char(1), 
	@settlement_option char(1), @report_type char(1), @summary_option char(1),
	@link_id varchar(500) = null,
	@round_value varchar(1) = '0',
	@legal_entity varchar(20) = NULL,
	--WhatIf Changes
	@hypothetical varchar(1) = 'n',  --n means do not show hypothetical, o means only hypothetical and a means both
	@source_deal_header_id varchar(500)=NULL,
	@deal_id varchar(500)=NULL,	
	@term_start DATETIME=NULL,
	@term_end DATETIME=NULL,
	@link_id_to varchar(500) = null,
	@link_desc VARCHAR(500)=null,
	@process_id varchar(5000)=NULL,	
	@page_size int =NULL,
	@page_no int=NULL 
 AS
 SET NOCOUNT ON 



exec [dbo].[spa_Create_Hedges_Measurement_Report] 
	@as_of_date , 
	@sub_entity_id , 
 	@strategy_entity_id , 
	@book_entity_id , 
	@discount_option, 
	@settlement_option , 
	@report_type ,
	@summary_option ,
	@link_id ,
	@round_value ,
	@legal_entity ,
	--WhatIf Changes
	@hypothetical ,  --n means do not show hypothetical, o means only hypothetical and a means both
	@source_deal_header_id ,
	@deal_id ,	
	@term_start,
	@term_end,
	@link_id_to,
	@link_desc,
	@process_id, 
	null,'1',
	@page_size,
	@page_no 





/*











declare @user_login_id varchar(50),@tempTable varchar(300) ,@flag char(1)

	set @user_login_id=dbo.FNADBUser()

	if @process_id is NULL
	Begin
		set @flag='i'
		set @process_id=REPLACE(newid(),'-','_')
	End
	set @tempTable=dbo.FNAProcessTableName('paging_temp_Measurement_Report', @user_login_id,@process_id)
	declare @sqlStmt varchar(5000)

--Sub Strategy Book Counterparty DealNumber DealDate PNLDate Type Phy/Fin Expiration Cumulative FV 

if @flag='i'
begin
if @report_type='c' and @summary_option='m'
	set @sqlStmt='create table '+ @tempTable+'( 
		sno int  identity(1,1),
		Sub varchar(500),
		Strategy varchar(500),
		Book varchar(500),
		[Der/ITem] varchar(500),
		[Deal Ref ID] varchar(500),
		[Deal ID] varchar(1000),
		[Rel ID] varchar(1000),
		[DeDesig Rel ID] varchar(500),
		[Rel Type] varchar(500),
		Counterparty varchar(500),
		[Deal Date] varchar(500),
		[Rel Eff Date] varchar(500),
		[DeDesig Date] varchar(500),
		Term varchar(500),
		[%] varchar(500),
		Volume float,
		UOM varchar(500),
		[Index] varchar(500),
		DF float,
		[Deal Price] float,
		[Market Price] float,
		[Inception Price] float,
		Currency varchar(500),
		[Cum FV] float,
		[Cum Intrinsic FV] float,
		[Cum Extrinsic FV] float,
		[Cum Hedge FV] float,
		[Hedge AOCI Ratio] float,
		[Dollar Offset Ratio] float,
		Test varchar(500),
		AOCI float,
		PNL float,
		[AOCI Released] float,
		[PNL Settled] float
)'
else if @report_type='c'
	set @sqlStmt='create table '+ @tempTable+'( 
		sno int  identity(1,1),
		Sub varchar(500),
		Strategy varchar(500),
		Book varchar(500),
		[ID] varchar(500),
		[Group] varchar(500),
		Type varchar(500),
		Test varchar(500),
		Expiration varchar(100),
		HedgeAmount float,
		ItemAmount float,
		[ST Ast (Db)] float,
		[ST Liab (Cr)] float,
		[LT Ast (Db)] float,
		[LT Liab (Cr)] float,
		[AOCI (+Cr/-Db)] float,
		[PNL (+Cr/-Db)] float,
		[Earnings (+Cr/-Db)] float,
		[Total Earnings (+Cr/-Db)] float,
		[Cash (-Cr/+Db)] float
		)'
	else if @report_type='f'
	set @sqlStmt='create table '+ @tempTable+'( 
		sno int  identity(1,1),
		Sub varchar(500),
		Strategy varchar(500),
		Book varchar(500),
		[ID] varchar(500),
		[Group] varchar(500),
		Type varchar(500),
		Test varchar(500),
		Expiration varchar(100),
		HedgeAmount float,
		ItemAmount float,
		[H ST Ast (Db)] float,
		[H ST Liab (Cr)] float,
		[H LT Ast (Db)] float,
		[H LT Liab (Cr)] float,
		[I ST Ast (Db)] float,
		[I ST Liab (Cr)] float,
		[I LT Ast (Db)] float,
		[I LT Liab (Cr)] float,
		[PNL (+Cr/-Db)] float,
		[Earnings (+Cr/-Db)] float,	
		[Cash (-Cr/+Db)] float
		)'
	
		exec(@sqlStmt)

	set @sqlStmt=' insert  '+@tempTable+'
	exec  spa_Create_Hedges_Measurement_Report '+ 
	dbo.FNASingleQuote(@as_of_date) +','+ 
	dbo.FNASingleQuote(@sub_entity_id) +','+ 
	dbo.FNASingleQuote(@strategy_entity_id) +','+ 
	dbo.FNASingleQuote(@book_entity_id) +','+ 
	dbo.FNASingleQuote(@discount_option) +',' +
	dbo.FNASingleQuote(@settlement_option) +',' +
	dbo.FNASingleQuote(@report_type) +',' +
	dbo.FNASingleQuote(@summary_option)+',' +
	dbo.FNASingleQuote(@link_id)+',' +
	dbo.FNASingleQuote(@round_value)+',' +
	dbo.FNASingleQuote(@legal_entity)+',' +
	dbo.FNASingleQuote(@hypothetical)+','+
	dbo.FNASingleQuote(@source_deal_header_id)+','+
	dbo.FNASingleQuote(@deal_id);


	EXEC spa_print @sqlStmt
	exec(@sqlStmt)	
 
	set @sqlStmt='select count(*) TotalRow,'''+@process_id +''' process_id  from '+ @tempTable
	EXEC spa_print @sqlStmt
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
end

	if @report_type='c' and @summary_option='m'
	set @sqlStmt='select
		Sub ,
		Strategy ,
		Book ,
		[Der/ITem] ,
		[Deal Ref ID] ,
		[Deal ID],
		[Rel ID],
		[DeDesig Rel ID] ,
		[Rel Type] ,
		Counterparty ,
		[Deal Date] ,
		[Rel Eff Date] ,
		[DeDesig Date] ,
		Term ,
		[%] ,
		Volume,
		UOM,
		[Index] ,
		DF,
		[Deal Price] ,
		[Market Price] ,
		[Inception Price] ,
		Currency ,
		[Cum FV] ,
		[Cum Intrinsic FV] ,
		[Cum Extrinsic FV] ,
		[Cum Hedge FV] ,
		[Hedge AOCI Ratio] ,
		[Dollar Offset Ratio] ,
		Test ,
		AOCI ,
		PNL ,
		[AOCI Released] ,
		[PNL Settled] '
	else if @report_type='c'
	begin
		set @sqlStmt='select 
		Sub ,
		Strategy ,
		Book,
		[ID] ,
		[Group] ' + case when (@summary_option = 'l') then ' AS [H/HI Ratio], ' else ', ' end + '
		[Type] ,
		Test AS [Test (Eff Ratio)],
		Expiration ,
		HedgeAmount ,
		ItemAmount ,
		[ST Ast (Db)] ,
		[ST Liab (Cr)] ,
		[LT Ast (Db)] ,
		[LT Liab (Cr)] ,
		[AOCI (+Cr/-Db)] ,
		[PNL (+Cr/-Db)],
		[Earnings (+Cr/-Db)] ,
		[Total Earnings (+Cr/-Db)] ,
		[Cash (-Cr/+Db)] '
	end
	else if @report_type='f'
	begin
		set @sqlStmt='select 
		Sub ,Strategy ,Book ,[ID] ,	[Group], Type ,	Test ,Expiration ,	HedgeAmount ,
		ItemAmount ,[H ST Ast (Db)] ,[H ST Liab (Cr)] ,	[H LT Ast (Db)] ,[H LT Liab (Cr)] ,	[I ST Ast (Db)] ,
		[I ST Liab (Cr)] ,[I LT Ast (Db)] ,[I LT Liab (Cr)] ,[PNL (+Cr/-Db)] ,		[Earnings (+Cr/-Db)] ,	
		[Cash (-Cr/+Db)] '
	end
set @sqlStmt=@sqlStmt +'	   from '+ @tempTable  +' where sno between '+ cast(@row_from as varchar) +' and '+ cast(@row_to as varchar)+ ' order by sno asc'

		EXEC spa_print @sqlStmt
		exec(@sqlStmt)











GO
*/